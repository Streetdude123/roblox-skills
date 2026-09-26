# Frieren study: the effects

Lepy (2026-09-26): "Frieren i think has the most beautiful and amazing animation i have ever seen ... improve the vfx to be like frieren too". His picks: Frieren is the default style, and the first effects are a Zoltraak beam, a barrier shield, and light with flowers. The animation half (timing, acting, the cast beat and the R6 clips that go with these effects) is in `roblox-r6-animation/references/study-frieren.md`.

## Contents

- Sources
- The effect language in eight rules
- Measured timings
- Measured palettes
- The three builds
- What was checked offline and what was not
- Where this meets his earlier rules

## Sources

Sakugabooru clips sheeted frame by frame (`ref_sheets.py`) and at 2 fps overviews; not committed.

| Post | What it shows |
| --- | --- |
| 238377 | the Zoltraak finisher: calm face, hair lift, light pillars, the rune circle, the firing line, inverted impact frames, the burst, the white-out, the beam with a green-black fringe |
| 262048 | the barrier: tiny vertical light lines, then pale cyan hex cells with a thin bright outline forming where the hits land, breaking into small ring fragments |
| 249521 | thin white light lines with a glowing head zipping across a floor, white crescent strokes, a hex panel by a hand and a column of cyan hex cells, flat grey cel smoke, a thin white shock ring, a flat white-blue beam along the floor |
| 251534 | a red beam with a black orb in a bright rim, flat blue-black silhouettes under it, cream cel debris with black outlines, orange spark lines, a violet radial burst, a cyan-white light burst with glitter and grey cel smoke at its base, hair whipping in the close-up |
| 244153 | night: a close-up that holds the face while the hair streams, a small light over a vast field |

The flower field spell is from episode 2 (Frieren Wiki): Frieren conjures a field of Himmel's favourite flowers; it was Flamme's favourite spell. It was not measured from footage.

## The effect language in eight rules

1. **Flat cel light.** Effects are flat colour shapes with hard edges and a white core; gradients are rare. On Roblox: untextured beams for lines and bands, few layers, hard-edged sprites.
2. **Thin lines.** Vertical light pillars, horizontal streaks, the firing line, glowing heads on moving lights. Lines carry the motion; blobs do not.
3. **Four-point star glints** mark the points of power: the circle's centre, the muzzle, a new barrier cell, the light in the hands.
4. **Geometric magic.** Circles of rings, spokes, rune bands and small sub-circles; barriers of hex cells. In this show the geometry is the look. It is drawn as thin bright lines over a faint flat fill, never as solid shapes.
5. **Calm before, burst after.** The caster holds still while the light gathers; the release is one or two frames of burst, then a white-out (timings below).
6. **Light tells the beat.** The scene takes the spell's colour; figures drop to silhouettes (251534, the violet and red scenes of episode 25). On Roblox: a PointLight on the caster and at the hit, a white screen flash on the release.
7. **Cel aftermath.** Two-tone grey smoke with hard edges, black debris silhouettes, white-yellow spark lines, a thin shock ring.
8. **Defence where the hit lands.** Barrier cells form 1 to 4 at a time where a hit comes and break after 0.3 to 0.4 s; a full hex sphere is the rare big form (episode 26).

## Measured timings

Zoltraak finisher (238377, 23.976 fps):

| Beat | Time | Frames |
| --- | --- | --- |
| calm, hair drifting | 55.09 to 55.46 s | 9 |
| head turns, hair whips | 55.50 to 55.59 s | 3 |
| staff up, soft white pillars rise round the body | 55.59 to 55.80 s | 5 |
| the circle draws and spins up until it fills the frame | 55.88 to 56.55 s | 16 |
| thin horizontal firing line, then a band, then a cross of lines | 56.42 to 56.55 s | 3 |
| inverted impact frames (black splat, ring and cross on white; a star glint on black) | 56.59, 56.63 s | 1 + 1 |
| white burst in the circle's centre, green fringe | 56.67 to 56.71 s | 2 |
| white-out, then the beam from the side | 56.76 to about 60.5 s | |

Barrier (262048): tiny vertical light lines 1.25 to 1.58 s; the first cells 1 to 4 at 1.63 s; a cluster of about 6 by 1.96 s; the cells break into small rings at 2.0 s; round the caster 2.04 to 2.38 s, 4 to 8 cells, each cluster lasting 0.3 to 0.4 s.

## Measured palettes

k-means on the frames:

| Source | Colours |
| --- | --- |
| Zoltraak circle | #f3f6fb, #ccd2e9, #aca7d5, #8780b2 (white to lavender) |
| barrier edges and fill | #c0e3e0 edges, #9cb8b9 and #7f9e9f fill |
| cupped light | #e8efeb, #dce1dc, #c3cbc3, #b0bd9b (near white, faint green) |
| violet beams | #3110b0, #6920d3, #ac4dd6, #dd85ed |
| red scene | #e51e34, #d00111, #9e000a, #770108 |

`Config.frieren.lua` holds them as `Config.Palette`. The green fringe, the ink partner, the smoke greys, the petal blue, the flower heart and the stem are chosen, not measured.

## The three builds

Install: `Config.frieren.lua` as `ReplicatedStorage.Frieren.Config`, `Tw.lua` and `FrierenVfx.lua` as `ReplicatedStorage.Frieren.Modules.Tw` and `.FrierenVfx`, then run `FrierenTemplates.lua` once in Edit mode (command bar or `execute_luau`). It builds the templates as a real instance tree in `ReplicatedStorage.Frieren.Assets.Vfx` (537 instances) and the `StarterGui.FrierenFlash` ScreenGui. The runtime clones the templates on the client into `workspace.FrierenFx`. Textures are ids from his packs (`Emitters.TEX`).

Each effect runs on the schedule of its clip in `roblox-r6-animation/scripts/ExampleFrieren.lua`.

### Zoltraak (`FrierenVfx.zoltraak(character)`, 2.4 s)

| Time | Clip event | Effect |
| --- | --- | --- |
| 0 to 1.3 s | the head finds the target, the arm rises | `Updraft`: motes, thin rising streaks and small glints at the feet (the hair lift) |
| 0.4 s | the arm rises | `Pillars`: 10 thin vertical light beams round the body flick on over 0.2 s and fade by 0.9 s |
| 0.65 s | circle | `Circle` 2 studs ahead of the hand, facing the aim: 160 beams (outer, band, inner, mid and core rings, 8 spokes, 36 rune ticks, 8 sub-circles) draw on in 0.27 s by an `Order` attribute while the circle grows from 0.35 to 1 of radius 3 and spins down from 6.2 to 1.2 rad/s over 0.65 s (the finisher's 16 drawings) |
| 1.3 s | fire | the firing line: a 0.07 stud white beam to the hit point for 0.13 s (3 drawings) |
| 1.43 s | beam | a flash and a star glint in the circle, specks, the white screen flash (0.1 transparency, fading from 0.08 s over 0.2 s), the beam (white core 0.55, lilac glow 1.25, green fringe 1.55, ink edge 1.9 behind it) grows in 0.06 s; streaks fly along it at 70 a second; at the hit a flash, a glint, a thin ring, 24 sparks, 10 cel smoke puffs, 12 black debris and a lilac light at 3, with sparks and smoke every 0.12 s |
| 2.05 s | beamEnd | the beam shrinks over 0.18 s, the circle over 0.3 s |

`Config.Zoltraak` sets the radius, the distance ahead, the circle time, the line time, the hold, the range, a width scale and the flash. No impact frames: his move-rung pick is a flash under 0.1 s.

### Barrier (`local shield = FrierenVfx.barrier(character)`, `shield.hit(point)`, `shield.drop()`)

- The raise: `Ticks` (10 short vertical light lines) flicker for 0.33 s, then a panel of 19 hex cells (two rings round a centre) forms in front of the chest: the centre at 0.33 s with a flash and a glint, ring 1 at 0.45 to 0.55 s, ring 2 at 0.57 to 0.67 s. Each cell: 6 edge beams (0.06, `#c0e3e0`), 6 soft rim beams (0.22 at 0.72 transparency), a flat fill of two trapezoid beams (0.84 to 0.7 transparency), flash, glint, ring-fragment and shard emitters. Cells sit on a sphere of radius 3.2 round a point 1.2 above the root, circumradius 0.7, and follow the root every frame.
- `hit(point)`: a cluster of 5 cells (the one under the hit with a flash and glint, then 4 neighbours from 0.04 s, 0.03 s apart) forms on the sphere where the hit comes; after 0.35 s each cell breaks into 5 small rings and 3 shards and shrinks in 0.12 s. A cell that would land on an existing one flashes it instead.
- `drop()`: every cell breaks 0.025 s after the one before.

From the player camera the panel's top two rows show over the head and shoulders; the lower rows are behind the body (a preview of the geometry, not a capture).

### Light and flowers (`FrierenVfx.flowers(character)`, 11.3 s)

| Time | Clip event | Effect |
| --- | --- | --- |
| 0 s | | a low `Updraft` at the feet |
| 0.75 s | gather | `Cup` between the hand tips (followed every frame): a soft glow, small star glints, short thin streaks, rising motes, a mint PointLight rising to 2.2 over the gather |
| 1.9 s | release | the cup fades; `Rise`: a thin light pillar 60 studs up with a halo and a star glint at its base, fading after 0.6 s |
| 2.25 s | bloom | 110 flower clumps (3 blooms each: a stem, 5 blue petals, a pale heart) spread outward at 14 studs/s from 2.5 to 14 studs, each rising out of the floor in 0.3 s with a back-out ease; every third one pops specks and a glint; drifting specks over the field |
| bloom + 7 s | | each flower fades and sinks in 0.8 s, in the order it came |

Flowers stand on the floor under each spot (a raycast), at least 1.1 studs apart.

## What was checked offline and what was not

Checked without Studio (a scratch harness that runs the builder and the runtime in the Luau command line tool against the Roblox API dump: every class, property name, value type and enum item, sequence keypoint rules, tweenable types, a clock that drives `task`, tweens and `RenderStepped`): the builder makes the tree above; the three effects run to the end with no error; every instance is cleaned up (0 left in `FrierenFx`); the circle reaches radius 3 facing the aim; the beam line stops at a wall; barrier corners sit 3.28 from the centre with 0.7 edges; flowers reach their floor height. Peaks: Zoltraak 420 instances and 175 beams, the barrier with two hits 696 instances and 336 beams, the flower field 4421 instances (2310 parts). A box preview of the geometry from the player camera set the circle radius (3, not 2.2: at 2.2 the body hid half of it) and the barrier lift (1.2: at 0.5 the panel was behind the body).

Not checked (Studio needed):

- The width axis of the flat beams (`FaceCamera = false`): the band ring and the hex fill assume the width runs along each attachment's Y axis, as the torrent joints did (water.md). If they show edge-on, swap the attachments' X and Y.
- That an untextured beam draws as a solid strip, and how each pack texture looks at these sizes.
- The frame cost: 336 beams on the barrier and 2310 flower parts are guesses at a budget; profile the first cast.
- The flash and the white core on his day lighting.

## Where this meets his earlier rules

- "Too geometric" was said of Neon solids, and of UI rings and borders on a water block. The Frieren circle and hexes are geometric because the reference is; here they are thin light beams over faint flat fills with glints and fragments. Ask him about the geometry on the first review.
- No impact frames on a move (his Bull Leap pick): the finisher's inverted frames are not built; the release gets a 0.08 s white flash (his water laser pick).
- No text: the rune band is ticks of three lengths, not glyphs.
- No Highlight on the rig.
- The identity rule still holds: a character with its own look (water, anti-magic) keeps its vocabulary; the Frieren rules decide how it is drawn.
