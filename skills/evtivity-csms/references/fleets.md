Generated from https://www.evtivity.com/docs/csms/fleets. Do not edit.

# Fleets

Organize drivers and stations into fleets for group management and pricing.

## Overview

Fleets group drivers, stations, and vehicles under a single organizational entity. Use fleets to manage corporate charging programs, municipal vehicle fleets, or any scenario where a group of drivers shares pricing or station access.

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

View all charging sessions from fleet drivers across all stations. Filterable by status and date range.

![Fleet sessions](https://www.evtivity.com/screenshots/csms/fleet-sessions-tab.png)

### Stations

Add or remove stations associated with the fleet. This is informational grouping rather than access control.

![Fleet stations](https://www.evtivity.com/screenshots/csms/fleet-stations-tab.png)

### Vehicles

View vehicles belonging to fleet drivers.

![Fleet vehicles](https://www.evtivity.com/screenshots/csms/fleet-vehicles-tab.png)

### Drivers

Add or remove drivers from the fleet. Drivers in a fleet inherit the fleet's pricing group when no driver-specific pricing is assigned.

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

### Bulk Reservations

Create and manage batch reservations for fleet vehicles across multiple stations in one go.

#### Create a Bulk Reservation

1. Open the **Bulk Reservations** tab on the fleet detail page.
2. Click **New Bulk Reservation**.
3. Set a name (optional), starts-at, and expires-at.
4. For each station you want to reserve, add a slot:
   - Search for a station (search-as-you-type).
   - Pick a connector from the dropdown that appears once a station is chosen.
   - Optionally assign a driver (search-as-you-type).
5. Click **Add Station** to add more slots, up to 100 per bulk reservation. Stations already chosen in another slot are filtered out so you cannot pick the same one twice.
6. Click **Create**.

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
- **Automatic monthly invoice**: the monthly run invoices the fleet for the previous month and emails the invoice to the billing contacts. See [Monthly Run](https://www.evtivity.com/docs/csms/fleets#monthly-run). It needs at least one billing contact. Without one the CSMS answers `FLEET_BILLING_CONTACT_REQUIRED`.

![Fleet billing profile](https://www.evtivity.com/screenshots/csms/fleet-billing-profile.png)

Changing the profile needs the `fleets:write` permission. Every change is recorded in the fleet history with the fields that changed.

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

The monthly run invoices every fleet with **Automatic monthly invoice** turned on for the previous calendar month. From the **Monthly Fleet Invoice Day** (**Settings** > **Payment** > **General**, 1 to 28, default 1, in the system time zone) to the end of the month, it checks every hour and issues the invoice of each such fleet that has no invoice for that month yet. The invoice is the same as one from **Generate Invoice**, and it is emailed to the billing contacts. A month with nothing to bill issues nothing. A fleet that no longer charges on account still gets its unbilled sessions invoiced. Each month gets its own invoice, which bills only the sessions that ended in that month. If the run missed a month, for example because the worker was down for the whole window, it bills the oldest missed month first and the next month on a later run.

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

#### Monthly Run for Members

With **Automatic monthly invoice** on, the monthly run also issues the member invoices of the previous month, one for each driver with sessions to bill, and sends each to its driver. It follows the same rules as the fleet invoice: one invoice per driver and month, the oldest missed month first, and no new invoice for a month that was credited. A member invoice the run could not finish appears in the same `fleet.InvoiceRunFailed` notice, with the fleet and the driver.

### Deleting a Fleet

**Delete** asks for confirmation. When the CSMS refuses the delete, the dialog shows why.

The CSMS refuses to delete a fleet with sessions billed to it and answers `FLEET_HAS_OPEN_BILLING`. Turn off charge on account instead.

The CSMS also refuses to delete a fleet that has bulk reservations, in any status and cancelled ones included, and answers `FLEET_HAS_RESERVATIONS`. They stay as the fleet's history.

### Notifications

Drivers receive `fleet.AccountBillingChanged` when their billing changes: when the fleet turns charge on account on or off, when it changes who receives the invoices, when they opt out or back in, and when they join or leave a fleet that bills on account. The session receipt of an account session names the fleet and says that no card was charged. For a session invoiced to the driver, it says that the session is invoiced to the driver monthly via the fleet.
