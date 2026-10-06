#!/usr/bin/env python3
"""Generate the evtivity-api skill references from public EVtivity sources.

Writes:
  skills/evtivity-api/references/routes.md       route catalog, one table per tag
  skills/evtivity-api/references/error-codes.md  error code catalog (English)

Sources:
  --openapi   OpenAPI spec (path or URL). Default: https://www.evtivity.com/openapi.json
  --errors    English CSMS locale file with the `errors` messages (path or URL).
              Default: packages/csms/src/i18n/locales/en.json of the public CSMS repo
  --csms      optional checkout of github.com/EVtivity/evtivity-csms. When given, the
              permission each operator route requires is read from packages/api/src/routes.

Run from the repo root: python3 scripts/generate-api-reference.py --csms ../evtivity-csms
"""

from __future__ import annotations

import argparse
import html
import json
import re
import sys
import urllib.request
from collections import OrderedDict
from pathlib import Path

DEFAULT_OPENAPI = "https://www.evtivity.com/openapi.json"
DEFAULT_ERRORS = (
    "https://raw.githubusercontent.com/EVtivity/evtivity-csms/main/"
    "packages/csms/src/i18n/locales/en.json"
)
OUT_DIR = Path("skills/evtivity-api/references")
METHODS = ("get", "post", "put", "patch", "delete")


def load_json(source: str) -> object:
    if source.startswith(("http://", "https://")):
        with urllib.request.urlopen(source, timeout=60) as resp:  # noqa: S310 (fixed public URLs)
            return json.loads(resp.read().decode("utf-8"))
    return json.loads(Path(source).read_text(encoding="utf-8"))


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


def write_routes(spec: dict, perms: dict[tuple[str, str], str]) -> int:
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

    version = spec.get("info", {}).get("version", "")
    lines = [
        "# EVtivity API route catalog",
        "",
        f"Generated from the public OpenAPI spec ({DEFAULT_OPENAPI}, spec version {version}) by",
        "`scripts/generate-api-reference.py`. Do not edit by hand.",
        "",
        "Permission column: the RBAC permission an operator JWT or API key needs. `public` needs no",
        "token. `driver` needs a driver portal token. Empty means the route needs a signed-in",
        "operator and no single permission was found; check Swagger at `<api>/docs`.",
        "A `write` permission includes `read` for the same resource.",
        "",
        "## Tags",
        "",
    ]
    for tag in groups:
        anchor = re.sub(r"[^a-z0-9 -]", "", tag.lower()).replace(" ", "-")
        lines.append(f"- [{tag}](#{anchor}) ({len(groups[tag])})")
    count = 0
    for tag, rows in groups.items():
        lines += ["", f"## {tag}", "", "| Method | Path | Permission | Summary |", "|---|---|---|---|"]
        for method, path, perm, summary in rows:
            lines.append(f"| {method} | `{path}` | {perm} | {summary} |")
            count += 1
    (OUT_DIR / "routes.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
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


def write_errors(messages: dict[str, str], spec: dict) -> int:
    statuses = error_statuses(spec)
    lines = [
        "# EVtivity API error codes",
        "",
        "Generated by `scripts/generate-api-reference.py` from the English messages of the",
        "public CSMS and the statuses in the OpenAPI spec. Do not edit by hand.",
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
    parser.add_argument("--openapi", default=DEFAULT_OPENAPI)
    parser.add_argument("--errors", default=DEFAULT_ERRORS)
    parser.add_argument("--csms", type=Path)
    args = parser.parse_args()

    spec = load_json(args.openapi)
    errors = load_json(args.errors)
    if not isinstance(spec, dict) or "paths" not in spec:
        sys.exit("The OpenAPI source has no paths")
    if not isinstance(errors, dict) or not isinstance(errors.get("errors"), dict):
        sys.exit("The locale source has no errors object")
    perms = read_permissions(args.csms) if args.csms else {}

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    routes = write_routes(spec, perms)
    codes = write_errors(errors["errors"], spec)
    print(f"routes.md: {routes} routes, error-codes.md: {codes} codes")


if __name__ == "__main__":
    main()
