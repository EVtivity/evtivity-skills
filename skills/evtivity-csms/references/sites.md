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

The **AI Insights** row shows whether [automatic AI insights](https://www.evtivity.com/docs/csms/ai-insights) watch the site: **In Scope**, **Off** with the reason, or **Suppressed** with **Until** and the end date or **Until resumed**, who suppressed them and why. **Off** means the site is outside the AI insights scope, or system-initiated AI is off: the reason names which, with a link to the **AI Insights Scope** card in [Settings](https://www.evtivity.com/docs/csms/settings#automatic-insights). **Suppress** shows only for a site in the scope. Users with the `sites:write` permission click **Suppress**, enter a reason and an optional end date, and confirm. While the site is suppressed:

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

The **Layout** tab shows where the site's stations stand. Switch between the **3D** and **2D** views in the tab header. **3D** is the default, and the browser remembers your choice.

![Site layout in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d.png)

The 3D view shows the site by its site type. A **Parking Lot** is an outdoor hub: a paved lot with painted spots and a curb, on grass that fills the whole view at any zoom and angle. An **Office or Retail** site is the car park in front of a building: the lot runs along the building front, with a sidewalk between them, and the building has its windows and an entrance with a canopy. An AC station shows as an **AC Pedestal** at the curb, and on an Office or Retail site as a wall box on the building facade when it stands in the row along the building. A DC station shows as a **DC Fast Charger**. A station is DC when one of its connectors is DC. The status light on each charger has the color of the station's state. A charging station has a car parked in its spot on the charging cable, nose to the charger, and a light around its screen or connector that glows in the charging color. The glow pulses gently, and stays steady when your system reduces motion. A reserved station has a **Reserved** sign on a concrete footing, and a station in maintenance a traffic cone. The back panel of every charger carries your company logo from **Settings** > **Company**, or stays plain without one. Drag to rotate, scroll or pinch to zoom, and right-drag or two-finger drag to pan along the ground. **Fit to View** brings the lot and everything on it back into view. On an Office or Retail site it looks at the lot from the open side, with the building behind it.

Each station label shows the station ID followed by its state in the state's color, for example **CS-0981 · Charging**. When several states apply, the label shows the first in this order: **Faulted**, **Unavailable**, **In Maintenance**, **Offline**, **Reserved**, **Charging**, **Available**. A **4G** badge marks a station with a cellular connection: its data plan is **Cellular**, or a SIM attachment is confirmed on it.

The layout updates live. Station states, connector statuses, charging, power, sessions, faults and AI insights change as they happen, without a reload. A faulted station carries a red beacon on a short mast above the charger. The beacon pulses, and stays steady when your system reduces motion. A station with an open AI insight gets a small sparkle marker beside its label. Click the marker to open the newest insight. You need `aiInsights:read` to see the markers.

The summary chip in the corner of the view counts the **Faulted**, **Offline** and **Charging** stations. Click a count to turn the view to the next station in that state and open its details. The list button at the top right (**Show Station List**) opens a list of every station with its ID, state, power now, session energy and driver name. Choose a station to turn the view to it and open its details. The list works with the keyboard, where Up and Down move between stations, and with screen readers.

A charging car carries its driver's avatar above it. Click the avatar to open the session: the driver's avatar and name, the energy and cost so far, the duration, the station, **Open Session** and **Open Driver**. The energy and cost update live. You need `sessions:read` to see session data. Without it, the car shows a plain marker that opens nothing. You need `drivers:read` to see the driver's name and avatar. Without it, the session shows a person icon instead. An avatar that would cover a station label moves higher, or hides when there is no room.

On a Parking Lot, transformers stand on the grass next to the lot, each with its name and rated kVA when you set them. They are for information only and link to nothing. A site that never saved its layout shows one transformer. An Office or Retail site shows no transformers. The ones you set are kept and show again when you switch the site back to Parking Lot.

Batteries and solar canopies show the storage and solar the site has. They are for information only and show no live data. A battery is a container cabinet on a pad on the grass, on both site types. A solar canopy is a carport roof over one row of a Parking Lot. An Office or Retail site shows no solar canopies. They are kept and show again when you switch the site back to Parking Lot. Each one has a label with its name and its capacity in kWh or kWp.

When the site's load management is on, each load management panel shows as its own model with its name, breaker amps and limit: on a Parking Lot a switchboard cabinet on a concrete pad, in a row on the grass left of the lot, and on an Office or Retail site a panel on the building facade left of the first spot. A sub-panel stands next to its parent. The panels are placed automatically. Glowing links run from a panel to its sub-panels and its circuits, and from a circuit to each of its stations. The labels show the circuit limits (breaker amps and kW) and each station's allocated limit. The links move gently unless your system reduces motion. A site without load management shows no panels and no links. Panels and links never take a click or a drag.

The links also show live power. A station link carries the station's draw, a circuit link the sum of its stations, and a panel link everything under it. A link grows brighter and thicker as its share of the limit grows. Each panel label carries a bar of its live draw against its limit. The bar is green below 80 percent of the limit, amber from 80 percent (near the limit) and red from 100 percent (at the limit).

A payment terminal paired to a station shows as a small card reader on the front of the charger: on the left for connector 1, on the right for connector 2, and in the middle when it is paired to the whole station. A reader with its own screen (VP6825) shows the screen; a VP7200 shows its contactless area. The light on the reader is green while it is online and grey otherwise. Click the reader to open its station. You need `paymentTerminals:read` to see terminals.

Click a station or its label to open its details. The 2D and 3D views show the same popup: the model with **DC Fast**, **Level 2**, **Level 1** or **AC**, the **Status** and its **Reason**, the **Power** now and the maximum, the **Allocated Limit** when load management sets one, the **Session Energy**, the **Connection** (with the signal for a cellular station), the display message, and each connector with its state. **Open Station** goes to the station page. Press Escape to close the popup. The popup also lists the payment terminals paired to the station, each with its connector and whether it is online.

![Station details in the 3D layout](https://www.evtivity.com/screenshots/csms/site-layout-3d-popup.png)

The 2D view shows each station as a card with the same state icon and **4G** badge. Click + on a card to open the same details popup as in the 3D view. The dashed area is the parking lot, and cards stay inside it. On an Office or Retail site, a bar along the top edge of the lot marks the building.

![Site layout in 2D](https://www.evtivity.com/screenshots/csms/site-layout-tab.png)

Click **Replay Day** to see the layout as it was at any moment of a past day, in the 3D and the 2D view. Pick a day from today back 90 days. The day runs in the site's time zone. Drag the timeline slider to a time of day, or click **Play**. The speed sets how many minutes of the day pass each second: 5, 15 or 60. The replay shows each station's online state, connector statuses, session energy and power, averaged over 5 minutes. Data that exists only live does not show: the display message, maintenance, sessions and drivers, and AI insights. A replay of today stops at the current time. **Edit Layout** is hidden while you replay. Click **Back to Live** to return to the live layout.

Sites of 100 to 200 stations stay smooth to rotate and zoom. On a site of 40 or more stations, the labels and avatars of stations far from the view hide until you zoom closer.

To move stations, click **Edit Layout** in the 3D view, or drag the cards in the 2D view. In 3D, the outlined spots show where a station can go, and a station snaps to the nearest free spot of the lot and never lands on another station. Drag a transformer or a battery to move it on the grass. Click **Done Editing** to leave edit mode. Moves stay pending until you click **Save**, which stores them and leaves edit mode. When the save fails, edit mode stays on with your changes, and the error shows above the layout. **Reset** drops them. You need `sites:write` to edit the layout.

In edit mode, the **Site Settings** panel sets the site: **Site Type** (**Parking Lot** or **Office or Retail**), **Spots per Row** and **Rows** (1 to 100 each), **Spot Width** (2 to 6 m), **Spot Depth** (4 to 10 m), **Lane Width** between two rows (0 to 15 m, 0 puts the rows back to back) and **Facing** (0°, 90°, 180° or 270°, which turns the rows and chargers, and the building with them). On a Parking Lot, under **Transformers**, click **Add Transformer** and give each one an optional name and **Rated kVA**, or remove it. Under **Batteries and Solar**, click **Add Battery** or, on a Parking Lot, **Add Solar Canopy**. Give each one an optional name and a **Capacity (kWh)** for a battery or a **Peak Power (kWp)** for a canopy, pick the canopy's **Row**, or remove it. The 3D view shows every change at once, and **Save** stores it with the station moves. A site that never saved its lot is a Parking Lot with 2 rows of 10 spots of 3.2 by 5.6 m with a 6 m lane, grown to hold the stations it already has.

When you make the lot smaller, a station outside it moves to the nearest free spot inside, and the save stores its new place. When the lot has fewer spots than the site has stations, **Save** is not available until you add spots or rows. A transformer or a battery that would stand on the lot moves to the grass beside it. A solar canopy over a row the lot no longer has moves to the last row.

A new station, an imported station and a station moved to this site get the first free spot of the lot automatically. When every spot is taken, the station stands on the grass below the lot until you move it or make the lot larger.
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
- **Monthly token budget**: leave it empty to use the default site budget from **Settings > AI > Usage and Limits**. 0 means no limit.

![Site AI tab](https://www.evtivity.com/screenshots/csms/site-ai-tab.png)

The tab shows to users with the `aiUsage:read` permission, and to users with access to every site and the `sites:write` permission. The token figures need `aiUsage:read`. Only users with access to every site and `sites:write` can change the budget. Whether [automatic insights](https://www.evtivity.com/docs/csms/ai-insights) analyze the site is set in the **AI Insights Scope** card of **Settings > AI > Automatic Insights** (see [Settings](https://www.evtivity.com/docs/csms/settings#automatic-insights)). Users without access to every site see **Only users with access to every site can change this.** See [AI Usage and Budgets](https://www.evtivity.com/docs/csms/ai-usage#site-budget).

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
