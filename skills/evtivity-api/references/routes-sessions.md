# EVtivity API routes: Sessions

Generated from EVtivity CSMS v0.1.48 (https://github.com/EVtivity/evtivity-csms, commit f06d1a2dc215) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sessions` | sessions:read | List charging sessions |
| GET | `/v1/sessions/{id}` | sessions:read | Get charging session details |
| POST | `/v1/sessions/{id}/vehicle-claim` | drivers:write | Store the session's captured vehicle id on a vehicle of the session's driver |
| GET | `/v1/sessions/{id}/transaction-events` | sessions:read | List transaction events for a charging session |
| GET | `/v1/sessions/{id}/meter-values` | sessions:read | List meter values for a charging session |
| POST | `/v1/sessions/{id}/end` | sessions:write | End an active session of an offline station without the station |
| POST | `/v1/sessions/{id}/rebill` | sessions:write | Bill a session the CSMS could not end |
| PATCH | `/v1/sessions/{id}/billing-recipient` | payments:write | Move a session between the fleet invoice and the member's invoice |
| GET | `/v1/sessions/{id}/neighbors` | sessions:read | Get previous and next entity IDs in default list order |
