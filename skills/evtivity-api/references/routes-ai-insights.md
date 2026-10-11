# EVtivity API routes: AI Insights

Generated from EVtivity CSMS v0.1.44-beta.1 (https://github.com/EVtivity/evtivity-csms, commit 3a48572ad4f5) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/ai/insights` | aiInsights:read | List automatic insights in your sites |
| GET | `/v1/ai/insights/{id}` | aiInsights:read | Get an automatic insight; asks for a translation into your language when missing |
| POST | `/v1/ai/insights/{id}/regenerate` | aiInsights:write | Generate an automatic insight again from fresh evidence |
| POST | `/v1/ai/insights/{id}/dismiss` | aiInsights:write | Dismiss an automatic insight |
| POST | `/v1/ai/insights/{id}/feedback` | aiInsights:write | Mark an automatic insight helpful or wrong |
