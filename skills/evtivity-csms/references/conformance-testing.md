Generated from https://www.evtivity.com/docs/csms/conformance-testing. Do not edit.

# Conformance Testing

Run OCPP conformance tests against your CSMS to validate protocol compliance.

## Overview

EVtivity includes a built-in OCPP conformance test runner based on the Open Charge Alliance OCTT (OCPP Compliance Testing Tool) specifications. The runner validates that the CSMS correctly handles OCPP protocol messages for both version 1.6 and 2.1.

Tests run from the CSMS dashboard or the command line. Results are stored in the database and displayed with per-module pass/fail/skip/error counts.

![Conformance Testing](https://www.evtivity.com/screenshots/csms/conformance.png)

## How It Works

The test runner acts as a simulated charging station. It connects to the CSMS via WebSocket, sends OCPP messages, and validates the responses against the OCTT specification.

1. The operator triggers a test run from the Settings page (Conformance tab) or via CLI.
2. A background worker picks up the job and runs the tests.
3. Each test connects as a provisioned station, executes its scenario, and records the result.
4. Results stream back to the UI via server-sent events in real time.

## Test Coverage

The conformance section lists every OCTT test case EVtivity runs, by OCPP version and module, with its current status. See [OCPP Conformance Testing](https://www.evtivity.com/docs/conformance/overview).

## Running Tests

### From the Dashboard

Navigate to **Settings** and select the **Conformance** tab. Choose **OCPP 2.1**, **OCPP 1.6**, or **Run All Tests**, then click **Run Tests** to start a conformance test run.

The results page shows:

- Overall pass/fail/skip/error counts
- Per-module breakdown with expandable test details
- Each test's step-by-step execution log
- Duration and error messages for failed tests

### From the Command Line

The command-line runner tests both the CSMS and the Charging Station Simulator, with options for TLS and OCSP tests. See [Run CSMS tests from the command line](https://www.evtivity.com/docs/conformance/overview#run-csms-tests-from-the-command-line).

## Test Results

Each test run records:

- **Run metadata** - OCPP version, start/end time, total duration, triggered by user
- **Per-test results** - Test ID, name, module, status (passed/failed/skipped/error), duration, step details

Test statuses:

| Status | Description |
|--------|-------------|
| Passed | All assertions validated successfully |
| Failed | One or more assertions did not match expected behavior |
| Skipped | Test preconditions not met or test intentionally excluded |
| Error | Test could not complete due to a connection or runtime error |
