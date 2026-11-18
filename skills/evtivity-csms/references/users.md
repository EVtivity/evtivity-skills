Generated from https://www.evtivity.com/docs/csms/users. Do not edit.

# Users

Manage operator users with role-based access control, granular permissions, and site-level access restrictions.

## Overview

The Users page manages operator accounts that access the CSMS dashboard. Each user has a role (admin, operator, viewer, or fleet manager), a set of granular permissions, and an access: every site, specific sites, or specific fleets.

![Users list](https://www.evtivity.com/screenshots/csms/users-list.png)

## Roles

| Role | Default Access |
|------|----------------|
| Admin | All 82 permissions. Full access to every page and setting. |
| Operator | Operational subset. No settings access, no user write permissions. |
| Viewer | Read-only access. |
| Fleet Manager | The permissions of a fleet user: view fleets, sessions, and payments, manage fleet RFID cards, and manage its own API keys. See [Fleet Users](#fleet-users). |

Roles provide default permission sets. After creating a user, you can customize their individual permissions.

## Create a User

1. Navigate to **Users** in the sidebar.
2. Click **Create User**.
3. Fill in the user details:

| Field | Description |
|-------|-------------|
| First Name | Required |
| Last Name | Required |
| Email | Login email address (must be unique) |
| Mobile | Phone number for SMS notifications (optional) |
| Role | Admin, Operator, Viewer, or Fleet Manager |
| Avatar | Optional. **Edit Avatar** opens the avatar editor. The avatar is saved right after the user is created. |

![Create user](https://www.evtivity.com/screenshots/csms/users-create.png)

4. Set **Access** (see below): **All sites**, **Sites** with at least one site, or **Fleets** for a [fleet user](#fleet-users). With **Sites** and no site checked, **Create** shows "At least one site must be selected".

![Site access required](https://www.evtivity.com/screenshots/csms/users-create-site-required.png)
5. Click **Create**. The role's default permissions are copied to the new user. EVtivity emails the user an invitation with a link to set a password. The link expires after 24 hours.

## Permissions

EVtivity uses 82 granular permissions in `resource:action` format. Actions are either `read` or `write`. Write permission implies read for the same resource.

### Page Permissions (60)

30 resources with read and write:

| Resource | Controls Access To |
|----------|--------------------|
| dashboard | Dashboard page and stats |
| stations | Station list, detail, and commands |
| sims | SIM list and SIM pages |
| paymentTerminals | Payment terminals and their payments |
| sites | Site list and detail |
| sessions | Session list and detail |
| drivers | Driver list, detail, and driver tokens |
| fleets | Fleet management |
| fleetCards | RFID cards a fleet owns |
| reservations | Reservation management |
| support | Support case management |
| payments | Payments and invoices |
| pricing | Pricing groups and tariffs |
| roaming | OCPI roaming management |
| smartCharging | Smart charging profiles |
| loadManagement | Load management |
| certificates | PnC certificate management |
| conformance | Conformance test runner |
| reports | Reports |
| sustainability | Sustainability and carbon data |
| notifications | Notification settings, history, and preferences |
| logs | Access and worker logs |
| securityEvents | Security events the stations report |
| users | User management |
| audit | Audit log |
| maintenance | Maintenance windows |
| aiAssistant | The AI assistant: read your own conversations (read), chat (write) |
| aiInsights | AI insights and their suggested actions |
| aiUsage | AI usage and cost |
| aiMcp | The MCP server for AI clients |

### Settings Permissions (22)

11 settings tabs with read and write, controlling access to individual Settings page tabs (e.g., `settings.system:read`, `settings.notification:write`).

## Customize Permissions

1. Open the user detail page.
2. Open the **Permissions** tab and click **Edit**.
3. Check or uncheck individual permissions.
4. Click **Save**.

![User detail](https://www.evtivity.com/screenshots/csms/user-detail.png)

Users cannot edit their own permissions. Another user with the `users:write` permission can change them, but only within the permissions it holds itself (see [Manage Other Users](#manage-other-users)).

Operators can manage their SMS notification preferences from the **Notifications** tab of their [Profile](https://www.evtivity.com/docs/csms/profile).

## Avatars

The Users list and each user page show the user's avatar, or initials when the user has none. Each user sets their own avatar on their [Profile](https://www.evtivity.com/docs/csms/profile#avatar).

A user with the `users:write` permission can also set or remove another user's avatar: open the user, click **Edit** on the **Details** tab, and click **Edit Avatar** in the form. The change is saved at once, apart from the form's **Save**, and recorded in the user's **History**. A site-restricted user changes only the avatars of users they may manage. Without `users:write`, avatars are read-only. The avatar editor works as on the [Profile](https://www.evtivity.com/docs/csms/profile#avatar) page. The API is `PUT` and `DELETE /v1/users/:id/avatar`, with `POST /v1/users/:id/avatar/upload-url` and `POST /v1/users/:id/avatar/image` for an upload.

## Security Tab

The **Security** tab of a user page shows the user's second factor and API keys. It appears only when you hold every permission of that user. Changes need the `users:write` permission.

![User detail, Security tab](https://www.evtivity.com/screenshots/csms/user-detail-security.png)

- **Multi-Factor Authentication** - shows whether the user signs in with a second factor. **Reset MFA** turns the second factor off, removes the user's passkeys and recovery codes, and signs the user out everywhere, after a confirmation. API keys keep working. The user then signs in with the password alone and can set up MFA again. When [Require MFA](https://www.evtivity.com/docs/csms/settings#mfa) covers the user's role, the user sets up MFA at the next sign-in. The user gets a security notice by email. You confirm it is you before the reset, with your own second factor, or your password when you have none.
- **API Keys** - lists the user's active API keys with their name, key suffix, created, last used, and expiry dates. **Revoke** ends a key the user no longer needs or that may have leaked, after a confirmation.

## Your Own Account

Opening your own user opens your [Profile](https://www.evtivity.com/docs/csms/profile). You cannot reset your own MFA or change your own role, status, site access or permissions. Your own email and phone number never change on the Users page: change your phone number on your Profile, and ask another admin to change your email address.

## Sessions and Sign-In

- Signing out ends the session at once. A password change, an MFA change, a role or permission change, and deactivation also end every session of the user at once.
- Deactivating or deleting a user also revokes the user's API keys and every emailed link (invitation and password reset).
- A password reset link works once.
- Repeated failed sign-ins lock the account for a growing delay: 30 seconds after 5 failures in a row, doubling with each further failure up to 15 minutes. Repeated wrong MFA codes lock the same way. A successful sign-in resets the count.
- MFA codes can be resent at most 5 times in 15 minutes.
- With [Single Sign-On](https://www.evtivity.com/docs/csms/settings#single-sign-on) enabled, accounts created through SSO have no password. They cannot sign in with a password, reset it, or change it.

## Site Access Control

Site access decides which sites a user can view and manage, along with everything at those sites.

### Access Modes

| Mode | Behavior |
|------|----------|
| All sites | User sees every site, including future ones, and every company-wide feature. |
| Specific sites | User sees only its assigned sites. This user is site-restricted. |
| Fleets | User sees only its assigned fleets and no site. This user is a fleet user. See [Fleet Users](#fleet-users). |

A user with **Sites** access needs at least one site. The create form and the user page refuse it without one.

### Configure Site Access

1. On the user create or detail page, find the **Access** field.
2. Choose **All sites** for unrestricted access, or **Sites** and check the sites the user may see.
3. Save.

The **Access** column of the Users list shows **All sites**, the number of sites, or the number of fleets of each user.

### What a Site-Restricted User Sees

A site-restricted user sees only data from its assigned sites:

- Sites, stations, sessions, transactions, and reservations
- Dashboard stats, charts, and map data
- Payments and session invoices for sessions at those sites
- Reports
- Support cases for stations or sessions at those sites
- Audit log rows for those sites and their stations, sessions, and reservations
- Load management, firmware campaigns, config templates, and smart charging templates that target those sites
- Station images, local auth lists, display messages, and OCPP commands
- Roaming locations, sessions, and CDRs at those sites
- Simulator stations at those sites
- SIMs with a confirmed attachment to a station of those sites, with their data from those periods only

Stations without a site are visible only to users with all-site access. A site-restricted user cannot create a station without a site or remove a station from its site. A simulator station it creates must name one of its sites.

Config and smart charging templates without a site target every site. A site-restricted user can view them but cannot edit, duplicate, push, or delete them.

Drivers, tokens, fleets, vendors, and roles are company-wide records. Every user with the permission sees them. Their sessions, reservations, and fleet stations show only the user's sites.

### Company-Wide Features

These features span every site and need all-site access:

- System settings: the **Company Info**, **Marketing**, **Content**, **Notification**, **Sustainability**, **Integrations & Features**, **Security**, **AI**, and **History** tabs of [Settings](https://www.evtivity.com/docs/csms/settings), and every change to a system setting
- The **System Information** dialog and the response cache flush
- Payment provider settings (provider, Stripe, and Adyen) and payment reconciliation
- Plug and Charge settings and trust store changes: provider settings, the local CA, CA certificate upload and delete, and the root certificate refresh
- Driver and fleet invoices
- Fleet billing and credit limits
- Changes to pricing groups, tariffs, and holidays, pricing group assignments of drivers and fleets, and the pricing audit
- Notification log, notification settings, notification templates, and test notifications
- Alert rules and station message templates
- Conformance runs
- Roaming partners and tariffs
- Access and worker logs
- Creating sites
- Importing, attaching, confirming, deactivating, reactivating, and deleting SIMs, and SIMs without a confirmed attachment to a station of the user's sites

A site-restricted user keeps the **Payment** (site configurations only), **API Keys**, **Firmware Campaign**, **Station Configurations**, **Smart Charging**, and **Conformance** tabs. With the permission to read system settings, the **Payment** tab also shows three company-wide settings read-only: **Low Credit Notice Threshold**, **Payment Terms (days)**, and **Monthly Fleet Invoice Day**. A notice says that only users with access to all sites can change them.

The dashboard hides these controls from a site-restricted user. A page opened by its address shows **Access to every site required** or returns to an allowed page. The API answers these requests as if the item does not exist (404). Users with the read permission can still view pricing groups, tariffs, holidays, and notification templates.

### Reports

Each report and schedule stores the site scope of the user who created it:

- A report created by a user with all-site access covers every site, including stations without a site.
- A report created by a site-restricted user covers only stations at its sites. Stations without a site are left out. A site or station filter outside its sites returns 404.
- A site-restricted user sees, downloads, and manages only reports and schedules whose scope lies within its own sites. Reports and schedules of all-site users stay hidden from it.
- A scheduled report runs with the current access of the user who created it. It covers the stored scope narrowed to that user's current sites. When that user is inactive, deleted, or lost the permission to read reports, the run is skipped until the access returns.

### Manage Other Users

Every user can grant only the permissions it holds itself, directly or through its role's defaults. This applies to the **Permissions** tab and to the role of a new or edited user. A grant above your own permissions returns 403 `PERMISSIONS_EXCEED_OWN`.

A site-restricted user also has these limits:

- It sees and manages only users whose sites are all within its own sites.
- It cannot see or manage users with all-site access or users without a site.
- It cannot grant all-site access. The **All sites** option is hidden.
- It cannot see, create, or manage fleet users.
- It can assign only its own sites. The site picker lists only those sites.
- It cannot leave a user without a site. A new or edited user needs at least one site, and the form shows **At least one site must be selected**.

## Fleet Users

A fleet user is a CSMS user who manages one or more fleets, for example the fleet manager of a company whose drivers charge at your stations. It sees only its assigned fleets and no site, station, driver, or setting outside them.

### Create a Fleet User

Only a user with access to all sites creates or edits fleet users, and only while **Enable Fleet** is on (see [Fleet](https://www.evtivity.com/docs/csms/settings#fleet)).

1. Click **Create User** on the **Users** page, or open a user and click **Edit** on the **Details** tab.
2. Choose the **Fleet Manager** role. This sets **Access** to **Fleets**.
3. Search for each fleet the user manages and add it to the list. Remove a fleet with its remove button.
4. Click **Create** or **Save**.

Creating a fleet user asks you to confirm it's you (your password or a second factor), because the **Fleet Manager** role can create API keys. The new user gets the fleet manager invitation email with a link to set the password; **Resend Invite** sends a new one. See [Set Up a Fleet Manager](https://www.evtivity.com/docs/guides/fleet-manager-setup).

The **Fleet Manager** role holds every permission a fleet user can have:

| Permission | Allows |
|------------|--------|
| `fleets:read` | View the assigned fleets |
| `sessions:read` | View the sessions billed to the fleet |
| `payments:read` | View session costs, fleet invoices, and the credit limit |
| `fleetCards:read`, `fleetCards:write` | View and manage the fleet's RFID cards |
| `settings.apiKeys:read`, `settings.apiKeys:write` | View, create, and revoke its own API keys |

A fleet user cannot hold any other permission. The **Permissions** tab offers only these, and the CSMS refuses any other with `FLEET_USER_PERMISSION_NOT_ALLOWED`. Remove `payments:read` to hide costs and invoices from a fleet user.

The **Users** list names each fleet user's fleets in the **Access** column. Filter it by **Access** to show only fleet users or only site users. A fleet's **Fleet Managers** tab lists its fleet users (see [Fleet Managers](https://www.evtivity.com/docs/csms/fleets#fleet-managers)).

SSO never creates a fleet user: the **Fleet Manager** role is not offered as the default role of users SSO creates, and the CSMS refuses it there.

### What a Fleet User Sees

The sidebar shows only **Dashboard**, **Fleets** and **Settings**. A fleet user lands on the Dashboard, which shows only the [fleet cards and charts](https://www.evtivity.com/docs/csms/dashboard#fleets) of its fleets, with the fleet charts shown by default. The Fleets page lists the assigned fleets. On each fleet the user sees these tabs, all read-only except **RFID Cards**:

- **Details** - the fleet name and description. The fleet cannot be edited or deleted.
- **Sessions** - the sessions billed to the fleet account, at every site. Clicking a session shows its details, with the label of the fleet RFID card it used. Costs show only with `payments:read`.
- **Vehicles** - the fleet's vehicles, without their VIN.
- **Drivers** - the names of the fleet members, without contact details.
- **Billing** - with `payments:read`, the preview of the next fleet invoice, the fleet invoices and their credit notes, and the credit limit. No billing setting can be changed.
- **RFID Cards** - the fleet's RFID cards. See [RFID Cards](https://www.evtivity.com/docs/csms/fleets#rfid-cards).

**Settings** shows only the **API Keys** tab.

While **Enable Fleet** is off, a fleet user sees one page saying "Fleet management is turned off. Contact your operator." on every page except its profile, and the API answers it `FLEET_DISABLED`. Its pages come back once **Enable Fleet** is on again.

A fleet user with no fleet left, because its fleet was deleted, its last fleet was removed, or it was created without one, sees one page saying "No fleets are assigned to you. Contact your operator." and keeps its profile and API keys. The API answers its fleet requests `FLEET_USER_NO_FLEETS`. Its pages come back once a fleet is assigned.

Fleet users see when and where their fleet's members charged. Inform your fleet members of this as your local privacy law requires.

### Fleet User API Keys

A fleet user creates and revokes its own API keys under **Settings** > **API Keys**. Each key carries the fleet user's fleets and can hold only the permissions above, so a key reaches the same fleets and data as the fleet user and nothing more.

## API Keys

API keys authenticate programmatic access to the CSMS API. Each key inherits the creating user's permissions and site access.

1. Navigate to **Settings > API Keys**.
2. Click **Create API Key**.
3. Enter a name and optionally restrict to a subset of the creating user's permissions.
4. Copy the generated key. It is shown only once.

API keys use the same permission and site access model as the user who created them. Revoking a user's permissions or site access immediately affects their API keys.

API keys cannot use the account routes of the signed-in user: profile, password, MFA, notification preferences, and personal AI configuration. These answer 403 `SESSION_REQUIRED`.

Creating a key, or widening the permissions of a key, asks you to confirm first with a code of your current second factor or a passkey, else your current password. See [API Keys](https://www.evtivity.com/docs/csms/settings#api-keys).
