Generated from https://www.evtivity.com/docs/csms/local-auth-list. Do not edit.

# Local Auth List

Manage offline authorization tokens stored on each charging station.

## Overview

Local authorization lists manage which driver tokens are stored on each station for offline authorization. When a station loses connectivity, it can still authorize drivers using its local list. Access this feature from the **Local Auth List** tab on the Station Detail page.

![Local auth list tab](https://www.evtivity.com/screenshots/csms/station-local-auth-tab.png)

## How It Works

1. **Add tokens**

   The operator adds tokens from the system to a station's local auth list. This is a database-only operation - no OCPP command is sent to the station. Only active tokens that are not prepaid cards can be added: a station checks a prepaid card's balance online, so prepaid cards never go on a local list.

2. **Remove tokens**

   The operator removes tokens from the list as needed. This is also database-only.

3. **Push to station**

   When the list is ready, the operator pushes it to the station via OCPP `SendLocalList` using the Full update type. This sends all tracked entries to the station in a single operation.

The CSMS is the source of truth. Every push sends the complete list to the station, replacing whatever the station had before.

## Pre-Push Reconciliation

Before pushing the list to a station, the system brings every entry in line with its token:

| Check | Action |
|-------|--------|
| Orphaned entries | Tokens whose backing record has been deleted are removed from the list |
| Prepaid cards | Entries of tokens that are now prepaid cards are removed from the list |
| Deactivated tokens | Tokens that are deactivated, or whose driver is deactivated, are pushed as `Blocked` so the station actively rejects them |
| Expired tokens | Tokens past their expiry are pushed as `Expired`; an active token carries its expiry to the station |
| Changed tokens | Each entry takes the token's current value and type, and a reactivated token is pushed as `Accepted` again |

The sync time moves only when the station accepts the list, so a rejected or failed push keeps the unpushed changes banner. A change to a token on a list, such as deactivation, a new value or expiry, deletion, or switching it to prepaid, shows the banner.

## UI Elements

The Local Auth List tab shows:

- **Version info** - CSMS version, station version, and last sync timestamp
- **Unpushed changes banner** - Warning when the local list has changes not yet pushed to the station
- **Token table** - All tokens in the list with their status and push state
- **Add tokens dialog** - Search and add tokens from the system

## Protocol Compatibility

This feature works with OCPP 1.6, 2.0.1 and 2.1 stations. The CSMS handles command translation between protocol versions automatically.
