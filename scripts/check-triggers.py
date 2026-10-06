#!/usr/bin/env python3
"""Check that common prompts would land on one skill, by a keyword heuristic.

For each prompt in scripts/trigger-evals.json:
- every listed term must appear in the expected skill's description, and
- the expected skill must score strictly higher than every other skill, where a
  skill's score is the number of distinct prompt words found in its description.

Only the part of a description before "Not for" counts: that part says when to
use the skill. Words are lowercased, split on non-alphanumerics, stripped of common
suffixes (s, ed, ing) and of stop words.

This is a heuristic. It does not run an agent or a model, so a pass does not prove
an agent picks the skill. It catches descriptions that lost a trigger word or that
overlap so much that a common prompt no longer has one clear owner.

Run from the repo root: python3 scripts/check-triggers.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import skillmeta  # noqa: E402

STOP = set(
    """a an and are at be by can could do does for from get how i in into is it its me my of
    on or our the this to t use using via want we what when which why will with without you your
    evtivity new keeps sets add set up run make""".split()
)


def stem(word: str) -> str:
    for suffix in ("ing", "ed", "s"):
        if word.endswith(suffix) and len(word) - len(suffix) >= 3:
            return word[: -len(suffix)]
    return word


def words(text: str, stop: bool = True) -> set[str]:
    tokens = re.findall(r"[a-z0-9]+", text.lower())
    return {stem(t) for t in tokens if not (stop and t in STOP)}


def has_term(term: str, text: str) -> bool:
    return words(term, stop=False) <= words(text, stop=False)


def main() -> int:
    skills = {s.name: s.trigger_text for s in skillmeta.load()}
    evals = json.loads(Path("scripts/trigger-evals.json").read_text(encoding="utf-8"))["evals"]
    errors = []
    for case in evals:
        prompt, expect = case["prompt"], case["expect"]
        if expect not in skills:
            errors.append(f"{prompt!r}: unknown skill {expect}")
            continue
        for term in case.get("terms", []):
            if not has_term(term, skills[expect]):
                errors.append(f"{prompt!r}: {expect} description lacks {term!r}")
        asked = words(prompt)
        scores = {name: len(asked & words(text)) for name, text in skills.items()}
        best_other = max((v, k) for k, v in scores.items() if k != expect)
        if scores[expect] <= best_other[0]:
            errors.append(
                f"{prompt!r}: {expect} scores {scores[expect]}, {best_other[1]} scores {best_other[0]}"
            )
    for error in errors:
        print(f"ERROR {error}")
    if errors:
        return 1
    print(f"{len(evals)} trigger prompts OK (keyword heuristic)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
