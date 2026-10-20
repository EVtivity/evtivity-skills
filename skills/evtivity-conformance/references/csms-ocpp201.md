Generated from https://www.evtivity.com/docs/conformance/csms-ocpp201. Do not edit.

# OCPP 2.0.1 CSMS Results

OCTT test case results for the EVtivity CSMS on OCPP 2.0.1, by certification profile and module.

## Overview

These are the OCTT test cases for the CSMS role in OCPP 2.0.1 (Edition 4, Part 6). The test runner acts as a charging station that connects over the `ocpp2.0.1` subprotocol and checks how the EVtivity CSMS responds. See [OCPP Conformance Testing](https://www.evtivity.com/docs/conformance/overview) for how tests run and how results are counted.

> **Note:**
>
> This is a self-run conformance check: EVtivity runs its own implementation of the Open Charge Alliance test cases. It is not an Open Charge Alliance certificate. It shows how the CSMS performs on the test cases that an official certification test uses.

Results as of 2026-10-20.

## Results by certification profile

OCPP 2.0.1 Part 5 (Certification Profiles) lists each test case in one or more profiles: Core, Advanced Security, Smart Charging, and ISO 15118 Support. Within a profile, a test case is mandatory or conditional. Test cases that Part 6 defines but no profile lists are informative. A test case listed in more than one profile counts in each.

| Certification profile | Requirement | Total | Passed |
|---|---|---|---|
| Core | Mandatory | 104 | 104 |
| Core | Conditional | 83 | 83 |
| Advanced Security | Mandatory | 4 | 4 |
| Smart Charging | Mandatory | 21 | 21 |
| Smart Charging | Conditional | 1 | 1 |
| ISO 15118 Support | Mandatory | 36 | 36 |
| ISO 15118 Support | Conditional | 1 | 1 |
| Informative (no profile) | - | 20 | 20 |

## Results by module

| Module | Total | Passed |
|---|---|---|
| A - Security | 13 | 13 |
| B - Provisioning | 22 | 22 |
| C - Authorization | 16 | 16 |
| D - Local Authorization List | 6 | 6 |
| E - Transactions | 27 | 27 |
| F - Remote Control | 15 | 15 |
| G - Availability | 10 | 10 |
| H - Reservation | 9 | 9 |
| I - Tariff and Cost | 2 | 2 |
| J - Meter Values | 9 | 9 |
| K - Smart Charging | 32 | 32 |
| L - Firmware Management | 19 | 19 |
| M - Certificate Management | 18 | 18 |
| N - Diagnostics | 30 | 30 |
| O - Display Message | 21 | 21 |
| P - Data Transfer | 2 | 2 |
| **Total** | **251** | **251** |

## Not applicable

These test cases need a feature EVtivity does not include. They are not run and do not count as passed.

Every test case in this suite applies.

## Test cases

### A - Security

13 tests

| Test ID | Name | Status |
|---|---|---|
| TC_A_01_CSMS | Basic Authentication - Valid username/password combination | Passed |
| TC_A_02_CSMS | Basic Authentication - Username does not equal ChargingStationId | Passed |
| TC_A_03_CSMS | Basic Authentication - Invalid password | Passed |
| TC_A_04_CSMS | TLS - server-side certificate - Valid certificate | Passed |
| TC_A_06_CSMS | TLS - server-side certificate - TLS version too low | Passed |
| TC_A_07_CSMS | TLS - Client-side certificate - valid certificate | Passed |
| TC_A_08_CSMS | TLS - Client-side certificate - Invalid certificate | Passed |
| TC_A_09_CSMS | Update Charging Station Password for HTTP Basic Authentication - Accepted | Passed |
| TC_A_10_CSMS | Update Charging Station Password for HTTP Basic Authentication - Rejected | Passed |
| TC_A_11_CSMS | Update Charging Station Certificate by request of CSMS - Success - Charging Station Certificate | Passed |
| TC_A_12_CSMS | Update Charging Station Certificate by request of CSMS - Success - V2G Certificate | Passed |
| TC_A_14_CSMS | Update Charging Station Certificate by request of CSMS - Invalid certificate | Passed |
| TC_A_19_CSMS | Upgrade Charging Station Security Profile - Accepted | Passed |

### B - Provisioning

22 tests

| Test ID | Name | Status |
|---|---|---|
| TC_B_01_CSMS | Cold Boot Charging Station - Accepted | Passed |
| TC_B_02_CSMS | Cold Boot Charging Station - Pending | Passed |
| TC_B_06_CSMS | Get Variables - single value | Passed |
| TC_B_07_CSMS | Get Variables - multiple values | Passed |
| TC_B_08_CSMS | Get Variables - limit to maximum number of values | Passed |
| TC_B_09_CSMS | Set Variables - single value | Passed |
| TC_B_10_CSMS | Set Variables - multiple values | Passed |
| TC_B_12_CSMS | Get Base Report - ConfigurationInventory | Passed |
| TC_B_13_CSMS | Get Base Report - FullInventory | Passed |
| TC_B_14_CSMS | Get Base Report - SummaryInventory | Passed |
| TC_B_18_CSMS | Get Custom Report - with componentCriteria and component/variables | Passed |
| TC_B_20_CSMS | Reset Charging Station - Without ongoing transaction - OnIdle | Passed |
| TC_B_21_CSMS | Reset Charging Station - With Ongoing Transaction - OnIdle | Passed |
| TC_B_22_CSMS | Reset Charging Station - With Ongoing Transaction - Immediate | Passed |
| TC_B_25_CSMS | Reset EVSE - Without ongoing transaction | Passed |
| TC_B_26_CSMS | Reset EVSE - With Ongoing Transaction - OnIdle | Passed |
| TC_B_27_CSMS | Reset EVSE - With Ongoing Transaction - Immediate | Passed |
| TC_B_30_CSMS | Cold Boot Charging Station - Pending/Rejected - SecurityError | Passed |
| TC_B_31_CSMS | Cold Boot Charging Station - Pending/Rejected - TriggerMessage | Passed |
| TC_B_42_CSMS | Set new NetworkConnectionProfile - Accepted | Passed |
| TC_B_44_CSMS | Set new NetworkConnectionProfile - Failed | Passed |
| TC_B_58_CSMS | WebSocket Subprotocol validation | Passed |

### C - Authorization

16 tests

| Test ID | Name | Status |
|---|---|---|
| TC_C_02_CSMS | Local start transaction - Authorization Invalid/Unknown | Passed |
| TC_C_06_CSMS | Local start transaction - Authorization Blocked | Passed |
| TC_C_07_CSMS | Local start transaction - Authorization Expired | Passed |
| TC_C_08_CSMS | Authorization through authorization cache - Accepted | Passed |
| TC_C_20_CSMS | Authorization through authorization cache - Invalid | Passed |
| TC_C_37_CSMS | Clear Authorization Data in Authorization Cache - Accepted | Passed |
| TC_C_38_CSMS | Clear Authorization Data in Authorization Cache - Rejected | Passed |
| TC_C_39_CSMS | Authorization by GroupId - Success | Passed |
| TC_C_40_CSMS | Authorization by GroupId - Success with Local Authorization List | Passed |
| TC_C_43_CSMS | Authorization by GroupId - Invalid status with Local Authorization List | Passed |
| TC_C_47_CSMS | Stop Transaction with a Master Pass - With UI - All transactions | Passed |
| TC_C_48_CSMS | Stop Transaction with a Master Pass - With UI - Specific transactions | Passed |
| TC_C_49_CSMS | Stop Transaction with a Master Pass - Without UI | Passed |
| TC_C_50_CSMS | Authorization using Contract Certificates 15118 - Online - Local validation - Accepted | Passed |
| TC_C_51_CSMS | Authorization using Contract Certificates 15118 - Online - Local validation - Rejected | Passed |
| TC_C_52_CSMS | Authorization using Contract Certificates 15118 - Online - Central validation - Accepted | Passed |

### D - Local Authorization List

6 tests

| Test ID | Name | Status |
|---|---|---|
| TC_D_01_CSMS | Send Local Authorization List - Full | Passed |
| TC_D_02_CSMS | Send Local Authorization List - Differential Update | Passed |
| TC_D_03_CSMS | Send Local Authorization List - Differential Remove | Passed |
| TC_D_04_CSMS | Send Local Authorization List - Full with empty list | Passed |
| TC_D_08_CSMS | Get Local List Version - Success | Passed |
| TC_D_09_CSMS | Get Local List Version - No list available | Passed |

### E - Transactions

27 tests

| Test ID | Name | Status |
|---|---|---|
| TC_E_01_CSMS | Start transaction options - PowerPathClosed | Passed |
| TC_E_02_CSMS | Start transaction options - EnergyTransfer | Passed |
| TC_E_03_CSMS | Local start transaction - Cable plugin first - Success | Passed |
| TC_E_04_CSMS | Local start transaction - Authorization first - Success | Passed |
| TC_E_07_CSMS | Stop transaction options - PowerPathClosed - Local stop | Passed |
| TC_E_08_CSMS | Stop transaction options - EnergyTransfer stopped - StopAuthorized | Passed |
| TC_E_09_CSMS | Start transaction options - EVConnected | Passed |
| TC_E_10_CSMS | Start transaction options - Authorized - Local | Passed |
| TC_E_11_CSMS | Start transaction options - DataSigned | Passed |
| TC_E_12_CSMS | Start transaction options - ParkingBayOccupied | Passed |
| TC_E_14_CSMS | Stop transaction options - EVDisconnected - Charging Station side | Passed |
| TC_E_15_CSMS | Stop transaction options - StopAuthorized - Local | Passed |
| TC_E_16_CSMS | Stop transaction options - Deauthorized - Invalid idToken | Passed |
| TC_E_17_CSMS | Stop transaction options - Deauthorized - EV side disconnect | Passed |
| TC_E_19_CSMS | Stop transaction options - ParkingBayUnoccupied | Passed |
| TC_E_20_CSMS | Stop transaction options - EVDisconnected - EV side | Passed |
| TC_E_21_CSMS | Stop transaction options - StopAuthorized - Remote | Passed |
| TC_E_22_CSMS | Stop transaction options - EnergyTransfer stopped - SuspendedEV | Passed |
| TC_E_26_CSMS | Disconnect cable on EV-side - Suspend transaction | Passed |
| TC_E_29_CSMS | Check Transaction status - ongoing - with messages in queue | Passed |
| TC_E_30_CSMS | Check Transaction status - ongoing - without messages in queue | Passed |
| TC_E_31_CSMS | Check Transaction status - ended - with messages in queue | Passed |
| TC_E_33_CSMS | Check Transaction status - without transactionId - with messages in queue | Passed |
| TC_E_34_CSMS | Check Transaction status - without transactionId - without messages in queue | Passed |
| TC_E_38_CSMS | Local start transaction - EV not ready | Passed |
| TC_E_39_CSMS | Stop transaction options - Deauthorized - timeout | Passed |
| TC_E_53_CSMS | Reset Sequence Number - CSMS accepting seqNo = 0 at start of transaction | Passed |

### F - Remote Control

15 tests

| Test ID | Name | Status |
|---|---|---|
| TC_F_01_CSMS | Remote start transaction - Cable plugin first | Passed |
| TC_F_02_CSMS | Remote start transaction - Remote start first - AuthorizeRemoteStart is true | Passed |
| TC_F_03_CSMS | Remote start transaction - Remote start first - AuthorizeRemoteStart is false | Passed |
| TC_F_04_CSMS | Remote start transaction - Remote start first - Cable plugin timeout | Passed |
| TC_F_06_CSMS | Remote unlock Connector - Without ongoing transaction - Accepted | Passed |
| TC_F_11_CSMS | Trigger message - MeterValues - Specific EVSE | Passed |
| TC_F_12_CSMS | Trigger message - MeterValues - All EVSE | Passed |
| TC_F_13_CSMS | Trigger message - TransactionEvent - Specific EVSE | Passed |
| TC_F_14_CSMS | Trigger message - TransactionEvent - All EVSE | Passed |
| TC_F_15_CSMS | Trigger message - LogStatusNotification - Idle | Passed |
| TC_F_18_CSMS | Trigger message - FirmwareStatusNotification - Idle | Passed |
| TC_F_20_CSMS | Trigger message - Heartbeat | Passed |
| TC_F_23_CSMS | Trigger message - StatusNotification - Specific EVSE - Available | Passed |
| TC_F_24_CSMS | Trigger message - StatusNotification - Specific EVSE - Occupied | Passed |
| TC_F_27_CSMS | Trigger message - NotImplemented | Passed |

### G - Availability

10 tests

| Test ID | Name | Status |
|---|---|---|
| TC_G_03_CSMS | Change Availability EVSE - Operative to inoperative | Passed |
| TC_G_04_CSMS | Change Availability EVSE - Inoperative to operative | Passed |
| TC_G_05_CSMS | Change Availability Charging Station - Operative to inoperative | Passed |
| TC_G_06_CSMS | Change Availability Charging Station - Inoperative to operative | Passed |
| TC_G_07_CSMS | Change Availability Connector - Operative to inoperative | Passed |
| TC_G_08_CSMS | Change Availability Connector - Inoperative to operative | Passed |
| TC_G_11_CSMS | Change Availability EVSE - With ongoing transaction | Passed |
| TC_G_14_CSMS | Change Availability Charging Station - With ongoing transaction | Passed |
| TC_G_17_CSMS | Change Availability Connector - With ongoing transaction | Passed |
| TC_G_20_CSMS | Connector status Notification - Lock Failure | Passed |

### H - Reservation

9 tests

| Test ID | Name | Status |
|---|---|---|
| TC_H_01_CSMS | Reserve a specific EVSE - Accepted - Valid idToken | Passed |
| TC_H_07_CSMS | Reserve a specific EVSE - Reservation Ended / not used | Passed |
| TC_H_08_CSMS | Reserve an unspecified EVSE - Accepted | Passed |
| TC_H_14_CSMS | Reserve an unspecified EVSE - EVSEs equals reservations | Passed |
| TC_H_15_CSMS | Reserve a connector with a specific type - Success | Passed |
| TC_H_17_CSMS | Cancel reservation of an EVSE - Success | Passed |
| TC_H_19_CSMS | Reserve a specific EVSE - Use a reserved EVSE with GroupId | Passed |
| TC_H_20_CSMS | Charging Station cancels reservation when Faulted | Passed |
| TC_H_22_CSMS | Reserve a specific EVSE - Configured to Reject | Passed |

### I - Tariff and Cost

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_I_01_CSMS | Show EV Driver running total cost during charging - costUpdatedRequest | Passed |
| TC_I_02_CSMS | Show EV Driver Final Total Cost After Charging | Passed |

### J - Meter Values

9 tests

| Test ID | Name | Status |
|---|---|---|
| TC_J_01_CSMS | Clock-aligned Meter Values - No transaction ongoing | Passed |
| TC_J_02_CSMS | Clock-aligned Meter Values - Transaction ongoing | Passed |
| TC_J_03_CSMS | Clock-aligned Meter Values - EventType Ended | Passed |
| TC_J_04_CSMS | Clock-aligned Meter Values - Signed | Passed |
| TC_J_07_CSMS | Sampled Meter Values - EventType Started - EVSE known | Passed |
| TC_J_08_CSMS | Sampled Meter Values - Context Transaction.Begin - EVSE not known | Passed |
| TC_J_09_CSMS | Sampled Meter Values - EventType Updated | Passed |
| TC_J_10_CSMS | Sampled Meter Values - EventType Ended | Passed |
| TC_J_11_CSMS | Sampled Meter Values - Signed | Passed |

### K - Smart Charging

32 tests

| Test ID | Name | Status |
|---|---|---|
| TC_K_01_CSMS | Set Charging Profile - TxDefaultProfile - Specific EVSE | Passed |
| TC_K_02_CSMS | Set Charging Profile - TxProfile without ongoing transaction on the specified EVSE | Passed |
| TC_K_03_CSMS | Set Charging Profile - ChargingStationMaxProfile | Passed |
| TC_K_04_CSMS | Replace charging profile - With chargingProfileId | Passed |
| TC_K_05_CSMS | Clear Charging Profile - With chargingProfileId | Passed |
| TC_K_06_CSMS | Clear Charging Profile - With stackLevel/purpose combination for one profile | Passed |
| TC_K_08_CSMS | Clear Charging Profile - Without previous charging profile | Passed |
| TC_K_10_CSMS | Set Charging Profile - TxDefaultProfile - All EVSE | Passed |
| TC_K_15_CSMS | Set Charging Profile - Not Supported | Passed |
| TC_K_19_CSMS | Set Charging Profile - ChargingProfileKind is Recurring | Passed |
| TC_K_29_CSMS | Get Charging Profile - EvseId 0 | Passed |
| TC_K_30_CSMS | Get Charging Profile - EvseId > 0 | Passed |
| TC_K_31_CSMS | Get Charging Profile - No EvseId | Passed |
| TC_K_32_CSMS | Get Charging Profile - chargingProfileId | Passed |
| TC_K_33_CSMS | Get Charging Profile - EvseId > 0 + stackLevel | Passed |
| TC_K_34_CSMS | Get Charging Profile - EvseId > 0 + chargingLimitSource | Passed |
| TC_K_35_CSMS | Get Charging Profile - EvseId > 0 + chargingProfilePurpose | Passed |
| TC_K_36_CSMS | Get Charging Profile - EvseId > 0 + chargingProfilePurpose + stackLevel | Passed |
| TC_K_37_CSMS | Remote start transaction with charging profile - Success | Passed |
| TC_K_43_CSMS | Get Composite Schedule - Specific EVSE | Passed |
| TC_K_44_CSMS | Get Composite Schedule - Charging Station | Passed |
| TC_K_48_CSMS | EMS Control - Set / Update External Charging Limit (not on a transaction) | Passed |
| TC_K_50_CSMS | EMS Control - Reset / release external charging limit - Without ongoing transaction | Passed |
| TC_K_51_CSMS | EMS Control - Reset / release external charging limit - With ongoing transaction | Passed |
| TC_K_52_CSMS | EMS Control - Set / Update External Charging Limit - Report | Passed |
| TC_K_53_CSMS | Charging with load leveling based on High Level Communication - Success | Passed |
| TC_K_55_CSMS | Charging with load leveling based on High Level Communication - EV charging profile exceeds limits | Passed |
| TC_K_57_CSMS | Renegotiating a Charging Schedule - Initiated by EV | Passed |
| TC_K_58_CSMS | Renegotiating a Charging Schedule - Initiated by CSMS | Passed |
| TC_K_59_CSMS | Renegotiating a Charging Schedule - Initiated by CSMS - Send NotifyEVChargingNeeds | Passed |
| TC_K_60_CSMS | Set Charging Profile - TxProfile with ongoing transaction on the specified EVSE | Passed |
| TC_K_70_CSMS | Set Charging Profile - Multiple Profiles | Passed |

### L - Firmware Management

19 tests

| Test ID | Name | Status |
|---|---|---|
| TC_L_01_CSMS | Secure Firmware Update - Installation successful | Passed |
| TC_L_02_CSMS | Secure Firmware Update - InstallScheduled | Passed |
| TC_L_03_CSMS | Secure Firmware Update - DownloadScheduled | Passed |
| TC_L_04_CSMS | Secure Firmware Update - RevokedCertificate | Passed |
| TC_L_05_CSMS | Secure Firmware Update - InvalidCertificate | Passed |
| TC_L_06_CSMS | Secure Firmware Update - InvalidSignature | Passed |
| TC_L_07_CSMS | Secure Firmware Update - DownloadFailed | Passed |
| TC_L_08_CSMS | Secure Firmware Update - InstallVerificationFailed | Passed |
| TC_L_09_CSMS | Secure Firmware Update - InstallationFailed | Passed |
| TC_L_10_CSMS | Secure Firmware Update - AcceptedCanceled | Passed |
| TC_L_11_CSMS | Secure Firmware Update - Unable to cancel | Passed |
| TC_L_13_CSMS | Secure Firmware Update - Unable to download/install firmware with ongoing transaction | Passed |
| TC_L_17_CSMS | Publish Firmware - Published | Passed |
| TC_L_19_CSMS | Publish Firmware - Invalid Checksum | Passed |
| TC_L_20_CSMS | Publish Firmware - PublishFailed | Passed |
| TC_L_21_CSMS | Unpublish Firmware - Unpublished | Passed |
| TC_L_22_CSMS | Unpublish Firmware - NoFirmware | Passed |
| TC_L_23_CSMS | Unpublish Firmware - Download Ongoing | Passed |
| TC_L_24_CSMS | Publish Firmware - Download failed | Passed |

### M - Certificate Management

18 tests

| Test ID | Name | Status |
|---|---|---|
| TC_M_01_CSMS | Install CA certificate - CSMSRootCertificate | Passed |
| TC_M_02_CSMS | Install CA certificate - ManufacturerRootCertificate | Passed |
| TC_M_03_CSMS | Install CA certificate - V2GRootCertificate | Passed |
| TC_M_04_CSMS | Install CA certificate - MORootCertificate | Passed |
| TC_M_05_CSMS | Install CA certificate - Failed | Passed |
| TC_M_12_CSMS | Retrieve certificates - CSMSRootCertificate | Passed |
| TC_M_13_CSMS | Retrieve certificates - ManufacturerRootCertificate | Passed |
| TC_M_14_CSMS | Retrieve certificates - V2GRootCertificate | Passed |
| TC_M_15_CSMS | Retrieve certificates - V2GCertificateChain | Passed |
| TC_M_16_CSMS | Retrieve certificates - MORootCertificate | Passed |
| TC_M_17_CSMS | Retrieve certificates - CSMSRoot & ManufacturerRoot | Passed |
| TC_M_18_CSMS | Retrieve certificates - All certificateTypes | Passed |
| TC_M_19_CSMS | Retrieve certificates - No matching certificate found | Passed |
| TC_M_20_CSMS | Delete certificate from CS - Success | Passed |
| TC_M_21_CSMS | Delete certificate from CS - Failed | Passed |
| TC_M_24_CSMS | Get Charging Station Certificate status - Success | Passed |
| TC_M_26_CSMS | Certificate Installation EV - Success | Passed |
| TC_M_28_CSMS | Certificate Update EV - Success | Passed |

### N - Diagnostics

30 tests

| Test ID | Name | Status |
|---|---|---|
| TC_N_01_CSMS | Get Monitoring Report - with monitoringCriteria | Passed |
| TC_N_02_CSMS | Get Monitoring Report - with component/variable | Passed |
| TC_N_03_CSMS | Get Monitoring Report - with criteria and component/variable | Passed |
| TC_N_05_CSMS | Set Monitoring Base - success | Passed |
| TC_N_08_CSMS | Set Variable Monitoring - One element | Passed |
| TC_N_09_CSMS | Set Variable Monitoring - Multiple elements | Passed |
| TC_N_16_CSMS | Set Monitoring Level - Success | Passed |
| TC_N_17_CSMS | Set Monitoring Level - Out of range | Passed |
| TC_N_18_CSMS | Clear Monitoring - Too many elements | Passed |
| TC_N_21_CSMS | Alert Event - HardWiredMonitor | Passed |
| TC_N_24_CSMS | Set Variable Monitoring - Periodic event | Passed |
| TC_N_25_CSMS | Retrieve Log Information - Diagnostics Log - Success | Passed |
| TC_N_27_CSMS | Get Customer Information - Accepted + data | Passed |
| TC_N_28_CSMS | Get Customer Information - Accepted + no data | Passed |
| TC_N_29_CSMS | Get Customer Information - Not Accepted | Passed |
| TC_N_30_CSMS | Clear Customer Information - Clear and report + data | Passed |
| TC_N_31_CSMS | Clear Customer Information - Clear and report + no data | Passed |
| TC_N_32_CSMS | Clear Customer Information - Clear and no report | Passed |
| TC_N_34_CSMS | Retrieve Log Information - Rejected | Passed |
| TC_N_35_CSMS | Retrieve Log Information - Security Log - Success | Passed |
| TC_N_36_CSMS | Retrieve Log Information - Second Request | Passed |
| TC_N_44_CSMS | Clear Monitoring - Rejected | Passed |
| TC_N_46_CSMS | Clear Customer Information - Update Local Authorization List | Passed |
| TC_N_47_CSMS | Get Monitoring Report - Report all | Passed |
| TC_N_48_CSMS | Alert Event - Variable monitoring on write only | Passed |
| TC_N_49_CSMS | Alert Event - LowerThreshold/UpperThreshold cleared after reboot | Passed |
| TC_N_50_CSMS | Alert Event - Periodic Triggered | Passed |
| TC_N_60_CSMS | Get Monitoring Report - with criteria and list of components/variables | Passed |
| TC_N_62_CSMS | Clear Customer Information - customerIdentifier | Passed |
| TC_N_63_CSMS | Clear Customer Information - customerCertificate | Passed |

### O - Display Message

21 tests

| Test ID | Name | Status |
|---|---|---|
| TC_O_01_CSMS | Set Display Message - Success | Passed |
| TC_O_02_CSMS | Get all Display Messages - Success | Passed |
| TC_O_03_CSMS | Get all Display Messages - No DisplayMessages configured | Passed |
| TC_O_04_CSMS | Clear Display Message - Success | Passed |
| TC_O_05_CSMS | Clear Display Message - Unknown Key | Passed |
| TC_O_06_CSMS | Set Display Message - Specific transaction - Success | Passed |
| TC_O_07_CSMS | Get a Specific Display Message - Id | Passed |
| TC_O_08_CSMS | Get a Specific Display Message - Priority | Passed |
| TC_O_09_CSMS | Get a Specific Display Message - State | Passed |
| TC_O_10_CSMS | Set Display Message - Specific transaction - UnknownTransaction | Passed |
| TC_O_11_CSMS | Get a Specific Display Message - Unknown parameters | Passed |
| TC_O_12_CSMS | Set Display Message - Replace DisplayMessage | Passed |
| TC_O_13_CSMS | Set Display Message - Display message at StartTime | Passed |
| TC_O_14_CSMS | Set Display Message - Remove message after EndTime | Passed |
| TC_O_17_CSMS | Set Display Message - NotSupportedPriority | Passed |
| TC_O_18_CSMS | Set Display Message - NotSupportedState | Passed |
| TC_O_19_CSMS | Set Display Message - NotSupportedMessageFormat | Passed |
| TC_O_25_CSMS | Set Display Message - Send Specific state | Passed |
| TC_O_26_CSMS | Set Display Message - Rejected | Passed |
| TC_O_27_CSMS | Set Display Message - Specific transaction - StartTime | Passed |
| TC_O_28_CSMS | Set Display Message - Specific transaction - EndTime | Passed |

### P - Data Transfer

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_P_02_CSMS | Data Transfer to CSMS - Rejected/Unknown | Passed |
| TC_P_03_CSMS | CustomData - Receive custom data | Passed |
