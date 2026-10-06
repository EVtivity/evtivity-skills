# EVtivity API routes: Portal Notifications

Generated from EVtivity CSMS v0.1.39-beta.2 (https://github.com/EVtivity/evtivity-csms, commit f3bd9ac5d1e8) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/notifications` | driver | List notification history for the driver |
| GET | `/v1/portal/notifications/unread-count` | driver | Get unread notification count |
| POST | `/v1/portal/notifications/mark-read` | driver | Mark all notifications as read |
| POST | `/v1/portal/notifications/push-token` | driver | Register or refresh a native push token |
| DELETE | `/v1/portal/notifications/push-token` | driver | Unregister a native push token |
