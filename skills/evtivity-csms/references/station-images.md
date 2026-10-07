Generated from https://www.evtivity.com/docs/csms/station-images (website commit ffa3c26). Do not edit.

# Station Images

Upload, tag, and manage photos for each charging station.

## Overview

Station images allow operators to upload, tag, and manage photos for each station. Access this feature from the **Images** tab on the Station Detail page.

![Station images tab](https://www.evtivity.com/screenshots/csms/station-images-tab.png)

## Features

### Upload

Upload images via presigned S3 URLs. Maximum file size is 10MB per image.

### Main Image

Set one image as the main image. The main image displays in the station header across the CSMS.

### Tags and Captions

Add tags and captions to organize images. Tags help filter and categorize photos across stations.

### Driver Visibility

Mark images as driver-visible to show them on the Portal Location Detail page. Drivers see these images when browsing station locations.

### Reorder

Reorder images via drag-and-drop or bulk reorder. The display order determines how images appear in the station detail view.

### Full-Screen Viewer

View any image in a full-screen viewer for detailed inspection.

## Storage

Images are stored in S3 with the key format:

```bash
stations/{stationId}/{uuid}-{fileName}
```

This uses the same S3 configuration as support case attachments.
