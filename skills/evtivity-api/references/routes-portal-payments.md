# EVtivity API routes: Portal Payments

Generated from EVtivity CSMS v0.1.42-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 627b28b192ed) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/payment-methods` | driver | List saved payment methods |
| POST | `/v1/portal/payment-methods` | driver | Save a payment method after Stripe setup |
| POST | `/v1/portal/payment-methods/ephemeral-key` | driver | Create a Stripe ephemeral key for the native PaymentSheet |
| POST | `/v1/portal/payment-methods/setup-intent` | driver | Create a Stripe SetupIntent for adding a payment method |
| POST | `/v1/portal/payment-methods/setup/submit` | driver | Submit a card collected by the payment provider card UI |
| POST | `/v1/portal/payment-methods/setup/details` | driver | Continue a card setup after a client action |
| DELETE | `/v1/portal/payment-methods/{pmId}` | driver | Delete a saved payment method |
| PATCH | `/v1/portal/payment-methods/{pmId}/default` | driver | Set a payment method as the default |
| GET | `/v1/portal/payment-provider` | driver | Get the active payment provider descriptor |
