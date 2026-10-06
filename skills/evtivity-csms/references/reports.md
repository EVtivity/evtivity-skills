Generated from https://www.evtivity.com/docs/csms/reports (website commit 0f3462e). Do not edit.

# Reports

Generate financial, energy, and sustainability reports, with carbon footprint tracking and revenue split by tax.

## Overview

The Reports page generates financial, energy, and compliance reports, schedules recurring sends, and lists past runs. It also includes a sustainability report that tracks the environmental impact of your charging network.

Reports require admin-level access.

![Reports page](https://www.evtivity.com/screenshots/csms/reports.png)

## Report Types

The **Generate** tab builds a report as CSV, PDF, or Excel (XLSX) for a date range and an optional site or station. The **History** tab lists past runs, and the **Schedules** tab sends a report by email daily, weekly, or monthly. Report types: Revenue, Utilization, Energy, Station Health, Sessions, Sustainability, Driver Activity, and NEVI Compliance.

### Money columns

Money columns carry the currency code in the header, for example `Revenue (incl. tax, EUR)`. In CSV files the values are plain decimals (`1234.50`, no currency symbol or grouping), and in XLSX files they are number cells with two decimals, so spreadsheets can sum them. PDF reports format amounts with the currency.

### Revenue report

The Revenue report has a **By Day** and a **By Site** table with these columns:

| Column | Value |
|--------|-------|
| Revenue (incl. tax) | Amounts charged, as the [dashboard](https://www.evtivity.com/docs/csms/dashboard) defines revenue |
| Tax | Tax contained in revenue |
| Revenue (excl. tax) | Revenue minus tax, from the net amount and tax each session stores with its cost |
| Electricity Cost | Wholesale electricity cost from the site rate periods |
| Profit | Revenue (excl. tax) minus electricity cost |
| Sessions | Billed sessions |

The By Site table adds **Energy (kWh)**, and a **Payments** table totals payments by status. The PDF summary lists the same totals.

### Sessions report

One row per session, with **Cost (incl. tax)** (the final cost, or the running cost while the session is active), **Cost Final** (`yes` once the session has its final cost), **Net**, **Tax**, **Tax Rate (%)**, **Refunded**, and **Currency**. Net and tax are the split stored with the session's cost. Each session's amounts are in its own currency.

### Driver Activity report

**Total Spend (incl. tax)** per driver uses the revenue definition: final costs minus refunds.

## Sustainability Report

The sustainability report calculates CO₂ avoided per session by comparing EV charging against gasoline vehicle emissions, accounting for regional grid carbon intensity.

## Carbon Footprint Tracking

Every completed charging session calculates CO₂ avoided using the formula:

```bash
energyKwh = energyDeliveredWh / 1000
gasolineCo2Kg = energyKwh * 0.46
gridCo2Kg = energyKwh * gridCarbonIntensityKgPerKwh
co2AvoidedKg = max(0, gasolineCo2Kg - gridCo2Kg)
```

The constant `0.46 kg CO₂/kWh` represents the gasoline vehicle baseline (EPA estimate). The grid carbon intensity varies by region and is looked up from the site's assigned carbon region.

The result is clamped at zero. When the grid carbon intensity exceeds the gasoline baseline (true for several fossil-heavy grids such as India, Indonesia, Mongolia, and parts of Australia and China) the raw difference is negative; storing or summing a negative "CO₂ avoided" would corrupt dashboard totals and the trees-equivalent computation, so the system records zero instead. Operators in those regions will see no CO₂-avoided credit until grid intensity drops below the baseline.

Trees equivalent is calculated as `co2AvoidedKg / 21.77` (EPA estimate of kg CO₂ absorbed per tree per year).

## Assign a Carbon Region to a Site

Before carbon tracking works, each site needs a carbon region assignment.

1. Navigate to the site detail page.
2. Find the **Carbon Region** dropdown.
3. Select a region from the list. Regions are grouped by country and include:
   - 27 EPA eGRID US subregions (e.g., CAMX, RFCW, SRSO)
   - 33 Ember country-level factors (e.g., Germany, France, United Kingdom)
4. Save. All future sessions at this site will use the selected region's carbon intensity.

To clear a region assignment, select the empty option and save.

## View the Sustainability Report

1. Navigate to **Reports** in the sidebar.
2. The sustainability report loads with the following sections:

| Section | Description |
|---------|-------------|
| Summary cards | Total CO₂ avoided (kg or tonnes), session count, average per session, trees equivalent |
| Monthly trend chart | CO₂ avoided over time, grouped by month |
| Site breakdown table | Per-site CO₂ totals with session counts |

![Sustainability report](https://www.evtivity.com/screenshots/csms/sustainability.png)

## Filter the Report

Use the controls at the top of the report page:

- **Date range**: Set start and end dates to scope the report to a specific period. The date pickers enforce a valid order via `min`/`max` constraints; the API rejects a swapped range with `400 VALIDATION_ERROR` so scripted callers get a clear signal instead of an empty result.
- **Site filter**: Select a single site to view its individual impact.

Filters apply to all sections: summary cards, chart, and breakdown table.

## Export to CSV

1. Set your desired date range and site filter.
2. Click **Export CSV**.
3. The download contains monthly summary rows with CO₂ avoided, session counts, and energy delivered.

The export respects the same filters applied on the page.

## Where Carbon Data Appears

CO₂ avoided values appear throughout the CSMS:

| Location | Display |
|----------|---------|
| Dashboard | CO₂ Avoided stat card with Leaf icon |
| Sessions table | CO₂ Avoided column (right-aligned, green text) |
| Session detail | CO₂ row with Leaf icon |
| Sustainability report | Full breakdown with charts and tables |

Sessions without a carbon region assignment show `--` in the CO₂ column. When a site references a carbon region code that no factor row exists for (a typo, or a factor deleted out-of-band), the projection skips the calculation and emits a warning log with the session, station, and region code so operators can spot and correct the assignment.
