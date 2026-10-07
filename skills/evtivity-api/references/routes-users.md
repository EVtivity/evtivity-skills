# EVtivity API routes: Users

Generated from EVtivity CSMS v0.1.40 (https://github.com/EVtivity/evtivity-csms, commit 571bdc26947f) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/auth/login` | public | Authenticate a user and return a JWT |
| POST | `/v1/auth/logout` |  | Logout and clear auth cookies |
| POST | `/v1/auth/refresh` | public | Refresh access token using refresh token cookie |
| POST | `/v1/auth/forgot-password` | public | Request a password reset email |
| POST | `/v1/auth/reset-password` | public | Reset password using a token from the reset email |
| POST | `/v1/auth/force-change-password` | public | Change password for a user that has mustResetPassword set |
| GET | `/v1/users/me` | users:read | Get the currently authenticated user |
| PATCH | `/v1/users/me` |  | Update the authenticated user's own profile fields |
| GET | `/v1/users` | users:read | List all users with pagination |
| POST | `/v1/users` | users:write | Create a new user |
| GET | `/v1/users/{id}` | users:read | Get a user by ID |
| PATCH | `/v1/users/{id}` | users:write | Update a user by ID |
| DELETE | `/v1/users/{id}` | users:write | Deactivate a user by ID |
| POST | `/v1/users/{id}/reset-password` | users:write | Reset a user password by admin |
| POST | `/v1/users/me/change-password` |  | Change the current user password |
| POST | `/v1/users/{id}/resend-invite` | users:write | Resend account setup invitation to a user |
| GET | `/v1/roles` | users:read | List all available roles |
| POST | `/v1/auth/mfa/verify` | public | Verify MFA code and complete login |
| POST | `/v1/auth/mfa/resend` | public | Resend MFA verification code |
| GET | `/v1/users/me/mfa` | users:read | Get current MFA status |
| DELETE | `/v1/users/me/mfa` |  | Disable MFA |
| POST | `/v1/users/me/mfa/setup` |  | Start MFA setup |
| POST | `/v1/users/me/mfa/confirm` |  | Confirm MFA setup with verification code |
| GET | `/v1/users/me/notification-preferences` |  | Get operator notification preferences |
| PUT | `/v1/users/me/notification-preferences` |  | Update operator notification preferences |
| GET | `/v1/users/me/chatbot-ai-config` |  | Get personal AI configuration |
| PUT | `/v1/users/me/chatbot-ai-config` |  | Create or update personal AI configuration |
| DELETE | `/v1/users/me/chatbot-ai-config` |  | Delete personal AI configuration |
| GET | `/v1/users/me/support-ai-config` |  | Get personal support AI configuration |
| PUT | `/v1/users/me/support-ai-config` |  | Create or update personal support AI configuration |
| DELETE | `/v1/users/me/support-ai-config` |  | Delete personal support AI configuration |
| GET | `/v1/permissions` | users:read | Get the permission catalog with groups |
| GET | `/v1/users/me/permissions` | users:read | Get current user permissions |
| GET | `/v1/users/{id}/permissions` | users:read | Get a user permissions by user ID |
| PUT | `/v1/users/{id}/permissions` | users:write | Replace a user permissions |
| GET | `/v1/users/{id}/neighbors` | users:read | Get previous and next entity IDs in default list order |
