Generated from https://www.evtivity.com/docs/csms/ai-insights. Do not edit.

# Automatic Insights

Short root-cause notes with suggested fixes for offline or faulted stations, failed sessions, refused authorizations, and reservation problems, and background worker suggestions with an action you confirm.

## Overview

An automatic insight is a short note about a problem on your network: what probably caused it, how sure the analysis is, how far it reaches, and what to do next. EVtivity creates insights on its own when a station goes offline or reports a fault, when a session fails, when a station refuses a token, or when a reservation fails. You do not have to ask.

Some insights also carry an action that a [background AI worker](https://www.evtivity.com/docs/csms/ai-workers) suggests, such as stopping a stuck session. The action runs only when you confirm it (see [Insight Actions](#insight-actions)).

Automatic insights are off by default. An administrator turns them on in **Settings > AI > Automatic Insights** (see [Turn On Automatic Insights](#turn-on-automatic-insights)).

> **Note:**
>
> **What the AI Provider Receives**
>
> The AI provider never receives stored credentials, such as passwords, API keys, secrets and station passwords. Card numbers and IBANs are cut to their last 4 characters. Support drafts, automatic insights, background workers and driver support also mask email addresses and phone numbers, and hash or shorten driver token ids. The assistant sends driver contact details as stored, only to users allowed to read them. Text you type and text files you attach are checked for keys and card numbers. Images and PDFs you attach are sent as they are.

![Automatic insight on a station](https://www.evtivity.com/screenshots/csms/ai-insight-station.png)

## What Starts an Insight

EVtivity checks for new events once a minute. These events start an insight:

| Event | Insight |
|-------|---------|
| A station disconnects | Station offline |
| A station or one of its connectors reports Faulted | Station faulted |
| A station reports a critical event (an event alert) | Station alert |
| A session ends as failed or faulted | Session failed |
| A station refuses a token | Authorization refused (one per token, station, and hour) |
| A station rejects or does not answer a reservation, or cannot take it at activation | Reservation rejected |
| A reservation expires unused although the station accepted it for a driver | Reservation no-show |
| A station does not cancel a reservation | Reservation cancel failed |
| A reservation fee cannot be charged | Reservation fee failed |
| A reserved station reports a fault during the reservation | Station faulted while reserved |

Reservation events start an insight only while reservations are on (see [Reservation Insights](#reservation-insights)). A station that disconnects because the CSMS itself is restarting does not start an insight. Events from before automatic insights were turned on are never analyzed.

Background workers add insights of their own: **Stuck session** and **Station faulted for hours**, each with an action, and the **Site summary**, **Network summary**, and **Tariff anomaly** insights. See [Background AI Workers](https://www.evtivity.com/docs/csms/ai-workers).

### Wait, Group, and Skip

EVtivity does not analyze every event right away:

1. It waits 2 minutes by default. When the problem clears in that time, for example the station comes back online, the insight ends as **Resolved before the analysis** and no AI request is made.
2. When 3 or more stations of one site go offline or fault within that wait, they become one **Site incident** instead of one insight per station. Sessions at a site that fail for the same reason within an hour are grouped the same way, and so are reservation no-shows at a site within an hour. A station faulted while reserved joins the open site incident of its station.
3. When the cause is already known from the data, such as a stop reason or a refusal reason with a fixed meaning, EVtivity writes the insight from its own rules. It is marked **Known cause** and uses no tokens.
4. A station, session, or token analyzed in the last 60 minutes is not analyzed again (**Analyzed recently**).
5. Each site gets at most 50 AI-written insights per day.
6. When an AI budget is used up, the insight is stored with the rule-based fields only (see [AI Usage and Budgets](https://www.evtivity.com/docs/csms/ai-usage)).

Each of these values is a setting in **Settings > AI > Automatic Insights**. See [Settings](https://www.evtivity.com/docs/csms/settings#automatic-insights).

An insight usually appears 2 to 3 minutes after the event: the scan runs every minute and the analysis waits 2 minutes (**Wait before analyzing (seconds)**, 120 by default). Stations of one site that fail within that wait become one site incident.

## Read an Insight

An insight card is labeled **Automatic Insight**. From top to bottom it shows:

- The insight type, badges such as **Known cause**, **Out of date**, or **High confidence**, and how long ago the insight was created.
- A headline that says what happened and where, the same as on the dashboard card, such as **CS-1616 is faulted**.
- A short summary written by the AI.
- **Likely cause**: one of Connectivity, Power supply, Hardware, Firmware, Configuration, Token, Payment, Tariff, Vehicle, Backend, or Unknown.
- **Suggested Fix**: the steps to take, from a fixed list, such as **Check the station's network connection**, **Reboot the station**, or **Review the token status**. The steps are plain text. When the insight carries an action, the action comes last in this section, with **Reject** and **Confirm** (see [Insight Actions](#insight-actions)).
- A footer with **Show original**, how many users found the insight helpful, and the buttons to act on it (see [Act on an Insight](#act-on-an-insight)).

While an insight is analyzed, the card shows a placeholder of the same shape. An insight that is out of date, was not analyzed, or whose analysis did not finish shows one line with the reason and **Regenerate**.

The likely cause, confidence, and fixes appear in your CSMS language. The summary is written once in the summary language set in Settings (English by default). When you open an insight in another language, EVtivity translates the summary once and keeps the translation for everyone who reads that language. Until it is ready, the card shows the original with **Translating…** next to it, and the translation replaces it in place when it arrives, with no reload. When no translation can be made (no provider or a used-up budget), the card shows **No translation is available. The original is shown.** Click **Show original** to read the summary in its original language.

The summary is shown as plain text. Links and formatting in it are not rendered.

An insight that no longer matches the data shows **Out of date**. When the problem clears, EVtivity marks the insight **Resolved**.

![Insight on a refused authorization](https://www.evtivity.com/screenshots/csms/ai-insight-authorization-refused.png)

## Statuses

Every insight has one status. It also covers the action the insight carries, if any. The AI Insights list, its **Status** filter, the dashboard card, and the **AI Insights** tabs all show this status.

| Status | Meaning |
|--------|---------|
| Open | The problem needs attention |
| Pending | The insight's action waits for a decision |
| Done | The action was confirmed and ran |
| Rejected | The action was rejected |
| Resolved | The condition cleared on its own: the station came back online or is no longer faulted, or every station of a site incident recovered. A station faulted while reserved resolves when the station is online and no longer faulted, and a reservation fee failure resolves when the fee is captured later. A refused authorization resolves when its cause is gone: the session the card already runs ends, a blocked, expired or unknown card becomes usable, or the same card is accepted later at that station. A stuck session resolves when the session is no longer active, and its offline advice also when the station is back online or the session gets an action. A station alert resolves when the station reports it cleared. Other one-off insights close as expired after **Close one-off insights after (days)**. An action whose condition no longer held when someone confirmed it also resolves its insight |
| Dismissed | A user with the `aiInsights:write` permission dismissed it |
| Expired | Nobody decided on the action before it expired, or a one-off insight (a failed session, a reservation problem, a tariff anomaly, a card refused with no cause the CSMS can watch) stayed open longer than **Close one-off insights after (days)** |

Done, Rejected, Resolved, Dismissed, and Expired are final. A later event does not change them.

The dashboard card shows Open and Pending insights. Station, session, reservation, and site pages list every insight about the record on their **AI Insights** tab.

While EVtivity analyzes an insight, the card shows **Analyzing**. An insight that was not analyzed shows the reason, such as **Resolved before the analysis**, **Analyzed recently**, the daily limit of the site, a site or station outside the AI insights scope, insights turned off in Settings, or a used-up AI budget. When the AI provider fails three times in a row, the card shows **The analysis did not finish.** An insight replaced by **Regenerate**, or merged into a site incident or a group of failed sessions, no longer appears in the list.

**Out of date** is not a status: it marks an insight whose record changed after the analysis. Click **Regenerate** for a current one.

## Where Insights Appear

- **Station, session, reservation, and site pages**: the **AI Insights** tab (see [AI Insights Tab](#ai-insights-tab)).
- **Support case detail**: up to three insights about the case's station and linked sessions. Support AI drafts also read these insights.
- **Authorize log** (on the token, driver, and station pages): an AI column on refused attempts. Click it to open the insight, or to [Explain](https://www.evtivity.com/docs/csms/ai-assistant#explain) the attempt when it has none.
- **Dashboard**: the **Active Insights** card, below the stat cards (see below).
- **AI Insights**: the list of all insights (see [AI Insights List](#ai-insights-list)).

### AI Insights Tab

Station, session, reservation, and site pages have an **AI Insights** tab. It lists every insight about the record, newest first, with the columns **Insight**, **Status**, **Root Cause**, and **Created**. Click a row to open the insight page. The station tab lists the insights of the station and of its sessions. Reservation insights show only on the reservation page.

A light bulb button floats above the assistant button in the bottom right corner of these pages. Click it to open the **AI Insights** tab. It shows while the record has an open or pending insight, or one resolved within the last day. It is green and pulses while an insight is open, pulses amber while an action waits for a decision, and shows the number of insights when more than one is open or pending.

The tab and the button need the `aiInsights:read` permission and show only while AI Insights are on. On the reservation page, they show only while reservations are on.

### Active Insights Card

![Active Insights Card](https://www.evtivity.com/screenshots/csms/ai-insights-dashboard.png)

The **Active Insights** card shows below the stat cards of the dashboard, full width. It shows one card per open or pending insight in a row that scrolls sideways: three cards in view on wide screens, two on medium screens, and one on phones. Dots below the row show the scroll position. Click a dot to scroll to it. Each card shows:

- A headline that says what happened and where, such as **3 stations offline at Convention Center** or **CS-1616 is faulted**.
- The status, **Open** or **Pending**. **Pending** marks an insight whose action waits for a decision.
- The root cause, how many stations or sessions are affected, the site, and how long ago it happened.
- A confidence badge, such as **High confidence**.
- The first suggested fix.

The cards hold no AI-written text. Site incidents come first, then the most severe and newest insights. Insights of the same type and root cause at one site collapse into one card with **+N similar**. Click a card to open the insight page.

The card shows only while AI Insights are on, with **No open insights** when none are open. AI Insights are on while **Turn on system-initiated AI** is on and at least one insight type or background worker job is on. When AI Insights are off, the dashboard shows no insights, even ones that are still open. Click **View All** to open the AI Insights list.

## Reservation Insights

Reservation insights describe a reservation that went wrong. They exist only while two switches are on. Reservations must be on in **Settings > Integrations & Features > Reservation**. **Reservation insights** must be on in **Settings > AI > Automatic Insights**. While reservations are off, EVtivity creates no reservation insights and hides the stored ones and **Explain** on the reservation page. They show again when you turn reservations back on.

![Reservation detail with its insight](https://www.evtivity.com/screenshots/csms/reservation-insight.png)

| Insight | Known cause (rule, no tokens) | Analyzed by the AI |
|---------|-------------------------------|--------------------|
| **Reservation rejected** | The EVSE was occupied or in use, or the station was offline or faulted at activation | The station rejected it for another reason, or did not answer |
| **Reservation no-show** | Always | Never |
| **Reservation cancel failed** | The station was offline | The station rejected the cancellation or did not answer |
| **Reservation fee failed** | The payment was declined, or the driver has no payment method | The payment provider failed |
| **Station faulted while reserved** | Never | Always, with the station's data |

A reservation that expires because it never reached the station, because another driver used the EVSE, or because it was an operator hold without a driver is not a no-show and starts no insight.

The reservation's insights are on the **AI Insights** tab of the reservation page. Reservation insights do not show on the station page. Suggested fixes include **Check the reserved EVSE's status**, **Cancel the reservation on the station again**, and **Review the reservation fee payment**.

The header of the reservation page also has [Explain](https://www.evtivity.com/docs/csms/ai-assistant#explain) when the reservation was cancelled because of the station (rejected, not answered, or unavailable during the hold), when it expired, or when its fee failed. Like every Explain button, it needs the assistant turned on and the `aiAssistant:write` permission. Explain on a reservation also needs the `reservations:read` permission.

## AI Insights List

![AI Insights List](https://www.evtivity.com/screenshots/csms/ai-insights.png)

Open the AI Insights list from **AI Insights** in the navigation. The entry shows while AI Insights are on, with the number of insight actions that wait for a decision. The list, `/ai/insights`, shows every insight of your sites, newest first. Filter by **Status**, **Type**, **Root Cause**, **Feedback**, and **Site**. Select **Pending** in the **Status** filter to see the insights whose action waits for a decision. The **Feedback** filter shows **Any feedback**, **Marked wrong**, or **Marked helpful**: the insights at least one user marked that way. The table has these columns: **Insight**, **Status**, **Root Cause**, **Confidence**, **Station**, **Site**, and **Created**.

Click a row to open the insight page, `/ai/insights/<id>`. **Prev** and **Next** in the header move to the neighboring insight of the list. It shows:

- The insight card, with its actions (see [Act on an Insight](#act-on-an-insight)) and the suggested action, if any (see [Insight Actions](#insight-actions)).
- **Details**: the type, station, session, and site, the site incident the insight is part of, when it was created, resolved, or dismissed, and the reason it was skipped. For an insight with an action, also the **Worker job**, when the action **Expires**, who **Decided** it and when, and when it ran (**Ran at**).
- **Marked Wrong**: shown when users marked the insight wrong. Each wrong vote with who gave it, when, and the note as plain text, or **No note**. A user your site access does not let you see shows as **Another user**.
- **History**: every change to the insight and to its action.

The **Details** card has an **AI Insights** row to stop insights where they come from:

- **Suppress for This Station** shows when the insight has a station. It needs the `stations:write` permission.
- **Suppress for This Site** shows when the insight has a site, directly or through its station. It needs the `sites:write` permission.

Each button opens the suppress dialog. Enter a reason and an optional end date, and confirm. A toast confirms the change, and the insight shows as dismissed. When the station or site is already suppressed, the row shows its state instead of the button: **Station suppressed until** and the date, **Station suppressed until resumed**, **Station suppressed with its site**, **Site suppressed until** and the date, or **Site suppressed until resumed**. See [Stations](https://www.evtivity.com/docs/csms/stations#details) and [Sites](https://www.evtivity.com/docs/csms/sites#details).

![Suppress shortcuts on an insight](https://www.evtivity.com/screenshots/csms/ai-insight-suppress-shortcuts.png)

Each record an insight names links to its page: the station (OCPP ID), session, site (name), reservation (`#` and the reservation ID), driver (name, else email), and token. The **Details** card links every record, and the **Station** and **Site** columns of the list and of the station and site **AI Insights** tabs link theirs. Without the read permission for a record (`stations:read`, `sessions:read`, `sites:read`, `reservations:read`, or `drivers:read` for drivers and tokens), or when the record no longer exists, it shows as plain text with its ID.

Both pages need the `aiInsights:read` permission.

## History

- **AI Insights list**: open it with **View All** on the dashboard card, or at `/ai/insights`. Use the **Status** filter to see open, pending, done, rejected, resolved, dismissed, or expired insights, or **All statuses**.
- **Insight page**: the **History** section lists who dismissed or regenerated the insight, who set, changed, or removed a vote, who confirmed or rejected its action, how the action ended, and when.
- **Audit**: filter the Audit page by the **Automatic Insight** type, or by **AI insight action** for the decisions on insight actions.

You see only the insights of your sites.

## Act on an Insight

These actions need the `aiInsights:write` permission:

- **Regenerate**: analyze again, for an insight that is out of date, resolved, not analyzed, or whose analysis did not finish. EVtivity refuses it while another analysis of the same record is running (`AI_INSIGHT_COOLDOWN`), when insights are turned off (`AI_INSIGHTS_DISABLED`), or when a budget is used up.
- **Dismiss**: hide an open insight you do not need.
- **Helpful** or **Wrong**: tell EVtivity whether the insight was right (see [Feedback](#feedback)).

**Ask a follow-up** on the insight page and on a support case opens the [AI assistant](https://www.evtivity.com/docs/csms/ai-assistant#explain) about the insight.

Dismissals and vote changes are recorded in the audit log.

### Feedback

Each user has one vote per insight: **Helpful** or **Wrong**. The thumb you chose shows as pressed. Click another thumb to change your vote. Click the pressed thumb again to remove your vote: its tooltip reads **Remove your vote**. The vote buttons appear on every insight except one that is analyzing, not analyzed, out of date, or whose analysis did not finish.

Every reader sees how many users found the insight helpful in the card footer, such as "3 found this helpful".

When you click **Wrong**, the card opens a panel with **Marked wrong. Generate the insight again from fresh data, or dismiss it.** It holds:

- **What is wrong? (optional)**: a note of up to 500 characters. Click **Save Note** to store it. Readers of the insight see it in **Marked Wrong** on the insight page.
- **Regenerate**, unless the insight is dismissed. When you typed a note without saving it, **Regenerate** saves it first.
- **Dismiss**, while the insight is open.

Votes are never sent to an AI provider. Your note is sent only when you regenerate an insight you marked wrong: the new analysis reads your own note, never the note of another user, as a claim to check against the station data, not as an instruction. EVtivity marks it as untrusted text and first masks credentials, card numbers, email addresses, and phone numbers in it. A known cause needs no AI request and ignores the note. An insight analyzed with your note shows **Regenerated with your feedback**. Other users see **Regenerated with operator feedback**. The AI assistant cannot read votes or notes. To see how insights rate over time, open the **Insight Quality** card in **Settings > AI > Automatic Insights** (see [Settings](https://www.evtivity.com/docs/csms/settings#automatic-insights)).

## Insight Actions

A [background AI worker](https://www.evtivity.com/docs/csms/ai-workers) can suggest an action. The suggestion is an insight that carries the action:

| Insight | Action | Runs only if |
|---------|--------|--------------|
| **Stuck session** | **Stop the session** | **The session is still active** |
| **Stuck session** | **End the session without the station** | **The session is still active** |
| **Station faulted for hours** | **Soft reset the station** | **The station is still faulted** |

![Insight with a suggested action](https://www.evtivity.com/screenshots/csms/ai-insight-action.png)

The action is the last part of the **Suggested Fix** section of the insight card, after the other fix steps. It shows:

- A sentence that names the action and its target, such as "Stop the charging session at station CS-1 (OCPP transaction ...)".
- **Expires on** and the time, on the right of the **Suggested Fix** heading. Hover it to see why the action expires.
- The **Rationale** with the measured values behind it, such as **Idle Time**, **Last Activity**, and **Faulted Since**, and the **OCPP Transaction ID** of a session.
- **API Request**, a collapsed panel with the method and path of the request. Open it to see the arguments.
- The result once the action ran, or the reason nothing ran.
- **Reject** and **Confirm**. After a decision, or once the action expired, the buttons stay disabled.

### Confirm or Reject

1. Open the insight from AI Insights, the dashboard card, or the **AI Insights** tab of the station or session.
2. Read the action, the rationale, and the API request.
3. Click **Confirm** to run the action, or **Reject** to drop it.
4. Confirm your choice in the dialog. **Run This Action?** runs the action once, now, with your permissions. **Reject This Action?** drops it.

When you confirm, EVtivity checks again that the action has not expired, that the condition still holds, and that the action is still allowed. Then it runs the request with your own permissions and site access, and the result appears on the card. Each action runs at most once: when two users confirm it at the same time, only one confirm runs it. An action that expired shows `AI_PROPOSAL_EXPIRED`. An action whose condition no longer holds shows `AI_PROPOSAL_STALE`.

The decision sets the status of the insight:

| Action | Insight status |
|--------|----------------|
| Waiting for a decision | Pending |
| Confirmed and ran | Done |
| Confirmed, but did not run, for example because you lack the permission it needs | Open, with the reason on the card |
| Rejected | Rejected |
| Nobody decided before it expired | Expired |
| The condition no longer held when someone confirmed it | Resolved |

While an action waits, **Regenerate** and **Dismiss** are hidden. Click **Reject** to drop the action. Insights with an action cannot be regenerated.

Confirm and reject need the `aiInsights:write` permission and a signed-in CSMS session. An API key cannot decide an action (`AI_CONFIRMATION_REQUIRES_SESSION`).

A suggested soft reset expires after 24 hours by default (**Action lifetime (hours)**). A suggested stop expires after 2 hours.

### Daily Digest Email

Users with the `aiInsights:write` permission can get a daily email with the number of insight actions that wait for a decision at their sites, per job, and a link to AI Insights filtered to **Pending**. The email holds counts and site names only, never AI-written text.

To turn it on, open your **Profile**, go to **Notifications**, and turn on **AI insight action digest email**. It is off by default. The email goes out once a day while actions are pending. Edit its template under **Notifications > System Events** (**AI Insight Action Digest**, `ai.ProposalDigest`).

## Turn On Automatic Insights

1. Add an API key for a provider in **Settings > AI > Providers and Keys**.
2. Open **Settings > AI > Automatic Insights**. In the **Automatic Insights and Workers** card, select the **Provider** and turn on **Turn on system-initiated AI**.
3. In the **Automatic Insights** card, keep or turn off **Station insights**, **Session insights**, **Authorization insights**, and **Reservation insights**. All four are on by default once system-initiated AI is on. **Reservation insights** shows only while reservations are on.
4. Click **Save**.
5. Optional: in the **AI Insights Scope** card, keep **All Sites**, or choose **Selected Sites** and pick the sites and stations to analyze (see [Settings](https://www.evtivity.com/docs/csms/settings#automatic-insights)).

Sites and stations outside the scope get no insights, and their open insights are dismissed when you take them out. To pause insights for a while instead, suppress the [station](https://www.evtivity.com/docs/csms/stations#details) or [site](https://www.evtivity.com/docs/csms/sites#details).

## Data Sent to the AI Provider

Automatic insights run without a user action. When system-initiated AI is on, EVtivity sends these data categories to the selected provider:

- Station data: identity, vendor, model, firmware, OCPP version, online state and heartbeat, availability and status, recent status changes, connections, boot reason, and the error codes, alerts, and information texts the station reported.
- Session data: status, stop reason, start and end times, energy, costs, currency, roaming, and payment failure reasons.
- Authorization data: the refusal outcome, the token type and state, prepaid credit, fleet credit limit state, and local list state. The token value itself is never sent: EVtivity sends a hash.
- Reservation data: status, times, cancel reason, fee state, the reservation's history entries, the reservation messages of its station (action and status only), the EVSE status changes during the hold, and the fee payment status and amounts. The driver is sent only as a hashed reference.
- Site data: counts of affected stations and sessions at the insight's site.
- Your note on a wrong vote, only when you regenerate that insight (see [Feedback](#feedback)).

Stored credentials are removed, and card numbers, email addresses, phone numbers, and token ids are masked before anything is sent. Text a station reported is marked as untrusted, so the AI does not follow instructions in it. This data leaves your deployment. Check the provider's data retention terms before you turn automatic insights on.

## Permissions

| Permission | Allows |
|------------|--------|
| `aiInsights:read` | See insights on records you can open |
| `aiInsights:write` | Regenerate, dismiss, give feedback, and confirm or reject insight actions |

By default, operators have both and viewers have `aiInsights:read`. Insights follow site access: you see only insights of your sites.

## Notes

- Insights never change anything on your network on their own. An insight action runs only when a user confirms it, with that user's permissions. Background workers suggest three actions today: a stop for a stuck session at an online station, an end in the CSMS for a stuck session at a station offline past the setting, and a soft reset for a station faulted for more than 6 hours. The only action kinds a worker may suggest are stop a session, end a session in the CSMS, soft reset a station, and change a station's availability. A station whose AI insights are suppressed, on its own or with its site, gets no suggestion (see [Stations](https://www.evtivity.com/docs/csms/stations#details) and [Sites](https://www.evtivity.com/docs/csms/sites#details)). Payments, pricing, and settings are never suggested.
- The card never names the AI provider or model.
- Insights are deleted after 90 days by default (**Automatic Insights** in **Settings > Data Retention**). An insight's action is deleted with it. Their audit entries stay after the insight is deleted.
- The API lists insights at `GET /v1/ai/insights`. See the [API reference](https://www.evtivity.com/api-reference) and the [error codes](https://www.evtivity.com/api-reference/error-codes).
