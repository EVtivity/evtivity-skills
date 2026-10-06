Generated from https://www.evtivity.com/docs/guides/reservations (website commit 0f3462e). Do not edit.

# Charging Reservations

How EV charger reservations work across the industry, what OCPP standardizes, and how EVtivity implements scheduled and immediate reservations.

This guide explains how a driver claims a charger ahead of time and what has to happen on the CSMS, the network, and the station for that claim to actually hold up when the driver arrives. It starts with the industry pattern that most networks share, then describes the EVtivity-specific implementation.

## Why reservations are hard

Reservations look simple on the surface - the driver picks a charger and a time window, and nobody else can use it during that window. The actual implementation has to handle a stack of edge cases that don't exist in regular charging:

- The station might be offline when the reservation is created. The CSMS has to remember the intent and dispatch later.
- The driver might be late. There needs to be a definite expiry the station enforces, otherwise a no-show blocks the connector forever.
- Another driver might walk up before the reserving driver arrives. The station has to recognize the reserving driver's token (RFID or app session) and reject everyone else.
- The driver might cancel. The CSMS has to clear the hold on the station and (optionally) charge a cancellation fee.
- The session might still be running when the reservation window ends. Most networks let the in-progress session finish; the reservation just transitions to "used".
- Multiple OCPP versions are in play. 1.6 and 2.1 use different commands and different ID semantics for the same concept.

What follows is the design that emerged once these cases got hammered out over a few years of OCPI and operator-network experience.

## How EV reservations work in the industry

Most production charging networks model a reservation with the same five primitives:

1. **A reservation record on the CSMS.** Stores who reserved what, when it starts, when it expires, and the current state. This is the source of truth.
2. **A `ReserveNow` command sent to the station.** Tells the station to lock the connector for a specific token holder until a specific time. OCPP 1.6 and 2.1 both define this command.
3. **A reservation ID** that the station echoes back when the driver later arrives and starts a transaction. The CSMS uses the ID to match the session to the reservation.
4. **Token-based access control on the station side.** The station only accepts authorization from the reserved token (RFID UID, ISO 15118 contract, or whatever the driver presented when reserving). All other tokens get rejected with a "reserved" error until the reservation expires.
5. **A scheduler that fires `ReserveNow` at the right time and `CancelReservation` when something changes.** The CSMS doesn't hold a thread for every future reservation; it queues them and dispatches when the start time arrives.

### The lifecycle

![EV charging reservation lifecycle](https://www.evtivity.com/images/reservation-lifecycle.png)

The reservation walks through one of three terminal states from the moment it's created:

| State        | Meaning                                                                                              |
|--------------|------------------------------------------------------------------------------------------------------|
| `scheduled`  | Created with a future start time. No `ReserveNow` sent yet. The CSMS waits.                          |
| `active`     | `starts_at` passed and `ReserveNow` was dispatched (or the reservation was created starting "now").  |
| `in_use`     | The reserved driver authorized at the station and a charging session is running.                    |
| `used`       | The session finished cleanly inside the reservation window.                                          |
| `cancelled`  | Driver or operator cancelled before or during the window. `CancelReservation` was sent.              |
| `expired`    | `expires_at` passed without the driver showing up. Station auto-released the connector.              |

Networks typically charge a no-show or cancellation fee when the reservation transitions to `cancelled` or `expired`. The fee is captured against the payment method the driver provided when they made the reservation.

### Where networks differ

The five primitives above are common, but the surface area around them varies. The big variables:

- **Immediate vs. scheduled reservations.** Some networks only allow "reserve right now for the next 15 minutes" (immediate). Others support arbitrary future windows. Scheduled reservations need the worker queue described below; immediate reservations can short-circuit straight to `active`.
- **No-show fees.** Capture a card pre-auth at reservation creation, then capture or void at expiry depending on whether the driver showed up. Some networks skip this for first-time guests.
- **Hardware support.** Older 1.6 stations sometimes ignore `ReserveNow` entirely or honor it inconsistently. Networks running mixed fleets either fall back to soft-reserve (CSMS-only intent, no station-level lock) or refuse to offer reservations on legacy hardware.
- **Token binding.** Strictest implementations bind the reservation to a single RFID UID. Looser ones accept any token belonging to the reserving driver. The looser variant is friendlier when drivers forget which card they used.
- **Roaming reservations.** OCPI 2.2.1 defines `RESERVE_NOW` and `CANCEL_RESERVATION` commands so an eMSP can reserve on a CPO's station the same way they can request a remote start. Networks that participate in roaming must accept these inbound commands and emit them outbound to peer CPOs.

## How EVtivity implements reservations

EVtivity uses the industry-standard model above, with a few specific design choices that make scheduled reservations work cleanly in a multi-pod deployment.

### Storage model

Reservations live in `reservations` with the OCPP-style integer `reservation_id` plus the EVtivity nanoid PK. Status is the enum described above (`scheduled` -> `active` -> `in_use`/`used`/`cancelled`/`expired`). Every reservation references the station, the optional EVSE, the optional driver, the time window, and the optional `session_id` once the driver actually arrives and starts charging.

`scheduled` was added specifically so the CSMS can hold a reservation that hasn't been pushed to the station yet without confusing UI code or operators reviewing the list.

### Endpoints

Operators manage reservations from the dashboard, drivers manage their own from the portal. Both flows hit the same routes under different prefixes:

- `GET /v1/reservations` - paginated list, filterable by status / station / driver.
- `POST /v1/reservations` - create one. Body specifies station, optional EVSE, optional driver, `startsAt`, `expiresAt`. A future `startsAt` skips the OCPP dispatch and inserts the row in `scheduled`.
- `DELETE /v1/reservations/:id` - cancel. Sends `CancelReservation` to the station only when the row is `active` (scheduled rows never reached the station).
- Driver portal mirrors above under `/v1/portal/reservations`. The driver can only see and cancel their own.

### Bulk reservations

Fleet operators sometimes want to reserve a row of stations for a yard or a delivery hub. EVtivity exposes a bulk reservation endpoint on a Fleet that accepts a list of `(stationId, evseId, driverId)` slots and the same `startsAt` / `expiresAt` window. Each slot is processed independently - failures in one slot don't roll back the others - and the bulk row stays alive carrying whichever slots succeeded.

### The scheduler

A `scheduled` reservation can't just live in the database hoping the API process notices when its start time arrives. It needs a durable scheduler that survives pod restarts and fires once per reservation across a horizontally scaled cluster.

EVtivity uses BullMQ on the existing Redis instance. When the API creates a reservation with a future `startsAt`, it publishes to the `reservation_schedule` channel. A worker subscribes, creates a delayed BullMQ job, and at `startsAt` the job fires `handleReservationActivate()` which:

1. Re-reads the reservation row to make sure it's still `scheduled` (it may have been cancelled in the meantime).
2. Sends `ReserveNow` to the station via the standard `ocpp_commands` pubsub bridge with version-specific command translation.
3. Updates the row to `active` and stamps a `reservation_id` integer that matches what the station now holds.

If the station rejects `ReserveNow` (offline, faulted, occupied), the row stays `scheduled` and the worker retries on the next BullMQ attempt. After all retries fail, the reservation transitions to `failed` and the driver gets notified.

### Cancellation and expiry

Three different paths can take a reservation out of `active`:

- **Driver or operator cancel.** API receives `DELETE`. If the row is `active`, dispatches `CancelReservation` to the station, then sets `cancelled`. Scheduled rows skip the OCPP step.
- **Session start during the window.** When `TransactionEvent.Started` arrives with the matching `reservationId`, the projection updates the reservation to `in_use` and links the resulting `session_id`. When the session ends, the reservation moves to `used`.
- **No-show.** The OCPP server runs a periodic check (only on the primary pod) that looks for `active` reservations whose `expires_at` has passed without a session. It marks them `expired` and lets the station release the connector on its own timer. A `reservation.Expired` notification is dispatched if the reservation had a driver attached and email/SMS was enabled.

#### Cancel actor and reason

Every cancel - regardless of which path triggered it - writes four audit columns on the row: `cancelled_by` (`driver` / `operator` / `system`), `cancel_reason` (typed enum), `cancel_note` (operator free-text), and `cancellation_fee_cents` (the amount actually captured, `0` when waived).

The reason enum is the source of truth for "why did this row die":

| Reason | Path |
|--------|------|
| `driver_initiated` | Portal `DELETE /v1/portal/reservations/:id` |
| `operator_manual` | Operator dashboard `DELETE /v1/reservations/:id` |
| `expired_no_show` | `reservation-expiry-check` cron after `expires_at` |
| `station_rejected_occupied` | Station replied `Occupied` to ReserveNow |
| `station_rejected_other` | Station replied with another non-Accepted status, or the request timed out |
| `station_offline_at_activation` | Worker tried to dispatch ReserveNow at `startsAt` but the station was offline |
| `system_cleanup` | Station-initiated `ReservationStatusUpdate(Removed)` |

All cancel paths route through a single helper (`packages/api/src/lib/reservation-cancel.ts`) so the metadata is consistent and concurrency-safe. The helper performs a conditional UPDATE filtered on `status IN ('active','scheduled')`, so two concurrent cancels are safe: only one wins; the loser sees `cancelled: false` and skips the fee dispatch. The Stripe charge runs only after a successful UPDATE.

System paths (the bottom three reasons above) hard-block the fee: even if a caller passes `chargeFee: true`, the helper short-circuits to `wantsFee = chargeFee && actor !== 'system'`. Operator-initiated cancels are opt-in (the dashboard cancel dialog has a checkbox), so a typical operator action does not bill the driver.

### Fees

Reservation creation **requires** a default payment method on a driver-attached reservation but does **not** place a Stripe hold at that point - it only verifies the card exists. There is no PaymentIntent until a fee actually fires.

- **No-show fee** is charged by the `reservation-expiry-check` cron job (`packages/worker/src/handlers/reservation-expiry-check.ts`, runs every minute) when an `active` reservation reaches `expires_at` without a linked session. The handler creates a fresh off-session `PaymentIntent` (`confirm: true, off_session: true`) against the saved customer and payment method, sized as `holdingMinutes * tariff.reservationFeePerMinute` (net) plus the tariff tax rate. Idempotency keyed on the reservation id so retries don't double-charge.
- **Cancellation fee** fires from the cancel endpoint only when (1) the actor is `driver` or `operator` (system paths always waive), (2) the operator opted in via `chargeCancellationFee: true` in the request body when the actor is `operator` (drivers always opt in), (3) `cancellationFeeCents > 0` (net, the tariff tax rate is added) and `cancellationWindowMinutes > 0`, (4) the reservation has a driver attached, and (5) the cancellation lands inside the window.

Both fees are stand-alone Stripe charges, not captures of a prior pre-auth. Each one gets a payment record with its tax rate, counts in revenue, and is invoiced on the driver's aggregated invoice. The session cost on `used` is billed through the regular charging-session payment flow with its own pre-auth and capture.

The cancellation-fee write order is deliberately "audit conservative": the conditional UPDATE writes `cancellation_fee_cents = 0`, then a second UPDATE writes the actual amount only after Stripe confirms. A process crash between charge and the second UPDATE leaves the row showing `0` while Stripe holds the money - recoverable via the daily Stripe reconciliation cron, which detects the drift. The opposite write order would leak a row claiming a fee that was never collected. When Stripe throws (declined card, etc.), the API response includes `feeChargeFailed: true` so the caller can surface the reconciliation hint to the user; the cancel itself still succeeds.

### Roaming

EVtivity exposes `RESERVE_NOW` and `CANCEL_RESERVATION` on its OCPI 2.2.1 CPO commands receiver. When a peer eMSP sends one, the OCPI service resolves the `location_id` and `evse_uid` (the EVSE's internal id, unique across the network) to an EVtivity station + EVSE, validates the partner token, and goes through the same `POST /v1/reservations` path as a local operator would. Outbound, EVtivity emits the same commands toward partner CPOs when one of its drivers reserves on a roaming station. The async result (accepted/rejected/timeout) flows back through the OCPI command callback service.

## Related

- [Smart Charging](https://www.evtivity.com/docs/guides/smart-charging) - power-shaping siblings of reservations; both use OCPP commands but for different purposes.
- [Charging Session Lifecycle](https://www.evtivity.com/docs/guides/station-lifecycle) - what happens after the reserved driver actually plugs in.
- [Notifications](https://www.evtivity.com/docs/guides/notifications) - templates for `reservation.Created`, `reservation.Cancelled`, `reservation.Expiring`, `reservation.Expired`.
