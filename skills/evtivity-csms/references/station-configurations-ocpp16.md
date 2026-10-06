Generated from https://www.evtivity.com/docs/csms/station-configurations-ocpp16 (website commit 257c8b8). Do not edit.

# OCPP 1.6 Configuration Keys

Standard configuration keys defined by OCPP 1.6, organized by purpose, with type and reboot semantics.

## Overview

OCPP 1.6 configuration is a flat list of named keys. Each key is read with `GetConfiguration` and written with `ChangeConfiguration`. The standard defines roughly 50 keys across nine functional areas. Vendors are free to add their own keys; those are not covered here.

A few protocol facts to keep in mind:

- All values travel as strings on the wire, regardless of underlying type.
- `ChangeConfiguration` returns one of `Accepted`, `Rejected`, `RebootRequired`, or `NotSupported`.
- A station only has to support keys for the features it actually implements. Reading an unsupported key returns it in the `unknownKey` array.

The tables below group standard keys by the OCPP 1.6 feature profile they belong to.

## Core Profile

The Core profile is mandatory. Every OCPP 1.6 station supports these keys.

| Key | Type | Mutability | Reboot | Purpose |
|-----|------|------------|--------|---------|
| `AllowOfflineTxForUnknownId` | boolean | RW | No | Allow transactions for unknown ID tags while offline |
| `AuthorizationCacheEnabled` | boolean | RW | No | Cache authorization responses locally for offline use |
| `AuthorizeRemoteTxRequests` | boolean | R or RW | No | Authorize tokens from `RemoteStartTransaction` against backend |
| `BlinkRepeat` | integer | RW | No | Number of times Light should blink for `Light` state |
| `ClockAlignedDataInterval` | integer (s) | RW | No | Period for clock-aligned `MeterValues` (0 disables) |
| `ConnectionTimeOut` | integer (s) | RW | No | Time after authorization to start the transaction before unlock |
| `ConnectorPhaseRotation` | CSL | RW | No | Phase rotation per connector (e.g. `RST`, `RTS`) |
| `ConnectorPhaseRotationMaxLength` | integer | R | - | Max number of items in `ConnectorPhaseRotation` list |
| `GetConfigurationMaxKeys` | integer | R | - | Max keys allowed in a single `GetConfiguration` request |
| `HeartbeatInterval` | integer (s) | RW | No | Heartbeat send interval |
| `LightIntensity` | integer (%) | RW | No | Percentage of max intensity for the indicator light |
| `LocalAuthorizeOffline` | boolean | RW | No | Authorize against the local list while offline |
| `LocalPreAuthorize` | boolean | RW | No | Authorize against the local list even while online (skip backend) |
| `MaxEnergyOnInvalidId` | integer (Wh) | RW | No | Max energy delivered if the ID becomes invalid mid-charge |
| `MeterValuesAlignedData` | CSL of measurands | RW | No | Measurands sampled at the clock-aligned interval |
| `MeterValuesAlignedDataMaxLength` | integer | R | - | Max measurands in `MeterValuesAlignedData` |
| `MeterValuesSampledData` | CSL of measurands | RW | No | Measurands sampled during a transaction |
| `MeterValuesSampledDataMaxLength` | integer | R | - | Max measurands in `MeterValuesSampledData` |
| `MeterValueSampleInterval` | integer (s) | RW | No | Period for transaction-related `MeterValues` (0 disables) |
| `MinimumStatusDuration` | integer (s) | RW | No | Min time a status must persist before reporting |
| `NumberOfConnectors` | integer | R | - | Number of physical connectors on the station |
| `ResetRetries` | integer | RW | No | Number of times a soft `Reset` is retried before hard reset |
| `StopTransactionOnEVSideDisconnect` | boolean | RW | No | Stop the transaction when the EV is unplugged |
| `StopTransactionOnInvalidId` | boolean | RW | No | Stop the transaction when the ID becomes invalid |
| `StopTxnAlignedData` | CSL of measurands | RW | No | Measurands sampled when a transaction stops at clock alignment |
| `StopTxnAlignedDataMaxLength` | integer | R | - | Max measurands in `StopTxnAlignedData` |
| `StopTxnSampledData` | CSL of measurands | RW | No | Measurands sampled when a transaction stops |
| `StopTxnSampledDataMaxLength` | integer | R | - | Max measurands in `StopTxnSampledData` |
| `SupportedFeatureProfiles` | CSL of strings | R | - | Profiles the station supports (Core, FirmwareManagement, etc.) |
| `SupportedFeatureProfilesMaxLength` | integer | R | - | Max items in `SupportedFeatureProfiles` |
| `TransactionMessageAttempts` | integer | RW | No | Retries for `StartTransaction` / `StopTransaction` on failure |
| `TransactionMessageRetryInterval` | integer (s) | RW | No | Wait between transaction message retries |
| `UnlockConnectorOnEVSideDisconnect` | boolean | RW | No | Unlock the cable when the EV is disconnected |
| `WebSocketPingInterval` | integer (s) | RW | No | WebSocket ping interval (security stack) |

## Local Authorization List Profile

Optional. Lets the station authorize tokens locally without backend roundtrip.

| Key | Type | Mutability | Reboot | Purpose |
|-----|------|------------|--------|---------|
| `LocalAuthListEnabled` | boolean | RW | No | Master switch for the local authorization list |
| `LocalAuthListMaxLength` | integer | R | - | Max number of entries in the list |
| `SendLocalListMaxLength` | integer | R | - | Max entries in a single `SendLocalList` request |

## Smart Charging Profile

Optional. Required for any operator that wants to set power schedules.

| Key | Type | Mutability | Reboot | Purpose |
|-----|------|------------|--------|---------|
| `ChargeProfileMaxStackLevel` | integer | R | - | Max `stackLevel` accepted in a charging profile |
| `ChargingScheduleAllowedChargingRateUnit` | CSL | R | - | `Current`, `Power`, or both |
| `ChargingScheduleMaxPeriods` | integer | R | - | Max periods per charging schedule |
| `ConnectorSwitch3to1PhaseSupported` | boolean | R | - | Whether the station can switch between 3-phase and 1-phase mid-charge |
| `MaxChargingProfilesInstalled` | integer | R | - | Max profiles the station will store at once |

## Reservation Profile

Optional.

| Key | Type | Mutability | Reboot | Purpose |
|-----|------|------------|--------|---------|
| `ReserveConnectorZeroSupported` | boolean | R | - | Whether the station accepts reservations for connector ID 0 (any) |

## Security (Security Profile 1, 2, 3)

Optional, defined in OCPP Security Whitepaper. Configures Basic Auth, TLS, and certificate handling.

| Key | Type | Mutability | Reboot | Purpose |
|-----|------|------------|--------|---------|
| `AuthorizationKey` | string | WO | Yes | Basic Auth password for the station, hex-encoded (16-20 byte password, at most 40 hex characters). Set by the CSMS when you change or rotate the password. |
| `CertificateSignedMaxChainSize` | integer | R | - | Max bytes of a signed certificate chain |
| `CertificateStoreMaxLength` | integer | R | - | Max number of installed certificates |
| `CpoName` | string | RW | No | CPO name embedded in CSRs |
| `SecurityProfile` | integer | RW | Yes | 0 (none), 1 (basic auth), 2 (basic auth + TLS), 3 (mutual TLS). Can only be increased. The CSMS sets it and resets the station when you upgrade the profile. |
| `AdditionalRootCertificateCheck` | boolean | R | - | Whether the station validates server cert against an additional root |

## Notes on Mutability

- **R** (ReadOnly): Read with `GetConfiguration`, can't be written.
- **RW** (ReadWrite): Read and write.
- **WO** (WriteOnly): Write with `ChangeConfiguration`. Reads return the key in `unknownKey` to avoid leaking secrets like `AuthorizationKey`.

## Reboot Required

Many keys take effect immediately. A few - notably `SecurityProfile`, `AuthorizationKey`, certificate store changes, and most timing parameters on some vendors - require a station reboot. The station signals this by returning `RebootRequired` from `ChangeConfiguration`. The new value is staged and applied on the next boot.

## Vendor Keys

OCPP 1.6 lets vendors add custom keys. Common patterns:

- `WebSocketPingInterval` is standard, but `WebSocketKeepAliveInterval` (vendor-specific) appears on some stations.
- Free-vending stations expose vendor keys like `FreeCharging`, `FreeVendEnabled`, or `FreeModeActive` because OCPP 1.6 has no standard way to disable authorization.
- Display brightness, badge reader timing, and language selection are almost always vendor keys.

EVtivity treats vendor keys the same as standard keys - you list them in a template and push. The CSMS doesn't validate the key name against a whitelist, so a typo will surface as a `Rejected` from the station rather than a CSMS error.

## See Also

- [Station Configurations overview](https://www.evtivity.com/docs/csms/station-configurations)
- [OCPP 2.1 Components &amp; Variables](https://www.evtivity.com/docs/csms/station-configurations-ocpp21)
