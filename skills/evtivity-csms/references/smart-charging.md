Generated from https://www.evtivity.com/docs/csms/smart-charging (website commit 0f3462e). Do not edit.

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

Two purposes are excluded from templates: `TxProfile` (requires an active transaction ID per station) and `ChargingStationExternalConstraints` (reserved for the load management control loop).

### Schedule Kinds

| Kind | Behavior |
|------|----------|
| Absolute | Schedule periods start from a fixed date and time |
| Recurring | Schedule repeats daily or weekly from a start time |

`Relative` (needs transaction context) and `Dynamic` (real-time EMS) are excluded from templates.

### Profile Stacking

A station can have multiple active profiles simultaneously. Different purposes coexist (e.g., a station max profile plus a default transaction profile). Within the same purpose, higher stack levels take precedence. The station computes a composite schedule from all profiles and applies the most restrictive limit.

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

### Track Push Results

After pushing, the push history shows:

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
- **Clear All Profiles**: Remove profiles from the station.
- **Push Charging Profile**: Push a single template to this specific station.
