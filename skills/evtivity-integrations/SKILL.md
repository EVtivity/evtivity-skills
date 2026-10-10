---
name: evtivity-integrations
description: "Set up EVtivity payments: Stripe, Stripe Connect payouts, Adyen, the test payment provider, holds, captures, refunds, guest payments, currency, payment webhooks and energy management. Use to accept cards, refund a payment, test payments without money, or debug a failed payment or webhook. Not for tariffs and prices (evtivity-csms)."
license: MIT
compatibility: Needs a running EVtivity CSMS (v0.1.38 or later for Adyen and the provider-neutral payment API). API examples use curl and jq. Stripe or Adyen setup needs an account with that provider. Provider webhooks need a public HTTPS URL for the API.
metadata:
  evtivity-version: "0.1.43"
  evtivity-release: "v0.1.43-beta.1"
  evtivity-commit: "d1264d35d3915ca23522cabf67d0336abd705e96"
  evtivity-docs-section: integrations
---

# EVtivity integrations

Not for: pricing groups, tariffs and tax rates (use evtivity-csms), the driver's card form in the portal (use evtivity-portal), environment variables in general (use evtivity-configuration).

The pages of the Integrations docs section are the source of truth. Read the reference for a step before you act on it.

## Safety rules

- Ask the user before any call that moves money or changes live payment behavior: capture, refund, retry capture, pre-authorize, ad hoc payment, changing `payments.provider`, saving provider keys, creating or replacing webhooks, creating payout accounts, changing the company currency or tax basis.
- Never print, log, commit or echo secret keys (`sk_...`, `rk_...`, `whsec_...`, Adyen API key, HMAC key, webhook password). Ask the user to enter them in the dashboard.
- `GET /v1/settings/stripe` and `GET /v1/settings/adyen` return decrypted secrets when the caller also holds `settings.system:read`. Filter them out with jq before you show output.
- Stay in Stripe test mode, the Adyen test environment, or the test provider until the user says to go live.
- Ask before pushing load management or charging profile changes to live stations. They cap the power drivers get.

## API basics

```bash
export EVTIVITY_API=http://localhost:7102      # Docker Compose default
export EVTIVITY_TOKEN=<API key>                  # see evtivity-api, keep it out of logs
```

| Task | Route | Permission |
|---|---|---|
| Provider, pre-auth amount, platform fee, test provider mode | `GET`, `PUT /v1/settings/payments` | `payments:read`, `payments:write` |
| Stripe keys, test, webhooks | `PUT /v1/settings/stripe`, `POST /v1/settings/stripe/test`, `POST /v1/settings/stripe/webhook` | `payments:write` |
| Adyen settings, test, webhook | `PUT /v1/settings/adyen`, `POST /v1/settings/adyen/test`, `POST /v1/settings/adyen/webhook` | `payments:write` |
| Site payment config | `GET`, `PUT`, `DELETE /v1/sites/{id}/payment-config` | `payments:read`, `payments:write` |
| Payout account | `GET`, `POST /v1/sites/{id}/payout-account`, `/refresh`, `/invite` | `payments:read`, `payments:write` |
| Session payment | `GET /v1/sessions/{id}/payment`, `POST /v1/sessions/{id}/pre-authorize`, `/capture`, `/refund` | `payments:read`, `payments:write` |
| Retry a failed top-up | `POST /v1/payments/{id}/retry-capture` | `payments:write` |
| Payment records, reconciliation | `GET /v1/payments`, `GET /v1/payments/reconciliation`, `POST /v1/payments/reconciliation/run` | `payments:read`, `payments:write` |
| Support case or reservation fee refund | `POST /v1/support-cases/{id}/refund`, `POST /v1/reservations/{id}/fee-payments/{paymentId}/refund` | `support:write`, `payments:write` |
| Company currency, tax basis, price display | `PUT /v1/settings/{key}` | `settings.system:write` |
| Load management | `GET`, `PUT /v1/sites/{id}/load-management` | `loadManagement:read`, `loadManagement:write` |

## Workflow

### 1. Check the current payment state (`references/payment-providers.md`)

```bash
curl -s "$EVTIVITY_API/v1/settings/payments" -H "Authorization: Bearer $EVTIVITY_TOKEN" | jq
curl -s "$EVTIVITY_API/v1/settings/stripe" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  | jq 'with_entries(select(.key | test("secret|Secret") | not))'
```

Read `provider` (`none`, `stripe`, `adyen` or `simulated`), `preAuthAmountCents`, `platformFeePercent`, and `providers[]` (`configured`, `selectable`, `reason`).

Decision:

- Development, demo or automated tests: step 2.
- Production card payments, or payouts to site hosts: step 3.
- Production on one Adyen merchant account, without payouts per site: step 4.
- Webhooks or event streams for other systems: step 9. Site power limits or carbon reporting: step 10.
- Payments already work and something failed: step 11.

Rules for every provider:

- Saving a provider's keys never selects it. Select it in Settings > Payment > General > **Provider for New Payments**.
- Provider pinning: a saved card and every hold, capture, top-up, refund and fee stays with the provider that created it. Keep the old provider's credentials until its payments are settled.
- With `none`, sessions start without a hold and guests charge without paying.

### 2. Test payment provider, no real money (`references/test-payment-provider.md`)

1. `PAYMENTS_ALLOW_SIMULATED` must be `true` on the API, OCPP server and worker. Docker Compose sets it. Helm uses `payments.allowSimulatedProvider`, default `false`. Never in production. If it is off, `simulated` is missing from `providers[]`.
2. Select it (confirm first):

   ```bash
   curl -s -X PUT "$EVTIVITY_API/v1/settings/payments" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
     -H 'Content-Type: application/json' -d '{"provider":"simulated","simulated":{"resultMode":"sync"}}' | jq .provider
   ```

3. `sync` behaves like Stripe. `async` confirms captures, cancels and refunds later through signed events, like Adyen. The worker must run for those events.
4. Pay with the test cards on the page. Each card number has a fixed outcome. Run a session on a simulated station (evtivity-simulator).

### 3. Stripe (`references/stripe.md`)

1. Keys: the user enters the Secret Key (or a restricted key with the listed permissions) and Publishable Key in Settings > Payment > Stripe, **Save**, then **Test Connection**.
2. Webhooks: two endpoints (platform and Connect) at `https://<api host>/v1/webhooks/payments/stripe`. **Create webhook** creates both and stores both secrets. It needs Stripe Connect turned on. Without Connect, create the platform endpoint by hand as the page shows. API (confirm first):

   ```bash
   curl -s -X POST "$EVTIVITY_API/v1/settings/stripe/webhook" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
     -H 'Content-Type: application/json' -d '{"url":"https://api.example.com/v1/webhooks/payments/stripe","replace":false}'
   ```

   409 `PAYMENT_WEBHOOK_EXISTS` means endpoints exist at that URL. Ask before you resend with `"replace":true`: Stripe issues new secrets.
3. Local stack: Stripe cannot reach `localhost`. Use `stripe listen` with `--forward-to` and `--forward-connect-to` as the page shows, and enter its one `whsec_...` in both secret fields.
4. Select Stripe (confirm first): `PUT /v1/settings/payments` with `{"provider":"stripe"}`.
5. Going live: repeat with live keys and create the webhooks again in live mode.

Confirm: Stripe shows `configured: true`, a test session paid with `4242 4242 4242 4242` reaches `captured`, and the webhook deliveries succeed.

### 4. Adyen (`references/adyen.md`)

1. Every API, OCPP, OCPI and worker process must run v0.1.38 or later. Never roll back below v0.1.38 after selecting Adyen.
2. Customer Area: API credential with the roles the page lists, API key, client key, and allowed origins for the portal and dashboard hosts.
3. Settings > Payment > Adyen: merchant account, environment, client key, API key. **Save**, then **Test connection**.
4. Settings > Company Info > **Country** must hold a two-letter ISO code. Adyen's card form does not start without it.
5. **Create webhook** at `https://<api host>/v1/webhooks/payments/adyen`. Local stack: a public HTTPS tunnel.
6. Ask Adyen Support for the enablements the page lists before going live.
7. Select Adyen in the dashboard or with `PUT /v1/settings/payments` `{"provider":"adyen"}`. Helm and CDK refuse it. 409 `PAYMENT_PROVIDER_UPGRADE_PENDING` means an older process is connected or was seen in the last 10 minutes.

Limits: no platform fees or payouts per site, cards only, IDR not supported. Captures, cancellations and refunds are confirmed later by webhook.

### 5. Amounts, currency and price display (`references/payment-providers.md`)

- `payments.preAuthAmountCents` (default `5000`) is the default hold. `payments.platformFeePercent` (default `0`) is the fee kept from site host payouts. A site payment config overrides both.
- Payments are charged in the company currency (`company.currency`). Amounts are in cents.
- `company.taxBasis` (`net` or `gross`) decides how tariff prices are entered. `company.priceDisplay` decides only what drivers see. Session costs always include tax.
- Change the currency (confirm first) with `PUT /v1/settings/company.currency` and `{"value":"EUR"}`. An unsupported code answers 400 `VALIDATION_ERROR`. Past records keep their currency. Check with the public `GET /v1/portal/branding`.

### 6. Site payment config and Stripe Connect payouts (`references/stripe.md`)

```bash
curl -s -X PUT "$EVTIVITY_API/v1/sites/$SITE_ID/payment-config" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  -H 'Content-Type: application/json' -d '{"isEnabled":true,"preAuthAmountCents":3000,"platformFeePercent":null}'
```

Send a connected account in `payoutAccountId` (the removed `stripeConnectedAccountId` answers 400). Onboard a site host (confirm first):

1. Give the site a country and a contact email.
2. `POST /v1/sites/$SITE_ID/payout-account` creates an Express account.
3. `POST /v1/sites/$SITE_ID/payout-account/invite` with `{"send":"email"}` or `{"send":"none"}` creates a 7-day EVtivity link. Never send a Stripe onboarding link itself.
4. After onboarding: `POST /v1/sites/$SITE_ID/payout-account/refresh`, then `GET /v1/sites/$SITE_ID/payout-account`.

Confirm: `status` is `active`. Until then, holds at the site are refused (409 `PAYOUT_ACCOUNT_NOT_READY`) and sessions there do not start.

### 7. Holds, capture, top-ups and refunds (`references/payment-providers.md`)

The normal flow needs no API call: hold at session start, capture of the final cost up to the hold at session end, a top-up charge for any cost above the hold, and a daily retry of failed top-ups.

```bash
curl -s "$EVTIVITY_API/v1/sessions/$SESSION_ID/payment" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  | jq '{status, provider, providerPaymentId, preAuthAmountCents, capturedAmountCents, refundedAmountCents, pendingOperation, failureReason, currency}'
```

Refund a payment (confirm session, amount and reason first). Omit `amountCents` for a full refund of the remaining amount:

```bash
curl -s -X POST "$EVTIVITY_API/v1/sessions/$SESSION_ID/refund" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  -H 'Content-Type: application/json' -d '{"amountCents":500,"reason":"Connector fault"}' \
  | jq '{status, refundStatus, refundedAmountCents}'
```

- `refundStatus: "succeeded"` means done. `"pending"` means Adyen or the async test provider confirms it later.
- 409 `PAYMENT_OPERATION_PENDING`: an Adyen capture is not confirmed yet. Retry later.
- Failed top-up shortfall: `POST /v1/payments/{id}/retry-capture` (confirm first). 409 `PAYMENT_RECORD_NOT_RECOVERABLE` means no shortfall.

### 8. Guest, QR and prepaid payments (`references/payment-providers.md`, `references/adyen.md`)

- The guest hold is the cost ceiling. A cost above it is not collected.
- Stripe guest checkout has no 3D Secure step, so a card that needs it is declined (400 `PAYMENT_FAILED`). Adyen runs 3D Secure.
- What a guest sees: public `GET /v1/portal/guest/charger-config/{stationId}/{evseId}` (`paymentEnabled`, `paymentProvider`, `preAuthAmountCents`, `currency`, `isFree`).
- Prepaid tokens: `prepaidBalanceCents` with `POST /v1/tokens` or `PATCH /v1/tokens/{id}`. `null` makes the token postpaid. The balance is debited at session end.
- OCPP 2.1 dynamic QR codes: `PUT /v1/stations/{id}/web-payments`. Payment terminals: `POST /v1/ad-hoc-payments`. Both need an online OCPP 2.1 station.

### 9. Webhooks and event streams (`references/webhooks.md`)

- Incoming payment webhooks: `POST /v1/webhooks/payments/stripe` and `POST /v1/webhooks/payments/adyen`. Both answer 200 only after verification and process each event ID once.
- Outgoing webhooks for OCPP events: Notifications page, OCPP Events tab. Enable the webhook channel per event type and set a recipient URL.
- Real-time streams over SSE: `GET /v1/events/stream` (operators) and `GET /v1/portal/events` (drivers).

### 10. Energy management (`references/energy-management.md`)

1. Model the site: panels, circuits, unmanaged loads, and stations assigned to circuits.
2. Turn on load management with a strategy (confirm first):

   ```bash
   curl -s -X PUT "$EVTIVITY_API/v1/sites/$SITE_ID/load-management" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
     -H 'Content-Type: application/json' -d '{"strategy":"equal_share","isEnabled":true}'
   ```

   `priority_based` uses each station's priority: `PATCH /v1/sites/{id}/stations/{stationId}/load-priority` `{"loadPriority":7}` (1 to 10).
3. The worker recalculates every 10 seconds and sends `ChargingStationExternalConstraints` profiles. The station applies the most restrictive limit. Check with `POST /v1/stations/{id}/charging-profiles/composite`.
4. Carbon tracking: `PUT /v1/sites/{id}/carbon-region` `{"regionCode":"<code>"}`. Codes: `GET /v1/carbon/factors`.

Confirm: `GET /v1/sites/$SITE_ID/load-management` and `/load-management/history`.

### 11. Troubleshoot a payment failure

```bash
curl -s "$EVTIVITY_API/v1/settings/payments" -H "Authorization: Bearer $EVTIVITY_TOKEN" | jq '{provider, providers}'
docker compose logs --tail 200 api worker | grep -i -E 'payment|webhook|stripe|adyen'
```

| Symptom or code | Likely cause | Fix (reference) |
|---|---|---|
| 400 `PAYMENT_PROVIDER_NOT_CONFIGURED` | No provider selected, or the card's pinned provider lost its credentials | Select a provider, or restore the old keys (payment-providers) |
| "Payment processing is not available at this time." | `payments.provider` is `none` | Select a provider (payment-providers) |
| 500 `WEBHOOK_NOT_CONFIGURED` | Signing secrets or Adyen webhook credentials not stored | Create the webhook again (stripe, adyen) |
| 400 or 401 `WEBHOOK_SIGNATURE_INVALID` or `WEBHOOK_SIGNATURE_MISSING` | Wrong secret, or an Adyen event for another merchant account or environment | Recreate the webhook in the same mode (webhooks) |
| Stripe deliveries fail after an upgrade from v0.1.37 or earlier | Endpoint still on the removed `/v1/webhooks/stripe` | Move it to `/v1/webhooks/payments/stripe` (stripe) |
| 409 `PAYOUT_ACCOUNT_NOT_READY` | Payout account not `active` | Finish onboarding, refresh (stripe) |
| 409 `PAYMENT_PROVIDER_UPGRADE_PENDING` | An older process is connected | Finish the upgrade, wait 10 minutes (adyen) |
| Adyen card form fails | Missing company country or allowed origin | Company Info > Country and the client key origins (adyen) |
| Adyen payments stuck awaiting confirmation | Webhook missing or failing | Customer Area webhook event log (adyen) |
| Adyen hold adjustment never confirmed | The answer to the raise was lost | Wait for the daily reconciliation, which re-sends it after 1 hour with the same idempotency key, or run it now with `POST /v1/payments/reconciliation/run`. Act only when listed as `pending_confirmation` after 24 hours (adyen) |
| Test provider events never arrive | Worker not running | Start the worker (test-payment-provider) |

Run reconciliation on demand (also daily over the last 48 hours): `POST /v1/payments/reconciliation/run`. Stack failures: evtivity-troubleshoot. Never include keys, card numbers or webhook secrets in a bug report.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer.

- `references/payment-providers.md`: provider choice, payment settings, pinning, lifecycle, statuses, reconciliation.
- `references/stripe.md`: Stripe keys, webhooks, local testing, Stripe Connect payouts.
- `references/adyen.md`: Adyen credential, webhook, enablements, selection after upgrade, async confirmations, adjustment re-send.
- `references/test-payment-provider.md`: simulated provider, test cards, sync and async modes.
- `references/webhooks.md`: incoming payment webhooks, outgoing OCPP event webhooks, SSE streams.
- `references/energy-management.md`: load management, smart charging profiles, carbon tracking.
