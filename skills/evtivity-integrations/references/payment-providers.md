Generated from https://www.evtivity.com/docs/integrations/payment-providers. Do not edit.

# Payment Providers

Overview of the payment providers. Stripe, Adyen, and the test provider, how the active provider is chosen, provider pinning, the payment lifecycle, webhooks, statuses, and reconciliation.

EVtivity takes card payments through a payment provider. Every payment flow (card registration, pre-authorization, capture, top-up, refund, reservation fees, guest checkout, reconciliation) runs through one provider interface, so the flows behave the same with each provider.

## Providers

| Provider | Status | Use |
|---|---|---|
| [Stripe](https://www.evtivity.com/docs/integrations/stripe) | Available | Production card payments, including Stripe Connect payouts per site |
| [Adyen](https://www.evtivity.com/docs/integrations/adyen) | Available from v0.1.38. Select it in Settings > Payment after the upgrade. | Alternative to Stripe for one merchant account, without payouts per site |
| [Test (simulated)](https://www.evtivity.com/docs/integrations/test-payment-provider) | Available in development and test deployments | Development, demos, and automated tests. Moves no money. |

Each provider has its own step-by-step setup page.

## Choosing the Active Provider

The `payments.provider` setting selects the provider of new payments:

| Value | Effect |
|---|---|
| `none` | Payments are off. Drivers cannot add cards, and paid guest checkout is unavailable. |
| `stripe` | New cards and new holds use Stripe. |
| `adyen` | New cards and new holds use Adyen. Select it in Settings > Payment. Helm and CDK refuse it. See [Select Adyen](https://www.evtivity.com/docs/integrations/adyen#9-select-adyen). |
| `simulated` | New cards and new holds use the test provider. Only allowed where the test provider is enabled. Its sync and async modes are both allowed in deployments. |

Select the provider in Settings > Payment > General, in **Provider for New Payments**. Saving a provider's keys does not select it. The list shows which providers are ready, and a provider without credentials cannot be selected. A fresh install starts at `none`, or at `stripe` when a Stripe secret key is already stored. On Helm, set `appSettings.payments.provider`. On CDK, set `appSettings['payments.provider']`. Leave it empty to keep the value stored in the database. The API is `GET` and `PUT /v1/settings/payments`.

### Payment Settings

These settings apply to every provider. Set them in Settings > Payment > General.

| Setting | Default | Description |
|---|---|---|
| `payments.provider` | `none` | Provider of new payments, see above |
| `payments.preAuthAmountCents` | `5000` | Default hold placed on a card when a session starts, in cents of the company currency (1 to 1000000). A site configuration can override it. |
| `payments.platformFeePercent` | `0` | Default platform fee on payments through a site host payout account (0 to 100). A site configuration can override it. |
| `simulated.resultMode` | `sync` | Test provider only: `sync` or `async`. See [Sync and Async Modes](https://www.evtivity.com/docs/integrations/test-payment-provider#sync-and-async-modes). |
| `simulated.asyncDelaySeconds` | `3` | Test provider only: delay of async results, 0 to 3600 seconds |
| `simulated.randomFailureRate` | `0.2` | Test provider only: failure rate of cards without a test scenario, 0 to 1 |

Before v0.1.38 the pre-auth amount and the platform fee were `stripe.preAuthAmountCents` and `stripe.platformFeePercent`, set on the Stripe tab. The upgrade copies them to the `payments.*` settings. The `stripe.*` names are deprecated: EVtivity still writes them for processes of the previous release during the upgrade, and a later release removes them. `PUT /v1/settings/stripe` no longer takes them, and `GET /v1/settings/stripe` no longer returns them. Helm and CDK refuse the old names.

### Provider Pinning

Existing payments stay with their provider. A saved card, and every hold, capture, top-up, refund, and fee on a payment, always goes to the provider that created it, never to the active one. Switching the active provider affects only new cards and new holds. Keep the credentials of the previous provider set until its open payments are settled and no more refunds are expected. When a pinned provider is not configured, a hold on that card is skipped with a warning, and a capture or refund answers 400 `PAYMENT_PROVIDER_NOT_CONFIGURED`.

## Payment Lifecycle

### Registered Drivers

1. **Card registration**: The driver saves a card. The provider stores it. EVtivity keeps only the provider ID, brand, and last 4 digits.
2. **Pre-authorization**: When a charging session starts, EVtivity places a hold for the pre-auth amount on the saved card. If the hold is declined, the session does not start, or stops at once, and the driver is notified.
3. **Capture**: When the session ends, EVtivity captures the final cost, including tax, up to the hold. A cost of 0 cancels the hold.
4. **Top-up**: When the final cost exceeds the hold, the hold is captured in full and the rest is charged to the same card as a second payment. A declined top-up leaves the payment `captured` with the shortfall recorded. A daily job retries it. Operators can also retry it with `POST /v1/payments/:id/retry-capture`.

### Guest Payments

Guest drivers pay at checkout without registering a card. EVtivity places a hold on the card before the session starts. When the session ends, it captures the actual amount, at most the hold. A guest has no saved card, so a cost above the hold is not collected and the payment record shows the shortfall. If the station rejects the start, the hold is cancelled. Holds of expired guest sessions are cancelled automatically. When the hold set for the site is below the session fee (tax included) of the tariff a guest pays, the guest is held the session fee plus that hold, so the hold stays available for energy. Without it the station would stop at once: the hold is the cost limit the station enforces.

### Reservation Fees

Reservation cancellation and no-show fees are configured excluding tax. When a fee is charged, the tax rate of the station's tariff for the driver is added, and the gross amount is charged to the driver's saved card through the site's connected account, with the platform fee of its net amount. Each fee gets a payment record (pending before the charge, then captured or failed) with its tax rate. A retry of the same fee charges nothing. Fees count in revenue and appear on the driver's aggregated invoice. See [Reservations](https://www.evtivity.com/docs/csms/reservations).

### Retries

Every call that moves money carries an idempotency key built from an EVtivity ID, such as the session or the payment record. A retried request returns the original result and never charges twice.

## Webhooks

Providers report asynchronous outcomes (failed payments, refunds, disputes, account changes) through webhooks. Each provider has its own endpoint on the API:

| Provider | Endpoint | Verification | Setup |
|---|---|---|---|
| Stripe | `POST /v1/webhooks/payments/stripe` | `Stripe-Signature` header, checked against the platform and Connect signing secrets | [Stripe webhooks](https://www.evtivity.com/docs/integrations/stripe#2-webhooks) |
| Adyen | `POST /v1/webhooks/payments/adyen` | Basic auth plus an HMAC signature per event | [Adyen webhook](https://www.evtivity.com/docs/integrations/adyen#5-webhook) |
| Test provider | No HTTP endpoint. The worker delivers its events. | Signature with a key derived from the settings encryption key | [Test provider events](https://www.evtivity.com/docs/integrations/test-payment-provider#events) |

Settings > Payment can create the Stripe and Adyen webhooks for you. All three run through one pipeline: verify the request, record each event ID once, then apply the event. A provider that retries a delivery never applies an event twice. The old Stripe path `/v1/webhooks/stripe` was removed in v0.1.38.

## Payment Statuses

| Status | Description |
|---|---|
| `pending` | Payment created, not yet confirmed |
| `pre_authorized` | Hold placed, awaiting capture |
| `captured` | Payment collected |
| `partially_refunded` | Partial refund issued |
| `refunded` | Full refund issued |
| `failed` | Payment attempt failed |
| `cancelled` | Hold cancelled, for example for a session that cost 0 |

Every status change names the statuses it may start from. A delayed or duplicate event never moves a payment back. For example, a failure event does not change a captured payment. The one exception is Adyen's `CAPTURE_FAILED` for the capture EVtivity waits for, which turns `captured` into `failed`.

## Reconciliation

A daily job at 4 AM compares the payment records of the last 48 hours with the provider each payment was made with. It catches delayed or missed webhooks. Discrepancies are stored with the run and logged for manual review. Run it on demand with `POST /v1/payments/reconciliation/run`. Payments of the test provider are skipped, because it has no payment status lookup. Adyen has none either. For Adyen payments, the job lists captures, cancellations, and refunds that have waited more than 24 hours for their webhook. See [Adyen reconciliation](https://www.evtivity.com/docs/integrations/adyen#reconciliation). A session billing by an operator whose card charge got no answer from the provider for 23 hours is listed as a discrepancy of kind `rebill_pending`. Check the provider for a payment with the idempotency key `rebill_<sessionId>`. See [Sessions](https://www.evtivity.com/docs/csms/sessions#billing-a-session-the-csms-could-not-end).

## Currencies

Payments are charged in the company currency. Choose it under Settings > Company Info from the supported currencies listed on the [Settings page](https://www.evtivity.com/docs/csms/settings). There is no separate provider currency setting.

All amounts are stored in the smallest currency unit (cents).
