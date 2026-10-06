Generated from https://www.evtivity.com/docs/getting-started/introduction (website commit 257c8b8). Do not edit.

# Introduction

What EVtivity CSMS is, what it does, and how it is built.

## What is EVtivity?

EVtivity is an open-source charging station management system (CSMS) for EV charging network operators, charge point operators, and developers. It handles the full lifecycle of EV charging: station management, driver authentication, session monitoring, billing, and roaming.

## Key Features

- **OCPP 1.6 and 2.1** with conformance test coverage for both versions
- **Real-time monitoring** of station status, connector state, and active sessions
- **Multi-tenant RBAC** with organizations, roles, and granular permissions
- **Driver portal** for EV drivers to find stations, start sessions, and manage payments
- **Billing** with Stripe integration, flexible tariffs, and automated invoicing
- **Notifications** via email, SMS, push, and webhooks with customizable templates
- **Load management** with site-level power limits and dynamic distribution
- **OCPI roaming** (2.2.1 and 2.3.0) for interoperability with roaming networks
- **Plug and Charge** (ISO 15118) with certificate management
- **Carbon footprint tracking** per session and per driver
- **AI assistant** for natural language queries against station and session data

## Architecture

EVtivity is a monorepo with 13 packages. The core services are the REST API (Fastify), OCPP WebSocket server, and Worker (BullMQ), backed by PostgreSQL and Redis. Two React frontends (CSMS Dashboard and Driver Portal) connect to the API. Supporting services include the OCPI roaming server and the charging station simulator.

![EVtivity architecture](https://www.evtivity.com/images/architecture.png)

Shared libraries (`configs`, `lib`, `database`, `codegen`) provide the foundation across all packages.

All packages use the `@evtivity/*` namespace, ESM modules, and strict TypeScript.

## Tech Stack

| Layer      | Technology                                    |
|------------|-----------------------------------------------|
| Runtime    | Node.js 24, TypeScript          |
| API        | Fastify                                       |
| ORM        | Drizzle ORM                                   |
| Database   | PostgreSQL 17                                 |
| Cache      | Redis 8                                       |
| Frontend   | React 19, Vite, Tailwind CSS                  |
| i18n       | i18next (6 languages: English, German, Spanish, Simplified Chinese, Traditional Chinese, Korean) |

## License

EVtivity is licensed under the Business Source License 1.1 (BUSL-1.1).

- **Single-tenant production use is free.** You can run EVtivity to manage your own charging stations without a commercial license.
- **Multi-tenant SaaS requires a commercial license.** Offering EVtivity as a hosted service to multiple independent customers is not permitted without a license.
- **Converts to Apache 2.0** four years after each version is released.

Contact evtivity@gmail.com for commercial licensing.

## Next Steps

- [Quick Start](https://www.evtivity.com/docs/getting-started/quick-start) to run EVtivity with Docker in minutes
- [Installation](https://www.evtivity.com/docs/getting-started/installation) for local development setup
- [Project Structure](https://www.evtivity.com/docs/getting-started/project-structure) to understand the codebase
