# EVtivity API routes: Transactions

Generated from EVtivity CSMS v0.1.42-beta.3 (https://github.com/EVtivity/evtivity-csms, commit 3955bbb2ae69) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/transactions` | sessions:read | List transaction events |
| GET | `/v1/transactions/by-session/{sessionId}` | sessions:read | Get transaction events for a session |
| GET | `/v1/transactions/by-transaction-id/{transactionId}` | sessions:read | Get session by OCPP transaction ID |
