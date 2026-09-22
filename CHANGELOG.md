# Changelog

Maintenance history for this repository. Entries were previously kept as dated
`CHANGELOG-*.md` files inside the `roblox-resource-acquisition` package; they
now live here so the shipped skill package carries only what an agent using it
needs.

## 2026-09-22 - VFX artist workflow and technical reference revision

- Replaced fixed showcase prescriptions with reference analysis, art direction,
  motion block-in, editable instance construction, asset polish, and playback critique.
- Added impact, slash, projectile, beam, aura, summon, and environmental recipes,
  plus texture/flipbook/mesh guidance and concise planning/review templates.
- Corrected particle, sequence, beam, trail, preload, storage, and module-contract
  guidance against official Roblox documentation and the bundled implementations.
- Linked primary artist explanations and production breakdowns with explicit
  evidence scope. Moved original measurements and cut lists into project history.
- Kept the existing Luau examples unchanged. Structural checks and the repository
  test suite do not certify rendered quality; Studio/device verification remains required.

## 2026-09-22 (night, later) — The knife throw, the hip rule (user-authorized)

- `roblox-r6-animation`: the hip rule — a limb key's translation is the joint gap; `attachLegs` in
  `scripts/Clips.lua` moves every authored DIO leg placement into the hip angles and clamps a drop at 0.12
  (SKILL.md pass 2, `references/r6-mechanics.md` "Joint gaps", the measurement and the feedback in
  `references/project-style.md`). `DioKnifeThrow` recorded with its numbers and two strip rounds.
- `roblox-vfx-craft`: the knife throw as a MOVE rung piece (`Moves.knives`, `startKnives` / `knifeStep`
  in `MovesServer.lua`): server flown knives that hang while any time stop holds the world and fly at
  the resume, the shimmer and light that keep them visible in the darkened stop, the sounds.

## 2026-09-22 (night) — Rebuild of the lost place, the road roller on the metal (user-authorized)

- `roblox-vfx-craft`: `scripts/RebuildStandPlace.lua` and `scripts/rebuild/` rebuild the whole
  DIO place from a fresh baseplate (kit archive, templates, sounds, the free model rig, dead sounds,
  modules, dummy, bake rig) after the unpublished place was lost. The road roller layout is measured
  with rays over the mesh: DIO on the rear hood, The World pitched 65 down over the front housing with
  its fists 0.3 studs into the metal, every contact effect placed in the roller's frame; the rush glow
  cut so the stand reads as a body. Two Studio traps logged (a runaway bake of a held clip, the
  50k instance kit doubling in play on a 6 GB machine).
- `roblox-r6-animation`: `Poser.bake` refuses a length over 60 s; `Bake.lua` takes a bake length per
  clip and the held `DioPoint` entry; the road roller numbers and the night's feedback in
  `references/project-style.md`.

## 2026-09-22 — Canon ZA WARUDO, the road roller cutscene (user-authorized)

- `roblox-r6-animation`: `DioTimeStop` remade from the show's two frames (arms crossed in an X
  in a forward crouch, then flung up and out into a wide V) after the user rejected the quiet
  one-hand version; the accepted numbers and the two strip rounds are under ZA WARUDO in SKILL.md.
  New `DioRollerUp` and `DioRollerOff` for the road roller with a procedural root;
  `WorldRollerBarrage` leans the stand's raw barrage into the deck. `references/principles.md`
  (animation principles translated to R6) is now in the package. The strip helper needs
  `Character.Archivable = true` in play.
- `roblox-vfx-craft`: `scripts/RoadRoller.lua`, a 12 s cinematic keyed to the RoadRollerDA voice
  line (leap, sky cut, land with the roller in the impact frames, the rush on the deck, the boom,
  the fade); the road roller phases in `references/cinematic.md`; two traps in SKILL.md (the client
  must not restore WalkSpeed the server owns; the impact-frame viewport is a first draw the warm-up
  now covers). Scripts synced: SummonVfx, MovesServer, StandClient, Config.summon.

## 2026-09-21 — The World stand set, raw sequence playback, barrage and time stop (user-authorized)

- `roblox-r6-animation`: new reference `the-world-clips.md` decoding the eight Moon
  Animator clips of a free-model The World (piston punches, a torso-engine barrage at six
  hits a second, end-to-start combo chaining, a 2.5 s float idle, 1 to 2 stud limb
  translations) with the raw decodes under `references/decodes/` and
  `scripts/AnalyzeClips.js` to summarise them.
- `Poser.fromSequence`, `Poser.wrapsOf` and `Poser.sample` play a KeyframeSequence
  through the Poser with no upload; `Clips.lua` now carries the stand float, barrage,
  heavy, combo, time stop and stopped clips plus DIO's bladed point and time stop poses.
- SKILL.md: a stand rush rung in the decision framework, the stand numbers, piston punch
  and combo chaining rules, the still bladed point the user holds, and three feedback entries.
- `roblox-vfx-craft`: The World's time vocabulary (clock gather, tick pop, gold echoes,
  charge and heartbeat idle), the barrage and time stop numbers, the voice-line beat table,
  the dead-mesh diagnosis, and worked examples `Moves.lua`, `TimeStop.lua`,
  `MovesServer.lua` with the reworked `SummonVfx.lua`.

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
