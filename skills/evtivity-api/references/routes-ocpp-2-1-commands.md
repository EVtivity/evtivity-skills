# EVtivity API routes: OCPP 2.1 Commands

Generated from EVtivity CSMS v0.1.39-beta.1 (https://github.com/EVtivity/evtivity-csms, commit bd06577f1cf1) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/ocpp/commands/v21/Reset` | stations:write | Reset a station |
| POST | `/v1/ocpp/commands/v21/RequestStartTransaction` | stations:write | Request to start a transaction |
| POST | `/v1/ocpp/commands/v21/RequestStopTransaction` | stations:write | Request to stop a transaction |
| POST | `/v1/ocpp/commands/v21/GetTransactionStatus` | stations:write | Get status of a transaction |
| POST | `/v1/ocpp/commands/v21/ChangeAvailability` | stations:write | Change station or EVSE availability |
| POST | `/v1/ocpp/commands/v21/UnlockConnector` | stations:write | Unlock a connector |
| POST | `/v1/ocpp/commands/v21/TriggerMessage` | stations:write | Trigger a message from station |
| POST | `/v1/ocpp/commands/v21/GetLocalListVersion` | stations:write | Get local authorization list version |
| POST | `/v1/ocpp/commands/v21/SendLocalList` | stations:write | Send local authorization list |
| POST | `/v1/ocpp/commands/v21/SetChargingProfile` | stations:write | Set a charging profile |
| POST | `/v1/ocpp/commands/v21/ClearChargingProfile` | stations:write | Clear charging profiles |
| POST | `/v1/ocpp/commands/v21/GetChargingProfiles` | stations:write | Get charging profiles from station |
| POST | `/v1/ocpp/commands/v21/GetCompositeSchedule` | stations:write | Get composite charging schedule |
| POST | `/v1/ocpp/commands/v21/ClearCache` | stations:write | Clear authorization cache |
| POST | `/v1/ocpp/commands/v21/UpdateFirmware` | stations:write | Update station firmware |
| POST | `/v1/ocpp/commands/v21/ReserveNow` | stations:write | Create a reservation |
| POST | `/v1/ocpp/commands/v21/CancelReservation` | stations:write | Cancel a reservation |
| POST | `/v1/ocpp/commands/v21/DataTransfer` | stations:write | Send a vendor-specific data transfer |
| POST | `/v1/ocpp/commands/v21/GetVariables` | stations:write | Get station variables |
| POST | `/v1/ocpp/commands/v21/SetVariables` | stations:write | Set station variables |
| POST | `/v1/ocpp/commands/v21/GetLog` | stations:write | Request log upload from station |
| POST | `/v1/ocpp/commands/v21/CertificateSigned` | stations:write | Send signed certificate to station |
| POST | `/v1/ocpp/commands/v21/InstallCertificate` | stations:write | Install a CA certificate on station |
| POST | `/v1/ocpp/commands/v21/DeleteCertificate` | stations:write | Delete a certificate from station |
| POST | `/v1/ocpp/commands/v21/GetInstalledCertificateIds` | stations:write | Query installed certificate IDs |
| POST | `/v1/ocpp/commands/v21/GetBaseReport` | stations:write | Get base report from station |
| POST | `/v1/ocpp/commands/v21/GetReport` | stations:write | Get detailed report from station |
| POST | `/v1/ocpp/commands/v21/SetMonitoringBase` | stations:write | Set monitoring base configuration |
| POST | `/v1/ocpp/commands/v21/SetMonitoringLevel` | stations:write | Set monitoring severity level |
| POST | `/v1/ocpp/commands/v21/SetVariableMonitoring` | stations:write | Set variable monitoring rules |
| POST | `/v1/ocpp/commands/v21/ClearVariableMonitoring` | stations:write | Clear variable monitoring rules |
| POST | `/v1/ocpp/commands/v21/GetMonitoringReport` | stations:write | Get monitoring report |
| POST | `/v1/ocpp/commands/v21/SetNetworkProfile` | stations:write | Set network connection profile |
| POST | `/v1/ocpp/commands/v21/SetDisplayMessage` | stations:write | Set a display message on station |
| POST | `/v1/ocpp/commands/v21/GetDisplayMessages` | stations:write | Get display messages from station |
| POST | `/v1/ocpp/commands/v21/ClearDisplayMessage` | stations:write | Clear a display message |
| POST | `/v1/ocpp/commands/v21/SetDefaultTariff` | stations:write | Set default tariff on station |
| POST | `/v1/ocpp/commands/v21/GetTariffs` | stations:write | Get tariffs from station |
| POST | `/v1/ocpp/commands/v21/ClearTariffs` | stations:write | Clear tariffs from station |
| POST | `/v1/ocpp/commands/v21/ChangeTransactionTariff` | stations:write | Change tariff for active transaction |
| POST | `/v1/ocpp/commands/v21/CustomerInformation` | stations:write | Request or clear customer information |
| POST | `/v1/ocpp/commands/v21/CostUpdated` | stations:write | Send updated cost to station |
| POST | `/v1/ocpp/commands/v21/UsePriorityCharging` | stations:write | Activate or deactivate priority charging |
| POST | `/v1/ocpp/commands/v21/UpdateDynamicSchedule` | stations:write | Update dynamic charging schedule |
| POST | `/v1/ocpp/commands/v21/PublishFirmware` | stations:write | Publish firmware to local controller |
| POST | `/v1/ocpp/commands/v21/UnpublishFirmware` | stations:write | Unpublish firmware from local controller |
| POST | `/v1/ocpp/commands/v21/AFRRSignal` | stations:write | Send AFRR signal to station |
| POST | `/v1/ocpp/commands/v21/SetDERControl` | stations:write | Set DER control on station |
| POST | `/v1/ocpp/commands/v21/GetDERControl` | stations:write | Get DER control settings from station |
| POST | `/v1/ocpp/commands/v21/ClearDERControl` | stations:write | Clear DER control settings |
| POST | `/v1/ocpp/commands/v21/OpenPeriodicEventStream` | stations:write | Open periodic event stream |
| POST | `/v1/ocpp/commands/v21/ClosePeriodicEventStream` | stations:write | Close periodic event stream |
| POST | `/v1/ocpp/commands/v21/AdjustPeriodicEventStream` | stations:write | Adjust periodic event stream |
| POST | `/v1/ocpp/commands/v21/GetPeriodicEventStream` | stations:write | Get periodic event streams |
| POST | `/v1/ocpp/commands/v21/RequestBatterySwap` | stations:write | Request battery swap |
| POST | `/v1/ocpp/commands/v21/VatNumberValidation` | stations:write | Validate VAT number |
| GET | `/v1/ocpp/commands/v21/{action}/schema` | stations:write | Get processed schema for an OCPP 2.1 command |
