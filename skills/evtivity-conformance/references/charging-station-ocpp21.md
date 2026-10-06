Generated from https://www.evtivity.com/docs/conformance/charging-station-ocpp21 (website commit 257c8b8). Do not edit.

# OCPP 2.1 Charging Station Results

OCTT test case results for the Charging Station Simulator on OCPP 2.1, by module, with its PICS.

## Overview

These are the OCTT test cases for the charging station role in OCPP 2.1. The test runner acts as a CSMS and checks how the EVtivity Charging Station Simulator behaves. See [OCPP Conformance Testing](https://www.evtivity.com/docs/conformance/overview) for how tests run and how results are counted.

A test case applies only when the simulator's PICS meets its conditions. The [PICS](#pics) section lists every item, and the [Not applicable](#not-applicable) section lists every excluded test case.

Results as of 2026-10-05.

## Results by module

| Module | Total | Passed | Not applicable |
|---|---|---|---|
| A - Security | 16 | 16 | 0 |
| B - Provisioning | 61 | 58 | 3 |
| C - Authorization | 78 | 53 | 25 |
| D - Local Authorization List | 9 | 9 | 0 |
| E - Transactions | 61 | 61 | 0 |
| F - Remote Control | 25 | 25 | 0 |
| G - Availability | 21 | 21 | 0 |
| H - Reservation | 21 | 21 | 0 |
| I - Tariff and Cost | 25 | 22 | 3 |
| J - Meter Values | 10 | 10 | 0 |
| K - Smart Charging | 76 | 44 | 32 |
| L - Firmware Management | 15 | 11 | 4 |
| M - Certificate Management | 27 | 20 | 7 |
| N - Diagnostics | 61 | 60 | 1 |
| O - Display Message | 33 | 33 | 0 |
| P - Data Transfer | 3 | 3 | 0 |
| Q - Bidirectional Power Transfer | 25 | 0 | 25 |
| R - DER Control | 8 | 0 | 8 |
| S - Battery Swapping | 3 | 0 | 3 |
| **Total** | **578** | **467** | **111** |

## PICS

The simulator declares these items from OCPP 2.1 Part 5 (Certification Profiles). Items without a Part 5 ID come from a test case prerequisite in the OCTT test case document. An unsupported item excludes every test case that needs it. A supported item excludes the test cases that need a station without it.

| PICS item | Supported | Description |
|---|---|---|
| ISO15118Support | No | Certification profile ISO 15118 support: ISO 15118-2/-20 certificate management, EIM/PnC authorization, HLC smart charging (Reason: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) |
| BidirectionalPowerTransfer | No | Certification profile Bidirectional Power Transfer (V2X, V2XChargingCtrlr) (Reason: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) |
| DERControl | No | Certification profile DER control (DCDERCtrlr / ACDERCtrlr) (Reason: No DER control: the simulator has no inverter model or DER control types) |
| C-09.2 | No | Start transaction options - Authorized (TxStartPoint contains Authorized) (Reason: Transactions start once the EV is connected and the driver is authorized (PowerPathClosed); the simulator has no TxCtrlr.TxStartPoint) |
| C-13 | Yes | Support for Reset per EVSE (AllowReset) |
| C-42 | Yes | Signed Metervalues (SampledDataSignReadings, AlignedDataSignReadings) |
| C-51 | No | Configurable TxStartPoint (Reason: The simulator has no TxCtrlr.TxStartPoint variable; its start point is fixed) |
| C-43 | No | Install Firmware with ongoing transaction(s) (Reason: The simulator downloads a firmware during a transaction but installs it only after all transactions ended (InstallScheduled)) |
| C-60 | Yes | Support for cancelling ongoing firmware update (AcceptedCanceled) |
| C-56 | Yes | Support for providing the SummaryInventory |
| C-62 | Yes | Support for resuming transactions (ImmediateAndResume) |
| DM-0 | Yes | Support for Advanced Device Management (monitoring) |
| DM-3 | Yes | Queue NotifyEventRequest messages for specific severities (OfflineMonitoringEventQueuingSeverity) |
| P-0 | Yes | Support for Payment (default tariff, local cost calculation) |
| P-1 | No | Support for Tariff conditions (TariffCostCtrlr.ConditionsSupported[Tariff]) (Reason: The simulator calculates cost from unconditional tariff prices only; SetDefaultTariff answers ConditionNotSupported) |
| P-2.1 | Yes | Payment by prepaid card (C17, TxCtrlr.SupportedLimits contains MaxCost) |
| P-2.2 | No | Integrated payment terminal (C18-C23) (Reason: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) |
| P-2.3 | No | Stand alone payment terminal (C24) (Reason: No stand-alone payment terminal or kiosk integration in the simulator) |
| P-2.4 | Yes | QR code payment (C25, WebPaymentsCtrlr) |
| SC-2.1 | Yes | Supported charging rate unit A (SmartChargingCtrlr.RateUnit) |
| SC-2.2 | Yes | Supported charging rate unit W (SmartChargingCtrlr.RateUnit) |
| SC-3 | No | Support for limiting based on SoC (limitAtSoC) (Reason: The simulated EV reports no state of charge (no ISO 15118 or CHAdeMO), so limitAtSoC cannot apply) |
| SC-4 | Yes | Support for TxDefaultProfile on EVSEID #0 |
| SC-5.1 | No | Support for using local time (useLocalTime) with TimeOffset (Reason: Charging schedules are evaluated in UTC only (SmartChargingCtrlr.SupportsFeature#UseLocalTime false)) |
| SC-5.2 | No | Support for using local time (useLocalTime) with TimeZone (Reason: Charging schedules are evaluated in UTC only (SmartChargingCtrlr.SupportsFeature#UseLocalTime false)) |
| SC-6 | No | Support for using priority charging (PriorityCharging, K21/K22) (Reason: No PriorityCharging profile purpose or local priority request in the simulator) |
| SC-7 | No | Support for using randomized delays (randomizedDelay) (Reason: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false)) |
| SC-8 | No | Support for dynamic charging profiles (K28/K29) (Reason: Dynamic charging profiles (PullDynamicScheduleUpdate, UpdateDynamicSchedule) are not implemented) |
| SC-9.1 | No | Support for operationMode Idle with EvseSleep (Reason: No EVSE sleep mode in the simulator (SmartChargingCtrlr.SupportsFeature#EvseSleep false)) |
| SC-10 | No | Support for EMS Control (SmartChargingCtrlr.MaxExternalConstraintsId) (Reason: No local EMS interface and no MaxExternalConstraintsId; external limits only arrive from the CSMS) |
| AQ-7 | Yes | The Charging Station is able to download firmware while there is an ongoing transaction |
| AQ-10 | Yes | The Charging Station supports a Delta monitor on the WriteOnly SecurityCtrlr.BasicAuthPassword |
| UI-2.2 | No | Supported message format HTML (DisplayMessageCtrlr.SupportedFormats) (Reason: The simulator display shows ASCII and UTF8 text only) |
| UI-3 | Yes | Multi-language support (DisplayMessageCtrlr.Language valuesList) |
| AQ-19 | Yes | The Charging Station has at least 1 unsupported language code |
| HFS-13 | No | Charging Station has Battery Swapping support (BatterySwapCtrlr.Available) (Reason: No battery swap station model: the simulator has no battery inventory or swap bays) |
| LocalEmsConnection | No | A local EMS or external system connected to the Charging Station can apply charging limit constraints (SC-10 EMS Control, TC_K_120/124/125 prerequisite) (Reason: The simulator has no local EMS or external system interface; external limits only arrive from the CSMS) |
| NoSmartCharging | No | The Charging Station does not support smart charging (TC_K_15_CS prerequisite) (Reason: The simulator supports smart charging (SmartChargingCtrlr.Enabled), so it never answers NotSupported) |
| SingleChargingRateUnit | No | Only one of the charging rate units A (SC-2.1) and W (SC-2.2) is supported (TC_K_12_CS and TC_K_42_CS condition) (Reason: The simulator supports both A and W (SmartChargingCtrlr.RateUnit A,W)) |
| NoLocalCostCalculation | No | The Charging Station does not support local cost calculation, or has it disabled (TC_I_103_CS prerequisite) (Reason: The simulator supports local cost calculation (P-0). With TariffCostCtrlr.Enabled[Tariff] false it still accepts a default tariff, as TC_I_107_CS (Part 5, P-0) requires; Part 5 does not list TC_I_103) |
| NoLogInformationAvailable | No | The Charging Station can be in a state with no log information available (TC_N_34_CS prerequisite, N01.FR.05) (Reason: The simulator always has diagnostics and security log information to upload, so it cannot be put in a state without log information) |

## Not applicable

The simulator's PICS excludes these test cases. They are not run and do not count as passed.

| Test ID | Name | Reason |
|---|---|---|
| TC_B_15_CS | Get Base Report - Not Supported base report | PICS C-56 supported: test requires a station without it (Support for providing the SummaryInventory) |
| TC_B_28_CS | Reset EVSE - Not Supported | PICS C-13 supported: test requires a station without it (Support for Reset per EVSE (AllowReset)) |
| TC_B_29_CS | Reset EVSE - With ongoing transaction - Not Supported | PICS C-13 supported: test requires a station without it (Support for Reset per EVSE (AllowReset)) |
| TC_C_50_CS | Authorization using Contract Certificates 15118 - Online - Local contract certificate validation - Accepted | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_C_51_CS | Authorization using Contract Certificates 15118 - Online - Local contract certificate validation - Rejected | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_C_52_CS | Authorization using Contract Certificates 15118 - Online - Central contract certificate validation | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_C_53_CS | Authorization using Contract Certificates 15118 - Online - Central contract validation fails | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_C_54_CS | Authorization using Contract Certificates 15118 - Offline - ContractValidationOffline is true | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_C_55_CS | Authorization using Contract Certificates 15118 - Offline - ContractValidationOffline is false | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_C_100_CS | Local start transaction - Authorization first - Cable plugin timeout | PICS none of C-51, C-09.2 supported: The simulator has no TxCtrlr.TxStartPoint variable; its start point is fixed; Transactions start once the EV is connected and the driver is authorized (PowerPathClosed); the simulator has no TxCtrlr.TxStartPoint |
| TC_C_105_CS | Integrated Payment Terminal - CSMS rejects authorization | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_106_CS | Integrated Payment Terminal - Only Payment Terminal authorises | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_107_CS | Integrated Payment Terminal - Payment Terminal and CSMS authorises | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_108_CS | Integrated Payment Terminal - VAT number validation | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_109_CS | Integrated Payment Terminal - Cancelation prior to transaction - Only PT authorised - EVConnectTimeout | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_110_CS | Integrated Payment Terminal - Cancelation prior to transaction - PT and CSMS authorised | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_111_CS | Integrated Payment Terminal - Cancelation prior to transaction - Only PT authorised - EV driver cancels | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_112_CS | Integrated Payment Terminal - Cancelation prior to transaction - PT and CSMS authorised - EVConnectTimeout | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_113_CS | Integrated Payment Terminal - Cancelation after start of transaction - stopped by EV driver | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_114_CS | Settlement at end of transaction - settled by CS, receipt by CS | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_115_CS | Settlement at end of transaction - settled by CSMS | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_116_CS | Settlement at end of transaction - settled by CS, receipt by CSMS | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_119_CS | Settlement - is rejected or fails - Failed | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_120_CS | Settlement - is rejected or fails - Rejected | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_121_CS | Incremental authorization - increasing enabled | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_122_CS | Incremental authorization - increasing disabled | PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts |
| TC_C_123_CS | Ad hoc payment via stand-alone payment terminal - local cost calculation | PICS P-2.3 not supported: No stand-alone payment terminal or kiosk integration in the simulator |
| TC_C_124_CS | Ad hoc payment via stand-alone payment terminal - central cost calculation | PICS P-2.3 not supported: No stand-alone payment terminal or kiosk integration in the simulator |
| TC_I_103_CS | Set Default Tariff - CS doesn’t support local cost calculation | PICS NoLocalCostCalculation not supported: The simulator supports local cost calculation (P-0). With TariffCostCtrlr.Enabled[Tariff] false it still accepts a default tariff, as TC_I_107_CS (Part 5, P-0) requires; Part 5 does not list TC_I_103 |
| TC_I_120_CS | Local Cost Calculation - Cost Details of Transaction - reservation | PICS P-1 not supported: The simulator calculates cost from unconditional tariff prices only; SetDefaultTariff answers ConditionNotSupported |
| TC_I_121_CS | Local Cost Calculation - Cost Details of Transaction - minCost/maxCost | PICS P-1 not supported: The simulator calculates cost from unconditional tariff prices only; SetDefaultTariff answers ConditionNotSupported |
| TC_K_12_CS | Set Charging Profile - ChargerRateUnit Rejected | PICS SingleChargingRateUnit not supported: The simulator supports both A and W (SmartChargingCtrlr.RateUnit A,W) |
| TC_K_15_CS | Set Charging Profile - Not Supported | PICS NoSmartCharging not supported: The simulator supports smart charging (SmartChargingCtrlr.Enabled), so it never answers NotSupported |
| TC_K_42_CS | Get Composite Schedule - chargingRateUnit not supported | PICS SingleChargingRateUnit not supported: The simulator supports both A and W (SmartChargingCtrlr.RateUnit A,W) |
| TC_K_53_CS | Charging with load leveling based on HLC - Success | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_54_CS | Charging with HLC - No SASchedule (rejected) | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_56_CS | Charging with HLC - Offline | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_57_CS | Renegotiating Charging Schedule ISO 15118-2 - EV initiated | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_58_CS | Renegotiating Charging Schedule ISO 15118-2 - CSMS initiated | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_101_CS | Set Charging Profile - Change operation mode | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_K_102_CS | Set Charging Profile - limitAtSoc | PICS SC-3 not supported: The simulated EV reports no state of charge (no ISO 15118 or CHAdeMO), so limitAtSoC cannot apply |
| TC_K_103_CS | Set Charging Profile - Local time - TimeOffset | PICS SC-5.1 not supported: Charging schedules are evaluated in UTC only (SmartChargingCtrlr.SupportsFeature#UseLocalTime false) |
| TC_K_104_CS | Set Charging Profile - PriorityCharging | PICS SC-6 not supported: No PriorityCharging profile purpose or local priority request in the simulator |
| TC_K_106_CS | Set Charging Profile - randomizedDelay | PICS SC-7 not supported: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false) |
| TC_K_107_CS | Set Charging Profile - randomizedDelay - validations | PICS SC-7 not supported: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false) |
| TC_K_108_CS | Set Charging Profile - randomizedDelay - random for each tx | PICS SC-7 not supported: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false) |
| TC_K_109_CS | EMS Control - Set Charging Profile - MaxExternalConstraintsId | PICS SC-10 not supported: No local EMS interface and no MaxExternalConstraintsId; external limits only arrive from the CSMS |
| TC_K_110_CS | EMS Control - Set Charging Profile - MaxExternalConstraintsId - validations | PICS SC-10 not supported: No local EMS interface and no MaxExternalConstraintsId; external limits only arrive from the CSMS |
| TC_K_112_CS | Get Composite Schedule - randomizedDelay | PICS SC-7 not supported: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false) |
| TC_K_113_CS | Renegotiating Charging Schedule ISO 15118-20 - CSMS initiated | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_114_CS | Renegotiating Charging Schedule ISO 15118-20 - EV initiated | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_115_CS | ISO 15118-20 Dynamic Control Mode - Success | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_116_CS | Renegotiating ISO 15118-20 - Adjusting schedule on energy needs | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_K_118_CS | Priority Charging - Remote | PICS SC-6 not supported: No PriorityCharging profile purpose or local priority request in the simulator |
| TC_K_119_CS | Priority Charging - Local | PICS SC-6 not supported: No PriorityCharging profile purpose or local priority request in the simulator |
| TC_K_120_CS | EMS Control - Smart Charging with EMS and LocalGeneration | PICS LocalEmsConnection not supported: The simulator has no local EMS or external system interface; external limits only arrive from the CSMS |
| TC_K_121_CS | Dynamic charging profiles from CSMS - Pull | PICS SC-8 not supported: Dynamic charging profiles (PullDynamicScheduleUpdate, UpdateDynamicSchedule) are not implemented |
| TC_K_122_CS | Dynamic charging profiles from CSMS - Push | PICS SC-8 not supported: Dynamic charging profiles (PullDynamicScheduleUpdate, UpdateDynamicSchedule) are not implemented |
| TC_K_123_CS | Dynamic charging profiles from CSMS - validations | PICS SC-8 not supported: Dynamic charging profiles (PullDynamicScheduleUpdate, UpdateDynamicSchedule) are not implemented |
| TC_K_124_CS | Dynamic profiles by external system - No Dynamic profile configured | PICS LocalEmsConnection not supported: The simulator has no local EMS or external system interface; external limits only arrive from the CSMS |
| TC_K_125_CS | Dynamic profiles by external system - Dynamic profile configured | PICS LocalEmsConnection not supported: The simulator has no local EMS or external system interface; external limits only arrive from the CSMS |
| TC_K_129_CS | Set Charging Profile - PriorityCharging persistent over reboot | PICS SC-6 not supported: No PriorityCharging profile purpose or local priority request in the simulator |
| TC_K_136_CS | Set Charging Profile - Local time - TimeZone | PICS SC-5.2 not supported: Charging schedules are evaluated in UTC only (SmartChargingCtrlr.SupportsFeature#UseLocalTime false) |
| TC_L_11_CS | Secure Firmware Update - Unable to cancel | PICS C-60 supported: test requires a station without it (Support for cancelling ongoing firmware update (AcceptedCanceled)) |
| TC_L_12_CS | Secure Firmware Update - Unable to download/install firmware with ongoing transaction - AllowNewSessionsPendingFirmwareUpdate is true | PICS AQ-7 supported: test requires a station without it (The Charging Station is able to download firmware while there is an ongoing transaction) |
| TC_L_13_CS | Secure Firmware Update - Unable to download/install firmware with ongoing transaction - AllowNewSessionsPendingFirmwareUpdate is false | PICS AQ-7 supported: test requires a station without it (The Charging Station is able to download firmware while there is an ongoing transaction) |
| TC_L_16_CS | Secure Firmware Update - Able to update firmware with ongoing transaction | PICS C-43 not supported: The simulator downloads a firmware during a transaction but installs it only after all transactions ended (InstallScheduled) |
| TC_M_24_CS | Get Charging Station Certificate status - Success | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_M_25_CS | Get Charging Station Certificate status - Rejected | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_M_26_CS | Certificate Installation EV - Success | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_M_27_CS | Certificate Installation EV - Failed | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_M_28_CS | Certificate Update EV - Success | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_M_29_CS | Certificate Update EV - Failed | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_M_100_CS | Certificate Installation EV - ISO 15118-20 - Success | PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate |
| TC_N_34_CS | Retrieve Log Information - Rejected | PICS NoLogInformationAvailable not supported: The simulator always has diagnostics and security log information to upload, so it cannot be put in a state without log information |
| TC_Q_100_CS | V2X Authorisation - V2X Tx Measurands defined | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_101_CS | V2X Authorisation - ISO15118-20 - Processing charging needs | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_102_CS | V2X Authorisation - ISO15118-20 - Charging only (V2X control) before starting V2X - Allowed Energy | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_103_CS | V2X Authorisation - ISO15118-20 - Charging needs rejected | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_104_CS | V2X Authorisation - ISO15118-20 - Scheduled Control | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_107_CS | V2X Authorisation - ISO15118-20 - Charging only (V2X control) before starting V2X | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_109_CS | Central dynamic schedule control with setpoint - push | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_110_CS | Central V2X control with dynamic CSMS setpoint - pull | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_111_CS | External V2X control - with a charging profile from CSMS - setpoint | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_112_CS | External V2X control - with a charging profile from CSMS - limit | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_113_CS | External V2X control - with a charging profile from CSMS - Duration expired | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_114_CS | External V2X control - External System - Dynamic external limits control | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_115_CS | External V2X control - External System - Dynamic setpoint control | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_116_CS | External V2X control - External System - Scheduled external limits control | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_117_CS | Frequency Support - Central V2X control - push | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_118_CS | Frequency Support - Central V2X control - Duration expired | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_119_CS | Frequency Support - Local V2X control - Charging profile validations | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_120_CS | Frequency Support - Local V2X control - AFRR support | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_122_CS | Local V2X control for load balancing - threshold validations | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_123_CS | Local V2X control for load balancing - not supported | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_125_CS | Idle operationMode - Idle with EvseSleep | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_126_CS | Idle operationMode - Idle with EvseSleep unsupported | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_127_CS | Idle operationMode - Charging profile validations | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_128_CS | Going offline during V2X operation - invalidAfterOfflineDuration = true | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_Q_130_CS | V2X Authorisation - ISO15118-20 - has ISO15118ServiceRenegotiationSupport - Charging needs rejected | PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop |
| TC_R_100_CS | Starting a V2X session with DER control in EVSE - Persistent DERControls | PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types |
| TC_R_101_CS | Starting a V2X session with DER control in EVSE - Device model | PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types |
| TC_R_102_CS | Configure DER control settings at CS - clearing controlTypes | PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types |
| TC_R_103_CS | Configure DER control settings at CS - validations | PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types |
| TC_R_104_CS | Configure DER control settings at CS - superseding future DER control | PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types |
| TC_R_105_CS | Configure DER control settings at CS - superseding active DER control | PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types |
| TC_R_106_CS | Configure DER control settings at CS - Active DER control supersedes new DER control | PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types |
| TC_R_108_CS | Charging station reporting a DER event | PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types |
| TC_S_102_CS | Battery Swap - Remote Start - not enough batteries | PICS HFS-13 not supported: No battery swap station model: the simulator has no battery inventory or swap bays |
| TC_S_104_CS | Battery Swap - Charging - Variables validation | PICS HFS-13 not supported: No battery swap station model: the simulator has no battery inventory or swap bays |
| TC_S_105_CS | Battery Swap - Charging - Battery Swap Charging | PICS HFS-13 not supported: No battery swap station model: the simulator has no battery inventory or swap bays |

## Test cases

### A - Security

16 tests

| Test ID | Name | Status |
|---|---|---|
| TC_A_01_CS | Basic Authentication - Valid username/password combination | Passed |
| TC_A_04_CS | TLS - server-side certificate - Valid certificate | Passed |
| TC_A_05_CS | TLS - server-side certificate - Invalid certificate | Passed |
| TC_A_06_CS | TLS - server-side certificate - TLS version too low | Passed |
| TC_A_07_CS | TLS - Client-side certificate - valid certificate | Passed |
| TC_A_09_CS | Update Charging Station Password for HTTP Basic Authentication - Accepted | Passed |
| TC_A_10_CS | Update Charging Station Password for HTTP Basic Authentication - Rejected | Passed |
| TC_A_11_CS | Update Charging Station Certificate by request of CSMS - Success - Charging Station Certificate | Passed |
| TC_A_12_CS | Update Charging Station Certificate by request of CSMS - Success - V2G Certificate | Passed |
| TC_A_14_CS | Update Charging Station Certificate by request of CSMS - Invalid certificate | Passed |
| TC_A_15_CS | Update Charging Station Certificate by request of CSMS - SignCertificateRequest Rejected | Passed |
| TC_A_19_CS | Upgrade Charging Station Security Profile - Accepted | Passed |
| TC_A_20_CS | Upgrade Charging Station Security Profile - No valid CSMSRootCertificate installed | Passed |
| TC_A_21_CS | Upgrade Charging Station Security Profile - No valid ChargingStationCertificate installed | Passed |
| TC_A_22_CS | Upgrade Charging Station Security Profile - Downgrade security profile - Rejected | Passed |
| TC_A_23_CS | Update Charging Station Certificate by request of CSMS - CertificateSignedRequest Timeout | Passed |

### B - Provisioning

61 tests

| Test ID | Name | Status |
|---|---|---|
| TC_B_01_CS | Cold Boot Charging Station - Accepted | Passed |
| TC_B_02_CS | Cold Boot Charging Station - Pending | Passed |
| TC_B_03_CS | Cold Boot Charging Station - Rejected | Passed |
| TC_B_06_CS | Get Variables - single value | Passed |
| TC_B_07_CS | Get Variables - multiple values | Passed |
| TC_B_09_CS | Set Variables - single value | Passed |
| TC_B_10_CS | Set Variables - multiple values | Passed |
| TC_B_11_CS | Set Variables - invalidly formatted values | Passed |
| TC_B_12_CS | Get Base Report - ConfigurationInventory | Passed |
| TC_B_13_CS | Get Base Report - FullInventory | Passed |
| TC_B_14_CS | Get Base Report - SummaryInventory | Passed |
| TC_B_15_CS | Get Base Report - Not Supported base report (PICS C-56 supported: test requires a station without it (Support for providing the SummaryInventory)) | Not applicable |
| TC_B_16_CS | Get Custom Report - with component criteria | Passed |
| TC_B_17_CS | Get Custom Report - with component/variable | Passed |
| TC_B_18_CS | Get Custom Report - with component criteria and component/variable | Passed |
| TC_B_19_CS | Get Custom Report - for unknown component criteria | Passed |
| TC_B_20_CS | Reset Charging Station - Without ongoing transaction - OnIdle | Passed |
| TC_B_21_CS | Reset Charging Station - With Ongoing Transaction - OnIdle | Passed |
| TC_B_22_CS | Reset Charging Station - With Ongoing Transaction - Immediate | Passed |
| TC_B_23_CS | Reset Charging Station - Unavailable persists reset | Passed |
| TC_B_24_CS | Reset Charging Station - Reserved persists reset | Passed |
| TC_B_25_CS | Reset EVSE - Without ongoing transaction | Passed |
| TC_B_26_CS | Reset EVSE - With Ongoing Transaction - OnIdle | Passed |
| TC_B_27_CS | Reset EVSE - With Ongoing Transaction - Immediate | Passed |
| TC_B_28_CS | Reset EVSE - Not Supported (PICS C-13 supported: test requires a station without it (Support for Reset per EVSE (AllowReset))) | Not applicable |
| TC_B_29_CS | Reset EVSE - With ongoing transaction - Not Supported (PICS C-13 supported: test requires a station without it (Support for Reset per EVSE (AllowReset))) | Not applicable |
| TC_B_30_CS | Cold Boot Charging Station - Pending/Rejected - SecurityError | Passed |
| TC_B_32_CS | Get Variables - Unknown component | Passed |
| TC_B_33_CS | Get Variables - Unknown variable | Passed |
| TC_B_34_CS | Get Variables - Not supported attribute type | Passed |
| TC_B_35_CS | Set Variables - Unknown component | Passed |
| TC_B_36_CS | Set Variables - Unknown variable | Passed |
| TC_B_37_CS | Set Variables - Not supported attribute type | Passed |
| TC_B_39_CS | Set Variables - Read-only | Passed |
| TC_B_41_CS | Reset Charging Station - With multiple ongoing transactions - OnIdle | Passed |
| TC_B_43_CS | Set new NetworkConnectionProfile - Rejected | Passed |
| TC_B_45_CS | Migrate to new ConnectionProfile - Success - Same CSMS Root | Passed |
| TC_B_46_CS | Migrate to new ConnectionProfile - Fallback mechanism - Same CSMS Root | Passed |
| TC_B_47_CS | Migrate to new ConnectionProfile - Fallback after NetworkProfileConnectionAttempts - New CSMS Root | Passed |
| TC_B_49_CS | Migrate to new ConnectionProfile - Fallback after NetworkProfileConnectionAttempts | Passed |
| TC_B_50_CS | Migrate to new ConnectionProfile - Success - New CSMS Root - New CSMS | Passed |
| TC_B_51_CS | Status change during offline period - > Offline Threshold | Passed |
| TC_B_52_CS | Status change during offline period - < Offline Threshold | Passed |
| TC_B_53_CS | Get Base Report - Test mandatory DM variables via FullInventory | Passed |
| TC_B_54_CS | Get Custom Report - with component/variable, but no instance | Passed |
| TC_B_55_CS | Get Custom Report - with component/variable/instance | Passed |
| TC_B_56_CS | Get Custom Report - with component/variable, but no evseId | Passed |
| TC_B_57_CS | Network Reconnection - After connection loss | Passed |
| TC_B_100_CS | Set new NetworkConnectionProfile - Identity and password | Passed |
| TC_B_101_CS | Reset ImmediateAndResume - With Ongoing Transaction - TxResumptionTimeout 0 | Passed |
| TC_B_102_CS | Reset ImmediateAndResume - With ongoing transaction - Energy Transfer Suspended | Passed |
| TC_B_103_CS | Reset ImmediateAndResume - With Ongoing Transaction - Resuming Energy Transfer | Passed |
| TC_B_104_CS | Reset ImmediateAndResume - Without ongoing transaction | Passed |
| TC_B_105_CS | Set new NetworkConnectionProfile - Add new NetworkConfiguration using SetVariables | Passed |
| TC_B_107_CS | Set new NetworkConnectionProfile - Add and remove slot from NetworkConfigurationPriority | Passed |
| TC_B_108_CS | Set new NetworkConnectionProfile - Prevent overwriting configured Network Profile slot | Passed |
| TC_B_109_CS | Set new NetworkConnectionProfile - When changing SecurityCtrlr.Identity/BasicAuthPassword | Passed |
| TC_B_110_CS | Set new NetworkConnectionProfile - No security downgrade to profile #1 | Passed |
| TC_B_111_CS | Set new NetworkConnectionProfile - No security downgrade to profile #1 - DM | Passed |
| TC_B_112_CS | Set new NetworkConnectionProfile - AllowSecurityDowngrade is false | Passed |
| TC_B_113_CS | Set new NetworkConnectionProfile - AllowSecurityDowngrade = false - DM | Passed |

### C - Authorization

78 tests

| Test ID | Name | Status |
|---|---|---|
| TC_C_02_CS | Local start transaction - Authorization Invalid/Unknown | Passed |
| TC_C_04_CS | Local Stop Transaction - Different idToken | Passed |
| TC_C_05_CS | Local start transaction - Authorization invalid - Cable lock | Passed |
| TC_C_06_CS | Local start transaction - Authorization Blocked | Passed |
| TC_C_07_CS | Local start transaction - Authorization Expired | Passed |
| TC_C_08_CS | Authorization through authorization cache - Accepted | Passed |
| TC_C_09_CS | Authorization through authorization cache - Invalid & Not Accepted | Passed |
| TC_C_10_CS | Authorization through authorization cache - Blocked | Passed |
| TC_C_11_CS | Authorization through authorization cache - Expired | Passed |
| TC_C_12_CS | Authorization through authorization cache - Invalid & Accepted | Passed |
| TC_C_13_CS | Authorization through authorization cache - Accepted but cable not connected yet | Passed |
| TC_C_14_CS | Authorization through authorization cache - GroupID equal to MasterPassGroupId | Passed |
| TC_C_15_CS | Authorization through authorization cache - StopTxOnInvalidId = false, MaxEnergyOnInvalidId > 0 | Passed |
| TC_C_16_CS | Authorization through authorization cache - StopTxOnInvalidId = true | Passed |
| TC_C_17_CS | Authorization through authorization cache - StopTxOnInvalidId = false | Passed |
| TC_C_18_CS | Authorization through authorization cache - StopTxOnInvalidId = true, MaxEnergyOnInvalidId > 0 | Passed |
| TC_C_21_CS | Offline authorization through local authorization list - Accepted | Passed |
| TC_C_22_CS | Offline authorization through local authorization list - Invalid | Passed |
| TC_C_23_CS | Offline authorization through local authorization list - Blocked | Passed |
| TC_C_24_CS | Offline authorization through local authorization list - Expired | Passed |
| TC_C_25_CS | Offline authorization through local authorization list - Local Authorization List > Authorization Cache | Passed |
| TC_C_26_CS | Offline Authorization - Unknown Id | Passed |
| TC_C_27_CS | Online authorization through local authorization list - Accepted | Passed |
| TC_C_28_CS | Online authorization through local authorization list - Invalid & Not Accepted | Passed |
| TC_C_29_CS | Online authorization through local authorization list - Blocked | Passed |
| TC_C_30_CS | Online authorization through local authorization list - Expired | Passed |
| TC_C_31_CS | Online authorization through local authorization list - Invalid & Accepted | Passed |
| TC_C_32_CS | Store Authorization Data in the Authorization Cache - Persistent over reboot | Passed |
| TC_C_33_CS | Store Authorization Data in the Authorization Cache - Update on AuthorizeResponse | Passed |
| TC_C_34_CS | Store Authorization Data in the Authorization Cache - Update on TransactionResponse | Passed |
| TC_C_36_CS | Store Authorization Data in the Authorization Cache - LocalPreAuthorize = false | Passed |
| TC_C_37_CS | Clear Authorization Data in Authorization Cache - Accepted | Passed |
| TC_C_38_CS | Clear Authorization Data in Authorization Cache - Rejected | Passed |
| TC_C_39_CS | Authorization by GroupId - Success | Passed |
| TC_C_40_CS | Authorization by GroupId - Success with Local Authorization List | Passed |
| TC_C_41_CS | Authorization by GroupId - Success with Authorization Cache | Passed |
| TC_C_42_CS | Authorization by GroupId - Not stopped by GroupId | Passed |
| TC_C_43_CS | Authorization by GroupId - Invalid status with Local Authorization List | Passed |
| TC_C_44_CS | Authorization by GroupId - Invalid status with Authorization Cache | Passed |
| TC_C_45_CS | Authorization by GroupId - Master pass - Not able to start transaction + groupId | Passed |
| TC_C_46_CS | Store Authorization Data in the Authorization Cache - AuthCacheLifeTime | Passed |
| TC_C_47_CS | Stop Transaction with a Master Pass - With UI - All transactions | Passed |
| TC_C_48_CS | Stop Transaction with a Master Pass - With UI - Specific transactions | Passed |
| TC_C_49_CS | Stop Transaction with a Master Pass - Without UI | Passed |
| TC_C_50_CS | Authorization using Contract Certificates 15118 - Online - Local contract certificate validation - Accepted (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_C_51_CS | Authorization using Contract Certificates 15118 - Online - Local contract certificate validation - Rejected (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_C_52_CS | Authorization using Contract Certificates 15118 - Online - Central contract certificate validation (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_C_53_CS | Authorization using Contract Certificates 15118 - Online - Central contract validation fails (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_C_54_CS | Authorization using Contract Certificates 15118 - Offline - ContractValidationOffline is true (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_C_55_CS | Authorization using Contract Certificates 15118 - Offline - ContractValidationOffline is false (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_C_56_CS | Local start transaction - Authorization Unknown | Passed |
| TC_C_57_CS | Authorization through authorization cache - AuthCacheDisablePostAuthorize | Passed |
| TC_C_58_CS | Online authorization through local authorization list - LocalAuthListDisablePostAuthorize | Passed |
| TC_C_100_CS | Local start transaction - Authorization first - Cable plugin timeout (PICS none of C-51, C-09.2 supported: The simulator has no TxCtrlr.TxStartPoint variable; its start point is fixed; Transactions start once the EV is connected and the driver is authorized (PowerPathClosed); the simulator has no TxCtrlr.TxStartPoint) | Not applicable |
| TC_C_103_CS | Authorization with prepaid card - success | Passed |
| TC_C_104_CS | Authorization with prepaid card - no credit | Passed |
| TC_C_105_CS | Integrated Payment Terminal - CSMS rejects authorization (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_106_CS | Integrated Payment Terminal - Only Payment Terminal authorises (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_107_CS | Integrated Payment Terminal - Payment Terminal and CSMS authorises (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_108_CS | Integrated Payment Terminal - VAT number validation (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_109_CS | Integrated Payment Terminal - Cancelation prior to transaction - Only PT authorised - EVConnectTimeout (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_110_CS | Integrated Payment Terminal - Cancelation prior to transaction - PT and CSMS authorised (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_111_CS | Integrated Payment Terminal - Cancelation prior to transaction - Only PT authorised - EV driver cancels (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_112_CS | Integrated Payment Terminal - Cancelation prior to transaction - PT and CSMS authorised - EVConnectTimeout (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_113_CS | Integrated Payment Terminal - Cancelation after start of transaction - stopped by EV driver (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_114_CS | Settlement at end of transaction - settled by CS, receipt by CS (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_115_CS | Settlement at end of transaction - settled by CSMS (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_116_CS | Settlement at end of transaction - settled by CS, receipt by CSMS (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_119_CS | Settlement - is rejected or fails - Failed (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_120_CS | Settlement - is rejected or fails - Rejected (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_121_CS | Incremental authorization - increasing enabled (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_122_CS | Incremental authorization - increasing disabled (PICS P-2.2 not supported: No payment terminal: the simulator has no PaymentCtrlr, card pre-authorization, settlement, or receipts) | Not applicable |
| TC_C_123_CS | Ad hoc payment via stand-alone payment terminal - local cost calculation (PICS P-2.3 not supported: No stand-alone payment terminal or kiosk integration in the simulator) | Not applicable |
| TC_C_124_CS | Ad hoc payment via stand-alone payment terminal - central cost calculation (PICS P-2.3 not supported: No stand-alone payment terminal or kiosk integration in the simulator) | Not applicable |
| TC_C_127_CS | Ad hoc payment via static or dynamic QR code - no URL parameters | Passed |
| TC_C_128_CS | Ad hoc payment via static or dynamic QR code - URL parameter maxTime | Passed |
| TC_C_129_CS | Ad hoc payment via static or dynamic QR code - URL parameter maxCost | Passed |
| TC_C_130_CS | Ad hoc payment via static or dynamic QR code - URL parameter maxEnergy | Passed |

### D - Local Authorization List

9 tests

| Test ID | Name | Status |
|---|---|---|
| TC_D_01_CS | Send Local Authorization List - Full | Passed |
| TC_D_02_CS | Send Local Authorization List - Differential Update | Passed |
| TC_D_03_CS | Send Local Authorization List - Differential Remove | Passed |
| TC_D_04_CS | Send Local Authorization List - Full with empty list | Passed |
| TC_D_05_CS | Send Local Authorization List - Differential with empty list | Passed |
| TC_D_06_CS | Send Local Authorization List - VersionMismatch | Passed |
| TC_D_07_CS | Send Local Authorization List - Persistent over reboot | Passed |
| TC_D_08_CS | Get Local List Version - Success | Passed |
| TC_D_10_CS | Get Local List Version - Function disabled | Passed |

### E - Transactions

61 tests

| Test ID | Name | Status |
|---|---|---|
| TC_E_01_CS | Start transaction options - PowerPathClosed | Passed |
| TC_E_02_CS | Start transaction options - EnergyTransfer | Passed |
| TC_E_03_CS | Local start transaction - Cable plugin first - Success | Passed |
| TC_E_04_CS | Local start transaction - Authorization first - Success | Passed |
| TC_E_05_CS | Local start transaction - Authorization first - Cable plugin timeout | Passed |
| TC_E_06_CS | Local Stop Transaction - Accepted | Passed |
| TC_E_07_CS | Stop transaction options - PowerPathClosed - Local stop | Passed |
| TC_E_08_CS | Stop transaction options - EnergyTransfer stopped - StopAuthorized | Passed |
| TC_E_09_CS | Start transaction options - EVConnected | Passed |
| TC_E_10_CS | Start transaction options - Authorized - Local | Passed |
| TC_E_11_CS | Start transaction options - DataSigned | Passed |
| TC_E_12_CS | Start transaction options - ParkingBayOccupied | Passed |
| TC_E_13_CS | Start transaction options - Authorized - Remote | Passed |
| TC_E_14_CS | Stop transaction options - EVDisconnected - Charging Station side | Passed |
| TC_E_15_CS | Stop transaction options - StopAuthorized - Local | Passed |
| TC_E_16_CS | Stop transaction options - Deauthorized - Invalid idToken | Passed |
| TC_E_17_CS | Stop transaction options - Deauthorized - EV side disconnect | Passed |
| TC_E_19_CS | Stop transaction options - ParkingBayUnoccupied | Passed |
| TC_E_20_CS | Stop transaction options - EVDisconnected - EV side (able to charge IEC 61851-1 EV) | Passed |
| TC_E_21_CS | Stop transaction options - StopAuthorized - Remote | Passed |
| TC_E_22_CS | Stop transaction options - EnergyTransfer stopped - SuspendedEV | Passed |
| TC_E_24_CS | Disconnect cable on EV-side - Deauthorize transaction - UnlockOnEVSideDisconnect is true | Passed |
| TC_E_25_CS | Disconnect cable on EV-side - Deauthorize transaction - UnlockOnEVSideDisconnect is false | Passed |
| TC_E_26_CS | Disconnect cable on EV-side - Suspend transaction | Passed |
| TC_E_27_CS | Disconnect cable on EV-side - Suspend transaction - Fixed cable connection timeout | Passed |
| TC_E_28_CS | Check Transaction status - TransactionId unknown | Passed |
| TC_E_29_CS | Check Transaction status - Transaction with id ongoing - with message in queue | Passed |
| TC_E_30_CS | Check Transaction status - Transaction with id ongoing - without message in queue | Passed |
| TC_E_31_CS | Check Transaction status - Transaction with id ended - with message in queue | Passed |
| TC_E_32_CS | Check Transaction status - Transaction with id ended - without message in queue | Passed |
| TC_E_33_CS | Check Transaction status - Without transactionId - with message in queue | Passed |
| TC_E_34_CS | Check Transaction status - Without transactionId - without message in queue | Passed |
| TC_E_35_CS | Stop transaction options - PowerPathClosed - Remote stop | Passed |
| TC_E_37_CS | Stop transaction options - PowerPathClosed - EV side disconnect | Passed |
| TC_E_38_CS | Local start transaction - EV not ready | Passed |
| TC_E_39_CS | Stop transaction options - Deauthorized - timeout | Passed |
| TC_E_40_CS | Offline Behaviour - Connection loss during transaction | Passed |
| TC_E_41_CS | Retry sending transaction message when failed - Max retry count reached | Passed |
| TC_E_42_CS | Retry sending transaction message when failed - Success before reaching the max retry count | Passed |
| TC_E_43_CS | Offline Behaviour - Transaction during offline period | Passed |
| TC_E_44_CS | Offline Behaviour - Stop transaction during offline period | Passed |
| TC_E_45_CS | Offline Behaviour - Stop transaction during offline period - Same GroupId | Passed |
| TC_E_46_CS | End of charging process 15118 | Passed |
| TC_E_50_CS | Retry sending transaction message when failed - Max retry count reached - CallError | Passed |
| TC_E_51_CS | Retry sending transaction message when failed - Success before reaching the max retry count - CallError | Passed |
| TC_E_52_CS | Local start transaction - Authorization first - DisableRemoteAuthorization | Passed |
| TC_E_54_CS | Stop transaction options - EVDisconnected - EV side (not able to charge IEC 61851-1 EV) | Passed |
| TC_E_100_CS | Transactions with fixed cost, energy or time - CSMS specifies energy limit | Passed |
| TC_E_101_CS | Transactions with fixed cost, energy or time - CSMS calculates costs and specifies limit | Passed |
| TC_E_102_CS | Transactions with fixed cost, energy or time - CSMS and CS both specify limits | Passed |
| TC_E_103_CS | Transactions with fixed cost, energy or time - CS calculates costs and CSMS specifies limit | Passed |
| TC_E_104_CS | Transactions with fixed cost, energy or time - CSMS calculates costs (through TransactionEventResponse) | Passed |
| TC_E_105_CS | Transactions with fixed cost, energy or time - CSMS specifies time limit | Passed |
| TC_E_106_CS | Transactions with fixed cost, energy or time - CS specifies energy limit | Passed |
| TC_E_107_CS | Transactions with fixed cost, energy or time - CS specifies time limit | Passed |
| TC_E_108_CS | Transactions with fixed cost, energy or time - CS calculates costs and specifies limit | Passed |
| TC_E_112_CS | Resuming transaction after interruption - TxResumptionTimeout not expired - AllowEnergyTransferResumption false | Passed |
| TC_E_113_CS | Resuming transaction after interruption - TxResumptionTimeout not expired - AllowEnergyTransferResumption true | Passed |
| TC_E_114_CS | Resuming transaction after interruption - Powerloss - TxResumptionTimeout absent | Passed |
| TC_E_115_CS | Resuming transaction after interruption - Powerloss - TxResumptionTimeout = 0 | Passed |
| TC_E_116_CS | Resuming transaction after interruption - Powerloss - TxResumptionTimeout expired | Passed |

### F - Remote Control

25 tests

| Test ID | Name | Status |
|---|---|---|
| TC_F_01_CS | Remote start transaction - Cable plugin first | Passed |
| TC_F_02_CS | Remote start transaction - Remote start first - AuthorizeRemoteStart is true | Passed |
| TC_F_03_CS | Remote start transaction - Remote start first - AuthorizeRemoteStart is false | Passed |
| TC_F_04_CS | Remote start transaction - Remote start first - Cable plugin timeout | Passed |
| TC_F_05_CS | Remote unlock Connector - With ongoing transaction | Passed |
| TC_F_06_CS | Remote unlock Connector - Without ongoing transaction - Accepted | Passed |
| TC_F_07_CS | Remote unlock Connector - Without ongoing transaction - No cable connected | Passed |
| TC_F_08_CS | Remote stop transaction - Success | Passed |
| TC_F_09_CS | Remote stop transaction - Rejected | Passed |
| TC_F_10_CS | Remote unlock Connector - Without ongoing transaction - UnknownConnector | Passed |
| TC_F_11_CS | Trigger message - MeterValues - Specific EVSE | Passed |
| TC_F_12_CS | Trigger message - MeterValues - All EVSE | Passed |
| TC_F_13_CS | Trigger message - TransactionEvent - Specific EVSE | Passed |
| TC_F_14_CS | Trigger message - TransactionEvent - All EVSE | Passed |
| TC_F_15_CS | Trigger message - LogStatusNotification - Idle | Passed |
| TC_F_16_CS | Trigger message - LogStatusNotification - Uploading | Passed |
| TC_F_17_CS | Trigger message - FirmwareStatusNotification - Specific EVSE not relevant | Passed |
| TC_F_18_CS | Trigger message - FirmwareStatusNotification - Idle | Passed |
| TC_F_19_CS | Trigger message - FirmwareStatusNotification - Downloading | Passed |
| TC_F_20_CS | Trigger message - Heartbeat | Passed |
| TC_F_23_CS | Trigger message - StatusNotification - Specific EVSE - Available | Passed |
| TC_F_24_CS | Trigger message - StatusNotification - Specific EVSE - Occupied | Passed |
| TC_F_26_CS | Trigger message - BootNotification - Rejected | Passed |
| TC_F_27_CS | Trigger message - NotImplemented | Passed |
| TC_F_100_CS | Trigger message - CustomTrigger | Passed |

### G - Availability

21 tests

| Test ID | Name | Status |
|---|---|---|
| TC_G_01_CS | Connector status Notification - Available to Occupied | Passed |
| TC_G_02_CS | Connector status Notification - Occupied to Available | Passed |
| TC_G_03_CS | Change Availability EVSE - Operative to inoperative | Passed |
| TC_G_04_CS | Change Availability EVSE - Inoperative to operative | Passed |
| TC_G_05_CS | Change Availability Charging Station - Operative to inoperative | Passed |
| TC_G_06_CS | Change Availability Charging Station - Inoperative to operative | Passed |
| TC_G_07_CS | Change Availability Connector - Operative to inoperative | Passed |
| TC_G_08_CS | Change Availability Connector - Inoperative to operative | Passed |
| TC_G_09_CS | Change Availability EVSE - Operative to operative | Passed |
| TC_G_10_CS | Change Availability EVSE - Inoperative to inoperative | Passed |
| TC_G_11_CS | Change Availability EVSE - With ongoing transaction | Passed |
| TC_G_12_CS | Change Availability Charging Station - Operative to operative | Passed |
| TC_G_13_CS | Change Availability Charging Station - Inoperative to inoperative | Passed |
| TC_G_14_CS | Change Availability Charging Station - With ongoing transaction | Passed |
| TC_G_15_CS | Change Availability Connector - Operative to operative | Passed |
| TC_G_16_CS | Change Availability Connector - Inoperative to inoperative | Passed |
| TC_G_17_CS | Change Availability Connector - With ongoing transaction | Passed |
| TC_G_18_CS | Change Availability EVSE - state persists across reboot | Passed |
| TC_G_19_CS | Change Availability Connector - state persists across reboot | Passed |
| TC_G_20_CS | Connector status Notification - Lock Failure | Passed |
| TC_G_21_CS | Change Availability Charging Station - state persists across reboot | Passed |

### H - Reservation

21 tests

| Test ID | Name | Status |
|---|---|---|
| TC_H_01_CS | Reserve a specific EVSE - Accepted - Valid idToken | Passed |
| TC_H_02_CS | Reserve a specific EVSE - Accepted - Different idToken | Passed |
| TC_H_03_CS | Reserve a specific EVSE - Occupied - EVSE Reserved | Passed |
| TC_H_04_CS | Reserve a specific EVSE - Occupied - EVSE Occupied | Passed |
| TC_H_06_CS | Reserve a specific EVSE - Unavailable | Passed |
| TC_H_07_CS | Reserve a specific EVSE - Reservation Ended / not used | Passed |
| TC_H_08_CS | Reserve an unspecified EVSE - Accepted | Passed |
| TC_H_09_CS | Reserve an unspecified EVSE - Occupied - EVSE Reserved | Passed |
| TC_H_10_CS | Reserve an unspecified EVSE - Occupied - EVSE Occupied | Passed |
| TC_H_12_CS | Reserve an unspecified EVSE - Unavailable | Passed |
| TC_H_13_CS | Reserve an unspecified EVSE - Rejected | Passed |
| TC_H_14_CS | Reserve an unspecified EVSE - Amount of EVSEs available equals the amount of reservations | Passed |
| TC_H_15_CS | Reserve a connector with a specific type - Success | Passed |
| TC_H_16_CS | Reserve a connector with a specific type - Amount of available connectors equals reservations | Passed |
| TC_H_17_CS | Cancel reservation of an EVSE - Success | Passed |
| TC_H_18_CS | Cancel reservation of an EVSE - Rejected | Passed |
| TC_H_19_CS | Reserve a specific EVSE - Use a reserved EVSE with GroupId | Passed |
| TC_H_21_CS | Charging Station cancels reservation when Unavailable | Passed |
| TC_H_22_CS | Reserve a specific EVSE - Configured to Reject | Passed |
| TC_H_23_CS | Reserve a specific EVSE - Replace reservation | Passed |
| TC_H_24_CS | Reserve an unspecified EVSE - GroupIdToken | Passed |

### I - Tariff and Cost

25 tests

| Test ID | Name | Status |
|---|---|---|
| TC_I_01_CS | Show EV Driver running total cost during charging - costUpdatedRequest | Passed |
| TC_I_02_CS | Show EV Driver Final Total Cost After Charging | Passed |
| TC_I_07_CS | Show EV Driver running total cost during charging - transactionEventResponse | Passed |
| TC_I_100_CS | Set Default Tariff - validFrom | Passed |
| TC_I_101_CS | Set Default Tariff - startTimeOfDay, endTimeOfDay | Passed |
| TC_I_102_CS | Set Default Tariff - TariffMaxElements | Passed |
| TC_I_103_CS | Set Default Tariff - CS doesn’t support local cost calculation (PICS NoLocalCostCalculation not supported: The simulator supports local cost calculation (P-0). With TariffCostCtrlr.Enabled[Tariff] false it still accepts a default tariff, as TC_I_107_CS (Part 5, P-0) requires; Part 5 does not list TC_I_103) | Not applicable |
| TC_I_104_CS | Set Default Tariff - transaction with default tariff | Passed |
| TC_I_105_CS | Set Default Tariff - TariffConditionsSupported is false | Passed |
| TC_I_106_CS | Set Default Tariff - validations | Passed |
| TC_I_107_CS | Receive Driver Tariff - CS cannot process tariff - UseDefault/CentralCost | Passed |
| TC_I_108_CS | Receive Driver Tariff - CS cannot process tariff - Deauthorize | Passed |
| TC_I_109_CS | Receive Driver Tariff - Goodflow | Passed |
| TC_I_110_CS | Clear Tariffs - DefaultTariff | Passed |
| TC_I_111_CS | Clear Tariffs - Tariff in use | Passed |
| TC_I_112_CS | Local Cost Calculation - Change transaction tariff - local cost calculation unsupported | Passed |
| TC_I_113_CS | Local Cost Calculation - Change transaction tariff - TariffMaxElements | Passed |
| TC_I_114_CS | Local Cost Calculation - Change transaction tariff - TariffConditionsSupported is false | Passed |
| TC_I_115_CS | Local Cost Calculation - Change transaction tariff - TariffConditionsSupported is true | Passed |
| TC_I_116_CS | Local Cost Calculation - Change transaction tariff - goodflow | Passed |
| TC_I_117_CS | Local Cost Calculation - Change transaction tariff - validations | Passed |
| TC_I_118_CS | Local Cost Calculation - Cost Details of Transaction - no tariff conditions | Passed |
| TC_I_119_CS | Local Cost Calculation - Cost Details of Transaction - with tariff conditions | Passed |
| TC_I_120_CS | Local Cost Calculation - Cost Details of Transaction - reservation (PICS P-1 not supported: The simulator calculates cost from unconditional tariff prices only; SetDefaultTariff answers ConditionNotSupported) | Not applicable |
| TC_I_121_CS | Local Cost Calculation - Cost Details of Transaction - minCost/maxCost (PICS P-1 not supported: The simulator calculates cost from unconditional tariff prices only; SetDefaultTariff answers ConditionNotSupported) | Not applicable |

### J - Meter Values

10 tests

| Test ID | Name | Status |
|---|---|---|
| TC_J_01_CS | Clock-aligned Meter Values - No transaction ongoing | Passed |
| TC_J_02_CS | Clock-aligned Meter Values - Transaction ongoing | Passed |
| TC_J_03_CS | Clock-aligned Meter Values - EventType Ended | Passed |
| TC_J_04_CS | Clock-aligned Meter Values - Signed | Passed |
| TC_J_06_CS | Clock-aligned Meter Values - No Meter Values during transaction | Passed |
| TC_J_07_CS | Sampled Meter Values - EventType Started - EVSE known | Passed |
| TC_J_08_CS | Sampled Meter Values - Context Transaction.Begin - EVSE not known | Passed |
| TC_J_09_CS | Sampled Meter Values - EventType Updated | Passed |
| TC_J_10_CS | Sampled Meter Values - EventType Ended | Passed |
| TC_J_11_CS | Sampled Meter Values - Signed | Passed |

### K - Smart Charging

76 tests

| Test ID | Name | Status |
|---|---|---|
| TC_K_01_CS | Set Charging Profile - TxDefaultProfile - Specific EVSE | Passed |
| TC_K_02_CS | Set Charging Profile - TxProfile without ongoing transaction | Passed |
| TC_K_03_CS | Set Charging Profile - ChargingStationMaxProfile | Passed |
| TC_K_04_CS | Replace charging profile - With chargingProfileId | Passed |
| TC_K_05_CS | Clear Charging Profile - With chargingProfileId | Passed |
| TC_K_06_CS | Clear Charging Profile - With stackLevel/purpose combination | Passed |
| TC_K_07_CS | Clear Charging Profile - Unknown stackLevel/purpose | Passed |
| TC_K_08_CS | Clear Charging Profile - Without previous profile | Passed |
| TC_K_09_CS | Clear Charging Profile - TxDefaultProfile with ongoing transaction | Passed |
| TC_K_10_CS | Set Charging Profile - TxDefaultProfile - All EVSE | Passed |
| TC_K_11_CS | Set Charging Profile - Unable to set TxProfile on all EVSE at once | Passed |
| TC_K_12_CS | Set Charging Profile - ChargerRateUnit Rejected (PICS SingleChargingRateUnit not supported: The simulator supports both A and W (SmartChargingCtrlr.RateUnit A,W)) | Not applicable |
| TC_K_13_CS | Set Charging Profile - Persistent over reboot | Passed |
| TC_K_14_CS | Set Charging Profile - Unexisting EVSEid | Passed |
| TC_K_15_CS | Set Charging Profile - Not Supported (PICS NoSmartCharging not supported: The simulator supports smart charging (SmartChargingCtrlr.Enabled), so it never answers NotSupported) | Not applicable |
| TC_K_16_CS | Set Charging Profile - Unknown transactionId | Passed |
| TC_K_19_CS | Set Charging Profile - ChargingProfileKind is Recurring | Passed |
| TC_K_21_CS | Set Charging Profile - ValidFrom | Passed |
| TC_K_22_CS | Set Charging Profile - ValidTo | Passed |
| TC_K_23_CS | Set Charging Profile - StartSchedule | Passed |
| TC_K_24_CS | Clear Charging Profile - stackLevel/purpose for multiple profiles | Passed |
| TC_K_28_CS | Set Charging Profile - TxDefaultProfile with transaction ongoing | Passed |
| TC_K_29_CS | Get Charging Profile - EvseId 0 | Passed |
| TC_K_30_CS | Get Charging Profile - EvseId > 0 | Passed |
| TC_K_31_CS | Get Charging Profile - No EvseId | Passed |
| TC_K_32_CS | Get Charging Profile - chargingProfileId | Passed |
| TC_K_33_CS | Get Charging Profile - EvseId > 0 + stackLevel | Passed |
| TC_K_34_CS | Get Charging Profile - EvseId > 0 + chargingLimitSource | Passed |
| TC_K_35_CS | Get Charging Profile - EvseId > 0 + chargingProfilePurpose | Passed |
| TC_K_36_CS | Get Charging Profile - EvseId > 0 + purpose + stackLevel | Passed |
| TC_K_37_CS | Remote start transaction with charging profile - Success | Passed |
| TC_K_38_CS | Remote start transaction with charging profile - Ignore chargingProfile | Passed |
| TC_K_39_CS | Get Composite Schedule - No ChargingProfile installed | Passed |
| TC_K_40_CS | Get Composite Schedule - Stacking ChargingProfiles | Passed |
| TC_K_41_CS | Get Composite Schedule - Combining chargingProfilePurposes | Passed |
| TC_K_42_CS | Get Composite Schedule - chargingRateUnit not supported (PICS SingleChargingRateUnit not supported: The simulator supports both A and W (SmartChargingCtrlr.RateUnit A,W)) | Not applicable |
| TC_K_47_CS | Get Composite Schedule - Unknown EVSEId | Passed |
| TC_K_52_CS | EMS Control - Set / Update External Charging Limit | Passed |
| TC_K_53_CS | Charging with load leveling based on HLC - Success (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_54_CS | Charging with HLC - No SASchedule (rejected) (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_56_CS | Charging with HLC - Offline (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_57_CS | Renegotiating Charging Schedule ISO 15118-2 - EV initiated (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_58_CS | Renegotiating Charging Schedule ISO 15118-2 - CSMS initiated (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_60_CS | Set Charging Profile - TxProfile with ongoing transaction on the specified EVSE | Passed |
| TC_K_100_CS | Set Charging Profile - maxOfflineDuration | Passed |
| TC_K_101_CS | Set Charging Profile - Change operation mode (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_K_102_CS | Set Charging Profile - limitAtSoc (PICS SC-3 not supported: The simulated EV reports no state of charge (no ISO 15118 or CHAdeMO), so limitAtSoC cannot apply) | Not applicable |
| TC_K_103_CS | Set Charging Profile - Local time - TimeOffset (PICS SC-5.1 not supported: Charging schedules are evaluated in UTC only (SmartChargingCtrlr.SupportsFeature#UseLocalTime false)) | Not applicable |
| TC_K_104_CS | Set Charging Profile - PriorityCharging (PICS SC-6 not supported: No PriorityCharging profile purpose or local priority request in the simulator) | Not applicable |
| TC_K_105_CS | Set Charging Profile - ChargingStationMaxProfile persistent over reboot | Passed |
| TC_K_106_CS | Set Charging Profile - randomizedDelay (PICS SC-7 not supported: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false)) | Not applicable |
| TC_K_107_CS | Set Charging Profile - randomizedDelay - validations (PICS SC-7 not supported: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false)) | Not applicable |
| TC_K_108_CS | Set Charging Profile - randomizedDelay - random for each tx (PICS SC-7 not supported: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false)) | Not applicable |
| TC_K_109_CS | EMS Control - Set Charging Profile - MaxExternalConstraintsId (PICS SC-10 not supported: No local EMS interface and no MaxExternalConstraintsId; external limits only arrive from the CSMS) | Not applicable |
| TC_K_110_CS | EMS Control - Set Charging Profile - MaxExternalConstraintsId - validations (PICS SC-10 not supported: No local EMS interface and no MaxExternalConstraintsId; external limits only arrive from the CSMS) | Not applicable |
| TC_K_112_CS | Get Composite Schedule - randomizedDelay (PICS SC-7 not supported: No randomized start delay in the simulator (SmartChargingCtrlr.SupportsFeature#RandomizedDelay false)) | Not applicable |
| TC_K_113_CS | Renegotiating Charging Schedule ISO 15118-20 - CSMS initiated (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_114_CS | Renegotiating Charging Schedule ISO 15118-20 - EV initiated (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_115_CS | ISO 15118-20 Dynamic Control Mode - Success (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_116_CS | Renegotiating ISO 15118-20 - Adjusting schedule on energy needs (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_K_118_CS | Priority Charging - Remote (PICS SC-6 not supported: No PriorityCharging profile purpose or local priority request in the simulator) | Not applicable |
| TC_K_119_CS | Priority Charging - Local (PICS SC-6 not supported: No PriorityCharging profile purpose or local priority request in the simulator) | Not applicable |
| TC_K_120_CS | EMS Control - Smart Charging with EMS and LocalGeneration (PICS LocalEmsConnection not supported: The simulator has no local EMS or external system interface; external limits only arrive from the CSMS) | Not applicable |
| TC_K_121_CS | Dynamic charging profiles from CSMS - Pull (PICS SC-8 not supported: Dynamic charging profiles (PullDynamicScheduleUpdate, UpdateDynamicSchedule) are not implemented) | Not applicable |
| TC_K_122_CS | Dynamic charging profiles from CSMS - Push (PICS SC-8 not supported: Dynamic charging profiles (PullDynamicScheduleUpdate, UpdateDynamicSchedule) are not implemented) | Not applicable |
| TC_K_123_CS | Dynamic charging profiles from CSMS - validations (PICS SC-8 not supported: Dynamic charging profiles (PullDynamicScheduleUpdate, UpdateDynamicSchedule) are not implemented) | Not applicable |
| TC_K_124_CS | Dynamic profiles by external system - No Dynamic profile configured (PICS LocalEmsConnection not supported: The simulator has no local EMS or external system interface; external limits only arrive from the CSMS) | Not applicable |
| TC_K_125_CS | Dynamic profiles by external system - Dynamic profile configured (PICS LocalEmsConnection not supported: The simulator has no local EMS or external system interface; external limits only arrive from the CSMS) | Not applicable |
| TC_K_129_CS | Set Charging Profile - PriorityCharging persistent over reboot (PICS SC-6 not supported: No PriorityCharging profile purpose or local priority request in the simulator) | Not applicable |
| TC_K_130_CS | Set Charging Profile - PriorityCharging unsupported | Passed |
| TC_K_131_CS | Set Charging Profile - LocalGeneration unsupported | Passed |
| TC_K_132_CS | Set Charging Profile - useLocalTime unsupported | Passed |
| TC_K_133_CS | Set Charging Profile - RandomizedDelay unsupported | Passed |
| TC_K_134_CS | Set Charging Profile - LimitAtSoC unsupported | Passed |
| TC_K_135_CS | Idle operationMode - Set Charging Profile - EvseSleep unsupported | Passed |
| TC_K_136_CS | Set Charging Profile - Local time - TimeZone (PICS SC-5.2 not supported: Charging schedules are evaluated in UTC only (SmartChargingCtrlr.SupportsFeature#UseLocalTime false)) | Not applicable |

### L - Firmware Management

15 tests

| Test ID | Name | Status |
|---|---|---|
| TC_L_01_CS | Secure Firmware Update - Installation successful | Passed |
| TC_L_02_CS | Secure Firmware Update - InstallScheduled | Passed |
| TC_L_03_CS | Secure Firmware Update - DownloadScheduled | Passed |
| TC_L_05_CS | Secure Firmware Update - InvalidCertificate | Passed |
| TC_L_06_CS | Secure Firmware Update - InvalidSignature | Passed |
| TC_L_07_CS | Secure Firmware Update - DownloadFailed | Passed |
| TC_L_08_CS | Secure Firmware Update - InstallVerificationFailed or InstallationFailed | Passed |
| TC_L_10_CS | Secure Firmware Update - AcceptedCanceled | Passed |
| TC_L_11_CS | Secure Firmware Update - Unable to cancel (PICS C-60 supported: test requires a station without it (Support for cancelling ongoing firmware update (AcceptedCanceled))) | Not applicable |
| TC_L_12_CS | Secure Firmware Update - Unable to download/install firmware with ongoing transaction - AllowNewSessionsPendingFirmwareUpdate is true (PICS AQ-7 supported: test requires a station without it (The Charging Station is able to download firmware while there is an ongoing transaction)) | Not applicable |
| TC_L_13_CS | Secure Firmware Update - Unable to download/install firmware with ongoing transaction - AllowNewSessionsPendingFirmwareUpdate is false (PICS AQ-7 supported: test requires a station without it (The Charging Station is able to download firmware while there is an ongoing transaction)) | Not applicable |
| TC_L_14_CS | Secure Firmware Update - Unable to install and activate firmware with ongoing transaction - AllowNewSessionsPendingFirmwareUpdate is true | Passed |
| TC_L_15_CS | Secure Firmware Update - Unable to install and activate firmware with ongoing transaction - AllowNewSessionsPendingFirmwareUpdate is false | Passed |
| TC_L_16_CS | Secure Firmware Update - Able to update firmware with ongoing transaction (PICS C-43 not supported: The simulator downloads a firmware during a transaction but installs it only after all transactions ended (InstallScheduled)) | Not applicable |
| TC_L_18_CS | Secure Firmware Update - Missing firmware signing certificate and signature | Passed |

### M - Certificate Management

27 tests

| Test ID | Name | Status |
|---|---|---|
| TC_M_01_CS | Install CA certificate - CSMSRootCertificate | Passed |
| TC_M_02_CS | Install CA certificate - ManufacturerRootCertificate | Passed |
| TC_M_03_CS | Install CA certificate - V2GRootCertificate | Passed |
| TC_M_04_CS | Install CA certificate - MORootCertificate | Passed |
| TC_M_07_CS | Install CA certificate - Rejected - Certificate invalid | Passed |
| TC_M_09_CS | Install CA certificate - AdditionalRootCertificateCheck - Rejected | Passed |
| TC_M_12_CS | Retrieve certificates - CSMSRootCertificate | Passed |
| TC_M_13_CS | Retrieve certificates - ManufacturerRootCertificate | Passed |
| TC_M_14_CS | Retrieve certificates - V2GRootCertificate | Passed |
| TC_M_15_CS | Retrieve certificates - V2GCertificateChain | Passed |
| TC_M_16_CS | Retrieve certificates - MORootCertificate | Passed |
| TC_M_17_CS | Retrieve certificates - CSMSRootCertificate & ManufacturerRootCertificate | Passed |
| TC_M_18_CS | Retrieve certificates - All certificateTypes | Passed |
| TC_M_19_CS | Retrieve certificates - No matching certificate found | Passed |
| TC_M_20_CS | Delete a certificate - Success | Passed |
| TC_M_22_CS | Delete a certificate - No matching certificate found | Passed |
| TC_M_23_CS | Delete a certificate - Unable to delete CS Certificate | Passed |
| TC_M_24_CS | Get Charging Station Certificate status - Success (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_M_25_CS | Get Charging Station Certificate status - Rejected (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_M_26_CS | Certificate Installation EV - Success (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_M_27_CS | Certificate Installation EV - Failed (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_M_28_CS | Certificate Update EV - Success (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_M_29_CS | Certificate Update EV - Failed (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_M_30_CS | Install CA certificate - AdditionalRootCertificateCheck - Reconnect Success | Passed |
| TC_M_31_CS | Install CA certificate - AdditionalRootCertificateCheck - Reconnect Fallback | Passed |
| TC_M_100_CS | Certificate Installation EV - ISO 15118-20 - Success (PICS ISO15118Support not supported: No ISO 15118 stack: the simulator has no EV-EVSE high-level communication, EV emulator, or V2G charging station certificate) | Not applicable |
| TC_M_101_CS | Install CA certificate - OEMRootCertificate | Passed |

### N - Diagnostics

61 tests

| Test ID | Name | Status |
|---|---|---|
| TC_N_01_CS | Get Monitoring Report - with monitoringCriteria | Passed |
| TC_N_02_CS | Get Monitoring Report - with component/variable | Passed |
| TC_N_03_CS | Get Monitoring Report - criteria + component/variable | Passed |
| TC_N_04_CS | Get Monitoring Report - unknown component criteria | Passed |
| TC_N_05_CS | Set Monitoring Base - success | Passed |
| TC_N_06_CS | Set Monitoring Base - test removal custom monitors | Passed |
| TC_N_07_CS | Set Monitoring Base - for unknown base type | Passed |
| TC_N_08_CS | Set Variable Monitoring - one element | Passed |
| TC_N_09_CS | Set Variable Monitoring - Multiple elements | Passed |
| TC_N_10_CS | Set Variable Monitoring - Multiple on same component/variable | Passed |
| TC_N_11_CS | Set Variable Monitoring - Unknown component | Passed |
| TC_N_12_CS | Set Variable Monitoring - Value out of range - Delta | Passed |
| TC_N_13_CS | Set Variable Monitoring - Value out of range - Threshold | Passed |
| TC_N_15_CS | Set Variable Monitoring - Duplicate Variable type/severity combination | Passed |
| TC_N_16_CS | Set Monitoring Level - Success | Passed |
| TC_N_17_CS | Set Monitoring Level - Out of range | Passed |
| TC_N_18_CS | Clear Monitoring - Success | Passed |
| TC_N_19_CS | Clear Monitoring - Not found | Passed |
| TC_N_20_CS | Alert Event - Threshold value exceeded | Passed |
| TC_N_21_CS | Alert Event - Caused by hardwired trigger | Passed |
| TC_N_22_CS | Offline Notification - Queued (severity equal or lower) | Passed |
| TC_N_23_CS | Offline Notification - Not queued (severity higher) | Passed |
| TC_N_24_CS | Set Variable Monitoring - Periodic event | Passed |
| TC_N_25_CS | Retrieve Log Information - Diagnostics Log - Success | Passed |
| TC_N_26_CS | Retrieve Log Information - Diagnostics Log - Upload failed | Passed |
| TC_N_27_CS | Get Customer Information - Accepted + data | Passed |
| TC_N_28_CS | Get Customer Information - Accepted + no data | Passed |
| TC_N_29_CS | Get Customer Information - Not Accepted | Passed |
| TC_N_30_CS | Clear Customer Information - Clear and report + data | Passed |
| TC_N_31_CS | Clear Customer Information - Clear and report + no data | Passed |
| TC_N_32_CS | Clear Customer Information - Clear and no report | Passed |
| TC_N_33_CS | Clear Customer Information - Invalid | Passed |
| TC_N_34_CS | Retrieve Log Information - Rejected (PICS NoLogInformationAvailable not supported: The simulator always has diagnostics and security log information to upload, so it cannot be put in a state without log information) | Not applicable |
| TC_N_35_CS | Retrieve Log Information - Security Log - Success | Passed |
| TC_N_36_CS | Retrieve Log Information - Second Request | Passed |
| TC_N_37_CS | Set Variable Monitoring - Unknown Variable | Passed |
| TC_N_38_CS | Set Variable Monitoring - Not supported MonitorType | Passed |
| TC_N_39_CS | Set Variable Monitoring - Component/Variable combination does NOT correspond | Passed |
| TC_N_40_CS | Set Variable Monitoring - Replace Variable Monitor | Passed |
| TC_N_41_CS | Set Variable Monitoring - Return to FactoryDefault | Passed |
| TC_N_43_CS | Set Variable Monitoring - First SetMonitoringData and third SetMonitoringData are valid, but the second contains an out of range value | Passed |
| TC_N_44_CS | Clear Monitoring - Rejected | Passed |
| TC_N_45_CS | Alert Event - Delta value exceeded | Passed |
| TC_N_47_CS | Get Monitoring Report - Report all | Passed |
| TC_N_48_CS | Alert Event - Variable monitoring on write only | Passed |
| TC_N_51_CS | Set Variable Monitoring - Modifying a VariableMonitor and trigger | Passed |
| TC_N_52_CS | Set Variable Monitoring - Removing a VariableMonitor | Passed |
| TC_N_53_CS | Alert Event - Persistant over reboot | Passed |
| TC_N_56_CS | Alert Event - Delta value NOT numeric exceeded | Passed |
| TC_N_61_CS | Alert Event - Variable monitoring on numeric | Passed |
| TC_N_62_CS | Clear Customer Information - customerIdentifier | Passed |
| TC_N_63_CS | Clear Customer Information - customerCertificate | Passed |
| TC_N_100_CS | Retrieve Log Information - DataCollectorLog - Success | Passed |
| TC_N_101_CS | Retrieve Log Information - validations (redirect failure) | Passed |
| TC_N_102_CS | Retrieve Log Information - Authentication - HTTP | Passed |
| TC_N_103_CS | Retrieve Log Information - Authentication - HTTPS | Passed |
| TC_N_104_CS | Get Monitoring Report - TargetDeltaMonitoring | Passed |
| TC_N_105_CS | Set Frequent Periodic Variable Monitoring - Periodic | Passed |
| TC_N_106_CS | Set Frequent Periodic Variable Monitoring - CSMS rejects stream | Passed |
| TC_N_108_CS | Close Periodic Event Streams | Passed |
| TC_N_109_CS | Adjust Periodic Event Streams | Passed |

### O - Display Message

33 tests

| Test ID | Name | Status |
|---|---|---|
| TC_O_01_CS | Set Display Message - Success | Passed |
| TC_O_02_CS | Get all Display Messages - Success | Passed |
| TC_O_03_CS | Get all Display Messages - None configured | Passed |
| TC_O_04_CS | Clear Display Message - Success | Passed |
| TC_O_05_CS | Clear Display Message - Unknown Key | Passed |
| TC_O_06_CS | Set Display Message - Specific transaction - Success | Passed |
| TC_O_07_CS | Get Specific Display Message - Id | Passed |
| TC_O_08_CS | Get Specific Display Message - Priority | Passed |
| TC_O_09_CS | Get Specific Display Message - State | Passed |
| TC_O_10_CS | Set Display Message - Specific transaction - UnknownTransaction | Passed |
| TC_O_11_CS | Get Specific Display Message - Unknown parameters | Passed |
| TC_O_12_CS | Set Display Message - Replace DisplayMessage | Passed |
| TC_O_13_CS | Set Display Message - Display at StartTime | Passed |
| TC_O_14_CS | Set Display Message - Remove after EndTime | Passed |
| TC_O_17_CS | Set Display Message - NotSupportedPriority | Passed |
| TC_O_18_CS | Set Display Message - NotSupportedState | Passed |
| TC_O_19_CS | Set Display Message - NotSupportedMessageFormat | Passed |
| TC_O_20_CS | Set Display Message - Persistent over reboot | Passed |
| TC_O_22_CS | Set Display Message - Multiple In front priority | Passed |
| TC_O_24_CS | Set Display Message - Second Alwaysfront priority | Passed |
| TC_O_27_CS | Set Display Message - Transaction - StartTime | Passed |
| TC_O_28_CS | Set Display Message - Transaction - EndTime | Passed |
| TC_O_30_CS | Set Display Message - Transaction - Multiple InFront | Passed |
| TC_O_32_CS | Set Display Message - Transaction - Second AlwaysFront | Passed |
| TC_O_33_CS | Get Specific Display Message - No messages configured | Passed |
| TC_O_34_CS | Get Specific Display Message - Known Id, not matching State | Passed |
| TC_O_35_CS | Get Specific Display Message - Known Id, not matching Priority | Passed |
| TC_O_36_CS | Set Display Message - State Charging | Passed |
| TC_O_37_CS | Set Display Message - State Idle | Passed |
| TC_O_38_CS | Set Display Message - State Unavailable | Passed |
| TC_O_39_CS | Set Display Message - State Faulted | Passed |
| TC_O_100_CS | Set Display Message - unsupported language | Passed |
| TC_O_101_CS | Set Display Message - Language preference of the EV Driver | Passed |

### P - Data Transfer

3 tests

| Test ID | Name | Status |
|---|---|---|
| TC_P_01_CS | Data Transfer to CS - Rejected / Unknown VendorId / Unknown MessageId | Passed |
| TC_P_03_CS | CustomData - Receive custom data | Passed |
| TC_P_04_CS | Able to receive customData - ChargingProfile | Passed |

### Q - Bidirectional Power Transfer

25 tests

| Test ID | Name | Status |
|---|---|---|
| TC_Q_100_CS | V2X Authorisation - V2X Tx Measurands defined (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_101_CS | V2X Authorisation - ISO15118-20 - Processing charging needs (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_102_CS | V2X Authorisation - ISO15118-20 - Charging only (V2X control) before starting V2X - Allowed Energy (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_103_CS | V2X Authorisation - ISO15118-20 - Charging needs rejected (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_104_CS | V2X Authorisation - ISO15118-20 - Scheduled Control (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_107_CS | V2X Authorisation - ISO15118-20 - Charging only (V2X control) before starting V2X (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_109_CS | Central dynamic schedule control with setpoint - push (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_110_CS | Central V2X control with dynamic CSMS setpoint - pull (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_111_CS | External V2X control - with a charging profile from CSMS - setpoint (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_112_CS | External V2X control - with a charging profile from CSMS - limit (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_113_CS | External V2X control - with a charging profile from CSMS - Duration expired (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_114_CS | External V2X control - External System - Dynamic external limits control (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_115_CS | External V2X control - External System - Dynamic setpoint control (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_116_CS | External V2X control - External System - Scheduled external limits control (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_117_CS | Frequency Support - Central V2X control - push (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_118_CS | Frequency Support - Central V2X control - Duration expired (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_119_CS | Frequency Support - Local V2X control - Charging profile validations (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_120_CS | Frequency Support - Local V2X control - AFRR support (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_122_CS | Local V2X control for load balancing - threshold validations (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_123_CS | Local V2X control for load balancing - not supported (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_125_CS | Idle operationMode - Idle with EvseSleep (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_126_CS | Idle operationMode - Idle with EvseSleep unsupported (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_127_CS | Idle operationMode - Charging profile validations (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_128_CS | Going offline during V2X operation - invalidAfterOfflineDuration = true (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |
| TC_Q_130_CS | V2X Authorisation - ISO15118-20 - has ISO15118ServiceRenegotiationSupport - Charging needs rejected (PICS BidirectionalPowerTransfer not supported: No V2X: the simulator models unidirectional charging only and has no ISO 15118-20 or CHAdeMO V2X loop) | Not applicable |

### R - DER Control

8 tests

| Test ID | Name | Status |
|---|---|---|
| TC_R_100_CS | Starting a V2X session with DER control in EVSE - Persistent DERControls (PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types) | Not applicable |
| TC_R_101_CS | Starting a V2X session with DER control in EVSE - Device model (PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types) | Not applicable |
| TC_R_102_CS | Configure DER control settings at CS - clearing controlTypes (PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types) | Not applicable |
| TC_R_103_CS | Configure DER control settings at CS - validations (PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types) | Not applicable |
| TC_R_104_CS | Configure DER control settings at CS - superseding future DER control (PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types) | Not applicable |
| TC_R_105_CS | Configure DER control settings at CS - superseding active DER control (PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types) | Not applicable |
| TC_R_106_CS | Configure DER control settings at CS - Active DER control supersedes new DER control (PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types) | Not applicable |
| TC_R_108_CS | Charging station reporting a DER event (PICS DERControl not supported: No DER control: the simulator has no inverter model or DER control types) | Not applicable |

### S - Battery Swapping

3 tests

| Test ID | Name | Status |
|---|---|---|
| TC_S_102_CS | Battery Swap - Remote Start - not enough batteries (PICS HFS-13 not supported: No battery swap station model: the simulator has no battery inventory or swap bays) | Not applicable |
| TC_S_104_CS | Battery Swap - Charging - Variables validation (PICS HFS-13 not supported: No battery swap station model: the simulator has no battery inventory or swap bays) | Not applicable |
| TC_S_105_CS | Battery Swap - Charging - Battery Swap Charging (PICS HFS-13 not supported: No battery swap station model: the simulator has no battery inventory or swap bays) | Not applicable |
