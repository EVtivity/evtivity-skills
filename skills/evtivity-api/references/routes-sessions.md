# EVtivity API routes: Sessions

Generated from EVtivity CSMS v0.1.39-beta.2 (https://github.com/EVtivity/evtivity-csms, commit f3bd9ac5d1e8) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sessions` | sessions:read | List charging sessions |
| GET | `/v1/sessions/{id}` | sessions:read | Get charging session details |
| GET | `/v1/sessions/{id}/transaction-events` | sessions:read | List transaction events for a charging session |
| GET | `/v1/sessions/{id}/meter-values` | sessions:read | List meter values for a charging session |
| GET | `/v1/sessions/{id}/neighbors` | sessions:read | Get previous and next entity IDs in default list order |
