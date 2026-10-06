Generated from https://www.evtivity.com/docs/csms/local-auth-list (website commit 0f3462e). Do not edit.

# Local Auth List

Manage offline authorization tokens stored on each charging station.

## Overview

Local authorization lists manage which driver tokens are stored on each station for offline authorization. When a station loses connectivity, it can still authorize drivers using its local list. Access this feature from the **Local Auth List** tab on the Station Detail page.

![Local auth list tab](https://www.evtivity.com/screenshots/csms/station-local-auth-tab.png)

## How It Works

1. **Add tokens**

   The operator adds tokens from the system to a station's local auth list. This is a database-only operation - no OCPP command is sent to the station.

2. **Remove tokens**

   The operator removes tokens from the list as needed. This is also database-only.

3. **Push to station**

   When the list is ready, the operator pushes it to the station via OCPP `SendLocalList` using the Full update type. This sends all tracked entries to the station in a single operation.

The CSMS is the source of truth. Every push sends the complete list to the station, replacing whatever the station had before.

## Pre-Push Reconciliation

Before pushing the list to a station, the system runs two reconciliation steps:

| Check | Action |
|-------|--------|
| Orphaned entries | Tokens whose backing record has been deleted are removed from the list |
| Deactivated tokens | Tokens that have been deactivated get their `authStatus` set to `Blocked` so the station actively rejects them |

## UI Elements

The Local Auth List tab shows:

- **Version info** - CSMS version, station version, and last sync timestamp
- **Unpushed changes banner** - Warning when the local list has changes not yet pushed to the station
- **Token table** - All tokens in the list with their status and push state
- **Add tokens dialog** - Search and add tokens from the system

## Protocol Compatibility

This feature works with both OCPP 1.6 and 2.1 stations. The CSMS handles command translation between protocol versions automatically.
