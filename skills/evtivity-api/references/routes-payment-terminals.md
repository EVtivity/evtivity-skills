# EVtivity API routes: Payment Terminals

Generated from EVtivity CSMS v0.1.49-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 34c1c1a0b35b) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/payment-terminals/feature` | paymentTerminals:read | Payment terminal feature status |
| GET | `/v1/payment-terminals` | paymentTerminals:read | List payment terminals |
| POST | `/v1/payment-terminals` | paymentTerminals:write | Register a payment terminal |
| GET | `/v1/payment-terminals/export` | paymentTerminals:read | Export payment terminals as CSV |
| GET | `/v1/payment-terminals/provider-devices` | paymentTerminals:write | List a provider's devices |
| GET | `/v1/payment-terminals/{id}` | paymentTerminals:read | Get a payment terminal |
| PATCH | `/v1/payment-terminals/{id}` | paymentTerminals:write | Edit a payment terminal |
| DELETE | `/v1/payment-terminals/{id}` | paymentTerminals:write | Delete a payment terminal |
| POST | `/v1/payment-terminals/{id}/pair` | paymentTerminals:write | Pair a payment terminal to a station |
| POST | `/v1/payment-terminals/{id}/unpair` | paymentTerminals:write | Unpair a payment terminal |
| POST | `/v1/payment-terminals/{id}/status` | paymentTerminals:write | Activate or deactivate a payment terminal |
| GET | `/v1/payment-terminals/{id}/transactions` | paymentTerminals:read | List a terminal's payments |
| POST | `/v1/payment-terminals/{id}/payments` | paymentTerminals:write | Start a card payment on a terminal |
| POST | `/v1/payment-terminal-transactions/{id}/void` | paymentTerminals:write | Release a terminal hold |
| POST | `/v1/payment-terminals/{id}/sim` | paymentTerminals:write | Enter a terminal's SIM |
| DELETE | `/v1/payment-terminals/{id}/sim` | paymentTerminals:write | Detach a terminal's SIM |
| GET | `/v1/payment-terminals/{id}/neighbors` | paymentTerminals:read | Get previous and next entity IDs in default list order |
