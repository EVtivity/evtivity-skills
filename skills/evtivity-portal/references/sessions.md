Generated from https://www.evtivity.com/docs/portal/sessions (website commit 0f3462e). Do not edit.

# Activity and Sessions

View your monthly charging dashboard, session history, monthly statements, and session detail receipts.

## Overview

The Activity tab is the central hub for your charging history. It shows a monthly dashboard with cost, energy, and distance metrics, a list of your sessions, and downloadable monthly statements.

## Activity Page

Open the Portal and tap the **Activity** tab in the bottom navigation.

![Activity page](https://www.evtivity.com/screenshots/portal/activity.png)

### Monthly Dashboard

The top of the page displays a donut chart with your selected metric for the current month.

1. Use the left and right arrows to navigate between months.
2. Tap the metric toggle to switch between **Cost**, **Energy**, and **Distance**.

| Metric   | Unit  | Source |
|----------|-------|--------|
| Cost     | Company currency | Sum of session final costs for the month, tax included |
| Energy   | kWh   | Sum of energy delivered across all sessions |
| Distance | miles | Estimated from energy and your vehicle's efficiency rating |

Distance estimation uses the efficiency value from your first registered vehicle. If no vehicle is registered, a default of 3.5 mi/kWh is used. You can add vehicles in the **Account** page.

### Carbon Impact

Below the donut chart, a card shows the CO₂ you avoided this month by charging an EV instead of using gasoline. This value is calculated based on the regional carbon intensity assigned to each station's site.

### Monthly Statement Banner

A banner card at the top links to a detailed monthly statement for the displayed month.

## Session List

Below the dashboard, your sessions for the selected month are listed with:

- Status dot (green for active, gray for completed, red for failed, amber for pending)
- Station name and location
- Estimated miles driven
- Session duration
- Total cost, followed by "incl. tax" when the session's tariff has tax

Tap a session to open the session detail page.

![Session list](https://www.evtivity.com/screenshots/portal/sessions.png)

## Monthly Statement

1. Tap the monthly statement banner on the Activity page, or navigate to it directly.
2. The statement shows an itemized table with columns for date, location, energy, duration, estimated miles, and cost. The cost column reads **Cost (incl. tax)** when a session cost includes tax.
3. A footer row shows totals for the month.
4. If carbon tracking is enabled, a CO₂ avoided column appears.

## Session Detail Receipt

Tap any session in the list to view the full receipt.

The session detail page shows:

- **Status badge** - Active, Completed, Failed, or Pending
- **Duration** - Total charging time in hours and minutes
- **Energy delivered** - Total energy in kWh
- **Total cost** - Final cost in the session currency. While the session is active, the row shows the estimated cost. See Cost and tax below.
- **CO₂ avoided** - Carbon savings in kg (when available)
- **Station details** - Station ID, location, connector type
- **Start and end timestamps**
- **Report Issue button** - Opens a new support case pre-filled with the session details (see [Support Cases](https://www.evtivity.com/docs/portal/support-cases))

### Cost and tax

Session costs always include tax. When the tariff has tax, the cost row reads **Total cost (incl. tax)** (or **Estimated cost (incl. tax)** while charging) and the page also shows the tax, as your **Show prices** choice in [Account settings](https://www.evtivity.com/docs/portal/account) sets:

| Show prices | Rows |
|-------------|------|
| Including tax (gross) | **Total cost (incl. tax)**, then **Tax included (19%)** with the tax the total contains |
| Excluding tax (net) | **Net amount (before tax)**, **Tax (19%)**, then **Total cost (incl. tax)** |

The tax comes from the tariff as billed. A session billed across tariffs with different tax rates shows the tax without a percentage. A session without tax shows only **Total cost**.

## Data Formatting

| Data | Format | Example |
|------|--------|---------|
| Cost | Session currency, formatted for your language | $12.50, 12,50 € |
| Energy | 2 decimals + kWh | 45.23 kWh |
| Duration | Hours and minutes | 3h 45m |
| Distance | Whole number + mi | 158 mi |
| Timestamps | M/D/YYYY, h:mm:ss AM/PM | 1/15/2026, 2:30:45 PM |

Null or missing values display as `--`.

## Notes

- The Activity page loads up to 100 sessions per month.
- Distance calculations depend on having a vehicle registered with a known efficiency rating.
- Session costs are stored in cents and shown in the currency the session was billed in.
