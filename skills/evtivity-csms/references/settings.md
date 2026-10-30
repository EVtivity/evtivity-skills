Generated from https://www.evtivity.com/docs/csms/settings. Do not edit.

# Settings

Configure company info, marketing, content, notifications, sustainability, payments, integrations, security, API keys, firmware, station configurations, smart charging, AI, and data retention.

## Overview

The Settings page contains all system-wide configuration organized into tabs. Each tab requires a specific permission to view and edit. The Settings nav item is hidden when a user has no settings permissions.

![Settings page](https://www.evtivity.com/screenshots/csms/settings.png)

## System Information

**Permission:** `settings.system:read` and access to every site.

The **System Information** button at the top of the Settings page opens a read-only dialog with the settings the CSMS processes run with. Type in **Search settings** to find a setting by name or value, or pick a section in **Section** to show one section. **All Sections** shows every section again.

- **Runtime** - version, `NODE_ENV`, `LOG_LEVEL`, and `SEED_DEMO`.
- **Network** - `BIND_IP`, the API host and port, the metrics port, the CSMS and portal URLs, `OCPP_STATION_TLS_URL` (the public `wss://` address stations use for security profiles 2 and 3), the cookie domain, and the CORS origin. `BIND_IP` is the address the Docker Compose ports bind to, such as `192.168.1.234`. The row appears on Docker Compose installs only and is hidden on Helm and AWS installs, which have no bind address.
- **Rate Limits** - the API and sign-in rate limits.
- **Security** - whether `TRUST_PROXY` lists the proxies in front of the API, the passkey relying party ID (`WEBAUTHN_RP_ID`), and whether the API counts its rate limits in Redis, shared by every API replica (**Shared Rate Limits**).
- **OCPP Processes** - the station registration policy, then one group per OCPP process that reported in the last 90 seconds: its connected stations, its start time, and the settings it runs with (version, WebSocket compression, the TLS listener and port, whether a client certificate CA is set, the per-IP connection, message and pending sign-in limits, and whether trusted proxies are set). Each OCPP process reports its own values, so a Helm or AWS install with several OCPP processes lists each of them.
- **OCPI** - base URL, country code, party ID, and business name.
- **Simulator** - `CSS_MODE`, the action interval, the station limit, and the number of simulator stations.
- **Payments** - the selected payment provider and whether it is ready.
- **SIM Providers** - whether Hologram and 1NCE are on and configured, the days of SIM sessions fetched, and the low signal monitor switch.
- **Station Data Plans** - the number of stations on the Wi-Fi or wired and on the cellular data plan, and the number of sites set to each plan.
- **Integrations** - whether each secret and integration is configured: `JWT_SECRET`, `SETTINGS_ENCRYPTION_KEY`, Stripe, Adyen, SMTP, Twilio, S3, reCAPTCHA, Hubject, Google Maps, the webhook signing secret, the Hologram API key, and the 1NCE client secret.

![System Information dialog](https://www.evtivity.com/screenshots/csms/settings-system-information.png)

The dialog never shows secret values. **Configured** only means that a value is set.

The API also offers a response cache flush (`POST /v1/cache/flush`), which empties the response cache that every site shares. It needs `settings.system:write` and access to every site.

## Company Info

**Permission:** `settings.system:read` / `settings.system:write`

Company branding, contact information, and SEO configuration.

**Branding:**

- **Logo** - upload a logo image (max 512 KB). Displayed in emails and portal branding.
- **QR Code Icon** - upload an SVG icon that appears in the center of station QR codes. Includes a live QR preview.
- **Favicon** - upload a custom favicon image for the portal (max 512 KB).
- **Social Share Image** - upload an Open Graph image for social media link previews (max 512 KB).

Uploading a new image replaces the current one.

**SEO and Social:**

- **Meta Description** - description tag for the portal's HTML head.
- **Meta Keywords** - keywords tag for the portal's HTML head.

**Theme:**

- **Theme Color** - hex color picker that sets the portal's primary brand color. Default `#2563eb`.

**Company Details:**

- **Company Name** - used in emails, portal header, and receipts.
- **Currency** - the one currency for all tariffs, card payments, and invoices. Changing it does not relabel past sessions, payments, or invoices. Supports 31 currencies (USD, EUR, GBP, CAD, AUD, CHF, CNY, INR, BRL, MXN, SEK, NOK, DKK, NZD, SGD, HKD, ZAR, ILS, AED, SAR, TWD, THB, PLN, CZK, HUF, TRY, COP, ARS, PHP, MYR, IDR).
- **Prices in the driver portal** - **Including tax (gross)** or **Excluding tax (net)** (`company.priceDisplay`, default net). See Price display below.
- **Tariff prices are entered** - **Excluding tax (net)** or **Including tax (gross)** (`company.taxBasis`, default net). See Tax calculation method below.
- **Contact Email** - general contact email for the company.
- **Support Email** - displayed in support communications.
- **Support Phone** - displayed in support communications and email footers.
- **Street Address, City, State / Province, ZIP / Postal Code, Country** - company address used in email footers and in the "From" block of invoices. Enter **Country** as a two-letter ISO code, for example `US`. The Adyen card forms need it.
- **Driver Portal URL** - the public URL of the driver portal (e.g., `https://portal.example.com`). Used for QR code links and email links, and shown as a link on the operator login page.

### Tax calculation method

**Tariff prices are entered** (`company.taxBasis`) sets whether tariff prices include tax and how tax is calculated:

- **Excluding tax (net)** (default) - tariff prices exclude tax. The tariff tax rate is added to each session's cost. Charged amounts are the same as before this setting existed.
- **Including tax (gross)** - tariff prices include tax. A session costs the gross price times the quantity, so each billed line equals the gross unit price times its quantity, and the tax is taken out of that amount.

The tariff form labels switch between "excl. tax" and "incl. tax" and preview the other value. See [Pricing](https://www.evtivity.com/docs/csms/pricing). Sessions keep the setting they started with. Changing it does not convert existing tariff prices: the CSMS asks you to confirm and to re-enter each tariff price after saving.

This setting decides how prices are entered and billed. **Prices in the driver portal** decides what drivers see. The two are independent: for example, you can enter prices excluding tax and show drivers prices including tax.

### Price display

Every session cost includes tax. The **Prices in the driver portal** setting only changes how prices are shown, not what drivers pay. Prices are converted from the way they were entered to the way they are shown.

- **Excluding tax (net)** shows prices before tax, with a note that tax is added to the amount charged.
- **Including tax (gross)** shows prices with the tariff tax rate added, with a note that prices include tax.

The setting applies to:

- Charger prices, session details, and idle fee emails in the driver portal and the mobile app.
- Guests, who have no choice of their own.
- Drivers who have not chosen **Show prices** in their account. A driver's own choice overrides the setting. See [Account management](https://www.evtivity.com/docs/portal/account).
- Station screens, which always follow this setting because the screen is public. See [Station display messages](https://www.evtivity.com/docs/guides/station-display-messages).

Session costs always include tax, whatever the setting. Session details split the total into net amount and tax.

EU and UK consumer price rules usually require gross prices at the point of sale (for example the EU Price Indication Directive 98/6/EC). Operators in those markets should choose **Including tax (gross)**.

### Invoice seller details

The **Invoice seller details** section sets what invoices print as the seller, in the "From" block under the company name and address. This covers driver invoices, credit notes, and fleet invoices. Many countries require the seller's address and tax number on an invoice, for example the VAT ID on an EU invoice.

- **Tax ID** - your VAT ID or tax number.
- **Tax ID label** - printed before the tax ID, for example `VAT ID`. Leave it empty to print "Tax ID" in the invoice language.
- **Company registration number** - for example your trade register entry.
- **Invoice contact email** and **Invoice contact phone** - contact details for questions about an invoice.

Each field is one line of text. An empty field is left off the invoice. A new installation starts with every field empty. Changing these settings needs `settings.system:write` and access to all sites.

![Invoice seller details](https://www.evtivity.com/screenshots/csms/settings-invoice-seller.png)

### Invoice payment information

The **Invoice Payment Information** section sets the bank details that invoices print in a "Payment information" block below the totals. The block appears only when an IBAN is set, on driver invoices, fleet invoices, member invoices, and credit notes.

- **Account holder** - the name of the account owner. Leave it empty to print the company name.
- **IBAN** - enter it with or without spaces. It is stored without spaces in upper case and printed in groups of four. An IBAN with a wrong check digit is refused.
- **BIC** - 8 or 11 characters. Optional.
- **Bank name** - optional.
- **EPC QR code on EUR invoices** - on by default. Prints a QR code (EPC069-12, SEPA credit transfer) that banking apps scan to fill in the account holder, the IBAN, the amount, and the invoice number.

What the block shows depends on the invoice:

- **Open invoice** - asks for a transfer of the total by the due date, with the invoice number as the payment reference, and lists the bank details. Fleet and member invoices paid by transfer get this block. The EPC QR code is added when the invoice is in EUR.
- **Paid invoice** - states that the invoice is paid, "by card" for a driver invoice paid by card when it was issued, and asks for no transfer, so nobody pays twice. A payment reference recorded with **Mark Paid** is printed.
- **Credit note** - states that no payment is due and that the amount is refunded or offset. No QR code.

The block is printed in the invoice language. A new installation starts with no bank details. Changing these settings needs `settings.system:write` and access to all sites. Settings `company.bankAccountHolder`, `company.iban`, `company.bic`, `company.bankName` and `invoice.epcQrEnabled`.

### PDF branding

The **PDF branding** section sets the logo and the footer of every PDF the platform generates: invoices, credit notes, fleet invoices, and reports.

- **PDF logo** - upload a PNG or SVG file (max 512 KB). The preview shows the logo in use. Scripts and references to other files are removed from SVG files. **Reset to default** returns to the default logo: the EVtivity mark with the word EVtivity.
- **PDF footer** - plain text centered at the bottom of every page, up to 5 lines and 500 characters. Long lines wrap. The footer is shown exactly as entered in every PDF, whatever its language. It is not translated. A new installation starts with `www.evtivity.com`. Leave it empty for no footer.

Changing these settings needs `settings.system:write` and access to all sites.

![PDF branding](https://www.evtivity.com/screenshots/csms/settings-pdf-branding.png)

## Marketing

**Permission:** `settings.system:read` / `settings.system:write`

Google Analytics tracking configuration.

- **Portal GTAG Measurement ID** - Google Analytics measurement ID for the driver portal (e.g., `G-XXXXXXXXXX`).
- **CSMS GTAG Measurement ID** - Google Analytics measurement ID for the operator dashboard.

## Content

**Permission:** `settings.system:read` / `settings.system:write`

Manage the legal content displayed in the driver portal. Content is edited per language using a WYSIWYG editor.

**Language** selector - choose between English, German, Spanish, Korean, Simplified Chinese, and Traditional Chinese (6 languages). Each language has independent content. The privacy policy and terms pages show the version for the language the visitor selected.

### Privacy Policy

Rich text editor for the portal's privacy policy page.

### Terms of Service

Rich text editor for the portal's terms of service page.

## Notification

**Permission:** `settings.notification:read` / `settings.notification:write`

Email, SMS and webhook delivery configuration with four sub-tabs.

### SMTP Email

SMTP email server configuration.

- **Host** - mail server hostname (e.g., `smtp.example.com`).
- **Port** - mail server port (default 587).
- **Username** - SMTP authentication username.
- **Password** - SMTP authentication password.
- **From Address** - sender email address for outgoing emails (e.g., `noreply@example.com`).
- **Send to** input + **Send Test** button - sends a test email to the address you type. Defaults to the From Address on first load; edit it to send the test to any inbox you control. The button is disabled until SMTP is saved and the Send to field has a value.

When SMTP is not configured, email notifications fall back to the log channel.

### Twilio SMS

Twilio SMS delivery configuration.

- **Account SID** - Twilio account identifier.
- **Auth Token** - Twilio authentication token.
- **From Number** - Twilio phone number for outgoing SMS (e.g., `+15551234567`).
- **Send to** input + **Send Test** button - sends a test SMS to the number you type (E.164 format, e.g., `+15551234567`). Use a phone you can check directly, not the From Number, since Twilio rejects sending a message from a number to itself.

When Twilio is not configured, SMS notifications fall back to the log channel.

### Webhooks

Notification webhooks are sent only to public addresses. A webhook URL that is, or resolves to, a private or internal address is blocked and logged as **Webhook blocked (private URL)**.

- **Allowed private webhook hosts** - hostnames or IP addresses, one per line, without scheme or port (up to 20). Webhooks to these hosts may use a private address, for example an in-house automation server. Empty by default.

### Email Layout

Customize the HTML wrapper template applied to all outgoing emails.

- **Available variables** - click-to-copy variable pills: `companyName`, `companyContactEmail`, `companySupportEmail`, `companySupportPhone`, `companyStreet`, `companyCity`, `companyState`, `companyZip`, `companyCountry`, `companyCurrency`.
- **HTML Template** - code editor for the raw HTML. Uses `{{{content}}}` (triple-stache, unescaped) for the email body and `{{companyName}}` for company name.
- **Preview** - sandboxed iframe showing the rendered template with sample email content.
- **Reset to Default** button - reverts to the built-in email layout.

All emails (notifications, MFA codes, password resets, reports) are wrapped in this layout.

## Sustainability

**Permission:** `settings.system:read` / `settings.system:write`

Parameters for CO₂ emissions calculations on the sustainability report.

- **Grid Emission Factor (kg CO₂/kWh)** - kg CO₂ per kWh from the grid (default 0.386).
- **EV Efficiency (miles/kWh)** - miles per kWh for electric vehicles (default 3.3).
- **Gasoline Emission Factor (kg CO₂/gallon)** - kg CO₂ per gallon of gasoline (default 8.887).
- **Average Vehicle MPG** - average miles per gallon for gasoline vehicles (default 25.4).

## Payment

**Permission:** `settings.payment:read` / `settings.payment:write`. Creating webhooks, saving Adyen settings, and site payout actions also need `payments:write`. Without it, those controls are hidden.

Card payment configuration with five sub-tabs: General, Stripe, Adyen, Payment Terminals, and Site Configurations. The tab opens on General. Saving a provider's keys does not select it: select the provider on the General tab. See [Payment Providers](https://www.evtivity.com/docs/integrations/payment-providers) for the providers and how the active one is chosen.

The **Payment Terminals** sub-tab holds the ID TECH account of the card readers at the chargers: environment, merchant ID, API key, API secret and webhook secret. Changing the environment, the merchant ID or a credential asks you to confirm your sign-in again, and an API key cannot change them. See [Payment Terminals](https://www.evtivity.com/docs/integrations/payment-terminals#settings).

![Payment settings, General tab](https://www.evtivity.com/screenshots/csms/settings-payment-general.png)

### General

- **Provider for New Payments** - None (payments off), Stripe, Adyen, or Test provider. Payments already made keep the provider that made them. A provider without credentials shows "(credentials missing)", and Adyen shows "(upgrade in progress)" while services of an earlier release are connected. The test provider is listed only where it is enabled.
- **Providers** - each provider with its badge: Selected, Ready, Not configured, or Upgrade pending.
- With None selected, a warning says that payments are off: sessions start without a pre-authorization and guests charge without paying.
- **Upgrade pending** panel - appears for Adyen while services of an earlier release are connected. It shows their open connections and hosts, when one was last seen, and when the worker last checked. See [Select Adyen](https://www.evtivity.com/docs/integrations/adyen#9-select-adyen).
- **Default Pre-Auth Amount** - hold placed on a card before charging starts, entered in the company currency (0.01 to 10,000.00, default 50.00). A site configuration can override it. Setting `payments.preAuthAmountCents`.
- **Platform Fee %** - share of each payment kept from a site host payout account (0-100%). The fee is a percent of the net amount charged, tax excluded, and is set when the payment is captured, not on the pre-authorization hold. A site configuration can override it. Setting `payments.platformFeePercent`.
- **Test Provider** card - shown where the test provider is enabled. "Test mode. No real money moves."
  - **Result Mode** - **Synchronous** returns each result in the API response. **Asynchronous** answers captures, cancels, and refunds as pending and confirms them through the webhook pipeline after the delay, as Adyen does.
  - **Async Result Delay (seconds)** - delay of asynchronous results, 0 to 3600.
  - **Random Failure Rate** - share of payments that fail for cards without a test scenario, 0 to 1.
- **Prepaid Cards** card - shown to users who can change system settings. **Low Credit Notice Threshold** is the balance below which a debit sends the driver the low credit notice `prepaid.LowCredit`, entered in the company currency (default 5.00). 0 turns the notice off. Setting `prepaid.lowCreditThresholdCents`. See [Prepaid Cards](https://www.evtivity.com/docs/csms/tokens#prepaid-cards).
- **Invoices** card - shown to users who can change system settings. **Payment Terms (days)** is the days from issue to the due date of a new invoice (0 to 365, default 30, 0 makes it due on issue). Setting `invoice.paymentTermsDays`. **Monthly Fleet Invoice Day** is the day of the month, in the system time zone, from which the monthly run invoices the previous month for every fleet with automatic monthly invoice (1 to 28, default 1). Setting `fleet.invoiceRunDay`. See [Monthly Run](https://www.evtivity.com/docs/csms/fleets#monthly-run).

![Invoice settings](https://www.evtivity.com/screenshots/csms/settings-payment-terms.png)

A site-restricted user does not see the provider, Stripe, Adyen, and Payment Terminals settings. It sees the **Site Configurations** sub-tab, and the **Prepaid Cards** and **Invoices** cards read-only when it can read system settings. See [Company-Wide Features](https://www.evtivity.com/docs/csms/users#company-wide-features).

Save sends only the changed fields. When the selection is refused, the previous provider stays selected and the panel shows the details.

### Stripe

Global Stripe configuration. Step-by-step setup: [Stripe](https://www.evtivity.com/docs/integrations/stripe).

- **Secret Key** - Stripe secret or restricted API key. Stored encrypted.
- **Publishable Key** - Stripe publishable key for client-side payment forms.
- **Webhook Signing Secret** - signing secret (`whsec_...`) of the platform webhook endpoint. Stored encrypted.
- **Connect Webhook Signing Secret** - signing secret (`whsec_...`) of the Connect webhook endpoint, which sends `account.updated` for site host accounts. Stored encrypted.
- Secret fields show the stored value, hidden until you click the eye icon. Edit a field to replace the value, or empty it to remove the stored value when you save.
- **Test Connection** button - verifies the Stripe API key is valid.

The **Webhooks** card creates and lists the two Stripe endpoints:

- **Webhook Endpoint URL** - the URL Stripe sends events to, ending in `/v1/webhooks/payments/stripe`. It starts as the API URL of your deployment. Edit the host to use a tunnel. The URL must use `https`.
- **Create webhook** button - creates the platform and Connect endpoints in Stripe at the Webhook Endpoint URL with their events and API version `2026-09-30.endive`, and stores both signing secrets. If EVtivity endpoints already exist at that URL, a dialog asks before replacing them, because Stripe issues new signing secrets. The **Endpoints** table lists the endpoints at that URL with their scope, URL, events, API version, and state. **Other EVtivity deployments** lists the EVtivity endpoints of other deployments that share the Stripe account. EVtivity never changes them.
- **Manual setup** - the events of each endpoint, the API version, and the `stripe listen` command for local tests, for when you create the endpoints in Stripe yourself.

### Adyen

Adyen configuration. Adyen cannot be selected on the General tab while services of an earlier release are still connected. You can save the settings, test the connection, and create the webhook before that. Step-by-step setup and selection: [Adyen](https://www.evtivity.com/docs/integrations/adyen).

![Payment settings, Adyen tab](https://www.evtivity.com/screenshots/csms/settings-payment-adyen.png)

- **Merchant Account** - Adyen merchant account code.
- **Environment** - Test or Live. **Live URL Prefix** and **Live Region** appear when live.
- **Client Key** - public client key for the card forms. Add the portal and CSMS URLs to its allowed origins.
- **API Key**, **HMAC Key**, **Webhook Password** - stored encrypted. Each shows the stored value behind the eye icon, like the Stripe secrets.
- **Webhook Username** - Basic auth username of the webhook.
- **Authorization Adjustment** - raises the hold to the final cost instead of charging a second payment. Off by default. Turn it on only after Adyen enables it for your merchant category. See [Costs Above the Hold](https://www.evtivity.com/docs/integrations/adyen#costs-above-the-hold).
- **Test connection** button - checks the API key with Adyen Checkout and lists the roles of the API credential, with a warning when the webhook role is missing.
- **Webhook** card - **Webhook URL**, ending in `/v1/webhooks/payments/adyen`, and **Create webhook**. Creates or, after a confirmation, updates the webhook at that URL in Adyen, stores its username, password, and HMAC key, switches it on, and shows the result of a test event Adyen sends. **Other EVtivity deployments** lists the EVtivity webhooks of other deployments that share the merchant account. EVtivity never changes them.

### Site Configurations

Per-site payment configuration. The left panel lists all sites with an enable/disable toggle. Selecting a site shows its configuration.

![Site payout account card](https://www.evtivity.com/screenshots/csms/settings-payment-site-payout.png)

The **Payout Account** card shows the site's Stripe connected account:

- No account: **Create Stripe account** opens a dialog. **Contact email** is required, because Stripe requires a contact email for the site host's account. It is prefilled with the site contact email. **Country code** is optional: a two-letter ISO code, empty to use the site's country. EVtivity creates an Express account for the site host with the site name, this email, and the country.
- With an account: the status (Onboarding, Action required with the number of requirements due, Pending, Active, Disabled with the reason, or Not checked), the `card_payments` and `transfers` capabilities, and when Stripe was last checked.
- **Copy onboarding link** - copies a 7-day EVtivity link for the site host. The link opens Stripe-hosted onboarding. Earlier links stop working.
- **Email site contact** - sends the link to the site's contact email. Disabled when the site has no contact email.
- Both link actions are hidden while the account is Active, because the link is revoked then.
- **Refresh** - reads the account status from Stripe.
- A warning appears when payments are enabled for the site and the account is not Active. Card payments at the site are refused until it is.

See [Stripe Connect](https://www.evtivity.com/docs/integrations/stripe#4-stripe-connect) for the onboarding flow.

- **Connected Account ID** - Stripe Connect account ID for this site (e.g., `acct_...`), for an account onboarded in Stripe. Accounts created above fill this in. Saving it checks the account with Stripe.
- **Default Pre-Auth Amount** - per-site hold amount, entered in the company currency. It replaces the General tab value at this site. Below the session fee of the site, the save shows a warning, and a guest is held the session fee plus this amount.
- **Platform Fee % Override** - per-site platform fee percentage. Blank uses the General tab value.

## Integrations & Features

**Permission:** `settings.integrations:read` / `settings.integrations:write`

Feature toggles and third-party service configuration with 17 sub-tabs.

### OCPP

OCPP values sent to stations at every boot, one set per data plan. The **Wi-Fi or Wired** tab holds the values of the default plan, the **Cellular** tab the values of stations on cellular data plans. Each tab has its own **Save**. A station gets its plan's values at its next boot, or at once when its plan changes while it is online.

| Field | Wi-Fi or wired | Cellular |
|---|---|---|
| Heartbeat interval (seconds), sent in the BootNotification response | 900 | 3600 |
| CSMS ping interval (seconds) | 120 | 240 |
| AC stations: meter value interval (seconds), readings while charging | 60 | 300 |
| AC stations: sampled measurands, readings while charging | `Energy.Active.Import.Register,Power.Active.Import,Current.Import` | `Energy.Active.Import.Register,Power.Active.Import` |
| DC stations: meter value interval (seconds), readings while charging | 30 | 60 |
| DC stations: sampled measurands, readings while charging | `Energy.Active.Import.Register,Power.Active.Import,Current.Import,SoC` | `Energy.Active.Import.Register,Power.Active.Import,SoC` |
| Clock-aligned interval (seconds), idle readings, 0 turns them off | 900 | 0 |
| Clock-aligned measurands | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` |
| Transaction ended measurands | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` |

The readings while charging have an **AC Stations** and a **DC Stations** section on each tab. See [Data Usage Defaults](https://www.evtivity.com/docs/configuration/data-usage-defaults) for the OCPP keys, how the CSMS tells AC from DC, and the data use of each plan, and [Cellular Stations](https://www.evtivity.com/docs/configuration/cellular-stations) for how a station gets its plan.

The tab also has:

- **Command timeout (seconds)** - seconds to wait for a station to respond to a command before timing out (default 120).
- **Reset retries** - number of reset command retries (default 3).
- **Require approval for new stations** - when on, new stations need manual approval. When off, stations are auto-accepted.

### Roaming

OCPI roaming feature toggle.

- **Enable Roaming (OCPI)** - toggle for OCPI roaming functionality. When disabled, roaming nav items and endpoints are hidden.

### Plug & Charge

ISO 15118 Plug and Charge configuration.

- **Enable Plug & Charge (ISO 15118)** - feature toggle for Plug and Charge.
- **PKI Provider** - select between the `Hubject`, `Manual`, and `Local` (local contract CA) PKI providers.
- **eMAID country code** and **eMAID provider ID** - prefix of the eMAIDs the local contract CA issues (Local provider).
- **Create Contract CA** button - creates the local contract CA once (Local provider). See [Certificates](https://www.evtivity.com/docs/csms/certificates#local-contract-ca).
- **Hubject API Base URL** - OPCP API base URL.
- **OAuth2 Client ID** - OAuth2 client ID.
- **OAuth2 Client Secret** - OAuth2 client secret (stored encrypted).
- **OAuth2 Token URL** - OAuth2 token endpoint.
- **Expiration Warning (days)** - days before certificate expiry to show warnings (default 30).
- **Auto-Renewal Threshold (days)** - days before certificate expiry to trigger auto-renewal (default 7).
- **OCSP Hosts on Private Networks** - private or internal hosts the CSMS may send OCSP requests to (default empty). See [OCSP Hosts on Private Networks](#ocsp-hosts-on-private-networks).
- **Test Connection** button - verifies connectivity to the selected PKI provider.

#### OCSP Hosts on Private Networks

The CSMS sends OCSP requests to check whether a certificate is revoked. It does this when a station sends `GetCertificateStatus` (OCPP 2.1) and when it checks a contract certificate in a Plug and Charge `Authorize` request. The responder URL comes from the station or from the certificate, not from your configuration.

**Why private hosts are blocked.** A station or a crafted certificate could name an internal address as the responder. Without a guard, the CSMS would send requests into your own network on their behalf (server-side request forgery). Examples are a cloud metadata endpoint such as `169.254.169.254`, the database, Redis, or an admin interface. The CSMS therefore refuses OCSP requests to:

- URLs that are not `http` or `https`
- `localhost` and names ending in `.local`, `.internal`, or `.localhost`
- Non-public IP addresses: loopback (`127.0.0.0/8`, `::1`), private ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `fc00::/7`), link-local (`169.254.0.0/16`, `fe80::/10`), carrier-grade NAT (`100.64.0.0/10`), documentation, multicast, and reserved ranges, and IPv4 addresses embedded in IPv6
- Host names that resolve to any non-public address. The CSMS checks every address a name resolves to when it connects, and connects only to an address it checked, so a DNS answer that changes between the check and the connection cannot reach an internal service.

The CSMS does not follow redirects from an OCSP responder. A blocked request fails the check: `GetCertificateStatus` returns `Failed`, and a contract certificate check returns `Invalid` with certificate status `CertChainError`. The OCPP server log records "OCSP status request failed" with the blocked host.

**When you need it.** List a host when your OCSP responder runs on a private network that the CSMS reaches, for example:

- An in-house OCSP responder of your own PKI
- A responder in the same Docker network or Kubernetes cluster as the CSMS
- The OCSP responder of a conformance test run, such as `host.docker.internal` (see [Conformance](https://www.evtivity.com/docs/conformance/overview))

Public responders, such as those of Hubject or a public CA, need no entry.

**How to set it.** Enter one host per line: a host name or an IP address, without scheme, port, or path (`ocsp.pki.internal`, `10.20.0.15`). The list holds at most 20 hosts. The CSMS stores them in lowercase and removes duplicates. A listed host skips the address check for every address it resolves to, so list only hosts you control. Changes take effect within 60 seconds. The setting key is `pnc.ocsp.allowedPrivateHosts`.

### Reservation

Reservation feature toggle and settings.

- **Enable Reservations** - toggle for the reservation system.
- **Buffer Time (minutes)** - minutes of buffer added to reservation windows (default 15).
- **Cancellation Window (minutes)** - minutes before the start time within which a cancellation is charged the cancellation fee (default 5).
- **Cancellation Fee** - amount in the company currency, excluding or including tax as **Tariff prices are entered** sets (the label says which), charged for a cancellation inside the cancellation window (default 0). The fee is taxed at the tax rate of the station's tariff. A reservation is charged the fee in effect when it was made.

### Support

Support cases feature toggle.

- **Enable Support** - toggle for the support case system. When disabled, support nav items and endpoints are hidden.

### Fleet

Fleet management feature toggle and the credit reservation of account sessions.

- **Enable Fleet** - toggle for fleet management. When disabled, fleet nav items and endpoints are hidden.
- **Credit reserved per session** - fleet credit, in the company currency, that an account session reserves at its start and adds each time its cost nears the reservation, for fleets with a credit limit (default 50.00). The other sessions of the fleet can use the rest of the limit. Setting `fleet.creditReservationCents`. See [Credit Limit](https://www.evtivity.com/docs/csms/fleets#credit-limit).

![Fleet settings](https://www.evtivity.com/screenshots/csms/settings-fleet-credit-reservation.png)

### Guest Charging

Guest charging feature toggle and card testing limits.

- **Enable Guest Charging** - toggle for guest (unauthenticated) charging via the portal. When disabled, the guest checkout flow is hidden.
- **Guest Starts per IP per Hour** - guest starts one client IP address may make in an hour (default 30). Setting `guest.startsPerIpPerHour`.
- **Declined Cards per IP per Hour** - after this many declined cards in an hour, the address can place no new payment hold (default 5). Setting `guest.declinesPerIpPerHour`.

0 means no limit. The limits apply only when the server knows the guest's real IP address: set `TRUST_PROXY` behind a load balancer or ingress. A public address reaching the API directly is limited as is. See [Guest Charging](https://www.evtivity.com/docs/portal/guest-charging#start-protection).

### Idling

Idle fee configuration.

- **Grace period (minutes)** - minutes of idle time before idle fees start (default 30). The first idle minutes of the session are free, across all of its idle periods and wherever its tariff segments split. Set to 0 to start idle fees immediately.

### Session

Session lifecycle settings.

- **Stale session timeout (hours)** - hours after which an inactive session is marked as stale and cleaned up (default 24). A stale session is marked faulted and not billed: its cost is set to 0 and its payment hold is released. A session replaced by a new transaction on the same EVSE, or one the station no longer knows when an operator stops it, is not stale: it is completed and billed at its last metered energy, and the driver gets the receipt.

### Pricing

Billing settings.

- **Split Billing** - toggle for per-segment billing when tariffs change during a session (`pricing.splitBillingEnabled`, default on). See [Pricing](https://www.evtivity.com/docs/csms/pricing).

### Messages

Station display message configuration. Drives the all-state push pipeline that writes context-aware text to OCPP 2.1 station displays as the connector and transaction state changes.

- **Enable Station Messages** - master toggle (`stationMessage.enabled`). When on, the CSMS pushes per-state messages to every connected OCPP 2.1 station: Available, Occupied, Reserved, Charging, Suspended, Discharging, Faulted, and Unavailable.
- **Pricing Format** - `compact` or `standard` (`stationMessage.pricingFormat`). Controls the format of the `{{pricingDisplay}}` variable inside the Available template.
- **Charging Refresh Interval (seconds)** - per-station refresh threshold for the Charging template during an active session (`stationMessage.charging.refreshSeconds`, default 30). The cron handler ticks every 30 seconds and skips stations whose Charging slot was pushed within this window. Lower values increase OCPP traffic and risk display flicker on slow stations.
- **Brand Line** - optional first line shown on every state (`stationMessage.brandLine`, the `{{brandLine}}` variable). Empty falls back to the company name.
- **Display Language** - default language of the station screens (`stationMessage.language`, default `en`): English, German, Spanish, Korean, Simplified Chinese, or Traditional Chinese. It picks the template language and formats prices, numbers, the tax rate, times, and the elapsed charging time. A site can set its own language on its Details tab ([Sites](https://www.evtivity.com/docs/csms/sites)).

Saving these settings, a state template, or the company name, support phone, currency, price display, or tax basis updates the screens of every online station within a few seconds. Screens whose text did not change are not sent again.

The Messages tab also includes a per-state template editor. Each state has a template per language, chosen with **Template Language** (defaults to the display language). Each of the eight state templates is a Handlebars body with a click-to-insert variable picker filtered by state (e.g., `{{energyKwh}}`, `{{powerKw}}`, `{{costFormatted}}` show up only for Charging, Suspended, and Discharging). A live preview renders the compiled template with sample values in the company currency, the price display, and the chosen language. Save persists to the `station_message_templates` table. Reset reverts that language's template to the default. Templates accept only variables, comments, and `{{#if}}` / `{{#unless}}` blocks on one variable with an optional `{{else}}`. Save refuses a template that uses any other Handlebars feature.

OCPP 1.6 stations have no native equivalent. They receive the Idle screen (Available, Occupied, Reserved) as a vendor `DataTransfer`.

### SIM Providers

The SIM provider accounts (Hologram and 1NCE) and the station signal settings behind the **SIMs** page and the station **Connectivity** tab. Needs access to every site. Off by default: while Hologram, 1NCE and **Read Signal from Stations** are all off, nothing changes. See [SIM Providers](https://www.evtivity.com/docs/integrations/sim-providers).

### S3 Bucket

Amazon S3 (or S3-compatible) object storage for file attachments and station images.

- **Bucket Name** - S3 bucket name.
- **Region** - AWS region (e.g., `us-east-1`).
- **Access Key ID** - IAM access key ID (stored encrypted).
- **Secret Access Key** - IAM secret access key (stored encrypted).
- **Test Connection** button - verifies S3 bucket access.

Leave both access key fields blank to use the default AWS credential chain. On AWS, that is the task or instance role. If you fill in only one of the two fields, S3 stays disabled until you fill in both or clear both.

Includes expandable sections showing the recommended IAM policy and CORS configuration.

The CSMS uploads support case attachments and station images, and the driver portal uploads driver avatars, straight to the bucket with a presigned `POST`. A self-managed bucket needs a CORS rule that allows `POST` from both the CSMS origin and the driver portal origin, for example:

```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["POST", "GET"],
    "AllowedOrigins": ["https://csms.example.com", "https://portal.example.com"],
    "ExposeHeaders": [],
    "MaxAgeSeconds": 300
  }
]
```

Without the portal origin, drivers cannot upload an avatar from the portal. The mobile app does not need a CORS rule. The AWS deployment creates the bucket with this rule.

### FTP Server

FTP server configuration for firmware file transfers.

- **Host** - FTP server hostname.
- **Port** - FTP server port (default 21).
- **Username** - FTP authentication username.
- **Password** - FTP authentication password.
- **Path** - base directory path on the FTP server.

### Google Maps

Google Maps integration for site and station mapping.

- **API Key** - Google Maps JavaScript API key.
- **Default Latitude** - map center latitude (default 39.8283, center of US).
- **Default Longitude** - map center longitude (default -98.5795).
- **Default Zoom Level** - initial map zoom level (default 4).

### Sentry

Sentry error monitoring configuration.

- **Enable Sentry** - toggle for error reporting.
- **DSN** - Sentry Data Source Name.
- **Environment** - environment label (e.g., `production`, `staging`).

## Security

**Permission:** `settings.security:read` / `settings.security:write`

Security settings with four sub-tabs.

### reCAPTCHA

Google reCAPTCHA v3 bot protection for login pages.

- **Enable reCAPTCHA v3** - toggle for reCAPTCHA on login forms.
- **Site Key** - reCAPTCHA v3 site key.
- **Secret Key** - reCAPTCHA v3 secret key (stored encrypted). Shows `********` when already configured.
- **Score Threshold** - minimum score to pass (0-1, default 0.5). Higher values are stricter.

When enabled, login pages and guest charging starts require a passing reCAPTCHA score.

While reCAPTCHA is off, the tab shows a warning: driver portal sign-up, sign-in and password reset are protected only by IP rate limits. Turn it on when anyone can register in the portal.

![Security settings, reCAPTCHA tab with the warning](https://www.evtivity.com/screenshots/csms/settings-security.png)

### MFA

The sign-in methods operators and drivers can use, and who must use MFA. See [Multi-Factor Authentication](https://www.evtivity.com/docs/configuration/authentication#multi-factor-authentication) for how each method works.

![Security settings, MFA tab](https://www.evtivity.com/screenshots/csms/settings-security-mfa.png)

- **Email Code** - toggle for email-based verification codes. Disabled when SMTP is not configured (shows a warning hint).
- **Authenticator App (TOTP)** - toggle for authenticator app codes (Google Authenticator, Authy, etc.).
- **SMS Code** - toggle for SMS-based verification codes. Disabled when Twilio is not configured (shows a warning hint).
- **Passkeys and Security Keys** - operators and drivers can add a passkey or a security key, such as a YubiKey, as a second factor. Needs HTTPS or localhost. On by default.
- **Passkey Sign-In** - operators and drivers can sign in with a passkey alone, without a password. The passkey counts as both factors. Needs **Passkeys and Security Keys**. Off by default.
- **Require MFA** - **Off**, **All Operators**, or **Selected Roles**. With **Selected Roles**, check the roles under **Roles That Must Use MFA**. Off by default. When it is on, operators without MFA must set it up at their next sign-in. Signed-in operators are asked at their next session renewal. Open sessions and API keys keep working until then.
- **Require MFA for Drivers** - off by default. When it is on, every driver must set up MFA in the driver portal at the next sign-in, before a session starts. Signed-in drivers are asked at their next session renewal. The mobile app sends drivers to the portal to finish the setup.

Notes:

- Switching a method off also applies at sign-in. Accounts that use it sign in with another factor, or set up an allowed method after proving the old one. See [Switched-Off Methods](https://www.evtivity.com/docs/configuration/authentication#switched-off-methods).
- **Require MFA** and **Require MFA for Drivers** need **Email Code** or **Authenticator App (TOTP)** on. Otherwise the tab shows "Turn on email codes or the authenticator app before you require MFA." and does not save.
- When the MFA settings cannot be read, accounts that must use MFA and have none cannot sign in until the settings can be read again.
- Saving needs access to all sites.

### Single Sign-On

SAML-based Single Sign-On for operator accounts.

- **Enable SSO** - toggle for SSO login.
- **Identity Provider** - select the identity provider: Okta, Azure AD, Google Workspace, or Custom.
- **IdP Entry Point URL** - IdP's SAML SSO endpoint (e.g., `https://your-idp.example.com/sso/saml`).
- **SP Entity ID (Issuer)** - service provider identifier (default `evtivity-csms`).
- **IdP Certificate (X.509 PEM)** - PEM-encoded X.509 certificate from the identity provider (stored encrypted).
- **ACS Callback URL** - read-only Assertion Consumer Service URL. Copy button provided for IdP configuration.
- **Auto-Provision Users** - toggle to automatically create operator accounts on first SSO login.
- **Default Role for New Users** - role assigned to auto-provisioned users (shown when auto-provision is enabled).
- **Attribute Mapping** - map IdP SAML attributes to user fields:
  - Email attribute name (default `email`)
  - First name attribute name (default `firstName`)
  - Last name attribute name (default `lastName`)

Notes:

- Accounts created through SSO have no password. They cannot sign in with a password, reset it, or change it.
- The allowed email domains (`sso.allowedDomains`, a comma-separated list) apply to existing accounts as well as new ones. An empty list allows every domain.
- A SAML reply is accepted only when it answers a sign-in request the CSMS made, and only once.
- A user with MFA completes the second factor after the SSO sign-in. When **Require MFA** covers a user without MFA, the user sets it up after the SSO sign-in.
- The sign-in must finish in the browser that started it. A reply posted to another browser shows "The single sign-on reply did not match a sign-in started in this browser." and starts no session.
- Over plain HTTP, Chrome accepts the reply only within two minutes of the start of the sign-in. Use HTTPS, or start a slow sign-in again. See [SSO Accounts](https://www.evtivity.com/docs/configuration/authentication#sso-accounts).

### Passwords and Sessions

The rules for new passwords and how long operators and drivers stay signed in. The tab has two cards, **Passwords** and **Sessions**, each with its own **Save** button.

![Security settings, Passwords and Sessions tab](https://www.evtivity.com/screenshots/csms/settings-security-passwords.png)

**Passwords** apply to operators and drivers alike:

- **Minimum Length** - characters, from 8 to 64 (default 12). A new password is at most 128 characters.
- **Require an Uppercase Letter** - on by default.
- **Require a Lowercase Letter** - on by default.
- **Require a Number** - on by default.
- **Require a Special Character** - any keyboard character that is not a letter, digit or space, such as `!` or `#`. Off by default.

The rules apply the next time someone sets a password. Current passwords keep working, because sign-in never checks the rules. The password forms of the CSMS and the driver portal list the rules in effect.

**Sessions**:

- **Operator Sign-In Check Interval** - minutes, from 5 to 1440 (default 60). The CSMS checks the sign-in again this often, in the background, without asking the operator.
- **Operator Inactivity Timeout** - days, from 1 to 90 (default 30). An operator who does not use the CSMS for this long has to sign in again.
- **Driver Sign-In Check Interval** - minutes, from 5 to 1440 (default 60), for the driver portal and the mobile app.
- **Driver Inactivity Timeout** - days, from 1 to 365 (default 30). A driver who does not use the portal or the app for this long has to sign in again.

The values apply when someone signs in or the app renews their sign-in. Active sessions take on the new values within one check interval. A session no one uses keeps its old expiry. A deactivated account is signed out within a minute, whatever the check interval.

Saving needs access to all sites. For the API, see [Password Policy](https://www.evtivity.com/docs/configuration/authentication#password-policy) and [Session Management](https://www.evtivity.com/docs/configuration/authentication#session-management).

## API Keys

**Permission:** `settings.apiKeys:read` / `settings.apiKeys:write`

Manage API keys for programmatic access to the REST API.

- **Create API Key** button - opens a dialog to create a new key with:
  - Key name
  - Expiration period (no expiry, 30/60/90/180/365 days, or custom)
  - Permission picker - select which permissions the key should have (defaults to all of the creating user's permissions)
- **Key table** - lists existing keys with columns:
  - Name
  - Key suffix (last characters of the token)
  - Created date
  - Last used date
  - Expiration date (with expired badge)
  - Actions (edit permissions, revoke)
- **Token display dialog** - shown once after creation with a copy button. The raw token is only visible at creation time.
- **Quick Start** card - code examples in cURL, JavaScript, and Python showing how to use the API key with Bearer authentication.

Creating a key, or widening the permissions of a key, asks you to confirm first with a code of your current second factor or a passkey, else your current password. An SSO account without a second factor signs in again with SSO. A request made with an API key needs no confirmation. See [API Keys](https://www.evtivity.com/docs/configuration/authentication#api-keys).

API keys inherit the creating user's site access at request time. Revoking a key is permanent. API keys cannot use the account routes of the signed-in user (profile, password, MFA, notification preferences, and personal AI configuration). Deactivating or deleting a user revokes the user's API keys, and the user page shows them on its [Security tab](https://www.evtivity.com/docs/csms/users#security-tab).

## Firmware Campaign

**Permission:** `settings.firmware:read` / `settings.firmware:write`

Embeds the Firmware Campaigns page. Create and manage firmware update campaigns that push firmware to stations matching target filters (site, vendor, model). See [Firmware Campaigns](https://www.evtivity.com/docs/csms/firmware-updates) for details.

## Station Configurations

**Permission:** `settings.stationConfig:read` / `settings.stationConfig:write`

Embeds the Configuration Templates page. Create templates of OCPP configuration variables and push them to groups of stations. See [Configuration Templates](https://www.evtivity.com/docs/csms/station-configurations) for details.

## Smart Charging

**Permission:** `settings.smartCharging:read` / `settings.smartCharging:write`

Embeds the Smart Charging Templates page. Create charging profile templates with time-of-day power schedules and push them to stations. See [Smart Charging](https://www.evtivity.com/docs/csms/smart-charging) for details.

## AI

**Permission:** `settings.ai:read` / `settings.ai:write`

Configures the [AI assistant](https://www.evtivity.com/docs/csms/ai-assistant), the support case AI draft, driver support, [automatic insights](https://www.evtivity.com/docs/csms/ai-insights), [background AI workers](https://www.evtivity.com/docs/csms/ai-workers), and the [MCP server](https://www.evtivity.com/docs/integrations/mcp-server). The tab has seven tabs, one per function, in this order: **Providers and Keys**, **Assistant**, **Support Drafts**, **Driver Support**, **Automatic Insights**, **MCP**, and **Usage and Limits**.

Each tab has its own link: `/settings?tab=ai&sub=<id>`, where `<id>` is `providers`, `assistant`, `support`, `driver`, `insights`, `mcp`, or `usage`. An unknown id opens **Providers and Keys**. Each tab starts with a short description of what it does. Each card has its own **Save** button. Rarely used options, such as base URLs, system prompts, and MCP origins, sit under **Advanced Options**. Unsaved changes stay when you switch to another tab.

**Providers and Keys** and every feature tab, from **Assistant** to **MCP**, show this note:

> **Note:**
>
> **What the AI Provider Receives**
>
> The AI provider never receives stored credentials, such as passwords, API keys, secrets and station passwords. Card numbers and IBANs are cut to their last 4 characters. Support drafts, automatic insights, background workers and driver support also mask email addresses and phone numbers, and hash or shorten driver token ids. The assistant sends driver contact details as stored, only to users allowed to read them. Text you type and text files you attach are checked for keys and card numbers. Images and PDFs you attach are sent as they are.

### Providers and Keys

One API key per provider. Every AI feature uses these keys: each feature tab picks one of these providers.

| Provider | Default model |
|----------|---------------|
| Anthropic | claude-sonnet-5-5 |
| OpenAI | gpt-6.1-sol |
| Google Gemini | gemini-3.8-flash |
| DeepSeek | deepseek-flash |

For each provider:

- **API key** - the provider API key, stored encrypted (`ai.<provider>.apiKeyEnc`, for example `ai.anthropic.apiKeyEnc`).
- **Base URL (optional)** - under **Advanced Options**. Leave it blank for the official endpoint (**Default endpoint**). A custom URL must use https and point to a public host (`ai.<provider>.baseUrl`).

The tab warns: "Messages, tool results and attachments are sent to the selected provider and leave this deployment. Check the provider's data retention terms."

![Providers and keys tab](https://www.evtivity.com/screenshots/csms/settings-ai-providers.png)

### Assistant

The **AI Assistant** card configures the chat panel operators open with the AI button or Ctrl+K.

- **Enable the AI assistant** - off by default (`chatbotAi.enabled`). Turns the assistant on or off for everyone. When off, the AI button is hidden and every assistant request is refused, including requests that use a personal configuration.
- **Provider** - one of the providers above (`chatbotAi.provider`, default Anthropic). A provider without an API key cannot answer, and the field shows **This provider has no API key yet.**
- **Model (optional)** - pick one of the known models of the selected provider. The provider's default model is marked **(default)** and is used when the field is blank (`chatbotAi.model`). Choose **Custom model id** to enter a model the list does not have yet. **Where to find model ids** opens the provider's models page. Switching the provider resets a listed model to the new provider's default and keeps a custom id.
- **Effort** - Low, Medium (default), or High (`chatbotAi.effort`). Higher effort gives more thorough answers and uses more tokens.
- **System prompt (optional)** - under **Advanced Options** (`chatbotAi.systemPrompt`). Without a custom prompt, the field shows the built-in prompt for your language, marked **Default** and read-only. Click **Edit** to start a custom prompt from it, and **Reset to default** to go back to the built-in prompt. Saving the built-in prompt unchanged stores no copy, so later improvements to the default still apply. Security rules are always added to the prompt and cannot be changed or removed. Open **Show the rules that are always added** to read them.

![Assistant tab](https://www.evtivity.com/screenshots/csms/settings-ai-assistant.png)

### Support Drafts

The **Support AI** card configures the drafts of replies to support cases, which an operator reviews before sending.

- **Enable support AI** - turns the **AI Draft** button on or off (`supportAi.enabled`, on by default).
- **Provider** - no provider is selected by default (`supportAi.provider`). Select one with an API key before the first draft.
- **Model (optional)**, **Effort**, and **System prompt (optional)** - as on the **Assistant** tab (`supportAi.model`, `supportAi.effort` default Medium, `supportAi.systemPrompt`).
- **Reply tone** - Professional (default), Friendly, or Formal (`supportAi.tone`).

Users can override the provider, key, model, effort, and system prompt of the assistant and of support AI for themselves on the **Chatbot AI** and **Support AI** tabs of their **Profile**. The switches on these tabs still apply to them.

![Support drafts tab](https://www.evtivity.com/screenshots/csms/settings-ai-support.png)

### Driver Support

The **Driver Support** card configures the automatic first answer to a driver support request. The model answers only when the driver allows it, uses the company provider key, and has no tools. The portal and the mobile app offer the AI analysis only while the switch is on and the selected provider has an API key. See [Support Cases](https://www.evtivity.com/docs/csms/support-cases) for the operator view and [Support Cases](https://www.evtivity.com/docs/portal/support-cases) in the portal for the driver flow.

The card warns: "When this is on and a driver allows it, the request text and the driver's own sessions, payments, reservations, used stations and tokens (last 4 characters) are sent to the configured provider."

| Field | Setting key | Default |
|-------|-------------|---------|
| **Offer AI analysis to drivers** | `driverAi.enabled` | Off |
| **Provider** | `driverAi.provider` | Anthropic |
| **Model (optional)** | `driverAi.model` | Blank: the provider's lowest-cost model |
| **Effort** | `driverAi.effort` | Low |
| **System prompt (optional)**, under **Advanced Options** | `driverAi.systemPrompt` | Blank: the built-in prompt |

The **Driver Support Limits** card holds the limits per driver. Requests over a limit go straight to the support team.

| Field | Setting key | Default | Range |
|-------|-------------|---------|-------|
| **AI-analyzed requests per driver per day** | `driverAi.maxCasesPerDriverPerDay` | 3 | 1 to 100 |
| **Wait for the driver's feedback (hours)** | `driverAi.feedbackTimeoutHours` | 24 | 1 to 168 |
| **Tokens per driver per day** | `ai.budget.driverDailyTokens` | 40,000 | 0 to 10,000,000,000 (0 means no limit) |
| **AI requests per driver per minute** | `ai.rateLimit.driverPerMinute` | 2 | 1 to 1,000 |

A request without feedback after the wait time goes to the support team.

The consent notice drivers see before they choose is built in and cannot be edited. Have it reviewed against your privacy obligations before you turn driver support on.

![Driver support tab](https://www.evtivity.com/screenshots/csms/settings-ai-driver.png)

### Automatic Insights

This tab holds five cards. The **Automatic Insights and Workers** card sets the model for automatic insights and background workers. They run without a user and use the company provider key, never a personal configuration.

- **Turn on system-initiated AI** - off by default (`opsAi.enabled`). Automatic insights and background workers run only while it is on. The card warns: "When this is on, operational data is sent to the configured provider automatically, without a user action."
- **Provider** (`opsAi.provider`, default Anthropic), **Model (optional)** (`opsAi.model`; blank uses the provider's lowest-cost model), **Effort** (`opsAi.effort`, default Low), and **System prompt (optional)** under **Advanced Options** (`opsAi.systemPrompt`; blank uses the built-in prompt).

The **Automatic Insights** card holds the insight settings. See [Automatic Insights](https://www.evtivity.com/docs/csms/ai-insights).

| Field | Setting key | Default | Range |
|-------|-------------|---------|-------|
| **Station insights** | `aiInsights.station.enabled` | On | |
| **Session insights** | `aiInsights.session.enabled` | On | |
| **Authorization insights** | `aiInsights.authorization.enabled` | On | |
| **Reservation insights** | `aiInsights.reservation.enabled` | On | |
| **Summary language** | `aiInsights.primaryLanguage` | English | en, de, es, ko, zh, zh-TW |
| **Wait before analyzing (seconds)** | `aiInsights.debounceSeconds` | 120 | 0 to 3,600 |
| **Cooldown per station, session or token (minutes)** | `aiInsights.cooldownMinutes` | 60 | 1 to 10,080 |
| **Stations down at one site that make one site incident** | `aiInsights.siteIncidentThreshold` | 3 | 2 to 1,000 |
| **Insights per site per day** | `aiInsights.maxPerSitePerDay` | 50 | 1 to 10,000 |
| **Close one-off insights after (days)** | `aiInsights.expireAfterDays` | 7 | 1 to 365 |

How long insights are kept is set in [Data Retention](#data-retention).

![Automatic Insights card](https://www.evtivity.com/screenshots/csms/settings-ai-insights-card.png)

**Reservation insights** shows only while reservations are on. While they are off, the card shows **Reservation insights are off while reservations are turned off.** with a **Turn on reservations** link to [Reservation](#reservation).

The **AI Insights Scope** card chooses which sites and stations automatic insights and background workers analyze:

- **All Sites** (default) - every site and station, including ones added later.
- **Selected Sites** - only the sites you turn on in the site list. The list is searchable and scrolls inside the card. Expand a site to see its stations, and turn off single stations of a selected site. A station switch is disabled while its site is not selected. New sites start unselected, and new stations follow their site. Stations without a site are not analyzed in this mode.

Click **Save** to apply the changes. Sites and stations you take out of the scope get no new insights or suggested actions, their open insights are dismissed, and their waiting actions expire. The detail page of each [station](https://www.evtivity.com/docs/csms/stations#details) and [site](https://www.evtivity.com/docs/csms/sites#details) shows whether insights run there and why. **Suppress** is offered only for sites and stations in the scope. Changing the scope needs access to every site and the `settings.system:write` permission. The API is `GET` and `PUT /v1/settings/ai/insights-scope`.

![AI Insights Scope card](https://www.evtivity.com/screenshots/csms/settings-ai-insights-scope.png)

While **Turn on system-initiated AI** is off, the insight, scope and background worker settings are disabled and the tab says so. Turn it on first to change them.

The **Insight Quality** card shows how users rated insights in your sites over the last 30 days. It lists each insight type that has a vote, with the **Helpful** and **Wrong** vote counts and the **Helpful Rate**. With no votes, it shows "No votes in the last 30 days." Each insight type with a **Wrong** vote links to its insights marked wrong, and the **View Insights Marked Wrong** link opens all of them. The notes show in **Marked Wrong** on each insight page. The card needs the `aiInsights:read` permission. See [Feedback](https://www.evtivity.com/docs/csms/ai-insights#feedback).

![Automatic insights tab](https://www.evtivity.com/screenshots/csms/settings-ai-insights.png)

The **Background AI Workers** card holds the scheduled jobs. Their suggestions appear as insights with an action, and nothing runs until an operator confirms it. Workers use the model of the **Automatic Insights and Workers** card. Every job is off by default. See [Background AI Workers](https://www.evtivity.com/docs/csms/ai-workers).

| Field | Setting key | Default | Range |
|-------|-------------|---------|-------|
| **Nightly Network Summary** | `aiWorkers.networkSummary.enabled` | Off | |
| **Stuck Sessions** | `aiWorkers.stuckSessions.enabled` | Off | |
| **Write the rationale with AI** | `aiWorkers.stuckSessions.useModel` | Off | |
| **Tariff Anomalies** | `aiWorkers.tariffAnomalies.enabled` | Off | |
| **Idle time before a session counts as stuck (minutes)** | `aiWorkers.stuckSessions.idleMinutes` | 90 | 15 to 1,440 |
| **Offline time before the AI suggests ending a stuck session in the CSMS (hours)** | `aiWorkers.stuckSessions.offlineEndAfterHours` | 24 | 1 to 720 |
| **Action lifetime (hours)** | `aiWorkers.proposalTtlHours` | 24 | 1 to 168 |

![Background AI workers card](https://www.evtivity.com/screenshots/csms/settings-ai-insights-workers.png)

### MCP

The **MCP Server** card configures the server that lets external AI agents use EVtivity with an API key. See [MCP Server](https://www.evtivity.com/docs/integrations/mcp-server). The card also shows the **Endpoint** URL and the default tool categories. With **Allow Writes** off, MCP clients only read. With it on, write tools (station commands) run at once, with the permissions and sites of the API key, and no confirmation.

| Field | Setting key | Default | Range |
|-------|-------------|---------|-------|
| **Turn on the MCP server** | `ai.mcp.enabled` | Off | |
| **Allow Writes** | `ai.mcp.allowWrites` | Off | |
| **Calls per API key per minute** | `ai.mcp.rateLimitPerMinute` | 60 | 1 to 10,000 |
| **Calls per API key per day** | `ai.mcp.dailyCallsPerKey` | 5,000 | 1 to 10,000,000 |
| **Allowed origins**, under **Advanced Options** | `ai.mcp.allowedOrigins` | Empty | Up to 50 http or https origins without a path, one per line |

![MCP tab](https://www.evtivity.com/screenshots/csms/settings-ai-mcp.png)

### Usage and Limits

The **AI Limits** card holds the rate limits and token budgets of the assistant, support drafts, automatic insights, and background workers, for every provider. The driver limits are on the [Driver support](#driver-support) tab.

| Field | Setting key | Default | Range |
|-------|-------------|---------|-------|
| **Requests per user per minute** | `ai.rateLimit.userPerMinute` | 10 | 1 to 1,000 |
| **Support AI requests per site per minute** | `ai.rateLimit.sitePerMinute` | 60 | 1 to 100,000 |
| **Tokens per user per day** | `ai.budget.userDailyTokens` | 2,000,000 | 0 to 10,000,000,000 (0 means no daily limit) |
| **Tool calls per answer** | `ai.maxToolCallsPerTurn` | 20 | 1 to 100 |
| **Maximum attachment size (bytes)** | `ai.attachments.maxBytes` | 10,485,760 (10 MB) | 1 to 33,554,432 (32 MB) |
| **Attachments per message** | `ai.attachments.maxPerMessage` | 5 | 1 to 20 |
| **Company tokens per month** | `ai.budget.companyMonthlyTokens` | 0 | 0 to 1,000,000,000,000 (0 means no limit) |
| **Tokens per site per month** | `ai.budget.siteMonthlyTokens` | 0 | 0 to 1,000,000,000,000 (0 means no limit) |
| **Tokens per site per day (insights and workers)** | `ai.budget.siteDailyTokens` | 300,000 | 0 to 10,000,000,000 (0 means no limit) |
| **Warn at (% of a budget)** | `ai.budget.warnPercent` | 80 | 1 to 100 |

The maximum attachment size also applies to [support case](https://www.evtivity.com/docs/csms/support-cases) attachments. How long conversations are kept is set in [Data Retention](#data-retention).

Token budgets count input plus output tokens. Daily budgets run on UTC days, monthly budgets on calendar months in the system timezone.

Below the limits, the tab shows the AI tokens of the company, each site, each surface, and the top users for the month you pick in **Month**. The **Sites** list shows 10 sites per page. This part needs the `aiUsage:read` permission and access to every site. See [AI Usage and Budgets](https://www.evtivity.com/docs/csms/ai-usage#usage-and-limits-tab).

![Usage and limits tab](https://www.evtivity.com/screenshots/csms/settings-ai-usage.png)

### AI Alerts

The CSMS shows a banner at the top of every page to users with the `settings.ai:write` permission and access to every site. **Settings > AI** shows the same alerts at its top to everyone who can open it.

- **Out of credit or quota** (red), titled with the provider name, for example **DeepSeek Is Out of Credit or Quota**: the provider refused a request made with the company key because the account is out of credit, over a spend limit, or over its daily quota. The banner says since when. The AI features that use this provider are paused: automatic insights and their translations, background workers, driver support, and support drafts. The assistant keeps trying and shows the `AI_PROVIDER_QUOTA_EXCEEDED` error. Add credit or raise the quota at the provider. While the alert lasts, EVtivity tries one background request every 15 minutes, and the alert clears with the next successful request, so the features resume on their own. **Open AI Settings** opens **Providers and Keys**.
- **AI Budget Warning** (yellow) or **AI Budget Used Up** (red): the company monthly token budget is at or past **Warn at (% of a budget)**, or used up. **View AI Usage** opens **Usage and Limits**.

A rate limit does not raise an alert: it ends by waiting. A personal key from a user's profile belongs to another provider account and never raises it.

The same users also get these alerts as system notifications by email and SMS: **AI Provider Out of Credit or Quota**, **AI Budget Warning**, and **AI Budget Used Up**. See [Notifications](https://www.evtivity.com/docs/csms/notifications). The API returns the active alerts at `GET /v1/ai/alerts`.

## Data Retention

**Permission:** `settings.system:read` / `settings.system:write` and access to every site.

Sets how many days the CSMS keeps each kind of stored data. A prune job deletes older rows at its next run. Without `settings.system:write` the fields are read-only and **Save** is hidden. Changes appear on the **History** tab.

The tab starts with a warning: chaos mode and large networks need large storage. Every OCPP message is a row in `ocpp_message_logs` and every meter reading a row in `meter_values`, so both tables grow with the number of connected stations.

![Data Retention tab](https://www.evtivity.com/screenshots/csms/settings-data-retention.png)

| Card | Field | Setting key | Default | Range |
|------|-------|-------------|---------|-------|
| **Operational Logs** | **OCPP Messages** | `logs.ocppMessage.retentionDays` | 30 | 0 to 3,650 |
| **Operational Logs** | **Meter Values** | `logs.meterValues.retentionDays` | 90 | 0 to 3,650 |
| **Operational Logs** | **Domain Events** | `logs.domainEvents.retentionDays` | 30 | 0 to 3,650 |
| **Operational Logs** | **Access Logs** | `logs.access.retentionDays` | 30 | 0 to 3,650 |
| **Operational Logs** | **Worker Job Logs** | `logs.workerJob.retentionDays` | 30 | 0 to 3,650 |
| **Operational Logs** | **Connector Status History** | `logs.portStatus.retentionDays` | 30 | 0 to 3,650 |
| **Operational Logs** | **Station Connection Log** | `logs.connection.retentionDays` | 90 | 0 to 3,650 |
| **Operational Logs** | **Sent Notifications** | `logs.notifications.retentionDays` | 90 | 0 to 3,650 |
| **Operational Logs** | **Load Management Allocations** | `logs.loadAllocation.retentionDays` | 90 | 0 to 3,650 |
| **Security and Audit** | **Audit History** | `audit.retentionDays` | 1,095 | 0 to 3,650 |
| **Security and Audit** | **Sign-In Records** | `logs.loginAudit.retentionDays` | 90 | 0 to 3,650 |
| **Security and Audit** | **Station Security Events** | `logs.securityEvents.retentionDays` | 365 | 0 to 3,650 |
| **Sign-In Sessions and Tokens** | **Revoked and Expired Sign-In Tokens** | `refreshTokens.retentionDays` | 30 | 0 to 3,650 |
| **AI** | **AI Assistant Conversations** | `ai.conversationRetentionDays` | 30 | 1 to 3,650 |
| **AI** | **Automatic Insights** | `aiInsights.retentionDays` | 90 | 1 to 3,650 |
| **SIM Data** | **SIM Sessions and Alerts** | `sim.sessions.retentionDays` | 90 | 7 to 730 |

A value of 0 keeps the data forever for the settings whose range starts at 0. See [Data Retention](https://www.evtivity.com/docs/configuration/data-retention) for the tables each setting covers and the prune jobs.

## Conformance

See [Conformance Testing](https://www.evtivity.com/docs/csms/conformance-testing) for full documentation on the OCPP conformance test runner embedded in this tab.
