# EVtivity API routes: Portal Auth

Generated from EVtivity CSMS v0.1.42 (https://github.com/EVtivity/evtivity-csms, commit a4268227cc43) by `scripts/generate-api-reference.py`. Do not edit by hand.
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
