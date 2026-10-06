Generated from https://www.evtivity.com/docs/guides/user-management (website commit 0f3462e). Do not edit.

# User Management

Roles, permissions, site access control, and API keys in EVtivity CSMS.

## Roles

EVtivity has two built-in roles:

- **Admin** - Full access to all 58 permissions. Can manage users, settings, and billing.
- **Operator** - A subset of permissions scoped to day-to-day operations. Cannot modify system settings or manage other admins.

## Permission Model

Permissions follow the format `resource:action` where action is `read` or `write`. Write permission implies read.

```bash
stations:read     - View station list and details
stations:write    - Create, update, delete stations
sessions:read     - View session data
sessions:write    - Stop sessions, export data
```

The system has 58 total permissions across two categories:

- **19 page resources** - Stations, sessions, dashboard, tariffs, sites, drivers, reservations, support cases, reports, and more.
- **11 settings tab resources** - Organization, billing, notifications, templates, API keys, security, integrations, and more.

## Per-User Permission Customization

After assigning a role, you can customize individual permissions for any user. The role sets the baseline. Toggle specific permissions on or off to tailor access.

## Site Access Control

Site access uses a default-deny model. Users see nothing until granted access.

Two modes:

- **All sites** - A boolean flag (`hasAllSiteAccess`) that grants access to every site, including sites created in the future.
- **Specific site assignments** - Assign individual sites to a user. They only see data for those sites.

Site access controls visibility for: stations, sessions, dashboard metrics, support cases, and reservations.

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
