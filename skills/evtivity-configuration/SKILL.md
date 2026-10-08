---
name: evtivity-configuration
description: "Configure EVtivity: environment variables, secrets such as JWT_SECRET and SETTINGS_ENCRYPTION_KEY, operator and driver auth, roles, MFA, reCAPTCHA setup, database, migrations, seed, Redis users, OCPP ports, TLS and station security profiles. Use to change a setting or variable or harden an install. Not for a blocked sign-in (evtivity-troubleshoot)."
license: MIT
metadata:
  evtivity-version: "0.1.42"
  evtivity-release: "v0.1.42-beta.1"
  evtivity-commit: "34bf507e0fc3747130048421f45a185cfe0bfe7e"
  evtivity-docs-section: configuration
---

# EVtivity configuration

Not for: sign-in that fails right now or a service that does not start (use evtivity-troubleshoot), Helm values and CDK config (use evtivity-deployment), payment provider credentials (use evtivity-integrations).

This skill tells you where a setting lives and how to change it safely. The website docs are the source of truth: read the reference, then follow the workflow here.

## Step 1: find where the value lives

| Surface | What goes there | How to change it | Takes effect |
| --- | --- | --- | --- |
| Environment variables | Ports, URLs, database and Redis connections, `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, OCPP TLS files, rate limits, seed credentials, `PAYMENTS_ALLOW_SIMULATED` | `.env` for Docker Compose, chart values for Helm, `config/<env>.yaml` for AWS CDK | After the service restarts |
| Dashboard settings (database) | Integrations (Stripe, Adyen, S3, SMTP, Twilio, reCAPTCHA, Google Maps, Plug and Charge), MFA methods, heartbeat interval, offline command queue TTL, company currency | Settings page, or `PUT /v1/settings/:key` | Without a restart (readers cache briefly) |
| Helm or CDK `appSettings` | Seed values for selected dashboard settings at install or upgrade | Chart values or CDK config | When the settings job runs |

- Integration credentials are never environment variables. They are dashboard settings, stored AES-256-GCM encrypted. The only integration variable is `SMTP_HOST`, which overrides the SMTP host setting.
- Frontend variables need the `VITE_` prefix. In Helm and Docker images the frontends read the API URL at runtime from `/runtime-config.js` (evtivity-deployment).

## Goal to setting map

| Goal | Change | Reference |
| --- | --- | --- |
| Set production secrets | `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY` | `references/environment-variables.md` |
| Change the first admin or driver login | `INITIAL_ADMIN_EMAIL`, `INITIAL_ADMIN_PASSWORD`, `INITIAL_ADMIN_MUST_RESET_PASSWORD`, `INITIAL_DRIVER_*` (first seed only) | `references/environment-variables.md` |
| Allow other machines to reach Compose ports | `BIND_IP` for user-facing ports, `INFRA_BIND_IP` (default `127.0.0.1`) for Postgres, pgAdmin, Mailpit, FTP and monitoring | `references/environment-variables.md` |
| Point at another database or Redis | `DATABASE_URL`, `REDIS_URL` | `references/database-setup.md` |
| Fix "too many connections" | `DB_POOL_MAX` per process, sum below Postgres `max_connections` | `references/environment-variables.md` |
| Cross-subdomain cookies | `COOKIE_DOMAIN`, plus `CSMS_URL`, `PORTAL_URL`, `CORS_ORIGIN` | `references/environment-variables.md` |
| Script against the API | API key from the dashboard, sent as Bearer | `references/authentication.md` |
| Restrict what a user can do | Custom role from `resource:action` permissions | `references/authentication.md` |
| Turn on MFA or reCAPTCHA | Settings > Security in the dashboard | `references/authentication.md` |
| Stations on TLS (profiles 2 and 3) | `OCPP_TLS_PORT`, `OCPP_TLS_CERT`, `OCPP_TLS_KEY`, `OCPP_TLS_CA` (or the `*_PEM` variants), `OCPP_STATION_TLS_URL` on the API | `references/ocpp-settings.md` |
| Run several OCPP servers | `OCPP_INSTANCE_ID` per instance | `references/ocpp-settings.md` |
| Open or approval-based station onboarding | `REGISTRATION_POLICY` at first install, later in the dashboard | `references/environment-variables.md` |
| Allow the test payment provider | `PAYMENTS_ALLOW_SIMULATED=true` on API, OCPP and worker (never in production) | `references/environment-variables.md` |

`references/environment-variables.md` is long: grep it for the variable, for example `grep -n 'OCPP_TLS' references/environment-variables.md`.

## Workflow: change an environment variable

1. Look up the variable, its default and the services that read it.
2. Set it: Docker Compose reads `.env` at the repo root (`docker-compose.yml` has a shell default for each, `${VAR:-default}`). Helm or AWS CDK: the chart value or CDK config key (evtivity-deployment).
3. Restart the services that read it. Compose: `docker compose up -d <service>` recreates a container whose environment changed.
4. Confirm: `docker compose exec <service> printenv <VAR>`, `curl -s http://localhost:7102/v1/health`, and `docker compose logs <service> --tail=50`, which shows a startup error when a value fails validation (each service validates its variables at start and exits on an invalid value).

## Workflow: production secrets

- `JWT_SECRET` signs operator and driver tokens. Always set it: the default is a known development value.
- `SETTINGS_ENCRYPTION_KEY` encrypts every secret setting (`*Enc` keys). The API, OCPP server, OCPI server and worker refuse to start without it. Use the same value in every service, the migrate container included. Use a long random value, for example `openssl rand -base64 32`.
- Set `NODE_ENV=production` in production.

Before you change `SETTINGS_ENCRYPTION_KEY` on an existing install, stop and confirm with the user. Settings encrypted with the old key cannot be decrypted with the new one, so every stored integration credential (payment keys, SMTP and Twilio credentials, TOTP secrets) must be entered again.

## Workflow: authentication and access (`references/authentication.md`)

- Two realms. Operators get the `csms_token` and `csms_refresh` cookies. Drivers get `portal_token`, `portal_refresh` and `portal_csrf` (path `/v1/portal/`). A token from one realm is rejected on the other realm's routes.
- API keys: created per user in the dashboard, sent as `Authorization: Bearer <key>`. A key inherits its creator's role and can be scoped down. Endpoint details: evtivity-api.
- RBAC: permissions use `resource:action` (for example `stations:write`). Write implies read. Default roles are Admin, Operator and Viewer. Manage roles in the dashboard (evtivity-csms).
- MFA: email, TOTP or SMS through Twilio. An admin enables methods system-wide in Settings > Security, then each user enables one. SMS needs Twilio, email needs SMTP. A code is single-use. Five failed attempts return `MFA_CHALLENGE_EXHAUSTED`.
- reCAPTCHA v3: invisible and score-based. Turn it on and enter the site key and secret key in Settings > Security. Turning it on for a host that is not on the site key's domain list blocks every sign-in (fix: evtivity-troubleshoot).
- Sessions: access tokens last 1 hour. Refresh tokens rotate on every use. A reused refresh token returns `401 INVALID_REFRESH_TOKEN`.
- Auth endpoints have their own rate limit: `AUTH_RATE_LIMIT_MAX` per `AUTH_RATE_LIMIT_WINDOW`.

## Workflow: database, migrations and seed (`references/database-setup.md`)

1. Use PostgreSQL 17. Set `DATABASE_URL` (default `postgres://evtivity:evtivity@localhost:5433/evtivity`). Compose publishes Postgres on host port 5433 on 127.0.0.1; `INFRA_BIND_IP` exposes it (see the evtivity-getting-started skill, "Network exposure").
2. Apply migrations with `npm run db:migrate`. In Compose the `migrate` service runs them before the other services start. Helm and CDK run them in a job.
3. Seed with `npm run db:seed`. `SEED_DEMO=true` adds demo sites, stations, sessions and drivers. Re-running adds only what is missing and keeps existing values. `npm run db:seed -- --apply-config` writes `seed.config.json` over existing settings: confirm with the user before running it on a database with real data.
4. Confirm: `psql "$DATABASE_URL" -c 'select 1'` and the API health check.

Connection pools: `DB_POOL_MAX` is per process. Keep the sum across all processes and replicas below Postgres `max_connections`.

Redis carries pub/sub, BullMQ job queues and caches. Each service connects as its own ACL user (`api`, `ocpp`, `ocpi`, `worker`, `css`) through its own `REDIS_URL`. On a shared host, set `REDIS_API_PASSWORD`, `REDIS_OCPP_PASSWORD`, `REDIS_OCPI_PASSWORD`, `REDIS_WORKER_PASSWORD` and `REDIS_CSS_PASSWORD` (URL-safe characters). For `rediss://` with a private CA, set `REDIS_TLS_CA_PEM` or `REDIS_TLS_CA_FILE`.

## Workflow: OCPP server and security profiles (`references/ocpp-settings.md`)

1. Create the station in the dashboard first. The station ID in the URL must match.
2. Station URL: `ws://<host>:7103/<stationId>` or `wss://<host>:8443/<stationId>`. OCPP 1.6 and 2.1 use the same server. The subprotocol header selects the version.
3. Security profile:

| Profile | Name | Port | Needs |
| --- | --- | --- | --- |
| 0 | No Auth | 7103 | Nothing. Development only. |
| 1 | Basic Auth | 7103 | Station password stored in the station record |
| 2 | TLS + Basic Auth | 8443 | Server certificate the station trusts, plus the password |
| 3 | Mutual TLS | 8443 | Server certificate and a client certificate signed by the CA |

4. Profiles 2 and 3: the TLS listener on `OCPP_TLS_PORT` (8443) with `OCPP_TLS_CERT`, `OCPP_TLS_KEY` and `OCPP_TLS_CA` (file paths) or the `*_PEM` variants. One port serves both profiles.
5. To move a connected OCPP 2.1 station from `ws://` to TLS, set `OCPP_STATION_TLS_URL` on the API to the public `wss://` address without the station ID. Unset, the API refuses those upgrades.
6. Confirm: the station shows as connected, and `docker compose logs ocpp` shows the connection.

Limits: `OCPP_MAX_CONNECTIONS_PER_IP` and `OCPP_MAX_MESSAGES_PER_IP_PER_SECOND`. Raise them when many stations share one NAT address. Heartbeat interval and offline command queue TTL are dashboard settings. Horizontal scaling: a unique `OCPP_INSTANCE_ID` per instance (the pod name in Kubernetes).

## Safety

Confirm with the user before you change or rotate `SETTINGS_ENCRYPTION_KEY`, run `npm run db:seed -- --apply-config` on real data, change `DATABASE_URL` on a running install, or set `PAYMENTS_ALLOW_SIMULATED=true` anywhere that is not a test install. Never print secrets back to the user unless they ask. Never commit `.env` files.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer.

- `references/authentication.md`: auth realms, cookies, API keys, RBAC, MFA, reCAPTCHA, CSRF, session lifetimes.
- `references/database-setup.md`: PostgreSQL 17, migration and seed commands, Redis purposes and ACL users.
- `references/environment-variables.md`: every environment variable per service, with defaults.
- `references/ocpp-settings.md`: station URLs, security profiles, TLS, limits, message pipeline, horizontal scaling.
