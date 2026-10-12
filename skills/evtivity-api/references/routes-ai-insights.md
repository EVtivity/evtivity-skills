# EVtivity API routes: AI Insights

Generated from EVtivity CSMS v0.1.45-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 8cbddaf0c6a1) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/ai/insights` | aiInsights:read | List automatic insights in your sites |
| GET | `/v1/ai/insights/feedback-summary` | aiInsights:read | Helpful and wrong votes on automatic insights by kind, last 30 days |
| GET | `/v1/ai/insights/{id}` | aiInsights:read | Get an automatic insight; asks for a translation into your language when missing |
| POST | `/v1/ai/insights/{id}/regenerate` | aiInsights:write | Generate an automatic insight again from fresh evidence |
| POST | `/v1/ai/insights/{id}/dismiss` | aiInsights:write | Dismiss an automatic insight |
| POST | `/v1/ai/insights/{id}/feedback` | aiInsights:write | Set or change your vote on an automatic insight: helpful or wrong |
| DELETE | `/v1/ai/insights/{id}/feedback` | aiInsights:write | Remove your vote on an automatic insight |
| POST | `/v1/ai/insights/{id}/action/confirm` | aiInsights:write | Confirm and run the action an insight carries |
| POST | `/v1/ai/insights/{id}/action/reject` | aiInsights:write | Reject the action an insight carries |
| GET | `/v1/ai/insights/{id}/neighbors` | aiInsights:read | Get previous and next entity IDs in default list order |
