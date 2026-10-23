# EVtivity API routes: SIMs

Generated from EVtivity CSMS v0.1.48-beta.4 (https://github.com/EVtivity/evtivity-csms, commit 871b5dded1fd) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sims` | sims:read | List SIMs |
| POST | `/v1/sims` | sims:write | Add a SIM |
| GET | `/v1/sims/export` | sims:read | Export SIMs as CSV |
| GET | `/v1/sims/export/template` | sims:read | Download the SIM import CSV template |
| POST | `/v1/sims/import` | sims:write | Import SIMs from parsed CSV rows |
| GET | `/v1/sims/{id}` | sims:read | Get a SIM |
| PATCH | `/v1/sims/{id}` | sims:write | Update a SIM |
| DELETE | `/v1/sims/{id}` | sims:write | Delete a SIM |
| POST | `/v1/sims/{id}/deactivate` | sims:write | Deactivate a SIM |
| POST | `/v1/sims/{id}/reactivate` | sims:write | Reactivate a SIM |
| GET | `/v1/sims/{id}/attachments` | sims:read | List a SIM's attachments |
| POST | `/v1/sims/{id}/attachments` | sims:write | Attach a SIM to a station |
| POST | `/v1/sims/{id}/attachments/{attachmentId}/detach` | sims:write | Detach a SIM |
| POST | `/v1/sims/{id}/attachments/{attachmentId}/confirm` | sims:write | Confirm a SIM's attachment |
| GET | `/v1/sims/{id}/timeline` | sims:read | Get a SIM's timeline |
| POST | `/v1/sims/{id}/refresh` | sims:read | Refresh a SIM's data |
| POST | `/v1/sims/{id}/network-reset` | sims:write | Reset a SIM's network |
| GET | `/v1/sims/{id}/neighbors` | sims:read | Get previous and next entity IDs in default list order |
