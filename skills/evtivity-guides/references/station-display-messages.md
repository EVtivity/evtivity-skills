Generated from https://www.evtivity.com/docs/guides/station-display-messages (website commit 0f3462e). Do not edit.

# Station Display Messages

How EV chargers display messages today, what the OCPP 2.1 spec defines, and how EVtivity drives the on-charger screen.

This guide explains how the on-charger screen actually gets updated in modern EV charging networks. It starts with the industry landscape - what hardware vendors do, what OCPP standardizes, what doesn't - then walks through the way EVtivity uses those primitives to keep the display accurate while a session runs.

## How the industry handles on-charger messaging

There is no single way to drive a charger's screen. What you see at a public charger today usually comes from one of four layers, often combined.

1. **Firmware-default screens.** The simplest case. The charger ships with a small set of fixed screens baked into firmware (welcome, plug-in prompt, charging stats, error code). The CSMS does not control any of this. Networks that buy commodity hardware and never invest in messaging end up here. Drivers see whatever the manufacturer chose to ship.

2. **Vendor-specific config keys.** Most major hardware vendors expose a handful of OCPP configuration keys that drive on-screen text - things like `welcomeText`, `idleMessage`, `qrUrl0`, or `connCode0`. The keys are vendor-proprietary and usually undocumented in the OCPP spec. Operators tune these once during provisioning and rarely touch them again. Useful for static branding, useless for live data.

3. **Vendor `DataTransfer` extensions.** OCPP 1.6 has no standard "set screen" command, so vendors layered their own on top of the generic `DataTransfer` action. A typical pattern is `DataTransfer(vendorId="com.acme", messageId="DisplayText", data=...)` carrying a JSON or text payload that the firmware parses into the active screen. Each vendor invents its own contract. Networks running mixed fleets end up maintaining a dispatch table that picks the right vendor format per station.

4. **OCPP 2.1 `SetDisplayMessage`.** The 2.1 spec introduced a real, standardized command for on-charger messaging. The CSMS sends `SetDisplayMessage` with a slot id, a `MessageState` enum (Idle / Charging / Suspended / Discharging / Faulted / Unavailable), a priority, optional time bounds, and the message body. The firmware stores the message and renders the slot whose `MessageState` matches the station's current condition. `ClearDisplayMessage` removes a slot, `GetDisplayMessages` reads them back.

The 2.1 design is a big step up because it gives the CSMS deterministic control over which screen the driver sees, but it covers only what 2.1 stations support natively. The OCPP 2.1 fleet is still small relative to the installed 1.6 base, so most production networks today run a hybrid: standardized `SetDisplayMessage` for new 2.1 hardware, vendor `DataTransfer` for some 1.6 vendors, vendor config keys for others, and firmware defaults for the rest.

## What OCPP 2.1 actually standardizes

OCPP 2.1 splits station state into three different enums and conflating them is the most common source of bugs when integrators wire up display messages.

- **ConnectorStatus** (from `StatusNotification`): `Available`, `Occupied`, `Reserved`, `Unavailable`, `Faulted`. Coarse grained.
- **chargingState** (from `TransactionEvent`): `Charging`, `EVConnected`, `SuspendedEV`, `SuspendedEVSE`, `Idle`, `Discharging`. Reported only while a transaction is active.
- **MessageState** (in `SetDisplayMessage`): `Idle`, `Charging`, `Suspended`, `Discharging`, `Faulted`, `Unavailable`. The station automatically renders the slot whose state matches its current condition.

The CSMS's job is to take the connector and chargingState signals it receives over OCPP and translate them into the right `MessageState` slot pushes. The firmware then handles slot selection automatically as the underlying state changes.

## How EVtivity drives the display

EVtivity supports all four layers above, but its first-class implementation is for OCPP 2.1. The pipeline keeps the screen accurate while a session runs without operator intervention, and degrades cleanly to vendor extensions on 1.6 hardware.

### The six slots EVtivity manages

![OCPP 2.1 Station Display Message Pipeline](https://www.evtivity.com/images/station-display-messages.png)

EVtivity edits eight templates in the operator dashboard but only six MessageState slots ever live on the station. The three "no transaction" connector statuses - Available, Occupied without an active session, and Reserved - all share the `Idle` slot, and EVtivity rewrites that slot's contents as the connector status changes.

| Template      | Triggered by                                       | MessageState | Slot id          |
|---------------|----------------------------------------------------|--------------|------------------|
| `available`   | ConnectorStatus -> Available                       | Idle         | 9000 (rewritten) |
| `occupied`    | ConnectorStatus -> Occupied with no active session | Idle         | 9000 (rewritten) |
| `reserved`    | ConnectorStatus -> Reserved                        | Idle         | 9000 (rewritten) |
| `charging`    | chargingState -> Charging                          | Charging     | 9001             |
| `suspended`   | chargingState -> SuspendedEV / SuspendedEVSE       | Suspended    | 9002             |
| `discharging` | chargingState -> Discharging                       | Discharging  | 9003             |
| `faulted`     | ConnectorStatus -> Faulted                         | Faulted      | 9004             |
| `unavailable` | ConnectorStatus -> Unavailable                     | Unavailable  | 9005             |

Slots 9004 and 9005 are pushed once at boot and persist on the station. Slots 9001, 9002, and 9003 are pushed when a `TransactionEvent` arrives and cleared when the transaction ends.

### The refresh pipeline

EVtivity reacts to two kinds of OCPP triggers and renders a Handlebars template against live context (cost so far, energy delivered, elapsed time, station name, etc.) before pushing the result to the charger.

1. **Connector status change.** The OCPP server publishes to the `station_message_refresh` Redis channel on every `StatusNotification`, for OCPP 1.6 and 2.1 stations. The API listener picks it up, re-renders the Idle slot, and pushes a fresh `SetDisplayMessage` if the content changed.
2. **Transaction event.** The OCPP server publishes to the `station_message_transaction` channel on `TransactionEvent.Started`, `Updated`, and `Ended`. The listener renders slot 9001/9002/9003 with current cost and energy.

A worker cron (`station-message-charging-refresh`) fires every 30 seconds and re-renders the Charging slot for every active session, so the displayed cost and energy keep climbing while the EV charges. The interval is configurable via `stationMessage.charging.refreshSeconds`. Suspended, Discharging, Idle, Faulted, and Unavailable slots are event-driven and dispatch immediately - no cron involved.

A change to a setting that shows on the screens (the station message settings, company name, support phone, currency, price display, tax basis), to a state template, or to a site's display language queues one re-render of the affected online stations a few seconds later, so the screens update without waiting for the next status change.

Every push is hashed and compared against the last value stored for that slot. Identical content is skipped, so Available `<->` Occupied churn during a quiet day doesn't flood the station with redundant `SetDisplayMessage` calls.

### The editor

Operators edit templates in **Settings -> Integrations & Features -> Messages**. The page is a two-pane editor:

- The left pane lists all eight states. Click one to edit its template.
- The right pane shows the **Template Language** select, the template body, a variable picker filtered by state, and a live preview of the compiled output.

Each state has a template per language: English, German, Spanish, Korean, Simplified Chinese, and Traditional Chinese. Stations show the templates in their site's display language, else the company display language.

Every default state template starts with `{{brandLine}}`: the brand line setting, or the company name when it is empty. Variables include `{{brandLine}}`, `{{companyName}}`, `{{stationOcppId}}`, `{{energyKwh}}`, `{{powerKw}}`, `{{costFormatted}}`, and `{{elapsedFormatted}}`, plus computed helpers like `{{pricingDisplay}}`, which renders the active tariff in compact (`€0.30/kWh + €0.02/min`) or standard (`Energy: €0.30/kWh | Time: €0.02/min | Session: €2.00`) format depending on `stationMessage.pricingFormat`. Amounts are formatted in the company currency and the display language before they reach the template, so the body just references the variable. `{{elapsedFormatted}}` is the charging time in the display language: `1h 5m` in English, `1 Std., 5 Min.` in German, `1시간 5분` in Korean.

The same tab surfaces these system-wide settings:

- `stationMessage.enabled` - master toggle for the pipeline. When off, no slots are pushed.
- `stationMessage.brandLine` - optional brand text for the `{{brandLine}}` first line of every state. Falls back to the configured `companyName` when blank.
- `stationMessage.charging.refreshSeconds` - how often the Charging slot is re-rendered while a transaction is active. Lower values increase OCPP traffic.
- `stationMessage.language` - the default **Display Language** of the station screens (default `en`). It picks the template language and formats prices, numbers, the tax rate, times, and the elapsed time. A site can override it with **Station Display Language** on its Details tab, for operators that run sites in several languages. The currency and price display stay company-wide.

### Prices and the tax note

Prices on station screens follow the company price display setting (Settings > Company Info > **Prices in the driver portal**). Drivers cannot override it on a station, because the screen is public. With **Including tax (gross)**, every unit price includes the tariff tax rate. EU operators set gross: the EU Price Indication Directive 98/6/EC and national rules such as the German PAngV require the gross price at the point of sale. Unit prices show 2 to 4 decimals, so a gross price such as `0.357` is not rounded. Session costs (`{{costFormatted}}`) always include tax.

| Variable | States | Value |
|---|---|---|
| `pricingDisplay` | Available | One-line price summary, net or gross, in the display language. No tax text. |
| `energyPrice` | Available | Price per kWh as shown, without a unit |
| `timePrice` | Available | Price per charging minute as shown |
| `sessionFee` | Available | Fee per session as shown |
| `idleFee` | Available | Idle fee per minute as shown |
| `taxRatePercent` | Available, Suspended | Tax rate without the percent sign (`19`, `8.25`, `7,5` in German). Empty when the tariff has no tax. |
| `pricesIncludeTax` | Available, Suspended | True when the shown prices include tax (tax above 0 and price display gross) |
| `idleFeeRate` | Suspended | Idle fee per minute as shown, with the unit |

The tax note is template text, so you word it for your jurisdiction. The English default is:

```handlebars
{{#if taxRatePercent}}{{#if pricesIncludeTax}}incl.{{else}}excl.{{/if}} {{taxRatePercent}}% tax{{/if}}
```

It renders as `incl. 19% tax` or `excl. 19% tax`. The German default renders `inkl. 19 % MwSt.` or `zzgl. 19 % MwSt.`. The standard pricing format no longer appends `Tax: N%` to `{{pricingDisplay}}`. If you edited a template before this change, add the tax note variables to show the rate.

The preview renders a sample tariff (0.30 per kWh, 0.02 per minute, 0.10 per idle minute, 19% tax) in the company currency, the price display, and the template language, through the same code that renders station screens.

### How EVtivity handles OCPP 1.6

OCPP 1.6 has no `SetDisplayMessage`, so EVtivity falls back to vendor extensions where the hardware supports them.

- **`DataTransfer` fallback.** EVtivity sends `DataTransfer` with `vendorId='com.evtivity'`, `messageId='PricingDisplay'`, and a JSON payload containing the rendered text (`{"pricing": "..."}`) - but only for the shared Idle slot. It re-renders on connect and on every connector status change (Available, Occupied, Reserved), in the station's display language, and skips unchanged text. Slots 9001-9005 are skipped on 1.6 stations because there is no general way to address them. A station without this vendor extension answers `UnknownVendorId` and keeps its firmware screen.
- **Vendor-specific config keys.** For vendors that drive the screen through OCPP configuration keys (IoCharger, several Asian DC fast-charger OEMs), operators target those keys with a Configuration Template under **Settings -> Station Configurations** and push it on demand. EVtivity ships with a few starter templates for common vendors; the rest live as operator-authored templates that name the right keys (`QR0`, `connCode0`, `welcomeText`, etc.).

In both cases you trade portability for vendor lock-in. Mixed fleets accept that some stations will run with whatever default the firmware ships with, and that screen messaging on 1.6 will never be as live or as deterministic as on 2.1.

## Related

- [Station Management](https://www.evtivity.com/docs/guides/station-management) - station detail pages and connector state model.
- [Charging Session Lifecycle](https://www.evtivity.com/docs/guides/station-lifecycle) - how the connector and chargingState fields evolve through a session.
- [Smart Charging](https://www.evtivity.com/docs/guides/smart-charging) - sibling feature that pushes `SetChargingProfile` instead of `SetDisplayMessage`.
