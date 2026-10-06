# EVtivity API routes: Settings

Generated from EVtivity CSMS v0.1.39-beta.1 (https://github.com/EVtivity/evtivity-csms, commit bd06577f1cf1) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/branding` | public | Get portal branding settings |
| GET | `/v1/portal/features` | public | Get public feature flags |
| GET | `/v1/portal/content/{type}` | public | Get public legal content |
| GET | `/v1/settings` | settings.system:read | Get all settings |
| GET | `/v1/settings/{key}` | settings.system:read | Get a setting by key |
| PUT | `/v1/settings/{key}` | settings.system:write | Create or update a setting by key |
| PATCH | `/v1/settings/{key}` | settings.system:write | Update a setting by key |
| DELETE | `/v1/settings/{key}` | settings.system:write | Delete a setting by key |
| GET | `/v1/settings/s3/status` | settings.system:read | Get S3 storage configuration status |
| PUT | `/v1/settings/s3` | settings.system:write | Save S3 storage settings |
| POST | `/v1/settings/s3/test` | settings.system:write | Test S3 connection |
| POST | `/v1/email-wrapper/preview` | settings.notification:read | Preview a draft email layout |
| GET | `/v1/security/settings` | settings.security:read | Get all security settings |
| PUT | `/v1/security/recaptcha` | settings.security:write | Update reCAPTCHA v3 settings |
| PUT | `/v1/security/mfa` | settings.security:write | Update MFA method availability |
| GET | `/v1/security/public` | public | Get public security configuration for login pages |
| GET | `/v1/system/info` | settings.system:read | Runtime version and environment configuration (no secret values) |
| GET | `/v1/sso/settings` | settings.security:read | Get SSO (SAML 2.0) settings |
| PUT | `/v1/sso/settings` | settings.security:write | Update SSO (SAML 2.0) settings |
| GET | `/v1/auth/sso/login` | public | Initiate SAML SSO login |
| POST | `/v1/auth/sso/callback` | public | SAML SSO assertion callback |
| GET | `/v1/carbon/factors` | sustainability:read | List carbon intensity factors |
| GET | `/v1/carbon/factors/{regionCode}` | sustainability:read | Get a carbon intensity factor by region code |
| GET | `/v1/station-message-templates` | settings.integrations:read | List all station message templates |
| PUT | `/v1/station-message-templates/{state}` | settings.integrations:write | Upsert a station message template body |
| DELETE | `/v1/station-message-templates/{state}` | settings.integrations:write | Reset a station message template to its seed default |
| POST | `/v1/station-message-templates/preview` | settings.integrations:read | Render a station message template body with sample variables |
| POST | `/v1/cache/flush` |  | Flush the HTTP response cache |
