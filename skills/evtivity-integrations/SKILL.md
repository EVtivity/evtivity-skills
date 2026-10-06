---
name: evtivity-integrations
description: Set up, test and troubleshoot the EVtivity CSMS integrations. Covers the payment providers (Stripe, Adyen and the simulated test payment provider), choosing the active provider and provider pinning, payment settings (pre-auth amount, platform fee), Stripe and Adyen webhooks and signing secrets, Stripe Connect payout accounts and site host onboarding, holds (pre-authorization), capture, top-ups, refunds, retry capture, reconciliation, guest and QR code payments, prepaid tokens, reservation fees, test cards, the company currency and net or gross price display, outgoing webhooks, SSE event streams, and energy management (load management, smart charging profiles, carbon footprint tracking). Use when someone wants to accept card payments, connect Stripe or Adyen, onboard a site host, refund a session, test payments without real money, receive webhooks, limit site power, or find out why a hold, capture, refund, webhook or guest checkout failed.
license: MIT
compatibility: Needs a running EVtivity CSMS (v0.1.38 or later for Adyen and the provider-neutral payment API). API examples use curl and jq. Stripe or Adyen setup needs an account with that provider. Provider webhooks need a public HTTPS URL for the API.
metadata:
  evtivity-version: "0.1.39"
  evtivity-docs-section: integrations
---

# EVtivity integrations

This skill covers the six pages of the Integrations docs section. The pages are the source of truth. Read the page for a step before you act on it.

| Page id | Live page | Use it for |
|---|---|---|
| integrations/payment-providers | https://www.evtivity.com/docs/integrations/payment-providers | Provider choice, payment settings, pinning, lifecycle, statuses, reconciliation |
| integrations/stripe | https://www.evtivity.com/docs/integrations/stripe | Stripe keys, webhooks, local testing, Stripe Connect payouts |
| integrations/adyen | https://www.evtivity.com/docs/integrations/adyen | Adyen credential, webhook, enablements, selection after upgrade, async confirmations |
| integrations/test-payment-provider | https://www.evtivity.com/docs/integrations/test-payment-provider | Simulated provider, test cards, sync and async modes |
| integrations/webhooks | https://www.evtivity.com/docs/integrations/webhooks | Incoming payment webhooks, outgoing OCPP event webhooks, SSE streams |
| integrations/energy-management | https://www.evtivity.com/docs/integrations/energy-management | Load management, smart charging profiles, carbon tracking |

Related skills:

- `evtivity-getting-started`: run the stack locally.
- `evtivity-configuration`: environment variables such as `PAYMENTS_ALLOW_SIMULATED`.
- `evtivity-deployment`: Helm and AWS values for payment settings and secrets.
- `evtivity-csms`: dashboard pages (Settings > Payment, Company Info, Pricing, Sessions, Sites, Tokens, Load Management, Smart Charging).
- `evtivity-portal`: driver payment methods and guest charging.
- `evtivity-mobile-app`: adding cards in the app.
- `evtivity-simulator`: simulated stations for test sessions.
- `evtivity-conformance`: OCTT runs.
- `evtivity-guides`: end-to-end guides such as portal setup and smart charging.
- `evtivity-api`: API keys, authentication, route catalog, error codes.
- `evtivity-troubleshoot`: stack failures.
- `evtivity-report-issue`: file a bug when behavior does not match the docs.

## Safety rules

- Ask the user before any call that moves money or changes live payment behavior: capture, refund, retry capture, pre-authorize, ad hoc payment, changing `payments.provider`, saving provider keys, creating or replacing webhooks, creating payout accounts, changing the company currency or tax basis.
- Never print, log, commit or echo secret keys (`sk_...`, `rk_...`, `whsec_...`, Adyen API key, HMAC key, webhook password). Ask the user to enter them in the dashboard.
- `GET /v1/settings/stripe` and `GET /v1/settings/adyen` return decrypted secrets when the caller also holds `settings.system:read`. Filter them out with jq before you show output.
- Stay in Stripe test mode, the Adyen test environment, or the test provider until the user says to go live.
- Ask before pushing load management or charging profile changes to live stations. They cap the power drivers get.

## API basics

Create an API key with the `evtivity-api` skill. All examples use:

```bash
export EVTIVITY_API=http://localhost:7102      # Docker Compose default
export EVTIVITY_TOKEN=<API key>                  # Bearer token, keep it out of logs
```

| Task | Route | Permission |
|---|---|---|
| Read or set provider, pre-auth amount, platform fee, test provider mode | `GET`, `PUT /v1/settings/payments` | `payments:read`, `payments:write` |
| Stripe keys, test, webhooks | `GET`, `PUT /v1/settings/stripe`, `POST /v1/settings/stripe/test`, `GET`, `POST /v1/settings/stripe/webhook` | `payments:read`, `payments:write` |
| Adyen settings, test, webhook | `GET`, `PUT /v1/settings/adyen`, `POST /v1/settings/adyen/test`, `GET`, `POST /v1/settings/adyen/webhook` | `payments:read`, `payments:write` |
| Site payment config | `GET`, `PUT`, `DELETE /v1/sites/{id}/payment-config`, `GET /v1/sites/payment-configs` | `payments:read`, `payments:write` |
| Payout account | `GET`, `POST /v1/sites/{id}/payout-account`, `POST .../refresh`, `POST .../invite` | `payments:read`, `payments:write` |
| Session payment | `GET /v1/sessions/{id}/payment`, `POST /v1/sessions/{id}/pre-authorize`, `/capture`, `/refund` | `payments:read`, `payments:write` |
| Retry a failed top-up | `POST /v1/payments/{id}/retry-capture` | `payments:write` |
| Payment records, reconciliation | `GET /v1/payments`, `GET /v1/payments/reconciliation`, `POST /v1/payments/reconciliation/run` | `payments:read`, `payments:write` |
| Support case refund | `POST /v1/support-cases/{id}/refund` | `support:write` |
| Reservation fee refund | `POST /v1/reservations/{id}/fee-payments/{paymentId}/refund` | `payments:write` |
| Company currency, tax basis, price display | `PUT /v1/settings/{key}` | `settings.system:write` |
| Prepaid token balance | `POST /v1/tokens`, `PATCH /v1/tokens/{id}` | `drivers:write` |
| Load management | `GET`, `PUT /v1/sites/{id}/load-management`, panels, circuits, unmanaged loads | `loadManagement:read`, `loadManagement:write` |
| Smart charging templates | `/v1/smart-charging/templates...` | `smartCharging:read`, `smartCharging:write` |

## Workflow

### 1. Check the current payment state

```bash
curl -s "$EVTIVITY_API/v1/settings/payments" -H "Authorization: Bearer $EVTIVITY_TOKEN" | jq
```

Read `provider` (`none`, `stripe`, `adyen` or `simulated`), `preAuthAmountCents`, `platformFeePercent`, and `providers[]`. Each provider entry shows `configured`, `selectable` and `reason` (`not_configured` or `requires_upgrade`).

Safe read of Stripe settings:

```bash
curl -s "$EVTIVITY_API/v1/settings/stripe" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  | jq 'with_entries(select(.key | test("secret|Secret") | not))'
```

Decision (page integrations/payment-providers, https://www.evtivity.com/docs/integrations/payment-providers):

- Development, demo or automated tests: step 2.
- Production card payments, or payouts to site hosts: step 3.
- Production on one Adyen merchant account, without payouts per site: step 4.
- Webhooks or event streams for other systems: step 9.
- Site power limits or carbon reporting: step 10.
- Payments already work and something failed: step 11.

Rules that apply to every provider:

- Saving a provider's keys never selects it. Select it in Settings > Payment > General > **Provider for New Payments**.
- Provider pinning: a saved card and every hold, capture, top-up, refund and fee stays with the provider that created it. Keep the old provider's credentials until its payments are settled.
- With `none`, sessions start without a hold and guests charge without paying.

### 2. Test payment provider (no real money)

Page: integrations/test-payment-provider, https://www.evtivity.com/docs/integrations/test-payment-provider

1. `PAYMENTS_ALLOW_SIMULATED` must be `true` on the API, OCPP server and worker. Docker Compose sets it. Helm uses `payments.allowSimulatedProvider`, default `false`. Never enable it in production. If it is off, `simulated` is missing from `providers[]`.
2. Select it (confirm with the user):

   ```bash
   curl -s -X PUT "$EVTIVITY_API/v1/settings/payments" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
     -H 'Content-Type: application/json' -d '{"provider":"simulated","simulated":{"resultMode":"sync"}}' | jq .provider
   ```

3. Choose the mode. `sync` behaves like Stripe. `async` confirms captures, cancels and refunds later through signed events, like Adyen. The worker must run for those events to arrive.
4. Pay with the test cards listed on the page. Each card number has a fixed outcome (approve, decline, needs authentication, capture fails, refund fails, dispute). Run a session on a simulated station (`evtivity-simulator` skill).

Confirm: `provider` is `simulated`, and the portal card form shows "Test mode, no real money. Pick a test card."

### 3. Stripe

Page: integrations/stripe, https://www.evtivity.com/docs/integrations/stripe

1. Keys: the user enters the Secret Key (or a restricted key with the permissions the page lists) and Publishable Key in Settings > Payment > Stripe, clicks **Save**, then **Test Connection**. API: `PUT /v1/settings/stripe` with `secretKey` and `publishableKey`, then `POST /v1/settings/stripe/test`.
2. Webhooks: two endpoints (platform and Connect) at `https://<api host>/v1/webhooks/payments/stripe`. **Create webhook** creates both and stores both secrets. It needs Stripe Connect turned on. Without Connect, create the platform endpoint by hand as the page shows. API (confirm first):

   ```bash
   curl -s -X POST "$EVTIVITY_API/v1/settings/stripe/webhook" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
     -H 'Content-Type: application/json' \
     -d '{"url":"https://api.example.com/v1/webhooks/payments/stripe","replace":false}'
   ```

   409 `PAYMENT_WEBHOOK_EXISTS` means endpoints exist at that URL. Ask the user before you resend with `"replace":true`, because Stripe issues new secrets.
3. Local stack: Stripe cannot reach `localhost`. Use `stripe listen` with `--forward-to` and `--forward-connect-to` as the page shows, and enter its one `whsec_...` in both secret fields.
4. Select Stripe (confirm first):

   ```bash
   curl -s -X PUT "$EVTIVITY_API/v1/settings/payments" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
     -H 'Content-Type: application/json' -d '{"provider":"stripe"}' | jq .provider
   ```

5. Going live: repeat with live keys and create the webhooks again in live mode.

Confirm: Stripe shows `configured: true`, a test session paid with `4242 4242 4242 4242` reaches `captured`, and Stripe shows the webhook deliveries succeeded.

### 4. Adyen

Page: integrations/adyen, https://www.evtivity.com/docs/integrations/adyen

1. Every API, OCPP, OCPI and worker process must run v0.1.38 or later. Never roll back below v0.1.38 after selecting Adyen.
2. Customer Area: API credential with the roles the page lists, API key, client key, and allowed origins for the portal and dashboard hosts.
3. Settings > Payment > Adyen: merchant account, environment, client key, API key. **Save**, then **Test connection**. It lists the credential roles.
4. Settings > Company Info > **Country** must hold a two-letter ISO code. Adyen's card form does not start without it.
5. **Create webhook** at `https://<api host>/v1/webhooks/payments/adyen`. Success shows `success` with response code `200`. Local stack: use a public HTTPS tunnel as the page shows.
6. Ask Adyen Support for the enablements the page lists before going live.
7. Select Adyen in Settings > Payment > General or with `PUT /v1/settings/payments` `{"provider":"adyen"}`. Helm and CDK refuse it. 409 `PAYMENT_PROVIDER_UPGRADE_PENDING` means an older process is still connected or was seen in the last 10 minutes. Wait until old pods are gone, then 10 more minutes.

Limits: no platform fees or payouts per site (a site with a payout account cannot take Adyen payments), cards only, IDR not supported. Captures, cancellations and refunds are confirmed later by webhook.

Confirm: the webhook test shows `success`, and a test session's Payment tab moves from **Capture awaiting confirmation** to confirmed.

### 5. Amounts, currency and price display

Pages: integrations/payment-providers (payment settings, currencies), plus the Settings and Pricing dashboard pages (`evtivity-csms` skill).

- `payments.preAuthAmountCents` (default `5000`) is the default hold. `payments.platformFeePercent` (default `0`) is the default fee kept from site host payouts. Set them with `PUT /v1/settings/payments` (`preAuthAmountCents`, `platformFeePercent`). A site payment config overrides both.
- Payments are charged in the company currency (`company.currency`). There is no provider currency setting. Amounts are stored in cents.
- `company.taxBasis` (`net` or `gross`) decides how tariff prices are entered. `company.priceDisplay` (`net` or `gross`) decides only what drivers and guests see. Session costs always include tax.

```bash
curl -s -X PUT "$EVTIVITY_API/v1/settings/company.currency" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  -H 'Content-Type: application/json' -d '{"value":"EUR"}'
```

An unsupported code answers 400 `VALIDATION_ERROR`. Past sessions, payments and invoices keep their currency. Confirm with the public `GET /v1/portal/branding`.

### 6. Site payment config and Stripe Connect payouts

Page: integrations/stripe, section Stripe Connect, https://www.evtivity.com/docs/integrations/stripe#4-stripe-connect

```bash
curl -s -X PUT "$EVTIVITY_API/v1/sites/$SITE_ID/payment-config" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  -H 'Content-Type: application/json' -d '{"isEnabled":true,"preAuthAmountCents":3000,"platformFeePercent":null}'
```

- Send a connected account in `payoutAccountId`. From v0.1.39 the removed `stripeConnectedAccountId` field answers 400 `VALIDATION_ERROR`.
- Payouts need Stripe Connect enabled, with the platform loss responsibilities acknowledged.

Onboard a site host:

1. Give the site a country and a contact email.
2. `POST /v1/sites/$SITE_ID/payout-account` (optional `contactEmail`, `country`) creates an Express account.
3. `POST /v1/sites/$SITE_ID/payout-account/invite` with `{"send":"email"}` or `{"send":"none"}` creates a 7-day EVtivity link. Never send a Stripe onboarding link itself.
4. After the site host finishes, `POST /v1/sites/$SITE_ID/payout-account/refresh`, then `GET /v1/sites/$SITE_ID/payout-account`.

Confirm: `status` is `active`. Until then, holds at the site are refused (409 `PAYOUT_ACCOUNT_NOT_READY`) and sessions there do not start.

### 7. Holds, capture, top-ups and refunds

Page: integrations/payment-providers, section Payment Lifecycle, https://www.evtivity.com/docs/integrations/payment-providers#payment-lifecycle

The normal flow needs no API call: hold at session start, capture of the final cost (tax included) up to the hold at session end, a top-up charge for any cost above the hold (or, on Adyen with **Authorization Adjustment** on, a raised hold), and a daily retry of failed top-ups.

Check a session's payment:

```bash
curl -s "$EVTIVITY_API/v1/sessions/$SESSION_ID/payment" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  | jq '{status, provider, preAuthAmountCents, capturedAmountCents, refundedAmountCents, pendingOperation, failureReason, currency}'
```

Read the provider-neutral fields (`provider`, `providerPaymentId`). The v0.1.39 release notes removed the `stripe*` fields from payment responses.

Refund (confirm session, amount and reason with the user first). Omit `amountCents` for a full refund of the remaining amount.

```bash
curl -s -X POST "$EVTIVITY_API/v1/sessions/$SESSION_ID/refund" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
  -H 'Content-Type: application/json' -d '{"amountCents":500,"reason":"Connector fault"}' \
  | jq '{status, refundStatus, refundedAmountCents}'
```

- `refundStatus: "succeeded"` means done. `"pending"` means Adyen or the async test provider confirms it later.
- 409 `PAYMENT_OPERATION_PENDING`: an Adyen capture is not confirmed yet. Retry later.
- Failed top-up shortfall: `POST /v1/payments/{id}/retry-capture` (confirm first). 409 `PAYMENT_RECORD_NOT_RECOVERABLE` means no shortfall to collect.

Confirm: `GET /v1/sessions/$SESSION_ID/payment` shows `captured`, `partially_refunded` or `refunded` as expected.

### 8. Guest, QR and prepaid payments

Pages: integrations/payment-providers (guest payments) and integrations/adyen (guest 3D Secure). The guest checkout screens are in the portal docs (`evtivity-portal` skill).

- The guest hold is the cost ceiling. A cost above it is not collected. When the site hold is below the tariff session fee, the guest is held the session fee plus the hold.
- Stripe guest checkout has no 3D Secure step, so a card that needs it is declined (400 `PAYMENT_FAILED`). Adyen runs 3D Secure.
- Check what a guest sees: public `GET /v1/portal/guest/charger-config/{stationId}/{evseId}` returns `paymentEnabled`, `paymentProvider`, `preAuthAmountCents`, `currency` and `isFree`.
- Prepaid tokens: set `prepaidBalanceCents` (company currency cents) with `POST /v1/tokens` or `PATCH /v1/tokens/{id}`. `null` makes the token postpaid. A balance of zero or less is refused at Authorize. The balance is debited at session end, with no card hold.
- OCPP 2.1 dynamic QR codes: `PUT /v1/stations/{id}/web-payments`. Payment terminals: `POST /v1/ad-hoc-payments`. Both need an online OCPP 2.1 station. Read the route descriptions in the `evtivity-api` skill before you use them.

### 9. Webhooks and event streams

Page: integrations/webhooks, https://www.evtivity.com/docs/integrations/webhooks

- Incoming payment webhooks: `POST /v1/webhooks/payments/stripe` and `POST /v1/webhooks/payments/adyen`. Both answer 200 only after verification and process each event ID once. The test provider has no HTTP endpoint. The worker delivers its events.
- Outgoing webhooks for OCPP events: Notifications page, OCPP Events tab. Enable the webhook channel per event type and set a recipient URL. EVtivity sends a JSON POST with `eventType`, `timestamp`, `stationId` and event fields.
- Real-time streams: `GET /v1/events` (operators) and `GET /v1/portal/events` (drivers), over SSE.

Confirm an incoming webhook: the provider shows delivery code 200, and the API log shows the event verified.

### 10. Energy management

Page: integrations/energy-management, https://www.evtivity.com/docs/integrations/energy-management. Dashboard steps are on the Load Management and Smart Charging pages (`evtivity-csms` skill).

1. Model the site: panels, circuits under panels, unmanaged loads on circuits, and stations assigned to circuits.
2. Turn on load management with a strategy (confirm first):

   ```bash
   curl -s -X PUT "$EVTIVITY_API/v1/sites/$SITE_ID/load-management" -H "Authorization: Bearer $EVTIVITY_TOKEN" \
     -H 'Content-Type: application/json' -d '{"strategy":"equal_share","isEnabled":true}'
   ```

   `priority_based` uses each station's load priority, set with `PATCH /v1/sites/{id}/stations/{stationId}/load-priority` `{"loadPriority":7}` (1 to 10).
3. The worker recalculates every 10 seconds and sends profiles with purpose `ChargingStationExternalConstraints`. Smart charging templates use `ChargingStationMaxProfile` or `TxDefaultProfile`, never that purpose. The station applies the most restrictive limit.
4. Check the merged result on a station with `POST /v1/stations/{id}/charging-profiles/composite`.
5. Carbon tracking: set the site carbon region with `PUT /v1/sites/{id}/carbon-region` `{"regionCode":"<code>"}`. List codes with `GET /v1/carbon/factors`.

Confirm: `GET /v1/sites/$SITE_ID/load-management` shows the config and station allocations, and `GET /v1/sites/$SITE_ID/load-management/history` shows new entries.

### 11. Troubleshoot a payment failure

Collect evidence first:

```bash
curl -s "$EVTIVITY_API/v1/settings/payments" -H "Authorization: Bearer $EVTIVITY_TOKEN" | jq '{provider, providers}'
curl -s "$EVTIVITY_API/v1/sessions/$SESSION_ID/payment" -H "Authorization: Bearer $EVTIVITY_TOKEN" | jq
docker compose logs --tail 200 api worker | grep -i -E 'payment|webhook|stripe|adyen'
```

| Symptom or code | Likely cause | Fix (page) |
|---|---|---|
| 400 `PAYMENT_PROVIDER_NOT_CONFIGURED` | No provider selected, or the card's pinned provider lost its credentials | Select a provider, or restore the old provider's keys (integrations/payment-providers) |
| Portal says "Payment processing is not available at this time." | `payments.provider` is `none` | Select a provider (integrations/payment-providers) |
| 500 `WEBHOOK_NOT_CONFIGURED` | Signing secrets or Adyen webhook credentials not stored | Create the webhook again (integrations/stripe, integrations/adyen) |
| 400 or 401 `WEBHOOK_SIGNATURE_INVALID` or `WEBHOOK_SIGNATURE_MISSING` | Wrong secret, or an Adyen event for another merchant account or environment. 401 is Adyen Basic auth. | Recreate the webhook in the same mode (integrations/webhooks) |
| Stripe deliveries fail after an upgrade from v0.1.37 or earlier | Endpoint still on the removed `/v1/webhooks/stripe` | Move it to `/v1/webhooks/payments/stripe` (integrations/stripe) |
| 409 `PAYOUT_ACCOUNT_NOT_READY`, sessions at one site do not start | Payout account not `active` | Finish onboarding, refresh (integrations/stripe) |
| 409 `PAYMENT_PROVIDER_UPGRADE_PENDING` | An older process is connected | Finish the upgrade, wait 10 minutes (integrations/adyen) |
| Adyen card form fails, "Card setup failed" | Missing company country or allowed origin | Set Company Info > Country and the client key origins (integrations/adyen) |
| Adyen payments stuck awaiting confirmation | Webhook missing or failing | Check the webhook event log in the Customer Area (integrations/adyen) |
| 400 `PAYMENT_FAILED` on Stripe guest checkout | Card requires 3D Secure | Use another card (integrations/stripe) |
| Test provider events never arrive | Worker not running | Start the worker (integrations/test-payment-provider) |
| `captured` with a shortfall | Top-up declined | Wait for the daily retry or retry capture (integrations/payment-providers) |

Run reconciliation on demand (also daily at 4 AM over the last 48 hours, test provider skipped):

```bash
curl -s -X POST "$EVTIVITY_API/v1/payments/reconciliation/run" -H "Authorization: Bearer $EVTIVITY_TOKEN" | jq
```

For stack failures use `evtivity-troubleshoot`. If behavior contradicts the docs, use `evtivity-report-issue`. Never include keys, card numbers or webhook secrets in a report.

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `integrations/adyen` | `references/adyen.md` | https://www.evtivity.com/docs/integrations/adyen |
| `integrations/energy-management` | `references/energy-management.md` | https://www.evtivity.com/docs/integrations/energy-management |
| `integrations/payment-providers` | `references/payment-providers.md` | https://www.evtivity.com/docs/integrations/payment-providers |
| `integrations/stripe` | `references/stripe.md` | https://www.evtivity.com/docs/integrations/stripe |
| `integrations/test-payment-provider` | `references/test-payment-provider.md` | https://www.evtivity.com/docs/integrations/test-payment-provider |
| `integrations/webhooks` | `references/webhooks.md` | https://www.evtivity.com/docs/integrations/webhooks |
