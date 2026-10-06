# EVtivity API route catalog

Generated from EVtivity CSMS v0.1.39-beta.2 (https://github.com/EVtivity/evtivity-csms, commit f3bd9ac5d1e8) by `scripts/generate-api-reference.py`. Do not edit by hand.

One file per API tag. Find a route without reading every file:
`grep -n '<path or word>' references/routes-*.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Tag | Routes | File |
|---|---|---|
| Health | 2 | `references/routes-health.md` |
| Sites | 29 | `references/routes-sites.md` |
| Stations | 68 | `references/routes-stations.md` |
| Sessions | 5 | `references/routes-sessions.md` |
| Users | 36 | `references/routes-users.md` |
| Drivers | 23 | `references/routes-drivers.md` |
| Pricing | 19 | `references/routes-pricing.md` |
| OCPP 2.1 Commands | 57 | `references/routes-ocpp-2-1-commands.md` |
| OCPP 1.6 Commands | 27 | `references/routes-ocpp-1-6-commands.md` |
| OCPP | 1 | `references/routes-ocpp.md` |
| Transactions | 3 | `references/routes-transactions.md` |
| Fleets | 23 | `references/routes-fleets.md` |
| Tokens | 12 | `references/routes-tokens.md` |
| Dashboard | 16 | `references/routes-dashboard.md` |
| Settings | 28 | `references/routes-settings.md` |
| Payments | 38 | `references/routes-payments.md` |
| Events | 1 | `references/routes-events.md` |
| Load Management | 18 | `references/routes-load-management.md` |
| Notifications | 15 | `references/routes-notifications.md` |
| Reservations | 9 | `references/routes-reservations.md` |
| Maintenance | 11 | `references/routes-maintenance.md` |
| Portal Auth | 14 | `references/routes-portal-auth.md` |
| Portal Driver | 16 | `references/routes-portal-driver.md` |
| Portal Payments | 9 | `references/routes-portal-payments.md` |
| Portal Sessions | 7 | `references/routes-portal-sessions.md` |
| Portal Chargers | 19 | `references/routes-portal-chargers.md` |
| Portal Guest | 9 | `references/routes-portal-guest.md` |
| Portal Payout Onboarding | 2 | `references/routes-portal-payout-onboarding.md` |
| Access Logs | 3 | `references/routes-access-logs.md` |
| Portal Access Logs | 1 | `references/routes-portal-access-logs.md` |
| Display Messages | 4 | `references/routes-display-messages.md` |
| Reports | 12 | `references/routes-reports.md` |
| NEVI | 6 | `references/routes-nevi.md` |
| Webhooks | 2 | `references/routes-webhooks.md` |
| Invoices | 9 | `references/routes-invoices.md` |
| Support Cases | 14 | `references/routes-support-cases.md` |
| Portal Vehicles | 5 | `references/routes-portal-vehicles.md` |
| Portal Tokens | 4 | `references/routes-portal-tokens.md` |
| Portal Notifications | 5 | `references/routes-portal-notifications.md` |
| Portal Support | 7 | `references/routes-portal-support.md` |
| Portal Roaming | 2 | `references/routes-portal-roaming.md` |
| Portal Events | 1 | `references/routes-portal-events.md` |
| OCPI | 20 | `references/routes-ocpi.md` |
| PnC | 13 | `references/routes-pnc.md` |
| Local Auth List | 5 | `references/routes-local-auth-list.md` |
| Fleet Operations | 21 | `references/routes-fleet-operations.md` |
| Event Alert Rules | 4 | `references/routes-event-alert-rules.md` |
| API Keys | 4 | `references/routes-api-keys.md` |
| CSS Management | 7 | `references/routes-css-management.md` |
| CSS Actions | 9 | `references/routes-css-actions.md` |
| CSS OCPP 1.6 Actions | 10 | `references/routes-css-ocpp-1-6-actions.md` |
| CSS OCPP 2.1 Actions | 37 | `references/routes-css-ocpp-2-1-actions.md` |
| Smart Charging | 12 | `references/routes-smart-charging.md` |
| AI Assistant | 1 | `references/routes-ai-assistant.md` |
| OCTT | 4 | `references/routes-octt.md` |
| Audit | 2 | `references/routes-audit.md` |
| Conformance | 1 | `references/routes-conformance.md` |
