# EVtivity API routes: Stations

Generated from EVtivity CSMS v0.1.42-beta.2 (https://github.com/EVtivity/evtivity-csms, commit 627b28b192ed) by `scripts/generate-api-reference.py`. Do not edit by hand.
Index of all tags: `references/routes.md`.

Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no
token. `driver` needs a driver portal token. Empty means the route needs a signed-in
operator and no single permission was found; check Swagger at `<api>/docs`.
A `write` permission includes `read` for the same resource.

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
