# EVtivity API routes: Payments

Generated from EVtivity CSMS v0.1.42 (https://github.com/EVtivity/evtivity-csms, commit a4268227cc43) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites/{id}/payment-config` | payments:read | Get payment configuration for a site |
| PUT | `/v1/sites/{id}/payment-config` | payments:write | Create or update payment configuration for a site |
| DELETE | `/v1/sites/{id}/payment-config` | payments:write | Delete payment configuration for a site |
| GET | `/v1/settings/stripe` | payments:read | Get system Stripe settings |
| PUT | `/v1/settings/stripe` | payments:write | Update system Stripe settings |
| POST | `/v1/settings/stripe/test` | payments:write | Test Stripe API connection |
| GET | `/v1/settings/stripe/webhook` | payments:read | Get the Stripe webhook setup |
| POST | `/v1/settings/stripe/webhook` | payments:write | Create the Stripe webhooks |
| GET | `/v1/sites/payment-configs` | payments:read | List all site payment configurations |
| GET | `/v1/drivers/{id}/payment-methods` | payments:read | List payment methods for a driver |
| POST | `/v1/drivers/{id}/payment-methods` | payments:write | Save a payment method for a driver |
| POST | `/v1/drivers/{id}/payment-methods/setup-intent` | payments:write | Create a Stripe setup intent for a driver |
| POST | `/v1/drivers/{id}/payment-methods/setup/submit` | payments:write | Submit a card collected for a driver by the payment provider card UI |
| POST | `/v1/drivers/{id}/payment-methods/setup/details` | payments:write | Continue a card setup for a driver after a client action |
| DELETE | `/v1/drivers/{id}/payment-methods/{pmId}` | payments:write | Delete a payment method for a driver |
| PATCH | `/v1/drivers/{id}/payment-methods/{pmId}/default` | payments:write | Set a payment method as default for a driver |
| POST | `/v1/sessions/{id}/pre-authorize` | payments:write | Pre-authorize a payment for a charging session |
| POST | `/v1/sessions/{id}/capture` | payments:write | Capture a pre-authorized payment for a session |
| POST | `/v1/sessions/{id}/refund` | payments:write | Refund a captured payment for a session |
| GET | `/v1/reservations/{id}/fee-payments` | payments:read | List the fee payments of a reservation |
| POST | `/v1/reservations/{id}/fee-payments/{paymentId}/refund` | payments:write | Refund a reservation fee payment |
| GET | `/v1/sessions/{id}/payment` | payments:read | Get payment record for a session |
| POST | `/v1/payments/{id}/retry-capture` | payments:write | Retry capture or top-up for a payment record |
| GET | `/v1/payments/reconciliation` | payments:read | List payment reconciliation runs |
| POST | `/v1/payments/reconciliation/run` | payments:write | Run payment reconciliation against Stripe |
| GET | `/v1/payments` | payments:read | List all payment records |
| GET | `/v1/settings/adyen` | payments:read | Get Adyen settings |
| PUT | `/v1/settings/adyen` | payments:write | Update Adyen settings |
| POST | `/v1/settings/adyen/test` | payments:write | Test the Adyen connection |
| GET | `/v1/settings/adyen/webhook` | payments:read | Get the Adyen webhook |
| POST | `/v1/settings/adyen/webhook` | payments:write | Create the Adyen webhook |
| GET | `/v1/sites/{id}/payout-account` | payments:read | Get the payout account of a site |
| POST | `/v1/sites/{id}/payout-account` | payments:write | Create the Stripe payout account of a site |
| POST | `/v1/sites/{id}/payout-account/refresh` | payments:write | Read the payout account status from Stripe |
| POST | `/v1/sites/{id}/payout-account/invite` | payments:write | Create the onboarding link of a site payout account |
| GET | `/v1/settings/payments` | payments:read | Get payment settings |
| PUT | `/v1/settings/payments` | payments:write | Update payment settings |
| POST | `/v1/ad-hoc-payments` | payments:write | Start a transaction for an authorized ad hoc payment |
