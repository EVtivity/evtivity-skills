#!/usr/bin/env bash
# Release tag helpers shared by scripts/release.sh and .github/workflows/release.yml.
#
# Source this file; it defines functions only. The skills are released with the
# EVtivity CSMS and use the same tag grammar: `v` plus a semver 2.0.0 version
# (https://semver.org) in one of four channels: stable `v0.1.39`, alpha
# `v0.1.39-alpha.1`, beta `v0.1.39-beta.2` and nightly `v0.1.39-nightly.7` (the
# number is optional). No other prerelease label (rc, preview) is used, so this
# grammar rejects them. Build metadata (`+...`) is rejected too.
#
# Usage from a shell: bash scripts/release-version.sh <function> [args...]

RELEASE_NUM='(0|[1-9][0-9]*)'
RELEASE_STABLE_RE="^v${RELEASE_NUM}\\.${RELEASE_NUM}\\.${RELEASE_NUM}\$"
RELEASE_TAG_RE="^v${RELEASE_NUM}\\.${RELEASE_NUM}\\.${RELEASE_NUM}(-(alpha|beta|nightly)(\\.${RELEASE_NUM})?)?\$"

# release_tag_is_valid <tag>: exit 0 when the tag is a stable, alpha, beta or nightly tag.
release_tag_is_valid() {
  [[ "${1:-}" =~ $RELEASE_TAG_RE ]]
}

# release_tag_is_prerelease <tag>: exit 0 when the tag is a valid prerelease tag.
release_tag_is_prerelease() {
  release_tag_is_valid "${1:-}" && ! [[ "$1" =~ $RELEASE_STABLE_RE ]]
}

# release_tag_channel <tag>: print the release channel: `stable`, `alpha`, `beta`
# or `nightly`. Exit 1 for an invalid tag.
release_tag_channel() {
  local tag="${1:-}" pre
  release_tag_is_valid "$tag" || return 1
  if ! release_tag_is_prerelease "$tag"; then
    echo stable
    return 0
  fi
  pre="${tag#*-}"
  echo "${pre%%.*}"
}

# release_base_version <tag>: print the X.Y.Z part of the tag (the CSMS version
# line the skills target). Exit 1 for an invalid tag.
release_base_version() {
  local tag="${1:-}" version
  release_tag_is_valid "$tag" || return 1
  version="${tag#v}"
  echo "${version%%-*}"
}

# release_latest_stable_tag: print the highest stable tag in the repo (prereleases
# skipped), or nothing when there is none.
release_latest_stable_tag() {
  git tag -l 'v*' --sort=-v:refname | grep -E "$RELEASE_STABLE_RE" | sed -n '1p' || true
}

# release_is_newer <tag> <than>: exit 0 when <tag> has higher semver precedence
# than <than>. Within one X.Y.Z, alpha < beta < nightly < stable.
release_is_newer() {
  local a="${1:-}" b="${2:-}"
  release_tag_is_valid "$a" && release_tag_is_valid "$b" || return 1
  [ "$a" != "$b" ] || return 1
  [ "$(release_sort "$a" "$b" | tail -n 1)" = "$a" ]
}

# release_sort <tag>...: print the tags in ascending semver order.
release_sort() {
  local tag base pre channel num rank
  for tag in "$@"; do
    base="${tag#v}"
    base="${base%%-*}"
    if release_tag_is_prerelease "$tag"; then
      pre="${tag#*-}"
      channel="${pre%%.*}"
      num="${pre#"$channel"}"
      num="${num#.}"
      case "$channel" in alpha) rank=0 ;; beta) rank=1 ;; *) rank=2 ;; esac
      num="${num:-0}"
    else
      rank=3
      num=0
    fi
    printf '%s.%s.%s %s\n' "$base" "$rank" "$num" "$tag"
  done | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -k5,5n | awk '{ print $2 }'
}

# release_previous_tag <tag>: print the tag the changelog for <tag> starts from,
# or nothing for the first tag. <tag> must exist in the repo.
# A stable tag compares against the previous stable tag, so its notes cover every
# change since the last stable release, prereleases included. A prerelease
# compares against the previous tag of any kind, so its notes cover only what
# changed since the last build that was tested. Order is semver precedence:
# versionsort.suffix=- sorts v0.1.39-beta.1 before v0.1.39.
release_previous_tag() {
  local tag="${1:?release_previous_tag needs a tag}" tags
  tags=$(git -c versionsort.suffix=- tag -l 'v*' --sort=v:refname | grep -E "$RELEASE_TAG_RE" || true)
  if ! release_tag_is_prerelease "$tag"; then
    tags=$(printf '%s\n' "$tags" | grep -E "$RELEASE_STABLE_RE" || true)
  fi
  printf '%s\n' "$tags" | awk -v cur="$tag" '
    $0 == cur { found = 1; exit }
    { prev = $0 }
    END { if (found) print prev }
  '
}

# release_skill_files: print every SKILL.md, relative to the repo root.
release_skill_files() {
  find skills -mindepth 2 -maxdepth 2 -name SKILL.md | sort
}

# release_set_version <tag>: write the tag's base version into the
# `evtivity-version` metadata of every SKILL.md. Run from the repo root.
release_set_version() {
  local tag="${1:?release_set_version needs a tag}" version file
  version=$(release_base_version "$tag") || return 1
  while IFS= read -r file; do
    if ! grep -qE '^  evtivity-version: ' "$file"; then
      echo "$file has no metadata evtivity-version line" >&2
      return 1
    fi
    sed -E "s/^(  evtivity-version: ).*/\\1\"$version\"/" "$file" >"$file.tmp" && mv "$file.tmp" "$file"
  done < <(release_skill_files)
}

# release_check_version <tag>: exit 0 when every SKILL.md carries the tag's base
# version. Prints each mismatch. Run from the repo root.
release_check_version() {
  local tag="${1:?release_check_version needs a tag}" version file actual status=0
  version=$(release_base_version "$tag") || return 1
  while IFS= read -r file; do
    actual=$(sed -nE 's/^  evtivity-version: "?([^"]*)"?$/\1/p' "$file")
    if [ "$actual" != "$version" ]; then
      echo "$file: evtivity-version is \"$actual\", expected \"$version\"" >&2
      status=1
    fi
  done < <(release_skill_files)
  return $status
}

# The public CSMS repository. EVTIVITY_CSMS_REPO overrides it (tests use a local repo).
RELEASE_CSMS_REPO="${EVTIVITY_CSMS_REPO:-https://github.com/EVtivity/evtivity-csms.git}"

# release_csms_tag_commit <tag>: print the commit the CSMS release tag points to
# (the peeled commit for an annotated tag). Exit 1 when the tag does not exist.
release_csms_tag_commit() {
  local tag="${1:?release_csms_tag_commit needs a tag}" refs commit
  refs=$(git ls-remote --tags "$RELEASE_CSMS_REPO" "refs/tags/$tag" "refs/tags/$tag^{}") || return 1
  commit=$(printf '%s\n' "$refs" | awk -v ref="refs/tags/$tag^{}" '$2 == ref { print $1 }')
  if [ -z "$commit" ]; then
    commit=$(printf '%s\n' "$refs" | awk -v ref="refs/tags/$tag" '$2 == ref { print $1 }')
  fi
  [ -n "$commit" ] || return 1
  echo "$commit"
}

# release_set_source <tag> <commit>: record the CSMS release tag and its commit
# in the `evtivity-release` and `evtivity-commit` metadata of every SKILL.md.
release_set_source() {
  local tag="${1:?release_set_source needs a tag}" commit="${2:?release_set_source needs a commit}" file
  release_tag_is_valid "$tag" || return 1
  if ! [[ "$commit" =~ ^[0-9a-f]{40}$ ]]; then
    echo "commit must be 40 lowercase hex characters: $commit" >&2
    return 1
  fi
  while IFS= read -r file; do
    if ! grep -qE '^  evtivity-release: ' "$file" || ! grep -qE '^  evtivity-commit: ' "$file"; then
      echo "$file has no metadata evtivity-release or evtivity-commit line" >&2
      return 1
    fi
    sed -E -e "s/^(  evtivity-release: ).*/\\1\"$tag\"/" -e "s/^(  evtivity-commit: ).*/\\1\"$commit\"/" \
      "$file" >"$file.tmp" && mv "$file.tmp" "$file"
  done < <(release_skill_files)
}

# release_skill_metadata <key>: print a metadata value of the first SKILL.md
# (check-skills.py checks that every skill carries the same value).
release_skill_metadata() {
  local key="${1:?release_skill_metadata needs a key}" file
  file=$(release_skill_files | sed -n '1p')
  sed -nE "s/^  $key: \"?([^\"]*)\"?\$/\\1/p" "$file"
}

# release_check_source <tag>: exit 0 when every SKILL.md records <tag> as
# `evtivity-release` and the same 40-hex `evtivity-commit`. Prints each mismatch.
release_check_source() {
  local tag="${1:?release_check_source needs a tag}" file release commit first="" status=0
  while IFS= read -r file; do
    release=$(sed -nE 's/^  evtivity-release: "?([^"]*)"?$/\1/p' "$file")
    commit=$(sed -nE 's/^  evtivity-commit: "?([^"]*)"?$/\1/p' "$file")
    if [ "$release" != "$tag" ]; then
      echo "$file: evtivity-release is \"$release\", expected \"$tag\"" >&2
      status=1
    fi
    if ! [[ "$commit" =~ ^[0-9a-f]{40}$ ]]; then
      echo "$file: evtivity-commit \"$commit\" is not a 40-hex commit" >&2
      status=1
    elif [ -z "$first" ]; then
      first="$commit"
    elif [ "$commit" != "$first" ]; then
      echo "$file: evtivity-commit differs from the other skills" >&2
      status=1
    fi
  done < <(release_skill_files)
  return $status
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -euo pipefail
  fn="${1:?Usage: release-version.sh <function> [args...]}"
  shift
  case "$fn" in
    release_tag_is_valid | release_tag_is_prerelease | release_tag_channel | \
      release_base_version | release_latest_stable_tag | release_is_newer | release_sort | \
      release_previous_tag | release_skill_files | release_check_version | \
      release_csms_tag_commit | release_skill_metadata | release_check_source) "$fn" "$@" ;;
    *)
      echo "Unknown function: $fn" >&2
      exit 1
      ;;
  esac
fi
