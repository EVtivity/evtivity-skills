# EVtivity API routes: Invoices

Generated from EVtivity CSMS v0.1.39-beta.1 (https://github.com/EVtivity/evtivity-csms, commit bd06577f1cf1) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/invoices` | payments:read | List invoices |
| GET | `/v1/invoices/{id}` | payments:read | Get an invoice with line items |
| POST | `/v1/invoices/session/{sessionId}` | payments:write | Generate an invoice for a single charging session |
| POST | `/v1/invoices/aggregated` | payments:write | Generate an aggregated invoice for a driver over a date range |
| PATCH | `/v1/invoices/{id}/void` | payments:write | Void an invoice |
| POST | `/v1/invoices/{id}/send` | payments:write | Email an invoice to its driver |
| GET | `/v1/invoices/{id}/pdf` | payments:read | Download an invoice as a PDF |
| GET | `/v1/invoices/{id}/download` | payments:read | Download an invoice as JSON |
| GET | `/v1/invoices/{id}/neighbors` | payments:read | Get previous and next entity IDs in default list order |
