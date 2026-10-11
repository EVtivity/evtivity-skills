Generated from https://www.evtivity.com/docs/csms/ai-workers. Do not edit.

# Background AI Workers

Optional scheduled jobs that summarize your network, find stuck sessions, and check tariffs. They propose actions but never act on their own.

## Overview

Background AI workers are scheduled jobs that look for problems on your network. They find the facts with database queries, and AI only writes a short summary or rationale. A worker can propose an action, but it cannot run one. Every proposal waits in the [AI Inbox](https://www.evtivity.com/docs/csms/ai-inbox) until a user confirms it.

Every worker is off by default.

![Background AI workers settings](https://www.evtivity.com/screenshots/csms/settings-ai-workers.png)

## Jobs

| Job | Runs | What it does | Proposes |
|-----|------|--------------|----------|
| **Nightly network summary** | Daily at 05:30 | For each site with activity, compares the last 24 hours with the daily average of the 7 days before: stations online, offline, and faulted, sessions, failed sessions, refused authorizations, and alerts. Writes a short summary per site and one summary of the whole network. | A soft reset for up to 3 online stations per site that have been faulted for more than 6 hours |
| **Stuck sessions** | Every 15 minutes | Finds active sessions that stopped reporting: no meter values or transaction events for the idle time, or on a station that is offline or a connector that reports Available, silent for 15 minutes. | A stop of the session, in the OCPP version of the station |
| **Tariff anomalies** | Daily at 06:00 | Finds sessions billed nothing on a priced tariff, station costs that differ from the CSMS cost, prices per kWh more than 3 times the site's 30-day median, and sessions priced with an inactive tariff. | Nothing. Findings only |

Times follow the system timezone. Summaries and findings appear as [automatic insights](https://www.evtivity.com/docs/csms/ai-insights): **Site summary**, **Network summary**, and **Tariff anomaly**. The network summary is visible only to users with access to every site.

### Stuck Sessions

- The idle time is 90 minutes by default (**Idle time before a session counts as stuck (minutes)**). It always stays at least 60 minutes below the stale session timeout, so a proposal comes before the CSMS ends the session on its own.
- A session that already has a pending or rejected stop proposal is not proposed again.
- The rationale is a fixed sentence, such as "No meter values or transaction events for 90 minutes". Turn on **Write the rationale with AI** to have AI write it instead.
- A stop proposal expires after 2 hours and runs only if the session is still active.

### Tariff Anomalies

Tariff anomalies never propose anything: changes to prices, billing, and payments are never available to AI. Review the findings and fix the tariff yourself on the [Pricing](https://www.evtivity.com/docs/csms/pricing) page.

## Turn On a Worker

1. Turn on **Turn on system-initiated AI** in **Settings > AI**, under **Automatic insights and workers**. Workers use the same provider and model as automatic insights.
2. Under **Background AI workers**, turn on the jobs you want: **Nightly network summary**, **Stuck sessions**, and **Tariff anomalies**.
3. Optionally set **Proposal lifetime (hours)** (24 by default), the time a network summary proposal stays open.
4. Click **Save**.

## Budgets

Each AI request of a worker counts against the site's daily token budget (**Tokens per site per day (insights and workers)**) and the monthly budgets. When a budget is used up, the worker still stores its findings and proposals, without the AI-written text. See [AI Usage and Budgets](https://www.evtivity.com/docs/csms/ai-usage).

## Data Sent to the AI Provider

A worker sends the facts it found to the selected provider: per-site counts of stations, sessions, refusals, and alerts, the stuck session's station and duration, and the tariff findings. This data leaves your deployment.

## Notes

- A worker never runs an action. Only a user who confirms a proposal in the AI Inbox does, with that user's own permissions.
- Each job runs once per site and period, even with several worker processes.
- Users can get a [daily digest email](https://www.evtivity.com/docs/csms/ai-inbox#daily-digest-email) of pending proposals.
