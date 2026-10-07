Generated from https://www.evtivity.com/docs/guides/using-rfid-tokens. Do not edit.

# Using RFID Tokens

Register manufacturer-supplied RFID cards in EVtivity and use them to start charging at your stations.

This guide walks through getting an RFID card from your charger manufacturer working in EVtivity: capturing the value the card actually transmits, registering it against a driver, and starting a session by tapping. It also covers the pre-pushing pattern for stations that may go offline.

## How tokens drive a charging session

An RFID card is just an `idToken` string. When a driver taps the card, the station sends an OCPP `Authorize` request to the CSMS containing that string. The CSMS looks the value up in its `driver_tokens` table:

- **Found and active** &rarr; returns `Accepted`, station starts the session, costs and history attribute to the assigned driver.
- **Found but inactive** &rarr; returns `Blocked`, station refuses to start.
- **Not found** &rarr; returns `Invalid` (with one fallback for OCPI roaming and an unconditional accept for free-vend sites).

So the entire job of "make my RFID card work" is: get the right `idToken` value into the table.

## Step 1: Capture the exact value the card transmits

The serial printed on the card is often **not** what the station sends. Card readers transmit the chip's UID (typically `ISO14443` for MIFARE Classic or DESFire) in whatever case and format the firmware uses &mdash; uppercase hex with no separators is most common, but vendors differ.

To find the real value:

1. Make sure the target station is online in the dashboard (Stations &rarr; the station shows a green dot).
2. Tap the card on the reader once. Because the card isn't registered yet, the station will get an `Invalid` response and refuse to start.
3. Open the station detail page in the CSMS, switch to the **Authorize Log** tab (shown when your role can read drivers). Look for a recent `Authorize` attempt with a rejected outcome.
4. Copy the `idToken` value from that event verbatim &mdash; same case, same length, no extra whitespace.

If you have multiple cards, tap each one in turn and record the values together. It's easier than coming back card by card.

## Step 2: Register the token

Two paths, depending on who owns the card.

### Operator path (recommended for fleet cards)

1. In the CSMS, go to **Drivers** and open the driver who should own the card.
2. Switch to the **Tokens** tab and click **Create Token**.
3. Fill in the fields:
   - **ID Token:** the value you captured in Step 1.
   - **Token Type:** `ISO14443` (the default, the standard for the common MIFARE-family cards).
4. Click **Create**.

The driver and the card are now linked. Every session that starts with this card bills to that driver and shows up in their session history.

### Driver self-service path

The driver portal lets each driver add their own cards, which is convenient for individual EV owners on a workplace or hospitality network.

1. Driver signs into the portal and opens **Account &rarr; RFID Cards**.
2. They tap **Add RFID Card**, paste the captured value into **Card number**, and tap **Add**.

Same end result, no operator step required.

## Step 3: Tap and charge

The flow is now what you'd expect:

1. Driver plugs the cable into the EV.
2. Driver taps the card on the station's reader.
3. Station sends `Authorize` &rarr; CSMS returns `Accepted` &rarr; station opens the transaction and begins delivering energy.
4. The session shows up live on the dashboard and in the driver's portal Activity tab.

If the first tap returns `Invalid`, the cause is almost always a format mismatch on the captured value (case, leading zeros, hyphens). Re-read it from the rejection event and update the row.

## Pre-pushing tokens for offline operation

If your stations may lose connectivity (rural sites, unreliable LTE), the **Local Auth List** lets a station authorize known cards locally without contacting the CSMS.

1. Open the station detail page and switch to the **Local Auth List** tab.
2. Click **Add Tokens**, search for the cards you want available offline, and add them.
3. Click **Push to Station**. The CSMS issues a full `SendLocalList` to the station with the curated set.

After the push, the station accepts those cards even when the WebSocket link is down. Adding or removing tokens on the local list is a database-only operation until you push &mdash; so you can stage changes and push once.

## Bulk-onboarding many cards

For new fleets, the fastest workflow is:

1. Capture every card's transmitted value once at a single station (Step 1, but in a batch).
2. Use the bulk-create endpoint via the API, or upload a CSV with **Import CSV** on the **Tokens** page (one row per card, columns: `idToken`, `tokenType`, `driverId`, `isActive`).
3. Optionally push the new tokens to the relevant stations' local auth lists if you need offline coverage.

The API endpoint is documented under [Tokens in the API Reference](https://www.evtivity.com/api-reference/tokens) for integrators wiring this into a provisioning pipeline.

## Edge cases worth knowing

- **The same card on a free-vend site:** sites with `free_vend_enabled` accept any token, registered or not. The session won't attribute to a driver because there's no token-to-driver link &mdash; that's the trade-off of free vend.
- **Mixed OCPP 1.6 and 2.1 fleets:** the registration is identical. OCPP 1.6 stations send the value as `idTag`, 2.1 sends it as `idToken` with a type. The CSMS normalizes both. Use `RFID`/`ISO14443` as the type for physical cards in either case.
- **Inactive tokens:** flipping a token to inactive returns `Blocked` on the next tap, which most stations treat as a refused authorization (the LED stays red and no session starts). Use this for lost-card revocation rather than deleting the row, so historic sessions retain the link.
- **Bringing a card from another network:** the card itself doesn't care which network it's used on &mdash; the UID is the UID. Capture it on an EVtivity station and register as above.

## Related

- [Tokens (CSMS reference)](https://www.evtivity.com/docs/csms/tokens)
- [Local Auth List](https://www.evtivity.com/docs/csms/local-auth-list)
- [Free Vend Mode](https://www.evtivity.com/docs/csms/free-vend)
- [API: Tokens endpoints](https://www.evtivity.com/api-reference/tokens)
