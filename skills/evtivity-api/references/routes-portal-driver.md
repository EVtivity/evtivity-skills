# EVtivity API routes: Portal Driver

Generated from EVtivity CSMS v0.1.41 (https://github.com/EVtivity/evtivity-csms, commit 1e95549f016a) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| PATCH | `/v1/portal/driver/profile` | driver | Update the authenticated driver profile |
| PATCH | `/v1/portal/driver/password` | driver | Change the authenticated driver password |
| GET | `/v1/portal/driver/notification-preferences` | driver | Get driver notification preferences |
| PUT | `/v1/portal/driver/notification-preferences` | driver | Update driver notification preferences |
| GET | `/v1/portal/driver/mfa` | driver | Get current MFA status |
| DELETE | `/v1/portal/driver/mfa` | driver | Disable MFA |
| POST | `/v1/portal/driver/mfa/setup` | driver | Start MFA setup |
| POST | `/v1/portal/driver/mfa/confirm` | driver | Confirm MFA setup with verification code |
| GET | `/v1/portal/favorites` | driver | List favorite stations |
| POST | `/v1/portal/favorites` | driver | Add a station to favorites |
| GET | `/v1/portal/favorites/check/{stationId}` | driver | Check if a station is favorited |
| DELETE | `/v1/portal/favorites/{id}` | driver | Remove a station from favorites |
| GET | `/v1/portal/station-watches` | driver | List watched stations |
| POST | `/v1/portal/station-watches` | driver | Start watching a station for availability |
| GET | `/v1/portal/station-watches/check/{stationId}` | driver | Check if a station is being watched |
| DELETE | `/v1/portal/station-watches/{id}` | driver | Stop watching a station |
