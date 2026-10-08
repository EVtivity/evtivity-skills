# EVtivity API routes: OCTT

Generated from EVtivity CSMS v0.1.42-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 627b28b192ed) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/octt/runs` | conformance:read | List conformance test runs |
| POST | `/v1/octt/runs` | conformance:write | Trigger a conformance test run |
| GET | `/v1/octt/runs/{id}` | conformance:read | Get conformance test run detail |
| GET | `/v1/octt/runs/{id}/summary` | conformance:read | Get per-module summary for a test run |
