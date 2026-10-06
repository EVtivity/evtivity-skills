---
name: evtivity-conformance
description: "Test OCPP on EVtivity: send OCPP 1.6 or 2.1 commands such as TriggerMessage, Reset or RequestStartTransaction and read the result, message and security logs, OCTT conformance tests and published results, 1.6 vs 2.1 differences. Not for simulated stations (evtivity-simulator) or a station that cannot connect (evtivity-troubleshoot)."
license: MIT
compatibility: API examples use curl and jq against a running EVtivity API (default http://localhost:7102 with Docker Compose). Command-line conformance runs need a CSMS source checkout with Node.js.
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39"
  evtivity-commit: "85333dc7da57a2e0b9d74d1d09d448dee313a29b"
  evtivity-docs-section: conformance
---

# EVtivity OCPP and conformance testing

Not for: creating simulated stations or driving test sessions (use evtivity-simulator), a station that cannot connect (use evtivity-troubleshoot), API keys and the route catalog (use evtivity-api).

EVtivity speaks OCPP 1.6 and OCPP 2.1 on one WebSocket server. You test it two ways:

- Manual: send single OCPP commands to a station and read the answer and the message log.
- Automated: run the built-in OCTT conformance runner, which follows the Open Charge Alliance OCTT test cases. Its results are not an OCA certification.

The OCTT result references are large (hundreds of test cases). Grep them for a test case or module instead of reading them whole, for example `grep -n 'TC_E_04' references/csms-ocpp21.md` or `grep -n -i 'not applicable' references/charging-station-ocpp21.md`.

## 0. Before you start

```bash
export EVTIVITY_API=http://localhost:7102
export EVTIVITY_TOKEN=<64-hex API key>        # see evtivity-api
H=(-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json')
```

Permissions: `stations:write` for OCPP commands, `stations:read` for logs, `conformance:read` and `conformance:write` for test runs.

Command routes take the OCPP identity (`stationId`, for example `CS-001`). Log and detail routes take the internal ID (`sta_...`).

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations?search=CS-001" \
  | jq '.data[] | {id, stationId, ocppProtocol, isOnline, onboardingStatus, securityProfile}'
```

Use `v21` routes for `ocppProtocol: "ocpp2.1"` and `v16` routes for `"ocpp1.6"`. The wrong one answers 400 `OCPP_VERSION_MISMATCH`.

### Safety rules

- Ask the user before any command that disrupts a live station: `Reset`, `ChangeAvailability` to `Inoperative`, `UpdateFirmware` or `SignedUpdateFirmware`, `SetNetworkProfile`, `ClearChargingProfile`, `ClearCache`, `DeleteCertificate`, `RequestStopTransaction` or `RemoteStopTransaction` on a real driver's session, and `SendLocalList` with `updateType: "Full"`.
- A command to an offline station is queued, not dropped. It runs when the station reconnects, within the offline queue TTL (setting, default 24 hours). A queued Reset still resets the station later. Tell the user.
- Run conformance tests only against a development or test deployment. The runner writes test stations, tokens, a test driver, a temporary API key and settings while it runs (`references/overview.md`).

## 1. Send an OCPP command and read the result (`references/ocpp-testing.md`)

Dashboard: station detail, **OCPP Commands** tab. Quick actions cover the common commands. The advanced section lists every command with a form built from the JSON schema, or a raw JSON payload. A yellow **Queued** badge means the station was offline.

API: `POST /v1/ocpp/commands/{v21|v16}/{Action}` with the OCPP request payload plus `stationId`. Payload schema: `GET /v1/ocpp/commands/v21/{action}/schema` (or `v16`).

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v21/TriggerMessage" \
  -d '{"stationId":"CS-001","requestedMessage":"StatusNotification","evse":{"id":1}}'
curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v16/TriggerMessage" \
  -d '{"stationId":"CS-016","requestedMessage":"StatusNotification","connectorId":1}'
```

The API waits up to 35 seconds. Read the result in this order:

| HTTP | Body | Meaning | Next step |
|---|---|---|---|
| 200 | `{status: "accepted", response}` | The station sent a CALLRESULT. `status: "accepted"` only means it answered. | Read `response.status` (`Accepted`, `Rejected`, `NotSupported`, `RebootRequired`, ...). |
| 202 | `{status: "queued", code: "COMMAND_QUEUED"}` | Station not connected. Command stored in the offline queue. | Bring the station online, then check the message log. |
| 400 | `{code: "INVALID_PAYLOAD", validationErrors}` | Payload failed the OCPP schema. | Fix the fields in `validationErrors`. |
| 400 | `{code: "OCPP_VERSION_MISMATCH"}` | `v21` route for a 1.6 station or the reverse. | Switch the route. |
| 400 | `{code: "UNKNOWN_ACTION"}` | Action name not in that version's registry. | Check spelling and version. |
| 404 | `{code: "STATION_NOT_FOUND"}` | Unknown OCPP identity, or outside the user's site access. | Check `stationId` and the key's site access. |
| 502 | `{status: "error", code: "COMMAND_ERROR", error}` | A CALLERROR from the station (for example `NotImplemented`), no answer within 30 seconds, a closed connection, a response that failed validation, or a command not supported on the station's version. | Read `error`, then the message log. |
| 504 | `{status: "timeout", code: "COMMAND_TIMEOUT"}` | No result reached the API within 35 seconds. | The OCPP server or Redis may be down: evtivity-troubleshoot. |

Every dispatch is audited on the station **History** tab (`command_dispatched` with its outcome).

Asynchronous commands answer `Accepted` first and send the data later:

| Command | Follow-up messages |
|---|---|
| GetBaseReport, GetReport (2.1) | NotifyReport, shown on the Configurations tab |
| GetChargingProfiles (2.1) | ReportChargingProfiles |
| GetDisplayMessages (2.1) | NotifyDisplayMessages |
| GetMonitoringReport (2.1) | NotifyMonitoringReport |
| UpdateFirmware | FirmwareStatusNotification, shown on Firmware History |
| GetLog, GetDiagnostics | LogStatusNotification (2.1), DiagnosticsStatusNotification (1.6) |
| TriggerMessage | The requested message |

## 2. Read the message log and security log

```bash
STA=sta_abc123def456
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/$STA/ocpp-logs?limit=50&action=StatusNotification&direction=inbound" \
  | jq '.data[] | {createdAt, direction, messageType, action, messageId, payload, errorCode, errorDescription}'
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/$STA/security-logs?limit=50" \
  | jq '.data[] | {createdAt, source, event, severity, remoteAddress, metadata}'
```

- `messageType`: 2 CALL, 3 CALLRESULT, 4 CALLERROR. Match request and response by `messageId`. `direction`: `inbound` (station to CSMS) or `outbound`.
- Security log `source: connection`: CSMS-side events `auth_failed`, `password_changed`, `credentials_rotated`, `connected`, `disconnected`. `source: security`: OCPP `SecurityEventNotification` types from the station, with `severity` (also `GET /v1/stations/{id}/security-events?severity=critical`).
- A critical security event disables the station when `security.autoDisableOnCritical` is on (default). **Enable Station** restores it.
- Other evidence: `GET /v1/stations/{id}/events` (OCPP 2.1 NotifyEvent), `GET /v1/sessions/{id}/transaction-events`, the **Authorize Log** tab.

## 3. Run the OCTT conformance runner (`references/overview.md`, `references/conformance-testing.md`)

- Check the CSMS quickly, no source checkout: dashboard or API (CSMS suites only).
- TLS reconnect steps, one module, selected tests, or the charging station suites: command line from a CSMS checkout.

Dashboard: **Settings**, **Conformance** tab. Choose **OCPP 2.1**, **OCPP 1.6** or **Run All Tests**, click **Run Tests**. Click a run for the per-module breakdown and each step's expected and actual result.

```bash
RUN=$(curl -s "${H[@]}" "$EVTIVITY_API/v1/octt/runs" -d '{"ocppVersion":"ocpp2.1","sutType":"csms"}' | jq -r .id)
curl -s "${H[@]}" "$EVTIVITY_API/v1/octt/runs?limit=5" | jq '.data[] | {id, status, totalTests, passed, failed, skipped, errors, notApplicable}'
curl -s "${H[@]}" "$EVTIVITY_API/v1/octt/runs/$RUN/summary"
curl -s "${H[@]}" "$EVTIVITY_API/v1/octt/runs/$RUN?status=failed" | jq '.results[] | {testId, module, error, steps}'
```

- `ocppVersion`: `ocpp2.1`, `ocpp1.6` or `all`. Run `status`: `pending`, `running`, `completed`, `failed`. Test `status` filter: `passed`, `failed`, `skipped`, `error`, `notApplicable`.
- The worker runs the job. If runs stay `pending`, check the worker.
- Dashboard and API runs have no TLS server URL, so TLS reconnect steps report skipped. The OCSP tests run when the worker has `OCTT_OCSP_RESPONDER_URL`, else they are skipped.

Command line (from the CSMS repository root, OCPP server, API and database running):

```bash
npm run octt:2.1                     # CSMS suite, OCPP 2.1
npm run octt:1.6                     # CSMS suite, OCPP 1.6
npx tsx packages/octt/src/cli.ts --server ws://localhost:7103 --version ocpp2.1 --module E-transactions
npx tsc -b packages/css && npm run octt:cs:2.1   # charging station suite against the simulator
```

| Status | Meaning | What to check |
|---|---|---|
| Passed | Every step got the expected result | Nothing |
| Failed | A step got another result | Expected vs actual. Under 1 second usually means a wrong field value or status |
| Error | Could not finish (connection, timeout) | About 10 seconds: a message never arrived. 30 seconds or more: timer, power cycle or offline queue behavior |
| Skipped | Applies but could not run here | Missing TLS server URL or OCSP responder |
| Not applicable | Excluded by PICS or a missing feature | Not run, not counted as passed |

Compare a run with the published results of the release: the totals, the per-module tables and every test case are in `references/csms-ocpp21.md`, `references/csms-ocpp16.md`, `references/charging-station-ocpp21.md` and `references/charging-station-ocpp16.md`, with the run date. A charging station test reported not applicable is expected when the simulator's PICS excludes it: the charging station references give the PICS item and reason for each. After a fix, re-run the affected module, then the full suite.

## 4. Connect a real station for testing

1. Create the station first. An unknown station gets HTTP 404 at the WebSocket upgrade. `POST /v1/stations` with `stationId`, `ocppProtocol` (`ocpp1.6` or `ocpp2.1`) and `securityProfile` (0 none, 1 Basic Auth, 2 TLS + Basic Auth, 3 mutual TLS).
2. Password for profile 1 or 2: Security tab, **Change Password**, or `POST /v1/stations/{id}/credentials` with `{"password": "..."}`. 16 to 40 characters for 2.1, 16 to 20 for 1.6. `appliedTo` says `station` (sent and accepted) or `stored`.
3. Point the station at `ws://<host>:7103/<stationId>` (profile 0 or 1) or `wss://<host>:8443/<stationId>` (profile 2 or 3). The path equals the station ID exactly. The Basic Auth username is the station ID.
4. Approve it (`POST /v1/stations/{id}/approve`) under the default `approval-required` policy. A pending station can connect and take configuration commands, but remote start is refused.
5. Verify: Online, inbound `BootNotification`, `Heartbeat` and `StatusNotification` in the log, and a TriggerMessage round trip (section 1).
6. Read its configuration: `POST /v1/stations/{id}/configurations/refresh` (400 when the station is offline).

Onboarding in full: evtivity-guides. If it does not connect: evtivity-troubleshoot.

Test the session flow next (confirm with the user on a real station):

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v21/RequestStartTransaction" \
  -d '{"stationId":"CS-001","evseId":1,"remoteStartId":1001,"idToken":{"idToken":"RFID-0001","type":"ISO14443"}}'
curl -s "${H[@]}" "$EVTIVITY_API/v1/sessions?status=active&limit=100" | jq '.data[] | {id, stationName, transactionId}'
```

Watch the log for `TransactionEvent` (2.1) or `StartTransaction` and `MeterValues` (1.6). Stop with `RequestStopTransaction` (string `transactionId`) or `RemoteStopTransaction` (integer `transactionId`).

## 5. OCPP 1.6 vs 2.1

| Topic | OCPP 1.6 | OCPP 2.1 |
|---|---|---|
| Remote start | `RemoteStartTransaction` with `idTag`, optional `connectorId` | `RequestStartTransaction` with `idToken` object and `remoteStartId`, optional `evseId` |
| Remote stop | `RemoteStopTransaction`, integer `transactionId` | `RequestStopTransaction`, string `transactionId` |
| Transaction id | The CSMS assigns an integer in the StartTransaction response | The station creates it in `TransactionEvent` `Started` |
| Transaction messages | `StartTransaction`, `MeterValues`, `StopTransaction` | `TransactionEvent` `Started`, `Updated`, `Ended` |
| Connector status | `StatusNotification` with 9 values (`Available`, `Preparing`, `Charging`, `SuspendedEV`, `SuspendedEVSE`, `Finishing`, `Reserved`, `Unavailable`, `Faulted`) | 5 values (`Available`, `Occupied`, `Reserved`, `Unavailable`, `Faulted`). Activity is `chargingState` on `TransactionEvent` |
| After a stop, cable still in | `Finishing` | `Occupied` with `chargingState` `EVConnected` |
| Refresh connector status | `TriggerMessage` `StatusNotification` | `TriggerMessage` `TransactionEvent` during a session, `StatusNotification` otherwise |
| EVSE model | No EVSEs. Connector N is stored as EVSE N | EVSEs with one or more connectors |
| Read configuration | `GetConfiguration` returns all keys | `GetVariables`, or `GetBaseReport` with data later in `NotifyReport` |
| Write configuration | `ChangeConfiguration`, one key per call | `SetVariables`, many items, per-item status |
| Reset | `Hard` or `Soft` | `Immediate`, `OnIdle` or `ImmediateAndResume`, optional `evseId` |
| Basic Auth password | `ChangeConfiguration` `AuthorizationKey` (hex), 16 to 20 characters | `SetVariables` `SecurityCtrlr.BasicAuthPassword`, 16 to 40 characters |
| Security profile upgrade | `ChangeConfiguration` `SecurityProfile`, then Reset | `SetNetworkProfile`, `NetworkConfigurationPriority`, then Reset OnIdle |

The `/v1/ocpp/commands/{version}/...` routes send the payload as written. They do not translate between versions.

## 6. When a result looks wrong

1. Re-read the raw exchange in the message log. Compare it with the schema (`GET /v1/ocpp/schemas/{action}`).
2. Check the station state: online, onboarding status, availability, protocol.
3. For conformance failures, open the failed test's steps and compare expected and actual.
4. If EVtivity is at fault, collect the request, the response, the log rows and `GET /v1/version`, then use evtivity-report-issue.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer.

- `references/overview.md`: how the runner works, suites, statuses, PICS and not applicable rules, command-line flags.
- `references/conformance-testing.md`: the dashboard Conformance tab and results page.
- `references/ocpp-testing.md`: manual testing with the OCPP Commands and Configurations tabs.
- `references/csms-ocpp21.md`, `references/csms-ocpp16.md`: published CSMS results per module and test case (grep them).
- `references/charging-station-ocpp21.md`, `references/charging-station-ocpp16.md`: published simulator results, PICS and not applicable cases (grep them).
