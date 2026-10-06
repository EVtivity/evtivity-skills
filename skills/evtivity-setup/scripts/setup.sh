#!/usr/bin/env bash
# Stand up a local EVtivity CSMS with Docker Compose, end to end:
# prerequisites, checkout at the matching release tag, npm ci, .env,
# scripts/docker-build.sh (answers piped to its prompts), wait until healthy,
# then print the URLs and the sign-in. Safe to rerun: each step skips work
# that is already done, and existing data is never wiped without --wipe.
#
# Usage: setup.sh [options]
#   --dir <path>     CSMS checkout (default: evtivity-csms next to the skills clone,
#                    else ./evtivity-csms)
#   --tag <tag>      CSMS release tag (default: the tag matching this skill's
#                    evtivity-version, else the newest release of that line,
#                    else the latest stable release)
#   --lan            bind to this machine's LAN IP (default: 127.0.0.1 only)
#   --tools          start pgAdmin, Mailpit and FTP
#   --ocpi           start the OCPI roaming server and simulators
#   --monitoring     start Prometheus, Grafana, Loki and Alloy
#   --demo           load demo data (sets SEED_DEMO=true in a new .env)
#   --wipe           existing install: delete its database and Redis data and reseed
#   --keep-data      existing install: keep its data
#   --timeout <sec>  how long to wait for healthy services (default: 600)
#   --check          only check the prerequisites
# Env: EVTIVITY_COMPOSE_PROJECT (default: evtivity, the name in docker-compose.yml)
# Exit: 0 running and healthy, 1 failed, 2 bad arguments, 4 a decision is needed
set -euo pipefail

REPO_URL="https://github.com/EVtivity/evtivity-csms.git"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
project="${EVTIVITY_COMPOSE_PROJECT:-evtivity}"

dir=""
tag=""
lan="n"
tools="n"
ocpi="n"
monitoring="n"
demo="n"
data=""
timeout=600
check_only="n"
while [ $# -gt 0 ]; do
  case "$1" in
    --dir) dir="${2:?--dir needs a path}"; shift 2 ;;
    --tag) tag="${2:?--tag needs a tag}"; shift 2 ;;
    --lan) lan="y"; shift ;;
    --tools) tools="y"; shift ;;
    --ocpi) ocpi="y"; shift ;;
    --monitoring) monitoring="y"; shift ;;
    --demo) demo="y"; shift ;;
    --wipe) data="wipe"; shift ;;
    --keep-data) data="keep"; shift ;;
    --timeout) timeout="${2:?--timeout needs seconds}"; shift 2 ;;
    --check) check_only="y"; shift ;;
    -h | --help) sed -n '2,27p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$timeout" in '' | *[!0-9]*) echo "--timeout needs seconds" >&2; exit 2 ;; esac

step() { printf '\n== %s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- prerequisites
step "Prerequisites"
missing=()
if ! command -v docker >/dev/null 2>&1; then
  missing+=("Docker: install Docker Desktop or Docker Engine (https://docs.docker.com/get-docker/)")
elif ! docker info >/dev/null 2>&1; then
  missing+=("Docker is installed but the daemon is not running: start Docker")
elif ! docker compose version >/dev/null 2>&1; then
  missing+=("Docker Compose v2 (the 'docker compose' plugin): install or update Docker")
fi
command -v git >/dev/null 2>&1 || missing+=("git")
command -v curl >/dev/null 2>&1 || missing+=("curl")
if command -v node >/dev/null 2>&1; then
  node_major=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)
  if [ "$node_major" -lt 24 ]; then
    missing+=("Node.js 24 or later (found $(node --version)); the database seed runs on the host")
  fi
else
  missing+=("Node.js 24 or later with npm (https://nodejs.org); the database seed runs on the host")
fi
command -v npm >/dev/null 2>&1 || missing+=("npm (ships with Node.js)")
if [ "${#missing[@]}" -gt 0 ]; then
  printf 'Missing:\n'
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi
echo "docker $(docker version --format '{{.Server.Version}}'), compose $(docker compose version --short), node $(node --version), npm $(npm --version), git ok, curl ok"

# Ports the stack publishes. A port held by this project's own containers is fine:
# docker-build.sh stops them before it starts the new ones.
PORTS="5433 6379 7100 7101 7102 7103 7104 8443"
port_conflicts=()
for port in $PORTS; do
  if ! (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then continue; fi
  owners=$(docker ps --filter "publish=$port" --format '{{.Label "com.docker.compose.project"}}' 2>/dev/null | sort -u | tr '\n' ' ')
  case " $owners " in
    *" $project "*) continue ;;
  esac
  holder=""
  if [ -n "${owners// /}" ]; then
    holder="container of compose project ${owners% }"
  elif command -v lsof >/dev/null 2>&1; then
    holder=$(lsof -nP -iTCP:"$port" -sTCP:LISTEN 2>/dev/null | awk 'NR > 1 { print $1 " (pid " $2 ")" }' | sort -u | tr '\n' ' ')
  fi
  port_conflicts+=("$port held by ${holder:-another process}")
done
if [ "${#port_conflicts[@]}" -gt 0 ]; then
  printf 'Ports in use (stop these processes, or change the ports in .env):\n'
  printf '  - %s\n' "${port_conflicts[@]}"
  exit 1
fi
echo "ports $PORTS free"
if [ "$check_only" = "y" ]; then exit 0; fi

# ---------------------------------------------------------------- release tag
# Tag grammar of EVtivity releases: vX.Y.Z or vX.Y.Z-(alpha|beta|nightly)[.N].
TAG_RE='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(alpha|beta|nightly)(\.(0|[1-9][0-9]*))?)?$'

# sort_key <tag>: a key that sorts tags in semver order with `sort -t. -k... -n`.
sort_key() {
  local t="${1#v}" base pre channel num rank
  base="${t%%-*}"
  if [ "$base" = "$t" ]; then
    rank=3
    num=0
  else
    pre="${t#*-}"
    channel="${pre%%.*}"
    num="${pre#"$channel"}"
    num="${num#.}"
    num="${num:-0}"
    case "$channel" in alpha) rank=0 ;; beta) rank=1 ;; nightly) rank=2 ;; esac
  fi
  echo "$base.$rank.$num $1"
}

step "Release"
remote_tags=$(git ls-remote --tags --refs "$REPO_URL" 'v*' 2>/dev/null | sed 's#.*refs/tags/##' | grep -E "$TAG_RE" || true)
[ -n "$remote_tags" ] || fail "cannot list the release tags of $REPO_URL (network?)"
if [ -n "$tag" ]; then
  printf '%s\n' "$remote_tags" | grep -qx "$tag" || fail "tag $tag does not exist in $REPO_URL"
else
  want=$(sed -n 's/^ *evtivity-version: *"\{0,1\}\([0-9.]*\)"\{0,1\} *$/\1/p' "$SKILL_DIR/SKILL.md" | head -n 1)
  sorted=$(printf '%s\n' "$remote_tags" | while read -r t; do sort_key "$t"; done |
    sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -k5,5n | awk '{ print $2 }')
  if [ -n "$want" ] && printf '%s\n' "$sorted" | grep -qx "v$want"; then
    tag="v$want"
  elif [ -n "$want" ] && printf '%s\n' "$sorted" | grep -q "^v$want-"; then
    tag=$(printf '%s\n' "$sorted" | grep "^v$want-" | tail -n 1)
    echo "v$want is not released yet. Using the newest release of that line."
  else
    tag=$(printf '%s\n' "$sorted" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1)
    echo "No release of ${want:-the skill version} found. Using the latest stable release."
  fi
fi
echo "CSMS release: $tag"

# ---------------------------------------------------------------- checkout
if [ -z "$dir" ]; then
  skills_root=$(git -C "$SKILL_DIR" rev-parse --show-toplevel 2>/dev/null || true)
  if [ -n "$skills_root" ] && [ -d "$skills_root/skills/evtivity-setup" ]; then
    dir="$(dirname "$skills_root")/evtivity-csms"
  else
    dir="$PWD/evtivity-csms"
  fi
fi

step "Checkout: $dir"
if [ ! -e "$dir" ]; then
  git clone --quiet --depth 1 --branch "$tag" "$REPO_URL" "$dir" 2>/dev/null ||
    fail "git clone of $tag failed"
  echo "cloned $tag"
else
  if [ ! -f "$dir/docker-compose.yml" ] || ! git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
    fail "$dir exists and is not an EVtivity CSMS checkout. Pass --dir with another path."
  fi
  current=$(git -C "$dir" describe --tags --exact-match 2>/dev/null || true)
  if [ "$current" = "$tag" ]; then
    echo "already at $tag"
  else
    if [ -n "$(git -C "$dir" status --porcelain --untracked-files=no)" ]; then
      fail "$dir has local changes and is at ${current:-a commit without a tag}, not $tag. Commit or discard them, or pass --dir."
    fi
    git -C "$dir" fetch --quiet --depth 1 origin "refs/tags/$tag:refs/tags/$tag" ||
      fail "git fetch of $tag failed"
    git -C "$dir" -c advice.detachedHead=false checkout --quiet "$tag" || fail "git checkout of $tag failed"
    echo "switched from ${current:-another commit} to $tag"
  fi
fi
cd "$dir"

# ---------------------------------------------------------------- npm ci
step "Dependencies"
if [ -f node_modules/.package-lock.json ] && [ ! package-lock.json -nt node_modules/.package-lock.json ]; then
  echo "node_modules up to date"
else
  echo "npm ci (a few minutes on the first run)"
  npm ci --no-audit --no-fund --loglevel=error >/dev/null || fail "npm ci failed. Rerun 'npm ci' in $dir to see why."
  echo "installed"
fi

# ---------------------------------------------------------------- .env
step "Configuration"
if [ -f .env ]; then
  echo ".env exists, left unchanged"
  if [ "$demo" = "y" ] && ! grep -qx 'SEED_DEMO=true' .env; then
    echo "note: --demo only applies to a new .env. Set SEED_DEMO=true in .env yourself to load demo data."
  fi
else
  cp .env.example .env
  if [ "$demo" = "y" ]; then
    sed -i.bak 's/^SEED_DEMO=.*/SEED_DEMO=true/' .env && rm -f .env.bak
  fi
  echo "created .env from .env.example$([ "$demo" = y ] && echo ' with SEED_DEMO=true')"
fi

# env_value <name> [default]: the value from .env, else the default.
env_value() {
  local value
  value=$(grep -E "^$1=" .env 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '"'"'" || true)
  echo "${value:-${2:-}}"
}

# ---------------------------------------------------------------- data decision
if docker volume inspect "${project}_pgdata" >/dev/null 2>&1; then
  case "$data" in
    wipe) wipe="y"; echo "existing install: its data will be deleted and reseeded (--wipe)" ;;
    keep) wipe="n"; echo "existing install: data kept (--keep-data)" ;;
    *)
      echo "An existing EVtivity database (volume ${project}_pgdata) was found."
      echo "Ask the user, then rerun with --keep-data (keep it) or --wipe (delete it and reseed)."
      exit 4
      ;;
  esac
else
  wipe="y"
  echo "fresh install: database will be created and seeded"
fi

# ---------------------------------------------------------------- build and start
bind_ip=$(env_value BIND_IP)
if [ -z "$bind_ip" ]; then
  if [ "$lan" = "y" ]; then
    bind_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null ||
      hostname -I 2>/dev/null | awk '{ print $1 }' || true)
    [ -n "$bind_ip" ] || fail "--lan: no LAN IP found"
  else
    bind_ip="127.0.0.1"
  fi
fi
export BIND_IP="$bind_ip"

# Answer docker-build.sh's prompts in the order the script asks them. With
# BIND_IP set, it skips the LAN question.
answers=""
while IFS= read -r prompt; do
  case "$prompt" in
    *"LAN IP"*) continue ;;
    *"dev tools"*) answers+="$tools"$'\n' ;;
    *"OCPI"*) answers+="$ocpi"$'\n' ;;
    *"monitoring"*) answers+="$monitoring"$'\n' ;;
    *"Restart postgres"* | *"wipes"*) answers+="$wipe"$'\n' ;;
    *) fail "scripts/docker-build.sh asks a question this setup does not know: $prompt" ;;
  esac
done < <(grep -E 'read -r?p' scripts/docker-build.sh | sed -E 's/.*read -r?p "([^"]*)".*/\1/')

log="${TMPDIR:-/tmp}/evtivity-setup-$(date +%Y%m%d-%H%M%S).log"
step "Build and start (log: $log)"
echo "bind $BIND_IP, tools $tools, ocpi $ocpi, monitoring $monitoring, wipe and seed $wipe"
echo "The first build takes several minutes."
if ! printf '%s' "$answers" | ./scripts/docker-build.sh >"$log" 2>&1; then
  echo "scripts/docker-build.sh failed. Last lines of the log:"
  tail -n 25 "$log" | sed 's/^/  /'
  echo "Use the evtivity-troubleshoot skill next."
  exit 1
fi
echo "containers started"

# ---------------------------------------------------------------- wait for healthy
step "Waiting for healthy services (up to ${timeout}s)"
deadline=$(($(date +%s) + timeout))
status=3
while :; do
  set +e
  bash "$SCRIPT_DIR/check-stack.sh" --dir . >/dev/null 2>&1
  status=$?
  set -e
  if [ "$status" -eq 0 ] || [ "$(date +%s)" -ge "$deadline" ]; then break; fi
  # A failed container does not recover by waiting; give it one minute for restarts.
  if [ "$status" -eq 1 ] && [ "$(date +%s)" -ge $((deadline - timeout + 60)) ]; then break; fi
  sleep 5
done
bash "$SCRIPT_DIR/check-stack.sh" --dir . || true
if [ "$status" -ne 0 ]; then
  echo
  echo "The stack is not healthy. Use the evtivity-troubleshoot skill (scripts/diagnose.sh --dir $dir)."
  exit 1
fi

# ---------------------------------------------------------------- done
host="$BIND_IP"
if [ "$host" = "0.0.0.0" ]; then host=localhost; fi
admin_email=$(env_value INITIAL_ADMIN_EMAIL admin@evtivity.local)
admin_password=$(env_value INITIAL_ADMIN_PASSWORD admin123)
driver_email=$(env_value INITIAL_DRIVER_EMAIL driver@evtivity.local)
driver_password=$(env_value INITIAL_DRIVER_PASSWORD driver123)
step "EVtivity $tag is running"
cat <<EOF
Dashboard:  http://$host:$(env_value CSMS_PORT 7100)
Portal:     http://$host:$(env_value PORTAL_PORT 7101)
API:        http://$host:$(env_value API_PORT 7102)  (Swagger UI at /docs)
OCPP:       ws://$host:$(env_value OCPP_PORT 7103)/<stationId>, wss://$host:8443/<stationId>
Checkout:   $dir

Dashboard sign-in: $admin_email / $([ "$admin_password" = admin123 ] && echo admin123 || echo 'INITIAL_ADMIN_PASSWORD in .env')
Portal sign-in:    $driver_email / $([ "$driver_password" = driver123 ] && echo driver123 || echo 'INITIAL_DRIVER_PASSWORD in .env')
Change these passwords before others can reach this host.
EOF
