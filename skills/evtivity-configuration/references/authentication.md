Generated from https://www.evtivity.com/docs/configuration/authentication (website commit ffa3c26). Do not edit.

# Authentication

Operator and driver authentication, API keys, RBAC, MFA, and security features.

## Auth Systems

EVtivity has two separate authentication systems:

| System | Token Contents | Transport | Use Case |
|---|---|---|---|
| Operator | `userId`, `roleId` | `csms_token` HTTP-only cookie (or `Authorization` Bearer for API keys) | CSMS dashboard access |
| Driver | `driverId`, `type: 'driver'` | `portal_token` HTTP-only cookie | Driver portal access |

Both realms share one JWT signing key but the server rejects driver tokens on operator routes and operator tokens on driver routes by inspecting the payload shape. A stolen driver JWT cannot be replayed against an operator endpoint and vice versa.

## Operator Login

Operators authenticate with email and password. If MFA is enabled, a second factor is required after password verification.

The server sets the JWT in the `csms_token` HTTP-only cookie and a paired `csms_refresh` cookie for refresh-token rotation. The response body also includes the access token for backward compatibility with integration tests and Bearer-only clients.

## Driver Login

Drivers authenticate with email and password. SMS is available as an MFA second factor, not as a primary login method. Driver JWTs land in the `portal_token` HTTP-only cookie (path `/v1/portal`), with a `portal_refresh` cookie for rotation and a `portal_csrf` cookie for double-submit CSRF protection.

## API Keys

API keys provide programmatic access to the REST API.

- Created per user through the CSMS settings UI.
- Sent as a Bearer token in the `Authorization` header.
- Inherits the creating user's role and permissions.
- Supports optional permission scoping to restrict access below the creator's level.

## Role-Based Access Control

EVtivity uses 66 granular permissions in `resource:action` format (e.g., `stations:write`, `sessions:read`): 44 page permissions and 22 settings permissions.

Route middleware enforces permissions:

```typescript
authorize('stations:write')
```

Write permission implies read. A user with `stations:write` can also read station data.

Each user holds any subset of the 66 permissions. The system ships with three roles (Admin, Operator, Viewer). A user's role sets their default permissions, and you can then customize the permissions of each user.

## Multi-Factor Authentication

Three MFA methods are available:

| Method | Description |
|---|---|
| Email | One-time code sent to the user's email |
| TOTP | Time-based one-time password via authenticator app |
| SMS | One-time code sent via Twilio |

An admin enables MFA system-wide through settings. Individual users then enable their preferred method.

### MFA Verification

When a user with MFA enabled submits correct credentials, the server returns a short-lived `mfaPending` JWT (3 minutes) instead of a session. The client posts the code plus the pending JWT to `/v1/auth/mfa/verify` (operator) or `/v1/portal/auth/mfa/verify` (driver). On success the server issues the real session JWT and refresh cookies.

The email/SMS challenge row stores `(user_id | driver_id, code_hash, expires_at, used_at)`. Verification requires three conditions: the supplied code matches `code_hash` under a constant-time compare, the challenge has not expired or been used, and the challenge's owner matches the principal in the `mfaPending` JWT. The owner check blocks an attacker who has victim A's password but no inbox access from completing login as A by submitting an MFA code from a challenge that belongs to their own account.

A challenge is single-use: a successful verify stamps `used_at`, and subsequent attempts return `MFA_CODE_INVALID`. Per-challenge rate limiting caps failed attempts at five before returning `MFA_CHALLENGE_EXHAUSTED` and forcing the user to request a new code.

### TOTP Configuration

- Algorithm: SHA1
- Digits: 6
- Period: 30 seconds
- Window tolerance: 1 step (±30s)
- QR code generated server-side for authenticator app setup
- Secret stored encrypted at rest (`totp_secret_enc`) and decrypted only at verification time

## reCAPTCHA

EVtivity uses Google reCAPTCHA v3 for bot protection.

- Invisible to users (no checkbox or challenge).
- Score-based with a configurable threshold (default 0.5).
- Enable and configure in Settings > Security.
- The site key, secret key, and threshold are dashboard settings, not environment variables. The secret key is stored encrypted.

## CSRF Protection

Token-based CSRF protection is active on all mutating requests (POST, PUT, PATCH, DELETE) for cookie-based authentication. This applies to the driver portal, which uses HTTP-only cookies for auth.

API key and Bearer token authentication are not subject to CSRF protection.

## Session Management

- Access tokens are short-lived JWTs (1 hour).
- Refresh tokens enable long-lived sessions without storing credentials (30 days for operators, 7 days for drivers).
- Token rotation: each refresh token is single-use. Using a refresh token issues a new access token and a new refresh token.
- Rotation is enforced atomically. Two concurrent refresh attempts with the same token race on `UPDATE refresh_tokens SET revoked_at = NOW() WHERE id = X AND revoked_at IS NULL RETURNING id`; only one caller's update returns a row. The loser receives `401 INVALID_REFRESH_TOKEN` rather than silently minting a parallel session.
- A replayed (already-revoked) refresh token is rejected on the SELECT (`WHERE revoked_at IS NULL`) and returns `401 INVALID_REFRESH_TOKEN`. The legitimate session, having rotated to a new token, continues until natural expiry.
- Logging out revokes the current refresh token immediately and clears the auth cookies. The portal and CSMS frontends both await the logout response before clearing local state so a tab-close race cannot leave the revocation un-applied.
