Generated from https://www.evtivity.com/docs/csms/reservations (website commit 257c8b8). Do not edit.

# Reservations

Reserve connectors for drivers and manage reservation lifecycle.

## Overview

Reservations allow drivers or operators to reserve a specific EVSE at a station for a future time. The CSMS sends OCPP ReserveNow commands to stations and tracks the reservation through its lifecycle.

![Reservations list](https://www.evtivity.com/screenshots/csms/reservations-list.png)

## Create a Reservation

1. Navigate to **Reservations** in the sidebar.
2. Click **Create Reservation**.
3. Select a station and EVSE.
4. Select a driver.
5. Set the start time and expiry time.
6. Click **Create**.

![Create reservation](https://www.evtivity.com/screenshots/csms/reservations-create.png)

### Scheduled Reservations

If the start time is in the future, the reservation is created with a **scheduled** status. The CSMS does not send the OCPP ReserveNow command immediately. Instead, a background worker job fires at the scheduled start time, sends ReserveNow to the station, and updates the status to **active**.

### Immediate Reservations

If the start time is now or in the past, the CSMS sends the ReserveNow command to the station immediately. If the station accepts, the reservation becomes **active**.

## Batch Reservations

For reserving multiple stations at once on behalf of a fleet, use the **Bulk Reservations** tab on the fleet detail page. The same date controls and conflict checks apply, and each slot can be assigned to a different driver.

See [Fleets &rarr; Bulk Reservations](https://www.evtivity.com/docs/csms/fleets#bulk-reservations) for the full workflow.

## Reservation Detail

Click any reservation in the list to view its detail page.

![Reservation detail](https://www.evtivity.com/screenshots/csms/reservation-detail.png)

The detail page has the following tabs:

- **Details** - station, EVSE, driver, token (linked to its detail page when bound), time range, current status, and the cancel action.
- **Session** - the linked charging session when one exists (status `in_use` or `used`).
- **History** - paginated `reservation_audit_log` with the action (created / updated / cancelled / expired / used / session_failed), the actor name (operator or driver, linked to their detail page), and a field-by-field diff of `driverId`, `tokenId`, `evseId`, `expiresAt`, and `status`.
- **OCPP Logs** - the OCPP ReserveNow / CancelReservation commands the CSMS dispatched for this reservation, with their results.

## Audit Trail

Every reservation mutation writes to `reservation_audit_log`. The History tab on the detail page is the operator-facing view; the same data is exposed via `GET /v1/reservations/:id/audit`.

| Action | Triggered by |
|--------|--------------|
| `created` | Operator POST, portal POST, fleet bulk POST, or worker delayed activation for scheduled reservations |
| `updated` | Operator PATCH that changed `driverId`, `tokenId`, `evseId`, or `expiresAt`; operator reassign to a different station; or system linkage when a charging session starts and consumes the reservation |
| `cancelled` | Operator, driver, or system cancel - see the cancellation metadata section below |
| `expired` | Expiry cron (`expires_at` passed) or station-reported `ReservationStatusUpdate(Expired)` |
| `used` | A linked charging session entered the `active` state - the reservation transitions `active &rarr; in_use` |
| `session_failed` | A charging session linked to this reservation ended in `faulted` or `failed` state. Written from every fault path: stale-session sweep, `EVConnectTimeout` on start, payment-gate eager cleanup, and the `TransactionEvent.Ended` handler. The reservation status itself stays `in_use` - the audit row records that the attempt did not produce a billable session, with the fault reason in the notes column. |

Each audit row includes the actor (`operator`, `driver`, or `system`) with the linked user or driver, and a before/after diff for any of the mutable fields above.

## Cancel a Reservation

1. Open the reservation detail page.
2. Click **Cancel Reservation**.
3. In the confirmation dialog, optionally tick **Charge cancellation fee** (operator opt-in, defaults to off) and add a free-text note describing why you are cancelling.
4. Confirm the cancellation.

For active reservations, the CSMS sends an OCPP CancelReservation command to the station. For scheduled reservations (not yet sent to the station), the cancellation is database-only. Either way, the cancel writes the actor and reason metadata described below.

## Cancellation Metadata

Every cancelled reservation carries four audit fields:

| Field | Description |
|-------|-------------|
| `cancelled_by` | Who killed it - `driver`, `operator`, or `system` |
| `cancel_reason` | Typed enum (see below) describing why |
| `cancel_note` | Optional operator free-text note (max 500 chars) |
| `cancellation_fee_cents` | Fee actually charged (`0` when waived, no payment method, or charge attempt failed) |

Cancel reasons:

| Reason | When it fires |
|--------|---------------|
| `driver_initiated` | Driver cancelled from the portal |
| `operator_manual` | Operator cancelled from the dashboard |
| `expired_no_show` | Reservation reached `expires_at` without being used |
| `station_rejected_occupied` | Station replied `Occupied` to ReserveNow |
| `station_rejected_other` | Station replied with another non-Accepted status, or the request timed out |
| `station_offline_at_activation` | The worker tried to dispatch ReserveNow at `startsAt` but the station was offline |
| `system_cleanup` | Station-side `ReservationStatusUpdate(Removed)` arrived (operator pressed cancel on the station, fault, etc.) |

Existing rows cancelled before this metadata was introduced have `NULL` actor and reason fields.

### Where it shows up

- **Reservation detail page** displays the actor, reason, optional note, and fee whenever the reservation is in `cancelled` state.
- **Driver detail page** has a **Reservations** tab (hidden when `reservation.enabled` is off) listing the driver's reservations with the cancel-reason column populated.
- **API response** for `GET /v1/reservations/:id` and `GET /v1/drivers/:id/reservations` includes `cancelledBy`, `cancelReason`, `cancelNote`, `cancellationFeeCents` on every row.

## Reservation Statuses

| Status | Description |
|--------|-------------|
| scheduled | Future reservation, not yet sent to the station |
| active | ReserveNow accepted by the station |
| used | Driver started a session using this reservation |
| expired | Reservation expired without being used |
| cancelled | Cancelled by operator, driver, or system (see metadata above) |
| rejected | Station rejected the ReserveNow command |

## OCPP Flow

The reservation flow depends on the OCPP version. Both versions are fully supported by the CSMS, including the holding-fee accounting described below.

**OCPP 2.1**: The CSMS sends `ReserveNow` with `idToken`, `evseId`, and `expiryDateTime`. The station responds with Accepted or Rejected.

**OCPP 1.6**: The CSMS sends `ReserveNow` with `idTag`, `connectorId`, `reservationId`, and `expiryDate`. The command translation layer in `command-translation.ts` handles version-specific field mapping.

The fee logic below operates on the CSMS-side `charging_sessions` and `tariffs` tables, not on OCPP wire fields. Both 1.6 and 2.1 stations flow through the same normalized `ocpp.TransactionEvent` projection, so the in-session holding fee, no-show fee, and cancellation fee all apply identically regardless of station protocol.

## Reservation Fees

Three independent fee paths apply to reservations. Each can be enabled or disabled by an operator.

### Payment Method Required

A driver default payment method is required to create a reservation. The portal blocks reserve creation when the holder has no card on file. The operator route returns `400 PAYMENT_METHOD_REQUIRED` when a driver-attached reservation has no default card. This is the safety net for the holding and cancellation fees below.

Operator-comp reservations created without a `driverId` skip this check and incur no fee.

### Cancellation Fee

A flat per-cancel charge applied to the driver's default payment method when the holder cancels close to the start time.

Settings (Settings > Integrations & Features > Reservation):

- `reservation.cancellationFeeCents` - flat fee in cents, excluding tax. Default `0` (off). The tax rate of the station's tariff for the driver is added when the fee is charged.
- `reservation.cancellationWindowMinutes` - window before `startsAt` during which the fee applies. Default `0` (off).

The fee fires when all of the following hold: the system fee is greater than zero, the system window is greater than zero, the reservation has a `driverId`, the cancel happens with `minutesUntilStart` less than `cancellationWindowMinutes`, and the driver has a default card. Charged via a one-shot Stripe PaymentIntent with idempotency key `cancellation-fee-{reservationId}`. The amount charged includes tax and is stored on the reservation.

#### Who pays

The actor that triggered the cancel decides whether the fee is even considered:

| Actor | Behaviour |
|-------|-----------|
| `driver` | Always evaluates the window check above. Pays the fee when inside the window. |
| `operator` | **Opt-in.** The operator must tick **Charge cancellation fee** in the cancel dialog. Defaults to off so a typical operator-side cancel does not surprise-bill the driver. The window check still applies on top of the opt-in. |
| `system` | **Never charges.** System paths (station rejected ReserveNow, station offline at activation time, station-side `ReservationStatusUpdate(Removed)`) always waive the fee. |

#### Charge attempt failures

The audit row writes `cancellation_fee_cents = 0` first; only after Stripe confirms is it updated to the actual amount. If the Stripe charge throws (declined card, expired card, network error), the row stays at `0` and the API response includes `feeChargeFailed: true` so the caller knows to reconcile against Stripe. The cancellation itself still succeeds - the reservation is gone whether or not the fee was collected.

Both the CSMS detail tab and the portal detail page render a "Cancellation policy" card when the policy is active, and the cancel-confirm dialog adds a fee warning when the cancel will fall inside the window, for example "A cancellation fee of $5.00 plus applicable tax will be charged to the driver's default payment method."

### Tax, payment records, and revenue

Both fees are priced excluding tax and taxed at the tax rate of the station's tariff for the driver. Each charge:

- Creates a payment record (`reservation_cancellation` or `reservation_no_show`) with the tax rate, before the charge. A retry or a concurrent call for the same reservation and fee type charges nothing.
- Goes through the site's Stripe connected account with the platform fee of its net amount.
- Counts in revenue (split into net and tax at its own rate) and appears as a line on the driver's aggregated invoice.

### No-Show Holding Fee

Per-minute charge for the time the connector was held when the holder reserved but never plugged in.

Per-tariff field: `tariffs.reservation_fee_per_minute` (decimal dollars per minute, configured in the tariff editor). Applies to both OCPP 1.6 and 2.1 stations - the rate is read from the resolved tariff and multiplied by the held minutes regardless of which protocol the station speaks.

The reaper job `reservation-expiry-check` runs every minute. When an `active` reservation expires WITHOUT a linked charging session and the resolved tariff has a non-zero rate:

```
holdingMinutes  = ceil((expiresAt - startsAt) / 60_000)
amountCents     = round(holdingMinutes * ratePerMinute * 100)
```

The amount is net. The tax rate of the tariff is added, and the gross is charged to the driver's saved card through its payment provider with idempotency key `no-show-fee-{reservationId}`. Skipped when the holder actually charged (the rate already feeds into the session cost via the tariff resolver), the reservation has no `driverId`, the rate is zero, or the driver has no default card.

### In-Session Holding Fee

When the holder DOES plug in, the same per-tariff `reservation_fee_per_minute` is rolled into the session cost. Computed in the `TransactionEvent.Started` projection as `holdingMinutes * tariff.reservationFeePerMinute`, taxed normally, and captured via the standard pre-auth / capture flow.

This is the in-band path of the no-show fee - the same rate applies whether or not the holder actually charges.

## Connector Pre-Block (Buffer)

`reservation.bufferMinutes` reserves the connector for the holder slightly before the official `startsAt`, so a walk-up driver cannot grab the connector right before the reservation begins. Default `0` (off).

When greater than zero, any portal driver-start or guest-start request on an EVSE whose next reservation has a `startsAt` within `[now, now + bufferMinutes]` is rejected with `409 RESERVATION_BUFFER_ACTIVE` and the message `This connector has an upcoming reservation and cannot start a new session`. The portal and guest checkout pages show the driver the translated message for this code.

Example with `bufferMinutes = 15`: Driver A holds a reservation starting at 3:00 PM. At 2:50 PM, Driver B taps the QR code at the same connector. The buffer check fires (10 minutes is inside the 15-minute window) and Driver B is rejected.

## Three-Level Enablement

Reservations can be turned off at three levels. The API checks all three on every create / reassign request (operator dashboard, portal driver, fleet bulk):

1. **Global** - `reservation.enabled` setting (Settings > Integrations & Features > Reservation).
2. **Site** - `sites.reservations_enabled` column (Site detail → Reservations toggle).
3. **Station** - `charging_stations.reservations_enabled` column (Station detail → Reservations toggle).

If any level is disabled, the create returns `403 RESERVATION_DISABLED` with a level-specific message. Existing active reservations continue to enforce their hold and expiry independently of the toggles - turning a level off only blocks new creates.

## System Settings

Settings > Integrations & Features > Reservation:

| Setting | Default | Effect |
|---------|---------|--------|
| `reservation.enabled` | `true` | System-wide kill switch. When `false`, no new reservations can be created and existing ones are not enforced. |
| `reservation.bufferMinutes` | `0` | Pre-block window in minutes before `startsAt`. New driver / guest sessions on the EVSE are rejected with `RESERVATION_BUFFER_ACTIVE` while the reservation is approaching. `0` disables the pre-block. |
| `reservation.cancellationFeeCents` | `0` | Flat cancellation fee in cents, excluding tax, charged with the tariff tax rate added to the driver's default payment method when they cancel inside the cancellation window. `0` disables the fee. |
| `reservation.cancellationWindowMinutes` | `0` | Window in minutes before `startsAt` during which a cancellation triggers the fee above. Outside the window the cancel is free. `0` disables the late-cancel fee. |
| `reservation.maxHours` | `3` | Maximum reservation duration in hours (`expiresAt - startsAt`). Create routes return `400 RESERVATION_TOO_LONG` when exceeded. Both UIs show the cap as a hint near the date pickers. `0` disables the cap. |

Cached reads: `getReservationSettings()` (60-second TTL).

## Time Window Validation

The API rejects reservations with malformed time windows:

| Code | Condition |
|------|-----------|
| `RESERVATION_WINDOW_TOO_SHORT` | The window is less than 60 seconds (`expiresAt - startsAt`) |
| `RESERVATION_EXPIRES_TOO_SOON` | `expiresAt` is less than 60 seconds in the future |
| `RESERVATION_STARTS_IN_PAST` | `startsAt` is more than 60 seconds in the past |
| `RESERVATION_TOO_LONG` | The window exceeds `reservation.maxHours` |
| `RESERVATION_CONFLICT` | The window overlaps an existing active or scheduled reservation on the same connector |
