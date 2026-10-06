Generated from https://www.evtivity.com/docs/portal/support-cases (website commit 900fb20). Do not edit.

# Support Cases

Report charging issues, communicate with the operator, and track case resolution.

## Overview

The support case system lets drivers report problems with charging sessions and communicate with the network operator. Cases are tracked with a unique case number and support a threaded message history.

## Create a Support Case

The most common way to create a case is from a session detail page.

### From a Session

1. Open the **Activity** tab and tap a session.
2. On the session detail page, tap **Report Issue**.
3. You are taken to the new support case form with the session pre-attached.
4. Under **Select Category**, pick a category:
   - Billing Dispute
   - Charging Failure
   - Connector Damage
   - Account Issue
   - Payment Problem
   - Reservation Issue
   - General Inquiry
5. Enter a **Subject** summarizing the issue.
6. Enter a **Description** with details about what happened.
7. Tap **Submit Case**.

The case is assigned a number (e.g., CASE-00001) and the operator is notified.

### From the Support Page

1. Navigate to the support cases page from the Account tab or directly via `/support`.
2. Tap **New Case**.
3. Fill in the category, subject, and description.
4. Tap **Submit Case**.

Cases created this way do not have a session attached unless you navigated from a session detail page.

## View Your Cases

![Support cases list](https://www.evtivity.com/screenshots/portal/support-cases.png)

1. Open the support cases page.
2. Your cases are displayed as cards showing:
   - Case number
   - Subject
   - Status badge (Open, In Progress, Awaiting Your Reply, Resolved, Closed)
   - Category
   - Date created

Tap a case to open the detail view.

## Case Detail and Messages

The case detail page shows a chat-style message thread.

- **Your messages** appear on the right side.
- **Operator messages** appear on the left side.
- **System messages** appear centered (e.g., status changes, assignment changes).

Internal operator notes are hidden from drivers.

### Send a Message

1. Type your message in the text input at the bottom of the case detail page.
2. Tap **Send**.

The operator is notified of your reply via email.

### Attached Sessions

If a session was attached to the case, it appears in the case info section with a link to the session detail.

## Case Statuses

| Status | Meaning |
|--------|---------|
| Open | Case submitted, awaiting operator review |
| In Progress | Operator is working on the case |
| Awaiting Your Reply | Operator needs more information from you |
| Resolved | Operator has resolved the issue |
| Closed | Case is closed |

## Notifications

You receive notifications when:

- The operator replies to your case (non-internal messages only).
- The case status changes to resolved.

Notifications are delivered via email and/or SMS based on your notification preferences.

## Notes

- Each case is assigned a priority by the operator (Low, Medium, High, Urgent). New cases from drivers default to Medium priority.
- Cases link to sessions via a junction table, so a single case can reference multiple sessions if the operator adds more.
- Only you can see your own cases. Cases are filtered by your driver ID.
