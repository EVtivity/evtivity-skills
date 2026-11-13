# EVtivity API routes: Load Management

Generated from EVtivity CSMS v0.1.52-beta.5 (https://github.com/EVtivity/evtivity-csms, commit 0533047444fd) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites/{id}/load-management` | loadManagement:read | Get load management config, hierarchy, and station status for a site |
| PUT | `/v1/sites/{id}/load-management` | loadManagement:write | Create or update load management config for a site |
| GET | `/v1/sites/{id}/charging-plan` | loadManagement:read | Get the depot charging plan of a site |
| POST | `/v1/sites/{id}/charging-plan/recalculate` | loadManagement:write | Recalculate the depot charging plan of a site |
| PATCH | `/v1/sites/{id}/stations/{stationId}/load-priority` | loadManagement:write | Update load priority for a station |
| PATCH | `/v1/sites/{id}/stations/{stationId}/load-min-power` | loadManagement:write | Update the minimum power of a station under load management |
| GET | `/v1/sites/{id}/load-management/history` | loadManagement:read | Get load allocation history for a site |
| GET | `/v1/sites/{siteId}/panels` | loadManagement:read | List panels for a site |
| POST | `/v1/sites/{siteId}/panels` | loadManagement:write | Create a panel |
| GET | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:read | Get panel detail |
| PATCH | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:write | Update a panel |
| DELETE | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:write | Delete a panel |
| GET | `/v1/sites/{siteId}/transformers` | loadManagement:read | List the transformers of a site |
| POST | `/v1/sites/{siteId}/transformers` | loadManagement:write | Create a transformer |
| PATCH | `/v1/sites/{siteId}/transformers/{transformerId}` | loadManagement:write | Update a transformer |
| DELETE | `/v1/sites/{siteId}/transformers/{transformerId}` | loadManagement:write | Delete a transformer |
| GET | `/v1/sites/{siteId}/energy-assets` | loadManagement:read | List the batteries and solar arrays of a site |
| POST | `/v1/sites/{siteId}/energy-assets` | loadManagement:write | Create a battery or solar array |
| PATCH | `/v1/sites/{siteId}/energy-assets/{assetId}` | loadManagement:write | Update a battery or solar array |
| DELETE | `/v1/sites/{siteId}/energy-assets/{assetId}` | loadManagement:write | Delete a battery or solar array |
| PUT | `/v1/sites/{siteId}/energy-assets/{assetId}/reading` | loadManagement:write | Report the latest reading of a battery or solar array |
| GET | `/v1/sites/{siteId}/panels/{panelId}/circuits` | loadManagement:read | List circuits for a panel |
| POST | `/v1/sites/{siteId}/panels/{panelId}/circuits` | loadManagement:write | Create a circuit on a panel |
| PATCH | `/v1/sites/{siteId}/panels/{panelId}/circuits/{circuitId}` | loadManagement:write | Update a circuit |
| DELETE | `/v1/sites/{siteId}/panels/{panelId}/circuits/{circuitId}` | loadManagement:write | Delete a circuit |
| PATCH | `/v1/sites/{siteId}/stations/{stationId}/circuit` | loadManagement:write | Assign or unassign a station to a circuit |
| GET | `/v1/sites/{siteId}/unmanaged-loads` | loadManagement:read | List unmanaged loads for a site |
| POST | `/v1/sites/{siteId}/unmanaged-loads` | loadManagement:write | Create an unmanaged load |
| PATCH | `/v1/sites/{siteId}/unmanaged-loads/{id}` | loadManagement:write | Update an unmanaged load |
| DELETE | `/v1/sites/{siteId}/unmanaged-loads/{id}` | loadManagement:write | Delete an unmanaged load |
