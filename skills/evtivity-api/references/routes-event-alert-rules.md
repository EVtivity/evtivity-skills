# EVtivity API routes: Event Alert Rules

Generated from EVtivity CSMS v0.1.42-beta.6 (https://github.com/EVtivity/evtivity-csms, commit 83073ffb3163) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/event-alert-rules` | stations:read | List event alert rules |
| POST | `/v1/event-alert-rules` | stations:write | Create event alert rule |
| PATCH | `/v1/event-alert-rules/{id}` | stations:write | Update event alert rule |
| DELETE | `/v1/event-alert-rules/{id}` | stations:write | Delete event alert rule |
