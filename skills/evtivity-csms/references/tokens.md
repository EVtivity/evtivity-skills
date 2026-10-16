Generated from https://www.evtivity.com/docs/csms/tokens. Do not edit.

# Tokens

Manage driver authentication tokens including RFID cards and app-based tokens.

## Overview

Tokens are authentication credentials that identify drivers when they start a charging session. A driver can have multiple tokens. The CSMS validates tokens during the OCPP Authorize flow before allowing a session to begin.

![Tokens list](https://www.evtivity.com/screenshots/csms/tokens-list.png)

## Token Types

The token type is the OCPP 2.1 IdToken type. Every form offers the same list.

| Type | Description |
|------|-------------|
| ISO14443 | UID of an RFID card or key fob. Most cards use this type. |
| ISO15693 | UID of an ISO 15693 RFID card. |
| KeyCode | A code the driver enters at the station, such as a PIN. |
| eMAID | Plug and Charge contract identifier (ISO 15118). |
| EVCCID | Identifier of the vehicle's charging controller (ISO 15118). |
| MacAddress | MAC address of the vehicle. |
| VIN | Vehicle identification number. |
| Central | An identifier the CSMS issues, for example for app starts. |
| Local | An identifier the station creates. |
| DirectPayment | A payment terminal reference. |
| NoAuthorization | A marker for charging without authorization. |

Drivers who add a card in the portal choose from ISO14443, ISO15693, KeyCode, eMAID, EVCCID, MacAddress, VIN and Local.

## Create a Token

1. Navigate to **Tokens** in the sidebar.
2. Click **Create Token**.
3. Enter the **Token Value**. For an RFID card, this is the card UID.
4. Choose the **Token Type**.
5. Optionally select the **Driver** to assign the token to.
6. Click **Create**.

![Create token](https://www.evtivity.com/screenshots/csms/tokens-create.png)

Drivers can also add RFID cards themselves through the portal's Account page.

## Token Detail

Click any token in the list to view its detail page.

![Token detail](https://www.evtivity.com/screenshots/csms/token-detail.png)

The detail page has four tabs:

- **Token Details** - token value, type, assigned driver, creation date, and active status. Edit and Delete actions live here.
- **Sessions** - charging sessions whose OCPP Authorize matched this specific token (filtered by `charging_sessions.token_id`, not driver id).
- **History** - paginated `token_audit_log` showing every lifecycle event (created, updated, activated, deactivated, revoked, deleted, imported) with the actor name (operator or driver, linked to their detail page) and free-text notes.
- **Authorize Log** - paginated `authorize_attempts` filtered to this token, including the matched outcome (accepted / blocked / expired / concurrent_tx / no_credit / db_error). Useful for forensic triage when a driver reports a swipe was rejected.

## Token Statuses

| Status | Description |
|--------|-------------|
| Active | Token can be used to authenticate and start sessions |
| Revoked | Token was deactivated and is rejected as Blocked |
| Inactive | Token is turned off without a recorded deactivation time and is rejected as Blocked |
| Expired | Token is active but past its expiry and is rejected as Expired |

Toggle a token between active and inactive from the detail page. Deactivated tokens are rejected by the OCPP authorize handler. For a deactivated token, the **Details** tab shows when it was deactivated, by whom (Operator, Driver or System), and the reason.

### Expiry

Set **Expires** on the token's edit form, or leave it empty for a token that does not expire. After that time stations refuse the token as Expired. A token on a local authorization list carries its expiry to the station.

### Reactivation by Drivers

A driver can turn a card back on in the portal only when the driver turned it off. A card the operator deactivated stays off until an operator reactivates it. The portal shows it as deactivated by the operator.

### Deactivated Drivers

When a driver is deactivated, the driver's tokens are deactivated. While the driver is inactive, you cannot create a token for the driver, reactivate one of the driver's tokens, or assign an active token to the driver. The CSMS also refuses an active token of an inactive driver at authorization.

## Delete a Token

Operator delete from the dashboard is a hard delete - the `driver_tokens` row is removed. To preserve historical session linkage and the audit trail, the system blocks deletion when an active charging session still references the token: `DELETE /v1/tokens/:id` returns `409 TOKEN_IN_USE` until the session ends. Cancel or finish the session, then retry.

Driver-side removal from the portal is a soft delete - the row stays with `is_active = false` and `revoked_reason = "Removed by driver"`. The token can be re-added later by the same driver without losing its historical link to past sessions.

## Authorization Flow

When a driver taps an RFID card or authenticates through the app:

1. The station sends an OCPP Authorize request with the token value.
2. The CSMS looks up the token in the `driver_tokens` table.
3. If found, active and not expired, and its driver is active, the CSMS checks for an existing active session referencing the same token. If one exists at any station, the response is `ConcurrentTx` and the attempt is recorded with outcome `concurrent_tx`. This prevents a single card from starting two sessions simultaneously.
4. If found, active, and not concurrent, the CSMS returns Accepted.
5. If not found locally, the CSMS checks OCPI external tokens from roaming partners.
6. If the station's site has free vend enabled, any token is accepted regardless of lookup result.

On OCPP 2.1, a token of type Local is accepted without a lookup, since the station created it. A token of type Central that the CSMS does not know is refused as Invalid, unless it is the id the CSMS sent that station to start a charge or hold a reservation: a station should never ask to authorize a Central token.

Stations using a cached local authorization list may skip the Authorize message and go straight to StartTransaction (OCPP 1.6) or TransactionEvent (OCPP 2.1). The CSMS validates the token in those handlers too and writes the same `authorize_attempts` rows, so the forensic log captures the decision regardless of which path the station takes.

## Authorize Log

Every Authorize attempt - and every OCPP 1.6 StartTransaction or OCPP 2.1 TransactionEvent (Started) that arrives without a prior Authorize - is recorded in `authorize_attempts` with the matched token, matched driver, outcome, OCPP version, and a short reason tag. Stations using a local authorization list skip the explicit Authorize call, so the StartTransaction / TransactionEvent path is the only forensic record for those flows. Free-vend sites also write a row with `reason = free_vend` and, when a registered card is tapped, link it to the matched driver and token.

![Station Authorize Log tab](https://www.evtivity.com/screenshots/csms/station-authorize-log-tab.png)

Three surfaces expose this log:

- **/tokens/authorize-log** - the global cross-token forensic page, reachable from the Authorize Log button on the Tokens list. Filter by id token, outcome, time range, and station.
- **Token detail &rarr; Authorize Log tab** - the same data filtered to the matched token.
- **Driver detail &rarr; Authorize Log tab** and **Station detail &rarr; Authorize Log tab** - the same data filtered by matched driver or by reporting station. The Station tab is permission-gated on `drivers:read`.

## Import and Export

**Export CSV** downloads the tokens the list shows, with the same search and filters, in the columns `idToken`, `tokenType`, `driverEmail`, `isActive` and `expiresAt`. **Import CSV** reads the same columns. A row with a problem, such as an unknown token type, an unknown or inactive driver, or a token that already exists, is listed as an error, and the other rows are imported.

## Prepaid Cards

A prepaid card holds a balance in the company currency. Check **Prepaid card** on the token's edit form and enter the **Prepaid balance**. The station asks for the balance before every charge, and the CSMS debits the cost of each session from it when the session ends. When a session's cost reaches the credit it started with and the station keeps charging, the CSMS stops the session.

The driver gets two notices from the **Prepaid Cards** group on the Driver Events tab ([Notifications](https://www.evtivity.com/docs/csms/notifications#driver-events)):

- `prepaid.LowCredit` - a debit took the balance below the low credit threshold. Each drop below the threshold sends it once. You set the threshold on the General tab of the [Payment settings](https://www.evtivity.com/docs/csms/settings#general).
- `prepaid.CreditExhausted` - the CSMS stopped a session because its prepaid credit ran out. The station also shows a short message on its screen, which you edit with the station messages in [Settings](https://www.evtivity.com/docs/csms/settings#messages).

## Notifications

| Event | When it fires |
|-------|---------------|
| `token.Added` | A new card is registered (operator dashboard, driver portal, or CSV import) |
| `token.Removed` | Operator hard-deletes a token |
| `token.Deactivated` | Operator or driver toggles a card to inactive, or removes it from the portal (which is a soft-delete) |
| `token.Reactivated` | A previously deactivated card is toggled back to active. Distinct template from `token.Added` so the driver does not read "card added" when it's the same physical card returning. |

All four events respect per-driver notification preferences and dispatch through the standard email/SMS channels.

## Local Authorization List

Tokens can be pushed to a station's local authorization list for offline validation. This allows stations to authorize drivers even when the OCPP connection to the CSMS is down. A change to a token on a list (activation, deactivation, a new value, type or expiry, or deletion) marks the list as changed. The next push sends each token as it is then: Accepted, Blocked or Expired. Prepaid cards never go on a local list: a station checks their balance online. Manage local auth lists from the station's **Local Auth List** tab. See [Stations](https://www.evtivity.com/docs/csms/stations) for details.

![Station Local Auth List tab](https://www.evtivity.com/screenshots/csms/station-local-auth-tab.png)
