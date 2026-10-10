# EVtivity API routes: OCPP 1.6 Commands

Generated from EVtivity CSMS v0.1.43 (https://github.com/EVtivity/evtivity-csms, commit 94253c800a66) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/ocpp/commands/v16/RemoteStartTransaction` | stations:write | Remote start a transaction |
| POST | `/v1/ocpp/commands/v16/RemoteStopTransaction` | stations:write | Remote stop a transaction |
| POST | `/v1/ocpp/commands/v16/Reset` | stations:write | Reset a station |
| POST | `/v1/ocpp/commands/v16/ChangeAvailability` | stations:write | Change connector availability |
| POST | `/v1/ocpp/commands/v16/UnlockConnector` | stations:write | Unlock a connector |
| POST | `/v1/ocpp/commands/v16/TriggerMessage` | stations:write | Trigger a message from station |
| POST | `/v1/ocpp/commands/v16/GetLocalListVersion` | stations:write | Get local authorization list version |
| POST | `/v1/ocpp/commands/v16/SendLocalList` | stations:write | Send local authorization list |
| POST | `/v1/ocpp/commands/v16/SetChargingProfile` | stations:write | Set a charging profile |
| POST | `/v1/ocpp/commands/v16/ClearChargingProfile` | stations:write | Clear charging profiles |
| POST | `/v1/ocpp/commands/v16/GetCompositeSchedule` | stations:write | Get composite charging schedule |
| POST | `/v1/ocpp/commands/v16/ClearCache` | stations:write | Clear authorization cache |
| POST | `/v1/ocpp/commands/v16/UpdateFirmware` | stations:write | Update station firmware |
| POST | `/v1/ocpp/commands/v16/ReserveNow` | stations:write | Create a reservation |
| POST | `/v1/ocpp/commands/v16/CancelReservation` | stations:write | Cancel a reservation |
| POST | `/v1/ocpp/commands/v16/DataTransfer` | stations:write | Send a vendor-specific data transfer |
| POST | `/v1/ocpp/commands/v16/GetConfiguration` | stations:write | Get station configuration keys |
| POST | `/v1/ocpp/commands/v16/ChangeConfiguration` | stations:write | Change a station configuration key |
| POST | `/v1/ocpp/commands/v16/GetDiagnostics` | stations:write | Request diagnostics upload |
| POST | `/v1/ocpp/commands/v16/SignedUpdateFirmware` | stations:write | Update firmware with signature verification |
| POST | `/v1/ocpp/commands/v16/ExtendedTriggerMessage` | stations:write | Trigger an extended message from station |
| POST | `/v1/ocpp/commands/v16/CertificateSigned` | stations:write | Send signed certificate to station |
| POST | `/v1/ocpp/commands/v16/InstallCertificate` | stations:write | Install a CA certificate on station |
| POST | `/v1/ocpp/commands/v16/DeleteCertificate` | stations:write | Delete a certificate from station |
| POST | `/v1/ocpp/commands/v16/GetInstalledCertificateIds` | stations:write | Query installed certificate IDs |
| POST | `/v1/ocpp/commands/v16/GetLog` | stations:write | Request log upload from station |
| GET | `/v1/ocpp/commands/v16/{action}/schema` | stations:write | Get processed schema for an OCPP 1.6 command |
