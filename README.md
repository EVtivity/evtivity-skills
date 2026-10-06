<p align="center">
  <img src="assets/evtivity-logo.svg" alt="EVtivity" width="80" height="80" />
</p>

<h1 align="center">EVtivity Agent Skills</h1>

<p align="center">
  <a href="https://github.com/EVtivity/evtivity-skills/releases"><img src="https://img.shields.io/github/v/release/EVtivity/evtivity-skills?include_prereleases&sort=semver&label=Release&color=4ade80" alt="Release" /></a>
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

Sources: [Claude Code](https://code.claude.com/docs/en/skills), [Codex](https://learn.chatgpt.com/docs/build-skills), [GitHub Copilot](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills), [Gemini CLI](https://geminicli.com/docs/cli/skills/), [Cursor](https://cursor.com/docs/context/skills). Gemini CLI can also install from Git: `gemini skills install https://github.com/EVtivity/evtivity-skills.git --path skills/evtivity-getting-started`.

### Clone and open

```bash
git clone https://github.com/EVtivity/evtivity-skills.git
cd evtivity-skills
```

Open your agent in the clone. `.claude/skills` and `.agents/skills` point to `skills/`, so the skills load without an install. Then ask: "Stand up EVtivity locally with Docker."

### Pin a version

Release tags match EVtivity CSMS releases: `v0.1.39` for stable, `v0.1.39-alpha.N`, `v0.1.39-beta.N` and `v0.1.39-nightly.N` for prereleases. Install the tag that matches your deployment. Find your version with `curl -s http://<api-host>:7102/v1/version` or the image tag of your deployment.

```bash
gh skill install EVtivity/evtivity-skills evtivity-csms@v0.1.39
claude plugin marketplace add EVtivity/evtivity-skills#v0.1.39
git clone --branch v0.1.39 https://github.com/EVtivity/evtivity-skills.git
```

Each `SKILL.md` names the CSMS version it targets in `metadata.evtivity-version`.

## Available Skills

The section skills follow the sections of the [EVtivity docs](https://www.evtivity.com/docs/getting-started/introduction).

<details>
<summary><strong>evtivity-getting-started</strong></summary>

Stands up a complete local stack with one script: prerequisites, the matching CSMS release, `npm ci`, `.env`, build, seed, a health wait, then the URLs and the sign-in. Checks stack health. Covers the getting-started docs: introduction, quick start, installation and project structure.

**Use when:** installing, running, trying or demoing EVtivity, asking for ports, URLs or the first sign-in, or learning how the code is organized.

</details>

<details>
<summary><strong>evtivity-configuration</strong></summary>

Covers the configuration docs: environment variables, authentication (operator and driver realms, API keys, roles, MFA, reCAPTCHA), database setup and OCPP server settings.

**Use when:** changing a setting or variable, securing an install, or setting up security profiles and TLS for stations.

</details>

<details>
<summary><strong>evtivity-deployment</strong></summary>

Covers the deployment docs: Docker images, Docker Compose, the Helm chart, AWS CDK and minikube, plus upgrades and a production checklist.

**Use when:** deploying to a server, Kubernetes or AWS, choosing image tags, or upgrading.

</details>

<details>
<summary><strong>evtivity-csms</strong></summary>

Covers every page of the operator dashboard docs: dashboard, sites, stations, sessions, drivers, tokens, fleets, pricing, reservations, smart charging, load management, maintenance, notifications, display messages, roaming, certificates, reports, NEVI, users, settings, firmware, station configurations, audit and access logs, support cases and the AI assistant.

**Use when:** operating the charging network day to day from the dashboard or its API.

</details>

<details>
<summary><strong>evtivity-portal</strong></summary>

Covers the driver portal docs: registration, sign-in, finding a station, charging, guest charging, payment methods, RFID cards, sessions, vehicles, favorites, station watches and support cases.

**Use when:** using the portal as a driver, supporting drivers, or calling the portal API.

</details>

<details>
<summary><strong>evtivity-mobile-app</strong></summary>

Covers the mobile app docs: setup, configuration against a CSMS, development, testing on a device, push notifications, builds, store release and white-labeling, plus the driver guide.

**Use when:** building or branding the driver app, or answering a driver's question about it.

</details>

<details>
<summary><strong>evtivity-integrations</strong></summary>

Covers the integrations docs: payment providers, Stripe and Stripe Connect payouts, Adyen, the test payment provider, webhooks and energy management. Holds, captures, top-ups, refunds, guest payments and currency.

**Use when:** setting up or debugging payments, webhooks or an energy management integration.

</details>

<details>
<summary><strong>evtivity-simulator</strong></summary>

Covers the simulator docs: standby and chaos modes, simulated OCPP 1.6 and 2.1 stations, actions, and driving a full test session.

**Use when:** testing without hardware, or reproducing a station behavior.

</details>

<details>
<summary><strong>evtivity-conformance</strong></summary>

Covers the conformance docs and OCPP testing: sending OCPP commands and reading the result, message and security logs, the OCTT conformance runner, published results, and OCPP 1.6 vs 2.1 differences.

**Use when:** testing OCPP behavior, running conformance tests, or reading results.

</details>

<details>
<summary><strong>evtivity-guides</strong></summary>

Covers the how-to guides: station onboarding, management and lifecycle, session monitoring, EV charging behaviors, RFID tokens, reservations, smart charging, notifications, display messages, user management, audit logs, portal setup, white-labeling, OCPP testing and field troubleshooting.

**Use when:** following an operational procedure end to end.

</details>

<details>
<summary><strong>evtivity-api</strong></summary>

The REST API: API keys and sign-in tokens, driver tokens, permissions per route, pagination, errors and the error code catalog, OCPP commands and their results, and curl examples. Includes a route catalog generated from the public OpenAPI spec.

**Use when:** scripting, automating or integrating with EVtivity.

</details>

<details>
<summary><strong>evtivity-troubleshoot</strong></summary>

A decision tree for stack failures: the migrate container, stations that cannot connect, reCAPTCHA, Redis users, payment provider setup, ports in use, and stale images or volumes after an upgrade. Includes a redacted diagnostics script.

**Use when:** EVtivity does not start, a container is unhealthy, sign-in fails, or a station stays offline.

</details>

<details>
<summary><strong>evtivity-report-issue</strong></summary>

Gathers the version, deployment, steps, expected and actual behavior and redacted diagnostics, searches existing issues, drafts an issue and opens it on [EVtivity/evtivity-csms](https://github.com/EVtivity/evtivity-csms/issues) only after you confirm the text.

**Use when:** a problem remains after troubleshooting and the maintainers should know.

</details>

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
- `references/`: one file per docs page, generated from the website docs by `scripts/generate-references.mjs`. Never edited by hand. Each file starts with the page URL and the website commit it came from.

The website docs are the single source of truth. CI regenerates the references and fails when they differ. `.well-known` skill discovery is not set up: it needs the skills served from the EVtivity website.

## Contributing

Pull requests and discussions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md). Fix doc content on the website, not in `references/`. Report EVtivity bugs in [EVtivity/evtivity-csms](https://github.com/EVtivity/evtivity-csms/issues), or let `evtivity-report-issue` draft one.

## License

MIT. See [LICENSE](LICENSE). EVtivity CSMS has its own license, see its repository.
