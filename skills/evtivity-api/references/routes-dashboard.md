# EVtivity API routes: Dashboard

Generated from EVtivity CSMS v0.1.41-alpha.3 (https://github.com/EVtivity/evtivity-csms, commit 83e6334e0f0d) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/dashboard/stats` | dashboard:read | Get dashboard statistics |
| GET | `/v1/dashboard/energy-history` | dashboard:read | Get energy delivery history by day |
| GET | `/v1/dashboard/session-history` | dashboard:read | Get charging session count history by day |
| GET | `/v1/dashboard/station-status` | dashboard:read | Get connector counts grouped by status |
| GET | `/v1/dashboard/utilization` | dashboard:read | Get site utilization percentages |
| GET | `/v1/dashboard/peak-usage` | dashboard:read | Get peak usage heatmap by hour and day of week |
| GET | `/v1/dashboard/financial-stats` | dashboard:read | Get financial summary statistics |
| GET | `/v1/dashboard/revenue-history` | dashboard:read | Get revenue history by day |
| GET | `/v1/dashboard/payment-breakdown` | dashboard:read | Get payment counts and totals grouped by status |
| GET | `/v1/dashboard/uptime` | dashboard:read | Get station uptime percentage and port counts |
| GET | `/v1/dashboard/ocpp-health` | dashboard:read | Get OCPP WebSocket server health metrics |
| GET | `/v1/dashboard/site-locations` | dashboard:read | Site locations for map |
| GET | `/v1/dashboard/snapshots/trend` | dashboard:read | Get 14-day trend of dashboard snapshots |
| GET | `/v1/dashboard/snapshots/available-dates` | dashboard:read | Get dates that have snapshot data |
| GET | `/v1/dashboard/snapshots` | dashboard:read | Get historical dashboard snapshot for a date |
| GET | `/v1/dashboard/carbon-stats` | dashboard:read | Get carbon impact statistics |
