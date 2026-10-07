# EVtivity API routes: Fleet Operations

Generated from EVtivity CSMS v0.1.41-alpha.3 (https://github.com/EVtivity/evtivity-csms, commit 83e6334e0f0d) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/firmware-campaigns/filter-options` | settings.firmware:read | Get filter options for firmware campaign targeting |
| GET | `/v1/firmware-campaigns` | settings.firmware:read | List firmware campaigns |
| POST | `/v1/firmware-campaigns` | settings.firmware:write | Create a firmware campaign |
| GET | `/v1/firmware-campaigns/{id}` | settings.firmware:read | Get firmware campaign with station progress |
| PATCH | `/v1/firmware-campaigns/{id}` | settings.firmware:write | Update a draft firmware campaign |
| DELETE | `/v1/firmware-campaigns/{id}` | settings.firmware:write | Delete a draft firmware campaign |
| GET | `/v1/firmware-campaigns/{id}/matching-stations` | settings.firmware:read | Preview stations matching the campaign target filter |
| POST | `/v1/firmware-campaigns/{id}/start` | settings.firmware:write | Start a firmware campaign - dispatch UpdateFirmware to targets |
| POST | `/v1/firmware-campaigns/{id}/cancel` | settings.firmware:write | Cancel an active firmware campaign |
| GET | `/v1/config-templates/filter-options` | settings.stationConfig:read | Get filter options for config template targeting |
| GET | `/v1/config-templates` | settings.stationConfig:read | List configuration templates |
| POST | `/v1/config-templates` | settings.stationConfig:write | Create a configuration template |
| GET | `/v1/config-templates/{id}` | settings.stationConfig:read | Get configuration template |
| PATCH | `/v1/config-templates/{id}` | settings.stationConfig:write | Update a configuration template |
| DELETE | `/v1/config-templates/{id}` | settings.stationConfig:write | Delete a configuration template |
| POST | `/v1/config-templates/{id}/duplicate` | settings.stationConfig:write | Duplicate a configuration template |
| GET | `/v1/config-templates/{id}/matching-stations` | settings.stationConfig:read | Preview stations matching the template target filter |
| POST | `/v1/config-templates/{id}/push` | settings.stationConfig:write | Push configuration template variables to matching stations via SetVariables |
| GET | `/v1/config-templates/{id}/pushes` | settings.stationConfig:read | List push history for a configuration template |
| GET | `/v1/config-template-pushes/{pushId}` | settings.stationConfig:read | Get config template push detail with per-station results |
| GET | `/v1/stations/{id}/config-drift` | settings.stationConfig:read | Compare station variables against matching config templates |
