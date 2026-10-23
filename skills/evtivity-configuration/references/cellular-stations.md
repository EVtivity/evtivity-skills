Generated from https://www.evtivity.com/docs/configuration/cellular-stations. Do not edit.

# Cellular Stations

The recommended OCPP configuration for charging stations on cellular data plans, why each value was chosen, and how to apply it.

## Overview

A station on a cellular data plan pays for every byte, and the carrier network drops idle connections sooner than a Wi-Fi or wired network does. EVtivity has a **Cellular** data plan for these stations: one set of OCPP settings that keeps the connection alive with less data. This page explains the values, why they were chosen and how to apply them.

For every value and the data use of both plans, see [Data Usage Defaults](https://www.evtivity.com/docs/configuration/data-usage-defaults).

## Data Use per Month

Estimated data use of one station in a 30-day month, with the plan's configuration template pushed.

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

These are estimates from a byte model, not measurements of a real station. They assume 4 one-hour AC sessions or 4 DC sessions of 30 minutes a day, 1 EVSE on OCPP 1.6 and 2 EVSEs on OCPP 2.0.1 and 2.1, as the simulator stations have, TLS 1.3 and TCP over IPv4. Firmware downloads and reconnects are not included. [Data Usage Defaults](https://www.evtivity.com/docs/configuration/data-usage-defaults#data-use-per-month) lists every assumption and the measured message sizes.

Station vendors report 20 to 150 MB a month for AC stations and 200 MB to 2 GB for DC stations with a screen or payment terminal, firmware included ([Simbase](https://simbase.com/industries/ev-charging), [IoT SIM data guide](https://simfalcon.ie/guides/how-much-data-iot-sim/)). Most of that is firmware, vendor messages and the station's own services. The OCPP part is what the plan controls.

## Settings

| Setting | Cellular | Wi-Fi or wired | OCPP 1.6 key | OCPP 2.0.1 and 2.1 variable |
|---|---|---|---|---|
| Heartbeat interval (seconds) | 3600 | 900 | `HeartbeatInterval` | `BootNotification` interval |
| AC: reading interval while charging (seconds) | 300 | 60 | `MeterValueSampleInterval` | `SampledDataCtrlr.TxUpdatedInterval` |
| AC: values while charging | `Energy.Active.Import.Register`, `Power.Active.Import` | `Energy.Active.Import.Register`, `Power.Active.Import`, `Current.Import` | `MeterValuesSampledData` | `SampledDataCtrlr.TxUpdatedMeasurands` |
| DC: reading interval while charging (seconds) | 60 | 30 | `MeterValueSampleInterval` | `SampledDataCtrlr.TxUpdatedInterval` |
| DC: values while charging | `Energy.Active.Import.Register`, `Power.Active.Import`, `SoC` | `Energy.Active.Import.Register`, `Power.Active.Import`, `Current.Import`, `SoC` | `MeterValuesSampledData` | `SampledDataCtrlr.TxUpdatedMeasurands` |
| Idle reading interval (seconds) | 0 (off) | 900 | `ClockAlignedDataInterval` | `AlignedDataCtrlr.Interval` |
| Idle reading values | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` | `MeterValuesAlignedData` | `AlignedDataCtrlr.Measurands` |
| Values at transaction end | `Energy.Active.Import.Register` | `Energy.Active.Import.Register` | `StopTxnSampledData` | `SampledDataCtrlr.TxEndedMeasurands` |
| CSMS ping interval (seconds) | 240 | 120 | Not a station setting | Not a station setting |
| Station ping interval (seconds) | 240 | 300 | `WebSocketPingInterval` | `OCPPCommCtrlr.WebSocketPingInterval` |
| Transaction message attempts | 5 | 3 | `TransactionMessageAttempts` | `OCPPCommCtrlr.MessageAttempts` (instance `TransactionEvent`) |
| Transaction message retry interval (seconds) | 120 | 60 | `TransactionMessageRetryInterval` | `OCPPCommCtrlr.MessageAttemptInterval` (instance `TransactionEvent`) |
| Queue all messages while offline | true | false | Not in OCPP 1.6 | `OCPPCommCtrlr.QueueAllMessages` |
| Offline threshold (seconds) | 300 | 60 | Not in OCPP 1.6 | `OCPPCommCtrlr.OfflineThreshold` |
| Message timeout (seconds) | 60 | 30 | Not in OCPP 1.6 | `OCPPCommCtrlr.MessageTimeout` (instance `Default`) |
| Reconnect back-off minimum / random range / repeat times | 15 / 30 / 5 | 5 / 10 / 5 | Not in OCPP 1.6 | `OCPPCommCtrlr.RetryBackOffWaitMinimum`, `RetryBackOffRandomRange`, `RetryBackOffRepeatTimes` |
| Energy register without phases | true | false | Not in OCPP 1.6 | `SampledDataCtrlr.RegisterValuesWithoutPhases` |
| Idle readings only while idle | true | false | Not in OCPP 1.6 | `AlignedDataCtrlr.SendDuringIdle` |

The first nine rows are plan settings in the CSMS, sent at every boot. A DC station gets the DC rows (see [AC and DC stations](https://www.evtivity.com/docs/configuration/data-usage-defaults#ac-and-dc-stations)). The others are in the plan's configuration templates. See [Data Usage Defaults](https://www.evtivity.com/docs/configuration/data-usage-defaults#plan-settings) for the setting keys.

## Why These Values

### Carrier NAT timeouts and keep-alive

Mobile carriers put stations behind NAT. A NAT mapping without traffic expires, and the carrier drops the connection without telling either side. Measured cellular NAT idle timeouts are 255 to 300 seconds ([NetPiculet](https://web.eecs.umich.edu/~zmao/Papers/netpiculet.pdf), [carrier-grade NAT timeouts](https://blog.wirelessmoves.com/2020/09/carrier-grade-nat-timeouts-and-how-to-configure-your-xmpp-server.html), [AWS re:Post](https://repost.aws/questions/QUhOcqMNk0Sc2VGkxHwij05Q/cellular-iot-devices-cannot-stay-connected-to-aws)). RFC 5382 asks for at least 2 hours 4 minutes, but carriers do not follow it. No values are published for LTE-M and NB-IoT.

The station and the CSMS both ping every 240 seconds, below that range. Any frame resets the NAT timer, so the CSMS pings only after 240 seconds without a frame from the station: when the station pings on its own, the CSMS sends no pings. The CSMS keeps its ping on so a station that does not ping still keeps its connection. The Open Charge Alliance names 50 to 600 seconds as the ping range ([OCA, Improving Uptime Monitoring](https://openchargealliance.org/wp-content/uploads/2024/08/improving_uptime_with_ocpp_v1_2.pdf)).

A load balancer or proxy between the stations and the CSMS has its own idle timeout. Keep it above the largest ping interval plus 30 seconds. The AWS deployment sets the load balancer idle timeout to 600 seconds ([ALB attributes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/edit-load-balancer-attributes.html)). On Kubernetes, check the idle or read timeout of your ingress or gateway.

### Heartbeat

The heartbeat tells the station the CSMS time and tells the CSMS the station is there. With pings keeping the connection alive, the heartbeat is needed less often. OCPP-J 1.6, section 5.3, says WebSocket pings can replace most heartbeats, but not the clock sync. OCPP 1.6 section 4.6 recommends at least one heartbeat a day. Vendors use 900 seconds (GreenFlux) up to 86,400 seconds (Zaptec, Monta, [Monta changelog](https://changelog.monta.com/en/optimized-ocpp-heartbeat-interval-for-improved-scalability)). The Cellular plan uses 3600: the station clock is checked every hour and the CSMS still notices a station that stopped sending.

### Meter values

Every reading while charging is one message, and each value makes it larger. OCPP gives 300 seconds as its example interval. Monta reads every 180 seconds with energy only; eMabler uses 60 to 180 seconds ([Monta](https://monta.com/help/integrations-advanced-developer/ocpp-configuration-for-charge-points-a-short-explainer), [eMabler](https://docs.emabler.com/docs/emabler-ocpp-configuration-parameters-guide)).

The Cellular plan reads an AC station every 300 seconds with energy and power, and a DC station every 60 seconds with energy, power and state of charge. DC reads faster for three reasons:

- A DC session is short. A 30-minute session read every 300 seconds gives only six readings, too few to follow its power curve.
- The power of a DC session changes fast as the battery fills, and [load management](https://www.evtivity.com/docs/csms/load-management) shares the site's power from the readings. Older readings mean the load manager works on old power values.
- The state of charge tells the driver and the CSMS how far the session is. AC stations do not report it.

GreenFlux uses the same split: AC every 900 seconds (300 with smart charging) and DC every 300 seconds (30 with smart charging) ([GreenFlux](https://greenflux.helpkit.so/13d17d68194280c7bed4d86435b26298)). On the Wi-Fi or wired plan, AC reads every 60 seconds and DC every 30.

Idle (clock-aligned) readings are off on the Cellular plan. The transaction start and end messages carry the energy register, and the CSMS does not need readings of an idle station. Set the idle reading interval to 900 when you need interval data, for example for a utility report.

### Compression

The CSMS supports WebSocket compression (permessage-deflate, RFC 7692) on every station connection, on the plain and the TLS ports. OCPP 2.0.1 and 2.1 require the CSMS to support it (OCPP 2.0.1 part 4, section 3.3; OCPP 2.1 part 4, section 3.4) and recommend it for stations to reduce mobile data.

- A station uses it when its WebSocket client offers it in the handshake. Many station firmwares have a setting for it, or always offer it.
- No station setting for it exists in OCPP. A station that does not offer it still works, uncompressed.
- The station compresses what it sends. A meter reading of 1,318 B shrinks to about 300 B on its own, and to about 50 B when the station keeps its compression state between messages. The CSMS compresses only its messages of 1,024 B or more; most replies are smaller.

The `OCPP_WS_COMPRESSION` environment variable (default `true`) turns compression off on the CSMS, for example to read the frames while you debug. See [Environment Variables](https://www.evtivity.com/docs/configuration/environment-variables).

### TLS

Every reconnect costs a TLS handshake. Use TLS 1.3, an ECDSA P-256 certificate and a short certificate chain, and let the station resume sessions with session tickets. A mutual TLS handshake with an ECDSA certificate takes about 3.8 kB, with RSA about 5.4 kB ([TLS overhead](https://www.ietf.org/archive/id/draft-mattsson-uta-tls-overhead-00.xml), [ECC handshake](https://techcommunity.microsoft.com/blog/iotblog/40-smaller-tls-handshake-with-ecc-cert-for-iot-hub/1943081), [TLS 1.3 IoT profile](https://datatracker.ietf.org/doc/html/draft-ietf-uta-tls13-iot-profile-14), [NB-IoT TLS study](https://arxiv.org/pdf/2309.03338)).

### Modem power saving

LTE-M and NB-IoT modems can sleep with PSM (Power Saving Mode) and eDRX (extended discontinuous reception). While the modem sleeps, the station cannot receive a remote start, a stop or a configuration change. A charging station has mains power, so run PSM off and eDRX off or short ([Soracom](https://developers.soracom.io/en/docs/air/edrx-psm-timers), [GSMA](https://www.gsma.com/iot/resources/what-is-the-difference-in-data-throughput-between-lte-m-nb-iot-and-3g-or-4g/)). These are modem settings of the station, not OCPP settings.

### Risks of going too low

- Pings above the carrier NAT timeout: the carrier drops the connection without a close. The CSMS sees the station offline only after the ping timeout, remote commands fail until the station reconnects, and each reconnect costs 5 to 7 kB.
- A long heartbeat without pings: an outage can go unnoticed for a day.
- Long reading intervals while charging: load management and the session view work on older data, most on DC stations.
- PSM or long eDRX: the station misses remote starts and stops.
- Pings or heartbeats far below the defaults: more data for no gain, and some networks treat very frequent traffic as abuse (GreenFlux warns a charger can be blocked).

## Pick the Cellular Plan

A station uses the first plan that applies:

1. The plan set on the station.
2. **Cellular** when a SIM attachment is confirmed on the station. See [Confirm SIM](https://www.evtivity.com/docs/csms/station-connectivity#confirm-sim).
3. The plan set on the station's site.
4. **Wi-Fi or Wired**.

Set the plan for a whole site on the site's **Details** tab, in the **Data Plan** card: **Not Set**, **Wi-Fi or Wired** or **Cellular**. You need `sites:write`. Before you save, the confirmation names how many stations change plan. Stations with their own plan or a confirmed SIM keep theirs. See [Sites](https://www.evtivity.com/docs/csms/sites#data-plan).

Set the plan for one station on its **Configurations** tab, in the **Data Plan** card. You need `stations:write`. The card shows the plan the station uses and where it came from: set on the station, a confirmed SIM, the site, or the default. It also shows whether the station gets the AC or the DC values. Choose **Wi-Fi or Wired** or **Cellular** and click **Save**. A plan set on the station wins over a SIM and the site. Choose **Use the Site's Plan** to remove the station's own choice.

When a SIM is detached, the station goes back to its site's plan or the default, unless the station has its own plan.

When a station's plan changes while it is online, it gets the plan's settings at once, the heartbeat interval included. An offline station gets them at its next boot. At every boot the CSMS sends the station its plan's settings again, so a reboot never undoes them.

To change the values of a plan, open **Settings > Integrations & Features > OCPP** and its **Cellular** tab. Each station on the plan gets the new values at its next boot or plan change.

## Which Template to Use

| Station's data plan | Station's OCPP version | Template |
|---|---|---|
| Wi-Fi or wired | 1.6 | Wi-Fi or Wired Data Plan (OCPP 1.6) |
| Wi-Fi or wired | 2.0.1 and 2.1 | Wi-Fi or Wired Data Plan (OCPP 2.0.1 and 2.1) |
| Cellular | 1.6 | Cellular Data Plan (OCPP 1.6) |
| Cellular | 2.0.1 and 2.1 | Cellular Data Plan (OCPP 2.0.1 and 2.1) |

The templates are complete: push the one that matches the station and change nothing.

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

## Apply the Templates

The station ping, the offline queue, the back-off and the other station-side settings are not in the boot push. They are the same for AC and DC stations. EVtivity ships four configuration templates with them, in **Configuration Templates**:

| Template | OCPP version | Target filter |
|---|---|---|
| Wi-Fi or Wired Data Plan (OCPP 1.6) | 1.6 | Data plan Wi-Fi or wired |
| Cellular Data Plan (OCPP 1.6) | 1.6 | Data plan Cellular |
| Wi-Fi or Wired Data Plan (OCPP 2.0.1 and 2.1) | 2.1, also OCPP 2.0.1 stations | Data plan Wi-Fi or wired |
| Cellular Data Plan (OCPP 2.0.1 and 2.1) | 2.1, also OCPP 2.0.1 stations | Data plan Cellular |

1. Set the data plan of your cellular stations or their sites.
2. Open **Configuration Templates** and the template from [Which Template to Use](#which-template-to-use) for each OCPP version your stations use.
3. Check the matching stations, then push the template. Each station records its result: accepted, rejected or failed.
4. A station that rejects a variable keeps its own value. Check the push result and the station's **Configurations** tab.

Templates are pushed only when you push them. Push the template again after you change a station's plan, and after a firmware update that resets the station settings (the drift check on the **Configurations** tab shows it). See [Station Configurations](https://www.evtivity.com/docs/csms/station-configurations#templates).

## Related Pages

- [Data Usage Defaults](https://www.evtivity.com/docs/configuration/data-usage-defaults)
- [Station Connectivity](https://www.evtivity.com/docs/csms/station-connectivity)
- [OCPP Settings](https://www.evtivity.com/docs/configuration/ocpp-settings)
- [Data Retention](https://www.evtivity.com/docs/configuration/data-retention)
