Generated from https://www.evtivity.com/docs/guides/white-labeling (website commit ffa3c26). Do not edit.

# White Labeling

Rebrand the EVtivity CSMS and driver portal with your network's identity - logo, colors, domain, content, and notifications.

## Overview

Network operators run EVtivity as the back end for their public-facing charging brand. White labeling replaces every EVtivity-specific surface a driver or operator sees with your own identity, without forking the codebase.

This guide covers what is configurable, where each setting lives, and the order to apply them in. Everything below is operator-managed through Settings or system configuration - no code changes required.

## License Note

EVtivity is licensed under [BUSL-1.1](https://www.evtivity.com/docs/getting-started/introduction#license). Single-tenant production use is free. Multi-tenant SaaS - offering EVtivity as a hosted service to multiple independent customers - requires a commercial license. Contact evtivity@gmail.com.

White labeling for your own network is single-tenant and falls under the free path.

## What You Can Brand

| Surface | What changes | Where |
|---|---|---|
| Driver portal | Logo, colors, name, footer, favicon, OG image | Settings &rarr; Company Info |
| Operator dashboard | Logo, name, theme color | Settings &rarr; Company Info |
| Email notifications | From-address, sender name, layout, footer | Settings &rarr; Notification |
| SMS notifications | Sender ID, brand prefix in body | Settings &rarr; Notification &rarr; Twilio SMS |
| Station displays | Per-state text on the EVSE screen | Settings &rarr; Integrations & Features &rarr; Messages |
| Legal pages | Privacy Policy, Terms of Service per language | Settings &rarr; Content |
| Analytics | Your own Google Analytics IDs | Settings &rarr; Marketing |
| Domain | Portal URL, API URL, OCPP endpoint | DNS + Helm `gatewayAPI.routes` |

What you CANNOT brand without a commercial license:
- Removing the BUSL license header from source files.
- Re-distributing as a separate product.
- Multi-tenant SaaS (one EVtivity install serving multiple unrelated brands).

## Recommended Order

1. Acquire your domain(s) and TLS certs.
2. Bring the CSMS up under your domain.
3. Set Company branding (logo, name, colors, contact info).
4. Configure SMTP and From address.
5. Configure Twilio (if SMS is in scope).
6. Edit legal content per language.
7. Customize email layout.
8. Set station display messages.
9. Add analytics IDs.
10. Test the driver registration flow end-to-end.

## 1. Domain and TLS

### Portal URL

Set under Settings &rarr; Company Info:

- **Driver Portal URL** - the public URL of your driver portal (e.g., `https://charge.example.com`). The operator login page shows it as a link.

Station QR codes and email links use the portal URL from your deployment configuration (the portal hostname below and the API's `PORTAL_URL` environment variable), not this setting. If you change the portal hostname after stations are deployed, the QR codes will route drivers to the wrong host. Plan domains before printing station signage.

### Helm / Gateway API

For Kubernetes deployments, set hostnames in `values.yaml`:

```yaml
gatewayAPI:
  routes:
    - host: api.example.com
      service: api
    - host: portal.example.com
      service: portal
    - host: csms.example.com
      service: csms
    - host: ocpp.example.com
      service: ocpp
```

For the OCPP TLS endpoint (Mutual TLS stations), set `ocpp.tls.serviceAnnotations` to provision a cloud LoadBalancer and point a separate DNS record at it.

DNS records for all hostnames must point at the Gateway's external IP. The Gateway controller (Istio by default) provisions a single cloud load balancer that serves all hostnames.

## 2. Company Branding

Settings &rarr; Company Info:

| Field | Where it shows |
|---|---|
| Company Name | Email subjects, portal header, dashboard sidebar, receipts |
| Company Logo | Email header, portal login screen, dashboard sidebar |
| QR Code Icon | Center of every station QR code (SVG only) |
| Favicon | Portal browser tab |
| OG Image | Social media link previews |
| Theme Color | Portal primary buttons, accents, links |
| Currency | Currency for all tariffs, Stripe charges, and invoices |
| Prices in the driver portal | Prices shown excluding tax (net) or including tax (gross) in the portal, mobile app, and station screens |
| Contact / Support email | Email footers, support pages |
| Support Phone | Email footers, station faulted-state display |
| Street, City, State, ZIP, Country | Email footers |

Image upload limits: 512 KB per file. SVG recommended for the logo and QR icon (scales without artifacts).

Theme color cascades to the operator dashboard and the driver portal. Pick a hex value (e.g., `#0f7a3e`) and the rest of the UI re-tints automatically.

## 3. Email Notifications

### SMTP

Settings &rarr; Notification &rarr; SMTP Email:

- **Host / Port / Username / Password** - your transactional email provider (SendGrid, Mailgun, AWS SES, etc.)
- **From Address** - the visible sender address. Must be a domain you control with proper SPF/DKIM/DMARC records, or your emails will land in spam.

Use the **Send Test** button to send a probe email before going live.

### Email Layout

Settings &rarr; Notification &rarr; Email Layout:

A single HTML template wraps every outgoing email. Two placeholders are required:

- `{{{content}}}` - triple-stache, the rendered email body
- `{{companyName}}` - your company name

Standard variables also available: `companyContactEmail`, `companySupportEmail`, `companySupportPhone`, `companyStreet`, `companyCity`, `companyState`, `companyZip`, `companyCountry`, `companyCurrency`.

Click any variable pill to copy. The live preview updates as you type. Save commits the new wrapper for all subsequent emails (driver notifications, MFA codes, password resets, scheduled reports).

### Per-event Templates

The Notifications page (separate from Settings &rarr; Notification) has per-event template editors for driver events (session.Started, session.Completed, etc.) and system events (welcome emails, password resets, MFA codes, support cases). Each template supports email and SMS body variants in 6 languages.

The dashboard's WYSIWYG editor produces HTML that renders inside the wrapper from above. **Reset Template** reverts to the file-based template.

## 4. SMS Notifications

Settings &rarr; Notification &rarr; Twilio SMS:

- **Account SID / Auth Token / From Number** - Twilio credentials. The from number must be a Twilio-provisioned phone number your account owns.

Every SMS template starts with `{{companyName}} - ` for brand identification. Edit per-event SMS templates from the Notifications page.

When Twilio is not configured, SMS notifications fall back to log output (no driver delivery) so the rest of the system keeps working.

## 5. Legal Content per Language

Settings &rarr; Content:

Two pages drivers can reach from the portal:

- Privacy Policy
- Terms of Service

Each is a WYSIWYG-edited rich-text page per language. The portal automatically serves the page matching the driver's selected locale, and serves the built-in default text for that language when none is saved. Supported languages: English, German, Spanish, Korean, Simplified Chinese, Traditional Chinese.

Have your legal team draft these before launch. The portal's footer links to them, and most regulators require both for paid charging.

## 6. Station Display Messages

Settings &rarr; Integrations & Features &rarr; Messages (OCPP 2.1 stations only):

Per-state Handlebars templates pushed to the station's display:

| State | Typical content |
|---|---|
| Available | Pricing summary, brand greeting |
| Occupied | "Tap card or open app to start" |
| Reserved | Reservation holder + expiry |
| Charging | Live energy / power / cost / time |
| Suspended | Pause notice + idle fee |
| Discharging | V2G energy back to grid |
| Faulted | Support phone |
| Unavailable | Service status |

Variables available include `companyName`, `stationOcppId`, `pricingDisplay`, `energyPrice`, `timePrice`, `sessionFee`, `idleFee`, `taxRatePercent`, `pricesIncludeTax`, `energyKwh`, `powerKw`, `costFormatted`, `elapsedFormatted`, `idleFeeRate`, `supportPhone`, `driverFirstName`, `reservationExpiresAt`. The variable picker filters by selected state - only relevant variables appear.

Set the **Display Language** on the same tab. Templates exist per state and language, and prices follow the company price display (net or gross) with a tax note you word in the template. See [Station display messages](https://www.evtivity.com/docs/guides/station-display-messages).

Turn on **Enable Station Messages** on the same tab. Stations running OCPP 1.6 get a DataTransfer-based pricing fallback (no per-state messages, vendor-dependent).

## 7. Analytics

Settings &rarr; Marketing:

- **Portal GTAG Measurement ID** - GA4 measurement ID for the driver portal (e.g., `G-XXXXXXXXXX`).
- **CSMS GTAG Measurement ID** - GA4 measurement ID for the operator dashboard.

Both are optional. When set, the corresponding gtag.js loads on page mount. Replace with your own analytics IDs before launch so traffic counts toward your account, not a default.

## 8. Driver-facing Identity

A driver who signs up sees:

- Your logo on the login screen.
- Your company name in the welcome email subject.
- Your support email in the email footer.
- Your privacy policy and terms when signing up.
- Your theme color throughout.
- Your station name on the QR landing page.

Test this end-to-end: register a fresh driver account, verify the welcome email, complete a guest charging session, request a password reset. Every email and screen should carry your brand.

## 9. Currency and Tax

Settings &rarr; Company Info &rarr; Currency sets the one currency for the network. Tariffs, Stripe charges, and invoices all use it. Tariffs do not carry their own currency.

Settings &rarr; Company Info &rarr; **Prices in the driver portal** sets whether drivers see prices excluding tax (net) or including tax (gross) in the portal, the mobile app, and on station screens. Drivers can override it in their account. Operators in the EU and UK usually need gross prices. The setting changes only the display: the amount charged is the same.

Settings &rarr; Payment &rarr; General selects the payment provider (Stripe or Adyen) and sets the default pre-auth amount and platform fee. The Stripe and Adyen tabs carry each provider's keys. Each site can override the Stripe Connect account, the pre-auth amount, and the platform fee via Settings &rarr; Payment &rarr; Site Configurations. This lets a single CSMS instance route revenue to different bank accounts per site - useful when sites are owned by different LLCs under the same network.

Tax rates are tariff-level (Pricing &rarr; pricing group &rarr; tariff). Set the appropriate rate per jurisdiction. Settings &rarr; Company Info &rarr; **Tariff prices are entered** sets whether tariff prices exclude tax (the rate is added when a session is billed) or include it (the tax is taken out). Invoices state the net amount and the tax per rate.

## 10. Going Live Checklist

Before announcing the launch:

- [ ] DNS resolves to the Gateway IP for portal, API, OCPP, dashboard hostnames.
- [ ] TLS certs valid for all hostnames.
- [ ] SPF/DKIM/DMARC pass on the from-address domain.
- [ ] SMTP test email arrives in inbox (not spam).
- [ ] Twilio test SMS arrives.
- [ ] Privacy Policy and Terms of Service drafted in every language you support.
- [ ] Email wrapper preview matches your brand guidelines.
- [ ] Station display messages tested on at least one OCPP 2.1 station.
- [ ] Analytics IDs replaced with yours.
- [ ] A driver can register, charge, and pay end-to-end.
- [ ] An operator user with the right RBAC role can manage stations and view reports.
- [ ] Backup and disaster-recovery plan documented for the database and Redis.

## Related Pages

- [Settings](https://www.evtivity.com/docs/csms/settings) - field-by-field reference for every operator setting
- [Notifications](https://www.evtivity.com/docs/csms/notifications) - notification template editing
- [Portal Setup](https://www.evtivity.com/docs/guides/portal-setup) - driver-facing configuration
- [Helm Chart](https://www.evtivity.com/docs/deployment/helm-chart) - Kubernetes deployment
