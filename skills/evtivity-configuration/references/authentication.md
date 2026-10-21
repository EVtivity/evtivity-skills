Generated from https://www.evtivity.com/docs/configuration/authentication. Do not edit.

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
- Creating a key, or widening the permissions of a key, from a signed-in session needs a fresh proof, the same as adding a sign-in method: a code of your current second factor or a passkey, else your current password. An SSO account without a second factor signs in again with SSO. A request made with an API key needs no proof.
- Cannot use the account routes of the signed-in user: profile, password, MFA, notification preferences, and personal AI configuration. These answer 403 `SESSION_REQUIRED`.
- Revoked when the user is deactivated or deleted.

## Role-Based Access Control

EVtivity uses 66 granular permissions in `resource:action` format (e.g., `stations:write`, `sessions:read`): 44 page permissions and 22 settings permissions.

Route middleware enforces permissions:

```typescript
authorize('stations:write')
```

Write permission implies read. A user with `stations:write` can also read station data.

Each user holds any subset of the 66 permissions. The system ships with three roles (Admin, Operator, Viewer). A user's role sets their default permissions, and you can then customize the permissions of each user.

## Multi-Factor Authentication

Operators and drivers can protect their sign-in with a second factor:

| Method | Description |
|---|---|
| Email | One-time code sent to the account's email address |
| TOTP | Time-based one-time password from an authenticator app |
| SMS | One-time code sent by text message through Twilio |
| Passkey or security key | A passkey on a phone, computer or password manager, or a FIDO2 security key such as a YubiKey |
| Recovery code | One of ten single-use codes, for when the other factor is lost |

An account has one code method (email, TOTP or SMS) and up to 20 passkeys and security keys. An admin switches each method on or off for everyone in Settings > Security > MFA (see [MFA settings](https://www.evtivity.com/docs/csms/settings#mfa)). Operators set up their factors on their [Profile](https://www.evtivity.com/docs/csms/profile#two-factor-authentication), drivers in the portal under [Account > Security](https://www.evtivity.com/docs/portal/registration#multi-factor-authentication-mfa).

### MFA Verification

When a user with MFA enabled submits correct credentials, the server returns a short-lived `mfaPending` JWT (3 minutes) instead of a session. The client posts the code plus the pending JWT to `/v1/auth/mfa/verify` (operator) or `/v1/portal/auth/mfa/verify` (driver). On success the server issues the real session JWT and refresh cookies. The verify routes also take a recovery code (`recoveryCode`) instead of a code, and a passkey or security key goes through `/v1/auth/webauthn/options` and `/verify` (operators) or `/v1/portal/auth/webauthn/options` and `/verify` (drivers). A password change, a password reset or a sign-out between the two steps ends the pending JWT: the API returns 401 `MFA_TOKEN_EXPIRED`.

The email/SMS challenge row stores `(user_id | driver_id, code_hash, expires_at, used_at)`. Verification requires three conditions: the supplied code matches `code_hash` under a constant-time compare, the challenge has not expired or been used, and the challenge's owner matches the principal in the `mfaPending` JWT. The owner check blocks an attacker who has victim A's password but no inbox access from completing login as A by submitting an MFA code from a challenge that belongs to their own account.

A challenge is single-use: a successful verify stamps `used_at`, and subsequent attempts return `MFA_CODE_INVALID`. Per-challenge rate limiting caps failed attempts at five before returning `MFA_CHALLENGE_EXHAUSTED` and forcing the user to request a new code. A code confirms only what it was sent for: a sign-in code never confirms a security change, an email code never confirms SMS, and an SMS code confirms only the number it went to.

Operator and driver MFA codes can be resent at most 5 times in 15 minutes. Over the limit, the API returns `MFA_RESEND_LIMITED`. Setup and phone change codes to one phone number are capped at 3 an hour across all accounts.

### Switched-Off Methods

Switching a method off in Settings stops new setups of it and also applies at sign-in:

- An account that has another usable factor, such as recovery codes or a passkey, signs in with that factor. A code of the switched-off method returns 403 `MFA_METHOD_DISABLED`, and the sign-in page opens on the recovery code input.
- An account whose only factor is the switched-off method proves it once more, then sets up an allowed method before the session starts.
- When no method can be set up at all, the account signs in after proving its factor.

### Sign-In Lockout

Repeated failed operator and driver sign-ins lock the account for a growing delay, on top of the per-IP rate limits. The first lock comes after 5 failures in a row and lasts 30 seconds. Each further failure doubles it, up to 15 minutes. A successful sign-in resets the count. While the account is locked, a password sign-in answers as for a wrong password.

Wrong MFA codes and recovery codes after the password step follow the same rule with their own count. While locked, the API returns 429 `MFA_LOCKED`. A passkey at the MFA step neither counts toward the lock nor waits for it, since its signature cannot be guessed.

Wrong codes entered from a signed-in session to confirm a security change count separately, so a stolen session cannot lock the owner's sign-in with them. A wrong current password counts toward the password sign-in lock wherever it is entered.

### Required MFA

An admin can require MFA for operators in Settings > Security > MFA > **Require MFA**: **Off**, **All Operators**, or **Selected Roles** (the roles under **Roles That Must Use MFA**). **Require MFA for Drivers** does the same for every driver.

- A covered account without MFA gets no session after the password step. The CSMS or the portal opens **Set Up Two-Factor Authentication**, and the account is signed in once the setup is confirmed. SSO users, including users that SSO creates on their first sign-in, set up MFA the same way.
- Signed-in accounts without MFA are signed out at their next session renewal and set up MFA when they sign in again. API keys keep working.
- A covered account cannot turn MFA off or remove its last passkey (409 `MFA_REQUIRED_BY_POLICY`). An admin can still reset its MFA. The account then sets up MFA again at its next sign-in.
- Requiring MFA needs email codes or the authenticator app switched on. When no method can be set up for an account, for example SMS only and no phone number, the sign-in fails with 403 `MFA_SETUP_UNAVAILABLE` and never starts a session without MFA.
- When the MFA settings cannot be read, every required MFA check fails closed: an account without MFA cannot sign in or renew its session, and no one can turn MFA off or remove the last passkey (503 `MFA_POLICY_UNAVAILABLE`). Accounts with MFA sign in as usual.

The mobile app cannot set up MFA during sign-in or use a passkey or a recovery code, so a driver who must set up MFA, or whose only factors are a passkey or recovery codes, is told to finish in the portal (403 `MFA_ENROLLMENT_REQUIRED`).

### Recovery Codes

Turning MFA on, with a code method or a first passkey, creates ten recovery codes. Each signs in once in place of the second factor.

- The codes show only once. Copy them or download them as a text file, and store them somewhere safe. The server keeps only their hashes.
- At the verification step, choose **Use a Recovery Code**. The reply says how many codes are left.
- Regenerating the codes replaces all of them. It needs a code of the account's method or a passkey.
- Turning MFA off and an admin MFA reset delete the codes.
- An account that turned MFA on before recovery codes existed has none until it generates them on its Profile or Account > Security page.

### Passkeys and Security Keys

Operators add passkeys and FIDO2 security keys on their Profile, drivers in the portal under Account > Security. A security key is a physical key, such as a YubiKey, that you plug in or hold near the device and touch when the browser asks. Passkeys need HTTPS on a domain, or `localhost`. The apps hide every passkey option on other pages, and the portal shows none while `PORTAL_URL` is an IP address.

- A passkey works as the second factor after the password. When an admin turns on **Passkey Sign-In**, a passkey also signs in on its own and counts as both factors. Passkey sign-in needs user verification, such as a fingerprint, face or PIN, so a security key without a PIN works as a second factor only.
- The first passkey of an account without MFA turns MFA on, signs out the account's other sessions and shows the recovery codes once.
- Any FIDO2 authenticator is accepted. The server keeps only the public key.

The relying party ID is the host of `CSMS_URL` for operators and the host of `PORTAL_URL` for drivers. `WEBAUTHN_RP_ID` sets one ID for both apps:

- It must be the CSMS host or a parent domain of it, otherwise the API does not start.
- The portal uses it only when it is also the portal host or a parent domain of it. Otherwise the portal uses its own host.
- A passkey is bound to its relying party ID. Changing `WEBAUTHN_RP_ID` later makes every registered passkey unusable.

For example, `example.com` serves `csms.example.com` and `portal.example.com`. With `csms.example.com`, operators use `csms.example.com` and drivers use `portal.example.com`. A driver passkey never signs in an operator, and an operator passkey never signs in a driver.

Never set `WEBAUTHN_RP_ID` to a parent domain with subdomains that serve user content or that third parties run, for example a domain whose subdomains host customer sites, file uploads or a vendor service. A page on any subdomain of the relying party ID can ask the browser for a passkey sign-in for that ID, so such a subdomain could phish passkey assertions. Use the CSMS host itself, or a parent domain whose every subdomain you control.

### Confirming Security Changes

A signed-in session alone cannot change how an account signs in. Each change asks for a fresh proof first.

Adding a passkey, setting up a code method, regenerating recovery codes, changing the phone number and creating an API key need:

- A factor the account holds: a code of its method, sent when the proof field opens, or one of its passkeys.
- The current password, when the account has no factor.
- A new SSO sign-in, for an SSO account without a password or factor. It counts for 10 minutes after the SSO sign-in.

An account with none of these, such as an SSO account after SSO was turned off, cannot add a factor or create an API key until an admin resets its password.

Removing a passkey and turning MFA off need a factor the account holds or one of its recovery codes. The password alone never removes a factor. Removing a passkey or turning MFA off signs out the account's other sessions.

A missing proof, or a proof of another kind, returns 400 `VALIDATION_ERROR` with the accepted kinds in `proofKinds`. Each proof works once.

### Phone Number Changes

SMS codes go to the account's phone, so a stolen session must not move them.

- An account with a factor confirms a phone number change first.
- An account that signs in with SMS codes also confirms the new number with a code sent to it, through **Send Code to New Number**. The number is saved only once confirmed.
- The mobile app cannot send the proof, so it tells drivers to change the number in the portal.
- Phone numbers are stored in international format (E.164). A number without a country code is read as a North American number, and a number that does not parse returns 400 `VALIDATION_ERROR`.

Operators and drivers cannot change their own email address. An admin changes an operator's email on the Users page and a driver's email on the driver page. The previous address gets a notice.

### SSO Accounts

An SSO account without a password and without a second factor confirms a security change by signing in again with SSO. This applies to adding a first sign-in method or passkey and to creating an API key. The confirmation lasts 10 minutes after the SSO sign-in.

An SSO sign-in must finish in the browser that started it. The CSMS sets a short-lived binding cookie when the sign-in starts and accepts the identity provider's reply only from the browser that holds it. Otherwise the sign-in page shows that the reply did not match a sign-in started in this browser, and no session starts.

- Over HTTPS the cookie is `__Host-csms_sso_binding`, which no other subdomain can set. With `COOKIE_DOMAIN` set, it is `csms_sso_binding` on that domain, so every subdomain of `COOKIE_DOMAIN` must be one you trust.
- Over plain HTTP, such as local development, Chrome sends the cookie back only within two minutes of the start of the sign-in. Firefox and Safari have no such limit. An identity provider sign-in in Chrome that takes longer must be started again.

### TOTP Configuration

- Algorithm: SHA1
- Digits: 6
- Period: 30 seconds
- Window tolerance: 1 step (±30s)
- Each code is accepted once
- QR code generated server-side for authenticator app setup
- Secret stored encrypted at rest (`totp_secret_enc`) and decrypted only at verification time

## Security Notices

Operators and drivers get an email when the security of their account changes. An account that signs in with SMS codes also gets a text message. A notice goes out when:

- A sign-in method or passkey is added or removed.
- Two-factor authentication is turned on or off.
- An administrator resets the account's MFA.
- Recovery codes are regenerated, or a recovery code is used.
- The phone number changes. The notice also goes to the previous number.
- An administrator changes the email address. The notice goes to the previous address.
- An operator creates an API key.

Each notice tells the user what to do if they did not make the change. These notices are always on. Edit their templates under **Notifications > System Events**, in the **Account Security** group. When drivers turn off two-factor authentication themselves, they get the `driver.MfaDisabled` notice.

## reCAPTCHA

EVtivity uses Google reCAPTCHA v3 for bot protection.

- Invisible to users (no checkbox or challenge).
- Score-based with a configurable threshold (default 0.5).
- Enable and configure in Settings > Security.
- The site key, secret key, and threshold are dashboard settings, not environment variables. The secret key is stored encrypted.
- Turn it on when anyone can sign up in the driver portal. It protects the portal sign-in, sign-up, forgot password and reset password forms, and the guest charging start. The mobile apps prove themselves with device attestation instead.
- While it is off, those forms are protected only by IP rate limits, and Settings > Security shows a warning.

### Driver sign-up limits

These limits apply whether reCAPTCHA is on or off, on top of the IP rate limits:

- The account verification link goes to the driver's email address only, never by SMS.
- A driver gets at most one verification email a minute and five in 24 hours, the sign-up email included. Over the limit, the API returns `VERIFICATION_RESEND_LIMITED`.
- A phone number can be used for at most three portal registrations in 24 hours. Over the limit, the API returns `PHONE_REGISTRATION_LIMITED`. Several drivers can share a phone number.

## CSRF Protection

Token-based CSRF protection is active on all mutating requests (POST, PUT, PATCH, DELETE) for cookie-based authentication. This applies to the driver portal, which uses HTTP-only cookies for auth.

API key and Bearer token authentication are not subject to CSRF protection.

## Password Policy

One password policy applies to operators and drivers. Admins set it in [Settings > Security > Passwords and Sessions](https://www.evtivity.com/docs/csms/settings#passwords-and-sessions). By default a password needs at least 12 characters, an uppercase letter, a lowercase letter and a number. A special character (a printable ASCII character that is not a letter, digit or space) can also be required. The minimum length ranges from 8 to 64, and a new password is at most 128 characters.

- The API checks the policy on every route that sets a new password. A password that misses a rule answers 400 `WEAK_PASSWORD`, and the `missing` list of the body names the rules it misses (`minLength`, `uppercase`, `lowercase`, `number`, `symbol`, `maxLength`). A password under 8 or over 128 characters answers 400 `VALIDATION_ERROR`.
- Sign-in never checks the policy, so a stricter policy locks nobody out. It applies the next time someone sets a password.
- `GET /v1/security/public` (no sign-in) returns the policy in effect as `passwordPolicy` (`minLength`, `requireUppercase`, `requireLowercase`, `requireNumber`, `requireSymbol`), so a client can list the rules.
- `PUT /v1/security/password-policy` sets the five policy fields, and `PUT /v1/security/sessions` sets the four session lifetimes below. Both take every field, need `settings.security:write` and access to all sites. `GET /v1/security/settings` (`settings.security:read`) returns the values in effect as `passwordPolicy` and `sessionLifetimes`.

## Session Management

- Access tokens are short-lived JWTs. Their lifetime is the sign-in check interval: 60 minutes by default, from 5 to 1440, set separately for operators (`operatorAccessMinutes`) and drivers (`driverAccessMinutes`). The access cookie lives as long as the token.
- Refresh tokens keep a session signed in without storing credentials. Their lifetime is the inactivity timeout: 30 days by default, from 1 to 90 for operators (`operatorRefreshDays`) and from 1 to 365 for drivers (`driverRefreshDays`). Each rotation starts a new lifetime, so a session ends after that long without use. The refresh cookie and the stored refresh token have the same lifetime.
- A lifetime change applies to tokens issued after it. A refresh issues both tokens with the current values, so an active session takes on the new lifetimes at its next renewal. A session no one uses keeps its old expiry.
- Token rotation: each refresh token is single-use. Using a refresh token issues a new access token and a new refresh token.
- Rotation is enforced atomically. Two concurrent refresh attempts with the same token race on `UPDATE refresh_tokens SET revoked_at = NOW() WHERE id = X AND revoked_at IS NULL RETURNING id`; only one caller's update returns a row. The loser receives `401 INVALID_REFRESH_TOKEN` rather than silently minting a parallel session.
- Signing out ends the operator session at once. A password change, an MFA change, a role or permission change, and deactivation end every session of the user at once.
- Deactivating or deleting an operator also revokes the user's API keys and emailed links. A password reset link works once.
- Operator accounts created through SSO have no password. They cannot sign in with a password, reset it, or change it. A password reset or invitation sent by an operator for such a user returns 409 `USER_SSO_MANAGED`.
- A replayed (already-revoked) refresh token is rejected on the SELECT (`WHERE revoked_at IS NULL`) and returns `401 INVALID_REFRESH_TOKEN`. The legitimate session, having rotated to a new token, continues until natural expiry.
- Logging out revokes the current refresh token immediately and clears the auth cookies. The portal and CSMS frontends both await the logout response before clearing local state so a tab-close race cannot leave the revocation un-applied.
