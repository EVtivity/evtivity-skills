#!/usr/bin/env python3
"""Build the Agent Skills .well-known discovery index and one archive per skill.

Writes <out>/index.json (discovery schema 0.2.0, the format supabase/agent-skills
publishes) and <out>/<skill>.tar.gz. The archives are reproducible: sorted entries,
fixed owner and mtime, gzip without a timestamp. Each index entry points at the
archive as a release asset of <tag> and carries its sha256 digest.

The EVtivity website does not serve /.well-known/agent-skills/ yet, so the Release
workflow uploads these files as GitHub release assets.

Run from the repo root: python3 scripts/build-discovery.py --tag <tag> [--out dist]
     [--repo EVtivity/evtivity-skills]
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import io
import json
import sys
import tarfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import skillmeta  # noqa: E402

SCHEMA = "https://schemas.agentskills.io/discovery/0.2.0/schema.json"


def archive(skill_dir: Path) -> bytes:
    raw = io.BytesIO()
    with tarfile.open(fileobj=raw, mode="w", format=tarfile.PAX_FORMAT) as tar:
        for path in sorted(p for p in skill_dir.rglob("*") if p.is_file()):
            info = tarfile.TarInfo(path.relative_to(skill_dir).as_posix())
            data = path.read_bytes()
            info.size = len(data)
            info.mtime = 0
            info.mode = 0o755 if path.stat().st_mode & 0o111 else 0o644
            info.uid = info.gid = 0
            info.uname = info.gname = ""
            tar.addfile(info, io.BytesIO(data))
    out = io.BytesIO()
    with gzip.GzipFile(fileobj=out, mode="wb", mtime=0, filename="") as gz:
        gz.write(raw.getvalue())
    return out.getvalue()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--tag", required=True)
    parser.add_argument("--out", type=Path, default=Path("dist"))
    parser.add_argument("--repo", default="EVtivity/evtivity-skills")
    args = parser.parse_args()

    args.out.mkdir(parents=True, exist_ok=True)
    entries = []
    for skill in skillmeta.load():
        if not skill.name or not skill.description:
            sys.exit(f"{skill.path}: name and description are required")
        data = archive(skill.path.parent)
        (args.out / f"{skill.name}.tar.gz").write_bytes(data)
        entries.append(
            {
                "name": skill.name,
                "type": "archive",
                "description": skill.description,
                "url": f"https://github.com/{args.repo}/releases/download/{args.tag}/{skill.name}.tar.gz",
                "digest": "sha256:" + hashlib.sha256(data).hexdigest(),
            }
        )
    index = {"$schema": SCHEMA, "skills": entries}
    (args.out / "index.json").write_text(json.dumps(index, indent=2) + "\n", encoding="utf-8")
    print(f"{args.out}/index.json: {len(entries)} skills")
    return 0


if __name__ == "__main__":
    sys.exit(main())
