# Fixes applied 2026-08-12 (user-authorized)

## Fix 1 — PyYAML is now a required dependency; fallback parsers removed

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

## Fix 2 — empty-value semantics made deterministic

YAML parses a bare `key:` as null while the templates spell the same intent
as `key: ""` / `key: []`. Values are now normalized before schema checks:
null becomes `""` (or `[]` for declared list fields, including nested dotted
paths such as `resource_proof.unavailable_claims`). This matches the template
spelling and the old fallback's behavior. Required-field checks still reject
empty strings and empty lists, so nothing absent gains trust.

## Fix 3 — shared `scripts/_common.py` module

The four scripts duplicated ~800 lines (URL/host validation ×4, HTTPS policy
×3, sensitive-query regex ×4, version-evidence detection ×2, date validation
×4, YAML loader preamble ×3, file collection ×2), with five behavioral drift
points already present (e.g. `validate_resource_record.py` alone rejected the
plain scalar `say "hi"`). The mechanisms now live once in
`scripts/_common.py`; policy checks and error wording remain in each script.
The scheme comparison is unified on the case-insensitive form.

## Fix 4 — validate_skill.py frontmatter is parsed as YAML

The hand-rolled frontmatter parser rejected any line without a colon and
stripped quotes unconditionally, so a generated skill using a folded
description (`description: >-`) false-failed validation. Frontmatter is now
parsed with the shared duplicate-key-rejecting YAML loader; values must be
scalars and are coerced to strings. Duplicate frontmatter fields still fail.

## Test evidence

- New pytest suite at repository root `tests/` (run `python3 -m pytest`):
  regression tests for the PASS/FAIL trust flip, end-to-end fixture runs for
  all four validators, `_common` unit tests (URL host, HTTPS policy, dates,
  version evidence, duplicate keys), frontmatter folded-value and
  duplicate-key cases, and a missing-PyYAML fail-fast subprocess test.
- Existing 10-case end-to-end CLI suite re-run on Python 3.10 and 3.11: all
  pass with identical verdicts to the pre-change PyYAML path (except the two
  documented empty-value fixes above).
