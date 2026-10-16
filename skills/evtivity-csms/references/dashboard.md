Generated from https://www.evtivity.com/docs/csms/dashboard. Do not edit.

# Dashboard

Monitor your charging network with real-time stats, historical snapshots, and trend analysis.

## Overview

The Dashboard is the main landing page of the CSMS. It provides a comprehensive view of your charging network across three display modes: Live, Historical, and Trend. Every user sees the same dashboard. The rows you see follow your permissions:

- The financial row, the **Revenue History** chart and the **Payment Breakdown** chart need the payments permission (`payments:read`).
- The **Active Sessions** table needs the sessions permission (`sessions:read`).
- The OCPP ping cards need access to all sites.

![Dashboard](https://www.evtivity.com/screenshots/csms/dashboard.png)

## Display Modes

Use the mode toggle at the top of the dashboard to switch between views.

### Live Mode

Live mode shows real-time data from your charging network. Stat cards display current values with day-over-day trend arrows that compare the last two snapshot days, normally yesterday and the day before. This avoids comparing an incomplete current day against a full previous day.

Trend arrows use color coding:

| Arrow Color | Meaning |
|-------------|---------|
| Green | Positive change (or negative for metrics where lower is better, like latency) |
| Red | Negative change (or positive for metrics where lower is better) |
| Gray | No change |

Hover (or tap on mobile) a trend arrow to see the exact percentage and the two dates it compares (e.g., "+2.5% (3/12 vs 3/11)").

Trend arrows are suppressed when either of the two days has no snapshot data. On the first 1-2 days after a fresh deployment, the earlier snapshot does not exist yet, so the cards render without arrows instead of showing a misleading +100% vs an empty baseline. The snapshot endpoint surfaces a `hasData` flag the frontend uses to make this decision.

Live updates refresh the numbers as stations and sessions change. Today's numbers are live. All-time totals can take up to a minute to reflect a change to an older record, for example a refund on an old session.

### Historical Mode

Historical mode displays snapshot data for a selected date or date range. Use the date picker to choose a specific day or a range. The picker's earliest selectable date is the oldest snapshot date on record, so you can't pick pre-history dates that would only render a `No Data` overlay. Snapshots are collected daily by a background worker job and stored per site.

When you select a date range, values are aggregated across days. Percentages like uptime use weighted averages based on station count.

The snapshot endpoint returns a `hasData` flag the dashboard uses to decide whether to show the snapshot stat cards or fall back to the live cards under a No Data overlay. Snapshots are populated by a nightly background worker. Each run also fills any missing day of the last week, so a missed run leaves no gap. A brand-new deployment will not have a snapshot for yesterday until the worker has run at least once.

### Trend Mode

Trend mode shows 14-day sparkline charts for each metric. Each stat card displays a mini chart and the percentage change over the 14-day period.

## Stat Cards

The dashboard displays three rows of stat cards.

**Station Health**: Total stations, online percentage, active sessions, energy delivered, faulted stations, total ports. **Total Stations** and the online percentage count accepted stations. Pending and blocked stations (see [Onboarding Status](https://www.evtivity.com/docs/csms/stations#onboarding-status)) show as a small note under **Total Stations**.

**OCPP and Infrastructure**: Connected stations, uptime percentage over the last 30 days, average ping latency, ping success rate. The ping cards show only to users with access to all sites.

**Financials**: **Total Revenue (incl. tax)** and **Today's Revenue (incl. tax)**, transaction count, **Revenue/Session**, **Total Revenue (excl. tax)**, **Total Tax Collected**, total electricity cost, and **Total Profit**, each with a today value. This row shows only to users with the payments permission. Electricity cost and profit are populated from the per-site electricity rate periods configured on each site's Electricity Rates tab. See [Sites](https://www.evtivity.com/docs/csms/sites) for how to configure rate periods.

### Card States

Every card and chart shows a loading state while its data loads, an error with a **Retry** button when the data fails to load, or an empty state when there is no data. A card never shows a zero or 100% for data that did not load.

### Revenue

Revenue counts money actually charged, in the company currency:

- The final cost of ended sessions, minus refunds.
- Reservation cancellation and no-show fees charged, minus refunds.
- Active sessions are not counted. Their running cost is an estimate until the session ends.

Revenue includes tax. Every session stores its net amount and tax with its cost, per tariff segment and tax rate, so **Total Revenue (excl. tax)** reads the stored split instead of recomputing it. A partly refunded session and each reservation fee are split at their own tax rate. **Total Tax Collected** is the tax that revenue contains. Tax is owed to the tax authority, so profit is computed from revenue excluding tax:

```
profit = revenue (excl. tax) - electricity cost
```

Profit can be negative. Today's values count sessions started today and fees charged today. Sessions billed in an earlier company currency are left out of revenue totals.

**Revenue/Session** divides the revenue of billed sessions by the number of billed sessions. Reservation fees are left out. Live and historical mode use the same definition.

Profit counts only sessions with an electricity cost. To find the sessions it leaves out, select **Missing** in the electricity cost filter of the [sessions list](https://www.evtivity.com/docs/csms/sessions#session-list). See [Electricity Rates](https://www.evtivity.com/docs/csms/sites#electricity-rates) and [Recalculate Electricity Cost](https://www.evtivity.com/docs/csms/sites#recalculate-electricity-cost). Profit also leaves out the electricity cost of unpaid account (fleet) sessions until their invoice is paid.

## Active Insights

The **Active Insights** card shows below the stat cards, full width. It shows the open and pending [automatic insights](https://www.evtivity.com/docs/csms/ai-insights) of your sites as cards in a row that scrolls sideways: three in view on wide screens, two on medium screens, and one on phones. Dots below the row show the scroll position. Click a dot to scroll to it. Site incidents come first. Click a card to open the insight, or **View All** to open the AI Insights list.

![Active Insights card](https://www.evtivity.com/screenshots/csms/ai-insights-dashboard.png)

The card needs the `aiInsights:read` permission and shows only while AI Insights are on, with **No open insights** when none are open. When AI Insights are off, the dashboard shows no insights, even ones that are still open. See [Active Insights Card](https://www.evtivity.com/docs/csms/ai-insights#active-insights-card).

## Charts

The dashboard includes these chart panels:

- **Station Status** - Connector status distribution across your network (available, occupied, charging, faulted, etc.)
- **Utilization** - Per-site utilization over a date range, measured per charging port in service. It never exceeds 100%.
- **Energy History** - Energy delivered over time
- **Session History** - Session count over time
- **Revenue History** - Revenue over time, by the same definition as the revenue cards (payments permission)
- **Payment Breakdown** - Payment status distribution (captured, pending, failed, refunded) (payments permission)
- **Peak Usage** - Heatmap showing sessions by hour and day of week
- **Site Map** - Geographic map of your site locations

![Top Utilization by Site chart](https://www.evtivity.com/screenshots/csms/dashboard-utilization.png)

### Chart Date Ranges

Chart date ranges are whole calendar days in the system timezone. Days without data show as zero.

The chart date pickers (energy, sessions, revenue, peak usage, utilization) constrain the **start** input to `max = end` and the **end** input to `min = start`, so the UI cannot produce an inverted range. The API mirrors the rule on its side: a zero or negative day count, an invalid custom `from` or `to` date, `from > to`, a range longer than 90 days, or a `from` date in the future gets a `400 VALIDATION_ERROR` instead of silently receiving last-7-days data.

## Active Sessions

Users with the sessions permission see the **Active Sessions** table with real-time updates.

## CO₂ Avoided

When carbon regions are configured on your sites, the dashboard displays a CO₂ Avoided stat card showing the total carbon offset from EV charging sessions.

## Data Filtering

All dashboard data is filtered by your site access permissions. If you have access to specific sites only, the dashboard shows data for those sites. Users with full site access see network-wide aggregations.
