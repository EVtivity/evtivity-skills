Generated from https://www.evtivity.com/docs/csms/dashboard. Do not edit.

# Dashboard

Monitor your charging network with real-time stats, historical snapshots, and trend analysis.

## Overview

The Dashboard is the main landing page of the CSMS. It provides a comprehensive view of your charging network across three display modes: Live, Historical, and Trend. Admin users see the full dashboard with station health, OCPP metrics, financials, and charts. Operator users see a compact view with key stats and an active sessions table.

![Dashboard](https://www.evtivity.com/screenshots/csms/dashboard.png)

## Display Modes

Use the mode toggle at the top of the dashboard to switch between views.

### Live Mode

Live mode shows real-time data from your charging network. Stat cards display current values with day-over-day trend arrows comparing yesterday against the day before yesterday. This avoids comparing an incomplete current day against a full previous day.

Trend arrows use color coding:

| Arrow Color | Meaning |
|-------------|---------|
| Green | Positive change (or negative for metrics where lower is better, like latency) |
| Red | Negative change (or positive for metrics where lower is better) |
| Gray | No change |

Hover (or tap on mobile) a trend arrow to see the exact percentage and date comparison (e.g., "+2.5% (3/12 vs 3/11)").

Trend arrows are suppressed when either reference day has no snapshot data. On the first 1-2 days after a fresh deployment, the day-before-yesterday snapshot does not exist yet, so the cards render without arrows instead of showing a misleading +100% vs an empty baseline. The snapshot endpoint surfaces a `hasData` flag the frontend uses to make this decision.

### Historical Mode

Historical mode displays snapshot data for a selected date or date range. Use the date picker to choose a specific day or a range. The picker's earliest selectable date is the oldest snapshot date on record, so you can't pick pre-history dates that would only render a `No Data` overlay. Snapshots are collected daily by a background worker job and stored per site.

The chart date pickers (energy, sessions, revenue, peak usage, utilization) constrain the **start** input to `max = end` and the **end** input to `min = start`, so the UI cannot produce an inverted range. The API mirrors the rule on its side: a raw caller passing `from > to`, a range longer than 90 days, or a `from` date in the future gets a `400 VALIDATION_ERROR` instead of silently receiving last-7-days data.

When you select a date range, values are aggregated across days. Percentages like uptime use weighted averages based on station count.

The snapshot endpoint returns a `hasData` flag the dashboard uses to decide whether to show the snapshot stat cards or fall back to the live cards under a No Data overlay. Snapshots are populated by a nightly background worker, so a brand-new deployment will not have a snapshot for yesterday until the worker has run at least once.

### Trend Mode

Trend mode shows 14-day sparkline charts for each metric. Each stat card displays a mini chart and the percentage change over the 14-day period.

## Stat Cards

The admin dashboard displays three rows of stat cards.

**Station Health**: Total stations, online percentage, active sessions, energy delivered, faulted stations, total ports.

**OCPP and Infrastructure**: Connected stations, uptime percentage, average ping latency, ping success rate.

**Financials**: **Total Revenue (incl. tax)** and **Today's Revenue (incl. tax)**, transaction count, average revenue per session, **Total Revenue (excl. tax)**, **Total Tax Collected**, total electricity cost, and **Total Profit**, each with a today value. Electricity cost and profit are populated from the per-site electricity rate periods configured on each site's Electricity Rates tab. See [Sites](https://www.evtivity.com/docs/csms/sites) for how to configure rate periods.

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

## Charts

The admin dashboard includes these chart panels:

- **Station Status** - Connector status distribution across your network (available, occupied, charging, faulted, etc.)
- **Utilization** - Per-site utilization rates over a date range
- **Energy History** - Energy delivered over time
- **Session History** - Session count over time
- **Revenue History** - Revenue over time, by the same definition as the revenue cards
- **Payment Breakdown** - Payment status distribution (captured, pending, failed, refunded)
- **Peak Usage** - Heatmap showing sessions by hour and day of week
- **Site Map** - Geographic map of your site locations

## Operator Dashboard

Operator users (non-admin) see a compact dashboard with:

- One row of stat cards: total stations, online stations, active sessions, faulted stations
- Energy chart showing energy delivered over time
- Station status chart showing connector distribution
- Active sessions table with real-time updates

## CO₂ Avoided

When carbon regions are configured on your sites, the dashboard displays a CO₂ Avoided stat card showing the total carbon offset from EV charging sessions.

## Data Filtering

All dashboard data is filtered by your site access permissions. If you have access to specific sites only, the dashboard shows data for those sites. Users with full site access see network-wide aggregations.
