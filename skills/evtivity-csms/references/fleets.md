Generated from https://www.evtivity.com/docs/csms/fleets (website commit 4cd1866). Do not edit.

# Fleets

Organize drivers and stations into fleets for group management and pricing.

## Overview

Fleets group drivers, stations, and vehicles under a single organizational entity. Use fleets to manage corporate charging programs, municipal vehicle fleets, or any scenario where a group of drivers shares pricing or station access.

![Fleets list](https://www.evtivity.com/screenshots/csms/fleets-list.png)

## Create a Fleet

1. Navigate to **Fleets** in the sidebar.
2. Click **Create Fleet**.
3. Enter the fleet name and optional description.
4. Click **Create**.

![Create fleet](https://www.evtivity.com/screenshots/csms/fleets-create.png)

## Fleet Detail

Click any fleet in the list to open the detail page. The default Details view edits the fleet's name and description.

![Fleet detail](https://www.evtivity.com/screenshots/csms/fleet-detail.png)

### Sessions

View all charging sessions from fleet drivers across all stations. Filterable by status and date range.

![Fleet sessions](https://www.evtivity.com/screenshots/csms/fleet-sessions-tab.png)

### Stations

Add or remove stations associated with the fleet. This is informational grouping rather than access control.

![Fleet stations](https://www.evtivity.com/screenshots/csms/fleet-stations-tab.png)

### Vehicles

View vehicles belonging to fleet drivers.

![Fleet vehicles](https://www.evtivity.com/screenshots/csms/fleet-vehicles-tab.png)

### Drivers

Add or remove drivers from the fleet. Drivers in a fleet inherit the fleet's pricing group when no driver-specific pricing is assigned.

To add drivers:

1. Click **Add Driver**.
2. Search for drivers by name or email.
3. Click a driver in the results to add them to the fleet.

To remove a driver, click the remove icon next to their name.

![Fleet drivers](https://www.evtivity.com/screenshots/csms/fleet-drivers-tab.png)

### Pricing

Assign a pricing group to the fleet. Fleet-level pricing applies to all fleet drivers at all stations, unless the driver has a driver-specific pricing override.

![Fleet pricing](https://www.evtivity.com/screenshots/csms/fleet-pricing-tab.png)

### Bulk Reservations

Create and manage batch reservations for fleet vehicles across multiple stations in one go.

#### Create a Bulk Reservation

1. Open the **Bulk Reservations** tab on the fleet detail page.
2. Click **New Bulk Reservation**.
3. Set a name (optional), starts-at, and expires-at.
4. For each station you want to reserve, add a slot:
   - Search for a station (search-as-you-type).
   - Pick a connector from the dropdown that appears once a station is chosen.
   - Optionally assign a driver (search-as-you-type).
5. Click **Add Station** to add more slots. Stations already chosen in another slot are filtered out so you cannot pick the same one twice.
6. Click **Create**.

#### Validation

The same date checks as the single-reservation flow apply: start cannot be in the past, end must be at least 60 seconds in the future, the window must be at least 60 seconds wide, and the duration cannot exceed the system-wide `reservation.maxHours` cap when set.

#### Result

Each slot is processed independently. The result toast reports the count of confirmed and failed slots. A failed slot does not roll back the others - the bulk reservation lives on with whichever slots succeeded, and the row's status reflects partial success when applicable.

#### Status

| Status | Meaning |
|---|---|
| active | At least one slot is currently reserved |
| partial | Some slots failed at create time; the remainder are active |
| completed | The expires-at time has passed |
| cancelled | An operator cancelled the bulk reservation |

#### Cancellation

Click the trash icon on any row to cancel all slots in that bulk reservation. This sends `CancelReservation` to every station holding an active slot and marks the bulk reservation as `cancelled`. Slots already used by an in-progress charging session are unaffected.

The tariff resolution priority is:

1. Driver-specific pricing (highest priority)
2. Fleet pricing
3. Station pricing
4. Site pricing
5. Default pricing group (lowest priority)

See [Pricing](https://www.evtivity.com/docs/csms/pricing) for full details on tariff resolution.

![Fleet bulk reservations](https://www.evtivity.com/screenshots/csms/fleet-reservations-tab.png)
