Generated from https://www.evtivity.com/docs/csms/support-cases. Do not edit.

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

Attach files to any message. Click the paperclip icon when composing a message, select files, and send. Attachments need S3 storage (see [Settings](https://www.evtivity.com/docs/csms/settings#s3-bucket)).

Allowed file types:

- Images (JPEG, PNG, WebP, GIF)
- PDF
- CSV, plain text, and log files
- JSON and JSONL

The maximum file size is the **Maximum attachment size (bytes)** limit in **Settings > AI > Usage and Limits** (10 MB by default). Drivers who attach files in the portal get the same checks.

The server checks every file before it stores it:

- It checks the file content against the declared type and refuses a mismatch.
- It re-encodes images and removes their metadata, such as camera and location data.
- It refuses encrypted PDFs and cuts text files to 2 MB.

Click an attachment to preview an image or download the file. A download always saves the file instead of opening it in the browser.

With a self-managed S3 bucket, add a CORS rule that allows `POST` from the CSMS origin. The browser uploads files straight to the bucket, and uploads fail without this rule. See [S3 Bucket](https://www.evtivity.com/docs/csms/settings#s3-bucket).

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
| ai_assist | The driver AI handles the case (shown as **With the AI**). See [Driver AI Support](#driver-ai-support) |

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

Cases with the driver AI do not count as unread until they reach the support team.

## Notifications

The system sends notifications for support case events:

- **Driver notifications**: Case created (by operator), operator reply, case resolved, automatic answer ready (driver AI support).
- **Operator notifications**: New case from driver, driver reply. A case the driver sent to the AI notifies operators only when it reaches the support team.

## Driver AI Support

Driver AI support gives a driver an automatic first answer to a new case, but only when the driver allows it. It is off by default. Turn it on with **Offer AI analysis to drivers** in **Settings > AI > Driver Support** (see [Settings](https://www.evtivity.com/docs/csms/settings#driver-support)), and choose a provider that has an API key.

> **Warning:**
>
> Before you turn driver AI support on, have the consent notice text reviewed against your privacy obligations. The notice is built in and versioned. You cannot edit it.

### How It Works

1. In the portal or the mobile app, the driver opening a case chooses **Ask AI first** or **Send to the team**. Nothing is preselected. The notice tells the driver that the request and their own data go to an external AI provider. See [Support Cases](https://www.evtivity.com/docs/portal/support-cases#ask-ai-first) in the portal guide.
2. With **Send to the team**, the case reaches your team at once, as any other case. Nothing is sent to the AI.
3. With **Ask AI first**, the case gets the status **With the AI**. The AI reads the case and the driver's own sessions, payments, reservations, tokens (last 4 characters) and the stations used, and writes one answer. It has no tools and changes nothing.
4. The driver answers **Did this solve your issue?**. Yes resolves the case. No sends it to your team.

The AI gives one answer per case and holds no conversation. The case reaches your team when:

- The driver answers No.
- The driver writes a message before answering.
- The driver gives no answer within **Wait for the driver's feedback (hours)**.
- The AI cannot answer: a driver limit, a token budget, a provider error, or an answer that fails the safety checks.
- You change the status of the case yourself.

A driver who writes on a case the AI resolved opens it again, and it reaches your team. A case you resolved does not reopen this way.

### Finding Cases With the AI

![Support cases filtered by AI state](https://www.evtivity.com/screenshots/csms/support-cases-ai-filter.png)

Cases with the AI are left out of the default case list, the unread count, the open case counts, and the operator notifications until they reach your team. To see them:

- Select **With the AI** in the **Status** filter.
- Select a state in the **AI State** filter: **Queued**, **Analyzing**, **Waiting for Driver Feedback**, **Resolved by AI**, **Passed to Support**, **AI Analysis Failed**, or **AI Analysis Skipped**.
- Select **AI** or **Support team** in the **Resolved by** filter to list resolved cases by who resolved them.

Cases the AI resolved stay in the default list with the status Resolved. A badge next to the status shows the AI state of a case, or **Resolved by AI**.

### AI on the Case Detail

![Support case with driver AI support](https://www.evtivity.com/screenshots/csms/support-case-driver-ai.png)

The **Driver Consent** card on the case detail shows:

- **Decision**: **Allowed AI analysis**, **Declined AI analysis**, or **Not asked**.
- **Answered at**: when the driver chose, in server time.
- **Notice Language** and **Notice Version**: the notice the driver read.
- **AI State** and its reason, for example **The driver reached the daily limit** or **No feedback from the driver**.
- **Automatic Answer at** and **Driver Feedback at**.
- **Resolved by**: **AI** or **Support team**.

The automatic answer appears in the message thread as **Automatic Answer**. The **History** section lists the AI steps: **AI analysis allowed**, **AI analysis declined**, **Automatic answer given**, **Resolved by AI**, **Passed from AI to support**, and **AI Analysis Failed**. The **Status** control shows **With the AI** but you cannot select it.

### Limits

These limits send a case straight to your team when the driver or the company reaches them. Set them in **Settings > AI > Driver Support**, except the monthly budgets.

| Limit | Default | Notes |
|-------|---------|-------|
| **AI-analyzed requests per driver per day** | 3 | Counted per day in the system timezone |
| **AI requests per driver per minute** | 2 | Checked when the driver creates the case |
| **Tokens per driver per day** | 40,000 | Midnight to midnight UTC. 0 means no limit |
| **Wait for the driver's feedback (hours)** | 24 | A case without feedback after this time goes to your team |
| **Company tokens per month** | 0 (no limit) | In **Settings > AI > Usage and Limits** |
| **Tokens per site per month** | 0 (no limit) | Counts the site of the case's station. In **Settings > AI > Usage and Limits** |

The tokens of driver AI support appear under **Driver Support** in the AI usage. See [AI Usage and Budgets](https://www.evtivity.com/docs/csms/ai-usage).

## AI-Assisted Replies

When support AI is turned on in **Settings > AI > Support Drafts**, users with the `support:write` permission see an **AI Draft** button in the message input area. Check **Internal note** for a note to your team, or leave it unchecked for a reply to the customer. The draft streams into the message box. Click **Stop draft** to end it early. A **Sources** list shows the data the AI read. The AI reads only the case and its linked data, follows the driver's language in customer replies, and never changes anything or sends a message. See [AI Assistant](https://www.evtivity.com/docs/csms/ai-assistant) for details.

![Support case AI draft](https://www.evtivity.com/screenshots/csms/support-case-ai-draft.png)
