Generated from https://www.evtivity.com/docs/csms/ai-assistant. Do not edit.

# AI Assistant

Ask questions about your charging network, review proposed changes, and draft support replies with the built-in AI assistant.

## Overview

The AI assistant answers questions about your charging network in plain language. It reads live data through the CSMS API with your own permissions and site access, so it sees only what you can see. It can also propose changes, but it never runs one until you confirm it.

The assistant works with four AI providers: Anthropic, OpenAI, Google Gemini, and DeepSeek. An administrator sets it up under **Settings > AI** (see [Settings](https://www.evtivity.com/docs/csms/settings#ai)).

The conversation text, the data the assistant reads (with secrets removed), and attached files are sent to the selected AI provider. This data leaves your deployment. Check the provider's data retention terms before you turn the assistant on.

## Permissions

| Permission | Allows |
|------------|--------|
| `aiAssistant:read` | Open the assistant and read your past conversations |
| `aiAssistant:write` | Start chats, send messages, attach files, rename and delete conversations, and confirm or reject proposed changes |

By default, administrators have both permissions, operators have both, and viewers have `aiAssistant:read`. A user with read access only sees past conversations and a note that starting a chat needs the write permission. Edit permissions per user on the [Users](https://www.evtivity.com/docs/csms/users) page.

The assistant runs every request as you. Each API call checks your permissions and your site access again, so the assistant cannot reach data or actions you lack.

## Open the Assistant

Click the AI button (sparkles icon) in the bottom-right corner of any CSMS page, or press Ctrl+K (Cmd+K on macOS). The button appears only when the assistant is turned on and has a provider with an API key, either in Settings or in your personal configuration.

On a wide screen the panel opens on the right side of the page. On a phone it fills the screen.

## Ask a Question

1. Type a question in the message box.
2. Press Enter or click **Send**.
3. The answer streams in as the model writes it. Click **Stop** to end it early. The partial answer is saved.

The assistant answers in your CSMS language unless you ask for another language. A new chat shows suggested prompts under **Try asking**, chosen for the page you are on. Click one to send it.

Example questions:

- "How many stations are online right now?"
- "Show me the top 5 stations by energy delivered this month."
- "How does this week's revenue compare to last week?"
- "List all faulted stations with their error details."

### Answers

- **Steps**: each API call the assistant made appears as a collapsible step with its status and duration.
- **Documentation**: when the answer draws on the EVtivity documentation, links to the pages it used appear below the answer. Answers without such sources show no list.
- **Copy**: click **Copy** to copy an answer. Code blocks have their own copy button.
- Answers render tables, lists, and code. Links open in a new tab and only trusted hosts are clickable. Images in answers are not loaded.
- Each answer shows the number of tokens it used.

![AI assistant answer with its steps](https://www.evtivity.com/screenshots/csms/ai-assistant-answer.png)

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Ctrl+K or Cmd+K | Open or close the panel |
| Enter | Send the message |
| Shift+Enter | Add a line |
| Up | Put your last message back in the message box (when the box is empty) |
| Esc | Stop the answer, or close the panel when nothing is streaming |

## Confirm Changes

The assistant reads data without asking. Any change, such as creating, updating, or deleting a record, stops the answer and shows a **Confirm this change** card. The card shows what the change does and its **Details**.

- Click **Confirm** to run the change. The assistant then continues its answer.
- Click **Reject** to cancel it.

![Confirm this change card](https://www.evtivity.com/screenshots/csms/ai-assistant-confirm.png)

The assistant proposes one change at a time. A proposal expires after 5 minutes and then shows **Expired**. Ask again to get a new one.

Some actions are never available to the assistant, even with confirmation: settings and stored secrets, API keys, sign-in and MFA, users and permissions, the AI configuration itself, payments, refunds, invoices, pricing, free vend, station credentials, certificates, network profiles, configuration variables, and firmware. Do these in the CSMS directly.

## Conversation History

Your conversations are saved and private to you. Open **Conversation history** in the panel to:

- Search conversations by title.
- Open a conversation to continue it.
- Rename a conversation.
- Delete a conversation and its attachments. This cannot be undone.

Click **New chat** to start over. Conversations are deleted automatically once they have had no activity for the retention period set in **Settings > AI** (30 days by default).

## Attachments

Click **Attach files**, drop files on the panel, or paste them into the message box. The assistant can read:

- Images (JPEG, PNG, WebP, GIF)
- PDF
- CSV, plain text, and log files
- JSON and JSONL (for example, OCPP message traces)

The maximum size and the number of files per message come from the AI limits in Settings (10 MB and 5 files by default). Attachments need S3 storage (see [Settings](https://www.evtivity.com/docs/csms/settings#s3-bucket)).

Attachments go through the same checks as support case attachments. The server checks each file's content against its declared type and refuses a mismatch. It re-encodes images and removes their metadata (such as location data) before storing them. If the selected model cannot read a file type, the assistant says so instead of answering.

## Personal Configuration

You can use your own provider and API key instead of the system settings.

1. Open your **Profile** page.
2. Open the **Chatbot AI** tab.
3. Select a **Provider** and enter your **API key**.
4. Optionally set a **Model (optional)**, the **Effort**, and a **System prompt (optional)**.
5. Click **Save**.

![Chatbot AI tab of the profile](https://www.evtivity.com/screenshots/csms/profile-chatbot-ai.png)

Your configuration applies only to you and takes priority over the system settings. An empty model uses the provider's default model. Click **Remove configuration** to go back to the system settings.

The tab appears only while the assistant is turned on in Settings. When an administrator turns the assistant off in **Settings > AI**, the AI button disappears and every assistant request is refused, including requests that use a personal configuration.

## Limits

An administrator sets these in **Settings > AI**. They apply to every user and provider.

- **Requests per user per minute**: default 10.
- **Tokens per user per day**: default 2,000,000. 0 means no daily limit.
- **Tool calls per answer**: default 20. The assistant stops calling the API for that answer when it reaches the limit.
- **Keep conversations for (days)**: default 30.

When you reach a limit, the assistant shows an error. Try again later.

## Support Case AI Draft

The AI drafts replies to support cases. It needs the `support:write` permission and **Enable support AI** in **Settings > AI**.

1. Open a support case.
2. Check **Internal note** for a note to your team. Leave it unchecked for a reply to the customer.
3. Click **AI Draft**.
4. The draft streams into the message box. Click **Stop draft** to end it early.
5. Review and edit the draft, then send it yourself.

If the message box already holds text, the CSMS asks before it replaces it. A **Sources** list below the message box shows the data the AI read for the draft, such as the case, its messages, linked sessions, the station, and the driver.

![Support case AI draft with its sources](https://www.evtivity.com/screenshots/csms/support-case-ai-draft.png)

- A customer reply follows the driver's language. An internal note uses your CSMS language.
- The AI reads only the case and its linked data. It cannot read other cases or other drivers.
- It never changes anything and never sends a message. You decide what to send.

Support AI has its own configuration with a **Reply tone** (Professional, Friendly, or Formal). Set it in **Settings > AI** or, for yourself, on the **Support AI** tab of your **Profile**. Support AI requests also count against **Support AI requests per site per minute** (default 60).
