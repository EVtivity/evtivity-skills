Generated from https://www.evtivity.com/docs/guides/charging-site-connection-setups. Do not edit.

# Charging Site Connection Setups

The five ways a charging site connects to EVtivity over OCPP, what the CSMS sees in each, and when station units apply.

## Overview

OCPP 2.1 Part 1, chapter 8, describes the topologies OCPP supports. OCPP was originally used for a setup where each charging station communicates directly with the CSMS, and OCPP has no knowledge of the topology of the charging station network. How a station reaches the internet (its own LTE modem, site Wi-Fi or Ethernet) is separate from the OCPP topology.

EVtivity accepts OCPP 1.6, 2.0.1 and 2.1 stations in every setup below. What changes is what the CSMS sees: one station per charger, or one station with many EVSEs.

| Setup | OCPP 2.1 Part 1 | Who speaks OCPP to the CSMS | What the CSMS sees |
|---|---|---|---|
| 1. A station with its own internet connection | 8.1 | Each station | Each station |
| 2. Several stations sharing one internet gateway or router | 8.1 | Each station, over the shared link | Each station |
| 3. A Local Proxy | 8.2 | The proxy, on behalf of each station | Each station. The proxy is invisible |
| 4. A Local Controller with OCPP chargers | 8.3 | The controller, for each station and for itself | Each station, plus the controller as a station without EVSEs |
| 5. A Local Controller with non-OCPP chargers (master and extender) | 8.4 | Only the master | One station with many EVSEs, or several stations |

## 1. A Station with Its Own Internet Connection

The basic, original OCPP setup (section 8.1). Each station opens its own OCPP connection to the CSMS and appears in EVtivity as one station.

![One charger with its own OCPP connection to the CSMS. The CSMS sees 1 station.](https://www.evtivity.com/images/docs-connection-setup-1.png)

## 2. Several Stations Sharing One Internet Gateway or Router

Several OCPP stations sit behind one shared router or LTE gateway, and each keeps its own OCPP connection. For OCPP this is still section 8.1: the router carries IP traffic only and is not an OCPP topology. Each station appears in EVtivity as one station.

![Three chargers behind one router or gateway, each with its own OCPP connection passing through it. The CSMS sees 3 stations.](https://www.evtivity.com/images/docs-connection-setup-2.png)

## 3. A Local Proxy

An on-site gateway relays the stations' OCPP messages to the CSMS and makes no decisions (section 8.2). The specification's example is a group of stations in an underground parking garage with little or no mobile network access, linked over a LAN to a central data communications unit that connects to the mobile network and acts as a proxy. For the CSMS the proxy is the charging station, so each station appears in EVtivity as one station.

![Three chargers connect over OCPP to a Local Proxy, which relays OCPP to the CSMS. The CSMS sees 3 stations.](https://www.evtivity.com/images/docs-connection-setup-3.png)

## 4. A Local Controller with OCPP Chargers

A Local Controller relays OCPP messages and can also act on its own, for example to impose charge limits on its stations (section 8.3). The controller has its own station identity without EVSEs or connectors, and it opens a connection to the CSMS for each station behind it. Each charger appears in EVtivity as one station. A controller that registers with its own identity appears as one more station with no EVSEs.

![Three chargers connect over OCPP to a Local Controller, which relays OCPP to the CSMS and sends its own limits to the chargers. The CSMS sees 3 stations, plus the controller as a station without EVSEs.](https://www.evtivity.com/images/docs-connection-setup-4.png)

## 5. A Local Controller with Non-OCPP Chargers (Master and Extender)

The chargers do not speak OCPP themselves, and an OCPP-enabled controller abstracts them away (section 8.4). In a master and extender setup the master is that controller and the extenders are the chargers behind it. The specification allows two forms:

- **Several stations:** the master acts as one OCPP station per charger, each with its own identity. Each charger appears in EVtivity as one station.
- **One station with many EVSEs:** the master is one OCPP station, and every charger behind it is a set of EVSEs of that station. EVtivity shows one station with all its EVSEs and connectors.

In the one-station form, load management sets one power limit for the whole station (see [Load Management](https://www.evtivity.com/docs/csms/load-management)), and a master that supports OCPP smart charging shares it among its chargers.

![A master charger with OCPP to the CSMS and three extenders on LAN or WLAN without OCPP. The CSMS sees 1 station with 8 EVSEs.](https://www.evtivity.com/images/docs-connection-setup-5.png)

## Station Units

Station units apply only to setup 5 in its one-station form. A unit groups the EVSEs of one station by physical charger, so drivers see each charger with its own name in the portal and the app, the site layout draws each charger, and roaming partners receive the unit name as the EVSE `physical_reference`. Sessions, OCPP commands and billing stay with the station. In every other setup each charger is already its own station, so units are not needed.

A unit is a grouping in the CSMS only. It is not an OCPP or OCPI object: the OCPP model stays station, EVSE and connector.

To set up units, see [Units](https://www.evtivity.com/docs/csms/stations#units) on the Stations page.

For how OCPP numbers EVSEs and connectors in each version, see [EVSEs and Connectors](https://www.evtivity.com/docs/guides/evses-and-connectors).
