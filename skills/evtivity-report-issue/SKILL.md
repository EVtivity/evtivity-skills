---
name: evtivity-report-issue
description: "Report an EVtivity bug to the maintainers: gather the version, deployment, steps and redacted diagnostics, search existing GitHub issues, draft the issue and open it on EVtivity/evtivity-csms only after the user confirms. Use to report a bug or file an issue. Not for fixing the failure yourself (evtivity-troubleshoot)."
license: MIT
compatibility: Requires the GitHub CLI (gh) signed in to a GitHub account. The diagnostics step needs bash, Docker and curl.
metadata:
  evtivity-version: "0.1.40"
  evtivity-release: "v0.1.40"
  evtivity-commit: "571bdc26947f0fc8a9a2626615d53eac39d251db"
---

# Report an EVtivity issue

Not for: diagnosing and fixing a failure (use evtivity-troubleshoot first), security vulnerabilities (follow `SECURITY.md` of the CSMS repository, never a public issue).

Issues go to https://github.com/EVtivity/evtivity-csms/issues. The goal is one issue a maintainer can reproduce without asking questions, and no private data in it.

Hard rules:

- Never include secrets: passwords, API keys, tokens, JWTs, signing secrets, private keys, certificates, connection strings with credentials, or the contents of `.env`.
- Never include personal data: driver or user names, email addresses, phone numbers, card details, home addresses, public IP addresses or hostnames the user did not approve.
- Open the issue only after the user has read the final text and said yes.

## Steps

### 1. Check gh

```bash
gh auth status
```

If gh is missing or not signed in, the user can still get the draft and open the issue in the browser.

### 2. Gather the facts

Ask for what you cannot find yourself:

- Version: `curl -s http://<api-host>:7102/v1/version`, or `git describe --tags` in the checkout, or the image tag in the Helm values or CDK config.
- Deployment: Docker Compose (local or server), Helm on Kubernetes, AWS CDK, or development with `npm run dev:*`. Add OS, Docker version and architecture for Compose.
- Area: dashboard, driver portal, REST API, OCPP (version 1.6 or 2.1, station vendor and model, security profile), OCPI, payments (provider), worker jobs, other.
- Steps to reproduce, numbered, from a known state.
- Expected behavior and actual behavior. Exact error codes (`code` in the API response, such as `EVSE_IN_USE`) and HTTP statuses help most.
- Since when: a new install, after an upgrade (from which version), or after a configuration change.

When the problem involves an API call, reproduce it with curl and keep the request path, the status and the response `code` (the evtivity-api skill shows how).

### 3. Collect diagnostics

For a Compose install, use the diagnostics script of the evtivity-troubleshoot skill. It masks secrets, emails, RFID values, IP addresses and hostnames by default. If that skill is not installed, install it first:

```bash
npx skills add EVtivity/evtivity-skills --skill evtivity-troubleshoot
```

Then run its `scripts/diagnose.sh --dir /path/to/evtivity-csms` from that skill's directory. Its `--redact` option masks logs you collect by hand: `docker compose logs --tail 300 api | bash scripts/diagnose.sh --redact`.

Without it, collect the same facts by hand:

```bash
docker compose ps -a
curl -s http://localhost:7102/v1/version
curl -s http://localhost:7102/v1/health
docker compose logs --no-color --tail 300 <service> | grep -iE 'warn|error|fatal' | tail -n 20
```

For Helm, use `kubectl get pods` and `kubectl logs --tail 300 <pod>`. For AWS, use the service's CloudWatch log group.

### 4. Redact

Redaction is pattern based. Read the output again and remove:

- anything left that looks like a password, token, key or certificate,
- email addresses, names and phone numbers of drivers and users (replace with `driver@example.com`),
- public hostnames and IP addresses unless the user wants them shown (replace with `csms.example.com`, `203.0.113.10`),
- station serial numbers and identities if the user asks.

Keep log lines short. Twenty relevant lines beat three hundred.

### 5. Search existing issues

```bash
gh issue list -R EVtivity/evtivity-csms --state all --search "<error code or key words>" --limit 20
```

Search the error code first, then two or three key words. If an issue matches, show it to the user and offer to comment with the new facts instead (`gh issue comment <number> -R EVtivity/evtivity-csms --body-file <file>`).

### 6. Draft the issue

Fill `references/issue-template.md`. Title: one line with the area and the symptom, for example `OCPP 1.6: station reconnects every 30 s with security profile 2`. Write the body to a temporary file and show the full title and body to the user.

### 7. Open it after confirmation

Only after the user says yes:

```bash
gh issue create -R EVtivity/evtivity-csms --title "<title>" --body-file <file>
```

Print the issue URL. Delete the temporary file. If the user declines, keep the draft in the conversation so they can edit it or open it at https://github.com/EVtivity/evtivity-csms/issues/new.
