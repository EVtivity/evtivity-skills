Generated from https://www.evtivity.com/docs/csms/ai-inbox. Do not edit.

# AI Inbox

Review and confirm the actions that background AI workers and MCP clients propose. Nothing runs until you confirm it.

## Overview

The AI Inbox lists proposals: actions that a [background AI worker](https://www.evtivity.com/docs/csms/ai-workers) or an [MCP client](https://www.evtivity.com/docs/integrations/mcp-server) asks EVtivity to run. AI never changes anything on its own. A proposal runs only when you click **Confirm**, and it runs as you, with your permissions and site access.

Open it from **AI Inbox** in the navigation. The entry shows the number of pending proposals.

![AI Inbox](https://www.evtivity.com/screenshots/csms/ai-inbox.png)

## Proposals

The AI Inbox lists proposals in a table with these columns:

- **Status**: see [Statuses](#statuses).
- **Action**: such as **Stop the session**, **Soft reset the station**, or **Change the station availability**.
- **Station** and **Site**: the records the action acts on. Click one to open it.
- **Source**: the job that made the proposal, such as **Stuck Sessions**, or the name of the MCP client. The line below it shows **Background worker** or **MCP client**.
- **Created**: when the proposal was made.
- **Expires**: when a pending proposal stops being valid.

Click a row to open the proposal page.

### Filters

**Search** by station, site, or action. Filter by **Status** (Pending by default), **Source** (**Background worker** or **MCP client**), **Job**, and **Site**.

### Statuses

| Status | Meaning |
|--------|---------|
| Pending | Waiting for a decision |
| Executed | Confirmed and the action ran |
| Failed | Confirmed, but the action did not run, for example because you lack the permission it needs |
| Rejected | Someone rejected it |
| Expired | Nobody decided before it expired |
| No longer applies | The condition no longer held when someone confirmed it |

## Proposal Page

The proposal page, `/ai/inbox/<id>`, shows the action as its title with the status next to it. While the proposal is pending, **Confirm** and **Reject** sit at the top of the page. These cards follow:

- **Summary**: a sentence that describes the action, the method and path of the request, its key arguments, and the **Result** once it ran.
- **Rationale**: why the proposal was made, with the measured values behind it, such as **Idle time**, **Last activity**, **Faulted since**, and **Transaction ID**.
- **Target**: the station, session, and site the action acts on, and **Runs only if**: the condition checked again when you confirm, such as **The session is still active** or **The station is still faulted**.
- **Requested by**: the source and the job. For an MCP proposal it also shows the requester, the API key, the client, and the requested tool.
- **Timing**: when the proposal was created, when it expires, when it was decided, and when the action ran.
- **Arguments**: every argument of the request.
- **History**: every change to the proposal.

## Confirm or Reject

1. Open the proposal from the AI Inbox.
2. Read the action, the condition, and the arguments.
3. Click **Confirm** to run the action, or **Reject** to drop it.
4. Confirm your choice in the dialog. **Run This Action?** runs the action once, now, with your permissions. **Reject This Proposal?** drops the proposal.

When you confirm, EVtivity checks again that the proposal has not expired, that the condition still holds, and that the action is still allowed. Then it runs the request with your own permissions and site access. The result appears in the **Summary** card. Each proposal runs at most once: when two users confirm it at the same time, only one confirm runs it.

A proposal that expired shows `AI_PROPOSAL_EXPIRED`. A proposal whose condition no longer holds shows `AI_PROPOSAL_STALE` and ends as **No longer applies**.

Confirm and reject need a signed-in CSMS session. An API key can read proposals but cannot decide them (`AI_CONFIRMATION_REQUIRES_SESSION`).

## How Long a Proposal Stays Open

| Source | Expires after | Setting |
|--------|---------------|---------|
| Nightly network summary | 24 hours | **Proposal lifetime (hours)** |
| Stuck sessions | 2 hours | fixed |
| MCP client | 30 minutes | **Time to approve an MCP change (minutes)** |

## MCP Approval Page

When an MCP client asks for a change, it sends you to the proposal page, `/ai/inbox/<id>`. The **Requested by** card shows the name of the user who made the request, the API key name, the client name and version, and the requested tool. The **Arguments** card shows every argument of the request. The key and client names come from the client and are shown as sent.

Only the user whose API key made the request can see and approve an MCP proposal. Other users get a not found answer.

![MCP approval page](https://www.evtivity.com/screenshots/csms/ai-inbox-detail.png)

## Proposals on Station and Session Pages

The station and session detail pages list up to three pending proposals for that record, with **Details**, **Confirm**, and **Reject** buttons. **Details** opens the proposal page.

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
