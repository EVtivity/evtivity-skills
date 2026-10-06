Generated from https://www.evtivity.com/docs/guides/notifications (website commit 257c8b8). Do not edit.

# Notifications

Event categories, delivery channels, templates, and configuration for EVtivity notifications.

## Event Categories

EVtivity has three categories of notification events, each with its own settings table and enable toggles.

### OCPP Events (41 types)

Station-level events from OCPP messages. Delivered via email and webhook.

Examples: `BootNotification`, `StatusNotification`, `FirmwareStatusNotification`, `SecurityEventNotification`.

### Driver Events (5 types)

Events relevant to EV drivers. Delivered via email and SMS.

Examples: session started, session completed, session failed, idle fee warning, payment receipt.

### System Events (19 types)

Operational alerts for CSMS administrators. Delivered via email and SMS.

Examples: station offline, certificate expiring, payment failure, low balance, scheduled maintenance.

## Delivery Channels

| Channel | Transport | Use Case |
|---|---|---|
| Email | SMTP via nodemailer | All event categories |
| SMS | Twilio | Driver and system events |
| Webhook | POST JSON | OCPP events for external integrations |
| Log | Pino logger | Fallback when no channel is configured |

## Template System

Templates resolve through a three-tier hierarchy:

1. **Settings HTML override** - Custom HTML entered in the notification settings UI. Highest priority.
2. **Database templates** - Templates stored in the database, editable via the template editor.
3. **File templates** - Default `.hbs` (Handlebars) templates shipped with the application.

### Languages

Templates support six languages: English (`en`), German (`de`), Spanish (`es`), Korean (`ko`), Simplified Chinese (`zh`), and Traditional Chinese (`zh-TW`). The system falls back to English if a translation is missing.

### Template Editor

The CSMS includes a WYSIWYG template editor. Click any template variable to insert it at the cursor position. Preview the rendered output before saving.

Available variables depend on the event type. Common variables include:

```bash
{{firstName}}
{{lastName}}
{{siteName}}
{{stationId}}
{{transactionId}}
{{energyDeliveredWh}}
{{costFormatted}}
{{companyName}}
```

### Money in templates

Money variables are formatted in the recipient's language and the record's currency, for example `$12.50` in English or `12,50 €` in German. The raw cents and currency stay available for custom templates.

| Event | Formatted variable | Raw variables |
|---|---|---|
| `session.Updated`, `session.Completed`, `session.Receipt` | `costFormatted` (includes tax) | `currentCostCents` or `finalCostCents`, `currency` |
| `session.PaymentReceived`, `payment.Complete`, `payment.Refunded`, `payment.FeeRefunded` | `amountFormatted` | `amountCents`, `currency` |
| `payment.CaptureFailed` | `amountFormatted` | |
| `session.IdlingStarted` | `idleFeeFormatted`, `taxRatePercent` | `idleFeePricePerMinute`, `currency` |
| `reservation.Cancelled` | `cancellationFeeFormatted` (includes tax, empty without a fee) | `cancellationFeeCents`, `currency` |
| `invoice.Sent` | `total` | `totalCents`, `currency` |

Session costs always include tax. `costIncludesTax` is true when a tariff tax rate applied, and the default templates add "incl. tax" only inside `{{#if costIncludesTax}}`. In `session.IdlingStarted`, `idleFeeFormatted` shows the idle fee as the recipient sees prices (with or without tax, see [Settings](https://www.evtivity.com/docs/csms/settings)), and `idleFeeIncludesTax` says which. Test fee text with `{{#if idleFeeFormatted}}`.

### Email Wrapper

A configurable HTML layout wraps all outgoing emails. Set it once in Settings to apply consistent branding (header, footer, colors) across every email notification.

## Notification Preferences

### Per-Driver Preferences

Drivers control their notification preferences from the portal Account page. They can toggle email and SMS independently for each driver event type.

### Per-Operator SMS Opt-Out

Operators can opt out of SMS notifications from their Profile page. When disabled, SMS delivery is skipped for routine system events like password-change confirmations and user-creation invites. Security-critical MFA verification codes continue to send via SMS regardless of the opt-out setting, so an operator who enrolled in SMS MFA never gets locked out by their own preference.

## Configuration

### SMTP Settings

Configure in the Settings page:

- Host, port, encryption (TLS/STARTTLS)
- Authentication credentials
- From address and display name

### Twilio Settings

Configure in the Settings page:

- Account SID and Auth Token
- From phone number
- Message service SID (optional)
