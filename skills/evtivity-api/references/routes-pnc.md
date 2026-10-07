# EVtivity API routes: PnC

Generated from EVtivity CSMS v0.1.40 (https://github.com/EVtivity/evtivity-csms, commit 571bdc26947f) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/pnc/settings` | settings.integrations:read | Get Plug and Charge settings |
| PUT | `/v1/pnc/settings` | settings.integrations:write | Update Plug and Charge settings |
| POST | `/v1/pnc/settings/test-provider` | settings.integrations:write | Test PnC provider connectivity |
| GET | `/v1/pnc/ca-certificates` | certificates:read | List CA certificates |
| POST | `/v1/pnc/ca-certificates` | certificates:write | Upload a CA certificate |
| DELETE | `/v1/pnc/ca-certificates/{id}` | certificates:write | Delete a CA certificate |
| GET | `/v1/pnc/csr-requests` | certificates:read | List CSR requests |
| POST | `/v1/pnc/csr-requests/{id}/sign` | certificates:write | Sign a pending CSR request |
| POST | `/v1/pnc/csr-requests/{id}/reject` | certificates:write | Reject a pending CSR request |
| GET | `/v1/pnc/station-certificates` | certificates:read | List station certificates |
| POST | `/v1/pnc/refresh-root-certificates` | certificates:write | Refresh root certificates from provider |
| GET | `/v1/pnc/settings/local-ca` | settings.integrations:read | Get the local contract CA |
| POST | `/v1/pnc/settings/local-ca` | settings.integrations:write | Create the local contract CA |
