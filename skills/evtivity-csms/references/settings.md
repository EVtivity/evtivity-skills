Generated from https://www.evtivity.com/docs/csms/settings (website commit ffa3c26). Do not edit.

# Settings

Configure company info, marketing, content, notifications, sustainability, payments, integrations, security, API keys, firmware, station configurations, smart charging, and AI.

## Overview

The Settings page contains all system-wide configuration organized into tabs. Each tab requires a specific permission to view and edit. The Settings nav item is hidden when a user has no settings permissions.

![Settings page](https://www.evtivity.com/screenshots/csms/settings.png)

## Company Info

**Permission:** `settings.system:read` / `settings.system:write`

Company branding, contact information, and SEO configuration.

**Branding:**

- **Logo** - upload or remove a logo image (max 512 KB). Displayed in emails and portal branding.
- **QR Code Icon** - upload an SVG icon that appears in the center of station QR codes. Includes a live QR preview.
- **Favicon** - upload a custom favicon image for the portal (max 512 KB).
- **Social Share Image** - upload an Open Graph image for social media link previews (max 512 KB).

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
- **Street Address, City, State / Province, ZIP / Postal Code, Country** - company address used in email footers. Enter **Country** as a two-letter ISO code, for example `US`. The Adyen card forms need it.
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

Card payment configuration with four sub-tabs: General, Stripe, Adyen, and Site Configurations. The tab opens on General. Saving a provider's keys does not select it: select the provider on the General tab. See [Payment Providers](https://www.evtivity.com/docs/integrations/payment-providers) for the providers and how the active one is chosen.

![Payment settings, General tab](https://www.evtivity.com/screenshots/csms/settings-payment-general.png)

### General

- **Provider for New Payments** - None (payments off), Stripe, Adyen, or Test provider. Payments already made keep the provider that made them. A provider without credentials shows "(credentials missing)", and Adyen shows "(upgrade in progress)" while an older process is connected. The test provider is listed only where it is enabled.
- **Providers** - each provider with its badge: Selected, Ready, Not configured, or Upgrade pending.
- With None selected, a warning says that payments are off: sessions start without a pre-authorization and guests charge without paying.
- **Upgrade pending** panel - appears for Adyen while a process older than v0.1.38 is connected. It shows the open connections from older processes, their hosts, when an older process was last seen, and when the worker last checked. Adyen can be selected once no older process has connected for 10 minutes. See [Select Adyen](https://www.evtivity.com/docs/integrations/adyen#9-select-adyen).
- **Default Pre-Auth Amount** - hold placed on a card before charging starts, entered in the company currency (0.01 to 10,000.00, default 50.00). A site configuration can override it. Setting `payments.preAuthAmountCents`.
- **Platform Fee %** - share of each payment kept from a site host payout account (0-100%). The fee is a percent of the net amount charged, tax excluded, and is set when the payment is captured, not on the pre-authorization hold. A site configuration can override it. Setting `payments.platformFeePercent`.
- **Test Provider** card - shown where the test provider is enabled. "Test mode. No real money moves."
  - **Result Mode** - **Synchronous** returns each result in the API response. **Asynchronous** answers captures, cancels, and refunds as pending and confirms them through the webhook pipeline after the delay, as Adyen does.
  - **Async Result Delay (seconds)** - delay of asynchronous results, 0 to 3600.
  - **Random Failure Rate** - share of payments that fail for cards without a test scenario, 0 to 1.

Save sends only the changed fields. When the selection is refused with 409 `PAYMENT_PROVIDER_UPGRADE_PENDING`, the previous provider stays selected and the panel shows the details.

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

Adyen configuration. Select Adyen on the General tab only after every process runs v0.1.38 or later. Until then the selection is refused, and the General tab shows why. You can save the settings, test the connection, and create the webhook before that. Step-by-step setup and selection: [Adyen](https://www.evtivity.com/docs/integrations/adyen).

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

Feature toggles and third-party service configuration with 15 sub-tabs.

### OCPP

Default OCPP configuration values sent to stations during provisioning.

- **Meter value interval (seconds)** - seconds between meter value reports (default 60).
- **Clock-aligned interval (seconds)** - seconds for clock-aligned meter values (default 900).
- **Sampled measurands** - comma-separated list of measurands for sampled meter values (default: `Energy.Active.Import.Register,Power.Active.Import,Voltage,Temperature,SoC,Current.Import`).
- **Clock-aligned measurands** - comma-separated list of measurands for clock-aligned meter values.
- **Transaction ended measurands** - measurands captured at transaction end.
- **Heartbeat interval (seconds)** - seconds between station heartbeats (default 300).
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
- **Create contract CA** button - creates the local contract CA once (Local provider). See [Certificates](https://www.evtivity.com/docs/csms/certificates#local-contract-ca).
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
- **Cancellation Window (minutes)** - minutes within which cancellation is free (default 5).
- **Cancellation Fee** - amount excluding tax, in the company currency, charged for a cancellation inside the cancellation window (default 0). The tax rate of the station's tariff is added when the fee is charged.

### Support

Support cases feature toggle.

- **Enable Support** - toggle for the support case system. When disabled, support nav items and endpoints are hidden.

### Fleet

Fleet management feature toggle.

- **Enable Fleet** - toggle for fleet management. When disabled, fleet nav items and endpoints are hidden.

### Guest Charging

Guest charging feature toggle.

- **Enable Guest Charging** - toggle for guest (unauthenticated) charging via the portal. When disabled, the guest checkout flow is hidden.

### Idling

Idle fee configuration.

- **Grace period (minutes)** - minutes of idle time before idle fees start accruing (default 30).

### Session

Session lifecycle settings.

- **Stale session timeout (hours)** - hours after which an inactive session is marked as stale and cleaned up (default 24). A stale session is marked faulted and not billed: its cost is set to 0 and its payment hold is released. A session replaced by a new transaction on the same EVSE, or one the station no longer knows when an operator stops it, is not stale: it is completed and billed at its last metered energy, and the driver gets the receipt.

### Pricing

Billing settings.

- **Split Billing** - toggle for per-segment billing when tariffs change during a session.

The previous **Display Format** and **Push Display Enabled** settings have moved to the Messages tab and are now `stationMessage.pricingFormat` and `stationMessage.enabled`.

### Messages

Station display message configuration. Drives the all-state push pipeline that writes context-aware text to OCPP 2.1 station displays as the connector and transaction state changes.

- **Enable Station Messages** - master toggle (`stationMessage.enabled`). When on, the CSMS pushes per-state messages to every connected OCPP 2.1 station: Available, Occupied, Reserved, Charging, Suspended, Discharging, Faulted, and Unavailable.
- **Pricing Format** - `compact` or `standard` (`stationMessage.pricingFormat`). Controls the format of the `{{pricingDisplay}}` variable inside the Available template.
- **Charging Refresh Interval (seconds)** - per-station refresh threshold for the Charging template during an active session (`stationMessage.charging.refreshSeconds`, default 30). The cron handler ticks every 30 seconds and skips stations whose Charging slot was pushed within this window. Lower values increase OCPP traffic and risk display flicker on slow stations.
- **Brand Line** - optional first line shown on every state (`stationMessage.brandLine`, the `{{brandLine}}` variable). Empty falls back to the company name.
- **Display Language** - default language of the station screens (`stationMessage.language`, default `en`): English, German, Spanish, Korean, Simplified Chinese, or Traditional Chinese. It picks the template language and formats prices, numbers, the tax rate, times, and the elapsed charging time. A site can set its own language on its Details tab ([Sites](https://www.evtivity.com/docs/csms/sites)).

Saving these settings, a state template, or the company name, support phone, currency, price display, or tax basis updates the screens of every online station within a few seconds. Screens whose text did not change are not sent again.

The Messages tab also includes a per-state template editor. Each state has a template per language, chosen with **Template Language** (defaults to the display language). Each of the eight state templates is a Handlebars body with a click-to-insert variable picker filtered by state (e.g., `{{energyKwh}}`, `{{powerKw}}`, `{{costFormatted}}` show up only for Charging, Suspended, and Discharging). A live preview renders the compiled template with sample values in the company currency, the price display, and the chosen language. Save persists to the `station_message_templates` table. Reset reverts that language's template to the default.

OCPP 1.6 stations have no native equivalent. They receive the Idle screen (Available, Occupied, Reserved) as a vendor `DataTransfer`.

### S3 Bucket

Amazon S3 (or S3-compatible) object storage for file attachments and station images.

- **Bucket Name** - S3 bucket name.
- **Region** - AWS region (e.g., `us-east-1`).
- **Access Key ID** - IAM access key ID (stored encrypted).
- **Secret Access Key** - IAM secret access key (stored encrypted).
- **Test Connection** button - verifies S3 bucket access.

Leave both access key fields blank to use the default AWS credential chain. On AWS, that is the task or instance role. If you fill in only one of the two fields, S3 stays disabled until you fill in both or clear both.

Includes expandable sections showing the recommended IAM policy and CORS configuration.

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

Security settings with three sub-tabs.

### reCAPTCHA

Google reCAPTCHA v3 bot protection for login pages.

- **Enable reCAPTCHA v3** - toggle for reCAPTCHA on login forms.
- **Site Key** - reCAPTCHA v3 site key.
- **Secret Key** - reCAPTCHA v3 secret key (stored encrypted). Shows `********` when already configured.
- **Score Threshold** - minimum score to pass (0-1, default 0.5). Higher values are stricter.

When enabled, login pages require a passing reCAPTCHA score before authenticating.

### MFA

Multi-factor authentication methods available system-wide. Enabling a method makes it available for users and drivers to activate on their profiles. It does not force MFA on anyone.

- **Email Code** - toggle for email-based verification codes. Disabled when SMTP is not configured (shows a warning hint).
- **Authenticator App (TOTP)** - toggle for authenticator app codes (Google Authenticator, Authy, etc.).
- **SMS Code** - toggle for SMS-based verification codes. Disabled when Twilio is not configured (shows a warning hint).

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

API keys inherit the creating user's site access at request time. Revoking a key is permanent.

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

AI assistant configuration with two sections.

### Chatbot AI

System-wide configuration for the operator chatbot assistant.

- **Enable Chatbot AI** - toggle for the chatbot feature.
- **Default Provider** - select between Anthropic, OpenAI, or Gemini.
- **API Key** - provider API key (stored encrypted). Shows `********` when already configured.
- **Default Model (optional)** - model name override (blank uses the provider default).
- **Temperature** - generation randomness (0-2, lower is more deterministic).
- **Top P** - nucleus sampling threshold (0-1).
- **Top K** - top-K token selection limit (1-100).
- **System Prompt** - custom instructions for the AI assistant (blank uses the built-in default).

### Support AI

Separate configuration for AI-powered support case reply drafting.

- **Enable Support AI** - toggle for support AI.
- **Provider** - select between Anthropic, OpenAI, or Gemini.
- **API Key** - provider API key (stored encrypted).
- **Model** - model name override.
- **Temperature** - generation randomness (0-2).
- **Top P** - nucleus sampling threshold (0-1).
- **Top K** - top-K token selection limit (1-100).
- **Reply Tone** - reply tone: Professional, Friendly, or Formal.
- **System Prompt** - custom instructions for support AI drafting.

## Conformance

See [Conformance Testing](https://www.evtivity.com/docs/csms/conformance-testing) for full documentation on the OCPP conformance test runner embedded in this tab.
