---
name: evtivity-report-issue
description: Report a bug or problem in the EVtivity CSMS to the maintainers as a GitHub issue on EVtivity/evtivity-csms. Gathers the version, deployment type, steps to reproduce, expected and actual behavior and redacted diagnostics, searches for an existing issue, drafts the issue from a template, and opens it only after the user confirms the text. Use when someone wants to report a bug, file an issue, ask the maintainers for help, or a problem remains after troubleshooting.
license: MIT
compatibility: Requires the GitHub CLI (gh) signed in to a GitHub account. The diagnostics step needs bash, Docker and curl.
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39-beta.1"
  evtivity-commit: "bd06577f1cf17f235971d9652327b04b768cee81"
---

# Report an EVtivity issue

Issues go to https://github.com/EVtivity/evtivity-csms/issues. The goal is one issue a maintainer can reproduce without asking questions, and no private data in it.

Hard rules:

- Never include secrets: passwords, API keys, tokens, JWTs, signing secrets, private keys, certificates, connection strings with credentials, or the contents of `.env`.
- Never include personal data: driver or user names, email addresses, phone numbers, card details, home addresses, public IP addresses or hostnames the user did not approve.
- Open the issue only after the user has read the final text and said yes.
- Security vulnerabilities do not go in a public issue. Point the user to the repository's security policy (`SECURITY.md`) instead.

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

When the problem involves an API call, reproduce it with curl and keep the request path, the status and the response `code`. The `evtivity-api` skill shows how to call the API.

### 3. Collect diagnostics

For a Compose install, run the diagnostics script of the `evtivity-troubleshoot` skill:

```bash
bash ../evtivity-troubleshoot/scripts/diagnose.sh --dir /path/to/evtivity-csms
```

The path is relative to this skill's directory. When that skill is not installed, collect the same facts by hand:

```bash
docker compose ps -a
curl -s http://localhost:7102/v1/version
curl -s http://localhost:7102/v1/health
docker compose logs --no-color --tail 300 <service> | grep -iE 'warn|error|fatal' | tail -n 20
```

For Helm, use `kubectl get pods` and `kubectl logs --tail 300 <pod>`. For AWS, use the service's CloudWatch log group.

### 4. Redact

The script masks common secret patterns. It is pattern based, so read the output again and remove:

- anything left that looks like a password, token, key or certificate,
- email addresses, names and phone numbers of drivers and users (replace with `driver@example.com`),
- public hostnames and IP addresses unless the user wants them shown (replace with `csms.example.com`, `203.0.113.10`),
- station serial numbers and identities if the user asks.

Keep log lines short. Twenty relevant lines beat three hundred.

### 5. Search existing issues

```bash
gh issue list -R EVtivity/evtivity-csms --state all --search "<error code or key words>" --limit 20
```

Search the error code first, then two or three key words. If an issue matches, show it to the user. Offer to add a comment with the new facts instead of a new issue:

```bash
gh issue comment <number> -R EVtivity/evtivity-csms --body-file <file>
```

### 6. Draft the issue

Fill `references/issue-template.md`. Title: one line with the area and the symptom, for example `OCPP 1.6: station reconnects every 30 s with security profile 2`. Write the body to a temporary file and show the full title and body to the user.

### 7. Open it after confirmation

Only after the user says yes:

```bash
gh issue create -R EVtivity/evtivity-csms --title "<title>" --body-file <file>
```

Print the issue URL. Delete the temporary file. If the user declines, keep the draft in the conversation so they can edit it or open it at https://github.com/EVtivity/evtivity-csms/issues/new.
