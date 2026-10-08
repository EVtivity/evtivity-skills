# EVtivity API routes: CSS Actions

Generated from EVtivity CSMS v0.1.41-alpha.6 (https://github.com/EVtivity/evtivity-csms, commit d149789379d5) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/css/actions/plugIn` | stations:write | Plug in charging cable |
| POST | `/v1/css/actions/authorize` | stations:write | Authorize with token |
| POST | `/v1/css/actions/startCharging` | stations:write | Start a charging session |
| POST | `/v1/css/actions/stopCharging` | stations:write | Stop a charging session |
| POST | `/v1/css/actions/unplug` | stations:write | Unplug charging cable |
| POST | `/v1/css/actions/injectFault` | stations:write | Inject a fault on an EVSE |
| POST | `/v1/css/actions/clearFault` | stations:write | Clear a fault on an EVSE |
| POST | `/v1/css/actions/goOffline` | stations:write | Disconnect station from OCPP server |
| POST | `/v1/css/actions/comeOnline` | stations:write | Reconnect station to OCPP server |
