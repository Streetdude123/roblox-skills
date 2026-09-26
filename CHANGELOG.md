# Changelog

Maintenance history for this repository. Entries were previously kept as dated
`CHANGELOG-*.md` files inside the `roblox-resource-acquisition` package; they
now live here so the shipped skill package carries only what an agent using it
needs.

## 2026-09-26 (later) - New skill roblox-sfx-synth (user-authorized)

- `roblox-sfx-synth`: a numpy/scipy synth (`scripts/sfx.py`) with 16 anime SFX presets (hits, whooshes, charge/aura/summon, UI), a checker (`scripts/check.py`) for peak, RMS, envelope, band energy, loop seam and a spectrogram PNG, `SKILL.md` with the workflow, rules and measured numbers, and `references/recipes.md`.

## 2026-09-26 — Parry signals, Bull Leap rebuild, smooth walks, clean ragdoll (user-authorized)

- roblox-vfx-craft: attack tells (white, amber, red), parry vs block by value, wall stop for forced motion; his feedback logged.
- roblox-r6-animation: Bull Leap wind-up rebuild, smooth-max walk height (no snap), per-style walks, ragdoll settle and per-part push; his feedback logged.

## 2026-09-25 (later) — Water Mage block rebuilt with the water rules (user-authorized)

- `roblox-vfx-craft`: `references/water.md` section 8 (centre attachments for facing sprites, rim attachments for edge spray, the Glass lens trap, white stacking, the blotchy dark partner, rim-first hit reactions for the player camera, the take camera that turns the body, the cost). `SKILL.md` feedback log and `references/taste.md` log his sentences.

## 2026-09-25 — Water construct research and the Judgement's Hammer rebuild (user-authorized)

- `roblox-vfx-craft`: new `references/water.md` (VFX Apprentice, the Creator Hub waterfall tutorial, DevForum mesh VFX and water threads, Real Time VFX, 2D water animation guides, translated to Roblox: the four water properties, edge break-up, line/fill/shadow/foam layers, the waterfall numbers, mesh VFX practice, and what the hammer rebuild proved: framing for the player camera, a free model hand mesh, fractional torrent textures, camera-facing swing trails, the cost of a big construct). `SKILL.md` gains three rules, the feedback log entry and the reference index line; `references/taste.md` logs his sentences.

## 2026-09-24 (night, final) — Basketball commission feedback (user-authorized)

- `roblox-r6-animation`: `references/project-style.md` logs his sentences on the basketball clips and the code style, with the held-ball method (the ball as a Motor6D keyed in torso space, hands reached after the torso) and the measured numbers.
- `roblox-vfx-craft`: feedback log (`SKILL.md`) and `references/taste.md` ("The kit rule") log his sentences on collecting free VFX packs and a barebones UI, the prize tier template ladder, the confetti texture trap and the first-cast frame times.

## 2026-09-24 (night, last) — Reference study and the water VFX overhaul (user-authorized)

- `roblox-vfx-craft`: new `references/study-atomic.md` (what a Roblox "I AM ATOMIC" recreation does to look amazing: a dark stage in the effect hue, one hue family with white-hot cores, thin lines, an ambient layer in every frame, foreground depth, a rim light, cel textures, repeated shapes, ground reaction, editing; and how it maps to a MOVE rung). `references/taste.md` and the feedback log (`SKILL.md`) gain his sentences (including "Don't copy the text though"), his picks, the water overhaul (dark partner layers, anime sprites from the kit, thin lines, spiral trail streams, lights on caster and target, a casting aura, a dash wake, a real ScreenGui flash) and five traps (Glass hides inner parts, per-frame Trail sampling jags fast spirals, a dark partner inside an orb reads grey, recorder scale 0.6 under memory pressure, F5 when the MCP play start sticks).

## 2026-09-24 (night, later) — Video rule changed; Water Mage video notes (user-authorized)

- `roblox-r6-animation`: `references/pipeline.md` records his new rule ("Record videos from now on please, until i say stop recording videos") and adds step 8 (memory pressure and a warm-up run before takes, hide the cursor, turns that follow the camera, a high rear camera past his accessory); `references/project-style.md` logs the sentence.
- `roblox-vfx-craft`: feedback log (`SKILL.md`) logs the sentence and the water video.

## 2026-09-24 (night) — Water Mage kit: water VFX, wand overlay clips (user-authorized)

- `roblox-vfx-craft`: feedback log (`SKILL.md`) and `references/taste.md` gain the Water Mage entry: the water vocabulary built
  from the kit's water sheets and waterfall beams (bubble, charge, splash, laser), his sentences on the wand, the water VFX,
  the beam start ("cuts off here not smoothly") and the simple selector GUI, and eight traps (disabled template emitters never
  emit from Rate, black-background beam textures need LightEmission 1, a beam must taper and fade in at its source, a glass
  ball reads as a crystal, mist puffs read as smoke, curved long beams do not spiral, muzzle mist hides the beam, name clashes).
- `roblox-r6-animation`: `references/project-style.md` gains the Water Mage entry: upper-body overlay clips over the walk with
  root-space arm and head keys, the wand as a pointer joint, the checks, and three traps (an upside-down union, WeldConstraint
  parts in Edit strips, a hold that overshoots an event).

## 2026-09-24 (later) — Block, parry and guard break clash VFX (user-authorized)

- `roblox-vfx-craft`: feedback log (`SKILL.md`) and `references/taste.md` gain the guard clash entry: white-gold metal sparks
  with Asta's red, new `Clash` and `ShieldBreak` templates from the kit, the layer sizes and counts per kind, the first-cast
  frame times, and five traps (full-size kit stars read as a sparkle field, additive gold blooming to white, red shards
  turning pink, a ring that lay flat, a puppet spawned before the server saw the move).

## 2026-09-24 — Smooth ragdoll, Deepwoken parry, Bull Leap, grounded dash (user-authorized)

- `roblox-r6-animation`: feedback log (`references/project-style.md`) gains the ragdoll smoothness entry (the attacker's
  client runs a ragdolled dummy's physics; a server-run body stepped every 3 to 5 frames) and the 2026-09-24 entry: a
  Deepwoken guard (parry window and block from the press, parry only while stunned after a 0.2 s shaky time, the queued
  block that must re-wait an extended stun), a grounded dash (foot contacts of 2 to 3 frames at 55 studs/s, the `carry`
  swing capped at 0.4 studs, a two-key skid, blade drag angles, a square trailing grip) and Bull Leap (R6 two-hand limits,
  the `lift` root curve, late landing feet), with the measured checks and the camera-lock trap for side takes.
- `roblox-vfx-craft`: feedback log (`SKILL.md`) and `references/taste.md` gain the ragdoll entry and the Bull Leap and dash
  VFX: the reference read, the floor-material crater with an open rear arc, flat slabs, no smear during root travel, kit
  `Wind1` rings instead of view-axis streaks, floor-tinted dust, and how to judge a fast effect (emitter TimeScale 0.08 or
  video) with the frame numbers.

## 2026-09-22 (night) — Weapons on R6 and the Asta anti-magic vocabulary (user-authorized)

- `roblox-r6-animation`: new `references/weapons.md` from the Asta greatsword kit (draw from the grimoire,
  sheathe by a toss into the pages, a four-hit combo): the grip as a three-axis joint (R6 has no visible wrist),
  sword keys written as a hand direction and a blade direction solved on the arm with Nelder-Mead, the physical
  twist limit (the shoulder pivots on the arm's inner edge), Euler branch continuity and slerp midpoints (a
  branch flip sent the blade tip 2.5 studs under the floor), blade tip and turn checks, the onion-skin view,
  props that grow out of props, the memoized solve cache (4.8 s to 0.07 s) and the welded-part resize cost.
  New `scripts/WeaponRig.lua` and `scripts/WeaponStrip.lua`; SKILL.md index and the feedback log updated.
- `roblox-vfx-craft`: feedback log and taste updated with "definitely not electric, just match the vfx with the
  references" and the anti-magic vocabulary built from the kit (black flame wisps over a dark red rim, red
  specks, black ash, red pages), plus the lessons on black puffs, hit placement, untinted kit pieces, a
  floating companion prop and capture time scales.

## 2026-09-22 (late) — Motion-first animation: spline curves, overlap, springs, planted feet, measured (user-authorized)

- `roblox-r6-animation`: rewritten around the measured cause of "too much still frames": Poser's legacy eases
  arrive at zero speed, so every key was a stop (authored moves over 1 s parked 56 to 90% of the time against
  16 to 50% in the professional references). `Poser.lua` gains `curve = "spline"` (auto, flat, smooth, step
  keys with tension), `lag`, `springs` (second order dynamics presets), `life`, a `post` pass, the inertial
  blend, `check`, `dump`, `posesAt` and `each`; legacy clips sample identically. New `Feet.lua` (R6 legs
  planted on floor targets after the torso), `EditStrip.lua` (Edit-mode pose strips and the foot check),
  `LoadTest.lua`, `ExampleClips.lua` (a guard and a right cross built on the method) and `motion_check.js`.
  New `references/motion-metrics.md`; `principles.md` rewritten with the research (posing checklist, timing in
  frames, overlap, moving holds, springs, game feel, recipes); SKILL.md, pipeline, review, sources, template and
  feedback log updated. `tests/test_motion_check.py` covers the Node checker.

## 2026-09-22 (night, last) — Walk2 walk, bladed idle, rigid-leg feet (user-authorized)

- `roblox-r6-animation`: DIO's walk rebuilt on Walk2 (emm1gar) from the user's BestWalkAnimR6 pack after a
  side-strip audition of all four references; `cyclic` hermite key curves, `legDepth` sole-corner body height,
  `legIK` / `dropFor` rigid-leg foot targets for the copied chain, a bladed idle, a landing fold that folds
  legs straight up into the hips. New sections "Planted feet on rigid legs" (r6-mechanics.md) and "Walk2 as
  DIO's walk" (walk-cycles.md); the feedback and the measurements in project-style.md.

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
