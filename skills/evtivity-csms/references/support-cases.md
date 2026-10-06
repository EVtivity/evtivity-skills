Generated from https://www.evtivity.com/docs/csms/support-cases (website commit 900fb20). Do not edit.

# Support Cases

Handle driver support requests with threaded messages, attachments, linked sessions, and refunds.

## Overview

Support cases provide a ticketing system for resolving driver issues. Operators create and manage cases from the CSMS. Drivers create cases from the portal. Each case has a threaded message history, file attachments, linked charging sessions, and the ability to issue per-session refunds.

![Support cases list](https://www.evtivity.com/screenshots/csms/support-cases-list.png)

## Create a Support Case

1. Navigate to **Support Cases** in the sidebar.
2. Click **Create Case**.
3. Select a category and priority, and optionally a driver and an operator under **Assigned To**.
4. Enter a subject and description.
5. Optionally link one or more charging sessions.
6. Click **Create**.

The system generates a case number (e.g., CASE-00001) from a PostgreSQL sequence.

Drivers can also create cases from the portal. When a driver clicks **Report Issue** on a session detail page, the session is automatically linked to the new case.

## Case Detail

Click any case in the list to open the detail page.

![Support case detail](https://www.evtivity.com/screenshots/csms/support-case-detail.png)

### Message Thread

The message thread shows all messages in chronological order. Operators can send two types of messages:

- **Public messages** - Visible to both the operator and the driver.
- **Internal notes** - Visible to operators only. Marked with a distinct visual style.

System messages are automatically generated when the case status, priority, or assignment changes.

### Attachments

Attach files to any message. Click the paperclip icon when composing a message, select files, and send. Files are uploaded to S3 with presigned URLs. Maximum file size is 10 MB. Click any attachment to preview or download it.

### Linked Sessions

Link charging sessions to a case for context. The case detail shows linked sessions with their transaction IDs. Add or remove session links from the sidebar controls.

### Sidebar Controls

The right sidebar provides controls for:

- **Status** - Update the case status.
- **Priority** - Change the priority level.
- **Category** - Reclassify the case.
- **Assigned To** - Assign the case to an operator.

## Case Statuses

| Status | Description |
|--------|-------------|
| open | New case, not yet addressed |
| in_progress | Operator is working on the case |
| waiting_on_driver | Operator needs information from the driver |
| resolved | Issue has been resolved |
| closed | Case is closed |

## Case Categories

| Category | Description |
|----------|-------------|
| billing_dispute | Billing or payment disagreement |
| charging_failure | Session did not charge correctly |
| connector_damage | Physical damage to a connector |
| account_issue | Driver account problem |
| payment_problem | Payment processing failure |
| reservation_issue | Reservation-related problem |
| general_inquiry | General question or feedback |

## Case Priority

| Priority | Description |
|----------|-------------|
| low | Non-urgent, handle when available |
| medium | Standard priority (default for driver-created cases) |
| high | Requires prompt attention |
| urgent | Requires immediate attention |

## Per-Session Refunds

Issue a refund for any session linked to the case:

1. Click **Refund** next to a linked session in the case detail.
2. Enter a refund amount (leave blank for a full refund).
3. Confirm the refund.

Refunds can be issued on sessions with `captured` or `partially_refunded` payment status. Partial refunds are supported.

## Unread Indicators

The support cases navigation item shows a green pulsing dot when there are unread cases assigned to you. A case is marked as read when you view the detail page. New driver messages reset the read status.

Unread cases appear with bold text in the list view.

## Notifications

The system sends notifications for support case events:

- **Driver notifications**: Case created (by operator), operator reply, case resolved.
- **Operator notifications**: New case from driver, driver reply.

## AI-Assisted Replies

When AI is configured, click the AI Draft button in the message input area to generate a draft reply. The AI gathers context from the case, linked sessions, station info, and driver history to produce a relevant response. You can generate drafts for public replies or internal notes. The draft populates the text area for review and editing before sending.
