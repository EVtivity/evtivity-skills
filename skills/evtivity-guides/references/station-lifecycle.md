Generated from https://www.evtivity.com/docs/guides/station-lifecycle (website commit 900fb20). Do not edit.

# Charging Session Lifecycle

How OCPP 1.6 and OCPP 2.1 stations move through their connector states from plug-in to unplug.

This guide walks through the connector state machine an OCPP charging station goes through during a single session, and how OCPP 1.6 and 2.1 differ in how they report it.

## How status is reported (1.6 vs 2.1)

OCPP 1.6 and 2.1 expose connector state through different fields. This is the most common source of confusion when reading raw OCPP traffic.

- **OCPP 1.6** uses a single field, `ChargePointStatus` on `StatusNotification`, with 9 fine-grained values: `Available, Preparing, Charging, SuspendedEV, SuspendedEVSE, Finishing, Reserved, Unavailable, Faulted`.

- **OCPP 2.1** splits state across two fields:
  - `connectorStatus` on `StatusNotification` - 5 coarse values: `Available, Occupied, Reserved, Unavailable, Faulted`.
  - `chargingState` on `TransactionEvent` - 5 fine-grained values: `EVConnected, Charging, SuspendedEV, SuspendedEVSE, Idle`. Reported only while a transaction is active.

The same physical state (cable plugged in, energy flowing) shows up in 2.1 as `connectorStatus=Occupied` **plus** `chargingState=Charging`, sent on two separate messages. There is no `Charging` or `EVConnected` connector status in 2.1.

The CSMS normalizes both protocols into a single `connectors.status` column for the dashboard. For 2.1, the more specific `chargingState` overwrites the coarse `connectorStatus` while a transaction is active - that's why the dashboard can show `charging` or `ev_connected` for a 2.1 station even though those aren't legal `StatusNotification` values.

## OCPP 1.6

![OCPP 1.6 connector lifecycle](https://www.evtivity.com/images/station-lifecycle-1-6.png)

| Step | Status | Trigger |
|---|---|---|
| Idle | Available | Initial state |
| Cable plugged in | Preparing | Driver plugs in cable |
| Energy flowing | Charging | Driver authorizes (RFID tap or app start) |
| Driver stops | Finishing | Driver stops the session |
| Cable unplugged | Available | Driver unplugs cable |

The connector stays at `Finishing` from the stop until the driver unplugs the cable.

## OCPP 2.1

![OCPP 2.1 connector lifecycle](https://www.evtivity.com/images/station-lifecycle-2-1.png)

Because 2.1 splits state across two fields, the table below shows both. The **Connector** column is what arrives on `StatusNotification`; the **ChargingState** column is what arrives on `TransactionEvent` (only while a transaction is active).

| Step | Connector | ChargingState | Trigger |
|---|---|---|---|
| Idle | Available | - | Initial state |
| Cable plugged in | Occupied | EVConnected | Driver plugs in cable |
| Energy flowing | Occupied | Charging | Driver authorizes (RFID tap or app start) |
| Driver stops | Occupied | EVConnected | Driver stops the session |
| Cable unplugged | Available | - | Driver unplugs cable |

The connector stays at `Occupied` the entire time the cable is plugged in. After a stop, the chargingState reverts to `EVConnected` and stays there until the cable is unplugged - that's what the dashboard displays during the post-stop period.

## Related

- [Station Management](https://www.evtivity.com/docs/guides/station-management) - full status enum reference and connector state model.
- [Station Onboarding](https://www.evtivity.com/docs/guides/station-onboarding) - registering a new station so it can join the network.
- [Authentication](https://www.evtivity.com/docs/configuration/authentication) - security profiles from No Auth through Mutual TLS.
