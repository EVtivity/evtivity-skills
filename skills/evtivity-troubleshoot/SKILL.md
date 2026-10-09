---
name: evtivity-troubleshoot
description: "Fix EVtivity failures: a station cannot connect or stays offline, a service or container is down or restarting, migrate failed, sign-in blocked by reCAPTCHA, Redis errors, ports in use, a broken upgrade. Runs a redacted diagnostics script. Use whenever something fails or shows errors. Not for stuck sessions or SuspendedEV (evtivity-guides)."
license: MIT
compatibility: Requires bash, Docker with Docker Compose v2 and curl. Written for Docker Compose installs; the symptoms and fixes also apply to Helm and AWS deployments.
metadata:
  evtivity-version: "0.1.42"
  evtivity-release: "v0.1.42-beta.6"
  evtivity-commit: "83073ffb3163330362c883e1662959e99a018c04"
---

# EVtivity troubleshooting

Not for: field problems on a running network such as a stuck session, a stale connector status or `SuspendedEV` (use evtivity-guides, `references/troubleshooting.md` here), a session the CSMS could not end (use evtivity-csms, Bill session), payment setup from scratch (use evtivity-integrations), filing a bug (use evtivity-report-issue).

Work from evidence. Run the diagnostics first, find the matching symptom below, confirm it with the listed check, then apply the fix. Ask the user before anything that deletes data.

## 1. Collect diagnostics

Run `scripts/diagnose.sh` from this skill's directory. It reads only.

```bash
bash scripts/diagnose.sh --dir /path/to/evtivity-csms
```

It prints the versions (checkout, image names, API `/v1/version`), container states, health endpoints, ports held by other processes, and the last warning and error lines of each service.

Redaction is on by default: passwords, tokens, keys, JWTs, Stripe and Adyen keys, URL credentials, PEM blocks (also multi-line), RFID `idTag` and `idToken` values, email addresses, IP addresses and hostnames are masked, and `BIND_IP` and `CORS_ORIGIN` are left out. Loopback addresses stay. `--keep-hosts` keeps IP addresses, hostnames, `BIND_IP` and `CORS_ORIGIN`, for the user's own use only. `--redact` masks any text on stdin the same way, for logs collected by hand. Redaction is pattern based: read the output before it is shared.

Useful single commands, run in the checkout:

```bash
docker compose ps -a
docker compose logs --tail 100 <service>      # api, ocpp, worker, migrate, redis, postgres
curl -s http://localhost:7102/v1/health
```

## 2. Decision tree

Start at the first symptom that matches.

- `migrate` exited with a non-zero code, and api, ocpp and worker are `created` but never start: go to A.
- A port is already allocated, or a container will not bind: go to F.
- api, ocpp or worker restarts, and its log shows Redis errors (`WRONGPASS`, `NOPERM`, `ECONNREFUSED ...:6379`): go to D.
- The stack is healthy but sign-in fails with `RECAPTCHA_REQUIRED` or `RECAPTCHA_FAILED`: go to C.
- A charging station stays offline or reconnects in a loop: go to B.
- Card payments, guest checkout or webhooks fail with `PAYMENT_PROVIDER_NOT_CONFIGURED` or `WEBHOOK_NOT_CONFIGURED`: go to E.
- The problem started after `git pull`, a checkout of a new tag, or an image upgrade: go to G.
- A session is `faulted` with stopped reason `EndRequestFailed` (Session End Failed alert): this is a field problem, not a stack failure. Bill it with the evtivity-csms skill (Bill session), or see evtivity-guides field troubleshooting.
- Reports stay `pending`, or the worker log shows `NOPERM` on `report_generate` or `ocpp:conn:*` after an upgrade to v0.1.40: go to D.
- None of these: collect diagnostics and use the evtivity-report-issue skill.

### A. Migrate container failed

The API, OCPP server and worker wait for `migrate` to exit with code 0 (`service_completed_successfully`). A failed migration keeps them down on purpose.

Confirm: `docker compose ps -a migrate` shows `Exited (1)`, then `docker compose logs migrate | tail -n 40`.

Fix by cause:

- Database not reachable: check `docker compose ps postgres` is healthy. Start it with `docker compose up -d postgres`, wait, then go on.
- Upgrade path: some releases must be installed in order. The release notes state it, for example installs on v0.1.37 or earlier must run v0.1.38 before the release after it. Check out the required intermediate tag, run it once, then upgrade. Notes: https://github.com/EVtivity/evtivity-csms/releases.
- Downgrade: the database has migrations newer than the checkout. Check out the version the database was last migrated with.
- Migration verifier error (a migration file not recorded): rebuild the migrate image from a clean checkout of the tag (`git status` clean, then `docker compose build migrate`).

Then `docker compose up migrate` (watch it exit 0) and `docker compose up -d`.

### B. Station cannot connect

EVtivity never creates a station on its own. An unknown station gets HTTP 404 at the WebSocket upgrade.

Confirm in the dashboard: open the station, Security tab, Security Event Log. `auth_failed` entries name the reason. Also `docker compose logs --tail 200 ocpp | grep -i <stationId>`.

Check in this order:

1. Station exists: it is listed under Stations, with the exact OCPP identity. The URL path is case-sensitive.
2. URL: profile 0 or 1 uses `ws://<host>:7103/<stationId>`. Profile 2 or 3 uses `wss://<host>:8443/<stationId>`. The `/<stationId>` suffix is required. Behind a load balancer, use the public host and port.
3. Security profile: the station's profile equals the profile on the station record.
4. Basic Auth: the username is the station identity, the password is the one set on the Security tab. 16 to 40 characters for OCPP 2.1, 16 to 20 for OCPP 1.6, letters, digits and `* - _ = : + | @ .`. Set a new one with Change Password and enter the same value on the station.
5. TLS (profile 2 and 3): the station must trust the CA that signed the server certificate, and the certificate must name the host the station dials. The Compose certificate is a self-signed test certificate for `localhost` and `ocpp` only. For a real station, set `OCPP_TLS_CERT`, `OCPP_TLS_KEY` and `OCPP_TLS_CA` to your own files and install your CA on the station. Profile 3 also needs a client certificate signed by the CA the server trusts. Check the server with `openssl s_client -connect <host>:8443 -servername <host> </dev/null | head -n 20`.
6. HTTP 403 at connect: the station was rejected (blocked). Unblock it on the station page.
7. Connects but stays Pending: `approval-required` registration policy. Approve the station under Stations, filter Pending.

Onboarding steps: evtivity-guides. Security profiles and TLS: evtivity-configuration.

### C. reCAPTCHA blocks sign-in

Sign-in answers 400 `RECAPTCHA_REQUIRED` or 403 `RECAPTCHA_FAILED`. reCAPTCHA v3 is off by default. When an operator turns it on (Settings > Security), Google only issues valid tokens on the domains listed for the site key. A host not on that list, such as a new domain, an IP address or a LAN name, fails every sign-in.

Confirm: the browser console shows a reCAPTCHA domain error, or the API log shows the codes above. `curl -s http://<api>/v1/security/public` shows `recaptchaEnabled: true`.

Fix, best first:

1. Add the host to the site key's domain list in the Google reCAPTCHA admin console. Sign in again.
2. If no operator can sign in, turn reCAPTCHA off in the database (ask the user first), then let the cache expire (60 seconds) or restart the API:

   ```bash
   docker compose exec postgres psql -U evtivity -d evtivity -c \
     "UPDATE settings SET value = 'false'::jsonb, updated_at = now() WHERE key = 'security.recaptcha.enabled';"
   docker compose restart api
   ```

   Sign in, fix the domain list, then turn reCAPTCHA back on in Settings > Security.

### D. Redis connection or ACL errors

Each service connects to Redis as its own ACL user (`api`, `ocpp`, `ocpi`, `worker`, `css`). Compose creates the users from `docker/redis/acl-rules.conf` at every Redis start, with passwords from `REDIS_<USER>_PASSWORD` (default `<user>-dev-password`).

Confirm: `docker compose logs --tail 100 api ocpp worker | grep -iE 'redis|WRONGPASS|NOPERM'` and `docker compose logs --tail 50 redis`.

- `WRONGPASS invalid username-password pair`: Redis and a service disagree on a password, usually after a `REDIS_*_PASSWORD` change in `.env` with only some containers recreated. `docker compose up -d --force-recreate redis api ocpp worker simulator`.
- Redis exits at start with a missing password message: a `REDIS_*_PASSWORD` is set to an empty value in `.env`. Set it or remove the line.
- `NOPERM`: use the ACL file of the same release as the images. A mixed checkout or old Helm values cause this. v0.1.40 adds the `report_generate` channel (api, ocpp, worker) and worker read access to `ocpp:conn:*`. Helm and CDK installs must upgrade the chart or stack with the images.
- `ECONNREFUSED` or `ENOTFOUND redis`: Redis is down or unhealthy. `docker compose up -d redis` and check its log.
- Passwords must be URL-safe: they go into each service's `REDIS_URL`.
- Helm and external Redis: create the five users with the chart's `redis/acl-rules.conf` and set one URL per service (evtivity-deployment). `rediss://` with a private CA needs `REDIS_TLS_CA_PEM` or `REDIS_TLS_CA_FILE`.

### E. Payment provider not configured

`payments.provider` starts at `none`. Saving keys does not select a provider.

Confirm: the error code is `PAYMENT_PROVIDER_NOT_CONFIGURED` (400), or webhooks answer 500 `WEBHOOK_NOT_CONFIGURED`. Settings > Payment > General shows the selected provider and which providers are ready.

Fix: enter the provider's keys (Settings > Payment > Stripe or Adyen), then pick it in **Provider for New Payments**. Create the webhooks from the same page. Adyen also needs the company country (Settings > Company Info). The test provider needs `PAYMENTS_ALLOW_SIMULATED=true` (development only). A saved card stays with the provider that created it, so keep the old provider's keys until its payments settle. Full setup: evtivity-integrations.

### F. Ports in use

Compose publishes 5433 (PostgreSQL), 6379 (Redis, loopback only), 7100 to 7104, 8443 and 9229, plus 7107 to 7109 and 9090 with profiles.

Confirm: `docker compose up` reports `port is already allocated` or `address already in use`. `diagnose.sh` lists ports held by other processes. By hand: `lsof -nP -iTCP:<port> -sTCP:LISTEN`.

Fix: stop the other process or container, or move EVtivity with `CSMS_PORT`, `PORTAL_PORT`, `API_PORT`, `OCPP_PORT` or `OCPI_PORT` in `.env`, then `docker compose up -d`. A second EVtivity checkout uses the same Compose project name (`evtivity`). Stop one with `docker compose -p evtivity down` before you start the other.

### G. Stale images or volume after an upgrade

Compose builds images from the checkout. After a new tag, `docker compose up -d` without `--build` keeps running the old images.

Confirm: API `/v1/version` differs from `package.json` in the checkout, or the UI lacks a change the release notes list.

Fix: `git status` (clean, at the new tag), then `docker compose up -d --build`.

Stale volume: the data in a volume does not fit the release, for example after a downgrade, a skipped required upgrade step, or a PostgreSQL major version change (`database files are incompatible with server`). Read the release notes for the upgrade path first. For data you must keep, back up first: `docker compose exec postgres pg_dump -U evtivity evtivity > backup.sql`. For disposable data only, and only after the user agrees: `docker compose down --volumes` (deletes all data), then `docker compose up -d`.

## 3. After the fix

Run `scripts/diagnose.sh` again and confirm every service is healthy and the symptom is gone. If the problem stays, use the evtivity-report-issue skill with the diagnostics output.

## References

Generated from the website docs. Never edit them. The first line is the live page URL: link it when you answer.

- `references/troubleshooting.md`: field fixes for stuck sessions, stale connector status and `SuspendedEV`.
