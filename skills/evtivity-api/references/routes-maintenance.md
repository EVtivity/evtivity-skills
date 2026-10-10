# EVtivity API routes: Maintenance

Generated from EVtivity CSMS v0.1.43 (https://github.com/EVtivity/evtivity-csms, commit 94253c800a66) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites/{siteId}/maintenance/events` | maintenance:read | List maintenance events for a site |
| POST | `/v1/sites/{siteId}/maintenance/events` | maintenance:write | Create a maintenance event |
| GET | `/v1/sites/{siteId}/maintenance/events/{id}/stations` | maintenance:read | Per-station fan-out results for a maintenance event |
| GET | `/v1/sites/{siteId}/maintenance/events/{id}` | maintenance:read | Get a maintenance event by ID |
| PATCH | `/v1/sites/{siteId}/maintenance/events/{id}` | maintenance:write | Edit a scheduled or active maintenance event |
| POST | `/v1/sites/{siteId}/maintenance/events/{id}/cancel` | maintenance:write | Cancel a scheduled or active maintenance event |
| POST | `/v1/sites/{siteId}/maintenance/events/{id}/add-stations` | maintenance:write | Add one or more stations to a scheduled or active event |
| POST | `/v1/sites/{siteId}/maintenance/events/{id}/remove-stations` | maintenance:write | Remove one or more stations from a scheduled or active event |
| GET | `/v1/sites/{siteId}/maintenance/status` | maintenance:read | Current and upcoming maintenance for a site |
| GET | `/v1/sites/{siteId}/maintenance/station-preview` | maintenance:read | Preview station impact for a proposed maintenance window |
| POST | `/v1/maintenance/preview-message` | maintenance:read | Render the maintenance display message with sample variables |
