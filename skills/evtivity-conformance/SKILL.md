---
name: evtivity-conformance
description: Test OCPP behavior on the EVtivity CSMS. Covers sending OCPP 1.6 and 2.1 commands to a station from the API (/v1/ocpp/commands/v21 and v16) or the station OCPP Commands tab and reading the result (200, 202 queued, 400, 404, 502, 504), the OCPP message log and security event log, the built-in OCTT conformance runner (dashboard, API and command line, run statuses), the published OCTT results per suite and version (CSMS 2.1 and 1.6, charging station 2.1 and 1.6, PICS, not applicable cases), connecting a real station for testing (URL, security profile, Basic Auth, TLS, approval), and OCPP 1.6 vs 2.1 differences (transaction ids, StatusNotification vs TransactionEvent chargingState, RemoteStart vs RequestStartTransaction, configuration keys vs variables, TriggerMessage choices). Use when someone tests a charger or the CSMS against OCPP, sends a raw OCPP command, reads OCPP logs, runs or reads conformance tests, or asks which OCTT tests pass.
license: MIT
compatibility: API examples use curl and jq against a running EVtivity API (default http://localhost:7102 with Docker Compose). Command-line conformance runs need a CSMS source checkout with Node.js.
metadata:
  evtivity-version: "0.1.39"
  evtivity-docs-section: conformance
---

# EVtivity OCPP and conformance testing

EVtivity speaks OCPP 1.6 and OCPP 2.1 on one WebSocket server. You test it two ways:

- Manual: send single OCPP commands to a station and read the station's answer and message log.
- Automated: run the built-in OCTT conformance runner, which follows the Open Charge Alliance OCTT test cases. Its results are not an OCA certification.

Related skills: `evtivity-api` (API keys, error format, route catalog), `evtivity-simulator` (simulated stations), `evtivity-guides` (station onboarding), `evtivity-csms` (station detail tabs), `evtivity-configuration` (OCPP settings, security profiles), `evtivity-troubleshoot` (station cannot connect decision tree), `evtivity-getting-started` (local stack), `evtivity-deployment`, `evtivity-report-issue` (file a bug with evidence).

## Docs pages and when to use them

The website docs are the source of truth. Fetch the page when you need its full detail.

| Page id | Use it for |
|---|---|
| `guides/ocpp-testing` https://www.evtivity.com/docs/guides/ocpp-testing | Manual testing: OCPP Commands tab, Configurations tab, configuration templates, the suggested testing workflow |
| `csms/conformance-testing` https://www.evtivity.com/docs/csms/conformance-testing | The dashboard Conformance tab: starting a run, the results page, run metadata, test statuses |
| `conformance/overview` https://www.evtivity.com/docs/conformance/overview | How the runner works, the four suites, result statuses, PICS and not applicable rules, test isolation, command-line runs and flags |
| `conformance/csms-ocpp21` https://www.evtivity.com/docs/conformance/csms-ocpp21 | Published OCPP 2.1 CSMS results by module (TC_x_nn_CSMS) and CSMS not applicable cases |
| `conformance/csms-ocpp16` https://www.evtivity.com/docs/conformance/csms-ocpp16 | Published OCPP 1.6 CSMS results by module (TC_nnn_CSMS) |
| `conformance/charging-station-ocpp21` https://www.evtivity.com/docs/conformance/charging-station-ocpp21 | Published OCPP 2.1 results for the Charging Station Simulator, its PICS and every not applicable case with the reason |
| `conformance/charging-station-ocpp16` https://www.evtivity.com/docs/conformance/charging-station-ocpp16 | Published OCPP 1.6 results for the Charging Station Simulator and its PICS rows |

Command routes per OCPP version and their permissions: the route catalog of the `evtivity-api` skill. Payload schema of one action: `GET /v1/ocpp/schemas/{action}`.

## 0. Before you start

Set the API base and an API key (see the `evtivity-api` skill to create one):

```bash
export EVTIVITY_API=http://localhost:7102
export EVTIVITY_TOKEN=<64-hex API key>
H=(-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json')
```

Permissions: `stations:write` for OCPP commands, `stations:read` for logs, `conformance:read` and `conformance:write` for test runs.

Find the station. Command routes take the OCPP identity (`stationId`, for example `CS-001`). Log and detail routes take the internal ID (`sta_...`).

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations?search=CS-001" \
  | jq '.data[] | {id, stationId, ocppProtocol, isOnline, onboardingStatus, securityProfile}'
```

Use `v21` routes for `ocppProtocol: "ocpp2.1"` and `v16` routes for `"ocpp1.6"`. The wrong one answers 400 `OCPP_VERSION_MISMATCH`.

### Safety rules

- Ask the user before any command that disrupts a live station: `Reset`, `ChangeAvailability` to `Inoperative`, `UpdateFirmware` or `SignedUpdateFirmware`, `SetNetworkProfile`, `ClearChargingProfile`, `ClearCache`, `DeleteCertificate`, `RequestStopTransaction` or `RemoteStopTransaction` on a real driver's session, and `SendLocalList` with `updateType: "Full"`. The dashboard asks for confirmation for Reset, ChangeAvailability and ClearCache.
- A command to an offline station is queued, not dropped. It runs when the station reconnects, within the offline queue TTL (setting, default 24 hours). A queued Reset still resets the station later. Tell the user.
- Run conformance tests only against a development or test deployment. The runner writes test stations, tokens, a test driver, a temporary API key and settings while it runs. Docs: https://www.evtivity.com/docs/conformance/overview

## 1. Send an OCPP command and read the result

Docs: `guides/ocpp-testing` https://www.evtivity.com/docs/guides/ocpp-testing and https://www.evtivity.com/docs/csms/stations

Dashboard: station detail, **OCPP Commands** tab. Quick actions cover the common commands. The advanced section lists every command with a form built from the JSON schema, or a raw JSON payload. The response card shows the result. A yellow **Queued** badge means the station was offline.

API: `POST /v1/ocpp/commands/{v21|v16}/{Action}` with the OCPP request payload plus `stationId`. Payload schema of one action: `GET /v1/ocpp/commands/v21/{action}/schema` (or `v16`).

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v21/TriggerMessage" \
  -d '{"stationId":"CS-001","requestedMessage":"StatusNotification","evse":{"id":1}}'

curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v16/TriggerMessage" \
  -d '{"stationId":"CS-016","requestedMessage":"StatusNotification","connectorId":1}'
```

The API waits up to 35 seconds. Read the result in this order:

| HTTP | Body | What it means | Next step |
|---|---|---|---|
| 200 | `{status: "accepted", response}` | The station sent a CALLRESULT. `status: "accepted"` only means it answered. | Read `response.status` (`Accepted`, `Rejected`, `NotSupported`, `RebootRequired`, ...). A `Rejected` answer still comes back as HTTP 200. |
| 202 | `{status: "queued", code: "COMMAND_QUEUED"}` | Station not connected. Command stored in the offline queue. | Bring the station online. The result is not returned to you later. Check the message log after reconnect. |
| 400 | `{code: "INVALID_PAYLOAD", validationErrors}` | Payload failed the OCPP schema. | Fix the fields listed in `validationErrors`. |
| 400 | `{code: "OCPP_VERSION_MISMATCH"}` | `v21` route for a 1.6 station or the reverse. | Switch the route. Right after a new station's first BootNotification this can show for a moment (v0.1.38 known issue). Retry once. |
| 400 | `{code: "UNKNOWN_ACTION"}` | Action name not in that version's registry. | Check spelling and version. |
| 404 | `{code: "STATION_NOT_FOUND"}` | Unknown OCPP identity, or outside the user's site access. | Check `stationId` and the key's site access. |
| 502 | `{status: "error", code: "COMMAND_ERROR", error}` | The OCPP server got an error, not a CALLRESULT. `error` holds the reason: `CALLERROR <code>: <description>` from the station (for example `NotImplemented`), `Timeout waiting for response to <Action>` (the station did not answer within 30 seconds), `Connection closed`, a response that failed schema validation, or a command not supported on the station's version. | Read `error`. Then read the message log. |
| 504 | `{status: "timeout", code: "COMMAND_TIMEOUT"}` | No result came back to the API within 35 seconds. | The OCPP server or Redis may be down. Use `evtivity-troubleshoot`. |

Note: the public API reference and some docs say 502 means "the station rejected the command". In the code, a station that answers with a `Rejected` status gives HTTP 200, and 502 means an error or no answer at the OCPP layer. Always read `response.status` on a 200.

Every dashboard or API dispatch is audited on the station **History** tab (`command_dispatched`, outcome `accepted`, `queued (station offline)`, `timeout` or `error: <msg>`).

Asynchronous commands answer `Accepted` first and send the data later as separate station messages. Check the message log or the matching tab for the follow-up:

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

OCPP message log (dashboard: OCPP Commands tab, below the commands). Every inbound and outbound message, raw payload included.

```bash
STA=sta_abc123def456
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/$STA/ocpp-logs?limit=50&action=StatusNotification&direction=inbound" \
  | jq '.data[] | {createdAt, direction, messageType, action, messageId, payload, errorCode, errorDescription}'
```

- `messageType`: 2 CALL, 3 CALLRESULT, 4 CALLERROR. Match request and response by `messageId`.
- `direction`: `inbound` (station to CSMS) or `outbound` (CSMS to station).
- A failed command shows as an inbound CALLERROR row with `errorDescription`.

Security event log (dashboard: **Security** tab). Two sources merged:

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/$STA/security-logs?limit=50" \
  | jq '.data[] | {createdAt, source, event, severity, remoteAddress, metadata}'
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/$STA/security-logs?event=auth_failed&source=connection"
```

- `source: connection`: CSMS-side events `auth_failed`, `password_changed`, `credentials_rotated`, `connected`, `disconnected`.
- `source: security`: OCPP `SecurityEventNotification` types from the station (for example `TamperDetectionActivated`), with `severity`. Also listed at `GET /v1/stations/{id}/security-events?severity=critical`.
- A critical security event disables the station and sends `ChangeAvailability` Inoperative when `security.autoDisableOnCritical` is on (default). Click **Enable Station** to restore. Docs: https://www.evtivity.com/docs/csms/stations

Other evidence: `GET /v1/stations/{id}/events` (OCPP 2.1 NotifyEvent), `GET /v1/sessions/{id}/transaction-events`, the **Authorize Log** tab for token outcomes.

## 3. Run the OCTT conformance runner

Docs: `conformance/overview` https://www.evtivity.com/docs/conformance/overview (runner, statuses, CLI flags) and `csms/conformance-testing` https://www.evtivity.com/docs/csms/conformance-testing (dashboard pages).

Pick the path:

- Check the CSMS quickly, no source checkout: dashboard or API (CSMS suites only).
- Need TLS reconnect steps, one module, selected tests, or the charging station suites: command line from a CSMS checkout.

Dashboard: **Settings**, **Conformance** tab. Choose **OCPP 2.1**, **OCPP 1.6** or **Run All Tests**, click **Run Tests**. The run list updates live. Click a run for the per-module breakdown and each step's expected and actual result.

API:

```bash
RUN=$(curl -s "${H[@]}" "$EVTIVITY_API/v1/octt/runs" -d '{"ocppVersion":"ocpp2.1","sutType":"csms"}' | jq -r .id)
curl -s "${H[@]}" "$EVTIVITY_API/v1/octt/runs?limit=5" | jq '.data[] | {id, status, ocppVersion, totalTests, passed, failed, skipped, errors, notApplicable}'
curl -s "${H[@]}" "$EVTIVITY_API/v1/octt/runs/$RUN/summary"
curl -s "${H[@]}" "$EVTIVITY_API/v1/octt/runs/$RUN?status=failed" | jq '.results[] | {testId, module, error, steps}'
```

- `ocppVersion`: `ocpp2.1`, `ocpp1.6` or `all`. Run `status`: `pending`, `running`, `completed`, `failed`. Poll until `completed`.
- Test `status` filter: `passed`, `failed`, `skipped`, `error`, `notApplicable`. `module` filter takes the module name.
- The worker runs the job. If runs stay `pending`, check the worker. Queued runs are lost if Redis loses its data (v0.1.38 known issue).
- Dashboard and API runs have no TLS server URL, so TLS reconnect steps report skipped. The OCSP tests (TC_C_50 to TC_C_52, TC_M_24) run when the worker has `OCTT_OCSP_RESPONDER_URL` (Docker Compose sets `http://worker:7110/ocsp`), else they are skipped.

Command line (from the CSMS repository root, OCPP server, API and database running):

```bash
npm run octt:2.1                     # CSMS suite, OCPP 2.1
npm run octt:1.6                     # CSMS suite, OCPP 1.6
npx tsx packages/octt/src/cli.ts --server ws://localhost:7103 --version ocpp2.1 --module E-transactions
npx tsc -b packages/css && npm run octt:cs:2.1   # charging station suite against the simulator
```

Read results:

| Status | Meaning | What to check |
|---|---|---|
| Passed | Every step got the expected result | Nothing |
| Failed | A step got another result | The step's expected vs actual. Under 1 second usually means a wrong field value or status |
| Error | Could not finish (connection, timeout) | About 10 seconds: a message never arrived. 30 seconds or more: timer, power cycle or offline queue behavior |
| Skipped | Applies but could not run here | Missing TLS server URL or OCSP responder |
| Not applicable | Excluded by PICS or a missing feature | Not run, not counted as passed |

Compare a run with the published results: CSMS 2.1 329/329, CSMS 1.6 77/77, charging station 2.1 467 passed and 111 not applicable, charging station 1.6 107/107 (run 2026-10-05, v0.1.38). Per module and per test case: `conformance/csms-ocpp21`, `conformance/csms-ocpp16`, `conformance/charging-station-ocpp21`, `conformance/charging-station-ocpp16` (URLs in the table above). A charging station test reported not applicable is expected when the simulator's PICS excludes it. The `conformance/charging-station-ocpp21` page gives the PICS item and reason for each. Known: TC_A_19_CSMS skips step 10 when OCPP is reachable only over wss://.

After a fix, re-run the affected module, then the full suite.

## 4. Connect a real station for testing

Docs: https://www.evtivity.com/docs/guides/station-onboarding, https://www.evtivity.com/docs/configuration/ocpp-settings, https://www.evtivity.com/docs/configuration/authentication

1. Create the station first. An unknown station gets HTTP 404 at the WebSocket upgrade. Dashboard: **Stations**, **Create Station** (the create form offers No Auth, Basic Auth and TLS + Basic Auth). API: `POST /v1/stations` with `stationId`, `ocppProtocol` (`ocpp1.6` or `ocpp2.1`) and `securityProfile` (0 none, 1 Basic Auth, 2 TLS + Basic Auth, 3 mutual TLS). A taken ID answers 409 `STATION_ID_EXISTS`.
2. Set the password for profile 1 or 2: Security tab, **Change Password**, or `POST /v1/stations/{id}/credentials` with `{"password": "..."}`. 16 to 40 characters for 2.1, 16 to 20 for 1.6, letters, digits and `* - _ = : + | @ .`. The response `appliedTo` says `station` (sent and accepted) or `stored` (configure it on the station).
3. Point the station at the CSMS:
   - Profile 0 or 1: `ws://<host>:7103/<stationId>`
   - Profile 2 or 3: `wss://<host>:8443/<stationId>`. The station must trust the CA of the server certificate. Profile 3 needs a client certificate signed by the CA the server trusts.
   - The path must equal the station ID exactly (case-sensitive). Basic Auth username is the station ID.
4. Approve it. With the default `ocpp.registrationPolicy` `approval-required`, the first BootNotification gets `Pending`. Approve on the station page or `POST /v1/stations/{id}/approve`. A pending station can connect and take configuration commands, but remote start is refused. A blocked station gets HTTP 403 at connect.
5. Verify: the station shows Online. The message log has inbound `BootNotification`, `Heartbeat` and `StatusNotification`. Send `TriggerMessage` `StatusNotification` (section 1) and confirm a new inbound StatusNotification arrives.
6. Read its configuration: Configurations tab, **Refresh from Station**, or `POST /v1/stations/{id}/configurations/refresh` (GetConfiguration on 1.6, GetBaseReport FullInventory on 2.1). It answers 400 when the station is offline.

If it does not connect, read the security log for `auth_failed` and follow the `evtivity-troubleshoot` skill. Common causes: ID mismatch, wrong password, wrong profile on either side, TLS chain, blocked station.

Test the session flow next. OCPP 2.1 needs `idToken` and `remoteStartId`, 1.6 needs `idTag`:

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v21/RequestStartTransaction" \
  -d '{"stationId":"CS-001","evseId":1,"remoteStartId":1001,"idToken":{"idToken":"RFID-0001","type":"ISO14443"}}'
curl -s "${H[@]}" "$EVTIVITY_API/v1/sessions?status=active&limit=100" | jq '.data[] | {id, stationName, transactionId}'
```

Watch the message log for `TransactionEvent` (2.1) or `StartTransaction` and `MeterValues` (1.6). Stop with `RequestStopTransaction` (string `transactionId`) or `RemoteStopTransaction` (integer `transactionId`) after the user confirms. Lifecycle reference: https://www.evtivity.com/docs/guides/station-lifecycle

Change the security profile or rotate the password on a connected station only with the user's consent. The CSMS sends SetNetworkProfile and Reset (2.1) or ChangeConfiguration and Reset (1.6). Lowering the profile of an online station is refused. Docs: https://www.evtivity.com/docs/csms/stations

## 5. OCPP 1.6 vs 2.1 gotchas

| Topic | OCPP 1.6 | OCPP 2.1 |
|---|---|---|
| Start a session remotely | `RemoteStartTransaction` with `idTag`, optional `connectorId` | `RequestStartTransaction` with `idToken` object and `remoteStartId`, optional `evseId` |
| Stop a session remotely | `RemoteStopTransaction`, integer `transactionId` | `RequestStopTransaction`, string `transactionId` |
| Transaction id origin | The CSMS assigns an integer in the StartTransaction response (from a database sequence, or the id of a session the portal pre-created) | The station creates it and sends it in `TransactionEvent` `Started`. Since v0.1.38 the CSMS scopes ids per station. |
| Transaction messages | `StartTransaction`, `MeterValues`, `StopTransaction` | `TransactionEvent` with `eventType` `Started`, `Updated`, `Ended` |
| Connector status | `StatusNotification` with 9 values: `Available`, `Preparing`, `Charging`, `SuspendedEV`, `SuspendedEVSE`, `Finishing`, `Reserved`, `Unavailable`, `Faulted` | `StatusNotification` with 5 values: `Available`, `Occupied`, `Reserved`, `Unavailable`, `Faulted`. Activity is `chargingState` on `TransactionEvent`: `EVConnected`, `Charging`, `SuspendedEV`, `SuspendedEVSE`, `Idle` (and `Discharging` for V2G). The CSMS writes the more specific value to the connector status during a transaction. |
| After a stop, cable still in | `Finishing` | `Occupied` with `chargingState` `EVConnected` |
| Station-level status | Connector 0 | EVSE 0, or `NotifyEvent` for `ChargingStation` `AvailabilityState` |
| Refresh connector status | `TriggerMessage` `StatusNotification` | `TriggerMessage` `TransactionEvent` during a session, `StatusNotification` otherwise |
| EVSE model | No EVSEs. The CSMS stores connector N as EVSE N with one connector N | EVSEs with one or more connectors |
| Read configuration | `GetConfiguration` returns all keys at once. Unknown keys come back in `unknownKey` | `GetVariables` (point read) or `GetBaseReport`, which answers `Accepted` and sends the data later in `NotifyReport` |
| Write configuration | `ChangeConfiguration`, one key per call, values are strings. Answers `Accepted`, `Rejected`, `RebootRequired`, `NotSupported` | `SetVariables`, many items per call, per-item status (`Accepted`, `Rejected`, `RebootRequired`, `NotSupported`, `UnknownComponent`, `UnknownVariable`) |
| Reset | `Hard` or `Soft`, whole station | `Immediate`, `OnIdle` or `ImmediateAndResume`, optional `evseId` |
| Basic Auth password change | `ChangeConfiguration` `AuthorizationKey` with the hex-encoded password, 16 to 20 characters | `SetVariables` `SecurityCtrlr.BasicAuthPassword`, 16 to 40 characters |
| Security profile upgrade | `ChangeConfiguration` `SecurityProfile`, then Reset | `SetNetworkProfile`, `NetworkConfigurationPriority`, then Reset OnIdle |
| Diagnostics upload | `GetDiagnostics` (or `GetLog` with the security extension) | `GetLog` |
| Commands only in 2.1 | | Variable monitoring, display messages, tariffs and cost, network profile, DER control, periodic event streams, battery swap, dynamic schedules, firmware publishing |

The ones that break tests most often:

- Transaction ids: 2.1 stations create a string `transactionId`. On 1.6 the CSMS assigns an integer in the StartTransaction response. Use the id the CSMS stored on the session.
- Status: 1.6 sends one fine-grained `StatusNotification` (`Charging`, `Preparing`, `Finishing`, ...). 2.1 `StatusNotification` has only `Available`, `Occupied`, `Reserved`, `Unavailable`, `Faulted`. Charging detail is `chargingState` on `TransactionEvent`. Do not expect `Charging` in a 2.1 StatusNotification.
- To refresh status on 2.1 with an active session, trigger `TransactionEvent`, not `StatusNotification`.
- Start and stop: `RemoteStartTransaction` and `RemoteStopTransaction` (1.6) vs `RequestStartTransaction` and `RequestStopTransaction` (2.1).
- Configuration: 1.6 keys with `GetConfiguration` and `ChangeConfiguration` (one key per call). 2.1 component and variable pairs with `GetVariables`, `SetVariables` and `GetBaseReport` (data arrives later in `NotifyReport`).
- The `/v1/ocpp/commands/{version}` routes send the payload as written. They do not translate between versions.

## 6. When a result looks wrong

1. Re-read the raw exchange in the message log. Compare it with the OCPP schema (`GET /v1/ocpp/schemas/{action}`).
2. Check the station state: online, onboarding status, availability, protocol.
3. For conformance failures, open the failed test's steps and compare expected and actual.
4. If EVtivity is at fault, collect the request, the response, the message log rows and the version (`GET /v1/version`), then use the `evtivity-report-issue` skill.

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `conformance/charging-station-ocpp16` | `references/charging-station-ocpp16.md` | https://www.evtivity.com/docs/conformance/charging-station-ocpp16 |
| `conformance/charging-station-ocpp21` | `references/charging-station-ocpp21.md` | https://www.evtivity.com/docs/conformance/charging-station-ocpp21 |
| `conformance/csms-ocpp16` | `references/csms-ocpp16.md` | https://www.evtivity.com/docs/conformance/csms-ocpp16 |
| `conformance/csms-ocpp21` | `references/csms-ocpp21.md` | https://www.evtivity.com/docs/conformance/csms-ocpp21 |
| `conformance/overview` | `references/overview.md` | https://www.evtivity.com/docs/conformance/overview |
| `csms/conformance-testing` | `references/conformance-testing.md` | https://www.evtivity.com/docs/csms/conformance-testing |
| `guides/ocpp-testing` | `references/ocpp-testing.md` | https://www.evtivity.com/docs/guides/ocpp-testing |
