Generated from https://www.evtivity.com/docs/integrations/mcp-server. Do not edit.

# MCP Server

Connect AI agents to EVtivity over the Model Context Protocol with an API key. Reads run under the key's permissions, and every change waits for your approval in the AI Inbox.

## Overview

EVtivity includes a Model Context Protocol (MCP) server. An MCP client, such as an AI agent or a desktop assistant, connects to it with an EVtivity API key and uses the same tools as the [AI assistant](https://www.evtivity.com/docs/csms/ai-assistant): it reads stations, sessions, sites, tokens, and automatic insights, and it can ask for OCPP commands.

The client brings its own AI model. EVtivity makes no AI requests for MCP calls, so they use no AI tokens.

Writes never run directly. An MCP change becomes a proposal that the same user approves in the CSMS [AI Inbox](https://www.evtivity.com/docs/csms/ai-inbox).

The MCP server is off by default.

## Endpoint

```
POST https://<your API host>/v1/mcp
```

The server uses the Streamable HTTP transport and is stateless, so any API instance answers any request. It answers `POST` only. `GET` and `DELETE` answer 405.

**Settings > AI > MCP server** shows the endpoint URL of your installation.

![MCP server settings](https://www.evtivity.com/screenshots/csms/settings-ai-mcp.png)

### Protocol Versions

- **2026-07-28**: the current MCP version, with URL elicitation for approvals.
- **2025-11-25** and other 2025 clients: served without sessions. These clients get approvals by polling (see [Approval Without URL Elicitation](#approval-without-url-elicitation)).

### Tested Clients

The official MCP TypeScript client (`@modelcontextprotocol/client` 2.3.1) is tested against the server as a 2026-07-28 client and as a 2025-11-25 client: it lists tools, reads, and asks for a change.

## Set Up

1. In **Settings > AI > MCP server**, turn on **Turn on the MCP server** and click **Save**.
2. In **Settings > API Keys**, create an API key with these permissions:
   - `aiMcp:read` to use the MCP server and its read tools.
   - `aiMcp:write` and `stations:read` to propose changes. Without them, the client sees no write tools.
   - `aiProposals:read` for a client that polls `get_ai_proposal` for the result of a change. Without it, the poll answers 403.
   - The permissions of the data the client should read, such as `stations:read` and `sessions:read`.
3. Configure your MCP client with the endpoint URL and the header `Authorization: Bearer <API key>`. The format of the client configuration depends on the client.

A key never exceeds the permissions and site access of the user who created it. Every tool call runs as that user, so the user's permissions and site access apply to each call. See [API Keys](https://www.evtivity.com/docs/csms/settings#api-keys).

## Authentication

- Only API keys are accepted. A request without a key, with a session cookie, or with a sign-in token answers 401 with a `WWW-Authenticate: Bearer` header.
- A key without `aiMcp:read` answers 403.
- When a request carries an `Origin` header, the origin must be in **Allowed origins**, else it answers 403. Leave the list empty to refuse every request from a browser. Clients that are not browsers usually send no `Origin` header.

## Tools

The server offers a curated set of the assistant's tools. Users and permissions, access logs, the audit log, payments, invoices, settings, API keys, and station security are never offered.

### Toolsets

Tools are grouped by API category. By default, the server lists these toolsets:

`ai-insights`, `ai-proposals`, `sessions`, `sites`, `stations`, `tokens`

Pick other toolsets with the `toolsets` query parameter:

```
POST https://<your API host>/v1/mcp?toolsets=stations,sessions,ocpp-2-1-commands
```

A toolset name is the API category in lowercase with hyphens, such as `ocpp-2-1-commands`, `ocpp-1-6-commands`, `load-management`, or `reports`. An unknown name answers 400 with the list of available toolsets.

The tool list is the same for every key. A tool the key has no permission for returns the API's 403 as an error result.

### Reads

A read tool runs the API request as the key's user. Secrets are removed and sensitive values are masked before the result goes to the client. Each result has a text part and a `structuredContent` part with `httpStatus` and `data`.

### Writes Become Proposals

The write tools are the OCPP command tools, such as reset, unlock, or stop a transaction. A write call never runs the command. Instead:

1. EVtivity checks the arguments and the station. When the tool is for the other OCPP version than the station uses, EVtivity maps it to the station's version. A station outside the user's sites is refused as not found.
2. EVtivity creates a proposal in the AI Inbox for the same user. Sending the same call again returns the open proposal instead of a second one.
3. The user opens the proposal in the CSMS and clicks **Confirm** or **Reject**. Only the user whose key made the request can see and approve it.
4. The command runs only after **Confirm**, as that user.

A proposal expires after 30 minutes by default (**Time to approve an MCP change (minutes)**).

### Approval With URL Elicitation

A 2026-07-28 client that supports URL elicitation receives an `input_required` result with:

- a link to the proposal's approval page, `https://<CSMS host>/ai/inbox/<proposalId>`. The link holds no token or personal data.
- a sealed `requestState`.

After the user confirms or rejects, the client sends the call again with the `requestState`. The server then returns the command's result once. A later retry with the same state returns `AI_PROPOSAL_ALREADY_DECIDED`. A rejected proposal returns `AI_PROPOSAL_ALREADY_DECIDED`, an expired one `AI_PROPOSAL_EXPIRED`, and one whose condition no longer holds `AI_PROPOSAL_STALE`.

A form answer from the client, such as "accept", never confirms a change. Only the user's click in the CSMS does.

### Approval Without URL Elicitation

Other clients receive a normal result:

```json
{ "status": "pending_approval", "proposalId": "...", "approveIn": "...", "expiresAt": "..." }
```

The client then polls the `get_ai_proposal` tool (in the `ai-proposals` toolset) until the proposal is decided. The key needs `aiProposals:read` for this tool.

## Limits

| Setting | Default | Range |
|---------|---------|-------|
| **Calls per API key per minute** (`ai.mcp.rateLimitPerMinute`) | 60 | 1 to 10,000 |
| **Calls per API key per day** (`ai.mcp.dailyCallsPerKey`) | 5,000 | 1 to 10,000,000 |

Every request counts once. Over a limit, the server answers 429 with a `Retry-After` header and a JSON-RPC error whose `data.code` is `AI_MCP_RATE_LIMITED`. The day is a UTC day.

## Errors

Errors of a tool call appear as an error result with a text and `structuredContent.code`. The code is an [API error code](https://www.evtivity.com/api-reference/error-codes) or a refusal reason such as `invalid_arguments`, `station_not_found`, or `unavailable`.

## Audit

EVtivity logs every tool call with the key, the user, the client name and version, the tool, the redacted arguments, the status, and the duration. Audit entries written by MCP reads, and by proposals confirmed from MCP, are marked as made through MCP. Call logs are deleted after the conversation retention period of **Settings > AI** (30 days by default), and never sooner than 3 days.

## Settings

| Setting | Key | Default |
|---------|-----|---------|
| **Turn on the MCP server** | `ai.mcp.enabled` | Off |
| **Calls per API key per minute** | `ai.mcp.rateLimitPerMinute` | 60 |
| **Calls per API key per day** | `ai.mcp.dailyCallsPerKey` | 5,000 |
| **Time to approve an MCP change (minutes)** | `ai.mcp.proposalTtlMinutes` | 30 (5 to 1,440) |
| **Allowed origins** | `ai.mcp.allowedOrigins` | Empty (up to 50 http or https origins, one per line, without a path) |

When the MCP server is off, `/v1/mcp` answers 404.

## Notes

- Behind a reverse proxy, turn off response buffering for `/v1/mcp` so streamed answers arrive at once. The server sends `X-Accel-Buffering: no`.
- API keys cannot confirm assistant actions or proposals (`AI_CONFIRMATION_REQUIRES_SESSION`). Approval always needs a signed-in CSMS session.
- OAuth sign-in for MCP clients is not available. Use API keys.
