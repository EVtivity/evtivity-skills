Generated from https://www.evtivity.com/docs/guides/user-management. Do not edit.

# User Management

Roles, permissions, site access control, and API keys in EVtivity CSMS.

## Roles

EVtivity has three built-in roles:

- **Admin** - Full access to all 66 permissions. Can manage users, settings, and billing.
- **Operator** - A subset of permissions scoped to day-to-day operations. Cannot modify system settings or manage other admins.
- **Viewer** - Read-only access.

## Permission Model

Permissions follow the format `resource:action` where action is `read` or `write`. Write permission implies read.

```bash
stations:read     - View station list and details
stations:write    - Create, update, delete stations
sessions:read     - View session data
sessions:write    - Stop sessions, export data
```

The system has 66 total permissions across two categories:

- **22 page resources** - Stations, sessions, dashboard, tariffs, sites, drivers, reservations, support cases, reports, and more.
- **11 settings tab resources** - System, notifications, payments, integrations, security, API keys, firmware, station configurations, and more.

## Per-User Permission Customization

After assigning a role, you can customize individual permissions for any user. The role sets the baseline. Toggle specific permissions on or off to tailor access.

You can grant only the permissions you hold yourself, directly or through your role's defaults. This also applies to the role you assign. A grant above your own permissions returns 403.

## Site Access Control

Site access uses a default-deny model. Users see nothing until granted access.

Two modes:

- **All sites** - A boolean flag (`hasAllSiteAccess`) that grants access to every site, including sites created in the future, and to company-wide features.
- **Specific site assignments** - Assign individual sites to a user. The user is site-restricted and sees only data for those sites.

A site-restricted user sees only the stations, sessions, reservations, payments, reports, support cases, and audit rows of its sites. Stations without a site are hidden from it.

Company-wide features need all-site access: invoices, fleet billing and credit, payment provider settings and reconciliation, pricing changes, the notification log and settings, alert rules, station message templates, conformance runs, roaming partners and tariffs, access and worker logs, and creating sites. The dashboard hides their controls from a site-restricted user, and the API answers as if the item does not exist (404).

A site-restricted user cannot grant all-site access or assign sites outside its own. It manages only users whose sites are all within its own sites, and it cannot see users with all-site access. See [Users](https://www.evtivity.com/docs/csms/users) for details.

## API Keys

Generate API keys from the Settings page. Each key:

- Belongs to the user who created it.
- Inherits that user's permissions by default.
- Can be scoped to a subset of permissions (never more than the creator has).

Use API keys for integrations, scripts, and external systems that need programmatic access.

## Route Guards

All operator-facing routes enforce permissions via middleware:

```typescript
// Example route guard
app.get('/stations', { preHandler: [authorize('stations:read')] }, handler)
app.post('/stations', { preHandler: [authorize('stations:write')] }, handler)
```

Unauthorized requests return a 403 response. The CSMS frontend hides UI elements the user lacks permission to access, but the API enforces permissions independently.
