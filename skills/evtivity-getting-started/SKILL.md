---
name: evtivity-getting-started
description: "Install and run EVtivity CSMS locally with Docker: one setup script stands up the stack, checks health and prints the URLs, ports and demo sign-in. Use to install, stand up, start, try or demo EVtivity on a laptop or one machine, or to learn the code layout. Not for production deploys (evtivity-deployment) or failures (evtivity-troubleshoot)."
license: MIT
compatibility: The setup script needs bash, git, curl, Docker with Docker Compose v2 and Node.js 24 or later with npm (the database seed runs on the host). Linux, macOS, or WSL on Windows.
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39"
  evtivity-commit: "85333dc7da57a2e0b9d74d1d09d448dee313a29b"
  evtivity-docs-section: getting-started
---

# EVtivity getting started

Not for: production installs (use evtivity-deployment), a stack that fails or a station that cannot connect (use evtivity-troubleshoot), changing settings (use evtivity-configuration).

EVtivity CSMS manages EV charging stations over OCPP 1.6 and 2.1. One Docker Compose file runs the whole stack: PostgreSQL, Redis, a migrate job, the REST API, the OCPP server, the worker, the operator dashboard (CSMS), the driver portal and a charging station simulator.

Which path to take:

- Try or demo EVtivity, or run it on one server: the Docker path below (`scripts/setup.sh`).
- Change EVtivity's code: `references/installation.md` (services on the host with hot reload, PostgreSQL and Redis in Docker).
- Production: the evtivity-deployment skill (Helm, AWS CDK, published images).

## Stand up a local stack

`scripts/setup.sh` in this skill's directory does the whole flow. It is safe to rerun.

1. Check the prerequisites and tell the user exactly what is missing:

   ```bash
   bash scripts/setup.sh --check
   ```

   It checks Docker (daemon running, Compose v2), git, curl, Node.js 24 or later with npm, and that ports 5433, 6379, 7100 to 7104 and 8443 are free.

2. Ask the user:
   - Where to put the CSMS checkout. Default: `evtivity-csms` next to the evtivity-skills clone, else `./evtivity-csms`.
   - Optional services: LAN access (`--lan`), dev tools with Mailpit (`--tools`), OCPI roaming (`--ocpi`), monitoring (`--monitoring`), demo data (`--demo`). Default: none.

3. Run it:

   ```bash
   bash scripts/setup.sh --dir /path/to/evtivity-csms [--tools] [--demo]
   ```

   Release: it installs exactly the CSMS release in `metadata.evtivity-release` above, and stops when that tag no longer points to `metadata.evtivity-commit`. When the tag does not exist, it installs the latest stable release. It never installs `main` or a prerelease (alpha or beta) unless the user passes `--tag <tag>`. `--print-release` shows the choice without installing.

   Then it runs `npm ci`, copies `.env.example` to `.env` only when `.env` is missing, runs the repository's `./scripts/docker-build.sh` with the prompts answered from the options, waits until every service is healthy (up to 600 seconds, `--timeout`), and prints the URLs and the sign-in.

4. Exit code 4 means an EVtivity database already exists on this machine. Ask the user whether to keep it (`--keep-data`) or delete it and reseed (`--wipe`), then rerun with that flag. Never choose `--wipe` without the user's answer.

5. Any other failure prints the last log lines. Switch to the evtivity-troubleshoot skill.

The first run builds every image from source and takes several minutes. The Compose project is named `evtivity`, so a second checkout on the same machine replaces the first stack.

## Network exposure

`setup.sh` binds the dashboard, portal, API and OCPP ports to 127.0.0.1 unless you pass `--lan` or `.env` sets `BIND_IP`.

PostgreSQL is different. The release's `docker-compose.yml` publishes it as `5433:5432`, on all interfaces, whatever `BIND_IP` says, with the default login `evtivity` / `evtivity`. Anyone who reaches port 5433 on the host can read and change the database. A later CSMS release will change this default. Until then, on a machine others can reach:

- Bind it to loopback with a `docker-compose.override.yml` next to `docker-compose.yml` (Docker Compose 2.24.4 or later), then `docker compose up -d postgres`:

  ```yaml
  services:
    postgres:
      ports: !override
        - '127.0.0.1:5433:5432'
  ```

- Or block port 5433 in the host firewall.

## Check health

```bash
bash scripts/check-stack.sh --dir /path/to/evtivity-csms
```

It prints each container's state and each endpoint's status and changes nothing. Exit codes: 0 healthy, 1 a container failed or stopped, 2 bad arguments, 3 still starting. Healthy means `migrate` exited with code 0 and every other service runs, healthy where it has a health check (the worker and the simulator have none). Manual checks: `docker compose ps -a`, `curl -s http://localhost:7102/v1/health`, `curl -s http://localhost:7102/v1/version`.

Default URLs (`references/quick-start.md`): dashboard http://localhost:7100, portal http://localhost:7101, API http://localhost:7102 with Swagger UI at `/docs`, OCPP `ws://localhost:7103/<stationId>` and `wss://localhost:8443/<stationId>`, Mailpit http://localhost:7108 with `--tools`.

## First sign-in

- Dashboard: `admin@evtivity.local` / `admin123`, or `INITIAL_ADMIN_EMAIL` and `INITIAL_ADMIN_PASSWORD` from `.env`.
- Driver portal: `driver@evtivity.local` / `driver123`, or the `INITIAL_DRIVER_*` values, or register a new driver.

The `migrate` container creates both accounts on the first start. Before others can reach the host, change these passwords and the `.env` secrets (`JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, `REDIS_*_PASSWORD`). Every variable: the evtivity-configuration skill.

## Next steps

- Demo data: set `SEED_DEMO=true` in `.env` and run `npm run db:seed` in the checkout, or pass `--demo` on a fresh install.
- Simulated stations that charge: `CSS_MODE=chaos docker compose up -d` in the checkout (evtivity-simulator).
- Connect a real station: evtivity-guides. Operate the dashboard: evtivity-csms. Payments: evtivity-integrations. Script it: evtivity-api. OCPP tests: evtivity-conformance.

## Manual Docker path (without setup.sh)

```bash
git clone --branch <release tag> https://github.com/EVtivity/evtivity-csms.git && cd evtivity-csms
docker compose up -d            # works without .env
```

`./scripts/docker-build.sh` is the guided build. It needs `.env` (`cp .env.example .env`) and `npm ci` first. It asks: bind to the LAN IP (skipped when `BIND_IP` is set), dev tools, OCPI, monitoring, and whether to restart postgres and redis (wipes all data and reseeds).

## Stop and reset

```bash
docker compose down              # stop, keep data
docker compose down --volumes    # stop and DELETE all data
```

Confirm with the user before `--volumes`.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer.

- `references/introduction.md`: what EVtivity is, features, architecture, tech stack, license.
- `references/quick-start.md`: Docker-only start, demo accounts, service URLs, profiles, demo data, simulator, LAN access.
- `references/installation.md`: native development with hot reload, `npm run dev:*`, dev tools, database commands.
- `references/project-structure.md`: packages, ports, what the worker does, key directories.
