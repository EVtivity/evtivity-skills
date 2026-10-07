Generated from https://www.evtivity.com/docs/getting-started/quick-start. Do not edit.

# Quick Start

Run EVtivity CSMS locally with Docker in under 5 minutes.

## Prerequisites

- [Docker Desktop](https://docs.docker.com/get-docker/) (includes Docker Compose)

## 1. Clone and start

```bash
git clone https://github.com/evtivity/evtivity-csms.git
cd evtivity-csms
docker compose up -d
```

No `.env` file needed. All defaults work out of the box.

Wait about 60 seconds for the database to migrate and all services to become healthy. Check status with:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## 2. Open the dashboard

Go to [http://localhost:7100](http://localhost:7100) and log in:

- **Email**: `admin@evtivity.local`
- **Password**: `admin123`

## 3. Open the driver portal

Go to [http://localhost:7101](http://localhost:7101) and register a new driver account, or log in with a seeded driver:

- **Email**: `driver@evtivity.local`
- **Password**: `driver123`

## Services

| Service | URL |
|---|---|
| CSMS dashboard | [http://localhost:7100](http://localhost:7100) |
| Driver portal | [http://localhost:7101](http://localhost:7101) |
| REST API | http://localhost:7102 |
| OCPP WebSocket | ws://localhost:7103 |
| OCPP WebSocket TLS | wss://localhost:8443 |
| OCPI | http://localhost:7104 |

## Load demo data

The migrate container runs schema migrations only. Seed the database explicitly with the npm script:

```bash
npm run db:seed
```

This honors `SEED_DEMO` in your `.env` file. Set `SEED_DEMO=false` (default) to seed only the admin user. Set `SEED_DEMO=true` to also load demo stations, sessions, drivers, and payments.

> **Warning:**
>
> Re-running `db:seed` adds only what is missing and keeps existing settings, the admin password, and roles. `npm run db:seed -- --apply-config` writes the values from `packages/database/seed.config.json` over existing settings, and dashboard changes to those settings are lost.

## Enable the charging station simulator

The simulator connects virtual stations to the OCPP server. It starts in standby mode by default. To activate it:

```bash
CSS_MODE=chaos docker compose up -d
```

## Optional services

Add profiles for additional services:

```bash
# Dev tools (pgAdmin, Mailpit, FTP)
docker compose --profile tools up -d

# OCPI roaming (OCPI server + simulators)
docker compose --profile ocpi up -d

# Monitoring (Prometheus, Grafana, Loki, Alloy)
docker compose --profile monitoring up -d

# Everything
docker compose --profile tools --profile ocpi --profile monitoring up -d
```

| Service | URL | Profile |
|---|---|---|
| Grafana | http://localhost:7107 (admin/admin) | monitoring |
| Mailpit | http://localhost:7108 | tools |
| pgAdmin | http://localhost:7109 | tools |
| Prometheus | http://localhost:9090 | monitoring |

## Access from other devices

By default, the user-facing services (dashboard, portal, API, OCPP, OCPI) bind to `0.0.0.0` (all network interfaces). Other devices on your network can access the dashboard at `http://YOUR_IP:7100`. Infrastructure and tool ports (PostgreSQL, pgAdmin, Mailpit, FTP, Prometheus, Grafana, Loki) bind to `127.0.0.1` unless you set `INFRA_BIND_IP` in `.env`. See [Docker Compose](https://www.evtivity.com/docs/deployment/docker-compose#port-binding).

To bind to your current LAN IP automatically:

```bash
BIND_IP=$(ipconfig getifaddr en0) docker compose up -d
```

On Linux, use `hostname -I | awk '{print $1}'` instead of `ipconfig getifaddr en0`.

To restrict access to localhost only, create a `.env` file:

```bash
BIND_IP=127.0.0.1
```

## Stop

```bash
docker compose down
```

Add `--volumes` to also delete the database data.

## Next steps

- [Installation](https://www.evtivity.com/docs/getting-started/installation) for local development with hot reload
- [Project Structure](https://www.evtivity.com/docs/getting-started/project-structure) for codebase orientation
- [Dashboard](https://www.evtivity.com/docs/csms/dashboard) to explore the operator interface
