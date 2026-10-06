#!/usr/bin/env bash
# Cut a release of the EVtivity skills. The tag matches the EVtivity CSMS
# release the skills target.
#
# Usage: scripts/release.sh <tag> [--push] [--website <dir>] [--website-ref <ref>]
#   <tag>          vX.Y.Z (stable) or vX.Y.Z-alpha[.N], -beta[.N], -nightly[.N]
#   --push         push main and the tag to origin (the Release workflow then
#                  creates the GitHub release). Without it, nothing leaves this machine.
#   --website      checkout of the website repository (default: ../evtivity.com)
#   --website-ref  website ref the references are generated from (default: origin/main)
#
# Steps: validate the tag, require a clean main that matches origin/main,
# resolve the commit of the CSMS release tag, regenerate the references from
# the website docs at the ref, set `evtivity-version` (X.Y.Z),
# `evtivity-release` (the tag) and `evtivity-commit` (the CSMS commit) in every
# SKILL.md, regenerate the API references from the CSMS at that commit, copy
# the descriptions into the manifests, validate the skills, commit
# (`release: version X.Y.Z` for stable, `release: prepare X.Y.Z` for a
# prerelease) when anything changed, and create the tag.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/release-version.sh
. scripts/release-version.sh

tag=""
push="n"
website="../evtivity.com"
website_ref="origin/main"
while [ $# -gt 0 ]; do
  case "$1" in
    --push) push="y"; shift ;;
    --website) website="${2:?--website needs a path}"; shift 2 ;;
    --website-ref) website_ref="${2:?--website-ref needs a ref}"; shift 2 ;;
    -h | --help) sed -n '2,19p' "$0"; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; exit 2 ;;
    *)
      if [ -n "$tag" ]; then echo "Only one tag, got $tag and $1" >&2; exit 2; fi
      tag="$1"
      shift
      ;;
  esac
done
if [ -z "$tag" ]; then
  sed -n '5,10p' "$0" >&2
  exit 2
fi
if ! release_tag_is_valid "$tag"; then
  echo "Invalid tag: $tag. Use vX.Y.Z or vX.Y.Z-(alpha|beta|nightly)[.N]. rc, preview and build metadata are not used." >&2
  exit 2
fi

branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" != "main" ]; then
  echo "Release from main (current branch: $branch)." >&2
  exit 1
fi
if [ -n "$(git status --porcelain)" ]; then
  echo "The working tree is not clean. Commit or stash first." >&2
  exit 1
fi
if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  echo "Tag $tag already exists." >&2
  exit 1
fi
if git remote get-url origin >/dev/null 2>&1; then
  git fetch --quiet --tags origin main
  if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
    echo "main differs from origin/main. Pull or push first." >&2
    exit 1
  fi
  if git ls-remote --exit-code --tags origin "refs/tags/$tag" >/dev/null 2>&1; then
    echo "Tag $tag already exists on origin." >&2
    exit 1
  fi
fi
latest=$(git -c versionsort.suffix=- tag -l 'v*' --sort=-v:refname | grep -E "$RELEASE_TAG_RE" | sed -n '1p' || true)
if [ -n "$latest" ] && ! release_is_newer "$tag" "$latest"; then
  echo "Warning: $tag is not newer than the latest tag $latest (hotfix of an older line?)." >&2
fi

version=$(release_base_version "$tag")
# The skills record the exact CSMS release they target: its tag and commit.
# The CSMS release must exist before the skills release.
if ! csms_commit=$(release_csms_tag_commit "$tag"); then
  echo "The CSMS release $tag does not exist in $RELEASE_CSMS_REPO. Release the CSMS first." >&2
  exit 1
fi
echo "CSMS $tag is commit $csms_commit."
if ! git -C "$website" rev-parse --git-dir >/dev/null 2>&1; then
  echo "Website checkout not found at $website. Pass --website <dir>." >&2
  exit 1
fi
git -C "$website" fetch --quiet origin
website_commit=$(git -C "$website" rev-parse --verify "$website_ref^{commit}")
export_dir=$(mktemp -d)
csms_dir="$(mktemp -d)/csms"
restore() {
  git checkout --quiet -- .
  git clean --quiet -fd -- skills
  rm -rf "$export_dir" "$(dirname "$csms_dir")"
}
trap restore ERR

# Regenerate the references from the website docs at the ref, without touching
# the website checkout's working tree.
git -C "$website" archive "$website_commit" app/content/docs/en app/data/octt-results.json app/i18n/en.json |
  tar -x -C "$export_dir"
node scripts/generate-references.mjs --website "$export_dir" --commit "$website_commit"
rm -rf "$export_dir"

release_set_version "$tag"
release_check_version "$tag"
release_set_source "$tag" "$csms_commit"
release_check_source "$tag"

# Regenerate the API references from the CSMS release itself: its OpenAPI spec,
# route sources and error messages at the tag's commit.
bash scripts/fetch-csms.sh "$csms_dir" "$tag" "$csms_commit"
python3 scripts/generate-api-reference.py --csms "$csms_dir" --release "$tag" --commit "$csms_commit"
python3 scripts/check-api-paths.py --openapi "$csms_dir/packages/api/openapi.json"
rm -rf "$(dirname "$csms_dir")"

# Copy the SKILL.md descriptions into the manifests, README.md and AGENTS.md.
python3 scripts/sync-descriptions.py
python3 scripts/check-skills.py

if [ -n "$(git status --porcelain)" ]; then
  if release_tag_is_prerelease "$tag"; then
    message="release: prepare $version"
  else
    message="release: version $version"
  fi
  git add -A
  git commit --quiet -m "$message"
  echo "Committed: $message"
else
  echo "References and versions are current. No commit needed."
fi
trap - ERR

git tag "$tag"
echo "Tagged $tag ($(release_tag_channel "$tag")) at $(git rev-parse --short HEAD)."

if [ "$push" = "y" ]; then
  git push --quiet origin main
  git push --quiet origin "$tag"
  echo "Pushed main and $tag. The Release workflow creates the GitHub release."
else
  echo "Not pushed. To publish: git push origin main && git push origin $tag"
fi
