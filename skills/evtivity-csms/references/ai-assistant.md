Generated from https://www.evtivity.com/docs/csms/ai-assistant (website commit 0f3462e). Do not edit.

# AI Assistant

Query your charging network data using natural language with the built-in AI assistant.

## Overview

The AI assistant lets operators ask natural language questions about their charging network. It answers by calling the CSMS API endpoints internally, aggregating data, and presenting results in a conversational format. The assistant supports three AI providers and respects the operator's RBAC permissions and site access restrictions.

## How It Works

The assistant uses a two-tier tool selection process to efficiently handle 500+ API endpoints:

1. **Category selection**: The AI receives a compact list of API categories (Dashboard, Stations, Sessions, etc.) and picks 1-4 relevant categories for the question.
2. **Tool loading**: Only the tool definitions from the selected categories are loaded (typically 10-30 tools instead of 500+).
3. **Execution**: The AI calls the selected API endpoints using the operator's JWT token. All requests inherit the operator's permissions and site access.
4. **Response**: Tool results are fed back to the AI until it produces a final text answer.

## Enable the AI Assistant

### System-Wide Configuration (Admin)

1. Navigate to **Settings**.
2. Open the **AI** tab.
3. Toggle **Enable Chatbot AI**.
4. Select a provider and enter the API key:

| Provider | Default Model |
|----------|---------------|
| Anthropic | claude-sonnet-4-20250514 |
| OpenAI | gpt-4o |
| Gemini | gemini-2.0-flash |

5. Optionally configure: model override, temperature, top-p, top-k, and a custom system prompt.
6. Save.

### Per-User Configuration

Individual operators can override the system AI config with their own API key and preferences.

1. Navigate to your **Profile** page.
2. Open the **Chatbot AI** tab.
3. Enter your preferred provider, API key, and model.
4. Optionally adjust generation parameters (temperature, top-p, top-k) and system prompt.
5. Save.

![Profile with AI configuration](https://www.evtivity.com/screenshots/csms/profile.png)

Per-user configuration takes priority over system-wide settings. This lets operators use their own API keys or preferred models.

## Use the AI Assistant

1. Click the **Chatbot AI** button (sparkles icon) in the bottom-right corner of the CSMS dashboard.
2. A chat panel slides in from the right.
3. Type a question and press Enter.

Example questions:

- "How many stations are online right now?"
- "Show me the top 5 stations by energy delivered this month."
- "What is the total revenue for last week?"
- "List all faulted stations with their error details."
- "Which drivers have the most charging sessions?"

### Chat Features

- **Edit messages**: Click the pencil icon on a sent message to edit and resend from that point.
- **Retry**: Click the rotate icon to retry a message.
- **Copy**: Click the copy icon on any message to copy its content.
- **Markdown rendering**: AI responses render as markdown with tables, code blocks, lists, and bold text.

The assistant asks for explicit confirmation before making any changes (creating, updating, or deleting resources).

## Support Case AI Draft

The AI can draft replies to support cases using read-only API access.

### How to Use

1. Open a support case detail page.
2. Optionally check **Internal note** if you want an internal draft rather than a customer-facing reply.
3. Click the **AI Draft** button in the message input area.
4. The AI gathers context by reading the case details, message history, linked sessions, station info, and driver history.
5. A draft reply populates the textarea for your review and editing before sending.

The support AI does not send messages automatically or modify any data. It only produces drafts.

### Support AI Configuration

Support AI has its own configuration, independent from the chatbot:

- System-level: **Settings > AI** has a separate Support AI section with provider, key, model, and tone.
- Per-user: **Profile** page has a separate **Support AI** tab.
- Tone options: professional (default), friendly, formal.

## Security

- All API calls use the operator's JWT token. The AI can only access data the operator has permission to see.
- Site access restrictions are enforced. An operator with access to 3 sites cannot query data from other sites through the AI.
- The AI is instructed to never reveal sensitive data (passwords, API keys, tokens, encryption keys).
- Chat requests are rate limited to 10 per minute per user.
