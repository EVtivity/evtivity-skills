Generated from https://www.evtivity.com/docs/getting-started/installation (website commit 257c8b8). Do not edit.

# Installation

Set up EVtivity CSMS for local development with hot reload.

This guide sets up native development with hot reload. Services run directly on your machine with live code reloading. PostgreSQL and Redis run in Docker.

For a quick Docker-only setup, see [Quick Start](https://www.evtivity.com/docs/getting-started/quick-start).

## Prerequisites

- Node.js 24 or later
- Docker Desktop (for PostgreSQL and Redis)

## 1. Clone and install

```bash
git clone https://github.com/evtivity/evtivity-csms.git
cd evtivity-csms
npm install
cp .env.example .env
```

The `.env` file is required for the local dev scripts. The defaults in `.env.example` work out of the box. Edit later if you need to override a value.

## 2. Start infrastructure

```bash
npm run dev:infra
```

This starts PostgreSQL, Redis, runs database migrations, and launches dev tools (Mailpit, Prometheus, Grafana, Loki). Migrations are idempotent and never wipe data. Wait for the migrate container to exit before starting services.

## 3. Seed the database

The migrate step runs schema migrations only. Seed the admin user (and optional demo data) explicitly:

```bash
npm run db:seed
```

`db:seed` reads `SEED_DEMO` from your `.env` file. Set `SEED_DEMO=false` (default) for a clean install with only the admin user. Set `SEED_DEMO=true` to also load demo stations, sessions, drivers, and payments.

> **Warning:**
>
> Re-running `db:seed` adds only missing settings, roles, and users. It keeps existing settings, the admin password, and role permissions. Stations, sessions, and drivers are not deleted. `npm run db:seed -- --apply-config` writes the values from `packages/database/seed.config.json` over existing settings, and dashboard changes to those settings are lost.

## 4. Start services

Open a separate terminal for each service you need:

```bash
npm run dev:api          # REST API with hot reload
npm run dev:ocpp         # OCPP WebSocket server with hot reload
npm run dev:worker       # Background job processor (required, see below)
npm run dev:csms         # Operator dashboard (Vite dev server)
npm run dev:portal       # Driver portal (Vite dev server)
```

`dev:worker` is **required** alongside `dev:api`. It owns guest charging session linking and payment finalization, scheduled cron jobs (payment reconciliation, dashboard snapshots, stale-session cleanup, guest-session expiry, tariff boundary checks), site-level load management, future-dated reservation activation, and OCTT conformance test runs. The API runs in multiple replicas in production, so this work is centralized in the worker for idempotency. Without `dev:worker`, guest charging hangs in "Starting Charger…" forever and several other features silently misbehave. See [Project Structure](https://www.evtivity.com/docs/getting-started/project-structure) for the full breakdown.

Additional services are optional:

```bash
npm run dev:css          # Charging station simulator
npm run dev:ocpi         # OCPI roaming server
```

## 5. Open in browser

| Service | URL | Credentials |
|---|---|---|
| CSMS dashboard | http://localhost:7100 | admin@evtivity.local / admin123 |
| Driver portal | http://localhost:7101 | Register a new account |
| API docs | http://localhost:7102/docs | - |

Auto-login is enabled by default in development. The `.env.example` file has `VITE_CSMS_AUTO_LOGIN` and `VITE_PORTAL_AUTO_LOGIN` set to skip the login page. Remove these lines to test the login flow.

## All services

| Command | Service | Port |
|---|---|---|
| `npm run dev:infra` | PostgreSQL, Redis, migrations, monitoring | 5433, 6379 |
| `npm run dev:api` | REST API | 7102 |
| `npm run dev:ocpp` | OCPP WebSocket server | 7103 |
| `npm run dev:worker` | Background job processor (required for guest charging) | - |
| `npm run dev:csms` | Operator dashboard (Vite) | 7100 |
| `npm run dev:portal` | Driver portal (Vite) | 7101 |
| `npm run dev:css` | Charging station simulator | - |
| `npm run dev:ocpi` | OCPI roaming server | 7104 |

## Dev tools

Started automatically by `npm run dev:infra`:

| Tool | URL | Credentials |
|---|---|---|
| Grafana | http://localhost:7107 | admin / admin |
| Mailpit | http://localhost:7108 | - |
| Prometheus | http://localhost:9090 | - |

## Database commands

```bash
npm run db:migrate       # Apply pending migrations
npm run db:seed          # Add missing seed data (keeps existing settings, respects SEED_DEMO env var)
npm run db:generate      # Generate migration from schema changes
```

## Code quality

```bash
npm run typecheck        # TypeScript type checking
npm run lint             # ESLint
npm test                 # Unit tests (Vitest)
npm run test:integration # Integration tests (requires running database)
```

## Environment variables

The `.env` file (created in step 1) provides default values for every environment variable used by the local dev scripts. Edit it to override database URLs, ports, secrets, or feature toggles. See [Environment Variables](https://www.evtivity.com/docs/configuration/environment-variables) for the full reference.

## Stopping

Stop infrastructure:

```bash
npm run dev:infra:down
```

Stop individual services with Ctrl+C in each terminal.

## Next steps

- [Project Structure](https://www.evtivity.com/docs/getting-started/project-structure) for codebase orientation
- [Environment Variables](https://www.evtivity.com/docs/configuration/environment-variables) for configuration options
- [Database Setup](https://www.evtivity.com/docs/configuration/database-setup) for advanced database configuration
