Generated from https://www.evtivity.com/docs/csms/nevi-compliance (website commit ffa3c26). Do not edit.

# NEVI Compliance

Track station uptime against federal NEVI requirements for compliance reporting.

## Overview

NEVI (National Electric Vehicle Infrastructure) compliance reporting tracks station uptime against federal requirements. Access reports from the **Reports** page.

NEVI requires **97% uptime** for funded stations. The report shows which stations meet this threshold and which do not.

![NEVI compliance report](https://www.evtivity.com/screenshots/csms/nevi-compliance.png)

## Features

### Per-Station Uptime

Uptime is calculated from `port_status_log` data for each station. The formula:

```
uptime = (total_time - excluded_downtime - faulted_time) / (total_time - excluded_downtime) * 100
```

Excluded downtime is subtracted from both the numerator and denominator so that approved maintenance windows do not count against a station's uptime score.

### Excluded Downtime

Operators can manage excluded downtime periods for each station. Common exclusion categories include:

- Scheduled maintenance
- Weather events
- Utility outages
- Other approved reasons

### NEVI Station Data

Track additional station data required for NEVI reporting:

- Connector counts
- Power levels
- Accessibility information

### Export

Export reports for compliance submission. The export includes uptime calculations, excluded downtime records, and station metadata.

## API

API endpoints are available under `/v1/nevi/` for programmatic access:

| Endpoint | Purpose |
|----------|---------|
| NEVI station data CRUD | Create, read, update, and delete station compliance data |
| Excluded downtime management | Add, update, and remove excluded downtime periods |
