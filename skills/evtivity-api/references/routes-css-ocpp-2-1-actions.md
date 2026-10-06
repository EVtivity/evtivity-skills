# EVtivity API routes: CSS OCPP 2.1 Actions

Generated from EVtivity CSMS v0.1.39-beta.2 (https://github.com/EVtivity/evtivity-csms, commit f3bd9ac5d1e8) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/css/actions/v21/sendBootNotification` | stations:write | Send BootNotification |
| POST | `/v1/css/actions/v21/sendHeartbeat` | stations:write | Send Heartbeat |
| POST | `/v1/css/actions/v21/sendStatusNotification` | stations:write | Send StatusNotification |
| POST | `/v1/css/actions/v21/sendMeterValues` | stations:write | Send MeterValues |
| POST | `/v1/css/actions/v21/sendAuthorize` | stations:write | Send Authorize request |
| POST | `/v1/css/actions/v21/sendFirmwareStatusNotification` | stations:write | Send FirmwareStatusNotification |
| POST | `/v1/css/actions/v21/sendDataTransfer` | stations:write | Send DataTransfer |
| POST | `/v1/css/actions/v21/sendTransactionEvent` | stations:write | Send TransactionEvent |
| POST | `/v1/css/actions/v21/sendLogStatusNotification` | stations:write | Send LogStatusNotification |
| POST | `/v1/css/actions/v21/sendSecurityEventNotification` | stations:write | Send SecurityEventNotification |
| POST | `/v1/css/actions/v21/sendNotifyEvent` | stations:write | Send NotifyEvent |
| POST | `/v1/css/actions/v21/sendNotifyReport` | stations:write | Send NotifyReport |
| POST | `/v1/css/actions/v21/sendNotifyMonitoringReport` | stations:write | Send NotifyMonitoringReport |
| POST | `/v1/css/actions/v21/sendNotifyChargingLimit` | stations:write | Send NotifyChargingLimit |
| POST | `/v1/css/actions/v21/sendNotifyEVChargingNeeds` | stations:write | Send NotifyEVChargingNeeds |
| POST | `/v1/css/actions/v21/sendClearedChargingLimit` | stations:write | Send ClearedChargingLimit |
| POST | `/v1/css/actions/v21/sendReservationStatusUpdate` | stations:write | Send ReservationStatusUpdate |
| POST | `/v1/css/actions/v21/sendNotifyDisplayMessages` | stations:write | Send NotifyDisplayMessages |
| POST | `/v1/css/actions/v21/sendNotifyCustomerInformation` | stations:write | Send NotifyCustomerInformation |
| POST | `/v1/css/actions/v21/sendSignCertificate` | stations:write | Send SignCertificate |
| POST | `/v1/css/actions/v21/sendGetCertificateStatus` | stations:write | Send GetCertificateStatus |
| POST | `/v1/css/actions/v21/sendGetTransactionStatus` | stations:write | Send GetTransactionStatus |
| POST | `/v1/css/actions/v21/sendReportChargingProfiles` | stations:write | Send ReportChargingProfiles |
| POST | `/v1/css/actions/v21/sendNotifyEVChargingSchedule` | stations:write | Send NotifyEVChargingSchedule |
| POST | `/v1/css/actions/v21/sendNotifySettlement` | stations:write | Send NotifySettlement |
| POST | `/v1/css/actions/v21/sendNotifyPriorityCharging` | stations:write | Send NotifyPriorityCharging |
| POST | `/v1/css/actions/v21/sendNotifyAllowedEnergyTransfer` | stations:write | Send NotifyAllowedEnergyTransfer |
| POST | `/v1/css/actions/v21/sendGet15118EVCertificate` | stations:write | Send Get15118EVCertificate |
| POST | `/v1/css/actions/v21/sendGetCertificateChainStatus` | stations:write | Send GetCertificateChainStatus |
| POST | `/v1/css/actions/v21/sendPublishFirmwareStatusNotification` | stations:write | Send PublishFirmwareStatusNotification |
| POST | `/v1/css/actions/v21/sendNotifyPeriodicEventStream` | stations:write | Send NotifyPeriodicEventStream |
| POST | `/v1/css/actions/v21/sendNotifyDERAlarm` | stations:write | Send NotifyDERAlarm |
| POST | `/v1/css/actions/v21/sendNotifyDERStartStop` | stations:write | Send NotifyDERStartStop |
| POST | `/v1/css/actions/v21/sendReportDERControl` | stations:write | Send ReportDERControl |
| POST | `/v1/css/actions/v21/sendBatterySwap` | stations:write | Send BatterySwap |
| POST | `/v1/css/actions/v21/sendPullDynamicScheduleUpdate` | stations:write | Send PullDynamicScheduleUpdate |
| POST | `/v1/css/actions/v21/sendVatNumberValidation` | stations:write | Send VatNumberValidation |
