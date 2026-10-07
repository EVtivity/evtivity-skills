#!/usr/bin/env bash
# Tests for the --csms checks of scripts/release.sh against scratch repositories:
# a checkout that is not git, at another commit, or without its OpenAPI spec is
# refused before anything is generated. Run: bash scripts/release-csms.test.sh
set -euo pipefail

cd "$(dirname "$0")/.."
root=$(pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

failures=0
check() {
  local name="$1" pattern="$2" output="$3"
  if ! printf '%s\n' "$output" | grep -q -- "$pattern"; then
    echo "FAIL $name: expected '$pattern', got:"
    printf '%s\n' "$output" | sed 's/^/  /'
    failures=$((failures + 1))
  fi
}
gitc() { git -c user.name=test -c user.email=test@example.com "$@"; }

# A CSMS repository with the release tag one commit behind its head.
csms="$scratch/csms"
git init --quiet "$csms"
gitc -C "$csms" commit --quiet --allow-empty -m one
tagged=$(git -C "$csms" rev-parse HEAD)
git -C "$csms" tag v9.9.9
gitc -C "$csms" commit --quiet --allow-empty -m two
export EVTIVITY_CSMS_REPO="$csms"

# A skills repository on main with no origin, holding only the release scripts.
skills="$scratch/skills"
git init --quiet -b main "$skills"
mkdir -p "$skills/scripts"
cp "$root/scripts/release.sh" "$root/scripts/release-version.sh" "$skills/scripts/"
git -C "$skills" add scripts
gitc -C "$skills" commit --quiet -m scripts

run() { bash "$skills/scripts/release.sh" v9.9.9 --website "$scratch/no-website" --csms "$1" 2>&1 || true; }

check "not a checkout" "is not a git checkout" "$(run "$scratch/missing")"

at_head="$scratch/at-head"
git clone --quiet "$csms" "$at_head"
check "other commit" "is at $(git -C "$at_head" rev-parse HEAD), not CSMS v9.9.9 ($tagged)" "$(run "$at_head")"

at_tag="$scratch/at-tag"
git clone --quiet -c advice.detachedHead=false --branch v9.9.9 "$csms" "$at_tag"
check "no spec" "has no OpenAPI spec" "$(run "$at_tag")"

# A prepared checkout passes the checks and the release goes on to the website step.
mkdir -p "$at_tag/packages/api"
echo '{}' > "$at_tag/packages/api/openapi.json"
check "prepared checkout" "Website checkout not found" "$(run "$at_tag")"

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "release --csms tests passed"
