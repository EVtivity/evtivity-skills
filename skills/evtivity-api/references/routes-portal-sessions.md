# EVtivity API routes: Portal Sessions

Generated from EVtivity CSMS v0.1.40 (https://github.com/EVtivity/evtivity-csms, commit 571bdc26947f) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/sessions` | driver | List charging sessions for the driver |
| GET | `/v1/portal/sessions/monthly-summary` | driver | Get monthly charging summary |
| GET | `/v1/portal/sessions/monthly-statement` | driver | Get monthly statement with itemized sessions |
| GET | `/v1/portal/sessions/{id}` | driver | Get charging session details with payment info |
| PATCH | `/v1/portal/sessions/{id}/vehicle` | driver | Set or clear the vehicle linked to a session |
| GET | `/v1/portal/sessions/{id}/power-history` | driver | Get power meter value history for a session |
| GET | `/v1/portal/sessions/{id}/energy-history` | driver | Get energy meter value history for a session |
