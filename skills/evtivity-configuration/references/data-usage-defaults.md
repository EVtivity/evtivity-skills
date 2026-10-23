Generated from https://www.evtivity.com/docs/configuration/data-usage-defaults. Do not edit.

# Data Usage Defaults

Every default that affects how much data a charging station uses, per data plan and OCPP version, with message sizes and monthly estimates.

## Overview

A charging station uses data for every OCPP message, every WebSocket ping and every reconnect. EVtivity groups the settings that decide this volume into two data plans:

- **Wi-Fi or Wired**: the default for every station.
- **Cellular**: for stations on a cellular data plan. See [Cellular Stations](https://www.evtivity.com/docs/configuration/cellular-stations).

Each station uses one plan. You pick it on the station's **Configurations** tab, and a station becomes **Cellular** when a SIM attachment is confirmed on it. You change the values of each plan in **Settings > Integrations & Features > OCPP**, on the **Wi-Fi or Wired** and **Cellular** tabs.

This page lists the values of both plans, the size of the messages they cause, and the data use they add up to per month.

## Data Use per Month

Estimated data use of one station in a 30-day month, uplink (station to CSMS) and downlink (CSMS to station), with the plan's configuration template pushed.

| Plan | OCPP | Idle uplink | Idle downlink | Charging adds (4 one-hour sessions a day) | Total per month | Total with compression |
|---|---|---|---|---|---|---|
| Wi-Fi or wired | 1.6 | 3.8 MB | 3.1 MB | 7.0 MB | 13.9 MB | 10.4 MB |
| Wi-Fi or wired | 2.0.1 | 5.0 MB | 3.5 MB | 9.0 MB | 17.4 MB | 11.1 MB |
| Wi-Fi or wired | 2.1 | 5.0 MB | 3.5 MB | 9.0 MB | 17.4 MB | 11.1 MB |
| Cellular | 1.6 | 1.6 MB | 0.9 MB | 1.3 MB | 3.8 MB | 3.4 MB |
| Cellular | 2.0.1 | 1.6 MB | 0.9 MB | 1.7 MB | 4.2 MB | 3.3 MB |
| Cellular | 2.1 | 1.6 MB | 0.9 MB | 1.7 MB | 4.2 MB | 3.3 MB |

**Idle** covers heartbeats, idle readings and WebSocket pings, all day. **Charging adds** covers the status changes, authorization, transaction messages and meter readings of the sessions. **Total with compression** assumes the station uses WebSocket compression (see [Compression](https://www.evtivity.com/docs/configuration/cellular-stations#compression)).

These numbers are estimates from a byte model, not measurements of a real station. Assumptions:

- 1 EVSE on OCPP 1.6 and 2 EVSEs on OCPP 2.0.1 and 2.1, as the stations of the [Charging Station Simulator](https://www.evtivity.com/docs/simulator/overview) have. Idle readings are sent for each EVSE.
- AC charging, three phases. An AC station reports no state of charge.
- TLS 1.3 (22 bytes per record), TCP over IPv4 (52 bytes per packet), one acknowledgement per exchange.
- The station pings at its plan's `WebSocketPingInterval`, and the CSMS pings only after its plan's ping interval without a frame from the station.
- Not included: firmware downloads, diagnostics and log uploads, reconnects, and messages your stations send on their own (vendor `DataTransfer`, events, display messages).

OCPP 2.0.1 and 2.1 send the same messages here, so their rows match.

## Plan Settings

The CSMS sends these values to the station at every boot, so a reboot never undoes them. The heartbeat interval goes in the `BootNotification` reply; the others go out as `ChangeConfiguration` (OCPP 1.6) or `SetVariables` (OCPP 2.0.1 and 2.1) right after the boot.

| Setting | Wi-Fi or wired | Cellular | OCPP 1.6 key | OCPP 2.0.1 and 2.1 variable | CSMS setting (Wi-Fi or wired / Cellular) |
|---|---|---|---|---|---|
| Heartbeat interval (seconds) | 900 | 3600 | `HeartbeatInterval` | `BootNotification` interval | `ocpp.heartbeatInterval` / `ocpp.cellular.heartbeatInterval` |
| Meter value interval while charging (seconds) | 60 | 300 | `MeterValueSampleInterval` | `SampledDataCtrlr.TxUpdatedInterval` | `ocpp.meterValueInterval` / `ocpp.cellular.meterValueInterval` |
| Measurands while charging | `Energy.Active.Import.Register`, `Power.Active.Import`, `Current.Import`, `SoC` | `Energy.Active.Import.Register`, `Power.Active.Import`, `SoC` | `MeterValuesSampledData` | `SampledDataCtrlr.TxUpdatedMeasurands` | `ocpp.sampledMeasurands` / `ocpp.cellular.sampledMeasurands` |
| Idle reading interval (seconds, clock-aligned) | 900 | 0 (off) | `ClockAlignedDataInterval` | `AlignedDataCtrlr.Interval` | `ocpp.clockAlignedInterval` / `ocpp.cellular.clockAlignedInterval` |
| Idle reading measurands | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` | `MeterValuesAlignedData` | `AlignedDataCtrlr.Measurands` | `ocpp.alignedMeasurands` / `ocpp.cellular.alignedMeasurands` |
| Measurands at transaction end | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` | `StopTxnSampledData` | `SampledDataCtrlr.TxEndedMeasurands` | `ocpp.txEndedMeasurands` / `ocpp.cellular.txEndedMeasurands` |
| CSMS ping interval (seconds) | 120 | 240 | Not a station setting | Not a station setting | `ocpp.csmsPingInterval` / `ocpp.cellular.csmsPingInterval` |

An idle reading interval of 0 turns idle readings off: the CSMS sends `ClockAlignedDataInterval` 0 or `AlignedDataCtrlr.Interval` 0, and the station sends no clock-aligned readings. The idle measurands are not sent then. An OCPP 2.0.1 station gets only the measurands OCPP 2.0.1 defines.

Ranges: heartbeat 30 to 86,400 seconds, meter value interval 5 to 3,600, idle reading interval 0 or 60 to 86,400, CSMS ping interval 30 to 3,600.

### CSMS ping

The CSMS sends a WebSocket ping to a station only when it received nothing from the station for the plan's ping interval. A station that pings on its own, or sends messages more often, gets no CSMS pings. A station that answered a ping and then sends nothing for three ping intervals is disconnected: after 6 minutes on Wi-Fi or wired and 12 minutes on Cellular. A station that never answers pings is disconnected after twice its heartbeat interval without a message or ping (at least 5 minutes).

### Template settings

These station settings are not in the boot push. Each plan has a configuration template with them, one for OCPP 1.6 and one for OCPP 2.0.1 and 2.1. See [Apply the templates](https://www.evtivity.com/docs/configuration/cellular-stations#apply-the-templates).

| Setting | Wi-Fi or wired | Cellular | OCPP 1.6 key | OCPP 2.0.1 and 2.1 variable |
|---|---|---|---|---|
| Station ping interval (seconds) | 300 | 240 | `WebSocketPingInterval` | `OCPPCommCtrlr.WebSocketPingInterval` |
| Transaction message attempts | 3 | 5 | `TransactionMessageAttempts` | Not in the template |
| Transaction message retry interval (seconds) | 60 | 120 | `TransactionMessageRetryInterval` | Not in the template |
| Queue all messages while offline | false | true | Not in OCPP 1.6 | `OCPPCommCtrlr.QueueAllMessages` |
| Offline threshold (seconds) | 60 | 300 | Not in OCPP 1.6 | `OCPPCommCtrlr.OfflineThreshold` |
| Reconnect back-off minimum (seconds) | 5 | 15 | Not in OCPP 1.6 | `OCPPCommCtrlr.RetryBackOffWaitMinimum` |
| Reconnect back-off random range (seconds) | 10 | 30 | Not in OCPP 1.6 | `OCPPCommCtrlr.RetryBackOffRandomRange` |
| Reconnect back-off repeat times | 5 | 5 | Not in OCPP 1.6 | `OCPPCommCtrlr.RetryBackOffRepeatTimes` |
| Measurands at transaction start | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` | Not in OCPP 1.6 | `SampledDataCtrlr.TxStartedMeasurands` |
| Readings in the transaction end message | 0 (none) | 0 (none) | Not in OCPP 1.6 | `SampledDataCtrlr.TxEndedInterval` |
| Energy register without phases | false | true | Not in OCPP 1.6 | `SampledDataCtrlr.RegisterValuesWithoutPhases` |
| Idle readings only while idle | false | true | Not in OCPP 1.6 | `AlignedDataCtrlr.SendDuringIdle` |
| Clock-aligned readings in the transaction end message | 0 (none) | 0 (none) | Not in OCPP 1.6 | `AlignedDataCtrlr.TxEndedInterval` |

The OCPP 2.0.1 and 2.1 message timeout (`OCPPCommCtrlr.MessageTimeout`, instance `Default`) and transaction message attempts (`OCPPCommCtrlr.MessageAttempts` and `MessageAttemptInterval`, instance `TransactionEvent`) need a variable instance, which templates do not hold. Set them on the station, or send them with `SetVariables` from the station's **OCPP Commands** tab. Suggested values: message timeout 30 seconds on Wi-Fi or wired and 60 on Cellular (90 on NB-IoT), attempts 3 and 5, interval 60 and 120 seconds.

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
| OCPP 1.6 reading while charging, Wi-Fi or wired measurands | 664 B | Model |
| OCPP 1.6 reading while charging, Cellular measurands | 364 B | Model |
| OCPP 2.0.1 and 2.1 `TransactionEvent` reading, Wi-Fi or wired measurands | 930 B | Model |
| OCPP 2.0.1 and 2.1 `TransactionEvent` reading, Cellular measurands | 582 B | Model |
| WebSocket ping and pong, on the wire with TLS and TCP | about 210 B | Model |

The LAN numbers come from the CSMS message log of simulated stations on the local network. Each measurand you add to a list adds about 60 to 100 B to every reading, and a phase-wise measurand such as `Current.Import` adds three values.

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
- [Station Configurations](https://www.evtivity.com/docs/csms/station-configurations)
