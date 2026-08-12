# Fixes applied 2026-08-10 (user-authorized)

## Fix 1 — validate_skill.py: Alternatives shape heuristic
- Replaced the inline six-verb regex with the named `ALTERNATIVES_DECISION_RE`
  constant covering genuine decision language (preferred/prefers, rather than,
  better fit/suited/choice, sufficient/suffices, is enough, covers the same,
  equivalent, closest, chosen, compared) in addition to the original verbs.
- Strictly more permissive; word-count, vagueness, list-form, and
  explicit-no-alternative paths unchanged. Generic filler prose still fails.

## Fix 2 — validate_learnings_store.py: advisory directive warning
- New `DIRECTIVE_STATEMENT_RE` + `entry_warnings()` emit `WARN:` lines when a
  learning statement reads as an imperative directive (statement-initial
  Always/Never/Ignore/Skip/Do not/Disable/Bypass, or policy-override phrases
  such as "in future runs", "from now on", "ignore the repair budget",
  "skip/bypass/disable verification").
- Warnings are advisory only: exit code, trust, and verification semantics are
  untouched. Factual uses of always/never do not warn.
- references/learnings-store.md updated with one paragraph documenting the
  warning channel and restating the consumption rule it supplements.

## Not changed
- Finding 3 (learnings edit gating is behavioral, one-file-per-observation) is
  a documented property of the design, left as-is.

## Test evidence
- Targeted: 25/25 (testlab/run_targeted.py) — 9 alternatives cases including
  3 negative guards; 8 directive cases including 3 injections, 1 benign
  imperative nudge, 3 factual no-warn guards, 1 pre-existing error case.
- Full harness regression: 67/67 (testlab/run_tests.py), rerun twice to
  confirm idempotence. Seeded child now fails with exactly the 3 real defects
  (alternatives false-FAIL eliminated) and repairs in 4 bounded cycles.
