# Issue template

Fill every section. Write "unknown" rather than leaving one out. Remove these instruction lines and the comments before you show the draft.

~~~~markdown
## Summary

<!-- One or two sentences: what fails, where, and how often. -->

## Environment

- EVtivity version: <!-- /v1/version, git tag or image tag, e.g. 0.1.39 -->
- Deployment: <!-- Docker Compose / Helm / AWS CDK / npm run dev -->
- Host: <!-- OS, architecture, Docker version (Compose installs) -->
- Area: <!-- dashboard / portal / API / OCPP / OCPI / payments / worker / other -->
- Station: <!-- OCPP 1.6 or 2.1, vendor, model, firmware, security profile; or "n/a" -->
- Payment provider: <!-- Stripe / Adyen / test provider / none; or "n/a" -->
- Started: <!-- new install / after upgrade from X / after a configuration change -->

## Steps to reproduce

1.
2.
3.

## Expected behavior

## Actual behavior

<!-- Include the HTTP status and the error `code` from the API response, the dashboard message, or the station behavior. -->

## Diagnostics

<details>
<summary>Diagnostics (redacted)</summary>

```text
<!-- Output of diagnose.sh or the commands from the skill. No secrets, no personal data. -->
```

</details>

## Logs

```text
<!-- The few log lines around the failure, redacted. -->
```

## Workaround

<!-- What the user tried and whether anything helps. "None found" is fine. -->
~~~~
