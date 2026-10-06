---
name: evtivity-simulator
description: Drive the EVtivity charging station simulator (CSS) to test the CSMS without hardware. Covers standby and chaos modes (CSS_MODE, CSS_STATION_LIMIT, CSS_ACTION_INTERVAL_MS and the other simulator environment variables), meter value generation, reconnect behavior, TLS and Mutual TLS for simulated stations, creating, enabling, disabling and deleting simulated OCPP 1.6 and 2.1 stations (dashboard toggle, /v1/stations, /v1/css/stations), real stations on a simulator row, the dashboard Simulate tab and the /v1/css/actions API (plug in, authorize, start and stop charging, unplug, inject and clear faults, go offline, come online, OCPP 1.6 and 2.1 station messages), and running a full test session end to end through to the session, energy and cost in the dashboard and API. Use when someone wants simulated or virtual charging stations, a test or demo charging session, load testing, chaos traffic, or asks why a simulated station does not connect or an action fails.
license: MIT
compatibility: Needs a running EVtivity CSMS with the simulator service (Docker Compose service "simulator"), curl and jq for the API examples.
metadata:
  evtivity-version: "0.1.39"
  evtivity-docs-section: simulator
---

# EVtivity charging station simulator

The simulator (CSS) runs virtual OCPP 1.6 and 2.1 stations that connect to the OCPP server like real hardware. You create simulated stations, then trigger physical events (plug in, tap a card, fault, go offline) from the dashboard or the API. The CSMS treats the result exactly like a real station.

Docs pages for this section. Read the live page when you need detail beyond this workflow:

| Page id | URL | Covers |
|---|---|---|
| simulator/overview | https://www.evtivity.com/docs/simulator/overview | Architecture, modes, env vars, meter value physics, TLS, reconnects |
| simulator/stations | https://www.evtivity.com/docs/simulator/stations | Creating, enabling, disabling, deleting simulated stations, real stations on a simulator row, management API |
| simulator/actions | https://www.evtivity.com/docs/simulator/actions | Each action, its body, the OCPP messages sent and the resulting connector status per version |

Related skills: `evtivity-getting-started` (local install, `.env`, `CSS_MODE`), `evtivity-api` (API keys and auth), `evtivity-csms` (dashboard pages: stations, sites, pricing, tokens, sessions), `evtivity-integrations` (test payment provider for paid sessions), `evtivity-conformance` (OCPP commands and OCTT), `evtivity-configuration`, `evtivity-deployment`, `evtivity-guides`, `evtivity-troubleshoot`, `evtivity-report-issue`.

## API basics

All examples use an operator API key (see `evtivity-api`):

```bash
export EVTIVITY_API=http://localhost:7102     # Docker Compose default
export EVTIVITY_TOKEN=<64-hex API key>
H=(-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json')
```

Permissions: `stations:read` for `GET /v1/css/stations...`, `stations:write` for every create, update, enable, disable, delete and every `/v1/css/actions/...` call. `drivers:write` to create tokens, `sessions:read` to read sessions.

Treat simulator station output as secret. `GET /v1/css/stations` and `GET /v1/css/stations/{stationId}` return each station's Basic Auth password, TLS private key and certificates to any caller with `stations:read` (default operator and viewer roles have it). Do not paste that output into tickets, logs or chats. Filter it with jq, for example `jq '.data[] | {stationId, status, enabled, targetUrl}'`. Give `stations:read` only to users and keys that may see these secrets.

## 1. Check the simulator runs and pick a mode

Docs: simulator/overview (https://www.evtivity.com/docs/simulator/overview) and configuration/environment-variables (https://www.evtivity.com/docs/configuration/environment-variables).

1. Confirm the service is up: `docker compose ps simulator` shows it running. It has no Docker health check and its health port (8082) is not published.
2. Read its log: `docker compose logs --tail 50 simulator`. Expect `SimulatorManager started. Mode: standby` (or `chaos`) and one `Started simulator: <stationId>` line per enabled station.
3. Pick the mode:
   - `standby` (default): stations connect and idle. Nothing happens until you send an action or the CSMS sends a command. Use it for any test where you need a predictable result.
   - `chaos`: every `CSS_ACTION_INTERVAL_MS` one random valid action runs on a random simulated station, with random active driver tokens. Use it for demos and load. It will interfere with a manual test on the same stations.
4. Change the mode in the CSMS checkout's `.env` (`CSS_MODE=chaos`, optional `CSS_STATION_LIMIT`, `CSS_ACTION_INTERVAL_MS`), then `docker compose up -d simulator`. One-off: `CSS_MODE=chaos docker compose up -d`. `CSS_MODE` accepts only `standby` or `chaos`. Any other value stops the simulator at startup. Ask the user before you switch a shared environment to chaos.

Code facts the overview page gets wrong: `CSS_API_URL` and `CSS_API_TOKEN` do not exist. `CSS_STATION_PASSWORD` is parsed but not used (each station uses the password stored on its simulator row). Chaos reads stations straight from the database. Docker Compose defaults `CSS_ACTION_INTERVAL_MS` to `3000` when `.env` does not set it.

## 2. Create a simulated station

Docs: simulator/stations (https://www.evtivity.com/docs/simulator/stations), guides/station-onboarding (https://www.evtivity.com/docs/guides/station-onboarding).

A simulated station is two rows: `charging_stations` (identity, `is_simulator = true`, security profile, password hash) and `css_stations` (simulator runtime: `targetUrl`, password, certificates, `enabled`). The simulator picks up enabled rows within 5 seconds.

Decide the path:

| You want | Use |
|---|---|
| A new station with a site, protocol, profile and password in one call | Path A: `POST /v1/stations` with `isSimulator: true` (recommended) |
| To simulate an existing station record | Path B: dashboard toggle or `PATCH /v1/stations/{id}` |
| Full control of EVSEs, connector types and power | Path C: `POST /v1/css/stations`, then set the password |

### Path A: POST /v1/stations

```bash
curl -s "$EVTIVITY_API/v1/stations" "${H[@]}" -d '{
  "stationId": "SIM-001",
  "ocppProtocol": "ocpp2.1",
  "securityProfile": 1,
  "password": "SimPassword123456",
  "siteId": "sit_xxxxxxxxxxxx",
  "isSimulator": true
}' | jq '{id, stationId, onboardingStatus}'
```

- The password must be 16 to 40 characters (16 to 20 for OCPP 1.6) from `a-z A-Z 0-9 * - _ = : + | @ .`.
- The CSMS stores the password hash and creates the simulator row with the same password. Profiles 0 and 1 get the plain URL (`OCPP_SERVER_URL` of the API, Compose `ws://ocpp:7103`), profiles 2 and 3 the TLS URL (`wss://ocpp:8443`). Without existing EVSEs it adds one EVSE with a random connector type at 22 kW.
- Keep the returned `id` (`sta_...`). Station routes and session filters need it, not the OCPP station ID.
- Under the default registration policy (`approval-required`) the station is `pending` and BootNotification returns `Pending`. Approve it: `curl -s -X POST "$EVTIVITY_API/v1/stations/$STA/approve" -H "Authorization: Bearer $EVTIVITY_TOKEN"`.

### Path B: toggle an existing station

Dashboard: station detail > Details tab > Edit > check **Simulator station** > Save. API: `PATCH /v1/stations/{id}` with `{"isSimulator": true}`. This creates or re-enables the simulator row. Unchecking sets `enabled = false` and keeps the row, so a re-enable reuses the URL, password and certificates.

If the simulator row has no password (it was created without one), set it with Step 2b.

### Path C: POST /v1/css/stations

```bash
curl -s "$EVTIVITY_API/v1/css/stations" "${H[@]}" -d '{
  "stationId": "SIM-002",
  "ocppProtocol": "ocpp1.6",
  "securityProfile": 1,
  "targetUrl": "ws://ocpp:7103",
  "password": "SimPassword12345",
  "evses": [
    {"evseId": 1, "connectorType": "ac_type2", "maxPowerW": 22000},
    {"evseId": 2, "connectorType": "dc_ccs2", "maxPowerW": 150000}
  ]
}' | jq '{stationId, enabled, targetUrl}'
```

- Required: `stationId`, `targetUrl`, `evses` (1 to 50). Connector types: `ac_type2`, `ac_type1`, `dc_ccs2`, `dc_ccs1`, `dc_chademo`. EVSE defaults: connector 1, `ac_type2`, 22000 W, 3 phases, 230 V.
- `targetUrl` is the URL as the simulator container sees it. In Docker Compose use `ws://ocpp:7103` or `wss://ocpp:8443`, not `localhost`.
- A new station ID gets a `charging_stations` row that is already `accepted`, with profile 1 and ocpp1.6 by default. An existing non-simulator row is flipped to simulator. A duplicate simulator row answers 409 `DUPLICATE_STATION_ID`.
- This route does not store a Basic Auth password hash on the station. With profile 1 or 2 the OCPP server rejects the connection ("No password configured") until you run Step 2b with the same password.

### 2b. Set the station password (paths B and C)

Find the station's `sta_` id (`GET /v1/stations?search=SIM-002&isSimulator=true`), then:

```bash
curl -s "$EVTIVITY_API/v1/stations/$STA/credentials" "${H[@]}" -d '{"password":"SimPassword12345"}'
```

While the station is offline, the CSMS stores the hash and writes the same password (and the matching plain or TLS URL) to the simulator row. It answers `appliedTo: "stored"`.

### Confirm the station is online

- Log: `Started simulator: SIM-001`. No line for minutes: check `enabled` and the URL (`jq '{stationId, enabled, status, targetUrl}'` on `GET /v1/css/stations/SIM-001`).
- `GET /v1/stations/$STA` shows `isOnline: true` and `onboardingStatus: "accepted"`. The dashboard station page shows the Simulator badge and a **Simulate** tab.
- `GET /v1/stations/$STA/connectors` lists EVSEs with status `available`.
- Still offline: the station **Security** tab and `GET /v1/stations/$STA/security-logs` show `auth_failed` with the reason. Then use `evtivity-troubleshoot`.

## 3. Prepare a driver token and pricing

Docs: csms/tokens (https://www.evtivity.com/docs/csms/tokens), csms/pricing (https://www.evtivity.com/docs/csms/pricing), guides/using-rfid-tokens (https://www.evtivity.com/docs/guides/using-rfid-tokens).

- `authorize` and `startCharging` need an `idToken` that exists in driver tokens. The Simulate tab refuses an unknown token. Create a driver and a token (`POST /v1/drivers`, then `POST /v1/tokens` with `idToken`, `tokenType` `ISO14443`, `driverId`), or reuse an active demo token from `GET /v1/tokens`.
- Cost needs a tariff that applies to the station: a pricing group assigned to the station or its site, or a default group. Without one the session still records energy. See `evtivity-csms`.
- When a payment provider is active, sessions go through the payment flow. For paid test sessions use the test provider (`evtivity-integrations`, https://www.evtivity.com/docs/integrations/test-payment-provider). It needs `PAYMENTS_ALLOW_SIMULATED=true`, which Docker Compose sets.

## 4. Run a full test session

Docs: simulator/actions (https://www.evtivity.com/docs/simulator/actions), csms/sessions (https://www.evtivity.com/docs/csms/sessions).

Run in `standby`. Dashboard: station page > **Simulate** tab, set EVSE ID and ID Token, press the buttons in order. Buttons that are not valid for the connector's current status are disabled. API: `POST /v1/css/actions/<action>` with `stationId` (the OCPP station ID) in the body.

```bash
act() { curl -s "$EVTIVITY_API/v1/css/actions/$1" "${H[@]}" -d "$2"; echo; }

act plugIn        '{"stationId":"SIM-001","evseId":1}'
act authorize     '{"stationId":"SIM-001","evseId":1,"idToken":"TEST-TOKEN-001"}'
# authorize with the cable in starts the transaction. Without authorize, use:
# act startCharging '{"stationId":"SIM-001","evseId":1,"idToken":"TEST-TOKEN-001"}'
sleep 60          # let meter values accumulate (one tick every 10 s by default)
act stopCharging  '{"stationId":"SIM-001","evseId":1,"reason":"Local"}'
act unplug        '{"stationId":"SIM-001","evseId":1}'
```

Each call waits up to 5 seconds for the simulator's result:

| Response | Meaning | Do |
|---|---|---|
| 200 `{commandId}` | The simulator ran the action | Check the connector status |
| 400 `CONNECTOR_NOT_AVAILABLE` | `startCharging` needs connector status `preparing`, `occupied`, `ev_connected` or `finishing` | Run `plugIn` first |
| 400 `CSS_ACTION_REJECTED` | The simulator refused, with its reason in `error` (for example no active transaction on the EVSE) | Fix the order or the EVSE |
| 400 `OCPP_VERSION_MISMATCH` | A `v16/` action on a 2.1 station or the reverse | Use the right prefix |
| 404 `STATION_NOT_FOUND`, `EVSE_NOT_FOUND` | No simulator row, no access, or wrong EVSE | Check `stationId` and `evseId` |
| 504 `CSS_ACTION_TIMEOUT` | No result in 5 s. The simulator is down, the station is not running, or Redis is unreachable | Check the simulator log |

The simulator/actions page also says actions are fire-and-forget. The code waits for the result as above.

Expected connector status after each step (`GET /v1/stations/$STA/connectors`):

| Step | OCPP 1.6 | OCPP 2.1 |
|---|---|---|
| plugIn | `preparing` | `occupied` |
| authorize (cable in) or startCharging | `charging` | `ev_connected`, then `charging` at the first meter tick |
| stopCharging | `finishing` | `occupied` |
| unplug | `available` | `available` |

Variants (details per version on simulator/actions):

- Authorize before plug in: 1.6 goes to `preparing` and plug in within the connection timeout starts the transaction. On 2.1 the status is unchanged until plug in. If the timeout expires, 1.6 returns to Available and 2.1 sends Started then Ended with `EVConnectTimeout`.
- Unplug during a transaction ends it (`EVDisconnected`) when `StopTransactionOnEVSideDisconnect` (1.6) or `TxCtrlr.StopTxOnEVSideDisconnect` (2.1) is true, the default.
- Remote start from the dashboard, portal or `evtivity-conformance` (RequestStartTransaction or RemoteStartTransaction) also works on a simulated station: the simulator accepts it and waits for plug in.

### Confirm the session, energy and cost

```bash
curl -s "$EVTIVITY_API/v1/sessions?stationId=$STA&limit=5" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  | jq '.data[] | {id, status, energyDeliveredWh, currentCostCents, finalCostCents, currency, stoppedReason}'
SESSION=<id from above>
curl -s "$EVTIVITY_API/v1/sessions/$SESSION/meter-values?limit=5" -H "Authorization: Bearer $EVTIVITY_TOKEN" | jq .
```

- While charging: `status` `active`, `energyDeliveredWh` rises every tick, `currentCostCents` follows the tariff.
- After stop: `status` `completed`, `finalCostCents` set, `endedAt` set. `faulted` or `failed` means the session was stopped by a fault, the payment flow or a lost stop (see https://www.evtivity.com/docs/guides/troubleshooting).
- Dashboard: Sessions page, or the station's sessions, shows the same session with meter values and cost.
- Energy check: AC power is about 85 to 95 percent of `maxPowerW`. A 22 kW EVSE adds about 55 Wh per 10 s tick.

## 5. Faults, offline and station messages

Docs: simulator/actions (https://www.evtivity.com/docs/simulator/actions), guides/ev-charging-behaviors (https://www.evtivity.com/docs/guides/ev-charging-behaviors).

- `injectFault` `{"stationId","evseId","errorCode":"InternalError"}`: stops an active transaction, then StatusNotification Faulted. Connector `faulted`. No-op when already faulted.
- `clearFault` `{"stationId","evseId"}`: back to `available`. No-op when not faulted.
- `goOffline` `{"stationId"}`: closes the WebSocket. The CSMS marks the station offline. Use it to test offline queues and stale session cleanup.
- `comeOnline` `{"stationId"}`: BootNotification and the last reported statuses. OCPP 1.6 replays queued StartTransaction, StopTransaction and MeterValues.
- Station-initiated messages, version prefixed: `/v1/css/actions/v16/<action>` (10 actions, for example `sendStatusNotification`, `sendMeterValues`, `sendStartTransaction`, `sendStopTransaction`) and `/v1/css/actions/v21/<action>` (37 actions, for example `sendTransactionEvent`, `sendNotifyEvent`, `sendSecurityEventNotification`). Bodies and the full list: the "CSS OCPP 1.6 Actions" and "CSS OCPP 2.1 Actions" tags in the API reference (`evtivity-api`). Use them to reproduce vehicle-side states such as `SuspendedEV`.
- `rebootStation` appears on simulator/actions but has no API route and no Simulate button. Do not call it. Use `goOffline` and `comeOnline`, or a Reset command.

## 6. Security profiles and TLS for simulated stations

Docs: simulator/overview (https://www.evtivity.com/docs/simulator/overview), csms/stations (https://www.evtivity.com/docs/csms/stations), configuration/ocpp-settings (https://www.evtivity.com/docs/configuration/ocpp-settings).

- Profile 0: no credentials, plain URL. Development only.
- Profile 1: Basic Auth over `ws://`. Profile 2: Basic Auth over `wss://`. Profile 3: client certificate over `wss://`, no password.
- The simulator connects to the row's `targetUrl`. A `wss://` URL uses TLS. With the Compose self-signed certificate keep `TLS_REJECT_UNAUTHORIZED=false` on the simulator.
- Profile 3 needs `clientCert`, `clientKey` and `caCert` PEMs on the simulator row (`POST` or `PATCH /v1/css/stations`), or the simulator env vars `CSS_CLIENT_CERT[_PEM]`, `CSS_CLIENT_KEY[_PEM]`, `CSS_CA_CERT`/`CSS_CA_PEM`. The overview page mentions a `test-certs` folder. The simulator does not read it.
- Change the password or profile through the station's **Security** tab or `POST /v1/stations/$STA/credentials` and `PATCH /v1/stations/$STA` (`securityProfile`). An online simulated station receives the change over OCPP like a real station, applies a profile upgrade at the following reset, and falls back to its old connection after three failed attempts. A lower profile is refused while the station is online. Take it offline first (`goOffline`).
- `PATCH /v1/css/stations/{stationId}` changes simulator fields (`targetUrl`, `password`, certificates, `enabled`) and routes `ocppProtocol`, `securityProfile`, `model`, `serialNumber`, `firmwareVersion` to the station. It does not change the stored password hash. Prefer the station security routes so both sides match.

## 7. Disable, delete, real stations

Docs: simulator/stations (https://www.evtivity.com/docs/simulator/stations).

- Disable or enable: `POST /v1/css/stations/{stationId}/disable` or `/enable`, or the dashboard toggle. The simulator stops or starts within 5 seconds. The rows stay.
- `DELETE /v1/css/stations/{stationId}` removes only the simulator row and stops its simulator. The station record stays. To remove the whole station, use the dashboard Delete Station action (simulator/stations). Both are irreversible: confirm with the user first.
- A real station that connects on a simulator row: the simulator sends the header `x-evtivity-simulator: css`. A connection without it and with a password or certificate clears the simulator flag and disables the simulator (`simulator_self_healed`). Profile 0, or an enabled simulator never seen with the header, records a conflict (`simulator_conflict`) and the station page shows a warning. Confirm a real station with **This is a real station** or `POST /v1/stations/$STA/confirm-real-station` (`stations:write`). Ask the user before you confirm: it disables the simulator.

## When to hand off

- Install, ports, `.env`: `evtivity-getting-started`.
- OCPP commands to a simulated station and OCTT conformance runs: `evtivity-conformance` (https://www.evtivity.com/docs/guides/ocpp-testing).
- Station, site, tariff and session pages: `evtivity-csms`.
- A simulator or OCPP container that fails or a station that will not connect: `evtivity-troubleshoot`.
- A reproducible bug in the simulator or the CSMS: `evtivity-report-issue`.

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `simulator/actions` | `references/actions.md` | https://www.evtivity.com/docs/simulator/actions |
| `simulator/overview` | `references/overview.md` | https://www.evtivity.com/docs/simulator/overview |
| `simulator/stations` | `references/stations.md` | https://www.evtivity.com/docs/simulator/stations |
