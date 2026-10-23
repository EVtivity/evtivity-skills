# EVtivity API routes: Portal Auth

Generated from EVtivity CSMS v0.1.48-beta.4 (https://github.com/EVtivity/evtivity-csms, commit 871b5dded1fd) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/portal/auth/attest/challenge` | public | Issue a device-attestation challenge |
| POST | `/v1/portal/auth/attest/register` | public | Register an iOS App Attest key |
| POST | `/v1/portal/auth/register` | public | Register a new driver account |
| POST | `/v1/portal/auth/login` | public | Log in with email and password |
| POST | `/v1/portal/auth/logout` | driver | Log out |
| POST | `/v1/portal/auth/refresh` | public | Refresh the access token |
| GET | `/v1/portal/auth/me` | driver | Get the current authenticated driver profile |
| POST | `/v1/portal/auth/mfa/verify` | public | Verify MFA code and complete portal login |
| POST | `/v1/portal/auth/mfa/resend` | public | Resend MFA verification code |
| POST | `/v1/portal/auth/forgot-password` | public | Request a password reset email for a driver account |
| POST | `/v1/portal/auth/activate` | public | Activate driver portal access from an operator invitation |
| POST | `/v1/portal/auth/reset-password` | public | Reset driver password using a token from the reset email |
| POST | `/v1/portal/auth/verify-email` | public | Verify driver email address using a token from the verification email |
| POST | `/v1/portal/auth/resend-verification` | driver | Resend email verification link |
| POST | `/v1/portal/auth/webauthn/options` | public | Start the passkey or security key MFA step |
| POST | `/v1/portal/auth/webauthn/verify` | public | Complete the MFA step with a passkey or security key |
| POST | `/v1/portal/auth/passkey/options` | public | Start a passkey sign-in |
| POST | `/v1/portal/auth/passkey/verify` | public | Sign in with a passkey |
