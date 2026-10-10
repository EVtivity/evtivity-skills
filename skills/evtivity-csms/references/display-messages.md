Generated from https://www.evtivity.com/docs/csms/display-messages. Do not edit.

# Display Messages

Push pricing info and custom text to station screens via OCPP 2.1.

## Overview

Display messages push pricing information and custom text to station screens using the OCPP 2.1 `SetDisplayMessage` command. Manage messages per station from the Station Detail page.

![Display messages tab](https://www.evtivity.com/screenshots/csms/station-messages-tab.png)

> **Note:**
>
> Display messages require OCPP 2.1. Stations running OCPP 1.6 do not support this feature.

## Managing Messages

Operators can perform three actions from the Station Detail page:

| Action | Description |
|--------|-------------|
| Create and send | Compose a message with text, priority, state, and optional transaction or component targeting, then send it to the station |
| Clear | Remove an accepted message from the station |
| Refresh | Query the station via `GetDisplayMessages` to update the message list |

### Offline Stations

**Send Message** and **Refresh from Station** need a connected station. **Clear Message** (the trash icon of an accepted message) also works while the station is offline: the CSMS queues the clear and shows "Station offline. The command is queued and sent when the station reconnects." The message keeps its status until the station reconnects and answers. An accepted clear then marks it cleared. The same happens when a station disconnects while a message is being sent or refreshed.

![Clear queued for an offline station](https://www.evtivity.com/screenshots/csms/station-messages-queued.png)

## Message Fields

| Field | Description |
|-------|-------------|
| Text | The message content displayed on the station screen |
| Priority | Message priority level |
| State | Display state (e.g., charging, idle) |
| Transaction ID | Optional - target a specific transaction |
| Component | Optional - target a specific station component |

## Status Lifecycle

Each display message has a status that tracks its lifecycle:

| Status | Description |
|--------|-------------|
| pending | Sent to the station but not yet confirmed |
| accepted | Station confirmed receipt and will display the message |
| rejected | Station refused the message |
| unknown | Status could not be determined |

## Automated Pricing Messages

The CSMS can push pricing and status messages to all connected OCPP 2.1 stations automatically (OCPP 1.6 stations get the Idle screen as a vendor `DataTransfer`). Turn on **Enable Station Messages** (`stationMessage.enabled`) under Settings > Integrations & Features > Messages. Prices follow the company price display and the display language. See [Station display messages](https://www.evtivity.com/docs/guides/station-display-messages).

When enabled, stations display current pricing information without manual operator intervention.
