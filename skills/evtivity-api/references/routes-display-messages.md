# EVtivity API routes: Display Messages

Generated from EVtivity CSMS v0.1.39 (https://github.com/EVtivity/evtivity-csms, commit 85333dc7da57) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/stations/{stationId}/display-messages` | stations:read | List display messages for a station |
| POST | `/v1/stations/{stationId}/display-messages` | stations:write | Create and send a display message to a station |
| DELETE | `/v1/stations/{stationId}/display-messages/{id}` | stations:write | Clear a display message from a station |
| POST | `/v1/stations/{stationId}/display-messages/refresh` | stations:write | Refresh display messages from a station |
