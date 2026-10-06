Generated from https://www.evtivity.com/docs/csms/drivers (website commit 900fb20). Do not edit.

# Drivers

Manage driver accounts, tokens, vehicles, and notification preferences.

## Overview

Drivers are EV owners who charge at your stations. Each driver has an account with authentication tokens, vehicles, payment methods, and notification preferences. Drivers can self-register through the portal or be created by operators in the CSMS.

![Drivers list](https://www.evtivity.com/screenshots/csms/drivers-list.png)

## Create a Driver

1. Navigate to **Drivers** in the sidebar.
2. Click **Create Driver**.
3. Enter the driver's name, email, and phone number.
4. Optionally set the driver's language. The portal, notifications, and invoice PDFs use it.
5. Click **Create**.

![Create driver](https://www.evtivity.com/screenshots/csms/drivers-create.png)

## Driver Detail

Click any driver in the list to open the detail page. The default Details view edits the driver's name, email, phone, and language.

![Driver detail](https://www.evtivity.com/screenshots/csms/driver-detail.png)

### Tokens

View and manage the driver's authentication tokens. Add new RFID cards or app-based tokens. Toggle tokens between active and inactive. See [Tokens](https://www.evtivity.com/docs/csms/tokens) for more details on token types and management.

![Driver tokens](https://www.evtivity.com/screenshots/csms/driver-tokens-tab.png)

### Payment Methods

View the driver's saved payment methods (credit/debit cards stored by the payment provider). Shows the card brand, last four digits, **Provider** (Stripe, Adyen, or Test provider), and the default card. Drivers manage their cards in the portal and the mobile app.

Operators can also add a card for a driver with **Create Payment Method**, set the default with **Set as default**, and delete a card. The card form is the active provider's. When the card issuer asks for 3D Secure with Adyen, the issuer's page opens, and the browser returns to the dashboard's `/payments/return` page, which saves the card and goes back to the driver.

![Driver payment methods](https://www.evtivity.com/screenshots/csms/driver-payment-methods-tab.png)

### Vehicles

View the driver's registered vehicles. Vehicles are used to estimate miles driven based on energy consumed and the vehicle's efficiency rating. The system includes a lookup table of common EV models with their mi/kWh efficiency values.

![Driver vehicles](https://www.evtivity.com/screenshots/csms/driver-vehicles-tab.png)

### Sessions

View all charging sessions for this driver with the same filters available on the main sessions list.

![Driver sessions](https://www.evtivity.com/screenshots/csms/driver-sessions-tab.png)

### Invoices

Monthly invoices for the driver's charging sessions. Click **Generate Invoice** to aggregate the driver's completed, uninvoiced sessions over a date range into one invoice. The invoice has one line per session and tax rate, plus one line for each reservation cancellation or no-show fee charged in the range. Statuses: draft, issued, paid, void. An invoice is created as paid when every session on it was already charged in full to the driver's card or prepaid balance (or cost nothing), and as issued when an amount is still open.

![Driver invoices](https://www.evtivity.com/screenshots/csms/driver-invoices-tab.png)

Click an invoice number to open the detail page, which shows the billed driver, line items linked to their sessions, and totals. From there you can print, download, resend, or void the invoice.

![Invoice detail](https://www.evtivity.com/screenshots/csms/invoice-detail.png)

#### Amounts and tax

Invoice amounts are stated net, with the tax per rate, as EU invoices require:

- **Line items** - description, quantity, net unit price, **Tax Rate**, and **Net Amount**. The note "Unit prices and amounts exclude tax." appears below the table.
- **Totals** - **Subtotal (net)**, **Total Tax**, and the total.
- **Tax Summary** - one row per tax rate with **Tax Rate**, **Net Amount**, **Tax**, and **Gross Amount**.

The total always equals what the driver was charged. Invoices read the net amount and tax each session stored with its final cost, so a later tariff change never alters an invoice. Tax is rounded to the cent per session, as the driver was billed, so the tax of a rate can differ by a cent per session from the rate applied to the summed net amount.

A session billed across tariffs with split billing gets one line per tax rate, so tariffs with different rates are invoiced separately and still add up to the amount charged.

#### Language and PDF

**Download** produces a PDF in the driver's language (English, German, Spanish, Korean, Simplified Chinese, or Traditional Chinese), the language the driver chose in the portal or you set on the driver. Invoices without a driver render in English. Korean and Chinese PDFs use the Noto Sans CJK fonts installed in the API Docker image. Outside Docker (for example `npm run dev:api` on macOS) the fonts are missing, and those invoices render in English.

### Authorize Log

Cross-token forensic view filtered to this driver: every OCPP Authorize attempt the CSMS has seen where the matched driver is this one. Useful for diagnosing why a specific driver's card was rejected (blocked / expired / concurrent_tx / no_credit) regardless of which of their cards was tapped. Same underlying data as the global **/tokens/authorize-log** page.

![Driver authorize log](https://www.evtivity.com/screenshots/csms/driver-authorize-log-tab.png)

### Pricing

Assign a driver-specific pricing group. Driver-level pricing takes the highest priority in the tariff resolution chain, applying at all stations regardless of station or site pricing. See [Pricing](https://www.evtivity.com/docs/csms/pricing) for the full priority system.

![Driver pricing](https://www.evtivity.com/screenshots/csms/driver-pricing-tab.png)

### Driver Portal Access

Drivers you create in the CSMS have no portal password. The **Driver Portal Access** card on the Details view shows whether the driver can sign in to the portal:

- **Active**: the driver has a password and signs in like any self-registered driver. They reset it from the portal sign-in page.
- **Invited**: an invitation is open. The card shows when it expires.
- **Not invited**: the driver cannot sign in to the portal.

To give the driver portal access on their existing account:

1. Open the driver and confirm the email address is correct.
2. Click **Invite to Driver Portal**, then **Send Invite**.
3. The driver receives an email with a link to set a password. The link works once and expires after 7 days.

The driver keeps their sessions, tokens, payment methods, and invoices. If the link expires or the email is lost, click **Resend Invite**. Each new invitation replaces the earlier link. The button is disabled for an inactive driver or one without an email address, and needs the `drivers:write` permission.

A driver without a password cannot register a new account with the same email, sign in, or request a password reset. Only an invitation from the operator sets the first password, so knowing a driver's email is not enough to take over the account. Edit the email text on the **Notifications** page under the **Driver Portal Invite** event.

![Driver portal access](https://www.evtivity.com/screenshots/csms/driver-portal-access.png)

## Deactivating or Deleting a Driver

Deactivating a driver (toggling **Active** off on the Details tab) blocks the account from new charging activity but preserves all historical sessions, tokens, and audit rows. Deleting a driver from the list performs a soft delete with the same effect: the row is marked inactive rather than removed.

Both actions cascade to the driver's tokens. Every RFID card or app token the driver owns is also deactivated, because OCPP Authorize handlers gate on the token's active flag, not the driver's. Without the cascade a deactivated driver could still charge by tapping a previously-issued card.

Reactivating the driver does **not** auto-reactivate the tokens. Tokens may have been deliberately revoked (stolen card, lost fob) before the driver was deactivated, and reactivating them blindly would override that intent. Reactivate individual tokens from the [Tokens](https://www.evtivity.com/docs/csms/tokens) page after reactivating the driver.

## Email Uniqueness

Driver emails are case-insensitive and globally unique. `Alice@example.com` and `alice@example.com` are the same address, and only one driver row can hold either form. The CSMS normalizes email to lowercase on create and update. A duplicate returns `409 DUPLICATE_EMAIL`.

## Timezone

The timezone field accepts any IANA timezone name (`America/New_York`, `Europe/Berlin`, `Asia/Tokyo`). Unknown values are rejected with `400 VALIDATION_ERROR`.
