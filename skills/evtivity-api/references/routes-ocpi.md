# EVtivity API routes: OCPI

Generated from EVtivity CSMS v0.1.42-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 627b28b192ed) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/ocpi/partners` | roaming:read | List OCPI partners |
| POST | `/v1/ocpi/partners` | roaming:write | Create OCPI partner |
| GET | `/v1/ocpi/partners/{id}` | roaming:read | Get OCPI partner details |
| PATCH | `/v1/ocpi/partners/{id}` | roaming:write | Update OCPI partner |
| DELETE | `/v1/ocpi/partners/{id}` | roaming:write | Disconnect OCPI partner |
| POST | `/v1/ocpi/partners/{id}/register` | roaming:write | Initiate outbound OCPI registration |
| POST | `/v1/ocpi/partners/{id}/sync/{module}` | roaming:write | Trigger manual OCPI module sync |
| GET | `/v1/ocpi/sync-log` | roaming:read | List OCPI sync log entries |
| GET | `/v1/ocpi/locations` | roaming:read | List all sites with OCPI publish status |
| GET | `/v1/ocpi/locations/{siteId}` | roaming:read | Get OCPI publish settings for a site |
| PUT | `/v1/ocpi/locations/{siteId}` | roaming:write | Update OCPI publish settings for a site |
| GET | `/v1/ocpi/sessions` | roaming:read | List OCPI roaming sessions |
| GET | `/v1/ocpi/cdrs` | roaming:read | List OCPI charge detail records |
| POST | `/v1/ocpi/cdrs/credit` | roaming:write | Create a credit CDR |
| GET | `/v1/ocpi/tariff-mappings` | roaming:read | List OCPI tariff mappings |
| POST | `/v1/ocpi/tariff-mappings` | roaming:write | Create OCPI tariff mapping |
| GET | `/v1/ocpi/tariff-mappings/{id}` | roaming:read | Get a single OCPI tariff mapping |
| PATCH | `/v1/ocpi/tariff-mappings/{id}` | roaming:write | Update OCPI tariff mapping |
| DELETE | `/v1/ocpi/tariff-mappings/{id}` | roaming:write | Delete OCPI tariff mapping |
| GET | `/v1/ocpi/partners/{id}/neighbors` | roaming:read | Get previous and next entity IDs in default list order |
