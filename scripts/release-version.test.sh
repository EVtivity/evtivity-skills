#!/usr/bin/env bash
# Tests for scripts/release-version.sh. Run: bash scripts/release-version.test.sh
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/release-version.sh
. scripts/release-version.sh

failures=0
check() {
  local name="$1" expected="$2" actual="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL $name: expected '$expected', got '$actual'"
    failures=$((failures + 1))
  fi
}
ok() { if "$@"; then echo yes; else echo no; fi; }

for tag in v0.1.39 v0.1.39-alpha v0.1.39-alpha.1 v0.1.39-beta.2 v0.1.39-nightly v0.1.39-nightly.7 v1.0.0 v10.20.30; do
  check "valid $tag" yes "$(ok release_tag_is_valid "$tag")"
done
for tag in 0.1.39 v0.1 v0.1.39-rc.1 v0.1.39-preview v0.1.39+build v01.1.39 v0.1.39-beta.01 v0.1.39-beta. v0.1.39-BETA.1 ''; do
  check "invalid '$tag'" no "$(ok release_tag_is_valid "$tag")"
done

check "prerelease beta" yes "$(ok release_tag_is_prerelease v0.1.39-beta.1)"
check "prerelease stable" no "$(ok release_tag_is_prerelease v0.1.39)"
check "channel stable" stable "$(release_tag_channel v0.1.39)"
check "channel alpha" alpha "$(release_tag_channel v0.1.39-alpha.3)"
check "channel beta" beta "$(release_tag_channel v0.1.39-beta)"
check "channel nightly" nightly "$(release_tag_channel v0.1.39-nightly.1)"
check "base version" 0.1.39 "$(release_base_version v0.1.39-beta.2)"
check "base version stable" 0.1.39 "$(release_base_version v0.1.39)"

check "sort" "v0.1.38 v0.1.39-alpha.1 v0.1.39-alpha.2 v0.1.39-beta v0.1.39-beta.1 v0.1.39-beta.10 v0.1.39-nightly.1 v0.1.39 v0.1.40-alpha.1" \
  "$(release_sort v0.1.39 v0.1.39-beta.10 v0.1.40-alpha.1 v0.1.39-alpha.2 v0.1.38 v0.1.39-nightly.1 v0.1.39-beta.1 v0.1.39-alpha.1 v0.1.39-beta | tr '\n' ' ' | sed 's/ $//')"
check "newer stable over beta" yes "$(ok release_is_newer v0.1.39 v0.1.39-beta.2)"
check "newer beta.10 over beta.9" yes "$(ok release_is_newer v0.1.39-beta.10 v0.1.39-beta.9)"
check "older" no "$(ok release_is_newer v0.1.38 v0.1.39-alpha.1)"
check "equal" no "$(ok release_is_newer v0.1.39 v0.1.39)"

# release_previous_tag against a scratch repository.
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
(
  cd "$scratch"
  git init --quiet
  git -c user.name=test -c user.email=test@example.com commit --quiet --allow-empty -m init
  for t in v0.1.37 v0.1.38-beta.1 v0.1.38-beta.2 v0.1.38 v0.1.39-alpha.1 v0.1.39-beta.1; do git tag "$t"; done
)
prev() { (cd "$scratch" && release_previous_tag "$1"); }
check "previous of first" "" "$(prev v0.1.37)"
check "previous of beta.1" v0.1.37 "$(prev v0.1.38-beta.1)"
check "previous of beta.2" v0.1.38-beta.1 "$(prev v0.1.38-beta.2)"
check "previous of stable" v0.1.37 "$(prev v0.1.38)"
check "previous of alpha after stable" v0.1.38 "$(prev v0.1.39-alpha.1)"
check "previous of beta after alpha" v0.1.39-alpha.1 "$(prev v0.1.39-beta.1)"

# release_csms_tag_commit against the scratch repository: lightweight and annotated tags.
head_commit=$(git -C "$scratch" rev-parse HEAD)
git -C "$scratch" -c user.name=test -c user.email=test@example.com tag -a v0.1.40 -m stable
check "csms tag commit" "$head_commit" "$(EVTIVITY_CSMS_REPO="$scratch" bash scripts/release-version.sh release_csms_tag_commit v0.1.39-beta.1)"
check "csms annotated tag commit" "$head_commit" "$(EVTIVITY_CSMS_REPO="$scratch" bash scripts/release-version.sh release_csms_tag_commit v0.1.40)"
check "csms missing tag" no "$(ok env EVTIVITY_CSMS_REPO="$scratch" bash scripts/release-version.sh release_csms_tag_commit v9.9.9)"

# release_set_source and release_check_source on a copy of the skills.
repo_root=$(pwd)
copy="$scratch/copy"
mkdir -p "$copy"
cp -R skills "$copy/"
cd "$copy"
release_set_source v0.1.40 "$head_commit"
check "source recorded" yes "$(ok release_check_source v0.1.40)"
check "source other tag" no "$(ok release_check_source v0.1.41 2>/dev/null)"
check "source metadata" "$head_commit" "$(release_skill_metadata evtivity-commit)"
check "short commit refused" no "$(ok release_set_source v0.1.40 abc123 2>/dev/null)"
cd "$repo_root"

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "release-version: all tests passed"
