#!/usr/bin/env python3
"""Generate the evtivity-api skill references from an EVtivity CSMS release.

Writes:
  skills/evtivity-api/references/routes.md          index: one line per API tag
  skills/evtivity-api/references/routes-<tag>.md    the routes of one tag, with permissions
  skills/evtivity-api/references/error-codes.md     error code catalog (English)

Source: a checkout of the public CSMS repository (github.com/EVtivity/evtivity-csms)
at the release tag the skills record (metadata evtivity-release and evtivity-commit),
prepared by scripts/fetch-csms.sh, which also generates the OpenAPI spec:
  packages/api/openapi.json               the OpenAPI spec of that release
  packages/api/src/routes/                the permission each operator route requires
  packages/csms/src/i18n/locales/en.json  the English error messages

Run from the repo root:
  python3 scripts/generate-api-reference.py --csms <checkout> --release <tag> --commit <sha>
"""

from __future__ import annotations

import argparse
import html
import json
import re
import subprocess
import sys
from collections import OrderedDict
from pathlib import Path

OUT_DIR = Path("skills/evtivity-api/references")
METHODS = ("get", "post", "put", "patch", "delete")
CSMS_REPO = "https://github.com/EVtivity/evtivity-csms"


def load_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def tag_slug(tag: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", tag.lower()).strip("-")


def normalize(path: str) -> str:
    """Replace every path parameter with {} so source and spec paths compare."""
    path = re.sub(r"\{[^}]+\}", "{}", path)
    path = re.sub(r":[A-Za-z0-9_]+", "{}", path)
    return path.rstrip("/") or "/"


ROUTE_RE = re.compile(r"app\.(get|post|put|patch|delete)\(\s*['`]([^'`]+)['`]", re.S)
AUTH_RE = re.compile(r"authorize\(\s*'([^']+)'")
# Route tables such as { path: '/sites/:id/neighbors', ..., permission: 'sites:read' } (GET routes).
TABLE_RE = re.compile(r"path:\s*'([^']+)'[^{}]*?permission:\s*'([^']+)'", re.S)


def read_permissions(csms: Path) -> dict[tuple[str, str], str]:
    """Map (method, normalized /v1 path) to the permission the route requires."""
    routes_dir = csms / "packages" / "api" / "src" / "routes"
    if not routes_dir.is_dir():
        sys.exit(f"Not a CSMS checkout: {routes_dir} not found")
    perms: dict[tuple[str, str], str] = {}
    for file in sorted(routes_dir.rglob("*.ts")):
        if "__tests__" in file.parts or file.name.endswith(".test.ts"):
            continue
        text = file.read_text(encoding="utf-8")
        matches = list(ROUTE_RE.finditer(text))
        for i, match in enumerate(matches):
            end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
            auth = AUTH_RE.search(text, match.end(), end)
            if auth is None:
                continue
            method, path = match.group(1), match.group(2)
            if "${" in path:
                continue
            perms[(method, normalize("/v1" + path))] = auth.group(1)
        for match in TABLE_RE.finditer(text):
            perms.setdefault(("get", normalize("/v1" + match.group(1))), match.group(2))
    return perms


def permission_for(method: str, path: str, tag: str, perms: dict[tuple[str, str], str]) -> str:
    if tag.endswith(" Commands") and tag.startswith("OCPP "):
        return "stations:write"
    if tag.startswith("CSS ") and tag.endswith("Actions") and path.startswith("/v1/css/actions/"):
        return "stations:write"
    if path.startswith("/v1/portal/"):
        return "driver"
    return perms.get((method, normalize(path)), "")


def write_routes(spec: dict, perms: dict[tuple[str, str], str], source: str) -> int:
    groups: "OrderedDict[str, list[tuple[str, str, str, str]]]" = OrderedDict()
    for path, ops in spec["paths"].items():
        for method in METHODS:
            op = ops.get(method)
            if not isinstance(op, dict):
                continue
            tag = (op.get("tags") or ["Other"])[0]
            secured = bool(op.get("security", spec.get("security", [])))
            perm = permission_for(method, path, tag, perms) if secured else "public"
            summary = html.unescape(op.get("summary") or "").replace("|", "/").strip()
            groups.setdefault(tag, []).append((method.upper(), path, perm, summary))

    for old in OUT_DIR.glob("routes-*.md"):
        old.unlink()
    legend = [
        "Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no",
        "token. `driver` needs a driver portal token. Empty means the route needs a signed-in",
        "operator and no single permission was found; check Swagger at `<api>/docs`.",
        "A `write` permission includes `read` for the same resource.",
    ]
    index = [
        "# EVtivity API route catalog",
        "",
        f"Generated from {source} by `scripts/generate-api-reference.py`. Do not edit by hand.",
        "",
        "One file per API tag. Find a route without reading every file:",
        "`grep -n '<path or word>' references/routes-*.md`.",
        "",
        *legend,
        "",
        "| Tag | Routes | File |",
        "|---|---|---|",
    ]
    count = 0
    for tag, rows in groups.items():
        name = f"routes-{tag_slug(tag)}.md"
        index.append(f"| {tag} | {len(rows)} | `references/{name}` |")
        lines = [
            f"# EVtivity API routes: {tag}",
            "",
            f"Generated from {source} by `scripts/generate-api-reference.py`. Do not edit by hand.",
            "Index of all tags: `references/routes.md`.",
            "",
            *legend,
            "",
            "| Method | Path | Permission | Summary |",
            "|---|---|---|---|",
        ]
        for method, path, perm, summary in rows:
            lines.append(f"| {method} | `{path}` | {perm} | {summary} |")
            count += 1
        (OUT_DIR / name).write_text("\n".join(lines) + "\n", encoding="utf-8")
    (OUT_DIR / "routes.md").write_text("\n".join(index) + "\n", encoding="utf-8")
    return count


def error_statuses(spec: dict) -> dict[str, set[int]]:
    """Collect the HTTP statuses each error code is documented with in the spec."""
    found: dict[str, set[int]] = {}
    for ops in spec["paths"].values():
        for method in METHODS:
            op = ops.get(method)
            if not isinstance(op, dict):
                continue
            for status, resp in op.get("responses", {}).items():
                if not status.isdigit() or int(status) < 400:
                    continue
                schema = resp.get("content", {}).get("application/json", {}).get("schema", {})
                for code in schema.get("properties", {}).get("code", {}).get("enum", []) or []:
                    found.setdefault(code, set()).add(int(status))
    return found


def write_errors(messages: dict[str, str], spec: dict, source: str) -> int:
    statuses = error_statuses(spec)
    lines = [
        "# EVtivity API error codes",
        "",
        f"Generated from {source} by `scripts/generate-api-reference.py`: the English",
        "messages of the CSMS and the statuses in its OpenAPI spec. Do not edit by hand.",
        "Catalog with localized messages: https://www.evtivity.com/api-reference/error-codes",
        "",
        "Every error response is JSON: `{ \"error\": \"<message>\", \"code\": \"<CODE>\" }`.",
        "Match on `code`, never on the message. HTTP lists the statuses the spec documents.",
        "",
        "| Code | HTTP | Message |",
        "|---|---|---|",
    ]
    for code in sorted(messages):
        http = ", ".join(str(s) for s in sorted(statuses.get(code, set())))
        message = str(messages[code]).replace("|", "/").replace("\n", " ")
        lines.append(f"| `{code}` | {http} | {message} |")
    (OUT_DIR / "error-codes.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return len(messages)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--csms", type=Path, required=True, help="CSMS checkout at the release")
    parser.add_argument("--release", required=True, help="CSMS release tag, e.g. v0.1.39")
    parser.add_argument("--commit", required=True, help="commit of the release tag (40 hex)")
    args = parser.parse_args()

    if not re.fullmatch(r"[0-9a-f]{40}", args.commit):
        sys.exit(f"--commit must be 40 hex characters: {args.commit}")
    head = subprocess.run(
        ["git", "-C", str(args.csms), "rev-parse", "HEAD"], capture_output=True, text=True, check=False
    ).stdout.strip()
    if head != args.commit:
        sys.exit(f"{args.csms} is at {head or 'no commit'}, not {args.commit} ({args.release})")
    spec_path = args.csms / "packages" / "api" / "openapi.json"
    if not spec_path.is_file():
        sys.exit(f"{spec_path} not found. Run scripts/fetch-csms.sh first, it generates the spec.")
    spec = load_json(spec_path)
    errors = load_json(args.csms / "packages" / "csms" / "src" / "i18n" / "locales" / "en.json")
    if not isinstance(spec, dict) or "paths" not in spec:
        sys.exit("The OpenAPI spec has no paths")
    if not isinstance(errors, dict) or not isinstance(errors.get("errors"), dict):
        sys.exit("The locale file has no errors object")
    perms = read_permissions(args.csms)
    source = f"EVtivity CSMS {args.release} ({CSMS_REPO}, commit {args.commit[:12]})"

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    routes = write_routes(spec, perms, source)
    codes = write_errors(errors["errors"], spec, source)
    print(f"routes: {routes} routes, error-codes.md: {codes} codes")


if __name__ == "__main__":
    main()
