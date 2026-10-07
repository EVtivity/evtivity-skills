Generated from https://www.evtivity.com/docs/getting-started/project-structure (website commit 4cd1866). Do not edit.

# Project Structure

How the EVtivity monorepo is organized.

## Overview

EVtivity is a monorepo managed with npm workspaces. All packages use the `@evtivity/*` namespace and ESM modules.

## Packages

| Package      | Path                    | Purpose                                              |
|--------------|-------------------------|------------------------------------------------------|
| `api`        | `packages/api`          | Fastify REST API (port 7102)                         |
| `ocpp`       | `packages/ocpp`         | WebSocket server for OCPP 1.6 and 2.1 (port 7103)   |
| `csms`       | `packages/csms`         | React operator dashboard                             |
| `portal`     | `packages/portal`       | React driver portal                                  |
| `database`   | `packages/database`     | Drizzle ORM schema, migrations, and seeds            |
| `lib`        | `packages/lib`          | Shared utilities: logger, errors, events, DI, encryption, cost calculator |
| `configs`    | `packages/configs`      | Zod environment config schemas                       |
| `worker`     | `packages/worker`       | BullMQ background jobs (see Worker Responsibilities below)                  |
| `css`        | `packages/css`          | Charging station simulator                           |
| `ocpi`       | `packages/ocpi`         | OCPI 2.2.1 and 2.3.0 roaming server (port 7104)     |
| `octt`       | `packages/octt`         | OCPP conformance test runner                         |
| `codegen`    | `packages/codegen`      | OCPP schema to TypeScript code generator             |

## Worker Responsibilities

The `worker` package hosts five independent BullMQ pipelines. Each subscribes to a Redis pub/sub channel and enqueues jobs that the corresponding worker processes.

| Pipeline                | Purpose                                                                                                                                                                                                                                                              |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Cron jobs**           | Reads the `cronjobs` table on startup and schedules every handler. Includes payment reconciliation, dashboard snapshots, stale-session cleanup, guest-session expiry sweeps, tariff boundary checks, and reservation expiry. None of these run without the worker.   |
| **Load management**     | Site-level smart-charging coordinator. Runs every 10 seconds, computes per-station power allocations, and dispatches `ChargingStationExternalConstraints` profiles. Without it, load distribution never updates.                                                     |
| **Guest sessions**      | Subscribes to `csms_events` for `TransactionStarted` and `TransactionEnded`. On start, links the guest session to the charging session. On end, captures or cancels the Stripe pre-auth and sends a receipt.                                                         |
| **Reservation activation** | Subscribes to `reservation_schedule`. When the API creates a reservation with a future `startsAt`, the worker schedules a delayed BullMQ job. At `startsAt` it sends `ReserveNow` to the station and flips the reservation from `scheduled` to `active`.          |
| **OCTT conformance runs**  | Subscribes to `octt_run`. When an operator clicks Run Tests on the Settings Conformance tab, the worker enqueues the run and executes the OCTT runner against the target SUT.                                                                                                   |

In production the worker is deployed as its own pod or container. In local development you must start it explicitly with `npm run dev:worker` for any of these features to function. See [Installation](https://www.evtivity.com/docs/getting-started/installation) for how to run it alongside the other services.

## Key Directories

```bash
evtivity-csms/
  packages/          # All application and library packages
  schemas/ocpp-2.1/  # OCPP 2.1 JSON schemas
  scripts/           # Build, release, and dev scripts
  .env.example       # Environment variable reference
  docker-compose.yml # Docker service definitions
```

## TypeScript Configuration

All packages share a base TypeScript config with these settings:

- **Strict mode** enabled
- **Project references** for cross-package builds
- **ES2022** target
- **Bundler** module resolution

Each package extends the base config and adds its own paths and references.
