Generated from https://www.evtivity.com/docs/csms/smart-charging. Do not edit.

# Smart Charging

Create charging profile templates with time-of-day power schedules and push them to multiple stations.

## Overview

Smart charging lets you define charging profile templates with time-based power limits and push them to groups of stations. Templates control when and how much power stations deliver, enabling time-of-use optimization, demand response, and power capping.

![Smart charging template list](https://www.evtivity.com/screenshots/csms/smart-charging-list.png)

## Concepts

### Profile Purposes

| Purpose | Applies To | Description |
|---------|-----------|-------------|
| ChargingStationMaxProfile | Entire station (evseId=0) | Caps the station's total power output |
| TxDefaultProfile | All sessions (evseId=0) | Default power limit for every charging session |
| PriorityCharging | Per EVSE (2.1 only) | Priority override for specific EVSEs |
| LocalGeneration | Station (2.1 only) | Limits based on local energy generation |

Two purposes are excluded from templates: `TxProfile` (requires an active transaction ID per station) and `ChargingStationExternalConstraints` (only a station or an external energy management system sets it; a CSMS never sends it).

### Schedule Kinds

| Kind | Behavior |
|------|----------|
| Absolute | Schedule periods start from a fixed date and time |
| Recurring | Schedule repeats daily or weekly from a start time |

`Relative` (needs transaction context) and `Dynamic` (real-time EMS) are excluded from templates.

### Profile Stacking

A station can have multiple active profiles simultaneously. Different purposes coexist (e.g., a station max profile plus a default transaction profile). Within the same purpose, higher stack levels take precedence. The station computes a composite schedule from all profiles and applies the most restrictive limit.

On a station under [load management](https://www.evtivity.com/docs/csms/load-management), the CSMS refuses a `ChargingStationMaxProfile` at stack level 1 or higher, and any profile that uses the load management profile ID (1000000000), so nothing lifts the breaker limit. A station push or a `SetChargingProfile` command returns `CHARGING_PROFILE_LOAD_MANAGED`, and a template push marks the station Failed.

## Create a Charging Profile Template

1. Navigate to **Settings** and open the **Smart Charging** tab.
2. Click **Create**.
3. Fill in the template fields:

| Field | Description |
|-------|-------------|
| Name | Descriptive name for the template |
| Profile Purpose | ChargingStationMaxProfile, TxDefaultProfile, PriorityCharging, or LocalGeneration |
| Schedule Kind | Absolute or Recurring |
| Stack Level | Priority level for profile stacking (higher wins within same purpose) |
| Start Schedule | Start date/time for the schedule |
| Recurrence | Daily or Weekly (Recurring kind only) |

![Create smart charging template](https://www.evtivity.com/screenshots/csms/smart-charging-create.png)

### Template Rules

The CSMS checks every template when you create or edit it and again before each push:

- **Start Schedule** is required for both Absolute and Recurring templates. Enter it in your own timezone (your profile setting); the CSMS stores it as an exact point in time.
- The first schedule period starts at 0, and later periods start strictly later.
- A Recurring template needs a recurrence (Daily or Weekly).
- **Valid From** must be before **Valid To**.
- An OCPP 1.6 template uses ChargingStationMaxProfile or TxDefaultProfile only.

A template that breaks a rule is refused with a message that names it, so a station never receives a profile it must reject.

### Define Schedule Periods

Use the **Schedule Periods** editor to define power limit periods:

1. Click **Add Time Slot** to create a time slot.
2. Set the **Start Time** for the period (offset from schedule start).
3. Set the **Power Limit** in watts or amps.
4. Add additional periods to create a multi-step schedule.

Example: a recurring daily schedule with off-peak (22:00-06:00) at 22 kW and peak (06:00-22:00) at 11 kW.

### Set Target Filter

Define which stations receive this profile:

- **Site**: Push to all stations at a specific site.
- **Vendor**: Filter by station vendor/manufacturer.
- **Model**: Filter by station model.

Filters can be combined. Leave all filters empty to target all stations.

## Push a Template to Stations

1. Open the template detail page.
2. Review the **Matching Stations** count to verify your target filter.
3. Click **Push to Stations**.
4. The system sends OCPP commands to each matching online station:
   - `ClearChargingProfile` (same purpose and stack level) to remove existing profiles
   - `SetChargingProfile` with the template payload

One push or clear runs per template at a time. Pushing or clearing again while one is still running opens the running one instead of starting a second. A push whose stations stopped reporting progress for 10 minutes is closed, and its remaining stations show Failed with the reason Interrupted.

### Track Push Results

After pushing, the Pushes list shows:

| Status | Meaning |
|--------|---------|
| Accepted | Station accepted the charging profile |
| Rejected | Station rejected the profile (check error info) |
| Failed | Communication failure or station offline |

Click a push record to see per-station results with error details.

## OCPP Version Handling

| Feature | OCPP 1.6 | OCPP 2.1 |
|---------|----------|----------|
| Supported purposes | ChargePointMaxProfile, TxDefaultProfile | All except TxProfile, ExternalConstraints |
| Connector addressing | connectorId | evseId |
| Command translation | Automatic | Native |

OCPP 1.6 uses `ChargePointMaxProfile` instead of `ChargingStationMaxProfile`. The command translation layer handles the mapping automatically.

## View Composite Schedule

On the station detail page, the **Charging Profiles** tab provides:

![Station Charging Profiles tab](https://www.evtivity.com/screenshots/csms/station-charging-profiles.png)

- **Refresh from Station**: Pull current profiles from the station via `GetChargingProfiles` (2.1 only).
- **View Composite Schedule**: Request the station's composite schedule showing the merged result of all active profiles.
- **Clear All Profiles**: Remove every profile the CSMS may clear from the station. External constraints and local generation profiles stay on the station.
- **Push Charging Profile**: Push a single template to this specific station.

## EV Charging Needs and Variable Monitors

On the station detail page of an OCPP 2.1 station, the **Charging Needs and Monitors** tab shows what EVs ask for over ISO 15118 and the variable monitors set on the station. OCPP 1.6 stations do not show the tab.

### EV Charging Needs

When an EV sends its charging needs during a session, the CSMS computes a charging schedule and sends it to the station as a transaction profile for that session, when the ISO 15118 smart charging setting is on and the EV asks for scheduled control. The limit is the lowest of what the EV accepts, the connector maximum and the free capacity of the site power limit. With a departure time and an energy amount, it is also capped at the rate that delivers that energy by the departure time. Without an active session, or for dynamic control, the CSMS sends no schedule and the station uses its default profile.

The **Charging Needs and Monitors** card shows, per EVSE: the energy transfer, control mode, requested energy, departure time and the **CSMS Limit** sent, or **No Profile Sent**. The needs end with the session.

### EV Charging Schedules

The EV answers with the schedule it plans to follow. The CSMS checks it against the schedule it sent: **Within Limits** is accepted. **Exceeds Limits** is rejected, and the CSMS sends its schedule again once so the station renegotiates with the EV. **Not Checked** means the CSMS had no schedule to compare with. A schedule in amperes is not compared with a schedule in watts; the station checks it.

### Variable Monitors

A variable monitor makes the station report an event when a device model variable crosses a threshold, changes by a delta, or on a period.

1. Click **Add Monitor** (the station must be online).
2. Enter the **Component** and **Variable** (for example `EVSE` and `Power`), the **Monitor Type**, the **Value** and the **Severity** (0 to 9).
3. Click **Create**.

The CSMS sends the monitor to the station and stores its answer: Active with the station's **Monitor ID**, or Error with the reason. Delta and periodic monitors need a value above 0. **Clear Monitor** removes an active monitor from the station first; the station must be online, and a monitor the station refuses to clear stays Active. Adding and clearing monitors needs the stations write permission.
