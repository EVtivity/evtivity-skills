#!/usr/bin/env bash
# Print the state of each EVtivity Docker Compose container and the status of
# each HTTP endpoint, a few lines in total. Read only: changes nothing.
#
# Usage: check-stack.sh [--dir <evtivity-csms checkout>] [--host <host>]
#   --dir   checkout with docker-compose.yml and an optional .env (default: current directory)
#   --host  host the endpoints are checked on (default: BIND_IP from .env, else localhost)
# Env: EVTIVITY_COMPOSE_PROJECT (default: evtivity, the name in docker-compose.yml)
# Exit: 0 every container is up and healthy and the API answers, 1 a container
# failed or is stopped, 3 still starting (health check pending or API not up yet).
set -euo pipefail

dir="."
host=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dir) dir="${2:?--dir needs a path}"; shift 2 ;;
    --host) host="${2:?--host needs a host}"; shift 2 ;;
    -h | --help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

project="${EVTIVITY_COMPOSE_PROJECT:-evtivity}"

# env_value <name> <default>: the value from <dir>/.env, else the default.
env_value() {
  local value=""
  if [ -f "$dir/.env" ]; then
    value=$(grep -E "^$1=" "$dir/.env" | tail -n 1 | cut -d= -f2- | tr -d '"'"'" || true)
  fi
  echo "${value:-$2}"
}

if ! command -v docker >/dev/null 2>&1; then
  echo "docker: not installed"
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "docker: daemon not reachable (start Docker)"
  exit 1
fi

if [ -z "$host" ]; then
  host=$(env_value BIND_IP localhost)
  if [ "$host" = "0.0.0.0" ]; then host=localhost; fi
fi

echo "== Containers (project $project)"
ps_out=$(docker compose -p "$project" ps -a --format '{{.Service}}|{{.State}}|{{.Health}}|{{.ExitCode}}' 2>/dev/null || true)
problems=0
starting=0
if [ -z "$ps_out" ]; then
  echo "no containers found. Start the stack with: docker compose up -d"
  problems=1
else
  while IFS='|' read -r service state health code; do
    [ -z "$service" ] && continue
    line="$service: $state"
    [ -n "$health" ] && line="$line ($health)"
    if [ "$state" = "exited" ]; then
      line="$line exit $code"
      if [ "$service" != "migrate" ] || [ "$code" != "0" ]; then problems=$((problems + 1)); fi
    elif [ "$health" = "unhealthy" ] || [ "$state" = "restarting" ] || [ "$state" = "dead" ]; then
      problems=$((problems + 1))
    elif [ "$health" = "starting" ] || [ "$state" = "created" ]; then
      starting=$((starting + 1))
    fi
    echo "  $line"
  done <<< "$(printf '%s\n' "$ps_out" | sort)"
  if [ "$problems" -gt 0 ]; then echo "  $problems container(s) need attention"; fi
  if [ "$starting" -gt 0 ]; then echo "  $starting container(s) still starting"; fi
fi

# http_status <url>: the HTTP status; "open" when the port accepts connections
# but sends no HTTP answer (the OCPP TLS port); "down" when nothing listens.
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

api_port=$(env_value API_PORT 7102)
echo "== Endpoints (host $host)"
printf '  %-10s %-6s %s\n' \
  csms "$(http_status "http://$host:$(env_value CSMS_PORT 7100)/")" "http://$host:$(env_value CSMS_PORT 7100)" \
  portal "$(http_status "http://$host:$(env_value PORTAL_PORT 7101)/")" "http://$host:$(env_value PORTAL_PORT 7101)" \
  api "$(http_status "http://$host:$api_port/v1/health")" "http://$host:$api_port/v1/health" \
  ocpp "$(http_status "http://$host:$(env_value OCPP_PORT 7103)/")" "ws://$host:$(env_value OCPP_PORT 7103) (426 means listening)" \
  ocpp-tls "$(http_status "https://$host:8443/")" "wss://$host:8443 (open means listening)"
if printf '%s\n' "$ps_out" | grep -q '^ocpi|running'; then
  printf '  %-10s %-6s %s\n' ocpi "$(http_status "http://$host:$(env_value OCPI_PORT 7104)/")" "http://$host:$(env_value OCPI_PORT 7104)"
fi
if printf '%s\n' "$ps_out" | grep -q '^mailpit|running'; then
  printf '  %-10s %-6s %s\n' mailpit "$(http_status "http://$host:$(env_value MAILPIT_PORT 7108)/")" "http://$host:$(env_value MAILPIT_PORT 7108)"
fi

health=$(curl -s --max-time 5 "http://$host:$api_port/v1/health" 2>/dev/null || true)
version=$(curl -s --max-time 5 "http://$host:$api_port/v1/version" 2>/dev/null || true)
if [ -n "$health" ]; then echo "== API health: $health"; fi
if [ -n "$version" ]; then echo "== API version: $version"; fi

if [ "$problems" -gt 0 ]; then exit 1; fi
case "$health" in
  *'"status":"ok"'*) ;;
  *) exit 3 ;;
esac
if [ "$starting" -gt 0 ]; then exit 3; fi
exit 0
