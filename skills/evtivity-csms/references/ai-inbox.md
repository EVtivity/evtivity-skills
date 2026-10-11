Generated from https://www.evtivity.com/docs/csms/ai-inbox. Do not edit.

# AI Inbox

Review and confirm the actions that background AI workers and MCP clients propose. Nothing runs until you confirm it.

## Overview

The AI Inbox lists proposals: actions that a [background AI worker](https://www.evtivity.com/docs/csms/ai-workers) or an [MCP client](https://www.evtivity.com/docs/integrations/mcp-server) asks EVtivity to run. AI never changes anything on its own. A proposal runs only when you click **Confirm**, and it runs as you, with your permissions and site access.

Open it from **AI Inbox** in the navigation. The entry shows the number of pending proposals.

![AI Inbox](https://www.evtivity.com/screenshots/csms/ai-inbox.png)

## Proposals

Each proposal card shows:

- The action, such as **Stop the session**, **Soft reset the station**, or **Change the station availability**, and a sentence that describes it.
- The station and session it acts on.
- **Runs only if**: the condition checked again when you confirm, such as **The session is still active** or **The station is still faulted**.
- **Rationale**: why the worker proposes it.
- The method, path, and arguments of the request that will run.
- **Expires**: when the proposal stops being valid.

### Filters

Filter by **Status** (Pending by default), **Source** (**Background worker** or **MCP client**), **Job**, and **Site**.

### Statuses

| Status | Meaning |
|--------|---------|
| Pending | Waiting for a decision |
| Executed | Confirmed and the action ran |
| Failed | Confirmed, but the action did not run, for example because you lack the permission it needs |
| Rejected | Someone rejected it |
| Expired | Nobody decided before it expired |
| No longer applies | The condition no longer held when someone confirmed it |

## Confirm or Reject

1. Read the action, the condition, and the arguments.
2. Click **Confirm** to run the action, or **Reject** to drop it.

When you confirm, EVtivity checks again that the proposal has not expired, that the condition still holds, and that the action is still allowed. Then it runs the request with your own permissions and site access. The result appears on the card. Each proposal runs at most once: when two users confirm it at the same time, only one confirm runs it.

A proposal that expired shows `AI_PROPOSAL_EXPIRED`. A proposal whose condition no longer holds shows `AI_PROPOSAL_STALE` and ends as **No longer applies**.

Confirm and reject need a signed-in CSMS session. An API key can read proposals but cannot decide them (`AI_CONFIRMATION_REQUIRES_SESSION`).

## How Long a Proposal Stays Open

| Source | Expires after | Setting |
|--------|---------------|---------|
| Nightly network summary | 24 hours | **Proposal lifetime (hours)** |
| Stuck sessions | 2 hours | fixed |
| MCP client | 30 minutes | **Time to approve an MCP change (minutes)** |

## MCP Approval Page

When an MCP client asks for a change, it sends you to the proposal's own page, `/ai/inbox/<id>`. The page shows the API key name, the client name and version, and every argument of the request. The key and client names come from the client and are shown as sent.

Only the user whose API key made the request can see and approve an MCP proposal. Other users get a not found answer.

![MCP approval page](https://www.evtivity.com/screenshots/csms/ai-inbox-detail.png)

## Proposals on Station and Session Pages

The station and session detail pages list up to three pending proposals for that record, with the same **Confirm** and **Reject** buttons.

## Daily Digest Email

Users with the `aiProposals:write` permission can get a daily email with the number of pending proposals at their sites, per job, and a link to the AI Inbox. The email holds counts and site names only, never AI-written text.

To turn it on, open your **Profile**, go to **Notifications**, and turn on **AI Inbox digest email**. It is off by default. The email goes out once a day when proposals from background workers are pending. Edit its template under **Notifications > System Events** (`ai.ProposalDigest`).

## Permissions

| Permission | Allows |
|------------|--------|
| `aiProposals:read` | See the AI Inbox and proposals of your sites |
| `aiProposals:write` | Confirm and reject proposals |

By default, operators have both and viewers have `aiProposals:read`. A proposal that has no site is visible only to users with access to every site.

## Notes

- Background workers can propose only three actions: stop a session, soft reset a station, and change a station's availability. Payments, pricing, and settings are never proposed.
- Every decision is recorded in the audit log. The audit entry of the action names the proposal and the user who confirmed it.
- Decided proposals are deleted after the insight retention period (90 days by default).
