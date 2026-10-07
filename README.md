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
  Poser runtime contract, diagnosis, sources, decoded reference clips, and
  project review history.
- `templates/clip-plan.md` - brief, beat table, motion layers, measurements,
  review record.
- `scripts/` - `Poser.lua` (runtime with `curve = "spline"`, `lag`,
  `springs`, `life`, `post`, the inertial blend, `check`, `dump`, `bake`),
  `Feet.lua` (planted R6 legs), `ExampleClips.lua` (a guard and a right cross
  built on the method), `EditStrip.lua` (Edit-mode pose strips and the foot
  check), `LoadTest.lua` (fresh module copies from `serve.js`),
  `motion_check.js` (the metrics on decode text), the DIO project clips,
  capture, decode and bake helpers, and `check_decode.py`.

Legacy Poser clips play exactly as before. The Python decode checker and the
Node motion checker are covered by the repository tests; Roblox runtime,
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
  `sound.md`, `verification.md`, `ambient.md` (canopy light shafts, beam
  butterflies, zone mist, weather rain).
- `scripts/` - `Tw.lua`, `Emitters.lua`, `Kit.lua`, `CameraRig.lua`,
  `ScreenFx.lua`, `ImpactFrames.lua`, `SpeedLines.lua`, the two worked
  examples `SummonVfx.lua` and `UltimateVfx.lua` with their client, server and
  config files, and the intake tools `ScanPack.lua`, `MeshGallery.lua` and
  `BlankDeadSounds.lua`.

The Lua scripts run inside Roblox Studio through an execute-Luau bridge; they
are not covered by the Python test suite.

### `roblox-sfx-synth`

Creates original anime style sound effects from code: hits and punches,
whooshes and slashes, charge ups, aura loops, summons, time stops and UI blips.
Voice lines are not made here. The agent cannot hear, so each sound is checked
by its numbers and a spectrogram image before the user listens.

Package layout:

- `SKILL.md` - the workflow, the layer model, the rules, the numbers measured
  on the presets, reading the spectrogram, the Roblox upload limits and the
  feedback log.
- `references/recipes.md` - each preset's layers and the numbers to change.
- `scripts/sfx.py` - the numpy/scipy synth and 16 presets; writes 44.1 kHz
  mono WAV files.
- `scripts/check.py` - peak, RMS, envelope, band energy, loop seam and a
  spectrogram PNG.

Needs `pip install -r roblox-sfx-synth/requirements.txt`. The scripts are not
covered by the test suite.

### `roblox-sfx-finder`

Gets realistic sound effects by finding them on the internet first. It searches
free-to-use libraries (BigSoundBank, freesound CC0, Mixkit, 効果音ラボ, Kenney),
downloads, measures and ranks the results, and searches the Roblox Creator
Store's licensed partner library (ProSoundEffects, APMOfficial) for ready asset
IDs. It then trims, pitches and layers real recordings into anime and
Frieren-style SFX, with license credits for every file. Synthesis with
`roblox-sfx-synth` is the last resort.

Package layout:

- `SKILL.md` - the find-first workflow, picking rules, measured numbers, the
  spectrogram guide and the feedback log.
- `references/` - `sources.md` (sources, licenses with evidence, exclusions),
  `frieren.md` (team, evidence, sound brief, search terms), `layering.md`
  (principles, reference ranges, recipe format, synthesis fallback).
- `scripts/` - `find.py` (web and Roblox store search, download, measure,
  rank), `build.py` (layer recordings, and synth presets from
  `roblox-sfx-synth`, from a JSON recipe through pedalboard; writes credits),
  `check.py` (measure any audio file, spectrogram PNG), `Audition.lua`
  (measure store IDs in Studio, untested).

Needs `pip install -r roblox-sfx-finder/requirements.txt`. The scripts are not
covered by the test suite.

### `roblox-ui-design`

Designs and builds professional game UI - HUDs, menus, shops, inventories,
settings, popups, toasts and reward screens - that work on phones, tablets,
desktop, console/TV and VR, built as real instance trees in the game's own
style. It carries the lessons of five assigned UI videos (C.R.A.P., every UI/UX
concept, Riot's UI design episode, game UI as part of the game, inventory UX),
the design system (hierarchy, spacing, type, colour, depth and motion tokens),
the device rules measured from Roblox's own device presets and touch-control
source (thumbstick and jump zones, top bar, safe areas, TV-safe margins,
gamepad selection, VR panel), the style families with a list of what reads as
AI-made, and the user's UI taste log. The tools were proven on a full
Undertale-style sample (HUD, shop with confirm, settings, round result) captured
on seven simulated devices.

Package layout:

- `SKILL.md` - session start, the user's rules, the workflow, the principles,
  the numbers, the device rules, the sizing method, the engine traps and the
  definition of done.
- `references/` - `lesson-videos.md`, `principles.md`, `devices.md`,
  `design-tokens.md`, `motion.md`, `components.md`, `game-ui.md`, `styles.md`,
  `roblox-ui-engine.md`, `verification.md`, `taste.md`, `sources.md`.
- `templates/ui-brief.md` - the brief to fill before building.
- `scripts/` - `Build.lua` (Edit-mode builder with theme tokens, HSL ramps and
  contrast), `Ui.lua` (runtime press/hover/ink states, open/close, toasts,
  counters, bar trails, key hints per input), `Fit.lua` (one root UIScale per
  device class), `Preview.lua` and `Devices.lua` (simulated-device previews
  through `StudioDeviceSimulatorService`), `Audit.lua` (off-screen, thumb zones,
  TV-safe, target and text size, contrast, overflow, nested buttons, overlaps,
  consistency sets), `Install.lua` and `serve.js` (push sources into a place),
  `icons.html` (SVG icon sets to PNG), `capture/` (window grab, letterbox trim,
  contact sheets, pixel icons) and `examples/PixelLab.lua` (the verified sample).

The Lua scripts run inside Roblox Studio through an execute-Luau bridge and the
PowerShell tools on Windows; they are not covered by the Python test suite.

### `roblox-modeling`

Models, textures and exports 3D assets for Roblox in Blender 5.2, driven from
Python in background mode - props, weapons, items, accessories, character
parts, terrain pieces and VFX meshes. It carries the lessons of three assigned
modeling videos (six modeling principles, the game asset workflow, every
modeling concept), the Roblox mesh, texture, importer and avatar numbers, and
the user's modeling taste: intricate creative detail on items, calm terrain,
controlled imperfection, and a style scan of the target game before any model.
The methods were proven on four practice builds reviewed over several rounds:
a mid-poly crate (3,900 triangles), a high-to-low longsword (41,810 baked into
938), a terrain rock formation (2,158) and an ornate chest with imperfection
(463k baked into 5,304), all previewed in Studio at the exact Blender size.

Package layout:

- `SKILL.md` - the user's rules, the start-of-task steps, budgets per asset
  class, the method, the definition of done, the tools and the measured traps.
- `references/` - `lesson-videos.md`, `roblox-specs.md`, `hard-surface.md`,
  `bake-and-texture.md`, `uv-and-texel.md`, `organic-and-terrain.md`,
  `imperfection.md`, `style-scan.md`, `review.md`, `studio-preview.md`,
  `taste.md`, and `sheets/` (the final review sheet of each practice build).
- `scripts/blender/rbx.py` - the modeling library (bmesh builders, sweeps and
  lathes, ornament outlines, modifier stacks, chart seams, hidden-face UV
  shrink, stacked copies, multi-object packing, per-part and mask bakes, numpy
  noise, Voronoi and vertex sculpting, curvature, coverage dilation, audits,
  review renders, FBX and mesh JSON export); `preview_export.py`; and
  `examples/` (`crate.py`, `sword.py`, `rock.py`, `chest.py`).
- `scripts/studio/` - `StyleScan.lua` (read-only style scan of a place),
  `PreviewMesh.lua` (EditableMesh + SurfaceAppearance preview under the local
  camera) and `serve_preview.js` (chunked local file server).

The Blender scripts need Blender 5.2 and run with `blender --background`; the
Lua scripts run inside Roblox Studio through an execute-Luau bridge. None of
them are covered by the Python test suite.

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
