Generated from https://www.evtivity.com/docs/configuration/environment-variables (website commit 257c8b8). Do not edit.

# Environment Variables

All environment variables for EVtivity CSMS, organized by service.

Copy `.env.example` to `.env` at the repo root. The defaults work for local development. Production deployments require you to set secrets and URLs explicitly.

When adding a new environment variable, update all 5 locations: Zod config schema, `.env.example`, `docker-compose.yml`, Helm `values.yaml`, and Helm `configmap.yaml`.

## Network

| Variable | Default | Description |
|---|---|---|
| `BIND_IP` | `0.0.0.0` | IP address to bind Docker ports to. Use `0.0.0.0` for all interfaces (accessible from other machines) or `127.0.0.1` for localhost only. |

## Database and Redis

| Variable | Default | Description |
|---|---|---|
| `DATABASE_URL` | `postgres://evtivity:evtivity@localhost:5433/evtivity` | PostgreSQL connection string |
| `DB_POOL_MAX` | `20` | Connections each process pools (api, ocpp, ocpi, worker; the simulator defaults to `10`). Keep the sum over all processes below the PostgreSQL `max_connections` (docker-compose sets `200`). The OCPP server authenticates at most half its pool of station connections at once. |
| `REDIS_URL` | `redis://localhost:6379` | Redis connection string for pub/sub, queues, and caching. In Docker Compose, Helm, and AWS each service connects as its own ACL user (`redis://<user>:<password>@host:6379`) |
| `REDIS_TLS_CA_PEM` | - | CA certificate (PEM) that signed the Redis server certificate, for a `rediss://` URL with a private CA. The Helm chart sets it when `redisTls.enabled` |
| `REDIS_TLS_CA_FILE` | - | Path to that CA certificate, as an alternative to `REDIS_TLS_CA_PEM` |
| `SEED_DEMO` | `false` | Read by `npm run db:seed`. Set to `true` to populate demo data (stations, sessions, drivers) when seeding. When `false`, only settings, roles, and the admin user are created. The migrate container does not auto-seed; seeding is always explicit. |
| `SEED_CSS_TARGET_URL` | `ws://ocpp:7103` | Override for the OCPP URL written to simulator station rows by the demo seed, as reachable from the simulator container. |
| `SEED_CSS_TLS_TARGET_URL` | `wss://ocpp:8443` | TLS variant of the seeded simulator target URL. |
| `REGISTRATION_POLICY` | `approval-required` | Station onboarding policy at first install. `approval-required` or `open`. Change later via dashboard, API, or Helm. |

## Initial Seed Credentials

Created by the migrate container's seed steps on first `docker compose up -d`. Idempotent: subsequent runs do not overwrite existing rows. Override these before bringing up the stack in any non-local environment.

| Variable | Default | Description |
|---|---|---|
| `INITIAL_ADMIN_EMAIL` | `admin@evtivity.local` | Email for the initial admin user |
| `INITIAL_ADMIN_PASSWORD` | `admin123` | Password for the initial admin user |
| `INITIAL_ADMIN_MUST_RESET_PASSWORD` | `false` | Force a password change on the admin's first login |
| `INITIAL_DRIVER_EMAIL` | `driver@evtivity.local` | Email for the initial portal driver |
| `INITIAL_DRIVER_PASSWORD` | `driver123` | Password for the initial portal driver |

## API Server

| Variable | Default | Description |
|---|---|---|
| `API_PORT` | `7102` | HTTP port for the REST API |
| `API_HOST` | `0.0.0.0` | Bind address |
| `JWT_SECRET` | `dev-secret-change-in-production` | Secret for signing JWTs. Always set it in production: the default is a known development value. |
| `CORS_ORIGIN` | `*` | Allowed CORS origins. Comma-separated for multiple. |
| `SETTINGS_ENCRYPTION_KEY` | - | Any non-empty value. The AES-256-GCM key for sensitive settings is derived from it with scrypt. Use a long random value (32 characters or more). Required; the API refuses to start without it. |
| `LOG_LEVEL` | `info` | Log verbosity: `trace`, `debug`, `info`, `warn`, `error`, `fatal` |
| `NODE_ENV` | `development` | `development`, `production`, or `test`. Set `production` in production. |
| `RATE_LIMIT_MAX` | `3000` | Max requests per window for general endpoints |
| `RATE_LIMIT_WINDOW` | `1 minute` | Time window for rate limiting |
| `AUTH_RATE_LIMIT_MAX` | `30` | Max requests per window for auth endpoints |
| `AUTH_RATE_LIMIT_WINDOW` | `1 minute` | Time window for auth endpoint rate limiting |
| `METRICS_PORT` | `9091` | Prometheus metrics endpoint port |
| `CSMS_URL` | `http://localhost:7100` | Public URL of the CSMS frontend |
| `PORTAL_URL` | `http://localhost:7101` | Public URL of the driver portal |
| `COOKIE_DOMAIN` | - | Domain for auth cookies. Set for cross-subdomain cookies. |
| `OCPP_STATION_TLS_URL` | - | Public `wss://` address of the OCPP TLS endpoint, without the station ID. Used when upgrading a connected OCPP 2.1 station from `ws://` to TLS (TLS + Basic Auth or Mutual TLS). Unset: those upgrades are refused. |

## Worker

| Variable | Default | Description |
|---|---|---|
| `API_BASE_URL` | `http://localhost:7102` | Base URL the worker uses to call the API (conformance test runs) |
| `OCPP_SERVER_URL` | `ws://localhost:7103` | OCPP server URL the worker connects to (conformance test runs) |
| `OCTT_OCSP_RESPONDER_URL` | - | URL at which the OCPP server reaches the test OCSP responder the worker starts for a conformance run. Unset: the OCSP tests are skipped. |

## OCPP Server

| Variable | Default | Description |
|---|---|---|
| `OCPP_PORT` | `7103` | WebSocket port for OCPP connections |
| `OCPP_HOST` | `0.0.0.0` | Bind address |
| `OCPP_HEALTH_PORT` | `8081` | Health check endpoint port |
| `OCPP_TLS_PORT` | `8443` | TLS WebSocket port for TLS + Basic Auth and Mutual TLS connections |
| `OCPP_TLS_CERT` | - | Path to TLS certificate file |
| `OCPP_TLS_KEY` | - | Path to TLS private key file |
| `OCPP_TLS_CA` | - | Path to CA certificate file for client cert validation |
| `OCPP_TLS_CERT_PEM` | - | Inline PEM certificate content. Alternative to `OCPP_TLS_CERT` when secrets are injected as environment variables. |
| `OCPP_TLS_KEY_PEM` | - | Inline PEM private key content |
| `OCPP_TLS_CA_PEM` | - | Inline PEM CA certificate content |
| `OCPP_MAX_CONNECTIONS_PER_IP` | `2500` | Max concurrent WebSocket connections per IP |
| `OCPP_MAX_MESSAGES_PER_IP_PER_SECOND` | `5000` | Rate limit for OCPP messages per IP |
| `OCPP_INSTANCE_ID` | - | Unique pod identifier for horizontal scaling. Typically set from pod name. |

## OCPI Server

| Variable | Default | Description |
|---|---|---|
| `OCPI_PORT` | `7104` | HTTP port for the OCPI server |
| `OCPI_HOST` | `0.0.0.0` | Bind address |
| `OCPI_BASE_URL` | `http://localhost:7104` | Public base URL for OCPI endpoints |
| `OCPI_COUNTRY_CODE` | `US` | ISO 3166-1 alpha-2 country code |
| `OCPI_PARTY_ID` | `EVT` | Three-character party identifier |
| `OCPI_BUSINESS_NAME` | `EVtivity` | Business name sent in OCPI credentials |
| `OCPI_WEBSITE` | - | Website URL sent in OCPI credentials |

## OCPI Simulator

A standalone eMSP/CPO partner simulator for testing OCPI roaming.

| Variable | Default | Description |
|---|---|---|
| `OCPI_SIM_PORT` | `7105` | HTTP port for the simulator |
| `OCPI_SIM_HOST` | `0.0.0.0` | Bind address |
| `OCPI_SIM_BASE_URL` | `http://localhost:7105` | Public base URL the simulator advertises |
| `OCPI_SIM_ROLE` | `emsp` | Simulator role: `emsp` or `cpo` |
| `OCPI_SIM_COUNTRY_CODE` | `NL` | ISO 3166-1 alpha-2 country code |
| `OCPI_SIM_PARTY_ID` | `SIM` | Three-character party identifier |
| `OCPI_SIM_NAME` | `OCPI Simulator` | Display name sent in credentials |
| `OCPI_TARGET_URL` | - | OCPI server URL to auto-register against on startup |
| `OCPI_REGISTRATION_TOKEN` | - | Registration token for auto-registration. Must match a seeded or API-created partner. |
| `OCPI_SIM_INCOMING_REG_TOKEN` | - | Restrict inbound registration to a specific token |
| `OCPI_SIM_AUTO_SESSION` | `false` | CPO role only. Automatically generate charging sessions. |
| `OCPI_SIM_SESSION_INTERVAL` | `60` | Seconds between auto-generated sessions |
| `OCPI_SIM_SESSION_DURATION` | `30` | Duration of each auto-generated session in seconds |

## Payments

Read by the API, OCPP server, and worker.

| Variable | Default | Description |
|---|---|---|
| `PAYMENTS_ALLOW_SIMULATED` | `true` when `NODE_ENV` is `development`, `test`, or unset, otherwise `false` | Allows the test (simulated) payment provider, which moves no money. Docker Compose sets `true`. Required for demo data. Never enable it in production. See [Payment Providers](https://www.evtivity.com/docs/integrations/test-payment-provider). |

## Integrations

Integrations (Stripe, S3, SMTP, Twilio, reCAPTCHA, Google Maps, Plug and Charge) are configured in the dashboard Settings page, including the Stripe webhook signing secret. There is no `STRIPE_WEBHOOK_SECRET` environment variable. Credentials are stored AES-256-GCM encrypted in the database. One environment variable remains:

| Variable | Default | Description |
|---|---|---|
| `SMTP_HOST` | - | Overrides the SMTP host setting from the database when set |

## Charging Station Simulator

| Variable | Default | Description |
|---|---|---|
| `CSS_MODE` | `standby` | Simulator mode on startup: `standby` or `chaos` |
| `CSS_HEALTH_PORT` | `8082` | Health check endpoint port |
| `CSS_ACTION_INTERVAL_MS` | `1000` | Milliseconds between simulated actions. Docker Compose sets `3000` when `.env` does not set it. |
| `CSS_STATION_LIMIT` | `0` | Max stations to simulate. 0 for unlimited. |
| `CSS_STATION_PASSWORD` | `password` | Not used. Each simulated station presents the password stored on its simulator record. |
| `OCPP_SERVER_URL` | `ws://localhost:7103` | OCPP server URL the simulator connects to |
| `OCPP_TLS_SERVER_URL` | `wss://localhost:8443` | TLS OCPP server URL for TLS + Basic Auth and Mutual TLS stations |
| `TLS_REJECT_UNAUTHORIZED` | `false` | Enable TLS certificate validation. Set to `true` for CA-signed certificates. |
| `CSS_CLIENT_CERT` | - | Path to client certificate file for Mutual TLS stations |
| `CSS_CLIENT_KEY` | - | Path to client private key file |
| `CSS_CA_CERT` | - | Path to CA certificate file |
| `CSS_CLIENT_CERT_PEM` | - | Inline PEM client certificate content. Alternative to `CSS_CLIENT_CERT`. |
| `CSS_CLIENT_KEY_PEM` | - | Inline PEM client private key content |
| `CSS_CA_PEM` | - | Inline PEM CA certificate content |

## Frontend

| Variable | Default | Description |
|---|---|---|
| `CSMS_PORT` | `7100` | Host port for the CSMS dashboard |
| `PORTAL_PORT` | `7101` | Host port for the driver portal |
| `VITE_CSMS_AUTO_LOGIN` | - | Set to a user email to auto-login to the CSMS in development |
| `VITE_PORTAL_AUTO_LOGIN` | - | Set to a driver email to auto-login to the portal in development |

Frontend variables must be prefixed with `VITE_` to be exposed to the browser bundle.
