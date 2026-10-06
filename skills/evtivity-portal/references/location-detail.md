Generated from https://www.evtivity.com/docs/portal/location-detail (website commit 257c8b8). Do not edit.

# Location Detail

View site information, hours, images, directions, and popular times for a charging location.

## Overview

The Location Detail page shows site information for a charging location. This is a public route accessible to both guests and authenticated drivers.

## How to Access

Tap the address line on any of these pages to open the Location Detail page:

- Station Detail page (authenticated flow)
- Guest Landing page (`/charge/:stationId/:evseId`)
- Guest Station Landing page (`/charge/:stationId`)

The back button at the top of the page returns you to the originating charger page. The Portal tracks the source page using a query parameter so the back navigation is accurate.

![Location detail page](https://www.evtivity.com/screenshots/portal/location-detail.png)

## Page Layout

The page is organized top to bottom:

### Site Name and Address

The site name appears as the page heading with the full street address displayed below it with a map pin icon.

### Hours of Operation

Shown when the operator has set hours in the site settings. This is a free-form text field, so the format varies by operator (for example, "Mon-Fri 6am-10pm" or "24/7").

### Charger Count

Displays the total number of chargers at the location and how many are currently available. This gives a quick read on whether the site has open connectors.

### Image Carousel

Horizontal row of thumbnail images. Tap any thumbnail to open a full-screen overlay viewer. Only driver-visible images are shown - operators control which images are visible to drivers in the CSMS site settings.

### Google Map

An embedded Google Map showing the site location with a pin marker. A **Get Directions** button opens Google Maps with the site coordinates as the destination.

The map requires two things from the operator:

1. Latitude and longitude coordinates set on the site in the CSMS
2. A Google Maps API key configured in CSMS settings

If either is missing, the map section does not appear.

### Popular Times

A bar chart showing average charging sessions by hour for each day of the week. Tabs across the top let you switch between days (Mon, Tue, Wed, etc.).

The data is based on historical session records at the site. Hours with more sessions show taller bars. This helps drivers find less busy times to charge and avoid waiting for an available connector.

### Contact Information

Displayed in a card at the bottom of the page when the operator has marked the site contact information as public. If the contact is not set to public, this section does not appear.

## Notes

- All data on this page is set by the operator in the CSMS site settings.
- The page loads without authentication, so guest drivers can view location details before deciding to charge.
- If the site has no images, hours, or coordinates configured, those sections are hidden rather than showing empty placeholders.
