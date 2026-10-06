Generated from https://www.evtivity.com/docs/deployment/minikube (website commit 900fb20). Do not edit.

# Minikube

Run EVtivity CSMS on a local Kubernetes cluster using minikube for development and testing.

## Purpose

Run the full EVtivity CSMS stack on a local Kubernetes cluster. Useful for testing Helm chart changes, validating gateway routing, and verifying Kubernetes-specific behavior before deploying to a production cluster.

## Prerequisites

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm 3](https://helm.sh/docs/intro/install/)
- [istioctl](https://istio.io/latest/docs/setup/getting-started/#download) (if using Istio)

## Start minikube

Start a cluster with enough resources for all services:

```bash
minikube start --cpus=4 --memory=8192
```

## Install Gateway API CRDs

Gateway API CRDs are required before installing any gateway implementation:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

## Install a Gateway Implementation

Choose one. Istio is recommended for a production-like environment.

### Istio (Recommended)

```bash
istioctl install --set profile=minimal -y
kubectl label namespace default istio-injection=enabled
```

### Envoy Gateway

```bash
helm install eg oci://docker.io/envoyproxy/gateway-helm \
  --version v1.3.2 \
  --namespace envoy-gateway-system \
  --create-namespace
```

## Install EVtivity CSMS

Clone the Helm chart repository and run the install script:

```bash
git clone https://github.com/EVtivity/evtivity-csms-helm.git
cd evtivity-csms-helm
./scripts/install.sh
```

The script prompts for:

1. **Gateway implementation** - select Istio or Envoy Gateway
2. **Bundled PostgreSQL** - accept the default (yes)
3. **Bundled Redis** - accept the default (yes)

The script auto-generates secrets, TLS certificates, and database passwords. It installs PostgreSQL, Redis, and the CSMS chart in order.

After completion, the script prints the admin email and password.

## Access Services

Open a tunnel in a separate terminal to expose the Gateway's LoadBalancer:

```bash
minikube tunnel
```

Keep this terminal open. The tunnel assigns an external IP (typically `127.0.0.1`) to the Gateway's LoadBalancer Service.

## DNS Setup

Get the Gateway's external IP:

```bash
kubectl get svc -n evtivity | grep LoadBalancer
```

Add entries to `/etc/hosts` pointing to the tunnel IP:

```bash
127.0.0.1 csms.evtivity.local
127.0.0.1 portal.evtivity.local
127.0.0.1 api.evtivity.local
127.0.0.1 ocpp.evtivity.local
127.0.0.1 ocpi.evtivity.local
```

On macOS:

```bash
sudo nano /etc/hosts
```

## Verify

Open [http://csms.evtivity.local](http://csms.evtivity.local) in your browser. Log in with the admin credentials printed by the install script.

## Useful Commands

Check pod status:

```bash
kubectl get pods -n evtivity
```

View logs for a service:

```bash
kubectl logs -n evtivity -l app.kubernetes.io/component=api --tail=100
kubectl logs -n evtivity -l app.kubernetes.io/component=ocpp --tail=100
```

Check Helm release status:

```bash
helm status evtivity -n evtivity
```

List all Helm releases in the namespace:

```bash
helm list -n evtivity
```

## Upgrade to the latest version

### Check the latest version

The latest CSMS release is published in three places:

- The [GitHub releases page](https://github.com/EVtivity/evtivity-csms/releases)
- `https://evtivity.com/csms-version.txt` - a plain-text mirror used by the dashboard
- The CSMS dashboard itself shows an "Update available" toast to admin users when a newer version exists

Prereleases (tags such as `v0.1.38-beta.1`, `v0.1.38-nightly.1`, or `v0.1.38-alpha.1`) are marked **Pre-release** on the GitHub releases page and publish images under their exact version only. They are not announced: `csms-version.txt` and the dashboard toast only name stable releases, and the chart's `appVersion` does not move to a prerelease. A dashboard running a prerelease is told when the stable release of that version ships.

### Pull the latest chart

```bash
cd evtivity-csms-helm
git pull
```

The release pipeline bumps `appVersion` in `Chart.yaml` whenever a new CSMS version ships, so the chart and the application stay in sync.

### Run the upgrade

```bash
helm upgrade evtivity . -n evtivity --reuse-values
```

`--reuse-values` preserves your existing configuration (database URLs, secrets, TLS certs, gateway hostnames) and applies only the changes from the new chart. The image tag is taken from `Chart.yaml`'s `appVersion`, which the release pipeline updates automatically.

### Pin to a specific version

To upgrade to a version other than the chart's default `appVersion`:

```bash
helm upgrade evtivity . -n evtivity --reuse-values --set image.tag=0.1.2
```

Image tags have no `v` prefix. The release `v0.1.2` publishes images tagged `0.1.2`, and the chart uses `image.tag` as given.

### Verify

Watch pods cycle to the new images:

```bash
kubectl rollout status deployment -n evtivity
kubectl get pods -n evtivity -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u
```

All deployments use rolling updates, so the dashboard, portal, OCPP, and API stay reachable during the upgrade. Stations stay connected to the existing OCPP pod until that pod terminates; they reconnect to a new pod automatically.

## Roll back

If an upgrade introduces a regression, revert the Helm release to a previous revision.

### View history

```bash
helm history evtivity -n evtivity
```

Lists every revision with its chart version, app version, deployment status, and timestamp. Use this to pick a rollback target.

### Roll back to the previous revision

```bash
helm rollback evtivity -n evtivity
```

With no revision number, Helm reverts to the immediately previous revision.

### Roll back to a specific revision

```bash
helm rollback evtivity 5 -n evtivity
```

Replace `5` with the revision number from `helm history`. Use this when you need to skip past several recent revisions to a known-good one.

### What rollback does and doesn't change

Helm rollback re-applies the manifests from the target revision. This affects:

- Image tags (pods restart with the older images)
- Helm-managed resources (Deployments, Services, ConfigMaps, HTTPRoutes, AuthorizationPolicies)
- Values stored in the release at the target revision

Helm rollback does NOT touch:

- **Database schema.** Migrations that ran during the upgrade are not reversed. If the upgrade included a breaking schema change, the older application code may be incompatible with the newer schema. Plan a forward fix or restore from a `pg_dump` snapshot instead.
- **PersistentVolumeClaims.** Data on persistent volumes is preserved across rollback.
- **Secrets managed outside the chart** (Vault, ExternalSecrets, Sealed Secrets).
- **Connected charging stations.** They reconnect to the rolled-back OCPP pod automatically as it cycles.

### Verify

```bash
kubectl rollout status deployment -n evtivity
helm list -n evtivity
helm history evtivity -n evtivity | head -3
```

`helm list` should report `STATUS: deployed`. `helm history` shows a new revision entry (rollbacks create a new revision rather than deleting the bad one). Pod images should match the rolled-back chart's `appVersion`.

## Teardown

Remove the CSMS and its dependencies:

```bash
cd evtivity-csms-helm
./scripts/uninstall.sh
```

The script prompts to delete PVCs and the namespace.

Delete the minikube cluster:

```bash
minikube delete
```
