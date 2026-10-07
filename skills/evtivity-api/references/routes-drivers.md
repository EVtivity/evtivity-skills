# EVtivity API routes: Drivers

Generated from EVtivity CSMS v0.1.40 (https://github.com/EVtivity/evtivity-csms, commit 571bdc26947f) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/drivers` | drivers:read | List all drivers with pagination |
| POST | `/v1/drivers` | drivers:write | Create a new driver |
| GET | `/v1/drivers/{id}` | drivers:read | Get a driver by ID |
| PATCH | `/v1/drivers/{id}` | drivers:write | Update a driver by ID |
| DELETE | `/v1/drivers/{id}` | drivers:write | Deactivate a driver by ID |
| POST | `/v1/drivers/{id}/portal-invite` | drivers:write | Invite a driver to the driver portal |
| GET | `/v1/drivers/{id}/tokens` | drivers:read | List tokens for a driver |
| POST | `/v1/drivers/{id}/tokens` | drivers:write | Create a token for a driver |
| GET | `/v1/drivers/{id}/vehicles` | drivers:read | List vehicles for a driver |
| POST | `/v1/drivers/{id}/vehicles` | drivers:write | Create a vehicle for a driver |
| GET | `/v1/drivers/{id}/vehicles/{vehicleId}` | drivers:read | Get a single vehicle for a driver |
| PATCH | `/v1/drivers/{id}/vehicles/{vehicleId}` | drivers:write | Update a vehicle |
| DELETE | `/v1/drivers/{id}/vehicles/{vehicleId}` | drivers:write | Delete a vehicle |
| GET | `/v1/vehicles/lookup` | drivers:read | List known vehicle makes and models for autocomplete |
| GET | `/v1/drivers/{id}/sessions` | drivers:read | List charging sessions for a driver |
| GET | `/v1/drivers/{id}/reservations` | drivers:read | List reservations for a driver, with cancel metadata |
| GET | `/v1/drivers/{id}/pricing-groups` | drivers:read | Get the pricing group for a driver |
| POST | `/v1/drivers/{id}/pricing-groups` | drivers:write | Assign a pricing group to a driver |
| DELETE | `/v1/drivers/{id}/pricing-groups/{pricingGroupId}` | drivers:write | Remove a pricing group from a driver |
| GET | `/v1/drivers/{id}/pnc-contracts` | drivers:read | List the Plug and Charge contracts of a driver |
| POST | `/v1/drivers/{id}/pnc-contracts` | drivers:write | Create a Plug and Charge contract for a driver |
| POST | `/v1/drivers/{id}/pnc-contracts/{contractId}/revoke` | drivers:write | Revoke a Plug and Charge contract |
| GET | `/v1/drivers/{id}/neighbors` | drivers:read | Get previous and next entity IDs in default list order |
