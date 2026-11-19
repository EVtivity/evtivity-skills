Generated from https://www.evtivity.com/docs/csms/fleets. Do not edit.

# Fleets

Organize drivers and stations into fleets for group management and pricing.

## Overview

Fleets group drivers, stations, and vehicles under a single organizational entity. Use fleets to manage corporate charging programs, municipal vehicle fleets, or any scenario where a group of drivers shares pricing or station access. A fleet can also own RFID cards and have its own [fleet users](https://www.evtivity.com/docs/csms/users#fleet-users), who see only their fleets.

![Fleets list](https://www.evtivity.com/screenshots/csms/fleets-list.png)

## Create a Fleet

1. Navigate to **Fleets** in the sidebar.
2. Click **Create Fleet**.
3. Enter the fleet name and optional description.
4. Click **Create**.

![Create fleet](https://www.evtivity.com/screenshots/csms/fleets-create.png)

## Fleet Detail

Click any fleet in the list to open the detail page. The default Details view edits the fleet's name and description.

![Fleet detail](https://www.evtivity.com/screenshots/csms/fleet-detail.png)

### Sessions

View the charging sessions of the fleet's drivers and of its RFID cards across all stations. Filter the list by **Member**, by **RFID Card** (with the `fleetCards:read` permission) and by the start date with **From** and **To**. A member filter lists only sessions of that member of the fleet, and an RFID card filter only sessions of that fleet card.

**Export CSV** (with the `sessions:read` permission) downloads the list with the filters on screen, newest first: session ID, start and end, status, site, station, unit, EVSE, connector, connector type, driver name, the label of a fleet RFID card, and energy in kWh. The cost and currency are included with the `payments:read` permission. Operators also get the RFID card value and the OCPP transaction ID; [fleet users](https://www.evtivity.com/docs/csms/users#fleet-users) never do. One export covers at most 366 days of start dates (without a date it covers the 366 days up to now) and at most 50,000 sessions.

![Fleet sessions](https://www.evtivity.com/screenshots/csms/fleet-sessions-tab.png)

A member whose data was erased shows as **Erased Driver** in the session details and as "Erased driver" in the export (in your language), with no name or other personal data.

### Stations

Add or remove stations associated with the fleet. This is informational grouping rather than access control.

![Fleet stations](https://www.evtivity.com/screenshots/csms/fleet-stations-tab.png)

### Vehicles

View vehicles belonging to fleet drivers.

![Fleet vehicles](https://www.evtivity.com/screenshots/csms/fleet-vehicles-tab.png)

### Departures

Enter when each fleet vehicle leaves a Depot and how much energy its next route needs: **Weekly Schedules** for repeating departures, one-off departures with **Add Departure**, or a file with **Import CSV**. With **Fleet Charging** on and the Depot on the **Departure Aware** strategy, each departure shows its state, delivered energy and predicted ready time. Departures a [bus depot system](https://www.evtivity.com/docs/integrations/bus-depot-systems) sends show here too and are read-only while that system is enabled. See [Route Aware Charging](https://www.evtivity.com/docs/csms/route-aware-charging).

![Fleet Departures tab](https://www.evtivity.com/screenshots/csms/fleet-departures-tab.png)

### Drivers

Add or remove drivers from the fleet. Each member shows with their avatar, or initials when the driver has none. Drivers in a fleet inherit the fleet's pricing group when no driver-specific pricing is assigned.

To add drivers:

1. Click **Add Driver**.
2. Search for drivers by name or email.
3. Click a driver in the results to add them to the fleet.

To remove a driver, click the remove icon next to their name.

![Fleet drivers](https://www.evtivity.com/screenshots/csms/fleet-drivers-tab.png)

### Pricing

Assign a pricing group to the fleet. Fleet-level pricing applies to all fleet drivers at all stations, unless the driver has a driver-specific pricing override.

![Fleet pricing](https://www.evtivity.com/screenshots/csms/fleet-pricing-tab.png)

### Billing

Turn charge on account on or off for the fleet, choose who receives its invoices, and set its billing profile. See the Charge on Account section below.

![Fleet billing tab](https://www.evtivity.com/screenshots/csms/fleet-billing-tab.png)

### RFID Cards

The **RFID Cards** tab lists the RFID cards the fleet owns, with the card value, type, label, member, and status. It needs the `fleetCards:read` permission, and changes need `fleetCards:write`. Operators and the fleet's [fleet users](https://www.evtivity.com/docs/csms/users#fleet-users) use the same tab.

- **Add RFID Card** - enter the card value and type, an optional label, and an optional member. A fleet user picks the type from two choices: **RFID card or key fob (most cards)**, the default, or **Other RFID card (ISO 15693)**. Operators pick from every card type, each with a short hint. A value that cannot be added answers a fleet user "This RFID card value cannot be added", whatever the reason.
- **Edit RFID Card** - change the label, give the card to an active member of the fleet or leave it with no member, and uncheck **Active** to turn the card off. Check **Active** again to turn it on.
- **Deactivate** - operators only. Deactivates the card for good after a confirmation. The card stops working at every station, cannot be turned on again, and stays in the list as **Deactivated**.

The status shows **Active**, **Turned Off**, or **Deactivated**. A fleet user cannot turn on a card that an operator turned off or deactivated. Such a card shows that an operator turned it off.

Every session of a fleet RFID card charges on account to the card's fleet, whether a member holds the card or not. It never charges the member's saved credit card and never goes on a member invoice. A fleet RFID card charges only while its fleet bills on account; otherwise the station refuses it. While the fleet does not bill on account, the CSMS refuses to add or import an RFID card, or give one to a member and answers `FLEET_CARD_NOT_BILLABLE`. Taking a card back from its member still works. See also [RFID Cards No Member Holds](#rfid-cards-no-member-holds). The label belongs to the fleet and stays when the card moves to another member. The member gets a notice when a card is given to them or taken back.

When a member leaves the fleet, is deactivated, or is erased, the fleet takes back the member's fleet RFID cards: they lose their member and are turned off. A fleet user can turn them on again.

The card value and type never change on this tab. Operators move a card into, out of, or between fleets with the **Fleet** field on the Tokens pages (see [Fleet RFID Cards](https://www.evtivity.com/docs/csms/tokens#fleet-rfid-cards)).

Drivers see a fleet card in the portal and the mobile app as managed by the fleet. They cannot rename it, turn it off, or remove it.

**Import CSV** (with `fleetCards:write`) adds many cards at once. Click **Download Template** for the columns: `idToken`, `tokenType` (`ISO14443` when empty; a fleet user's file takes only `ISO14443` or `ISO15693`), an optional `label`, and an optional `memberEmail` of an active member of the fleet. Only operators give imported cards to members by email: the template a fleet user downloads has no `memberEmail` column, and a fleet user's file that holds one is refused whole. A fleet user gives the cards to members on this tab after the import. A file holds at most 2,000 cards and 512 KB. Each row is checked like a single card; the result lists the cards added and each refused row with its line, field, and reason. A refused row adds nothing.

Roaming partners get every fleet RFID card. A card a member holds is listed to them like the member's own RFID cards. A card no member holds is listed to them as not valid, so a card taken back from its member stops working at partner stations.

**History** on a card's row lists the card's changes while it belonged to the fleet: added, given to a member or taken back, renamed, monthly limit changed, turned off and on, and deactivated, each with its date and who made it. A fleet user sees the names of the fleet's own fleet users; every other person shows as **Operator**. Card values, earlier values, and notes never show.

A fleet without RFID cards shows how to start, with **Import CSV** and **Add RFID Card** in the empty list.

#### Monthly Limit

**Monthly Limit** in the add and edit dialogs sets the most a card may cost in one calendar month, in the company currency. Leave it empty for no limit. The **This Month** column shows what the card has spent this month, against its limit when it has one. The limit counts every session of the card, whoever charges with it: the member it is given to, or no member. A running session counts at the cost reserved for it.

- A card that has spent its limit is refused at the station until the next month.
- A session's cost ceiling is never more than what the card has left. An OCPP 2.1 station gets it as the cost limit of the transaction. An OCPP 1.6 session is stopped by the CSMS when its cost reaches it, and the station screen shows the **Card Monthly Limit Reached** message.
- When the limit refuses a card given to a member, or stops its session, the member gets the notice "This RFID card reached its monthly spending limit" by email, SMS or push, once per card and month (again after the limit is changed and reached). A card with no member notifies nobody: only the station screen shows it. Drivers can turn the notice off with their other RFID card notifications.
- The month starts at midnight in the company time zone.
- A card moved out of its fleet loses its limit. Only a card of a fleet has one.

### Fleet Managers

The **Fleet Managers** tab lists the [fleet users](https://www.evtivity.com/docs/csms/users#fleet-users) assigned to the fleet, with their name, email, and last sign-in. Click a row to open the user. It shows to users with access to all sites and the `users:read` permission. With `users:write`, **Add Fleet Manager** opens **Create User** with the **Fleet Manager** role and the fleet already chosen. It comes right after the **Drivers** tab and is hidden while **Enable Fleet** is off.

Fleet managers see when and where the fleet's members charged. Inform your fleet members of this as your local privacy law requires.

A new fleet manager gets the fleet manager invitation email: what a fleet manager can do with sessions, invoices, and RFID cards, the fleets by name, and a link to set the password (valid 24 hours). **Resend Invite** on the user sends a new one.

### Bulk Reservations

Create and manage batch reservations for fleet vehicles across multiple stations in one go.

#### Create a Bulk Reservation

1. Open the **Bulk Reservations** tab on the fleet detail page.
2. Click **New Bulk Reservation**.
3. Set a name (optional), starts-at, and expires-at.
4. For each station you want to reserve, add a slot:
   - Search for a station (search-as-you-type).
   - Pick a connector from the dropdown that appears once a station is chosen. A station without connectors shows **No Connectors**.
   - Optionally assign a driver (search-as-you-type).
5. Click **Add Station** to add more slots, up to 100 per bulk reservation. A station can be in several slots, one connector each: a connector already chosen in another slot is not offered again.
6. Click **Create**.

The name does not need to be unique: two bulk reservations of a fleet can have the same name.

#### Validation

The same date checks as the single-reservation flow apply: start cannot be in the past, end must be at least 60 seconds in the future, the window must be at least 60 seconds wide, and the duration cannot exceed the system-wide `reservation.maxHours` cap when set.

#### Result

Each slot is processed independently. The result toast reports the count of confirmed and failed slots. When a slot fails, the **Bulk Reservation Result** dialog lists each slot that was not reserved with its station and reason. A failed slot does not roll back the others. The bulk reservation keeps the slots that succeeded. A slot rejected at create is not stored.

#### Status

| Status | Meaning |
|---|---|
| scheduled | Every live slot waits for its start |
| active | At least one slot is on its station or in use, and no slot was lost |
| partial | A slot is still live, and another slot was cancelled or expired |
| completed | Every slot ended, and at least one was used |
| expired | Every slot ended, none was used, and at least one expired |
| cancelled | Every slot was cancelled, or an operator cancelled the bulk reservation |

The status follows the slots. `completed`, `expired` and `cancelled` are final: a later slot change does not move the bulk reservation.

#### Cancellation

Click the trash icon on any row to cancel all slots in that bulk reservation. This sends `CancelReservation` to every station holding an active slot and marks the bulk reservation as `cancelled`. Slots already used by an in-progress charging session are unaffected.

The tariff resolution priority is:

1. Driver-specific pricing (highest priority)
2. Fleet pricing
3. Station pricing
4. Site pricing
5. Default pricing group (lowest priority)

See [Pricing](https://www.evtivity.com/docs/csms/pricing) for full details on tariff resolution.

![Fleet bulk reservations](https://www.evtivity.com/screenshots/csms/fleet-reservations-tab.png)

## Charge on Account

Charge on account lets the drivers of a fleet charge without a card. Their sessions are billed to the fleet instead of their own card, and the fleet pays for them on the fleet invoice. A fleet can also invoice each member for their own sessions. See [Member Invoices](https://www.evtivity.com/docs/csms/fleets#member-invoices).

### Turn It On

1. Open the fleet and select the **Billing** tab.
2. Click the **Charge on Account** switch.
3. Confirm the change.

Each affected driver receives a notification. Turning the switch off works the same way. New sessions are then paid by card. Running sessions keep how they started. Sessions not billed yet stay billed to the fleet.

Changing the switch needs the `fleets:write` permission. Every change is recorded in the fleet history.

Charge on account cannot be turned on while services of an earlier release are still connected.

### Members Who Pay by Card

The **Drivers** tab has a **Charge on Account** switch for each member. Turn it off for a member who pays by card although the fleet bills on account. The driver is notified when the fleet bills on account.

![Charge on account per fleet member](https://www.evtivity.com/screenshots/csms/fleet-drivers-billing-tab.png)

### Billing Profile

The **Billing Profile** card on the **Billing** tab sets who the fleet invoice goes to and how it is issued. Click **Edit** to change it.

- **Billing contacts**: the email addresses that receive the fleet invoice, one per line, up to 10.
- **Legal name**, address and **VAT ID or tax ID**: the bill-to block printed on the invoice. Without a legal name the invoice uses the fleet name.
- **Invoice language**: the language of the fleet invoice and its email.
- **Payment terms (days)**: the days from issue to the due date. Leave it empty to use the payment terms in **Settings** > **Payment**.
- **Invoice date**: **Day the invoice is issued** (the default) or **Last day of the billed month**. With the last day of the billed month, a fleet invoice or member invoice issued after the month end is dated on that day and numbered in that month (for example `INV-202610-...` for October), and its due date counts from that day. An invoice of the current month is dated today.
- **Automatic monthly invoice**: the monthly run invoices the fleet for the previous month and emails the invoice to the billing contacts. See [Monthly Run](https://www.evtivity.com/docs/csms/fleets#monthly-run). It needs at least one billing contact. Without one the CSMS answers `FLEET_BILLING_CONTACT_REQUIRED`.

![Fleet billing profile](https://www.evtivity.com/screenshots/csms/fleet-billing-profile.png)

Changing the profile needs the `fleets:write` permission. Every change is recorded in the fleet history with the fields that changed.

A [fleet user](https://www.evtivity.com/docs/csms/users#fleet-users) with the **Manage Fleet Billing Profile** permission (`fleetBilling:write`) edits the billing contacts, the legal name and address, the VAT ID or tax ID, and the invoice language of its own fleets. The payment terms, the invoice date and automatic monthly invoicing stay with operators. The VAT ID is printed on the invoice: a new one applies to invoices issued after the change, and invoices already issued keep theirs. Every change of the VAT ID notifies the operators who manage fleet billing (users with access to every site who hold `payments:write` or `fleetBilling:write`), and every change shows in the fleet history under the name of the user who made it. Billing contacts are not verified before invoices are sent to them, whoever adds them.

### Which Fleet Bills a Driver

A driver can belong to several fleets. The oldest membership in a fleet with charge on account wins, as long as the driver has not opted out there. With fleets turned off in the settings, every driver pays by card.

The fleet that bills a driver and the fleet that prices a driver can differ. The **Billing** card on the driver page shows both: **Billing fleet** and **Pricing fleet**.

When a driver pricing group applies, the card shows it instead of a pricing fleet, because driver pricing overrides fleet pricing. When the billing fleet invoices each member, the card also shows **Invoiced to**: The driver.

![Driver billing card](https://www.evtivity.com/screenshots/csms/driver-billing-card.png)

### How a Session Is Paid

The CSMS decides how a session is paid when it starts, in this order:

1. The roaming partner bills a roaming session.
2. A free vend site charges nothing.
3. A prepaid token pays from its balance.
4. A driver whose fleet bills on account charges on account.
5. Every other driver pays by card.

The session keeps this decision. A later change to the fleet does not change a running session.

On account, the driver starts from the portal without a payment method. The CSMS places no pre-authorization hold, for portal starts and RFID starts alike. This also works when payments are turned off. Reservations still need a card.

### Billing State

The session page shows a badge with the fleet and the billing state:

- **Unbilled**: the session waits for the fleet invoice.
- **Invoiced**: the session is on an issued invoice.
- **Paid**: the invoice is paid.

![Session billed on account](https://www.evtivity.com/screenshots/csms/session-account-billing.png)

Driver invoices leave account sessions out, so the CSMS never bills a session twice.

A session that was paid by card, for example through a hold an operator placed, shows no badge and is not billed to the fleet.

Drivers see the fleet and the billing state of their account sessions in the portal and the mobile app. They never see the fleet invoice. A driver whose fleet invoices each member sees their own member invoices. See [Invoices](https://www.evtivity.com/docs/portal/invoices). Earlier versions of the mobile app show the driver's saved card instead of the fleet for an account session, and do not charge it.

### Revenue

An account session counts as revenue once its invoice is paid. Until then the dashboard and the revenue report show it apart as **Billed on Account**.

It counts on the day the invoice is paid, not on the day of the session. A session that costs nothing is not shown apart.

![Billed on account on the dashboard](https://www.evtivity.com/screenshots/csms/dashboard-billed-on-account.png)

### Credit Limit

A fleet can have a credit limit. Drivers billed to the fleet can start sessions while the fleet has credit left, and several of them can charge at once. Each session reserves part of the credit when it starts and reserves more as it charges.

The open amount is what the fleet owes or will owe on account, in the company currency:

- Ended sessions that are on no invoice yet, at their final cost.
- Sessions on an issued, unpaid invoice.
- Running sessions, at their current cost.

Sessions paid by card do not count. A paid invoice, or a higher limit, lets drivers start again. The limit applies to the whole fleet when it invoices each member too: member sessions and unpaid member invoices count toward it.

The credit left is the limit minus the ended sessions that are not paid yet and minus what the running sessions reserve.

To set the limit:

1. Open the fleet and select the **Billing** tab.
2. In the **Credit Limit** card, click **Edit**.
3. Enter the **Credit limit** in the company currency. Leave it empty for no limit.
4. Enter **Warning at (%)**: the percent of the limit at which the fleet is warned, from 1 to 99 (default 80).
5. Click **Save**.

The card shows the open amount, split into unbilled sessions, invoiced and unpaid, and running sessions, and whether the fleet is below the limit, at the warning level, or at the limit. You need the `fleets:write` permission to edit it.

![Fleet credit limit](https://www.evtivity.com/screenshots/csms/fleet-credit-limit.png)

When the fleet has no credit left:

- A station that asks the CSMS before it starts gets `NoCredit` (OCPP 1.6: `Blocked`) and does not start.
- The portal and the mobile app refuse the start with `FLEET_CREDIT_LIMIT_REACHED`.
- An RFID start is stopped right after it begins. The session ends faulted with the stopped reason `AccountCreditLimit` and costs nothing. The station shows the **Fleet Credit Limit Reached** message, which you edit with the station messages in [Settings](https://www.evtivity.com/docs/csms/settings#messages), and the driver receives `payment.AccountCreditLimit`.

#### While Charging

Each session of the fleet reserves part of the credit left when it starts: the **Credit reserved per session** amount set in [Settings](https://www.evtivity.com/docs/csms/settings#fleet) (default 50.00 in the company currency), or the credit left when that is less. This reservation is the session's cost ceiling. Sessions that start at the same time reserve from what is left, so together they never pass the limit, and the rest of the limit stays free for the other drivers of the fleet.

When the cost of a session reaches 80% of its ceiling, the CSMS raises the ceiling by another reservation, at most up to the credit the fleet has left. A session stops only when its cost reaches the ceiling and the fleet has no credit left to raise it. A session that gets no credit is stopped at the start, as described above.

A session is billed at most its ceiling. When it reaches it:

- An OCPP 2.1 station gets the ceiling as the cost limit of the transaction when it starts, and each raised ceiling as the new cost limit in the response to its next transaction event. It suspends charging itself at the limit. The driver unplugs to end the session.
- An OCPP 1.6 station, or a 2.1 station without cost limit support, is stopped by the CSMS.

The session ends with the stopped reason `AccountCreditLimit` and is billed to the fleet at the credit it used. The station shows the **Fleet Credit Limit Reached** message and the driver receives `payment.AccountCreditLimit`, once per session. A new limit applies when a session starts or its ceiling is raised.

Once per month each, the fleet receives `fleet.CreditLimitWarning` when the open amount reaches the warning percent and `fleet.CreditLimitReached` when it reaches the limit. Both go to the fleet's billing contacts. The reached notice also goes to every active operator with the `fleets:write` permission, and so does the warning while the fleet has no billing contact. Both also go out while a session charges, when its cost raises the open amount to the warning percent or the limit.

### Fleet Invoice

The fleet invoice bills the fleet's account sessions of one calendar month in the system time zone. You need the `payments:read` permission to see it and `payments:write` to issue, send and correct it.

1. Open the fleet and select the **Billing** tab.
2. In the **Unbilled Sessions** card, pick the **Month**. It shows the sessions the invoice bills, per driver, and the sessions left off the invoice.
3. Click **Generate Invoice** and confirm.

![Unbilled sessions of the fleet](https://www.evtivity.com/screenshots/csms/fleet-billing-unbilled.png)

The invoice bills every account session of the fleet that ended before the end of the month and is on no invoice yet, including older ones. A session that ends later goes on the next invoice. Sessions in another currency than the company currency, sessions without a final cost and sessions that cost nothing are left off and listed. Sessions paid by card are never on it.

The invoice is issued at once, with no draft. It lists the sessions grouped by driver with a subtotal for each driver, and the tax of each session as it was charged. A session's idle fee shows as its own line under the session, with the idle minutes billed (for example "Idle fee, 25 min"); the session line shows the rest of the amount. It carries the bill-to block and the language of the billing profile, and is due after the profile's payment terms. Each month has one invoice per fleet: a second one is refused with `FLEET_INVOICE_PERIOD_EXISTS`, and a month with nothing to bill with `FLEET_INVOICE_NOTHING_TO_BILL`.

The CSMS emails the invoice once, with the PDF attached, to the billing contacts (`invoice.FleetInvoice`). The PDF shows each driver's name and the stations, no other personal data. The **Fleet Invoices** card lists the fleet's invoices and credit notes. From there you download the PDF, **Send** the invoice again, **Mark Paid** when the fleet paid, or **Issue Credit Note** to correct it. A send without a billing contact is refused with `FLEET_BILLING_CONTACT_REQUIRED`.

![Fleet invoices](https://www.evtivity.com/screenshots/csms/fleet-billing-invoices.png)

![Fleet invoice](https://www.evtivity.com/screenshots/csms/fleet-invoice-detail.png)

A credit note cancels the whole invoice and is emailed to the billing contacts (`invoice.FleetCreditNote`). Its sessions are billed again, corrected, on the next invoice you generate for the month or a later one. Every issued invoice is recorded in the invoice history.

![Fleet credit note](https://www.evtivity.com/screenshots/csms/fleet-credit-note-detail.png)

### Monthly Run

The monthly run invoices every fleet with **Automatic monthly invoice** checked for the previous calendar month. From the **Monthly Fleet Invoice Day** (**Settings** > **Payment** > **General**, 1 to 28, default 1, in the system time zone) to the end of the month, it checks every hour and issues the invoice of each such fleet that has no invoice for that month yet. The invoice is the same as one from **Generate Invoice**, and it is emailed to the billing contacts. A month with nothing to bill issues nothing. A fleet that no longer charges on account still gets its unbilled sessions invoiced. Each month gets its own invoice, which bills only the sessions that ended in that month. If the run missed a month, for example because the worker was down for the whole window, it bills the oldest missed month first and the next month on a later run.

The run never issues a second invoice for a month, and it does not bill a month whose invoice was credited. After a credit note, generate the corrected invoice on the **Billing** tab.

The run retries a failing fleet for about two and a half hours. Every active operator with the `payments:write` permission then receives one `fleet.InvoiceRunFailed` notice per month that lists the fleets it could not finish, each with its last error: **invoice issued, email not sent** (open the invoice and use **Send**) or **not invoiced** (generate the invoice on the **Billing** tab). A fleet that fails later in the month comes in a later notice. The run does not try that fleet and month again.

When an issued fleet invoice passes its due date unpaid, the billing contacts receive one payment reminder with the PDF attached (`invoice.FleetOverdue`). A fleet without billing contacts gets the reminder once a contact is added. The invoice page shows when the reminder was sent.

### Member Invoices

A fleet that charges on account can invoice each member instead of the fleet. Each driver then gets a monthly invoice for their own account sessions. Members keep everything else: they charge without a card, the fleet's pricing and credit limit apply, and members who pay by card keep paying by card. Only the invoice recipient changes.

To choose the recipient:

1. Open the fleet and select the **Billing** tab.
2. In **Invoice To**, select **Each Driver**, or **Fleet** to go back to one fleet invoice.
3. Click **Change** to confirm.

Sessions that start after the change are invoiced to each driver. Sessions that started before it stay on the fleet invoice. Switching back to **Fleet** works the same way: sessions already started stay on each driver's invoice. Each affected driver receives `fleet.AccountBillingChanged`. The change needs the `fleets:write` permission and is recorded in the fleet history.

Invoicing each driver cannot be turned on while services of an earlier release are still connected. The CSMS then answers `FLEET_BILLING_OLD_PODS_CONNECTED`.

#### Driver Invoices

The **Unbilled Sessions** card on the **Billing** tab shows a **Driver Invoices** table for the **Month** you pick. It lists each driver with unbilled sessions billed to them on account: the driver, the number of sessions, the total, and the member invoice the month already has. A **No Email** badge marks a driver without an email address. A **No Address** badge marks a driver without a billing address (street and city).

- Click **Generate** on a row to issue the invoice of that driver and send it to the driver.
- Click **Invoice All Members** to issue the invoices of every driver with unbilled sessions. The CSMS issues them in the background and sends each to its driver. The table updates as the invoices are issued.

Issuing member invoices needs the `payments:write` permission. A member invoice bills every unbilled session of the driver that ended before the end of the month, including older ones. Each driver gets one invoice per fleet and month: a second one is refused with `FLEET_INVOICE_PERIOD_EXISTS`, and a driver with nothing to bill with `FLEET_INVOICE_NOTHING_TO_BILL`. A driver who left the fleet still gets their unbilled sessions invoiced.

#### Member Invoice Content

A member invoice is issued at once, with no draft, and is due after the fleet's payment terms. It is in the driver's language and lists the driver's sessions without driver groups. The PDF bill-to block prints the driver's billing name and address, then the driver's email, and below it "Charged on account of" and the fleet name. A driver without a billing address still gets the invoice, with the name and email. The CSMS flags the missing address and never blocks the invoice. Drivers enter their address in the portal and the mobile app, and you can edit it on the driver page. See [Billing Address](https://www.evtivity.com/docs/csms/drivers#billing-address).

The invoice page shows the fleet as **Via Fleet** and links the driver. The driver's **Invoices** tab lists member invoices with a "Via" badge that names the fleet, and the session page reads "On account: (fleet) (driver invoice)".

#### Sending and Corrections

The CSMS sends each member invoice once to the driver only, by email with the PDF attached and as a push notification (`invoice.MemberInvoice`). The fleet's billing contacts receive no copy. A driver without an email address gets no email: add the address on the driver page, then click **Send**. A send to a driver without an email address is refused with `INVOICE_NO_DRIVER_EMAIL`.

The **Fleet Invoices** card lists member invoices beside the fleet invoices. The **Billed To** column shows the fleet or the driver. The **Invoice To** filter shows **All** invoices, only **Fleet** invoices, or only **Driver** invoices.

- **Send** emails the invoice again to the driver.
- **Mark Paid** records the payment of the driver.
- **Issue Credit Note** cancels the invoice. The driver receives the credit note (`invoice.MemberCreditNote`), and its sessions are billed again on the next invoice you generate for the driver for that month or a later one.

When an issued member invoice passes its due date unpaid, the driver receives one reminder with the PDF attached (`invoice.MemberOverdue`). A driver without an email address gets the reminder once an address is added.

#### Moving Sessions Between Invoices

An unbilled session can move between the fleet invoice and the member invoice of its driver.

- On the session page, **Bill to Driver** moves a session from the fleet invoice to the driver's member invoice, and **Bill to Fleet** moves it back.
- In the invoice preview on the **Billing** tab, **Bill to Driver** on a driver row moves that driver's unbilled sessions of the month to the member invoice, and **Bill All to Drivers** moves every driver's. On the member rows, **Bill to Fleet** and **Bill All to Fleet** move them back to the fleet invoice.

A session moves only while it is on no invoice, its driver is still a member of the fleet, and the fleet bills on account. A session of an issued invoice needs a credit note first: the credit note releases it. Each move is recorded in the session history. Moving sessions needs the `payments:write` permission and access to all sites.

#### Monthly Run for Members

With **Automatic monthly invoice** checked, the monthly run also issues the member invoices of the previous month, one for each driver with sessions to bill, and sends each to its driver. It follows the same rules as the fleet invoice: one invoice per driver and month, the oldest missed month first, and no new invoice for a month that was credited. A member invoice the run could not finish appears in the same `fleet.InvoiceRunFailed` notice, with the fleet and the driver.

### RFID Cards No Member Holds

A fleet RFID card that no member holds charges on account to its fleet:

- It works only while **Enable Fleet** and the fleet's charge on account are on. Otherwise stations refuse the card.
- Its sessions count against the fleet's [credit limit](#credit-limit). Stations refuse the card when the limit is reached.
- Its sessions are priced with the fleet's pricing group.
- The fleet invoice lists its sessions under **Fleet RFID Cards**, without a driver.
- It never charges from a prepaid balance, as an anonymous or guest session, or for free when its fleet cannot bill it. A card of a fleet holds no prepaid balance.
- A session that is running when the fleet's charge on account is turned off finishes and is billed to the fleet.
- At a [free vend](https://www.evtivity.com/docs/csms/sites#free-vend) site it charges free, like every RFID card.

### Deleting a Fleet

**Delete** asks for confirmation. When the CSMS refuses the delete, the dialog shows why.

The CSMS refuses to delete a fleet with sessions billed to it and answers `FLEET_HAS_OPEN_BILLING`. Turn off charge on account instead.

The CSMS also refuses to delete a fleet that has bulk reservations, in any status and cancelled ones included, and answers `FLEET_HAS_RESERVATIONS`. They stay as the fleet's history.

The CSMS also refuses to delete a fleet that still owns RFID cards and answers `FLEET_HAS_CARDS`. Move the cards out of the fleet on the Tokens pages, or delete them, first.

### Notifications

Drivers receive `fleet.AccountBillingChanged` when their billing changes: when the fleet turns charge on account on or off, when it changes who receives the invoices, when they opt out or back in, and when they join or leave a fleet that bills on account. The session receipt of an account session names the fleet and says that no card was charged. For a session invoiced to the driver, it says that the session is invoiced to the driver monthly via the fleet.

The fleet's fleet users with `payments:read` receive `fleet.ManagerCreditLimitWarning` and `fleet.ManagerCreditLimitReached` when the fleet nears or reaches its credit limit, and `fleet.ManagerInvoiceIssued` once for each new fleet invoice, with a link to it in the CSMS. Members receive `token.FleetCardAssigned` when a fleet RFID card is given to them and `token.FleetCardTakenBack` when it is taken back.

A new fleet user, and a fleet user an operator sends **Resend Invite** to, receives `operator.FleetManagerInvite` instead of the operator account email. It is a security template: changing it needs the `settings.system:write` permission.
