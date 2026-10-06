---
name: evtivity-deployment
description: Deploy and upgrade the EVtivity CSMS. Covers AWS (the CDK app on ECS Fargate with Aurora PostgreSQL, ElastiCache Valkey, ALB and WAF, per-environment sizing, credential rotation, cost), Docker Compose (core services, tools, monitoring and OCPI profiles, volumes, overrides), Docker images (registry, tags, build context, frontend runtime config, resource sizing), the Helm chart (install script, Gateway API with Istio or Envoy Gateway, OCPP TLS, secrets, Redis ACL users and TLS, migration job, autoscaling, monitoring, values and appSettings) and minikube (local Kubernetes install, upgrade, rollback, teardown). Use when someone chooses where to run EVtivity, installs it on Kubernetes or AWS, picks image tags, upgrades or rolls back a release, or prepares a production install (secrets, encryption key, Redis users, test payment provider off).
license: MIT
compatibility: Docker Compose targets need Docker with Compose v2. Kubernetes targets need kubectl, Helm 3, Kubernetes 1.27+ and a Gateway API implementation (Istio or Envoy Gateway), plus minikube and optionally istioctl for local clusters. AWS needs Node.js with npm, the AWS CLI and the AWS CDK, run against your own account.
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39-beta.1"
  evtivity-commit: "bd06577f1cf17f235971d9652327b04b768cee81"
  evtivity-docs-section: deployment
---

# EVtivity deployment

This skill picks a deployment target and walks through install, upgrade and production hardening. The website docs are the source of truth. Read the page for each target, then follow the workflow here.

## Pages in this section

| Page id | Live page | Read it for |
| --- | --- | --- |
| deployment/aws | https://www.evtivity.com/docs/deployment/aws | AWS CDK app: stacks, sizing, hostnames, deploy, sign-in, payments config, observability, Valkey users, rotation, cost |
| deployment/docker-compose | https://www.evtivity.com/docs/deployment/docker-compose | Compose services and ports, profiles, infra-only mode, volumes, overrides |
| deployment/docker | https://www.evtivity.com/docs/deployment/docker | Images per service, build context, frontend runtime config, resource sizing |
| deployment/helm-chart | https://www.evtivity.com/docs/deployment/helm-chart | Kubernetes chart: install script, gateway, OCPP TLS, secrets, Redis ACL and TLS, migration job, autoscaling, monitoring, values |
| deployment/minikube | https://www.evtivity.com/docs/deployment/minikube | Local Kubernetes: cluster, gateway, install, DNS, upgrade, rollback, teardown |

Repositories:

- CSMS: https://github.com/EVtivity/evtivity-csms
- Helm chart: https://github.com/EVtivity/evtivity-csms-helm
- AWS CDK app: https://github.com/EVtivity/evtivity-csms-cdk

## Step 1: choose a target

| Situation | Target | Page id |
| --- | --- | --- |
| Try EVtivity or develop on one machine | Docker Compose. Use evtivity-getting-started for the end-to-end local setup | deployment/docker-compose |
| Build or run single images, size containers | Docker images | deployment/docker |
| Production on any Kubernetes cluster | Helm chart | deployment/helm-chart |
| Test the chart or gateway routing locally | minikube with the Helm chart | deployment/minikube |
| Production on AWS without managing Kubernetes | AWS CDK (ECS Fargate) | deployment/aws |

The Compose file builds every service from source with development Dockerfiles (`Dockerfile.dev`) and publishes a Node inspector port (9229) on the OCPP container. Helm and CDK run the published release images.

## Images and tags

Read deployment/docker for the image list and sizing.

- Images are published for `linux/amd64` and `linux/arm64` under `ghcr.io/evtivity/evtivity-csms/<service>`: `api`, `ocpp`, `ocpi`, `csms`, `portal`, `worker`, `css`, `migrate`, `ocpi-simulator`.
- Every release has an exact, immutable tag without a `v` prefix: release `v0.1.38` publishes `0.1.38`.
- Stable releases also move `0.1`, `0`, `latest` and `stable`. Prereleases (`-alpha.N`, `-beta.N`, `-nightly.N`) move only their channel alias (`alpha`, `beta`, `nightly`).
- Pin an exact stable tag in production. Aliases change only when a deployment pulls again.
- Build an image from the repo root so the context includes shared packages: `docker build -f packages/api/Dockerfile -t <your-registry>/api .`
- CSMS and portal images read the API URL at runtime: set `API_URL` on the container, and the entrypoint writes `/runtime-config.js` before nginx starts. Their nginx listens on port 8080.
- Starting sizes: API 1 GB and 1 CPU, OCPP 4 GB and 2 CPU, CSMS and portal 1 GB and 0.5 CPU, worker 1 GB and 0.5 CPU.

## Workflow: Docker Compose

Read deployment/docker-compose. For first-time local setup and first sign-in, use evtivity-getting-started.

1. `docker compose up -d` starts the core services: postgres (5433), redis (127.0.0.1:6379), migrate, api (7102), ocpp (7103 and 8443), csms (7100), portal (7101), worker and simulator.
2. Add profiles as needed:
   - `--profile tools`: pgadmin (7109), mailpit (7108), ftp (21)
   - `--profile monitoring`: prometheus (9090), grafana (7107), loki (3100), alloy
   - `--profile ocpi`: ocpi (7104), ocpi-simulator, ocpi-cpo-sim
3. `npm run dev:infra` starts only the infrastructure (postgres, redis, migrate, mailpit, prometheus, grafana, loki, alloy) when you run the app services on the host.
4. Override any variable in `.env` or the shell. Variable details are in evtivity-configuration.
5. Confirm: `docker compose ps` shows the services healthy and `migrate` exited 0. `curl -s http://localhost:7102/v1/health` answers.

Data lives in named volumes: `pgdata`, `redisdata`, `ftpdata`, `pgadmindata`, `prometheusdata`, `grafanadata`, `lokidata`. `docker compose down --volumes` deletes all of them, including the database. Ask the user before running it.

## Workflow: Helm chart

Read deployment/helm-chart. Prerequisites: Kubernetes 1.27+, Helm 3, kubectl and a Gateway API implementation.

1. Clone the chart: `git clone https://github.com/EVtivity/evtivity-csms-helm.git && cd evtivity-csms-helm`.
2. Run the chart repo install script (./scripts/install.sh). It asks for the gateway (Istio or Envoy Gateway), bundled PostgreSQL and bundled Redis. It generates `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, the admin password, database passwords and OCPP TLS certificates. Override any of them with env vars, for example JWT_SECRET=... before the install script command. `REDIS_TLS=true` serves the bundled Redis over TLS.
3. Without the script, pass secrets with `--set secrets.*` (`databaseUrl`, `redisUrls.api`, `.ocpp`, `.ocpi`, `.worker`, `.css`, `jwtSecret`, `settingsEncryptionKey`), or point `secrets.existingSecret` at a Secret you manage. Never commit secrets to `values.yaml`.
4. External Redis 7+: create the five ACL users from the chart's `redis/acl-rules.conf` before you install or upgrade, then set one `secrets.redisUrls.<user>` per service.
5. Point DNS for each hostname (default `csms`, `portal`, `api`, `ocpp`, `ocpi` under `evtivity.local`) at the gateway LoadBalancer IP.
6. For OCPP TLS, stations use the separate LoadBalancer on 8443. Set `api.env.stationTlsUrl` so the API can move connected OCPP 2.1 stations to TLS.
7. Sign in with the admin credentials the script prints. The admin must change the password at first sign-in.
8. Confirm: `kubectl get pods -n evtivity` shows all pods running, `helm status evtivity -n evtivity` shows `deployed`, and the dashboard loads at the CSMS hostname.

Settings seeded through `appSettings` (currency, tax basis, price display, station message language, payment provider and amounts, Adyen, mobile app lists) are listed on deployment/helm-chart. Leave a key empty to keep the dashboard value. Payment credentials go under `appSettings.sensitive` with `--set`. The chart refuses `appSettings.payments.provider: adyen`: select Adyen in the dashboard after the upgrade (evtivity-integrations).

Monitoring (`monitoring.enabled`) is off by default and only reachable with `kubectl port-forward`. Grafana starts with `admin/admin`. Change it before you expose it.

The chart repo uninstall script (./scripts/uninstall.sh) removes the releases and offers to delete PVCs and the namespace. Deleting PVCs deletes the bundled database. Ask the user before running it, and before any `helm uninstall`.

## Workflow: minikube

Read deployment/minikube.

1. `minikube start --cpus=4 --memory=8192`
2. Install the Gateway API CRDs, then Istio (`istioctl install --set profile=minimal -y`) or Envoy Gateway. The page gives the exact commands and versions.
3. Clone the chart and run the chart repo install script (./scripts/install.sh). Accept the bundled PostgreSQL and Redis.
4. Run `minikube tunnel` in a separate terminal and keep it open.
5. Add the five `*.evtivity.local` hostnames to `/etc/hosts` with the tunnel IP (usually `127.0.0.1`). This needs `sudo`, so ask the user to do it or confirm first.
6. Open http://csms.evtivity.local and sign in with the printed credentials.
7. Confirm: `kubectl get pods -n evtivity`, `kubectl logs -n evtivity -l app.kubernetes.io/component=api --tail=100`.

Teardown: run the chart repo uninstall script (./scripts/uninstall.sh), then `minikube delete`. Both delete data. Confirm with the user first.

## Workflow: AWS CDK

Read deployment/aws. The app deploys six stacks per environment (`dev`, `qa`, `prod`): Network, Domain, Storage, Data, Alb, App. You need your own AWS account and a Route 53 hosted zone.

1. `git clone https://github.com/EVtivity/evtivity-csms-cdk.git && cd evtivity-csms-cdk && npm ci`
2. `cp config/dev.local.yaml.example config/dev.local.yaml` and fill in the account, hosted zone ID and admin email. The file is gitignored.
3. Check: `npm run typecheck && npm run lint && npm test`
4. Bootstrap once per account and region: `npx cdk bootstrap aws://ACCOUNT_ID/us-east-1`
5. Preview, then deploy: `npm run synth -- --context env=dev`, then `npm run deploy -- --context env=dev --all`. Show the user the synth output and confirm before the deploy, because it creates billable resources (the page lists monthly costs per environment).
6. A database job runs migrations, creates the app role, seeds the first admin and writes settings before services start. If it fails, CloudFormation rolls back and names the log stream.
7. Sign in as `initialAdmin.email`. Read the generated password with `aws secretsmanager get-secret-value --secret-id evtivity/<env>/initial-admin --query SecretString --output text`. The dashboard asks for a new password at first sign-in.
8. Confirm: the App stack outputs list each service URL, and the dashboard loads at `csms.<subdomain>.<apex>`.

Enter payment credentials in the dashboard, not the config. `payments.allowSimulatedProvider` is refused in `prod`. Grafana answers only to addresses in a WAF IP set: the CDK repo script ./scripts/grafana-access.sh with `<env> add <ip or cidr>`.

Ask the user before `cdk destroy` or deleting any stack. The Data stack holds the database.

## Workflow: upgrade a release

1. Read the GitHub release notes of every version between the current and the target: `gh release view v<version> -R EVtivity/evtivity-csms`. Start with **Breaking changes** and **Upgrade notes**.
2. Check required upgrade paths. When notes say to upgrade through a version, do not skip it. Example: installs on v0.1.37 or earlier must upgrade to v0.1.38 and let every pod roll over before installing the release after it (two-step database changes).
3. Back up the database with `pg_dump` first. Rollbacks never reverse migrations.
4. Pin the target to an exact stable tag.
5. Run the upgrade for the target:
   - Compose: check out the release tag in the CSMS repo, then `docker compose up -d --build`.
   - Helm: `git pull` in the chart repo, then `helm upgrade evtivity . -n evtivity --reuse-values`. Pin with `--set image.tag=<version>`. The migration job runs `pre-upgrade`, so a failed migration stops the upgrade and old pods keep running. With `--reuse-values` from before v0.1.38, add `--set appSettings.stripe=null`, and replace `secrets.redisUrl` with the five `secrets.redisUrls.*` values.
   - AWS CDK: pull the CDK repo (each stable release bumps `image.tag`), review the change, then `npm run deploy -- --context env=<env> --all`. Upgrading from v0.1.37 or earlier: deploy the stack in the same window as the application, because the Stripe webhook path changed.
6. Confirm: `kubectl rollout status deployment -n evtivity` (Helm), the pod images match the target tag, `GET /v1/version` on the API shows the new version, and stations reconnect.

Roll back on Helm with `helm history evtivity -n evtivity`, then `helm rollback evtivity <revision> -n evtivity`. A rollback restores manifests and images, not the database schema. Confirm with the user before rolling back across a release with schema changes.

## Production checklist

- Set strong unique values for `JWT_SECRET` and `SETTINGS_ENCRYPTION_KEY`. The Helm script and CDK generate them. Never use the Compose development values. Never change `SETTINGS_ENCRYPTION_KEY` on a live install without user approval: stored secret settings become unreadable.
- Change the initial admin password. Helm and CDK force a reset at first sign-in. For Compose, set `INITIAL_ADMIN_*` before the first start.
- Give each service its own Redis user and password (`api`, `ocpp`, `ocpi`, `worker`, `css`). Keep Redis off public networks.
- Keep `PAYMENTS_ALLOW_SIMULATED=false` (Helm and CDK `payments.allowSimulatedProvider: false`) and set `NODE_ENV=production`.
- Pin exact image tags. Run only stable releases.
- Set the public URLs (`CSMS_URL`, `PORTAL_URL`, `OCPP_STATION_TLS_URL`) and serve the frontends and API over HTTPS. Use OCPP security profile 2 or 3 for real stations (evtivity-configuration).
- Keep monitoring internal or behind access control, and change the Grafana admin password.
- Back up PostgreSQL before every upgrade.

## Where the docs and the code differ

Follow the code and the release notes. Mention the difference when it matters.

| Topic | Page says | Code or release notes |
| --- | --- | --- |
| Image path (deployment/docker, deployment/helm-chart) | `ghcr.io/evtivity/api` or `ghcr.io/evtivity/evtivity-api:<tag>` | `ghcr.io/evtivity/evtivity-csms/<service>:<tag>`. The chart's `image.registry` is `ghcr.io/evtivity/evtivity-csms` |
| CSMS and portal container port (deployment/docker-compose, deployment/docker) | 80 | nginx listens on 8080. Compose maps 7100 and 7101 to 8080 |
| OCPI simulator service (deployment/docker-compose) | `ocpi-sim` | Compose service `ocpi-simulator` |
| Prerelease labels (deployment/minikube) | Mentions `-rc.1` tags | Channels are stable, alpha, beta and nightly. `rc` is not used |
| Seed re-runs | Older pages say the seed overwrites settings | Since v0.1.38 the seed only adds what is missing (`--apply-config` to overwrite) |

## Related skills

- evtivity-getting-started: local Docker setup end to end, first sign-in, its setup script
- evtivity-configuration: environment variables, auth, database, OCPP security profiles and TLS
- evtivity-csms: dashboard pages, including Settings
- evtivity-portal: the driver portal
- evtivity-mobile-app: driver app builds and settings
- evtivity-integrations: payments (Stripe, Adyen, test provider), webhooks
- evtivity-simulator: the charging station simulator
- evtivity-conformance: OCTT conformance runs
- evtivity-guides: task guides
- evtivity-api: REST API, health and version endpoints
- evtivity-troubleshoot: failed pods, migrations and connections
- evtivity-report-issue: report a bug

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `deployment/aws` | `references/aws.md` | https://www.evtivity.com/docs/deployment/aws |
| `deployment/docker-compose` | `references/docker-compose.md` | https://www.evtivity.com/docs/deployment/docker-compose |
| `deployment/docker` | `references/docker.md` | https://www.evtivity.com/docs/deployment/docker |
| `deployment/helm-chart` | `references/helm-chart.md` | https://www.evtivity.com/docs/deployment/helm-chart |
| `deployment/minikube` | `references/minikube.md` | https://www.evtivity.com/docs/deployment/minikube |
