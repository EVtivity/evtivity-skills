Generated from https://www.evtivity.com/docs/csms/tokens. Do not edit.

# Tokens

Manage driver authentication tokens including RFID cards and app-based tokens.

## Overview

Tokens are authentication credentials that identify drivers when they start a charging session. A driver can have multiple tokens. The CSMS validates tokens during the OCPP Authorize flow before allowing a session to begin.

![Tokens list](https://www.evtivity.com/screenshots/csms/tokens-list.png)

## Token Types

| Type | Description |
|------|-------------|
| RFID | Physical RFID card or key fob. The token value is the card's UID. |
| APP_USER | App-based token generated when a driver registers through the portal. |

## Create a Token

1. Navigate to **Tokens** in the sidebar.
2. Click **Create Token**.
3. Select a driver to assign the token to.
4. Choose the token type (RFID or APP_USER).
5. Enter the token value. For RFID, this is the card UID (alphanumeric, 4-20 characters).
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
| Inactive | Token is disabled and will be rejected during authorization |

Toggle a token between active and inactive from the detail page. Deactivated tokens are rejected by the OCPP authorize handler. If a deactivated token is on a station's local authorization list, it is pushed as "Blocked" during the next list push.

## Delete a Token

Operator delete from the dashboard is a hard delete - the `driver_tokens` row is removed. To preserve historical session linkage and the audit trail, the system blocks deletion when an active charging session still references the token: `DELETE /v1/tokens/:id` returns `409 TOKEN_IN_USE` until the session ends. Cancel or finish the session, then retry.

Driver-side removal from the portal is a soft delete - the row stays with `is_active = false` and `revoked_reason = "Removed by driver"`. The token can be re-added later by the same driver without losing its historical link to past sessions.

## Authorization Flow

When a driver taps an RFID card or authenticates through the app:

1. The station sends an OCPP Authorize request with the token value.
2. The CSMS looks up the token in the `driver_tokens` table.
3. If found and active, the CSMS checks for an existing active session referencing the same token. If one exists at any station, the response is `ConcurrentTx` and the attempt is recorded with outcome `concurrent_tx`. This prevents a single card from starting two sessions simultaneously.
4. If found, active, and not concurrent, the CSMS returns Accepted.
5. If not found locally, the CSMS checks OCPI external tokens from roaming partners.
6. If the station's site has free vend enabled, any token is accepted regardless of lookup result.

Stations using a cached local authorization list may skip the Authorize message and go straight to StartTransaction (OCPP 1.6) or TransactionEvent (OCPP 2.1). The CSMS validates the token in those handlers too and writes the same `authorize_attempts` rows, so the forensic log captures the decision regardless of which path the station takes.

## Authorize Log

Every Authorize attempt - and every OCPP 1.6 StartTransaction or OCPP 2.1 TransactionEvent (Started) that arrives without a prior Authorize - is recorded in `authorize_attempts` with the matched token, matched driver, outcome, OCPP version, and a short reason tag. Stations using a local authorization list skip the explicit Authorize call, so the StartTransaction / TransactionEvent path is the only forensic record for those flows. Free-vend sites also write a row with `reason = free_vend` and, when a registered card is tapped, link it to the matched driver and token.

![Station Authorize Log tab](https://www.evtivity.com/screenshots/csms/station-authorize-log-tab.png)

Three surfaces expose this log:

- **/tokens/authorize-log** - the global cross-token forensic page, reachable from the Authorize Log button on the Tokens list. Filter by id token, outcome, time range, and station.
- **Token detail &rarr; Authorize Log tab** - the same data filtered to the matched token.
- **Driver detail &rarr; Authorize Log tab** and **Station detail &rarr; Authorize Log tab** - the same data filtered by matched driver or by reporting station. The Station tab is permission-gated on `drivers:read`.

## Notifications

| Event | When it fires |
|-------|---------------|
| `token.Added` | A new card is registered (operator dashboard, driver portal, or CSV import) |
| `token.Removed` | Operator hard-deletes a token |
| `token.Deactivated` | Operator or driver toggles a card to inactive, or removes it from the portal (which is a soft-delete) |
| `token.Reactivated` | A previously deactivated card is toggled back to active. Distinct template from `token.Added` so the driver does not read "card added" when it's the same physical card returning. |

All four events respect per-driver notification preferences and dispatch through the standard email/SMS channels.

## Local Authorization List

Tokens can be pushed to a station's local authorization list for offline validation. This allows stations to authorize drivers even when the OCPP connection to the CSMS is down. Manage local auth lists from the station's **Local Auth List** tab. See [Stations](https://www.evtivity.com/docs/csms/stations) for details.

![Station Local Auth List tab](https://www.evtivity.com/screenshots/csms/station-local-auth-tab.png)
