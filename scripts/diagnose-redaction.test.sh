#!/usr/bin/env bash
# Tests for the redaction of skills/evtivity-troubleshoot/scripts/diagnose.sh.
# Run: bash scripts/diagnose-redaction.test.sh
set -euo pipefail

cd "$(dirname "$0")/.."
diagnose=skills/evtivity-troubleshoot/scripts/diagnose.sh

failures=0
# masked <name> <input> <secret> [flags]: the secret must not survive redaction.
masked() {
  local name="$1" input="$2" secret="$3" out
  shift 3
  out=$(printf '%s\n' "$input" | bash "$diagnose" --redact "$@")
  if [ -z "$out" ] || [[ "$out" == *"$secret"* ]]; then
    echo "FAIL $name: '$secret' survived in: $out"
    failures=$((failures + 1))
  fi
}
# kept <name> <input> <text> [flags]: the text must survive redaction.
kept() {
  local name="$1" input="$2" text="$3" out
  shift 3
  out=$(printf '%s\n' "$input" | bash "$diagnose" --redact "$@")
  if [[ "$out" != *"$text"* ]]; then
    echo "FAIL $name: '$text' lost in: $out"
    failures=$((failures + 1))
  fi
}

# Secrets.
masked "password key" 'password=hunter2hunter2' hunter2
masked "json secret" '{"secretKey":"s3cr3tvalue"}' s3cr3tvalue
masked "url credentials" 'redis://api:redispass@redis:6379' redispass
masked "bearer" 'Authorization: Bearer abcdef0123456789' abcdef0123456789
masked "jwt" 'token eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJl' eyJzdWIiOiIxIn0
masked "stripe secret" 'key sk_live_51Habcdefghijklmnop' 51Habcdefghijklmnop
masked "stripe webhook" 'whsec_abcdefghijklmnop' abcdefghijklmnop
masked "adyen api key" 'x-api-key AQEyhmfxKonIYxZGw0m/n3Q5qf3VaY9UCJ14XWZE03G/k2NFitRvbe4N1XqH1eHaH2AksaEQjsJ4ZCfw4yzT' AQEyhmfxKonIYxZGw0
masked "adyen api user" 'user ws_123456@Company.AcmeCharging failed' AcmeCharging
masked "adyen client key" 'clientKey test_ABCDEFGHIJKLMNOPQRSTUVWX0123' ABCDEFGHIJKLMNOPQRSTUVWX
masked "rfid idTag" '{"idTag":"04A1B2C3D4E5F6","connectorId":1}' 04A1B2C3D4E5F6
masked "rfid idToken" '{"idToken":{"idToken":"04A1B2C3D4E5F6","type":"ISO14443"}}' 04A1B2C3D4E5F6
masked "single-line pem" 'cert -----BEGIN CERTIFICATE-----MIIBszCCAVmgAwIBAgIU-----END CERTIFICATE----- done' MIIBszCCAVmgAwIBAgIU
# The PEM markers are built at run time so this file holds no literal key block.
dashes='-----'
kind='PRIVATE'" KEY"
begin="${dashes}BEGIN ${kind}${dashes}"
end="${dashes}END ${kind}${dashes}"
masked "multi-line pem" "before"$'\n'"$begin"$'\nFAKEBODYLINEONE\nFAKEBODYLINETWO\n'"$end"$'\nafter' FAKEBODYLINEONE
kept "multi-line pem keeps the rest" "before"$'\n'"$begin"$'\nFAKEBODY\n'"$end"$'\nafter' after
masked "email" 'invite sent to jane.doe@acme-charging.com' jane.doe
masked "email with keep-hosts" 'invite sent to jane.doe@acme-charging.com' jane.doe --keep-hosts

# Hosts and addresses.
masked "ipv4" 'connection from 198.51.100.23 refused' 198.51.100.23
masked "ipv6" 'remote 2001:db8:85a3::8a2e:370:7334 closed' 2001:db8:85a3
masked "hostname" 'connect ECONNREFUSED csms.acme-charging.com:443' acme-charging
masked "url host" 'GET https://ocpp.charge.example-operator.eu/CS-001' example-operator
masked "host key" '{"remoteAddress":"station-17","msg":"auth_failed"}' station-17
kept "loopback v4" 'listening on 127.0.0.1:7102' 127.0.0.1
kept "any address" 'bind 0.0.0.0' 0.0.0.0
kept "loopback v6" 'listening on ::1' ::1
kept "timestamp" '2026-10-06T01:43:12.123Z level error' 01:43:12
kept "version" 'image ghcr.io/evtivity/evtivity-csms/api:0.1.39' ghcr.io/evtivity/evtivity-csms/api:0.1.39
kept "file name" 'at packages/api/src/app.ts:42 index.js' index.js
kept "service host" 'redis://redis:6379 ok' redis:6379
kept "keep-hosts ipv4" 'connection from 198.51.100.23 refused' 198.51.100.23 --keep-hosts
kept "keep-hosts hostname" 'connect csms.acme-charging.com' csms.acme-charging.com --keep-hosts

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "diagnose redaction: all tests passed"
