Generated from https://www.evtivity.com/docs/portal/activity. Do not edit.

# Activity

View charging history with cost, energy, and distance metrics by month.

## Overview

The Activity tab is the second item in the portal's bottom navigation (Home, Activity, Charge, Account). It shows your charging history organized by month with summary metrics and a session list.

![Activity page](https://www.evtivity.com/screenshots/portal/activity.png)

## Page Layout

The page is organized top to bottom:

### Monthly Statement Banner

A card at the top linking to the itemized statement page for the selected month. Tap the banner or navigate directly to `/activity/statement?month=YYYY-MM` to open the statement.

### Month Selector

Left and right arrows with an uppercase month label (for example, JANUARY 2026). Tap the arrows to move between months. The selector wraps around - navigating past December moves to January of the next year, and navigating before January moves to December of the previous year.

### Donut Chart

A circular chart displaying the selected metric value in the center with an animated transition when switching metrics or months.

### Metric Toggle

Three segments below the donut chart: **Cost**, **Energy**, and **Distance**. Tap a segment to switch the donut chart to that metric.

- **Cost** - total charging cost for the selected month, tax included, formatted as currency
- **Energy** - total energy consumed in kWh
- **Distance** - estimated miles driven, calculated from energy using your vehicle's efficiency (mi/kWh)

If you have not added a vehicle, the Distance metric uses a default efficiency of 3.5 mi/kWh. See [Vehicles](https://www.evtivity.com/docs/portal/vehicles) for details on how miles are calculated.

### Session List

Each row in the session list shows:

- **Status dot** - color-coded by session status
- **Station ID** - the identifier of the station used
- **Site name** - the location name
- **Date and time** - when the session occurred
- **Energy** - total kWh delivered
- **Cost** - total session cost, followed by "incl. tax" when the session's tariff has tax

Tap any session row to view the full session detail page.

## Session Status Dots

The colored dot on each session row indicates its status:

| Color  | Status    |
|--------|-----------|
| Green  | Active    |
| Gray   | Completed |
| Red    | Failed    |
| Amber  | Pending   |

## Monthly Statement

The Monthly Statement provides an itemized breakdown of all sessions for the selected month. Access it from the banner card on the Activity page.

The statement table includes the following columns:

- **Date** - session date and time
- **Location** - site name where the session occurred
- **Energy** - kWh delivered during the session
- **Duration** - how long the session lasted
- **Miles** - estimated miles driven (based on vehicle efficiency)
- **Cost** - total cost of the session. The column reads **Cost (incl. tax)** when a session cost includes tax.

A totals row at the bottom sums each column for the month.

## Notes

- Activity data is only available for authenticated drivers. Guest sessions do not appear here.
- Distance calculations depend on your vehicle efficiency setting. See [Vehicles](https://www.evtivity.com/docs/portal/vehicles).
- Sessions are grouped by the month in which they started.
- The Activity page loads session data for the selected month on each navigation.
