Generated from https://www.evtivity.com/docs/csms/users (website commit 0f3462e). Do not edit.

# Users

Manage operator users with role-based access control, granular permissions, and site-level access restrictions.

## Overview

The Users page manages operator accounts that access the CSMS dashboard. Each user has a role (admin or operator), a set of granular permissions, and optional site-level access restrictions.

![Users list](https://www.evtivity.com/screenshots/csms/users-list.png)

## Roles

| Role | Default Access |
|------|----------------|
| Admin | All 58 permissions. Full access to every page and setting. |
| Operator | Operational subset. No settings access, no user write permissions. |

Roles provide default permission sets. After creating a user, you can customize their individual permissions.

## Create a User

1. Navigate to **Users** in the sidebar.
2. Click **Create User**.
3. Fill in the user details:

| Field | Description |
|-------|-------------|
| Name | Full name |
| Email | Login email address (must be unique) |
| Mobile | Phone number for SMS notifications (optional) |
| Password | Initial password (user can change it later) |
| Role | Admin or Operator |

![Create user](https://www.evtivity.com/screenshots/csms/users-create.png)

4. Configure **Site Access** (see below).
5. Click **Create**. The role's default permissions are copied to the new user.

## Permissions

EVtivity uses 58 granular permissions in `resource:action` format. Actions are either `read` or `write`. Write permission implies read for the same resource.

### Page Permissions (38)

19 resources with read and write:

| Resource | Controls Access To |
|----------|--------------------|
| dashboard | Dashboard page and stats |
| sites | Site list and detail |
| stations | Station list, detail, and commands |
| sessions | Session list and detail |
| drivers | Driver list and detail |
| tokens | Driver token management |
| fleets | Fleet management |
| pricing | Pricing groups and tariffs |
| reservations | Reservation management |
| support-cases | Support case management |
| notifications | Notification settings, history, and preferences |
| firmware-campaigns | Firmware update campaigns |
| config-templates | Station configuration templates |
| users | User management |
| reports | Reports and sustainability |
| roaming | OCPI roaming management |
| certificates | PnC certificate management |
| conformance | Conformance test runner |
| access-logs | Access log viewing |

### Settings Permissions (20)

11 settings tabs with read and write, controlling access to individual Settings page tabs (e.g., `settings.general:read`, `settings.smtp:write`).

## Customize Permissions

1. Open the user detail page.
2. Open the **Permissions** tab and click **Edit**.
3. Check or uncheck individual permissions.
4. Click **Save**.

![User detail](https://www.evtivity.com/screenshots/csms/user-detail.png)

Users cannot edit their own permissions. Only other admin users can modify a user's permission set.

Operators can manage their SMS notification preferences from the **Notifications** tab on their Profile page.

## Site Access Control

Site access restricts which sites (and their stations, sessions, dashboard data, and support cases) a user can view and manage.

### Access Modes

| Mode | Behavior |
|------|----------|
| All Sites | User sees every site and its resources. No filtering applied. |
| Specific Sites | User sees only assigned sites. All related data (stations, sessions, dashboard stats) is filtered to those sites. |

New users default to no site access (`hasAllSiteAccess = false` with no site assignments), meaning they see nothing until access is granted.

### Configure Site Access

1. On the user create or detail page, find the **Site Access** section.
2. Toggle **All sites** for unrestricted access, or leave it off and select specific sites from the multi-select picker.
3. Save.

### What Gets Filtered

When a user has specific site access, these resources are filtered:

- Sites, stations, sessions, reservations
- Dashboard stats, charts, and map data
- Support cases linked to stations at those sites
- Load management, firmware campaigns, and config template targets
- Station images, local auth lists, display messages, and OCPP commands

Resources not filtered by site access: drivers, tokens, fleets, pricing, tariffs, notification settings, system settings, and roaming data.

## API Keys

API keys authenticate programmatic access to the CSMS API. Each key inherits the creating user's permissions and site access.

1. Navigate to **Settings > API Keys**.
2. Click **Create API Key**.
3. Enter a name and optionally restrict to a subset of the creating user's permissions.
4. Copy the generated key. It is shown only once.

API keys use the same permission and site access model as the user who created them. Revoking a user's permissions or site access immediately affects their API keys.
