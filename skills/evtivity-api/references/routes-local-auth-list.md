# EVtivity API routes: Local Auth List

Generated from EVtivity CSMS v0.1.41-alpha.6 (https://github.com/EVtivity/evtivity-csms, commit d149789379d5) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/stations/{stationId}/local-auth-list` | stations:read | List local auth list entries and version info |
| GET | `/v1/stations/{stationId}/local-auth-list/available-tokens` | stations:read | List active driver tokens not on this station local auth list |
| POST | `/v1/stations/{stationId}/local-auth-list/push` | stations:write | Push tracked entries to station via OCPP SendLocalList Full |
| POST | `/v1/stations/{stationId}/local-auth-list/add` | stations:write | Add tokens to station local auth list (DB-only) |
| POST | `/v1/stations/{stationId}/local-auth-list/remove` | stations:write | Remove entries from station local auth list (DB-only) |
