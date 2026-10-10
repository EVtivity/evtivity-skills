Generated from https://www.evtivity.com/docs/csms/users. Do not edit.

# Users

Manage operator users with role-based access control, granular permissions, and site-level access restrictions.

## Overview

The Users page manages operator accounts that access the CSMS dashboard. Each user has a role (admin, operator, or viewer), a set of granular permissions, and optional site-level access restrictions.

![Users list](https://www.evtivity.com/screenshots/csms/users-list.png)

## Roles

| Role | Default Access |
|------|----------------|
| Admin | All 66 permissions. Full access to every page and setting. |
| Operator | Operational subset. No settings access, no user write permissions. |
| Viewer | Read-only access. |

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
| Role | Admin, Operator, or Viewer |

![Create user](https://www.evtivity.com/screenshots/csms/users-create.png)

4. Configure **Site Access** (see below). Every user needs **All sites** or at least one site. **Create** shows "At least one site must be selected" otherwise.

![Site access required](https://www.evtivity.com/screenshots/csms/users-create-site-required.png)
5. Click **Create**. The role's default permissions are copied to the new user. EVtivity emails the user an invitation with a link to set a password. The link expires after 24 hours.

## Permissions

EVtivity uses 66 granular permissions in `resource:action` format. Actions are either `read` or `write`. Write permission implies read for the same resource.

### Page Permissions (44)

22 resources with read and write:

| Resource | Controls Access To |
|----------|--------------------|
| dashboard | Dashboard page and stats |
| stations | Station list, detail, and commands |
| sites | Site list and detail |
| sessions | Session list and detail |
| drivers | Driver list, detail, and driver tokens |
| fleets | Fleet management |
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
| users | User management |
| audit | Audit log |
| maintenance | Maintenance windows |

### Settings Permissions (22)

11 settings tabs with read and write, controlling access to individual Settings page tabs (e.g., `settings.system:read`, `settings.notification:write`).

## Customize Permissions

1. Open the user detail page.
2. Open the **Permissions** tab and click **Edit**.
3. Check or uncheck individual permissions.
4. Click **Save**.

![User detail](https://www.evtivity.com/screenshots/csms/user-detail.png)

Users cannot edit their own permissions. Another user with the `users:write` permission can change them, but only within the permissions it holds itself (see [Manage Other Users](#manage-other-users)).

Operators can manage their SMS notification preferences from the **Notifications** tab on their Profile page.

## Site Access Control

Site access decides which sites a user can view and manage, along with everything at those sites.

### Access Modes

| Mode | Behavior |
|------|----------|
| All sites | User sees every site, including future ones, and every company-wide feature. |
| Specific sites | User sees only its assigned sites. This user is site-restricted. |

Every user has **All sites** or at least one site. The create form and the user page refuse a user without site access.

### Configure Site Access

1. On the user create or detail page, find the **Site Access** section.
2. Turn on **All sites** for unrestricted access, or leave it off and select specific sites from the multi-select picker.
3. Save.

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
- It cannot grant all-site access. The **All sites** toggle is hidden.
- It can assign only its own sites. The site picker lists only those sites.
- It cannot leave a user without a site. A new or edited user needs at least one site, and the form shows **At least one site must be selected**.

## API Keys

API keys authenticate programmatic access to the CSMS API. Each key inherits the creating user's permissions and site access.

1. Navigate to **Settings > API Keys**.
2. Click **Create API Key**.
3. Enter a name and optionally restrict to a subset of the creating user's permissions.
4. Copy the generated key. It is shown only once.

API keys use the same permission and site access model as the user who created them. Revoking a user's permissions or site access immediately affects their API keys.
