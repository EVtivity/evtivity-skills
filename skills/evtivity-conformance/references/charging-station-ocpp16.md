Generated from https://www.evtivity.com/docs/conformance/charging-station-ocpp16 (website commit ffa3c26). Do not edit.

# OCPP 1.6 Charging Station Results

OCTT test case results for the Charging Station Simulator on OCPP 1.6, by module, with its PICS.

## Overview

These are the OCTT test cases for the charge point role in OCPP 1.6. The test runner acts as a Central System and checks how the EVtivity Charging Station Simulator behaves. See [OCPP Conformance Testing](https://www.evtivity.com/docs/conformance/overview) for how tests run and how results are counted.

Modules follow the numbered sections of the OCPP 1.6 test case document. A suffix such as `_1` or `_2` on a test ID marks a variant of the same test case.

Results as of 2026-10-05.

## Results by module

| Module | Total | Passed |
|---|---|---|
| 01 - Cold Boot | 2 | 2 |
| 02 - Start Charging Session | 3 | 3 |
| 03 - Stop Charging Session | 5 | 5 |
| 04 - Cache | 4 | 4 |
| 05 - Remote Actions (Happy Flow) | 4 | 4 |
| 06 - Resetting (Happy Flow) | 4 | 4 |
| 07 - Unlocking (Happy Flow) | 4 | 4 |
| 08 - Configuration (Happy Flow) | 2 | 2 |
| 09 - Meter Values | 2 | 2 |
| 10 - Basic Actions (Non-Happy Flow) | 1 | 1 |
| 11 - Basic Actions (Non-Happy Flow 2) | 2 | 2 |
| 12 - Remote Actions (Non-Happy Flow) | 3 | 3 |
| 13 - Unlocking (Non-Happy Flow) | 2 | 2 |
| 14 - Power Failure (Non-Happy Flow) | 3 | 3 |
| 15 - Offline Behavior (Non-Happy Flow) | 6 | 6 |
| 16 - Configuration Keys (Non-Happy Flow) | 2 | 2 |
| 17 - Fault Behavior (Non-Happy Flow) | 1 | 1 |
| 18 - Local Authorization List | 8 | 8 |
| 19 - Firmware Management | 3 | 3 |
| 20 - Diagnostics | 2 | 2 |
| 21 - Reservation | 16 | 16 |
| 22 - Remote Trigger | 2 | 2 |
| 23 - Smart Charging | 10 | 10 |
| 24 - Data Transfer | 1 | 1 |
| 25 - Security | 15 | 15 |
| **Total** | **107** | **107** |

## PICS

The simulator declares these rows of the OCPP 1.6 PICS. It supports every row, so every test case applies.

| PICS item | Supported | Description |
|---|---|---|
| Core | Yes | Basic Charging Station functionality: booting, authorization (incl. cache), configuration, transactions, remote control |
| Reservation | Yes | Optional feature: Reservation of a Connector |
| LocalAuthListManagement | Yes | Optional feature: Local Authorization List Management |
| SmartCharging | Yes | Smart Charging: all profile types, including stacking |
| AdvancedSecurity | Yes | Security Profile 3: TLS with client side certificates |

## Test cases

### 01 - Cold Boot

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_001_CS | Cold Boot Charge Point | Passed |
| TC_002_CS | Cold Boot Charge Point - Pending | Passed |

### 02 - Start Charging Session

3 tests

| Test ID | Name | Status |
|---|---|---|
| TC_003_CS | Regular Charging Session - Plugin First | Passed |
| TC_004_1_CS | Regular Charging Session - Identification First | Passed |
| TC_004_2_CS | Regular Charging Session - Identification First - ConnectionTimeOut | Passed |

### 03 - Stop Charging Session

5 tests

| Test ID | Name | Status |
|---|---|---|
| TC_005_1_CS | EV Side Disconnected - StopTransactionOnEVSideDisconnect = true (unlock true) | Passed |
| TC_005_2_CS | EV Side Disconnected - StopTransactionOnEVSideDisconnect = true (unlock false) | Passed |
| TC_005_3_CS | EV Side Disconnected - StopTransactionOnEVSideDisconnect = false | Passed |
| TC_068_CS | Stop transaction - IdTag matches StartTransaction IdTag | Passed |
| TC_069_CS | Stop transaction - ParentIdTag matches StartTransaction ParentIdTag | Passed |

### 04 - Cache

4 tests

| Test ID | Name | Status |
|---|---|---|
| TC_007_1_CS | Regular Start Charging Session - Cached Id | Passed |
| TC_007_2_CS | Remote Start Charging Session - Cached Id | Passed |
| TC_061_1_CS | Clear Authorization Data in Authorization Cache - Local | Passed |
| TC_061_2_CS | Clear Authorization Data in Authorization Cache - Remote | Passed |

### 05 - Remote Actions (Happy Flow)

4 tests

| Test ID | Name | Status |
|---|---|---|
| TC_010_CS | Remote Start Charging Session - Cable Plugged in First | Passed |
| TC_011_1_CS | Remote Start Charging Session - Remote Start First | Passed |
| TC_011_2_CS | Remote Start Charging Session - Time Out | Passed |
| TC_012_CS | Remote Stop Charging Session | Passed |

### 06 - Resetting (Happy Flow)

4 tests

| Test ID | Name | Status |
|---|---|---|
| TC_013_CS | Hard Reset Without transaction | Passed |
| TC_014_CS | Soft Reset Without Transaction | Passed |
| TC_015_CS | Hard Reset With Transaction | Passed |
| TC_016_CS | Soft Reset With Transaction | Passed |

### 07 - Unlocking (Happy Flow)

4 tests

| Test ID | Name | Status |
|---|---|---|
| TC_017_1_CS | Unlock connector - no session (Not fixed cable) | Passed |
| TC_017_2_CS | Unlock connector - no session (Fixed cable) | Passed |
| TC_018_1_CS | Unlock Connector - With Charging Session (Not fixed cable) | Passed |
| TC_018_2_CS | Unlock Connector - With Charging Session (Fixed cable) | Passed |

### 08 - Configuration (Happy Flow)

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_019_CS | Retrieve configuration | Passed |
| TC_021_CS | Change/set Configuration | Passed |

### 09 - Meter Values

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_070_CS | Sampled Meter Values | Passed |
| TC_071_CS | Clock-aligned Meter Values | Passed |

### 10 - Basic Actions (Non-Happy Flow)

1 test

| Test ID | Name | Status |
|---|---|---|
| TC_023_4_CS | Start local Charging Session - Authorize invalid | Passed |

### 11 - Basic Actions (Non-Happy Flow 2)

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_023_5_CS | Start remote Charging Session - Authorize invalid | Passed |
| TC_024_CS | Start Charging Session - Lock Failure | Passed |

### 12 - Remote Actions (Non-Happy Flow)

3 tests

| Test ID | Name | Status |
|---|---|---|
| TC_026_CS | Remote Start Charging Session - Rejected | Passed |
| TC_027_CS | Remote start transaction - connector id shall not be 0 | Passed |
| TC_028_CS | Remote Stop Transaction - Rejected | Passed |

### 13 - Unlocking (Non-Happy Flow)

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_030_CS | Unlock Connector - Unlock Failure | Passed |
| TC_031_CS | Unlock Connector - Unknown Connector | Passed |

### 14 - Power Failure (Non-Happy Flow)

3 tests

| Test ID | Name | Status |
|---|---|---|
| TC_032_1_CS | Power failure - stop transaction(s) before going down | Passed |
| TC_032_2_CS | Power failure - stop transaction(s) after going down | Passed |
| TC_034_CS | Power Failure with Unavailable Status | Passed |

### 15 - Offline Behavior (Non-Happy Flow)

6 tests

| Test ID | Name | Status |
|---|---|---|
| TC_036_CS | Connection Loss During Transaction | Passed |
| TC_037_1_CS | Offline Start Transaction - Valid IdTag | Passed |
| TC_037_2_CS | Offline Start Transaction - Invalid IdTag - StopTransactionOnInvalidId = false | Passed |
| TC_037_3_CS | Offline Start Transaction - Invalid IdTag - StopTransactionOnInvalidId = true | Passed |
| TC_038_CS | Offline Stop Transaction | Passed |
| TC_039_CS | Offline Transaction | Passed |

### 16 - Configuration Keys (Non-Happy Flow)

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_040_1_CS | Configuration key - NotSupported | Passed |
| TC_040_2_CS | Configuration key - Invalid value | Passed |

### 17 - Fault Behavior (Non-Happy Flow)

1 test

| Test ID | Name | Status |
|---|---|---|
| TC_041_CS | Fault Behavior | Passed |

### 18 - Local Authorization List

8 tests

| Test ID | Name | Status |
|---|---|---|
| TC_008_1_CS | Regular Start Charging Session - Id in Local Authorization List | Passed |
| TC_008_2_CS | Remote Start Charging Session - Id in Local Authorization List | Passed |
| TC_042_1_CS | Get Local List Version (not supported) | Passed |
| TC_042_2_CS | Get Local List Version (empty) | Passed |
| TC_043_1_CS | Send Local Authorization List - NotSupported | Passed |
| TC_043_2_CS | Send Local Authorization List - VersionMismatch | Passed |
| TC_043_3_CS | Send Local Authorization List - Failed | Passed |
| TC_043_CS | Send Local Authorization List | Passed |

### 19 - Firmware Management

3 tests

| Test ID | Name | Status |
|---|---|---|
| TC_044_1_CS | Firmware Update - Download and Install | Passed |
| TC_044_2_CS | Firmware Update - Download Failed | Passed |
| TC_044_3_CS | Firmware Update - Installation Failed | Passed |

### 20 - Diagnostics

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_045_1_CS | Get Diagnostics | Passed |
| TC_045_2_CS | Get Diagnostics - Upload Failed | Passed |

### 21 - Reservation

16 tests

| Test ID | Name | Status |
|---|---|---|
| TC_046_1_CS | Reservation of a Connector - Local start transaction | Passed |
| TC_046_2_CS | Reservation of a Connector - Remote start transaction | Passed |
| TC_047_CS | Reservation of a Connector - Expire | Passed |
| TC_048_1_CS | Reservation of a Connector - Faulted | Passed |
| TC_048_2_CS | Reservation of a Connector - Occupied | Passed |
| TC_048_3_CS | Reservation of a Connector - Unavailable | Passed |
| TC_048_4_CS | Reservation of a Connector - Rejected | Passed |
| TC_049_CS | Reservation of a Charge Point - Transaction | Passed |
| TC_050_1_CS | Reservation of a Charge Point - Faulted | Passed |
| TC_050_2_CS | Reservation of a Charge Point - Occupied | Passed |
| TC_050_3_CS | Reservation of a Charge Point - Unavailable | Passed |
| TC_050_4_CS | Reservation of a Charge Point - Rejected | Passed |
| TC_051_CS | Cancel Reservation | Passed |
| TC_052_CS | Cancel Reservation - Rejected | Passed |
| TC_053_1_CS | Use a reserved Connector with parentIdTag - Local | Passed |
| TC_053_2_CS | Use a reserved Connector with parentIdTag - Remote | Passed |

### 22 - Remote Trigger

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_054_CS | Trigger Message | Passed |
| TC_055_CS | Trigger Message - Rejected | Passed |

### 23 - Smart Charging

10 tests

| Test ID | Name | Status |
|---|---|---|
| TC_056_CS | Central Smart Charging - TxDefaultProfile | Passed |
| TC_057_CS | Central Smart Charging - TxProfile | Passed |
| TC_058_1_CS | Central Smart Charging - No ongoing transaction | Passed |
| TC_058_2_CS | Central Smart Charging - Wrong transactionId | Passed |
| TC_059_CS | Remote Start Transaction with Charging Profile | Passed |
| TC_060_CS | Remote Start Transaction with Charging Profile - Rejected | Passed |
| TC_066_CS | Get Composite Schedule | Passed |
| TC_067_CS | Clear Charging Profile | Passed |
| TC_072_CS | Stacking Charging Profiles | Passed |
| TC_082_CS | Central Smart Charging - TxDefaultProfile - with ongoing transaction | Passed |

### 24 - Data Transfer

1 test

| Test ID | Name | Status |
|---|---|---|
| TC_062_CS | Data Transfer to a Charge Point | Passed |

### 25 - Security

15 tests

| Test ID | Name | Status |
|---|---|---|
| TC_073_CS | Update Charge Point Password for HTTP Basic Authentication | Passed |
| TC_074_CS | Update Charge Point Certificate by request of Central System | Passed |
| TC_075_1_CS | Install certificate - ManufacturerRootCertificate | Passed |
| TC_075_2_CS | Install certificate - CentralSystemRootCertificate | Passed |
| TC_076_CS | Delete a specific certificate from the Charge Point | Passed |
| TC_077_CS | Invalid ChargePointCertificate Security Event | Passed |
| TC_078_CS | Invalid CentralSystemCertificate Security Event | Passed |
| TC_079_CS | Get Security Log | Passed |
| TC_080_CS | Secure Firmware Update | Passed |
| TC_081_CS | Secure Firmware Update - Invalid Signature | Passed |
| TC_083_CS | Upgrade security profile | Passed |
| TC_084_CS | Downgrade security profile - Rejected | Passed |
| TC_085_CS | Basic Authentication - Valid username/password combination | Passed |
| TC_086_CS | TLS - server-side certificate - Valid certificate | Passed |
| TC_087_CS | TLS - Client-side certificate - valid certificate | Passed |
