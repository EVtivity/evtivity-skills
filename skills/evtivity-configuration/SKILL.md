---
name: evtivity-configuration
description: Configure an EVtivity CSMS install. Covers authentication (operator and driver auth realms, JWT cookies, API keys, RBAC permissions and roles, MFA by email, TOTP or SMS, reCAPTCHA, CSRF, session and refresh token lifetimes), database setup (PostgreSQL 17, Drizzle migrations, seeding, connection pools, Redis with one ACL user per service), environment variables for every service (API, OCPP, OCPI, worker, simulator, frontends, payments, seed credentials) and OCPP settings (ports, station connection URLs, security profiles 0 to 3, TLS certificates, connection limits, heartbeat, horizontal scaling). Use when someone asks which environment variable or dashboard setting changes a behavior, sets secrets such as JWT_SECRET or SETTINGS_ENCRYPTION_KEY, enables MFA or reCAPTCHA, runs migrations or the seed, sizes database pools, or sets up OCPP TLS and security profiles.
license: MIT
metadata:
  evtivity-version: "0.1.39"
  evtivity-docs-section: configuration
---

# EVtivity configuration

This skill tells you where a setting lives and how to change it safely. The website docs are the source of truth for each topic. Read the page for the details, then follow the workflow here.

## Pages in this section

| Page id | Live page | Read it for |
| --- | --- | --- |
| configuration/authentication | https://www.evtivity.com/docs/configuration/authentication | Operator and driver auth realms, cookies, API keys, RBAC, MFA, reCAPTCHA, CSRF, session lifetimes |
| configuration/database-setup | https://www.evtivity.com/docs/configuration/database-setup | PostgreSQL 17, Drizzle conventions, migration and seed commands, Redis purposes and ACL users |
| configuration/environment-variables | https://www.evtivity.com/docs/configuration/environment-variables | Every environment variable per service, with defaults |
| configuration/ocpp-settings | https://www.evtivity.com/docs/configuration/ocpp-settings | OCPP 1.6 and 2.1, station URLs, security profiles, TLS, limits, message pipeline, horizontal scaling |

## Step 1: find where the value lives

EVtivity has three configuration surfaces. Pick the right one before you change anything.

| Surface | What goes there | How to change it | Takes effect |
| --- | --- | --- | --- |
| Environment variables | Ports, URLs, database and Redis connections, `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, OCPP TLS files, rate limits, seed credentials, `PAYMENTS_ALLOW_SIMULATED` | `.env` for Docker Compose, chart values for Helm, `config/<env>.yaml` for AWS CDK | After the service restarts |
| Dashboard settings (database) | Integrations (Stripe, Adyen, S3, SMTP, Twilio, reCAPTCHA, Google Maps, Plug and Charge), MFA methods, heartbeat interval, offline command queue TTL, company currency | Settings page in the CSMS dashboard, or `PUT /v1/settings/:key` | Without a restart (readers cache for a short time) |
| Helm `appSettings` or CDK `appSettings` | Seed values for selected dashboard settings at install or upgrade | Chart values or CDK config | When the settings job runs |

Rules that follow from the docs and the code:

- Integration credentials are never environment variables. They are dashboard settings, stored AES-256-GCM encrypted. There is no `STRIPE_WEBHOOK_SECRET` variable. The only integration variable left is `SMTP_HOST`, which overrides the SMTP host setting.
- Frontend variables need the `VITE_` prefix. In Helm and Docker images the frontends read the API URL at runtime from `/runtime-config.js` instead (see evtivity-deployment).
- For deployment-specific keys (Helm values, CDK config), use evtivity-deployment.

## Goal to setting map

| Goal | Change | Page id |
| --- | --- | --- |
| Set production secrets | `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY` | configuration/environment-variables |
| Change the first admin or driver login | `INITIAL_ADMIN_EMAIL`, `INITIAL_ADMIN_PASSWORD`, `INITIAL_ADMIN_MUST_RESET_PASSWORD`, `INITIAL_DRIVER_*` (only on first seed) | configuration/environment-variables |
| Allow other machines to reach Compose ports | `BIND_IP` (`0.0.0.0` all interfaces, `127.0.0.1` local only) | configuration/environment-variables |
| Point at another database or Redis | `DATABASE_URL`, `REDIS_URL` | configuration/database-setup |
| Fix "too many connections" | `DB_POOL_MAX` per process, sum below Postgres `max_connections` | configuration/environment-variables |
| Cross-subdomain cookies | `COOKIE_DOMAIN`, plus `CSMS_URL`, `PORTAL_URL`, `CORS_ORIGIN` | configuration/environment-variables |
| Script against the API | API key from the dashboard, sent as Bearer | configuration/authentication |
| Restrict what a user can do | Custom role from the permissions in `resource:action` form | configuration/authentication |
| Turn on MFA | Admin enables methods system-wide in Settings, users pick one | configuration/authentication |
| Bot protection on login and sign-up | reCAPTCHA v3 in Settings > Security | configuration/authentication |
| Stations on TLS (profiles 2 and 3) | `OCPP_TLS_PORT`, `OCPP_TLS_CERT`, `OCPP_TLS_KEY`, `OCPP_TLS_CA` (or the `*_PEM` variants), `OCPP_STATION_TLS_URL` on the API | configuration/ocpp-settings |
| Run several OCPP servers | `OCPP_INSTANCE_ID` per instance | configuration/ocpp-settings |
| Open or approval-based station onboarding | `REGISTRATION_POLICY` at first install, later in the dashboard | configuration/environment-variables |
| Allow the test payment provider | `PAYMENTS_ALLOW_SIMULATED=true` on API, OCPP and worker (never in production) | configuration/environment-variables |
| Heartbeat interval or offline command TTL | Dashboard settings, not env vars | configuration/ocpp-settings |

## Workflow: change an environment variable

1. Look up the variable, its default and the services that read it on configuration/environment-variables.
2. Set it in the right place:
   - Docker Compose: add it to `.env` at the repo root. `docker-compose.yml` reads every variable with a shell default (`${VAR:-default}`). The local Compose setup is covered by evtivity-getting-started.
   - Helm or AWS CDK: set the chart value or CDK config key (evtivity-deployment).
3. Restart the services that read it. Compose: `docker compose up -d <service>` recreates a container whose environment changed.
4. Confirm it worked:
   - `docker compose exec <service> printenv <VAR>` shows the value inside the container.
   - `curl -s http://localhost:7102/v1/health` reports API, database and Redis health.
   - `docker compose logs <service> --tail=50` shows a startup error when a value fails validation. Each service validates its variables with a Zod schema at start and exits on an invalid value.

## Workflow: production secrets

The two values every install must set:

- `JWT_SECRET` signs operator and driver tokens. Both realms share it.
- `SETTINGS_ENCRYPTION_KEY` encrypts every secret setting (`*Enc` keys). The API, OCPP server, OCPI server and worker refuse to start without it. Use the same value in every service, the migrate container included.

Generate values with `openssl rand -base64 24` (32 characters) or similar.

Before you change `SETTINGS_ENCRYPTION_KEY` on an existing install, stop and confirm with the user. Settings encrypted with the old key cannot be decrypted with the new one, so every stored integration credential (payment keys, SMTP and Twilio credentials, TOTP secrets) must be entered again. Never rotate it without explicit approval.

## Workflow: authentication and access

Read configuration/authentication first. Key facts for decisions:

- Two realms. Operators get the `csms_token` and `csms_refresh` cookies. Drivers get `portal_token`, `portal_refresh` and `portal_csrf` (path `/v1/portal`). The server rejects a token from one realm on the other realm's routes.
- API keys: created per user in the dashboard settings, sent as `Authorization: Bearer <key>`. A key inherits its creator's role and can be scoped down. Bearer requests are not subject to CSRF. For endpoint details use evtivity-api.
- RBAC: permissions use `resource:action` (for example `stations:write`). Write implies read. Default roles are Admin, Operator and Viewer, and custom roles combine any subset. Manage roles in the dashboard (evtivity-csms).
- MFA: email, TOTP (SHA1, 6 digits, 30 s, 1 step tolerance) or SMS through Twilio. An admin enables methods system-wide, then each user enables one. In the code the switches are the settings `security.mfa.emailEnabled`, `security.mfa.totpEnabled` and `security.mfa.smsEnabled`. SMS needs Twilio configured, email needs SMTP.
- MFA flow: correct password returns a 3-minute `mfaPending` JWT. The client posts the code to `/v1/auth/mfa/verify` (operator) or `/v1/portal/auth/mfa/verify` (driver). A code is single-use. Five failed attempts return `MFA_CHALLENGE_EXHAUSTED`.
- Sessions: access tokens last 1 hour. Refresh tokens last 30 days (operators) or 7 days (drivers) and rotate on every use. A reused refresh token returns `401 INVALID_REFRESH_TOKEN`.
- Login and auth endpoints have their own rate limit: `AUTH_RATE_LIMIT_MAX` (30) per `AUTH_RATE_LIMIT_WINDOW` (1 minute).

### reCAPTCHA

reCAPTCHA v3 is invisible and score-based (default threshold 0.5). Turn it on in Settings > Security in the dashboard.

The authentication page says it needs `RECAPTCHA_SECRET_KEY` and `RECAPTCHA_SITE_KEY` environment variables. The code reads no such variables. Follow the code: the keys are dashboard settings `security.recaptcha.enabled`, `security.recaptcha.siteKey`, `security.recaptcha.secretKeyEnc` (encrypted) and `security.recaptcha.threshold`, edited in Settings > Security.

## Workflow: database, migrations and seed

Read configuration/database-setup.

1. Use PostgreSQL 17. Set `DATABASE_URL` (default `postgres://evtivity:evtivity@localhost:5433/evtivity`). Compose publishes Postgres on host port 5433.
2. Apply migrations with `npm run db:migrate`. In Compose the `migrate` service runs them before the other services start. Helm and CDK run them in a job (evtivity-deployment).
3. Seed with `npm run db:seed`. `SEED_DEMO=true` adds demo sites, stations, sessions and drivers. `false` creates only settings, roles and the admin user. The migrate container never seeds demo data on its own.
4. Confirm: `psql "$DATABASE_URL" -c 'select 1'`, and the API health check reports the database as healthy.

Seed behavior differs from the page. The page says re-running the seed overwrites all settings and resets the admin password. Since v0.1.38 the seed only adds what is missing and keeps existing settings, the admin password, roles and templates. To write `seed.config.json` over existing settings, run `npm run db:seed -- --apply-config`. Confirm with the user before running it on a database with real data.

The page's schema rules (`npm run generate` for new migrations, the shared database client, no cross-package schema imports) apply to people changing EVtivity code, not to operators.

### Connection pools

`DB_POOL_MAX` (default 20 for api, ocpp, ocpi and worker, 10 for the simulator) is per process. Keep the sum across all processes and replicas below Postgres `max_connections` (Compose sets 200). The code also reads `DB_POOL_IDLE_TIMEOUT` (default 30 s) and `DB_POOL_MAX_LIFETIME` (default 300 s). The page does not list them.

### Redis

Redis carries pub/sub between services, BullMQ job queues and caches. Each service connects as its own ACL user (`api`, `ocpp`, `ocpi`, `worker`, `css`) through its own `REDIS_URL`. On a shared host, set `REDIS_API_PASSWORD`, `REDIS_OCPP_PASSWORD`, `REDIS_OCPI_PASSWORD`, `REDIS_WORKER_PASSWORD` and `REDIS_CSS_PASSWORD` (URL-safe characters). Compose publishes Redis on `127.0.0.1:6379` only, because the `default` user stays open for host tools. For `rediss://` with a private CA, set `REDIS_TLS_CA_PEM` or `REDIS_TLS_CA_FILE`.

## Workflow: OCPP server and security profiles

Read configuration/ocpp-settings.

1. Create the station in the dashboard first. The station ID in the URL must match.
2. Give the station its URL: `ws://<host>:7103/<stationId>` or `wss://<host>:8443/<stationId>`. Both OCPP 1.6 and 2.1 use the same server. The subprotocol header selects the version.
3. Pick a security profile:

| Profile | Name | Port | Needs |
| --- | --- | --- | --- |
| 0 | No Auth | 7103 | Nothing. Development only. |
| 1 | Basic Auth | 7103 | Station password stored in the station record |
| 2 | TLS + Basic Auth | 8443 | Server certificate the station trusts, plus the password |
| 3 | Mutual TLS | 8443 | Server certificate and a client certificate signed by the CA |

4. For profiles 2 and 3, enable the TLS listener: `OCPP_TLS_PORT=8443` with `OCPP_TLS_CERT`, `OCPP_TLS_KEY` and `OCPP_TLS_CA` (file paths) or `OCPP_TLS_CERT_PEM`, `OCPP_TLS_KEY_PEM` and `OCPP_TLS_CA_PEM` (inline PEM). One port serves both profiles.
5. To move a connected OCPP 2.1 station from `ws://` to TLS, set `OCPP_STATION_TLS_URL` on the API to the public `wss://` address without the station ID. Unset, the API refuses those upgrades.
6. Confirm: the station shows as connected in the dashboard, and `docker compose logs ocpp` shows the connection. The OCPP health endpoint listens on `OCPP_HEALTH_PORT` (8081).

Limits: `OCPP_MAX_CONNECTIONS_PER_IP` (2500) and `OCPP_MAX_MESSAGES_PER_IP_PER_SECOND` (5000). Raise them when many stations share one NAT address.

Settings that are not env vars: heartbeat interval (default 300 s, sent in the BootNotification response) and offline command queue TTL (default 24 h). Change them in the dashboard.

Horizontal scaling: set a unique `OCPP_INSTANCE_ID` per instance (the pod name in Kubernetes). Redis tracks which instance holds each station, and commands reach the right instance through the `ocpp_commands` channel.

OCPP variables in the code that the page does not list:

- `OCPP_TRUSTED_PROXY_CIDRS`: comma-separated load balancer CIDRs whose `X-Forwarded-For` header is trusted for the station IP.
- `OCPP_AUTH_MAX_CONCURRENT` (default half of `DB_POOL_MAX`), `OCPP_AUTH_MAX_QUEUED` (1000) and `OCPP_AUTH_MAX_WAIT_MS` (10000): bound station authentications after a reconnect wave. Stations over the limit get 503 with `Retry-After`.

## Where the docs and the code differ

Follow the code. Mention the difference when it matters to the user.

| Topic | Page says | Code does |
| --- | --- | --- |
| reCAPTCHA keys (configuration/authentication) | `RECAPTCHA_SECRET_KEY` and `RECAPTCHA_SITE_KEY` env vars | Dashboard settings `security.recaptcha.siteKey` and `security.recaptcha.secretKeyEnc` |
| Seed re-run (configuration/database-setup) | Overwrites settings and resets the admin password | Adds only what is missing. `--apply-config` writes `seed.config.json` over settings |
| `SETTINGS_ENCRYPTION_KEY` length (configuration/environment-variables) | Exactly 32 characters | Any non-empty value is accepted and the key is derived from it. Use 32 characters anyway |
| `JWT_SECRET` default | None | Falls back to an insecure development value, so always set it |
| `CORS_ORIGIN` default | None | `*` in the API config. `.env.example` sets `local` |
| `OCPP_TLS_PORT` default (configuration/ocpp-settings) | `8443` | No default. The TLS listener starts only when set. Compose sets 8443 |
| `NODE_ENV` default | None | `development`. This also turns on `PAYMENTS_ALLOW_SIMULATED` by default, so set `NODE_ENV=production` in production |
| Worker variables | `API_BASE_URL` only | Also `OCPP_SERVER_URL` and `OCTT_OCSP_RESPONDER_URL` (conformance runs) |

## Safety

Confirm with the user before you:

- change or rotate `SETTINGS_ENCRYPTION_KEY`
- run `npm run db:seed -- --apply-config` on a database with real data
- change `DATABASE_URL` on a running install
- set `PAYMENTS_ALLOW_SIMULATED=true` anywhere that is not a test install

Never print secrets back to the user unless they ask. Never commit `.env` files.

## Related skills

- evtivity-getting-started: local Docker setup, first sign-in, its setup script
- evtivity-deployment: Docker images, Compose profiles, Helm, minikube, AWS CDK, upgrades
- evtivity-csms: dashboard pages, including Settings, roles and users
- evtivity-portal: driver portal sign-in and MFA from the driver side
- evtivity-mobile-app: driver app configuration
- evtivity-integrations: payments, webhooks, SMTP, Twilio and other integration settings
- evtivity-api: API keys, endpoints and error codes
- evtivity-simulator: simulator variables (`CSS_*`) and simulated stations
- evtivity-conformance: OCTT runs and their worker settings
- evtivity-guides: task guides
- evtivity-troubleshoot: diagnose startup, connection and auth failures
- evtivity-report-issue: report a bug

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `configuration/authentication` | `references/authentication.md` | https://www.evtivity.com/docs/configuration/authentication |
| `configuration/database-setup` | `references/database-setup.md` | https://www.evtivity.com/docs/configuration/database-setup |
| `configuration/environment-variables` | `references/environment-variables.md` | https://www.evtivity.com/docs/configuration/environment-variables |
| `configuration/ocpp-settings` | `references/ocpp-settings.md` | https://www.evtivity.com/docs/configuration/ocpp-settings |
