# EVtivity API routes: CSS Management

Generated from EVtivity CSMS v0.1.40 (https://github.com/EVtivity/evtivity-csms, commit 571bdc26947f) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/css/stations` | stations:read | List CSS stations |
| POST | `/v1/css/stations` | stations:write | Create a CSS station |
| GET | `/v1/css/stations/{stationId}` | stations:read | Get a CSS station by station ID |
| PATCH | `/v1/css/stations/{stationId}` | stations:write | Update a CSS station |
| DELETE | `/v1/css/stations/{stationId}` | stations:write | Delete a CSS station |
| POST | `/v1/css/stations/{stationId}/enable` | stations:write | Enable a CSS station |
| POST | `/v1/css/stations/{stationId}/disable` | stations:write | Disable a CSS station |
