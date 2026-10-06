#!/usr/bin/env python3
"""Check that every /v1 API path a SKILL.md mentions exists in the CSMS release.

The paths come from the OpenAPI spec of the CSMS release the skills record
(metadata evtivity-release). By default the check reads them from the generated
route catalog (skills/evtivity-api/references/routes-*.md), which CI regenerates
from that spec. With --openapi it reads the spec itself.

A mentioned segment such as `{id}`, `<id>`, `:id`, `$STA` or `{v21|v16}` stands for
any value. A mention that ends with `/` or `...` is a prefix. Query strings are
ignored.

Run from the repo root: python3 scripts/check-api-paths.py [--openapi <spec.json>]
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROUTE_ROW = re.compile(r"^\| [A-Z]+ \| `(/[^`]+)` \|", re.M)
MENTION = re.compile(r"/v1(?:/[A-Za-z0-9_.:{}<>$|*-]+)*/?")
# Paths the skills name on purpose although the release no longer has them.
ALLOWED_MISSING = {
    "/v1/webhooks/stripe": "removed in v0.1.38; the skills name it so users move off it",
}


def spec_paths(openapi: Path | None) -> list[list[str]]:
    if openapi is not None:
        paths = list(json.loads(openapi.read_text(encoding="utf-8"))["paths"])
    else:
        paths = []
        for file in sorted(Path("skills/evtivity-api/references").glob("routes-*.md")):
            paths += ROUTE_ROW.findall(file.read_text(encoding="utf-8"))
    if not paths:
        sys.exit("No API paths found. Generate the API references first.")
    return [p.strip("/").split("/") for p in set(paths)]


def is_wildcard(segment: str) -> bool:
    return segment[:1] in "{<$:" or "|" in segment or segment == "*"


def matches(mention: list[str], path: list[str], prefix: bool) -> bool:
    if len(mention) > len(path) or (not prefix and len(mention) != len(path)):
        return False
    for m, p in zip(mention, path):
        if is_wildcard(m) or (p.startswith("{") and p.endswith("}")):
            continue
        if m != p:
            return False
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--openapi", type=Path)
    args = parser.parse_args()
    paths = spec_paths(args.openapi)

    errors = []
    checked = 0
    for skill_md in sorted(Path("skills").glob("*/SKILL.md")):
        for lineno, line in enumerate(skill_md.read_text(encoding="utf-8").splitlines(), 1):
            for raw in MENTION.findall(line):
                prefix = raw.endswith("/") or raw.endswith("...")
                text = raw.rstrip(".").rstrip(":").rstrip("/")
                if text in ALLOWED_MISSING:
                    continue
                segments = text.strip("/").split("/")
                checked += 1
                if not any(matches(segments, p, prefix) for p in paths):
                    errors.append(f"{skill_md}:{lineno}: {raw} is not in the CSMS release's API")
    for error in errors:
        print(f"ERROR {error}")
    if errors:
        return 1
    print(f"{checked} API path mentions OK against {len(paths)} paths")
    return 0


if __name__ == "__main__":
    sys.exit(main())
