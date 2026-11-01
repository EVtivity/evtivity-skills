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
   Pick the **Site Type**: **Parking Lot** (the default), **Office or Retail**, **Curbside**, **Depot** or **Custom**. It decides how the [layout](#layout) shows the site.
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

Edit the site's name, address, coordinates, contact information, hours of operation and **Site Type**. Hours of operation is a free-form text field displayed in the driver portal's location detail page. Assign a carbon region (EPA eGRID subregion or Ember country-level) for CO₂ tracking on completed sessions.

**Station Display Language** sets the language of the station screens at this site. **Company default** follows the display language under Settings > Integrations & Features > Messages. A change updates the screens of the site's online stations. See [Station display messages](https://www.evtivity.com/docs/guides/station-display-messages).

Contact information has a **Make contact info public** toggle. When off (the default) the contact name, email, and phone are visible only to operators and never to drivers. When on, the same three fields appear on the driver portal's charger and location detail pages, and the operator name is published to OCPI roaming partners. The toggle change is captured in the site audit log so a later compliance query can find when each site started or stopped publishing contact details.

The Details tab also shows a read-only summary of the layout, for example **Parking Lot, 2 x 10 spots, 2 transformers**, **Office or Retail, 12 wall chargers**, **Curbside, 4 + 6 chargers**, **Depot, 6 bus bays, 3 truck lanes** or **Custom, stations placed freely**. It links to the **Layout** tab. Changing the site type moves stations outside the new layout to the nearest free position; a station with no free position left stands off the lot. You need `sites:write` to change the site type.

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

The 3D view shows the site by its site type, drawn with standard real dimensions: 2.6 by 5.5 m spots, a 7 m two-way drive aisle, 2.4 by 6 m parallel spots and 3.5 m travel lanes.

- A **Parking Lot** is an outdoor hub: a paved lot with painted spots and a curb, on grass that fills the whole view at any zoom and angle. The chargers stand at the curb of paired rows. Transformers, batteries, solar canopies and load management panels show only on a Parking Lot, a Depot and a Custom site.
- An **Office or Retail** site is one row of spots along a building, with a sidewalk between them and a drive aisle in front. The building has its windows and an entrance with a canopy. With **Wall** mounting, an AC charger is a wall box on the facade, with its cable across the sidewalk to the car; a DC charger still stands at the curb. With **Stall** mounting, every charger stands on a post at the head of its spot, with its cable straight to the car.
- A **Curbside** site is a street with lane markings, curbs and sidewalks. Cars park parallel to the curb, and the chargers stand on posts at the curb on one or both sides of the street.

![Office or Retail site in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-office-retail.png)

![Curbside site in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-curbside.png)

A **Depot** is a fenced fleet yard for buses and trucks, with a gate at the end of its drive lane. Buses park nose in to a row of straight 4.3 by 14 m bus bays, with their chargers on a strip at the head of the bays. Trucks drive through 5 by 25 m pull-through lanes beside them and never reverse: each lane has its dispenser on an island on the driver's left, as CharIN recommends for drive-through bays (4.7 to 5.05 m wide, charger on the left), and arrows mark the one-way roads into and out of the lanes. A 15 m two-way drive lane runs along the front. One station charges at each bus bay or truck lane:

- A station with a pantograph connector (OCPP connector type **OppCharge**, pantograph down, or **Pan**, pantograph up) shows a depot pantograph pole with its boom over the bay.
- A plug-in DC station in a bus bay shows a dispenser with a cable arm above the bus.
- A DC station in a truck lane shows a megawatt dispenser with its short heavy cable and connector holder.

Like a Parking Lot, a Depot shows transformers, batteries, solar canopies, and load management switchboards and links, on the grass beside the yard. A solar canopy stands where you place it, over staff parking behind the yard until you move it.

In a bus bay or a truck lane, the 3D layout draws the session's vehicle at its real size and in its color: a box truck, a bus, or a semi truck with its trailer. A bus stands nose in. A truck stands in its lane in the driving direction. The charging cable or the pantograph is connected. A car never shows in a bus bay or a truck lane: a bus bay holds a bus or a box truck, and a truck lane a semi truck, a box truck or a bus. A session without such a vehicle shows a bus in a bus bay and a semi truck in a truck lane.

The demo data includes the Depot **Northgate Fleet Depot**, with pantograph poles and plug-in dispensers in its bus bays, megawatt and box truck dispensers in its truck lanes, a substation, a battery and load managed switchboards.

![Northgate Fleet Depot in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-fleet-depot.png)

![A depot pantograph pole over its bus bay](https://www.evtivity.com/screenshots/csms/site-layout-3d-fleet-depot-bus.png)

![A megawatt dispenser at its truck lane](https://www.evtivity.com/screenshots/csms/site-layout-3d-fleet-depot-truck.png)

A **Custom** site has no lot, street or building: the stations stand on grass wherever you place them, each turned its own way, for example along a curved access road. Each station has its own parking spots in front of it on a paved apron, one for each EVSE and two at most, side by side with the charger between them. The spots of two stations may touch but never overlap. Like a Parking Lot, a Custom site shows transformers, batteries, solar canopies, and load management switchboards and links. A solar canopy stands where you place it, and its length follows its peak power.

![Custom site in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-custom.png)

An AC station shows as an **AC Pedestal** (or a wall box or curbside post, as above), a DC station as a **DC Fast Charger**. A station is DC when one of its connectors is DC. The status light on each charger has the color of the station's state. A charging station has a car parked in its spot on the charging cable, and a light around its screen or connector that glows in the charging color. The glow pulses gently, and stays steady when your system reduces motion. A reserved station has a **Reserved** sign on a concrete footing, and a station in maintenance a traffic cone. The back panel of every charger carries your company logo from **Settings** > **Company**, or stays plain without one. Drag to rotate, scroll or pinch to zoom, and right-drag or two-finger drag to pan along the ground. **Fit to View** brings the site and everything on it back into view. On an Office or Retail site it looks at the lot from the open side, with the building behind it.

A charging car has the body type and color of the session's vehicle: a sedan, hatchback, SUV, pickup truck, van, box truck, bus or semi truck in its color. The layout takes the session's vehicle, else the driver's only vehicle, else the vehicle the driver used last. Without a vehicle, color or body type it shows a grey sedan. The color and body type show with `sessions:read`, also without `drivers:read`; the make, model and license plate never show on the layout.

Click **Full Screen** to fill the screen with the 3D view. The labels, popups, summary chip, station list and day replay bar all work in full screen. Press Escape or click **Exit Full Screen** to return. On an iPhone, the view fills the browser window instead.

![Site layout in full screen](https://www.evtivity.com/screenshots/csms/site-layout-3d-full-screen.png)

Each station label shows the station ID followed by its state in the state's color, for example **CS-0981 · Charging**. When several states apply, the label shows the first in this order: **Faulted**, **Unavailable**, **In Maintenance**, **Offline**, **Reserved**, **Charging**, **Available**. A **4G** badge marks a station with a cellular connection: its data plan is **Cellular**, or a SIM attachment is confirmed on it.

The layout updates live. Station states, connector statuses, charging, power, sessions, faults and AI insights change as they happen, without a reload. A faulted station carries a red beacon on a short mast above the charger. The beacon pulses, and stays steady when your system reduces motion. A station with an open AI insight gets a small sparkle marker beside its label. Click the marker to open the newest insight. You need `aiInsights:read` to see the markers.

The summary chip in the corner of the view counts the **Faulted**, **Offline** and **Charging** stations. Click a count to turn the view to the next station in that state and open its details. The list button at the top right (**Show Station List**) opens a list of every station with its ID, state, power now, session energy and driver name. Choose a station to turn the view to it and open its details. The list works with the keyboard, where Up and Down move between stations, and with screen readers.

A charging car carries its driver's avatar above it. Click the avatar to open the session: the driver's avatar and name, the energy and cost so far, the duration, the station, **Open Session** and **Open Driver**. The energy and cost update live. You need `sessions:read` to see session data. Without it, the car shows a plain marker that opens nothing. You need `drivers:read` to see the driver's name and avatar. Without it, the session shows a person icon instead. An avatar that would cover a station label moves higher, or hides when there is no room.

On a Parking Lot, transformers stand on the grass next to the lot, each with its name and rated kVA when you set them. They are for information only and link to nothing. A site that never saved its layout shows one transformer. Office or Retail and Curbside sites show no transformers. The ones you set are kept and show again when you switch the site back to Parking Lot.

Batteries and solar canopies show the storage and solar the site has, on a Parking Lot. They are for information only and show no live data. A battery is a container cabinet on a pad on the grass. A solar canopy is a carport roof over one row of the lot. Office or Retail and Curbside sites show neither. They are kept and show again when you switch the site back to Parking Lot. Each one has a label with its name and its capacity in kWh or kWp.

When the site's load management is on, a Parking Lot shows each load management panel as a switchboard cabinet on a concrete pad, with its name, breaker amps and limit, in a row on the grass left of the lot. A sub-panel stands next to its parent. The panels are placed automatically. Glowing links run from a panel to its sub-panels and its circuits, and from a circuit to each of its stations. The labels show the circuit limits (breaker amps and kW) and each station's allocated limit. The links move gently unless your system reduces motion. A site without load management shows no panels and no links. Panels and links never take a click or a drag. On Office or Retail and Curbside sites the panels sit behind walls or in cabinets, so the layout shows no panels or links; the station details show the **Allocated Limit**.

The links also show live power. A station link carries the station's draw, a circuit link the sum of its stations, and a panel link everything under it. A link grows brighter and thicker as its share of the limit grows. Each panel label carries a bar of its live draw against its limit. The bar is green below 80 percent of the limit, amber from 80 percent (near the limit) and red from 100 percent (at the limit).

A payment terminal paired to a station shows as a small card reader on the front of the charger, on every site type: on the left for connector 1, on the right for connector 2, and in the middle when it is paired to the whole station. A reader with its own screen (VP6825) shows the screen; a VP7200 shows its contactless area. The light on the reader is green while it is online and grey otherwise. Click the reader to open its station. You need `paymentTerminals:read` to see terminals.

Click a station or its label to open its details. The 2D and 3D views show the same popup: the model with **DC Fast**, **Level 2**, **Level 1** or **AC**, the **Status** and its **Reason**, the **Power** now and the maximum, the **Allocated Limit** when load management sets one, the **Session Energy**, the **Connection** (with the signal for a cellular station), the display message, and each connector with its state. **Open Station** goes to the station page. Press Escape to close the popup. The popup also lists the payment terminals paired to the station, each with its connector and whether it is online.

![Station details in the 3D layout](https://www.evtivity.com/screenshots/csms/site-layout-3d-popup.png)

A lit charger shows its station's display message on its screen: the large screen of a DC charger or the small screen of an AC charger. It is the same active message as in the details popup, and it changes live. A short message fits on the screen. A longer one scrolls across it, and stays still when your system reduces motion. Up close the text is readable, and from far away the screen glows.

![Display message on a charger screen](https://www.evtivity.com/screenshots/csms/site-layout-3d-screen-message.png)

The 2D view shows each station as a card with the same state icon and **4G** badge. Click + on a card to open the same details popup as in the 3D view. The dashed area holds the spots of the layout, and cards stay inside it. On an Office or Retail site, a bar along the top edge marks the building. On a Curbside site, a street runs between the left side (top row) and the right side (bottom row).

![Site layout in 2D](https://www.evtivity.com/screenshots/csms/site-layout-tab.png)

On a Custom site, the 2D view draws every station's spots from above, placed and turned as in 3D, with a chip at the charger that opens the details. When the site is load managed, the **Power Draw** strip sits above the board and never covers a station.

![Custom site in 2D](https://www.evtivity.com/screenshots/csms/site-layout-2d-custom.png)

On a Depot, the 2D view draws the yard from above: the bus bays, the truck lanes with their islands and arrows, the roads, the drive lane and the gate. Each station's chip stands in its bus bay or at its lane's dispenser and opens the details. With `sites:write`, drag a chip to another free bay or lane, or select it and use the arrow keys: left and right along its row, up and down between the bus bays and the truck lanes.

![Depot in 2D](https://www.evtivity.com/screenshots/csms/site-layout-2d-fleet-depot.png)

Click **Replay Day** to see the layout as it was at any moment of a past day, in the 3D and the 2D view. Pick a day from today back 90 days. The day runs in the site's time zone. Drag the timeline slider to a time of day, or click **Play**. The speed sets how many minutes of the day pass each second: 5, 15 or 60. The replay shows each station's online state, connector statuses, session energy and power, averaged over 5 minutes. Data that exists only live does not show: the display message, maintenance, sessions and drivers, and AI insights. A replay of today stops at the current time. **Edit Layout** is hidden while you replay. Click **Back to Live** to return to the live layout.

Sites of 100 to 200 stations stay smooth to rotate and zoom. On a site of 40 or more stations, the labels and avatars of stations far from the view hide until you zoom closer.

When labels crowd each other, the selected station places its label first, then faulted, then charging stations. A label without room becomes a small dot in its state's color. Click a dot to open the station's details. On a phone, the labels of far stations also show as dots, and **Fit to View** frames the busiest part of a wide site, such as an Office or Retail row or a street, so the stations stay readable. Click **Fit to View** again, or zoom out, to see the whole site.

To move stations, click **Edit Layout** in the 3D view, or drag the cards in the 2D view. In 3D, the outlined spots show where a station can go, and a station snaps to the nearest free spot of the layout and never lands on another station. On a Parking Lot or a Depot, drag a transformer or a battery to move it on the grass. Click **Done Editing** to leave edit mode. Moves stay pending until you click **Save**, which stores them and leaves edit mode. When the save fails, edit mode stays on with your changes, and the error shows above the layout. **Reset** drops them. You need `sites:write` to edit the layout.

In edit mode, the **Site Settings** panel shows the **Site Type** with a link to the **Details** tab, where you change it, and only the settings of that type. Spot sizes are standard and have no settings.

- **Parking Lot**: **Spots per Row** and **Rows** (1 to 100 each) and **Facing** (0°, 90°, 180° or 270°, which turns the rows and chargers). Under **Transformers**, click **Add Transformer** and give each one an optional name and **Rated kVA**, or remove it. Under **Batteries and Solar**, click **Add Battery** or **Add Solar Canopy**. Give each one an optional name and a **Capacity (kWh)** for a battery or a **Peak Power (kWp)** for a canopy, pick the canopy's **Row**, or remove it.
- **Office or Retail**: **Chargers**, the number of charger positions along the building, one spot each (1 to 100; until you set it, one per station at the site), and **Charger Mounting**: **Wall** (the default) or **Stall**.
- **Curbside**: **Chargers on the Left Side** and **Chargers on the Right Side** (0 to 100 each, at least 1 in all), left and right as seen driving along the street.
- **Depot**: **Bus Bays** and **Truck Lanes** (0 to 100 each, at least 1 in all; until you set them, one bus bay for each station at the site without a Megawatt Charging System (MCS) connector and one truck lane for each station with one), and **Facing**. **Transformers** and **Batteries and Solar** work as on a Parking Lot, and a solar canopy has no row.
- **Custom**: no counts. **Transformers** and **Batteries and Solar** work as on a Parking Lot, and a solar canopy has no row.

The values of the other site types are kept, and come back when you switch the type back. The 3D view shows every change at once, and **Save** stores it with the station moves. A site that never saved its layout is a Parking Lot with 2 rows of 10 spots, grown to hold the stations it already has.

When you make the layout smaller, a station outside it moves to the nearest free position, and the save stores its new place. When the layout has fewer positions than the site has stations, **Save** is not available until you add positions. A transformer or a battery that would stand on the lot moves to the grass beside it. A solar canopy over a row the lot no longer has moves to the last row.

A new station, an imported station and a station moved to this site get the first free position of the layout automatically. When every position is taken, the station stands off the lot until you move it or add positions.

On a Custom site, drag a station anywhere in 3D. It snaps to 0.5 m steps, and dashed guides show when it lines up with another station. Click a station, or Tab to its label, to select it. Drag the ring handle in front of its spots to turn it in 15° steps, or hold Shift to turn it to any angle. Press R to turn the selected station by 15°, Shift+R by 1°, and the arrow keys to move it by 0.5 m. A station whose spots would overlap another station's goes back where it was, and a note says why. Drag transformers, batteries and solar canopies anywhere. Select a canopy and press R to turn it. In the 2D view, drag a station, or select it and use the same keys. A new station stands to the right of the others until you move it. When you switch a site to Custom, every station keeps its place, and a station whose spots would overlap a neighbor's slides along its row until they are free. When you switch the site back, the stations return to their spots.

![Editing a Custom site in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-custom-edit.png)

On a Depot, drag a station in 3D to another bus bay or truck lane. It snaps to the nearest free one. When you switch a site to Depot, the stations with a Megawatt Charging System (MCS) connector move into the truck lanes and the others into the bus bays. A new station takes a free spot of its own kind first.

![Site Settings of a Depot](https://www.evtivity.com/screenshots/csms/site-layout-3d-fleet-depot-settings.png)

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
