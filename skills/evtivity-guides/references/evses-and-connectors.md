Generated from https://www.evtivity.com/docs/guides/evses-and-connectors. Do not edit.

# EVSEs and Connectors

How OCPP 1.6, 2.0.1 and 2.1 describe EVSEs and connectors, how EVtivity stores them, and what operators and drivers see.

## Overview

A charging station has one or more outlets that can each charge a car. OCPP 2.0.1 and 2.1 describe a station in three levels: charging station, EVSE and connector. OCPP 1.6 has two levels: charge point and connector. This page explains both models, compares them, and shows how EVtivity stores and displays each.

## OCPP 2.0.1 and 2.1

OCPP 2.1 Edition 2, Part 1, chapter 2 ("3-tier model") defines the levels:

- A **Charging Station** is the physical system where EVs can be charged. It has one or more EVSEs.
- An **EVSE** "is considered as a part of the Charging Station that can deliver energy to one EV at a time."
- A **Connector** "refers to an independently operated and managed electrical outlet on a Charging Station". An EVSE may have several connectors, "multiple physical socket types and/or tethered cable/connector arrangements", for different vehicle types.

Because an EVSE delivers energy to one EV at a time, the connectors of one EVSE are alternatives: one car charges on that EVSE at a time.

Numbering is set in chapter 7 of the same part. EVSEs are numbered from 1 on every station, with no gaps, and evseId 0 addresses the whole station (or, in reports from the station, its main controller). Connectors are numbered from 1 on every EVSE. OCPP 2.0.1 Edition 4, Part 1 uses the same 3-tier model (chapter 2) and the same numbering rules (chapter 7).

## OCPP 1.6

OCPP 1.6 edition 2 has no EVSE level. It defines a **Connector** as "an independently operated and managed electrical outlet on a Charge Point", which usually corresponds to one physical connector but may have several socket types. Each connector charges on its own.

Section 3.8 ("Connector numbering") sets the numbers: the first connector is 1, further connectors are numbered in sequence with no gaps, and connectorId 0 addresses the entire charge point (or, in reports from the charge point, its main controller).

## Comparison

| | OCPP 2.0.1 and 2.1 | OCPP 1.6 |
|---|---|---|
| Levels | Charging station, EVSE, connector | Charge point, connector |
| Numbering | evseId from 1 per station, connectorId from 1 per EVSE | connectorId from 1 per charge point |
| Whole station | evseId 0 | connectorId 0 |
| One outlet that charges one car (a "port") | An EVSE | A connector |
| Dual-port AC charger | EVSE 1 and EVSE 2, connector 1 each | Connector 1 and connector 2 |
| DC charger with CCS and CHAdeMO on one outlet | EVSE 1 with connector 1 (CCS) and connector 2 (CHAdeMO) | Two connectors, 1 and 2 (1.6 has no level that groups them) |
| Master and extender site with 8 dual-port chargers | One station, EVSE 1 to 16 | One charge point, connector 1 to 16 |

## Examples

### Dual-Port AC Charger

The charger has two outlets that charge two cars at the same time. In OCPP 2.x it reports two EVSEs with one connector each.

![A dual-port AC charger with two ports: EVSE 1, connector 1 and EVSE 2, connector 1.](https://www.evtivity.com/images/docs-evse-example-a.png)

### DC Charger with CCS and CHAdeMO

The charger has one outlet with two connector types. In OCPP 2.x it reports one EVSE with two connectors, so one car charges at a time, on either connector.

![A DC charger with one EVSE, EVSE 1, that has connector 1 (CCS) and connector 2 (CHAdeMO).](https://www.evtivity.com/images/docs-evse-example-b.png)

### Master and Extender Site

A master charger and its extenders report as one station with many EVSEs. See [Charging Site Connection Setups](https://www.evtivity.com/docs/guides/charging-site-connection-setups) for how this compares with other setups, and [Units](https://www.evtivity.com/docs/csms/stations#units) for how EVtivity shows each physical charger.

![A master and three extenders form 1 station with EVSE 1 to 8, one connector each.](https://www.evtivity.com/images/docs-evse-example-c.png)

## How EVtivity Stores EVSEs and Connectors

- **OCPP 2.0.1 and 2.1:** EVtivity stores the EVSE and connector numbers as the station reports them. An EVSE or connector the station reports for the first time in a StatusNotification is created automatically and marked as auto-created. Its connector type starts as Unknown, and EVtivity asks the station for its base report, which fills the connector type and maximum power of existing connectors. A status for evseId 0 becomes the station's reported status.
- **OCPP 1.6:** each 1.6 connector is stored as an EVSE with one connector, both with the 1.6 number: connector 3 becomes EVSE 3 with connector 3. A 1.6 EVSE always holds exactly one connector, so a 1.6 DC charger with CCS and CHAdeMO shows as two EVSEs. A status for connectorId 0 becomes the station's reported status. Auto-created 1.6 connectors keep the type Unknown until an operator sets it, since OCPP 1.6 has no base report.
- **Commands:** EVtivity addresses EVSEs. For a 1.6 station it sends the EVSE number as the connectorId.
- Operators can also add EVSEs and connectors by hand on the station's **EVSE & Connectors** tab.

## What Operators and Drivers See

- **EVSE & Connectors tab:** one card per EVSE, with its connectors inside. See [EVSE & Connectors](https://www.evtivity.com/docs/csms/stations#connectors) and [OCPP 1.6 stations](https://www.evtivity.com/docs/csms/stations#ocpp-16-stations).
- **Driver portal:** the station page shows one tile per EVSE with the connector types of that EVSE. The driver picks an EVSE, and the charge starts on that station and EVSE number. See [EVSE Grid](https://www.evtivity.com/docs/portal/charging#evse-grid).
- **2D site layout:** each station card shows the connector pictograms grouped by EVSE.
- **3D site layout:** a charger with two or more EVSEs shows a number plate per EVSE, and a charger with a light per port shows each port in its own EVSE's state. A car stands at each EVSE with a connector plugged in. A charger model draws at most two EVSEs: one connector each for AC, up to two each for DC. See [Layout](https://www.evtivity.com/docs/csms/sites#layout).
- **Station units:** for a master and extender station, units group the EVSEs by physical charger, so each charger shows on its own in the portal, the app and the site layout. See [Units](https://www.evtivity.com/docs/csms/stations#units).
