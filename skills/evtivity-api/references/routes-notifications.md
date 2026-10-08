# EVtivity API routes: Notifications

Generated from EVtivity CSMS v0.1.42-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 627b28b192ed) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/ocpp-event-types` | notifications:read | List all event types |
| GET | `/v1/ocpp-event-template` | notifications:read | Get default OCPP event template |
| GET | `/v1/ocpp-event-settings` | notifications:read | List OCPP event settings |
| PUT | `/v1/ocpp-event-settings` | notifications:write | Create or update an OCPP event setting |
| DELETE | `/v1/ocpp-event-settings` | notifications:write | Delete an OCPP event setting |
| GET | `/v1/notifications` | notifications:read | List notification history |
| POST | `/v1/notifications/test` | notifications:write | Send a test notification |
| GET | `/v1/driver-event-settings` | notifications:read | List driver event settings |
| PUT | `/v1/driver-event-settings` | notifications:write | Turn a driver event type on or off |
| GET | `/v1/notification-templates` | notifications:read | Get a notification template |
| PUT | `/v1/notification-templates` | notifications:write | Create or update a notification template |
| DELETE | `/v1/notification-templates` | notifications:write | Delete a notification template |
| POST | `/v1/notification-templates/preview` | notifications:write | Preview a notification template with sample data |
