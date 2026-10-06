# EVtivity API routes: Reservations

Generated from EVtivity CSMS v0.1.39 (https://github.com/EVtivity/evtivity-csms, commit 85333dc7da57) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/reservations` | reservations:read | List all reservations |
| POST | `/v1/reservations` | reservations:write | Create a reservation and send ReserveNow to station |
| GET | `/v1/reservations/{id}` | reservations:read | Get a single reservation by ID |
| PATCH | `/v1/reservations/{id}` | reservations:write | Update an active reservation |
| DELETE | `/v1/reservations/{id}` | reservations:write | Cancel an active reservation |
| GET | `/v1/reservations/{id}/audit` | reservations:read | List audit log entries for a reservation |
| GET | `/v1/reservations/{id}/commands` | reservations:read | List OCPP commands for a reservation |
| POST | `/v1/reservations/{id}/reassign` | reservations:write | Move an active reservation to a different station |
| GET | `/v1/reservations/{id}/neighbors` | reservations:read | Get previous and next entity IDs in default list order |
