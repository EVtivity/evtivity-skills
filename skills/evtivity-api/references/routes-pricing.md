# EVtivity API routes: Pricing

Generated from EVtivity CSMS v0.1.42-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 627b28b192ed) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/pricing-groups` | pricing:read | List all pricing groups |
| POST | `/v1/pricing-groups` | pricing:write | Create a pricing group |
| GET | `/v1/pricing-groups/{id}` | pricing:read | Get a pricing group by ID |
| PATCH | `/v1/pricing-groups/{id}` | pricing:write | Update a pricing group |
| DELETE | `/v1/pricing-groups/{id}` | pricing:write | Delete a pricing group and its tariffs |
| GET | `/v1/pricing/tariffs` | pricing:read | List all tariffs across every pricing group |
| GET | `/v1/pricing-groups/{id}/tariffs` | pricing:read | List tariffs in a pricing group |
| POST | `/v1/pricing-groups/{id}/tariffs` | pricing:write | Create a tariff in a pricing group |
| GET | `/v1/pricing-groups/{id}/tariffs/{tariffId}` | pricing:read | Get a single tariff |
| PATCH | `/v1/pricing-groups/{id}/tariffs/{tariffId}` | pricing:write | Update a tariff |
| DELETE | `/v1/pricing-groups/{id}/tariffs/{tariffId}` | pricing:write | Delete a tariff from a pricing group |
| GET | `/v1/pricing-groups/{id}/schedule` | pricing:read | Get tariff schedule for a pricing group |
| GET | `/v1/stations/{id}/active-tariff` | pricing:read | Get the currently active tariff for a station |
| GET | `/v1/pricing-audit` | pricing:read | List pricing audit log entries |
| GET | `/v1/pricing-holidays` | pricing:read | List all pricing holidays |
| POST | `/v1/pricing-holidays` | pricing:write | Create a pricing holiday |
| DELETE | `/v1/pricing-holidays/{id}` | pricing:write | Delete a pricing holiday |
| POST | `/v1/pricing-holidays/bulk` | pricing:write | Bulk create pricing holidays |
| GET | `/v1/pricing-groups/{id}/neighbors` | pricing:read | Get previous and next entity IDs in default list order |
