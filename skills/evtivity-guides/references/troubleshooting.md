Generated from https://www.evtivity.com/docs/guides/troubleshooting (website commit 900fb20). Do not edit.

# Troubleshooting

Common operator pain points encountered during day-to-day CSMS operation and how to resolve them.

This page is a growing FAQ for issues operators run into in the field. Each entry lists the symptom, the likely cause, and the fastest fix.

## Contents

- [Phantom or stuck charging session won't end](#stuck-session)
- [Connector status is stuck or stale](#stuck-status)
- [Session starts but no power is delivered (SuspendedEV)](#suspended-ev-no-power)

## Phantom or stuck charging session won't end

### Symptom

A charging session shows as **active** in the dashboard but has clearly ended in the real world:

- The driver unplugged hours ago, but the session is still running.
- Energy stopped accumulating, the connector is back to **Available**, but the session is still listed as active.
- A new driver tries to start on the same EVSE and gets `409 EVSE_IN_USE` even though the connector is empty.
- A test or simulator session never received a proper stop and is now permanent in the database.

### Why it happens

A charging session is closed in the CSMS only when one of these arrives from the station:

- `TransactionEvent` with `eventType: Ended` (OCPP 2.1)
- `StopTransaction` (OCPP 1.6)
- The result of an operator-initiated `RequestStopTransaction`

If the station never sends one of these, the session record stays `active` in the database forever. Common causes:

- Firmware bug or network drop right at session end so the stop event was never delivered.
- Station crashed or lost power without flushing its buffered events.
- A simulator or test fixture was killed before it sent the stop event.
- The station was rebooted while a session was still active.

The active session record blocks new starts on the same EVSE -- the `EVSE_IN_USE` guard refuses a second start until the first session is closed.

### Fix

On the station's **Connectors** tab, click the red **Stop active session** icon (square in a circle) on the EVSE row. Confirm the prompt. The CSMS dispatches an OCPP `RequestStopTransaction` to the station for that transaction. When the station acknowledges, it sends back the missing end event and the session is closed normally -- final cost, energy, and duration are computed the same way as a driver-initiated stop.

The button is enabled only when the CSMS has an active session recorded for that EVSE. If the EVSE is free, there's nothing to stop.

### If it doesn't work

- **Station offline.** `RequestStopTransaction` only reaches connected stations. The session stays active until the station comes back. Bring it online first; in most cases it catches up and emits the missing end event on reconnect.
- **Station rejected the stop.** Some firmware refuses `RequestStopTransaction` if it has already cleared its own transaction state. When the station answers `Rejected` with reason `TxNotFound`, the CSMS ends the session the normal way (completed at its last metered energy, with final cost and receipt). Any other rejection leaves the session active, and the dashboard still shows **Stop request sent**: check the station's OCPP message log for the reply. Power-cycle the station; on reconnect it usually emits a fresh `StatusNotification` and the missing end event.
- **No active session on this EVSE.** The button reports `No active session on this EVSE`. The session you're seeing might belong to a different EVSE on the same station -- check the Sessions tab and locate the EVSE the session was started on.

## Connector status is stuck or stale

### Symptom

The Connectors tab on a station shows a status that doesn't match physical reality:

- A connector still shows **Charging** several minutes after the driver pressed Stop.
- A connector shows **Occupied** or **EVConnected** long after the cable was unplugged.
- After a CSMS restart, every station's connector status looks frozen at whatever it was at restart time.

### Why it happens

The connector badge on the dashboard reads `connectors.status` in the database. That field is only written when the station sends one of:

- `StatusNotification` (the canonical path)
- `TransactionEvent` with a `chargingState` value (OCPP 2.1 enrichment)

If the station never sends a follow-up `StatusNotification` after a state change -- common with some firmware after a remote stop, after a network blip, or on certain OCPP 2.1 stations that bundle the post-stop state into `TransactionEvent` only -- the badge stays at whatever it was last set to until the next status report arrives.

### Fix

Click the **Refresh connector status** icon (circular arrow) on the EVSE row in the station's **Connectors** tab. The button dispatches an OCPP `TriggerMessage` to the station, waits up to ~10 seconds for the station to report back, and refreshes the dashboard with the latest value.

The CSMS picks the right `requestedMessage` based on protocol and whether a transaction is active, because OCPP 2.1 splits the state across two channels:

- **OCPP 1.6** -- always `TriggerMessage(StatusNotification)`. 1.6 statuses are already fine-grained (`Charging`, `Preparing`, `Finishing`, `SuspendedEV`, `SuspendedEVSE`), so a single StatusNotification gives the accurate state.
- **OCPP 2.1, active session** -- `TriggerMessage(TransactionEvent)`. The 2.1 `StatusNotification` only carries the coarse connector-level value (`Occupied`); the fine-grained `chargingState` (`Charging`, `EVConnected`, `SuspendedEV`, etc.) lives on `TransactionEvent`. Triggering a fresh `TransactionEvent` returns the current `chargingState`, which the projection writes to `connectors.status`.
- **OCPP 2.1, no active session** -- `TriggerMessage(StatusNotification)`. There's no transaction to refresh, so the connector-level value is all the station has.

The result lands in the same projection path as a spontaneous status update, so the dashboard refreshes the same way it would if the station had reported on its own.

### Even if the badge is wrong, two drivers cannot start on the same connector

The CSMS enforces a server-side guard: starting a session is refused with `409 EVSE_IN_USE` whenever an active session already exists on that EVSE, regardless of what the connector badge currently says. So if the badge is briefly stale, a second driver attempting to start will still be rejected -- the door stays closed.

### If it doesn't work

- **Station offline.** The button is disabled when the station isn't connected. Get the station back online first; the badge will refresh automatically once it sends its first status report after reconnect.
- **Station rejected the trigger** (rare). Some firmware advertises `NotImplemented` for `TriggerMessage`. The badge then keeps the cached value. Power-cycle the station or wait for the next spontaneous report.
- **Status truly hasn't changed yet** -- the station's actual state is what the badge says. Check the OCPP message log on the station detail page for recent inbound `StatusNotification` and `TransactionEvent` entries.

## Session starts but no power is delivered (SuspendedEV)

### Symptom

A session starts cleanly but no energy flows. The OCPP message log on the station detail page shows a `TransactionEvent` shortly after the session starts with `triggerReason: ChargingStateChanged` and `transactionInfo.chargingState: SuspendedEV`. The cable is connected, the contactor never closes, and meter values stay flat at zero.

### Why it happens

`SuspendedEV` is the OCPP 2.1 charging state the station reports when the EV refuses to draw current. In most field cases this is a real EV-side condition: battery already at the configured charge limit, the car's scheduled-charging feature is active, or the vehicle simply needs to be woken up.

It also fires when the station offers less power than the EV will accept, including zero. The most common operator-side cause is a leftover charging profile that caps the offered current or power below the EV's minimum acceptance threshold. A `ChargingStationMaxProfile` or `TxDefaultProfile` with a `limit` of 0 (or a value lower than the EV's floor, typically 6 A) makes the station offer almost nothing, and the EV responds with `SuspendedEV` instead of `Charging`. Stale smart-charging templates pushed earlier and never cleared are a frequent culprit.

### Fix

Open the station detail page and go to the **Charging Profiles** tab. You have two options:

1. **Clear all profiles.** Click **Clear All Profiles** and confirm. The CSMS sends an OCPP `ClearChargingProfile` to the station that removes every profile across every purpose and stack level. Use this when you don't need any profiles active and want a clean slate.
2. **Identify and fix the offending profile.** Click **Refresh from Station** to pull the station's current profile list. Inspect each entry's `chargingSchedule` periods and look for `limit` values that are 0 or unreasonably low for the connector type (for example, a 32 A AC connector with a 6 A or lower limit). Either edit the offending profile to a sensible limit and re-push, or click the trash icon on that row to delete it.

After clearing, ask the driver to unplug and replug. Some EVs cache the previous offer and won't retry until the session restarts.

### If it doesn't work

- **Profiles stack.** A station can have several active profiles at once and applies the most restrictive limit at each point in time. Clearing one isn't enough if a second profile still caps the offer. Click **View Composite Schedule** to see the merged schedule the station is actually using; that is the offer the EV is reacting to.
- **Load management is the source.** EVtivity load management uses `ChargingStationExternalConstraints`. If the site is over its power budget, the allocation can drop the per-EVSE limit low enough to trigger `SuspendedEV`. Check the site's load management status.
- **Power offer below EV minimum.** Some EVs refuse to charge below 6 A or have a higher minimum on DC. If your tariff floor or load-management settings cap the offer that low, the car will sit in `SuspendedEV` indefinitely. Raise the floor.
- **Real EV-side cause.** If no profile is restricting the offer and load management is not active, the cause is on the vehicle: battery full or near the configured charge limit, a scheduled-charging feature is on (Tesla Scheduled Departure, Ford or GM off-peak schedule), or the EV needs to be woken up by opening a door or touching the manufacturer app.
- **Cable not fully latched.** A loose CP signal can present the same way to the CSMS. Re-seat the connector and listen for the contactor click.
