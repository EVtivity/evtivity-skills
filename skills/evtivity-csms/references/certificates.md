Generated from https://www.evtivity.com/docs/csms/certificates. Do not edit.

# Certificates

Manage ISO 15118 Plug and Charge certificates, Mutual TLS station certificates, and PKI provider integration.

## Overview

The Certificates page manages the PKI (Public Key Infrastructure) for ISO 15118 Plug and Charge (PnC) and Mutual TLS station authentication. It provides a central view of CA certificates, station certificates, and certificate signing requests (CSRs).

Plug and Charge is a feature-toggled capability. Enable it in **Settings > Integrations & Features > Plug & Charge** before the Certificates page and related functionality become available.

![Certificates page](https://www.evtivity.com/screenshots/csms/certificates.png)

## Enable Plug and Charge

1. Navigate to **Settings > Integrations & Features**.
2. Open the **Plug & Charge** tab.
3. Toggle **Enable Plug & Charge (ISO 15118)**.
4. Select a PKI provider:

| Provider | Description |
|----------|-------------|
| Hubject | Hubject OPCP API with OAuth2 client credentials. Automated certificate signing via EST protocol. |
| Manual | CSRs are stored as pending. You sign them manually through the UI with your own CA. |
| Local | The CSMS issues ISO 15118 contract certificates from its own contract CA. CSRs are signed manually as with Manual. |

5. If using Hubject, enter the OAuth2 credentials (base URL, client ID, client secret, token URL).
6. Click **Test Connection** to verify provider connectivity.
7. Save settings.

When PnC is disabled, the Certificates nav item is hidden and certificate-related API routes return 403.

## Certificate Tabs

The Certificates page has four tabs. The History tab shows only with the `audit:read` permission.

### CA Certificates

Root and intermediate CA certificates used for certificate chain validation.

- **Upload**: Click **Upload CA Certificate** and paste the PEM-encoded certificate.
- **Delete**: Remove a CA certificate from the system.
- **Refresh from Provider**: Fetch root certificates from the configured PKI provider (Hubject only).

CA certificates include hash fields (issuer name hash, issuer key hash) used for OCSP status lookups.

### Station Certificates

Certificates installed on charging stations for PnC (V2G) or Mutual TLS authentication.

- View certificate details: subject, issuer, serial number, expiration date, and source.
- Track certificate status: active, expiring, or expired.
- Filter by station, certificate type, or expiration status.

### CSR Requests

Certificate signing requests submitted by stations via OCPP `SignCertificate`.

| CSR Status | Description |
|------------|-------------|
| Pending | CSR received, awaiting signing (Manual provider) |
| Submitted | CSR sent to PKI provider for signing (Hubject) |
| Signed | Certificate issued and sent to station |
| Rejected | CSR rejected by operator or provider |
| Expired | CSR timed out without being signed |

For the Manual provider, pending CSRs have a **Sign** button. Paste the signed certificate PEM to complete the signing process.

### History

The audit trail of certificate changes: who uploaded, deleted, signed, or rejected a certificate or CSR, and when. See [Audit Logs](https://www.evtivity.com/docs/guides/audit-logs).

## Local Contract CA

With the **Local** provider the CSMS acts as the contract certificate provisioning service. When an EV asks its charging station for a contract (`Get15118EVCertificate`, ISO 15118-2 install or update, ISO 15118-20 install), the CSMS decodes the EXI request, checks its signature and the vehicle's OEM provisioning certificate, issues a contract certificate, encrypts its private key for the vehicle, and returns the signed EXI response.

1. In **Settings > Integrations & Features > Plug & Charge**, select **Local contract CA**, enter the eMAID country code (2 letters) and provider ID (3 letters or digits), and save.
2. Click **Create contract CA**. The CSMS generates a Mobility Operator chain and a provisioning chain for ISO 15118-2 (secp256r1) and ISO 15118-20 (secp521r1). Private keys are stored encrypted and never shown. A CA is created once.
3. Upload the OEM root certificate of each vehicle make as a CA certificate of type `OEMRootCertificate`. Requests from vehicles whose OEM provisioning certificate does not chain to an installed OEM root are refused.
4. On the driver page, create a **Plug & Charge contract** for the vehicle's PCID (the common name of its OEM provisioning certificate). Each contract gets a new eMAID token.

An ISO 15118-20 vehicle can install several contracts: the CSMS answers each repeated request with the next contract and the number still to come in `remainingContracts`. Revoking a contract deactivates its eMAID and reports its certificates as revoked when a station authorizes with them.

Vehicles verify the response against the V2G root they trust. The local CA suits fleets and testing with vehicles configured to trust its V2G root. For vehicles that trust the public V2G roots, use Hubject.

## OCPP Certificate Operations

### Station-Initiated

| OCPP Message | Description |
|-------------|-------------|
| SignCertificate | Station requests a new certificate. CSR saved and forwarded to the PKI provider. |
| Get15118EVCertificate | Station requests a contract certificate for a driver (PnC only). |
| GetCertificateStatus | Station requests OCSP status for a certificate. |

`SignCertificate` with type `ChargingStationCertificate` works regardless of the PnC toggle. This is the Mutual TLS renewal path. V2G certificate types require PnC to be enabled.

### CSMS-Initiated

| OCPP Command | Description |
|-------------|-------------|
| CertificateSigned | Send a signed certificate back to the station after CSR signing. |
| InstallCertificate | Install a CA certificate on a station. |
| DeleteCertificate | Remove a certificate from a station. |
| GetInstalledCertificateIds | Query which certificates are installed on a station. |

These commands are available from the station detail page **Certificates** tab (visible for OCPP 2.1 stations when PnC is enabled).

![Station Certificates tab](https://www.evtivity.com/screenshots/csms/station-certificates-tab.png)

## Expiration Monitoring

An hourly background task monitors certificate expiration:

1. Certificates within the **critical window** (default 7 days): triggers automatic renewal by sending `TriggerMessage(SignChargingStationCertificate)` to the station.
2. Certificates within the **warning window** (default 30 days): generates an expiration warning event.
3. Expired certificates are marked as expired.

Configure warning and critical thresholds in **Settings > Integrations & Features > Plug & Charge**.

## Mutual TLS Certificates

The Mutual TLS profile uses client certificates for station authentication. These stations present a client certificate instead of a password. The OCPP server validates the client certificate for Mutual TLS stations while allowing No Auth through TLS + Basic Auth stations to connect without one.

Mutual TLS certificate management uses the same `SignCertificate` flow with `ChargingStationCertificate` type. This path is always available and does not require the PnC toggle.

On the station detail page, Mutual TLS stations show a Security Profile badge and hide the password field. Certificate management is done through the Certificates tab.
