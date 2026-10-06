#!/usr/bin/env python3
"""Check the repository's skills against the Agent Skills rules and this repo's rules.

Complements the skills-ref validator (run in CI) with checks that need no install:
- name: 1 to 64 characters, lowercase letters, digits and single hyphens, equal to the directory
- description: 1 to 1024 characters
- license: MIT
- metadata.evtivity-version: present, X.Y.Z, the same in every skill
- body under 500 lines, files referenced from SKILL.md exist
- every skill is listed in .claude-plugin/marketplace.json and README.md

Run from the repo root: python3 scripts/check-skills.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")
REF_RE = re.compile(r"`((?:scripts|references|assets)/[A-Za-z0-9._/-]+)`")


def frontmatter(text: str) -> tuple[dict[str, object], str]:
    """Parse the small YAML subset SKILL.md uses: scalars and one nested map."""
    if not text.startswith("---\n"):
        raise ValueError("no frontmatter")
    end = text.index("\n---\n", 4)
    data: dict[str, object] = {}
    current: dict[str, str] | None = None
    for line in text[4:end].splitlines():
        if not line.strip():
            continue
        if line.startswith("  ") and current is not None:
            key, _, value = line.strip().partition(":")
            current[key.strip()] = value.strip().strip('"')
            continue
        key, _, value = line.partition(":")
        value = value.strip()
        if value:
            data[key.strip()] = value.strip('"')
            current = None
        else:
            current = {}
            data[key.strip()] = current
    return data, text[end + 5 :]


def main() -> int:
    errors: list[str] = []
    skills = sorted(p for p in Path("skills").iterdir() if p.is_dir())
    if not skills:
        errors.append("no skills found")
    versions: set[str] = set()
    for skill in skills:
        path = skill / "SKILL.md"
        if not path.is_file():
            errors.append(f"{skill}: SKILL.md missing")
            continue
        try:
            meta, body = frontmatter(path.read_text(encoding="utf-8"))
        except ValueError as exc:
            errors.append(f"{path}: {exc}")
            continue
        name = str(meta.get("name", ""))
        if not (1 <= len(name) <= 64 and NAME_RE.match(name)):
            errors.append(f"{path}: invalid name {name!r}")
        if name != skill.name:
            errors.append(f"{path}: name {name!r} differs from directory {skill.name!r}")
        description = str(meta.get("description", ""))
        if not 1 <= len(description) <= 1024:
            errors.append(f"{path}: description has {len(description)} characters (1 to 1024)")
        if meta.get("license") != "MIT":
            errors.append(f"{path}: license must be MIT")
        compatibility = meta.get("compatibility")
        if compatibility is not None and not 1 <= len(str(compatibility)) <= 500:
            errors.append(f"{path}: compatibility must be 1 to 500 characters")
        metadata = meta.get("metadata")
        version = metadata.get("evtivity-version", "") if isinstance(metadata, dict) else ""
        if not VERSION_RE.match(version):
            errors.append(f"{path}: metadata evtivity-version {version!r} is not X.Y.Z")
        versions.add(version)
        lines = body.count("\n")
        if lines >= 500:
            errors.append(f"{path}: body has {lines} lines (under 500)")
        for ref in sorted(set(REF_RE.findall(body))):
            if not (skill / ref).exists():
                errors.append(f"{path}: references missing file {ref}")
        for sub in skill.iterdir():
            if sub.is_dir() and sub.name not in {"scripts", "references", "assets"}:
                errors.append(f"{skill}: unexpected directory {sub.name}")
            if sub.is_dir():
                for nested in sub.iterdir():
                    if nested.is_dir():
                        errors.append(f"{nested}: keep files one level deep")
    if len(versions) > 1:
        errors.append(f"skills target different versions: {sorted(versions)}")

    marketplace = json.loads(Path(".claude-plugin/marketplace.json").read_text(encoding="utf-8"))
    listed = {
        Path(s).name
        for plugin in marketplace.get("plugins", [])
        for s in plugin.get("skills", [])
    }
    readme = Path("README.md").read_text(encoding="utf-8")
    for skill in skills:
        if skill.name not in listed:
            errors.append(f".claude-plugin/marketplace.json: {skill.name} not listed")
        if f"`{skill.name}`" not in readme:
            errors.append(f"README.md: {skill.name} not listed")

    for error in errors:
        print(f"ERROR {error}")
    if errors:
        return 1
    print(f"{len(skills)} skills OK (evtivity-version {versions.pop() if versions else '?'})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
