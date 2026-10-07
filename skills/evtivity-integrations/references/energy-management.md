Generated from https://www.evtivity.com/docs/integrations/energy-management (website commit 4cd1866). Do not edit.

# Energy Management

Load management, smart charging profiles, and carbon footprint tracking.

EVtivity provides site-level load management, template-based smart charging profiles, and per-session carbon footprint tracking.

## Load Management

### Hierarchy

Each site models its electrical infrastructure as a hierarchy:

- **Panels**: top-level distribution points with a power capacity limit
- **Circuits**: branches under a panel, each with its own limit
- **Unmanaged loads**: non-EV loads on a circuit (HVAC, lighting) that reduce available capacity for charging

The load management system distributes available power across stations connected to each circuit.

### Allocation Strategies

| Strategy | Behavior |
|---|---|
| `equal_share` | Divides available power evenly across all active stations on the circuit |
| `priority_based` | Allocates power by each station's `loadPriority` value. Higher priority stations receive power first. |

### Control Loop

The load management worker runs every 10 seconds via BullMQ. Each site is processed with a concurrency limit of 5 to prevent overloading the OCPP message pipeline.

When the worker recalculates limits, it sends OCPP charging profiles to each station using the `ChargingStationExternalConstraints` purpose. This purpose is reserved exclusively for load management. Smart charging templates use separate purposes to avoid conflicts.

## Smart Charging Profiles

Smart charging profiles are managed through templates and pushed to stations in batches.

### Purposes

| Purpose | Usage |
|---|---|
| `ChargingStationMaxProfile` | Sets the maximum power for the entire station |
| `TxDefaultProfile` | Sets the default power limit for new transactions |
| `ChargingStationExternalConstraints` | Reserved for load management (not used by templates) |

### Schedule Kinds

| Kind | Behavior |
|---|---|
| `Absolute` | Fixed start and end time. Runs once. |
| `Recurring` | Repeats daily or weekly on a schedule. |

### Profile Stacking

Multiple profiles can coexist on a station. Within the same purpose, the profile with the higher `stackLevel` takes precedence. The station computes a composite schedule from all active profiles across purposes.

Use `GetCompositeSchedule` to query a station for its merged result across all active profiles.

### Interaction with Load Management

Load management writes profiles with `ChargingStationExternalConstraints`. Smart charging templates write profiles with `ChargingStationMaxProfile` or `TxDefaultProfile`. The station composes limits from both sources, applying the most restrictive constraint at any given time.

## Carbon Footprint Tracking

EVtivity calculates CO₂ avoided per charging session by comparing EV charging emissions against gasoline vehicle emissions.

### Formula

```bash
CO₂ avoided = gasoline CO₂ per mile - grid CO₂ per mile
```

Grid emission factors come from two sources:

| Source | Coverage |
|---|---|
| EPA eGRID | 27 US regions |
| Ember | 33 international regions |

Trees equivalent is calculated as: `CO₂ avoided / 21.77 kg per tree per year`.

### Configuration

Each site is assigned a carbon region that determines which emission factor to use. Set this in the site settings.

### Reporting

- **Dashboard**: carbon stats card showing total CO₂ avoided and trees equivalent
- **Sustainability report page**: detailed breakdown by site and time period with CSV export
