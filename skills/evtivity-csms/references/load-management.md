Generated from https://www.evtivity.com/docs/csms/load-management (website commit ffa3c26). Do not edit.

# Load Management

Distribute available power across charging stations using hierarchical panel and circuit modeling with automatic 10-second control loops.

## Overview

Load management prevents electrical infrastructure overload by dynamically distributing available power across charging stations at a site. It models your physical electrical hierarchy (panels, circuits, unmanaged loads) and runs a 10-second control loop that adjusts station power limits via OCPP `ChargingStationExternalConstraints` profiles.

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
maxContinuousKw = breakerRatingAmps * voltageV * phases * 0.8 / 1000
```

Circuits inherit voltage and phase count from their parent panel.

## Configure Load Management

### Step 1: Create the Electrical Hierarchy

1. Navigate to the site detail page.
2. Open the **Load Mgmt** tab.
3. Click **Add Panel** to create your first electrical panel. Enter:
   - Panel name
   - Breaker rating (amps)
   - Voltage (V)
   - Number of phases
4. Within the panel, click **Add Circuit** to create circuits. Enter:
   - Circuit name
   - Breaker rating (amps)
5. Assign stations to circuits using the station-to-circuit assignment control.
6. Add unmanaged loads to panels or circuits if applicable.

### Step 2: Enable Load Management

1. In the Load Mgmt tab, toggle **Enable Load Management**.
2. Select an allocation strategy:

| Strategy | Behavior |
|----------|----------|
| Equal Share | Distributes available power equally among stations with active sessions. Stations hitting their max cap get capped and surplus is redistributed. |
| Priority Based | Groups stations by priority (1-10, default 5). Higher priority groups get first claim. Equal share within each group. Stations with earlier departure times get secondary priority. |

3. Save the configuration.

### Step 3: Set Station Priorities (Priority Based Only)

If using the priority-based strategy:

1. In the Load Mgmt tab, find the station allocations table.
2. Set the **Load Priority** for each station (1 = lowest, 10 = highest).
3. Priority 5 is the default for all stations.

## Allocation Algorithm

The algorithm runs bottom-up through the hierarchy:

1. **Circuit level**: Compute available power (`maxContinuousKw - unmanagedLoadKw`). Distribute among active stations using the selected strategy.
2. **Panel level (bottom-up)**: Compute panel available power (`maxContinuousKw - safetyMarginKw - unmanagedLoadKw`). If total child demand exceeds available, scale all child allocations proportionally.
3. **Final output**: Per-station power allocations in watts.

## Control Loop

When enabled, the system runs a 10-second polling cycle for each site:

1. Query station status, active sessions, and recent meter values.
2. Build the hierarchy tree with current power consumption.
3. Compute new allocations.
4. Compare against the previous cycle using a JSON hash.
5. If allocations changed, send `SetChargingProfile` commands with `ChargingStationExternalConstraints` purpose to each affected station.

Allocations are logged in the allocation history for audit purposes.

## View Allocation Status

The Load Mgmt tab displays:

- **Power bar**: Visual representation of total available vs. consumed power.
- **Station allocations table**: Current allocation per station with actual power consumption.
- **Allocation history**: Timestamped log of allocation changes.

Data refreshes every 5 seconds automatically.

## Interaction with Smart Charging

Load management and smart charging operate on different OCPP profile purposes:

| Feature | OCPP Purpose |
|---------|-------------|
| Load Management | `ChargingStationExternalConstraints` |
| Smart Charging | `ChargingStationMaxProfile` or `TxDefaultProfile` |

The station composes all active profiles and applies the most restrictive limit at any point in time. A smart charging recurring schedule sets the ceiling. Load management distributes within it.

## Requirements

- Stations must be assigned to circuits to participate in load management.
- Stations with no circuit assignment are excluded from allocation.
- The station must be online to receive power limit commands.
- Set a max power on every connector. A connector without one is capped at its equal share of the circuit, not at its rating. OCPP 2.1 stations fill in the max power from their configuration report. For OCPP 1.6 stations, set it on the station **Connectors** tab, where a **Max power unknown** badge marks the missing value. See [Max power](https://www.evtivity.com/docs/csms/stations#connectors).
- OCPP 1.6 and 2.1 stations are both supported (command translation handles version differences).
