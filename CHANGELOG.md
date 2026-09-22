# Changelog

Maintenance history for this repository. Entries were previously kept as dated
`CHANGELOG-*.md` files inside the `roblox-resource-acquisition` package; they
now live here so the shipped skill package carries only what an agent using it
needs.

## 2026-09-22 — Added the roblox-r6-animation skill (user-authorized)

- New package `roblox-r6-animation`: SKILL.md, five references (idle-run-land,
  walk-cycles, attack-timing, pipeline, moon-animator) and seven scripts (Poser,
  Locomotion, Clips, ReadClips, Strip, Bake, serve.js).
- Numbers come from decoded KeyframeSequences: a professional idle, run and
  landing set, four community R6 walks, a professional sword kit and the Roblox
  default walk and idle.
- README gained a section for the new package. No changes to
  `roblox-resource-acquisition` or the test suite.

## 2026-08-12 — Review, polish, and repository cleanup (user-authorized)

- `validate_skill.py`: fixed the observable-verb heuristic used by pass-condition
  checks — `send(?:s|sent)?` matched "send"/"sends" but never the past tense
  "sent"; it is now `send(?:s)?|sent`.
- `validate_resource_record.py`: removed a redundant duplicate error — an empty
  `canonical_url` on a verified-acquisition record was reported twice (once by
  the required-fields loop, once by a trailing check that could never fire
  independently).
- Added `tests/test_quality_heuristics.py` locking both fixes.
- Repository cleanup: real README, changelogs consolidated into this file and
  removed from the skill package, `.gitignore` extended, CI workflow added to
  run the test suite.

## 2026-08-12 — PyYAML required, shared module, tests (user-authorized)

### Fix 1 — PyYAML is now a required dependency; fallback parsers removed

The registry, learnings, and record validators previously treated PyYAML as
optional, each carrying a ~200-line bundled fallback YAML parser. The two
parse paths could disagree: a registry entry with a bare `package_id:` was
FAIL (untrusted) with PyYAML installed and PASS (trusted) without it, and 19
of 21 probed inputs diverged (tab indentation, octal-like integers,
case-folded booleans, resolved duplicate keys such as `yes:`/`true:`, block
scalars, anchors). A trust verdict must not depend on which parser happens to
be installed (`references/curated-registry.md`: a malformed entry must not be
silently treated as trusted).

- `MiniYamlError`, `strip_comment`, `split_inline_list`, `parse_scalar`, and
  the flat/record fallback parsers are deleted (~640 lines).
- A missing PyYAML now exits with code 2 and an install hint on stderr
  (exit 1 remains validation failure, 0 pass).
- requirements.txt and SKILL.md `compatibility` now declare PyYAML>=5.4 as
  required.

### Fix 2 — empty-value semantics made deterministic

YAML parses a bare `key:` as null while the templates spell the same intent
as `key: ""` / `key: []`. Values are now normalized before schema checks:
null becomes `""` (or `[]` for declared list fields, including nested dotted
paths such as `resource_proof.unavailable_claims`). This matches the template
spelling and the old fallback's behavior. Required-field checks still reject
empty strings and empty lists, so nothing absent gains trust.

### Fix 3 — shared `scripts/_common.py` module

The four scripts duplicated ~800 lines (URL/host validation ×4, HTTPS policy
×3, sensitive-query regex ×4, version-evidence detection ×2, date validation
×4, YAML loader preamble ×3, file collection ×2), with five behavioral drift
points already present (e.g. `validate_resource_record.py` alone rejected the
plain scalar `say "hi"`). The mechanisms now live once in
`scripts/_common.py`; policy checks and error wording remain in each script.
The scheme comparison is unified on the case-insensitive form.

### Fix 4 — validate_skill.py frontmatter is parsed as YAML

The hand-rolled frontmatter parser rejected any line without a colon and
stripped quotes unconditionally, so a generated skill using a folded
description (`description: >-`) false-failed validation. Frontmatter is now
parsed with the shared duplicate-key-rejecting YAML loader; values must be
scalars and are coerced to strings. Duplicate frontmatter fields still fail.

### Test evidence

- New pytest suite at repository root `tests/` (run `python3 -m pytest`):
  regression tests for the PASS/FAIL trust flip, end-to-end fixture runs for
  all four validators, `_common` unit tests (URL host, HTTPS policy, dates,
  version evidence, duplicate keys), frontmatter folded-value and
  duplicate-key cases, and a missing-PyYAML fail-fast subprocess test.
- Existing 10-case end-to-end CLI suite re-run on Python 3.10 and 3.11: all
  pass with identical verdicts to the pre-change PyYAML path (except the two
  documented empty-value fixes above).

## 2026-08-10 — Validator fixes (user-authorized)

### Fix 1 — validate_skill.py: Alternatives shape heuristic

- Replaced the inline six-verb regex with the named `ALTERNATIVES_DECISION_RE`
  constant covering genuine decision language (preferred/prefers, rather than,
  better fit/suited/choice, sufficient/suffices, is enough, covers the same,
  equivalent, closest, chosen, compared) in addition to the original verbs.
- Strictly more permissive; word-count, vagueness, list-form, and
  explicit-no-alternative paths unchanged. Generic filler prose still fails.

### Fix 2 — validate_learnings_store.py: advisory directive warning

- New `DIRECTIVE_STATEMENT_RE` + `entry_warnings()` emit `WARN:` lines when a
  learning statement reads as an imperative directive (statement-initial
  Always/Never/Ignore/Skip/Do not/Disable/Bypass, or policy-override phrases
  such as "in future runs", "from now on", "ignore the repair budget",
  "skip/bypass/disable verification").
- Warnings are advisory only: exit code, trust, and verification semantics are
  untouched. Factual uses of always/never do not warn.
- references/learnings-store.md updated with one paragraph documenting the
  warning channel and restating the consumption rule it supplements.

### Not changed

- Finding 3 (learnings edit gating is behavioral, one-file-per-observation) is
  a documented property of the design, left as-is.

### Test evidence

- Targeted: 25/25 (testlab/run_targeted.py) — 9 alternatives cases including
  3 negative guards; 8 directive cases including 3 injections, 1 benign
  imperative nudge, 3 factual no-warn guards, 1 pre-existing error case.
- Full harness regression: 67/67 (testlab/run_tests.py), rerun twice to
  confirm idempotence. Seeded child now fails with exactly the 3 real defects
  (alternatives false-FAIL eliminated) and repairs in 4 bounded cycles.
