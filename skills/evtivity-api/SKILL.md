---
name: evtivity-api
description: Use the EVtivity CSMS REST API. Covers operator sign-in tokens and API keys (create, scope permissions, revoke), driver portal authentication, base URLs (/v1/ and /v1/portal/), pagination, the error format and code catalog, RBAC permissions per route group, sending OCPP commands to charging stations and reading the result, and curl examples for stations, sessions, tariffs and reports. Use when someone wants to script, automate or integrate with EVtivity, call an endpoint, create an API key, start or stop a charging session remotely, or understand an API error code.
license: MIT
compatibility: Examples use curl and jq against a running EVtivity API (default http://localhost:7102 with Docker Compose).
metadata:
  evtivity-version: "0.1.39"
---

# EVtivity REST API

The API server serves the operator dashboard, the driver portal and integrations. Everything the dashboard does goes through it.

- Base URL: the API host. Docker Compose: `http://localhost:7102`. Helm and AWS: the API host name of the deployment.
- Operator routes: `/v1/...`. Driver portal routes: `/v1/portal/...`.
- Interactive reference on a running stack: Swagger UI at `<api>/docs`. Public reference: https://www.evtivity.com/api-reference and the spec at https://www.evtivity.com/openapi.json.
- Route catalog with the permission each route needs: `references/routes.md`.
- Error codes with HTTP statuses and messages: `references/error-codes.md`.

Unauthenticated checks: `GET /v1/health` (API, database, Redis) and `GET /v1/version`.

## Authenticate

Two realms. A driver token is refused on operator routes, and an operator token on driver routes.

### Operator: API key (preferred for scripts)

An API key is a 64-character hex token sent as a Bearer token. It belongs to the user who created it, and its permissions are a subset of that user's permissions.

Create one in the dashboard: Settings > API Keys > Create API Key (name, expiry, permissions). The token is shown once. Store it in a secret store or an environment variable, never in a file you commit.

Or create one with the API, signed in as a user with `settings.apiKeys:write`:

```bash
API=http://localhost:7102
TOKEN=$(curl -s "$API/v1/auth/login" -H 'Content-Type: application/json' \
  -d '{"email":"admin@evtivity.local","password":"admin123"}' | jq -r .token)

curl -s "$API/v1/api-keys" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"name":"reporting-script","expiresInDays":90,"permissions":["stations:read","sessions:read","reports:read","reports:write"]}' \
  | jq -r .rawToken
```

- `permissions` is required. A permission the creator lacks answers 403 `PERMISSIONS_EXCEED_OWN`. An unknown one answers 400 `INVALID_PERMISSIONS`.
- `GET /v1/api-keys` lists keys, `PATCH /v1/api-keys/{id}` changes permissions, `DELETE /v1/api-keys/{id}` revokes.
- Expired keys answer `API_KEY_EXPIRED`. Over the per-key rate limit: `API_KEY_RATE_LIMITED`.

Use it:

```bash
export EVTIVITY_API=http://localhost:7102
export EVTIVITY_TOKEN=<64-hex API key>
curl -s "$EVTIVITY_API/v1/stations" -H "Authorization: Bearer $EVTIVITY_TOKEN"
```

### Operator: sign-in token

`POST /v1/auth/login` with `email` and `password` returns `token` (a JWT valid for one hour) and sets cookies for the dashboard. Bearer clients send `token`.

- MFA on: the response has `mfaRequired: true` and an `mfaToken`. Post the code to `POST /v1/auth/mfa/verify` to get the session token.
- reCAPTCHA on: the login needs `recaptchaToken`, so scripts should use an API key instead.
- `mustResetPassword: true`: change the password first (`POST /v1/auth/force-change-password`).

### Driver portal

`POST /v1/portal/auth/login` with the driver's `email` and `password` returns `token` (and `refreshToken`). Send it as `Authorization: Bearer <token>` on `/v1/portal/...` routes. `POST /v1/portal/auth/refresh` rotates it. Public portal routes (station search, guest checkout) need no token.

## Conventions

- JSON in and out. Send `Content-Type: application/json` on requests with a body.
- IDs: resources use prefixed IDs, for example `sta_` plus 12 characters for stations and `sit_` for sites. A station also has `stationId`, its OCPP identity (`CS-001`). Detail routes such as `/v1/stations/{id}` take the prefixed ID. OCPP command routes take the OCPP identity.
- Pagination: list routes take `page` (from 1, default 1), `limit` (default 10, max 100) and often `search`, and return `{ "data": [...], "total": <count> }`. Loop until `page * limit >= total`.
- Money is in cents of the company currency (`currentCostCents`, `finalCostCents`). Energy is in Wh.
- Errors: `{ "error": "<message>", "code": "<CODE>" }`. Match on `code`, never the message. 401 means no or bad token, 403 a missing permission or forbidden action, 404 also hides resources outside the user's site access, 409 a conflict such as `EVSE_IN_USE`, 429 `RATE_LIMITED` (see the `x-ratelimit-*` headers). Codes: `references/error-codes.md` and https://www.evtivity.com/api-reference/error-codes.

## Permissions

Permissions are `resource:action`, with `read` and `write`. `write` includes `read` for the same resource. Default roles: Admin (all), Operator (operations, no settings, `users:read`), Viewer (read only). The `references/routes.md` table lists the exact permission per route.

| Route group | Permission |
|---|---|
| Stations, EVSEs, connectors, station images, local auth list, event alerts, display messages | `stations:read` / `stations:write` |
| OCPP commands (`/v1/ocpp/commands/...`) | `stations:write` |
| Sites | `sites:read` / `sites:write` |
| Sessions, transactions, meter values | `sessions:read` |
| Drivers and driver tokens (RFID) | `drivers:read` / `drivers:write` |
| Fleets | `fleets:read` / `fleets:write` |
| Pricing groups, tariffs, holidays | `pricing:read` / `pricing:write` |
| Payments, invoices | `payments:read` / `payments:write` |
| Reservations | `reservations:read` / `reservations:write` |
| Reports, NEVI | `reports:read` / `reports:write` |
| Dashboard metrics | `dashboard:read` |
| Load management | `loadManagement:read` / `loadManagement:write` |
| Smart charging | `smartCharging:read` / `smartCharging:write` |
| Maintenance windows | `maintenance:read` / `maintenance:write` |
| OCPI roaming | `roaming:read` / `roaming:write` |
| Certificates, Plug and Charge | `certificates:read` / `certificates:write` |
| Notifications | `notifications:read` / `notifications:write` |
| Support cases | `support:read` / `support:write` |
| Users and roles | `users:read` / `users:write` |
| Audit log, access logs | `audit:read`, `logs:read` |
| Settings | `settings.system`, `settings.security`, `settings.integrations`, `settings.notification`, `settings.payment`, `settings.apiKeys`, `settings.firmware`, `settings.stationConfig`, `settings.ai` (each `:read` / `:write`) |

Give a script's API key only the permissions it needs.

## OCPP commands

`POST /v1/ocpp/commands/{v21|v16}/{Action}` sends an OCPP command to a connected station and waits for its answer (up to 35 seconds). Use `v21` for stations with `ocppProtocol: "ocpp2.1"` and `v16` for `"ocpp1.6"`. The body is the OCPP request payload plus `stationId`, the station's OCPP identity. `GET /v1/ocpp/commands/v16/{action}/schema` and `GET /v1/ocpp/schemas/{action}` return the JSON schema of a payload.

Responses:

| Status | Body | Meaning |
|---|---|---|
| 200 | `{ status: "accepted", stationId, action, response }` | The station answered. `status` only says an answer arrived. Read `response.status` (`Accepted`, `Rejected`, `Scheduled`, ...): a station that refuses still gives 200. |
| 202 | `{ status: "queued", code: "COMMAND_QUEUED", ... }` | The station is offline. The command is queued and sent when it reconnects. |
| 502 | `{ status: "error", code: "COMMAND_ERROR", error, ... }` | No usable answer: the station returned an OCPP CALLERROR, did not answer in time, closed the connection, or does not support the command. `error` says which. |
| 504 | `{ status: "timeout", code: "COMMAND_TIMEOUT", ... }` | No result reached the API within 35 seconds. |
| 400, 404 | `{ error, code }` | Bad payload, unknown station, or wrong OCPP version for the station. |

The route descriptions in Swagger say 502 means "the station rejects". The code returns a rejection as 200 with `response.status: "Rejected"`. Always check `response.status`.

Trigger a status report (OCPP 2.1):

```bash
curl -s "$EVTIVITY_API/v1/ocpp/commands/v21/TriggerMessage" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  -H 'Content-Type: application/json' -d '{"stationId":"CS-001","requestedMessage":"StatusNotification"}'
```

Station operations without OCPP payloads are also routes, for example `POST /v1/stations/{id}/evses/{evseId}/refresh-status` and `POST /v1/stations/{id}/evses/{evseId}/stop-active-session`.

## Examples

Set once: `H=(-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json')` and use `curl -s "${H[@]}" ...` in bash.

List stations (online, with OCPP identity and protocol):

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations?isOnline=true&limit=100" \
  | jq '.total, (.data[] | {id, stationId, ocppProtocol, status})'
```

Station detail and its connectors:

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/sta_abc123def456"
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/sta_abc123def456/connectors"
```

Start a session remotely. OCPP 2.1 needs an `idToken` and a `remoteStartId`. OCPP 1.6 needs an `idTag`:

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v21/RequestStartTransaction" \
  -d '{"stationId":"CS-001","evseId":1,"remoteStartId":1001,"idToken":{"idToken":"RFID-0001","type":"ISO14443"}}'

curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v16/RemoteStartTransaction" \
  -d '{"stationId":"CS-016","connectorId":1,"idTag":"RFID-0001"}'
```

Stop a session. Find the active session and its `transactionId`, then send the stop command for the station's protocol. Or stop whatever runs on an EVSE:

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/sessions?status=active&limit=100" \
  | jq '.data[] | {id, stationName, transactionId, energyDeliveredWh}'

curl -s "${H[@]}" "$EVTIVITY_API/v1/ocpp/commands/v21/RequestStopTransaction" \
  -d '{"stationId":"CS-001","transactionId":"<transactionId>"}'
# OCPP 1.6: /v1/ocpp/commands/v16/RemoteStopTransaction with an integer transactionId

curl -s "${H[@]}" -X POST "$EVTIVITY_API/v1/stations/sta_abc123def456/evses/1/stop-active-session"
```

List sessions (completed, newest first) and one session's meter values:

```bash
curl -s "${H[@]}" "$EVTIVITY_API/v1/sessions?status=completed&page=1&limit=50"
curl -s "${H[@]}" "$EVTIVITY_API/v1/sessions/<sessionId>/meter-values"
```

Set a tariff. Prices are decimal strings in the company currency, `taxRate` a decimal fraction:

```bash
GROUP=$(curl -s "${H[@]}" "$EVTIVITY_API/v1/pricing-groups" -d '{"name":"Public AC"}' | jq -r .id)
curl -s "${H[@]}" "$EVTIVITY_API/v1/pricing-groups/$GROUP/tariffs" \
  -d '{"name":"Standard","pricePerKwh":"0.45","pricePerSession":"1.00","idleFeePricePerMinute":"0.40","taxRate":"0.08","isActive":true,"isDefault":true}'
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/sta_abc123def456/pricing-groups" -d "{\"pricingGroupId\":\"$GROUP\"}"
curl -s "${H[@]}" "$EVTIVITY_API/v1/stations/sta_abc123def456/active-tariff"
```

Generate and download a report. Types: `revenue`, `energy`, `sessions`, `utilization`, `stationHealth`, `sustainability`, `driverActivity`, `nevi`. Formats: `csv`, `pdf`, `xlsx`:

```bash
REPORT=$(curl -s "${H[@]}" "$EVTIVITY_API/v1/reports/generate" \
  -d '{"name":"September revenue","reportType":"revenue","format":"csv","filters":{"dateFrom":"2026-09-01","dateTo":"2026-09-30"}}' | jq -r .id)
curl -s "${H[@]}" "$EVTIVITY_API/v1/reports/$REPORT" | jq -r .status   # pending, generating, completed, failed
curl -s "${H[@]}" -o revenue.csv "$EVTIVITY_API/v1/reports/$REPORT/download"
```

Report filters: `dateFrom`, `dateTo` and `siteId` (most types), `stationId` and `status` (some), `year` and `quarter` (NEVI). Dashboard numbers without a file: `GET /v1/dashboard/stats`, `GET /v1/dashboard/financial-stats`.

## Real-time events

`GET /v1/events/stream` is a server-sent events stream of station, session and status changes for the signed-in operator (`curl -N`). Drivers use `GET /v1/portal/events`.

## When a call fails

1. Read `code` and look it up in `references/error-codes.md`.
2. 401: token missing, expired (sign-in tokens last one hour) or revoked. 403: the key lacks the permission in `references/routes.md`.
3. OCPP command 200 with `response.status: "Rejected"`: the station refused it. 502 or 504: the station sent an error or did not answer. Check that the station is online and its protocol matches `v21` or `v16`. The station's OCPP log is at `GET /v1/stations/{id}/ocpp-logs`.
4. Connection refused or 5xx on every route: the stack is down. Use the `evtivity-troubleshoot` skill.
