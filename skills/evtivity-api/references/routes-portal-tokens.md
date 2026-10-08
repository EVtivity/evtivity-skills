# EVtivity API routes: Portal Tokens

Generated from EVtivity CSMS v0.1.41 (https://github.com/EVtivity/evtivity-csms, commit 1e95549f016a) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/tokens` | driver | List driver RFID tokens |
| POST | `/v1/portal/tokens` | driver | Add RFID card |
| PATCH | `/v1/portal/tokens/{id}` | driver | Toggle RFID token active status |
| DELETE | `/v1/portal/tokens/{id}` | driver | Deactivate (soft-delete) an RFID card |
