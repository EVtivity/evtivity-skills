Generated from https://www.evtivity.com/docs/csms/conformance-testing. Do not edit.

# Conformance Testing

Run OCPP conformance tests against your CSMS to validate protocol compliance.

## Overview

EVtivity includes a built-in OCPP conformance test runner based on the Open Charge Alliance OCTT (OCPP Compliance Testing Tool) specifications. The runner validates that the CSMS correctly handles OCPP protocol messages for versions 1.6, 2.0.1 and 2.1. It also tests the Charging Station Simulator against the OCTT charging station test cases for the same versions.

Tests run from the CSMS dashboard or the command line. Results are stored in the database and displayed with per-module pass/fail/skip/error counts.

> **Warning:**
>
> Run conformance tests in a test environment, not production: a run creates temporary stations, a test driver and tokens, and changes PnC and payment settings while it runs.

![Conformance Testing](https://www.evtivity.com/screenshots/csms/conformance.png)

## How It Works

In a CSMS run, the test runner acts as a simulated charging station. It connects to the CSMS via WebSocket, sends OCPP messages, and validates the responses against the OCTT specification. In a Charging Station Simulator run, the runner acts as the CSMS. It starts a test OCPP server for each test case, connects a simulator station to it, and checks the station's messages.

1. The operator triggers a test run from the Settings page (Conformance tab) or via CLI.
2. A background worker picks up the job and runs the tests.
3. Each test connects as a provisioned station, executes its scenario, and records the result.
4. Results stream back to the UI via server-sent events in real time.

## Test Coverage

The conformance section lists every OCTT test case EVtivity runs, by OCPP version and module, with its current status. See [OCPP Conformance Testing](https://www.evtivity.com/docs/conformance/overview).

## Running Tests

### From the Dashboard

Navigate to **Settings** and select the **Conformance** tab.

1. In **System Under Test**, choose **CSMS** to test this CSMS, or **Charging Station Simulator** to test the simulator with the charging station test cases.
2. Choose **OCPP 2.1**, **OCPP 2.0.1**, **OCPP 1.6**, or **Run All Tests**.
3. Click **Run Tests** and confirm to start the run.

The run list shows the system under test of every run. A run removes its test data when it ends.

![Start Conformance Run confirmation](https://www.evtivity.com/screenshots/csms/conformance-start-run.png)

The results page shows:

- Overall pass/fail/skip/error counts
- Per-module breakdown with expandable test details
- Each test's step-by-step execution log
- Duration and error messages for failed tests

### From the Command Line

The command-line runner tests both the CSMS and the Charging Station Simulator, with options for TLS and OCSP tests. See [Run CSMS tests from the command line](https://www.evtivity.com/docs/conformance/overview#run-csms-tests-from-the-command-line).

## Test Results

Each test run records:

- **Run metadata** - System under test, OCPP version, start/end time, total duration, triggered by user
- **Per-test results** - Test ID, name, module, status (passed/failed/skipped/error), duration, step details

Test statuses:

| Status | Description |
|--------|-------------|
| Passed | All assertions validated successfully |
| Failed | One or more assertions did not match expected behavior |
| Skipped | Test preconditions not met or test intentionally excluded |
| Error | Test could not complete due to a connection or runtime error |
