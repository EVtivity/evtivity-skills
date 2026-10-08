Generated from https://www.evtivity.com/docs/deployment/helm-chart. Do not edit.

# Helm Chart

Deploy EVtivity CSMS on Kubernetes using the evtivity-csms Helm chart with Gateway API routing, OCPP TLS, and optional monitoring.

## Overview

The `evtivity-csms` Helm chart deploys the full EVtivity CSMS platform on Kubernetes. The chart lives in a separate repository (`evtivity-csms-helm`) and packages all microservices, gateway routing, secrets, migrations, and optional monitoring.

Chart name: `evtivity-csms`
Type: application
Source: [github.com/EVtivity/evtivity-csms-helm](https://github.com/EVtivity/evtivity-csms-helm)

PostgreSQL and Redis are not bundled as subcharts. They are installed separately by the install script or by you.

## Prerequisites

- Kubernetes cluster (1.27+)
- Helm 3
- A Gateway API implementation: [Istio](https://istio.io/) (recommended) or [Envoy Gateway](https://gateway.envoyproxy.io/)
- `kubectl` configured for your cluster

## Install Script

The interactive install script handles dependency installation, secret generation, TLS certificate creation, and chart deployment.

```bash
cd evtivity-csms-helm
./scripts/install.sh
```

The script prompts for three choices:

1. **Gateway implementation** - Istio (default, service mesh with mTLS and authorization policies) or Envoy Gateway (lightweight ingress-only routing)
2. **Bundled PostgreSQL** - yes (default, installs Bitnami PostgreSQL via Helm) or no (provide external connection details)
3. **Bundled Redis** - yes (default, installs Bitnami Redis via Helm with one ACL user per service) or no (provide the external host, port, and the password of each service user)

The script auto-generates random values for `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, `ADMIN_PASSWORD`, and database passwords. Override any value with environment variables:

```bash
POSTGRES_PASSWORD=mypass JWT_SECRET=mysecret ./scripts/install.sh
```

Supported env var overrides: `POSTGRES_PASSWORD`, `REDIS_PASSWORD` (the Redis admin user), `REDIS_API_PASSWORD`, `REDIS_OCPP_PASSWORD`, `REDIS_OCPI_PASSWORD`, `REDIS_WORKER_PASSWORD`, `REDIS_CSS_PASSWORD`, `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, `ADMIN_PASSWORD`, `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `REDIS_HOST`, `REDIS_PORT`.

After installation, the script prints the default admin credentials. The admin user is created with `mustResetPassword: true`, forcing a password change on first login.

## Services

The chart deploys six microservices, each with an independent enable toggle:

| Service | Port | Image | Health Probe | Description |
|---------|------|-------|-------------|-------------|
| API | 7102 | api | HTTP /health | Fastify REST API |
| OCPP | 7103, 8443 | ocpp | HTTP / on 8081 | OCPP WebSocket server |
| OCPI | 7104 | ocpi | TCP 7104 | OCPI roaming server |
| CSMS | 7100 | csms | HTTP /health (nginx) | Operator dashboard |
| Portal | 7101 | portal | HTTP /health (nginx) | Driver portal |
| CSS | - | css | HTTP / on 8082 | Charging station simulator |

Two OCPI simulator services are also available for testing:

| Service | Port | Role | Description |
|---------|------|------|-------------|
| OCPI Sim | 7105 | eMSP | Simulates an external eMSP partner |
| OCPI CPO Sim | 7106 | CPO | Simulates an external CPO with auto-session generation |

Both simulators use the same Docker image (`ocpi-simulator`) with different env vars. They are internal-only with no external HTTPRoute.

## Gateway API

The chart uses `gateway.networking.k8s.io/v1` (GA) for ingress routing. Each service gets its own hostname via HTTPRoute resources. All hostnames share a single LoadBalancer IP.

Default hostnames:

- `csms.evtivity.local`
- `portal.evtivity.local`
- `api.evtivity.local`
- `ocpp.evtivity.local`
- `ocpi.evtivity.local`

### Istio (Default)

Istio provides both north-south ingress and east-west service mesh capabilities. When `istio.enabled: true`, the chart creates:

- **PeerAuthentication** - namespace-wide mTLS (default STRICT)
- **AuthorizationPolicy** - per-service rules allowing traffic only from the Istio gateway service account

Use Istio for production deployments that need inter-service encryption, traffic policies, and distributed tracing.

### Envoy Gateway

Envoy Gateway is a lightweight alternative that handles ingress routing only. No mTLS between services, no authorization policies. Set `gatewayClassName: eg` and `istio.enabled: false`.

### DNS

The Gateway creates a `type: LoadBalancer` Service. DNS records for each hostname must point to the LoadBalancer's external IP. Configure this manually or with [external-dns](https://github.com/kubernetes-sigs/external-dns).

## OCPP TLS

OCPP TLS is enabled by default for station connections on port 8443. The chart creates a separate LoadBalancer Service for direct TLS access, supporting both Mutual TLS (client certificate validation) and No Auth through TLS + Basic Auth (no client certificate) on the same port.

The install script generates self-signed certificates automatically:

- **CA** - P-256 EC, 10-year validity
- **Server cert** - signed by the CA, stored in `{release}-ocpp-tls` Secret
- **CSS client cert** - signed by the same CA, stored in `{release}-css-tls` Secret

The TLS Secret must contain `tls.crt`, `tls.key`, and `ca.crt`.

OCPP has two external paths:

- **Gateway route** (`ocpp.evtivity.local`) - plain WebSocket via the gateway. Always available.
- **LoadBalancer** (port 8443) - TLS with optional client cert. Only when `ocpp.tls.enabled: true`.

Station WebSocket URL format: `ws://ocpp.evtivity.local/STATION-001` or `wss://<tls-lb-ip>:8443/STATION-001`.

The API needs the public TLS address to move a connected OCPP 2.1 station from `ws://` to TLS. Set `api.env.stationTlsUrl` (for example `wss://<tls-lb-ip>:8443`). When it is empty and the gateway serves HTTPS, the chart uses `wss://<ocpp route host>`. Otherwise those upgrades are refused.

## Secrets

Two modes for managing sensitive values:

### Chart-Managed (Default)

Set `secrets.create: true` (default). The chart creates a Kubernetes Secret from values passed via `--set` flags. Never commit secrets to `values.yaml`.

Required keys:

| Key | Description |
|-----|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL_API`, `REDIS_URL_OCPP`, `REDIS_URL_OCPI`, `REDIS_URL_WORKER`, `REDIS_URL_CSS` | Redis URL of each service's own ACL user (`ocpi` and `css` only when enabled) |
| `JWT_SECRET` | JWT signing key |
| `SETTINGS_ENCRYPTION_KEY` | AES-256 encryption key for settings |

```bash
helm install evtivity ./evtivity-csms-helm \
  --set secrets.databaseUrl="postgres://..." \
  --set secrets.redisUrls.api="redis://api:..." \
  --set secrets.redisUrls.ocpp="redis://ocpp:..." \
  --set secrets.redisUrls.worker="redis://worker:..." \
  --set secrets.redisUrls.css="redis://css:..." \
  --set secrets.jwtSecret="..." \
  --set secrets.settingsEncryptionKey="..."
```

### External Secrets

Set `secrets.create: false` and `secrets.existingSecret: "my-evtivity-secrets"` to reference a pre-existing Secret created by Vault, Sealed Secrets, or ExternalSecrets. The Secret must contain the same keys: `DATABASE_URL`, `REDIS_URL_API`, `REDIS_URL_OCPP`, `REDIS_URL_OCPI`, `REDIS_URL_WORKER`, `REDIS_URL_CSS`, `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`.

### Redis Access Control

Each service connects to Redis as its own ACL user. The chart's `redis/acl-rules.conf` lists the users and what each may do:

| User | Keys | Pub/sub channels |
|------|------|------------------|
| `api` | Response cache, attestation nonces, payment process watch key (read only) | Core channels and the simulator channels |
| `ocpp` | Station connection registry | Core channels |
| `worker` | BullMQ queues, maintenance locks, payment process watch key | Core channels |
| `ocpi` | OCPI pull locks | `ocpp_commands`, `ocpp_command_results`, `csms_events`, `ocpi_push`, `ocpi_sync`, `ocpi_register` |
| `css` | None | `css_commands`, `css_command_results` |

No user may run admin or dangerous commands (`CONFIG`, `MODULE`, `FLUSHALL`, `KEYS`, `REPLICAOF`, `SHUTDOWN`, `ACL SETUSER` and the rest of the `@dangerous` category). `INFO` stays allowed because BullMQ reads it. A leaked simulator or OCPI credential can no longer command stations, read queued jobs, or reconfigure Redis.

The install script creates the users in the bundled Redis. For an external Redis (7 or later), create them before installing or upgrading. This prints one `ACL SETUSER` command per user. Replace each `CHANGE_ME_*` with a URL-safe password without commas:

```bash
awk '$1 == "user" { name = $2; $1 = $2 = ""; printf "ACL SETUSER %s reset on >CHANGE_ME_%s%s\n", name, toupper(name), $0 }' redis/acl-rules.conf
```

Run them with `redis-cli` as an admin user, persist them (`ACL SAVE` or `CONFIG REWRITE`), and set `secrets.redisUrls.<user>` to `redis://<user>:<password>@<host>:<port>`.

The chart refuses to render while `secrets.redisUrl` is set.

### Redis TLS

Off by default. With TLS on, the per-service passwords and all Redis traffic are encrypted between the pods and Redis, which sits outside the Istio mesh.

- **Bundled Redis:** run `REDIS_TLS=true ./scripts/install.sh` (or answer yes to the TLS prompt). The script stores the Redis server certificate in the Secret `<release>-redis-tls`, starts Redis with TLS only, switches the service URLs to `rediss://`, and sets `redisTls.enabled` and `redisTls.caSecret`. By default it makes a private CA. With cert-manager, set `REDIS_TLS_ISSUER` (and `REDIS_TLS_ISSUER_KIND`, default `ClusterIssuer`) to a CA or self-signed issuer. A re-run keeps an existing certificate.
- **Chart values:** `redisTls.enabled: true` and `redisTls.caSecret` (key `redisTls.caKey`, default `ca.crt`) give every service the CA in `REDIS_TLS_CA_PEM`. The chart refuses to render while a service URL is not `rediss://`.
- **Managed Redis with a public certificate:** use `rediss://` URLs and leave `redisTls` off.

## ConfigMap

Non-sensitive environment variables are stored in a shared ConfigMap mounted by all deployments:

| Variable | Source | Description |
|----------|--------|-------------|
| `NODE_ENV` | `api.env.nodeEnv` | Node environment |
| `LOG_LEVEL` | `api.env.logLevel` | Log verbosity |
| `CORS_ORIGIN` | Auto-derived from routes | Allowed origins |
| `API_PORT` | `api.port` | API listen port |
| `RATE_LIMIT_MAX` | `api.env.rateLimitMax` | Rate limit ceiling |
| `RATE_LIMIT_WINDOW` | `api.env.rateLimitWindow` | Rate limit window |
| `OCPI_COUNTRY_CODE` | `ocpi.env.countryCode` | OCPI country code |
| `OCPI_PARTY_ID` | `ocpi.env.partyId` | OCPI party ID |

`CORS_ORIGIN` is automatically derived from gateway route hostnames. No manual configuration needed.

## Runtime Config

The CSMS and Portal frontends need the API URL at runtime. Since each service has its own hostname in Kubernetes, the API URL cannot be baked into the Docker image.

Each frontend's nginx ConfigMap serves a `/runtime-config.js` endpoint that returns:

```javascript
window.__RUNTIME_CONFIG__ = {
  apiUrl: "http://api.evtivity.local",
  portalUrl: "http://portal.evtivity.local",
  csmsUrl: "http://csms.evtivity.local",
  ocppUrl: "ws://ocpp.evtivity.local"
};
```

Values are derived automatically from the gateway configuration. No separate values key is needed. The frontend `config.ts` module reads `window.__RUNTIME_CONFIG__` with fallbacks to `VITE_*` env vars for local development.

## Migration Job

Database migrations run as a Helm hook job with the migrate image:

- Hook annotations: `pre-upgrade`, `post-install` (weight 0)
- Deletion policy: `before-hook-creation`
- Init container waits for PostgreSQL
- `backoffLimit: 1`

On `helm upgrade`, the job runs before Helm updates the Deployments, so new pods never start against the old schema. If a migration fails, the upgrade stops and the old pods keep running. On upgrade the job reads `DATABASE_URL` from the Secret of the installed release. To change the database URL, upgrade with the new `secrets.databaseUrl` first, then upgrade the image. On `helm install`, the job runs after the Secret and ConfigMap exist. The settings seed job (`post-install`, `post-upgrade`, weight 1) runs after the migration in both cases.

## Initial Admin User

A `post-install` hook (weight 1, runs after migrations) creates an admin role and user. The user is created with `mustResetPassword: true`.

Controlled by:

```yaml
initialAdmin:
  enabled: true
  email: "admin@evtivity.local"
  password: ""  # Set via --set or auto-generated by install script
```

The job uses `ON CONFLICT DO NOTHING` for idempotency. If the admin already exists, the job exits cleanly.

## Autoscaling

HPA is supported for the API and OCPP services. Disabled by default.

```yaml
api:
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 5
    targetCPUUtilization: 70

ocpp:
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 5
    targetCPUUtilization: 70
```

The OCPP HPA includes a 300-second scale-down stabilization window with a maximum of 1 pod removed per 120 seconds. This allows graceful WebSocket session draining.

OCPP horizontal scaling uses `RedisConnectionRegistry` with per-pod instance IDs (from Kubernetes downward API) to route station commands to the correct pod.

## Monitoring

Optional Prometheus, Grafana, Loki, and Alloy stack. Disabled by default (`monitoring.enabled: false`). The install script prompts at install time and defaults to off.

```yaml
monitoring:
  enabled: true
  prometheus:
    retention: 15d
    scrapeInterval: 60s
    storage:
      size: 10Gi
  grafana:
    storage:
      size: 5Gi
  loki:
    enabled: true
    retention: 168h
  alloy:
    enabled: true
```

Components:

- **Prometheus** - scrapes API metrics port (9091)
- **Grafana** - provisions Prometheus and Loki datasources with three pre-built dashboards (system metrics, business metrics, logs)
- **Loki** - log aggregation (sub-toggled under monitoring)
- **Alloy** - ships container logs to Loki (sub-toggled under monitoring)

All monitoring services are deployed as `ClusterIP` only - not exposed via the Gateway and not reachable from outside the cluster. Access them with `kubectl port-forward`:

```bash
kubectl port-forward -n evtivity svc/evtivity-grafana 3000:3000     # http://localhost:3000 (admin / admin)
kubectl port-forward -n evtivity svc/evtivity-prometheus 9090:9090
kubectl port-forward -n evtivity svc/evtivity-loki 3100:3100
```

This is deliberate: Grafana ships with `admin/admin` defaults and Prometheus/Loki have no built-in auth. Expose them through the Gateway only after rotating credentials and adding access controls.

## Image Resolution

Images are resolved from three levels:

```yaml
image:
  registry: ghcr.io/evtivity/evtivity-csms   # Base registry for all services
  tag: ""                       # Defaults to Chart.appVersion
  pullPolicy: IfNotPresent

api:
  image:
    repository: ""              # Per-service override
    tag: ""                     # Per-service tag override
```

Full image reference: `{registry}/{component}:{tag}`. Example: `ghcr.io/evtivity/evtivity-csms/api:0.1.18`.

## Values Reference

Key sections in `values.yaml`:

| Section | Description |
|---------|-------------|
| `image.*` | Global registry, tag, pull policy, pull secrets |
| `api.*` | API service config, resources, autoscaling, rate limits |
| `ocpp.*` | OCPP service config, TLS settings, connection limits |
| `ocpi.*` | OCPI service config, country/party settings |
| `csms.*` | CSMS frontend resources |
| `portal.*` | Portal frontend resources |
| `css.*` | Simulator config, TLS client certs |
| `worker.*` | Background job processor resources |
| `gatewayAPI.*` | Gateway creation, routes, listeners |
| `istio.*` | PeerAuthentication mode, enable toggle |
| `secrets.*` | Secret management mode and values |
| `dependencies.*` | PostgreSQL and Redis host/port for init containers |
| `initialAdmin.*` | Admin user creation settings |
| `monitoring.*` | Prometheus, Grafana, Loki, Alloy config |
| `appSettings.*` | Application settings seeded into the database |

### Currency and price settings

These `appSettings` keys seed the matching dashboard settings. Leave a key empty to keep the value set in the dashboard. A fresh install then starts at the default. The chart fails to render with an unsupported value.

| Key | Values | Default | Setting |
|-----|--------|---------|---------|
| `appSettings.company.currency` | Two-decimal ISO 4217 code, for example `USD` or `EUR` | `USD` | Settings > Company Info > Currency |
| `appSettings.company.taxBasis` | `net` or `gross` | `net` | Settings > Company Info > Tariff prices are entered. Whether tariff prices exclude or include tax. See [Settings](https://www.evtivity.com/docs/csms/settings). |
| `appSettings.company.priceDisplay` | `gross` or `net` | `net` | Settings > Company Info > Prices in the driver portal. Whether drivers see prices including or excluding tax. See [Settings](https://www.evtivity.com/docs/csms/settings). |
| `appSettings.stationMessage.language` | `en`, `de`, `es`, `ko`, `zh`, `zh-TW` | `en` | Settings > Integrations & Features > Messages > Display Language. The language of every station screen. |

```yaml
appSettings:
  company:
    currency: "EUR"
    taxBasis: "gross"
    priceDisplay: "gross"
  stationMessage:
    language: "de"
```

### Payment settings

These keys configure payments. For the `appSettings.payments.*`, `appSettings.simulated.*`, and `appSettings.adyen.*` keys, leave a key empty to keep the value set in the dashboard. The chart fails to render with an unsupported value. See [Payment Providers](https://www.evtivity.com/docs/integrations/payment-providers).

| Key | Values | Default | Setting |
|-----|--------|---------|---------|
| `payments.allowSimulatedProvider` | `true` or `false` | `false` | Sets `PAYMENTS_ALLOW_SIMULATED` on the API, OCPP server, and worker. Allows the test payment provider, which moves no money. Required when demo data is seeded (`seedDemo`). Keep it `false` in production. |
| `appSettings.payments.provider` | `none`, `stripe`, or `simulated` (needs `payments.allowSimulatedProvider`) | empty | Provider of new payments. A fresh install starts at `none`, or `stripe` when a Stripe secret key is stored. `adyen` is refused: select Adyen in Settings > Payment. See [Select Adyen](https://www.evtivity.com/docs/integrations/adyen#9-select-adyen). |
| `appSettings.payments.preAuthAmountCents` | Whole cents, 1 to 1000000 | empty (5000 on a fresh install) | Settings > Payment > General > Default Pre-Auth Amount (`payments.preAuthAmountCents`) |
| `appSettings.payments.platformFeePercent` | 0 to 100 | empty (0 on a fresh install) | Settings > Payment > General > Platform Fee % (`payments.platformFeePercent`) |
| `appSettings.simulated.resultMode` | `sync` or `async` | empty (`sync`) | Settings > Payment > General > Test Provider > Result Mode (`simulated.resultMode`) |
| `appSettings.simulated.asyncDelaySeconds` | Whole seconds, 0 to 3600 | empty (`3`) | Test Provider > Async Result Delay (`simulated.asyncDelaySeconds`) |
| `appSettings.simulated.randomFailureRate` | 0 to 1 | empty (`0.2`) | Test Provider > Random Failure Rate (`simulated.randomFailureRate`) |
| `appSettings.adyen.merchantAccount` | Adyen merchant account code | empty | `adyen.merchantAccount` |
| `appSettings.adyen.clientKey` | Adyen client key. Its allowed origins must list the portal and CSMS URLs. | empty | `adyen.clientKey` |
| `appSettings.adyen.environment` | `test` or `live` | empty (`test`) | `adyen.environment` |
| `appSettings.adyen.liveUrlPrefix` | For example `1797a841fbb37ca7-AdyenDemo`. Required when live. | empty | `adyen.liveUrlPrefix` |
| `appSettings.adyen.liveRegion` | `eu`, `us`, `au`, `nea`, or `in` | empty (`eu`) | `adyen.liveRegion` |
| `appSettings.adyen.webhookUsername` | Basic auth username of the Adyen webhook | empty | `adyen.webhookUsername` |
| `appSettings.adyen.authorisationAdjustment` | `true` or `false` | empty (`false`) | `adyen.authorisationAdjustment`. Set `true` only after Adyen enables authorisation adjustment for your merchant category. |
| `appSettings.mobile.app.urlSchemes` | List of lowercase app URL schemes, not `http`, `https`, or `adyencheckout` | `[evtivity]` | `mobile.app.urlSchemes`. The `scheme` of each mobile app brand. The API accepts an Adyen 3D Secure return to the iOS app only for these. |
| `appSettings.mobile.app.androidPackageNames` | List of Android application ids | `[com.evtivity.driver]` | `mobile.app.androidPackageNames`. The `androidPackage` of each mobile app brand, for the Adyen 3D Secure return on Android. |

The chart refuses `appSettings.stripe.preAuthAmountCents` and `appSettings.stripe.platformFeePercent`. The mobile app lists have defaults, so every upgrade writes them. Set them to your brands, or edit them with `PUT /v1/settings/:key` and keep the chart values in step.

Pass payment credentials with `--set` under `appSettings.sensitive`. Never commit them to `values.yaml`. Secret keys are stored encrypted.

| Key | Setting |
|-----|---------|
| `appSettings.sensitive.stripeSecretKey` | Settings > Payment > Stripe > Secret Key |
| `appSettings.sensitive.stripePublishableKey` | Settings > Payment > Stripe > Publishable Key |
| `appSettings.sensitive.stripeWebhookSecret` | Settings > Payment > Stripe > Webhook Signing Secret, the secret of the platform webhook endpoint. There is no environment variable for it. |
| `appSettings.sensitive.stripeConnectWebhookSecret` | Settings > Payment > Stripe > Connect Webhook Signing Secret, the secret of the Connect webhook endpoint (`stripe.connectWebhookSecretEnc`) |
| `appSettings.sensitive.adyenApiKey` | `adyen.apiKeyEnc` |
| `appSettings.sensitive.adyenHmacKey` | `adyen.hmacKeyEnc`, the hex HMAC key of the Adyen webhook |
| `appSettings.sensitive.adyenHmacKeyPrevious` | `adyen.hmacKeyPreviousEnc`, accepted during a key rotation |
| `appSettings.sensitive.adyenWebhookPassword` | `adyen.webhookPasswordEnc`, the Basic auth password of the Adyen webhook |

## Uninstall

The uninstall script removes all Helm releases and orphaned resources:

```bash
cd evtivity-csms-helm
./scripts/uninstall.sh
```

The script prompts to delete PVCs and the namespace.
