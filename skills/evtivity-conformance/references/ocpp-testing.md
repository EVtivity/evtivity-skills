Generated from https://www.evtivity.com/docs/guides/ocpp-testing (website commit 0f3462e). Do not edit.

# OCPP Testing

Run conformance tests, send OCPP commands, and verify station configurations from the CSMS.

## Overview

EVtivity includes tools for testing OCPP communication with charging stations. The Conformance Testing page runs automated test suites against the CSMS. The Station Detail page provides direct OCPP command controls and configuration viewing for manual testing.

## Conformance Testing

The conformance test runner executes OCPP test scenarios against the CSMS server. The runner acts as a simulated charging station, sends OCPP messages, and validates that the CSMS responds correctly according to the OCPP specification.

### Running a Test

1. Navigate to **Settings** in the sidebar and open the **Conformance** tab.
2. Select the OCPP version from the dropdown: **Run All Tests**, **OCPP 2.1**, or **OCPP 1.6**.
3. Click **Run Tests**.

![Conformance testing page](https://www.evtivity.com/screenshots/csms/conformance.png)

The test runner connects to the CSMS WebSocket server, provisions test stations, and executes each test case. Progress updates appear in real time via SSE.

### Test Modules

Tests are organized by OCPP functional module:

| Module | Coverage |
|---|---|
| B - Provisioning | BootNotification, Heartbeat, StatusNotification |
| C - Authorization | Authorize, local auth list, token validation |
| D - Transaction | TransactionEvent (Started, Updated, Ended) |
| E - Transactions | Remote start/stop, meter values, cost updates |
| F - Remote Control | Reset, UnlockConnector, TriggerMessage |
| G - Availability | ChangeAvailability, StatusNotification transitions |
| H - Reservation | ReserveNow, CancelReservation |
| I - Tariff and Cost | SetChargingProfile, CostUpdated |
| J - Meter Values | MeterValues reporting and clock-aligned sampling |
| K - Smart Charging | SetChargingProfile, GetCompositeSchedule |
| M - Firmware | FirmwareStatusNotification, UpdateFirmware |
| N - Diagnostics | GetLog, LogStatusNotification |
| O - Display Message | SetDisplayMessage, GetDisplayMessages |
| P - Data Transfer | DataTransfer request/response |

### Test Results

Each test run records:

- **Pass/Fail/Skip/Error counts** with pass rate percentage
- **Per-module breakdown** showing which functional areas passed or failed
- **Per-test detail** with step-by-step execution log
- **Duration** for the entire run and individual tests

Click any test run row to view the detailed results.

### Result Statuses

| Status | Meaning |
|---|---|
| Passed | All test steps validated successfully |
| Failed | One or more validation checks did not match the expected response |
| Skipped | Test prerequisites not met (missing capability or configuration) |
| Error | Test could not complete due to a timeout or connection issue |

### Quick Failures vs. Timeouts

- **Quick failure** (under 1 second): Usually a validation issue. The CSMS returned a wrong field value or status.
- **10-second error**: The test waited for a message that never arrived. Missing handler, wrong message flow, or a drain pattern consumed the needed message.
- **30+ second error**: Timeout on a feature that requires timer behavior, power cycle simulation, or offline queue processing.

## OCPP Commands

The Station Detail page includes an **OCPP Commands** tab for sending commands directly to a connected station.

![OCPP Commands tab](https://www.evtivity.com/screenshots/csms/station-commands.png)

### Available Commands

Commands vary by OCPP version. Common commands available for both 1.6 and 2.1:

| Command | Purpose |
|---|---|
| Reset | Restart the station (Immediate or OnIdle) |
| UnlockConnector | Remotely unlock a connector |
| TriggerMessage | Request the station to send a specific message (StatusNotification, MeterValues, etc.) |
| GetConfiguration / GetVariables | Read the station's current configuration |
| ChangeConfiguration / SetVariables | Update a station configuration variable |
| RemoteStartTransaction / RequestStartTransaction | Start a charging session remotely |
| RemoteStopTransaction / RequestStopTransaction | Stop an active charging session |
| ClearCache | Clear the station's authorization cache |
| ChangeAvailability | Set a connector or station to available or unavailable |

### OCPP 2.1 Additional Commands

| Command | Purpose |
|---|---|
| GetBaseReport | Request a full configuration report from the station |
| SetChargingProfile | Push a charging power limit profile |
| GetChargingProfiles | Query active charging profiles on the station |
| ClearChargingProfile | Remove charging profiles |
| GetCompositeSchedule | Get the merged charging schedule |
| SendLocalList | Push the local authorization list |
| InstallCertificate | Install a CA certificate |
| GetInstalledCertificateIds | Query installed certificates |
| SetDisplayMessage | Push a message to the station display |
| GetDisplayMessages | Query current display messages |
| UpdateFirmware | Initiate a firmware update |

### Sending a Command

1. Open a station detail page.
2. Go to the **OCPP Commands** tab.
3. Select a command from the dropdown.
4. Fill in the required parameters (connector ID, transaction ID, etc.).
5. Click **Send**.

The station must be online to receive commands. The send button is disabled when the station is offline.

The command response appears below the form showing the station's response status and any returned data.

## Station Configurations

The **Configurations** tab on the Station Detail page shows the station's current OCPP configuration variables.

### Viewing Configurations

1. Open a station detail page.
2. Go to the **Configurations** tab.
3. The table shows all configuration keys, values, and read-only status.

### Refreshing Configurations

Click **Refresh from Station** to pull the latest configuration from the station:

- OCPP 1.6: sends `GetConfiguration`
- OCPP 2.1: sends `GetBaseReport`

The station responds with its current configuration, which is stored in the CSMS database for display.

### Pushing Configuration Templates

Configuration templates let you push a set of configuration variables to multiple stations at once.

1. Navigate to **Settings** in the sidebar and open the **Station Configurations** tab.
2. Click **Create** and add the variables you want to set to the template.
3. Define a target filter (site, vendor, model) to select which stations receive the push.
4. Click **Push Config** to send the configuration to matching stations.

Each station receives a `SetVariables` (2.1) or `ChangeConfiguration` (1.6) command for each variable in the template.

## Testing Workflow

A recommended workflow for verifying station compliance:

1. **Run conformance tests** to check baseline OCPP compliance.
2. **Review failures** by module. Fix handler or configuration issues.
3. **Send individual commands** from the OCPP Commands tab to test specific behaviors.
4. **Check configurations** to verify the station accepted configuration changes.
5. **Re-run affected test modules** after fixing issues to confirm the fix.

## Notes

- Conformance tests provision temporary test stations in the database. These are cleaned up after each run.
- Commands sent to offline stations are queued and delivered when the station reconnects (OCPP 2.1 offline queue).
- The CSMS supports both OCPP 1.6 and 2.1. Command names and payloads differ between versions, but the CSMS handles translation automatically.
- Station configurations are read-only in the CSMS. To change a value, use a configuration template push or the SetVariables command.
