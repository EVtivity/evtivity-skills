# EVtivity API routes: CSS OCPP 1.6 Actions

Generated from EVtivity CSMS v0.1.42-beta.1 (https://github.com/EVtivity/evtivity-csms, commit 34bf507e0fc3) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/css/actions/v16/sendBootNotification` | stations:write | Send BootNotification |
| POST | `/v1/css/actions/v16/sendHeartbeat` | stations:write | Send Heartbeat |
| POST | `/v1/css/actions/v16/sendStatusNotification` | stations:write | Send StatusNotification |
| POST | `/v1/css/actions/v16/sendMeterValues` | stations:write | Send MeterValues |
| POST | `/v1/css/actions/v16/sendAuthorize` | stations:write | Send Authorize request |
| POST | `/v1/css/actions/v16/sendFirmwareStatusNotification` | stations:write | Send FirmwareStatusNotification |
| POST | `/v1/css/actions/v16/sendDataTransfer` | stations:write | Send DataTransfer |
| POST | `/v1/css/actions/v16/sendStartTransaction` | stations:write | Send StartTransaction |
| POST | `/v1/css/actions/v16/sendStopTransaction` | stations:write | Send StopTransaction |
| POST | `/v1/css/actions/v16/sendDiagnosticsStatusNotification` | stations:write | Send DiagnosticsStatusNotification |
