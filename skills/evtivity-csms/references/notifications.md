Generated from https://www.evtivity.com/docs/csms/notifications (website commit 257c8b8). Do not edit.

# Notifications

Configure notification templates, channels, and delivery settings for OCPP, driver, and system events.

## Overview

The notification system dispatches messages to operators and drivers via email, SMS, and webhooks. You configure which events trigger notifications, customize message templates with a WYSIWYG editor, and review delivery history. The notification page has four tabs: Driver Events, System Events, OCPP Events, and History.

![Notifications](https://www.evtivity.com/screenshots/csms/notifications.png)

## Driver Events

Driver events are notifications sent to drivers about their charging sessions. These are always enabled (no per-event toggle). You customize the message template for each event type.

Available driver event types:

| Event | Description |
|-------|-------------|
| session.Started | Charging session has begun |
| session.Updated | Session updated with new meter values |
| session.Completed | Charging session finished |
| session.PaymentReceived | Payment captured for a session |
| session.IdlingStarted | Vehicle stopped charging but remains plugged in |

Channels: email and SMS.

### Editing a Template

1. Select an event type from the list.
2. The template editor opens in the right panel.
3. For email: edit the subject line and body using the WYSIWYG editor. Toggle to source mode for raw HTML editing.
4. For SMS: edit the plain text message. A character counter shows the count against the 160-character limit.
5. Use the variable panel to insert template variables. Click a variable to insert it at the cursor position, or drag and drop it into the editor.
6. Click **Save** to store the custom template.
7. Click **Reset Template** to revert to the default file-based template.

Template variables use Handlebars syntax (e.g., `{{firstName}}`, `{{stationId}}`, `{{costFormatted}}`). Available variables are shown in the click-to-insert panel and vary by event type. Money variables such as `costFormatted` and `amountFormatted` are formatted in the recipient's language and the record's currency. See [Notifications](https://www.evtivity.com/docs/guides/notifications) for the full list.

## System Events

System events are notifications for operator-facing and account-related events. Like driver events, these are always enabled. You customize the template for each event type.

Available system event types include:

- Driver account events (welcome, password reset, verification)
- Payment events (complete, refunded, pre-auth failed, capture failed)
- Reservation events (created, cancelled, expiring, expired)
- Support case events (created, operator reply, resolved)
- Session receipt
- MFA verification code

Channels: email and SMS.

![System events](https://www.evtivity.com/screenshots/csms/notifications-system-events-tab.png)

## OCPP Events

OCPP events are station-level notifications triggered by OCPP protocol messages. Each event type can be independently toggled on or off per channel. When an event type has no row in the settings table, it is inactive.

To enable an OCPP event notification:

1. Select an event type from the list.
2. Toggle the channel (email or webhook) to active.
3. Enter the recipient email address or webhook URL. The API validates the format against the channel and returns a `400 VALIDATION_ERROR` if the address doesn't look like a real email (for the email channel) or a real `http(s)://` URL (for the webhook channel), so misconfigured recipients fail at save time instead of silently at dispatch time.
4. Optionally customize the HTML template.
5. Click **Save**.

To disable, toggle the channel to inactive. This removes the settings row and stops notifications for that event type and channel.

There are 41 OCPP event types covering station connectivity, status changes, transaction events, meter values, firmware updates, certificate events, and more. Events are categorized as Common (1.6/2.1) and OCPP 2.1 Only.

Channels: email and webhook.

![OCPP events](https://www.evtivity.com/screenshots/csms/notifications-ocpp-events-tab.png)

## History

The History tab shows a log of all sent notifications with three sub-tabs:

- **Email** - Sent email notifications with delivery status.
- **SMS** - Sent SMS notifications with delivery status.
- **Push** - Push notifications sent to the portal.

Each sub-tab supports filtering by category, event type, and delivery status.

The dispatcher writes a history row for every dispatch attempt, including the ones it has to skip. When the row's status is `failed`, the Email and SMS tabs show a short reason below the badge so you can tell at a glance whether the issue is the configuration, the recipient, or the upstream provider:

| Reason | What it means |
|--------|----------------|
| No address on file | The driver or recipient has no email/phone configured. Update the driver profile or the system recipient. |
| SMTP not configured | The SMTP host or credentials in **Settings > Notification > SMTP Email** are missing. |
| Twilio not configured | The Twilio account SID or token in **Settings > Notification > Twilio SMS** is missing. |
| Credentials decrypt failed | The encrypted SMTP password or Twilio token couldn't be decrypted. Most often a `SETTINGS_ENCRYPTION_KEY` mismatch. |
| SMTP send failed | The SMTP server returned an error (auth, DNS, TLS, etc.). |
| Twilio send failed | Twilio rejected the request (invalid number, suspended account, etc.). |
| Webhook blocked (private URL) | The webhook URL resolves to a private/internal address and was refused for SSRF safety. Configure a public endpoint. |
| Webhook returned non-2xx | The configured webhook URL returned an HTTP error. Check the receiver's logs. |
| Webhook network error | DNS, TCP, or TLS failure reaching the webhook URL. Verify the host is reachable. |
| Webhook timed out | The webhook didn't respond within 10 seconds. Investigate the receiver's latency. |
| Webhook delivery failed | Legacy catch-all for older rows. New failures use one of the four specific reasons above. |

![Notification history](https://www.evtivity.com/screenshots/csms/notifications-history-tab.png)

## Email Wrapper Template

All outgoing emails are wrapped in a configurable HTML layout. Edit the wrapper in **Settings > Notification > Email Layout**. The wrapper uses two placeholders:

- `{{{content}}}` - The email body (triple braces for unescaped HTML).
- `{{companyName}}` - Your company name from settings.

The wrapper applies to all email channels: driver notifications, system notifications, OCPP notifications, template previews, forgot-password emails, and scheduled reports.

If you save a wrapper with a Handlebars syntax error, the dispatcher logs a warning and falls back to the built-in default wrapper so mail keeps flowing. Notification rows still record `status: sent` for those deliveries, but the body uses the default layout. Fix the wrapper to restore your branding.

## Driver Notification Preferences

Drivers control their own notification preferences from the portal's Account page. They can independently enable or disable email and SMS channels. When a driver disables a channel, notifications for that channel are skipped even if the event type is enabled system-wide.

## Operator Notification Preferences

Operators can opt out of SMS notifications from their Profile page. The `smsEnabled` preference defaults to true (opt-out model). Operators must set their phone number in Profile to receive SMS notifications.

## Template Resolution

When sending a notification, the system resolves the template in priority order:

1. **Settings-level HTML override** - Custom HTML stored in the OCPP event settings row.
2. **Database template** - Custom template saved via the template editor.
3. **File template** - Default Handlebars `.hbs` template file. Falls back from the requested language to English.

All SMS templates start with a `{{companyName}} -` prefix for brand identification.
