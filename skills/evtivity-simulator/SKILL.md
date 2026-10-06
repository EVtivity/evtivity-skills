---
name: evtivity-simulator
description: "Run the EVtivity charging station simulator: create simulated OCPP 1.6 and 2.1 stations, standby and chaos modes, plug in, authorize, start and stop charging, faults, offline, and full test sessions without hardware. Use for a test or demo charging session or load testing. Not for OCTT conformance runs (evtivity-conformance)."
license: MIT
compatibility: Needs a running EVtivity CSMS with the simulator service (Docker Compose service "simulator"), curl and jq for the API examples.
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39"
  evtivity-commit: "85333dc7da57a2e0b9d74d1d09d448dee313a29b"
  evtivity-docs-section: simulator
---

# EVtivity charging station simulator

Not for: OCTT conformance runs and raw OCPP command testing (use evtivity-conformance), a real station that cannot connect (use evtivity-troubleshoot), installing the stack (use evtivity-getting-started).

The simulator (CSS) runs virtual OCPP 1.6 and 2.1 stations that connect to the OCPP server like real hardware. You create simulated stations, then trigger physical events (plug in, tap a card, fault, go offline) from the dashboard or the API. The CSMS treats the result exactly like a real station.

## API basics

```bash
export EVTIVITY_API=http://localhost:7102     # Docker Compose default
export EVTIVITY_TOKEN=<64-hex API key>        # see evtivity-api
H=(-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json')
```

Permissions: `stations:read` for `GET /v1/css/stations`, `stations:write` for every create, update, enable, disable, delete and every `/v1/css/actions/` call. `drivers:write` to create tokens, `sessions:read` to read sessions.

Treat simulator station output as secret. `GET /v1/css/stations` and `GET /v1/css/stations/{stationId}` return each station's Basic Auth password, TLS private key and certificates to any caller with `stations:read`. Do not paste that output into tickets, logs or chats. Filter it: `jq '.data[] | {stationId, status, enabled, targetUrl}'`.

## 1. Check the simulator runs and pick a mode (`references/overview.md`)

1. `docker compose ps simulator` shows it running. It has no Docker health check and its health port (8082) is not published.
2. `docker compose logs --tail 50 simulator`: expect `SimulatorManager started. Mode: standby` (or `chaos`) and one `Started simulator: <stationId>` line per enabled station.
3. Modes:
   - `standby` (default): stations connect and idle until you send an action or the CSMS sends a command. Use it for predictable tests.
   - `chaos`: every `CSS_ACTION_INTERVAL_MS` one random valid action runs on a random simulated station. Use it for demos and load. It interferes with manual tests on the same stations.
4. Change the mode in the checkout's `.env` (`CSS_MODE=chaos`, optional `CSS_STATION_LIMIT`, `CSS_ACTION_INTERVAL_MS`), then `docker compose up -d simulator`. `CSS_MODE` accepts only `standby` or `chaos`. Ask the user before switching a shared environment to chaos.

## 2. Create a simulated station (`references/stations.md`)

A simulated station is two rows: `charging_stations` (identity, `is_simulator = true`, security profile, password hash) and `css_stations` (simulator runtime: `targetUrl`, password, certificates, `enabled`). The simulator picks up enabled rows within 5 seconds.

| You want | Use |
|---|---|
| A new station with a site, protocol, profile and password in one call | Path A: `POST /v1/stations` with `isSimulator: true` (recommended) |
| To simulate an existing station record | Path B: dashboard toggle or `PATCH /v1/stations/{id}` |
| Full control of EVSEs, connector types and power | Path C: `POST /v1/css/stations`, then set the password |

### Path A: POST /v1/stations

```bash
curl -s "$EVTIVITY_API/v1/stations" "${H[@]}" -d '{
  "stationId": "SIM-001", "ocppProtocol": "ocpp2.1", "securityProfile": 1,
  "password": "SimPassword123456", "siteId": "sit_xxxxxxxxxxxx", "isSimulator": true
}' | jq '{id, stationId, onboardingStatus}'
```

- Password: 16 to 40 characters (16 to 20 for OCPP 1.6) from `a-z A-Z 0-9 * - _ = : + | @ .`.
- The CSMS stores the hash and creates the simulator row with the same password. Profiles 0 and 1 get the plain URL (Compose `ws://ocpp:7103`), profiles 2 and 3 the TLS URL (`wss://ocpp:8443`). Without EVSEs it adds one EVSE at 22 kW.
- Keep the returned `id` (`sta_...`). Station routes and session filters need it.
- Under the default `approval-required` policy the station is `pending`. Approve it: `POST /v1/stations/$STA/approve`.

### Path B: toggle an existing station

Dashboard: station detail > Details tab > Edit > **Simulator station** > Save. API: `PATCH /v1/stations/{id}` with `{"isSimulator": true}`. Unchecking sets `enabled = false` and keeps the row. If the simulator row has no password, set it with 2b.

### Path C: POST /v1/css/stations

```bash
curl -s "$EVTIVITY_API/v1/css/stations" "${H[@]}" -d '{
  "stationId": "SIM-002", "ocppProtocol": "ocpp1.6", "securityProfile": 1,
  "targetUrl": "ws://ocpp:7103", "password": "SimPassword12345",
  "evses": [
    {"evseId": 1, "connectorType": "ac_type2", "maxPowerW": 22000},
    {"evseId": 2, "connectorType": "dc_ccs2", "maxPowerW": 150000}
  ]
}' | jq '{stationId, enabled, targetUrl}'
```

- Required: `stationId`, `targetUrl`, `evses` (1 to 50). Connector types: `ac_type2`, `ac_type1`, `dc_ccs2`, `dc_ccs1`, `dc_chademo`.
- `targetUrl` is the URL as the simulator container sees it: in Docker Compose `ws://ocpp:7103` or `wss://ocpp:8443`, not `localhost`.
- A duplicate simulator row answers 409 `DUPLICATE_STATION_ID`.
- This route stores no Basic Auth password hash on the station. With profile 1 or 2 the OCPP server rejects the connection until you run 2b with the same password.

### 2b. Set the station password (paths B and C)

```bash
curl -s "$EVTIVITY_API/v1/stations/$STA/credentials" "${H[@]}" -d '{"password":"SimPassword12345"}'
```

Offline, the CSMS stores the hash, writes the same password and URL to the simulator row, and answers `appliedTo: "stored"`.

### Confirm the station is online

- Log: `Started simulator: SIM-001`. No line for minutes: check `enabled` and `targetUrl` on `GET /v1/css/stations/SIM-001`.
- `GET /v1/stations/$STA` shows `isOnline: true` and `onboardingStatus: "accepted"`. The station page shows a **Simulate** tab.
- Still offline: the **Security** tab and `GET /v1/stations/$STA/security-logs` show `auth_failed` with the reason. Then evtivity-troubleshoot.

## 3. Prepare a driver token and pricing

- `authorize` and `startCharging` need an `idToken` that exists in driver tokens. Create a driver and a token (`POST /v1/drivers`, then `POST /v1/tokens` with `idToken`, `tokenType` `ISO14443`, `driverId`), or reuse an active demo token from `GET /v1/tokens`.
- Cost needs a tariff for the station (evtivity-csms). Without one the session still records energy.
- With a payment provider active, sessions go through the payment flow. For paid test sessions use the test provider (evtivity-integrations), which needs `PAYMENTS_ALLOW_SIMULATED=true` (Docker Compose sets it).

## 4. Run a full test session (`references/actions.md`)

Run in `standby`. Dashboard: station page > **Simulate** tab, set EVSE ID and ID Token, press the buttons in order. API: `POST /v1/css/actions/<action>` with `stationId` (the OCPP station ID) in the body.

```bash
act() { curl -s "$EVTIVITY_API/v1/css/actions/$1" "${H[@]}" -d "$2"; echo; }

act plugIn        '{"stationId":"SIM-001","evseId":1}'
act authorize     '{"stationId":"SIM-001","evseId":1,"idToken":"TEST-TOKEN-001"}'
# authorize with the cable in starts the transaction. Without authorize, use:
# act startCharging '{"stationId":"SIM-001","evseId":1,"idToken":"TEST-TOKEN-001"}'
sleep 60          # meter values accumulate (one tick every 10 s by default)
act stopCharging  '{"stationId":"SIM-001","evseId":1,"reason":"Local"}'
act unplug        '{"stationId":"SIM-001","evseId":1}'
```

Each call waits up to 5 seconds for the simulator's result:

| Response | Meaning | Do |
|---|---|---|
| 200 `{commandId}` | The simulator ran the action | Check the connector status |
| 400 `CONNECTOR_NOT_AVAILABLE` | `startCharging` needs status `preparing`, `occupied`, `ev_connected` or `finishing` | Run `plugIn` first |
| 400 `CSS_ACTION_REJECTED` | The simulator refused, reason in `error` | Fix the order or the EVSE |
| 400 `OCPP_VERSION_MISMATCH` | A `v16/` action on a 2.1 station or the reverse | Use the right prefix |
| 404 `STATION_NOT_FOUND`, `EVSE_NOT_FOUND` | No simulator row, no access, or wrong EVSE | Check `stationId` and `evseId` |
| 504 `CSS_ACTION_TIMEOUT` | No result in 5 s: simulator down, station not running, or Redis unreachable | Check the simulator log |

Connector status after each step (`GET /v1/stations/$STA/connectors`):

| Step | OCPP 1.6 | OCPP 2.1 |
|---|---|---|
| plugIn | `preparing` | `occupied` |
| authorize (cable in) or startCharging | `charging` | `ev_connected`, then `charging` at the first meter tick |
| stopCharging | `finishing` | `occupied` |
| unplug | `available` | `available` |

Variants are on the actions page: authorize before plug in, unplug during a transaction (`EVDisconnected`), and remote start from the dashboard, portal or evtivity-conformance.

### Confirm the session, energy and cost

```bash
curl -s "$EVTIVITY_API/v1/sessions?stationId=$STA&limit=5" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  | jq '.data[] | {id, status, energyDeliveredWh, currentCostCents, finalCostCents, currency, stoppedReason}'
curl -s "$EVTIVITY_API/v1/sessions/$SESSION/meter-values?limit=5" -H "Authorization: Bearer $EVTIVITY_TOKEN" | jq .
```

- While charging: `status` `active`, `energyDeliveredWh` rises every tick, `currentCostCents` follows the tariff.
- After stop: `status` `completed`, `finalCostCents` and `endedAt` set. `faulted` or `failed` means a fault, the payment flow or a lost stop (evtivity-guides, field troubleshooting).
- Energy check: AC power is about 85 to 95 percent of `maxPowerW`. A 22 kW EVSE adds about 55 Wh per 10 s tick.

## 5. Faults, offline and station messages (`references/actions.md`)

- `injectFault` `{"stationId","evseId","errorCode":"InternalError"}`: stops an active transaction, then Faulted. `clearFault`: back to `available`.
- `goOffline` `{"stationId"}`: closes the WebSocket (test offline queues and stale session cleanup). `comeOnline`: BootNotification and the last statuses. OCPP 1.6 replays queued transaction messages.
- Station-initiated messages, version prefixed: `/v1/css/actions/v16/<action>` (for example `sendStatusNotification`, `sendMeterValues`) and `/v1/css/actions/v21/<action>` (for example `sendTransactionEvent`, `sendNotifyEvent`). Bodies: grep the evtivity-api route files `routes-css-ocpp-1-6-actions.md` and `routes-css-ocpp-2-1-actions.md`. Use them to reproduce states such as `SuspendedEV`.
- To restart a simulated station, use `goOffline` and `comeOnline`, or an OCPP Reset command.

## 6. Security profiles and TLS for simulated stations (`references/overview.md`)

- Profile 0: no credentials, plain URL, development only. Profile 1: Basic Auth over `ws://`. Profile 2: Basic Auth over `wss://`. Profile 3: client certificate over `wss://`, no password.
- A `wss://` `targetUrl` uses TLS. With the Compose self-signed certificate keep `TLS_REJECT_UNAUTHORIZED=false` on the simulator.
- Profile 3 needs `clientCert`, `clientKey` and `caCert` PEMs on the simulator row (`POST` or `PATCH /v1/css/stations`), or the simulator env vars `CSS_CLIENT_CERT[_PEM]`, `CSS_CLIENT_KEY[_PEM]`, `CSS_CA_CERT`/`CSS_CA_PEM`.
- Change the password or profile through the station's **Security** tab or `POST /v1/stations/$STA/credentials` and `PATCH /v1/stations/$STA` (`securityProfile`). An online simulated station receives the change over OCPP like a real station. A lower profile is refused while it is online: `goOffline` first.
- `PATCH /v1/css/stations/{stationId}` changes simulator fields but not the stored password hash. Prefer the station security routes so both sides match.

## 7. Disable, delete, real stations (`references/stations.md`)

- Disable or enable: `POST /v1/css/stations/{stationId}/disable` or `/enable`, or the dashboard toggle. The rows stay.
- `DELETE /v1/css/stations/{stationId}` removes only the simulator row. To remove the whole station, use Delete Station in the dashboard. Both are irreversible: confirm first.
- A real station on a simulator row: the simulator sends the header `x-evtivity-simulator: css`. A connection without it and with a password or certificate clears the simulator flag (`simulator_self_healed`). Otherwise a conflict is recorded (`simulator_conflict`). Confirm a real station with **This is a real station** or `POST /v1/stations/$STA/confirm-real-station` after the user agrees: it disables the simulator.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer.

- `references/overview.md`: architecture, modes, environment variables, meter value physics, TLS, reconnects.
- `references/stations.md`: creating, enabling, disabling and deleting simulated stations, real stations on a simulator row.
- `references/actions.md`: each action, its body, the OCPP messages sent and the connector status per version.
