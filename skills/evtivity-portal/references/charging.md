Generated from https://www.evtivity.com/docs/portal/charging. Do not edit.

# Start a Charging Session

Find a station, select a connector, choose a payment method, and start charging as an authenticated driver.

## Overview

Authenticated drivers can start charging sessions by scanning a QR code at a station or by searching for stations in the Portal. This guide covers both entry points, the station detail page, and the active session experience.

## QR Code Flow

Every charging station has a QR code that links to the Portal.

1. Scan the QR code with your phone camera. The URL format is `/charge/:stationId/:evseId` (specific connector) or `/charge/:stationId` (station level).
2. If you are logged in, the Portal redirects you to the authenticated charging page at `/start/:stationId`. If a specific connector was in the QR code, it is preselected.
3. If you are not logged in, you see the guest landing page. Tap **Sign In** to log in and continue with authenticated charging, or charge as a guest (see [Guest Charging](https://www.evtivity.com/docs/portal/guest-charging)).

## Search for a Station

1. Open the Portal and tap the **Charge** tab in the bottom navigation.
2. The search page detects your location via browser geolocation. Nearby stations within 10 miles are displayed automatically.
3. Use the search bar to find stations by name, ID, or address.
4. Tap a station to open the station detail page.

![Station search](https://www.evtivity.com/screenshots/portal/charger-search.png)

If location access is denied, a banner prompts you to enable location services. You can still search by name or address.

Nearby station results are cached in localStorage for 24 hours.

## Station Detail Page

The station detail page at `/start/:stationId` shows everything you need to start a session.

### Station Information

- **Station ID and site name** - displayed at the top of the page
- **Online/offline status** - indicator showing whether the station is communicating with the CSMS
- **Address** - tap to view the [Location Detail](https://www.evtivity.com/docs/portal/location-detail) page with map and popular times
- **Site contact information** - shown when the operator marks the contact as public
- **Favorites star** - tap to add or remove the station from your [Favorites](https://www.evtivity.com/docs/portal/favorites)
- **Report Issue** - link to create a support case about this station

### Pricing

The pricing section displays the resolved tariff for your account. This is the price the operator has assigned based on your driver group or the default tariff. Pricing components may include per-kWh rates, per-minute rates, flat fees, or a combination.

Prices are shown excluding or including tax, depending on your **Show prices** choice in [Account settings](https://www.evtivity.com/docs/portal/account) or, until you choose, the operator default. When the tariff has tax, a note below the price says which one you see, for example "Prices include 19% tax" or "Prices exclude 19% tax, which is added to the amount charged". Prices show 2 to 4 decimals, so a price such as 0.357 per kWh is not rounded. The pricing section appears once the Portal knows which display applies.

When the resolved tariff has time-of-day or other restrictions, a one-line summary appears below the rate, for example "Mon, Tue, Wed 09:00-17:00" or "Holiday rate". For a time or day restriction, the summary names the timezone of the time window, for example "Times in Europe/Berlin". If the site is in free vend mode, the section shows a **Free charging** badge instead of a rate.

When the price can change during the session, a note says so: "The price can change during the session (time of day, day or energy charged)." This happens when the operator bills each tariff change separately and the station has tariffs for other times or amounts of energy.

A tariff shows as free when all its prices are zero, whatever its tax rate.

### EVSE Grid

The EVSE grid shows all connectors at the station. Each tile displays:

- **Connector type** - CCS2, CHAdeMO, Type 2, J1772, etc.
- **Power rating** - maximum power output in kW
- **Amperage** - maximum current in amps
- **Port number** - the physical port identifier on the station
- **Status badge** - color-coded availability status

#### Connector Status Colors

| Status       | Color  | Meaning                                    |
|--------------|--------|--------------------------------------------|
| Available    | Green  | Ready for use, no cable detected           |
| Occupied     | Blue   | Active charging session in progress        |
| Preparing    | Cyan   | Cable connected, waiting for authorization |
| EV Connected | Cyan   | Cable connected to the vehicle             |
| Reserved     | Orange | Reserved for another driver                |
| Suspended    | Yellow | Session paused by vehicle or station       |
| Faulted      | Red    | Hardware or communication error            |
| Unavailable  | Red    | Taken out of service by operator           |

#### Station Unavailable

When the whole station is unavailable, the page shows "This station is unavailable right now. Try another station." and no connector tile can be selected. This happens when the operator disabled the station, a firmware install is running or failed, or the station reports a fault. A single faulted connector blocks only that connector.

## Select a Connector

1. On the station detail page, tap an available connector tile.
2. Only connectors with a startable status (available, occupied, preparing, or ev_connected) can be selected. No connector can be selected while the station is unavailable.
3. The selected connector is highlighted with a border.

## Pre-Start Status Check

Before starting, the Portal sends a TriggerMessage to the station to request a fresh StatusNotification.

1. The system triggers a status refresh from the station.
2. If the connector status is **available** (no cable detected), a warning dialog asks you to plug in your EV before proceeding. You can dismiss the warning and start anyway.
3. If the connector is ready (cable connected), the session starts immediately.

This check prevents failed start attempts when the cable is not plugged in.

On an OCPP 2.1 station, you can also start from the Portal when your cable is already plugged in and the station is waiting for authorization.

## Select a Payment Method

1. After selecting a connector, your default payment method is shown.
2. To use a different card, tap the payment method selector dropdown and choose from your saved cards.
3. If you have no payment method on file and the tariff is not free, you must add one before starting. See [Payment Methods](https://www.evtivity.com/docs/portal/payment-methods). You also need one when the current tariff is free but a paid tariff can apply later in the session.

### Charge on Account

If your fleet bills your sessions on account, the station page shows **Billed to** and your fleet in place of the payment methods. You start without a card, no amount is held, and your fleet pays the session on its invoice. At a free vend site nothing is billed. See [Fleets](https://www.evtivity.com/docs/csms/fleets).

![Station page billed to the fleet](https://www.evtivity.com/screenshots/portal/charger-detail-billed-to.png)

## Start Charging

1. Tap **Start Charging**.
2. The Portal sends a `RequestStartTransaction` command to the station.
3. The session detail page opens automatically.

## Active Session

After starting, the Portal shows the session detail page with live charging data:

- **Energy** - kWh delivered so far, updating in real time
- **Estimated cost** - running cost based on the tariff and energy consumed
- **Duration timer** - elapsed time since the session started
- **Stop Charging button** - tap to end the session early

The session detail page updates via polling to show the latest data from the station. The polling interval is a few seconds during active charging.

When the session completes (either by tapping Stop or when the vehicle stops drawing power), the page shows the final session summary with total energy, duration, and cost.

### Ghost Transaction Recovery

If the station rejects the start command because it already has an active transaction the CSMS does not know about, the system automatically:

1. Stops the unknown transaction on the station.
2. Retries the start command.
3. If the retry succeeds, charging begins normally.

## Notes

- Charging sessions require a verified email and a valid payment method, unless the tariff is free and no paid tariff can apply later in the session.
- A driver whose fleet bills on account needs no payment method.
- The Portal supports OCPP 1.6 and 2.1 stations.
- Live session data (energy, cost, duration) updates in real time via polling.
- If a session fails to start, the Portal displays an error message with the reason from the station.
- A start request at an unavailable station returns `409 STATION_UNAVAILABLE`.
