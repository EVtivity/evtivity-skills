Generated from https://www.evtivity.com/docs/guides/smart-charging. Do not edit.

# Smart Charging

Push power-limit profiles to stations in bulk or one at a time, and understand how OCPP charging schedules actually take effect.

## Overview

Smart charging in EVtivity uses OCPP `SetChargingProfile` to enforce time-of-day power limits on connected stations. Profiles do not start charging on their own. They constrain the energy a station is allowed to deliver during an active session. To make a session honor a profile, either the EV or the operator has to start the session first.

This guide covers three things:

- Batch push: send one template to many stations at once
- Per-station push and delete: target a single station
- How scheduling actually works: EV-side schedulers vs. session-active-and-suspended

## Batch Push: Send a Template to Many Stations

Use this when you have a fleet (a site, a vendor, a model) and want them all to honor the same window.

![Smart Charging templates list](https://www.evtivity.com/screenshots/csms/smart-charging-list.png)

### Steps

1. From the sidebar, open **Settings** and select the **Smart Charging** tab. You see a list of templates.
2. Click **Create** to define a new schedule, or open an existing template.
3. In the template, set:
   - **Profile Purpose** — `ChargingStationMaxProfile` (caps the whole station) or `TxDefaultProfile` (caps each session).
   - **Stack Level** — higher levels override lower levels of the same purpose. Use 0 for the base, 7 for an emergency override.
   - **Schedule Periods** — wall-clock time ranges and the power limit (W) or current limit (A) for each.
   - **Target Filter** — pick a site, vendor, or model. Only matching online stations receive the push.
4. Click **Push to Stations**.
5. EVtivity sends two OCPP commands per matching station:
   - `ClearChargingProfile` to remove any existing profile at the same `(purpose, stack level, EVSE)` slot.
   - `SetChargingProfile` with your template payload.
6. The push history pane shows per-station results: Accepted, Rejected, or Failed (with error info).

![Create or edit a charging profile template](https://www.evtivity.com/screenshots/csms/smart-charging-create.png)

### What you should see after a successful batch push

For OCPP 2.1 stations, EVtivity automatically refreshes each station's reported profile list (sends `GetChargingProfiles` in the background). After the push completes, the station detail page's **Charging Profiles** tab will show both the CSMS-pushed row (`Source: CSMS`) and a station-reported row (`Source: Station, Limit Source: CSO`) confirming the profile is installed.

OCPP 1.6 has no equivalent command, so 1.6 stations only show the CSMS-pushed row. There is no way for the CSMS to confirm a 1.6 station's actual profile state, only that the station replied `Accepted` to the push.

## Per-Station Push and Delete

Use this for one-off targeted changes on a single station: a test push, a customer-specific override, removing a stale factory profile.

![Charging Profiles tab on a station](https://www.evtivity.com/screenshots/csms/station-charging-profiles.png)

### Push to one station

1. Open the station detail page and select the **Charging Profiles** tab.
2. Click **Push Charging Profile**.
3. Pick a template that matches the station's OCPP version.
4. Click **Push Charging Profile**.

EVtivity dispatches the same Clear-then-Set sequence as a batch push, but only to this station. After Accepted, a `GetChargingProfiles` runs in the background (2.1 only) so the table refreshes automatically.

### Delete a single profile

1. On the **Charging Profiles** tab, find the row to remove.
2. Click the trash icon at the right of the row.
3. Confirm the dialog.

EVtivity sends `ClearChargingProfile` with the row's OCPP profile id. After Accepted, the matching DB row is removed and (for 2.1) `GetChargingProfiles` re-mirrors the station's remaining profiles.

### Clear all profiles on a station

Click **Clear All Profiles** at the top of the tab to send `ClearChargingProfile` with no filter. The station removes every profile of every purpose. Use carefully on production stations — this also removes any factory or local profiles.

### Refresh from station

Click **Refresh from Station** to send `GetChargingProfiles` on demand. The station's reply repopulates the `Source: Station` rows with whatever profiles are actually installed. This is the only way to see profiles set outside EVtivity (factory defaults, prior CSMS, the station's local UI).

## How a Charging Schedule Actually Takes Effect

A charging profile by itself does nothing. It is a power ceiling that applies during an active session. There are two paths a session uses to honor a schedule, and the right path depends on whether you are running residential or fleet operations.

### Path A: EV-Side Scheduling (most common for residential)

Most modern EVs have a built-in charging scheduler. The driver sets a time window in the car or the OEM app (Tesla, BMW, VW, Ford, etc.).

What happens:

1. Driver plugs in any time of day.
2. Authorization happens immediately (RFID, RemoteStart, or auto-start).
3. The session starts. The car holds back energy until its programmed time.
4. Connector status reads `SuspendedEV` while the car waits.
5. At the scheduled time, the car wakes up and starts drawing power. Status flips to `Charging`.

EVtivity does nothing during the wait beyond keeping the session open. No profile is needed for this path. The schedule lives entirely in the EV.

If you want to nudge drivers toward off-peak charging without forcing it, pair this with **time-of-use pricing** (different `$/kWh` rates per time block). Drivers see the cost difference in their session receipt and adjust their EV scheduler accordingly.

### Path B: Charging Profile Gates the Energy (operator-controlled)

This is what the Smart Charging feature does. Use it when the operator decides the schedule, not the driver.

What happens:

1. Operator pushes a `TxDefaultProfile` to the station with a schedule like 0A from 03:00 to 23:00, 32A from 23:00 to 03:00.
2. Driver plugs in any time of day.
3. Authorization happens immediately, the session opens.
4. If it is currently within a 0A window, the station enters `SuspendedEVSE` (paused by the station, not the EV).
5. At 23:00 the schedule allows 32A, the station resumes delivering, status flips to `Charging`.
6. At 03:00 the schedule drops to 0A again, station returns to `SuspendedEVSE`.
7. The session stays open the whole time, even while paused.

Caveats for Path B:

- **Idle fees apply.** The session is open. If your tariff charges per minute or has idle fees, the driver pays for the suspended time unless the grace period covers it.
- **EV may sleep.** Many cars go to sleep after 10 to 30 minutes of inactivity and stop responding to wake-up signals. Some never restart charging when the limit lifts. Tesla and recent VW MEB platforms handle this fine. Older cars often do not.
- **Station idle timeout.** Some stations have an internal "no energy for N minutes, end transaction" rule. Check the station's `EVConnectionTimeOut` configuration before relying on long suspended windows.

### Path C: CSMS-Driven Scheduled Remote Start (advanced)

If you want EVtivity itself to start a transaction at a scheduled time without the EV or the driver doing anything, you need a CSMS-side cron job sending `RequestStartTransaction` at the scheduled time. The cable still has to be physically connected when the command fires; the station rejects with `EVConnectTimeout` otherwise. This is not built into EVtivity today. Open a request if you need it.

## Choosing the Right Approach

| Scenario | Recommended path |
|---|---|
| Residential / single-driver | Path A (EV scheduler) plus optional time-of-use pricing |
| Fleet site, operator-enforced window | Path B (Smart Charging profile) |
| Demand response, hard cap from utility | Path B with `ChargingStationMaxProfile` at high stack level |
| Test or emergency block | Push the seeded `Test: Block All Charging` template (0W constant, stack level 7) |

## Notes

- A station can hold multiple profiles. They occupy slots keyed by `(purpose, stack level, EVSE)`. Pushing a new profile with the same triple replaces the old one.
- Higher stack levels win within the same purpose. Different purposes coexist; the station applies the lowest active limit at each point in time.
- The **View Composite Schedule** button shows the merged result of every active profile. This is what the EV actually sees as its limit.
- For OCPP 1.6 stations, the `Source: Station` rows do not exist (1.6 has no `ReportChargingProfiles`). The CSMS only knows what it sent, not what the station ultimately retains. Use the composite schedule view to verify on-station state.
