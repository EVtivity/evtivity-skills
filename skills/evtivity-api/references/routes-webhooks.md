# EVtivity API routes: Webhooks

Generated from EVtivity CSMS v0.1.42-beta.1 (https://github.com/EVtivity/evtivity-csms, commit 34bf507e0fc3) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/webhooks/payments/stripe` | public | Handle Stripe webhook events |
| POST | `/v1/webhooks/payments/adyen` | public | Handle Adyen webhook events |
