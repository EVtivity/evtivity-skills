Generated from https://www.evtivity.com/docs/csms/notifications. Do not edit.

# Notifications

Configure notification templates, channels, and delivery settings for OCPP, driver, and system events.

## Overview

The notification system dispatches messages to operators and drivers via email, SMS, and webhooks. You configure which events trigger notifications, customize message templates with a WYSIWYG editor, and review delivery history. The notification page has four tabs: Driver Events, System Events, OCPP Events, and History.

![Notifications](https://www.evtivity.com/screenshots/csms/notifications.png)

## Driver Events

Driver events are notifications sent to drivers about their sessions, account, payments, reservations, invoices, support cases, tokens, maintenance, station watches, and prepaid cards. You turn each event type on or off with its **Active** switch. When an event type is on, each driver's notification preferences apply. You customize the message template for each event type.

The **Driver Events** tab groups them:

- **Sessions**: `session.Started`, `session.Updated`, `session.Completed`, `session.Faulted`, `session.PaymentReceived`, `session.IdlingStarted`, `session.Receipt`
- **Driver Account**: `driver.Welcome`, `driver.ForgotPassword`, `driver.PasswordChanged`, `driver.AccountVerification`, `driver.MfaDisabled`, `driver.PortalInvite`
- **Payments**: `payment.Complete`, `payment.Refunded`, `payment.FeeRefunded`, `payment.PreAuthFailed`, `payment.CaptureFailed`, `payment.MissingPaymentMethod`, `payment.AccountCreditLimit`
- **Reservations**: `reservation.Created`, `reservation.Cancelled`, `reservation.CancelledForMaintenance`, `reservation.Expiring`, `reservation.Expired`, `reservation.StationFaulted`
- **Invoice Events**: `invoice.Sent`, `invoice.CreditNote`
- **Support Cases**: `supportCase.Created`, `supportCase.OperatorReply`, `supportCase.Resolved`
- **Multi-Factor Auth**: `mfa.VerificationCode`
- **Tokens**: `token.Added`, `token.Removed`, `token.Deactivated`, `token.Reactivated`
- **Maintenance**: `maintenance.SessionStopped`
- **Station Watch**: `watch.StationAvailable`
- **Prepaid Cards**: `prepaid.LowCredit`, `prepaid.CreditExhausted` (see [Prepaid Cards](https://www.evtivity.com/docs/csms/tokens#prepaid-cards))

`session.IdlingStarted` goes out once per idle period, when the EV has been idle for at least 60 seconds, on OCPP 1.6 and 2.1 alike. A shorter pause, such as an EV that reports full and ends the session a moment later, sends no idling notification. Idle fees follow the idling grace period in Settings.

These event types are always on, because drivers need them to get into their account: `driver.ForgotPassword`, `driver.AccountVerification`, `driver.PortalInvite` and `mfa.VerificationCode`. Their switch is locked on, and they are sent even when the driver turned a channel off. The API refuses to turn one off with the error code `NOTIFICATION_EVENT_REQUIRED`.

![Driver event with a locked Active switch](https://www.evtivity.com/screenshots/csms/notifications-driver-event-detail.png)

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

System events are notifications sent to operators and site hosts. They are always on and have no switch. You customize the template for each event type.

The **System Events** tab groups them:

- **Operator Events**: `operator.UserCreated`, `operator.ForgotPassword`, `operator.PasswordChanged`
- **Support Cases**: `supportCase.NewCaseFromDriver`, `supportCase.DriverReply`
- **Session Alerts**: `session.EndRequestFailed`
- **Site Hosts**: `site.PayoutOnboarding` (email only)
- **Fleet Billing Alerts**: `fleet.CreditLimitWarning`, `fleet.CreditLimitReached`, `fleet.InvoiceRunFailed`
- **Fleet Invoices**: `invoice.FleetInvoice`, `invoice.FleetCreditNote`, `invoice.FleetOverdue` (email only)

The **Fleet Billing Alerts** go to a fleet's billing contacts when the open amount on account reaches the warning percent of the fleet's credit limit (`fleet.CreditLimitWarning`) or the limit (`fleet.CreditLimitReached`), each once per month. The reached alert also goes to every active operator with the `fleets:write` permission, and so does the warning while the fleet has no billing contact. See [Credit Limit](https://www.evtivity.com/docs/csms/fleets#credit-limit).

The **Fleet Invoices** emails go to a fleet's billing contacts with the PDF attached: `invoice.FleetInvoice` when a fleet invoice is issued or sent again, `invoice.FleetCreditNote` when it is credited. See [Fleet Invoice](https://www.evtivity.com/docs/csms/fleets#fleet-invoice).

`fleet.InvoiceRunFailed` goes to every active operator with the `payments:write` permission once per month and lists the fleets the monthly run could not invoice or email. `invoice.FleetOverdue` reminds the billing contacts once, with the PDF attached, when an issued fleet invoice passes its due date unpaid. See [Monthly Run](https://www.evtivity.com/docs/csms/fleets#monthly-run).

The **Session End Failed** alert, in the **Session Alerts** group, goes to every active operator with the `sessions:write` permission and access to the session's site when the CSMS gives up ending a session after repeated failed end requests. It names the session and the station, so you can search the session ID on the Sessions page and bill the session. See [Billing a Session the CSMS Could Not End](https://www.evtivity.com/docs/csms/sessions#billing-a-session-the-csms-could-not-end). Each operator receives it in their language and time zone, and the SMS opt-out on their Profile page applies.

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

OCPP events cover station connectivity, status changes, transaction events, meter values, firmware updates, certificate events, and more. The list groups them as **Common (1.6 and 2.1)**, **OCPP 1.6 Only** and **OCPP 2.1 Only**.

- **Common (1.6 and 2.1)**: `station.Connected`, `station.Disconnected`, `ocpp.Authorize`, `ocpp.BootNotification`, `ocpp.DataTransfer`, `ocpp.FirmwareStatusNotification`, `ocpp.Heartbeat`, `ocpp.MessageLog`, `ocpp.MeterValues`, `ocpp.StatusNotification`, `ocpp.TransactionEvent`
- **OCPP 1.6 Only**: `ocpp.DiagnosticsStatus`
- **OCPP 2.1 Only**: `ocpp.BatterySwap`, `ocpp.ClearedChargingLimit`, `ocpp.Get15118EVCertificate`, `ocpp.GetCertificateChainStatus`, `ocpp.GetCertificateStatus`, `ocpp.LogStatusNotification`, `ocpp.NotifyAllowedEnergyTransfer`, `ocpp.NotifyChargingLimit`, `ocpp.NotifyCustomerInformation`, `ocpp.NotifyDERAlarm`, `ocpp.NotifyDERStartStop`, `ocpp.NotifyDisplayMessages`, `ocpp.NotifyEVChargingNeeds`, `ocpp.NotifyEVChargingSchedule`, `ocpp.NotifyEvent`, `ocpp.NotifyMonitoringReport`, `ocpp.NotifyPeriodicEventStream`, `ocpp.NotifyPriorityCharging`, `ocpp.NotifyReport`, `ocpp.NotifySettlement`, `ocpp.PublishFirmwareStatusNotification`, `ocpp.PullDynamicScheduleUpdate`, `ocpp.ReportChargingProfiles`, `ocpp.ReportDERControl`, `ocpp.ReservationStatusUpdate`, `ocpp.SecurityEventNotification`, `ocpp.SignCertificate`, `ocpp.VatNumberValidation`

Every OCPP event is off until you enable it. `ocpp.MessageLog` fires for every OCPP message the CSMS logs, in both directions, so enable it only for a short investigation.

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

Drivers control their own notification preferences from the portal's Account page. They can independently enable or disable email and SMS channels. When a driver disables a channel, notifications for that channel are skipped even if the event type is enabled system-wide. The always-on event types listed under Driver Events are sent anyway.

## Operator Notification Preferences

Operators can opt out of SMS notifications from their Profile page. The `smsEnabled` preference defaults to true (opt-out model). Operators must set their phone number in Profile to receive SMS notifications.

## Template Resolution

When sending a notification, the system resolves the template in priority order:

1. **Settings-level HTML override** - Custom HTML stored in the OCPP event settings row.
2. **Database template** - Custom template saved via the template editor.
3. **File template** - Default Handlebars `.hbs` template file. Falls back from the requested language to English.

All SMS templates start with a `{{companyName}} -` prefix for brand identification.
