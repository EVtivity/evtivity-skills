Generated from https://www.evtivity.com/docs/csms/maintenance (website commit ffa3c26). Do not edit.

# Maintenance Mode

Schedule per-site maintenance windows that mark stations unavailable, stop sessions gracefully, and cancel overlapping reservations.

## Overview

Maintenance mode lets an operator take a whole site (or a subset of stations) offline for a planned window. The system pushes OCPP `ChangeAvailability(Inoperative)` to each affected station, swaps the station display to a maintenance message, cancels any reservations that fall inside the window, and optionally stops in-progress sessions.

Use it for planned electrical work, firmware rollouts, software upgrades, network changes, or any other event where the site cannot serve drivers.

![Site Maintenance tab with an active window and rollout history](https://www.evtivity.com/screenshots/csms/site-maintenance.png)

## How It Works

1. **Create an event**

   From the Site Detail page Maintenance tab, click **Schedule maintenance**. Choose **Now** for an immediate window or **Scheduled** with a future start time. Pick the end time and (optionally) a custom display message and reason.

2. **Worker activates the window**

   The `maintenance-scheduler` cron job runs every minute. When a scheduled event's start time arrives, the worker transitions the row to `active` and runs the activation flow.

3. **Stations are taken offline**

   The system sends OCPP `ChangeAvailability(Inoperative)` to every affected station, pushes the rendered maintenance message to slot 9005 of the station display, and broadcasts an SSE event so the dashboard updates.

4. **Overlapping reservations are cancelled**

   Every reservation whose window overlaps the maintenance window is cancelled with no fee. Drivers are notified by `reservation.CancelledForMaintenance`.

5. **Active sessions are handled**

   If the policy is **Stop gracefully**, the system sends `RequestStopTransaction` for every active charging session on the affected stations and dispatches the `maintenance.SessionStopped` notification to each driver. With the **Leave running** policy, in-progress sessions continue uninterrupted.

6. **Window ends automatically**

   When `planned_end_at` passes, the worker transitions the event to `completed`, sends `ChangeAvailability(Operative)` to every affected station, and clears the maintenance display slot. Cancel an event manually before the end time to terminate the window early.

## Rollout in the Background

Creating, ending, or editing a maintenance window returns immediately. The per-station work -- OCPP commands, display messages, reservation cancellations, session stops -- runs as a background job in the worker, so a 90-station site never ties up the dashboard request. Stations are commanded 10 at a time, and jobs for the same site always run one after another (including when the worker is scaled to multiple replicas), so the start of one window and the end of another can never interleave on a station.

Each action is its own run: starting the window, adding stations, removing stations, and ending the window each produce a separate background job with its own per-station results.

**Re-assert on reconnect:** a station that was offline or rebooting while the rollout ran would otherwise come back and keep serving drivers mid-window. When a station reconnects during an active window, the system automatically re-sends the offline command and the maintenance display message to just that station.

## Tracking the Rollout

The Maintenance History table shows three rollout columns. Each counts stations by their most recent command result, so a station that failed initially but succeeded on a retry counts once, as a success:

| Column | Meaning |
| --- | --- |
| **Taken Offline** | Stations confirmed out of service when the window started (or when added to it), out of all stations commanded offline. |
| **Re-asserted** | Stations that reconnected mid-window and were commanded offline again, out of all such reconnects. A station that missed the initial run is covered here. |
| **Restored** | Stations confirmed back in service after the window ended, was cancelled, or stations were removed from it, out of all stations commanded back. |

A green badge (for example "96 of 96") means every commanded station accepted. A yellow badge means some stations did not confirm -- click the row for per-station details.

## Station Results

![Station Results page with per-station command outcomes](https://www.evtivity.com/screenshots/csms/maintenance-station-results.png)

Clicking a Maintenance History row opens the Station Results page: one row per station per run, with the OCPP command sent, the result, the error reason when it failed, the station status before and after the run, and the station's live current status. A phase filter narrows the view to a single run.

| Result | Meaning |
| --- | --- |
| `accepted` | The station confirmed the command. |
| `rejected` | The station refused the command. |
| `scheduled` | The station accepted but will apply the change when its current transaction ends. |
| `offline` | The station was not connected when the command was sent. It is re-asserted automatically when it reconnects. |
| `failed` | The station did not answer within 35 seconds. The command may still have applied late -- check Current Status. |

**Current Status** is computed live from the station and uses the same status badge as the station list. It is the ground truth when a snapshot or timeout looks ambiguous.

## Maintenance Badges

While a site has an active window, a Maintenance badge appears next to the site name on the Site Detail page and next to every covered station in station lists, so anyone browsing the dashboard sees at a glance which hardware is intentionally out of service.

## Permissions

`maintenance:read` lets an operator view the Site Detail Maintenance tab and the audit log. `maintenance:write` lets them create, edit, and cancel events.

Both permissions are bundled into the **admin** and **operator** default roles. Viewers get read-only access.

## Notifications

Two driver event types are enabled by default:

- `reservation.CancelledForMaintenance` - one email/SMS per driver whose reservation was cancelled. Variables: `maintenanceEventId`, `plannedStartAt`, `plannedEndAt`, `reason`.
- `maintenance.SessionStopped` - one email/SMS per driver whose session was stopped under the graceful-stop policy. Variables: `sessionId`, `maintenanceEventId`, `plannedEndAt`, `reason`.

You can disable either event type from **Notifications > Driver Events**.

## Editing an Event

![Editing an active maintenance window](https://www.evtivity.com/screenshots/csms/site-maintenance-edit.png)

Every active and scheduled event card on the Site Detail Maintenance tab has an **Edit** button that opens an inline form.

**Scheduled events** are fully editable: start time, end time, reason, custom display message, plus add and remove stations.

**Active events** allow a narrower set of edits because the window is already in flight: end time, reason, and custom display message. The start time and overall scope are locked in. Adding or removing stations on an active event is still supported and runs the matching OCPP side effects on just the affected stations:

- **Adding a station** sends `ChangeAvailability(Inoperative)`, pushes the maintenance display, cancels any overlapping reservations on that station, and (when the policy is **Stop gracefully**) stops any active session on it.
- **Removing a station** sends `ChangeAvailability(Operative)` and clears the maintenance display on that station immediately. The rest of the event continues.

Add-station picks come from a fixed-height scrollable list with the same search box and status filter the create form uses, including Online/Offline, Charging, and reservation badges per station.

When the event was created with **All stations at this site** scope, the first add or remove materialises the explicit current list so any stations added to the site later won't be auto-pulled into the existing window. Removing the last remaining station is refused; cancel the event from the same card instead.

When a scheduled event's window is changed (start time, end time, or both), drivers with reservations that now fall inside the new window are notified and cancelled immediately, not at activation. The `reservation.CancelledForMaintenance` notification fires at edit time so drivers can re-book before they show up to a closed site.

## OCPP Commands During Maintenance

Maintenance mode only affects new transactions. The OCPP WebSocket connection to every affected station stays open, and operators can continue to send any OCPP command: `UpdateFirmware`, `SetVariables` / `ChangeConfiguration`, `Reset`, `SendLocalList`, certificate management, log retrieval, and so on. Maintenance windows are commonly scheduled specifically to run firmware updates.

## Reservation Blocking

The reservation create endpoints (operator and driver portal) call the maintenance check helper before any other validation. Attempting to reserve any EVSE during a scheduled or active maintenance window returns `409 RESERVATION_DURING_MAINTENANCE` with the conflicting event ID and window in the response body, so the UI can show the driver exactly when the site reopens.

Defense in depth: the same check is applied to fleet bulk reservations, the operator reservation reassign flow, and OCPI `START_SESSION` / `RESERVE_NOW` commands received from external eMSP partners. Partners receive a `REJECTED` command result when the target station is under maintenance.

## Portal Behavior

When a driver views a station whose site has an active maintenance window, the portal shows a "Site under maintenance" banner with the expected end time (in the viewer's local timezone) and disables the start-charging buttons. The OCPI location transformer marks only the actually-affected stations as `INOPERATIVE`, so partner networks reflect per-station maintenance scope correctly when an event targets a subset of a site.

## Maintenance vs Station Disable

A maintenance window covers a site or a subset of its stations for a planned period and ends on its own. To take one station out of service with no end time, use **Disable Station** on the station detail page. A disabled station stays unavailable, including after a reboot, until an operator enables it. See [Enable and disable a station](https://www.evtivity.com/docs/csms/stations#enable-and-disable-a-station).

## Settings

| Key | Default | Description |
| --- | --- | --- |
| `maintenance.defaultMessageTemplate` | `This site is temporarily unavailable for maintenance. {{reason}}` | Handlebars template rendered on station displays during a window. Variables: `companyName`, `siteName`, `endTime`, `durationMinutes`, `reason`. |

## Audit Trail

Every transition writes a row to `maintenance_event_audit_log`. Actions: `created`, `updated`, `started`, `ended`, `cancelled`, `sessions_stopped`, `reservations_cancelled`. The global `/audit` page lists maintenance entries alongside every other entity type.
