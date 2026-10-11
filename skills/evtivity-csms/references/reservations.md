Generated from https://www.evtivity.com/docs/csms/reservations. Do not edit.

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

If the start time is in the future, the reservation is created with a **scheduled** status. The CSMS does not send the OCPP ReserveNow command immediately. Instead, a background worker job fires at the scheduled start time, sends ReserveNow to the station, and updates the status to **active**. The expiry check also activates a scheduled reservation whose start time has passed, so a lost activation job does not leave it scheduled.

A scheduled reservation counts as held on the station only once the station accepts ReserveNow. If the station refuses it, the reservation is cancelled without a fee.

### Immediate Reservations

If the start time is now or in the past, the CSMS sends ReserveNow to the station and waits for the answer. The station must be online.

- The station accepts: the reservation is **active** and the station holds the EVSE.
- The station refuses: the reservation is cancelled as **Station rejected: occupied** or **Station rejected**, with no fee. The API answers `400 RESERVATION_REJECTED`.
- The station does not answer: the reservation is cancelled as **Station did not respond**, with no fee. The CSMS also sends CancelReservation, so a late acceptance does not keep the EVSE held. The API answers `504 RESERVATION_TIMEOUT`.

ReserveNow carries the token bound to the reservation. A new reservation binds the driver's most recently used active token, so the driver's RFID card starts on the held EVSE. A driver without a token is reserved under the driver ID, the same ID a portal start uses.

Two reservations created at the same moment for the same window cannot both succeed. The second one gets `409 RESERVATION_CONFLICT`.

## Batch Reservations

For reserving multiple stations at once on behalf of a fleet, use the **Bulk Reservations** tab on the fleet detail page. The same date controls and conflict checks apply, and each slot can be assigned to a different driver.

See [Fleets &rarr; Bulk Reservations](https://www.evtivity.com/docs/csms/fleets#bulk-reservations) for the full workflow.

## Reservation Detail

Click any reservation in the list to view its detail page.

![Reservation detail](https://www.evtivity.com/screenshots/csms/reservation-detail.png)

### Insight and Explain

When an [AI insight](https://www.evtivity.com/docs/csms/ai-insights) covers the reservation, its card shows above the tabs. Reservation insights cover a station that refused or never confirmed the hold, a no-show, a station cancel that failed, a failed fee, and a station that faulted during the hold. **Explain** opens the AI assistant about this reservation. It shows for an expired reservation, a reservation cancelled for a station reason, and a reservation with a failed fee. The card and **Explain** show only while reservations are turned on.

![Reservation insight](https://www.evtivity.com/screenshots/csms/reservation-insight.png)

### Tabs

The detail page has the following tabs:

- **Details** - station, EVSE, driver, token (linked to its detail page when bound), time range, current status, and the cancel action.
- **Session** - the linked charging session when one exists (status `in_use` or `used`).
- **History** - paginated `reservation_audit_log` with the action (see the table below), the actor name (operator or driver, linked to their detail page), and a field-by-field diff of `driverId`, `tokenId`, `evseId`, `expiresAt`, and `status`.
- **OCPP Logs** - the OCPP ReserveNow / CancelReservation commands the CSMS dispatched for this reservation, with their results.

## Audit Trail

Every reservation mutation writes to `reservation_audit_log`. The History tab on the detail page is the operator-facing view; the same data is exposed via `GET /v1/reservations/:id/audit`.

| Action | Triggered by |
|--------|--------------|
| `created` | Operator POST, portal POST, or fleet bulk POST |
| `activated` | The worker sent ReserveNow for a scheduled reservation at its start time |
| `updated` | Operator PATCH that changed `driverId`, `tokenId`, `evseId`, or `expiresAt`, operator reassign to a different station, or an edit the station did not answer, after which the CSMS sent the previous hold again |
| `cancelled` | Operator, driver, or system cancel - see the cancellation metadata section below |
| `station_rejected` | The station refused ReserveNow or did not answer. The reason names which |
| `station_cancel_failed` | The station refused CancelReservation, did not answer, or was offline. The reservation stays cancelled |
| `station_faulted` | The station went offline or a connector faulted during the hold. The reservation is cancelled without a fee |
| `expired` | Expiry cron (`expires_at` passed) or station-reported `ReservationStatusUpdate(Expired)`. The reason says whether it was a no-show |
| `used` | A linked charging session started (`active &rarr; in_use`) or ended (`in_use &rarr; used`) |
| `taken_by_other` | Another driver started a session on the held EVSE. The holder is notified and no no-show fee applies |
| `fee_charged` | A cancellation or no-show fee was charged |
| `fee_failed` | A fee charge failed: declined, no payment method, or a provider error |
| `session_failed` | A charging session linked to this reservation ended in `faulted` or `failed` state. Written from every fault path: stale-session sweep, `EVConnectTimeout` on start, payment-gate eager cleanup, and the `TransactionEvent.Ended` handler. The reservation status itself stays `in_use` - the audit row records that the attempt did not produce a billable session, with the fault reason in the notes column. |

Each audit row includes the actor (`operator`, `driver`, or `system`) with the linked user or driver, and a before/after diff for any of the mutable fields above.

## Cancel a Reservation

1. Open the reservation detail page.
2. Click **Cancel Reservation**.
3. In the confirmation dialog, optionally tick **Charge cancellation fee** (operator opt-in, defaults to off) and add a free-text note describing why you are cancelling.
4. Confirm the cancellation.

The CSMS saves the cancellation first. For an active reservation it then sends an OCPP CancelReservation command to the station and waits for the answer. A scheduled reservation never reached the station, so its cancellation is database-only. Either way, the cancel writes the actor and reason metadata described below.

When the station refuses the cancel, does not answer, or is offline, the reservation stays cancelled. The **History** tab records **Station cancel failed**, and the API response carries `warning: station_cancel_failed`. The station can still hold the EVSE until the reservation expires.

## Edit and Reassign

**Reassign Station** moves an active or scheduled reservation to another station. To change the EVSE on the same station, edit the reservation instead. Edit and reassign run the same checks as a create:

- The new window or station must not overlap another reservation (`409 RESERVATION_CONFLICT`).
- A cancelled, expired, or used reservation cannot be edited or reassigned (`RESERVATION_NOT_ACTIVE`).
- For an active reservation, the CSMS sends ReserveNow again with the new values. On an edit, a refusal or a missing answer keeps the previous values. On a reassign, the new station must accept first. The CSMS then moves the reservation and sends CancelReservation to the old station.
- A scheduled reservation moves in the database only. The worker sends ReserveNow at the start time.

## Cancellation Metadata

Every cancelled reservation carries four audit fields:

| Field | Description |
|-------|-------------|
| `cancelled_by` | Who killed it - `driver`, `operator`, or `system` |
| `cancel_reason` | Typed enum (see below) describing why |
| `cancel_note` | Optional operator free-text note (max 500 chars) |
| `cancellation_fee_cents` | Fee actually charged (`0` when waived, no payment method, or charge attempt failed) |

Cancel reasons, with the label the dashboard shows:

| Reason | Label | When it fires |
|--------|-------|---------------|
| `driver_initiated` | **Driver cancelled** | Driver cancelled from the portal |
| `operator_manual` | **Operator cancelled** | Operator cancelled from the dashboard |
| `expired_no_show` | **Expired (no-show)** | Reservation reached `expires_at` without being used |
| `station_rejected_occupied` | **Station rejected: occupied** | Station replied `Occupied` to ReserveNow |
| `station_rejected_other` | **Station rejected** | Station replied with another non-Accepted status, or the command could not be sent |
| `station_no_response` | **Station did not respond** | Station did not answer ReserveNow, or the station went offline before the command reached it |
| `station_offline_at_activation` | **Station offline at activation** | The worker tried to dispatch ReserveNow at `startsAt` but the station was offline |
| `evse_in_use_at_activation` | **EVSE in use at activation** | At `startsAt` the reserved EVSE was busy (another session or a plugged-in cable) |
| `station_faulted_at_activation` | **Station faulted at activation** | At `startsAt` every connector of the reserved EVSE was faulted or unavailable |
| `station_unavailable_during_hold` | **Station unavailable during the reservation** | The station went offline, or a connector reported Faulted, while the reservation was active |
| `system_cleanup` | **System cleanup** | Station-side `ReservationStatusUpdate(Removed)` arrived (operator pressed cancel on the station, fault, etc.) |

### Station Outage During a Reservation

When a station goes offline, or a connector reports Faulted, while a reservation is active, the CSMS cancels the reservation as `system` with **Station unavailable during the reservation**. No fee is charged. The CSMS sends CancelReservation to the station and notifies the driver that no fee applies. A reservation that is already in use keeps running.

Existing rows cancelled before this metadata was introduced have `NULL` actor and reason fields.

### Where it shows up

- **Reservation detail page** displays the actor, reason, optional note, and fee whenever the reservation is in `cancelled` state.
- **Driver detail page** has a **Reservations** tab (hidden when `reservation.enabled` is off) listing the driver's reservations with the cancel-reason column populated.
- **API response** for `GET /v1/reservations/:id` and `GET /v1/drivers/:id/reservations` includes `cancelledBy`, `cancelReason`, `cancelNote`, `cancellationFeeCents` on every row.

## Reservation Statuses

| Status | Description |
|--------|-------------|
| scheduled | Future reservation, not yet sent to the station |
| active | Sent to the station with ReserveNow. The EVSE is held until `expiresAt` |
| in_use | The reserved driver's charging session is running |
| used | The session that used this reservation has ended |
| expired | Reservation expired without being used |
| cancelled | Cancelled by operator, driver, or system, including a station that rejected ReserveNow (see metadata above) |

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

- `reservation.cancellationFeeCents` - flat fee in cents, in the company tax basis (excluding or including tax). Default `0` (off). The fee is taxed at the tax rate of the station's tariff for the driver.
- `reservation.cancellationWindowMinutes` - window before `startsAt` during which the fee applies. Default `0` (off).

The fee fires when all of the following hold: the system fee is greater than zero, the system window is greater than zero, the reservation has a `driverId`, the cancel happens with `minutesUntilStart` less than `cancellationWindowMinutes`, and the driver has a default card. Charged as a one-shot payment with idempotency key `cancellation-fee-{reservationId}`. The amount charged includes tax and is stored on the reservation. The fee amount, tax rate, and tax basis are the ones in effect when the reservation was created. The window is the current setting.

#### Who pays

The actor that triggered the cancel decides whether the fee is even considered:

| Actor | Behaviour |
|-------|-----------|
| `driver` | Always evaluates the window check above. Pays the fee when inside the window. |
| `operator` | **Opt-in.** The operator must tick **Charge cancellation fee** in the cancel dialog. Defaults to off so a typical operator-side cancel does not surprise-bill the driver. The window check still applies on top of the opt-in. |
| `system` | **Never charges.** System paths (station rejected or did not answer ReserveNow, station offline at activation time, station outage during the reservation, station-side `ReservationStatusUpdate(Removed)`) always waive the fee. |

#### Charge attempt failures

The audit row writes `cancellation_fee_cents = 0` first; only after Stripe confirms is it updated to the actual amount. If the Stripe charge throws (declined card, expired card, network error), the row stays at `0` and the API response includes `feeChargeFailed: true` so the caller knows to reconcile against Stripe. The cancellation itself still succeeds - the reservation is gone whether or not the fee was collected.

Both the CSMS detail tab and the portal detail page render a "Cancellation policy" card when the policy is active. Both show the fee as it is charged, tax included, with a tax label, for example "€5.95 incl. 19% tax". In the CSMS cancel dialog the **Charge cancellation fee** option shows the same amount. In the portal the cancel-confirm dialog adds a fee warning when the cancel will fall inside the window, for example "A cancellation fee of €5.95 incl. 19% tax will be charged to your default payment method."

### Tax, payment records, and revenue

Both fees are entered in the company tax basis (Settings > Company Info > **Tariff prices are entered**) and taxed once at the tax rate of the station's tariff for the driver. On the net basis the tax is added. On the gross basis the amount includes it. The fee terms (holding fee per minute, cancellation fee, tax rate, and tax basis) are fixed when the reservation is created, so a later tariff or settings change does not change them. Each charge:

- Creates a payment record (`reservation_cancellation` or `reservation_no_show`) with the tax rate, before the charge. A retry or a concurrent call for the same reservation and fee type charges nothing.
- Goes through the site's Stripe connected account with the platform fee of its net amount.
- Counts in revenue (split into net and tax at its own rate) and appears as a line on the driver's aggregated invoice.

### No-Show Holding Fee

Per-minute charge for the time the connector was held when the holder reserved but never plugged in.

Per-tariff field: `tariffs.reservation_fee_per_minute` (per minute in the company currency, configured in the tariff editor). Applies to both OCPP 1.6 and 2.1 stations - the rate of the station's tariff for the driver is recorded when the reservation is created and multiplied by the held minutes regardless of which protocol the station speaks.

The reaper job `reservation-expiry-check` runs every minute. A reservation that expires is charged a no-show fee only when all of these hold:

- It was `active` and the station confirmed the hold (accepted ReserveNow). A hold the station never confirmed is never charged.
- No charging session is linked to it.
- No other driver took the held EVSE.
- The station had no outage during the hold. An outage cancels the reservation instead (see [Station Outage During a Reservation](#station-outage-during-a-reservation)).
- It has a driver, the recorded rate is not zero, and the driver has a default card.

The fee is charged once. The expiry marks the fee as due in the same database write that expires the reservation, and the next run settles a fee that a crash left unsettled. Reconciliation resumes a charge that was started but not sent to the payment provider. A fee that stays unsettled for 24 hours is marked failed and recorded as **Fee charge failed** in the **History** tab. A station that reports the reservation expired gets the same check.

The amount:

```
holdingMinutes  = ceil((expiresAt - startsAt) / 60_000)
amountCents     = round(holdingMinutes * ratePerMinute * 100)
```

The rate is in the company tax basis. On the net basis the tax rate is added, on the gross basis the amount includes the tax. The gross is charged to the driver's saved card through its payment provider with idempotency key `no-show-fee-{reservationId}`. When the holder actually charged, the rate already feeds into the session cost via the tariff resolver.

### Session Link

A session starts the reservation (`active &rarr; in_use`) when the station echoes the reservation ID, or when the reservation holder starts on the station inside the window without one. The holder is the reservation's driver or token, so a portal start or an RFID start both count. A portal start by the holder links the session directly.

A start by another driver never uses the holder's reservation. The CSMS records **Taken by another driver**, notifies the holder, and waives the no-show fee for that reservation.

The portal shows the no-show fee before the driver reserves and on the detail page of an open reservation, under a **No-Show Fee** card. The amount is the holding fee per minute times the minutes from the reservation start (or its creation for an instant reservation) to its expiry, rounded up, on the terms fixed when the reservation was made. It is shown as charged, tax included, with a tax label, for example "If you do not start charging before the reservation expires, a no-show fee of €3.57 incl. 19% tax is charged to your default payment method."

### Free Vend Sites

A reservation at a site with [free vend](https://www.evtivity.com/docs/csms/free-vend) turned on costs nothing. The fee terms recorded when the reservation is made have no holding fee and no cancellation fee, so the reservation is never charged a no-show fee or a cancellation fee, and no card hold or charge is made. The portal and the mobile app show no fee for these stations.

The terms recorded at creation decide. A site that turns free vend on after a reservation was made keeps the fees of that reservation, and a site that turns it off keeps a reservation made during free vend free.

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
| `reservation.cancellationFeeCents` | `0` | Flat cancellation fee in cents, in the company tax basis, taxed at the tariff tax rate and charged to the driver's default payment method when they cancel inside the cancellation window. `0` disables the fee. |
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
