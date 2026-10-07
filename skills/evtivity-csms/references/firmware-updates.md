Generated from https://www.evtivity.com/docs/csms/firmware-updates (website commit ffa3c26). Do not edit.

# Firmware Updates

Create firmware update campaigns to roll out new firmware versions to groups of charging stations, and send signed firmware updates.

## Overview

Firmware campaigns let you update charging station firmware across your network. Create a campaign targeting specific stations by site, vendor, or model, then track per-station progress as the update rolls out.

![Firmware campaigns list](https://www.evtivity.com/screenshots/csms/firmware-campaigns.png)

## Campaign Lifecycle

Firmware campaigns follow a draft-to-completion lifecycle:

| Status | Description |
|--------|-------------|
| Draft | Campaign created but not started. You can edit the target filter, the firmware URL, and the signing fields. |
| Active | Campaign started. OCPP `UpdateFirmware` commands sent to matching stations. |
| Completed | All target stations have finished (installed or failed). |
| Cancelled | Campaign stopped before completion. |

## Create a Firmware Campaign

1. Navigate to **Settings** and open the **Firmware Campaign** tab.
2. Click **Create**.
3. Fill in the campaign details:

| Field | Description |
|-------|-------------|
| Name | Descriptive name for the campaign (e.g., "ABB v3.2.1 Rollout") |
| Firmware URL | HTTPS URL where stations download the firmware file |
| Version | Target firmware version string (optional, for tracking) |
| Signing certificate (PEM) | Firmware Signing certificate for a signed update. See [Signed Firmware Updates](#signed-firmware-updates). |
| Firmware signature (base64) | Signature of the firmware file. Set together with the signing certificate. |

Leave both signing fields empty for an unsigned update.

![Create firmware campaign](https://www.evtivity.com/screenshots/csms/firmware-campaigns-create.png)

### Set Target Filter

Define which stations receive the update:

- **Site**: Target all stations at a specific site.
- **Vendor**: Filter by station vendor/manufacturer.
- **Model**: Filter by station model.

Filters can be combined. The matching stations count updates as you change filters.

## Start the Campaign

1. Open the campaign detail page.
2. Review the list of matching stations.
3. Click **Start Campaign**.
4. The system sends OCPP `UpdateFirmware` commands to each matching online station.

The campaign status changes from **Draft** to **Active**.

## Track Progress

Each station in the campaign progresses through these statuses:

| Station Status | Description |
|----------------|-------------|
| Pending | Command not yet sent or awaiting response |
| Downloading | Station is downloading the firmware file |
| Downloaded | Download complete, awaiting installation |
| Installing | Station is installing the firmware |
| Installed | Firmware update completed |
| Failed | Update failed (check error info for details) |

The campaign detail page shows a summary of station statuses and a per-station breakdown. Station status updates arrive via OCPP `FirmwareStatusNotification` messages from the stations.

When all stations reach a terminal state (installed or failed), the campaign status changes to **Completed**.

## Signed Firmware Updates

A signed (secure) firmware update lets the station confirm that the firmware comes from its manufacturer before it installs it. You send the manufacturer's Firmware Signing certificate and the firmware signature with the download URL. The station checks the certificate, downloads the file, verifies the signature, and installs the firmware only when both checks pass.

OCPP 2.1 requires the CSMS to include the signing certificate in every `UpdateFirmware` request (L01.FR.11). Many OCPP 2.1 stations reject an update without it, and the EVtivity simulator does. Get the signing certificate and the signature from your station manufacturer with each firmware release.

### Send a Signed Update

- **Campaign**: fill in **Signing certificate (PEM)** and **Firmware signature (base64)** when you create the campaign, or edit them while the campaign is a draft. The campaign detail page shows **Signature** as **Signed** or **Unsigned**. Every station in the campaign gets the same certificate and signature.
- **Single station**: open the station detail page, go to the **OCPP Commands** tab, and choose **Update Firmware**. Enter the **Firmware Location URL**, the **Retrieve Date/Time**, and the two signing fields.

### OCPP Messages

| OCPP Version | Signed Update | Unsigned Update | Status Reports |
|--------------|---------------|-----------------|----------------|
| 2.1 | `UpdateFirmware` with `firmware.signingCertificate` and `firmware.signature` | `UpdateFirmware` without the signing fields | `FirmwareStatusNotification` |
| 1.6 | `SignedUpdateFirmware` (OCPP 1.6 Security Whitepaper) | `UpdateFirmware` (`location`, `retrieveDate`) | `SignedFirmwareStatusNotification` for a signed update, `FirmwareStatusNotification` for an unsigned one |

You do not pick the message. The CSMS sends `SignedUpdateFirmware` to an OCPP 1.6 station when both signing fields are set, and the plain `UpdateFirmware` when they are empty. The CSMS records the status reports in the station's **Firmware History** tab and in the campaign.

### Certificate and Signature Requirements

The CSMS checks the fields before it sends the update and returns `400 VALIDATION_ERROR` when one fails:

| Field | Requirement |
|-------|-------------|
| Signing certificate | One PEM encoded X.509 certificate (`-----BEGIN CERTIFICATE-----` to `-----END CERTIFICATE-----`) that parses as X.509. At most 5500 characters. |
| Firmware signature | Base64 encoded, at most 800 characters. |
| Both | Set together or both empty. |

The station checks the rest:

- A manufacturer root certificate installed on the station (certificate type `ManufacturerRootCertificate`) must issue the signing certificate. The OCPP specification does not allow intermediate certificates for firmware signing, so the manufacturer root issues the signing certificate directly.
- The signing certificate must be valid (not expired).
- The signature must match the downloaded file and the signing certificate's key.

Stations usually ship with the manufacturer root certificate. To install one on an OCPP 2.1 station, use **Install Certificate** on the station **Certificates** tab (shown when Plug and Charge is enabled) or the `InstallCertificate` command on the **OCPP Commands** tab. For an OCPP 1.6 station, use the API endpoint `POST /v1/ocpp/commands/v16/InstallCertificate`. Without a manufacturer root certificate, a station cannot install signed firmware.

### Signature Failures

| Station Result | Meaning |
|----------------|---------|
| `InvalidCertificate` response | The signing certificate does not chain to an installed manufacturer root, or it expired. The station does not download the firmware and reports the security event `InvalidFirmwareSigningCertificate`. |
| `InvalidSignature` status | The downloaded file does not match the signature. The station does not install it and reports the security event `InvalidFirmwareSignature`. |
| `SignatureVerified` status | The signature is valid. Installation follows. |

An `InvalidSignature` status marks the station faulted, the same as any failed install (see [Considerations](#considerations)).

## Considerations

- Stations must be online to receive the update command. Offline stations show as **Pending**.
- Firmware updates may cause stations to reboot. Active charging sessions could be interrupted.
- While a station installs firmware, its status is unavailable and drivers cannot start charging.
- A failed install (`InstallationFailed`, `InvalidSignature`, or `InstallVerificationFailed`) marks the station faulted. It stays faulted after a reboot. The next install clears it, or an operator clicks **Enable Station** on the station detail page.
- The firmware URL must be accessible from the station's network. The station downloads the file. The CSMS never fetches it.
- Both OCPP 1.6 and 2.1 stations are supported. Command translation handles version differences.
