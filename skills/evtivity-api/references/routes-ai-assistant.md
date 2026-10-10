# EVtivity API routes: AI Assistant

Generated from EVtivity CSMS v0.1.43-beta.1 (https://github.com/EVtivity/evtivity-csms, commit d1264d35d391) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/assistant/status` |  | Whether the AI assistant and support assist are available |
| GET | `/v1/assistant/conversations` |  | List the user's AI assistant conversations |
| POST | `/v1/assistant/conversations` |  | Start an AI assistant conversation |
| GET | `/v1/assistant/conversations/{id}` |  | Get an AI assistant conversation with its messages |
| PATCH | `/v1/assistant/conversations/{id}` |  | Rename an AI assistant conversation |
| DELETE | `/v1/assistant/conversations/{id}` |  | Delete an AI assistant conversation |
| POST | `/v1/assistant/conversations/{id}/messages` |  | Send a message and stream the answer |
| POST | `/v1/assistant/conversations/{id}/actions/{actionId}/confirm` |  | Confirm a proposed action and stream the rest of the answer |
| POST | `/v1/assistant/conversations/{id}/actions/{actionId}/reject` |  | Reject a proposed action and stream the rest of the answer |
| POST | `/v1/assistant/attachments/upload-url` |  | Request an upload URL for an AI chat attachment |
| POST | `/v1/assistant/attachments/{id}/confirm` |  | Confirm an uploaded AI chat attachment |
| GET | `/v1/assistant/attachments/{id}/download-url` |  | Get a download URL for an AI chat attachment |
| DELETE | `/v1/assistant/attachments/{id}` |  | Delete an AI chat attachment |
