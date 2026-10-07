# EVtivity API routes: Tokens

Generated from EVtivity CSMS v0.1.40 (https://github.com/EVtivity/evtivity-csms, commit 571bdc26947f) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/tokens/filter-options` | drivers:read | Get distinct token types for filtering |
| GET | `/v1/tokens` | drivers:read | List all tokens with pagination |
| POST | `/v1/tokens` | drivers:write | Create a new token |
| GET | `/v1/tokens/export` | drivers:read | Export tokens as CSV |
| POST | `/v1/tokens/import` | drivers:write | Import tokens from parsed CSV rows |
| POST | `/v1/tokens/bulk-active` | drivers:write | Bulk activate or deactivate tokens |
| GET | `/v1/tokens/{id}/sessions` | drivers:read | List charging sessions authorized by this token |
| GET | `/v1/tokens/{id}` | drivers:read | Get a token by ID |
| PATCH | `/v1/tokens/{id}` | drivers:write | Update a token by ID |
| DELETE | `/v1/tokens/{id}` | drivers:write | Delete a token by ID |
| GET | `/v1/authorize-attempts` | drivers:read | List Authorize attempts (success and failure) for forensic triage |
| GET | `/v1/tokens/{id}/neighbors` | drivers:read | Get previous and next entity IDs in default list order |
