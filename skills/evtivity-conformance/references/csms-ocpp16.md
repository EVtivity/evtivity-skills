Generated from https://www.evtivity.com/docs/conformance/csms-ocpp16 (website commit ffa3c26). Do not edit.

# OCPP 1.6 CSMS Results

OCTT test case results for the EVtivity CSMS on OCPP 1.6, by module.

## Overview

These are the OCTT test cases for the Central System role in OCPP 1.6, run against the EVtivity CSMS. The test runner acts as a charge point and checks how the CSMS responds. See [OCPP Conformance Testing](https://www.evtivity.com/docs/conformance/overview) for how tests run and how results are counted.

OCPP 1.6 test cases use numeric IDs such as `TC_003_CSMS`. A suffix such as `_1` or `_2` marks a variant of the same test case.

Results as of 2026-10-05.

## Results by module

| Module | Total | Passed |
|---|---|---|
| Core | 34 | 34 |
| Local Authorization List | 6 | 6 |
| Firmware Management | 5 | 5 |
| Reservation | 10 | 10 |
| Remote Trigger | 2 | 2 |
| Smart Charging | 5 | 5 |
| Security | 15 | 15 |
| **Total** | **77** | **77** |

## Test cases

### Core

34 tests

| Test ID | Name | Status |
|---|---|---|
| TC_001_CSMS | Cold Boot Charging Station (1.6) | Passed |
| TC_003_CSMS | Regular Charging Session - Plugin First (1.6) | Passed |
| TC_004_1_CSMS | Regular Charging Session - Identification First (1.6) | Passed |
| TC_004_2_CSMS | Regular Charging Session - Identification First - ConnectionTimeOut (1.6) | Passed |
| TC_005_1_CSMS | EV Side Disconnected - StopTransactionOnEVSideDisconnect (1.6) | Passed |
| TC_007_CSMS | Regular Start Charging Session - Cached Id (1.6) | Passed |
| TC_010_CSMS | Remote Start Charging Session - Cable Plugged in First (1.6) | Passed |
| TC_011_1_CSMS | Remote Start Charging Session - Remote Start First (1.6) | Passed |
| TC_011_2_CSMS | Remote Start Charging Session - Time Out (1.6) | Passed |
| TC_012_CSMS | Remote Stop Charging Session (1.6) | Passed |
| TC_013_CSMS | Hard Reset (1.6) | Passed |
| TC_014_CSMS | Soft Reset (1.6) | Passed |
| TC_017_1_CSMS | Unlock Connector - No Charging Session (Not Fixed Cable) (1.6) | Passed |
| TC_017_2_CSMS | Unlock Connector - No Charging Session (Fixed Cable) (1.6) | Passed |
| TC_018_1_CSMS | Unlock Connector - With Charging Session (Not Fixed Cable) (1.6) | Passed |
| TC_019_1_CSMS | Retrieve All Configuration Keys (1.6) | Passed |
| TC_019_2_CSMS | Retrieve Specific Configuration Key (1.6) | Passed |
| TC_021_CSMS | Change/Set Configuration (1.6) | Passed |
| TC_023_1_CSMS | Start Charging Session - Authorize Invalid (1.6) | Passed |
| TC_023_2_CSMS | Start Charging Session - Authorize Expired (1.6) | Passed |
| TC_023_3_CSMS | Start Charging Session - Authorize Blocked (1.6) | Passed |
| TC_024_CSMS | Start Charging Session Lock Failure (1.6) | Passed |
| TC_026_CSMS | Remote Start Charging Session - Rejected (1.6) | Passed |
| TC_028_CSMS | Remote Stop Transaction - Rejected (1.6) | Passed |
| TC_030_CSMS | Unlock Connector - Unlock Failure (1.6) | Passed |
| TC_031_CSMS | Unlock Connector - Unknown Connector (1.6) | Passed |
| TC_032_1_CSMS | Power Failure Boot - Stop Transactions (1.6) | Passed |
| TC_037_1_CSMS | Offline Start Transaction - Valid IdTag (1.6) | Passed |
| TC_037_3_CSMS | Offline Start Transaction - Invalid IdTag - StopTransactionOnInvalidId (1.6) | Passed |
| TC_039_CSMS | Offline Transaction (1.6) | Passed |
| TC_040_1_CSMS | Configuration Keys - NotSupported (1.6) | Passed |
| TC_040_2_CSMS | Configuration Keys - Invalid Value (1.6) | Passed |
| TC_061_CSMS | Clear Authorization Data in Authorization Cache (1.6) | Passed |
| TC_064_CSMS | Data Transfer to a Central System (1.6) | Passed |

### Local Authorization List

6 tests

| Test ID | Name | Status |
|---|---|---|
| TC_042_1_CSMS | Get Local List Version - Not Supported (1.6) | Passed |
| TC_042_2_CSMS | Get Local List Version - Empty (1.6) | Passed |
| TC_043_1_CSMS | Send Local Authorization List - NotSupported (1.6) | Passed |
| TC_043_3_CSMS | Send Local Authorization List - Failed (1.6) | Passed |
| TC_043_4_CSMS | Send Local Authorization List - Full (1.6) | Passed |
| TC_043_5_CSMS | Send Local Authorization List - Differential (1.6) | Passed |

### Firmware Management

5 tests

| Test ID | Name | Status |
|---|---|---|
| TC_044_1_CSMS | Firmware Update - Download and Install (1.6) | Passed |
| TC_044_2_CSMS | Firmware Update - Download Failed (1.6) | Passed |
| TC_044_3_CSMS | Firmware Update - Installation Failed (1.6) | Passed |
| TC_045_1_CSMS | Get Diagnostics (1.6) | Passed |
| TC_045_2_CSMS | Get Diagnostics - Upload Failed (1.6) | Passed |

### Reservation

10 tests

| Test ID | Name | Status |
|---|---|---|
| TC_046_CSMS | Reservation of a Connector - Transaction (1.6) | Passed |
| TC_047_CSMS | Reservation of a Connector - Expire (1.6) | Passed |
| TC_048_1_CSMS | Reservation of a Connector - Faulted (1.6) | Passed |
| TC_048_2_CSMS | Reservation of a Connector - Occupied (1.6) | Passed |
| TC_048_3_CSMS | Reservation of a Connector - Unavailable (1.6) | Passed |
| TC_048_4_CSMS | Reservation of a Connector - Rejected (1.6) | Passed |
| TC_049_CSMS | Reservation of a Charge Point - Transaction (1.6) | Passed |
| TC_051_CSMS | Cancel Reservation (1.6) | Passed |
| TC_052_CSMS | Cancel Reservation - Rejected (1.6) | Passed |
| TC_053_CSMS | Use a Reserved Connector with parentIdTag (1.6) | Passed |

### Remote Trigger

2 tests

| Test ID | Name | Status |
|---|---|---|
| TC_054_CSMS | Trigger Message (1.6) | Passed |
| TC_055_CSMS | Trigger Message - Rejected (1.6) | Passed |

### Smart Charging

5 tests

| Test ID | Name | Status |
|---|---|---|
| TC_056_CSMS | Central Smart Charging - TxDefaultProfile (1.6) | Passed |
| TC_057_CSMS | Central Smart Charging - TxProfile (1.6) | Passed |
| TC_059_CSMS | Remote Start Transaction with Charging Profile (1.6) | Passed |
| TC_066_CSMS | Get Composite Schedule (1.6) | Passed |
| TC_067_CSMS | Clear Charging Profile (1.6) | Passed |

### Security

15 tests

| Test ID | Name | Status |
|---|---|---|
| TC_073_CSMS | Update Charge Point Password for HTTP Basic Authentication (1.6) | Passed |
| TC_074_CSMS | Update Charge Point Certificate by Request of Central System (1.6) | Passed |
| TC_075_1_CSMS | Install Certificate - ManufacturerRootCertificate (1.6) | Passed |
| TC_075_2_CSMS | Install Certificate - CentralSystemRootCertificate (1.6) | Passed |
| TC_076_CSMS | Delete a Specific Certificate from the Charge Point (1.6) | Passed |
| TC_077_CSMS | Invalid ChargePointCertificate Security Event (1.6) | Passed |
| TC_078_CSMS | Invalid CentralSystemCertificate Security Event (1.6) | Passed |
| TC_079_CSMS | Get Security Log (1.6) | Passed |
| TC_080_CSMS | Secure Firmware Update (1.6) | Passed |
| TC_081_CSMS | Secure Firmware Update - Invalid Signature (1.6) | Passed |
| TC_083_CSMS | Upgrade Charge Point Security Profile - Accepted (1.6) | Passed |
| TC_085_CSMS | Basic Authentication - Valid username/password (1.6) | Passed |
| TC_086_CSMS | TLS - Server-side Certificate - Valid Certificate (1.6) | Passed |
| TC_087_CSMS | TLS - Client-side Certificate - Valid Certificate (1.6) | Passed |
| TC_088_CSMS | WebSocket Subprotocol Negotiation (1.6) | Passed |
