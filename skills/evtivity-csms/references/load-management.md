Generated from https://www.evtivity.com/docs/csms/load-management. Do not edit.

# Load Management

Distribute available power across charging stations within the limits of the site's transformers, panels and circuits, with battery and solar supply and an automatic 10-second control loop.

## Overview

Load management prevents electrical infrastructure overload by dynamically distributing available power across charging stations at a site. It models your physical electrical hierarchy (transformers, panels, circuits, unmanaged loads, batteries and solar) and runs a 10-second control loop that sets each station's power limit with an OCPP `ChargingStationMaxProfile` (OCPP 1.6: `ChargePointMaxProfile`).

Load management is configured per site from the site detail page.

Load management shares power within the limits you enter. It does not replace breakers or correctly sized wiring, so make sure every panel and circuit rating matches the installed equipment. The Load Management tab shows this warning while load management is on.

![Load management tab](https://www.evtivity.com/screenshots/csms/site-load-management-tab.png)

## Electrical Safety

Load management shares power within the limits you enter. It does not replace breakers, correctly sized wiring, listed equipment or a licensed electrical design. Make sure every transformer, panel and circuit rating you enter matches the installed equipment. The site layout is a representation of the site, never a certified or compliant design.

## Electrical Hierarchy

![Load management hierarchy: utility, service transformer, switchboard, circuits and stations, a step-down transformer feeding a panelboard, an unmanaged load, and a battery and solar array with their connection points](https://www.evtivity.com/images/load-management-hierarchy.png)

The system models the physical electrical tree:

```bash
Site
  Service Transformer (kVA, power factor, loading limit)
    Panel (breaker rating, voltage, phases)
      Circuit (breaker rating)
        Station 1
        Station 2
      Circuit
        Station 3
      Unmanaged Load (fixed kW draw)
      Step-Down Transformer (kVA)
        Sub-Panel
          Circuit
            Station 4
    Battery or Solar (connection point)
```

**Transformers** feed the panels: a service transformer feeds the top-level panels of the site, and a step-down transformer sits between a panel and a sub-panel. **Panels** represent electrical panels with breaker ratings, voltage, and phase count. Panels can contain sub-panels (nested hierarchy). **Circuits** represent individual breakers within a panel. Stations attach to circuits. **Unmanaged loads** represent non-EV electrical loads (HVAC, lighting) attached to a panel or circuit. Their power draw is subtracted from available capacity. **Batteries and solar** connect at a transformer or a panel and add capacity above that point while they report fresh readings.

The maximum continuous power of panels and circuits is computed automatically using the NEC 80% continuous load rule:

```bash
maxContinuousKw = breakerRatingAmps * voltageV * phaseFactor * 0.8 / 1000
```

The phase factor is 1 for one phase, 3 for three phases, and the square root of 3 (1.73) for a circuit on two phases of a three-phase panel, which runs at the line-to-line voltage.

The panel voltage is the voltage of a single-phase panel or the phase-to-neutral voltage of a three-phase panel: 120 V for 208Y/120, 230 V for 400Y/230, 277 V for 480Y/277. The voltages offered are 120, 208, 220, 230, 240, 277 and 480 V. A three-phase panel does not accept 208 V or 480 V, because those are line-to-line voltages.

A circuit uses the panel voltage unless you set its **Circuit Voltage (V)**. Only a circuit on a single-phase panel can set one, at or below the panel voltage, for example a 120 V circuit on a 240 V split-phase panel. Capacity and current limits use the circuit voltage. A lower-voltage circuit draws from one leg of the panel, so the panel check counts its load in proportion: a 120 V load counts twice on a 240 V panel.

A circuit uses all panel phases unless its **Phase Connections** name one or two of them, and its capacity counts only the phases it uses.

A single-phase sub-panel under a three-phase panel can name the parent phases that feed it in **Feeding Phases** (L1, L2 or L3 line to neutral, or L1-L2, L1-L3 or L2-L3 line to line). Its load then counts only on those phases. With **Unknown (counts on every phase)**, the default, its load counts in full on every phase of the parent panel.

## Transformers

A transformer limits the power of everything it feeds. Two types exist:

| Transformer Type | Where it sits | Linked from |
|---|---|---|
| Service Transformer | Feeds the top-level panels (switchboards) of the site's service, usually the utility's pad-mounted transformer. | A top-level panel |
| Step-Down Transformer | A dry-type unit fed from a panel breaker that feeds a sub-panel, such as 480 V to 208Y/120 V for Level 2 panelboards. | A sub-panel of the panel that feeds it |

### Add a Transformer

1. Open the **Load Management** tab of the site.
2. Click **Add Transformer** in the **Electrical Infrastructure** header.
3. Enter:
   - **Transformer Type**: **Service Transformer** or **Step-Down Transformer**
   - **Transformer Name**
   - **Rated Power (kVA)**: the nameplate rating. Pick a standard rating (45 to 3750 kVA for a service transformer, 75 to 500 kVA for a step-down transformer), **Custom Rating** for another value, or **Not Rated**.
   - **Phases** and **Secondary Voltage (V)**. A three-phase transformer does not accept a line-to-line secondary voltage, as for panels.
   - **Power Factor**: turns kVA into kW, 0.80 to 1.00, default 0.95.
   - **Loading Limit (%)**: the share of the nameplate rating load management may use, 50 to 100 percent, default 100.
   - **Safety Margin (kW)**: optional.
   - **Fed from Panel**: for a step-down transformer, the panel whose breaker feeds it (required).
4. Save the form.

The capacity of a transformer is:

```bash
maxContinuousKw = ratedKva * powerFactor * loadingLimitPercent / 100
```

For example, a 500 kVA transformer at power factor 0.95 and a loading limit of 100% gives 475 kW. The 80% rule of breakers does not apply to a transformer. A three-phase transformer is also checked per phase, at a third of its capacity on each phase.

### Link a Transformer

A transformer is a limit only once a panel names it. Open the panel's form and pick it in **Fed by Transformer**:

- A top-level panel offers the rated service transformers of the site. The transformer then limits this panel and everything below it. Several top-level panels can name the same service transformer, and a site can have several service transformers.
- A sub-panel offers the rated step-down transformers fed from its parent panel. The transformer then sits between the parent and this sub-panel and limits the sub-panel.
- **None** removes the link.

A transformer without a rating limits nothing and cannot feed a panel. Transformers that limit nothing yet (not rated, or no panel names them) show under **Transformers Not Linked**. Transformers entered in the site layout before they became load management equipment also show there, with their names and ratings, and limit nothing until you link them.

A linked transformer shows as a card above the panels it feeds, with its type, kVA, power factor, loading limit, phases, its maximum in kW and its load against its capacity, with one bar per phase for a three-phase transformer.

Below a three-phase panel, a three-phase step-down transformer carries the load of each secondary phase on two primary phases. Load management counts it that way, so a balanced load counts up to 15 percent high on the primary side, on the safe side.

Deleting a transformer keeps the panels it feeds. They no longer have its limit. Deleting a panel also deletes the step-down transformers fed from it.

## Energy Storage and Solar

The **Energy Storage and Solar** card lists the batteries and solar arrays of the site with their rating, **Connection Point**, **Supply** state, **Last Reading** (time, kW and state of charge) and **Credit**. A battery or solar array raises the capacity above its connection point while a fresh reading arrives.

### Add a Battery or Solar Array

1. On the **Load Management** tab, click **Add Battery or Solar**.
2. Enter:
   - **Type**: **Battery** or **Solar**
   - **Name**
   - For a battery: **Energy Capacity (kWh)**, **Max Discharge (kW)** and **Max Charge (kW)**
   - For solar: **Peak Power (kWp)**
   - For solar at a Parking Lot, with `sites:write`: **Row**, the lot row its carport covers in the site layout
   - **Inverter Output (kW)**: the AC nameplate output. No credit is ever above it.
   - **Phases**
   - **Connection Point**: a transformer, a panel, or **Not Connected**
   - For a battery: **Grid Charging** (**Never Charges from the Grid** or **May Charge from the Grid**) and **Reserve (%)**, default 10
   - **Readings**: **None**, **Sent by an EMS or Gateway (API)**, or **Simulated (Development and Demos)**
   - **Reading Lifetime (Seconds)**: how long a reading stays fresh, 15 to 600 seconds, default 60
3. Save the form.

![Edit Battery or Solar form for a battery](https://www.evtivity.com/screenshots/csms/site-energy-asset-battery.png)

![Edit Battery or Solar form for a solar array](https://www.evtivity.com/screenshots/csms/site-energy-asset-solar.png)

### Where the Credit Counts

The credit counts only on the equipment above the connection point:

- At a transformer, the credit counts on that transformer only.
- At a panel, it counts on the panels and the transformer above that panel, not on the panel itself.
- **Not Connected** counts nowhere.

A credit never lifts a transformer or panel above what the equipment it feeds can carry, so the panels and circuits below keep their own limits.

### How Much It Counts

- Solar gives the larger of the output it reports and the power it says it can give, up to its inverter output (else its peak power).
- A discharging battery gives the power it says it can give (else its current output), up to the lower of its max discharge and its inverter output. It gives nothing at or below its reserve.
- A charging battery gives no credit. Its charging power counts as load at its connection point and on everything above it.
- A reading above the nameplate is capped at the nameplate.

### Supply States

| Supply | Meaning |
|---|---|
| Live | A reading measured within the reading lifetime arrived. The asset counts as reported. |
| Stale | The last reading is older than the reading lifetime. The asset counts as no supply. |
| No Data | No reading arrived. The asset counts as no supply. |

Load management fails closed: without a fresh reading, a battery or solar array counts as no supply. A battery that may charge from the grid then counts as a load at its max charge power (else its inverter output), because it may be charging at full rate. With **Readings** set to **None**, an asset never gives supply. When the CSMS cannot read the readings or the assets, it gives no credit that cycle and keeps counting known batteries that may charge from the grid as load. When a credit ends, the next cycle lowers the limits it raised before it raises any other. A limit that rests on a reading also ends at the station when the reading goes stale, even when no cycle runs: the station holds the limit computed without readings, and the higher limit only until the reading expires.

The power bar of a node with a credit shows the credit as a separate **Local Supply** segment after the grid capacity.

On a depot that plans charging by departure, only the current slot of the plan uses the live credit. Later slots use the grid capacity alone. See [Route Aware Charging](https://www.evtivity.com/docs/csms/route-aware-charging).

**Simulated (Development and Demos)** computes readings in the CSMS: solar from the site's position and the time of day, and a battery that follows the site type. At a Depot site it discharges overnight while the buses charge and charges at midday. At other sites it discharges in the evening peak and charges at night and midday. It is offered only where the API and worker run with `ENERGY_ASSETS_ALLOW_SIMULATED` on, which is off in production by default. See [Environment Variables](https://www.evtivity.com/docs/configuration/environment-variables#load-management).

## Reporting Readings

An energy management system (EMS), battery management system or gateway sends the readings of a battery or solar array with an API key:

1. Set the asset's **Readings** to **Sent by an EMS or Gateway (API)**.
2. Create an API key with the `loadManagement:write` permission. See [API Keys](https://www.evtivity.com/docs/configuration/authentication#api-keys).
3. Send each reading to `PUT /v1/sites/{siteId}/energy-assets/{assetId}/reading`, more often than the reading lifetime, and at most once a second.

```bash
curl -X PUT "https://api.example.com/v1/sites/sit_abc123/energy-assets/ena_def456/reading" \
  -H "Authorization: Bearer $EVTIVITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"reportedAt":"2026-11-04T14:05:00Z","powerKw":42.5,"availableKw":60,"socPercent":78}'
```

| Field | Required | Values |
|---|---|---|
| `reportedAt` | Yes | When the asset measured the values (ISO 8601). Not more than 30 seconds in the future and not older than the reading lifetime. A time later than the arrival is stored as the arrival time. The reading lifetime counts from the earlier of the two. |
| `powerKw` | Yes | AC power in kW, -100,000 to 100,000: positive for output or discharge, negative while a battery charges. |
| `availableKw` | No | Power in kW the asset controller says it can give now, 0 to 100,000, or null when unknown. |
| `socPercent` | No | Battery state of charge, 0 to 100, or null when unknown. |

The API answers 204. The reading replaces the stored one. A reading reported earlier than the stored one changes nothing, and the API answers 409 `ENERGY_ASSET_READING_OUTDATED`. The CSMS keeps the latest reading of each asset only. It answers 400 `VALIDATION_ERROR` when the asset does not take readings from the API, `reportedAt` is out of range or a value is out of range, 404 `ENERGY_ASSET_NOT_FOUND` for an asset of another site or outside the API key's sites, and 429 after 60 readings a minute per asset and API key. See [Error Codes](https://www.evtivity.com/api-reference/error-codes#load-management).

## Configure Load Management

### Step 1: Create the Electrical Hierarchy

1. Navigate to the site detail page.
2. Open the **Load Management** tab.
3. Click **Add Panel** to create your first electrical panel. Enter:
   - Panel name
   - Breaker rating (amps)
   - Voltage (V)
   - Number of phases
   - Feeding phases (a single-phase sub-panel under a three-phase panel, optional)
   - Fed by transformer (optional)
4. Within the panel, click **Add Circuit** to create circuits. Enter:
   - Circuit name
   - Breaker rating (amps)
   - Circuit voltage (single-phase panels, optional, the panel voltage by default)
   - Phase connections (three-phase panels, **Auto** uses all panel phases)
5. On each circuit, click **Add Station** and pick the stations it feeds. **Remove** on a station row takes the station off the circuit after a confirmation. The station is not deleted. Stations of the site on no circuit show under **Stations Not on a Circuit**.
6. Add unmanaged loads to panels or circuits if applicable.
7. Add the site's transformers and link them to their panels (see [Transformers](#transformers)).
8. Add batteries and solar arrays and their connection points (see [Energy Storage and Solar](#energy-storage-and-solar)).

### Step 2: Enable Load Management

1. In the Load Management tab, toggle **Enable Load Management**.
2. Select an allocation strategy:

| Strategy | Behavior |
|----------|----------|
| Equal Share | Distributes available power equally among stations with active sessions. Stations hitting their max cap get capped and surplus is redistributed. |
| Priority Based | Every session first gets its station minimum. Then stations are grouped by priority (1-10, default 5) and higher priority groups get first claim, with an equal share within each group. Stations with earlier departure times get secondary priority. |
| Departure Aware | Plans the charging of fleet vehicles so each is ready by its departure, within the site capacity and at the lowest electricity price. Shown while the **Fleet Charging** setting is on. Set the **Finish Buffer (Minutes)**, 0 to 180, to finish charging that long before each departure. See [Route Aware Charging](https://www.evtivity.com/docs/csms/route-aware-charging). |

3. Save the configuration.

### Step 3: Set Station Priorities and Minimums

1. In the Load Management tab, find the station rows under each circuit. Each row shows the station status, session, power draw against its allocated limit, priority, minimum power and limit unit on one line. On a phone the tree scrolls sideways. A **Reserved** value is power kept for the station, not a limit sent to it.
2. Set the **Priority** for each station (1 = lowest, 10 = highest). Priority 5 is the default. The priority orders power in the Priority Based strategy and decides which sessions stop first in both strategies. You can change it only while the saved strategy is **Priority Based**. Otherwise the row shows the value.
3. Optionally set **Min Power (kW)** for a station: the lowest power a charging session there gets. Many EVs stop charging below about 6 A (1.4 kW on one phase, 4.1 kW on three phases at 230 V). Leave it empty for no minimum.

When the minimums of all sessions do not fit in a circuit or panel, the lowest priority sessions stop (limit 0) until the rest fit. The others never drop below their minimum.

## Allocation Algorithm

The algorithm runs bottom-up through the hierarchy:

1. **Circuit level**: Compute available power (`maxContinuousKw` minus the circuit's unmanaged loads and the power kept for offline stations). Distribute among active stations using the selected strategy.
2. **Panel and transformer level (bottom-up)**: Compute available power (`maxContinuousKw - safetyMarginKw` plus the battery and solar credit, minus every unmanaged load, battery charging load and power kept for offline stations below it). If the stations below need more, the power above their minimums is reduced proportionally. On a three-phase panel or transformer, each phase is checked the same way.
3. **Final output**: Per-station power limits, never below zero.

A station that goes offline during a session keeps charging at the last limit it received, so that power stays reserved for it until it reconnects.

### Station Local Generation

An OCPP 2.1 station that reports local generation (a `LocalGeneration` charging profile, OCPP 2.1 K27) may draw its limit plus the power of that generation. Load management counts that power as extra load on the station's circuit and on everything above it, and gives no credit for it, because the CSMS does not know where that generation connects.

## Control Loop

When enabled, the system runs a 10-second polling cycle for each site:

1. Query station status, active sessions, recent meter values, and the latest battery and solar readings.
2. Build the hierarchy tree with current power consumption.
3. Compute new allocations.
4. Compare them with the allocations last sent.
5. If they changed, send each station a `SetChargingProfile` with a `ChargingStationMaxProfile` on EVSE 0 (the whole station). Unchanged limits are sent again every 5 minutes, and after a failed send on the next cycle.

Each cycle sends every lowered limit first and the raised limits only after all cuts went out, so the stations together never hold more than the capacity while the limits change. When a cut fails, the raises wait for the next cycle.

A station that refuses its limit, or does not support smart charging, counts at its maximum power until it accepts one.

The limit is in watts. A station that reports support for amps only (OCPP 2.1 `SmartChargingCtrlr.RateUnit`, OCPP 1.6 `ChargingScheduleAllowedChargingRateUnit`) gets it in amps per phase, computed from its circuit's voltage and phases. The **Limit Unit** of each station row shows which one the station gets.

When you turn load management off, or a station leaves its circuit or the site, its limit is removed from the station.

Changed allocations are logged in the Allocations list. The list keeps entries for 90 days by default (**Load Management Allocations** in **Settings > Data Retention**). See [Data Retention](https://www.evtivity.com/docs/configuration/data-retention).

## View Allocation Status

The Load Management tab displays:

- **Power bar**: Visual representation of total available vs. consumed power, with the **Local Supply** credit of batteries and solar as its own segment.
- **Transformer cards**: Each linked transformer's load against its capacity, per phase for a three-phase transformer.
- **Energy Storage and Solar**: Each battery and solar array with its supply state, last reading and credit.
- **Station rows**: Under each circuit, each station with its status, session, power draw against its allocated limit, priority, minimum power and limit unit.
- **Allocations**: Timestamped log of allocation changes.

Data refreshes every 5 seconds automatically.

## Permissions

Viewing transformers, batteries and solar needs `loadManagement:read`. Adding, editing and deleting them, and sending readings, needs `loadManagement:write`. Without it the tab is read only.

## Interaction with Smart Charging

Load management sends a `ChargingStationMaxProfile` with its own profile ID (1000000000) at stack level 1. This is the limit computed without battery and solar readings. When a fresh reading allows more, it also sends a second `ChargingStationMaxProfile` with the next profile ID (1000000001) at stack level 2, with `validTo` set to the time the reading expires. The station uses the higher stack level while it is valid and returns to stack level 1 when it expires. A station that reports a maximum stack level below 2 (`SmartChargingCtrlr.ProfileStackLevel`, OCPP 1.6 `ChargeProfileMaxStackLevel`) gets the stack level 1 limit only.

| Feature | OCPP Purpose |
|---------|-------------|
| Load Management | `ChargingStationMaxProfile`, stack level 1, and stack level 2 while a battery or solar reading raises the limit |
| Smart Charging | `ChargingStationMaxProfile` or `TxDefaultProfile` |

A station applies the lowest limit across purposes, so a `TxDefaultProfile` template still caps sessions below the load management limit. Within the same purpose the highest stack level wins: on a load-managed station, the load management limit replaces a `ChargingStationMaxProfile` template at stack level 0.

On a load-managed station, the CSMS refuses a `ChargingStationMaxProfile` at stack level 1 or higher and any profile with either load management profile ID (`CHARGING_PROFILE_LOAD_MANAGED`), so no other profile lifts the breaker limit.

## Requirements

- Stations must be on a circuit to take part in load management (**Add Station** on the circuit).
- Stations on no circuit show under **Stations Not on a Circuit** and are excluded from allocation.
- The station must be online to receive power limit commands.
- Set a max power on every connector. A connector without one is capped at its equal share of the circuit, not at its rating. OCPP 2.1 stations fill in the max power from their configuration report. For OCPP 1.6 stations, set it on the station **EVSE & Connectors** tab, where a **Max power unknown** badge marks the missing value. See [Max power](https://www.evtivity.com/docs/csms/stations#connectors).
- OCPP 1.6, 2.0.1 and 2.1 stations are supported (command translation handles version differences).

## Notes

- The site layout stores only the positions of transformers, batteries and solar. Their names and ratings come from load management, so an integration of an earlier release that writes them through the layout API is not compatible.
