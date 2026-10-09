# EVtivity API routes: Portal Chargers

Generated from EVtivity CSMS v0.1.42 (https://github.com/EVtivity/evtivity-csms, commit a4268227cc43) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/chargers/{stationId}/evse/{evseId}` | public | Get charger and EVSE details |
| GET | `/v1/portal/chargers/{stationId}/pricing` | driver | Get resolved pricing for a charger |
| GET | `/v1/portal/chargers/search` | public | Search chargers by station ID, site name, or address |
| GET | `/v1/portal/chargers/nearby` | public | List nearby chargers by coordinates |
| GET | `/v1/portal/chargers/map-config` | public | Get Google Maps configuration |
| GET | `/v1/portal/chargers/location/{siteId}` | public | Get location detail for a site |
| GET | `/v1/portal/chargers/location/{siteId}/images` | public | Get driver-visible images for a site |
| GET | `/v1/portal/chargers/location/{siteId}/images/{imageId}/download-url` | public | Get presigned download URL for a driver-visible image |
| GET | `/v1/portal/chargers/location/{siteId}/popular-times` | public | Get popular times for a site |
| GET | `/v1/portal/chargers/{stationId}` | public | Get station details with all EVSEs and connectors |
| POST | `/v1/portal/chargers/{stationId}/evse/{evseId}/check-status` | driver | Check connector status via TriggerMessage |
| POST | `/v1/portal/chargers/{stationId}/evse/{evseId}/start` | driver | Start a charging session on a charger EVSE |
| GET | `/v1/portal/chargers/sessions/active` | driver | List active charging sessions for the driver |
| POST | `/v1/portal/chargers/sessions/{sessionId}/stop` | driver | Stop an active charging session |
| GET | `/v1/portal/reservations` | driver | List reservations for the driver |
| POST | `/v1/portal/reservations` | driver | Create a reservation on a station |
| GET | `/v1/portal/reservations/{id}` | driver | Get a reservation by id with linked session for used reservations |
| DELETE | `/v1/portal/reservations/{id}` | driver | Cancel a reservation |
| GET | `/v1/portal/chargers/{stationId}/events` | public | Subscribe to real-time station status events |
