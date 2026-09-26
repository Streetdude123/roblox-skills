# roblox-skills

Agent skills for Roblox development.

## Skills

### `roblox-resource-acquisition`

Finds, evaluates, verifies, packages, refreshes, and validates Roblox community
resources (libraries, modules, frameworks, plugins) as reusable agent skills.
Its core discipline: **trust** (a user/project curation decision) is tracked
separately from **verification** (what has actually been proven by executed
tests), and neither is ever silently upgraded into the other.

Package layout:

- `SKILL.md` — the workflow: decide whether acquisition is warranted, consult
  the curated registry, discover/qualify/understand/verify a resource, generate
  a dedicated resource skill, validate and repair it, and record the evidence.
- `references/` — deeper contracts the workflow delegates to (curated-registry
  and learnings-store ownership rules, search playbook, evaluation rubric,
  generated-skill contract, testing protocol, repair loop).
- `templates/` — portable YAML/Markdown starting points for curated registry
  entries, learning entries, evidence records, and generated resource skills.
- `scripts/` — structural validators (see below).

User/project data (the curated registry and the learnings store) lives
**outside** the skill package by design; the package ships only contracts and
templates for it.

### `roblox-r6-animation`

Authors, measures and refines R6 animation in code at a professional hand-keyed
standard, and hands it off as a verified KeyframeSequence. The method is
motion-first: poses are blocked and checked, then a motion pass gives every clip
spline curves that keep their speed through breakdowns, offset joints, keyed
follow-through, springs on carried parts, a life layer so holds never freeze,
and planted feet solved after the torso. Clips are measured against decoded
professional references before anyone looks at them.

Package layout:

- `SKILL.md` - what made earlier AI clips look dead (measured), the method,
  the checks with their target ranges, verification and handoff, R6 rules.
- `references/` - the craft (posing checklist, timing in frames, overlap,
  moving holds, springs, game feel, recipes), the motion metrics with the
  professional and earlier Claude numbers, R6 transform and contact math, the
  Poser runtime contract, diagnosis, sources, decoded reference clips,
  project review history, the frame-by-frame reference study method, the
  measured study of the target Moon Animator fight, cinematic shots, the
  real-motion pipeline, and real human timing measured from motion capture.
- `templates/clip-plan.md` - brief, beat table, motion layers, measurements,
  review record.
- `scripts/` - `Poser.lua` (runtime with `curve = "spline"`, `lag`,
  `springs`, `life`, `post`, the inertial blend, `check`, `dump`, `bake`),
  `Feet.lua` (planted R6 legs), `ExampleClips.lua` (a guard and a right cross
  built on the method), `ExampleMoves.lua` (a throw, a heavy landing, a superhero landing and a
  leap strike in the target style), `EditStrip.lua` (Edit-mode pose strips and the foot
  check), `LoadTest.lua` (fresh module copies from `serve.js`),
  `motion_check.js` (the metrics on decode text, with range and sweep),
  `video/ref_sheets.py` (frame-by-frame sheets, cuts and holds of a
  reference or a take), `r6_render.py` (an R6 box preview of decode text
  without Studio), `bvh_to_r6.py` (motion capture to R6 decode and Poser clip),
  `beats.py` (moves and holds of the hands, feet and head), `mocap_study.py`
  (strike, jump and gait timing on captures), `stylize.py` (exaggeration, the
  cartoon animation filter, snap, slow in and slow out), `poser_offline.py`
  (`Poser.check` and `Poser.dump` on the Luau command line tool, no Studio),
  `feet_check.py` (the foot check on decode text), `faults.py` (common
  animation faults on decode text), the DIO project clips,
  capture, decode and bake helpers, and `check_decode.py`.

Legacy Poser clips play exactly as before. The Python decode checker, the
Node motion checker, the Python preview, retarget, beat, stylize and foot
tools and the offline Poser runner (when `luau` is on PATH or in `LUAU`) are
covered by the repository tests; Roblox runtime,
visual quality and replication still require Studio verification.

### `roblox-vfx-craft`

Builds ability VFX from the VFX packs that ship with each place: small stand
summons, moves, and full cinematic ultimates with a scripted camera, anime
impact frames, screen effects and a two-group sound mix. It carries the tone
ladder (summon, move, cinematic), the taste log of every review sentence, the
pack intake routine (script scan, archive, mesh gallery, dead sounds, template
folder, join-time warm-up), the module APIs, the sword ultimate's schedule and
cut list, the mix numbers measured from a recording, and the Studio
verification routine (quality level, capture cache, phase polling, first-cast
frame profiling).

Package layout:

- `SKILL.md` - the tone ladder, the workflow, the rules he taught, the
  measured numbers and the feedback log.
- `references/` - `taste.md`, `kit-workflow.md`, `modules.md`, `cinematic.md`,
  `sound.md`, `verification.md`.
- `scripts/` - `Tw.lua`, `Emitters.lua`, `Kit.lua`, `CameraRig.lua`,
  `ScreenFx.lua`, `ImpactFrames.lua`, `SpeedLines.lua`, the two worked
  examples `SummonVfx.lua` and `UltimateVfx.lua` with their client, server and
  config files, and the intake tools `ScanPack.lua`, `MeshGallery.lua` and
  `BlankDeadSounds.lua`.

The Lua scripts run inside Roblox Studio through an execute-Luau bridge; they
are not covered by the Python test suite.

## Using these skills in a new chat

1. Make the relevant skill folder and project instructions available to the agent.
2. Name the requested skill, such as `/roblox-r6-animation`, and provide the
   action, rig or project, reference, constraints, and intended handoff.
3. For animation, connect Studio when you need instance edits, playback,
   captures, or runtime verification. The skill also supports source work when
   Studio is unavailable and requires the result to state that limitation.
4. Keep feedback specific to the clip and the visible issue. Preserve useful
   project preferences without turning them into rules for every animation.

## Validator scripts

All four validators require Python 3.8+ and PyYAML
(`pip install -r roblox-resource-acquisition/requirements.txt`). They exit 0 on
pass, 1 on validation failure, and 2 when PyYAML is missing. Passing is
structural evidence only — it never proves quality, safety, or runtime
behavior.

| Script | Validates |
|---|---|
| `validate_curated_registry.py` | curated registry entries (schema, identity, duplicate slugs) |
| `validate_learnings_store.py` | learnings-store entries (schema, kind/scope rules, no smuggled trust state) |
| `validate_resource_record.py` | portable evidence records (schema plus trust/verification state consistency) |
| `validate_skill.py` | a generated resource skill's SKILL.md (required sections, provenance, verification recipe) |

## Development

```sh
pip install -r requirements-dev.txt
python3 -m pytest
```

Tests live in `tests/` at the repository root. Maintenance history is in
[CHANGELOG.md](CHANGELOG.md).
