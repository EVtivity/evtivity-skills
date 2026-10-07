Generated from https://www.evtivity.com/docs/csms/station-configurations (website commit ffa3c26). Do not edit.

# Station Configurations

Industry standards for charger configuration, OCPP variable model differences, and how EVtivity CSMS pushes configuration to fleets.

## Overview

A charging station's behavior is shaped almost entirely by its configuration: which authorization tokens it accepts, how aggressively it samples meter values, whether it allows offline transactions, what it shows on its display, how it negotiates power, and dozens of other knobs. Configuration is the operator's primary lever for tuning a fleet without firmware changes.

EVtivity CSMS lets you express that configuration as templates, target it at a slice of your fleet, push it over the wire, and verify that the fleet stayed in compliance.

![Station configurations list](https://www.evtivity.com/screenshots/csms/station-configurations.png)

## Industry Standards

Charging station configuration is governed by a small stack of standards. Knowing where each layer sits helps explain why OCPP looks the way it does.

| Standard | Body | Scope |
|----------|------|-------|
| **OCPP** (Open Charge Point Protocol) | Open Charge Alliance (OCA) | CSMS-to-station messages, including configuration management |
| **IEC 61851** | IEC | Physical conductive charging, signalling between EV and EVSE |
| **ISO 15118** | ISO/IEC | Vehicle-to-grid communication, Plug & Charge identification |
| **IEC 63110** | IEC | Management of EV charging infrastructure (overlaps with OCPP at higher layers) |
| **OpenADR** | OpenADR Alliance | Demand response signals from utilities to operators |

OCPP is what an operator deals with day-to-day. ISO 15118 controls Plug & Charge but rides over the existing OCPP transport. IEC 61851 lives below OCPP entirely. OpenADR feeds the operator's upstream grid signals; the operator translates those into OCPP commands. For configuration management specifically, OCPP is the only standard that matters.

## OCPP Versions and the Configuration Model

Two versions of OCPP are in active deployment: 1.6 (2015, still the majority of installed stations as of 2026) and 2.1 (2024, supersedes 2.0.1 with backward-compatible additions). They differ fundamentally in how a station's configuration is described.

### OCPP 1.6: Flat Key-Value Configuration

OCPP 1.6 treats station configuration as a flat list of named keys. Each key has a single value, a read-only flag, and a hint about whether changing it requires a reboot. There are roughly 50 standard keys (`HeartbeatInterval`, `MeterValueSampleInterval`, `LocalPreAuthorize`, etc.) and vendors are free to add their own.

| Aspect | OCPP 1.6 |
|--------|----------|
| Read configuration | `GetConfiguration` returns the whole list |
| Write configuration | `ChangeConfiguration` with one key/value pair per call |
| Discovery | Vendors self-document custom keys; no machine-readable schema |
| Type information | All values transferred as strings; client must know the type |
| Hierarchy | None. Keys are flat |
| Per-EVSE values | Not supported. Configuration is station-wide |

The strength is simplicity. The weakness is that a CSMS cannot know in advance whether a key exists, what type it accepts, or which vendor key is the equivalent of a standard key on another vendor.

[See the OCPP 1.6 configuration keys reference &rarr;](https://www.evtivity.com/docs/csms/station-configurations-ocpp16)

### OCPP 2.1: Component &times; Variable Model

OCPP 2.1 replaced the flat list with a hierarchical model. Configuration lives on _components_ (logical parts of the station), each component exposes _variables_, and each variable carries up to four typed _attributes_.

```
Component
   |
   +-- Variable
            |
            +-- Attribute (Actual | Target | MinSet | MaxSet)
                   - dataType (boolean, integer, decimal, string, ...)
                   - mutability (ReadOnly | WriteOnly | ReadWrite)
                   - unit
                   - constant flag
```

A few examples:

- `AuthCtrlr.Enabled` (boolean) - master switch for authorization on the whole station
- `TxCtrlr.EVConnectionTimeOut` (integer, seconds) - how long the station waits for a vehicle to plug in after authorization
- `SampledDataCtrlr.TxUpdatedMeasurands` (sequence of MeasurandEnum) - which meter values the station reports during a transaction

| Aspect | OCPP 2.1 |
|--------|----------|
| Read configuration | `GetVariables` (point lookup) and `GetBaseReport` (full report) |
| Write configuration | `SetVariables` with multiple component/variable updates per call |
| Discovery | `NotifyReport` enumerates every component, variable, and attribute the station supports |
| Type information | Each variable declares its data type, constraints, and mutability |
| Hierarchy | Component &rarr; Variable &rarr; Attribute |
| Per-EVSE values | Components can be instanced per EVSE or connector (`evse.id`, `evse.connectorId`) |

The model is verbose, but a CSMS can introspect a station, validate writes against the station's reported schema, and reason about per-connector configuration.

[See the OCPP 2.1 component / variable reference &rarr;](https://www.evtivity.com/docs/csms/station-configurations-ocpp21)

### Differences That Matter to Operators

| Concern | 1.6 | 2.1 |
|---------|-----|-----|
| Bulk reads | One `GetConfiguration` call returns everything | `GetBaseReport` requested, station replies asynchronously via `NotifyReport` |
| Bulk writes | One `ChangeConfiguration` call per key | One `SetVariables` call carries many updates |
| Schema introspection | Not possible | Stations advertise their schema via `NotifyReport` |
| Per-connector tuning | Not supported | First-class via component instances |
| Reboot requirement | Returned as `RebootRequired` on the response | Same, with finer-grained `Accepted` / `Rejected` / `RebootRequired` per variable |
| Error reporting | Single status per call | Per-variable status array |

For operators with mixed fleets the practical implication is that a single configuration template usually has to be authored twice: once for the 1.6 stations and once for the 2.1 stations. EVtivity CSMS handles each version with the right command and payload, but the template content itself reflects the underlying model.

## How EVtivity CSMS Handles Configuration

EVtivity treats configuration as a fleet-wide concern, not a per-station concern. The unit of work is a _template_ that targets a slice of the fleet.

### Templates

A template is a named bundle of configuration values plus a target filter. Each template is bound to a single OCPP version, because the variable model differs.

| Field | Description |
|-------|-------------|
| Name | Operator-facing identifier |
| Description | Free text explaining intent |
| OCPP Version | 1.6 or 2.1 (determines variable encoding) |
| Variables | Component / variable / value triples (or key / value pairs for 1.6) |
| Target Filter | Site, vendor, model, station selectors that combine with AND |

You can preview the matching station count before pushing.

![Create configuration template](https://www.evtivity.com/screenshots/csms/station-configurations-create.png)

Once a template is created, the detail page shows the variables and the target filter, and gives you the matching-station preview and push action.

![Template detail](https://www.evtivity.com/screenshots/csms/station-configurations-template.png)

### Push and Track

Pushing a template fans out an OCPP `SetVariables` (2.1) or `ChangeConfiguration` (1.6) command to every matching online station. Each push records per-station results so you can audit what happened:

| Per-Station Status | Meaning |
|--------------------|---------|
| Pending | Command queued, not yet acknowledged |
| Accepted | Station applied the change |
| Rejected | Station refused one or more variables; the rejection reason is captured |
| Failed | Communication failure or station offline before timeout |

The Push History tab on the template detail lists every push that has been initiated against this template.

![Push history](https://www.evtivity.com/screenshots/csms/station-configurations-push-history.png)

Click into any push record to see per-station progress with error details for any rejected or failed station.

![Push progress](https://www.evtivity.com/screenshots/csms/station-configurations-push-progress.png)

After a successful push the CSMS automatically refreshes the station's configuration view by issuing `GetBaseReport` (2.1) or `GetConfiguration` (1.6). The refreshed values feed the drift-detection step.

### Drift Detection

A station's live configuration can drift away from a template, either because someone set a variable directly on the station or because a firmware update reset defaults. EVtivity compares the station's current configuration against the most recently pushed template and flags any variable whose value no longer matches. You can re-push the template to bring drifted stations back into compliance.

### Station Detail: Configurations

Individual station configuration is visible on the station detail page under the **Configurations** tab. This is where you read or push configuration to a single station rather than an entire fleet slice.

![Station Configurations tab](https://www.evtivity.com/screenshots/csms/station-configurations-tab.png)

- **View**: read-only table of every variable the station is reporting, sourced from the most recent `NotifyReport` (2.1) or `GetConfiguration` response (1.6).
- **Refresh from Station**: re-issue the read so the table reflects the latest station state. The CSMS sends `GetBaseReport` (2.1) or `GetConfiguration` (1.6) and updates the table when the station replies. The screenshot above shows the table after a refresh has populated it from the live station.
- **Push Configuration**: push a single template to this one station. Useful for ad-hoc tuning or testing a template against one station before rolling it out fleet-wide. Clicking the button opens a dialog where you choose a template that matches the station's OCPP version.

![Station Push Configuration dialog](https://www.evtivity.com/screenshots/csms/station-configurations-push-dialog.png)

After a successful push, the same auto-refresh runs so the table immediately reflects the new values.

#### Instanced Variables

OCPP 2.1 components and variables can have an instance name. The table keeps one row per component, component instance, variable, variable instance, EVSE, connector, and attribute type. For example, `DeviceDataCtrlr.ItemsPerMessage` has the instances `GetReport` and `GetVariables`, and the table shows them as two rows with their own values. The CSMS splits large `GetVariables` requests by the `ItemsPerMessage[GetVariables]` value, and drift detection compares the top-level `Actual` row a template sets.

#### After Upgrading to v0.1.33

Before v0.1.33, rows that differed only by instance shared one row. That row kept the first instance name and the last value, so `ItemsPerMessage[GetVariables]` could show the `GetReport` limit. Database migration 0095 separates the rows from then on, but it does not correct the values already stored.

After you upgrade from a version earlier than v0.1.33, refresh every OCPP 2.1 station once:

1. Open the station detail page and go to the **Configurations** tab.
2. Click **Refresh from Station**. The station must be online.
3. Wait for the table to reload. The CSMS sends `GetBaseReport` (`FullInventory`), and the station's `NotifyReport` writes each instance to its own row.

Until a station is refreshed, the CSMS can split `GetVariables` requests by the wrong limit, and drift detection can compare against a stale value. An offline station gets the correct rows on its first refresh or template push after it reconnects. OCPP 1.6 stations have no instances and need no refresh.

### How It Compares to Adjacent Features

Configuration management is one of three independent OCPP write paths in the CSMS. Don't confuse them.

| Feature | OCPP Command | What It Changes |
|---------|--------------|-----------------|
| Station Configurations | `SetVariables` / `ChangeConfiguration` | Operating parameters (auth, timers, intervals, vendor flags) |
| Smart Charging | `SetChargingProfile` | Power delivery schedules |
| Firmware Campaigns | `UpdateFirmware` | Station software image |

A station can have all three pushed at once. They don't interact at the protocol level, and each tracks its own push history.

## Reference Pages

- [OCPP 1.6 Configuration Keys](https://www.evtivity.com/docs/csms/station-configurations-ocpp16) - flat key reference
- [OCPP 2.1 Components &amp; Variables](https://www.evtivity.com/docs/csms/station-configurations-ocpp21) - hierarchical reference
