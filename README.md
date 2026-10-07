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

Release tags match EVtivity CSMS releases: `v0.1.39` for stable, `v0.1.39-alpha.N` and `v0.1.39-beta.N` for prereleases. Install the tag that matches your deployment. Find your version with `curl -s http://<api-host>:7102/v1/version` or the image tag of your deployment.

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
| `evtivity-api` | Call the EVtivity REST API: API keys, sign-in and driver tokens, permissions, pagination, error codes, OCPP command routes, curl examples and a route catalog per API tag. Use to script, automate or integrate, list sessions or stations via the API, or decode an error code. Not for dashboard clicks (evtivity-csms). |
| `evtivity-configuration` | Configure EVtivity: environment variables, secrets such as JWT_SECRET and SETTINGS_ENCRYPTION_KEY, operator and driver auth, roles, MFA, reCAPTCHA setup, database, migrations, seed, Redis users, OCPP ports, TLS and station security profiles. Use to change a setting or variable or harden an install. Not for a blocked sign-in (evtivity-troubleshoot). |
| `evtivity-conformance` | Test OCPP on EVtivity: send OCPP 1.6 or 2.1 commands such as TriggerMessage, Reset or RequestStartTransaction and read the result, message and security logs, OCTT conformance tests and published results, 1.6 vs 2.1 differences. Not for simulated stations (evtivity-simulator) or a station that cannot connect (evtivity-troubleshoot). |
| `evtivity-csms` | Operate the EVtivity operator dashboard: sites, stations, sessions, drivers, RFID tokens, fleets, pricing groups and tariffs, reservations, smart charging, load management, roaming, reports, users, roles, settings. Use for daily operator tasks in the dashboard. Not for payment provider setup (evtivity-integrations) or scripts (evtivity-api). |
| `evtivity-deployment` | Deploy and upgrade EVtivity in production: Docker images and tags, Compose on a server, the Helm chart on Kubernetes, minikube, AWS CDK on ECS Fargate, upgrades, rollbacks and a production checklist. Use to deploy on Kubernetes or AWS, pick image tags, upgrade or roll back. Not for a first local trial (evtivity-getting-started). |
| `evtivity-getting-started` | Install and run EVtivity CSMS locally with Docker: one setup script stands up the stack, checks health and prints the URLs, ports and demo sign-in. Use to install, stand up, start, try or demo EVtivity on a laptop or one machine, or to learn the code layout. Not for production deploys (evtivity-deployment) or failures (evtivity-troubleshoot). |
| `evtivity-guides` | Step-by-step EVtivity how-to guides: onboard a station, station lifecycle, session monitoring, RFID cards, reservations, charging profiles, notifications, display messages, users and audit, white-labeling, fix stuck sessions and SuspendedEV. Use for an end-to-end procedure or walkthrough. Not for one dashboard page in detail (evtivity-csms). |
| `evtivity-integrations` | Set up EVtivity payments: Stripe, Stripe Connect payouts, Adyen, the test payment provider, holds, captures, refunds, guest payments, currency, payment webhooks and energy management. Use to accept cards, refund a payment, test payments without money, or debug a failed payment or webhook. Not for tariffs and prices (evtivity-csms). |
| `evtivity-mobile-app` | Build, white-label and ship the EVtivity driver mobile app (Expo, React Native, iOS, Android): brands, device runs, EAS builds, push notifications, App Store and Google Play release, plus the driver guide for the app. Use to build or brand the mobile app or help a driver with it. Not for the web portal (evtivity-portal). |
| `evtivity-portal` | Use the EVtivity driver portal web app and its API: driver registration, sign-in, find a station, start and stop charging, guest charging by QR code, saved cards, RFID cards, sessions and receipts, vehicles, favorites, station watches, support cases. Use when a driver works in the portal. Not for the native app (evtivity-mobile-app). |
| `evtivity-report-issue` | Report an EVtivity bug to the maintainers: gather the version, deployment, steps and redacted diagnostics, search existing GitHub issues, draft the issue and open it on EVtivity/evtivity-csms only after the user confirms. Use to report a bug or file an issue. Not for fixing the failure yourself (evtivity-troubleshoot). |
| `evtivity-simulator` | Run the EVtivity charging station simulator: create simulated OCPP 1.6 and 2.1 stations, standby and chaos modes, plug in, authorize, start and stop charging, faults, offline, and full test sessions without hardware. Use for a test or demo charging session or load testing. Not for OCTT conformance runs (evtivity-conformance). |
| `evtivity-troubleshoot` | Fix EVtivity failures: a station cannot connect or stays offline, a service or container is down or restarting, migrate failed, sign-in blocked by reCAPTCHA, Redis errors, ports in use, a broken upgrade. Runs a redacted diagnostics script. Use whenever something fails or shows errors. Not for stuck sessions or SuspendedEV (evtivity-guides). |
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
- `references/`: one file per docs page, generated from the website docs by `scripts/generate-references.mjs`. Never edited by hand. Each file starts with the live page URL. `scripts/references-source.json` records the website commit they come from.

The website docs are the single source of truth. CI regenerates the references and fails when they differ. The API references (`references/routes*.md`, `error-codes.md`) come from the OpenAPI spec and sources of the CSMS release in `metadata.evtivity-release`, and CI checks them against that release.

`.well-known` skill discovery: each GitHub release carries `index.json` (Agent Skills discovery schema 0.2.0) and one archive per skill, built by `scripts/build-discovery.py`. The EVtivity website does not serve them at `/.well-known/agent-skills/` yet, so use the release assets.

## Contributing

Pull requests and discussions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md). Fix doc content on the website, not in `references/`. Report EVtivity bugs in [EVtivity/evtivity-csms](https://github.com/EVtivity/evtivity-csms/issues), or let `evtivity-report-issue` draft one.

## License

MIT. See [LICENSE](LICENSE). EVtivity CSMS has its own license, see its repository.
