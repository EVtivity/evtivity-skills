Generated from https://www.evtivity.com/docs/csms/sites (website commit 4cd1866). Do not edit.

# Sites

Create and manage physical locations where charging stations are deployed.

## Overview

A site represents a physical location (parking garage, office building, retail center) where one or more charging stations are installed. Sites hold address information, coordinates, hours of operation, and configuration for features like free vend, load management, carbon tracking, pricing, and electricity cost.

![Sites list](https://www.evtivity.com/screenshots/csms/sites-list.png)

## Create a Site

1. Navigate to **Sites** in the sidebar.
2. Click **Create Site**.
3. Fill in the required fields: name and address.
4. Optionally add coordinates (latitude/longitude) for map display, contact information, and hours of operation.
5. Click **Create**.

![Create site](https://www.evtivity.com/screenshots/csms/sites-create.png)

## Site Detail

Click any site in the list to open the detail page. The site detail page has the following tabs.

![Site detail](https://www.evtivity.com/screenshots/csms/site-detail.png)

### Details

Edit the site's name, address, coordinates, contact information, and hours of operation. Hours of operation is a free-form text field displayed in the driver portal's location detail page. Assign a carbon region (EPA eGRID subregion or Ember country-level) for CO₂ tracking on completed sessions.

**Station Display Language** sets the language of the station screens at this site. **Company default** follows the display language under Settings > Integrations & Features > Messages. A change updates the screens of the site's online stations. See [Station display messages](https://www.evtivity.com/docs/guides/station-display-messages).

Contact information has a **Make contact info public** toggle. When off (the default) the contact name, email, and phone are visible only to operators and never to drivers. When on, the same three fields appear on the driver portal's charger and location detail pages, and the operator name is published to OCPI roaming partners. The toggle change is captured in the site audit log so a later compliance query can find when each site started or stopped publishing contact details.

### Metrics

Site performance metrics including total stations, uptime percentage, utilization, total sessions, and energy delivered, plus **Total Revenue (incl. tax)**, **Revenue (excl. tax)**, **Tax Collected**, electricity cost, and **Profit** (revenue excluding tax minus electricity cost). Revenue follows the [dashboard definition](https://www.evtivity.com/docs/csms/dashboard): final costs of ended sessions and reservation fees charged at the site, minus refunds.

![Site metrics tab](https://www.evtivity.com/screenshots/csms/site-metrics-tab.png)

### Sessions

Paginated list of all charging sessions across stations at this site. Filterable by status and date range.

![Site sessions tab](https://www.evtivity.com/screenshots/csms/site-sessions-tab.png)

### Stations

List of all charging stations at this site with their online/offline status, station status, connector counts, and model information. Hover a status badge to see the reason a station is unavailable or faulted.

![Site stations tab](https://www.evtivity.com/screenshots/csms/site-stations-tab.png)

### Layout

Visual layout or map of the site showing station placement and EVSE locations.

![Site layout tab](https://www.evtivity.com/screenshots/csms/site-layout-tab.png)

### Load Management

Configure site-level power limits for dynamic load distribution. Set the maximum site power capacity, configure panels and circuits, and add unmanaged loads. The system distributes available power to active sessions based on the allocation strategy (equal share or priority-based). See [Load Management](https://www.evtivity.com/docs/csms/load-management) for details.

![Site load management tab](https://www.evtivity.com/screenshots/csms/site-load-management-tab.png)

### QR Codes

Generate and download QR codes for all stations and EVSEs at this site. QR codes link to the driver portal charging flow.

![Site QR codes tab](https://www.evtivity.com/screenshots/csms/site-qr-codes-tab.png)

### Pricing

Assign a pricing group to the site. All stations at this site inherit the assigned pricing unless they have a station-level or driver-level pricing override. See [Pricing](https://www.evtivity.com/docs/csms/pricing) for the priority system.

![Site pricing tab](https://www.evtivity.com/screenshots/csms/site-pricing-tab.png)

### Electricity Rates

Record your wholesale cost of electricity for this site so the dashboard can report electricity cost and profit alongside revenue. Add one or more rate periods. Each period has a name, a rate in dollars per kWh, and an optional time restriction.

Restriction types:

- **Always (flat rate)** - a flat rate that applies whenever no more specific period matches. Use a single Always period for a simple flat rate.
- **Time of day** - applies during a daily time window. Windows that cross midnight (for example 22:00 to 06:00) are supported.
- **Day and time** - applies during a time window on the selected days of the week.
- **Date range** - a seasonal rate that applies between two calendar dates (MM-DD). Ranges that wrap the year end (for example 11-01 to 03-31) are supported.

When a session ends, the system resolves the period that matches the session end time in the site's timezone and stores the electricity cost (energy delivered multiplied by the rate). More specific periods win: date range, then day and time, then time of day, then the Always default. The cost is computed once at session end and is never backfilled onto historical sessions. If no period matches or the lookup fails, the session still completes normally with no electricity cost recorded.

Electricity cost and profit (revenue excluding tax minus electricity cost) appear on the dashboard financial cards, the site and station Metrics tabs, and the session list and detail pages.

![Site electricity rates tab](https://www.evtivity.com/screenshots/csms/site-electricity-rates-tab.png)

### Reservations

Available when reservations are enabled in settings. View and manage reservations across all stations at this site.

![Site reservations tab](https://www.evtivity.com/screenshots/csms/site-reservations-tab.png)

### Free Vend

Toggle free vend mode to allow charging without driver identification or payment. When enabled:

- The authorize handler accepts any token immediately, skipping validation.
- Sessions skip driver resolution and payment processing.
- OCPP configuration templates are auto-created and pushed to online stations to enable plug-and-charge behavior.

Stations that support OCPP 2.1 receive `AuthCtrlr.Enabled=false` and `TxCtrlr.TxStartPoint=EVConnected`. OCPP 1.6 stations receive best-effort configuration keys. You can edit the generated config templates to add vendor-specific keys.

Disabling free vend sets the database flag to false but does not push configuration changes to stations.

![Site free vend tab](https://www.evtivity.com/screenshots/csms/site-free-vend-tab.png)

### Maintenance

Schedule maintenance windows for the site. During an active window, affected stations are set Inoperative via OCPP, station displays show a maintenance message, overlapping reservations are cancelled, and in-progress sessions can be gracefully stopped. See [Maintenance Mode](https://www.evtivity.com/docs/csms/maintenance) for details.

![Site maintenance tab](https://www.evtivity.com/screenshots/csms/site-maintenance.png)

### History

Per-site audit trail. Every operator-initiated change to the site is recorded with the actor, the before/after state, and a timestamp.

![Site history tab](https://www.evtivity.com/screenshots/csms/site-history-tab.png)
