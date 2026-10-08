# EVtivity API routes: CSS Actions

Generated from EVtivity CSMS v0.1.42-beta.1 (https://github.com/EVtivity/evtivity-csms, commit 34bf507e0fc3) by `scripts/generate-api-reference.py`. Do not edit by hand.
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
| POST | `/v1/css/actions/suspendCharging` | stations:write | Suspend the energy transfer (EV or EVSE) |
| POST | `/v1/css/actions/resumeCharging` | stations:write | Resume the energy transfer |
| POST | `/v1/css/actions/evFull` | stations:write | EV battery full: suspend, then end |
| POST | `/v1/css/actions/powerCycle` | stations:write | Power cycle the station |
| POST | `/v1/css/actions/goOffline` | stations:write | Disconnect station from OCPP server, keeping its transactions and queueing their messages |
| POST | `/v1/css/actions/comeOnline` | stations:write | Reconnect station to OCPP server without a reboot: reports connector statuses and replays queued transaction messages |
