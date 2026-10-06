<p align="center">
  <img src="assets/evtivity-logo.svg" alt="EVtivity" width="80" height="80" />
</p>

<h1 align="center">EVtivity Agent Skills</h1>

<p align="center">
  <a href="https://github.com/EVtivity/evtivity-skills/releases/latest"><img src="https://img.shields.io/github/v/release/EVtivity/evtivity-skills?label=Release&color=4ade80" alt="Release" /></a>
  <a href="https://github.com/EVtivity/evtivity-skills/actions/workflows/validate.yml"><img src="https://github.com/EVtivity/evtivity-skills/actions/workflows/validate.yml/badge.svg" alt="Validate" /></a>
  <a href="https://github.com/EVtivity/evtivity-skills/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT" /></a>
  <a href="https://agentskills.io"><img src="https://img.shields.io/badge/Agent%20Skills-open%20standard-4ade80.svg" alt="Agent Skills" /></a>
  <img src="https://img.shields.io/badge/Skills-13-4ade80.svg" alt="Skills: 13" />
  <img src="https://img.shields.io/badge/Agents-Claude%20Code%20%7C%20Codex%20%7C%20Copilot%20%7C%20Gemini%20%7C%20Cursor-lightgrey.svg" alt="Agents" />
</p>

<p align="center">
  <a href="https://github.com/EVtivity/evtivity-csms">EVtivity CSMS</a> ·
  <a href="https://www.evtivity.com/docs">Documentation</a> ·
  <a href="https://github.com/EVtivity/evtivity-csms-helm">Helm chart</a> ·
  <a href="https://github.com/EVtivity/evtivity-mobile-app">Mobile app</a>
</p>

Agent Skills for the [EVtivity CSMS](https://github.com/EVtivity/evtivity-csms), the OCPP 1.6 and 2.1 charging station management system. They teach a coding agent to stand up EVtivity, configure, deploy, operate and test it, call its API, troubleshoot it and report issues.

The skills follow the [Agent Skills](https://agentskills.io) format, so they work with Claude Code, OpenAI Codex, GitHub Copilot, Gemini CLI, Cursor and other agents that read `SKILL.md`.

## Installation

### Install all skills

```bash
npx skills add EVtivity/evtivity-skills
```

The [skills CLI](https://github.com/vercel-labs/skills) asks which agents to install for. Pick them with `-a` (`claude-code`, `codex`, `github-copilot`, `gemini-cli`, `cursor`, `opencode`, `windsurf`, `junie`, `cline`), install for your user instead of the project with `-g`, and skip the prompts with `-y`:

```bash
npx skills add EVtivity/evtivity-skills -a claude-code -a codex -g -y
```

### Install a specific skill

```bash
npx skills add EVtivity/evtivity-skills --skill evtivity-getting-started
npx skills add EVtivity/evtivity-skills --skill evtivity-csms
```

Update installed skills with `npx skills update`.

### Claude Code plugin

```bash
# 1. Add the EVtivity marketplace
claude plugin marketplace add EVtivity/evtivity-skills

# 2. Install the plugins you want
claude plugin install evtivity-getting-started@evtivity-skills
claude plugin install evtivity-csms@evtivity-skills
claude plugin install evtivity-troubleshoot@evtivity-skills
```

Every skill below is a plugin with the same name. In a Claude Code session, use `/plugin marketplace add EVtivity/evtivity-skills` and `/plugin install <plugin>@evtivity-skills`. Update with `claude plugin marketplace update evtivity-skills`.

### GitHub CLI

GitHub CLI 2.90 or later installs one skill for Copilot or another agent:

```bash
gh skill install EVtivity/evtivity-skills evtivity-getting-started
gh skill install EVtivity/evtivity-skills evtivity-csms --agent claude-code --scope user
```

### Manual install

Copy the directories under `skills/` into the folder your agent reads:

| Agent | Project folder | Personal folder |
|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` |
| OpenAI Codex | `.agents/skills/` | `~/.agents/skills/` |
| GitHub Copilot | `.github/skills/`, `.agents/skills/` or `.claude/skills/` | `~/.copilot/skills/` or `~/.agents/skills/` |
| Gemini CLI | `.gemini/skills/` or `.agents/skills/` | `~/.gemini/skills/` or `~/.agents/skills/` |
| Cursor | `.cursor/skills/` or `.agents/skills/` | `~/.cursor/skills/` or `~/.agents/skills/` |

Sources: [Claude Code](https://code.claude.com/docs/en/skills), [Codex](https://developers.openai.com/codex/skills), [GitHub Copilot](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills), [Gemini CLI](https://geminicli.com/docs/cli/skills/), [Cursor](https://cursor.com/docs/context/skills). Gemini CLI can also install from Git: `gemini skills install https://github.com/EVtivity/evtivity-skills.git --path skills/evtivity-getting-started`.

### Clone and open

```bash
git clone https://github.com/EVtivity/evtivity-skills.git
cd evtivity-skills
```

Open your agent in the clone. `.claude/skills` and `.agents/skills` point to `skills/`, so the skills load without an install. Then ask: "Stand up EVtivity locally with Docker."

### Codex and Cursor plugins

The repository is also a plugin for Codex (`.codex-plugin/plugin.json`, with the repo marketplace in `.agents/plugins/marketplace.json`) and for Cursor (`.cursor-plugin/plugin.json` and `marketplace.json`). Each installs all skills as one `evtivity` plugin. `plugin.json` at the root is the portable manifest (https://agent-plugins.org).

### Windows

- The discovery links `.claude/skills` and `.agents/skills` are symbolic links. Git for Windows creates them only with `core.symlinks=true` and Windows Developer Mode on (or an elevated shell): `git clone -c core.symlinks=true https://github.com/EVtivity/evtivity-skills.git`. Without them, install with `npx skills add EVtivity/evtivity-skills`, which copies the skill directories.
- The scripts (`setup.sh`, `check-stack.sh`, `diagnose.sh`) need bash. Run them in WSL or Git Bash. Docker Desktop with the WSL 2 backend works with WSL.

### Pin a version

Release tags match EVtivity CSMS releases: `v0.1.39` for stable, `v0.1.39-alpha.N`, `v0.1.39-beta.N` and `v0.1.39-nightly.N` for prereleases. Install the tag that matches your deployment. Find your version with `curl -s http://<api-host>:7102/v1/version` or the image tag of your deployment.

Each release records the exact CSMS release it was made for in every `SKILL.md`: `metadata.evtivity-release` (the tag) and `metadata.evtivity-commit` (that tag's commit). `setup.sh` installs exactly that tag after it checks the commit. When the tag does not exist it installs the latest stable CSMS release, never a nightly or other prerelease, unless you pass `--tag`.

```bash
gh skill install EVtivity/evtivity-skills evtivity-csms@v0.1.39
claude plugin marketplace add EVtivity/evtivity-skills#v0.1.39
git clone --branch v0.1.39 https://github.com/EVtivity/evtivity-skills.git
```

Each `SKILL.md` also names the CSMS version line in `metadata.evtivity-version`.

## Available Skills

The section skills follow the sections of the [EVtivity docs](https://www.evtivity.com/docs/getting-started/introduction).

<!-- skills:start (generated by scripts/sync-descriptions.py) -->
| Skill | Description |
|---|---|
| `evtivity-api` | Use the EVtivity CSMS REST API. Covers operator sign-in tokens and API keys (create, scope permissions, revoke), driver portal authentication, base URLs (/v1/ and /v1/portal/), pagination, the error format and code catalog, RBAC permissions per route group, sending OCPP commands to charging stations and reading the result, and curl examples for stations, sessions, tariffs and reports. Use when someone wants to script, automate or integrate with EVtivity, call an endpoint, create an API key, start or stop a charging session remotely, or understand an API error code. |
| `evtivity-configuration` | Configure an EVtivity CSMS install. Covers authentication (operator and driver auth realms, JWT cookies, API keys, RBAC permissions and roles, MFA by email, TOTP or SMS, reCAPTCHA, CSRF, session and refresh token lifetimes), database setup (PostgreSQL 17, Drizzle migrations, seeding, connection pools, Redis with one ACL user per service), environment variables for every service (API, OCPP, OCPI, worker, simulator, frontends, payments, seed credentials) and OCPP settings (ports, station connection URLs, security profiles 0 to 3, TLS certificates, connection limits, heartbeat, horizontal scaling). Use when someone asks which environment variable or dashboard setting changes a behavior, sets secrets such as JWT_SECRET or SETTINGS_ENCRYPTION_KEY, enables MFA or reCAPTCHA, runs migrations or the seed, sizes database pools, or sets up OCPP TLS and security profiles. |
| `evtivity-conformance` | Test OCPP behavior on the EVtivity CSMS. Covers sending OCPP 1.6 and 2.1 commands to a station from the API (/v1/ocpp/commands/v21 and v16) or the station OCPP Commands tab and reading the result (200, 202 queued, 400, 404, 502, 504), the OCPP message log and security event log, the built-in OCTT conformance runner (dashboard, API and command line, run statuses), the published OCTT results per suite and version (CSMS 2.1 and 1.6, charging station 2.1 and 1.6, PICS, not applicable cases), connecting a real station for testing (URL, security profile, Basic Auth, TLS, approval), and OCPP 1.6 vs 2.1 differences (transaction ids, StatusNotification vs TransactionEvent chargingState, RemoteStart vs RequestStartTransaction, configuration keys vs variables, TriggerMessage choices). Use when someone tests a charger or the CSMS against OCPP, sends a raw OCPP command, reads OCPP logs, runs or reads conformance tests, or asks which OCTT tests pass. |
| `evtivity-csms` | Operate the EVtivity CSMS operator dashboard. Covers every CSMS docs page - dashboard, sites, stations (approval, connectors, availability, security profiles), station images, station configurations (OCPP 1.6 keys, OCPP 2.1 variables, templates), firmware updates, smart charging, load management, free vend, local auth list, display messages, maintenance mode, sessions, drivers, tokens (RFID, authorize log), fleets, pricing (tariffs, tax, split billing), reservations, roaming (OCPI), certificates (Plug and Charge, Mutual TLS), notifications, reports, NEVI compliance, support cases, users (roles, permissions, site access), settings and API keys, access logs, conformance testing and the AI assistant. Use when someone wants to run a charging network in EVtivity, find the dashboard page or permission a task needs, or do an operator task through the dashboard or the API. |
| `evtivity-deployment` | Deploy and upgrade the EVtivity CSMS. Covers AWS (the CDK app on ECS Fargate with Aurora PostgreSQL, ElastiCache Valkey, ALB and WAF, per-environment sizing, credential rotation, cost), Docker Compose (core services, tools, monitoring and OCPI profiles, volumes, overrides), Docker images (registry, tags, build context, frontend runtime config, resource sizing), the Helm chart (install script, Gateway API with Istio or Envoy Gateway, OCPP TLS, secrets, Redis ACL users and TLS, migration job, autoscaling, monitoring, values and appSettings) and minikube (local Kubernetes install, upgrade, rollback, teardown). Use when someone chooses where to run EVtivity, installs it on Kubernetes or AWS, picks image tags, upgrades or rolls back a release, or prepares a production install (secrets, encryption key, Redis users, test payment provider off). |
| `evtivity-getting-started` | Get started with the EVtivity CSMS (OCPP 1.6 and 2.1 charging station management system). Stands up a complete local Docker Compose environment end to end with one script (prerequisites, release checkout, npm ci, .env, build, seed, health wait, sign-in), checks stack health, and explains the docs pages of the getting-started section, the introduction (what EVtivity is, features, architecture, tech stack, license), quick start (Docker in minutes, demo accounts, ports, profiles, demo data, simulator), installation (native development with hot reload, npm run dev scripts, dev tools) and project structure (packages, worker responsibilities). Use when someone wants to install, run, start, try, evaluate or demo EVtivity, asks for a local Docker environment, asks which ports, URLs or sign-in to use, or wants to understand how the codebase is organized. |
| `evtivity-guides` | Operator workflows from the EVtivity CSMS Guides docs. Covers onboarding a charging station (registration, security profile, password, approval), station management and the connector status model, the charging session lifecycle on OCPP 1.6 and 2.1, session monitoring (idle detection, cost, split billing, live updates), RFID tokens and the local auth list, reservations (scheduled and immediate, fees, cancellation), smart charging profiles (batch push, clear, composite schedule), notifications (OCPP, driver and system events, channels, templates), station display messages (OCPP 2.1 SetDisplayMessage, 1.6 DataTransfer), users, roles, permissions and site access, audit logs, driver portal setup and QR charging, white labeling (branding, domains, SMTP, Twilio, legal pages), field troubleshooting (stuck sessions, stale connector status, SuspendedEV), EV-specific charging behaviors, and OCPP testing. Use when an operator asks how to run, configure or debug daily EVtivity operations. |
| `evtivity-integrations` | Set up, test and troubleshoot the EVtivity CSMS integrations. Covers the payment providers (Stripe, Adyen and the simulated test payment provider), choosing the active provider and provider pinning, payment settings (pre-auth amount, platform fee), Stripe and Adyen webhooks and signing secrets, Stripe Connect payout accounts and site host onboarding, holds (pre-authorization), capture, top-ups, refunds, retry capture, reconciliation, guest and QR code payments, prepaid tokens, reservation fees, test cards, the company currency and net or gross price display, outgoing webhooks, SSE event streams, and energy management (load management, smart charging profiles, carbon footprint tracking). Use when someone wants to accept card payments, connect Stripe or Adyen, onboard a site host, refund a session, test payments without real money, receive webhooks, limit site power, or find out why a hold, capture, refund, webhook or guest checkout failed. |
| `evtivity-mobile-app` | Build, white-label, ship and support the open-source EVtivity driver mobile app (Expo, React Native, iOS and Android). Covers the app overview, setup and first run, configuring Expo (app.config.ts, brands, env vars, identifiers, plugins), making changes (project structure, conventions, adding a screen), testing (typecheck, lint, on-device checks), running on a real device (Android over USB or Wi-Fi, iOS Simulator, physical iPhone), EAS and local builds, push notifications (EAS project id, APNs, FCM), App Store and Google Play submission, white-labeling and licensing (Adyen return settings mobile.app.urlSchemes and mobile.app.androidPackageNames), and the /v1/portal/ APIs the app uses. Also covers the end user guide (getting started, find a charger, start and stop a charge, payments, reservations, activity and statements, vehicles, RFID cards, favorites, station watch, support, and account and settings). Use when an operator builds or brands the app, or when someone helps a driver use it. |
| `evtivity-portal` | Use the EVtivity driver portal (web app for EV drivers) and its /v1/portal/ API. Covers registration, operator invitations, email verification, sign-in, password reset and MFA, account settings (personal info, show prices gross or net, security, notification preferences, notification bell, sign out), finding a station by search or QR code, the station detail page, location detail (hours, images, map, popular times), starting and stopping a charge, guest charging by QR with card checkout and 3D Secure, payment methods (Stripe, Adyen, test provider), RFID cards, activity and the monthly dashboard, sessions, session receipts and monthly statements, vehicles and mileage estimates, favorites, station watches, and support cases. Use when someone asks how a driver does something in the portal, needs to script driver actions against the portal API, or is debugging what a driver sees. |
| `evtivity-report-issue` | Report a bug or problem in the EVtivity CSMS to the maintainers as a GitHub issue on EVtivity/evtivity-csms. Gathers the version, deployment type, steps to reproduce, expected and actual behavior and redacted diagnostics, searches for an existing issue, drafts the issue from a template, and opens it only after the user confirms the text. Use when someone wants to report a bug, file an issue, ask the maintainers for help, or a problem remains after troubleshooting. |
| `evtivity-simulator` | Drive the EVtivity charging station simulator (CSS) to test the CSMS without hardware. Covers standby and chaos modes (CSS_MODE, CSS_STATION_LIMIT, CSS_ACTION_INTERVAL_MS and the other simulator environment variables), meter value generation, reconnect behavior, TLS and Mutual TLS for simulated stations, creating, enabling, disabling and deleting simulated OCPP 1.6 and 2.1 stations (dashboard toggle, /v1/stations, /v1/css/stations), real stations on a simulator row, the dashboard Simulate tab and the /v1/css/actions API (plug in, authorize, start and stop charging, unplug, inject and clear faults, go offline, come online, OCPP 1.6 and 2.1 station messages), and running a full test session end to end through to the session, energy and cost in the dashboard and API. Use when someone wants simulated or virtual charging stations, a test or demo charging session, load testing, chaos traffic, or asks why a simulated station does not connect or an action fails. |
| `evtivity-troubleshoot` | Diagnose and fix a broken or misbehaving EVtivity CSMS deployment. Covers the migrate container failing and blocking the API and OCPP server, charging stations that cannot connect (URL, security profile, Basic Auth password, TLS certificate), reCAPTCHA blocking sign-in, Redis connection or ACL errors, payment provider not configured, ports already in use, and stale images or volumes after an upgrade. Use when EVtivity does not start, a container is unhealthy or restarting, sign-in fails, a station stays offline, or logs show errors. Includes a redacted diagnostics script. |
<!-- skills:end -->

The descriptions above are copied from each `SKILL.md` by `scripts/sync-descriptions.py`. Edit the `SKILL.md`, not this table.

## Usage

Skills load when a task matches. Example prompts:

| Skill | Prompt |
|---|---|
| `evtivity-getting-started` | Stand up EVtivity locally with Docker. |
| `evtivity-configuration` | Which settings do I change before others can reach my install? |
| `evtivity-deployment` | Deploy EVtivity to my Kubernetes cluster with Helm. |
| `evtivity-csms` | Create a site, add a station and set a tariff. |
| `evtivity-portal` | How does a driver pay by QR code without an account? |
| `evtivity-mobile-app` | Build the driver app with my brand and point it at my CSMS. |
| `evtivity-integrations` | Set up Stripe and test a paid session. |
| `evtivity-simulator` | Run a full simulated charging session on an OCPP 2.1 station. |
| `evtivity-conformance` | Send a TriggerMessage to CS-001 and explain the result. |
| `evtivity-guides` | Onboard a new OCPP 1.6 station with Basic Auth. |
| `evtivity-api` | Create an API key that can only read sessions and reports. |
| `evtivity-troubleshoot` | Why can't my station connect? |
| `evtivity-report-issue` | Report this bug to the EVtivity maintainers. |

## Skill Structure

Each skill follows the [Agent Skills](https://agentskills.io/specification) format:

- `SKILL.md`: frontmatter (name, description, license, metadata with the CSMS version and docs section) and the workflow. Hand-written.
- `scripts/`: scripts the skill runs, such as `setup.sh`, `check-stack.sh` and `diagnose.sh`.
- `references/`: one file per docs page, generated from the website docs by `scripts/generate-references.mjs`. Never edited by hand. Each file starts with the live page URL and the website commit it came from.

The website docs are the single source of truth. CI regenerates the references and fails when they differ. The API references (`references/routes*.md`, `error-codes.md`) come from the OpenAPI spec and sources of the CSMS release in `metadata.evtivity-release`, and CI checks them against that release.

`.well-known` skill discovery: each GitHub release carries `index.json` (Agent Skills discovery schema 0.2.0) and one archive per skill, built by `scripts/build-discovery.py`. The EVtivity website does not serve them at `/.well-known/agent-skills/` yet, so use the release assets.

## Contributing

Pull requests and discussions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md). Fix doc content on the website, not in `references/`. Report EVtivity bugs in [EVtivity/evtivity-csms](https://github.com/EVtivity/evtivity-csms/issues), or let `evtivity-report-issue` draft one.

## License

MIT. See [LICENSE](LICENSE). EVtivity CSMS has its own license, see its repository.
