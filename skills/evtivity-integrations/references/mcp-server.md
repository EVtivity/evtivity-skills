Generated from https://www.evtivity.com/docs/integrations/mcp-server. Do not edit.

# MCP Server

Connect AI agents to EVtivity over the Model Context Protocol with an API key. Every call runs under the key's permissions and sites. Writes run only when you allow them.

## Overview

EVtivity includes a Model Context Protocol (MCP) server. An MCP client, such as an AI agent or a desktop assistant, connects to it with an EVtivity API key and uses the same tools as the [AI assistant](https://www.evtivity.com/docs/csms/ai-assistant): it reads stations, sessions, sites, tokens, and automatic insights, and, when you allow writes, it can send OCPP commands.

The client brings its own AI model. EVtivity makes no AI requests for MCP calls, so they use no AI tokens.

Clients only read by default. Writes run only while **Allow Writes** is on (see [Writes](#writes)).

The MCP server is off by default.

The tool results an MCP client receives are filtered the same way as the tool results of the AI assistant. The assistant rules of this note apply to them:

> **Note:**
>
> **What the AI Provider Receives**
>
> The AI provider never receives stored credentials, such as passwords, API keys, secrets and station passwords. Card numbers and IBANs are cut to their last 4 characters. Support drafts, automatic insights, background workers and driver support also mask email addresses and phone numbers, and hash or shorten driver token ids. The assistant sends driver contact details as stored, only to users allowed to read them. Text you type and text files you attach are checked for keys and card numbers. Images and PDFs you attach are sent as they are.

## Endpoint

```
POST https://<your API host>/v1/mcp
```

The server uses the Streamable HTTP transport and is stateless, so any API instance answers any request. It answers `POST` only. `GET` and `DELETE` answer 405.

**Settings > AI > MCP** shows the endpoint URL of your installation.

![MCP server settings](https://www.evtivity.com/screenshots/csms/settings-ai-mcp.png)

### Protocol Versions

- **2026-07-28**: the current MCP version.
- **2025-11-25** and other 2025 clients: served without sessions, with the same tools and results.

### Tested Clients

The official MCP TypeScript client (`@modelcontextprotocol/client` 2.3.1) is tested against the server as a 2026-07-28 client and as a 2025-11-25 client: it lists tools, reads, and runs a write with **Allow Writes** on.

## Set Up

1. In **Settings > AI > MCP**, turn on **Turn on the MCP server**. Turn on **Allow Writes** only if clients should send station commands. Click **Save**.
2. In **Settings > API Keys**, create an API key with these permissions:
   - `aiMcp:read` to use the MCP server and its read tools.
   - `aiMcp:write` to use the write tools while **Allow Writes** is on. Without it, the client sees no write tools.
   - The permission of each command the client should send, and `stations:read` so EVtivity can match the command to the station's OCPP version.
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

`ai-insights`, `sessions`, `sites`, `stations`, `tokens`

Pick other toolsets with the `toolsets` query parameter:

```
POST https://<your API host>/v1/mcp?toolsets=stations,sessions,ocpp-2-1-commands
```

A toolset name is the API category in lowercase with hyphens, such as `ocpp-2-1-commands`, `ocpp-1-6-commands`, `load-management`, or `reports`. An unknown name answers 400 with the list of available toolsets.

The tool list is the same for every key. A tool the key has no permission for returns the API's 403 as an error result.

### Reads

A read tool runs the API request as the key's user. Secrets are removed and sensitive values are masked before the result goes to the client. Each result has a text part and a `structuredContent` part with `httpStatus` and `data`.

### Writes

The write tools are the OCPP command tools, such as reset, unlock, or stop a transaction. Station password and security profile commands are never offered.

Writes are off by default. While **Allow Writes** is off, the client sees no write tools, and a call to one answers `writes_disabled`. A key without `aiMcp:write` sees no write tools either, and a call to one answers `forbidden`.

While **Allow Writes** is on, a write call runs at once, with no approval step:

1. EVtivity checks the arguments and the station. When the tool is for the other OCPP version than the station uses, EVtivity maps it to the station's version. A station outside the user's sites is refused as not found.
2. The command runs as the key's user, with that user's permissions and site access, like an API call with the key. A key without the command's permission gets the API's 403 as an error result.
3. The result returns to the client. A write keeps running when the client disconnects, so its result and audit entries are complete.

Turn on **Allow Writes** only for clients you trust to change stations, and give their keys only the permissions and sites they need.

## Limits

| Setting | Default | Range |
|---------|---------|-------|
| **Calls per API key per minute** (`ai.mcp.rateLimitPerMinute`) | 60 | 1 to 10,000 |
| **Calls per API key per day** (`ai.mcp.dailyCallsPerKey`) | 5,000 | 1 to 10,000,000 |

Every request counts once. A request carries one JSON-RPC message: a batch (an array body) is refused with 400 and a JSON-RPC error `-32600` whose `data.code` is `VALIDATION_ERROR`, and nothing in it runs. Over a limit, the server answers 429 with a `Retry-After` header and a JSON-RPC error whose `data.code` is `AI_MCP_RATE_LIMITED`. The day is a UTC day.

## Errors

Errors of a tool call appear as an error result with a text and `structuredContent.code`. The code is an [API error code](https://www.evtivity.com/api-reference/error-codes) or a refusal reason such as `writes_disabled`, `forbidden`, `invalid_arguments`, `station_not_found`, or `unavailable`.

## Audit

EVtivity logs every tool call with the key, the user, the client name and version, the tool, the redacted arguments, the status, and the duration. Audit entries written by MCP reads and writes are marked as made through MCP, with the API key as the actor. Call logs are deleted after the conversation retention period of **Settings > Data Retention** (30 days by default), and never sooner than 3 days.

## Settings

| Setting | Key | Default |
|---------|-----|---------|
| **Turn on the MCP server** | `ai.mcp.enabled` | Off |
| **Allow Writes** | `ai.mcp.allowWrites` | Off |
| **Calls per API key per minute** | `ai.mcp.rateLimitPerMinute` | 60 |
| **Calls per API key per day** | `ai.mcp.dailyCallsPerKey` | 5,000 |
| **Allowed origins** | `ai.mcp.allowedOrigins` | Empty (up to 50 http or https origins, one per line, without a path) |

When the MCP server is off, `/v1/mcp` answers 404.

## Notes

- Behind a reverse proxy, turn off response buffering for `/v1/mcp` so streamed answers arrive at once. The server sends `X-Accel-Buffering: no`.
- API keys cannot confirm assistant actions or insight actions (`AI_CONFIRMATION_REQUIRES_SESSION`). MCP writes need no confirmation: the key's permissions decide.
- OAuth sign-in for MCP clients is not available. Use API keys.
