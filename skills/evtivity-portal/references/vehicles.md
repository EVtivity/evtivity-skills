Generated from https://www.evtivity.com/docs/portal/vehicles (website commit 4cd1866). Do not edit.

# Vehicles

Add vehicles to your account for estimated miles driven from energy consumed.

## Overview

Adding a vehicle to your account enables the Portal to estimate miles driven from energy consumed during charging sessions. Open the Vehicles page from **Account** > **Vehicles**, or tap the **Vehicles** card on the Home page. Vehicles is one of the default Home cards; drivers choose their cards under **Account** > **Home Screen**.

![Vehicles page](https://www.evtivity.com/screenshots/portal/vehicles.png)

## Why Add a Vehicle

Without a vehicle, the Portal cannot estimate distance driven from your charging data. Adding a vehicle unlocks:

- **Activity page** - the Distance metric in the donut chart shows estimated miles for the selected month
- **Session list** - each session row displays estimated miles alongside energy and cost
- **Monthly Statement** - the itemized table includes a Miles column with per-session and total estimates

These estimates help you track how far your EV travels on the energy you consume.

## Adding a Vehicle

1. Open **Account** > **Vehicles**, or tap the **Vehicles** card on the Home page.
2. Enter the make, model, and optional year.
3. Tap **Add Vehicle**.
4. The system looks up the vehicle's efficiency from a built-in table of 24 common EVs, including Tesla Model 3, Chevy Bolt, Nissan Leaf, BMW i4, Ford Mustang Mach-E, Hyundai Ioniq 5, and others. A year-specific entry is preferred when one exists; otherwise the lookup falls back to the year-agnostic row for the make and model.
5. If no match is found, a default efficiency of 3.5 mi/kWh is used.

## How Miles Are Calculated

The Portal multiplies session energy by vehicle efficiency to estimate miles driven.

**Example**: A 35 kWh session with a vehicle rated at 3.5 mi/kWh produces an estimate of 122.5 miles.

The formula is: `energy (kWh) x efficiency (mi/kWh) = estimated miles`.

If you have more than one vehicle on your account, the Portal uses the most-recently-added one for the distance estimate. To switch to a different vehicle, delete the older one and re-add it; the new entry becomes the most recent and starts driving the estimate.

## Where Miles Appear

- **Activity donut chart** - select the Distance metric to see total estimated miles for the month
- **Session list** - each row shows miles alongside duration and cost
- **Monthly Statement** - the itemized table includes a Miles column, and the totals row sums all miles for the month

## Deleting a Vehicle

To remove a vehicle, open the Vehicles page and tap the delete button next to the vehicle. If you delete your only vehicle, the Portal reverts to the default 3.5 mi/kWh for distance estimates.
