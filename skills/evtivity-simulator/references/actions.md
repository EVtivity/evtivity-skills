Generated from https://www.evtivity.com/docs/simulator/actions (website commit 900fb20). Do not edit.

# Simulator Actions

Trigger physical actions on simulated stations including plug in, authorize, start and stop charging, inject faults, and power cycle.

## Overview

Simulator actions simulate physical events that would normally happen at a real charging station. You trigger them through the CSMS API, and the simulator translates them into the appropriate OCPP messages.

## Triggering an Action

Send a POST request to the action endpoint with `stationId` in the body:

```bash
POST /v1/css/actions/:action
Content-Type: application/json

{ "stationId": "CS-001", "evseId": 1, ...action-specific fields }
```

The API publishes the command to Redis. The SimulatorManager dispatches it to the target StationSimulator and publishes the result back on `css_command_results`. The route waits up to 5 seconds for that result before returning, so the dashboard shows simulator-side errors (e.g. "no active transaction on this EVSE") inline rather than fire-and-forget.

## Available Actions

The dashboard's Simulate tab exposes nine state-mutating actions. For each one below, the table shows the OCPP messages sent and the resulting `connectors.status` for both protocol versions. OCPP 1.6 derives connector status directly from `StatusNotification`. OCPP 2.1 reports five coarse `StatusNotification` values (Available, Occupied, Reserved, Unavailable, Faulted) and refines them via `chargingState` on `TransactionEvent` (Charging, EVConnected, SuspendedEV, SuspendedEVSE, Idle, Discharging), which the CSMS writes back into the same connector status field. See [Connector Status Model](https://www.evtivity.com/docs/guides/station-management#connector-status-model).

#### Plug In

Simulates a driver plugging the EV cable into the connector.

- **Action**: `plugIn`
- **Body**: `{ "stationId": "CS-001", "evseId": 1 }`

| OCPP | Messages emitted | Connector status |
|---|---|---|
| 1.6 | StatusNotification(Preparing) | `preparing` |
| 2.1 | StatusNotification(Occupied) | `occupied` |

If the connector was already in state Authorized (e.g. authorize ran first, or RemoteStart accepted before plug-in), this step auto-starts the transaction.

#### Unplug

Simulates removing the EV cable from the connector. Behavior depends on whether a transaction is active and the `StopTransactionOnEVSideDisconnect` (1.6) / `TxCtrlr.StopTxOnEVSideDisconnect` (2.1) configuration variable.

- **Action**: `unplug`
- **Body**: `{ "stationId": "CS-001", "evseId": 1 }`

| OCPP | Scenario | Messages emitted | Connector status |
|---|---|---|---|
| 1.6 | No active tx | StatusNotification(Available) | `available` |
| 1.6 | Tx active, StopTxOnEVSideDisconnect=true (default) | StopTransaction(EVDisconnected) + StatusNotification(Available) | `available` |
| 1.6 | Tx active, StopTxOnEVSideDisconnect=false | StatusNotification(SuspendedEV) (tx stays active) | `suspended_ev` |
| 2.1 | No active tx | StatusNotification(Available) | `available` |
| 2.1 | Tx active, StopTxOnEVSideDisconnect=true (default) | TransactionEvent(Ended) + StatusNotification(Available) | `available` |
| 2.1 | Tx active, StopTxOnEVSideDisconnect=false | TransactionEvent(Updated, chargingState=Idle) + StatusNotification(Available); EVConnectionTimeout timer armed | `available` |

#### Authorize

Simulates a driver tapping an RFID card or presenting an authorization token.

- **Action**: `authorize`
- **Body**: `{ "stationId": "CS-001", "evseId": 1, "idToken": "DRIVER-TOKEN-001" }`

| OCPP | Cable plugged | Messages emitted | Connector status |
|---|---|---|---|
| 1.6 | yes | Authorize.req; auto-starts transaction via the start path | `charging` (after StartTransaction) |
| 1.6 | no | Authorize.req + StatusNotification(Preparing); ConnectionTimeOut timer armed | `preparing` |
| 2.1 | yes | Authorize.req; auto-starts transaction via the start path | `charging` (after first meter tick) |
| 2.1 | no | Authorize.req only; EVConnectionTimeOut timer armed | (unchanged) |

If cable plug-in arrives within the timeout, the simulator auto-starts the transaction. If the timeout expires first, 1.6 reverts to Available and 2.1 emits TransactionEvent(Started) + TransactionEvent(Ended, triggerReason=EVConnectTimeout).

#### Start Charging

Combined authorize + transaction start.

- **Action**: `startCharging`
- **Body**: `{ "stationId": "CS-001", "evseId": 1, "idToken": "DRIVER-TOKEN-001" }`

| OCPP | Messages emitted | Connector status |
|---|---|---|
| 1.6 | Authorize.req + StatusNotification(Charging) + StartTransaction | `charging` |
| 2.1 | Authorize.req + TransactionEvent(Started, chargingState=EVConnected) → `ev_connected`, then TransactionEvent(Updated, chargingState=Charging) on the first meter tick | `charging` |

The API endpoint pre-checks `connectors.status` and returns 400 `CONNECTOR_NOT_AVAILABLE` unless the connector is in `preparing`, `occupied`, `ev_connected`, or `finishing`. Meter values begin flowing at the configured interval (`MeterValueSampleInterval` for 1.6, `SampledDataCtrlr.TxUpdatedMeasurands` for 2.1).

#### Stop Charging

Ends the active charging session.

- **Action**: `stopCharging`
- **Body**: `{ "stationId": "CS-001", "evseId": 1, "reason": "Local" }`

| OCPP | Messages emitted | Connector status |
|---|---|---|
| 1.6 | StopTransaction + StatusNotification(Finishing) | `finishing` (cable still connected; cleared by Unplug) |
| 2.1 | TransactionEvent(Ended, chargingState=EVConnected) + StatusNotification(Occupied) | `occupied` (cable still connected; cleared by Unplug) |

#### Inject Fault

Simulates a hardware fault on the connector.

- **Action**: `injectFault`
- **Body**: `{ "stationId": "CS-001", "evseId": 1, "errorCode": "InternalError" }`

| OCPP | Messages emitted | Connector status |
|---|---|---|
| 1.6 | (Active tx is stopped first with reason=Other) + StatusNotification(Faulted, errorCode) | `faulted` |
| 2.1 | (Active tx is stopped first) + StatusNotification(Faulted) | `faulted` |

No-op if the connector is already in `faulted`.

#### Clear Fault

Clears a previously injected fault.

- **Action**: `clearFault`
- **Body**: `{ "stationId": "CS-001", "evseId": 1 }`

| OCPP | Messages emitted | Connector status |
|---|---|---|
| 1.6 | StatusNotification(Available) | `available` |
| 2.1 | StatusNotification(Available) | `available` |

No-op if the connector is not currently in `faulted` (avoids forcing a healthy connector back to Available).

#### Go Offline

Simulates the station losing its OCPP connection.

- **Action**: `goOffline`
- **Body**: `{ "stationId": "CS-001" }`

| OCPP | Behavior |
|---|---|
| 1.6, 2.1 | WebSocket closed. Station marked offline by the CSMS heartbeat watchdog. Connector statuses stay at their last reported values. |

Useful for testing offline message queueing, reconnection logic, and CSMS-side stale-session cleanup.

#### Come Online

Brings an offline station back online.

- **Action**: `comeOnline`
- **Body**: `{ "stationId": "CS-001" }`

| OCPP | Messages emitted | Connector status |
|---|---|---|
| 1.6 | BootNotification + `StatusNotification(<last reported>)`; offline-queued StartTransaction / StopTransaction / MeterValues replayed | restored to last reported value |
| 2.1 | BootNotification + `StatusNotification(<last reported>)` | restored to last reported value |

#### Reboot Station

Re-issues BootNotification and re-reports connector status. Lighter than `Reset` (does not stop active transactions or pass through Unavailable).

- **Action**: `rebootStation`
- **Trigger**: no `/v1/css/actions` route. The CSMS sends it to the simulator when an operator approves a pending simulated station.

| OCPP | Messages emitted | Connector status |
|---|---|---|
| 1.6, 2.1 | BootNotification(reason=RemoteReset); on Accepted, StatusNotification(Available) for every non-charging connector | `available` for non-charging connectors; charging connectors are left untouched |

### OCPP 2.1 specifics

- `TransactionEvent` carries `chargingState` (Charging, EVConnected, SuspendedEV, SuspendedEVSE, Idle, Discharging). The CSMS enriches `connectors.status` from this field.
- `GetBaseReport` returns the full set of OCPP 2.1 configuration variables.
- `SignCertificate` triggers CSR generation for certificate renewal.

### OCPP 1.6 specifics

- `StartTransaction` and `StopTransaction` use the 1.6 message format with `connectorId` (the simulator passes its `evseId` as `connectorId`).
- `StatusNotification` reports 9 granular statuses directly: Available, Preparing, Charging, SuspendedEV, SuspendedEVSE, Finishing, Reserved, Unavailable, Faulted.
- `ChangeConfiguration` and `GetConfiguration` use key/value pairs instead of the 2.1 variable model.

## Meter Value Generation

During an active transaction, the simulator generates realistic meter values at the configured interval. Supported measurands:

| Measurand | Unit | Description |
|-----------|------|-------------|
| Energy.Active.Import.Register | Wh | Cumulative energy consumed |
| Energy.Active.Export.Register | Wh | Cumulative energy exported (V2G) |
| Power.Active.Import | W | Current power draw |
| Power.Active.Export | W | Current power export |
| Power.Reactive.Import | var | Reactive power import |
| Current.Import | A | Current draw |
| Current.Export | A | Current export |
| Voltage | V | Line voltage |
| SoC | % | State of charge |
| Temperature | Celsius | Connector temperature |
| Frequency | Hz | Grid frequency |
| Power.Offered | W | Maximum available power |

Measurands and reporting intervals are configurable via OCPP SetVariables (2.1) or ChangeConfiguration (1.6).

## CSMS Command Responses

The simulator responds to all 51 CSMS-initiated commands. When the CSMS sends a command (via the command dispatcher), the simulator processes it and returns the appropriate response. Examples:

- **RemoteStartTransaction / RequestStartTransaction** - Starts a transaction on the specified EVSE
- **RemoteStopTransaction / RequestStopTransaction** - Stops the active transaction
- **Reset** - Simulates a station reboot
- **ChangeAvailability** - Changes connector availability
- **SetChargingProfile** - Stores the profile and applies power limits
- **SendLocalList** - Updates the local authorization list
- **TriggerMessage** - Sends the requested message immediately
- **GetDiagnostics / GetLog** - Returns a simulated upload URL
- **UnlockConnector** - Resets the connector state

## Notes

- Action routes wait up to 5 seconds for the simulator's result on `css_command_results`. They answer 200 with the `commandId` when the action ran, 400 `CSS_ACTION_REJECTED` when the simulator refused it, and 504 `CSS_ACTION_TIMEOUT` when no result came in time.
- The SimulatorManager routes each command to the correct StationSimulator by station ID.
- In chaos mode, the ChaosOrchestrator triggers actions randomly without manual API calls.
- Clock-aligned meter values use a global scheduler with jitter to prevent all stations from reporting at the same millisecond.
