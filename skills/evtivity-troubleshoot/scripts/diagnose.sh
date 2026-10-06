#!/usr/bin/env bash
# Collect a short, redacted diagnostic report of an EVtivity Docker Compose
# stack: versions, container states, health endpoints, ports held by other
# processes, and the last warning and error log lines of each service.
# Read only: changes nothing. Never prints .env contents beyond a few
# non-secret keys. Passwords, tokens, keys and URL credentials are masked.
#
# Usage: diagnose.sh [--dir <evtivity-csms checkout>] [--host <host>] [--lines <n>]
#   --dir    checkout with docker-compose.yml and an optional .env (default: current directory)
#   --host   host the endpoints are checked on (default: BIND_IP from .env, else localhost)
#   --lines  warning and error lines shown per service (default: 5)
# Env: EVTIVITY_COMPOSE_PROJECT (default: evtivity, the name in docker-compose.yml)
set -uo pipefail

dir="."
host=""
lines=5
while [ $# -gt 0 ]; do
  case "$1" in
    --dir) dir="${2:?--dir needs a path}"; shift 2 ;;
    --host) host="${2:?--host needs a host}"; shift 2 ;;
    --lines) lines="${2:?--lines needs a number}"; shift 2 ;;
    -h | --help) sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$lines" in '' | *[!0-9]*) echo "--lines needs a number" >&2; exit 2 ;; esac

project="${EVTIVITY_COMPOSE_PROJECT:-evtivity}"
scan=400   # log lines read per service
width=240  # longest log line printed

# redact: mask secrets in stdin. Keeps email addresses and hostnames.
redact() {
  sed -E \
    -e 's#([A-Za-z][A-Za-z0-9+.-]*://[^:/@[:space:]"]*):[^@/[:space:]"]+@#\1:***@#g' \
    -e 's#([Bb]earer|[Bb]asic)[[:space:]]+[A-Za-z0-9._~+/=-]+#\1 ***#g' \
    -e 's#eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+#***jwt***#g' \
    -e 's#(sk|rk|pk)_(live|test)_[A-Za-z0-9]+#\1_\2_***#g' \
    -e 's#whsec_[A-Za-z0-9]+#whsec_***#g' \
    -e 's#("?[A-Za-z0-9_.-]*([Pp]ass(word|wd)?|PASS(WORD|WD)?|[Ss]ecret|SECRET|[Tt]oken|TOKEN|[Aa]pi[_-]?[Kk]ey|API[_-]?KEY|[Pp]rivate[_-]?[Kk]ey|PRIVATE[_-]?KEY|[Ee]nc[_-]?[Kk]ey|ENCRYPTION_KEY|[Aa]uthorization|AUTHORIZATION|[Cc]ookie|COOKIE|[Ss]ignature|SIGNATURE|[Hh]mac|HMAC)[A-Za-z0-9_.-]*"?[[:space:]]*[:=][[:space:]]*)("[^"]*"|[^[:space:],;}&"]+)#\1"***"#g' \
    -e 's#-----BEGIN [A-Z ]+-----[^-]*-----END [A-Z ]+-----#***pem***#g'
}

# env_value <name> <default>: the value from <dir>/.env, else the default.
env_value() {
  local value=""
  if [ -f "$dir/.env" ]; then
    value=$(grep -E "^$1=" "$dir/.env" | tail -n 1 | cut -d= -f2- | tr -d '"'"'" || true)
  fi
  echo "${value:-$2}"
}

# http_status <url>: the HTTP status, "open" (accepts connections, no HTTP answer) or "down".
http_status() {
  local code rc=0
  code=$(curl -sk -o /dev/null --max-time 5 -w '%{http_code}' "$1" 2>/dev/null) || rc=$?
  if [ -n "$code" ] && [ "$code" != "000" ]; then
    echo "$code"
  elif [ "$rc" -eq 6 ] || [ "$rc" -eq 7 ]; then
    echo "down"
  else
    echo "open"
  fi
}

echo "# EVtivity diagnostics ($(date -u '+%Y-%m-%dT%H:%M:%SZ'))"

echo "== Environment"
echo "  os: $(uname -sm)"
if ! command -v docker >/dev/null 2>&1; then
  echo "  docker: not installed"
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "  docker: daemon not reachable"
  exit 1
fi
echo "  docker: $(docker version --format '{{.Server.Version}}' 2>/dev/null)"
echo "  compose: $(docker compose version --short 2>/dev/null)"

echo "== Version"
if [ -f "$dir/package.json" ]; then
  pkg=$(grep -m 1 '"version"' "$dir/package.json" | sed -E 's/.*"version": *"([^"]+)".*/\1/')
  echo "  checkout package.json: $pkg"
fi
if command -v git >/dev/null 2>&1 && git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
  echo "  checkout git: $(git -C "$dir" describe --tags --always --dirty 2>/dev/null)"
fi
if [ -z "$host" ]; then
  host=$(env_value BIND_IP localhost)
  if [ "$host" = "0.0.0.0" ]; then host=localhost; fi
fi
api_port=$(env_value API_PORT 7102)
api_version=$(curl -s --max-time 5 "http://$host:$api_port/v1/version" 2>/dev/null || true)
echo "  api /v1/version: ${api_version:-unreachable}"
docker ps -a --filter "label=com.docker.compose.project=$project" \
  --format '  image {{.Label "com.docker.compose.service"}}: {{.Image}}' 2>/dev/null | sort

if [ -f "$dir/.env" ]; then
  echo "== Settings from .env (non-secret keys only)"
  for key in NODE_ENV LOG_LEVEL BIND_IP CSS_MODE SEED_DEMO REGISTRATION_POLICY PAYMENTS_ALLOW_SIMULATED \
    CSMS_PORT PORTAL_PORT API_PORT OCPP_PORT OCPI_PORT CORS_ORIGIN; do
    value=$(env_value "$key" "")
    if [ -n "$value" ]; then echo "  $key=$value"; fi
  done
else
  echo "== Settings: no .env in $dir (Compose defaults apply)"
fi

echo "== Containers (project $project)"
ps_out=$(docker compose -p "$project" ps -a --format '{{.Service}}|{{.State}}|{{.Health}}|{{.ExitCode}}|{{.Status}}' 2>/dev/null | sort)
if [ -z "$ps_out" ]; then
  echo "  no containers found"
else
  while IFS='|' read -r service state health code status; do
    [ -z "$service" ] && continue
    line="  $service: $state"
    [ -n "$health" ] && line="$line ($health)"
    [ "$state" = "exited" ] && line="$line exit $code"
    echo "$line, $status"
  done <<< "$ps_out"
fi

echo "== Endpoints (host $host)"
echo "  csms $(http_status "http://$host:$(env_value CSMS_PORT 7100)/")"
echo "  portal $(http_status "http://$host:$(env_value PORTAL_PORT 7101)/")"
echo "  api /v1/health $(http_status "http://$host:$api_port/v1/health"): $(curl -s --max-time 5 "http://$host:$api_port/v1/health" 2>/dev/null || true)"
echo "  ocpp ws $(http_status "http://$host:$(env_value OCPP_PORT 7103)/") (426 means listening)"
echo "  ocpp wss $(http_status "https://$host:8443/") (open means listening)"

if command -v lsof >/dev/null 2>&1; then
  held=""
  for port in 5433 6379 "$(env_value CSMS_PORT 7100)" "$(env_value PORTAL_PORT 7101)" "$api_port" \
    "$(env_value OCPP_PORT 7103)" 8443 "$(env_value OCPI_PORT 7104)"; do
    owner=$(lsof -nP -iTCP:"$port" -sTCP:LISTEN 2>/dev/null | awk 'NR > 1 { print $1 }' | sort -u | tr '\n' ' ')
    case "$owner" in
      '' | *com.docke* | *docker* | *vpnkit* | *rootlessk*) ;;
      *) held="$held  port $port held by: $owner"$'\n' ;;
    esac
  done
  if [ -n "$held" ]; then
    echo "== Ports held by processes outside Docker"
    printf '%s' "$held"
  fi
fi

echo "== Recent warnings and errors (last $lines per service, from the last $scan log lines)"
pattern='"level":(40|50|60)|"level":"(warn|error|fatal)"|(^|[^A-Za-z])(WARN|WARNING|ERROR|FATAL|Error|error|failed|FAILED|refused|denied)([^A-Za-z]|$)'
while IFS='|' read -r service state _ code _; do
  [ -z "$service" ] && continue
  if [ "$state" = "exited" ] && [ "$code" != "0" ]; then
    out=$(docker compose -p "$project" logs --no-color --no-log-prefix --tail 15 "$service" 2>/dev/null)
    label="last 15 lines (exited $code)"
  else
    out=$(docker compose -p "$project" logs --no-color --no-log-prefix --tail "$scan" "$service" 2>/dev/null |
      grep -E "$pattern" | tail -n "$lines")
    label="warnings and errors"
  fi
  if [ -n "$out" ]; then
    echo "-- $service: $label"
    printf '%s\n' "$out" | redact | cut -c "1-$width" | sed 's/^/  /'
  fi
done <<< "$ps_out"

echo "# end of diagnostics. Review before sharing: redaction is pattern based."
