Generated from https://www.evtivity.com/docs/integrations/adyen (website commit 257c8b8). Do not edit.

# Adyen

Set up and use Adyen step by step. Merchant account, API credential roles, client key and allowed origins, the Adyen settings, the webhook, Adyen Support enablements, local testing, selecting Adyen after the upgrade, 3D Secure, guest checkout, captures and refunds confirmed by webhook, the mobile app, and the Content Security Policy.

> **Warning:**
>
> Adyen payments need v0.1.38 or later on every API, OCPP, and worker process. Set up Adyen first, then select it in the dashboard after the upgrade is complete. See [Select Adyen](#9-select-adyen). After you select Adyen, do not roll back below v0.1.38.

EVtivity talks to the Adyen Checkout API v72 for payments and the Adyen Management API v3 for webhook setup. Platform fees and per-site payouts need Adyen for Platforms, which EVtivity does not support yet, so a site with a payout account cannot take Adyen payments. Cards are the only payment method. The company currency IDR is not supported with Adyen.

## 1. Merchant Account

1. Sign up for an [Adyen test account](https://www.adyen.com/signup). You get a Customer Area with a company account and a merchant account.
2. Note the merchant account code from the account switcher at the top of the Customer Area, for example `YourCompanyECOM`. EVtivity sends it with every request.

## 2. API Credential

1. In the Customer Area, open **Developers** > **API credentials** and select the `ws@Company.<YourCompany>` credential, or create one.
2. Under **Server settings** > **Roles**, make sure the credential has these roles:

   | Role | Used for |
   |---|---|
   | Checkout webservice role | Payments, captures, cancels, refunds, and hold adjustments |
   | Merchant Recurring role | Saved cards (tokenization) |
   | Management API - Webhooks read and write | Creating the webhook from EVtivity, and the webhook test |

3. Under **Server settings** > **Authentication**, generate an **API key** and copy it. Adyen shows it only once.
4. Click **Save changes**.

The webhook role is optional when you create the webhook by hand. Without it, **Create webhook** answers 400 `PAYMENT_PROVIDER_PERMISSION_MISSING`.

## 3. Client Key and Allowed Origins

The client key lets the card forms in the browser talk to Adyen. It is not a secret.

1. On the same credential, under **Client settings** > **Authentication**, select the **Client key** tab and click **Generate client key**. Copy it.
2. Under **Allowed origins**, add the origin of each page that shows a card form, and click **Add** after each:
   - the driver portal, for example `https://portal.example.com`
   - the operator dashboard, for example `https://csms.example.com`
   - local development origins, if you test locally, for example `http://localhost:7101`
3. Click **Save changes**. Changes take a few seconds to apply.

An origin is a scheme, host, and port, with no path. A missing origin makes the card form fail to load.

## 4. Adyen Settings in EVtivity

Open Settings > Payment > Adyen and fill in the fields:

| Field | Setting | Description |
|---|---|---|
| **Merchant Account** | `adyen.merchantAccount` | Merchant account code from step 1 |
| **Environment** | `adyen.environment` | `test` (default) or `live` |
| **Live URL Prefix** | `adyen.liveUrlPrefix` | Shown when live. Customer Area > **Developers** > **API URLs** > **Prefix**, for example `1797a841fbb37ca7-AdyenDemo`. |
| **Live Region** | `adyen.liveRegion` | Shown when live. `eu` (default), `us`, `au`, `nea`, or `in`, the region of your live account |
| **Client Key** | `adyen.clientKey` | Client key from step 3 |
| **API Key** | `adyen.apiKeyEnc` | API key from step 2. Stored encrypted. The field shows the stored key behind the eye icon. |
| **HMAC Key** | `adyen.hmacKeyEnc` | Hex HMAC key of the webhook. Stored encrypted. Filled in for you by **Create webhook**. |
| **Webhook Username** | `adyen.webhookUsername` | Basic auth username of the webhook. Filled in for you by **Create webhook**. |
| **Webhook Password** | `adyen.webhookPasswordEnc` | Basic auth password of the webhook. Stored encrypted. Filled in for you by **Create webhook**. |
| **Authorization Adjustment** | `adyen.authorisationAdjustment` | Off by default. Raises the hold to the final cost instead of charging a second payment. Turn it on only after Adyen enables authorisation adjustment for your merchant category. See [Costs Above the Hold](#costs-above-the-hold). |

The secret fields show the stored value, hidden until you click the eye icon. Edit a field to replace the value, or empty it to remove the value when you save. Click **Save**, then **Test connection**. The test calls Adyen Checkout with your API key and lists the roles of the credential. A warning appears when the webhook role is missing.

Set the company country too. Adyen's card form does not start without a country, so open **Settings > Company Info** and enter **Country** as a two-letter ISO code (`company.country`), for example `NL` or `US`. Without it, adding a card in the portal shows "Card setup failed" and guest checkout shows "Payment is not configured for this charger".

On Helm, set the plain values under `appSettings.adyen.*` and the secrets under `appSettings.sensitive.adyenApiKey`, `adyenHmacKey`, `adyenHmacKeyPrevious`, and `adyenWebhookPassword`. On AWS (CDK), enter the secrets in the dashboard. See [Helm Chart](https://www.evtivity.com/docs/deployment/helm-chart) and [AWS](https://www.evtivity.com/docs/deployment/aws).

## 5. Webhook

Adyen confirms captures, refunds, cancellations, chargebacks, and expired holds through a webhook. Without a working webhook, captures and refunds stay unconfirmed. The URL is:

```bash
https://<api host>/v1/webhooks/payments/adyen
```

The URL must be public HTTPS with a host name that resolves on the internet. Adyen checks the URL when the webhook is saved and refuses `localhost`, private addresses, and names it cannot resolve. For local tests, see [Local Testing](#7-local-testing).

### Create the Webhook from EVtivity

1. Save the API key and merchant account, and make sure the credential has the webhook role (**Test connection** shows it).
2. In Settings > Payment > Adyen, check the **Webhook URL**. It shows the API URL of your deployment followed by `/v1/webhooks/payments/adyen`. Change the host if Adyen must reach the API through another address, such as a tunnel. The path must stay `/v1/webhooks/payments/adyen`, and the URL must start with `https://`.
3. Click **Create webhook**. EVtivity:
   1. creates a standard webhook on the merchant account, switched off, with JSON format, TLS 1.3, a new Basic auth username and password, and the 13 event codes below
   2. asks Adyen for a new HMAC key
   3. stores the username, password, and HMAC key
   4. switches the webhook on and deletes any duplicate webhook at the same URL
   5. asks Adyen to send a test `AUTHORISATION` event and shows the result
4. A successful test shows `success` with response code `200`. A failed test shows the code EVtivity's API answered, or that Adyen could not connect.

The webhook is switched on only after the credentials are stored, so no event arrives that EVtivity cannot verify.

EVtivity manages only the webhook at the URL you enter (same host and path). If a webhook already exists at that URL, EVtivity asks before it replaces it. Replacing updates the same webhook in place, and leaves it switched on, with a new username, password, and HMAC key. The previous HMAC key stays accepted (`adyen.hmacKeyPreviousEnc`), so events Adyen signed before the change still verify. An event that arrives during the change and fails the credential check is retried by Adyen. Several EVtivity deployments can share one merchant account: the EVtivity webhooks of another deployment, at another URL, are listed under **Other EVtivity deployments** and are never changed. If your deployment moves to a new URL, delete its old webhook in the Customer Area.

| Answer | Cause | Fix |
|---|---|---|
| 400 `VALIDATION_ERROR` | The URL is not `https`, its path is not exactly `/v1/webhooks/payments/adyen`, or it has a query | Correct the URL |
| 400 `PAYMENT_PROVIDER_NOT_CONFIGURED` | API key, merchant account, or client key missing | Save the settings |
| 400 `PAYMENT_PROVIDER_PERMISSION_MISSING` | The credential lacks Management API - Webhooks read and write | Add the role (step 2) |
| 400 `PAYMENT_PROVIDER_CONNECTION_FAILED` | Adyen refused the request, for example a URL it cannot resolve. The message is Adyen's. | Fix the cause Adyen names |
| 409 `PAYMENT_WEBHOOK_EXISTS` | A webhook already exists at this URL | Confirm the replacement |

### Create the Webhook by Hand

1. In the Customer Area, open **Developers** > **Webhooks**, click **Create new webhook**, choose **Standard webhook**, and click **Add**.
2. Under **General**, enter a description and select your merchant account.
3. Under **Server configuration**, enter the URL `https://<api host>/v1/webhooks/payments/adyen`, choose method **JSON**, and encryption protocol **TLSv1.3** (or **TLSv1.2**).
4. Under **Security**, enter a **Basic authentication** username and a long random password. Generate an **HMAC key** and copy it.
5. Under **Events**, select exactly these event codes:

   | Event code | Event code | Event code |
   |---|---|---|
   | `AUTHORISATION` | `AUTHORISATION_ADJUSTMENT` | `CAPTURE` |
   | `CAPTURE_FAILED` | `CANCELLATION` | `TECHNICAL_CANCEL` |
   | `REFUND` | `REFUND_FAILED` | `CHARGEBACK` |
   | `EXPIRE` | `RECURRING_CONTRACT` | `REFUNDED_REVERSED` |
   | `NOTIFICATION_OF_CHARGEBACK` | | |

   A new standard webhook leaves out `EXPIRE` by default, so check it.
6. In EVtivity, enter the username in **Webhook Username**, the password in **Webhook Password**, and the HMAC key in **HMAC Key**. Click **Save**.
7. Back in the Customer Area, switch **Enabled** on and click **Save configuration**. Then use **Test configuration** to send a test event.

### How Requests Are Checked

Every request must carry the Basic auth username and password, and every event in it a valid HMAC signature. The endpoint answers:

| Answer | When |
|---|---|
| 200 `[accepted]` | Every event verified. Each event is processed once, and a repeated delivery is acknowledged and skipped. |
| 401 `WEBHOOK_SIGNATURE_MISSING` or `WEBHOOK_SIGNATURE_INVALID` | Basic auth credentials missing or wrong |
| 400 `WEBHOOK_SIGNATURE_INVALID` | An event has a wrong HMAC signature, or the merchant account or live flag does not match |
| 500 `WEBHOOK_NOT_CONFIGURED` | No HMAC key, username, or password stored. Adyen retries later. |

Adyen retries failed deliveries for up to 30 days. Adyen publishes no IP ranges and advises against IP allowlists, so do not restrict the endpoint by address. On AWS (CDK), the WAF exempts exactly this path from the country rule and gives it its own rate limit.

[What Each Event Does](#what-each-event-does) lists the payment changes the events trigger.

## 6. Adyen Support Enablements

Ask Adyen Support to enable these on your merchant account before going live:

- Manual capture
- Pre-authorisation for your merchant category code (EV charging)
- Authorisation adjustment (raising a pre-authorised amount) for your merchant category code, if you turn on **Authorization Adjustment**. The test account allows it. A live account needs Adyen to enable it for its merchant category code. EVtivity waits for the `AUTHORISATION_ADJUSTMENT` webhook, so synchronous adjustment is not required.
- 3D Secure 2
- The stored payment method ID (`tokenization.storedPaymentMethodId`) in the payment response
- Card-on-file payments started by the merchant without the CVC (`ContAuth` with `UnscheduledCardOnFile`). EVtivity charges saved cards this way. See [Charging with a Saved Card](#charging-with-a-saved-card).

Optional, in the Customer Area:

- **Developers** > **Additional data** > **Card summary** returns the last four digits with each payment, which saves a lookup when a driver saves a card.

## 7. Local Testing

Adyen cannot reach `localhost`. Expose the local API through a public HTTPS tunnel, for example with [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/trycloudflare/):

1. With the Docker Compose stack running (API on port 7102), start a quick tunnel:

   ```bash
   cloudflared tunnel --url http://localhost:7102
   ```

2. Copy the `https://<random>.trycloudflare.com` address it prints.
3. In Settings > Payment > Adyen, set the **Webhook URL** to `https://<random>.trycloudflare.com/v1/webhooks/payments/adyen` and click **Create webhook**. The test event result appears in the card.

A quick tunnel gets a new address each time it starts. Click **Create webhook** again after each restart. EVtivity creates a webhook for the new address and leaves the old one, which then appears under **Other EVtivity deployments**. Delete it in the Customer Area. Use a named Cloudflare tunnel for a stable address.

## 8. Going Live

1. Repeat steps 1 to 3 in your live Customer Area: a live merchant account, an API credential with the same roles, and a client key with the live origins.
2. In Settings > Payment > Adyen, set **Environment** to `live`, and enter the **Live URL Prefix** and **Live Region**.
3. Enter the live API key and client key, click **Save** and **Test connection**.
4. Click **Create webhook** to create the live webhook. Live and test webhooks are separate.
5. Leave **Authorization Adjustment** off unless Adyen has enabled authorisation adjustment for your live merchant category code.

## 9. Select Adyen

Select Adyen in Settings > Payment after the upgrade to v0.1.38 is complete. Helm and CDK refuse `payments.provider: adyen`, so the dashboard is the only place to select it.

1. Finish steps 1 to 5: the settings are saved, **Test connection** succeeds, the webhook test shows `success`, and **Settings > Company Info > Country** holds a two-letter code.
2. Make sure no process older than v0.1.38 still runs: API, OCPP, OCPI, worker, and any job that connects to the database.
3. In Settings > Payment > General, choose **Adyen** in **Provider for New Payments** and click **Save**.

### The Upgrade Guard

A process older than v0.1.38 cannot handle Adyen. It treats Adyen as "payments off", so guests would charge for free, and it would send Adyen holds to Stripe. EVtivity therefore refuses to select Adyen while such a process may still run. Selecting Stripe, the test provider, or `none` is never refused.

EVtivity names every database connection with its release version. Older releases do not, so their connections are recognizable. The worker checks the open connections every minute and remembers when it last saw an old one. Selecting Adyen succeeds only when all of these hold:

- No old connection is open at that moment.
- The worker checked within the last 3 minutes. A worker that is stopped, or still on an old release, blocks the switch.
- The worker has seen no old connection in the last 10 minutes.

Otherwise the request answers 409 `PAYMENT_PROVIDER_UPGRADE_PENDING`. Until the conditions hold, the select lists "Adyen (upgrade in progress)" and the **Providers** list shows the badge **Upgrade pending**. The General tab keeps the previous provider and shows a panel, "Adyen cannot be selected until the upgrade finishes", with:

- the number of old connections and the addresses they come from
- when an old process was last seen
- when the worker last checked

During a rolling upgrade, wait until the old pods are gone, then wait 10 more minutes and select Adyen again. Payments continue with the previous provider in the meantime.

A tool of your own that connects with the application's database user through the Node.js `postgres` library also counts as an old process, because its connections carry no name. Stop it, or connect it with another database user. The guard has no bypass.

### Rollback

After you select Adyen, do not roll back below v0.1.38. An older release cannot capture or cancel Adyen holds. To roll back, first select another provider, then wait until every open Adyen hold is captured or cancelled and no refund is pending.

## 10. Payments with Adyen

The card forms in the driver portal and the operator dashboard are Adyen's card fields. Card data goes from the browser to Adyen, never through EVtivity.

### Saved Cards and 3D Secure

When a driver adds a card in the portal, or an operator adds one for a driver in the dashboard, EVtivity asks Adyen to store it with a zero-amount check. The card issuer can ask for 3D Secure:

1. The browser opens the issuer's page.
2. The cardholder confirms the card there.
3. The browser comes back to `/payments/return` on the portal (`https://<portal host>/payments/return`) or the dashboard (`https://<csms host>/payments/return`). The page finishes the verification and goes back to the payment methods (in the dashboard, to the driver) with the message "Card saved.". For guest checkout, the portal page (`?flow=guest`) places the hold, starts the session, and opens the session page.

A refused card shows the reason Adyen gives ("The card was refused (...). Try a different card."), and nothing is saved. A failed verification shows "Authentication failed. The card was not saved." Both return pages must be reachable at the same host as the card form, and both hosts must be in the client key's allowed origins. EVtivity stores only Adyen's card token, the brand, and the last four digits.

### Charging with a Saved Card

A charging session on a saved card starts without the CVC and without 3D Secure. EVtivity places the hold as a payment the merchant starts on a stored card, as it does with Stripe. The Adyen test account accepts these payments. If your live account refuses them, ask Adyen Support to allow them (see [Adyen Support Enablements](#6-adyen-support-enablements)).

### Guest Checkout

A guest enters a card on the station page. When the issuer asks for 3D Secure, the guest confirms the payment on the issuer's page and comes back to the portal, where the session starts. A refused card answers `PAYMENT_FAILED`, and the session does not start.

If the guest confirms at the issuer but never comes back, Adyen still reports the hold. EVtivity attaches it to the guest session while that session still waits for payment. Otherwise EVtivity cancels the hold, so no money stays held on the card without a session.

### Captures and Cancellations

Adyen confirms a capture or a cancellation later, through the webhook. EVtivity does not wait:

- When a session ends, the payment shows `captured` at once. The session's Payment tab marks it **Capture awaiting confirmation** under **Provider confirmation** until the `CAPTURE` event arrives, usually within minutes. A cancellation shows **Cancellation awaiting confirmation** the same way.
- When Adyen reports `CAPTURE_FAILED` for that capture, the payment becomes `failed`, and the driver gets the capture failed notification. A later `CAPTURE` event does not undo the failure.
- A cancelled hold shows `cancelled` at once. If Adyen cannot cancel it, EVtivity logs the error, and the hold expires at the issuer.
- When an open hold expires at Adyen (`EXPIRE`), the payment becomes `cancelled` with the reason `Adyen authorisation expired`. The driver gets no notification.

### Refunds

A refund starts as pending. The dashboard shows "Refund requested. The payment provider confirms it shortly." The refund counts toward the refunded amount only when Adyen confirms it with a `REFUND` event. The session's Payment tab lists every refund under **Refunds** with its state: **Pending confirmation**, **Succeeded**, or **Failed**. A `REFUND_FAILED` event marks the refund failed, and the amount stays charged. A refund you start in the Adyen Customer Area appears when its `REFUND` event arrives.

While a capture awaits confirmation, the Payment tab says "Refunds are possible once the provider confirms the capture.", and a refund through the API answers 409 `PAYMENT_OPERATION_PENDING`. Try again after the capture is confirmed. This keeps EVtivity from recording a refund of money that was never taken.

### Costs Above the Hold

When a registered driver's session costs more than the hold, the **Authorization Adjustment** setting decides what happens:

- **Off** (default): EVtivity captures the hold and charges the difference as a second payment on the same saved card (a top-up), as with Stripe.
- **On**: EVtivity asks Adyen to raise the hold to the final cost. The Payment tab shows **Hold increase awaiting confirmation** until the `AUTHORISATION_ADJUSTMENT` event arrives. On success, EVtivity captures the final cost in one payment, and the driver gets the payment received notification. If Adyen refuses the adjustment, or the request fails, EVtivity captures the hold and charges the difference as a top-up, as with the switch off.

Turn it on only after Adyen enables authorisation adjustment for your merchant category code (see [Adyen Support Enablements](#6-adyen-support-enablements)). It was verified on the Adyen test account. A live account without the enablement refuses the adjustment, and every such session falls back to a top-up. A guest has no saved card, so a guest session is never adjusted and a cost above the hold is not collected.

### What Each Event Does

| Event code | Effect |
|---|---|
| `AUTHORISATION` | Attaches a guest hold confirmed after 3D Secure, or cancels a hold that belongs to no session |
| `CAPTURE` | Confirms the capture |
| `CAPTURE_FAILED` | Marks the payment `failed` and notifies the driver |
| `AUTHORISATION_ADJUSTMENT` | Success: captures the final cost on the raised hold. Failure: captures the hold and charges a top-up. |
| `CANCELLATION`, `TECHNICAL_CANCEL` | Confirms the cancellation EVtivity asked for. For an open hold that Adyen ended on its own, or that was cancelled in the Customer Area, cancels the payment with the reason `Adyen cancelled the authorisation`. |
| `EXPIRE` | Cancels an open hold that expired |
| `REFUND` | Confirms a refund and raises the refunded amount |
| `REFUND_FAILED` | Marks the refund failed |
| `CHARGEBACK`, `NOTIFICATION_OF_CHARGEBACK` | Records the dispute and shows it to operators |

An event that does not match the operation EVtivity waits for, or that arrives out of order, changes nothing. Each event applies once.

### Reconciliation

Adyen has no payment status lookup, so the daily reconciliation does not ask Adyen. It lists a capture, cancellation, or refund that has waited more than 24 hours for its event as a discrepancy of kind `pending_confirmation`. Check the webhook's event log in the Customer Area under **Developers** > **Webhooks**. A missing or failing webhook is the usual cause.

### Mobile App

The mobile app adds cards through Adyen's React Native module (`@adyen/react-native`). The module needs a native build of the app. It does not run in Expo Go.

When the issuer asks for 3D Secure, the app opens the issuer's page and the cardholder returns to the app afterwards. The return URL leads back to the app, so the API accepts it only for your app builds:

| Platform | Return URL | Setting |
|---|---|---|
| iOS | `<brand scheme>://payments/adyen` | `mobile.app.urlSchemes`, the `scheme` of each app brand. Default `["evtivity"]`. |
| Android | `adyencheckout://<application id>`, set by Adyen's Android SDK | `mobile.app.androidPackageNames`, the `androidPackage` of each app brand. Default `["com.evtivity.driver"]`. |

Both settings are JSON lists, so one CSMS can serve several app brands. They have no dashboard field: set them on Helm (`appSettings.mobile.app.*`), on CDK (`appSettings['mobile.app.*']`), or with `PUT /v1/settings/:key`. A return URL that matches no listed build answers 400 `VALIDATION_ERROR` before Adyen is called. See [Mobile App White-labeling](https://www.evtivity.com/docs/mobile-app/white-labeling).

App builds that cannot add an Adyen card show a message instead of the card form:

- A build without the Adyen payment module: "Update the app to add a card with this payment provider."
- A build with the module but without the native SDK, such as Expo Go: "This app build cannot add a card with this payment provider. Install the latest version of the app."

Charging with a card saved earlier works in every build, because the server places the hold.

## 11. Content Security Policy

The portal and dashboard pages carry a Content Security Policy that allows Adyen's card fields and the 3D Secure pages of card issuers:

| Directive | Allows |
|---|---|
| `script-src`, `img-src` | `https://*.adyen.com` |
| `connect-src` | `https:`, which covers Adyen's API |
| `frame-src` | `https:`, for the 3D Secure pages of issuers |
| `form-action` | `https:`, because 3D Secure sends a form to the issuer's page |

If you serve the portal or the dashboard behind your own proxy and add a `Content-Security-Policy` header, the browser enforces both policies. Add the same sources to your header, or the card form or 3D Secure fails to load.

Adyen references: [API credentials](https://docs.adyen.com/development-resources/api-credentials), [Client key](https://docs.adyen.com/development-resources/client-side-authentication), [Webhooks](https://docs.adyen.com/development-resources/webhooks/configure-and-manage), [Secure webhooks](https://docs.adyen.com/development-resources/webhooks/secure-webhooks), [Live endpoints](https://docs.adyen.com/development-resources/live-endpoints).
