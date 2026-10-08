# EVtivity API routes: Portal Guest

Generated from EVtivity CSMS v0.1.42-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 627b28b192ed) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/portal/guest/qr/validate` | public | Validate a dynamic QR code URL |
| POST | `/v1/portal/guest/check-status/{stationId}/{evseId}` | public | Check connector status via TriggerMessage (guest) |
| GET | `/v1/portal/guest/charger-config/{stationId}/{evseId}` | public | Get charger payment configuration for guest charging |
| POST | `/v1/portal/guest/start/{stationId}/{evseId}` | public | Start a guest charging session with payment |
| POST | `/v1/portal/guest/payment-details/{sessionToken}` | public | Continue a guest payment after 3D Secure and start charging |
| GET | `/v1/portal/guest/status/{sessionToken}` | public | Get the status of a guest charging session |
| POST | `/v1/portal/guest/stop/{sessionToken}` | public | Stop a guest charging session |
| GET | `/v1/portal/guest/power-history/{sessionToken}` | public | Get power history for a guest charging session |
| GET | `/v1/portal/guest/energy-history/{sessionToken}` | public | Get energy history for a guest charging session |
