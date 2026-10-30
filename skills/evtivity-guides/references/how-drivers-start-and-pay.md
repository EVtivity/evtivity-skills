Generated from https://www.evtivity.com/docs/guides/how-drivers-start-and-pay. Do not edit.

# How Drivers Start and Pay

The five ways a driver starts a charging session and how each one is paid, from the portal and app to RFID cards, guest QR checkout and payment terminals.

## Overview

A driver can start a charging session in five ways. Each way has its own rules for who picks the connector, what pays for the session, and when a credit card is checked:

1. From the driver portal or the mobile app.
2. With an RFID card that holds a prepaid balance.
3. With an RFID card without a prepaid balance, linked to a driver account.
4. With guest QR checkout in a browser, without an account.
5. With a credit card on a payment terminal at the station.

This guide compares the five ways, then walks through each one. For setup, see the linked pages in each section.

## Comparison

| Way to start | Account needed | Who picks the connector | What pays | When the credit card is checked | Car plugged in first | Shows in driver history |
|---|---|---|---|---|---|---|
| Portal or mobile app | Yes | The driver, in the portal or the app | Free vend, the fleet account, or the selected saved credit card. Nothing on a free tariff. | A hold is placed before the station starts. A decline means charging never begins. | Yes. At Start, the portal and the app check the cable. Without a detected car, they ask the driver to plug in, start nothing and place no hold. | Yes |
| RFID card with a prepaid balance | No. The operator issues the RFID card. It can belong to a driver. | The driver plugs in and taps the RFID card | The prepaid balance only | Never. No credit card is used. | Yes. The driver plugs in, then taps the RFID card. | Only when the RFID card belongs to a driver |
| RFID card without a prepaid balance | Yes. The RFID card is linked to a driver. | The driver plugs in and taps the RFID card | The fleet account, else the driver's default saved credit card | A hold is placed right after the session starts. Without a saved credit card, or on a decline, the session stops at once and nothing is billed. | Yes. The driver plugs in, then taps the RFID card. | Yes |
| Guest QR checkout (browser) | No | The driver, on the QR code page | The credit card entered in the browser | A hold is placed before the station starts | Not required. The session waits up to 15 minutes for the station to begin. | No. The driver gets a session page and an optional email receipt. |
| Payment terminal | No | The pairing of the terminal in the CSMS | The credit card presented at the terminal only | The bank places a hold at the terminal before any session exists | No. The driver pays first, then plugs in. | No. The driver gets a receipt link. |

## Payment Order

When a session starts, the CSMS decides what pays for it, in this order:

1. **Free vend site**: nothing is billed. See [Free Vend Mode](https://www.evtivity.com/docs/csms/free-vend).
2. **Prepaid balance**: the session is paid from the balance. This applies to an RFID card with a prepaid balance only.
3. **Fleet account billing**: the driver's fleet pays. When the driver belongs to several fleets, the oldest membership in a fleet that bills on account wins. An operator can opt a member out, and that member pays by credit card. See [Fleets](https://www.evtivity.com/docs/csms/fleets).
4. **Credit card hold**: a hold is placed on the driver's credit card.

A free tariff needs no payment. A start from the portal or the app never uses a prepaid balance, even when the driver owns an RFID card with one. Sessions of roaming partners are billed by the partner.

The session keeps this decision. A later change, for example to the fleet, does not change a running session.

## Portal or Mobile App

The driver picks a station and a connector in the [driver portal](https://www.evtivity.com/docs/portal/charging) or the [mobile app](https://www.evtivity.com/docs/mobile-app/guide/start-and-stop-a-charge).

1. The driver selects a connector. Selecting a connector reserves nothing.
2. When the session needs payment, the driver's default saved credit card is preselected. The driver can pick another saved credit card. The **Start Charging** button appears only when a saved credit card is selected. A driver whose fleet bills on account sees the fleet in place of the credit card.
3. The driver taps **Start Charging**. The portal and the app check for a plugged-in cable. When the station detects no car, they show a message with only an **OK** button that asks the driver to plug in. They do not start the station or place a hold. The driver plugs in and taps **Start Charging** again.
4. The server checks the connector, and checks that the selected credit card belongs to the driver.
5. The CSMS places a hold on the credit card. When the bank declines it, the station is never asked to start and nothing is charged.
6. The CSMS asks the station to start. Charging begins when the station detects the car.

The driver needs a saved credit card for a paid session. A driver needs one too when the tariff is free now but a paid tariff can apply later in the session. Drivers add credit cards on [Payment Methods](https://www.evtivity.com/docs/portal/payment-methods) in the portal or under [Payments](https://www.evtivity.com/docs/mobile-app/guide/payments) in the app.

## RFID Card with a Prepaid Balance

An operator issues the RFID card and sets its balance in the CSMS. See [Prepaid Cards](https://www.evtivity.com/docs/csms/tokens#prepaid-cards). The RFID card can belong to a driver account, but needs none.

1. The driver plugs in and taps the RFID card on the station's reader.
2. The station asks the CSMS. An RFID card with a prepaid balance never goes on a local authorization list, and its approval expires at once, so the station never keeps it in its cache.
3. The CSMS refuses the RFID card when its balance is 0 or less, with "no credit" on OCPP 2.1 and "blocked" on OCPP 1.6. It also refuses it when the RFID card already has a running session.
4. When the CSMS accepts it, the session starts. Its cost limit is the balance minus the cost of the RFID card's other sessions that are not yet settled.
5. At the cost limit, an OCPP 2.1 station stops charging itself. An OCPP 1.6 or 2.0.1 station is stopped by the CSMS. When the credit runs out, the station display shows a message and the driver gets a notice.
6. When the session ends, the CSMS deducts its cost from the balance.

Notes:

- The station cannot start a session with this RFID card while it is offline, unless the station accepts unknown RFID cards when offline.
- Drivers cannot top up a balance. Operators set and change balances in the CSMS.
- A balance change during a session applies from the next session.
- A session is linked to the driver who owns the RFID card. It shows in that driver's history. An RFID card that belongs to no driver leaves no driver history.

## RFID Card Linked to a Driver

An RFID card without a prepaid balance pays through the driver it belongs to. Drivers add their own RFID cards in the [portal](https://www.evtivity.com/docs/portal/rfid-cards) or the [app](https://www.evtivity.com/docs/mobile-app/guide/rfid-cards), and operators register them in [Tokens](https://www.evtivity.com/docs/csms/tokens). See also [Using RFID Tokens](https://www.evtivity.com/docs/guides/using-rfid-tokens).

1. The driver plugs in and taps the RFID card on the station's reader.
2. The station asks the CSMS, or checks its local authorization list, and starts the session.
3. When the driver's fleet bills on account, the fleet pays and no hold is placed.
4. Otherwise the CSMS places a hold on the driver's default saved credit card right after the session starts. The driver cannot pick another credit card at the station.
5. When the driver has no saved credit card, or the bank declines the hold, the CSMS stops the session at once and bills nothing.

## Fleet Account Billing

A driver whose fleet bills on account charges without a credit card. See [Charge on Account](https://www.evtivity.com/docs/csms/fleets#charge-on-account).

- The CSMS places no hold, for portal, app and RFID card starts alike.
- When the fleet has a credit limit and no credit left, the start is refused. A session that reaches its share of the credit stops with the reason "account credit limit".
- The fleet is invoiced, on demand or by the monthly run. When the fleet invoices each member, each driver gets an invoice for their own sessions.
- A member the operator opted out pays by credit card like any other driver.

## Guest QR Checkout

A driver without an account scans the QR code on the station. See [Guest Charging](https://www.evtivity.com/docs/portal/guest-charging).

1. The driver scans the QR code and picks a connector on the page.
2. On a paid tariff, the driver taps **Pay with card** and enters a credit card in the browser. On a free tariff, the driver starts without a credit card.
3. The payment provider places a hold on the credit card before the station is asked to start. On a decline, the session does not start.
4. The session starts. The driver follows it on a session page in the browser.
5. When the session ends, the actual cost is captured, at most the hold, and the rest is released.

The session is not linked to any account. The driver gets the session page and, when they enter an email address, a receipt by email.

## Payment Terminal

A payment terminal is a credit card reader at the station. The driver pays without an account or an app. See [Payment Terminals](https://www.evtivity.com/docs/integrations/payment-terminals).

The pairing of the terminal in the CSMS decides the connector:

- A terminal paired to a connector starts on that connector.
- A station-wide terminal starts on the connector the driver picks on the terminal, when that connector belongs to the paired station.
- A station with a single connector starts on that connector.
- Otherwise the session starts on any free connector of the paired station.

A terminal that is not paired cannot start a session.

1. The driver presents a credit card at the terminal. The terminal, or the station display for a terminal without a screen, shows the hold amount.
2. The bank places the hold. No session exists yet. On a decline, nothing is charged and charging does not start.
3. The CSMS starts charging on the paired station. The station display or the terminal screen says the payment is approved and asks the driver to plug in.
4. The driver plugs in and charging begins.
5. The cost of the session is capped at the hold. An OCPP 2.1 station gets the hold as its maximum cost. On every OCPP version, the CSMS stops the session at the hold.
6. When the session ends, the CSMS captures the actual cost and releases the rest of the hold. A session that cost nothing voids the hold.
7. The driver gets a receipt link as a QR code on the station display or the terminal screen, and by email when they gave an email address.

## Common Questions

**Can two drivers start on one connector at once?**
No. One connector runs one session at a time, and the first start wins. The other start is refused. A payment terminal shows "Another session is already active on this connector".

**Does selecting a connector in the app hold it for me?**
No. Selecting a connector reserves nothing. Another driver can start there first. To hold a connector, make a [reservation](https://www.evtivity.com/docs/guides/reservations).

**Can a payment terminal take over a session started in the app?**
No. A terminal cannot take over a session started in the app or the portal, and the app cannot take over a session started at a terminal.

**I saved the same credit card in the app. Why is my terminal session not in my history?**
Terminal and guest QR sessions are not linked to driver accounts, even when the same credit card is saved in the app. Use the receipt link instead.

**I have an RFID card with a prepaid balance and one without. Which one pays?**
The RFID card you tap decides. The RFID card with the prepaid balance pays from its balance. The other one pays through your fleet account or your default saved credit card.
