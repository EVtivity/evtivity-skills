Generated from https://www.evtivity.com/docs/csms/pricing. Do not edit.

# Pricing

Configure tariffs with time-of-day restrictions, split billing, holidays, and multi-level assignment.

## Overview

The pricing system uses pricing groups that contain one or more tariffs. Each tariff defines rates for energy, time, session fees, idle fees, and tax. Tariffs can have restrictions that control when they apply, enabling time-of-day pricing, seasonal rates, holiday pricing, and energy threshold pricing.

![Pricing list](https://www.evtivity.com/screenshots/csms/pricing-list.png)

## Create a Pricing Group

1. Navigate to **Pricing** in the sidebar.
2. Click **Create Pricing Group**.
3. Enter a name and optional description.
4. Optionally mark it as the default group (used when no other assignment matches). Only one pricing group can be the default. Marking a second group as the default is refused with `409 PRICING_GROUP_DEFAULT_EXISTS`.
5. Click **Create**.

## Create a Tariff

1. Open a pricing group detail page.
2. Click **Create Tariff** in the Tariffs tab.
3. Enter the tariff name.
4. Set rate components. Prices are entered excluding or including tax, as the tax calculation method in Settings > Company Info sets (see Prices and Tax below). The labels say which, for example **Price per kWh (excl. tax)** or **Price per kWh (incl. tax)**:
   - **Price per kWh**
   - **Price per minute**
   - **Price per session**, a flat fee per session
   - **Idle Fee (Per Min)**, charged per minute after the idle grace period (the first idle minutes of the session are free), only while the EV pauses charging itself (not while the station pauses it or in a fault)
   - **Reservation Fee (Per Min)**
   - **Tax Rate** (decimal fraction, 0 to 1)
5. Select the **Tariff type**. **Default (no restrictions)** creates the default tariff of the group. Any other type adds a restriction that controls when the tariff applies.
6. Click **Create**.

![Create tariff](https://www.evtivity.com/screenshots/csms/pricing-create.png)

## Default Tariff

A pricing group with active tariffs needs exactly one active default tariff, and the default has no restrictions. It applies whenever no tariff with restrictions matches, so every time of day and every amount of energy has a price.

- The CSMS derives the default: the active tariff without restrictions is the default tariff of the group. You do not set it separately.
- Create the default tariff first. A tariff with restrictions in a group without a default is refused.
- While other tariffs of the group are active, you cannot deactivate the default, add restrictions to it, or delete it. Deactivate or delete the other tariffs first.

These changes are refused with `409 TARIFF_DEFAULT_REQUIRED`. The tariff form explains the rule below the **Tariff type** field.

## Prices and Tax

Every session cost includes tax. How tariff prices are entered depends on the **Tariff prices are entered** setting (`company.taxBasis`) under Settings > Company Info:

| Setting | Tariff prices | How a session is billed |
|---------|---------------|-------------------------|
| **Excluding tax (net)** (default) | Exclude tax. Labels read "excl. tax". | The cost calculator adds the tariff tax rate to the net cost. |
| **Including tax (gross)** | Include tax. Labels read "incl. tax". | Each billed line is the gross unit price times the quantity, rounded to the cent. The tax it contains is taken out. |

Example with the gross setting: 20 kWh at €0.36 per kWh (incl. tax) and a tax rate of `0.19` costs exactly €7.20. The tax taken out is €1.15 and the net amount is €6.05.

Tax is computed exactly for each tax rate of a session and rounded half up to the cent once per rate. Example with the net setting: $3.60 at a tax rate of `0.0875` has a tax of $0.32 (31.5 cents rounds up).

While you enter a price, the form shows the price on the other side of tax below the field, in the company currency. With the net setting it shows the gross price, for example `€0.357 incl. tax` for `0.30` at a tax rate of `0.19` in EUR. With the gross setting it shows the net price, for example `€0.3025 excl. tax` for `0.36`. The hint appears when the price and a tax rate above 0 are set.

Each session keeps the setting it started with. Changing the setting does not convert existing tariff prices: the CSMS asks for confirmation, and you re-enter each tariff price after saving. Under the default net setting, charged amounts are the same as before the setting existed.

Drivers see prices excluding or including tax depending on the price display setting (Settings > Company Info > **Prices in the driver portal**) and their own **Show prices** choice. See [Settings](https://www.evtivity.com/docs/csms/settings) and [Account management](https://www.evtivity.com/docs/portal/account). The display never changes the amount charged.

OCPP 2.1 stations that calculate the cost locally receive the driver's tariff in the `Authorize` response. See Station Tariff (OCPP 2.1) below.

## Currency

Tariffs have no currency field. Every tariff is priced in the company currency, chosen under Settings > Company Info from the [supported currencies](https://www.evtivity.com/docs/csms/settings). Stripe charges in the same currency.

Changing the company currency does not relabel past sessions, payments, or invoices. They keep the currency they were billed in.

## Tax Rate Format

Tax rate is a decimal fraction between 0 and 1, not a percent. For an 8.25% tax, enter `0.0825`. The system rejects values greater than 1.0 to catch the common data-entry mistake of typing a percent value (for example, `8.25`).

Examples:

| Tax | Enter |
|-----|-------|
| 0% | `0` |
| 8.25% | `0.0825` |
| 20% | `0.2` |
| 100% | `1.0` |

## Tariff Restrictions

Restrictions determine when a tariff is active. Each restriction type has an auto-derived priority. Higher priority wins during resolution.

| Priority | Type | Example |
|----------|------|---------|
| 0 | Default | No restrictions. Fallback when no other tariff matches. |
| 10 | Time-only | 09:00-17:00 peak hours |
| 20 | Day + time | Monday-Friday 09:00-17:00 |
| 30 | Seasonal (date range) | June 1 - September 30 summer rate |
| 40 | Holiday | Applies on configured holiday dates only |
| 50 | Energy threshold | Above 50 kWh per session |

### Time Windows

- The end time is exclusive. An end time of `00:00` means midnight, so `18:00-00:00` runs from 18:00 to the end of the day.
- A window that ends before it starts stays on the same calendar day. `Fri 22:00-06:00` applies on Friday from 00:00 to 06:00 and from 22:00 to 24:00. It does not apply on Saturday morning.
- Days of the week without a time window apply all day. Tick **All day** in the tariff form.
- Times and days are evaluated in the site's timezone.

### Date Ranges

Dates use the MM-DD format and both dates are included. Ranges can wrap the year end (for example 11-01 to 03-31). An end date of `02-29` includes the leap day, so `12-01` to `02-29` covers all of February in a leap year. `12-01` to `02-28` does not include February 29.

### Energy Thresholds

An energy-threshold tariff applies once the session has delivered at least its threshold. A group can have several thresholds, one tariff per threshold value. The highest threshold the session reached applies. Energy thresholds are billed only with split billing (see Split Billing below).

### Combination Rules

- Energy threshold cannot combine with other restriction types.
- Holiday cannot combine with date range.
- Days of week can be used with a time window or all day.
- Time range can be used alone or with days of week.

## Overlap Validation

The system validates that tariffs within the same priority level do not conflict:

- Only one default tariff (priority 0) per group.
- Time ranges at priority 10 must not overlap.
- At priority 20, overlapping days AND overlapping times create a conflict.
- Date ranges at priority 30 must not overlap.
- Only one holiday tariff (priority 40) per group.
- Multiple energy thresholds (priority 50) are allowed, one tariff per threshold value.

Tariffs at different priority levels never conflict with each other.

## Pricing Group Detail

![Pricing detail](https://www.evtivity.com/screenshots/csms/pricing-detail.png)

The detail page has three tabs:

- **Details** - Edit group name, description, and default status.
- **Tariffs** - List of tariffs in the group with their restrictions and rates.
- **Schedule** - Visual timeline showing which tariff is active at each point in time, with the current tariff highlighted. A pricing group has no site, so the group page marks the current tariff in the system timezone (Settings). On a site's or station's Pricing tab it uses the site's timezone.

## Assignment

Assign pricing groups to stations, sites, fleets, or drivers. The tariff resolution system checks assignments in priority order:

1. **Driver-specific** (highest) - Applies at all stations.
2. **Fleet** - Applies at all stations for fleet drivers.
3. **Station** - Applies at a specific station.
4. **Site** - Applies at all stations in a site.
5. **Default group** (lowest) - Applies when no other assignment matches.

A group passes to the next group in this order when it has no active tariff that applies at that moment. When no group has a tariff that applies, the session is not priced.

Assign pricing from the Pricing tab on the respective detail page (station, site, fleet, or driver). Every assignment change (create, update, remove) is recorded in the pricing audit log.

### Session Pricing Group

A session keeps the pricing group it started in until it ends. Changes to an assignment, a fleet membership, or the station's group apply to the next session, not to a running one. With split billing on, a running session moves only between the tariffs of its own group.

### Driver in Multiple Fleets

When a driver belongs to more than one fleet and the fleets have different pricing groups, the OLDEST fleet membership wins. Resolution orders fleet memberships by `fleet_drivers.created_at` ascending and picks the first match.

## Holidays

Click **Manage Holidays** on the pricing list page to configure holiday dates.

![Pricing holidays](https://www.evtivity.com/screenshots/csms/pricing-holidays.png)

Add individual holidays or use bulk add to import multiple dates. Holiday tariffs (priority 40) apply on these configured dates. Each date must be unique. Holiday create, update, and delete actions are recorded in the pricing audit log.

## Pricing Audit Log

Every create, update, and delete on pricing entities is recorded with before/after JSONB snapshots. The log captures:

| Entity type | Covers |
|-------------|--------|
| `pricing_group` | Group create, update, delete |
| `tariff` | Tariff create, update, delete |
| `holiday` | Holiday create, update, delete |
| `pricing_assignment` | Station, site, fleet, or driver assignment changes |

View the audit trail from the **History** tab on the Pricing Group Detail page. Each entry shows the actor, timestamp, action, and the diff between before and after snapshots.

## Split Billing

Split billing is on by default (**Split Billing** under Settings > Pricing, `pricing.splitBillingEnabled`). While it is on, the system tracks tariff changes during a session. If the active tariff changes mid-session (e.g., crossing a time-of-day boundary), each segment is costed independently:

- Energy cost uses the segment's energy delta.
- Time cost uses the segment's duration.
- Session fee applies to the first segment only.
- Idle fee uses the segment's billable idle minutes. The idle grace period covers the first idle minutes of the session, whichever segments they fall in, so the free minutes are the same with or without split billing.
- Each segment is taxed at the tax rate of its own tariff. Tax is rounded once per rate: the net amounts of all segments at the same rate are added up first, then the tax is computed exactly and rounded half up to the cent. With prices entered including tax, the tax contained in the sum of each rate is taken out once. Example: three segments of €0.33 at a rate of `0.19` are taxed €0.19 (19% of €0.99), not 3 x €0.06.
- Reservation holding fee, when present, is taxed at the first segment's rate (consistent with the session fee).

The final session cost is the sum of all segment costs. A background job checks active sessions every minute for tariff boundary crossings. Each per-segment snapshot is stored in `session_tariff_segments`.

An energy-threshold tariff applies once the session has delivered at least its threshold. With split billing on, a new segment at that tariff starts when the session crosses the threshold, so only the energy after it is billed at the threshold price. When a group has several thresholds, the highest threshold the session reached applies. Without split billing, the tariff that applied at the session start prices the whole session, and energy-threshold tariffs are never billed.

### Payment on a Free Start

With split billing on, a session can move to any tariff of its group. A session that starts on a free tariff in a group that also has a paid tariff is treated as paid from the start:

- A card session gets the payment hold at the start, as on a paid tariff.
- The portal requires a payment method before the driver starts.
- A guest pays at checkout.

When a session that started free moves to a paid tariff, for example one added to the group after the start, the payment check runs at that moment. A card session gets the hold. A guest who started free without a card hold is stopped.

## Station Tariff (OCPP 2.1)

OCPP 2.1 stations that calculate the cost locally receive the driver's tariff in the `Authorize` response. The station tariff describes the prices the CSMS bills with. The CSMS bill is the amount charged.

- **Prices excluding tax.** Prices are net (converted with 4 decimals when prices are entered including tax), each with the tax rate as a percentage (`19` for a rate of `0.19`), as the OCPP 2.1 schema defines.
- **Time for the whole session.** `chargingTime` carries the time price. `idleTime` carries the time price and, from `minIdleTime`, the time price plus the idle fee. `minIdleTime` is the idle grace period in seconds.
- **Fees.** `fixedFee` is the session fee. `reservationTime` is the reservation fee per minute.
- **Group tariffs under split billing.** With split billing on, the station gets every active tariff of the session's pricing group, in resolution order with the default tariff last, each with its conditions: energy thresholds as `minEnergy`, time windows as `startTimeOfDay` and `endTimeOfDay`, days as `dayOfWeek`, and date ranges and holidays as `validFromDate` and `validToDate` in the site's local date. A day window past midnight is sent as two windows on the same day, for example `Fri 22:00-06:00` as Friday 00:00-06:00 and Friday 22:00-24:00. Without split billing the station gets the session's tariff alone.
- **Limits.** The station gets the session's tariff alone when it reports no condition support (`TariffCostCtrlr.ConditionsSupported`), when the group's tariffs have different tax rates, or when a price field needs more elements than the station's `TariffCostCtrlr.MaxElements`. A station without condition support gets no idle fee element when there is an idle grace period, because it cannot keep the first idle minutes free. The CSMS still bills the idle fee.
- **Tariff ID.** The `tariffId` is derived from the tariff content, so a changed tariff gets a new ID. `validFrom` is never sent.

When split billing moves a session to another tariff, at a time window or an energy threshold, the CSMS sends `ChangeTransactionTariff` to an online station that reports local cost calculation (`TariffCostCtrlr.Enabled`) when the station's tariff no longer describes the session. A station that holds the group's tariffs with their conditions moves to the new window by itself, so nothing is sent.

The station reports its tariff ID and its cost in its `TransactionEvent` messages. The CSMS stores both and compares the station's total with the bill when the session ends. See [Sessions](https://www.evtivity.com/docs/csms/sessions).

## Tariff Delete Protection

A tariff cannot be deleted while any session still references it. The API returns `409 TARIFF_IN_USE` when the tariff is referenced by either:

- `charging_sessions.tariff_id` - the primary tariff snapshot for the session, or
- `session_tariff_segments.tariff_id` - a per-segment snapshot recorded during split billing.

Both references are checked. Earlier behavior only checked the primary snapshot, which let split-billing segment references block deletion silently.

## Pricing Display

Drivers see each rate in the company currency, formatted for their language with 2 to 4 decimals, so a price such as `0.357` is not rounded. Prices are shown excluding or including tax as the price display setting and the driver's choice set, with a note that names the tax rate, for example "Prices include 19% tax". When all rate components are zero, the display shows "Free", whatever the tax rate.

The Portal pricing display also returns the resolved tariff's restrictions and renders a one-line summary below the rate, for example "Mon, Tue, Wed 09:00-17:00" or "Holiday rate". This makes time-of-day and holiday tariffs visible to drivers before they start a session. For a time or day restriction the summary names the site's timezone, for example "Times in Europe/Berlin". With split billing on and tariffs with restrictions in the group, a note says the price can change during the session.
