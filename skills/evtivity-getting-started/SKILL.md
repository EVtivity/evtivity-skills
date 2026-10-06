---
name: evtivity-getting-started
description: Get started with the EVtivity CSMS (OCPP 1.6 and 2.1 charging station management system). Stands up a complete local Docker Compose environment end to end with one script (prerequisites, release checkout, npm ci, .env, build, seed, health wait, sign-in), checks stack health, and explains the docs pages of the getting-started section, the introduction (what EVtivity is, features, architecture, tech stack, license), quick start (Docker in minutes, demo accounts, ports, profiles, demo data, simulator), installation (native development with hot reload, npm run dev scripts, dev tools) and project structure (packages, worker responsibilities). Use when someone wants to install, run, start, try, evaluate or demo EVtivity, asks for a local Docker environment, asks which ports, URLs or sign-in to use, or wants to understand how the codebase is organized.
license: MIT
compatibility: The setup script needs bash, git, curl, Docker with Docker Compose v2 and Node.js 24 or later with npm (the database seed runs on the host). Linux or macOS.
metadata:
  evtivity-version: "0.1.39"
  evtivity-docs-section: getting-started
---

# EVtivity getting started

EVtivity CSMS manages EV charging stations over OCPP 1.6 and 2.1. One Docker Compose file runs the whole stack: PostgreSQL, Redis, a migrate job, the REST API, the OCPP server, the worker, the operator dashboard (CSMS), the driver portal and a charging station simulator.

## Docs pages in this section

The website is the source of truth. Read the page that fits the question.

| Page id | Read it for |
|---|---|
| `getting-started/introduction` | What EVtivity is, features, architecture, tech stack, license. https://www.evtivity.com/docs/getting-started/introduction |
| `getting-started/quick-start` | Docker-only start, demo accounts, service URLs, profiles, demo data, simulator, LAN access. https://www.evtivity.com/docs/getting-started/quick-start |
| `getting-started/installation` | Native development with hot reload: `npm run dev:*`, dev tools, database commands. https://www.evtivity.com/docs/getting-started/installation |
| `getting-started/project-structure` | Packages, ports, what the worker does, key directories. https://www.evtivity.com/docs/getting-started/project-structure |

Which path to take:

- Try or demo EVtivity, or run it on one server: the Docker path below (`scripts/setup.sh`).
- Change EVtivity's code: `getting-started/installation` (services on the host with hot reload, PostgreSQL and Redis in Docker).
- Production: the `evtivity-deployment` skill (Helm, AWS CDK, published images).

## Stand up a local stack

`scripts/setup.sh` in this skill's directory does the whole flow. It is safe to rerun.

1. Check the prerequisites and tell the user exactly what is missing:

   ```bash
   bash scripts/setup.sh --check
   ```

   It checks Docker (daemon running, Compose v2), git, curl, Node.js 24 or later with npm, and that ports 5433, 6379, 7100 to 7104 and 8443 are free. Fix what it lists first.

2. Ask the user:
   - Where to put the CSMS checkout. Default: `evtivity-csms` next to the evtivity-skills clone, else `./evtivity-csms`.
   - Optional services: LAN access (`--lan`), dev tools with Mailpit (`--tools`), OCPI roaming (`--ocpi`), monitoring (`--monitoring`), demo data (`--demo`). Default: none.

3. Run it:

   ```bash
   bash scripts/setup.sh --dir /path/to/evtivity-csms [--tools] [--demo]
   ```

   It clones https://github.com/EVtivity/evtivity-csms at the release tag that matches `evtivity-version` in this file. When that release does not exist yet, it takes the newest release of that version line, else the latest stable release. It never installs from `main`. `--tag vX.Y.Z` picks another release. Then it runs `npm ci`, copies `.env.example` to `.env` only when `.env` is missing, runs the repository's `./scripts/docker-build.sh` with the prompts answered from the options, waits until every service is healthy (up to 600 seconds, `--timeout`), and prints the URLs and the sign-in.

4. Exit code 4 means an EVtivity database already exists on this machine. Ask the user whether to keep it (`--keep-data`) or delete it and reseed (`--wipe`), then rerun with that flag. Never choose `--wipe` without the user's answer.

5. Any other failure prints the last log lines. Switch to the `evtivity-troubleshoot` skill.

The first run builds every image from source and takes several minutes. The Compose project is named `evtivity`, so a second checkout on the same machine replaces the first stack.

## Check health

```bash
bash scripts/check-stack.sh --dir /path/to/evtivity-csms
```

It prints each container's state and each endpoint's status and changes nothing. Exit 0 means healthy, 1 a container failed or stopped, 3 still starting. Healthy means `migrate` exited with code 0 and every other service runs, healthy where it has a health check (the worker and the simulator have none). Quick manual checks: `docker compose ps -a`, `curl -s http://localhost:7102/v1/health`, `curl -s http://localhost:7102/v1/version`.

Default URLs (from `getting-started/quick-start`): dashboard http://localhost:7100, portal http://localhost:7101, API http://localhost:7102 with Swagger UI at `/docs`, OCPP `ws://localhost:7103/<stationId>` and `wss://localhost:8443/<stationId>`, Mailpit http://localhost:7108 with `--tools`. `setup.sh` binds to 127.0.0.1 unless you pass `--lan` or `.env` sets `BIND_IP`.

## First sign-in

- Dashboard: `admin@evtivity.local` / `admin123`, or `INITIAL_ADMIN_EMAIL` and `INITIAL_ADMIN_PASSWORD` from `.env`.
- Driver portal: `driver@evtivity.local` / `driver123`, or the `INITIAL_DRIVER_*` values, or register a new driver.

The `migrate` container creates both accounts on the first start. Before others can reach the host, change these passwords and the `.env` secrets (`JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, `REDIS_*_PASSWORD`). Every variable: `configuration/environment-variables` (https://www.evtivity.com/docs/configuration/environment-variables), see the `evtivity-configuration` skill.

## Next steps

- Demo data: set `SEED_DEMO=true` in `.env` and run `npm run db:seed` in the checkout, or pass `--demo` on a fresh install. `db:seed` adds missing settings and never changes existing settings, passwords, roles or templates.
- Simulated stations that charge: `CSS_MODE=chaos docker compose up -d` in the checkout. See the `evtivity-simulator` skill.
- Connect a real station and approve it: the `evtivity-guides` skill (`guides/station-onboarding`).
- Operate the dashboard: the `evtivity-csms` skill. Driver side: `evtivity-portal` and `evtivity-mobile-app`.
- Payments: the `evtivity-integrations` skill.
- Script it: the `evtivity-api` skill.
- Test OCPP and run conformance tests: the `evtivity-conformance` skill.
- Production: the `evtivity-deployment` skill.

## Manual Docker path (without setup.sh)

```bash
git clone https://github.com/EVtivity/evtivity-csms.git && cd evtivity-csms
git checkout v0.1.39            # a release tag, not main
docker compose up -d            # works without .env
```

`./scripts/docker-build.sh` is the guided build. It needs `.env` (`cp .env.example .env`) and `npm ci` first. It asks: bind to the LAN IP (skipped when `BIND_IP` is set), dev tools, OCPI, monitoring, and whether to restart postgres and redis (wipes all data and reseeds).

## Stop and reset

```bash
docker compose down              # stop, keep data
docker compose down --volumes    # stop and DELETE all data
```

Confirm with the user before `--volumes`.

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `getting-started/installation` | `references/installation.md` | https://www.evtivity.com/docs/getting-started/installation |
| `getting-started/introduction` | `references/introduction.md` | https://www.evtivity.com/docs/getting-started/introduction |
| `getting-started/project-structure` | `references/project-structure.md` | https://www.evtivity.com/docs/getting-started/project-structure |
| `getting-started/quick-start` | `references/quick-start.md` | https://www.evtivity.com/docs/getting-started/quick-start |
