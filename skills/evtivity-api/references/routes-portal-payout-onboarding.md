# EVtivity API routes: Portal Payout Onboarding

Generated from EVtivity CSMS v0.1.42 (https://github.com/EVtivity/evtivity-csms, commit a4268227cc43) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/portal/payout-onboarding/link` | public | Start Stripe onboarding from a payout onboarding link |
| POST | `/v1/portal/payout-onboarding/status` | public | Read the payout account status after Stripe onboarding |
