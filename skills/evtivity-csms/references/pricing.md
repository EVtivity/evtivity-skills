Generated from https://www.evtivity.com/docs/csms/pricing (website commit 4cd1866). Do not edit.

# Pricing

Configure tariffs with time-of-day restrictions, split billing, holidays, and multi-level assignment.

## Overview

The pricing system uses pricing groups that contain one or more tariffs. Each tariff defines rates for energy, time, session fees, idle fees, and tax. Tariffs can have restrictions that control when they apply, enabling time-of-day pricing, seasonal rates, holiday pricing, and energy threshold pricing.

![Pricing list](https://www.evtivity.com/screenshots/csms/pricing-list.png)

## Create a Pricing Group

1. Navigate to **Pricing** in the sidebar.
2. Click **Create Pricing Group**.
3. Enter a name and optional description.
4. Optionally mark it as the default group (used when no other assignment matches).
5. Click **Create**.

## Create a Tariff

1. Open a pricing group detail page.
2. Click **Create Tariff** in the Tariffs tab.
3. Enter the tariff name.
4. Set rate components. Prices are entered excluding or including tax, as the tax calculation method in Settings > Company Info sets (see Prices and Tax below). The labels say which, for example **Price per kWh (excl. tax)** or **Price per kWh (incl. tax)**:
   - **Price per kWh**
   - **Price per minute**
   - **Price per session**, a flat fee per session
   - **Idle Fee (Per Min)**, charged per minute after the grace period
   - **Reservation Fee (Per Min)**
   - **Tax Rate** (decimal fraction, 0 to 1)
5. Optionally select a restriction type to control when this tariff applies.
6. Click **Create**.

![Create tariff](https://www.evtivity.com/screenshots/csms/pricing-create.png)

## Prices and Tax

Every session cost includes tax. How tariff prices are entered depends on the **Tariff prices are entered** setting (`company.taxBasis`) under Settings > Company Info:

| Setting | Tariff prices | How a session is billed |
|---------|---------------|-------------------------|
| **Excluding tax (net)** (default) | Exclude tax. Labels read "excl. tax". | The cost calculator adds the tariff tax rate to the net cost. |
| **Including tax (gross)** | Include tax. Labels read "incl. tax". | Each billed line is the gross unit price times the quantity, rounded to the cent. The tax it contains is taken out. |

Example with the gross setting: 20 kWh at €0.36 per kWh (incl. tax) and a tax rate of `0.19` costs exactly €7.20. The tax taken out is €1.15 and the net amount is €6.05.

While you enter a price, the form shows the price on the other side of tax below the field, in the company currency. With the net setting it shows the gross price, for example `€0.357 incl. tax` for `0.30` at a tax rate of `0.19` in EUR. With the gross setting it shows the net price, for example `€0.3025 excl. tax` for `0.36`. The hint appears when the price and a tax rate above 0 are set.

Each session keeps the setting it started with. Changing the setting does not convert existing tariff prices: the CSMS asks for confirmation, and you re-enter each tariff price after saving. Under the default net setting, charged amounts are the same as before the setting existed.

Drivers see prices excluding or including tax depending on the price display setting (Settings > Company Info > **Prices in the driver portal**) and their own **Show prices** choice. See [Settings](https://www.evtivity.com/docs/csms/settings) and [Account management](https://www.evtivity.com/docs/portal/account). The display never changes the amount charged.

OCPP 2.1 stations that receive the driver's tariff in the `Authorize` response get net prices (converted with 4 decimals when prices are entered including tax) with the tax rate as a percentage (`19` for a rate of `0.19`), as the OCPP 2.1 schema defines.

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

Time ranges support midnight crossing (e.g., 22:00-06:00). Date ranges support year wrapping (e.g., November 1 - March 31).

### Combination Rules

- Energy threshold cannot combine with other restriction types.
- Holiday cannot combine with date range.
- Days of week requires a time range.
- Time range can be used alone or with days of week.

## Overlap Validation

The system validates that tariffs within the same priority level do not conflict:

- Only one default tariff (priority 0) per group.
- Time ranges at priority 10 must not overlap.
- At priority 20, overlapping days AND overlapping times create a conflict.
- Date ranges at priority 30 must not overlap.
- Only one holiday tariff (priority 40) per group.
- Multiple energy thresholds (priority 50) are allowed.

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

Assign pricing from the Pricing tab on the respective detail page (station, site, fleet, or driver). Every assignment change (create, update, remove) is recorded in the pricing audit log.

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

When `pricing.splitBillingEnabled` is turned on in Settings, the system tracks tariff changes during a session. If the active tariff changes mid-session (e.g., crossing a time-of-day boundary), each segment is costed independently:

- Energy cost uses the segment's energy delta.
- Time cost uses the segment's duration.
- Session fee applies to the first segment only.
- Idle fee uses the segment's idle minutes.
- Each segment is taxed at the tax rate of its own tariff. Tax is rounded once per rate: the net amounts of all segments at the same rate are added up first, then the tax is rounded to the cent. With prices entered including tax, the tax contained in the sum of each rate is taken out once. Example: three segments of €0.33 at a rate of `0.19` are taxed €0.19 (19% of €0.99), not 3 x €0.06.
- Reservation holding fee, when present, is taxed at the first segment's rate (consistent with the session fee).

The final session cost is the sum of all segment costs. A background job checks active sessions every minute for tariff boundary crossings. Each per-segment snapshot is stored in `session_tariff_segments`.

An energy-threshold tariff applies once the session has delivered at least its threshold. With split billing on, a new segment at that tariff starts when the session crosses the threshold, so only the energy after it is billed at the threshold price. Without split billing, the tariff that applied at the session start prices the whole session, and energy-threshold tariffs are never billed.

## Tariff Delete Protection

A tariff cannot be deleted while any session still references it. The API returns `409 TARIFF_IN_USE` when the tariff is referenced by either:

- `charging_sessions.tariff_id` - the primary tariff snapshot for the session, or
- `session_tariff_segments.tariff_id` - a per-segment snapshot recorded during split billing.

Both references are checked. Earlier behavior only checked the primary snapshot, which let split-billing segment references block deletion silently.

## Pricing Display

Drivers see each rate in the company currency, formatted for their language with 2 to 4 decimals, so a price such as `0.357` is not rounded. Prices are shown excluding or including tax as the price display setting and the driver's choice set, with a note that names the tax rate, for example "Prices include 19% tax". When all rate components are zero, the display shows "Free".

The Portal pricing display also returns the resolved tariff's restrictions and renders a one-line summary below the rate, for example "Mon, Tue, Wed 09:00-17:00" or "Holiday rate". This makes time-of-day and holiday tariffs visible to drivers before they start a session.
