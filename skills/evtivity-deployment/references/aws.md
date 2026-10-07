Generated from https://www.evtivity.com/docs/deployment/aws. Do not edit.

# AWS Deployment

Deploy EVtivity to AWS using CDK (ECS Fargate).

## AWS CDK (ECS Fargate)

The CDK app lives in a separate repository: [github.com/EVtivity/evtivity-csms-cdk](https://github.com/EVtivity/evtivity-csms-cdk). It runs the same platform as the Helm chart on AWS: ECS Fargate (ARM64), Aurora PostgreSQL Serverless v2, ElastiCache Valkey, an Application Load Balancer with WAF, and Prometheus and Grafana for observability.

### Stack Architecture

Six stacks per environment. Supported environments: `dev`, `qa`, `prod`.

| Stack   | Resources |
|---------|-----------|
| Network | VPC across two AZs, public/private/isolated subnets, NAT (fck-nat or NAT gateway), security groups, flow logs |
| Domain  | ACM certificate for `<zone>` and `*.<zone>` (DNS validation in your Route 53 zone) |
| Storage | S3 buckets for app files, logs, and Grafana provisioning |
| Data    | Aurora PostgreSQL 17, ElastiCache Valkey 8, application secrets, credential rotation |
| Alb     | Application Load Balancer, WAF web ACL, Grafana allowlist |
| App     | ECS cluster, database job, services, DNS records, observability, alarms, scheduled redeploys |

All public services share one ALB and are routed by hostname: `csms`, `portal`, `api`, `ocpp` (WebSockets), `ocpi`, and `grafana`. An optional NLB passes OCPP security profile 3 (mutual TLS) straight through to the OCPP server. The API gets the `ocpp` host as `OCPP_STATION_TLS_URL`, the address it gives OCPP 2.1 stations upgraded from `ws://` to TLS.

### Per-Environment Sizing

Each environment is driven by one YAML file (`config/{dev,qa,prod}.yaml`). Every service can be resized or turned off. Defaults:

| Environment | Compute | Aurora | Valkey | NAT | WAF |
|-------------|---------|--------|--------|-----|-----|
| dev  | 1 task per service, Fargate Spot | Serverless v2, 0 to 2 ACU, pauses when idle | t4g.micro, single node | fck-nat | Off |
| qa   | 1 task per service | Serverless v2, 0.5 to 4 ACU | t4g.micro, single node | fck-nat | On |
| prod | 2+ tasks per public service, autoscaling | Serverless v2, 1 to 16 ACU, writer and reader | t4g.medium, replica, failover | NAT gateway x 2 | On |

### Hostnames

Hostnames are `<service>.<subdomain>.<apex>`. With `domain.subdomain: dev`, the dashboard is `csms.dev.example.com`. Production can use an empty subdomain (`csms.example.com`). Rename a service with `services.<name>.hostname`. The stacks only add records under your zone. They never change the apex or `www`.

### Deploying

A one-shot database job runs during every deploy that changes the image or settings: it applies migrations, creates the application database role, seeds the first admin, and writes settings. Services start only after it succeeds. If it fails, CloudFormation rolls back and names the log stream.

```bash
git clone https://github.com/EVtivity/evtivity-csms-cdk.git
cd evtivity-csms-cdk
npm ci

# Account, hosted zone id, admin email (gitignored)
cp config/dev.local.yaml.example config/dev.local.yaml

# Checks: typecheck, lint, compliance tests
npm run typecheck && npm run lint && npm test

# Bootstrap (one-time per account/region)
npx cdk bootstrap aws://ACCOUNT_ID/us-east-1

# Preview, then deploy
npm run synth -- --context env=dev
npm run deploy -- --context env=dev --all
```

A first deploy takes about 30 minutes, mostly Aurora and Valkey.

### Signing In

The App stack prints each service URL as an output. The first dashboard admin is `initialAdmin.email` from the config. Its password is generated at deploy time, and the dashboard asks for a new one at first sign-in:

```bash
aws secretsmanager get-secret-value --secret-id evtivity/dev/initial-admin \
  --query SecretString --output text
```

### Payments

Enter payment credentials in the dashboard (Settings > Payment), not in the config. Leave a key out to keep the value set in the dashboard. The config validates these payment keys:

- `payments.allowSimulatedProvider` (default `false`) allows the test payment provider, which moves no money. It is refused in the `prod` environment and required when `seedDemo.enabled` is true, because demo drivers have test cards.
- `appSettings['payments.provider']` is `none`, `stripe`, or `simulated` (only with `payments.allowSimulatedProvider`). `adyen` is refused: select Adyen in Settings > Payment after the upgrade. See [Select Adyen](https://www.evtivity.com/docs/integrations/adyen#9-select-adyen).
- `appSettings['payments.preAuthAmountCents']` (whole cents, 1 to 1000000) and `appSettings['payments.platformFeePercent']` (0 to 100). The synth refuses the old names `stripe.preAuthAmountCents` and `stripe.platformFeePercent`. The upgrade copies their stored values to the new settings.
- `appSettings['simulated.resultMode']` (`sync` or `async`), `appSettings['simulated.asyncDelaySeconds']` (whole seconds, 0 to 3600), and `appSettings['simulated.randomFailureRate']` (0 to 1), for the test provider.
- `appSettings['mobile.app.urlSchemes']` and `appSettings['mobile.app.androidPackageNames']`, the lists of your mobile app builds for the Adyen 3D Secure return (defaults `[evtivity]` and `[com.evtivity.driver]`). These two keys take lists, as in `mobile.app.urlSchemes: [evtivity, acme]`. See [Mobile App White-labeling](https://www.evtivity.com/docs/mobile-app/white-labeling).
- `appSettings['adyen.environment']` (`test` or `live`), `appSettings['adyen.liveUrlPrefix']` (required when live), `appSettings['adyen.liveRegion']` (`eu`, `us`, `au`, `nea`, or `in`), and `appSettings['adyen.authorisationAdjustment']` (boolean).

The WAF lets Stripe webhooks through only on `/v1/webhooks/payments/stripe` and only from Stripe's published addresses. A POST to exactly `/v1/webhooks/payments/adyen` on the API host skips the country rule, because Adyen sends from outside the allowed countries and publishes no addresses. It has its own rate limit, `waf.adyenWebhookRateLimitPer5Min` (default 1000 per IP per 5 minutes). When you upgrade from v0.1.37 or earlier, deploy the CDK stack in the same window as the application, because the Stripe webhook path changed.

See [Payment Providers](https://www.evtivity.com/docs/integrations/payment-providers).

### Observability

Every environment runs the Helm chart's dashboards and alert rules:

- **Prometheus** runs in agent mode and writes to Amazon Managed Service for Prometheus.
- **Logs** stay in CloudWatch Logs. Grafana reads them directly through its CloudWatch data source, so the logs dashboard uses Logs Insights instead of Loki.
- **Grafana** keeps its database on encrypted EFS. Alerts publish to the environment's SNS topic.

Grafana answers only to addresses in a WAF IP set. Change the list at any time, no deploy needed:

```bash
./scripts/grafana-access.sh dev add me              # this machine's public IP
./scripts/grafana-access.sh dev add 203.0.113.0/24  # an office or VPN range
./scripts/grafana-access.sh dev list
```

Sign in as `admin` with the password from `evtivity/<env>/grafana-admin`.

### Valkey Users

Each enabled service connects to Valkey as its own RBAC user: `api`, `ocpp`, `ocpi`, `worker`, and `css`. A user gets only the keys, pub/sub channels, and commands of its service, from `config/redis-acl-rules.conf`, a copy of the CSMS rules. [Redis Access Control](https://www.evtivity.com/docs/deployment/helm-chart#redis-access-control) lists what each user may do. Each user has its own Secrets Manager secret, `evtivity/<env>/cache-<service>`.

The legacy shared user `cache-app` stays in place but unused for one release, so tasks of the previous release keep working during the upgrade. It is removed in the release after v0.1.38.

A change to `config/redis-acl-rules.conf` updates the users and resets their passwords to the current secrets. Redeploy the services after an ACL change.

### Credential Rotation

The database owner, the application database user, and the Valkey user of each service rotate automatically (every 30 days by default, `rotation.databaseDays` and `rotation.cacheDays`). The application user alternates between two database roles and each Valkey user keeps two active passwords, the current and the pending one, so the previous credential stays valid while services restart. Every service is redeployed weekly to pick up new credentials. Rotation runs on its schedule, not on ordinary deploys, and a failed rotation publishes an alert.

### Security Posture

The stacks are built to pass the AWS Foundational Security Best Practices controls that apply to their resources. Account-level services (Security Hub, AWS Config, CloudTrail, GuardDuty) are out of scope. Every synth runs cdk-nag, and `npm test` asserts the controls for each environment. Highlights:

- Encryption at rest for Aurora, Valkey, S3, EFS, Secrets Manager, and SNS. TLS required to Aurora, Valkey, and S3.
- Every container runs as a non-root user with a read-only root filesystem.
- No task has a public IP. Aurora and Valkey sit in isolated subnets.
- ALB with TLS 1.2+, HTTP-to-HTTPS redirect, and access logs. WAF managed rules and rate limiting in qa and prod.
- Credentials only through Secrets Manager. Valkey uses one RBAC user per service instead of an AUTH token.
- Every resource tagged with `Environment`, `Service`, `Stack`, `CreatedDate`, and `UpdatedDate`.

The repository documents each accepted gap (for example, HTTP between the load balancer and containers) with compensating controls and a review date.

### Cost

Approximate monthly cost with the default configs in `us-east-1`, including observability:

| Environment | Monthly |
|-------------|---------|
| dev  | $127 - $191 |
| qa   | $195 - $262 |
| prod | $598 - $960 |

Aurora and Fargate are the largest items. Setting every service to `desiredCount: 0` in dev lets Aurora pause and drops dev to about $45 per month.

### Release Auto-Bump

When a new CSMS version is released, CI sets `image.tag` in `config/{dev,qa,prod}.yaml` and the `version` in `package.json` of the CDK repository, and tags a matching CDK release. Review the commit and run `npm run deploy` per environment. For stricter promotion, pin a different `image.tag` in the environment's config before deploying.
