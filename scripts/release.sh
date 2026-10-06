#!/usr/bin/env bash
# Cut a release of the EVtivity skills. The tag matches the EVtivity CSMS
# release the skills target.
#
# Usage: scripts/release.sh <tag> [--push]
#   <tag>   vX.Y.Z (stable) or vX.Y.Z-alpha[.N], -beta[.N], -nightly[.N]
#   --push  push main and the tag to origin (the Release workflow then creates
#           the GitHub release). Without it, nothing leaves this machine.
#
# Steps: validate the tag, require a clean main that matches origin/main, set
# `evtivity-version` in every SKILL.md to X.Y.Z, validate the skills, commit
# (`release: version X.Y.Z` for stable, `release: prepare X.Y.Z` for a
# prerelease) when the version changed, and create the tag.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/release-version.sh
. scripts/release-version.sh

tag=""
push="n"
for arg in "$@"; do
  case "$arg" in
    --push) push="y" ;;
    -h | --help) sed -n '2,13p' "$0"; exit 0 ;;
    -*) echo "Unknown option: $arg" >&2; exit 2 ;;
    *)
      if [ -n "$tag" ]; then echo "Only one tag, got $tag and $arg" >&2; exit 2; fi
      tag="$arg"
      ;;
  esac
done
if [ -z "$tag" ]; then
  sed -n '5,9p' "$0" >&2
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
restore() {
  git checkout --quiet -- skills
}
trap restore ERR

release_set_version "$tag"
release_check_version "$tag"
python3 scripts/check-skills.py

if [ -n "$(git status --porcelain)" ]; then
  if release_tag_is_prerelease "$tag"; then
    message="release: prepare $version"
  else
    message="release: version $version"
  fi
  git add skills
  git commit --quiet -m "$message"
  echo "Committed: $message"
else
  echo "Every SKILL.md already targets $version. No commit needed."
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
