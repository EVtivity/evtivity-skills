Generated from https://www.evtivity.com/docs/getting-started/demo-data. Do not edit.

# Demo Data

What the optional demo data set creates, how to turn it on, and how a rerun treats it.

## Overview

The demo data set fills an empty install with test data: sites, simulated charging stations, drivers, fleets, charging history and examples of the optional features. Use it to explore the dashboard, the driver portal and the simulator. It is test data only. Never load it into a production install.

> **Warning:**
>
> Demo stations are simulators, demo drivers are fictional, and demo payments use the test payment provider, which moves no money. The sites and addresses are fictional.

## Turn It On

### Docker Compose and local development

Set `SEED_DEMO=true` in your `.env` file, then seed the database:

```bash
npm run db:seed
```

With `SEED_DEMO=false` (the default) the seed creates only the roles, the admin user and the settings. See [Quick Start](https://www.evtivity.com/docs/getting-started/quick-start) and [Environment Variables](https://www.evtivity.com/docs/configuration/environment-variables).

### Helm

Set both values in `values.yaml`:

```yaml
seedDemo:
  enabled: true
  confirmed: true
```

The chart runs the demo seed as a post-install job only when both are true. `enabled` without `confirmed` fails the install. The demo also needs `payments.allowSimulatedProvider: true`, because demo drivers pay with simulated cards. See [Helm Chart](https://www.evtivity.com/docs/deployment/helm-chart).

### When the demo is created

The demo is created only in an empty inventory. The built-in Main Office site and the stations `CS-0001` and `CS-0002` count as empty. Any other site or station skips the demo and the seed prints a notice.

## Accounts

| Account | Sign in at | Email | Password |
|---|---|---|---|
| Admin | CSMS dashboard | `admin@evtivity.local` | `admin123` |
| Driver | Driver portal and mobile app | `driver@evtivity.local` | `driver123` |
| Fleet manager of Northwind Logistics | CSMS dashboard | `fleet@evtivity.local` | `fleet123` |

`INITIAL_ADMIN_EMAIL` and `INITIAL_ADMIN_PASSWORD` replace the admin defaults. The demo also creates 9 operator users (6 of them limited to a few sites) and 150 fictional drivers with `example.com` addresses. Every demo driver gets a generated avatar.

## Sites and Stations

### Base network

| Item | Count |
|---|---|
| Sites in the United States | 20 |
| Simulated stations `CS-0003` to `CS-2002` | 2,000 |
| OCPP 2.1 (`CS-0003` to `CS-1002`, except every third) | 666 |
| OCPP 2.0.1 (every third of `CS-0003` to `CS-1002`, starting with `CS-0003`) | 334 |
| OCPP 1.6 (`CS-1003` to `CS-2002`) | 1,000 |

- An OCPP 2.x station has 2 EVSEs. A DC split system (C-Series Satellites model) has 4, one per satellite. Every tenth OCPP 2.x station is seeded without its last EVSE: the simulator reports it and the CSMS creates it when the station connects.
- An OCPP 1.6 station has 1 or 2 connectors, each on its own EVSE.
- Some OCPP 2.x EVSEs carry a second connector: a CHAdeMO plug on some DC fast chargers, a second Type 1 plug on some AC chargers.
- About one in five stations starts switched off by an operator.
- Security profiles: OCPP 2.x stations use profile 0 (`CS-0003` to `CS-0202`), 1, 2 or 3 (`CS-0953` to `CS-1002`). OCPP 1.6 stations use profile 0 (`CS-1003` to `CS-1502`) or 1. The simulators of profile 3 stations start disabled.

### Feature sites

| Site | Location | Stations |
|---|---|---|
| Riverside Community Center (free vend) | Albany, NY | `CS-2003` (OCPP 2.1), `CS-2004` (OCPP 1.6) |
| Laadplein Papendorp | Utrecht, Netherlands | `CS-4001` to `CS-4007` |

With these two sites the demo has 22 sites and 2,009 stations outside the site layout demo.

### Site layout demo

Eight sites show the [site layout](https://www.evtivity.com/docs/csms/sites) of each site type. Their stations run OCPP 2.1, except the Parkhaus Lindenhof station, which runs OCPP 1.6.

| Site | Site type | Stations |
|---|---|---|
| Harbor Point Charging Hub | Parking lot, chargers at the lot edge | 11 DC |
| Lakeside Retail Park | Office or retail | 10 AC |
| Riverside Medical Offices | Office or retail | 4 AC |
| Maple Street Curbside | Curbside | 8 AC |
| Willow Creek Park and Ride | Custom | 5 AC, 3 DC |
| Northgate Fleet Depot | Depot | 8 DC |
| Patroon Creek Charging Plaza | Parking lot, chargers on islands | 8 AC, 4 DC |
| Parkhaus Lindenhof (Freiburg, Germany) | Parking lot | 1 AC station with 16 EVSEs |

The first seven sites hold stations `CS-3001` to `CS-3061`. Every station has its own circuit. Every DC fast charger at a public site has a simulated card reader.

## Electrical Supply

The simulator sets the phases and voltage of each EVSE by its connector type and its site's country:

| Region | Charger | Supply |
|---|---|---|
| United States | AC Level 2 (Type 1) | One phase, 208 V |
| United States | DC | Three phases, 480Y/277 V |
| Europe | AC Type 2 and DC | Three phases, 230/400 V |
| Europe | AC Type 1 | One phase, 230 V |

US demo AC connectors are rated at the current of their 208 V circuit: 16 A is 3.33 kW, 32 A is 6.66 kW, 48 A is 9.98 kW.

### Power equipment of US sites

Every base and free vend site gets a load management tree sized to its connected load: one service transformer and one 480Y/277 V switchboard per group of nearby stations, DC chargers on switchboard breakers, and AC chargers on 225 A or 400 A panelboards with 42 spaces. Each panelboard has its own step-down transformer. The site layout demo sites have their own equipment plans.

### Laadplein Papendorp

The European site runs on the 230/400 V system. Each station has one EVSE on its own circuit of one 500 A main distribution board under one 250 kVA transformer. Load management is off.

| Station | OCPP | Charger |
|---|---|---|
| `CS-4001`, `CS-4002` | 2.1 | 22 kW Type 2, 32 A three-phase |
| `CS-4003`, `CS-4004` | 2.0.1 | 11 kW Type 2, 16 A three-phase |
| `CS-4005`, `CS-4006` | 1.6 | 7.4 kW Type 2, 32 A single-phase on L1 and L2 |
| `CS-4007` | 2.1 | 150 kW CCS2 |

EVSE 1 of `CS-4001` and `CS-4003` reports `SmartChargingCtrlr.ACPhaseSwitchingSupported` as true, so it can switch a single-phase car between phases. The simulators of this site start disabled. Enable them in the simulator list for live sessions.

### Station units

The Parkhaus Lindenhof station `EM4-MASTER-01` is one master with seven extenders behind one Charge Point ID: 16 Type 2 22 kW EVSEs, three-phase 230 V, grouped into 8 [units](https://www.evtivity.com/docs/csms/stations#units) `Box 1` to `Box 8` of 2 EVSEs each. It hangs on one feeder circuit of a 400 A main distribution board under a 225 kVA transformer.

## Charging History

- 10,000 ended sessions over the last 90 days, about 9 completed to 1 faulted. A faulted session costs nothing.
- 20 active sessions on profile 3 stations, started 5 to 60 minutes before the seed ran.
- Two sessions on `CS-0003` that show re-billing on the session Billing card.
- Every site gets electricity rates: Standard at 0.12 per kWh and Weekday Peak at 0.22 per kWh from 16:00 to 21:00, Monday to Friday. Sessions store their electricity cost from these rates.
- 14 days of dashboard snapshots per site.

## Fleet Billing

- Northwind Logistics charges on account to the fleet. It has fleet invoices, a credit note, a credit limit of 5,000.00 in the company currency, a pool RFID card no member holds and a member card. Its history holds 0 to 3 account sessions a day over the last 30 days, kept at or below 70 percent of the credit limit.
- Contoso Engineering invoices each member. It has member invoices, a credit note and unbilled member sessions.

See [Fleets](https://www.evtivity.com/docs/csms/fleets).

## Feature Examples

### Plug and Charge

The OCPP 2.1 stations `CS-0979` and `CS-0980` report the ISO 15118 configuration. Four demo drivers hold contracts with eMAID tokens, and one contract is revoked. 36 completed sessions over the last 30 days started with these contracts. See [Certificates](https://www.evtivity.com/docs/csms/certificates).

### Free vend

Riverside Community Center has free vend on, with the four configuration templates free vend creates. `CS-2003` and `CS-2004` each have one 6.66 kW Type 1 connector. The site has 30 free sessions over the last 30 days. See [Free Vend](https://www.evtivity.com/docs/csms/free-vend).

### SIMs

The stations `CS-0983` to `CS-0986` each hold one Hologram SIM with usage, data sessions and alerts. The inventory also holds a spare SIM and a deactivated one. No provider credential is seeded, so no Refresh reaches a provider. See [SIMs](https://www.evtivity.com/docs/csms/sims).

### Payment terminals

Two simulated card readers: a VP6825 (Lobby Card Reader) paired to EVSE 1 of `CS-0981`, and a VP7200 (Garage Entrance Card Reader) paired to a whole station at another site. They hold six payments: three captured, two voided and one refunded. See [Payment Terminals](https://www.evtivity.com/docs/integrations/payment-terminals).

### AI insights

Offline profile 3 stations hold 19 insights that show each insight kind and status, and `CS-0993` holds four reservations with reservation insights. See [AI Insights](https://www.evtivity.com/docs/csms/ai-insights).

### Settings the demo turns on

Plug and Charge, the Hologram SIM provider, route-aware charging, station units and roaming.

## Running the Seed Again

`npm run db:seed` never truncates or deletes. It adds only what is missing and never overwrites an operator change: settings keep their values, existing users keep their passwords, and edited or deleted electricity rates stay as they are. On an install that already has the demo, the seed skips the demo block and adds only the fleet manager account, the fleet cards and the missing days of the Northwind history.

To add the feature examples to an existing demo install, run:

```bash
npm run seed:demo-features -w @evtivity/database
```

It uses fixed ids and inserts only rows that are missing.

`npm run db:seed -- --apply-config` is the one exception: it writes the values from `packages/database/seed.config.json` over the existing settings.

For a clean slate, delete the database (for Docker Compose, `docker compose down --volumes`), migrate, and seed again.

## Notes

- The 2,000 simulated stations fill the database fast once the simulator connects them. See [Data Retention](https://www.evtivity.com/docs/configuration/data-retention).
- Counts that come from random picks (connectors, completed and faulted sessions, switched-off stations) differ between installs.
