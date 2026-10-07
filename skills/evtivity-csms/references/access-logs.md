Generated from https://www.evtivity.com/docs/csms/access-logs (website commit 4cd1866). Do not edit.

# Access Logs

View the audit trail of CSMS user, driver portal, API client, and background worker activity.

## Overview

The Access Logs page captures every authenticated request and background job run across the platform. Four tabs split the data by source so you can investigate one surface at a time without sifting through unrelated traffic.

![Access logs](https://www.evtivity.com/screenshots/csms/access-logs.png)

## Tabs

- **CSMS** &mdash; operator dashboard requests authenticated with a session cookie.
- **Portal** &mdash; driver portal requests authenticated with a driver session cookie.
- **API** &mdash; all `/v1/*` requests, including both session-authenticated and API-key-authenticated calls. Use the Method and Status filters to narrow results.
- **Workers** &mdash; background job runs from the BullMQ worker. Filter by queue (`cron-jobs`, `load-management`, `guest-session-events`) or status (`started`, `completed`, `failed`).

Server-sent event streams (`/v1/events/stream`) are excluded so long-lived connections don't flood the table.

## Log Fields

Each row records timestamp, user (or API key name on the API tab), action or path, HTTP method and status (API tab), and duration. Click a row to expand the request IP address, user agent, and request body when one was captured.

The Workers tab shows job name, queue, start time, duration, and the full error stack when a job failed.

## Sensitive Data

The notification dispatcher redacts sensitive content before persisting it to the notification history. Six-digit verification codes and `token`, `code`, `verifyToken`, `verificationToken`, `magicToken`, `resetToken`, and `otp` query parameters are replaced with `<redacted>` in:

- `mfa.*` events (TOTP setup confirmations, SMS and email verification codes)
- `driver.ForgotPassword` and `operator.ForgotPassword` (reset links)
- `driver.AccountVerification` (email verification links)
- `driver.Welcome` (initial verification link)

The redaction applies to both subject and body fields. Other operator emails and audit log entries are unaffected.

## Retention

Each log table has its own retention setting so noisy operational tables can stay short while security-critical history is preserved longer.

| Setting | Default | Table |
| --- | --- | --- |
| `logs.access.retentionDays` | 30 | Access logs (CSMS, Portal, API tabs) |
| `logs.ocppMessage.retentionDays` | 30 | OCPP message log |
| `logs.connection.retentionDays` | 90 | Connection log |
| `logs.notifications.retentionDays` | 90 | Notification history |
| `logs.securityEvents.retentionDays` | 365 | Security events |
| `logs.portStatus.retentionDays` | 30 | Connector status history |
| `logs.workerJob.retentionDays` | 30 | Worker job logs (Workers tab) |

A daily cron job named `log-retention-prune` runs at 03:30 UTC and removes rows older than each setting's cutoff in 1000-row batches so a large prune does not hold an exclusive lock. Set any value to 0 to disable pruning for that table.

The audit log family (per-entity History tabs and the global Audit page) is governed separately by `audit.retentionDays`. See [Audit Logs](https://www.evtivity.com/docs/guides/audit-logs) for details.

## API Access

`GET /v1/access-logs` returns the same data the CSMS, Portal, and API tabs render. `GET /v1/worker-logs` powers the Workers tab. Both require the `logs:read` permission. See the [API reference](https://www.evtivity.com/api-reference/access-logs) for query parameters.
