Generated from https://www.evtivity.com/docs/csms/load-management. Do not edit.

# Load Management

Distribute available power across charging stations using hierarchical panel and circuit modeling with automatic 10-second control loops.

## Overview

Load management prevents electrical infrastructure overload by dynamically distributing available power across charging stations at a site. It models your physical electrical hierarchy (panels, circuits, unmanaged loads) and runs a 10-second control loop that sets each station's power limit with an OCPP `ChargingStationMaxProfile` (OCPP 1.6: `ChargePointMaxProfile`).

Load management is configured per site from the site detail page.

![Load management tab](https://www.evtivity.com/screenshots/csms/site-load-management-tab.png)

## Electrical Hierarchy

The system models the physical electrical tree:

```bash
Site
  Panel (breaker rating, voltage, phases)
    Circuit (breaker rating)
      Station 1
      Station 2
    Circuit
      Station 3
    Unmanaged Load (fixed kW draw)
  Sub-Panel
    Circuit
      Station 4
```

**Panels** represent electrical panels with breaker ratings, voltage, and phase count. Panels can contain sub-panels (nested hierarchy). **Circuits** represent individual breakers within a panel. Stations attach to circuits. **Unmanaged loads** represent non-EV electrical loads (HVAC, lighting) attached to a panel or circuit. Their power draw is subtracted from available capacity.

Maximum continuous power is computed automatically using the NEC 80% continuous load rule:

```bash
maxContinuousKw = breakerRatingAmps * voltageV * phaseFactor * 0.8 / 1000
```

The phase factor is 1 for one phase, 3 for three phases, and the square root of 3 (1.73) for a circuit on two phases of a three-phase panel, which runs at the line-to-line voltage.

The panel voltage is the voltage of a single-phase panel or the phase-to-neutral voltage of a three-phase panel: 120 V for 208Y/120, 230 V for 400Y/230, 277 V for 480Y/277. The voltages offered are 120, 208, 220, 230, 240, 277 and 480 V. A three-phase panel does not accept 208 V or 480 V, because those are line-to-line voltages.

A circuit uses the panel voltage unless you set its **Circuit Voltage (V)**. Only a circuit on a single-phase panel can set one, at or below the panel voltage, for example a 120 V circuit on a 240 V split-phase panel. Capacity and current limits use the circuit voltage. A lower-voltage circuit draws from one leg of the panel, so the panel check counts its load in proportion: a 120 V load counts twice on a 240 V panel.

A circuit uses all panel phases unless its **Phase Connections** name one or two of them, and its capacity counts only the phases it uses.

A single-phase sub-panel under a three-phase panel can name the parent phases that feed it in **Feeding Phases** (L1, L2 or L3 line to neutral, or L1-L2, L1-L3 or L2-L3 line to line). Its load then counts only on those phases. With **Unknown (counts on every phase)**, the default, its load counts in full on every phase of the parent panel.

## Configure Load Management

### Step 1: Create the Electrical Hierarchy

1. Navigate to the site detail page.
2. Open the **Load Mgmt** tab.
3. Click **Add Panel** to create your first electrical panel. Enter:
   - Panel name
   - Breaker rating (amps)
   - Voltage (V)
   - Number of phases
   - Feeding phases (a single-phase sub-panel under a three-phase panel; optional)
4. Within the panel, click **Add Circuit** to create circuits. Enter:
   - Circuit name
   - Breaker rating (amps)
   - Circuit voltage (single-phase panels; optional, the panel voltage by default)
   - Phase connections (three-phase panels; **Auto** uses all panel phases)
5. Assign stations to circuits using the station-to-circuit assignment control.
6. Add unmanaged loads to panels or circuits if applicable.

### Step 2: Enable Load Management

1. In the Load Mgmt tab, toggle **Enable Load Management**.
2. Select an allocation strategy:

| Strategy | Behavior |
|----------|----------|
| Equal Share | Distributes available power equally among stations with active sessions. Stations hitting their max cap get capped and surplus is redistributed. |
| Priority Based | Every session first gets its station minimum. Then stations are grouped by priority (1-10, default 5) and higher priority groups get first claim, with an equal share within each group. Stations with earlier departure times get secondary priority. |

3. Save the configuration.

### Step 3: Set Station Priorities and Minimums

1. In the Load Mgmt tab, find the **Station Allocations** table.
2. Set the **Priority** for each station (1 = lowest, 10 = highest). Priority 5 is the default. The priority orders power in the Priority Based strategy and decides which sessions stop first in both strategies.
3. Optionally set **Min Power (kW)** for a station: the lowest power a charging session there gets. Many EVs stop charging below about 6 A (1.4 kW on one phase, 4.1 kW on three phases at 230 V). Leave it empty for no minimum.

When the minimums of all sessions do not fit in a circuit or panel, the lowest priority sessions stop (limit 0) until the rest fit. The others never drop below their minimum.

## Allocation Algorithm

The algorithm runs bottom-up through the hierarchy:

1. **Circuit level**: Compute available power (`maxContinuousKw` minus the circuit's unmanaged loads and the power kept for offline stations). Distribute among active stations using the selected strategy.
2. **Panel level (bottom-up)**: Compute panel available power (`maxContinuousKw - safetyMarginKw` minus every unmanaged load in the panel, its circuits and its sub-panels, and the power kept for offline stations). If the stations below need more, the power above their minimums is reduced proportionally. On a three-phase panel, each phase is checked the same way.
3. **Final output**: Per-station power limits, never below zero.

A station that goes offline during a session keeps charging at the last limit it received, so that power stays reserved for it until it reconnects.

## Control Loop

When enabled, the system runs a 10-second polling cycle for each site:

1. Query station status, active sessions, and recent meter values.
2. Build the hierarchy tree with current power consumption.
3. Compute new allocations.
4. Compare them with the allocations last sent.
5. If they changed, send each station a `SetChargingProfile` with a `ChargingStationMaxProfile` on EVSE 0 (the whole station). Unchanged limits are sent again every 5 minutes, and after a failed send on the next cycle.

Each cycle sends every lowered limit first and the raised limits only after all cuts went out, so the stations together never hold more than the capacity while the limits change. When a cut fails, the raises wait for the next cycle.

A station that refuses its limit, or does not support smart charging, counts at its maximum power until it accepts one.

The limit is in watts. A station that reports support for amps only (OCPP 2.1 `SmartChargingCtrlr.RateUnit`, OCPP 1.6 `ChargingScheduleAllowedChargingRateUnit`) gets it in amps per phase, computed from its circuit's voltage and phases. The **Limit Unit** column shows which one each station gets.

When you turn load management off, or a station leaves its circuit or the site, its limit is removed from the station.

Changed allocations are logged in the Allocations list. The list keeps entries for 90 days by default (setting `logs.loadAllocation.retentionDays`; 0 keeps them forever).

## View Allocation Status

The Load Mgmt tab displays:

- **Power bar**: Visual representation of total available vs. consumed power.
- **Station allocations table**: Current allocation per station with actual power consumption, priority, minimum power and limit unit.
- **Allocations**: Timestamped log of allocation changes.

Data refreshes every 5 seconds automatically.

## Interaction with Smart Charging

Load management sends a `ChargingStationMaxProfile` with its own profile ID (1000000000) at stack level 1.

| Feature | OCPP Purpose |
|---------|-------------|
| Load Management | `ChargingStationMaxProfile`, stack level 1 |
| Smart Charging | `ChargingStationMaxProfile` or `TxDefaultProfile` |

A station applies the lowest limit across purposes, so a `TxDefaultProfile` template still caps sessions below the load management limit. Within the same purpose the highest stack level wins: on a load-managed station, the load management limit replaces a `ChargingStationMaxProfile` template at stack level 0.

On a load-managed station, the CSMS refuses a `ChargingStationMaxProfile` at stack level 1 or higher and any profile with the load management profile ID (`CHARGING_PROFILE_LOAD_MANAGED`), so no other profile lifts the breaker limit.

## Requirements

- Stations must be assigned to circuits to participate in load management.
- Stations with no circuit assignment are excluded from allocation.
- The station must be online to receive power limit commands.
- Set a max power on every connector. A connector without one is capped at its equal share of the circuit, not at its rating. OCPP 2.1 stations fill in the max power from their configuration report. For OCPP 1.6 stations, set it on the station **Connectors** tab, where a **Max power unknown** badge marks the missing value. See [Max power](https://www.evtivity.com/docs/csms/stations#connectors).
- OCPP 1.6 and 2.1 stations are both supported (command translation handles version differences).
