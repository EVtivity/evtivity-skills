#!/usr/bin/env bash
# Check out the public EVtivity CSMS at a release tag, verify the tag's commit,
# and generate its OpenAPI spec (packages/api/openapi.json), the source of the
# evtivity-api references and of the API path check.
#
# Usage: scripts/fetch-csms.sh <dir> [<tag> <commit>]
#   <dir>     where to clone (reused when it already holds the commit)
#   <tag>     CSMS release tag (default: metadata evtivity-release of the skills)
#   <commit>  the tag's commit (default: metadata evtivity-commit of the skills)
# Env: EVTIVITY_CSMS_REPO (default: https://github.com/EVtivity/evtivity-csms.git)
# Needs git, Node.js 24 or later and npm. Installs the CSMS dependencies with
# `npm ci --ignore-scripts` and builds only the packages the spec generator imports.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/release-version.sh
. scripts/release-version.sh

dir="${1:?Usage: fetch-csms.sh <dir> [<tag> <commit>]}"
tag="${2:-$(release_skill_metadata evtivity-release)}"
commit="${3:-$(release_skill_metadata evtivity-commit)}"
release_tag_is_valid "$tag" || { echo "Invalid release tag: $tag" >&2; exit 2; }
[[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { echo "Invalid commit: $commit" >&2; exit 2; }

if [ -d "$dir/.git" ] && [ "$(git -C "$dir" rev-parse HEAD)" = "$commit" ] &&
  [ -s "$dir/packages/api/openapi.json" ]; then
  echo "$dir is at $tag ($commit) with its OpenAPI spec."
  exit 0
fi
if [ -e "$dir" ]; then
  echo "$dir exists and is not a prepared checkout of $tag. Remove it or pass another directory." >&2
  exit 1
fi

git clone --quiet --depth 1 --branch "$tag" -c advice.detachedHead=false "$RELEASE_CSMS_REPO" "$dir"
actual=$(git -C "$dir" rev-parse HEAD)
if [ "$actual" != "$commit" ]; then
  echo "Tag $tag is at $actual, not the recorded commit $commit. Stop." >&2
  exit 1
fi

(
  cd "$dir"
  npm ci --no-audit --no-fund --loglevel=error --ignore-scripts
  npx tsc -b packages/ocpp packages/api
  npm run generate:openapi --silent
)
test -s "$dir/packages/api/openapi.json"
echo "$dir is at $tag ($commit). Spec: $dir/packages/api/openapi.json"
