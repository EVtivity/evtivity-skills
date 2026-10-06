Generated from https://www.evtivity.com/docs/guides/ev-charging-behaviors (website commit 257c8b8). Do not edit.

# EV Charging Behaviors

Vehicle-specific quirks that surface in OCPP states. When a station reports SuspendedEV, prolonged EVConnected, or unusual stop reasons, the cause is usually on the vehicle side.

This guide is an operator's reference for the most common vehicle behaviors that show up on the CSMS as unexpected OCPP states. The charging station and the CSMS are passive observers in many of these cases — the EV itself drives the decision (battery temperature, SoC limit, scheduled timers, BMS faults). Knowing how each major brand behaves helps you decide whether a `SuspendedEV` is a real problem or just a sleeping car.

## How EV behaviors surface in OCPP

Most vehicle-side decisions show up in one of these forms:

| What the driver sees on the car | What the station reports |
|---|---|
| Scheduled charging timer is waiting | `SuspendedEV` (2.1 chargingState) / `SuspendedEV` connector status (1.6) |
| Battery reached the configured SoC limit (e.g. 80%) | Clean `Ended` with `stopReason: Local` or natural taper to zero current then `SuspendedEV` |
| Battery too cold to accept charge | `SuspendedEV` until preconditioning warms the pack |
| Station scaled power below the EV's minimum acceptance | `SuspendedEV` and (some EVs) the EV refuses to resume even when power returns |
| Driver pressed unlock / unplug | `Ended` with `stoppedReason: EVDisconnected` |
| EV reports a fault (12V dead, BMS error, isolation fault) | `SuspendedEV` followed by `Faulted`, or no `Authorize` at all |

The CSMS distinguishes `SuspendedEV` (vehicle declined power) from `SuspendedEVSE` (station declined power, e.g. load management). Almost everything in this guide is `SuspendedEV` — vehicle-driven.

## Tesla (Model 3, Y, S, X, Cybertruck)

**Scheduled charging in the car app/screen.** When the driver has set a scheduled start time on the vehicle (Charging → Schedule), the car sits in standby with a **blue charge-port LED** and refuses to draw current until the scheduled window. Over OCPP this looks like a connector that authorized successfully and immediately reports `SuspendedEV`. The session can sit in this state for hours and is normal — it will start at the scheduled time without operator intervention. Confusingly, drivers often forget the timer is set in the car (vs. the wallbox or backend) and report the station as broken.

**Hard stop below the EV's minimum current.** Tesla vehicles refuse to charge below approximately **6 kW / 5 A**. When OCPP load management or smart-charging schedules drop the offered current under that threshold, the vehicle does not scale down — it **stops** and shows `SuspendedEV`. Worse, when power is restored the vehicle does **not auto-resume**; the driver must unplug and replug to start a new session. Avoid configuring per-EVSE limits below 6 kW for Tesla-heavy sites.

**Scheduled Precondition.** If the driver enabled Scheduled Precondition (separate from Scheduled Charging), the car runs cabin and battery preconditioning immediately before the scheduled departure time. During preconditioning the car may briefly draw power for HVAC even outside the charging window — visible as a short `Charging` window followed by `SuspendedEV` again.

**OCPP support is limited.** Tesla Wall Connector Gen 3 historically had no OCPP support. Newer firmware now offers OCPP 1.6, but field deployment is uneven. If you operate Tesla wall connectors as part of a network, verify the firmware version supports OCPP before commissioning.

**Plug & Charge** is region-locked and depends on the network. Outside Tesla's own Supercharger network, expect the driver to authenticate via RFID or the operator's app rather than ISO 15118 contract certificates.

## Hyundai / Kia (Ioniq 5, Ioniq 6, EV6, EV9, Niro EV — e-GMP platform)

**Battery preconditioning is gated on navigation.** Modern e-GMP vehicles only auto-precondition the battery when the driver routes to a DC fast charger via the in-car navigation. If the driver shows up cold without nav routing, the vehicle accepts power slowly until the pack warms — visible as a long `Charging` window with low energy delivery, occasional `SuspendedEV`, and gradual ramp-up over 10–20 minutes. Earlier firmware versions don't precondition automatically at all; manual activation is via a service menu.

**V2L active.** Most e-GMP vehicles support Vehicle-to-Load. If the driver is using the V2L adapter while plugged in, the station may see unusual current draw patterns or `SuspendedEV` when the V2L load exceeds what the AC EVSE can offer.

**Plug & Charge.** Ioniq 6 is the first Hyundai with native Plug & Charge support; the Ioniq 5's P&C availability depends on the network — currently primarily Electrify America in the US. Stations rolling out ISO 15118 should expect mixed P&C results across the e-GMP fleet.

**Charge port communication delays.** A small percentage of e-GMP units have intermittent CCS handshake delays (4–10 seconds extra during the initial cable-check phase). If you see authorize succeed but the actual `StartTransaction` lag, this is often the cause and is benign.

## Nissan Leaf (24 / 30 / 40 / 62 kWh)

**Onboard charge timer overrides AC sessions.** The Leaf has a per-vehicle charge timer (set on the dash). When the timer is active and the driver plugs into AC, the car ignores the connection until the timer's scheduled start. Same `SuspendedEV` symptom as Tesla. The driver can override by pressing **Charge Timer Off** on the dash or holding the cabin start button.

**CHAdeMO bypasses the timer.** DC fast charging via CHAdeMO ignores the onboard timer entirely — drivers can plug in and start immediately regardless of timer state.

**Rapidgate (24/30/40 kWh models).** Older Leafs without active battery cooling severely throttle DC fast charging after 1–2 consecutive sessions on a warm day. The station reports normal `Charging` but actual delivered power drops from 50 kW to 22 kW to 8 kW over the session. This is a vehicle-side limitation; nothing the CSMS can do.

**12V battery faults.** Leafs are sensitive to weak 12V auxiliary batteries. If the 12V is low, the high-voltage contactors won't close and the station never sees a real `Authorize` — the cable plugs in, the station reports `Preparing` (1.6) or `Occupied` (2.1), and nothing else happens for minutes. If a Leaf is stuck in `Preparing` with no progress, suggest the driver check 12V battery state.

## Ford Mustang Mach-E / F-150 Lightning

**Auto-resume on power restoration.** Unlike Tesla, Ford EVs reliably auto-resume when OCPP load management restores power above the EV's minimum threshold (~6 A). They handle scaling well across the full range.

**Departure schedule (BlueCruise app).** When a departure time is set in FordPass, the car waits before charging. Identical OCPP signature to Tesla's scheduled charging.

**Pro Power Onboard.** F-150 Lightning supports vehicle-to-grid and bidirectional power. With newer ISO 15118-20 stations you may see `Discharging` chargingState (V2G). Most current OCPP 2.1 stations don't support this yet.

## VW / Audi / Porsche (MEB, J1)

**11 kW AC cap on most MEB models.** ID.3, ID.4, ID.5, Q4 e-tron all cap at 11 kW AC charging regardless of station capability. Some early build dates capped at 7.4 kW — driver firmware update fixes this on most VINs.

**Battery preconditioning is automatic on Porsche Taycan / Audi e-tron GT** when DC fast charger is set as nav destination. No explicit precondition button.

**Departure timer behavior matches Tesla** — set in car, vehicle waits, station shows `SuspendedEV`.

## Common scenarios by symptom

| Symptom | Most likely cause | Operator action |
|---|---|---|
| Connector in `SuspendedEV` for hours, no fault | EV scheduled charging timer is waiting | None — will start at scheduled time. Confirm with driver. |
| Charging stopped within seconds of start, won't resume | Tesla, power scaled below 6 kW threshold | Unplug + replug to restart. Raise per-EVSE minimum to 6 kW. |
| Long `Preparing` / `Occupied` with no `Authorize` | EV-side fault (12V battery, BMS, isolation) | Suggest driver check vehicle warning lights. |
| Charging starts at high power then drops repeatedly | Older Leaf rapidgate, or thermal throttling on DC fast charger | Vehicle-side; no CSMS action. |
| `SuspendedEV` only on cold mornings | Battery preconditioning not active | Suggest driver use nav routing to fast charger to trigger preconditioning. |
| Energy delivered tapers off above 80% SoC | Driver-set SoC limit on the vehicle | Normal — DC fast chargers naturally taper too. |

## Diagnostic checklist

When a driver reports a session that "didn't work" but the station logs show `SuspendedEV`, walk through:

1. Is the EV reporting itself as charging or waiting? (Driver checks the in-car charge screen.)
2. Is there a scheduled timer set in the car or the manufacturer's app?
3. What was the offered current/power at the time of the suspend? If under 6 kW, that's a Tesla-style hard floor.
4. What's the ambient temperature? If under 0 °C / 32 °F and the car wasn't preconditioned, the slow start is normal.
5. Is the 12V auxiliary battery healthy? (Leaf-specific; ask if any dashboard warnings.)

## Related

- [Station Management](https://www.evtivity.com/docs/guides/station-management) for the full connector status enum and `chargingState` mapping.
- [Charging Session Lifecycle](https://www.evtivity.com/docs/guides/station-lifecycle) for the OCPP 1.6 vs 2.1 state machines.
- [Load Management](https://www.evtivity.com/docs/csms/load-management) for setting per-EVSE minimum power to avoid the Tesla hard-floor issue.
