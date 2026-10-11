Generated from https://www.evtivity.com/docs/portal/support-cases. Do not edit.

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

## Ask AI First

When the operator offers it, a new case starts with a choice: let an AI analyze your issue first, or send the case straight to the support team. You choose for each case. The option shows only when the operator turned it on, so many networks do not show it.

### Choose How to Handle Your Request

![Choose how to handle your request](https://www.evtivity.com/screenshots/portal/support-ai-consent.png)

1. Tap **New Case**, or **Report Issue** on a session.
2. Under **How Should We Handle Your Request?**, read **About the AI Analysis**:
   - An AI gives an automatic first answer. It is not a promise, for example of a refund.
   - Your request and the data listed below are sent to an external AI provider.
   - You can still reach a person: answer No or write a message, and the support team takes over.
   - You decide for each request. If you send it to the support team, nothing is sent to the AI.
3. Open **What the AI Reads** to see the data the AI uses: this request, your last 10 charging sessions of the past 30 days, your charging cards and tokens (last 4 characters only), your payments and reservations of the past 30 days, and the stations you used.
4. Tap **Ask AI first** or **Send to the team**. The two buttons are equal and nothing is selected for you. The form opens only after you choose.
5. Fill in the category, subject, and description, and tap **Submit Case**.

The form shows **Your choice** at the top. Tap **Change** to choose again before you submit.

The notice also links to the operator's **Privacy policy** and shows what the AI receives:

> **Note:**
>
> **What the AI Receives**
>
> The AI reads your request and your own charging sessions, payments, reservations and the stations you used. Stored credentials, such as passwords, are never sent. Card numbers and IBANs are cut to their last 4 characters. Email addresses and phone numbers are masked. Charging card and token ids are shortened to their last 4 characters.

If you choose **Send to the team**, the case goes to the support team at once and nothing is sent to the AI.

### The Automatic Answer

![Automatic answer](https://www.evtivity.com/screenshots/portal/support-ai-answer.png)

With **Ask AI first**, the case shows the status **Automatic Answer** and the line **Analyzing your issue** while the AI works. The page updates by itself when the answer arrives. You also get a notification through the channels you chose in your notification preferences.

The answer appears in the thread as **Automatic Answer**, sometimes with suggested steps such as **Try another connector** or **Check the payment method**. The AI gives one answer per case. It does not hold a conversation.

Below the answer, the case asks **Did this solve your issue?**:

- **Yes**: the case is resolved and shows **Resolved. You can reopen it by writing to us.**
- **No**: the case goes to the support team and shows **Sent to the support team.**

![Case resolved by the automatic answer](https://www.evtivity.com/screenshots/portal/support-ai-resolved.png)

When the answer says a person needs to look at your issue, the page adds **We will pass this to the support team if you choose No.**

### When the Case Goes to the Support Team

The support team takes over the case when:

- You answer **No**.
- You write a message while the AI is still working or before you answer the question.
- You do not answer the question within the time the operator set, 24 hours by default.
- The AI cannot answer, for example because of a provider error, a daily limit, or a usage limit the operator set.

In the last case the page shows **We sent your request to the support team.** The support team then handles the case as any other case.

A case the AI resolved stays open for messages. When you write a message on it, the case opens again and goes to the support team.

![Case sent to the support team](https://www.evtivity.com/screenshots/portal/support-ai-sent.png)

## View Your Cases

![Support cases list](https://www.evtivity.com/screenshots/portal/support-cases.png)

1. Open the support cases page.
2. Your cases are displayed as cards showing:
   - Case number
   - Subject
   - Status badge (Open, In Progress, Awaiting Your Reply, Resolved, Closed, Automatic answer)
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
| Automatic answer | The AI is analyzing the case or waits for your answer (see [Ask AI First](#ask-ai-first)) |
| Open | Case submitted, awaiting operator review |
| In Progress | Operator is working on the case |
| Awaiting Your Reply | Operator needs more information from you |
| Resolved | The operator, or your **Yes** to the automatic answer, resolved the issue |
| Closed | Case is closed |

## Notifications

You receive notifications when:

- The operator replies to your case (non-internal messages only).
- The case status changes to resolved.
- The automatic answer to your case is ready.

Notifications are delivered via email and/or SMS based on your notification preferences.

## Notes

- Each case is assigned a priority by the operator (Low, Medium, High, Urgent). New cases from drivers default to Medium priority.
- Cases link to sessions via a junction table, so a single case can reference multiple sessions if the operator adds more.
- Only you can see your own cases. Cases are filtered by your driver ID.
