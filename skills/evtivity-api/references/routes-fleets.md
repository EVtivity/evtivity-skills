# EVtivity API routes: Fleets

Generated from EVtivity CSMS v0.1.41 (https://github.com/EVtivity/evtivity-csms, commit 1e95549f016a) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/fleets` | fleets:read | List fleets |
| POST | `/v1/fleets` | fleets:write | Create a fleet |
| GET | `/v1/fleets/{id}` | fleets:read | Get a fleet by ID |
| PATCH | `/v1/fleets/{id}` | fleets:write | Update a fleet |
| DELETE | `/v1/fleets/{id}` | fleets:write | Delete a fleet |
| PATCH | `/v1/fleets/{id}/billing` | fleets:write | Turn charge on account on or off for a fleet |
| PATCH | `/v1/fleets/{id}/billing-profile` | fleets:write | Update the fleet billing profile |
| GET | `/v1/fleets/{id}/credit-limit` | fleets:read | Get a fleet's credit limit and exposure |
| PATCH | `/v1/fleets/{id}/credit-limit` | fleets:write | Set a fleet's credit limit |
| GET | `/v1/fleets/{id}/drivers` | fleets:read | List drivers in a fleet |
| POST | `/v1/fleets/{id}/drivers` | fleets:write | Add a driver to a fleet |
| PATCH | `/v1/fleets/{id}/drivers/{driverId}` | fleets:write | Set a member's opt-out of charge on account |
| DELETE | `/v1/fleets/{id}/drivers/{driverId}` | fleets:write | Remove a driver from a fleet |
| GET | `/v1/fleets/{id}/stations` | fleets:read | List stations in a fleet |
| POST | `/v1/fleets/{id}/stations` | fleets:write | Add a station to a fleet |
| DELETE | `/v1/fleets/{id}/stations/{stationId}` | fleets:write | Remove a station from a fleet |
| GET | `/v1/fleets/{id}/vehicles` | fleets:read | List vehicles in a fleet |
| GET | `/v1/fleets/{id}/vehicles/available` | fleets:read | Search vehicles not in fleet |
| GET | `/v1/fleets/{id}/sessions` | fleets:read | List charging sessions for a fleet |
| GET | `/v1/fleets/{id}/metrics` | fleets:read | Get fleet metrics |
| GET | `/v1/fleets/{id}/energy-history` | fleets:read | Get fleet energy delivery history |
| GET | `/v1/fleets/{id}/pricing-groups` | fleets:read | Get the pricing group for a fleet |
| POST | `/v1/fleets/{id}/pricing-groups` | fleets:write | Add a pricing group to a fleet |
| DELETE | `/v1/fleets/{id}/pricing-groups/{pricingGroupId}` | fleets:write | Remove a pricing group from a fleet |
| GET | `/v1/fleets/{id}/billing/unbilled` | payments:read | Preview the fleet invoice of a period |
| GET | `/v1/fleets/{id}/invoices` | payments:read | List a fleet's invoices and credit notes |
| POST | `/v1/fleets/{id}/invoices` | payments:write | Generate the fleet invoice of a period |
| GET | `/v1/fleets/{fleetId}/reservations` | reservations:read | List fleet reservations |
| POST | `/v1/fleets/{fleetId}/reservations` | reservations:write | Create bulk reservations for a fleet |
| DELETE | `/v1/fleet-reservations/{id}` | reservations:write | Cancel all reservations in a fleet reservation |
| GET | `/v1/fleets/{id}/neighbors` | fleets:read | Get previous and next entity IDs in default list order |
