Generated from https://www.evtivity.com/docs/integrations/payment-terminals. Do not edit.

# Payment Terminals

Card readers at a charger that the CSMS drives through the terminal provider cloud. Providers, settings, pairing, how a driver pays, receipts, refunds, offline alerts and permissions.

## Overview

A payment terminal is a card reader mounted at or near a charger. The driver pays a charging session by card at the reader, without an account or an app. The CSMS drives the terminal through the cloud of its terminal provider: it asks for a hold, starts charging when the card is authorized, and captures the final cost when the session ends. The charger needs no firmware change. In OCPP terms it sees an ad hoc payment through a stand-alone payment terminal.

Each operator uses its own merchant account with the terminal provider. EVtivity never holds the funds. The CSMS stores no card numbers: of each card it keeps only the last 4 digits, the first 6 digits (BIN) and the brand.

![Payment Terminals list](https://www.evtivity.com/screenshots/csms/payment-terminals-list.png)

**Export CSV** on the list exports the terminals with the search and the filters on screen: label, provider, device ID, model, serial number, mode, status, device status, site, station, connector and the time the terminal was last seen. The file holds no credentials and no card data. The API is `GET /v1/payment-terminals/export`.

## Providers

| Provider | Status | Use |
|---|---|---|
| Simulated | Available in development and test deployments | Development, demos and automated tests. Moves no money. |
| ID TECH Payment Services Gateway (PSG) | Not yet available in production | ID TECH VP6825 and VP7200 terminals |

The ID TECH provider can be turned on only in development and test deployments until it has passed a check against the ID TECH sandbox. Elsewhere, saving it as enabled answers `400 PAYMENT_TERMINAL_PROVIDER_UNVERIFIED`.

| Model | Screen | Where the prompts show |
|---|---|---|
| VP6825 | Yes | On the terminal screen |
| VP7200 | No | On the station display |

## Settings

Configure the ID TECH account on the **Settings > Payment > Payment Terminals** sub-tab. The settings apply to every site, so the sub-tab shows only to users with access to every site.

![Payment Terminals settings](https://www.evtivity.com/screenshots/csms/settings-payment-terminals.png)

| Field | Description |
|---|---|
| Enabled | Turns the ID TECH provider on or off |
| Environment | `sandbox` or `production` |
| Merchant ID | Your merchant ID at the gateway |
| API Key | Stored encrypted |
| API Secret | Stored encrypted |
| Webhook Secret | Signing secret of the webhook. Stored encrypted. |

- Viewing the settings needs `settings.payment:read`, changing them `settings.payment:write`.
- A change of the environment, the merchant ID or a credential asks you to confirm your sign-in again. An API key cannot change them (`403 SESSION_REQUIRED`).
- Changing the environment clears the stored API key, API secret and webhook secret unless you enter new ones with the change.
- The stored secrets are shown only to users with `settings.system:read`. Other users see only that a value is stored.
- Each such change sends a security notice to the users with access to every site who may change payment settings.
- A connection test checks the saved values with the provider.

The API is `GET` and `PUT /v1/settings/payment-terminals`, and `POST /v1/settings/payment-terminals/idtech/test` for the connection test.

### Webhook

ID TECH sends payment results to:

```
POST /v1/webhooks/payment-terminals/idtech
```

Enter this URL on your API host at the gateway, and enter the signing secret of the gateway as the webhook secret. The CSMS refuses a request with a wrong signature, one older than 5 minutes and one larger than 256 KiB. A retried delivery is applied once. The CSMS also reads open payments back from the provider every 5 minutes, so a lost webhook does not leave a payment open.

## Add and Pair a Terminal

1. Add the terminal to the CSMS. Pick it from the devices the provider lists for your merchant account, or enter it by its device ID. Give it a label.
2. Pair it to a station. By default a terminal is paired to one connector. A station-wide terminal serves every connector of the station: the driver picks the connector on the terminal screen, or on the station display for a VP7200.
3. A terminal with its own cellular SIM can have the SIM attached, as a station can. See [SIMs](https://www.evtivity.com/docs/csms/sims).

![New Payment Terminal with the device and the pairing](https://www.evtivity.com/screenshots/csms/payment-terminals-create.png)

A connector has at most one active terminal. A terminal that is set to inactive takes no payments. A terminal with payments cannot be deleted. Set it to inactive instead.

The API is `/v1/payment-terminals` (`GET`, `POST`, `PATCH`, `DELETE`), with `POST /v1/payment-terminals/:id/pair` and `/unpair` for the pairing and `POST` and `DELETE /v1/payment-terminals/:id/sim` for the SIM.

![Payment terminal details with vendor, model, serial number and firmware version](https://www.evtivity.com/screenshots/csms/payment-terminal-detail.png)

![SIM Card tab of a payment terminal](https://www.evtivity.com/screenshots/csms/payment-terminal-sim.png)

![Payment Terminals card on the Connectors tab of a station](https://www.evtivity.com/screenshots/csms/station-payment-terminals.png)

## How a Driver Pays

1. The terminal, or the station display for a terminal without a screen, asks the driver to present a card and shows the hold amount. The hold is the pre-auth amount of the site, else the default pre-auth amount (see [Payment Providers](https://www.evtivity.com/docs/integrations/payment-providers#payment-settings)).
2. The driver presents the card. The provider places the hold.
3. When the card is authorized, the CSMS starts charging on the paired connector, or on the connector the driver picked. When neither applies, the driver plugs in at any connector of the station. The hold is the cost limit of the session.
4. When the session ends, the CSMS captures the final cost, at most the hold. A session that cost nothing releases the hold.
5. When the card is declined, nothing is charged and charging does not start. When charging cannot start after the card was authorized, the CSMS releases the hold at once.

Charging never runs without a hold: when a hold is released during a session, the session stops.

### Receipts

After the capture, the driver gets a receipt link. It shows as a QR code on the terminal screen or on the station display, and goes by email when the driver gave an email address. The link opens the session receipt in the driver portal. There is no paper receipt.

The texts on the station display (card prompt, payment result, receipt link) come from station message templates in the six display languages. See [Messages](https://www.evtivity.com/docs/csms/settings#messages).

### Refunds

Refund a terminal payment from the session, like any other session payment. The refund needs `payments:write` and goes back to the card through the terminal provider. The API is `POST /v1/sessions/:id/refund`.

![Payments tab of a payment terminal](https://www.evtivity.com/screenshots/csms/payment-terminal-payments.png)

## Offline Alerts

The CSMS reads the status of every terminal every 5 minutes. When a terminal stays offline for 15 minutes, the active users with `paymentTerminals:write` and access to its site get the **Payment Terminal Offline** notification once for that offline period.

## Permissions

| Action | Needs |
|---|---|
| See terminals | `paymentTerminals:read` |
| Add, edit, activate, deactivate and delete terminals | `paymentTerminals:write` |
| Pair and unpair | `paymentTerminals:write` and `stations:write` |
| See terminal payments | `paymentTerminals:read` and `payments:read` |
| Start a test payment, release a hold | `paymentTerminals:write` and `payments:write` |
| Attach or detach a SIM | `paymentTerminals:write` and `sims:write` |
| Payment terminal settings | `settings.payment:read` or `settings.payment:write` |

Operators get read and write by default, viewers read. A site-restricted user sees only the terminals and payments of their sites.
