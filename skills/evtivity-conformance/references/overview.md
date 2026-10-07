Generated from https://www.evtivity.com/docs/conformance/overview (website commit 4cd1866). Do not edit.

# OCPP Conformance Testing

How EVtivity tests the CSMS and the Charging Station Simulator against the OCTT test cases for OCPP 1.6 and OCPP 2.1.

## Overview

The Open Charge Alliance (OCA) publishes the OCPP Compliance Testing Tool (OCTT) test cases. Each OCPP version has one set of test cases for the CSMS role and one for the charging station role. A test case has an ID such as `TC_B_01_CSMS`, prerequisites, and a step-by-step message sequence with expected results.

EVtivity includes its own test runner that implements these test cases. It runs four suites:

| System under test | Version | Total | Passed | Not applicable | Pending |
|---|---|---|---|---|---|
| [CSMS](https://www.evtivity.com/docs/conformance/csms-ocpp21) | OCPP 2.1 | 329 | 329 | 0 | 0 |
| [CSMS](https://www.evtivity.com/docs/conformance/csms-ocpp16) | OCPP 1.6 | 77 | 77 | 0 | 0 |
| [Charging Station Simulator](https://www.evtivity.com/docs/conformance/charging-station-ocpp21) | OCPP 2.1 | 578 | 467 | 111 | 0 |
| [Charging Station Simulator](https://www.evtivity.com/docs/conformance/charging-station-ocpp16) | OCPP 1.6 | 107 | 107 | 0 | 0 |

Pending counts every applicable test that does not pass yet. Open a suite for the per-module results and the status of every test case.

> **Note:**
>
> These results come from the EVtivity test runner, which follows the OCTT test case specifications. They are not an Open Charge Alliance certification.

## What gets tested

| Suite | Runner acts as | System under test |
|-------|----------------|-------------------|
| CSMS | A charging station. It connects to the OCPP WebSocket server, sends station messages, and checks every CSMS response. Tests that need a CSMS-initiated command trigger it through the REST API, the same way an operator does. | The EVtivity CSMS (OCPP server, API, and worker) |
| Charging station | A CSMS. It starts a test OCPP server for each test case, connects a Charging Station Simulator to it, sends CSMS commands, and checks the station's messages and behavior. | The EVtivity Charging Station Simulator |

Tests follow the OCTT documents step by step. A test only calls a physical station action (plug in, present a card, power cycle) where the OCTT test case lists a manual action.

## How results are counted

| Status | Meaning |
|--------|---------|
| Passed | Every step checked a real condition and got the expected result. |
| Not applicable | The test case does not apply to the product. It is not run and does not count as passed. |
| Pending | The test case applies but does not pass yet. |
| Failed | A step got a result other than the expected one. |
| Error | The test could not finish, for example a connection error or a timeout. |
| Skipped | The test case applies but could not run in this setup, for example a TLS step without a TLS server URL. |

### Not applicable for the charging station

Real OCTT runs only the test cases that the vendor's PICS (Protocol Implementation Conformance Statement) makes applicable. The EVtivity runner does the same with the simulator's PICS. OCPP 2.1 items use the IDs from OCPP 2.1 Part 5 (Certification Profiles), such as `ISO15118Support`, `C-13`, or `SC-6`. OCPP 1.6 items follow the rows of the OCPP 1.6 PICS.

A test case lists the PICS items it needs. Some test cases need a product without a feature. For example, TC_B_28_CS applies only to a station that cannot reset a single EVSE. The simulator supports reset per EVSE, so TC_B_25_CS to TC_B_27_CS run instead. When a condition is not met, the runner reports the test as not applicable with the PICS item and the reason.

An item is only declared unsupported when the simulator lacks the feature. The PICS tables on the [OCPP 2.1 charging station](https://www.evtivity.com/docs/conformance/charging-station-ocpp21) and [OCPP 1.6 charging station](https://www.evtivity.com/docs/conformance/charging-station-ocpp16) pages list every item and why it is or is not supported.

### Not applicable for the CSMS

A CSMS test case is not applicable when it needs a feature EVtivity does not include. Each one names the missing feature on the results page.

## Test isolation

- Each CSMS test gets its own test station and its own ID tokens (valid, blocked, expired, prepaid, and others). Tests that run in parallel never share a token.
- After each test, the runner stops any transaction the test left open, as the OCTT test procedure requires.
- When the run ends, the runner deletes its test stations, test driver, tokens, and temporary API key, and restores the settings it changed.
- Each charging station test gets its own test server on an ephemeral port on `127.0.0.1`, so parallel tests never collide.

> **Warning:**
>
> Run conformance tests against a development or test deployment. The runner writes test stations, tokens, and settings to the CSMS database while it runs.

## Run CSMS tests from the dashboard

1. Open **Settings** in the CSMS sidebar and select the **Conformance** tab.
2. Choose **OCPP 2.1**, **OCPP 1.6**, or **Run All Tests**.
3. Click **Run Tests**. The worker runs the suite and the run list updates in real time.
4. Click a run to see the per-module breakdown and the expected and actual result of every step.

![Settings Conformance tab](https://www.evtivity.com/screenshots/csms/conformance.png)

The dashboard runs the CSMS suites only, without a TLS server URL or an OCSP responder. Tests that need either one report the affected steps as skipped. Use the command line for a full run and for the charging station suites. See [Conformance Testing](https://www.evtivity.com/docs/csms/conformance-testing) for the dashboard pages.

## Run CSMS tests from the command line

Run these commands from the CSMS repository root. The runner reads `DATABASE_URL` from `.env` and needs the OCPP server, API, and database running.

```bash
# All CSMS tests, both versions
npm run octt

# One version
npm run octt:2.1
npm run octt:1.6

# One module
npx tsx packages/octt/src/cli.ts --server ws://localhost:7103 --version ocpp2.1 --module E-transactions

# Full OCPP 2.1 run with the TLS and OCSP steps
npx tsx packages/octt/src/cli.ts --server ws://localhost:7103 --version ocpp2.1 \
  --tls-server wss://localhost:8443 \
  --ocsp-responder http://host.docker.internal:8090/ocsp
```

| Flag | Default | Purpose |
|------|---------|---------|
| `--server` | `ws://localhost:7103` | OCPP WebSocket URL of the CSMS |
| `--tls-server` | none | `wss://` URL of the CSMS TLS listener. Tests that reconnect over TLS (security profile upgrades, TC_A_19_CSMS) need it. Without it those steps are skipped. |
| `--ocsp-responder` | none | URL of a test OCSP responder the runner starts, for example `http://host.docker.internal:8090/ocsp`. The OCPP server must reach it. Contract certificate and OCSP tests (TC_C_50 to TC_C_52, TC_M_24) need it. Without it they are skipped. |
| `--version` | both | `ocpp2.1` or `ocpp1.6` |
| `--module` | all | One module, for example `B-provisioning` (2.1) or `core` (1.6) |
| `--concurrency` | `10` | Number of tests that run in parallel |
| `--api-url` | `http://localhost:7102` | REST API URL used to trigger CSMS-initiated commands |
| `--password` | none | Basic Auth password for the test stations |

When the OCSP responder runs on a private host such as `host.docker.internal`, add that host to the CSMS setting `pnc.ocsp.allowedPrivateHosts`. The runner installs a test MO root certificate for the run and removes it at the end.

## Run charging station tests from the command line

The charging station runner starts its own test servers and Charging Station Simulator instances. It needs the database but not a running CSMS. It uses the built simulator package, so build it after you change the simulator.

```bash
# Build the simulator
npx tsc -b packages/css

# All charging station tests, both versions
npm run octt:cs

# One version
npm run octt:cs:2.1
npm run octt:cs:1.6

# One module
npx tsx packages/octt/src/cs-cli.ts --version ocpp2.1 --module E-transactions

# Selected test cases
npx tsx packages/octt/src/cs-cli.ts --version ocpp2.1 --test-ids TC_E_01_CS,TC_E_02_CS
```

| Flag | Default | Purpose |
|------|---------|---------|
| `--version` | both | `ocpp2.1` or `ocpp1.6` |
| `--module` | all | One module, for example `K-smart-charging` (2.1) or `21-reservation` (1.6) |
| `--test-ids` | all | Comma-separated test case IDs |
| `--concurrency` | `3` | Number of tests that run in parallel |

The output prints one line per test: `[PASS]`, `[FAIL]`, `[SKIP]`, `[ERR ]`, or `[N/A ]` with the PICS reason. The summary adds a `Not applicable (PICS)` count.

## Results pages

- [OCPP 2.1 CSMS](https://www.evtivity.com/docs/conformance/csms-ocpp21)
- [OCPP 1.6 CSMS](https://www.evtivity.com/docs/conformance/csms-ocpp16)
- [OCPP 2.1 Charging Station](https://www.evtivity.com/docs/conformance/charging-station-ocpp21)
- [OCPP 1.6 Charging Station](https://www.evtivity.com/docs/conformance/charging-station-ocpp16)
