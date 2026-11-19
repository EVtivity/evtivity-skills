Generated from https://www.evtivity.com/docs/guides/fleet-manager-setup. Do not edit.

# Set Up a Fleet Manager

Give a fleet customer their own CSMS access, from creating the fleet manager to downloading the first fleet invoice.

A fleet manager is a CSMS user who sees only the fleets assigned to them: when and where the fleet charged, the fleet invoices, and the fleet's RFID cards. This guide sets one up step by step. The operator steps need access to all sites and the `users:write` permission.

## Before You Start

- Turn on **Enable Fleet** (see [Fleet](https://www.evtivity.com/docs/csms/settings#fleet)). While it is off, a fleet manager sees only a page saying fleet management is turned off.
- [Create the fleet](https://www.evtivity.com/docs/csms/fleets#create-a-fleet) and add its members on the **Drivers** tab.
- To bill the fleet for its charging, turn on [charge on account](https://www.evtivity.com/docs/csms/fleets#charge-on-account) on the **Billing** tab, fill in the billing profile, and set a [credit limit](https://www.evtivity.com/docs/csms/fleets#credit-limit) if you want one.

## 1. Add the Fleet's RFID Cards

Open the fleet and select the **RFID Cards** tab. Add cards one at a time with **Add RFID Card**, or many at once with **Import CSV**. Give a card to a member, or leave it with no member so it charges to the fleet account. You can set a **Monthly Limit** on each card (see [Monthly Limit](https://www.evtivity.com/docs/csms/fleets#monthly-limit)). The fleet manager can also do this later.

## 2. Create the Fleet Manager

1. On the fleet, select the **Fleet Managers** tab and click **Add Fleet Manager**. **Create User** opens with the **Fleet Manager** role and the fleet already chosen.
2. Enter the email address and name. Add more fleets if the user manages several.
3. Confirm it's you with your password or a second factor, then click **Create**.

![Create a fleet manager](https://www.evtivity.com/screenshots/csms/fleet-guide-new-manager.png)

The user now shows on the fleet's **Fleet Managers** tab.

![Fleet Managers tab](https://www.evtivity.com/screenshots/csms/fleet-guide-managers-tab.png)

Fleet managers see when and where the fleet's members charged. Inform the members as your local privacy law requires.

## 3. The Invitation Email

The fleet manager receives an invitation email with a link to set the password. The link is valid for 24 hours. When it expires, open the user and click **Resend Invite**. The email lists what a fleet manager can do.

## 4. Sign In and the Dashboard

After setting the password, the fleet manager signs in to the CSMS and lands on the **Dashboard**, which shows the fleet's sessions, energy, and, with the `payments:read` permission, cost and credit limit used. A fleet picker and a date range apply to every card and chart.

![Fleet manager Dashboard](https://www.evtivity.com/screenshots/csms/fleet-guide-dashboard.png)

The **Charging Sessions** card lists the newest sessions billed to the fleet. Click one to see its details.

## 5. Manage RFID Cards

On the fleet's **RFID Cards** tab, the fleet manager adds cards, gives them to members, renames them, turns them off and on, and sets their monthly limits. **History** on a card lists its changes. Only an operator deactivates a card for good.

![RFID Cards tab](https://www.evtivity.com/screenshots/csms/fleet-guide-cards.png)

The **Monthly Limit** field of the edit dialog sets the most a card may cost in a calendar month. **This Month** shows what it spent.

![Monthly limit of an RFID card](https://www.evtivity.com/screenshots/csms/fleet-guide-card-limit.png)

## 6. Follow the Fleet's Charging

The **Sessions** tab lists the sessions billed to the fleet at every site. Filter by member, RFID card, or date, and download the list with **Export CSV**. Click a session for its details.

![Fleet sessions](https://www.evtivity.com/screenshots/csms/fleet-guide-sessions.png)

## 7. Download the First Invoice

Fleet invoices show on the **Billing** tab once they are issued: each month by the monthly run when **Automatic monthly invoice** is on in the billing profile, or when an operator clicks **Generate Invoice**. The tab also shows the credit limit and the sessions not invoiced yet.

![Fleet Billing tab](https://www.evtivity.com/screenshots/csms/fleet-guide-billing.png)

With the **Manage Fleet Billing Profile** permission (`fleetBilling:write`), which you grant on the user's **Permissions** tab, the fleet manager edits the fleet's billing profile on the same tab: invoice contacts, company name and address, VAT ID or tax number, and invoice language. You are notified when the VAT ID changes.

Click an invoice to open it and click **Download** for its PDF.

![Fleet invoice](https://www.evtivity.com/screenshots/csms/fleet-guide-invoice.png)

## What a Fleet Manager Cannot Do

A fleet manager reaches no other page: no stations, sites, drivers, or other fleets, and of the settings only its own API keys (see [Fleet User API Keys](https://www.evtivity.com/docs/csms/users#fleet-user-api-keys)). It never sees RFID card values outside its fleet's RFID Cards tab, payment records, or the members' contact details. See [What a Fleet User Sees](https://www.evtivity.com/docs/csms/users#what-a-fleet-user-sees).
