# EVtivity API routes: Smart Charging

Generated from EVtivity CSMS v0.1.42-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 627b28b192ed) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/smart-charging/filter-options` | smartCharging:read | Get filter options for smart charging template targeting |
| GET | `/v1/smart-charging/templates` | smartCharging:read | List charging profile templates |
| POST | `/v1/smart-charging/templates` | smartCharging:write | Create a charging profile template |
| GET | `/v1/smart-charging/templates/{id}` | smartCharging:read | Get charging profile template |
| PATCH | `/v1/smart-charging/templates/{id}` | smartCharging:write | Update a charging profile template |
| DELETE | `/v1/smart-charging/templates/{id}` | smartCharging:write | Delete a charging profile template |
| POST | `/v1/smart-charging/templates/{id}/duplicate` | smartCharging:write | Duplicate a charging profile template |
| GET | `/v1/smart-charging/templates/{id}/matching-stations` | smartCharging:read | Preview stations matching the template target filter |
| POST | `/v1/smart-charging/templates/{id}/push` | smartCharging:write | Push charging profile template to matching stations via SetChargingProfile |
| POST | `/v1/smart-charging/templates/{id}/clear` | smartCharging:write | Clear charging profile from all matching stations |
| GET | `/v1/smart-charging/templates/{id}/pushes` | smartCharging:read | List push history for a charging profile template |
| GET | `/v1/smart-charging/pushes/{pushId}` | smartCharging:read | Get charging profile push detail with per-station results |
