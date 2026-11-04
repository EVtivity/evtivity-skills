Generated from https://www.evtivity.com/docs/integrations/bus-depot-systems. Do not edit.

# Bus Depot Systems

Connect a bus depot management system or ITCS to EVtivity. It sends the charging requests of its buses and gets the charging information of its depots back.

## Overview

A bus depot system is the software that runs a bus depot: a depot management system (BMS) or an intermodal transport control system (ITCS). It knows which bus leaves when, on which route and with how much charge. The bus depot interface lets such a system connect to EVtivity over a WebSocket. It sends a charging request for each of its buses, and EVtivity plans the charging with [Route Aware Charging](https://www.evtivity.com/docs/csms/route-aware-charging). In return, EVtivity sends the system the state of every charging point and charging process at its depots, with the predicted state of charge of each bus.

The interface follows VDV 463 version 1.1.0, the charging interface standard of the German Association of Transport Companies (VDV). Give your vendor the connection details below. Your vendor can check its side against the standard.

The interface serves buses only. A request for a vehicle that is not a bus is refused, and the rest of the request list still applies. Plan trucks, vans and cars in the CSMS with [departures](https://www.evtivity.com/docs/csms/route-aware-charging#step-3-enter-departures).

## How It Works

1. The bus depot system opens a WebSocket to the API and signs in with its presystem ID and password.
2. It sends its whole list of charging requests. Each request names a bus, a departure time and the state of charge the bus needs.
3. EVtivity turns each request into a departure of that bus at the depot. The planner meets the departure inside the site power limits, as for every departure.
4. At a fixed interval EVtivity sends the charging information of the depots: the status of each charging station, charging point and charging process, the power and energy, and the predicted state of charge over time.
5. Each new list replaces the previous one. A request that leaves the list is cancelled, unless its bus already charges.

## Set Up

### Step 1: Prepare the Depot

The depot must be a site whose **Site Type** is **Depot**. See [Sites](https://www.evtivity.com/docs/csms/sites). Each bus must be a vehicle of a driver of a fleet that charges at the depot, with the body type bus, its VIN and its battery capacity. See [Fleets](https://www.evtivity.com/docs/csms/fleets) and [Set Vehicle Battery Data](https://www.evtivity.com/docs/csms/route-aware-charging#step-2-set-vehicle-battery-data).

Turn on **Fleet Charging** and choose the **Departure Aware** strategy on the depot's **Load Management** tab, so the requests are planned. See [Route Aware Charging](https://www.evtivity.com/docs/csms/route-aware-charging#set-up).

### Step 2: Turn On the Bus Depot Interface

Open **Settings** > **Integrations & Features** > **Bus Depot Systems** and turn on the bus depot interface. It is off by default. While it is off, EVtivity refuses every bus depot system connection. Turning it off closes the open connections at once.

### Step 3: Create a Depot System

On the same tab, create a depot system:

| Field | Description |
|-------|-------------|
| Presystem ID | The ID the depot system sends in every message. It is also its sign-in user name. Visible ASCII characters, at most 255, no space and no colon. Each depot system has its own. |
| Name | The name shown in the CSMS |
| System Type | BMS (depot management system) or ITCS |
| Depots | The Depot sites it sends requests for |
| Enabled | Accept its connections. Off by default. |

EVtivity generates the password and shows it once, after the create. Copy it then. EVtivity stores only a hash of it, so nobody can read it later. When the password is lost, set a new one: the old password stops working and the open connection closes.

### Step 4: Give the Vendor the Connection Details

| Detail | Value |
|--------|-------|
| URL | `wss://<api host>/vdv463` |
| WebSocket subprotocol | `v1.463.vdv.de` |
| User name | The presystem ID |
| Password | The password shown at the create |

The depot system signs in with HTTP Basic authentication. One connection per depot system is live at a time: a new connection replaces the older one.

### Step 5: Tune the Timings

Each depot system has its own timings. The defaults suit most systems.

| Timing | Range | Default | Meaning |
|--------|-------|---------|---------|
| Information interval | 10 to 600 s | 30 s | Time between two charging information messages |
| Request timeout | 5 to 120 s | 30 s | Time EVtivity waits for a confirmation before it sends a message again |
| Retries | 0 to 10 | 3 | Times a message is sent again before the connection closes |
| Keepalive timeout | 30 to 900 s | 180 s | Silence after which the connection closes |

EVtivity also pings the depot system every 30 seconds.

## Identifiers

The depot system names depots, stations, points and buses with the identifiers EVtivity uses:

| Item | Identifier | Example |
|------|-----------|---------|
| Depot | The site ID | `sit_northgate01` |
| Charging station | The OCPP ID of the station | `NGF-CS-01` |
| Charging point | `<OCPP ID>/<EVSE ID>`. For an OCPP 1.6 station, the connector ID takes the place of the EVSE ID. | `NGF-CS-01/2` |
| Vehicle | The VIN | `EVTNGF00000000101` |

The depot system page lists the identifiers of its depots, stations, points and buses. **Export CSV** gives the same list as a file for your vendor. A bus without a battery capacity is listed as such, because its requests are refused.

## Charging Requests

### Departures

A request with a departure time becomes a departure of the bus at the depot. It carries:

- **Minimum state of charge**: the bus must reach it by the departure. The planner meets it first.
- **Maximum state of charge**: the bus may charge further up to it when the site has power left that no other departure needs.
- **Expected arrival**: when the bus is expected to plug in, and its expected state of charge. The planner uses the expected state of charge until the bus reports its own.
- **Charging point**: when the request names one, the departure expects the bus there. The bus may still plug in at another point of the depot.
- **Priority**: the depot system's priority, turned into the EVtivity priority of 1 to 10.

A request of the depot system for a departure within 60 minutes of a departure the operators entered for the same bus replaces the operators' departure.

### Ad Hoc Requests

The depot system can mark a request as ad hoc. An ad hoc request has no departure time. The bus charges as soon as it plugs in, earliest first, with no finish buffer. The request ends when its session ends, or 24 hours after it was sent when no bus charged for it.

### Terminate

A Terminate request stops the charging of a bus that already charges. EVtivity holds the session at 0 kW and cancels the departure. The charging session itself stays open until the bus unplugs.

### Preconditioning

A request can ask for preconditioning: heating or cooling the bus while it is still plugged in, so the battery is not used for it.

- Automatic preconditioning starts before the departure. The window is the bus's preconditioning window, or the start the request names.
- Manual preconditioning names the start and the power of the climate system and of the other systems.

The plan reserves the bus's preconditioning power in the window, so the charging power and the preconditioning power together stay inside the site limits. OCPP 2.1 stations get a preconditioning request with their charging schedule for that window. OCPP 2.0.1 and 1.6 stations get the schedule without it. The preconditioning status an OCPP 2.1 station reports goes back to the depot system. Set the power and the window on the vehicle. See [Set Vehicle Battery Data](https://www.evtivity.com/docs/csms/route-aware-charging#step-2-set-vehicle-battery-data).

## Refused Requests

EVtivity confirms every message it can read. A request it cannot apply is refused. The other requests of the list still apply. The depot system page lists the refused requests of the last list, with the reason:

| Reason | Meaning |
|--------|---------|
| Unknown vehicle | No bus with this VIN charges at the depots of this system. A bus that exists but belongs to no fleet at these depots shows the same reason. |
| Not a bus | The vehicle's body type is not bus. Plan it in the CSMS. |
| Unknown charging point | The charging point is not at a depot of this system. |
| Unknown charging process | The charging process is not at a depot of this system. |
| State of charge out of range | A state of charge is below 0 or above 100 %. |
| Minimum above maximum | The minimum state of charge is above the maximum. |
| No departure time | The request is not ad hoc and has no departure time. |
| Departure in the past | The departure was more than 5 minutes ago. |
| Departure too far ahead | The departure is more than 7 days ahead. |
| Arrival after departure | The expected arrival is after the departure. |
| Vehicle held by another system | Another depot system holds an open request for this bus. |
| No battery capacity | The bus has no battery capacity, which a state of charge target needs. |
| Invalid preconditioning window | The preconditioning starts after it ends. |
| Duplicate request ID | Two requests of the list share one ID. |
| Identifier too long | The request, vehicle, charging point or process ID has more than 255 characters. Only this request is refused. |
| List too long | The list holds more than 2000 requests. The whole list is refused and nothing changes. |

The active users with the `fleets:read` permission and access to the depot get a notice when requests are refused, at most once an hour per depot system. The depot system page always lists every refused request. Edit its email and SMS templates on the [Notifications](https://www.evtivity.com/docs/csms/notifications) page. A request that applies later leaves the list.

## Departures in the CSMS

Departures of a depot system show on the fleet's **Departures** tab and the depot's **Fleet Readiness** tab with the source **Bus Depot System**. Users who may see the depot systems (`settings.integrations:read` and access to every site) also see its name. While the depot system is enabled, the departures show **Managed by the bus depot system** and the CSMS cannot change or cancel them: the change answers `409 DEPARTURE_MANAGED_BY_DEPOT_SYSTEM`. Change them in the depot system, or disable the depot system first. Deleting a depot system turns its scheduled departures into departures the operators own.

## Change or Delete a Depot System

On the depot system page you can:

- Edit its name, timings and depots. A depot must be a Depot site (`400 DEPOT_SYSTEM_SITE_NOT_DEPOT`).
- Turn it on or off. Off closes its connection.
- Set a new password. The old one stops working at once.
- Delete it. Its connection closes.

Removing a depot, disabling the system, a new password and a delete close its open connection. Two depot systems cannot share a presystem ID (`409 DEPOT_SYSTEM_ID_IN_USE`).

## Security

- TLS ends at the ingress or load balancer in front of the API. The API accepts a bus depot system only over TLS, so the proxy must be trusted (`TRUST_PROXY`, `api.env.trustProxy` in the Helm chart). See [Helm Chart](https://www.evtivity.com/docs/deployment/helm-chart#bus-depot-interface) and [AWS](https://www.evtivity.com/docs/deployment/aws#bus-depot-interface).
- The depot system signs in with HTTP Basic authentication. Passwords are generated by EVtivity.
- Wrong passwords count per depot system and client address. After three failures from one address, that address waits before its next try, longer after each failure, up to 15 minutes. Other addresses still sign in, so a guessing address cannot lock out the real depot system. After 100 failures in all, only the addresses with failures of their own wait.
- One address may open at most 20 connections a minute. A connection may send at most 60 messages a minute, each at most 1 MiB.
- A depot system reaches only the buses of the fleets at its depots and the stations of its depots.
- Turning off the bus depot interface or a depot system closes the live connections at once.
- Creating a depot system, setting a new password, turning it on, changing its depots and deleting it ask you to confirm your sign-in again. An API key cannot do these (`403 SESSION_REQUIRED`).
- Every change is in the depot system history, and the users with access to every site who may change integrations get a security notice.

## API

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/v1/depot-systems` | List depot systems |
| GET | `/v1/depot-systems/:id` | One depot system, with its depots and refused requests |
| GET | `/v1/depot-systems/:id/identifiers` | Its depots, stations, charging points and buses |
| POST | `/v1/depot-systems` | Create a depot system. The reply holds the password. |
| PATCH | `/v1/depot-systems/:id` | Change it |
| POST | `/v1/depot-systems/:id/password` | Set a new password. The reply holds it. |
| DELETE | `/v1/depot-systems/:id` | Delete it |

An unknown depot system answers `404 DEPOT_SYSTEM_NOT_FOUND`.

Every departure in the departure and charging plan replies carries `managedByDepotSystem`, true while it is scheduled and its depot system is enabled, and `depotSystemName`, null for users who may not see the depot systems. `GET /v1/sites/:id/charging-plan?departureStatus=cancelled` lists the cancelled departures of a depot with their `cancelReason`. See the [API reference](https://www.evtivity.com/api-reference).

## Permissions

| Action | Permission |
|--------|-----------|
| View depot systems and their identifiers | `settings.integrations:read` |
| Create, change and delete depot systems | `settings.integrations:write` |

Depot systems serve every site they name, so only users with access to every site see and manage them.
