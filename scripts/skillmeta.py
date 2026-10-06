"""Read the frontmatter of every skills/*/SKILL.md. Shared by the repo scripts.

SKILL.md frontmatter uses a small YAML subset: `key: value` scalars (optionally
in double quotes, without escapes) and one nested `metadata:` map.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Skill:
    name: str
    path: Path
    description: str
    metadata: dict[str, str] = field(default_factory=dict)
    body: str = ""

    @property
    def trigger_text(self) -> str:
        """The description up to "Not for": the part that should match a prompt."""
        return self.description.split("Not for", 1)[0]


def parse(path: Path) -> Skill:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise ValueError(f"{path}: no frontmatter")
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
            if len(value) >= 2 and value[0] == value[-1] == '"':
                value = value[1:-1]
            data[key.strip()] = value
            current = None
        else:
            current = {}
            data[key.strip()] = current
    metadata = data.get("metadata")
    return Skill(
        name=str(data.get("name", "")),
        path=path,
        description=str(data.get("description", "")),
        metadata=metadata if isinstance(metadata, dict) else {},
        body=text[end + 5 :],
    )


def load(root: Path = Path(".")) -> list[Skill]:
    return [parse(p) for p in sorted((root / "skills").glob("*/SKILL.md"))]
