Generated from https://www.evtivity.com/docs/csms/sessions (website commit 900fb20). Do not edit.

# Sessions

Monitor charging sessions, review transaction details, and track energy delivery and costs.

## Overview

Sessions represent individual charging transactions between a driver and a station. The CSMS tracks the full lifecycle from start to completion, including real-time meter values, cost calculations, idle detection, and payment processing.

![Sessions list](https://www.evtivity.com/screenshots/csms/sessions-list.png)

## Session List

The sessions list shows all charging sessions with filters for status, station, site, driver, and date range. Each row displays the station name, driver, status, energy delivered, duration, and cost.

Free vend sessions show a "Free Vend" label in the driver column instead of a driver name.

## Session Statuses

| Status | Badge | Description |
|--------|-------|-------------|
| active | Success (green) | Charging in progress |
| active (idle) | Warning (yellow) | Transaction active but no energy flowing |
| completed | Secondary (gray) | Session finished normally |
| failed | Destructive (red) | Session ended with an error |
| pending | Warning (yellow) | Session awaiting confirmation |

## Session Detail

Click any session to view its full detail page. The detail page has three tabs.

![Session detail](https://www.evtivity.com/screenshots/csms/session-detail.png)

### Details

The overview of the session including station, EVSE, driver, start/end times, energy delivered, duration, idle time, cost, and CO₂ avoided (when the site has a carbon region configured).

Contains a transaction events timeline showing OCPP events (Started, Updated, Ended) with trigger reasons and charging state (OCPP 2.1).

The cost includes tax. With the default tax calculation method (net), the calculator adds these net components and then the tariff tax rate. With the gross method, each component is the gross price times the quantity, and the tax is taken out. Each session stores its net amount and tax with its cost.

- Energy cost (kWh delivered multiplied by the per-kWh rate)
- Time cost (session duration multiplied by the per-minute rate)
- Session fee (flat fee per session)
- Idle fee (idle minutes beyond the grace period multiplied by the idle rate)
- Tax at the tariff tax rate

When split billing is enabled and the tariff changed during the session, each tariff segment is costed and taxed at its own rate. The driver's invoice lists the net amount and tax per rate. See [Drivers](https://www.evtivity.com/docs/csms/drivers).

### Meter Values

A table of meter value readings received during the session. Includes energy (kWh), power (kW), voltage (V), current (A), and state of charge (%) when available from the station.

![Session meter values](https://www.evtivity.com/screenshots/csms/session-meter-values-tab.png)

### Payment

Payment record for the session showing the payment status, source, pre-auth amount, captured amount, refunded amount, and failure reason. Operators can issue refunds (full or partial) from this tab for captured payments.

With a provider that confirms operations by webhook (Adyen, or the test provider in async mode), the tab also shows:

- **Provider confirmation** - **Capture awaiting confirmation**, **Cancellation awaiting confirmation**, or **Hold increase awaiting confirmation** until the provider's event arrives.
- **Refunds** - every refund with its state: **Pending confirmation**, **Succeeded**, or **Failed**. A new refund shows "Refund requested. The payment provider confirms it shortly."
- While a capture awaits confirmation, refunds are not possible yet: "Refunds are possible once the provider confirms the capture."

See [Adyen captures and refunds](https://www.evtivity.com/docs/integrations/adyen#captures-and-cancellations).

![Session payment](https://www.evtivity.com/screenshots/csms/session-payment-tab.png)

## Reservation Token Mismatch

When a session was started under a reservation but the OCPP Authorize matched a different token than the one the reservation was bound to, the session detail page shows a yellow **Reservation token mismatch** badge next to the status. The check is informational - the session is allowed to proceed, but the badge surfaces a discrepancy worth investigating (e.g., the driver swiped a different card than the one they pre-bound the reservation with, or two cards are sharing the same `idToken`). The expected/actual token ids are stored in `charging_sessions.metadata.reservationTokenMismatch`.

## Idle Detection

The CSMS detects idle state using multiple signals, prioritized by reliability:

1. **chargingState** (OCPP 2.1 only) - TransactionEvent reports the charging state directly.
2. **Power reading** (1.6 and 2.1) - Power.Active.Import of 0 in meter values.
3. **StatusNotification** (1.6 only) - SuspendedEV, SuspendedEVSE, or Finishing status.
4. **Flat energy reading** (1.6 and 2.1) - Energy meter value unchanged between readings.

Higher-priority signals are never overwritten by lower-priority ones. The idle grace period (configurable in Settings) determines when idle fees start accruing. The grace period is applied during cost calculation, not during detection.

## Reporting an Issue

To open a support case about a session, click **Create Case** on the Support Cases page and add the session under **Sessions**. Drivers report an issue from the session in the portal. See [Support Cases](https://www.evtivity.com/docs/csms/support-cases) for details.
