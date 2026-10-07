Generated from https://www.evtivity.com/docs/csms/free-vend. Do not edit.

# Free Vend

Enable free charging at a site without driver identification or payment.

## Overview

Free vend is a site-level mode where stations charge without driver identification or payment. When enabled, any driver can plug in and start a session without presenting a token or completing a payment flow.

Toggle free vend per site from the **Free Vend** tab on the Site Detail page.

![Free vend tab](https://www.evtivity.com/screenshots/csms/site-free-vend-tab.png)

## How It Works

1. **Enable free vend**

   An operator enables the free vend toggle on a site. The system sets the `free_vend` flag on the site record.

2. **Config templates are created**

   The system generates OCPP configuration templates for both 2.1 and 1.6 with autostart variables. These templates configure stations to begin charging on plug-in without authorization.

3. **Templates push to stations**

   The generated templates are pushed to all online stations at that site. Offline stations receive the configuration when they reconnect.

## Enforcement Layers

Free vend uses three enforcement layers so a session starts without identification regardless of which path the station takes:

| Layer | Behavior |
|-------|----------|
| Authorize handler (1.6 and 2.1) | Accepts any token presented by the station |
| StartTransaction handler (1.6) | Accepts any idTag when a 1.6 station skips Authorize and goes straight to StartTransaction. Common when LocalPreAuthorize or AllowOfflineTxForUnknownId is set on the station. |
| TransactionEvent Started projection | Skips the payment gate and sets `free_vend=true` on the session record |
| OCPP config template push | Configures stations to start charging on plug-in without asking for a token |

The site lookup behind the first two layers is cached in-process for 60 seconds, so toggling free vend takes effect immediately on the pod handling the toggle and within a minute everywhere else.

## OCPP Variables

### OCPP 2.1

| Variable | Value |
|----------|-------|
| `AuthCtrlr.Enabled` | `false` |
| `TxCtrlr.TxStartPoint` | `EVConnected` |

### OCPP 1.6 (best-effort)

| Variable | Value |
|----------|-------|
| `AllowOfflineTxForUnknownId` | `true` |
| `LocalPreAuthorize` | `true` |
| `LocalAuthorizeOffline` | `true` |

## Disabling Free Vend

Disabling free vend sets the database flag to `false` but does not modify station OCPP configuration. Operators should manually update or remove the generated config templates if they want stations to require authorization again.

## Customization

Operators can edit the generated config templates to add vendor-specific keys. The templates follow the same format as standard OCPP configuration templates.

## Visual Indicators

- Sessions created under free vend display a **Free Vend** label in the driver column.
- Stations at a site with free vend enabled show a **Free Vend** badge on the station card.

## No Pricing Group Required

A site with `free_vend_enabled=true` does not need a pricing group or tariff assigned. Guest checkout and the authenticated start endpoint both short-circuit on `freeVendEnabled` before any tariff lookup. The Portal pricing display shows a **Free charging** badge in this case, even when no pricing group resolves.
