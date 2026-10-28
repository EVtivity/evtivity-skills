# EVtivity API routes: AI

Generated from EVtivity CSMS v0.1.49-beta.1 (https://github.com/EVtivity/evtivity-csms, commit a030132e96bd) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/ai/usage` |  | AI usage and budgets of a month |
| GET | `/v1/ai/usage/sites/{siteId}` |  | A site's AI usage and monthly budget |
| GET | `/v1/users/me/ai-usage` |  | My AI usage |
| GET | `/v1/ai/alerts` | settings.ai:read | Active AI alerts |
