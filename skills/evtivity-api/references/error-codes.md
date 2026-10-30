# EVtivity API error codes

Generated from EVtivity CSMS v0.1.49-beta.5 (https://github.com/EVtivity/evtivity-csms, commit faa640e387de) by `scripts/generate-api-reference.py`: the English
messages of the CSMS and the statuses in its OpenAPI spec. Do not edit by hand.
Catalog with localized messages: https://www.evtivity.com/api-reference/error-codes

Every error response is JSON: `{ "error": "<message>", "code": "<CODE>" }`.
Match on `code`, never on the message. HTTP lists the statuses the spec documents.

| Code | HTTP | Message |
|---|---|---|
| `ACCOUNT_DEACTIVATED` | 401 | Account deactivated |
| `ACCOUNT_DISABLED` | 401, 403 | Account disabled |
| `AI_ACTION_EXPIRED` | 409 | The AI action expired. Ask the assistant again |
| `AI_ACTION_INVALID` | 409 | The AI action no longer matches or was already rejected |
| `AI_ACTION_NOT_FOUND` | 404 | AI action not found |
| `AI_ATTACHMENT_REJECTED` | 400 | The attachment was rejected: its content does not match its type or could not be processed |
| `AI_ATTACHMENT_TOO_LARGE` | 400 | The attachment is too large, or the message has too many attachments |
| `AI_ATTACHMENT_TYPE_NOT_ALLOWED` | 400 | This file type is not allowed |
| `AI_ATTACHMENT_UNSUPPORTED` | 400 | The selected AI model cannot read this attachment type |
| `AI_BASE_URL_INVALID` | 400 | The AI provider base URL must be an https URL without credentials on a public host |
| `AI_BUDGET_EXCEEDED` | 429 | Your daily AI usage limit is reached |
| `AI_CONFIRMATION_REQUIRES_SESSION` | 403 | Confirm this action while signed in to the dashboard, not with an API key |
| `AI_CONTEXT_NOT_FOUND` | 404 | Explain context not found |
| `AI_CONVERSATION_BUSY` | 409 | The assistant is still answering in this conversation. Wait for it to finish or stop it |
| `AI_CONVERSATION_NOT_FOUND` | 404 | Conversation not found |
| `AI_ERROR` |  | Failed to process AI request |
| `AI_INSIGHTS_DISABLED` | 400 | Automatic insights are turned off |
| `AI_INSIGHTS_NOT_IN_SCOPE` | 409 | AI insights are not on for this site or station. Add it to the AI insights scope in Settings first |
| `AI_INSIGHT_COOLDOWN` | 429 | This insight was regenerated recently. Try again later |
| `AI_INSIGHT_NOT_FOUND` | 404 | Insight not found |
| `AI_MCP_RATE_LIMITED` |  | Too many MCP requests. Try again later |
| `AI_MODEL_UNAVAILABLE` |  | The configured AI model does not exist or is retired |
| `AI_MONTHLY_BUDGET_EXCEEDED` | 429 | The monthly AI usage limit is reached |
| `AI_NOT_CONFIGURED` | 400 | AI is not configured |
| `AI_PROPOSAL_ALREADY_DECIDED` | 409 | This action was already decided |
| `AI_PROPOSAL_EXPIRED` | 409 | This action has expired |
| `AI_PROPOSAL_NOT_FOUND` | 404 | Action not found |
| `AI_PROPOSAL_STALE` | 409 | This action no longer applies because the situation changed |
| `AI_PROVIDER_AUTH_FAILED` |  | The AI provider refused the configured API key |
| `AI_PROVIDER_QUOTA_EXCEEDED` |  | The AI provider account is out of credit or quota. An administrator must add credit or raise the quota |
| `AI_PROVIDER_RATE_LIMITED` |  | The AI provider is rate limiting requests. Try again shortly |
| `AI_PROVIDER_UNAVAILABLE` |  | The AI provider is unavailable. Try again later |
| `AI_RATE_LIMITED` | 429 | Too many AI requests. Try again in a minute |
| `AI_SITE_BUDGET_EXCEEDED` | 429 | The site's daily AI usage limit is reached |
| `ALERT_NOT_FOUND` | 404 | Alert not found |
| `ALREADY_FAVORITED` | 409 | Already favorited |
| `ALREADY_VERIFIED` | 400 | Email already verified |
| `API_KEY_EXPIRED` |  | API key expired |
| `API_KEY_NOT_FOUND` | 404 | API key not found |
| `API_KEY_RATE_LIMITED` |  | API key rate limit exceeded |
| `ATTACHMENT_NOT_FOUND` | 404 | Attachment not found |
| `ATTESTATION_FAILED` | 403 | Device attestation failed. Update the app and try again. |
| `AUDIT_ENTITY_TYPE_INVALID` | 400 | Unknown audit entity type |
| `AUTOCHARGE_CLAIM_REQUIRED` | 409 | Autocharge works only with vehicle ids a charger sent in one of your sessions. Use the vehicle id from a session first. |
| `CAMPAIGN_NOT_ACTIVE` | 409 | Only active campaigns can be cancelled |
| `CAMPAIGN_NOT_FOUND` | 404 | Campaign not found |
| `CASE_NOT_FOUND` | 404 | Case not found |
| `CA_CERT_NOT_FOUND` | 404 | CA certificate not found |
| `CDR_NOT_CREDITED` | 409 | Credit every CDR of the session before reissuing it |
| `CDR_NOT_FOUND` | 404 | CDR not found |
| `CDR_PUSH_NOT_FAILED` | 409 | Only a CDR whose push failed can be pushed again |
| `CHARGING_PROFILE_ID_RESERVED` | 400 | The charging profile ID must be above the station's MaxExternalConstraintsId. |
| `CHARGING_PROFILE_LOAD_MANAGED` | 400 | Load management sets the limit of this station. Use a ChargingStationMaxProfile with stack level 0 and an ID other than the load management profile ID. |
| `CIRCUIT_NOT_FOUND` | 404 | Circuit not found |
| `COMMAND_ERROR` |  | Command failed |
| `COMMAND_FAILED` | 502 | Command failed |
| `COMMAND_QUEUED` |  | Station offline, command queued |
| `COMMAND_TIMEOUT` | 504 | No response from station |
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
| `DATA_PLAN_SETTING_IN_TEMPLATE` | 400 | Heartbeat and meter value settings come from Settings > Integrations & Features > OCPP and the station data plan, not from a configuration template. |
| `DOWNTIME_NOT_FOUND` | 404 | Excluded downtime record not found |
| `DRIVER_AI_NOTICE_OUTDATED` | 409 | The AI notice has changed. Read it and choose again |
| `DRIVER_ALREADY_IN_FLEET` | 409 | Driver is already in this fleet |
| `DRIVER_CREATE_FAILED` | 500 | Failed to create driver |
| `DRIVER_ERASED` | 409 | The driver was erased |
| `DRIVER_HAS_ACTIVE_SESSION` | 409 | The driver has an active charging session |
| `DRIVER_INACTIVE` | 409 | Driver is inactive |
| `DRIVER_NOT_FLEET_MEMBER` | 409 | The driver is no longer a member of the fleet |
| `DRIVER_NOT_FOUND` | 400, 404 | Driver not found |
| `DUPLICATE_ALERT_RULE` | 409 | An alert rule for this component and variable already exists |
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
| `EMAIL_NOT_CONFIGURED` | 400 | Email provider not configured |
| `EMAIL_NOT_VERIFIED` |  | Email not verified |
| `EMAIL_REQUIRED` | 400 | Email required for paid charging |
| `EMAIL_SEND_FAILED` | 500 | Failed to send email |
| `ENCRYPTION_KEY_MISSING` | 500 | SETTINGS_ENCRYPTION_KEY not configured on server |
| `EVSE_HAS_HISTORY` | 409 | The EVSE or connector has charging history and cannot be deleted. Retire it instead. |
| `EVSE_IN_USE` | 409 | Another session is already active on this connector |
| `EVSE_NOT_FOUND` | 404 | EVSE not found on this station |
| `EVSE_RESERVED` | 409 | The EVSE has an active or upcoming reservation. Cancel it before retiring the EVSE. |
| `FAVORITE_NOT_FOUND` | 404 | Favorite not found |
| `FLEET_ACCOUNT_BILLING_OFF` | 409 | The fleet does not bill on account |
| `FLEET_BILLING_CONTACT_REQUIRED` | 400 | The fleet needs at least one billing contact for automatic invoicing and invoice emails. |
| `FLEET_BILLING_OLD_PODS_CONNECTED` | 409 | A process of an older release is still connected. Finish the upgrade, then change the fleet billing. |
| `FLEET_BILLING_VERSION_CHECK_STALE` | 409 | The worker's version check has not run recently, so the upgrade cannot be confirmed. Check that the worker is running, then change the fleet billing. |
| `FLEET_CREDIT_LIMIT_REACHED` | 402 | The credit limit of the fleet your sessions are billed to is reached. Contact your fleet manager. |
| `FLEET_DISABLED` |  | Fleet is disabled |
| `FLEET_HAS_OPEN_BILLING` | 409 | The fleet has sessions billed to its account and cannot be deleted. Turn off account billing instead. |
| `FLEET_HAS_RESERVATIONS` | 409 | The fleet has fleet reservations and cannot be deleted. Reservations are kept as history. |
| `FLEET_INVOICE_NOTHING_TO_BILL` | 409 | The fleet has no unbilled sessions with a cost to invoice for this period. |
| `FLEET_INVOICE_PERIOD_EXISTS` | 409 | The fleet already has an invoice for this period. Credit it to bill the period again. |
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
| `INSUFFICIENT_PERMISSIONS` | 403 | Insufficient permissions |
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
| `INVALID_SITE_IDS` | 400 | One or more siteIds do not exist |
| `INVALID_TOKEN` | 400 | Invalid or expired reset link |
| `INVOICE_ALREADY_CREDITED` | 409 | The invoice is already credited by a credit note |
| `INVOICE_ALREADY_PAID` | 409 | The invoice is already paid |
| `INVOICE_CREATION_FAILED` | 400 | Failed to create invoice |
| `INVOICE_IS_CREDIT_NOTE` | 409 | A credit note cannot be marked paid or credited |
| `INVOICE_NOT_FOUND` | 404 | Invoice not found |
| `INVOICE_NOT_ISSUED` | 409 | The invoice must be issued for this action |
| `INVOICE_NOT_VOIDABLE` | 409 | Only a draft invoice can be voided. Correct an issued invoice with a credit note |
| `INVOICE_NO_DRIVER` | 400 | This invoice has no driver to send to |
| `INVOICE_NO_DRIVER_EMAIL` | 400 | The driver of this invoice has no email address |
| `INVOICE_NO_SESSIONS` | 400 | No uninvoiced sessions in the selected date range |
| `LOAD_NOT_FOUND` | 404 | Load not found |
| `LOCAL_CA_EXISTS` | 409 | A local contract CA already exists |
| `LOCAL_CA_NOT_CONFIGURED` | 409 | Create the local contract CA first |
| `LOCAL_CPO_SUB_CA_EXISTS` | 409 | The local contract CA already has its CPO Sub-CAs |
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
| `MESSAGE_REFRESH_FAILED` | 502 | Failed to refresh display messages |
| `MESSAGE_SEND_FAILED` | 502 | Failed to send display message |
| `MESSAGE_TIMEOUT` | 504 | Display message command timed out |
| `MFA_ALREADY_ENABLED` | 409 | MFA is already enabled. Disable it first before setting up a new method. |
| `MFA_CHALLENGE_EXHAUSTED` | 400 | Too many failed attempts. Request a new code. |
| `MFA_CODE_INVALID` | 400 | Invalid verification code |
| `MFA_ENROLLMENT_REQUIRED` | 401, 403 | Set up multi-factor authentication to sign in. |
| `MFA_LOCKED` | 429 | Too many wrong codes. Wait before you try again. |
| `MFA_METHOD_DISABLED` | 403 | MFA method is disabled |
| `MFA_NOT_CONFIGURED` | 400 | MFA not configured |
| `MFA_POLICY_UNAVAILABLE` | 503 | The MFA settings could not be checked. Try again in a few minutes. |
| `MFA_REQUIRED` |  | MFA verification required |
| `MFA_REQUIRED_BY_POLICY` | 409 | MFA is required for your role and cannot be turned off. |
| `MFA_RESEND_LIMITED` | 429 | Too many codes sent. Wait before you request another one. |
| `MFA_SETUP_UNAVAILABLE` | 403 | MFA is required to sign in, but no MFA method can be set up. Contact your administrator. |
| `MFA_TOKEN_EXPIRED` | 401 | Invalid or expired MFA token |
| `MFA_TOKEN_INVALID` | 400 | Invalid MFA token |
| `MFA_TOTP_NO_RESEND` | 400 | Cannot resend TOTP codes |
| `MISSING_PAYMENT_INTENT` | 400 | Payment intent missing |
| `MISSING_VERSION_URL` | 400 | Partner version URL is required for registration |
| `NOTIFICATION_EVENT_REQUIRED` | 400 | This notification is required for account access and cannot be turned off |
| `NOT_BLOCKED` | 409 | Station is not blocked |
| `NOT_CHARGING` | 400 | Session is not currently charging |
| `NOT_DRAFT` |  | Only draft campaigns can be updated |
| `NOT_FOUND` |  | Not found |
| `NOT_IMPLEMENTED` | 501 | Remote start on partner networks requires the OCPI Commands module |
| `NOT_PENDING` | 409 | Station is not pending approval |
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
| `PARTNER_ALREADY_CONNECTED` | 409 | Partner is already connected |
| `PARTNER_NOT_CONNECTED` | 400 | Partner must be connected to sync |
| `PARTNER_NOT_FOUND` | 404 | Partner not found |
| `PARTNER_NOT_REGISTERED` | 409 | A partner becomes connected through the OCPI credentials handshake |
| `PASSKEY_LIMIT_REACHED` | 409 | You have registered the maximum number of passkeys and security keys. Remove one first. |
| `PASSKEY_NOT_FOUND` | 404 | Passkey or security key not found. |
| `PASSWORD_REQUIRED` | 400 | Password required when upgrading to Basic Auth or TLS + Basic Auth |
| `PAYLOAD_TOO_LARGE` |  | The request is too large |
| `PAYMENT_CONFIG_NOT_FOUND` | 404 | No payment config for this site |
| `PAYMENT_FAILED` | 400 | Payment failed |
| `PAYMENT_METHOD_IN_USE` |  | Payment method is in use by an active charging session |
| `PAYMENT_METHOD_NOT_FOUND` | 404 | Payment method not found |
| `PAYMENT_METHOD_REQUIRED` | 400 | Payment method required |
| `PAYMENT_NOT_CONFIGURED` | 400 | Payment not configured for this station |
| `PAYMENT_NOT_FOUND` | 404 | No payment record for this session |
| `PAYMENT_OPERATION_PENDING` | 409 | The payment has an operation waiting for the provider's confirmation. Try again later. |
| `PAYMENT_PREAUTH_FAILED` | 402 | Payment authorization declined |
| `PAYMENT_PROVIDER_CONNECTION_FAILED` | 400 | Payment provider connection test failed |
| `PAYMENT_PROVIDER_NOT_CONFIGURED` | 400, 409 | Payment provider is not configured |
| `PAYMENT_PROVIDER_PERMISSION_MISSING` | 400 | The payment provider credential lacks a required permission |
| `PAYMENT_PROVIDER_UPGRADE_PENDING` | 409 | A process older than v0.1.38 is still connected. Finish the upgrade, then select Adyen. |
| `PAYMENT_RECORD_NOT_RECOVERABLE` | 409 | Payment record is not in a recoverable state |
| `PAYMENT_TERMINAL_BUSY` | 409 | The payment terminal already has a payment in progress |
| `PAYMENT_TERMINAL_DEVICE_TAKEN` | 409 | This device is already registered as a payment terminal |
| `PAYMENT_TERMINAL_EVSE_TAKEN` | 409 | Another active payment terminal is paired to this connector |
| `PAYMENT_TERMINAL_HARDWARE_MODE` | 400 | The charging station drives this hardware mode terminal; the CSMS cannot start payments on it |
| `PAYMENT_TERMINAL_HAS_SIM` | 409 | The payment terminal already has a SIM |
| `PAYMENT_TERMINAL_HAS_TRANSACTIONS` | 409 | The payment terminal has payments and cannot be deleted; deactivate it instead |
| `PAYMENT_TERMINAL_INACTIVE` | 409 | The payment terminal is inactive |
| `PAYMENT_TERMINAL_NOT_FOUND` | 404 | Payment terminal not found |
| `PAYMENT_TERMINAL_NOT_PAIRED` | 409 | The payment terminal is not paired to a charging station |
| `PAYMENT_TERMINAL_PROVIDER_ERROR` | 502 | The payment terminal provider request failed |
| `PAYMENT_TERMINAL_PROVIDER_NOT_CONFIGURED` | 400 | The payment terminal provider is off or has no credentials |
| `PAYMENT_TERMINAL_PROVIDER_UNVERIFIED` | 400 | The ID TECH integration is not verified for production use yet |
| `PAYMENT_TOP_UP_FAILED` | 502 | Payment top-up rejected |
| `PAYMENT_WEBHOOK_EXISTS` | 409 | An EVtivity webhook already exists for this provider |
| `PAYOUT_ACCOUNT_EXISTS` | 409 | The site already has a payout account |
| `PAYOUT_ACCOUNT_NOT_READY` | 409 | The site's payout account cannot receive payments yet |
| `PERMISSIONS_EXCEED_OWN` | 403 | Permissions must be a subset of your own permissions |
| `PHONE_REGISTRATION_LIMITED` | 429 | Too many accounts were registered with this phone number. Try again later. |
| `PKI_ROOT_REFRESH_FAILED` | 502 | Root certificate refresh from the PKI provider failed |
| `PNC_CONTRACT_NOT_FOUND` | 404 | Plug & Charge contract not found |
| `PNC_CONTRACT_TOKEN_LOCKED` | 409 | This token belongs to a Plug & Charge contract. Manage it through the driver's contracts. |
| `PNC_DISABLED` |  | Plug & Charge is disabled |
| `PORTAL_ALREADY_ACTIVE` | 409 | Driver already has portal access |
| `PORTAL_REGISTRATION_DISABLED` | 403 | Driver self-registration is disabled. Contact your operator to be invited. |
| `PREPAID_BALANCE_CONFLICT` | 409 | The prepaid balance changed since you opened the form, for example after a session. Reload the token and enter the balance again. |
| `PRE_AUTH_FAILED` |  | Payment pre-authorization failed |
| `PRICING_ASSIGNMENT_NOT_FOUND` | 404 | No pricing group is assigned to this entity |
| `PRICING_GROUP_DEFAULT_EXISTS` | 409 | Another pricing group is already the default |
| `PRICING_GROUP_NOT_FOUND` | 404 | Pricing group not found |
| `PRICING_GROUP_TARIFFS_IN_USE` | 409 | Pricing group has tariffs referenced by charging sessions |
| `PRICING_NOT_FOUND` | 404 | No pricing found |
| `PRIVATE_URL` | 400 | Version URL must not point to a private or internal address |
| `PROFILE_ID_ALLOC_FAILED` |  | Could not allocate a free profileId |
| `PROFILE_ID_IN_USE` | 409 | profileId ... is already used by another template |
| `PROVIDER_TEST_FAILED` |  | Provider returned ... |
| `PUSH_NOT_FOUND` | 404 | Push not found |
| `PUSH_REJECTED` | 502 | Station rejected push: ... |
| `QR_SCAN_REQUIRED` | 403 | Scan the QR code shown on the charger to start charging. |
| `RATE_LIMITED` | 429 | Too many requests. Wait a moment and try again. |
| `RECAPTCHA_FAILED` | 403 | reCAPTCHA verification failed |
| `RECAPTCHA_REQUIRED` | 400 | reCAPTCHA token is required |
| `RECAPTCHA_SECRET_REQUIRED` | 400 | A reCAPTCHA secret key is required to enable reCAPTCHA |
| `REFUND_EXCEEDS_REMAINING` | 400, 409 | Refund amount exceeds remaining ... |
| `REFUND_TOP_UP_UNKNOWN` | 409 | This payment includes a top-up charge with no recorded payment id. Refund the top-up in the payment provider's dashboard. |
| `REGION_NOT_FOUND` | 404 | Region not found |
| `REPORT_NOT_FOUND` | 404 | Report not found |
| `RESERVATION_BUFFER_ACTIVE` | 409 | This connector has an upcoming reservation and cannot start a new session |
| `RESERVATION_CONFLICT` | 409 | An active reservation already exists for this station |
| `RESERVATION_CREATE_FAILED` | 500 | Failed to create reservation |
| `RESERVATION_DISABLED` | 403 | Reservations are disabled |
| `RESERVATION_DURING_MAINTENANCE` | 409 | Reservation falls within a scheduled maintenance window |
| `RESERVATION_EXPIRES_TOO_SOON` | 400 | Reservation must end at least 60 seconds in the future |
| `RESERVATION_FEE_ALREADY_INVOICED` | 409 | The reservation fee is already invoiced |
| `RESERVATION_NOT_ACTIVE` | 400, 409 | Reservation is not active |
| `RESERVATION_NOT_FOUND` | 404 | Reservation not found |
| `RESERVATION_REJECTED` | 400, 502 | Station rejected reservation: ... |
| `RESERVATION_STARTS_IN_PAST` | 400 | Reservation start time cannot be in the past |
| `RESERVATION_TIMEOUT` | 504 | Reservation command timed out |
| `RESERVATION_TOO_LONG` | 400 | Reservation cannot exceed ... hours |
| `RESERVATION_WINDOW_TOO_SHORT` | 400 | Reservation must end at least 60 seconds after it starts |
| `ROAMING_DISABLED` |  | Roaming is disabled |
| `ROLE_NOT_FOUND` | 400 | Role does not exist |
| `ROTATION_NOT_APPLICABLE` | 400 | Credential rotation only applies to security profiles 1 and 2 |
| `RULE_NOT_FOUND` | 404 | Rule not found |
| `SCHEDULE_NOT_FOUND` | 404 | Schedule not found |
| `SCHEMA_NOT_FOUND` | 404 | Schema not found |
| `SECURITY_PROFILE_DOWNGRADE` | 400 | A connected station cannot be moved to a lower security profile |
| `SELF_EDIT_FORBIDDEN` | 403 | Cannot edit your own role, status, or site access |
| `SESSION_ALREADY_ACTIVE` | 400 | You already have an active charging session |
| `SESSION_ALREADY_INVOICED` | 409 | The session is already invoiced |
| `SESSION_CREATE_FAILED` | 500 | Failed to create session |
| `SESSION_NOT_ACTIVE` | 409 | The session is not active |
| `SESSION_NOT_FOUND` | 400, 404 | Session not found |
| `SESSION_NOT_LINKED` | 400 | Session not linked to this case |
| `SESSION_NOT_ON_ACCOUNT` | 409 | The session is not billed on account to a fleet |
| `SESSION_NO_VEHICLE_ID` | 409 | The charger sent no vehicle id for this session. |
| `SESSION_REBILL_IN_PROGRESS` | 409 | The session is being billed. Try again in a few minutes. |
| `SESSION_REBILL_NOT_ELIGIBLE` | 409 | This session cannot be billed |
| `SESSION_REBILL_PAYMENT_PENDING` | 409 | The session has a payment the provider has not settled yet. Try again later. |
| `SESSION_REQUIRED` | 403 | This action needs a signed-in session. API keys cannot use it. |
| `SESSION_STOP_REJECTED` | 409 | The station rejected the stop request. The session is still charging. |
| `SETTING_NOT_FOUND` | 404 | Setting not found |
| `SIM_ACTION_UNSUPPORTED` | 409 | The SIM provider does not support this action for this SIM |
| `SIM_ATTACHED` | 409 | Detach the SIM from its station before deleting it |
| `SIM_ATTACHED_ELSEWHERE` | 409 | This SIM is attached to another station |
| `SIM_ATTACHMENT_CHANGED` | 409 | The SIM attachment changed since it was shown. Check the SIM and confirm again |
| `SIM_ATTACHMENT_NOT_CONFIRMED` | 409 | Confirm the SIM before resetting its network |
| `SIM_FEATURE_DISABLED` | 400 | SIM providers and station signal reads are turned off |
| `SIM_INACTIVE` | 409 | This SIM is inactive. Reactivate it first |
| `SIM_NOT_FOUND` | 404 | SIM not found |
| `SIM_PROVIDER_ERROR` | 502 | The SIM provider request failed |
| `SIM_PROVIDER_NOT_CONFIGURED` | 400 | No SIM provider is configured |
| `SIM_PROVIDER_RATE_LIMITED` | 429 | Too many SIM requests, try again later |
| `SIM_RESET_UNAVAILABLE` | 503 | The network reset cannot be started right now. Try again in a minute |
| `SIM_TEST_UNAVAILABLE` | 503 | The connection test cannot run right now. Try again in a minute |
| `SITE_HAS_STATIONS` | 409 | Cannot delete site with stations. Remove or reassign stations first. |
| `SITE_NOT_FOUND` | 404 | Site not found |
| `SITE_PAYMENT_CONFIG_IN_USE` | 409 | This site's payment configuration has payments and cannot be deleted. Disable it instead. |
| `SMS_NOT_CONFIGURED` | 400 | SMS provider not configured |
| `SMS_SEND_FAILED` | 500 | Failed to send SMS |
| `SSO_DISABLED` | 400 | SSO is not configured |
| `START_REJECTED` | 502 | Station rejected start request: ... |
| `STATION_ALREADY_AVAILABLE` | 409 | Station already has an available connector |
| `STATION_ALREADY_IN_FLEET` | 409 | Station is already in this fleet |
| `STATION_CREDENTIALS_ROUTE_REQUIRED` | 400 | Station passwords are changed with POST /v1/stations/:id/credentials, not with a generic OCPP command |
| `STATION_ENDPOINT_URL_UNKNOWN` | 400 | The address this station connects on is not known yet. It is recorded when the station next connects. |
| `STATION_HAS_ACTIVE_SESSION` | 409 | The station has an active charging session. Stop it before deleting the station. |
| `STATION_HAS_SIM` | 409 | This station already has a SIM attached. Detach it first |
| `STATION_ID_EXISTS` | 409 | A station with this name already exists. Please choose a different name. |
| `STATION_NOT_FOUND` | 400, 404 | Station not found |
| `STATION_OFFLINE` | 400, 403, 409 | Station is offline |
| `STATION_ONLINE` | 409 | The station is online. Stop the session at the station instead. |
| `STATION_REJECTED` | 502 | Station rejected start: ... |
| `STATION_SECURITY_CHANGE_REJECTED` | 502 | The station did not accept the security change; its current settings are unchanged |
| `STATION_SECURITY_ROUTE_REQUIRED` | 400 | Station security profiles and network profiles are changed with PATCH /v1/stations/:id, not with a configuration template |
| `STATION_SITE_SUPPRESSED` | 409 | The AI insights of the station's site are suppressed. Resume the site to resume its stations |
| `STATION_TIMEOUT` | 504 | Station did not respond |
| `STATION_TLS_URL_NOT_CONFIGURED` | 400 | The public TLS address for stations (OCPP_STATION_TLS_URL) is not configured |
| `STATION_UNAVAILABLE` | 409 | This station is unavailable right now. Try another station. |
| `STATION_WATCH_NOT_FOUND` | 404 | Watch not found |
| `STATUS_CHECK_REJECTED` | 502 | Station rejected the status check |
| `STATUS_CHECK_TIMEOUT` | 504 | Status check timed out. Replug the connector and try again. |
| `STORAGE_CONNECTION_FAILED` | 400 | Storage connection test failed |
| `STORAGE_NOT_CONFIGURED` | 400, 404 | Attachment storage not configured |
| `STREAM_LIMIT_REACHED` |  | Too many live station updates are open from this device. Close other tabs and try again. |
| `SUPPORT_AI_NOT_CONFIGURED` | 400 | Support AI is not configured |
| `SUPPORT_CASE_AI_NOT_AWAITING_FEEDBACK` | 409 | This support case is not waiting for feedback on an automatic answer |
| `SUPPORT_CASE_NOT_FOUND` | 404 | Support case not found |
| `SUPPORT_DISABLED` |  | Support is disabled |
| `TARIFF_DEFAULT_REQUIRED` | 409 | A pricing group with tariffs needs one active default tariff without restrictions |
| `TARIFF_IN_USE` | 409 | Tariff is referenced by charging sessions and cannot be deleted |
| `TARIFF_NOT_FOUND` | 404 | Tariff not found |
| `TARIFF_OVERLAP` | 409 | Tariff overlaps with an existing tariff |
| `TEMPLATE_NOT_FOUND` | 404 | Template not found |
| `TERMINAL_TRANSACTION_NOT_FOUND` | 404 | Terminal payment not found |
| `TERMINAL_TRANSACTION_STATE` | 409 | The terminal payment cannot do this in its current state |
| `TOKEN_BLOCKED_BY_OPERATOR` | 403 | This card was deactivated by the operator. Contact the operator to reactivate it. |
| `TOKEN_DUPLICATE` | 409 | Token already registered |
| `TOKEN_IN_USE` | 409 | Token is currently in use by an active charging session |
| `TOKEN_NOT_FOUND` | 404 | Token not found |
| `TOO_MANY_WATCHES` | 409 | You are watching too many stations |
| `TOTP_NOT_CONFIGURED` | 400 | TOTP not set up |
| `TRANSACTION_NOT_FOUND` | 404 | Transaction not found |
| `UNAUTHORIZED` | 401 | Unauthorized |
| `UNKNOWN_ACTION` | 404 | Unknown OCPP action |
| `UNSUPPORTED_MEDIA_TYPE` |  | Unsupported content type |
| `USER_NOT_FOUND` | 400, 404 | User not found |
| `USER_SSO_MANAGED` | 409 | This user signs in with SSO and has no password to set. |
| `VALIDATION_ERROR` | 400 | Validation error |
| `VEHICLE_BLOCKED_BY_OPERATOR` | 403 | The operator blocked Autocharge for this vehicle. Contact the operator to unblock it. |
| `VEHICLE_ID_IN_USE` | 409 | Another vehicle already uses this VIN or EVCCID for Autocharge. |
| `VEHICLE_ID_REQUIRED` | 400 | Autocharge needs a VIN or an EVCCID on the vehicle. |
| `VEHICLE_NOT_FOUND` | 404 | Vehicle not found |
| `VENDOR_NOT_FOUND` | 404 | Vendor not found |
| `VERIFICATION_RESEND_LIMITED` | 429 | Too many verification emails. Wait before you request another one. |
| `WEAK_PASSWORD` | 400 | Password does not meet complexity requirements |
| `WEBAUTHN_CHALLENGE_EXPIRED` | 400 | The passkey request expired or was already used. Try again. |
| `WEBAUTHN_VERIFICATION_FAILED` | 400 | The passkey or security key could not be verified. |
| `WEBHOOK_NOT_CONFIGURED` | 500 | Webhook not configured |
| `WEBHOOK_SIGNATURE_INVALID` | 400, 401 | Invalid signature |
| `WEBHOOK_SIGNATURE_MISSING` | 400, 401 | Missing webhook signature or credentials |
| `WEB_PAYMENTS_NOT_SUPPORTED` | 409 | The station does not support dynamic QR codes |
| `retry` |  | Try Again |
| `serverDown` |  | Unable to Connect |
| `serverDownDescription` |  | The server is not responding. Please check that the API service is running and try again. |
| `unknown` |  | An unexpected error occurred |
