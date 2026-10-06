---
name: evtivity-setup
description: Stand up the EVtivity CSMS (OCPP charging station management system) locally with Docker Compose, end to end, check that every service is healthy, sign in for the first time, and find the production deployment guides (Helm, AWS CDK). Use when someone wants to install, run, start, deploy, evaluate or demo EVtivity, asks for a local Docker environment, asks which ports or .env values matter, wants demo data or the station simulator, or asks how to move to Kubernetes or AWS.
license: MIT
compatibility: Requires git, Docker with Docker Compose v2, curl, bash and Node.js 24 or later with npm (the database seed runs on the host). Linux or macOS.
metadata:
  evtivity-version: "0.1.39"
---

# EVtivity setup

EVtivity CSMS is an OCPP 1.6 and 2.1 charging station management system. One Docker Compose file runs the whole stack: PostgreSQL, Redis, a migrate job, the REST API, the OCPP server, the worker, the operator dashboard (CSMS), the driver portal and a charging station simulator.

Source: https://github.com/EVtivity/evtivity-csms. Docs: https://www.evtivity.com/docs.

## Stand up a local stack

`scripts/setup.sh` in this skill's directory does the whole flow. It is safe to rerun.

1. Check the prerequisites first and tell the user exactly what is missing:

   ```bash
   bash scripts/setup.sh --check
   ```

   It checks Docker (daemon running, Compose v2), git, curl, Node.js 24 or later with npm, and that ports 5433, 6379, 7100 to 7104 and 8443 are free. Fix what it lists before you go on.

2. Ask the user:
   - Where to put the CSMS checkout. Default: `evtivity-csms` next to the evtivity-skills clone (else `./evtivity-csms`).
   - Optional services: LAN access (`--lan`), dev tools with Mailpit (`--tools`), OCPI roaming (`--ocpi`), monitoring (`--monitoring`), demo data (`--demo`). Default: none of them.

3. Run it:

   ```bash
   bash scripts/setup.sh --dir /path/to/evtivity-csms [--tools] [--demo]
   ```

   What it does:
   - Clones https://github.com/EVtivity/evtivity-csms at the release tag that matches `evtivity-version` in this file. When that tag is not released yet, it takes the newest release of that version line, else the latest stable release. It never installs from `main`. `--tag vX.Y.Z` picks another release.
   - Runs `npm ci`, and copies `.env.example` to `.env` only when `.env` does not exist.
   - Runs the repository's `./scripts/docker-build.sh` and answers its prompts from the options.
   - Waits until every service is healthy (default up to 600 seconds, `--timeout`), then prints the URLs and the sign-in.

4. Exit code 4 means an EVtivity database already exists on this machine. Ask the user whether to keep it (`--keep-data`) or delete it and reseed (`--wipe`), then rerun with that flag. Never pick `--wipe` without the user's answer: it deletes all data.

5. Any other failure: the script prints the last log lines. Switch to the `evtivity-troubleshoot` skill.

The first run builds every image from source and takes several minutes.

## Check health

```bash
bash scripts/check-stack.sh --dir /path/to/evtivity-csms
```

It prints each container's state and each endpoint's status, and changes nothing. Exit 0 means healthy, 1 means a container failed or stopped, 3 means still starting. By hand:

```bash
docker compose ps -a
curl -s http://localhost:7102/v1/health    # {"status":"ok","database":"ok","redis":"ok",...}
curl -s http://localhost:7102/v1/version
```

Expected: `migrate` exited with code 0, every other service running, and healthy where it has a health check (the worker and the simulator have none).

| Service | URL | Profile |
|---|---|---|
| CSMS dashboard | http://localhost:7100 | core |
| Driver portal | http://localhost:7101 | core |
| REST API, Swagger UI | http://localhost:7102, http://localhost:7102/docs | core |
| OCPP WebSocket | ws://localhost:7103/<stationId> | core |
| OCPP WebSocket TLS | wss://localhost:8443/<stationId> | core |
| OCPI | http://localhost:7104 | ocpi |
| Grafana | http://localhost:7107 | monitoring |
| Mailpit (captures all email) | http://localhost:7108 | tools |
| pgAdmin | http://localhost:7109 | tools |
| PostgreSQL | localhost:5433 | core |

`setup.sh` binds to 127.0.0.1 unless you pass `--lan` or set `BIND_IP` in `.env`. A plain `docker compose up -d` binds to all interfaces.

## Sign in

- Dashboard: `admin@evtivity.local` / `admin123`, or the `INITIAL_ADMIN_*` values in `.env`.
- Driver portal: `driver@evtivity.local` / `driver123`, or the `INITIAL_DRIVER_*` values, or register a new driver.

The `migrate` container creates both accounts on the first start. Change the passwords before others can reach the host.

## Configuration that matters

Set these in `.env` before the first start.

| Variable | Default | Change it when |
|---|---|---|
| `BIND_IP` | `0.0.0.0` with plain Compose | `127.0.0.1` keeps the stack on this machine |
| `INITIAL_ADMIN_EMAIL`, `INITIAL_ADMIN_PASSWORD` | `admin@evtivity.local`, `admin123` | Others can reach the host |
| `INITIAL_DRIVER_EMAIL`, `INITIAL_DRIVER_PASSWORD` | `driver@evtivity.local`, `driver123` | Same |
| `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY` | dev values | Shared or public host. Set the encryption key once: stored integration secrets depend on it. |
| `REDIS_API_PASSWORD` and the other `REDIS_*_PASSWORD` | `<service>-dev-password` | Shared host. URL-safe characters only. |
| `SEED_DEMO` | `false` | `true` loads demo sites, stations, sessions and drivers |
| `REGISTRATION_POLICY` | `approval-required` | `open` accepts new stations without approval |
| `CSS_MODE` | `standby` | `chaos` makes the simulator connect stations and run sessions |
| `PAYMENTS_ALLOW_SIMULATED` | `true` | Never `true` in production |
| `CSMS_PORT`, `PORTAL_PORT`, `API_PORT`, `OCPP_PORT`, `OCPI_PORT` | 7100 to 7104 | A port is taken |

Integrations (Stripe, Adyen, SMTP, Twilio, S3, reCAPTCHA, Google Maps) are not environment variables. Configure them in the dashboard under Settings.

## Manual setup (without setup.sh)

```bash
git clone https://github.com/EVtivity/evtivity-csms.git && cd evtivity-csms
git checkout v0.1.39            # a release tag, not main
docker compose up -d            # defaults work without .env
```

Optional profiles: `--profile tools` (pgAdmin, Mailpit, FTP), `--profile ocpi`, `--profile monitoring`.

`./scripts/docker-build.sh` is the guided build. It needs `.env` (`cp .env.example .env`) and `npm ci` first. It asks five questions: bind to the LAN IP (skipped when `BIND_IP` is set), dev tools, OCPI, monitoring, and whether to restart postgres and redis (wipes all data and reseeds).

Demo data on an existing stack: set `SEED_DEMO=true` in `.env`, then `npm run db:seed`. `db:seed` adds missing settings and never changes an existing setting, password, role or template. `npm run db:seed -- --apply-config` applies `packages/database/seed.config.json` to an existing database.

Simulated stations charging: `CSS_MODE=chaos docker compose up -d`.

## Connect a real station

1. Create the station in the dashboard (Stations > Create Station). The station name must equal the OCPP identity in the station's URL.
2. Point the station at `ws://<host>:7103/<stationId>` (security profile 0 or 1) or `wss://<host>:8443/<stationId>` (profile 2 or 3).
3. With `REGISTRATION_POLICY=approval-required`, approve it under Stations, filter Pending.

The Compose TLS certificate is a self-signed test certificate for `localhost` and `ocpp` only. A real station on TLS needs your own certificate (`OCPP_TLS_CERT`, `OCPP_TLS_KEY`, `OCPP_TLS_CA`). Guide: https://www.evtivity.com/docs/guides/station-onboarding.

To script stations, sessions or settings, use the REST API. The `evtivity-api` skill covers authentication, API keys and examples.

## Production

Docker Compose is for development, evaluation and demos. For production:

- Kubernetes: Helm chart at https://github.com/EVtivity/evtivity-csms-helm. Docs: https://www.evtivity.com/docs/deployment/helm-chart.
- AWS: CDK app at https://github.com/EVtivity/evtivity-csms-cdk. Docs: https://www.evtivity.com/docs/deployment/aws.

Both deploy the published images (`ghcr.io/evtivity/api`, `ocpp`, `worker`, `csms`, `portal`, `ocpi`, `css`, `migrate`). Pin a numbered image tag, not `latest`. Read the release notes before each upgrade: https://github.com/EVtivity/evtivity-csms/releases.

## Stop and reset

```bash
docker compose down              # stop, keep data
docker compose down --volumes    # stop and DELETE all data
```

Confirm with the user before `--volumes`.
