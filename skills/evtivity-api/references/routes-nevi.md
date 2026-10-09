# EVtivity API routes: NEVI

Generated from EVtivity CSMS v0.1.42-beta.6 (https://github.com/EVtivity/evtivity-csms, commit 83073ffb3163) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/nevi/station-data` | reports:read | List NEVI station data for all stations |
| PUT | `/v1/nevi/station-data/{stationId}` | reports:write | Create or update NEVI data for a station |
| GET | `/v1/nevi/excluded-downtime` | reports:read | List excluded downtime records |
| POST | `/v1/nevi/excluded-downtime` | reports:write | Create an excluded downtime record |
| PATCH | `/v1/nevi/excluded-downtime/{id}` | reports:write | Update an excluded downtime record |
| DELETE | `/v1/nevi/excluded-downtime/{id}` | reports:write | Delete an excluded downtime record |
