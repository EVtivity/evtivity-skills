# EVtivity API error codes

Generated from EVtivity CSMS v0.1.39-beta.2 (https://github.com/EVtivity/evtivity-csms, commit f3bd9ac5d1e8) by `scripts/generate-api-reference.py`: the English
messages of the CSMS and the statuses in its OpenAPI spec. Do not edit by hand.
Catalog with localized messages: https://www.evtivity.com/api-reference/error-codes

Every error response is JSON: `{ "error": "<message>", "code": "<CODE>" }`.
Match on `code`, never on the message. HTTP lists the statuses the spec documents.

| Code | HTTP | Message |
|---|---|---|
| `ACCOUNT_DEACTIVATED` |  | Account deactivated |
| `ACCOUNT_DISABLED` | 401, 403 | Account disabled |
| `AI_ERROR` | 500 | Failed to process AI request |
| `AI_NOT_CONFIGURED` | 400 | AI is not configured |
| `ALERT_NOT_FOUND` | 404 | Alert not found |
| `ALREADY_FAVORITED` | 409 | Already favorited |
| `ALREADY_VERIFIED` | 400 | Email already verified |
| `API_KEY_EXPIRED` |  | API key expired |
| `API_KEY_NOT_FOUND` | 404 | API key not found |
| `API_KEY_RATE_LIMITED` |  | API key rate limit exceeded |
| `ATTACHMENT_NOT_FOUND` | 404 | Attachment not found |
| `ATTESTATION_FAILED` | 403 | Device attestation failed. Update the app and try again. |
| `AUDIT_ENTITY_TYPE_INVALID` | 400 | Unknown audit entity type |
| `CAMPAIGN_NOT_FOUND` | 404 | Campaign not found |
| `CASE_NOT_FOUND` | 404 | Case not found |
| `CA_CERT_NOT_FOUND` | 404 | CA certificate not found |
| `CDR_NOT_FOUND` | 404 | CDR not found |
| `CIRCUIT_NOT_FOUND` | 404 | Circuit not found |
| `COMMAND_ERROR` |  | Command failed |
| `COMMAND_FAILED` |  | Command failed |
| `COMMAND_QUEUED` |  | Station offline, command queued |
| `COMMAND_TIMEOUT` |  | No response from station |
| `CONNECTOR_ID_MISMATCH` | 400 | On an OCPP 1.6 station each EVSE has one connector with the same number. |
| `CONNECTOR_NOT_AVAILABLE` | 400 | Connector is not available for charging |
| `CONNECTOR_NOT_FOUND` | 404 | Connector not found |
| `CONNECTOR_OCCUPIED` | 409 | Cannot delete EVSE with occupied connectors |
| `CONNECTOR_RESERVED` | 403 | Connector is reserved for another driver |
| `CREATE_FAILED` | 500 | Failed to create circuit |
| `CSRF_INVALID` |  | Invalid CSRF token |
| `CSR_NOT_FOUND` | 404 | Pending CSR not found |
| `CSS_ACTION_REJECTED` | 400 | Charging Station Simulator rejected the action |
| `CSS_ACTION_TIMEOUT` | 504 | Simulator did not respond within 5s |
| `DOWNTIME_NOT_FOUND` | 404 | Excluded downtime record not found |
| `DRIVER_ALREADY_IN_FLEET` | 409 | Driver is already in this fleet |
| `DRIVER_CREATE_FAILED` |  | Failed to create driver |
| `DRIVER_INACTIVE` | 409 | Driver is inactive |
| `DRIVER_NOT_FOUND` | 400, 404 | Driver not found |
| `DUPLICATE_API_KEY_NAME` | 409 | An API key with this name already exists |
| `DUPLICATE_CONNECTOR_ID` | 409 | Connector ID ... already exists on this EVSE |
| `DUPLICATE_EMAIL` | 409 | Email already in use |
| `DUPLICATE_EVSE_ID` | 409 | EVSE ID ... already exists on this station |
| `DUPLICATE_HOLIDAY` | 409 | A holiday already exists for this date |
| `DUPLICATE_PARTNER` | 409 | Partner with this country code and party ID already exists |
| `DUPLICATE_SITE_NAME` |  | A site with this name already exists |
| `DUPLICATE_STATION_ID` | 409 | Station ID already exists |
| `ELECTRICITY_RATE_NOT_FOUND` | 404 | Electricity rate not found |
| `EMAID_PREFIX_NOT_CONFIGURED` | 409 | Set the eMAID country code and provider ID first |
| `EMAIL_EXISTS` | 409 | Email already registered |
| `EMAIL_NOT_CONFIGURED` | 400 | Email provider not configured |
| `EMAIL_NOT_VERIFIED` |  | Email not verified |
| `EMAIL_REQUIRED` | 400 | Email required for paid charging |
| `EMAIL_SEND_FAILED` | 500 | Failed to send email |
| `ENCRYPTION_KEY_MISSING` | 500 | SETTINGS_ENCRYPTION_KEY not configured on server |
| `EVSE_IN_USE` | 409 | Another session is already active on this connector |
| `EVSE_NOT_FOUND` | 404 | EVSE not found on this station |
| `FAVORITE_NOT_FOUND` | 404 | Favorite not found |
| `FLEET_DISABLED` |  | Fleet is disabled |
| `FLEET_NOT_FOUND` | 404 | Fleet not found |
| `FLEET_RESERVATION_ALREADY_CANCELLED` | 400 | Fleet reservation is already cancelled |
| `FLEET_RESERVATION_CREATE_FAILED` | 400 | Failed to create fleet reservation |
| `FLEET_RESERVATION_NOT_FOUND` | 404 | Fleet reservation not found |
| `FORBIDDEN` | 403 | Forbidden |
| `FORBIDDEN_DRIVER_TOKEN` |  | Forbidden: driver token required |
| `GUEST_CHARGING_DISABLED` |  | Guest charging is disabled |
| `HOLIDAY_NOT_FOUND` | 404 | Holiday not found |
| `IMAGE_NOT_FOUND` | 404 | Image not found |
| `INSERT_FAILED` | 500 | Failed to create run |
| `INSUFFICIENT_PERMISSIONS` |  | Insufficient permissions |
| `INTERNAL_ERROR` | 500 | Internal server error |
| `INVALID_CIRCUIT` | 400 | Circuit not found in this site |
| `INVALID_CREDENTIALS` | 401 | Invalid email or password |
| `INVALID_OPERATION` | 400 | Cannot credit a credit CDR |
| `INVALID_PANEL` | 400 | Panel not found in this site |
| `INVALID_PARENT_PANEL` |  | Parent panel not found in this site |
| `INVALID_PASSWORD` | 400 | Current password is incorrect |
| `INVALID_PAYLOAD` |  | Invalid OCPP payload |
| `INVALID_PERMISSIONS` | 400 | Invalid permissions: ... |
| `INVALID_REFRESH_TOKEN` | 401 | Invalid refresh token |
| `INVALID_REGION_CODE` | 400 | Invalid region code |
| `INVALID_RESTRICTIONS` | 400 | Invalid tariff restrictions |
| `INVALID_SITE_IDS` |  | One or more siteIds do not exist |
| `INVALID_TOKEN` | 400 | Invalid or expired reset link |
| `INVOICE_CREATION_FAILED` | 400 | Failed to create invoice |
| `INVOICE_NOT_FOUND` | 404 | Invoice not found |
| `INVOICE_NO_DRIVER` | 400 | This invoice has no driver to send to |
| `INVOICE_NO_SESSIONS` | 400 | No uninvoiced sessions in the selected date range |
| `LOAD_NOT_FOUND` | 404 | Load not found |
| `LOCAL_CA_EXISTS` | 409 | A local contract CA already exists |
| `LOCAL_CA_NOT_CONFIGURED` | 409 | Create the local contract CA first |
| `LOCATION_NOT_FOUND` | 404 | Location not found |
| `MAINTENANCE_ACTIVE` | 409 | Site is currently under maintenance |
| `MAINTENANCE_ALREADY_ACTIVE` | 409 | Maintenance event is already active |
| `MAINTENANCE_INVALID_RANGE` | 400 | Maintenance end must be after start |
| `MAINTENANCE_NOT_FOUND` | 404 | Maintenance event not found |
| `MAINTENANCE_OVERLAPS_EXISTING` | 409 | Maintenance window overlaps an existing event |
| `MAPPING_NOT_FOUND` | 404 | Tariff mapping not found |
| `MESSAGE_CLEAR_FAILED` | 502 | Failed to clear display message |
| `MESSAGE_CLEAR_REJECTED` | 400 | Station rejected clear: ... |
| `MESSAGE_CREATE_FAILED` | 500 | Failed to create message |
| `MESSAGE_NOT_CLEARABLE` | 400 | Only accepted messages can be cleared |
| `MESSAGE_NOT_FOUND` | 404 | Message not found |
| `MESSAGE_REFRESH_FAILED` |  | Failed to refresh display messages |
| `MESSAGE_SEND_FAILED` | 502 | Failed to send display message |
| `MESSAGE_TIMEOUT` | 504 | Display message command timed out |
| `MFA_ALREADY_ENABLED` |  | MFA is already enabled. Disable it first before setting up a new method. |
| `MFA_CHALLENGE_EXHAUSTED` | 400 | Too many failed attempts. Request a new code. |
| `MFA_CODE_INVALID` | 400 | Invalid verification code |
| `MFA_METHOD_DISABLED` | 403 | MFA method is disabled |
| `MFA_NOT_CONFIGURED` | 400 | MFA not configured |
| `MFA_REQUIRED` |  | MFA verification required |
| `MFA_TOKEN_EXPIRED` | 401 | Invalid or expired MFA token |
| `MFA_TOKEN_INVALID` | 400 | Invalid MFA token |
| `MFA_TOTP_NO_RESEND` | 400 | Cannot resend TOTP codes |
| `MISSING_PAYMENT_INTENT` | 400 | Payment intent missing |
| `MISSING_VERSION_URL` | 400 | Partner version URL is required for registration |
| `NOT_BLOCKED` | 409 | Station is not blocked |
| `NOT_CHARGING` | 400 | Session is not currently charging |
| `NOT_DRAFT` |  | Only draft campaigns can be updated |
| `NOT_IMPLEMENTED` | 501 | Remote start on partner networks requires the OCPI Commands module |
| `NOT_PENDING` |  | Station is not pending approval |
| `NOT_SUPPORTED` | 400 | Not supported for OCPP 1.6 |
| `NO_ACTIVE_SESSION` |  | No active session on this EVSE |
| `NO_CAPTURED_PAYMENT` | 400 | No captured payment to refund |
| `NO_CHARGING_SESSION` | 400 | No linked charging session |
| `NO_MATCHING_TARIFF` | 404 | No matching tariff for current time |
| `NO_PRE_AUTH` | 404 | No pre-authorized payment for this session |
| `NO_PRICING_GROUP` | 404 | No pricing group found for station |
| `NO_REFRESH_TOKEN` | 401 | No refresh token |
| `NO_TARGETS` | 409 | No matching stations found |
| `NO_TARIFFS` | 404 | No active tariffs found |
| `NO_VALID_ENTRIES` | 400 | No valid entries found |
| `NO_VALID_TOKENS` | 400 | No valid tokens found |
| `OCPP_COMMAND_FAILED` | 502 | OCPP command failed |
| `OCPP_VERSION_MISMATCH` | 400 | The command is for a different OCPP version than the station uses |
| `OCTT_RUN_NOT_FOUND` | 404 | Conformance run not found |
| `OVERSUBSCRIPTION_EXCEEDED` | 400 | Total connected capacity (... kW) exceeds panel effective capacity (... kW) |
| `PANEL_NOT_FOUND` | 404 | Panel not found |
| `PARTNER_NOT_CONNECTED` | 400 | Partner must be connected to sync |
| `PARTNER_NOT_FOUND` | 404 | Partner not found |
| `PASSWORD_REQUIRED` | 400 | Password required when upgrading to Basic Auth or TLS + Basic Auth |
| `PAYMENT_CONFIG_NOT_FOUND` | 404 | No payment config for this site |
| `PAYMENT_FAILED` | 400 | Payment failed |
| `PAYMENT_METHOD_IN_USE` |  | Payment method is in use by an active charging session |
| `PAYMENT_METHOD_NOT_FOUND` | 404 | Payment method not found |
| `PAYMENT_METHOD_REQUIRED` | 400 | Payment method required |
| `PAYMENT_NOT_CONFIGURED` | 400 | Payment not configured for this station |
| `PAYMENT_NOT_FOUND` | 404 | No payment record for this session |
| `PAYMENT_OPERATION_PENDING` | 409 | The payment has an operation waiting for the provider's confirmation. Try again later. |
| `PAYMENT_PREAUTH_FAILED` |  | Payment authorization declined |
| `PAYMENT_PROVIDER_CONNECTION_FAILED` | 400 | Payment provider connection test failed |
| `PAYMENT_PROVIDER_NOT_CONFIGURED` | 400, 409 | Payment provider is not configured |
| `PAYMENT_PROVIDER_PERMISSION_MISSING` | 400 | The payment provider credential lacks a required permission |
| `PAYMENT_PROVIDER_UPGRADE_PENDING` | 409 | A process older than v0.1.38 is still connected. Finish the upgrade, then select Adyen. |
| `PAYMENT_RECORD_NOT_RECOVERABLE` | 409 | Payment record is not in a recoverable state |
| `PAYMENT_TOP_UP_FAILED` | 502 | Payment top-up rejected |
| `PAYMENT_WEBHOOK_EXISTS` | 409 | An EVtivity webhook already exists for this provider |
| `PAYOUT_ACCOUNT_EXISTS` | 409 | The site already has a payout account |
| `PAYOUT_ACCOUNT_NOT_READY` | 409 | The site's payout account cannot receive payments yet |
| `PERMISSIONS_EXCEED_OWN` | 403 | API key permissions must be a subset of your own permissions |
| `PKI_ROOT_REFRESH_FAILED` | 502 | Root certificate refresh from the PKI provider failed |
| `PNC_CONTRACT_NOT_FOUND` | 404 | Plug & Charge contract not found |
| `PNC_DISABLED` |  | Plug & Charge is disabled |
| `PORTAL_ALREADY_ACTIVE` | 409 | Driver already has portal access |
| `PORTAL_REGISTRATION_DISABLED` | 403 | Driver self-registration is disabled. Contact your operator to be invited. |
| `PRE_AUTH_FAILED` |  | Payment pre-authorization failed |
| `PRICING_ASSIGNMENT_NOT_FOUND` | 404 | No pricing group is assigned to this entity |
| `PRICING_GROUP_NOT_FOUND` | 404 | Pricing group not found |
| `PRICING_GROUP_TARIFFS_IN_USE` | 409 | Pricing group has tariffs referenced by charging sessions |
| `PRICING_NOT_FOUND` | 404 | No pricing found |
| `PRIVATE_URL` | 400 | Version URL must not point to a private or internal address |
| `PROFILE_ID_ALLOC_FAILED` |  | Could not allocate a free profileId |
| `PROFILE_ID_IN_USE` | 409 | profileId ... is already used by another template |
| `PROVIDER_TEST_FAILED` |  | Provider returned ... |
| `PUSH_NOT_FOUND` | 404 | Push not found |
| `PUSH_REJECTED` | 502 | Station rejected push: ... |
| `RATE_LIMITED` | 429 | Too many status checks for this station |
| `RECAPTCHA_FAILED` | 403 | reCAPTCHA verification failed |
| `RECAPTCHA_REQUIRED` | 400 | reCAPTCHA token is required |
| `REFUND_EXCEEDS_REMAINING` | 400, 409 | Refund amount exceeds remaining ... |
| `REFUND_TOP_UP_UNKNOWN` | 409 | This payment includes a top-up charge with no recorded payment id. Refund the top-up in the payment provider's dashboard. |
| `REGION_NOT_FOUND` | 404 | Region not found |
| `REPORT_NOT_FOUND` | 404 | Report not found |
| `RESERVATION_BUFFER_ACTIVE` | 409 | This connector has an upcoming reservation and cannot start a new session |
| `RESERVATION_CONFLICT` | 409 | An active reservation already exists for this station |
| `RESERVATION_CREATE_FAILED` | 500 | Failed to create reservation |
| `RESERVATION_DISABLED` |  | Reservations are disabled |
| `RESERVATION_DURING_MAINTENANCE` | 409 | Reservation falls within a scheduled maintenance window |
| `RESERVATION_EXPIRES_TOO_SOON` | 400 | Reservation must end at least 60 seconds in the future |
| `RESERVATION_NOT_ACTIVE` | 400 | Reservation is not active |
| `RESERVATION_NOT_FOUND` | 404 | Reservation not found |
| `RESERVATION_REJECTED` | 400, 502 | Station rejected reservation: ... |
| `RESERVATION_STARTS_IN_PAST` | 400 | Reservation start time cannot be in the past |
| `RESERVATION_TIMEOUT` | 504 | Reservation command timed out |
| `RESERVATION_TOO_LONG` | 400 | Reservation cannot exceed ... hours |
| `RESERVATION_WINDOW_TOO_SHORT` | 400 | Reservation must end at least 60 seconds after it starts |
| `RESET_NOT_REQUIRED` |  | Password reset is not required |
| `ROAMING_DISABLED` |  | Roaming is disabled |
| `ROLE_NOT_FOUND` |  | Role does not exist |
| `ROTATION_NOT_APPLICABLE` | 400 | Credential rotation only applies to security profiles 1 and 2 |
| `RULE_NOT_FOUND` | 404 | Rule not found |
| `SCHEDULE_NOT_FOUND` | 404 | Schedule not found |
| `SCHEMA_NOT_FOUND` | 404 | Schema not found |
| `SECURITY_PROFILE_DOWNGRADE` | 400 | A connected station cannot be moved to a lower security profile |
| `SELF_EDIT_FORBIDDEN` | 403 | Cannot edit your own role, status, or site access |
| `SESSION_ALREADY_ACTIVE` | 400 | You already have an active charging session |
| `SESSION_CREATE_FAILED` | 500 | Failed to create session |
| `SESSION_NOT_FOUND` | 400, 404 | Session not found |
| `SESSION_NOT_LINKED` | 400 | Session not linked to this case |
| `SETTING_NOT_FOUND` | 404 | Setting not found |
| `SITE_HAS_STATIONS` | 409 | Cannot delete site with stations. Remove or reassign stations first. |
| `SITE_NOT_FOUND` | 404 | Site not found |
| `SITE_PAYMENT_CONFIG_IN_USE` | 409 | This site's payment configuration has payments and cannot be deleted. Disable it instead. |
| `SMS_NOT_CONFIGURED` | 400 | SMS provider not configured |
| `SMS_SEND_FAILED` | 500 | Failed to send SMS |
| `SSO_DISABLED` | 400 | SSO is not configured |
| `START_REJECTED` | 502 | Station rejected start request: ... |
| `STATION_ALREADY_AVAILABLE` | 409 | Station already has an available connector |
| `STATION_ALREADY_IN_FLEET` | 409 | Station is already in this fleet |
| `STATION_ID_EXISTS` | 409 | A station with this name already exists. Please choose a different name. |
| `STATION_NOT_FOUND` | 400, 404 | Station not found |
| `STATION_OFFLINE` | 400, 403, 409 | Station is offline |
| `STATION_REJECTED` | 502 | Station rejected start: ... |
| `STATION_SECURITY_CHANGE_REJECTED` | 502 | The station did not accept the security change; its current settings are unchanged |
| `STATION_TIMEOUT` | 504 | Station did not respond |
| `STATION_TLS_URL_NOT_CONFIGURED` | 400 | The public TLS address for stations (OCPP_STATION_TLS_URL) is not configured |
| `STATION_UNAVAILABLE` | 409 | This station is unavailable right now. Try another station. |
| `STATION_WATCH_NOT_FOUND` | 404 | Watch not found |
| `STATUS_CHECK_REJECTED` | 502 | Station rejected the status check |
| `STATUS_CHECK_TIMEOUT` | 504 | Status check timed out. Replug the connector and try again. |
| `STORAGE_CONNECTION_FAILED` | 400 | Storage connection test failed |
| `STORAGE_NOT_CONFIGURED` | 400, 404 | Attachment storage not configured |
| `SUPPORT_AI_NOT_CONFIGURED` | 400 | Support AI is not configured |
| `SUPPORT_CASE_NOT_FOUND` | 404 | Support case not found |
| `SUPPORT_DISABLED` |  | Support is disabled |
| `TARIFF_IN_USE` | 409 | Tariff is referenced by charging sessions and cannot be deleted |
| `TARIFF_NOT_FOUND` | 404 | Tariff not found |
| `TARIFF_OVERLAP` | 409 | Tariff overlaps with an existing tariff |
| `TEMPLATE_NOT_FOUND` | 404 | Template not found |
| `TOKEN_DUPLICATE` | 409 | Token already registered |
| `TOKEN_IN_USE` | 409 | Token is currently in use by an active charging session |
| `TOKEN_NOT_FOUND` | 404 | Token not found |
| `TOO_MANY_WATCHES` | 409 | You are watching too many stations |
| `TOTP_NOT_CONFIGURED` | 400 | TOTP not set up |
| `TRANSACTION_NOT_FOUND` | 404 | Transaction not found |
| `UNAUTHORIZED` | 401 | Unauthorized |
| `UNKNOWN_ACTION` | 404 | Unknown OCPP action |
| `USER_NOT_FOUND` | 400, 404 | User not found |
| `VALIDATION_ERROR` | 400 | Validation error |
| `VEHICLE_NOT_FOUND` | 404 | Vehicle not found |
| `VENDOR_NOT_FOUND` | 404 | Vendor not found |
| `WEAK_PASSWORD` | 400 | Password does not meet complexity requirements |
| `WEBHOOK_NOT_CONFIGURED` | 500 | Webhook not configured |
| `WEBHOOK_SIGNATURE_INVALID` | 400, 401 | Invalid signature |
| `WEBHOOK_SIGNATURE_MISSING` | 400, 401 | Missing webhook signature or credentials |
| `retry` |  | Try Again |
| `serverDown` |  | Unable to Connect |
| `serverDownDescription` |  | The server is not responding. Please check that the API service is running and try again. |
| `unknown` |  | An unexpected error occurred |
