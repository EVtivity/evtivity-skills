Generated from https://www.evtivity.com/docs/csms/sessions. Do not edit.

# Sessions

Monitor charging sessions, review transaction details, and track energy delivery and costs.

## Overview

Sessions represent individual charging transactions between a driver and a station. The CSMS tracks the full lifecycle from start to completion, including real-time meter values, cost calculations, idle detection, and payment processing.

![Sessions list](https://www.evtivity.com/screenshots/csms/sessions-list.png)

## Session List

The sessions list shows all charging sessions with filters for status, station, site, driver, and date range. Each row displays the station name, driver, status, energy delivered, duration, and cost.

Free vend sessions show a "Free Vend" label in the driver column instead of a driver name.

Select **Manual billing** in the status filter to list the sessions that wait for billing outside the platform. See [Billing a Session the CSMS Could Not End](#billing-a-session-the-csms-could-not-end).

## Session Statuses

| Status | Badge | Description |
|--------|-------|-------------|
| active | Success (green) | Charging in progress |
| active (idle) | Warning (yellow) | Transaction active but no energy flowing |
| completed | Secondary (gray) | Session finished normally |
| failed | Destructive (red) | Session ended with an error |
| pending | Warning (yellow) | Session awaiting confirmation |

## Session Detail

Click any session to view its full detail page. The detail page has three tabs. Users with the `audit:read` permission also see a **History** tab that lists the audited changes to the session, such as a billing by an operator.

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

## Billing a Session the CSMS Could Not End

The CSMS ends some sessions itself, for example when a new transaction starts on the same EVSE or the station no longer knows the transaction. When ending such a session fails 5 times, the CSMS gives up and sends operators a session end failed alert. The session gets the status faulted and the stopped reason `EndRequestFailed`. Its cost is set to 0 and any pre-authorization hold is cancelled, so the driver is not charged. The **Details** tab of the session shows a **Billing** card with the **Not billed** badge.

![Session not billed](https://www.evtivity.com/screenshots/csms/session-rebill-detail.png)

To bill the session:

1. Open the session from the Sessions page.
2. On the **Details** tab, click **Bill session** in the **Billing** card.
3. Confirm in the **Bill this session?** dialog.

The CSMS recomputes the cost from the tariff up to the last meter value of the session. It then debits the balance of a prepaid token, or charges the driver's default saved card without the driver present. The session becomes completed, the card shows **Billed by an operator**, and the driver receives a session receipt.

### Manual Billing

A session that cannot be charged automatically is marked for manual billing. This happens when:

- The card is declined or needs the cardholder to authenticate (3D Secure).
- The driver has no saved card.
- The session is a guest session or has no driver.
- The prepaid balance could not be debited.
- The session uses a prepaid token but already has a payment record, such as the cancelled pre-authorization hold. The card shows **The session already has a payment record, so the prepaid balance was not debited.**

The session becomes completed with its recomputed cost and shows a **Manual billing** badge on the detail page and in the session list. Collect the amount shown in the **Billing** card outside the platform, for example by invoice or bank transfer. The driver receives no receipt.

![Session marked for manual billing](https://www.evtivity.com/screenshots/csms/session-manual-billing-detail.png)

### Notes

- The **Bill session** button requires both the `sessions:write` and `payments:write` permissions. Without them the card shows no button.
- Each session is billed once. A billed session or one marked for manual billing cannot be billed again.
- Roaming sessions (billed by the roaming partner), free vend sessions, sessions without a tariff, and sessions already paid cannot be billed.
- The button is disabled while the session cannot be billed, and its tooltip gives the reason: a payment the provider has not settled yet, another billing of the session in progress, or one of the cases above. When a billing request stopped before it finished, the button is available again 5 minutes later.
- A billing whose card charge got no answer from the payment provider can be run again. The retry sends the same charge with the same idempotency key, so the driver is charged once, and the session is billed at the amount first charged or requested, not a newly computed one.
- After 23 hours without an answer the CSMS no longer retries the charge, because the provider may no longer recognize its idempotency key (Stripe keeps it 24 hours). **Bill session** then returns `SESSION_REBILL_PAYMENT_PENDING`, and the daily payment reconciliation lists the payment as a discrepancy of kind `rebill_pending`. Check the payment provider for a payment with the idempotency key `rebill_<sessionId>`.
- Each billing is recorded in the **History** tab of the session.

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
