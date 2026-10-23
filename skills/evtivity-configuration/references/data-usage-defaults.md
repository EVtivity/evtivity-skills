Generated from https://www.evtivity.com/docs/configuration/data-usage-defaults. Do not edit.

# Data Usage Defaults

Every default that affects how much data a charging station uses, per data plan, OCPP version and AC or DC, with message sizes and monthly estimates.

## Overview

A charging station uses data for every OCPP message, every WebSocket ping and every reconnect. EVtivity groups the settings that decide this volume into two data plans:

- **Wi-Fi or Wired**: the default for every station.
- **Cellular**: for stations on a cellular data plan. See [Cellular Stations](https://www.evtivity.com/docs/configuration/cellular-stations).

Each plan has AC and DC values for the readings a station sends while it charges. Everything else in a plan is the same for AC and DC stations.

A station uses the first plan that applies:

1. The plan set on the station, on its **Configurations** tab.
2. **Cellular** when a SIM attachment is confirmed on the station.
3. The plan set on the station's site, on the site's **Details** tab.
4. **Wi-Fi or Wired**.

You change the values of each plan in **Settings > Integrations & Features > OCPP**, on the **Wi-Fi or Wired** and **Cellular** tabs.

## Data Use per Month

Estimated data use of one station in a 30-day month, uplink (station to CSMS) and downlink (CSMS to station), with the plan's configuration template pushed.

| Plan | OCPP | Station | Idle uplink | Idle downlink | Charging adds | Total per month | Total with compression |
|---|---|---|---|---|---|---|---|
| Wi-Fi or wired | 1.6 | AC | 3.8 MB | 3.1 MB | 7.0 MB | 13.9 MB | 10.4 MB |
| Wi-Fi or wired | 1.6 | DC | 3.8 MB | 3.1 MB | 6.1 MB | 13.0 MB | 10.3 MB |
| Wi-Fi or wired | 2.0.1 | AC | 5.0 MB | 3.5 MB | 9.0 MB | 17.4 MB | 11.1 MB |
| Wi-Fi or wired | 2.0.1 | DC | 5.0 MB | 3.5 MB | 7.9 MB | 16.4 MB | 11.1 MB |
| Wi-Fi or wired | 2.1 | AC | 5.0 MB | 3.5 MB | 9.0 MB | 17.4 MB | 11.1 MB |
| Wi-Fi or wired | 2.1 | DC | 5.0 MB | 3.5 MB | 7.9 MB | 16.4 MB | 11.1 MB |
| Cellular | 1.6 | AC | 1.6 MB | 0.9 MB | 1.3 MB | 3.8 MB | 3.4 MB |
| Cellular | 1.6 | DC | 1.6 MB | 0.9 MB | 2.9 MB | 5.4 MB | 4.4 MB |
| Cellular | 2.0.1 | AC | 1.6 MB | 0.9 MB | 1.7 MB | 4.2 MB | 3.3 MB |
| Cellular | 2.0.1 | DC | 1.6 MB | 0.9 MB | 3.8 MB | 6.3 MB | 4.1 MB |
| Cellular | 2.1 | AC | 1.6 MB | 0.9 MB | 1.7 MB | 4.2 MB | 3.3 MB |
| Cellular | 2.1 | DC | 1.6 MB | 0.9 MB | 3.8 MB | 6.3 MB | 4.1 MB |

**Idle** covers heartbeats, idle readings and WebSocket pings, all day. **Charging adds** covers the status changes, authorization, transaction messages and meter readings of the sessions. **Total with compression** assumes the station uses WebSocket compression (see [Compression](https://www.evtivity.com/docs/configuration/cellular-stations#compression)).

These numbers are estimates from a byte model, not measurements of a real station. Assumptions:

- AC: 4 one-hour sessions a day, three phases, no state of charge.
- DC: 4 sessions of 30 minutes a day, one current value, state of charge reported.
- 1 EVSE on OCPP 1.6 and 2 EVSEs on OCPP 2.0.1 and 2.1, as the stations of the [Charging Station Simulator](https://www.evtivity.com/docs/simulator/overview) have. Idle readings are sent for each EVSE.
- TLS 1.3 (22 bytes per record), TCP over IPv4 (52 bytes per packet), one acknowledgement per exchange.
- The station pings at its plan's `WebSocketPingInterval`, and the CSMS pings only after its plan's ping interval without a frame from the station.
- Not included: firmware downloads, diagnostics and log uploads, reconnects, and messages your stations send on their own (vendor `DataTransfer`, events, display messages).

OCPP 2.0.1 and 2.1 send the same messages here, so their rows match.

## Plan Settings

The CSMS sends these values to the station at every boot, so a reboot never undoes them. The heartbeat interval goes in the `BootNotification` reply; the others go out as `ChangeConfiguration` (OCPP 1.6) or `SetVariables` (OCPP 2.0.1 and 2.1) right after the boot. When a station's plan changes while it is online, it gets the new values at once.

| Setting | Wi-Fi or wired | Cellular | OCPP 1.6 key | OCPP 2.0.1 and 2.1 variable | CSMS setting (Wi-Fi or wired / Cellular) |
|---|---|---|---|---|---|
| Heartbeat interval (seconds) | 900 | 3600 | `HeartbeatInterval` | `BootNotification` interval | `ocpp.heartbeatInterval` / `ocpp.cellular.heartbeatInterval` |
| AC: reading interval while charging (seconds) | 60 | 300 | `MeterValueSampleInterval` | `SampledDataCtrlr.TxUpdatedInterval` | `ocpp.meterValueInterval` / `ocpp.cellular.meterValueInterval` |
| AC: values while charging | `Energy.Active.Import.Register`, `Power.Active.Import`, `Current.Import` | `Energy.Active.Import.Register`, `Power.Active.Import` | `MeterValuesSampledData` | `SampledDataCtrlr.TxUpdatedMeasurands` | `ocpp.sampledMeasurands` / `ocpp.cellular.sampledMeasurands` |
| DC: reading interval while charging (seconds) | 30 | 60 | `MeterValueSampleInterval` | `SampledDataCtrlr.TxUpdatedInterval` | `ocpp.dc.meterValueInterval` / `ocpp.cellular.dc.meterValueInterval` |
| DC: values while charging | `Energy.Active.Import.Register`, `Power.Active.Import`, `Current.Import`, `SoC` | `Energy.Active.Import.Register`, `Power.Active.Import`, `SoC` | `MeterValuesSampledData` | `SampledDataCtrlr.TxUpdatedMeasurands` | `ocpp.dc.sampledMeasurands` / `ocpp.cellular.dc.sampledMeasurands` |
| Idle reading interval (seconds, clock-aligned) | 900 | 0 (off) | `ClockAlignedDataInterval` | `AlignedDataCtrlr.Interval` | `ocpp.clockAlignedInterval` / `ocpp.cellular.clockAlignedInterval` |
| Idle reading values | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` | `MeterValuesAlignedData` | `AlignedDataCtrlr.Measurands` | `ocpp.alignedMeasurands` / `ocpp.cellular.alignedMeasurands` |
| Values at transaction end | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` | `StopTxnSampledData` | `SampledDataCtrlr.TxEndedMeasurands` | `ocpp.txEndedMeasurands` / `ocpp.cellular.txEndedMeasurands` |
| CSMS ping interval (seconds) | 120 | 240 | Not a station setting | Not a station setting | `ocpp.csmsPingInterval` / `ocpp.cellular.csmsPingInterval` |

An idle reading interval of 0 turns idle readings off: the CSMS sends `ClockAlignedDataInterval` 0 or `AlignedDataCtrlr.Interval` 0, and the station sends no clock-aligned readings. The idle reading values are not sent then. An OCPP 2.0.1 station gets only the values OCPP 2.0.1 defines.

Ranges: heartbeat 30 to 86,400 seconds, reading interval while charging 5 to 3,600, idle reading interval 0 or 60 to 86,400, CSMS ping interval 30 to 3,600.

### AC and DC stations

The CSMS decides AC or DC from the connector types of the station's EVSEs:

- `CCS1`, `CCS2` and `CHAdeMO` are DC.
- `GBT`, `Tesla` and `NACS` are DC when the connector's maximum power is above 22 kW, else AC.
- `Type1`, `Type2` and a connector without a type are AC.

A station with at least one DC connector gets the DC values. The reading settings apply to the whole station in OCPP 1.6, 2.0.1 and 2.1, so a station with AC and DC EVSEs reads at the DC interval on every EVSE. Set the connector types on the station's **Connectors** tab: a station whose connectors have no type gets the AC values. When a connector type change turns a station from AC to DC, or back, an online station gets the new values at once.

### CSMS ping

The CSMS sends a WebSocket ping to a station only when it received nothing from the station for the plan's ping interval. A station that pings on its own, or sends messages more often, gets no CSMS pings. A station that answered a ping and then sends nothing for three ping intervals is disconnected: after 6 minutes on Wi-Fi or wired and 12 minutes on Cellular. A station that never answers pings is disconnected after twice its heartbeat interval without a message or ping (at least 5 minutes).

## Which Template to Use

| Station's data plan | Station's OCPP version | Template |
|---|---|---|
| Wi-Fi or wired | 1.6 | Wi-Fi or Wired Data Plan (OCPP 1.6) |
| Wi-Fi or wired | 2.0.1 and 2.1 | Wi-Fi or Wired Data Plan (OCPP 2.0.1 and 2.1) |
| Cellular | 1.6 | Cellular Data Plan (OCPP 1.6) |
| Cellular | 2.0.1 and 2.1 | Cellular Data Plan (OCPP 2.0.1 and 2.1) |

The templates are complete: push the one that matches the station and change nothing.

Push a template from its page in **Configuration Templates**: set the **Target Filter** (site, data plan, vendor or model) and push it to every matching station. A filter on one site reaches all of that site's stations at once. To update a single station, push the template from the station's **Configurations** tab.

Push the template again for a station you add later and for a station whose data plan changes. The out-of-sync check on the station's **Configurations** tab shows a station that still misses the template's values.

## What the CSMS Sends and What the Templates Set

Sent automatically at every boot from the station's plan, with the AC or DC values chosen from the connector types:

- Heartbeat interval
- Reading interval and values while charging (AC or DC)
- Idle readings
- Values at the end of a session

These values live in **Settings > Integrations & Features > OCPP** and the station's data plan, never in a template: a template that names one of them is refused with `400 DATA_PLAN_SETTING_IN_TEMPLATE`, on save and on push.

| OCPP 1.6 key | OCPP 2.0.1 and 2.1 variable |
|---|---|
| `HeartbeatInterval` | `OCPPCommCtrlr.HeartbeatInterval` |
| `MeterValueSampleInterval` | `SampledDataCtrlr.TxUpdatedInterval` |
| `MeterValuesSampledData` | `SampledDataCtrlr.TxUpdatedMeasurands` |
| `StopTxnSampledData` | `SampledDataCtrlr.TxEndedMeasurands` |
| `ClockAlignedDataInterval` | `AlignedDataCtrlr.Interval` |
| `MeterValuesAlignedData` | `AlignedDataCtrlr.Measurands` |

Set by the templates, one per plan per OCPP version:

- Station ping interval
- Offline message queue
- Reconnect back-off
- Message retries
- Offline threshold

| Template | Applies to |
|---|---|
| Wi-Fi or Wired Data Plan (OCPP 1.6) | OCPP 1.6 stations on the Wi-Fi or wired plan, AC and DC |
| Cellular Data Plan (OCPP 1.6) | OCPP 1.6 stations on the Cellular plan, AC and DC |
| Wi-Fi or Wired Data Plan (OCPP 2.0.1 and 2.1) | OCPP 2.0.1 and 2.1 stations on the Wi-Fi or wired plan, AC and DC |
| Cellular Data Plan (OCPP 2.0.1 and 2.1) | OCPP 2.0.1 and 2.1 stations on the Cellular plan, AC and DC |

AC and DC stations share a template because the template values depend on the network connection, not on the charger type. The boot values stay out of the templates because the CSMS picks the AC or DC values for each station.

## Template Settings

These station settings are not in the boot push, and they are the same for AC and DC stations. Each plan has a configuration template with them, one for OCPP 1.6 and one for OCPP 2.0.1 and 2.1.

| Setting | Wi-Fi or wired | Cellular | OCPP 1.6 key | OCPP 2.0.1 and 2.1 variable |
|---|---|---|---|---|
| Station ping interval (seconds) | 300 | 240 | `WebSocketPingInterval` | `OCPPCommCtrlr.WebSocketPingInterval` |
| Transaction message attempts | 3 | 5 | `TransactionMessageAttempts` | `OCPPCommCtrlr.MessageAttempts`, instance `TransactionEvent` |
| Transaction message retry interval (seconds) | 60 | 120 | `TransactionMessageRetryInterval` | `OCPPCommCtrlr.MessageAttemptInterval`, instance `TransactionEvent` |
| Message timeout (seconds) | 30 | 60 | Not in OCPP 1.6 | `OCPPCommCtrlr.MessageTimeout`, instance `Default` |
| Queue all messages while offline | false | true | Not in OCPP 1.6 | `OCPPCommCtrlr.QueueAllMessages` |
| Offline threshold (seconds) | 60 | 300 | Not in OCPP 1.6 | `OCPPCommCtrlr.OfflineThreshold` |
| Reconnect back-off minimum (seconds) | 5 | 15 | Not in OCPP 1.6 | `OCPPCommCtrlr.RetryBackOffWaitMinimum` |
| Reconnect back-off random range (seconds) | 10 | 30 | Not in OCPP 1.6 | `OCPPCommCtrlr.RetryBackOffRandomRange` |
| Reconnect back-off repeat times | 5 | 5 | Not in OCPP 1.6 | `OCPPCommCtrlr.RetryBackOffRepeatTimes` |
| Values at transaction start | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` | Not in OCPP 1.6 | `SampledDataCtrlr.TxStartedMeasurands` |
| Readings in the transaction end message | 0 (none) | 0 (none) | Not in OCPP 1.6 | `SampledDataCtrlr.TxEndedInterval` |
| Energy register without phases | false | true | Not in OCPP 1.6 | `SampledDataCtrlr.RegisterValuesWithoutPhases` |
| Idle readings only while idle | false | true | Not in OCPP 1.6 | `AlignedDataCtrlr.SendDuringIdle` |
| Clock-aligned readings in the transaction end message | 0 (none) | 0 (none) | Not in OCPP 1.6 | `AlignedDataCtrlr.TxEndedInterval` |

The templates set the variable instance where OCPP needs one: `Default` for the message timeout, `TransactionEvent` for the transaction message attempts and retry interval.

## Message Sizes

Sizes of the OCPP message text (the JSON), before WebSocket, TLS and TCP add their headers.

| Message | Size | Source |
|---|---|---|
| `Heartbeat` request payload / reply payload | 2 B / 43 B | Measured on the LAN |
| OCPP 1.6 `MeterValues` payload with five measurands | 542 B | Measured on the LAN |
| OCPP 2.0.1 and 2.1 `MeterValues` payload with five measurands | 622 B | Measured on the LAN |
| `Heartbeat` request / reply, whole message | 57 B / 85 B | Model |
| OCPP 1.6 idle reading, energy only | 247 B | Model |
| OCPP 2.0.1 and 2.1 idle reading, energy only | 258 B | Model |
| OCPP 1.6 reading while charging: Wi-Fi or wired AC / DC | 664 B / 533 B | Model |
| OCPP 1.6 reading while charging: Cellular AC / DC | 364 B / 446 B | Model |
| OCPP 2.0.1 and 2.1 `TransactionEvent` reading: Wi-Fi or wired AC / DC | 930 B / 783 B | Model |
| OCPP 2.0.1 and 2.1 `TransactionEvent` reading: Cellular AC / DC | 582 B / 680 B | Model |
| WebSocket ping and pong, on the wire with TLS and TCP | about 210 B | Model |

The LAN numbers come from the CSMS message log of simulated stations on the local network. Each value you add to a list adds about 60 to 100 B to every reading. On an AC station a per-phase value such as `Current.Import` adds three values, one per phase; a DC station reports one.

## Other Costs

| Cost | Size | When |
|---|---|---|
| Reconnect (TLS handshake, WebSocket upgrade) | 5 to 7 kB | Each time the connection drops, for example after a carrier drops an idle connection |
| Mutual TLS handshake with an ECDSA certificate | about 3.8 kB | Security profile 3 reconnects |
| Mutual TLS handshake with an RSA certificate | about 5.4 kB | Security profile 3 reconnects |
| Firmware update | 50 to 500 MB | Each update, often 2 to 4 times a year |

One dropped connection every 5 minutes adds 45 to 60 MB a month, more than the whole Cellular plan. A firmware update usually costs more than a year of OCPP messages.

## Related Pages

- [Cellular Stations](https://www.evtivity.com/docs/configuration/cellular-stations)
- [OCPP Settings](https://www.evtivity.com/docs/configuration/ocpp-settings)
- [Data Retention](https://www.evtivity.com/docs/configuration/data-retention)
- [Settings](https://www.evtivity.com/docs/csms/settings#ocpp)
- [Sites](https://www.evtivity.com/docs/csms/sites#data-plan)
- [Station Configurations](https://www.evtivity.com/docs/csms/station-configurations)
