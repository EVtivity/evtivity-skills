Generated from https://www.evtivity.com/docs/csms/ai-workers. Do not edit.

# Background AI Workers

Optional scheduled jobs that summarize your network, find stuck sessions, and check tariffs. Their suggestions are insights with an action that runs only when you confirm it.

## Overview

Background AI workers are scheduled jobs that look for problems on your network. They find the facts with database queries, and AI only writes a short summary or rationale. A worker can suggest an action, but it cannot run one. A suggestion is an [automatic insight](https://www.evtivity.com/docs/csms/ai-insights) that carries the action, with **Confirm** and **Reject**. Nothing runs until a user confirms it (see [Insight Actions](https://www.evtivity.com/docs/csms/ai-insights#insight-actions)).

Every worker is off by default.

![Background AI workers settings](https://www.evtivity.com/screenshots/csms/settings-ai-insights-workers.png)

## Jobs

| Job | Runs | What it does | Suggests |
|-----|------|--------------|----------|
| **Nightly Network Summary** | Daily at 05:30 | For each site with activity, compares the last 24 hours with the daily average of the 7 days before: stations online, offline, and faulted, sessions, failed sessions, refused authorizations, and alerts. Writes a short summary per site and one summary of the whole network. | A soft reset for up to 3 online stations per site that have been faulted for more than 6 hours, each as a **Station faulted for hours** insight |
| **Stuck Sessions** | Every 15 minutes | Finds active sessions that stopped reporting: no meter values or transaction events for the idle time, or on a station that is offline or a connector that reports Available, silent for 15 minutes. | At an online station, a stop of the session. At a station offline for longer than the offline time setting, an end of the session in the CSMS. Each as a **Stuck session** insight |
| **Tariff Anomalies** | Daily at 06:00 | Finds sessions billed nothing on a priced tariff, station costs that differ from the CSMS cost, prices per kWh more than 3 times the site's 30-day median, and sessions priced with an inactive tariff. | Nothing. Findings only |

Times follow the system timezone. Summaries and findings appear as [automatic insights](https://www.evtivity.com/docs/csms/ai-insights): **Site summary**, **Network summary**, and **Tariff anomaly**. The network summary is visible only to users with access to every site.

### Stuck Sessions

- The idle time is 90 minutes by default (**Idle time before a session counts as stuck (minutes)**). It always stays at least 60 minutes below the stale session timeout, so a suggestion comes before the CSMS ends the session on its own.
- A session that already has a pending or rejected action gets no new suggestion.
- At an online station, the action is the same stop as **Stop Session** on the session page. Before it, the worker asks an OCPP 2.1 station whether it still runs the transaction. The insight then says how the stop bills the session: from its final meter reading while the station runs the transaction, or at its last metered energy when the station no longer knows it and the CSMS ends the session.
- At an offline station, the insight first advises getting the station back online: how long it has been offline, a **Connection History** link, and what to check (power, network or SIM, the site). When the station reconnects, it sends its stored transaction messages, so the session ends with its real final meter reading and exact billing. This insight has no action.
- Once the station has been offline for **Offline time before the AI suggests ending a stuck session in the CSMS (hours)** (24 hours by default), the insight suggests **End Session**: the CSMS closes the session without the station and bills it at its last metered energy. A later report from the station does not bill it again.
- The rationale is a fixed sentence, such as "No meter values or transaction events for 90 minutes". Turn on **Write the rationale with AI** to have AI write it instead. The AI rationale becomes the text of the insight. AI only explains the step the worker chose, from the measured facts; it never chooses the step.
- An action expires after 2 hours. It runs only if the session is still active and the station is still online (a stop) or still offline (an end).

### Tariff Anomalies

Tariff anomalies never suggest an action: changes to prices, billing, and payments are never available to AI. Review the findings and fix the tariff yourself on the [Pricing](https://www.evtivity.com/docs/csms/pricing) page.

## Turn On a Worker

1. Open **Settings > AI > Automatic Insights** and turn on **Turn on system-initiated AI** in the **Automatic Insights and Workers** card. Workers use the same provider and model as automatic insights.
2. In the **Background AI Workers** card on the same tab, turn on the jobs you want: **Nightly Network Summary**, **Stuck Sessions**, and **Tariff Anomalies**.
3. Optionally set **Action lifetime (hours)** (24 by default), the time a suggested soft reset stays open.
4. Click **Save**.

## Budgets

Each AI request of a worker counts against the site's daily token budget (**Tokens per site per day (insights and workers)**) and the monthly budgets. When a budget is used up, the worker still stores its findings and suggested actions, without the AI-written text. See [AI Usage and Budgets](https://www.evtivity.com/docs/csms/ai-usage).

## Data Sent to the AI Provider

A worker sends the facts it found to the selected provider: per-site counts of stations, sessions, refusals, and alerts, the stuck session's station and duration, and the tariff findings. This data leaves your deployment.

> **Note:**
>
> **What the AI Provider Receives**
>
> The AI provider never receives stored credentials, such as passwords, API keys, secrets and station passwords. Card numbers and IBANs are cut to their last 4 characters. Support drafts, automatic insights, background workers and driver support also mask email addresses and phone numbers, and hash or shorten driver token ids. The assistant sends driver contact details as stored, only to users allowed to read them. Text you type and text files you attach are checked for keys and card numbers. Images and PDFs you attach are sent as they are.

## Notes

- A worker never runs an action. Only a user who confirms the action on its insight does, with that user's own permissions.
- Each job runs once per site and period, even with several worker processes.
- Users can get a [daily digest email](https://www.evtivity.com/docs/csms/ai-insights#daily-digest-email) of pending insight actions.
