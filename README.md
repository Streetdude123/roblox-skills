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

Authors, verifies and hands off R6 character animation in code: idle, walk and
run cycles, attacks and summons, weapon or stand overlays. Every amplitude and
timing in it was measured from real clips (a professional idle, run and
landing set, four community walk cycles, a professional sword kit, the Roblox
defaults) rather than guessed, and the skill keeps a feedback log so it grows
with each review.

Package layout:

- `SKILL.md` - the decision framework, the workflow, the "model for everything"
  rules taken from a professional idle (one engine, lagged secondary motion,
  translation builds the pose, amplitude follows energy, nothing is still), the
  measured numbers for idle, walk, run, landing and attacks, and R6 posing
  rules.
- `references/` - the decoded clips frame by frame (idle-run-land,
  walk-cycles, attack-timing), the pose space and runtime pipeline, and the
  Moon Animator round trip.
- `scripts/` - `Poser.lua` (key and procedural clips written to
  `Motor6D.Transform` in PreSimulation, plus a KeyframeSequence baker),
  `Locomotion.lua` (a per character idle, walk, run, jump and land controller
  that replaces the Roblox Animate script), `Clips.lua` (worked examples),
  `ReadClips.lua` and `serve.js` (decode any KeyframeSequence to text),
  `Strip.lua` (a motion strip so one capture shows a whole cycle) and
  `Bake.lua`.

The Lua scripts run inside Roblox Studio through an execute-Luau bridge; they
are not covered by the Python test suite.

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
