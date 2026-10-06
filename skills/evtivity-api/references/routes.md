# EVtivity API route catalog

Generated from the public OpenAPI spec (https://www.evtivity.com/openapi.json, spec version 2.0.0) by
`scripts/generate-api-reference.py`. Do not edit by hand.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

## Tags

- [Health](#health) (2)
- [Sites](#sites) (29)
- [Stations](#stations) (68)
- [Sessions](#sessions) (5)
- [Users](#users) (36)
- [Drivers](#drivers) (23)
- [Pricing](#pricing) (19)
- [OCPP 2.1 Commands](#ocpp-21-commands) (57)
- [OCPP 1.6 Commands](#ocpp-16-commands) (27)
- [OCPP](#ocpp) (1)
- [Transactions](#transactions) (3)
- [Fleets](#fleets) (23)
- [Tokens](#tokens) (12)
- [Dashboard](#dashboard) (16)
- [Settings](#settings) (28)
- [Payments](#payments) (38)
- [Events](#events) (1)
- [Load Management](#load-management) (18)
- [Notifications](#notifications) (15)
- [Reservations](#reservations) (9)
- [Maintenance](#maintenance) (11)
- [Portal Auth](#portal-auth) (14)
- [Portal Driver](#portal-driver) (16)
- [Portal Payments](#portal-payments) (9)
- [Portal Sessions](#portal-sessions) (7)
- [Portal Chargers](#portal-chargers) (19)
- [Portal Guest](#portal-guest) (9)
- [Portal Payout Onboarding](#portal-payout-onboarding) (2)
- [Access Logs](#access-logs) (3)
- [Portal Access Logs](#portal-access-logs) (1)
- [Display Messages](#display-messages) (4)
- [Reports](#reports) (12)
- [NEVI](#nevi) (6)
- [Webhooks](#webhooks) (2)
- [Invoices](#invoices) (9)
- [Support Cases](#support-cases) (14)
- [Portal Vehicles](#portal-vehicles) (5)
- [Portal Tokens](#portal-tokens) (4)
- [Portal Notifications](#portal-notifications) (5)
- [Portal Support](#portal-support) (7)
- [Portal Roaming](#portal-roaming) (2)
- [Portal Events](#portal-events) (1)
- [OCPI](#ocpi) (20)
- [PnC](#pnc) (13)
- [Local Auth List](#local-auth-list) (5)
- [Fleet Operations](#fleet-operations) (21)
- [Event Alert Rules](#event-alert-rules) (4)
- [API Keys](#api-keys) (4)
- [CSS Management](#css-management) (7)
- [CSS Actions](#css-actions) (9)
- [CSS OCPP 1.6 Actions](#css-ocpp-16-actions) (10)
- [CSS OCPP 2.1 Actions](#css-ocpp-21-actions) (37)
- [Smart Charging](#smart-charging) (12)
- [AI Assistant](#ai-assistant) (1)
- [OCTT](#octt) (4)
- [Audit](#audit) (2)
- [Conformance](#conformance) (1)

## Health

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/health` | public | Check API, database, and Redis health |
| GET | `/v1/version` | public | Get the CSMS backend version |

## Sites

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites` | sites:read | List all sites |
| POST | `/v1/sites` | sites:write | Create a new site |
| GET | `/v1/sites/filter-options` | sites:read | Get distinct filter values for sites |
| GET | `/v1/sites/export` | sites:read | Export sites as CSV |
| GET | `/v1/sites/export/template` | sites:read | Download site import CSV template |
| POST | `/v1/sites/import` | sites:write | Import sites from parsed CSV rows |
| GET | `/v1/sites/{id}` | sites:read | Get a site by ID |
| PATCH | `/v1/sites/{id}` | sites:write | Update a site |
| DELETE | `/v1/sites/{id}` | sites:write | Delete a site |
| GET | `/v1/sites/{id}/metrics` | sites:read | Get performance metrics for a site |
| GET | `/v1/sites/{id}/stations` | sites:read | List stations at a site |
| GET | `/v1/sites/{id}/energy-history` | sites:read | Get daily energy delivery history for a site |
| GET | `/v1/sites/{id}/revenue-history` | sites:read | Get daily revenue history for a site |
| GET | `/v1/sites/{id}/popular-times` | sites:read | Get average session count by day-of-week and hour for a site |
| GET | `/v1/sites/{id}/meter-values` | sites:read | Get meter value time series for a site |
| GET | `/v1/sites/{id}/sessions` | sites:read | List charging sessions at a site |
| GET | `/v1/sites/{id}/layout` | sites:read | Get station layout positions for a site |
| PUT | `/v1/sites/{id}/layout` | sites:write | Update station layout positions for a site |
| GET | `/v1/sites/{id}/pricing-groups` | sites:read | Get the pricing group for a site |
| POST | `/v1/sites/{id}/pricing-groups` | sites:write | Assign a pricing group to a site |
| DELETE | `/v1/sites/{id}/pricing-groups/{pricingGroupId}` | sites:write | Remove a pricing group from a site |
| POST | `/v1/sites/{id}/free-vend` | sites:write | Toggle free vend mode for a site |
| GET | `/v1/sites/{id}/carbon-region` | sites:read | Get carbon region for a site |
| PUT | `/v1/sites/{id}/carbon-region` | sites:write | Set carbon region for a site |
| GET | `/v1/sites/{id}/electricity-rates` | sites:read | List electricity rate periods for a site |
| POST | `/v1/sites/{id}/electricity-rates` | sites:write | Create an electricity rate period for a site |
| PATCH | `/v1/sites/{id}/electricity-rates/{periodId}` | sites:write | Update an electricity rate period |
| DELETE | `/v1/sites/{id}/electricity-rates/{periodId}` | sites:write | Delete an electricity rate period |
| GET | `/v1/sites/{id}/neighbors` | sites:read | Get previous and next entity IDs in default list order |

## Stations

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/stations` | stations:read | List all stations |
| POST | `/v1/stations` | stations:write | Create a new station |
| GET | `/v1/stations/{id}` | stations:read | Get a station by ID |
| PATCH | `/v1/stations/{id}` | stations:write | Update a station |
| DELETE | `/v1/stations/{id}` | stations:write | Delete a station (marks as removed) |
| POST | `/v1/stations/{id}/configurations/refresh` | stations:write | Refresh station configurations from the station via OCPP |
| GET | `/v1/stations/{id}/connectors` | stations:read | List EVSEs and connectors for a station |
| POST | `/v1/stations/{id}/evses` | stations:write | Add an EVSE with connectors to a station |
| PATCH | `/v1/stations/{id}/evses/{evseId}` | stations:write | Update connectors on an EVSE |
| DELETE | `/v1/stations/{id}/evses/{evseId}` | stations:write | Delete an EVSE and all its connectors |
| POST | `/v1/stations/{id}/evses/{evseId}/refresh-status` | stations:read | Force the station to re-report this EVSE's connector status |
| POST | `/v1/stations/{id}/evses/{evseId}/stop-active-session` | stations:write | Force-stop the active charging session on this EVSE |
| POST | `/v1/stations/{id}/evses/{evseId}/connectors` | stations:write | Add a connector to an EVSE |
| DELETE | `/v1/stations/{id}/evses/{evseId}/connectors/{connectorId}` | stations:write | Delete a connector from an EVSE |
| GET | `/v1/stations/{id}/meter-values` | stations:read | Get meter value time series for a station |
| GET | `/v1/stations/{id}/energy-history` | stations:read | Get daily energy delivery history for a station |
| GET | `/v1/stations/{id}/revenue-history` | stations:read | Get daily revenue history for a station |
| GET | `/v1/stations/{id}/uptime-history` | stations:read | Get daily uptime percentage history for a station |
| GET | `/v1/stations/{id}/popular-times` | stations:read | Get average session count by day-of-week and hour for a station |
| GET | `/v1/stations/{id}/metrics` | stations:read | Get performance metrics for a station |
| GET | `/v1/stations/{id}/sessions` | stations:read | List charging sessions for a station |
| GET | `/v1/stations/{id}/ocpp-logs` | stations:read | Get OCPP message logs for a station |
| POST | `/v1/stations/{id}/credentials` | stations:write | Set or update station Basic Auth password |
| POST | `/v1/stations/{id}/rotate-credentials` | stations:write | Rotate station Basic Auth password via OCPP |
| POST | `/v1/stations/{id}/confirm-real-station` | stations:write | Confirm that a real station uses a simulator-flagged station identity |
| GET | `/v1/stations/{id}/security-logs` | stations:read | Get security event logs for a station |
| GET | `/v1/stations/{id}/certificates` | stations:read | List certificates for a station |
| POST | `/v1/stations/{id}/certificates/install` | stations:write | Install a certificate on a station |
| POST | `/v1/stations/{id}/certificates/delete` | stations:write | Delete a certificate from a station |
| POST | `/v1/stations/{id}/certificates/query` | stations:write | Query installed certificate IDs from a station |
| GET | `/v1/stations/{id}/pricing-groups` | stations:read | Get the pricing group for a station |
| POST | `/v1/stations/{id}/pricing-groups` | stations:write | Assign a pricing group to a station |
| DELETE | `/v1/stations/{id}/pricing-groups/{pricingGroupId}` | stations:write | Remove a pricing group from a station |
| POST | `/v1/stations/{id}/approve` | stations:write | Approve a pending station |
| POST | `/v1/stations/{id}/unblock` | stations:write | Unblock a station (sets status to pending) |
| POST | `/v1/stations/{id}/reject` | stations:write | Reject a pending station |
| GET | `/v1/stations/{id}/security-events` | stations:read | List security events for a station |
| GET | `/v1/stations/{id}/events` | stations:read | List OCPP events for a station |
| GET | `/v1/stations/{id}/variables` | stations:read | List reported variables for a station |
| GET | `/v1/stations/{id}/firmware-history` | stations:read | List firmware update history for a station |
| GET | `/v1/stations/{id}/charging-profiles` | stations:read | List charging profiles for a station |
| POST | `/v1/stations/{id}/charging-profiles/refresh` | stations:write | Refresh charging profiles from the station via OCPP GetChargingProfiles |
| POST | `/v1/stations/{id}/charging-profiles/composite` | stations:write | Get composite charging schedule from the station |
| POST | `/v1/stations/{id}/charging-profiles/clear` | stations:write | Clear charging profiles from the station |
| POST | `/v1/stations/{id}/charging-profiles/push` | stations:write | Push a charging profile template to this station |
| POST | `/v1/stations/{id}/configurations/push` | stations:write | Push a configuration template to this station |
| GET | `/v1/stations/{id}/ev-charging-needs` | stations:read | List EV charging needs for a station |
| GET | `/v1/stations/{id}/monitoring-rules` | stations:read | List variable monitoring rules for a station |
| POST | `/v1/stations/{id}/monitoring-rules` | stations:write | Create a variable monitoring rule and dispatch SetVariableMonitoring |
| DELETE | `/v1/stations/{id}/monitoring-rules/{ruleId}` | stations:write | Delete a variable monitoring rule and dispatch ClearVariableMonitoring |
| GET | `/v1/stations/{id}/event-alerts` | stations:read | List event alerts for a station |
| POST | `/v1/stations/{id}/event-alerts/{alertId}/acknowledge` | stations:write | Acknowledge an event alert |
| GET | `/v1/stations/{id}/standalone-meter-values` | stations:read | List standalone meter values for a station |
| GET | `/v1/stations/{id}/web-payments` | stations:read | Get the dynamic QR code payment configuration of a station |
| PUT | `/v1/stations/{id}/web-payments` | stations:write | Enable dynamic QR code payments on a station |
| DELETE | `/v1/stations/{id}/web-payments` | stations:write | Disable dynamic QR code payments on a station |
| GET | `/v1/stations/{id}/images` | stations:read | List all images for a station |
| POST | `/v1/stations/{id}/images` | stations:write | Confirm a station image upload after S3 PUT |
| POST | `/v1/stations/{id}/images/upload-url` | stations:write | Get a presigned S3 upload URL for a station image |
| PATCH | `/v1/stations/{id}/images/{imageId}` | stations:write | Update station image metadata |
| DELETE | `/v1/stations/{id}/images/{imageId}` | stations:write | Delete a station image |
| GET | `/v1/stations/{id}/images/{imageId}/download-url` | stations:read | Get a presigned download URL for a station image |
| PATCH | `/v1/stations/{id}/images/reorder` | stations:write | Reorder station images |
| POST | `/v1/stations/{id}/images/{imageId}/set-main` | stations:write | Set an image as the main station image |
| GET | `/v1/stations/{id}/neighbors` | stations:read | Get previous and next entity IDs in default list order |
| GET | `/v1/config-templates/{id}/neighbors` | settings.stationConfig:read | Get previous and next entity IDs in default list order |
| GET | `/v1/smart-charging/templates/{id}/neighbors` | smartCharging:read | Get previous and next entity IDs in default list order |
| GET | `/v1/firmware-campaigns/{id}/neighbors` | settings.firmware:read | Get previous and next entity IDs in default list order |

## Sessions

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sessions` | sessions:read | List charging sessions |
| GET | `/v1/sessions/{id}` | sessions:read | Get charging session details |
| GET | `/v1/sessions/{id}/transaction-events` | sessions:read | List transaction events for a charging session |
| GET | `/v1/sessions/{id}/meter-values` | sessions:read | List meter values for a charging session |
| GET | `/v1/sessions/{id}/neighbors` | sessions:read | Get previous and next entity IDs in default list order |

## Users

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/auth/login` | public | Authenticate a user and return a JWT |
| POST | `/v1/auth/logout` |  | Logout and clear auth cookies |
| POST | `/v1/auth/refresh` | public | Refresh access token using refresh token cookie |
| POST | `/v1/auth/forgot-password` | public | Request a password reset email |
| POST | `/v1/auth/reset-password` | public | Reset password using a token from the reset email |
| POST | `/v1/auth/force-change-password` | public | Change password for a user that has mustResetPassword set |
| GET | `/v1/users/me` | users:read | Get the currently authenticated user |
| PATCH | `/v1/users/me` |  | Update the authenticated user's own profile fields |
| GET | `/v1/users` | users:read | List all users with pagination |
| POST | `/v1/users` | users:write | Create a new user |
| GET | `/v1/users/{id}` | users:read | Get a user by ID |
| PATCH | `/v1/users/{id}` | users:write | Update a user by ID |
| DELETE | `/v1/users/{id}` | users:write | Deactivate a user by ID |
| POST | `/v1/users/{id}/reset-password` | users:write | Reset a user password by admin |
| POST | `/v1/users/me/change-password` |  | Change the current user password |
| POST | `/v1/users/{id}/resend-invite` | users:write | Resend account setup invitation to a user |
| GET | `/v1/roles` | users:read | List all available roles |
| POST | `/v1/auth/mfa/verify` | public | Verify MFA code and complete login |
| POST | `/v1/auth/mfa/resend` | public | Resend MFA verification code |
| GET | `/v1/users/me/mfa` | users:read | Get current MFA status |
| DELETE | `/v1/users/me/mfa` |  | Disable MFA |
| POST | `/v1/users/me/mfa/setup` |  | Start MFA setup |
| POST | `/v1/users/me/mfa/confirm` |  | Confirm MFA setup with verification code |
| GET | `/v1/users/me/notification-preferences` |  | Get operator notification preferences |
| PUT | `/v1/users/me/notification-preferences` |  | Update operator notification preferences |
| GET | `/v1/users/me/chatbot-ai-config` |  | Get personal AI configuration |
| PUT | `/v1/users/me/chatbot-ai-config` |  | Create or update personal AI configuration |
| DELETE | `/v1/users/me/chatbot-ai-config` |  | Delete personal AI configuration |
| GET | `/v1/users/me/support-ai-config` |  | Get personal support AI configuration |
| PUT | `/v1/users/me/support-ai-config` |  | Create or update personal support AI configuration |
| DELETE | `/v1/users/me/support-ai-config` |  | Delete personal support AI configuration |
| GET | `/v1/permissions` | users:read | Get the permission catalog with groups |
| GET | `/v1/users/me/permissions` | users:read | Get current user permissions |
| GET | `/v1/users/{id}/permissions` | users:read | Get a user permissions by user ID |
| PUT | `/v1/users/{id}/permissions` | users:write | Replace a user permissions |
| GET | `/v1/users/{id}/neighbors` | users:read | Get previous and next entity IDs in default list order |

## Drivers

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/drivers` | drivers:read | List all drivers with pagination |
| POST | `/v1/drivers` | drivers:write | Create a new driver |
| GET | `/v1/drivers/{id}` | drivers:read | Get a driver by ID |
| PATCH | `/v1/drivers/{id}` | drivers:write | Update a driver by ID |
| DELETE | `/v1/drivers/{id}` | drivers:write | Deactivate a driver by ID |
| POST | `/v1/drivers/{id}/portal-invite` | drivers:write | Invite a driver to the driver portal |
| GET | `/v1/drivers/{id}/tokens` | drivers:read | List tokens for a driver |
| POST | `/v1/drivers/{id}/tokens` | drivers:write | Create a token for a driver |
| GET | `/v1/drivers/{id}/vehicles` | drivers:read | List vehicles for a driver |
| POST | `/v1/drivers/{id}/vehicles` | drivers:write | Create a vehicle for a driver |
| GET | `/v1/drivers/{id}/vehicles/{vehicleId}` | drivers:read | Get a single vehicle for a driver |
| PATCH | `/v1/drivers/{id}/vehicles/{vehicleId}` | drivers:write | Update a vehicle |
| DELETE | `/v1/drivers/{id}/vehicles/{vehicleId}` | drivers:write | Delete a vehicle |
| GET | `/v1/vehicles/lookup` | drivers:read | List known vehicle makes and models for autocomplete |
| GET | `/v1/drivers/{id}/sessions` | drivers:read | List charging sessions for a driver |
| GET | `/v1/drivers/{id}/reservations` | drivers:read | List reservations for a driver, with cancel metadata |
| GET | `/v1/drivers/{id}/pricing-groups` | drivers:read | Get the pricing group for a driver |
| POST | `/v1/drivers/{id}/pricing-groups` | drivers:write | Assign a pricing group to a driver |
| DELETE | `/v1/drivers/{id}/pricing-groups/{pricingGroupId}` | drivers:write | Remove a pricing group from a driver |
| GET | `/v1/drivers/{id}/pnc-contracts` | drivers:read | List the Plug and Charge contracts of a driver |
| POST | `/v1/drivers/{id}/pnc-contracts` | drivers:write | Create a Plug and Charge contract for a driver |
| POST | `/v1/drivers/{id}/pnc-contracts/{contractId}/revoke` | drivers:write | Revoke a Plug and Charge contract |
| GET | `/v1/drivers/{id}/neighbors` | drivers:read | Get previous and next entity IDs in default list order |

## Pricing

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/pricing-groups` | pricing:read | List all pricing groups |
| POST | `/v1/pricing-groups` | pricing:write | Create a pricing group |
| GET | `/v1/pricing-groups/{id}` | pricing:read | Get a pricing group by ID |
| PATCH | `/v1/pricing-groups/{id}` | pricing:write | Update a pricing group |
| DELETE | `/v1/pricing-groups/{id}` | pricing:write | Delete a pricing group and its tariffs |
| GET | `/v1/pricing/tariffs` | pricing:read | List all tariffs across every pricing group |
| GET | `/v1/pricing-groups/{id}/tariffs` | pricing:read | List tariffs in a pricing group |
| POST | `/v1/pricing-groups/{id}/tariffs` | pricing:write | Create a tariff in a pricing group |
| GET | `/v1/pricing-groups/{id}/tariffs/{tariffId}` | pricing:read | Get a single tariff |
| PATCH | `/v1/pricing-groups/{id}/tariffs/{tariffId}` | pricing:write | Update a tariff |
| DELETE | `/v1/pricing-groups/{id}/tariffs/{tariffId}` | pricing:write | Delete a tariff from a pricing group |
| GET | `/v1/pricing-groups/{id}/schedule` | pricing:read | Get tariff schedule for a pricing group |
| GET | `/v1/stations/{id}/active-tariff` | pricing:read | Get the currently active tariff for a station |
| GET | `/v1/pricing-audit` | pricing:read | List pricing audit log entries |
| GET | `/v1/pricing-holidays` | pricing:read | List all pricing holidays |
| POST | `/v1/pricing-holidays` | pricing:write | Create a pricing holiday |
| DELETE | `/v1/pricing-holidays/{id}` | pricing:write | Delete a pricing holiday |
| POST | `/v1/pricing-holidays/bulk` | pricing:write | Bulk create pricing holidays |
| GET | `/v1/pricing-groups/{id}/neighbors` | pricing:read | Get previous and next entity IDs in default list order |

## OCPP 2.1 Commands

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

## OCPP 1.6 Commands

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

## OCPP

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/ocpp/schemas/{action}` | stations:read | Get JSON schema for an OCPP action |

## Transactions

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/transactions` | sessions:read | List transaction events |
| GET | `/v1/transactions/by-session/{sessionId}` | sessions:read | Get transaction events for a session |
| GET | `/v1/transactions/by-transaction-id/{transactionId}` | sessions:read | Get session by OCPP transaction ID |

## Fleets

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/fleets` | fleets:read | List fleets |
| POST | `/v1/fleets` | fleets:write | Create a fleet |
| GET | `/v1/fleets/{id}` | fleets:read | Get a fleet by ID |
| PATCH | `/v1/fleets/{id}` | fleets:write | Update a fleet |
| DELETE | `/v1/fleets/{id}` | fleets:write | Delete a fleet |
| GET | `/v1/fleets/{id}/drivers` | fleets:read | List drivers in a fleet |
| POST | `/v1/fleets/{id}/drivers` | fleets:write | Add a driver to a fleet |
| DELETE | `/v1/fleets/{id}/drivers/{driverId}` | fleets:write | Remove a driver from a fleet |
| GET | `/v1/fleets/{id}/stations` | fleets:read | List stations in a fleet |
| POST | `/v1/fleets/{id}/stations` | fleets:write | Add a station to a fleet |
| DELETE | `/v1/fleets/{id}/stations/{stationId}` | fleets:write | Remove a station from a fleet |
| GET | `/v1/fleets/{id}/vehicles` | fleets:read | List vehicles in a fleet |
| GET | `/v1/fleets/{id}/vehicles/available` | fleets:read | Search vehicles not in fleet |
| GET | `/v1/fleets/{id}/sessions` | fleets:read | List charging sessions for a fleet |
| GET | `/v1/fleets/{id}/metrics` | fleets:read | Get fleet metrics |
| GET | `/v1/fleets/{id}/energy-history` | fleets:read | Get fleet energy delivery history |
| GET | `/v1/fleets/{id}/pricing-groups` | fleets:read | Get the pricing group for a fleet |
| POST | `/v1/fleets/{id}/pricing-groups` | fleets:write | Add a pricing group to a fleet |
| DELETE | `/v1/fleets/{id}/pricing-groups/{pricingGroupId}` | fleets:write | Remove a pricing group from a fleet |
| GET | `/v1/fleets/{fleetId}/reservations` | reservations:read | List fleet reservations |
| POST | `/v1/fleets/{fleetId}/reservations` | reservations:write | Create bulk reservations for a fleet |
| DELETE | `/v1/fleet-reservations/{id}` | reservations:write | Cancel all reservations in a fleet reservation |
| GET | `/v1/fleets/{id}/neighbors` | fleets:read | Get previous and next entity IDs in default list order |

## Tokens

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/tokens/filter-options` | drivers:read | Get distinct token types for filtering |
| GET | `/v1/tokens` | drivers:read | List all tokens with pagination |
| POST | `/v1/tokens` | drivers:write | Create a new token |
| GET | `/v1/tokens/export` | drivers:read | Export tokens as CSV |
| POST | `/v1/tokens/import` | drivers:write | Import tokens from parsed CSV rows |
| POST | `/v1/tokens/bulk-active` | drivers:write | Bulk activate or deactivate tokens |
| GET | `/v1/tokens/{id}/sessions` | drivers:read | List charging sessions authorized by this token |
| GET | `/v1/tokens/{id}` | drivers:read | Get a token by ID |
| PATCH | `/v1/tokens/{id}` | drivers:write | Update a token by ID |
| DELETE | `/v1/tokens/{id}` | drivers:write | Delete a token by ID |
| GET | `/v1/authorize-attempts` | drivers:read | List Authorize attempts (success and failure) for forensic triage |
| GET | `/v1/tokens/{id}/neighbors` | drivers:read | Get previous and next entity IDs in default list order |

## Dashboard

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/dashboard/stats` | dashboard:read | Get dashboard statistics |
| GET | `/v1/dashboard/energy-history` | dashboard:read | Get energy delivery history by day |
| GET | `/v1/dashboard/session-history` | dashboard:read | Get charging session count history by day |
| GET | `/v1/dashboard/station-status` | dashboard:read | Get connector counts grouped by status |
| GET | `/v1/dashboard/utilization` | dashboard:read | Get site utilization percentages |
| GET | `/v1/dashboard/peak-usage` | dashboard:read | Get peak usage heatmap by hour and day of week |
| GET | `/v1/dashboard/financial-stats` | dashboard:read | Get financial summary statistics |
| GET | `/v1/dashboard/revenue-history` | dashboard:read | Get revenue history by day |
| GET | `/v1/dashboard/payment-breakdown` | dashboard:read | Get payment counts and totals grouped by status |
| GET | `/v1/dashboard/uptime` | dashboard:read | Get station uptime percentage and port counts |
| GET | `/v1/dashboard/ocpp-health` | dashboard:read | Get OCPP WebSocket server health metrics |
| GET | `/v1/dashboard/site-locations` | dashboard:read | Site locations for map |
| GET | `/v1/dashboard/snapshots/trend` | dashboard:read | Get 14-day trend of dashboard snapshots |
| GET | `/v1/dashboard/snapshots/available-dates` | dashboard:read | Get dates that have snapshot data |
| GET | `/v1/dashboard/snapshots` | dashboard:read | Get historical dashboard snapshot for a date |
| GET | `/v1/dashboard/carbon-stats` | dashboard:read | Get carbon impact statistics |

## Settings

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/branding` | public | Get portal branding settings |
| GET | `/v1/portal/features` | public | Get public feature flags |
| GET | `/v1/portal/content/{type}` | public | Get public legal content |
| GET | `/v1/settings` | settings.system:read | Get all settings |
| GET | `/v1/settings/{key}` | settings.system:read | Get a setting by key |
| PUT | `/v1/settings/{key}` | settings.system:write | Create or update a setting by key |
| PATCH | `/v1/settings/{key}` | settings.system:write | Update a setting by key |
| DELETE | `/v1/settings/{key}` | settings.system:write | Delete a setting by key |
| GET | `/v1/settings/s3/status` | settings.system:read | Get S3 storage configuration status |
| PUT | `/v1/settings/s3` | settings.system:write | Save S3 storage settings |
| POST | `/v1/settings/s3/test` | settings.system:write | Test S3 connection |
| POST | `/v1/email-wrapper/preview` | settings.notification:read | Preview a draft email layout |
| GET | `/v1/security/settings` | settings.security:read | Get all security settings |
| PUT | `/v1/security/recaptcha` | settings.security:write | Update reCAPTCHA v3 settings |
| PUT | `/v1/security/mfa` | settings.security:write | Update MFA method availability |
| GET | `/v1/security/public` | public | Get public security configuration for login pages |
| GET | `/v1/system/info` | settings.system:read | Runtime version and environment configuration (no secret values) |
| GET | `/v1/sso/settings` | settings.security:read | Get SSO (SAML 2.0) settings |
| PUT | `/v1/sso/settings` | settings.security:write | Update SSO (SAML 2.0) settings |
| GET | `/v1/auth/sso/login` | public | Initiate SAML SSO login |
| POST | `/v1/auth/sso/callback` | public | SAML SSO assertion callback |
| GET | `/v1/carbon/factors` | sustainability:read | List carbon intensity factors |
| GET | `/v1/carbon/factors/{regionCode}` | sustainability:read | Get a carbon intensity factor by region code |
| GET | `/v1/station-message-templates` | settings.integrations:read | List all station message templates |
| PUT | `/v1/station-message-templates/{state}` | settings.integrations:write | Upsert a station message template body |
| DELETE | `/v1/station-message-templates/{state}` | settings.integrations:write | Reset a station message template to its seed default |
| POST | `/v1/station-message-templates/preview` | settings.integrations:read | Render a station message template body with sample variables |
| POST | `/v1/cache/flush` |  | Flush the HTTP response cache |

## Payments

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites/{id}/payment-config` | payments:read | Get payment configuration for a site |
| PUT | `/v1/sites/{id}/payment-config` | payments:write | Create or update payment configuration for a site |
| DELETE | `/v1/sites/{id}/payment-config` | payments:write | Delete payment configuration for a site |
| GET | `/v1/settings/stripe` | payments:read | Get system Stripe settings |
| PUT | `/v1/settings/stripe` | payments:write | Update system Stripe settings |
| POST | `/v1/settings/stripe/test` | payments:write | Test Stripe API connection |
| GET | `/v1/settings/stripe/webhook` | payments:read | Get the Stripe webhook setup |
| POST | `/v1/settings/stripe/webhook` | payments:write | Create the Stripe webhooks |
| GET | `/v1/sites/payment-configs` | payments:read | List all site payment configurations |
| GET | `/v1/drivers/{id}/payment-methods` | payments:read | List payment methods for a driver |
| POST | `/v1/drivers/{id}/payment-methods` | payments:write | Save a payment method for a driver |
| POST | `/v1/drivers/{id}/payment-methods/setup-intent` | payments:write | Create a Stripe setup intent for a driver |
| POST | `/v1/drivers/{id}/payment-methods/setup/submit` | payments:write | Submit a card collected for a driver by the payment provider card UI |
| POST | `/v1/drivers/{id}/payment-methods/setup/details` | payments:write | Continue a card setup for a driver after a client action |
| DELETE | `/v1/drivers/{id}/payment-methods/{pmId}` | payments:write | Delete a payment method for a driver |
| PATCH | `/v1/drivers/{id}/payment-methods/{pmId}/default` | payments:write | Set a payment method as default for a driver |
| POST | `/v1/sessions/{id}/pre-authorize` | payments:write | Pre-authorize a payment for a charging session |
| POST | `/v1/sessions/{id}/capture` | payments:write | Capture a pre-authorized payment for a session |
| POST | `/v1/sessions/{id}/refund` | payments:write | Refund a captured payment for a session |
| GET | `/v1/reservations/{id}/fee-payments` | payments:read | List the fee payments of a reservation |
| POST | `/v1/reservations/{id}/fee-payments/{paymentId}/refund` | payments:write | Refund a reservation fee payment |
| GET | `/v1/sessions/{id}/payment` | payments:read | Get payment record for a session |
| POST | `/v1/payments/{id}/retry-capture` | payments:write | Retry capture or top-up for a payment record |
| GET | `/v1/payments/reconciliation` | payments:read | List payment reconciliation runs |
| POST | `/v1/payments/reconciliation/run` | payments:write | Run payment reconciliation against Stripe |
| GET | `/v1/payments` | payments:read | List all payment records |
| GET | `/v1/settings/adyen` | payments:read | Get Adyen settings |
| PUT | `/v1/settings/adyen` | payments:write | Update Adyen settings |
| POST | `/v1/settings/adyen/test` | payments:write | Test the Adyen connection |
| GET | `/v1/settings/adyen/webhook` | payments:read | Get the Adyen webhook |
| POST | `/v1/settings/adyen/webhook` | payments:write | Create the Adyen webhook |
| GET | `/v1/sites/{id}/payout-account` | payments:read | Get the payout account of a site |
| POST | `/v1/sites/{id}/payout-account` | payments:write | Create the Stripe payout account of a site |
| POST | `/v1/sites/{id}/payout-account/refresh` | payments:write | Read the payout account status from Stripe |
| POST | `/v1/sites/{id}/payout-account/invite` | payments:write | Create the onboarding link of a site payout account |
| GET | `/v1/settings/payments` | payments:read | Get payment settings |
| PUT | `/v1/settings/payments` | payments:write | Update payment settings |
| POST | `/v1/ad-hoc-payments` | payments:write | Start a transaction for an authorized ad hoc payment |

## Events

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/events/stream` |  | Subscribe to real-time server-sent events |

## Load Management

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites/{id}/load-management` | loadManagement:read | Get load management config, hierarchy, and station status for a site |
| PUT | `/v1/sites/{id}/load-management` | loadManagement:write | Create or update load management config for a site |
| PATCH | `/v1/sites/{id}/stations/{stationId}/load-priority` | loadManagement:write | Update load priority for a station |
| GET | `/v1/sites/{id}/load-management/history` | loadManagement:read | Get load allocation history for a site |
| GET | `/v1/sites/{siteId}/panels` | loadManagement:read | List panels for a site |
| POST | `/v1/sites/{siteId}/panels` | loadManagement:write | Create a panel |
| GET | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:read | Get panel detail |
| PATCH | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:write | Update a panel |
| DELETE | `/v1/sites/{siteId}/panels/{panelId}` | loadManagement:write | Delete a panel |
| GET | `/v1/sites/{siteId}/panels/{panelId}/circuits` | loadManagement:read | List circuits for a panel |
| POST | `/v1/sites/{siteId}/panels/{panelId}/circuits` | loadManagement:write | Create a circuit on a panel |
| PATCH | `/v1/sites/{siteId}/panels/{panelId}/circuits/{circuitId}` | loadManagement:write | Update a circuit |
| DELETE | `/v1/sites/{siteId}/panels/{panelId}/circuits/{circuitId}` | loadManagement:write | Delete a circuit |
| PATCH | `/v1/sites/{siteId}/stations/{stationId}/circuit` | loadManagement:write | Assign or unassign a station to a circuit |
| GET | `/v1/sites/{siteId}/unmanaged-loads` | loadManagement:read | List unmanaged loads for a site |
| POST | `/v1/sites/{siteId}/unmanaged-loads` | loadManagement:write | Create an unmanaged load |
| PATCH | `/v1/sites/{siteId}/unmanaged-loads/{id}` | loadManagement:write | Update an unmanaged load |
| DELETE | `/v1/sites/{siteId}/unmanaged-loads/{id}` | loadManagement:write | Delete an unmanaged load |

## Notifications

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/ocpp-event-types` | notifications:read | List all event types |
| GET | `/v1/ocpp-event-template` | notifications:read | Get default OCPP event template |
| GET | `/v1/ocpp-event-settings` | notifications:read | List OCPP event settings |
| PUT | `/v1/ocpp-event-settings` | notifications:write | Create or update an OCPP event setting |
| DELETE | `/v1/ocpp-event-settings` | notifications:write | Delete an OCPP event setting |
| GET | `/v1/notifications` | notifications:read | List notification history |
| POST | `/v1/notifications/test` | notifications:write | Send a test notification |
| GET | `/v1/driver-event-settings` | notifications:read | List driver event settings |
| PUT | `/v1/driver-event-settings` | notifications:write | Create or update a driver event setting |
| GET | `/v1/system-event-settings` | notifications:read | List system event settings |
| PUT | `/v1/system-event-settings` | notifications:write | Create or update a system event setting |
| GET | `/v1/notification-templates` | notifications:read | Get a notification template |
| PUT | `/v1/notification-templates` | notifications:write | Create or update a notification template |
| DELETE | `/v1/notification-templates` | notifications:write | Delete a notification template |
| POST | `/v1/notification-templates/preview` | notifications:write | Preview a notification template with sample data |

## Reservations

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/reservations` | reservations:read | List all reservations |
| POST | `/v1/reservations` | reservations:write | Create a reservation and send ReserveNow to station |
| GET | `/v1/reservations/{id}` | reservations:read | Get a single reservation by ID |
| PATCH | `/v1/reservations/{id}` | reservations:write | Update an active reservation |
| DELETE | `/v1/reservations/{id}` | reservations:write | Cancel an active reservation |
| GET | `/v1/reservations/{id}/audit` | reservations:read | List audit log entries for a reservation |
| GET | `/v1/reservations/{id}/commands` | reservations:read | List OCPP commands for a reservation |
| POST | `/v1/reservations/{id}/reassign` | reservations:write | Move an active reservation to a different station |
| GET | `/v1/reservations/{id}/neighbors` | reservations:read | Get previous and next entity IDs in default list order |

## Maintenance

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/sites/{siteId}/maintenance/events` | maintenance:read | List maintenance events for a site |
| POST | `/v1/sites/{siteId}/maintenance/events` | maintenance:write | Create a maintenance event |
| GET | `/v1/sites/{siteId}/maintenance/events/{id}/stations` | maintenance:read | Per-station fan-out results for a maintenance event |
| GET | `/v1/sites/{siteId}/maintenance/events/{id}` | maintenance:read | Get a maintenance event by ID |
| PATCH | `/v1/sites/{siteId}/maintenance/events/{id}` | maintenance:write | Edit a scheduled or active maintenance event |
| POST | `/v1/sites/{siteId}/maintenance/events/{id}/cancel` | maintenance:write | Cancel a scheduled or active maintenance event |
| POST | `/v1/sites/{siteId}/maintenance/events/{id}/add-stations` | maintenance:write | Add one or more stations to a scheduled or active event |
| POST | `/v1/sites/{siteId}/maintenance/events/{id}/remove-stations` | maintenance:write | Remove one or more stations from a scheduled or active event |
| GET | `/v1/sites/{siteId}/maintenance/status` | maintenance:read | Current and upcoming maintenance for a site |
| GET | `/v1/sites/{siteId}/maintenance/station-preview` | maintenance:read | Preview station impact for a proposed maintenance window |
| POST | `/v1/maintenance/preview-message` | maintenance:read | Render the maintenance display message with sample variables |

## Portal Auth

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/portal/auth/attest/challenge` | public | Issue a device-attestation challenge |
| POST | `/v1/portal/auth/attest/register` | public | Register an iOS App Attest key |
| POST | `/v1/portal/auth/register` | public | Register a new driver account |
| POST | `/v1/portal/auth/login` | public | Log in with email and password |
| POST | `/v1/portal/auth/logout` | driver | Log out |
| POST | `/v1/portal/auth/refresh` | public | Refresh the access token |
| GET | `/v1/portal/auth/me` | driver | Get the current authenticated driver profile |
| POST | `/v1/portal/auth/mfa/verify` | public | Verify MFA code and complete portal login |
| POST | `/v1/portal/auth/mfa/resend` | public | Resend MFA verification code |
| POST | `/v1/portal/auth/forgot-password` | public | Request a password reset email for a driver account |
| POST | `/v1/portal/auth/activate` | public | Activate driver portal access from an operator invitation |
| POST | `/v1/portal/auth/reset-password` | public | Reset driver password using a token from the reset email |
| POST | `/v1/portal/auth/verify-email` | public | Verify driver email address using a token from the verification email |
| POST | `/v1/portal/auth/resend-verification` | driver | Resend email verification link |

## Portal Driver

| Method | Path | Permission | Summary |
|---|---|---|---|
| PATCH | `/v1/portal/driver/profile` | driver | Update the authenticated driver profile |
| PATCH | `/v1/portal/driver/password` | driver | Change the authenticated driver password |
| GET | `/v1/portal/driver/notification-preferences` | driver | Get driver notification preferences |
| PUT | `/v1/portal/driver/notification-preferences` | driver | Update driver notification preferences |
| GET | `/v1/portal/driver/mfa` | driver | Get current MFA status |
| DELETE | `/v1/portal/driver/mfa` | driver | Disable MFA |
| POST | `/v1/portal/driver/mfa/setup` | driver | Start MFA setup |
| POST | `/v1/portal/driver/mfa/confirm` | driver | Confirm MFA setup with verification code |
| GET | `/v1/portal/favorites` | driver | List favorite stations |
| POST | `/v1/portal/favorites` | driver | Add a station to favorites |
| GET | `/v1/portal/favorites/check/{stationId}` | driver | Check if a station is favorited |
| DELETE | `/v1/portal/favorites/{id}` | driver | Remove a station from favorites |
| GET | `/v1/portal/station-watches` | driver | List watched stations |
| POST | `/v1/portal/station-watches` | driver | Start watching a station for availability |
| GET | `/v1/portal/station-watches/check/{stationId}` | driver | Check if a station is being watched |
| DELETE | `/v1/portal/station-watches/{id}` | driver | Stop watching a station |

## Portal Payments

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/payment-methods` | driver | List saved payment methods |
| POST | `/v1/portal/payment-methods` | driver | Save a payment method after Stripe setup |
| POST | `/v1/portal/payment-methods/ephemeral-key` | driver | Create a Stripe ephemeral key for the native PaymentSheet |
| POST | `/v1/portal/payment-methods/setup-intent` | driver | Create a Stripe SetupIntent for adding a payment method |
| POST | `/v1/portal/payment-methods/setup/submit` | driver | Submit a card collected by the payment provider card UI |
| POST | `/v1/portal/payment-methods/setup/details` | driver | Continue a card setup after a client action |
| DELETE | `/v1/portal/payment-methods/{pmId}` | driver | Delete a saved payment method |
| PATCH | `/v1/portal/payment-methods/{pmId}/default` | driver | Set a payment method as the default |
| GET | `/v1/portal/payment-provider` | driver | Get the active payment provider descriptor |

## Portal Sessions

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/sessions` | driver | List charging sessions for the driver |
| GET | `/v1/portal/sessions/monthly-summary` | driver | Get monthly charging summary |
| GET | `/v1/portal/sessions/monthly-statement` | driver | Get monthly statement with itemized sessions |
| GET | `/v1/portal/sessions/{id}` | driver | Get charging session details with payment info |
| PATCH | `/v1/portal/sessions/{id}/vehicle` | driver | Set or clear the vehicle linked to a session |
| GET | `/v1/portal/sessions/{id}/power-history` | driver | Get power meter value history for a session |
| GET | `/v1/portal/sessions/{id}/energy-history` | driver | Get energy meter value history for a session |

## Portal Chargers

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/chargers/{stationId}/evse/{evseId}` | public | Get charger and EVSE details |
| GET | `/v1/portal/chargers/{stationId}/pricing` | driver | Get resolved pricing for a charger |
| GET | `/v1/portal/chargers/search` | public | Search chargers by station ID, site name, or address |
| GET | `/v1/portal/chargers/nearby` | public | List nearby chargers by coordinates |
| GET | `/v1/portal/chargers/map-config` | public | Get Google Maps configuration |
| GET | `/v1/portal/chargers/location/{siteId}` | public | Get location detail for a site |
| GET | `/v1/portal/chargers/location/{siteId}/images` | public | Get driver-visible images for a site |
| GET | `/v1/portal/chargers/location/{siteId}/images/{imageId}/download-url` | public | Get presigned download URL for a driver-visible image |
| GET | `/v1/portal/chargers/location/{siteId}/popular-times` | public | Get popular times for a site |
| GET | `/v1/portal/chargers/{stationId}` | public | Get station details with all EVSEs and connectors |
| POST | `/v1/portal/chargers/{stationId}/evse/{evseId}/check-status` | driver | Check connector status via TriggerMessage |
| POST | `/v1/portal/chargers/{stationId}/evse/{evseId}/start` | driver | Start a charging session on a charger EVSE |
| GET | `/v1/portal/chargers/sessions/active` | driver | List active charging sessions for the driver |
| POST | `/v1/portal/chargers/sessions/{sessionId}/stop` | driver | Stop an active charging session |
| GET | `/v1/portal/reservations` | driver | List reservations for the driver |
| POST | `/v1/portal/reservations` | driver | Create a reservation on a station |
| GET | `/v1/portal/reservations/{id}` | driver | Get a reservation by id with linked session for used reservations |
| DELETE | `/v1/portal/reservations/{id}` | driver | Cancel a reservation |
| GET | `/v1/portal/chargers/{stationId}/events` | public | Subscribe to real-time station status events |

## Portal Guest

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/portal/guest/qr/validate` | public | Validate a dynamic QR code URL |
| POST | `/v1/portal/guest/check-status/{stationId}/{evseId}` | public | Check connector status via TriggerMessage (guest) |
| GET | `/v1/portal/guest/charger-config/{stationId}/{evseId}` | public | Get charger payment configuration for guest charging |
| POST | `/v1/portal/guest/start/{stationId}/{evseId}` | public | Start a guest charging session with payment |
| POST | `/v1/portal/guest/payment-details/{sessionToken}` | public | Continue a guest payment after 3D Secure and start charging |
| GET | `/v1/portal/guest/status/{sessionToken}` | public | Get the status of a guest charging session |
| POST | `/v1/portal/guest/stop/{sessionToken}` | public | Stop a guest charging session |
| GET | `/v1/portal/guest/power-history/{sessionToken}` | public | Get power history for a guest charging session |
| GET | `/v1/portal/guest/energy-history/{sessionToken}` | public | Get energy history for a guest charging session |

## Portal Payout Onboarding

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/portal/payout-onboarding/link` | public | Start Stripe onboarding from a payout onboarding link |
| POST | `/v1/portal/payout-onboarding/status` | public | Read the payout account status after Stripe onboarding |

## Access Logs

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/access-logs` | logs:read | List access log entries |
| POST | `/v1/access-logs` | logs:write | Create an operator access log entry |
| GET | `/v1/worker-logs` | logs:read | List worker job logs |

## Portal Access Logs

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/portal/access-logs` | driver | Create a driver portal access log entry |

## Display Messages

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/stations/{stationId}/display-messages` | stations:read | List display messages for a station |
| POST | `/v1/stations/{stationId}/display-messages` | stations:write | Create and send a display message to a station |
| DELETE | `/v1/stations/{stationId}/display-messages/{id}` | stations:write | Clear a display message from a station |
| POST | `/v1/stations/{stationId}/display-messages/refresh` | stations:write | Refresh display messages from a station |

## Reports

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/reports` | reports:read | List reports |
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

## NEVI

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/nevi/station-data` | reports:read | List NEVI station data for all stations |
| PUT | `/v1/nevi/station-data/{stationId}` | reports:write | Create or update NEVI data for a station |
| GET | `/v1/nevi/excluded-downtime` | reports:read | List excluded downtime records |
| POST | `/v1/nevi/excluded-downtime` | reports:write | Create an excluded downtime record |
| PATCH | `/v1/nevi/excluded-downtime/{id}` | reports:write | Update an excluded downtime record |
| DELETE | `/v1/nevi/excluded-downtime/{id}` | reports:write | Delete an excluded downtime record |

## Webhooks

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/webhooks/payments/stripe` | public | Handle Stripe webhook events |
| POST | `/v1/webhooks/payments/adyen` | public | Handle Adyen webhook events |

## Invoices

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/invoices` | payments:read | List invoices |
| GET | `/v1/invoices/{id}` | payments:read | Get an invoice with line items |
| POST | `/v1/invoices/session/{sessionId}` | payments:write | Generate an invoice for a single charging session |
| POST | `/v1/invoices/aggregated` | payments:write | Generate an aggregated invoice for a driver over a date range |
| PATCH | `/v1/invoices/{id}/void` | payments:write | Void an invoice |
| POST | `/v1/invoices/{id}/send` | payments:write | Email an invoice to its driver |
| GET | `/v1/invoices/{id}/pdf` | payments:read | Download an invoice as a PDF |
| GET | `/v1/invoices/{id}/download` | payments:read | Download an invoice as JSON |
| GET | `/v1/invoices/{id}/neighbors` | payments:read | Get previous and next entity IDs in default list order |

## Support Cases

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/support-cases` | support:read | List support cases |
| POST | `/v1/support-cases` | support:write | Create a support case |
| GET | `/v1/support-cases/unread-count` | support:read | Get unread support case count for the current operator |
| GET | `/v1/support-cases/{id}` | support:read | Get support case detail |
| PATCH | `/v1/support-cases/{id}` | support:write | Update a support case |
| POST | `/v1/support-cases/{id}/read` | support:write | Mark a support case as read by the current operator |
| POST | `/v1/support-cases/{id}/messages` | support:write | Add a message to a support case |
| POST | `/v1/support-cases/{id}/messages/{messageId}/attachments/upload-url` | support:write | Get a presigned S3 upload URL for an attachment |
| POST | `/v1/support-cases/{id}/messages/{messageId}/attachments` | support:write | Confirm an attachment after uploading to S3 |
| GET | `/v1/support-cases/{id}/messages/{messageId}/attachments/{attachmentId}/download-url` | support:read | Get a presigned S3 download URL for an attachment |
| DELETE | `/v1/support-cases/{id}/messages/{messageId}/attachments/{attachmentId}` | support:write | Delete an attachment from a support case message |
| POST | `/v1/support-cases/{id}/refund` | support:write | Issue a refund for a session linked to a support case |
| POST | `/v1/support-cases/{id}/ai-assist` | support:write | Generate an AI draft reply for a support case |
| GET | `/v1/support-cases/{id}/neighbors` | support:read | Get previous and next entity IDs in default list order |

## Portal Vehicles

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/vehicles` | driver | List driver vehicles |
| POST | `/v1/portal/vehicles` | driver | Add a vehicle |
| DELETE | `/v1/portal/vehicles/{id}` | driver | Delete a vehicle |
| GET | `/v1/portal/vehicles/efficiency` | driver | Get vehicle efficiency for miles estimation |
| GET | `/v1/portal/vehicles/lookup` | driver | List known vehicle makes and models for autocomplete |

## Portal Tokens

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/tokens` | driver | List driver RFID tokens |
| POST | `/v1/portal/tokens` | driver | Add RFID card |
| PATCH | `/v1/portal/tokens/{id}` | driver | Toggle RFID token active status |
| DELETE | `/v1/portal/tokens/{id}` | driver | Deactivate (soft-delete) an RFID card |

## Portal Notifications

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/notifications` | driver | List notification history for the driver |
| GET | `/v1/portal/notifications/unread-count` | driver | Get unread notification count |
| POST | `/v1/portal/notifications/mark-read` | driver | Mark all notifications as read |
| POST | `/v1/portal/notifications/push-token` | driver | Register or refresh a native push token |
| DELETE | `/v1/portal/notifications/push-token` | driver | Unregister a native push token |

## Portal Support

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/support-cases` | driver | List support cases for the driver |
| POST | `/v1/portal/support-cases` | driver | Create a new support case |
| GET | `/v1/portal/support-cases/{id}` | driver | Get support case details with messages |
| POST | `/v1/portal/support-cases/{id}/messages` | driver | Reply to a support case |
| POST | `/v1/portal/support-cases/{id}/messages/{messageId}/attachments/upload-url` | driver | Request a presigned S3 upload URL for an attachment |
| POST | `/v1/portal/support-cases/{id}/messages/{messageId}/attachments` | driver | Confirm an attachment after S3 upload |
| GET | `/v1/portal/support-cases/{id}/messages/{messageId}/attachments/{attachmentId}/download-url` | driver | Get a presigned download URL for an attachment |

## Portal Roaming

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/chargers/roaming` | driver | Search roaming chargers from partner networks |
| POST | `/v1/portal/chargers/roaming/start` | driver | Start a remote charging session on an external station |

## Portal Events

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/portal/events` | driver | Subscribe to real-time portal events |

## OCPI

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/ocpi/partners` | roaming:read | List OCPI partners |
| POST | `/v1/ocpi/partners` | roaming:write | Create OCPI partner |
| GET | `/v1/ocpi/partners/{id}` | roaming:read | Get OCPI partner details |
| PATCH | `/v1/ocpi/partners/{id}` | roaming:write | Update OCPI partner |
| DELETE | `/v1/ocpi/partners/{id}` | roaming:write | Disconnect OCPI partner |
| POST | `/v1/ocpi/partners/{id}/register` | roaming:write | Initiate outbound OCPI registration |
| POST | `/v1/ocpi/partners/{id}/sync/{module}` | roaming:write | Trigger manual OCPI module sync |
| GET | `/v1/ocpi/sync-log` | roaming:read | List OCPI sync log entries |
| GET | `/v1/ocpi/locations` | roaming:read | List all sites with OCPI publish status |
| GET | `/v1/ocpi/locations/{siteId}` | roaming:read | Get OCPI publish settings for a site |
| PUT | `/v1/ocpi/locations/{siteId}` | roaming:write | Update OCPI publish settings for a site |
| GET | `/v1/ocpi/sessions` | roaming:read | List OCPI roaming sessions |
| GET | `/v1/ocpi/cdrs` | roaming:read | List OCPI charge detail records |
| POST | `/v1/ocpi/cdrs/credit` | roaming:write | Create a credit CDR |
| GET | `/v1/ocpi/tariff-mappings` | roaming:read | List OCPI tariff mappings |
| POST | `/v1/ocpi/tariff-mappings` | roaming:write | Create OCPI tariff mapping |
| GET | `/v1/ocpi/tariff-mappings/{id}` | roaming:read | Get a single OCPI tariff mapping |
| PATCH | `/v1/ocpi/tariff-mappings/{id}` | roaming:write | Update OCPI tariff mapping |
| DELETE | `/v1/ocpi/tariff-mappings/{id}` | roaming:write | Delete OCPI tariff mapping |
| GET | `/v1/ocpi/partners/{id}/neighbors` | roaming:read | Get previous and next entity IDs in default list order |

## PnC

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

## Local Auth List

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/stations/{stationId}/local-auth-list` | stations:read | List local auth list entries and version info |
| GET | `/v1/stations/{stationId}/local-auth-list/available-tokens` | stations:read | List active driver tokens not on this station local auth list |
| POST | `/v1/stations/{stationId}/local-auth-list/push` | stations:write | Push tracked entries to station via OCPP SendLocalList Full |
| POST | `/v1/stations/{stationId}/local-auth-list/add` | stations:write | Add tokens to station local auth list (DB-only) |
| POST | `/v1/stations/{stationId}/local-auth-list/remove` | stations:write | Remove entries from station local auth list (DB-only) |

## Fleet Operations

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/firmware-campaigns/filter-options` | settings.firmware:read | Get filter options for firmware campaign targeting |
| GET | `/v1/firmware-campaigns` | settings.firmware:read | List firmware campaigns |
| POST | `/v1/firmware-campaigns` | settings.firmware:write | Create a firmware campaign |
| GET | `/v1/firmware-campaigns/{id}` | settings.firmware:read | Get firmware campaign with station progress |
| PATCH | `/v1/firmware-campaigns/{id}` | settings.firmware:write | Update a draft firmware campaign |
| DELETE | `/v1/firmware-campaigns/{id}` | settings.firmware:write | Delete a draft firmware campaign |
| GET | `/v1/firmware-campaigns/{id}/matching-stations` | settings.firmware:read | Preview stations matching the campaign target filter |
| POST | `/v1/firmware-campaigns/{id}/start` | settings.firmware:write | Start a firmware campaign - dispatch UpdateFirmware to targets |
| POST | `/v1/firmware-campaigns/{id}/cancel` | settings.firmware:write | Cancel an active firmware campaign |
| GET | `/v1/config-templates/filter-options` | settings.stationConfig:read | Get filter options for config template targeting |
| GET | `/v1/config-templates` | settings.stationConfig:read | List configuration templates |
| POST | `/v1/config-templates` | settings.stationConfig:write | Create a configuration template |
| GET | `/v1/config-templates/{id}` | settings.stationConfig:read | Get configuration template |
| PATCH | `/v1/config-templates/{id}` | settings.stationConfig:write | Update a configuration template |
| DELETE | `/v1/config-templates/{id}` | settings.stationConfig:write | Delete a configuration template |
| POST | `/v1/config-templates/{id}/duplicate` | settings.stationConfig:write | Duplicate a configuration template |
| GET | `/v1/config-templates/{id}/matching-stations` | settings.stationConfig:read | Preview stations matching the template target filter |
| POST | `/v1/config-templates/{id}/push` | settings.stationConfig:write | Push configuration template variables to matching stations via SetVariables |
| GET | `/v1/config-templates/{id}/pushes` | settings.stationConfig:read | List push history for a configuration template |
| GET | `/v1/config-template-pushes/{pushId}` | settings.stationConfig:read | Get config template push detail with per-station results |
| GET | `/v1/stations/{id}/config-drift` | settings.stationConfig:read | Compare station variables against matching config templates |

## Event Alert Rules

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/event-alert-rules` | stations:read | List event alert rules |
| POST | `/v1/event-alert-rules` | stations:write | Create event alert rule |
| PATCH | `/v1/event-alert-rules/{id}` | stations:write | Update event alert rule |
| DELETE | `/v1/event-alert-rules/{id}` | stations:write | Delete event alert rule |

## API Keys

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/api-keys` | settings.apiKeys:read | List active API keys for the current user |
| POST | `/v1/api-keys` | settings.apiKeys:write | Create a new API key |
| PATCH | `/v1/api-keys/{id}` | settings.apiKeys:write | Update API key permissions |
| DELETE | `/v1/api-keys/{id}` | settings.apiKeys:write | Revoke an API key |

## CSS Management

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/css/stations` | stations:read | List CSS stations |
| POST | `/v1/css/stations` | stations:write | Create a CSS station |
| GET | `/v1/css/stations/{stationId}` | stations:read | Get a CSS station by station ID |
| PATCH | `/v1/css/stations/{stationId}` | stations:write | Update a CSS station |
| DELETE | `/v1/css/stations/{stationId}` | stations:write | Delete a CSS station |
| POST | `/v1/css/stations/{stationId}/enable` | stations:write | Enable a CSS station |
| POST | `/v1/css/stations/{stationId}/disable` | stations:write | Disable a CSS station |

## CSS Actions

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

## CSS OCPP 1.6 Actions

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

## CSS OCPP 2.1 Actions

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

## Smart Charging

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/smart-charging/filter-options` | smartCharging:read | Get filter options for smart charging template targeting |
| GET | `/v1/smart-charging/templates` | smartCharging:read | List charging profile templates |
| POST | `/v1/smart-charging/templates` | smartCharging:write | Create a charging profile template |
| GET | `/v1/smart-charging/templates/{id}` | smartCharging:read | Get charging profile template |
| PATCH | `/v1/smart-charging/templates/{id}` | smartCharging:write | Update a charging profile template |
| DELETE | `/v1/smart-charging/templates/{id}` | smartCharging:write | Delete a charging profile template |
| POST | `/v1/smart-charging/templates/{id}/duplicate` | smartCharging:write | Duplicate a charging profile template |
| GET | `/v1/smart-charging/templates/{id}/matching-stations` | smartCharging:read | Preview stations matching the template target filter |
| POST | `/v1/smart-charging/templates/{id}/push` | smartCharging:write | Push charging profile template to matching stations via SetChargingProfile |
| POST | `/v1/smart-charging/templates/{id}/clear` | smartCharging:write | Clear charging profile from all matching stations |
| GET | `/v1/smart-charging/templates/{id}/pushes` | smartCharging:read | List push history for a charging profile template |
| GET | `/v1/smart-charging/pushes/{pushId}` | smartCharging:read | Get charging profile push detail with per-station results |

## AI Assistant

| Method | Path | Permission | Summary |
|---|---|---|---|
| POST | `/v1/assistant/chat` | settings.ai:write | Chat with the AI assistant |

## OCTT

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/octt/runs` | conformance:read | List conformance test runs |
| POST | `/v1/octt/runs` | conformance:write | Trigger a conformance test run |
| GET | `/v1/octt/runs/{id}` | conformance:read | Get conformance test run detail |
| GET | `/v1/octt/runs/{id}/summary` | conformance:read | Get per-module summary for a test run |

## Audit

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/audit/{entityType}/{entityId}` | audit:read | List audit entries for one entity |
| GET | `/v1/audit` | audit:read | List audit entries across all entities |

## Conformance

| Method | Path | Permission | Summary |
|---|---|---|---|
| GET | `/v1/octt/runs/{id}/neighbors` | conformance:read | Get previous and next entity IDs in default list order |
