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

## Read an Insight

An insight card is labeled **Automatic insight**. It shows:

- **Root cause**: one of Connectivity, Power supply, Hardware, Firmware, Configuration, Token, Payment, Tariff, Vehicle, Backend, or Unknown.
- **Confidence**: Low, Medium, or High.
- **Suggested fixes**: from a fixed list, such as **Check the station's network connection**, **Reboot the station**, or **Review the token status**.
- **Scope**: counts from the database, such as how many stations at this site are offline or how many sessions failed for the same reason in 24 hours. Users with access to every site also see counts **Across all sites**.
- A short summary written by the AI.

The root cause, confidence, fixes, and scope appear in your CSMS language. The summary is written once in the summary language set in Settings (English by default). When you read an insight in another language, EVtivity translates the summary once and keeps the translation for everyone who reads that language. While it is translated, the card shows **The summary is being translated**. Click **Show original** to read the summary in its original language.

The summary is shown as plain text. Links and formatting in it are not rendered.

An insight that no longer matches the data shows **Out of date**. When the problem clears, EVtivity marks the insight **Resolved**.

## Where Insights Appear

- **Station detail**: the active insight of the station, or one resolved within the last day.
- **Session detail**: the insight of a failed or faulted session.
- **Support case detail**: up to three insights about the case's station and linked sessions. Support AI drafts also read these insights.
- **Authorize log** (on the token, driver, and station pages): an AI column on refused attempts. Click it to open the insight, or to [Explain](https://www.evtivity.com/docs/csms/ai-assistant#explain) the attempt when it has none.
- **Dashboard**: an **Active insights** widget, shown only while active insights exist.

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
- Insights are deleted after 90 days by default (**Keep insights (days)**).
- The API lists insights at `GET /v1/ai/insights`. See the [API reference](https://www.evtivity.com/api-reference) and the [error codes](https://www.evtivity.com/api-reference/error-codes).
