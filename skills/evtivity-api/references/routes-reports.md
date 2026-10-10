# EVtivity API routes: Reports

Generated from EVtivity CSMS v0.1.43 (https://github.com/EVtivity/evtivity-csms, commit 94253c800a66) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/reports` | reports:read | List reports |
| GET | `/v1/reports/types` | reports:read | List report types |
| GET | `/v1/reports/{id}` | reports:read | Get a report by ID |
| DELETE | `/v1/reports/{id}` | reports:write | Delete a report |
| GET | `/v1/reports/{id}/download` | reports:read | Download a report file |
| POST | `/v1/reports/generate` | reports:write | Queue a new report for generation |
| GET | `/v1/report-schedules` | reports:read | List report schedules |
| POST | `/v1/report-schedules` | reports:write | Create a report schedule |
| PATCH | `/v1/report-schedules/{id}` | reports:write | Update a report schedule |
| DELETE | `/v1/report-schedules/{id}` | reports:write | Delete a report schedule |
| POST | `/v1/report-schedules/{id}/run-now` | reports:write | Run a report schedule immediately |
| GET | `/v1/carbon/report` | sessions:read | Get sustainability report with monthly and site breakdowns |
| GET | `/v1/carbon/report/export` | sessions:read | Export sustainability report as CSV |
