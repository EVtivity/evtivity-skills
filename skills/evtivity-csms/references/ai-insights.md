Generated from https://www.evtivity.com/docs/csms/ai-insights. Do not edit.

# Automatic Insights

Short root-cause notes with suggested fixes for offline or faulted stations, failed sessions, and refused authorizations.

## Overview

An automatic insight is a short note about a problem on your network: what probably caused it, how sure the analysis is, how far it reaches, and what to do next. EVtivity creates insights on its own when a station goes offline or reports a fault, when a session fails, or when a station refuses a token. You do not have to ask.

Automatic insights are off by default. An administrator turns them on in **Settings > AI** (see [Turn On Automatic Insights](#turn-on-automatic-insights)).

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

A station that disconnects because the CSMS itself is restarting does not start an insight. Events from before automatic insights were turned on are never analyzed.

### Wait, Group, and Skip

EVtivity does not analyze every event right away:

1. It waits 2 minutes by default. When the problem clears in that time, for example the station comes back online, the insight ends as **Resolved before the analysis** and no AI request is made.
2. When 3 or more stations of one site go offline or fault within that wait, they become one **Site incident** instead of one insight per station. Sessions at a site that fail for the same reason within an hour are grouped the same way.
3. When the cause is already known from the data, such as a stop reason or a refusal reason with a fixed meaning, EVtivity writes the insight from its own rules. It is marked **Known cause** and uses no tokens.
4. A station, session, or token analyzed in the last 60 minutes is not analyzed again (**Analyzed recently**).
5. Each site gets at most 50 AI-written insights per day.
6. When an AI budget is used up, the insight is stored with the rule-based fields only (see [AI Usage and Budgets](https://www.evtivity.com/docs/csms/ai-usage)).

Each of these values is a setting. See [Settings > AI](https://www.evtivity.com/docs/csms/settings#automatic-insights).

An insight usually appears 2 to 3 minutes after the event: the scan runs every minute and the analysis waits 2 minutes (**Wait before analyzing (seconds)**, 120 by default). Stations of one site that fail within that wait become one site incident.

## Read an Insight

An insight card is labeled **Automatic insight**. It shows:

- A headline that says what happened and where, the same as on the dashboard card, such as **CS-1616 is faulted**.
- **Likely cause**: one of Connectivity, Power supply, Hardware, Firmware, Configuration, Token, Payment, Tariff, Vehicle, Backend, or Unknown.
- **Confidence**: Low, Medium, or High.
- **Suggested fixes**: from a fixed list, such as **Check the station's network connection**, **Reboot the station**, or **Review the token status**.
- **Scope**: counts from the database, such as how many stations at this site are offline or how many sessions failed for the same reason in 24 hours. Users with access to every site also see counts **Across all sites**.
- A short summary written by the AI.

A suggested fix that is done on a station tab, such as **Reboot the station**, links to that tab. An insight that is out of date, skipped, or failed shows one line with the reason and **Regenerate**.

The likely cause, confidence, fixes, and scope appear in your CSMS language. The summary is written once in the summary language set in Settings (English by default). When you open an insight in another language, EVtivity translates the summary once and keeps the translation for everyone who reads that language. Until it is ready, the card shows the original with **Translating…** next to it, and the translation replaces it in place when it arrives, with no reload. When no translation can be made (no provider or a used-up budget), the card shows **No translation is available. The original is shown.** Click **Show original** to read the summary in its original language.

The summary is shown as plain text. Links and formatting in it are not rendered.

An insight that no longer matches the data shows **Out of date**. When the problem clears, EVtivity marks the insight **Resolved**.

### Scope at Detection and Now

The **Scope** row is collapsed by default and names the main measure at detection, for example **3 stations offline at detection**. Click it to open the table. It lists each measure with two values. **At detection** is counted when the insight is detected and stored with it. Most measures cover the last 24 hours, and these are the figures the analysis used. **Now** is counted when you open the table, with no AI request. Hover the **Now** header to see when it was counted. A value that changed is shown in a heavier weight. The dashboard card shows only the value at detection. Rows for all sites are visible only to users with access to every site.

## Statuses

Only **Active** insights appear on the dashboard card. Station and session pages show the active or analyzing insight, or one resolved within the last day. All other insights stay in the AI Insights list.

| Status | Meaning |
|--------|---------|
| Analyzing | Waiting for the analysis or being analyzed |
| Active | Open. Shown on the dashboard card and the record pages |
| Resolved | The condition cleared on its own: the station came back online or is no longer faulted, or every station of a site incident recovered. Session, authorization and alert insights are not resolved automatically |
| Dismissed | A user with the `aiInsights:write` permission dismissed it |
| Superseded | A newer insight replaced it after **Regenerate**, or it was merged into a site incident or a group of failed sessions |
| Skipped | It was not analyzed. The card shows the reason, such as **Resolved before the analysis**, **Analyzed recently**, the daily limit of the site, insights turned off for the site or in Settings, or a used-up AI budget |
| Failed | The AI provider failed three times in a row |

**Out of date** is not a status: it marks an active insight whose record changed after the analysis. Click **Regenerate** for a current one.

## Where Insights Appear

- **Station detail**: the active insight of the station, or one resolved within the last day.
- **Session detail**: the insight of a failed or faulted session.
- **Support case detail**: up to three insights about the case's station and linked sessions. Support AI drafts also read these insights.
- **Authorize log** (on the token, driver, and station pages): an AI column on refused attempts. Click it to open the insight, or to [Explain](https://www.evtivity.com/docs/csms/ai-assistant#explain) the attempt when it has none.
- **Dashboard**: the **Active insights** card (see below).
- **AI Insights**: the list of all insights (see [AI Insights List](#ai-insights-list)).

### Active Insights Card

![Active Insights Card](https://www.evtivity.com/screenshots/csms/ai-insights-dashboard.png)

The **Active insights** card on the dashboard shows up to five open insights. Each row shows:

- A headline that says what happened and where, such as **3 stations offline at Convention Center** or **CS-1616 is faulted**.
- The root cause, how many stations or sessions are affected, the site, and how long ago it happened.
- A confidence badge, such as **High confidence**.
- The first suggested fix.

The rows hold no AI-written text. Site incidents come first, then the most severe and newest insights. Insights of the same type and root cause at one site collapse into one row with **+N similar**. Click a row to open the insight page.

The card shows while automatic insights are on, with **No open insights** when none are open. When automatic insights are off, it shows only while insights are still open. Click **View all** to open the AI Insights list with the active insights.

## AI Insights List

![AI Insights List](https://www.evtivity.com/screenshots/csms/ai-insights.png)

The AI Insights list, `/ai/insights`, shows every insight of your sites, newest first. Filter by **Status**, **Type**, **Root cause**, and **Site**. The table has these columns: **Insight**, **Status**, **Root cause**, **Confidence**, **Station**, **Site**, and **Created**.

Click a row to open the insight page, `/ai/insights/<id>`. It shows:

- The insight card, with its actions (see [Act on an Insight](#act-on-an-insight)).
- **Details**: the type, station, session, and site, the site incident the insight is part of, when it was created, resolved, or dismissed, and the reason it was skipped.
- **History**: every change to the insight.

Both pages need the `aiInsights:read` permission.

## History

- **AI Insights list**: open it with **View all** on the dashboard card, or at `/ai/insights`. Use the **Status** filter to see active, resolved, dismissed, superseded, skipped, or failed insights, or **All statuses**.
- **Insight page**: the **History** section lists who dismissed, regenerated, or rated the insight, and when.
- **Audit**: filter the Audit page by the **Automatic insight** type.

You see only the insights of your sites.

## Act on an Insight

These actions need the `aiInsights:write` permission:

- **Regenerate**: analyze again, for an insight that is out of date, resolved, skipped, or failed. EVtivity refuses it while another analysis of the same record is running (`AI_INSIGHT_COOLDOWN`), when insights are turned off (`AI_INSIGHTS_DISABLED`), or when a budget is used up.
- **Dismiss**: hide an insight you do not need.
- **Helpful** or **Wrong**: tell EVtivity whether the insight was right. Feedback and dismissals are recorded in the audit log.

## Turn On Automatic Insights

1. Add an API key for a provider in **Settings > AI > AI providers**.
2. Under **Automatic insights and workers**, select the **Provider** and click **Turn on system-initiated AI**.
3. Under **Automatic insights**, keep or turn off **Station insights**, **Session insights**, and **Authorization insights**. All three are on by default once system-initiated AI is on.
4. Click **Save**.

To stop insights for one site, open the site and turn off **Automatic insights** in the **AI usage** card of the **Details** tab. Only users with access to every site and the `sites:write` permission can change it.

## Data Sent to the AI Provider

Automatic insights run without a user action. When system-initiated AI is on, EVtivity sends these data categories to the selected provider:

- Station data: identity, vendor, model, firmware, OCPP version, online state and heartbeat, availability and status, recent status changes, connections, boot reason, and the error codes, alerts, and information texts the station reported.
- Session data: status, stop reason, start and end times, energy, costs, currency, roaming, and payment failure reasons.
- Authorization data: the refusal outcome, the token type and state, prepaid credit, fleet credit limit state, and local list state. The token value itself is never sent: EVtivity sends a hash.
- Site data: counts of affected stations and sessions.

Secrets are removed and email addresses are masked before anything is sent. Text a station reported is marked as untrusted, so the AI does not follow instructions in it. This data leaves your deployment. Check the provider's data retention terms before you turn automatic insights on.

## Permissions

| Permission | Allows |
|------------|--------|
| `aiInsights:read` | See insights on records you can open |
| `aiInsights:write` | Regenerate, dismiss, and give feedback |

By default, operators have both and viewers have `aiInsights:read`. Insights follow site access: you see only insights of your sites.

## Notes

- Insights never change anything on your network. They only describe and suggest.
- The card never names the AI provider or model.
- Insights are deleted after 90 days by default (**Keep insights (days)** under **Automatic insights** in **Settings > AI**). Their audit entries stay after the insight is deleted.
- The API lists insights at `GET /v1/ai/insights`. See the [API reference](https://www.evtivity.com/api-reference) and the [error codes](https://www.evtivity.com/api-reference/error-codes).
