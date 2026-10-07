Generated from https://www.evtivity.com/docs/integrations/test-payment-provider (website commit ffa3c26). Do not edit.

# Test Payment Provider

The simulated payment provider for development, demos, and automated tests. How to enable it with PAYMENTS_ALLOW_SIMULATED, its test cards, sync and async modes, and how its events reach the webhook pipeline.

The test (simulated) provider is for development, demos, and automated tests. It makes no network calls and moves no money. It runs through the same payment flows as Stripe: holds, captures with top-ups, cancels, refunds, reservation fees, and retries.

## Enabling It

The `PAYMENTS_ALLOW_SIMULATED` environment variable of the API, OCPP server, and worker decides whether the test provider exists. It is an environment variable, not a dashboard setting, so an operator cannot turn on a payment path that moves no money.

| Deployment | Setting | Default |
|---|---|---|
| Node process | `PAYMENTS_ALLOW_SIMULATED` | `true` when `NODE_ENV` is `development`, `test`, or unset, otherwise `false` |
| Docker Compose | `PAYMENTS_ALLOW_SIMULATED` | `true` |
| Helm | `payments.allowSimulatedProvider` | `false` |
| CDK | `payments.allowSimulatedProvider` | `false`. Refused in the `prod` environment. |

Set the same value on all three services. Demo data requires it, because demo drivers have test cards. Helm and CDK refuse to deploy demo data without it. Never enable it in production.

To make it the active provider, select **Test provider** in Settings > Payment > General > **Provider for New Payments**, or set `payments.provider` to `simulated`: on Helm `appSettings.payments.provider`, on CDK `appSettings['payments.provider']`. When the test provider is off, Helm and CDK refuse the `simulated` value, and cards or payments made with the test provider are treated as not configured.

## Test Cards

The test provider accepts only these card numbers. The outcome is fixed per card, so a test gives the same result every time and in every process.

| Card number | Outcome |
|---|---|
| `4242424242424242` | Approved (Visa) |
| `4111111111111111` | Approved (Visa) |
| `5555555555554444` | Approved (Mastercard) |
| `4000000000000002` | Declined at authorization: card declined |
| `4000000000009995` | Declined at authorization: insufficient funds |
| `4000000000000341` | Saves, then every charge is declined |
| `4000002500003155` | Requires authentication: a challenge when the driver is present, declined off-session |
| `4917610000000000` | Requires authentication (3DS2), same as above |
| `4000000000000606` | Authorizes 50% of the amount |
| `4000000000000408` | Capture fails |
| `4000000000000309` | Hold adjustment declined |
| `4000000000000507` | Refund fails |
| `4000000000000259` | Disputed 30 seconds after capture |

Any other number is refused. Cards seeded by the demo data have no fixed outcome. They fail at random at the **Random Failure Rate** (default 0.2, so 20% of the time) to exercise error handling.

## Test Card Forms

Where the test provider is active, the card forms show a test card list instead of card fields:

- **Portal**, Payment Methods and guest checkout: the notice "Test mode, no real money. Pick a test card." and a **Test card** select with each card's outcome, for example "Approves" or "Declined: insufficient funds".
- **Dashboard**, a driver's payment methods: the same select, for an operator who adds a card for a driver.
- **Mobile app**: a **Test mode** badge and a **Choose a test card** list.

A card that requires authentication opens a challenge, as a bank would with 3-D Secure: **Approve** saves the card, and **Fail** (in the app **Fail authentication**) refuses it, so the card is not saved.

## Settings

Settings > Payment > General shows a **Test Provider** card where the test provider is enabled:

| Field | Setting | Default | Description |
|---|---|---|---|
| **Result Mode** | `simulated.resultMode` | `sync` | **Synchronous** or **Asynchronous**, see below |
| **Async Result Delay (seconds)** | `simulated.asyncDelaySeconds` | `3` | Delay of asynchronous results, 0 to 3600 |
| **Random Failure Rate** | `simulated.randomFailureRate` | `0.2` | Share of payments that fail for cards without a test scenario, 0 to 1 |

On Helm, set `appSettings.simulated.*`. On CDK, set `appSettings['simulated.*']`. Leave a value empty to keep the one set in the dashboard. Both refuse values outside these ranges.

## Events

The test provider signs its events like a real provider and sends them through the same webhook pipeline as Stripe and Adyen, without an HTTP route:

1. The API or OCPP server publishes the signed event on the internal `payment_webhook_deliveries` channel.
2. The worker queues it with the provider's delay, for example 30 seconds for the dispute of card `4000000000000259`.
3. When the delay ends, the worker verifies the signature, records the event once, and applies it, as it would a Stripe or Adyen webhook.

So the worker must run for test provider events to arrive. A repeated event is recorded once. An event with a bad signature is logged as an error and not retried.

## Sync and Async Modes

The test provider has two modes:

- **Sync** (default): captures, cancels, and refunds return their result at once, and a cost above the hold is a top-up charge, as with Stripe.
- **Async**: captures, cancels, refunds, and hold adjustments return pending and confirm later through a signed event, and a cost above the hold raises the hold, as with Adyen.

Both modes are allowed in every deployment where the test provider is enabled. Use the async mode to rehearse Adyen behavior without an Adyen account: payments show the same awaiting confirmation states, and the worker must run to confirm them.

See [Payment Providers](https://www.evtivity.com/docs/integrations/payment-providers) for how the active provider is chosen.
