# EVtivity API routes: Sites

Generated from EVtivity CSMS v0.1.39-beta.2 (https://github.com/EVtivity/evtivity-csms, commit f3bd9ac5d1e8) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites` | sites:read | List all sites |
| POST | `/v1/sites` | sites:write | Create a new site |
| GET | `/v1/sites/filter-options` | sites:read | Get distinct filter values for sites |
| GET | `/v1/sites/export` | sites:read | Export sites as CSV |
| GET | `/v1/sites/export/template` | sites:read | Download site import CSV template |
| POST | `/v1/sites/import` | sites:write | Import sites from parsed CSV rows |
| GET | `/v1/sites/{id}` | sites:read | Get a site by ID |
| PATCH | `/v1/sites/{id}` | sites:write | Update a site |
| DELETE | `/v1/sites/{id}` | sites:write | Delete a site |
| GET | `/v1/sites/{id}/metrics` | sites:read | Get performance metrics for a site |
| GET | `/v1/sites/{id}/stations` | sites:read | List stations at a site |
| GET | `/v1/sites/{id}/energy-history` | sites:read | Get daily energy delivery history for a site |
| GET | `/v1/sites/{id}/revenue-history` | sites:read | Get daily revenue history for a site |
| GET | `/v1/sites/{id}/popular-times` | sites:read | Get average session count by day-of-week and hour for a site |
| GET | `/v1/sites/{id}/meter-values` | sites:read | Get meter value time series for a site |
| GET | `/v1/sites/{id}/sessions` | sites:read | List charging sessions at a site |
| GET | `/v1/sites/{id}/layout` | sites:read | Get station layout positions for a site |
| PUT | `/v1/sites/{id}/layout` | sites:write | Update station layout positions for a site |
| GET | `/v1/sites/{id}/pricing-groups` | sites:read | Get the pricing group for a site |
| POST | `/v1/sites/{id}/pricing-groups` | sites:write | Assign a pricing group to a site |
| DELETE | `/v1/sites/{id}/pricing-groups/{pricingGroupId}` | sites:write | Remove a pricing group from a site |
| POST | `/v1/sites/{id}/free-vend` | sites:write | Toggle free vend mode for a site |
| GET | `/v1/sites/{id}/carbon-region` | sites:read | Get carbon region for a site |
| PUT | `/v1/sites/{id}/carbon-region` | sites:write | Set carbon region for a site |
| GET | `/v1/sites/{id}/electricity-rates` | sites:read | List electricity rate periods for a site |
| POST | `/v1/sites/{id}/electricity-rates` | sites:write | Create an electricity rate period for a site |
| PATCH | `/v1/sites/{id}/electricity-rates/{periodId}` | sites:write | Update an electricity rate period |
| DELETE | `/v1/sites/{id}/electricity-rates/{periodId}` | sites:write | Delete an electricity rate period |
| GET | `/v1/sites/{id}/neighbors` | sites:read | Get previous and next entity IDs in default list order |
