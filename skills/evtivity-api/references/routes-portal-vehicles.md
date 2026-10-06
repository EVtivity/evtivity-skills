# EVtivity API routes: Portal Vehicles

Generated from EVtivity CSMS v0.1.39-beta.1 (https://github.com/EVtivity/evtivity-csms, commit bd06577f1cf1) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/vehicles` | driver | List driver vehicles |
| POST | `/v1/portal/vehicles` | driver | Add a vehicle |
| DELETE | `/v1/portal/vehicles/{id}` | driver | Delete a vehicle |
| GET | `/v1/portal/vehicles/efficiency` | driver | Get vehicle efficiency for miles estimation |
| GET | `/v1/portal/vehicles/lookup` | driver | List known vehicle makes and models for autocomplete |
