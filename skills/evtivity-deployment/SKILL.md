---
name: evtivity-deployment
description: "Deploy and upgrade EVtivity in production: Docker images and tags, Compose on a server, the Helm chart on Kubernetes, minikube, AWS CDK on ECS Fargate, upgrades, rollbacks and a production checklist. Use to deploy on Kubernetes or AWS, pick image tags, upgrade or roll back. Not for a first local trial (evtivity-getting-started)."
license: MIT
compatibility: Docker Compose targets need Docker with Compose v2. Kubernetes targets need kubectl, Helm 3, Kubernetes 1.27+ and a Gateway API implementation (Istio or Envoy Gateway), plus minikube and optionally istioctl for local clusters. AWS needs Node.js with npm, the AWS CLI and the AWS CDK, run against your own account.
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39-beta.1"
  evtivity-commit: "bd06577f1cf17f235971d9652327b04b768cee81"
  evtivity-docs-section: deployment
---

# EVtivity deployment

Not for: a first local trial on one machine (use evtivity-getting-started), individual environment variables (use evtivity-configuration), failed pods or containers (use evtivity-troubleshoot).

This skill picks a deployment target and walks through install, upgrade and production hardening. The website docs are the source of truth: read the reference for each target, then follow the workflow here. `references/helm-chart.md` and `references/aws.md` are long: grep them for the value or step you need.

Repositories: CSMS https://github.com/EVtivity/evtivity-csms, Helm chart https://github.com/EVtivity/evtivity-csms-helm, AWS CDK app https://github.com/EVtivity/evtivity-csms-cdk.

## Step 1: choose a target

| Situation | Target | Reference |
| --- | --- | --- |
| Try EVtivity or develop on one machine | Docker Compose (evtivity-getting-started for the local setup) | `references/docker-compose.md` |
| Build or run single images, size containers | Docker images | `references/docker.md` |
| Production on any Kubernetes cluster | Helm chart | `references/helm-chart.md` |
| Test the chart or gateway routing locally | minikube with the Helm chart | `references/minikube.md` |
| Production on AWS without managing Kubernetes | AWS CDK (ECS Fargate) | `references/aws.md` |

The Compose file builds every service from source with development Dockerfiles. Helm and CDK run the published release images.

## Images and tags (`references/docker.md`)

- Images for `linux/amd64` and `linux/arm64` under `ghcr.io/evtivity/evtivity-csms/<service>`: `api`, `ocpp`, `ocpi`, `csms`, `portal`, `worker`, `css`, `migrate`, `ocpi-simulator`.
- Every release has an exact, immutable tag without a `v` prefix: release `v0.1.38` publishes `0.1.38`. Stable releases also move `0.1`, `0`, `latest` and `stable`. Prereleases (`-alpha.N`, `-beta.N`, `-nightly.N`) move only their channel alias.
- Pin an exact stable tag in production. Aliases change only when a deployment pulls again.
- Build from the repo root so the context includes shared packages: `docker build -f packages/api/Dockerfile -t <your-registry>/api .`
- CSMS and portal images read the API URL at runtime: set `API_URL` on the container. Their nginx listens on port 8080.

## Workflow: Docker Compose on a server (`references/docker-compose.md`)

1. `docker compose up -d` starts the core services: postgres (5433), redis (127.0.0.1:6379), migrate, api (7102), ocpp (7103 and 8443), csms (7100), portal (7101), worker and simulator.
2. Profiles: `--profile tools` (pgadmin, mailpit, ftp), `--profile monitoring` (prometheus, grafana, loki, alloy), `--profile ocpi` (ocpi, ocpi-simulator, ocpi-cpo-sim).
3. On a host others can reach, restrict PostgreSQL port 5433 (published on all interfaces with the default login: see evtivity-getting-started, "Network exposure") and set `BIND_IP`.
4. Confirm: `docker compose ps` shows the services healthy and `migrate` exited 0. `curl -s http://localhost:7102/v1/health` answers.

Data lives in named volumes. `docker compose down --volumes` deletes all of them, including the database. Ask the user first.

## Workflow: Helm chart (`references/helm-chart.md`)

Prerequisites: Kubernetes 1.27+, Helm 3, kubectl and a Gateway API implementation.

1. `git clone https://github.com/EVtivity/evtivity-csms-helm.git && cd evtivity-csms-helm`.
2. Run the chart's install script (`./scripts/install.sh`). It asks for the gateway (Istio or Envoy Gateway), bundled PostgreSQL and bundled Redis, and generates `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, the admin password, database passwords and OCPP TLS certificates. Override any of them with environment variables. `REDIS_TLS=true` serves the bundled Redis over TLS.
3. Without the script, pass secrets with `--set secrets.*` (`databaseUrl`, `redisUrls.api`, `.ocpp`, `.ocpi`, `.worker`, `.css`, `jwtSecret`, `settingsEncryptionKey`), or point `secrets.existingSecret` at a Secret you manage. Never commit secrets to `values.yaml`.
4. External Redis 7+: create the five ACL users from the chart's `redis/acl-rules.conf` before you install or upgrade.
5. Point DNS for each hostname (default `csms`, `portal`, `api`, `ocpp`, `ocpi` under `evtivity.local`) at the gateway LoadBalancer IP.
6. OCPP TLS: stations use the separate LoadBalancer on 8443. Set `api.env.stationTlsUrl` so the API can move connected OCPP 2.1 stations to TLS.
7. Sign in with the admin credentials the script prints. The admin must change the password at first sign-in.
8. Confirm: `kubectl get pods -n evtivity`, `helm status evtivity -n evtivity` shows `deployed`, and the dashboard loads.

`appSettings` seeds selected dashboard settings. Leave a key empty to keep the dashboard value. Payment credentials go under `appSettings.sensitive` with `--set`. The chart refuses `appSettings.payments.provider: adyen`: select Adyen in the dashboard after the upgrade (evtivity-integrations). Monitoring (`monitoring.enabled`) is off by default. Grafana starts with `admin/admin`: change it before you expose it.

The chart's uninstall script removes the releases and offers to delete PVCs and the namespace. Deleting PVCs deletes the bundled database. Ask the user first, and before any `helm uninstall`.

## Workflow: minikube (`references/minikube.md`)

1. `minikube start --cpus=4 --memory=8192`.
2. Install the Gateway API CRDs, then Istio or Envoy Gateway (exact commands and versions on the page).
3. Clone the chart and run its install script. Accept the bundled PostgreSQL and Redis.
4. Run `minikube tunnel` in a separate terminal and keep it open.
5. Add the five `*.evtivity.local` hostnames to `/etc/hosts` with the tunnel IP. This needs `sudo`: ask the user.
6. Open http://csms.evtivity.local and sign in with the printed credentials.

Teardown: the chart's uninstall script, then `minikube delete`. Both delete data. Confirm first.

## Workflow: AWS CDK (`references/aws.md`)

Six stacks per environment (`dev`, `qa`, `prod`): Network, Domain, Storage, Data, Alb, App. You need your own AWS account and a Route 53 hosted zone.

1. `git clone https://github.com/EVtivity/evtivity-csms-cdk.git && cd evtivity-csms-cdk && npm ci`
2. `cp config/dev.local.yaml.example config/dev.local.yaml` and fill in the account, hosted zone ID and admin email. The file is gitignored.
3. `npm run typecheck && npm run lint && npm test`
4. Bootstrap once per account and region: `npx cdk bootstrap aws://ACCOUNT_ID/us-east-1`
5. `npm run synth -- --context env=dev`, show the user the result, then `npm run deploy -- --context env=dev --all` after the user confirms: it creates billable resources (monthly costs per environment on the page).
6. A database job runs migrations, creates the app role, seeds the first admin and writes settings before services start.
7. Sign in as `initialAdmin.email`. The password: `aws secretsmanager get-secret-value --secret-id evtivity/<env>/initial-admin --query SecretString --output text`.

Enter payment credentials in the dashboard, not the config. `payments.allowSimulatedProvider` is refused in `prod`. Ask the user before `cdk destroy` or deleting any stack: the Data stack holds the database.

## Workflow: upgrade a release

1. Read the GitHub release notes of every version between the current and the target: `gh release view v<version> -R EVtivity/evtivity-csms`. Start with **Breaking changes** and **Upgrade notes**.
2. Follow required upgrade paths. Example: installs on v0.1.37 or earlier upgrade to v0.1.38 and let every pod roll over before the release after it.
3. Back up the database with `pg_dump` first. Rollbacks never reverse migrations.
4. Pin the target to an exact stable tag, then:
   - Compose: check out the release tag, then `docker compose up -d --build`.
   - Helm: `git pull` in the chart repo, then `helm upgrade evtivity . -n evtivity --reuse-values --set image.tag=<version>`. The migration job runs `pre-upgrade`, so a failed migration stops the upgrade and old pods keep running.
   - AWS CDK: pull the CDK repo (each stable release bumps `image.tag`), review, then `npm run deploy -- --context env=<env> --all`.
5. Confirm: `kubectl rollout status deployment -n evtivity` (Helm), the pod images match the tag, `GET /v1/version` shows the new version, and stations reconnect.

Helm rollback: `helm history evtivity -n evtivity`, then `helm rollback evtivity <revision> -n evtivity`. It restores manifests and images, not the database schema. Confirm before rolling back across a release with schema changes.

## Production checklist

- Strong unique `JWT_SECRET` and `SETTINGS_ENCRYPTION_KEY`. Never change `SETTINGS_ENCRYPTION_KEY` on a live install without user approval.
- Change the initial admin password. Helm and CDK force a reset at first sign-in. For Compose, set `INITIAL_ADMIN_*` before the first start.
- One Redis user and password per service. Keep Redis and PostgreSQL off public networks.
- `PAYMENTS_ALLOW_SIMULATED=false` (Helm and CDK `payments.allowSimulatedProvider: false`) and `NODE_ENV=production`.
- Pin exact image tags. Run only stable releases.
- Set the public URLs (`CSMS_URL`, `PORTAL_URL`, `OCPP_STATION_TLS_URL`) and serve the frontends and API over HTTPS. Use OCPP security profile 2 or 3 for real stations.
- Keep monitoring internal, change the Grafana admin password, back up PostgreSQL before every upgrade.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer. Every page is listed once in the Step 1 table.
