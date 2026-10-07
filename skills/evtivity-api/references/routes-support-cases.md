# EVtivity API routes: Support Cases

Generated from EVtivity CSMS v0.1.40 (https://github.com/EVtivity/evtivity-csms, commit 571bdc26947f) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/support-cases` | support:read | List support cases |
| POST | `/v1/support-cases` | support:write | Create a support case |
| GET | `/v1/support-cases/unread-count` | support:read | Get unread support case count for the current operator |
| GET | `/v1/support-cases/attachment-storage` | support:read | Get whether support case attachment storage is configured |
| GET | `/v1/support-cases/{id}` | support:read | Get support case detail |
| PATCH | `/v1/support-cases/{id}` | support:write | Update a support case |
| POST | `/v1/support-cases/{id}/read` | support:write | Mark a support case as read by the current operator |
| POST | `/v1/support-cases/{id}/messages` | support:write | Add a message to a support case |
| POST | `/v1/support-cases/{id}/messages/{messageId}/attachments/upload-url` | support:write | Get a presigned S3 upload URL for an attachment |
| POST | `/v1/support-cases/{id}/messages/{messageId}/attachments` | support:write | Confirm an attachment after uploading to S3 |
| GET | `/v1/support-cases/{id}/messages/{messageId}/attachments/{attachmentId}/download-url` | support:read | Get a presigned S3 download URL for an attachment |
| DELETE | `/v1/support-cases/{id}/messages/{messageId}/attachments/{attachmentId}` | support:write | Delete an attachment from a support case message |
| POST | `/v1/support-cases/{id}/refund` | support:write | Issue a refund for a session linked to a support case |
| POST | `/v1/support-cases/{id}/ai-assist` | support:write | Generate an AI draft reply for a support case |
| GET | `/v1/support-cases/{id}/neighbors` | support:read | Get previous and next entity IDs in default list order |
