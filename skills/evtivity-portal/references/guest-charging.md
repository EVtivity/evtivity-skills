Generated from https://www.evtivity.com/docs/portal/guest-charging. Do not edit.

# Guest Charging

Charge without an account using a QR code, pay with a credit card through the operator's payment provider, and track your session.

## Overview

Guest charging lets drivers use a charging station without creating a Portal account. Drivers scan a QR code, see pricing, pay with a credit card (if required), and monitor the session on a temporary tracking page.

## How It Works

1. A driver scans the QR code on a charging station.
2. The Portal opens the guest landing page showing station info, connector details, and pricing.
3. If the tariff is free, the driver taps **Start Charging** directly.
4. If the tariff requires payment, the driver taps **Pay with card** to proceed to checkout.
5. The session starts and the driver monitors progress on a temporary session page.

## Guest Landing Page

The QR code URL follows the format `/charge/:stationId/:evseId` (specific connector) or `/charge/:stationId` (station level).

### Dynamic QR Codes

Some OCPP 2.1 stations show a QR code on their display that changes over time instead of a printed one. The code holds a one-time password that is valid only for a short period, so a photo or copy of the code expires. The operator turns this on per station (see [Stations](https://www.evtivity.com/docs/csms/stations)).

When a driver scans a dynamic QR code, the portal opens `/qr/...` and checks the password:

- **Valid code**: the portal continues to the landing page of that connector, the same page a static QR code opens.
- **Expired or invalid code**: the portal shows **QR code not valid** and does not start a session. Scan the QR code shown on the station again.

![QR code not valid page](https://www.evtivity.com/screenshots/portal/qr-invalid.png)

If the station let the driver enter a maximum cost, energy, or time before it showed the code, the code URL carries them as `maxcost`, `maxenergy` (Wh), and `maxtime` (seconds). They limit the session the same way for static and dynamic QR codes.

### Single Connector Landing (`/charge/:stationId/:evseId`)

This page shows the details for a specific connector:

![Guest landing page](https://www.evtivity.com/screenshots/portal/guest-charging.png)

- **Station name** - the operator-assigned station identifier
- **Connector type** - CCS2, CHAdeMO, Type 2, or other standard
- **Power rating** - maximum output in kW
- **Status badge** - current connector availability
- **Pricing breakdown** - tariff components (per-kWh, per-minute, flat fee, etc.). Guests see prices excluding or including tax as the operator's price display setting sets, with a note naming the tax rate.

Two buttons appear at the bottom:

- **Pay with card** - proceed to the card checkout for guest charging
- **Sign In** - redirect to the login page for authenticated charging with an account

If the driver is already logged in, the page redirects automatically to the authenticated charging flow at `/start/:stationId`.

### Station Landing (`/charge/:stationId`)

This page shows all EVSEs at the station in a grid layout. Each tile displays the connector type, power rating, and current status. Tap an available connector to navigate to the single connector landing page.

Connectors that are faulted or unavailable are shown but cannot be selected.

When the whole station is unavailable (disabled by the operator, installing firmware, failed firmware install, or a station-level fault), both landing pages show "This station is unavailable right now. Try another station." and no connector can be selected. A guest start request at that station returns `409 STATION_UNAVAILABLE`.

## Free Stations

Some stations are configured for free charging. On these stations:

1. The guest landing page shows **Free** pricing with no cost components.
2. No credit card is required.
3. The **Pay with card** button is replaced with **Start Charging**.
4. Tap **Start Charging** to begin the session immediately without entering payment details.

## Card Checkout

When the tariff requires payment:

1. Tap **Pay with card** on the guest landing page.
2. The **Guest checkout** page opens with the card form of the operator's payment provider (Stripe or Adyen). Card data goes straight to the provider.
3. Enter your credit or debit card number, expiration date, and CVC.
4. Optionally enter your email address in **Email (for receipt)** to receive a receipt.
5. The pre-authorization amount is displayed above the button: "A hold of ... will be placed on your card. You will only be charged for the energy used."
6. Tap **Start Charging** to authorize the hold and begin the session.

The system places a pre-authorization hold on your card. The final charge is captured when the session ends based on actual energy consumed and time elapsed. If the final amount is less than the hold, the difference is released. A guest has no saved card, so a cost above the hold is not charged. When the station's QR code sets a maximum cost below the hold, that maximum is the limit instead: the session stops there and you are charged no more than it.

If the card is refused, the session does not start and the page shows the reason, for example "Your card was declined. Try a different card." Try another card.

### Card Verification (3D Secure)

With Adyen, your bank can ask you to confirm the payment. The page shows "Complete the verification from your bank to continue." and opens your bank's page. After you confirm, the browser returns to the Card Verification page (`/payments/return`), which finishes the verification, starts the session, and opens the session tracking page. If the card is refused or the verification fails, the session does not start, no money stays held, and the page shows the reason with **View charging session**.

With Stripe, guest checkout has no verification step: a card that requires 3D Secure is declined, so use another card.

### Test Mode

When the operator runs the test payment provider, the checkout shows "Test mode, no real money. Pick a test card." and a **Test card** list instead of card fields. See [Test Payment Provider](https://www.evtivity.com/docs/integrations/test-payment-provider).

## Session Tracking

After starting, you are redirected to a session tracking page at `/guest-session/:sessionToken`.

The session token is stored in the URL. You do not need an account to access this page - anyone with the URL can view the session status. Bookmark the page or keep the browser tab open to monitor your session.

The page shows:

- **Session status** - current state of the charging session
- **Live stats** - duration, energy delivered, and estimated cost (updates every 5 seconds). The cost includes tax and reads **Estimated cost (incl. tax)**, then **Total cost (incl. tax)** when the session ends, when the tariff has tax.
- **Power chart** - real-time power output graph (updates every 10 seconds)
- **Stop Charging** - tap to end the session early

### Session Statuses

| Status              | Meaning                                                |
|---------------------|--------------------------------------------------------|
| Waiting for charger | Command sent to station, waiting for transaction to begin |
| Charging            | Active energy delivery                                 |
| Idle                | EV is connected but not drawing power                  |
| Completed           | Session ended normally                                 |
| Failed              | Session could not start or encountered an error        |
| Expired             | Session token expired before charging began            |

## Session Token Expiry

Each guest session has a 15-minute token that starts when you initiate the session. If the charging station does not begin the transaction within 15 minutes, the session expires automatically. Any pre-authorization hold on your card is cancelled.

## Receipt

If you provided an email address during checkout, a receipt is sent to that email when the session completes. The receipt includes:

- Station ID and location
- Energy delivered (kWh)
- Session duration
- Total cost, labeled "incl. tax" when the tariff has tax
- Start and end timestamps

## Notes

- Guest sessions do not appear in the Activity tab or monthly statements. Those features require a driver account.
- The guest checkout page is not protected by CSRF tokens since no session cookies are involved.
- Idling notifications are sent to the guest email if one was provided.
- Expired guest sessions with pending card holds are cleaned up automatically every 5 minutes.
- No account creation is required at any point in the guest flow.
