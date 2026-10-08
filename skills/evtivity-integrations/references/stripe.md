Generated from https://www.evtivity.com/docs/integrations/stripe. Do not edit.

# Stripe

Set up Stripe step by step. API keys, the two webhook endpoints created from the dashboard or by hand, local testing with the Stripe CLI, Stripe Connect payouts, and site host onboarding.

Stripe is the production card payment provider of EVtivity. This page walks through the setup in order: keys, webhooks, local testing, and Stripe Connect for sites that pay out to their own host. [Payment Providers](https://www.evtivity.com/docs/integrations/payment-providers) explains how the active provider is chosen and how payments flow.

## 1. API Keys

1. In the Stripe Dashboard, open [API keys](https://dashboard.stripe.com/apikeys). Start in a sandbox or test mode.
2. Copy the **Publishable key** (`pk_test_...`).
3. Copy the **Secret key** (`sk_test_...`), or create a restricted key (`rk_test_...`). A restricted key needs write access to PaymentIntents, SetupIntents, Customers, PaymentMethods, Refunds, Ephemeral Keys, and Webhook Endpoints, read access to Balance, Transfers, and Application Fees, and, for Stripe Connect, write access to Accounts and Account Links.
4. In EVtivity, open Settings > Payment > Stripe and enter both keys in **Secret Key** and **Publishable Key**. Click **Save**.
5. Click **Test Connection**. A success message confirms the secret key.
6. Open Settings > Payment > General, select **Stripe** in **Provider for New Payments**, and click **Save**. Saving the keys does not select Stripe.

| Field | Setting | Description |
|---|---|---|
| **Secret Key** | `stripe.secretKeyEnc` | Secret or restricted API key. Stored AES-256-GCM encrypted. |
| **Publishable Key** | `stripe.publishableKey` | Publishable key for the card forms in the portal and dashboard |
| **Webhook Signing Secret** | `stripe.webhookSecretEnc` | Signing secret (`whsec_...`) of the platform webhook endpoint. Stored encrypted. |
| **Connect Webhook Signing Secret** | `stripe.connectWebhookSecretEnc` | Signing secret (`whsec_...`) of the Connect webhook endpoint. Stored encrypted. |

The secret fields show the stored value, hidden until you click the eye icon. Edit a field to replace the value, or empty it to remove the value when you save. The default pre-auth amount and the platform fee are on the General tab (`payments.preAuthAmountCents`, `payments.platformFeePercent`) and apply to every provider. See [Payment Settings](https://www.evtivity.com/docs/integrations/payment-providers#payment-settings).

On Helm, pass the keys as `appSettings.sensitive.stripeSecretKey` and `appSettings.sensitive.stripePublishableKey`. There are no environment variables for Stripe credentials.

When you go live, repeat these steps with the live keys (`sk_live_...`, `pk_live_...`) and create the webhooks again in live mode. Test and live webhook endpoints have different signing secrets.

## 2. Webhooks

Stripe tells EVtivity about failed payments, refunds, disputes, and changes to connected accounts through webhooks. EVtivity needs two webhook endpoints, both sending to the same URL:

```bash
https://<api host>/v1/webhooks/payments/stripe
```

| Endpoint | Listens to | Events | Signing secret |
|---|---|---|---|
| Platform | Your account | `payment_intent.payment_failed`, `charge.refunded`, `charge.dispute.created` | **Webhook Signing Secret** |
| Connect | Connected accounts | `account.updated` | **Connect Webhook Signing Secret** |

Both endpoints use API version `2026-09-30.endive`, the version the EVtivity server pins. Destination charges happen on your platform account, so their payment events come from the platform endpoint. The Connect endpoint carries only the status changes of site host accounts.

The URL must be public HTTPS. Stripe cannot reach `localhost` or a private network. For local tests, see [Local Testing](#3-local-testing).

### Create the Webhooks from EVtivity

1. Save the Stripe keys first.
2. Turn on Stripe Connect for your Stripe account ([Connect](https://dashboard.stripe.com/connect)). Stripe refuses the Connect endpoint without it, and EVtivity then creates neither endpoint. Without Connect, create the platform endpoint by hand instead.
3. In Settings > Payment > Stripe, check the **Webhook Endpoint URL**. It shows the API URL of your deployment followed by `/v1/webhooks/payments/stripe`. Change the host if Stripe must reach the API through another address, such as a tunnel. The path must stay `/v1/webhooks/payments/stripe`, and the URL must start with `https://`.
4. Click **Create webhook**. EVtivity creates both endpoints in Stripe and stores both signing secrets. The signing secret fields on the Stripe tab show them behind the eye icon.
5. The card lists the endpoints with their scope, URL, events, API version, and state.

EVtivity manages only the endpoints at the URL you enter (same host and path). If EVtivity endpoints already exist at that URL, EVtivity asks before it replaces them. Replacing creates two new endpoints with new signing secrets, then deletes the old ones at that URL, so events keep arriving during the change. Several EVtivity deployments, such as a test and a staging deployment, can share one Stripe account: the endpoints of another deployment, at another URL, are listed under **Other EVtivity deployments** and are never changed. If your deployment moves to a new URL, delete its old endpoints in the Stripe Dashboard.

| Answer | Cause | Fix |
|---|---|---|
| 400 `VALIDATION_ERROR` | The URL is not `https`, or its path is not exactly `/v1/webhooks/payments/stripe`, or it has a query | Correct the URL |
| 400 `PAYMENT_PROVIDER_NOT_CONFIGURED` | No Stripe keys stored | Save the keys |
| 400 `PAYMENT_PROVIDER_PERMISSION_MISSING` | The restricted key cannot write Webhook Endpoints | Grant Webhook Endpoints write access |
| 400 `PAYMENT_PROVIDER_CONNECTION_FAILED` | Stripe refused the request, for example a URL it cannot reach or Connect not enabled. The message is Stripe's. | Fix the cause Stripe names |
| 409 `PAYMENT_WEBHOOK_EXISTS` | EVtivity endpoints already exist at this URL | Confirm the replacement |

### Create the Webhooks by Hand

Use this when you prefer to manage endpoints in Stripe yourself.

1. Open the [Webhooks](https://dashboard.stripe.com/webhooks) tab in Stripe Workbench and click **Create an event destination**.
2. Select **Your account**, select API version `2026-09-30.endive`, and select the events `payment_intent.payment_failed`, `charge.refunded`, and `charge.dispute.created`.
3. Click **Continue**, select **Webhook endpoint**, click **Continue**, and enter the URL `https://<api host>/v1/webhooks/payments/stripe`. Create the destination.
4. On the endpoint page, click **Reveal secret** and copy the `whsec_...` value into **Webhook Signing Secret** in Settings > Payment > Stripe.
5. If you use Stripe Connect, repeat steps 1 to 4 with **Connected accounts** instead of **Your account**, the event `account.updated`, and the same URL. Copy its secret into **Connect Webhook Signing Secret**.
6. Click **Save**.

On Helm, set `appSettings.sensitive.stripeWebhookSecret` and `appSettings.sensitive.stripeConnectWebhookSecret` instead.

### How Events Are Handled

| Event | Action |
|---|---|
| `payment_intent.payment_failed` | Marks a pending or pre-authorized payment as failed. A captured, refunded, or cancelled payment is not changed. |
| `charge.refunded` | Updates a captured payment to refunded or partially refunded. A delayed event never lowers the refunded amount. |
| `charge.dispute.created` | Logs a dispute warning for operator review |
| `account.updated` | Reads the connected account from Stripe and updates the payout account status of its site. The event content itself is not trusted. |

Other events are acknowledged and ignored.

EVtivity checks the `Stripe-Signature` header of every request against the platform secret, then the Connect secret. Until a secret and the Stripe keys are set, the endpoint answers 500 `WEBHOOK_NOT_CONFIGURED`, so Stripe retries later. A missing signature answers 400 `WEBHOOK_SIGNATURE_MISSING`, a wrong one 400 `WEBHOOK_SIGNATURE_INVALID`. Each event ID is processed once, and a repeated delivery is acknowledged and skipped. Stripe retries a failed delivery for up to three days in live mode, and a few times over a few hours in a sandbox.

## 3. Local Testing

Stripe cannot send webhooks to `localhost`. The Stripe CLI forwards them instead.

1. [Install the Stripe CLI](https://docs.stripe.com/stripe-cli) and run `stripe login`.
2. With the Docker Compose stack running (API on port 7102), forward both scopes to the local API:

   ```bash
   stripe listen \
     --forward-to http://localhost:7102/v1/webhooks/payments/stripe \
     --forward-connect-to http://localhost:7102/v1/webhooks/payments/stripe
   ```

3. The CLI prints one signing secret (`whsec_...`) for the session. Enter it in both **Webhook Signing Secret** and **Connect Webhook Signing Secret**, then click **Save**.
4. Trigger events in another terminal:

   ```bash
   stripe trigger charge.refunded
   stripe trigger --stripe-account acct_... account.updated
   ```

   The API log shows each event as verified. Triggered payment events do not match EVtivity payments, so they are acknowledged and ignored. Run real test sessions to exercise the payment handlers.

To test the **Create webhook** button locally, expose the API through a public HTTPS tunnel, for example `cloudflared tunnel --url http://localhost:7102`, and enter the tunnel URL plus `/v1/webhooks/payments/stripe` as the webhook URL.

Pay with Stripe test cards, such as `4242 4242 4242 4242` with any future expiry date and any CVC. See [Stripe test cards](https://docs.stripe.com/testing).

## 4. Stripe Connect

Each site can pay out to the Stripe account of its site host, for example a property owner. The site host's account is a connected account (`acct_...`) under your platform account.

| Account | Owner | Role |
|---|---|---|
| Platform account | The operator running EVtivity | Creates every charge with the platform keys. Keeps the platform fee. |
| Connected account | The site host | Receives the payout for sessions at its site |

For a site with a connected account, EVtivity makes a destination charge. The PaymentIntent sets `on_behalf_of` and `transfer_data.destination`, so the site host's name appears on the driver's card statement and Stripe pays the amount minus the platform fee to the site host. A site without a connected account pays into the platform account.

### Enable Connect

1. In the Stripe Dashboard, open [Connect](https://dashboard.stripe.com/connect) and complete the platform onboarding. When Stripe asks for your business model, choose a marketplace: your platform collects the payments and pays out the site hosts.
2. Complete the [platform profile](https://dashboard.stripe.com/settings/connect/platform-profile), including the loss responsibilities. EVtivity creates site host accounts where your platform collects fees and covers losses. Stripe refuses those accounts until you acknowledge the responsibilities, and EVtivity then shows Stripe's message, which names this page.
3. Add your business name, icon, and brand color in the Connect [branding settings](https://dashboard.stripe.com/settings/connect/stripe-dashboard/branding). Stripe-hosted onboarding shows them.
4. Create the webhooks (step 2), so EVtivity receives `account.updated`.
5. Before going live, [activate your Stripe account](https://dashboard.stripe.com/account/onboarding), switch the Dashboard to live mode, and repeat steps 1 to 4 there. Connected accounts created in test mode do not exist in live mode.

### Onboard a Site Host from EVtivity

The site host needs no EVtivity login. You create the Stripe account from the site, then send the site host an EVtivity link that opens Stripe's own onboarding.

1. Give the site a country, and a contact name and email if you want EVtivity to send the link (Sites > the site > Details).
2. In Settings > Payment > Site Configurations, select the site. In the **Payout Account** card, click **Create Stripe account**. The dialog asks for the **Contact email**, which Stripe requires and which is prefilled with the site contact email, and an optional two-letter **Country code** (empty uses the site's country). EVtivity creates an Express account with the site name, the email, and the country, and stores its ID on the site at once.
3. Send the onboarding link:
   - **Email site contact** sends the link to the site's contact email, or
   - **Copy onboarding link** copies it, so you can send it yourself.
4. The site host opens the link. The EVtivity page creates a fresh Stripe onboarding link and redirects to Stripe, where the site host enters business details, identity, and the bank account for payouts.
5. Stripe returns the site host to EVtivity, which shows whether the account is ready, still being verified, or needs more information. **Continue Setup** opens Stripe again.

The EVtivity link is valid for 7 days and can be opened many times. Each visit asks Stripe for a new onboarding link, because a Stripe link expires after a few minutes and works once. Never send a Stripe onboarding link itself. Creating a new EVtivity link revokes the previous one. The link stops working when the account becomes active or the site's account ID changes. While the account is active, the card hides **Copy onboarding link** and **Email site contact**.

### Payout Account Status

The card shows the account's status, its capabilities (`card_payments` and `transfers`), the number of requirements due, and when Stripe was last checked.

| Status | Meaning | Payments at the site |
|---|---|---|
| `onboarding` | The site host has not finished onboarding | Refused |
| `action_required` | Stripe needs more information now or past due | Refused |
| `pending` | Details are submitted and Stripe is verifying them | Refused |
| `active` | `card_payments` and `transfers` are both active | Accepted |
| `disabled` | Stripe rejected or closed the account. The card shows the reason. | Refused |

EVtivity refreshes the status in three ways: the `account.updated` webhook, the **Refresh** button and the site host's return from Stripe, and a daily job at 05:00 that checks every site account.

Until the status is `active`, EVtivity refuses the card hold at the site, so the money of a site host is never paid into the platform account. The session does not start, the driver gets the pre-authorization failed notification, and guest checkout and reservation fees at the site fail the same way. A site whose status is unknown, for example right after you enter an account ID, is checked with Stripe on its first payment. The card warns you when payments are on for a site whose account is not active.

### Enter an Existing Account ID

A site host already onboarded in Stripe, for example through the Stripe Dashboard, keeps working:

1. Copy the `acct_...` ID from the [Connected accounts](https://dashboard.stripe.com/connect/accounts) page.
2. In Settings > Payment > Site Configurations, select the site, enter the ID in **Connected Account ID**, and click **Save**. EVtivity checks the account with Stripe and shows its status in the card.

The account needs the `card_payments` and `transfers` capabilities. In the Stripe Dashboard, open the account and check the **Capabilities** section.

### Platform Fee

The platform fee (`application_fee_amount`) is a percent of the net amount actually charged, tax excluded. Tax is owed to the tax authority, so the platform takes no fee on it. Example: a session charged 11.90 EUR at 19% tax has a net amount of 10.00 EUR, so a 10% platform fee is 1.00 EUR.

The fee is never set on the pre-authorization hold, because the final amount is not known yet. It is set when money is charged:

- **Capture** of the hold at session end, for the amount captured
- **Top-up** when the final cost exceeds the hold, for the extra amount
- **Reservation fees** charged to a saved card

Set the global fee in **Platform Fee %** on the General tab and a per-site fee in **Platform Fee % Override** under Site Configurations. Refunds of destination charges reverse the transfer and refund the application fee proportionally.

### Test Connect

1. Use test mode keys and create the site host account from EVtivity, or enter an account created in test mode.
2. Complete Stripe's test onboarding with [test data](https://docs.stripe.com/connect/testing), for example `000-000` as the SMS code, `110000000` as the routing number, and `000123456789` as the account number.
3. Check that the card shows `active`, then run a small session at the site.
4. In the Stripe Dashboard, confirm that the payment went to the connected account and that the platform fee appears as an application fee.

Stripe references: [Connect webhooks](https://docs.stripe.com/connect/webhooks), [Accounts v2](https://docs.stripe.com/connect/accounts-v2), [Stripe-hosted onboarding](https://docs.stripe.com/connect/hosted-onboarding), [Account capabilities](https://docs.stripe.com/connect/account-capabilities), [Destination charges](https://docs.stripe.com/connect/destination-charges).

## Payment Details

### Pre-Authorization and Top-Ups

The hold is a PaymentIntent with manual capture. For a registered driver it is charged off-session to the saved card. The amount is the site's pre-auth amount when the site has an enabled payment configuration, otherwise the **Default Pre-Auth Amount** of the General tab. At session end, EVtivity captures at most the hold, because Stripe rejects a capture above it. A cost above the hold is charged as a separate off-session top-up on the same card and connected account.

### 3D Secure

Guest checkout has no authentication step yet. A guest card that requires 3D Secure is declined (400 `PAYMENT_FAILED`) and its pending payment is cancelled. The guest can use another card.

### Refunds

Operators refund from the session's payment tab or from a support case. Full and partial refunds are supported, up to the captured amount minus earlier refunds. See [Support Cases](https://www.evtivity.com/docs/csms/support-cases).

### API Version

EVtivity uses the Stripe Node SDK 23, which pins Stripe API version `2026-09-30.endive`. EVtivity creates its webhook endpoints with the same version, so webhook events and API responses have the same shape. If you created an endpoint by hand with another version, set it to `2026-09-30.endive` in Workbench.
