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
   Pick the **Site Type**: **Parking Lot** (the default), **Office or Retail**, **Curbside**, **Depot** or **Custom**. It decides how the [layout](#layout) shows the site. For a Parking Lot, also pick the **Charger Placement**: **Islands** (the default) or **Lot Edge**.
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

The Details tab also shows a read-only summary of the layout, for example **Parking Lot, 2 x 10 spots, 2 transformers**, **Office or Retail, 12 wall chargers**, **Curbside, 4 + 6 chargers**, **Depot, 6 bus bays, 3 truck lanes** or **Custom, stations placed freely**. A Parking Lot with Lot Edge adds **chargers along the lot edge**. It links to the **Layout** tab. Changing the site type moves stations outside the new layout to the nearest free position; a station with no free position left stands off the lot. You need `sites:write` to change the site type.

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

The 3D view shows the site by its site type, drawn with standard real dimensions: 2.6 by 5.5 m spots, a 7.3 m (24 ft) two-way drive aisle, 2.4 by 6 m parallel spots and 3.5 m travel lanes.

- A **Parking Lot** is an outdoor hub: a paved lot with painted spots and a curb, on grass that fills the whole view at any zoom and angle. Rows that face each other share a drive aisle. Rows that stand back to back share a raised 2.4 m island, and the chargers of both rows stand on it. The first and the last row have their chargers at the lot edge. The **Charger Placement** on the **Details** tab and the New Site page decides where the chargers go: with **Islands** (the default) they stand on the islands between rows and in the edge rows; with **Lot Edge** only the first and the last row have chargers, along the lot edge, and the inner rows are plain parking. With Lot Edge, the edge nearest the transformer gets the DC chargers, and the AC chargers fill from the far edge. Changing the Charger Placement moves the stations to the new charging spots. Transformers, batteries and solar canopies show only on a Parking Lot, a Depot and a Custom site; load management panels also show on an Office or Retail site.
- An **Office or Retail** site is one row of spots along a building, with a sidewalk between them and a drive aisle in front. The building has its windows and an entrance with a canopy. With **Wall** mounting, an AC charger is a wall box on the facade, with its cable across the sidewalk to the car; a DC charger still stands at the curb. With **Stall** mounting, every AC charger stands on a post on the sidewalk behind the curb at the head of its spot, with its cable straight to the car, and a DC charger stands at the head of its spot.
- A **Curbside** site is a street with lane markings, curbs and sidewalks. Cars park parallel to the curb, and the chargers stand on posts at the curb on one or both sides of the street.

![Office or Retail site in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-office-retail.png)

![Curbside site in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-curbside.png)

A **Depot** is a paved fleet yard for buses and trucks. Buses park nose in to a row of straight 4.3 by 14 m bus bays, with their chargers on a strip at the head of the bays. Trucks drive through 5 by 25 m pull-through lanes beside them and never reverse: each lane has its dispenser on an island on the driver's left, as CharIN recommends for drive-through bays (4.7 to 5.05 m wide, charger on the left), and arrows mark the one-way roads into and out of the lanes. A two-way drive lane runs along the front. The drive lane and the roads are as wide as the design turning radius of the vehicle that turns there (the AASHTO design vehicles): 12.7 m in front of the bus bays for a city bus, 13.7 m in front of the truck lanes and on the truck roads for a tractor-trailer. The radius serves as a minimum width, not as a published lane width, so the yard is no larger than its bays and lanes need. One station charges at each bus bay or truck lane:

- A station with a pantograph connector (OCPP connector type **OppCharge**, pantograph down, or **Pan**, pantograph up) shows a depot pantograph pole with its boom over the bay.
- A plug-in DC station in a bus bay shows a dispenser with a cable arm above the bus.
- A DC station in a truck lane shows a megawatt dispenser with its short heavy cable and connector holder.

Like a Parking Lot, a Depot shows transformers, batteries, solar canopies, and load management switchboards and links. Each transformer and its switchboards stand on the grass right behind the bus bays or truck lanes they feed, and their cables follow the row ends and islands. The yard has no curb, so each transformer, battery and switchboard pad has bollards on the sides that face the yard. On a Parking Lot and a Custom site, whose paving has a curb, a pad gets bollards on a side that stands closer than 5 ft to the paving. A solar canopy stands where you place it, over staff parking behind the yard until you move it.

In a bus bay or a truck lane, the 3D layout draws the session's vehicle at its real size and in its color: a box truck, a bus, or a semi truck with its trailer. A bus stands nose in. A truck stands in its lane in the driving direction. The charging cable or the pantograph is connected. A car never shows in a bus bay or a truck lane: a bus bay holds a bus or a box truck, and a truck lane a semi truck, a box truck or a bus. A session without such a vehicle shows a bus in a bus bay and a semi truck in a truck lane.

The demo data includes the Depot **Northgate Fleet Depot**, with pantograph poles and plug-in dispensers in its bus bays, megawatt and box truck dispensers in its truck lanes, a bus charging transformer and a truck charging transformer, a battery and load managed switchboards. Its chargers are all DC.

The demo data also includes two Parking Lots: **Patroon Creek Charging Plaza**, 4 rows with Islands, its DC fast chargers next to the transformer and its Level 2 chargers in the far rows, and **Harbor Point Charging Hub**, with Lot Edge.

![Northgate Fleet Depot in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-fleet-depot.png)

![A depot pantograph pole over its bus bay](https://www.evtivity.com/screenshots/csms/site-layout-3d-fleet-depot-bus.png)

![A megawatt dispenser at its truck lane](https://www.evtivity.com/screenshots/csms/site-layout-3d-fleet-depot-truck.png)

A **Custom** site has no lot, street or building: the stations stand on grass wherever you place them, each turned its own way, for example along a curved access road. Each station has its own parking spots in front of it on a paved apron, one for each EVSE and two at most, side by side with the charger between them. The charger stands on the apron 0.6 m behind the head of its spots. The spots of two stations may touch but never overlap. Like a Parking Lot, a Custom site shows transformers, batteries, solar canopies, and load management switchboards and links. A solar canopy stands where you place it, and its length follows its peak power. Its columns stand along its back side and move aside, so none stands on a station or its spots.

![Custom site in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-custom.png)

An AC station shows as an **AC Pedestal** (or a wall box or curbside post, as above), a DC station as a **DC Fast Charger**. A station is DC when one of its connectors is DC. Megawatt Charging System (MCS) and pantograph connectors count as DC. A DC station with three or more EVSEs is a split system, as Kempower and other makers build them: one power cabinet beside the switchboards and one slim dispenser per EVSE, each in its own spot, side by side in the DC group. A dispenser with more connectors than EVSEs shows one holstered cable per connector. On a Parking Lot, an AC station with two EVSEs stands on the line between two spots and serves both, with a wheel stop for each spot and a car in each spot that is charging. Spots pair up along each row from the first spot. An AC station with one EVSE keeps its own spot. Where a curb heads its spot, an AC charger stands behind the head of the spot: on the island, behind the curb at the edge of the lot, on the sidewalk of an Office or Retail site, or on the apron of a Custom site's station (a wall box hangs on the facade), so the spot keeps its full 5.5 m depth. In the next to last row of a Parking Lot with an odd number of rows, whose spots face a drive aisle, it stands at the head of its spot, with the wheel stop 3 ft in front of its pad. Every other AC charging spot on a Parking Lot, an Office or Retail site or a Custom site has a concrete wheel stop 0.61 m (2 ft) from the head of the spot, as many municipal parking standards place it, and a parked car stands with its front wheels at the stop. DC chargers keep their bollards instead, and curbside spots and depot bays have no wheel stops. The status light on each charger has the color of the station's state. A charging station has a car parked in its spot on the charging cable, and a light around its screen or connector that glows in the charging color. The glow pulses gently, and stays steady when your system reduces motion. A reserved station and a station in maintenance show a translucent **Reserved** or **Maintenance** overlay over the spot, a marker of the view and not a sign on the site; a station in maintenance also has a traffic cone. Point at the overlay, or tap it, to see the reservation time (with `reservations:read`) or the maintenance window. The back panel of every DC charger and AC pedestal carries your company logo from **Settings** > **Company**, or stays plain without one. The front plate of each charger takes the **AC Charger Plate Color** or the **DC Charger Plate Color** from **Settings** > **Company**, else the **Theme Color**.

The chargers, vehicles and power equipment are generic models of their kind, sized from typical products and not copied from one product. Each connector shows its real type, in its holster and in the car. An idle cable runs in one piece from the charger, loops over a hanger and ends in the handle in its holster. A plugged cable leaves the hanger empty and runs to the charge port of the car, on the ground outside the car. A wall box docks its handle in the middle of its front. A megawatt truck dispenser carries its heavy cable on a cable management arm, which swings toward the truck while it charges. While a connector charges, its cable carries a flowing green light from the charger toward the vehicle. A plugged cable that delivers no power shows no light, and the light stands still when your system reduces motion. A car that is plugged in when its charger faults stays in its spot until the connector is unplugged.

With a mouse, drag to rotate the 3D view, scroll to zoom, and Shift-drag or right-drag to pan. On a trackpad, swipe with two fingers to pan along the ground like a map, and pinch to zoom. On a touch screen, drag to rotate, pinch to zoom and drag with two fingers to pan. You can tilt the view down to eye level; the camera stays at least 1.6 m above the ground. **Fit to View** brings the site and everything on it back into view. On an Office or Retail site it looks at the lot from the open side, with the building behind it. To use the keyboard, click the view or Tab to it first: W, A, S, D or the arrow keys move, Q and E rotate, R and F tilt, + and - (or Page Up and Page Down) zoom, Home fits the view, and holding Shift moves 3 times as far. In **Edit Layout** on a Custom site, while a station or a solar canopy is selected, the arrow keys move it and R turns it. The **Keyboard Controls** button next to the full screen button lists the keys and the mouse and trackpad gestures.

![Keyboard Controls in the 3D layout](https://www.evtivity.com/screenshots/csms/site-layout-3d-keyboard.png)

Each charging stall on a Parking Lot, an Office or Retail site, a Curbside site and the car spots of a Custom site shows a **No Parking Except While Charging** sign, modeled on the US MUTCD R7-113 sign, with its bottom 7 ft above the ground. It stands on a galvanized post set in the ground at the head of the stall, on the facade above a wall box, or on a post along the curb. The text on the sign faces shows in your CSMS language; real signs in the US are in English. A stall off the street at a site in California also shows a tow-away sign below it; a Curbside stall, on a public street, does not. A Depot, a private fleet yard, shows no parking signs. The 2D view is a schematic and shows no signs. The signs show a typical installation; they are not a sign plan for your site.

A Parking Lot and an Office or Retail site show one accessible charging space, after the US Access Board guidance for accessible EV charging: the station spot at the end of a group of charging spots, nearest the electrical equipment, gets a wider vehicle space and a striped 5 ft (60 in) access aisle in the spot beside it. A new station placed automatically continues the group past the aisle, and the accessible space moves to the group's new end, so no empty spot stays inside a group. The space shows no International Symbol of Accessibility sign, which the Access Board does not recommend at EV charging spaces unless a state or local code requires it. A Depot, a Custom site and a Curbside site show none. It shows where such a space could go; it is not an accessibility plan for your site.

A charging car has the body type and color of the session's vehicle: a sedan, hatchback, SUV, pickup truck, van, box truck, bus or semi truck in its color. The layout takes the session's vehicle, else the driver's only vehicle, else the vehicle the driver used last. Without a vehicle, color or body type it shows a grey sedan. The color and body type show with `sessions:read`, also without `drivers:read`; the make, model and license plate never show on the layout.

Click **Full Screen** to fill the screen with the 3D view. The markers, popups, summary chip, station list and day replay bar all work in full screen. Press Escape or click **Exit Full Screen** to return. On an iPhone, the view fills the browser window instead.

![Site layout in full screen](https://www.evtivity.com/screenshots/csms/site-layout-3d-full-screen.png)

Each station shows its state icon above it on a solid white round background, without a border, on every site type and at any number of stations; the 2D cards show the state with a colored bar and a status badge. The markers and avatars shrink with the site as you zoom out, down to a readable size, and when the markers crowd each other only the state icons show. One legend under the view, the same in the 2D and the 3D view, lists only what that site shows in that view: the charger kinds it has (in 3D), its batteries and solar canopies, its spot types, the states (**Faulted**, **Unavailable**, **Offline**, **Charging** and **Available**, plus **In Maintenance**, **Reserved** and **Online** when a station shows them), each once, and the connection types its stations have: **Cellular**, **Wi-Fi** and **Wired**, each with its own icon, and **Wi-Fi or Wired** for a station that did not report which. The **Reserved** and **Maintenance** overlays carry their own text and are not in the legend. The station names show only when you point at a station or tap it. When several states apply, the marker shows the first in this order: **Faulted**, **In Maintenance**, **Unavailable**, **Offline**, **Reserved**, **Charging**, **Available**; a station in an active maintenance window shows **In Maintenance**, even though the window turns it off. Point at a station or its marker with a mouse to see its station ID, its state and its connection: cellular from its data plan or SIM, Wi-Fi or wired from the network interface an OCPP 2.0.1 or 2.1 station reported, and for a cellular station signal bars (0 to 4) when the station reported its signal strength. The signal bars follow the reported RSSI: 4 bars above -70 dBm, 3 from -70 to -85 dBm, 2 from -86 to -100 dBm, 1 from -101 to -109 dBm, 0 at -110 dBm or below. Click the station or its marker, or tap it on a touch screen, to open its details.

The layout updates live. Station states, connector statuses, charging, power, sessions, faults and AI insights change as they happen, without a reload. A faulted station carries a red beacon on a short mast above the charger. The beacon pulses, and stays steady when your system reduces motion. A station with an open AI insight gets a small sparkle marker beside its state marker. Click the marker to open the newest insight. You need `aiInsights:read` to see the markers.

The summary chip in the corner of the view counts the **Faulted**, **Offline** and **Charging** stations. Click a count to turn the view to the next station in that state and open its details. The list button at the top right (**Show Station List**) opens a list of every station with its ID, state, power now, session energy and driver name. Choose a station to turn the view to it and open its details. The list works with the keyboard, where Up and Down move between stations, and with screen readers.

Click **Live OCPP Commands**, under the summary chip, to open a terminal window with the OCPP messages of the site's stations. Each message is one line: the time, the station, the direction (station to CSMS or CSMS to station), the action and a short summary, such as the event of a transaction, a connector status or the power of a meter value. Heartbeats show dimmed, and errors and refused requests in red. The window opens with the last 100 messages and adds new ones as they arrive. Pick a station in the station filter, or click a station in the 3D view, to see only its messages; **All Stations** shows every station again. **Pause** stops loading new messages until you click **Resume**, **Clear** empties the window, and **Jump to Latest** returns to the newest line after you scroll up. Click a line to see its payload. Passwords in a payload show as `[redacted]`. Conformance test stations are left out. The window is part of the live 3D view: it does not show while you replay a day or edit the layout. You need `stations:read` to open it.

![Live OCPP Commands window in the 3D layout](https://www.evtivity.com/screenshots/csms/site-layout-3d-live-ocpp.png)

A charging car carries its driver's avatar above it: the picture on a white round background, without a ring. Click the avatar to open the session: the driver's avatar and name, the energy and cost so far, the duration, the station, **Open Session** and **Open Driver**. The energy and cost update live. You need `sessions:read` to see session data. Without it, the car shows a plain marker that opens nothing. You need `drivers:read` to see the driver's name and avatar. Without it, the session shows a person icon instead. An avatar that would cover a station marker moves higher, or hides when there is no room.

On a Parking Lot, transformers stand on the grass at the edge of the lot. Point at a transformer, or tap it, to see its name and rated kVA when you set them. A site that never saved its layout, and each transformer you add in the **Power Equipment** dialog, puts it 2.5 m from the edge of the lot, next to the DC chargers it feeds. At that distance its pad keeps the 3 ft that utilities ask to keep clear at the sides of a pad-mounted transformer, and bollards guard it. With load management on, the first transformer feeds the switchboards; otherwise transformers are for information only. A site that never saved its layout shows one transformer. Office or Retail and Curbside sites show no transformers. The ones you set are kept and show again when you switch the site back to Parking Lot.

Batteries and solar canopies show the storage and solar the site has, on a Parking Lot. They are for information only and show no live data. A battery is a container cabinet on a pad on the grass. A solar canopy is a galvanized steel carport over the spots of one row. Two rows that share an island get one canopy over both, with a single line of columns on the island. The drive aisles stay open. Columns stand about every three spots at the head of the spots, on the island or past the lot edge, never in a spot or a drive aisle and never where a dual-port charger or an accessible charging space stands, each on a concrete pier that rises as its bollard, a girder across the spots on each column, purlins under the panels, and the panels tilted 7 degrees with 14 ft of clearance underneath. Office or Retail and Curbside sites show neither. They are kept and show again when you switch the site back to Parking Lot. Point at one, or tap it, to see its name and its capacity in kWh or kWp.

A Parking Lot, a Depot and a Custom site show each load management panel as a switchboard cabinet on a concrete pad. The switchboards stand in a row 3 ft beside the pad of their transformer, so the transformer, the switchboards and their feeders share one equipment pad at the edge of the site, next to the DC chargers. A sub-panel stands next to its parent. A panelboard of AC chargers away from the transformer stands on the island or the curb strip at the end of its row nearest the transformer, inside the lot and never on the grass, so its feeder takes the shortest route: along the lot edge and in along the row. Where another group's chargers hold that end, it stands just before its own chargers. A switchboard of DC chargers in another row stands at the end of that row, right past the lot edge. A panel's own row's cables run straight along the row. An Office or Retail site shows such a panelboard on the building wall next to its AC chargers, with a cable along the foot of the wall to each charger; the building's own switchboard is inside and does not show. The panels are placed automatically. Point at a panel or a cable, or tap it, to see its name, breaker amps and limit. The links run on the ground like cables in buried conduit: a cable from the transformer to each main switchboard, from a switchboard to each sub-panel, and for each circuit one cable on its own route out of the switchboard, along the edge of the site to its row, along the row behind the chargers (on the island of back-to-back rows), with a short branch to each charger. The runs keep apart from each other and are laid out so they do not cross on a regular layout. The labels show the circuit limits (breaker amps and kW) and each station's allocated limit. A glowing pulse moves along the cables unless your system reduces motion. The cable routes are drawn for orientation and are not a wiring plan. The panels show whether or not the site's load management is on. The cables, their glow and the limits show only while it is on; with it off, pointing at a panel shows its name and breaker amps only. Panels and links never take a click or a drag. On a Curbside site the panels sit in cabinets, so the layout shows no panels or links; the station details show the **Allocated Limit**.

The links also show live power. A station link carries the station's draw, a circuit link the sum of its stations, and a panel link everything under it. A link grows brighter and thicker as its share of the limit grows. Each panel label carries a bar of its live draw against its limit. The bar is green below 80 percent of the limit, amber from 80 percent (near the limit) and red from 100 percent (at the limit).

In the demo data each charger has its own circuit, sized for its load: DC fast chargers on switchboard breakers and Level 2 chargers on panelboards, the way a site electrical design lays them out. Each Level 2 pedestal with two EVSEs, at Patroon Creek Charging Plaza and at the other demo sites, has one 40 A circuit: load management holds the station to its circuit, and the station shares that limit between its two ports. It is a representation of a site, not an engineering design.

A payment terminal paired to a station shows as a small card reader on the front of the charger, on every site type: on the left for connector 1, on the right for connector 2, and in the middle when it is paired to the whole station. A reader with its own screen (VP6825) shows the screen; a VP7200 shows its contactless area. The light on the reader is green while it is online and grey otherwise. Click the reader to open its station. You need `paymentTerminals:read` to see terminals. On the public demo sites every DC fast charger has a card reader of its own, paired to the whole charger, and the Level 2 chargers and the fleet depot have none. That is a choice of the demo: payment rules such as the US NEVI rules and California's also allow a nearby payment kiosk or other payment options.

Click a station or its marker to open its details. The 2D and 3D views show the same popup: the model with **DC Fast**, **Level 2**, **Level 1** or **AC**, the **Status** and its **Reason**, the **Power** now and the maximum, the **Allocated Limit** when load management sets one, the **Session Energy**, the **Connection** (the network type the SIM provider reported, else the data plan, with the signal bars and dBm when known), the **OCPP Version** when known, **Screen Shows** with the text on the charger screen and its source (**Display Message**, **Station Message Template** or **Default Welcome**), the display message, and each connector with its state. **Open Station** goes to the station page. Press Escape to close the popup. The popup also lists the payment terminals paired to the station, each with its connector and whether it is online.

![Station details in the 3D layout](https://www.evtivity.com/screenshots/csms/site-layout-3d-popup.png)

A lit charger shows a message on its screen: the station's display message, else the station message template of its state, else a welcome with your company name, such as "Welcome to EVtivity", in your CSMS language. Every charger with a screen shows it, and so does a card reader with its own screen. The message changes live. A message that fits stays still. A longer one scrolls across the screen in one line, and stays still, cut short, when your system reduces motion. Point at a screen with the mouse to see a larger copy of its full text next to the pointer, with the station and the source. The station details show the same text under **Screen Shows**, also for keyboard and touch screen users.

![Display message on a charger screen](https://www.evtivity.com/screenshots/csms/site-layout-3d-screen-message.png)

The 2D view is a board of station cards, the same on every site type. Each card shows the station ID, its connection icon and, when an active payment terminal is paired to the station, a card reader icon, green while the terminal is online. Below them are a small picture of the station's charger as it looks in 3D, in your charger plate color and greyed out while the station is offline, the station status badge, and the power and session energy while it charges, else its maximum power. The bottom row shows each port as the face of its connector type, outlined in the connector's status color and grouped by EVSE. Point at a port icon to see its EVSE, type and state. A colored bar along the left edge shows the station state. Click a card, or focus it and press Enter, to open the same details popup as in the 3D view.

![Site layout in 2D](https://www.evtivity.com/screenshots/csms/site-layout-tab.png)

Drag the empty board, or press W, A, S or D, to pan. Scroll, pinch, press + and -, or click **Zoom In** and **Zoom Out** to zoom; a two-finger swipe on a trackpad pans. **Fit to View**, or Home, frames every card. The board opens with every card in view. When the site is load managed, the **Power Draw** strip sits above the board and never covers a card.

![Custom site in 2D](https://www.evtivity.com/screenshots/csms/site-layout-2d-custom.png)

With `sites:write`, drag a card anywhere on the board: it lands where you drop it, with no grid. A card dropped on another moves the shortest distance until it is clear. Focus a card and use the arrow keys to move it in small steps, with Shift for larger ones. **Save** on the layout stores the card positions for everyone who opens the site, and **Reset** drops your moves. Moving a card on the board never moves the station in the 3D view. A card you never moved stands in its default place, in the order of the site type: on a Depot the bus bays come before the truck lanes, and on a Custom site the cards follow where the stations stand.

![Depot in 2D](https://www.evtivity.com/screenshots/csms/site-layout-2d-fleet-depot.png)

Click **Replay Day** to see the layout as it was at any moment of a past day, in the 3D and the 2D view. Pick a day from today back 90 days. The day runs in the site's time zone. Drag the timeline slider to a time of day, or click **Play**. The speed sets how many minutes of the day pass each second: 5, 15 or 60. The replay shows each station's online state, connector statuses, session energy and power, averaged over 5 minutes. Data that exists only live does not show: the display message, maintenance and AI insights. A replayed moment shows the same car and driver avatar as the live view: each session's car color and body type with `sessions:read`, its driver with `drivers:read` too, at the connector the session used. Sessions show only from the station's time at this site. A replay of today stops at the current time. **Edit Layout** is hidden while you replay. Click **Back to Live** to return to the live layout.

Sites of 100 to 200 stations stay smooth to rotate and zoom. On a site of 40 or more stations, the avatars of stations far from the view hide until you zoom closer. Station markers always show. On a phone, **Fit to View** frames the busiest part of a wide site, such as an Office or Retail row or a street, so the stations stay readable. Click **Fit to View** again, or zoom out, to see the whole site.

To move stations, click **Edit Layout** in the 3D view. In 3D, the outlined spots show where a station can go, and a station snaps to the nearest free spot of the layout and never lands on another station. On a Parking Lot or a Depot, drag a transformer or a battery to move it on the grass. Click **Done Editing** to leave edit mode. Moves stay pending until you click **Save**, which stores them and leaves edit mode. When the save fails, edit mode stays on with your changes, and the error shows above the layout. **Reset** drops them. You need `sites:write` to edit the layout.

In edit mode, the **Site Settings** panel shows the **Site Type** with a link to the **Details** tab, where you change it, and only the settings of that type. Spot sizes are standard and have no settings.

- **Parking Lot**: **Spots per Row** and **Rows** (1 to 100 each) and **Facing** (0°, 90°, 180° or 270°, which turns the rows and chargers). The **Charger Placement** shows here read-only; change it on the **Details** tab.
- **Office or Retail**: **Chargers**, the number of charger positions along the building, one spot each (1 to 100; until you set it, one per station at the site), and **Charger Mounting**: **Wall** (the default) or **Stall**.
- **Curbside**: **Chargers on the Left Side** and **Chargers on the Right Side** (0 to 100 each, at least 1 in all), left and right as seen driving along the street.
- **Depot**: **Bus Bays** and **Truck Lanes** (0 to 100 each, at least 1 in all; until you set them, one bus bay for each DC station at the site without a Megawatt Charging System (MCS) connector and one truck lane for each station with one; AC stations get neither), and **Facing**.
- **Custom**: no counts.

On a Parking Lot, a Depot and a Custom site, the Site Settings show a **Power Equipment** button with a summary of the site's transformers, batteries and solar canopies, or **None**. Click it to open a dialog. Under **Transformers**, click **Add Transformer** and give each one an optional name and **Rated kVA**, or remove it. Under **Batteries and Solar**, click **Add Battery** or **Add Solar Canopy**. Give each one an optional name and a **Capacity (kWh)** for a battery or a **Peak Power (kWp)** for a canopy, pick a canopy's **Row** on a Parking Lot, or remove it. On a Depot and a Custom site a solar canopy has no row. **Apply** adds your changes to the layout, and **Save** on the layout stores them; **Cancel** drops them. Transformers, batteries and solar canopies are for the layout only and do not change load management. Switchboards, panels and circuits come from the **Load Management** tab, and a note under the button and in the dialog links to it. Without `sites:write`, the button on the **Layout** tab opens a read-only list.

The values of the other site types are kept, and come back when you switch the type back. The 3D view shows every change at once, and **Save** stores it with the station moves. A site that never saved its layout is a Parking Lot with 2 rows of 10 spots, grown so every station it already has fits on the lot in its group: an AC station with two EVSEs counts two spots, and the lot keeps room for the access aisle and one row to spare.

When you make the layout smaller, a station outside it moves to the nearest free position, and the save stores its new place. When the layout has fewer positions than the site has stations, **Save** is not available until you add positions. A transformer or a battery that would stand on the lot moves to the grass beside it. A solar canopy over a row the lot no longer has moves to the last row.

A new station, an imported station and a station moved to this site get a free position automatically. AC and DC chargers are kept apart: on a Parking Lot, an Office or Retail site and a Curbside site, a DC station takes the free spot nearest the site's first transformer, and an AC station takes the free spot farthest from it, so the two groups fill from opposite ends. An Office or Retail site and a Curbside site keep their transformers without showing them; a site without a transformer measures from the right end of the first row. Each group is one continuous run of charging spots. A station never takes a spot past the first spot of the other group: when its own group has no free spot, it stands off the lot until you move it or add positions. An AC station with two EVSEs takes two free spots side by side. A station whose connectors are not known yet takes the first free spot. When you switch a site to one of these types, the stations regroup the same way. Stations you move by hand keep their place when you save. When every position is taken, the station stands off the lot until you move it or add positions.

On a Custom site, drag a station anywhere in 3D. It snaps to 0.5 m steps, and dashed guides show when it lines up with another station. Click a station, or Tab to its label, to select it. Drag the ring handle in front of its spots to turn it in 15° steps, or hold Shift to turn it to any angle. Press R to turn the selected station by 15°, Shift+R by 1°, and the arrow keys to move it by 0.5 m. A station whose spots would overlap another station's goes back where it was, and a note says why. Drag transformers, batteries and solar canopies anywhere. Select a canopy and press R to turn it. A new station stands to the right of the others until you move it. When you switch a site to Custom, every station keeps its place, and a station whose spots would overlap a neighbor's slides along its row until they are free. When you switch the site back, the stations return to their spots.

![Editing a Custom site in 3D](https://www.evtivity.com/screenshots/csms/site-layout-3d-custom-edit.png)

On a Depot, drag a station in 3D to another bus bay or truck lane. It snaps to the nearest free one. When you switch a site to Depot, the stations with a Megawatt Charging System (MCS) connector move into the truck lanes and the other DC stations into the bus bays. A new station takes a free spot of its own kind first. A Depot charges DC only: an AC station at a Depot site never takes a bus bay or truck lane. It stands on the grass behind the yard, like a station without a free position.

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
