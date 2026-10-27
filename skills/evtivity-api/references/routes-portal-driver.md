# EVtivity API routes: Portal Driver

Generated from EVtivity CSMS v0.1.48 (https://github.com/EVtivity/evtivity-csms, commit f06d1a2dc215) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| PATCH | `/v1/portal/driver/profile` | driver | Update the authenticated driver profile |
| POST | `/v1/portal/driver/phone-verification` | driver | Send a code to confirm a new phone number |
| PATCH | `/v1/portal/driver/billing-address` | driver | Update the authenticated driver billing address |
| PATCH | `/v1/portal/driver/password` | driver | Change the authenticated driver password |
| GET | `/v1/portal/driver/notification-preferences` | driver | Get driver notification preferences |
| PUT | `/v1/portal/driver/notification-preferences` | driver | Update driver notification preferences |
| GET | `/v1/portal/driver/mfa` | driver | Get current MFA status |
| DELETE | `/v1/portal/driver/mfa` | driver | Disable MFA |
| POST | `/v1/portal/driver/mfa/setup` | driver | Start MFA setup |
| POST | `/v1/portal/driver/mfa/confirm` | driver | Confirm MFA setup with verification code |
| POST | `/v1/portal/driver/mfa/recovery-codes` | driver | Replace the MFA recovery codes |
| POST | `/v1/portal/driver/webauthn/registration-options` | driver | Start registering a passkey or security key |
| POST | `/v1/portal/driver/webauthn/registration` | driver | Register a passkey or security key |
| GET | `/v1/portal/driver/webauthn` | driver | List my passkeys and security keys |
| PATCH | `/v1/portal/driver/webauthn/{id}` | driver | Rename a passkey or security key |
| DELETE | `/v1/portal/driver/webauthn/{id}` | driver | Remove a passkey or security key |
| POST | `/v1/portal/driver/mfa/recovery-codes/webauthn-options` | driver | Start the passkey proof for new recovery codes |
| POST | `/v1/portal/driver/mfa/factor-proof` | driver | Prepare the proof for adding an MFA factor |
| GET | `/v1/portal/driver/avatar` | driver | Get the driver avatar |
| PUT | `/v1/portal/driver/avatar` | driver | Set a generated avatar |
| DELETE | `/v1/portal/driver/avatar` | driver | Remove the driver avatar |
| POST | `/v1/portal/driver/avatar/upload-url` | driver | Get a presigned upload for an avatar image |
| POST | `/v1/portal/driver/avatar/image` | driver | Confirm an uploaded avatar image |
| GET | `/v1/portal/favorites` | driver | List favorite stations |
| POST | `/v1/portal/favorites` | driver | Add a station to favorites |
| GET | `/v1/portal/favorites/check/{stationId}` | driver | Check if a station is favorited |
| DELETE | `/v1/portal/favorites/{id}` | driver | Remove a station from favorites |
| GET | `/v1/portal/station-watches` | driver | List watched stations |
| POST | `/v1/portal/station-watches` | driver | Start watching a station for availability |
| GET | `/v1/portal/station-watches/check/{stationId}` | driver | Check if a station is being watched |
| DELETE | `/v1/portal/station-watches/{id}` | driver | Stop watching a station |
