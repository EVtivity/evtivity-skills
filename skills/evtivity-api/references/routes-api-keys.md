# EVtivity API routes: API Keys

Generated from EVtivity CSMS v0.1.41-alpha.3 (https://github.com/EVtivity/evtivity-csms, commit 83e6334e0f0d) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/api-keys` | settings.apiKeys:read | List active API keys for the current user |
| POST | `/v1/api-keys` | settings.apiKeys:write | Create a new API key |
| PATCH | `/v1/api-keys/{id}` | settings.apiKeys:write | Update API key permissions |
| DELETE | `/v1/api-keys/{id}` | settings.apiKeys:write | Revoke an API key |
