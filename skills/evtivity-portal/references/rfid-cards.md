Generated from https://www.evtivity.com/docs/portal/rfid-cards (website commit 900fb20). Do not edit.

# RFID Cards

Add and manage RFID cards for tap-to-charge at charging stations.

## Overview

RFID cards let you start a charging session by tapping a physical card on the station's card reader. This is an alternative to starting sessions through the Portal app.

Open the RFID Cards page from **Account** > **RFID Cards**, or tap the **RFID Cards** card on the Home page. RFID Cards is one of the default Home cards; drivers choose their cards under **Account** > **Home Screen**.

![RFID Cards page](https://www.evtivity.com/screenshots/portal/rfid-cards.png)

## How RFID Charging Works

1. Tap your RFID card on the card reader built into the charging station.
2. The station sends the card number to the CSMS for authorization.
3. If the card is active and linked to your account, the CSMS authorizes the session.
4. The station starts charging. The session appears in your Activity page like any other session.

This flow does not require opening the Portal or scanning a QR code. It is useful when you charge at the same station regularly or prefer a physical token over a phone.

### RFID vs. App-Based Charging

With RFID, you tap the card and the station starts automatically. You do not select a connector or payment method - the station uses the connector where the cable is plugged in, and your default payment method on file.

With app-based charging, you select a specific connector, choose a payment method, and see pricing before starting.

## Adding a Card

1. Open **Account** > **RFID Cards**, or tap the **RFID Cards** card on the Home page.
2. Tap **Add RFID Card**.
3. Enter the card number printed on your RFID card. The number is alphanumeric and between 4 and 20 characters. Tap **Add**.
4. The card is added in an active state and ready to use.

Duplicate card numbers are rejected. Each card number can only be linked to one account.

## Managing Cards

- **Toggle active/inactive** - turn a card's toggle off and confirm with **Deactivate** to disable it, or turn it on to reactivate it. When a card is deactivated, the station rejects authorization attempts with that card. Reactivate it at any time.
- **Masked display** - card numbers are displayed with partial masking for security.
- **No delete** - the Portal does not delete cards. Deactivate a card you no longer use.

## Deactivated Cards

When you tap a deactivated card on a station reader, the station sends an authorization request to the CSMS. The CSMS rejects the request because the card is inactive. The station displays an authorization failure and does not start charging.

## System Integration

Added cards appear as driver tokens with type RFID in the system. Operators can also see and manage these tokens from the CSMS Tokens page. Cards are shared between portal self-service and operator management - changes made by either side take effect immediately.
