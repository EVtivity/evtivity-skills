Generated from https://www.evtivity.com/docs/portal/account. Do not edit.

# Account Settings

Manage your personal info, security, notification preferences, and favorites.

## Overview

The Account page is the fourth tab in the Portal bottom navigation. It lists a row for each account-related setting. Each row opens its own page.

![Account page](https://www.evtivity.com/screenshots/portal/account.png)

## Personal Info

The Personal Info page holds your profile and display settings.

1. Tap **Personal Info**.
2. Edit any of the following fields:
   - **First name** and **Last name**
   - **Email** (shown only: ask the operator to change it)
   - **Phone** (used for SMS notifications and MFA)
   - **Language** (English, Deutsch, Español, 한국어, 简体中文, or 繁體中文)
   - **Timezone** (affects how timestamps are displayed)
   - **Theme** (Light or Dark)
   - **Distance Unit** (miles or km, affects vehicle range estimates and session summaries)
   - **Show prices** (**Operator default**, **Including tax (gross)**, or **Excluding tax (net)**)
3. Tap **Save** to apply changes. All fields persist in one request, and the language bundle reloads in place if you switched it.

When your account has a second factor, a new phone number needs a proof first: a code of your method or one of your passkeys. When you sign in with SMS codes, also tap **Send Code to New Number** and enter the code from the text message under **Code Sent to the New Number**. The number is saved only once confirmed. The mobile app cannot change the number of such an account and tells you to use the portal.

### Billing Address

The **Billing Address** section on the Personal Info page holds the address printed on the invoices your fleet addresses to you. See [Invoices](https://www.evtivity.com/docs/portal/invoices).

1. Tap **Personal Info**.
2. In **Billing Address**, enter **Name on Invoice**, **Street**, **City**, **State or Region**, **Postal Code**, and **Country**. Leave **Name on Invoice** empty to use your first and last name.
3. Tap **Save** in the section.

When your fleet invoices your sessions to you and you have no billing address yet, the section shows "Your fleet invoices your sessions to you. Add your billing address so it appears on your invoices." Without an address, your invoices show your name and email. The operator can also edit the address, and the mobile app shows the same one.

### Show prices

**Show prices** sets how the Portal shows charger prices and session costs:

- **Including tax (gross)** shows prices with tax added.
- **Excluding tax (net)** shows prices before tax.
- **Operator default** follows the operator's setting and names it, for example "Operator default (Including tax (gross))". New accounts start here.

You pay the same amount either way. The choice changes only how prices are shown. The same choice applies in the mobile app, because it is saved on your account.

## Security

The Security section lets you change your password and manage MFA, passkeys and security keys, and recovery codes.

### Change Password

1. Tap **Security**.
2. Enter your current password.
3. Enter your new password.
4. Tap **Change password**.

### Multi-Factor Authentication

The Security section shows your current MFA status, your passkeys and security keys, and how many recovery codes are left. See [Multi-Factor Authentication](https://www.evtivity.com/docs/portal/registration#multi-factor-authentication-mfa) for setup, recovery codes and disabling MFA, and [Passkeys and Security Keys](https://www.evtivity.com/docs/portal/registration#passkeys-and-security-keys) for passkeys.

## Notification Preferences

Control how you receive notifications from the charging network.

1. Tap **Notifications**.
2. Toggle **Email notifications** on or off.
3. Toggle **SMS notifications** on or off.
4. Tap **Save** to apply changes.

Notification preferences apply to session events (started, completed, idling, payment received) and system events (receipts, support case updates). Language, timezone, theme, and distance unit live under **Personal Info**, not here.

## Invoices

Tap **Invoices** to see your invoices and credit notes and download them as PDFs. See [Invoices](https://www.evtivity.com/docs/portal/invoices).

## Favorites

Save frequently used stations for quick access.

![Favorites page](https://www.evtivity.com/screenshots/portal/favorites.png)

### Add a Favorite

1. Navigate to a station detail page (via search or QR code).
2. Tap **Add to Favorites** above the Report Issue button.
3. A filled star icon appears next to the station ID.

### View Favorites

Tap the star icon in the Portal header (left of the notification bell) to open the Favorites page. The page lists your saved stations with EVSE counts.

### Remove a Favorite

On the Favorites page, tap the remove button on the station you want to unfavorite.

## Notification Bell

The bell icon in the Portal header shows your unread notification count. Tap it to open the notification drawer, which slides up from the bottom of the screen and displays your notification history. Opening the drawer marks all notifications as read.

The unread count refreshes every 60 seconds.

## Sign Out

At the bottom of the Account page, tap **Sign out** to log out of the Portal.

## Notes

- Each row on the Account page opens its own page. Tap the back arrow to return.
- Payment Methods and Support Cases sections link to their respective full pages.
- Language changes take effect immediately across the entire Portal.
