Generated from https://www.evtivity.com/docs/csms/autocharge. Do not edit.

# Autocharge

Start charging when a driver plugs in, identified by the vehicle id the charger reads from the EV.

## Overview

Autocharge (charge by plugging in) starts a session for a driver without a card or the app. During the plug-in handshake (DIN 70121 or ISO 15118), a DC charger learns the vehicle id of the EV: its charging controller id (EVCCID, usually the MAC address) or its VIN. When the charger sends that id and a vehicle with Autocharge on holds it, the session starts as the vehicle's driver.

Autocharge is off by default. Turn it on company-wide under **Settings** > **Integrations & Features** > **Autocharge**, or for one site on the site's **Details** tab (**Autocharge**: **Use Company Setting**, **On** or **Off**).

## What the Charger Sends

| Protocol | How the vehicle id arrives |
|----------|----------------------------|
| OCPP 2.1 | An idToken of type `MacAddress`, `EVCCID` or `VIN` |
| OCPP 2.1 | An `EVCCID` in `idToken.additionalInfo` next to a card or app start (ISO 15118-20) |
| OCPP 1.6 | The idTag carries the MAC address, often with the prefix `VID:` (for example `VID:92D50A693F80`), or the VIN |

The CSMS compares ids in one form: a MAC address in any case, with or without `:`, `-` or `.` separators, and without the `VID:` prefix; a VIN in uppercase. A card registered with the same value always wins over a vehicle.

## Vehicle IDs on Every Session

Every start that carries a vehicle id stores it on the session, refused starts included:

- **Sessions** list: the **Vehicle** column shows the linked vehicle, or the id the charger sent with "(captured)".
- Session detail: the **Vehicle** row shows the linked vehicle, an **Autocharge** badge when the vehicle started the session, and the id with "Captured from the charger".
- **Authorize Log**: the **Vehicle ID** column shows the id of every start, so a refused Autocharge start is visible. The **ID Token** filter also finds it.

A session is linked to the driver's vehicle that holds the captured id.

## Enrolling a Vehicle

A driver enrolls a vehicle in one step from a session in which a charger sent its id: in the portal session detail, **Use This Vehicle for Plug-In Charging** stores the id on a new or existing vehicle and turns Autocharge on. Operators do the same from the session detail with **Use This Vehicle for Plug-In Charging**, for the session's driver.

Operators also enter the **EVCCID (MAC Address)** and VIN on the vehicle (**Drivers** > driver > **Vehicles** > vehicle) and turn **Autocharge** on there. Autocharge needs a VIN or an EVCCID, and one vehicle at a time can use an id for Autocharge.

## Authorization

A start is authorized by a vehicle when:

1. No driver token has the value.
2. A vehicle with Autocharge on holds the id.
3. Autocharge is on at the station's site.
4. The vehicle is not blocked and its driver is active.

The session then follows the same rules as a card start: payment method, pricing, the fleet credit limit and concurrent sessions. A vehicle id that is not enrolled, or a site with Autocharge off, is refused. The charger is told not to keep the authorization in its cache, so switching Autocharge off or blocking a vehicle applies to the next plug-in. Vehicles are never pushed to a station's local authorization list.

## Notifications

Each Autocharge start sends the driver the **Autocharge Session Started** notice (email and push) in place of the session started notice. It is always on: the operator switch is locked and the driver cannot turn it off. It names the vehicle and links to the portal Vehicles page, where the driver turns Autocharge off. The link needs the **Driver Portal URL** in **Settings** > **Company Info**.

## Blocking a Vehicle

On the vehicle page, **Block Vehicle** refuses the vehicle's VIN and EVCCID at every start, whether Autocharge is on or off, and the driver cannot turn Autocharge back on. **Unblock Vehicle** lifts it. Every change to a vehicle, its ids, its Autocharge switch and a block is listed on the vehicle's **History** tab.

## Notes

- **Last Seen** on the vehicle shows the station and time of the last session in which a charger sent its id.
- Drivers see the Autocharge switch in the portal where Autocharge is on.
- A card registered with a vehicle id as its value (token type `VIN`, `EVCCID` or `MacAddress`) keeps working as a card.
