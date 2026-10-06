#!/usr/bin/env bash
# Tests for the release selection of skills/evtivity-getting-started/scripts/setup.sh
# against a scratch CSMS repository. Run: bash scripts/setup-release.test.sh
set -euo pipefail

cd "$(dirname "$0")/.."
root=$(pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

failures=0
check() {
  local name="$1" expected="$2" actual="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL $name: expected '$expected', got '$actual'"
    failures=$((failures + 1))
  fi
}

# A CSMS repository with stable, prerelease and annotated tags.
repo="$scratch/csms"
git init --quiet "$repo"
commit() {
  git -C "$repo" -c user.name=test -c user.email=test@example.com commit --quiet --allow-empty -m "$1"
  git -C "$repo" rev-parse HEAD
}
c38=$(commit one)
git -C "$repo" tag v0.1.38
c39b=$(commit two)
git -C "$repo" tag v0.1.39-beta.1
c39n=$(commit three)
git -C "$repo" tag v0.1.39-nightly.1
c310=$(commit four)
git -C "$repo" -c user.name=test -c user.email=test@example.com tag -a v0.1.310 -m stable
commit five >/dev/null
git -C "$repo" tag v0.2.0-alpha.1

# skill <release> <commit>: a copy of the skill with that metadata.
skill() {
  local dir="$scratch/skill-$1"
  mkdir -p "$dir/scripts"
  cp "$root/skills/evtivity-getting-started/scripts/setup.sh" "$dir/scripts/"
  printf -- '---\nname: evtivity-getting-started\nmetadata:\n  evtivity-release: "%s"\n  evtivity-commit: "%s"\n---\n' "$1" "$2" >"$dir/SKILL.md"
  echo "$dir/scripts/setup.sh"
}
run() {
  EVTIVITY_CSMS_REPO="$repo" bash "$@" --print-release 2>/dev/null || echo "exit $?"
}

check "recorded release" "v0.1.39-beta.1 $c39b" "$(run "$(skill v0.1.39-beta.1 "$c39b")")"
check "recorded stable, annotated tag" "v0.1.310 $c310" "$(run "$(skill v0.1.310 "$c310")")"
check "moved tag is refused" "exit 1" "$(run "$(skill v0.1.39-beta.1 "$c38")")"
check "missing release falls back to latest stable" "v0.1.310 $c310" "$(run "$(skill v0.1.99 "$c38")")"
check "explicit prerelease" "v0.1.39-nightly.1 $c39n" "$(run "$(skill v0.1.99 "$c38")" --tag v0.1.39-nightly.1)"
check "unknown explicit tag" "exit 1" "$(run "$(skill v0.1.39-beta.1 "$c39b")" --tag v9.9.9)"

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "setup release selection: all tests passed"
