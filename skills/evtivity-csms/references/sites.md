Generated from https://www.evtivity.com/docs/csms/sites. Do not edit.

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
   The **Country** field takes an ISO 3166-1 code (for example `US` or `DE`) or an English country name (for example `Germany`).
5. Click **Create**.

![Create site](https://www.evtivity.com/screenshots/csms/sites-create.png)

## Import and Export

**Export CSV** downloads the sites that match the current search and filters, with their stations, EVSEs, and connectors. **Template** downloads an example file. **Import CSV** creates sites by name and, from rows with a station ID, creates stations with their EVSEs and connectors. Turn on **Update existing records** to change sites and stations that already exist. Rows with a station ID need the `stations:write` permission as well as `sites:write`.

## Site Detail

Click any site in the list to open the detail page. The site detail page has the following tabs.

![Site detail](https://www.evtivity.com/screenshots/csms/site-detail.png)

### Details

Edit the site's name, address, coordinates, contact information, and hours of operation. Hours of operation is a free-form text field displayed in the driver portal's location detail page. Assign a carbon region (EPA eGRID subregion or Ember country-level) for CO₂ tracking on completed sessions.

**Station Display Language** sets the language of the station screens at this site. **Company default** follows the display language under Settings > Integrations & Features > Messages. A change updates the screens of the site's online stations. See [Station display messages](https://www.evtivity.com/docs/guides/station-display-messages).

Contact information has a **Make contact info public** toggle. When off (the default) the contact name, email, and phone are visible only to operators and never to drivers. When on, the same three fields appear on the driver portal's charger and location detail pages, and the operator name is published to OCPI roaming partners. The toggle change is captured in the site audit log so a later compliance query can find when each site started or stopped publishing contact details.

To remove an address, coordinate, or contact detail, empty the field and save. A removed contact email or phone no longer appears to drivers. Changes to the name, address, coordinates, timezone, hours, or public contact reach roaming partners right away.

#### Data Plan

The **Data Plan** card sets the data plan of the site's stations: **Not Set**, **Wi-Fi or Wired** or **Cellular**. A station uses, in this order, a plan set on the station, **Cellular** when a SIM attachment is confirmed on it, the site's plan, and **Wi-Fi or Wired**. So the site's plan reaches the stations that have neither their own plan nor a confirmed SIM.

Choose a plan and click **Save**. The confirmation names how many stations change plan. Online stations get the new plan's settings at once, offline stations at their next boot. The change is recorded in the site's **History**. You need `sites:write`, and a user with access to some sites changes only those sites. See [Cellular Stations](https://www.evtivity.com/docs/configuration/cellular-stations#pick-the-cellular-plan) and [Data Usage Defaults](https://www.evtivity.com/docs/configuration/data-usage-defaults).

**Delete** asks for confirmation. A site with stations cannot be deleted. This includes stations deleted from the site, which keep their site for their history: move them to another site first. A site whose payment configuration has payments cannot be deleted either.

The **AI Insights** row shows whether [automatic AI insights](https://www.evtivity.com/docs/csms/ai-insights) watch the site: **In Scope**, or **Suppressed** with **Until** and the end date or **Until resumed**, who suppressed them and why. Users with the `sites:write` permission click **Suppress**, enter a reason and an optional end date, and confirm. While the site is suppressed:

- Every station of the site counts as suppressed, also stations added to the site later.
- The site gets no site-level insight: no site incident, site summary, or tariff anomaly.
- When you suppress, the open insights of the site and its stations are dismissed and their waiting actions expire.

When the end date passes, insights resume on their own. **Resume** brings each station back to its own state: in scope, or still suppressed when the station has its own suppression (see [Stations](https://www.evtivity.com/docs/csms/stations#details)). An active maintenance event still suppresses the stations it covers, or every station of the site when it names no stations. The sites list filters by **AI Insights** (**All**, **In Scope**, **Suppressed**) and marks suppressed sites with the **AI Insights Suppressed** badge.

Only operators suppress or resume insights. The AI assistant cannot. The API is `POST /v1/sites/:id/ai-insights/suppress` with a `reason` and an optional `until`, `POST /v1/sites/:id/ai-insights/resume`, and `GET /v1/sites?aiInsights=in_scope` or `suppressed` to filter the list.

![Site with suppressed AI insights](https://www.evtivity.com/screenshots/csms/site-ai-insights-suppressed.png)

![Sites list filtered to suppressed AI insights](https://www.evtivity.com/screenshots/csms/sites-ai-insights-filter.png)

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

When a session ends, the system resolves the period that matches the session end time in the site's timezone and stores the electricity cost (energy delivered multiplied by the rate). More specific periods win: date range, then day and time, then time of day, then the Always default. The cost is computed once at session end, at the period of the end time, for the whole session. A session that ended without a cost keeps none until you recalculate it (see below). If no period matches or the lookup fails, the session still completes normally with no electricity cost recorded.

Electricity cost and profit (revenue excluding tax minus electricity cost) appear on the dashboard financial cards, the site and station Metrics tabs, and the session list and detail pages.

Profit counts only sessions with an electricity cost. A session that delivered energy gets no electricity cost when the site has no rate period, when no period matches its end time (the site has only restricted periods and no Always default), or when its station has no site. Its revenue stays in revenue but is left out of profit, and the dashboard, the Metrics tabs, and the revenue report show how many sessions were left out. The site page warns when the site has no rate period or no default period, and the dashboard lists the sites with sessions left out. Add an Always period to every site so each session gets a cost.

#### Recalculate Electricity Cost

Sessions that ended before a site had rates, or outside every period before you added an Always period, keep no electricity cost. To fill them, click **Recalculate electricity cost** on the Electricity Rates tab and confirm. The same action is on the sessions list filtered to sessions without an electricity cost.

- Each billed session of the site that delivered energy and has no electricity cost gets one from the site's current rate periods, at the period in force when that session ended in the site's timezone, the same way as at session end.
- Existing costs never change. Sessions billed in another currency and sessions of other sites are left alone. Running it again changes nothing.
- Sessions whose end time matches no period keep no cost. The message shown after the run says how many remain.
- Each run that adds costs is recorded in the site's **History** tab with the number of sessions without a cost before and after.
- The action needs permission to edit sites.

![Site without electricity rates](https://www.evtivity.com/screenshots/csms/site-electricity-notice.png)

![Site electricity rates tab](https://www.evtivity.com/screenshots/csms/site-electricity-rates-tab.png)

### Reservations

Available when reservations are enabled in settings. View and manage reservations across all stations at this site.

![Site reservations tab](https://www.evtivity.com/screenshots/csms/site-reservations-tab.png)

### AI Usage

The **AI Usage** tab holds the site's **AI Usage** card:

- **Used** and **Budget**: the site's AI tokens this month against its monthly budget, with the percentage used. When the company currency is USD, the card also shows the cost.
- **Automatic Insights**: turn it off to stop [automatic insights](https://www.evtivity.com/docs/csms/ai-insights) for this site.
- **Monthly token budget**: leave it empty to use the default site budget from **Settings > AI > Usage and Limits**. 0 means no limit.

![Site AI tab](https://www.evtivity.com/screenshots/csms/site-ai-tab.png)

The tab shows to users with the `aiUsage:read` permission, and to users with access to every site and the `sites:write` permission. The token figures need `aiUsage:read`. Only users with access to every site and `sites:write` can change the switch and the budget. Users without access to every site see **Only users with access to every site can change this.** See [AI Usage and Budgets](https://www.evtivity.com/docs/csms/ai-usage#site-budget).

### AI Insights

The **AI Insights** tab lists every [automatic insight](https://www.evtivity.com/docs/csms/ai-insights#ai-insights-tab) of the site, newest first, with its status: site incidents, site summaries, and the insights about its stations, sessions, and reservations. Click a row to open the insight. The tab shows to users with the `aiInsights:read` permission while AI Insights are on. The light bulb button above the assistant button opens this tab.

### Free Vend

Toggle free vend mode to allow charging without driver identification or payment. When enabled:

- The authorize handler accepts any token immediately, skipping validation.
- Sessions skip driver resolution and payment processing.
- OCPP configuration templates are auto-created and pushed to online stations to enable plug-and-charge behavior.

Stations that support OCPP 2.1 receive `AuthCtrlr.Enabled=false` and `TxCtrlr.TxStartPoint=EVConnected`. OCPP 1.6 stations receive best-effort configuration keys. You can edit the generated config templates to add vendor-specific keys.

Turning free vend off pushes authorization back to the online stations. The **Authorization Restore Templates** card links the templates, which hold the values the stations reported when free vend was turned on. See [Free Vend](https://www.evtivity.com/docs/csms/free-vend).

Turning free vend on or off asks for confirmation first.

![Site free vend tab](https://www.evtivity.com/screenshots/csms/site-free-vend-tab.png)

### Maintenance

Schedule maintenance windows for the site. During an active window, affected stations are set Inoperative via OCPP, station displays show a maintenance message, overlapping reservations are cancelled, and in-progress sessions can be gracefully stopped. See [Maintenance Mode](https://www.evtivity.com/docs/csms/maintenance) for details.

![Site maintenance tab](https://www.evtivity.com/screenshots/csms/site-maintenance.png)

### History

Per-site audit trail. Every operator-initiated change to the site is recorded with the actor, the before/after state, and a timestamp.

![Site history tab](https://www.evtivity.com/screenshots/csms/site-history-tab.png)
