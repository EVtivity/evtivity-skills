# EVtivity API routes: Load Management

Generated from EVtivity CSMS v0.1.39-beta.2 (https://github.com/EVtivity/evtivity-csms, commit f3bd9ac5d1e8) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites/{id}/load-management` | loadManagement:read | Get load management config, hierarchy, and station status for a site |
| PUT | `/v1/sites/{id}/load-management` | loadManagement:write | Create or update load management config for a site |
| PATCH | `/v1/sites/{id}/stations/{stationId}/load-priority` | loadManagement:write | Update load priority for a station |
| GET | `/v1/sites/{id}/load-management/history` | loadManagement:read | Get load allocation history for a site |
| GET | `/v1/sites/{siteId}/panels` | loadManagement:read | List panels for a site |
| POST | `/v1/sites/{siteId}/panels` | loadManagement:write | Create a panel |
| GET | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:read | Get panel detail |
| PATCH | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:write | Update a panel |
| DELETE | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:write | Delete a panel |
| GET | `/v1/sites/{siteId}/panels/{panelId}/circuits` | loadManagement:read | List circuits for a panel |
| POST | `/v1/sites/{siteId}/panels/{panelId}/circuits` | loadManagement:write | Create a circuit on a panel |
| PATCH | `/v1/sites/{siteId}/panels/{panelId}/circuits/{circuitId}` | loadManagement:write | Update a circuit |
| DELETE | `/v1/sites/{siteId}/panels/{panelId}/circuits/{circuitId}` | loadManagement:write | Delete a circuit |
| PATCH | `/v1/sites/{siteId}/stations/{stationId}/circuit` | loadManagement:write | Assign or unassign a station to a circuit |
| GET | `/v1/sites/{siteId}/unmanaged-loads` | loadManagement:read | List unmanaged loads for a site |
| POST | `/v1/sites/{siteId}/unmanaged-loads` | loadManagement:write | Create an unmanaged load |
| PATCH | `/v1/sites/{siteId}/unmanaged-loads/{id}` | loadManagement:write | Update an unmanaged load |
| DELETE | `/v1/sites/{siteId}/unmanaged-loads/{id}` | loadManagement:write | Delete an unmanaged load |
