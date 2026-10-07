Generated from https://www.evtivity.com/docs/csms/station-configurations-ocpp21 (website commit 4cd1866). Do not edit.

# OCPP 2.1 Components & Variables

Standardized components and variables defined by OCPP 2.1, organized by functional block, with read/write semantics and per-EVSE scope.

## Overview

OCPP 2.1 replaces 1.6's flat key list with a hierarchical model: a station has _components_, components expose _variables_, and each variable carries up to four typed _attributes_ (`Actual`, `Target`, `MinSet`, `MaxSet`). Configuration is read with `GetVariables` (point) or `GetBaseReport` (full inventory) and written with `SetVariables`.

Stations describe their own configuration shape: a `NotifyReport` from the station enumerates every component, variable, attribute, data type, mutability, and constraint. A CSMS can validate writes against that schema rather than guessing.

A few protocol facts to keep in mind:

- Components can be _instanced_ per EVSE or per connector via `evse.id` and `evse.connectorId`. Station-wide components leave both fields unset.
- Each variable has a `dataType` (`boolean`, `integer`, `decimal`, `string`, `dateTime`, `OptionList`, `SequenceList`, `MemberList`).
- Each variable has a `mutability`: `ReadOnly`, `WriteOnly`, or `ReadWrite`.
- `SetVariables` returns a per-variable status (`Accepted`, `Rejected`, `RebootRequired`, `NotSupported`, `UnknownComponent`, `UnknownVariable`).

The catalog below covers the standard components and the variables most operators actually touch. The full list runs to several hundred variables; the OCPP 2.1 specification is the authoritative reference.

## Authorization (`AuthCtrlr`)

Master controls for how the station authorizes tokens.

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch for authorization (free-vending sets this to `false`) |
| `AdditionalInfoItemsPerMessage` | integer | RW | Max entries in `additionalInfo` per `AuthorizeRequest` |
| `AuthorizeRemoteStart` | boolean | RW | Authorize tokens from `RequestStartTransaction` against backend |
| `LocalAuthorizeOffline` | boolean | RW | Authorize against local list while offline |
| `LocalPreAuthorize` | boolean | RW | Skip backend authorization when token is in local list |
| `MasterPassGroupId` | string | RW | Token group permitted to stop transactions started by other tokens |
| `OfflineTxForUnknownIdEnabled` | boolean | RW | Allow transactions for unknown tokens while offline |
| `DisableRemoteAuthorization` | boolean | RW | Reject all `RequestStartTransaction` from CSMS |

## Transaction Control (`TxCtrlr`)

When transactions start, when they stop, and timeouts.

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `EVConnectionTimeOut` | integer (s) | RW | Time after authorization before unlock if no EV plugs in |
| `MaxEnergyOnInvalidId` | integer (Wh) | RW | Energy ceiling when the ID becomes invalid mid-charge |
| `StopTxOnEVSideDisconnect` | boolean | RW | Stop transaction when EV is unplugged |
| `StopTxOnInvalidId` | boolean | RW | Stop transaction when the ID becomes invalid |
| `TxStartPoint` | SequenceList | RW | Events that start a transaction (`PowerPathClosed`, `EVConnected`, `Authorized`, etc.) |
| `TxStopPoint` | SequenceList | RW | Events that stop a transaction |

## Sampled Data (`SampledDataCtrlr`)

What the station samples on its meter and when.

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch for sampled data |
| `TxStartedMeasurands` | MemberList | RW | Measurands sampled at transaction start |
| `TxUpdatedMeasurands` | MemberList | RW | Measurands sampled during a transaction |
| `TxUpdatedInterval` | integer (s) | RW | Period between in-transaction samples |
| `TxEndedMeasurands` | MemberList | RW | Measurands sampled when a transaction ends |
| `TxEndedInterval` | integer (s) | RW | If non-zero, batches end-of-transaction samples at this interval |

Common measurands: `Energy.Active.Import.Register`, `Power.Active.Import`, `Current.Import`, `Voltage`, `SoC`, `Temperature`, `Frequency`.

## Aligned Data (`AlignedDataCtrlr`)

Clock-aligned meter values (independent of transactions).

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch for clock-aligned sampling |
| `Interval` | integer (s) | RW | Alignment interval (e.g. 900 = on the quarter hour) |
| `Measurands` | MemberList | RW | Measurands sampled at each alignment |
| `SendDuringIdle` | boolean | RW | Send aligned samples even when no transaction is active |

## OCPP Communications Controller (`OCPPCommCtrlr`)

CSMS communication parameters.

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `HeartbeatInterval` | integer (s) | RW | Heartbeat send interval |
| `MessageAttempts` | integer | RW | Retries on transaction message failure |
| `MessageAttemptInterval` | integer (s) | RW | Wait between retries |
| `MessageTimeout` | integer (s) | RW | OCPP message response timeout |
| `WebSocketPingInterval` | integer (s) | RW | WebSocket ping interval |
| `OfflineThreshold` | integer (s) | RW | Time without successful CSMS contact before declaring offline |
| `ResetRetries` | integer | RW | Soft-reset retries before hard reset |
| `NetworkConfigurationPriority` | SequenceList | RW | Order in which network profiles are tried |

## Reservation (`ReservationCtrlr`)

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch for reservations |
| `NonEvseSpecific` | boolean | R | Whether reservations can target the station rather than a specific EVSE |

## Smart Charging (`SmartChargingCtrlr`)

Tariff-aware power scheduling.

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch for `SetChargingProfile` |
| `ACPhaseSwitchingSupported` | boolean | R | Whether the station can switch between 1-phase and 3-phase mid-charge |
| `EntriesChargingProfiles` | integer | R | Max charging profiles installed at once |
| `LimitChangeSignificance` | decimal | RW | Min change (kW) before the station notifies the CSMS |
| `PeriodsPerSchedule` | integer | R | Max periods per charging schedule |
| `ProfileStackLevel` | integer | R | Max stack level supported |
| `RateUnit` | MemberList | R | `A`, `W`, or both |

## Display Messages (`DisplayMessageCtrlr`)

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch |
| `NumberOfDisplayMessages` | integer | R | Max messages stored at once |
| `PersonalMessageSize` | integer | R | Max length of a single message |
| `SupportedFormats` | MemberList | R | `ASCII`, `HTML`, `URI`, `UTF8` |
| `SupportedPriorities` | MemberList | R | Priorities the station respects |

## Tariff &amp; Cost (`TariffCostCtrlr`)

In-session pricing display.

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `TariffEnabled` | boolean | RW | Whether the station displays tariff information |
| `CostEnabled` | boolean | RW | Whether the station displays running cost |
| `Currency` | string (ISO 4217) | RW | Currency for displayed amounts |

## Local Authorization List (`LocalAuthListCtrlr`)

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch |
| `Entries` | integer | R | Current entry count |
| `ItemsPerMessage` | integer | R | Max entries per `SendLocalList` message |
| `Storage` | integer | R | Max entries the station can store |

## Authorization Cache (`AuthCacheCtrlr`)

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch |
| `LifeTime` | integer (s) | RW | Cache entry TTL |
| `Storage` | integer | R | Max cache entries |

## Security Controller (`SecurityCtrlr`)

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `BasicAuthPassword` | string | WO | Basic Auth password (returned write-only to avoid leaking) |
| `CertificateEntries` | integer | R | Number of installed certificates |
| `Identity` | string | RW | Station's identity string used in Basic Auth |
| `OrganizationName` | string | RW | Used in CSRs |
| `SecurityProfile` | integer | R | 0, 1, 2, or 3. Read-only. The CSMS changes it with a new network connection profile (`SetNetworkProfile`) and `OCPPCommCtrlr.NetworkConfigurationPriority`. |
| `AdditionalRootCertificateCheck` | boolean | R | Validates server cert against an additional root |

## ISO 15118 / Plug &amp; Charge (`ISO15118Ctrlr`)

Required for Plug &amp; Charge support.

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Enabled` | boolean | RW | Master switch for ISO 15118 |
| `CentralContractValidationAllowed` | boolean | RW | Allow CSMS to validate contract certificates |
| `ContractValidationOffline` | boolean | RW | Allow station to validate contract certificates while offline |
| `RequestMeteringReceipt` | boolean | RW | Request signed metering receipts from the EV |

## Connector / EVSE Components

These are component _instances_ - one per physical part - with their own variables.

### `EVSE` (per EVSE)

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Available` | boolean | RW | Whether the EVSE is operational |
| `AvailabilityState` | OptionList | R | Current availability status |
| `Power` | decimal (W) | R | Current power being delivered |
| `SupplyPhases` | integer | R | Number of supply phases (1 or 3) |
| `AllowReset` | boolean | R | Whether `Reset` is supported on this EVSE |

### `Connector` (per connector)

| Variable | Type | Mutability | Purpose |
|----------|------|------------|---------|
| `Available` | boolean | RW | Whether the connector is operational |
| `AvailabilityState` | OptionList | R | Current availability |
| `ConnectorType` | OptionList | R | `cType1`, `cType2`, `cCCS1`, `cCCS2`, `cCHAdeMO`, `cTesla`, etc. |
| `SupplyPhases` | integer | R | Phases on this connector |

## Mutability Cheat Sheet

- **R** (ReadOnly): Read with `GetVariables`, write returns `Rejected`.
- **RW** (ReadWrite): Read and write.
- **WO** (WriteOnly): Write only. Reads return the variable in the `unknown` array (avoids leaking secrets like `BasicAuthPassword`).

## Per-EVSE Scope

Component instances let you configure differently per EVSE. For example:

- `SampledDataCtrlr.TxUpdatedInterval` set station-wide to 60s, but on EVSE 1 set to 10s for a high-priority customer
- `Connector.Available = false` to take a single connector out of service while the rest of the station keeps running

The CSMS encodes this via `evse.id` and `evse.connectorId` in `SetVariables`. EVtivity templates support per-EVSE values when authoring the component path.

## Vendor Variables

Stations are free to expose custom components and variables. They appear in `NotifyReport` like any other variable, and EVtivity will read and write them. Custom variables don't go through the standard schema validation, so the CSMS surfaces a `Rejected` if the station refuses the value.

## See Also

- [Station Configurations overview](https://www.evtivity.com/docs/csms/station-configurations)
- [OCPP 1.6 Configuration Keys](https://www.evtivity.com/docs/csms/station-configurations-ocpp16)
