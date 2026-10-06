# AGENTS.md

Guidance for agents working in this repository. Two uses: running the skills for a user, and editing the skills.

## Skills in this repository

Each skill is a directory under `skills/` with a `SKILL.md`. `.claude/skills` and `.agents/skills` link to `skills/`, so agents opened in a clone find them. Edit only `skills/`.

| Skill | Path | Website docs section | Use it to |
|---|---|---|---|
| evtivity-getting-started | `skills/evtivity-getting-started/SKILL.md` | getting-started | Stand up a local Docker Compose stack end to end (`scripts/setup.sh`), check health (`scripts/check-stack.sh`), sign in |
| evtivity-configuration | `skills/evtivity-configuration/SKILL.md` | configuration | Environment variables, authentication, API keys, roles, database, OCPP settings |
| evtivity-deployment | `skills/evtivity-deployment/SKILL.md` | deployment | Docker images, Compose, Helm, AWS CDK, minikube, upgrades |
| evtivity-csms | `skills/evtivity-csms/SKILL.md` | csms | Operate the dashboard: sites, stations, sessions, drivers, pricing, reservations, roaming, reports, users, settings |
| evtivity-portal | `skills/evtivity-portal/SKILL.md` | portal | The driver portal |
| evtivity-mobile-app | `skills/evtivity-mobile-app/SKILL.md` | mobile-app | Build and white-label the driver app, and the driver guide |
| evtivity-integrations | `skills/evtivity-integrations/SKILL.md` | integrations | Payments (Stripe, Adyen, test provider), webhooks, energy management |
| evtivity-simulator | `skills/evtivity-simulator/SKILL.md` | simulator | The charging station simulator and full test sessions |
| evtivity-conformance | `skills/evtivity-conformance/SKILL.md` | conformance | OCPP commands and results, message logs, OCTT conformance |
| evtivity-guides | `skills/evtivity-guides/SKILL.md` | guides | How-to guides: onboarding, lifecycle, RFID, reservations, smart charging, field troubleshooting |
| evtivity-api | `skills/evtivity-api/SKILL.md` | API reference | The REST API: authentication, API keys, permissions, errors, OCPP commands |
| evtivity-troubleshoot | `skills/evtivity-troubleshoot/SKILL.md` | (task) | Diagnose and fix stack failures (`scripts/diagnose.sh`) |
| evtivity-report-issue | `skills/evtivity-report-issue/SKILL.md` | (task) | Draft and open a redacted issue after the user confirms |

When a user asks to "stand up", "install" or "run" EVtivity, read `skills/evtivity-getting-started/SKILL.md` and follow it.

## Where content comes from

- The website docs (https://www.evtivity.com/docs) are the single source of truth.
- `skills/*/references/*.md` that start with `Generated from https://www.evtivity.com/docs/` are generated from the website MDX by `scripts/generate-references.mjs`. Never edit them by hand. `scripts/sections.json` maps each website section to a skill, plus extra pages a skill also needs. The generator writes `scripts/coverage.json` and `scripts/references-source.json` (the website commit).
- `skills/evtivity-api/references/routes.md` and `error-codes.md` are generated from the public OpenAPI spec and the public CSMS repository by `scripts/generate-api-reference.py`.
- `SKILL.md` files and `scripts/` are hand-written: the workflow, when to use which page, and how the pieces fit. They link the references and the live pages. They do not copy page text.

## Skill format

Skills follow the Agent Skills specification (https://agentskills.io/specification):

- `name`: 1 to 64 characters, lowercase letters, digits and single hyphens, equal to the directory name.
- `description`: 1 to 1024 characters. Say what the skill does and when to use it, with the words users say.
- `license: MIT`. `compatibility` only when the skill needs tools (at most 500 characters).
- `metadata.evtivity-version`: the CSMS version line the skills target, `X.Y.Z`, the same in every skill. `scripts/release.sh` sets it. Section skills also carry `metadata.evtivity-docs-section`.
- Body under 500 lines. Keep `scripts/`, `references/` and `assets/` one level deep, and refer to files by paths relative to the skill directory.
- Scripts: bash, read-only unless the skill says otherwise, and they must pass shellcheck.

## Content rules

- Write from public sources only: the public EVtivity CSMS repository, its releases and issues, and the public docs at https://www.evtivity.com/docs.
- Never add secrets, credentials, hostnames or IP addresses of real deployments, account identifiers, or personal data. Use `example.com`, `203.0.113.0/24` and the documented demo accounts.
- Never describe how EVtivity is developed internally. Describe the product as a user sees it.
- Skills that change data, move money, or affect live stations tell the agent to confirm with the user first.
- Plain, direct English. Short sentences, active voice, no emojis.

## Validate

```bash
python3 scripts/check-skills.py
node --test scripts/*.test.mjs
pip install "git+https://github.com/agentskills/agentskills.git#subdirectory=skills-ref"
for d in skills/*/; do skills-ref validate "$d"; done
shellcheck scripts/*.sh skills/*/scripts/*.sh
bash scripts/release-version.test.sh
```

Regenerate the references from a website checkout: `node scripts/generate-references.mjs --website <dir> --commit <sha>`. CI regenerates them at the commit in `scripts/references-source.json` and fails on any difference.

## Commits and releases

- Conventional Commits, one line, English (`feat(csms): ...`, `fix(troubleshoot): ...`, `docs: ...`).
- Release tags match CSMS releases. Cut them with `scripts/release.sh <tag> [--push]` only. It regenerates the references from the website first.
