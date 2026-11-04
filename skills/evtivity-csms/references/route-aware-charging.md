Generated from https://www.evtivity.com/docs/csms/route-aware-charging. Do not edit.

# Route Aware Charging

Charge every fleet vehicle at a Depot by its departure time with the energy its next route needs, within the site power limits and in the cheapest hours.

## Overview

Route aware charging plans the charging of fleet vehicles (buses, semi trucks, box trucks and other fleet vehicles) at a Depot site. You enter when each vehicle leaves and how much energy its next route needs. The CSMS plans power for every plugged-in vehicle so each one is ready by its departure, never above a panel, circuit or phase limit of the site, using the cheapest electricity hours first and spreading load to avoid peaks. When a vehicle arrives late, arrives with less charge or a charger does not follow its schedule, the plan is recalculated.

You enter departures on the fleet page, choose the **Departure Aware** strategy on the site's **Load Management** tab, and follow each departure on the **Fleet Readiness** tab of the Depot site and in its 3D layout.

![Fleet Readiness tab with the charging plan](https://www.evtivity.com/screenshots/csms/site-fleet-readiness-tab.png)

## How It Works

- **Departure**: one time a vehicle must leave the depot, with the energy it needs by then. A departure belongs to a vehicle, not to a charger, so the vehicle may plug in at any charger of the depot.
- **Weekly schedule**: a repeating departure, for example Monday to Friday at 05:30 with 220 kWh. Each schedule creates the departures of the coming week.
- **Plan**: the planned power of every vehicle at the site in 15-minute periods, computed together for the next departures (up to 48 hours ahead).
- **Finish buffer**: the minutes before each departure the plan tries to keep free, so a vehicle is ready early. 30 minutes by default.

The plan runs inside the [Load Management](https://www.evtivity.com/docs/csms/load-management) control loop of the site:

1. Vehicles are planned by priority (1 lowest to 10 highest, 5 by default), highest first. When power is short, the lowest priority vehicle gets less first.
2. Within one priority, the vehicle that leaves first is served first.
3. Each vehicle charges in the cheapest periods of the site's [electricity rates](https://www.evtivity.com/docs/csms/sites#electricity-rates) before its departure. Among periods with the same price, the least loaded periods are used first, which keeps the site peak low. Without electricity rates, every period costs the same and only the departures and the peak decide.
4. Each charging session gets its plan as an OCPP `TxProfile` (OCPP 2.1, 2.0.1 and 1.6) with the power for the coming hours. The plan is sent again every 15 minutes, so the charger always holds the next hours.
5. The station limit that load management sends (`ChargingStationMaxProfile`) stays in force as the safety ceiling. A charger that refuses or ignores its schedule still stays within the breaker limits.
6. Every 10 seconds the CSMS measures the actual power and energy of each session. A session behind its plan, a battery that takes less power near full, a charger that draws more than its limit, a station that goes offline, a session that starts or ends, or a changed departure leads to a new plan.

A plan that cannot meet every departure never exceeds a limit: vehicles get less energy, never more power.

## Set Up

### Step 1: Turn on Fleet Charging

Open **Settings** > **Integrations & Features**, select the **Fleet** tab and turn on **Fleet Charging**: "Plans depot charging by each vehicle's departure at sites that use the Departure Aware strategy." It is off by default. While it is off, you can already enter vehicle data, schedules and departures, and the **Departures** tab, the **Fleet Readiness** tab and the 3D layout list them, but nothing is planned and no charging profile is sent.

Turning it off asks for confirmation: depot plans stop, the charging profiles they sent are cleared, and Departure Aware sites share power equally. Departures stay stored.

![Fleet Charging setting](https://www.evtivity.com/screenshots/csms/settings-fleet-charging.png)

### Step 2: Set Vehicle Battery Data

On the driver's **Vehicles** tab, open the vehicle (or click **Create Vehicle**) and set:

- **Battery Capacity (kWh)**: the usable battery size, 1 to 2000 kWh. Needed only for departures with a state of charge target.
- **Max Charge Power (kW)**: the highest power the vehicle accepts, 1 to 3750 kW. Empty means the charger maximum.
- Preconditioning power: the power in kW the vehicle draws to heat or cool itself before it leaves, 0.5 to 500 kW. Empty reserves nothing.
- Preconditioning window: how long before the departure preconditioning starts, 5 to 240 minutes, 30 by default.

The plan reserves the preconditioning power in the window when a [bus depot system](https://www.evtivity.com/docs/integrations/bus-depot-systems#preconditioning) asks for preconditioning.

A fleet vehicle is a vehicle of a driver of the fleet.

### Step 3: Enter Departures

Open the fleet and select the **Departures** tab.

![Fleet Departures tab](https://www.evtivity.com/screenshots/csms/fleet-departures-tab.png)

**Weekly Schedules** lists the repeating departures. Click **Add Schedule** and pick the vehicle, the depot, the days, the **Departure Time** in the depot's local time, the target and the priority. **Valid From** and **Valid To** optionally limit the schedule to a date range. Changing a schedule changes its upcoming departures, except the ones someone changed by hand. **Delete Schedule** cancels its upcoming departures the same way.

**Departures** lists the departures of the next 7 days, each with its **State**, **Delivered** energy of the target, **Predicted Ready** time, **Reason** and **Source**. Click **Add Departure** for a one-off departure, 5 minutes to 30 days ahead. Edit a departure to change its time, target, priority or expected arrival for that day only, or click **Cancel Departure** to cancel it. A completed or cancelled departure cannot change.

The **Status** filter lists **Scheduled**, **Cancelled** or **Completed** departures. Cancelled and completed departures show from the last 30 days. A cancelled departure shows why: **Cancelled by a person**, or one of the bus depot system reasons (**Removed by the bus depot system**, **Ended by the bus depot system**, **Replaced by a bus depot system request**).

The **Source** of a departure is **Manual**, **Schedule**, **Import** or **Bus Depot System**. A user who may see the bus depot systems (`settings.integrations:read` and access to every site) also sees the name of the system. Other users see **Bus Depot System** only.

The departure dialog optionally takes the expected arrival: **Expected Arrival Date**, **Expected Arrival Time** and **State of Charge at Arrival (%)**, 0 to 100. The arrival must be before the departure. The plan counts the vehicle from its arrival and uses that state of charge until the vehicle reports one. Leave the fields empty for none.

Every departure has a target of one of two kinds (**Target Type**):

- **Energy**: 0.1 to 2000 kWh from the charger.
- **State of Charge**: 1 to 100 %. It needs the vehicle's **Battery Capacity (kWh)**. This is the minimum the vehicle must reach. **Up To (%)** optionally sets a maximum between the target and 100 %: the vehicle charges further up to it when the site has power left that no other departure needs.

The vehicle must belong to a driver of the fleet, and the depot must be one of your sites. Adding or changing departures needs the `fleets:write` permission.

### Departures From a Bus Depot System

A [bus depot system](https://www.evtivity.com/docs/integrations/bus-depot-systems) sends the departures of its buses itself. They show on the same lists with the source **Bus Depot System**, and carry more data:

- **Expected arrival**: when the bus is expected to plug in and its expected state of charge, as for a departure you enter.
- **Ad hoc**: a request with no departure time. The bus charges as soon as it plugs in, earliest first.
- **Charging point**: the point the depot system expects the bus at. The bus may still plug in at another point.

While the depot system is enabled, its departures show **Managed by the bus depot system** and you cannot change or cancel them in the CSMS (`409 DEPARTURE_MANAGED_BY_DEPOT_SYSTEM`). Change them in the depot system. A departure of the depot system within 60 minutes of a departure you entered for the same bus replaces yours.

### Step 4: Import Departures From a CSV File

Click **Import CSV** on the **Departures** tab to import departures from a file your scheduling system exports. The file has a header row and these columns:

| Column | Content |
|--------|---------|
| `vehicle` | License plate, VIN or vehicle ID |
| `site` | Site name or ID |
| `departure` | ISO time with an offset, or `YYYY-MM-DD HH:MM` in the depot's local time |
| `energy_kwh` or `soc_percent` | The target: energy in kWh, or state of charge in percent |
| `priority` | Optional, 1 to 10 |
| `arrival` | Optional, the expected arrival, in the formats of `departure`. It must be before the departure. |
| `arrival_soc_percent` | Optional, the state of charge at arrival, 0 to 100 |

```bash
vehicle,site,departure,energy_kwh,priority,arrival,arrival_soc_percent
NGF-101,Northgate Fleet Depot,2026-11-02 05:30,220,5,2026-11-01 21:40,35
NGF-102,Northgate Fleet Depot,2026-11-02T06:15:00-08:00,180,8,,
```

- The file holds at most 2000 rows and 512 KB.
- A row that matches a manual or imported departure of the same vehicle within 10 minutes updates it, so you can import the same file again.
- The result lists the created, updated, unchanged and refused rows. A refused row names its row number, the field and the reason (missing, not found, matches more than one, not valid).

### Step 5: Choose the Departure Aware Strategy

On the Depot site's **Load Management** tab, select the **Departure Aware** strategy and set the **Finish Buffer (Minutes)**, 0 to 180. The strategy shows only while **Fleet Charging** is on. Panels, circuits and unmanaged loads set the limits as for every load managed site.

![Load Management with the Departure Aware strategy](https://www.evtivity.com/screenshots/csms/site-load-management-departure-aware.png)

Sessions without a departure at the site share the power the plan leaves, equally.

## Fleet Readiness

The **Fleet Readiness** tab shows on Depot sites. It lists the departures from 2 hours ago to 48 hours ahead and the stations their vehicles charge at, in the depot's local time, with a count per state.

The **Charging Plan** chart shows the planned power of each vehicle over the next 24 hours against the **Site Capacity** line. Shaded periods have a higher electricity price than the rest of the day. **Recalculate** plans the site again within a few seconds (`loadManagement:write`).

Each departure shows its **Source**, as on the **Departures** tab. The **Scheduled** and **Cancelled** buttons switch the list. **Cancelled** lists the departures cancelled in the last 7 days or for the next 48 hours, each with why it was cancelled, without readiness. An ad hoc request shows no departure time and charges as soon as its bus plugs in. A departure with a maximum state of charge counts as ready once it reaches its minimum.

While planning is off (**Fleet Charging** is off, or the site does not use the **Departure Aware** strategy), the tab lists the departures and names what turns planning on, and leaves out the chart, the states and **Recalculate**.

### Readiness States

| State | Meaning |
|-------|---------|
| Ready | The vehicle has the energy it needs. |
| On Track | The plan meets the target before the finish buffer starts. |
| At Risk | The plan meets the target only inside the finish buffer, a higher priority vehicle takes the power it needs, the charger does not follow its schedule, the charger refused its profile, the station is offline, or the vehicle is not plugged in and plugging it in now would no longer meet the target with the buffer. |
| Cannot Meet | The vehicle cannot reach its target by its departure, even with all the power of its path to itself at its maximum power. |
| Waiting For Vehicle | The vehicle is not plugged in yet, and plugging it in now would still meet the target with the buffer. |

### Reasons

| Reason | Meaning |
|--------|---------|
| Site Capacity | A panel, circuit or phase limit leaves too little power. |
| Not Plugged In | The vehicle is not charging at the depot. |
| Late Arrival | The vehicle plugged in too late for its target. |
| Charger Not Following | The charger draws more than its limit. The CSMS lowers the station limit at once and plans around its measured draw. |
| Profile Rejected | The charger refused its schedule. It follows only its station limit, and the CSMS tries the schedule again every hour. |
| Station Offline | The station lost its connection. Its last limit stays reserved for it. |
| Vehicle Power | The vehicle's maximum charge power is too low for its target. |
| Unknown State of Charge | The target is a state of charge, but the vehicle reports none. The plan assumes it arrived empty. |

When a departure passes, it completes as met, short, or without a vehicle when no session charged for it.

### Assign a Vehicle to a Session

The CSMS matches a charging session to a vehicle in this order: the vehicle id the charger reports ([Autocharge](https://www.evtivity.com/docs/csms/autocharge) or a captured VIN, EVCCID or MAC address), an RFID card linked to the vehicle (`vehicleId` of the token in the API), and the driver's only vehicle. A session with a vehicle that has a departure at the site charges for the earliest such departure.

A session without a match shows under **Sessions Without a Vehicle** and shares power equally. Click **Assign Vehicle** and pick a vehicle of the session's driver, or of a driver of a fleet that holds the station. Only the vehicle changes, never the driver or the billing. Assigning needs the `sessions:write` permission.

## 3D Layout

In the 3D [layout](https://www.evtivity.com/docs/csms/sites#layout) of a Depot, each parked vehicle with a departure carries a label with its departure time and readiness, colored by state, for example the time it is ready, or how many kWh it will be short. The station popup adds the **Departure**, **Target**, **Delivered**, **Predicted Ready** and **Reason** rows. While planning is off, the label shows the departure time only and the popup leaves out **Predicted Ready** and **Reason**.

![Depot in 3D with departure labels](https://www.evtivity.com/screenshots/csms/site-layout-3d-fleet-depot-departures.png)

## Notifications

The **Fleet Departure Alerts** group on the [Notifications](https://www.evtivity.com/docs/csms/notifications) page holds two events:

- **Departure at Risk**: a departure turns At Risk or Cannot Meet. Sent once per departure: a departure that returns to On Track and turns at risk again sends no second notice.
- **Departure Missed**: a departure completes short or without a vehicle. Sent once per departure.

They go to active users with the `fleets:read` permission and access to the depot site. Edit the email and SMS templates, or turn an event off, on the Notifications page.

## Data Retention

Completed and cancelled departures are kept for 365 days by default (**Vehicle Departures** in **Settings > Data Retention**). See [Data Retention](https://www.evtivity.com/docs/configuration/data-retention).

## Limits

- Targets are energy from the charger. Charger-measured energy includes charging losses, so the battery receives somewhat less than the target.
- Many chargers and vehicles report no state of charge. Enter targets in kWh when your vehicles do not report it. A state of charge target without a reading assumes the vehicle arrived empty.
- A charger may not follow its schedule exactly. The CSMS measures every 10 seconds and recalculates the plan, and the station limit keeps the site within its breaker limits.
- The station limit stays the safety ceiling. No departure value raises any power above a panel, circuit or phase limit.
- Vehicles not yet plugged in get no power reserved. They show Waiting For Vehicle or At Risk until they plug in.
- Roaming sessions at a depot have no departure and share the remaining power.

## Permissions

| Action | Permission |
|--------|-----------|
| View departures and schedules | `fleets:read` |
| Add, change, cancel and import departures and schedules | `fleets:write` |
| View the Fleet Readiness tab | `loadManagement:read` |
| Recalculate the plan, choose the strategy and the finish buffer | `loadManagement:write` |
| Assign a vehicle to a session | `sessions:write` |
| Set vehicle battery data | `drivers:write` |
