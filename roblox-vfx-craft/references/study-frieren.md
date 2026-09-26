# Frieren study: the effects

Lepy (2026-09-26): "Frieren i think has the most beautiful and amazing animation i have ever seen ... improve the vfx to be like frieren too". His picks: Frieren is the default style, and the first effects are a Zoltraak beam, a barrier shield, and light with flowers. The animation half (timing, acting, the cast beat and the R6 clips that go with these effects) is in `roblox-r6-animation/references/study-frieren.md`.

## Contents

- Sources
- The effect language in eight rules
- Measured timings
- Measured palettes
- The builds
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
| 238364 | episode 2, the flower field: a dense carpet of pale blue five-petal flowers under a sunset, then from above a round patch of them inside a ruin with Frieren at its edge and big flat blue petals streaming across the frame; later a single flower that glows pale blue under a hand, and glowing blue light creatures at night |
| 238344 | episode 2, Fern's practice Zoltraak: a thin violet line with a dark outline crossing to a far rock, which is left with a hole |
| 238347 | episode 2, Fern's cast: a big pale circle behind her, flat dark green leaves blown past, her hair thrown straight back, then a white-out |
| 241286, 241279 | episode 9, Fern's volley: small cyan-white glyph circles appear round the staff one after another and each fires a fat white comet bolt with a blue rim; thin white rings round the beam where it leaves; short white dashes and thin white arcs after each hit; white radial spike bursts; distant hits as small starbursts; a long white-out with a crackled pattern |
| 241864 | episode 10, Frieren's mana release: a pale blue dome of light round her, then a translucent veil over the field with thin branching white lines; concentric rings in the eye |
| 250896 | episode 6, the dragon fight: flat two-tone tan dust, flat rocks, hard-edged white wind shapes round a leap, and a thin vertical light line that lands as a flat golden ring and a dust dome |

The flower field spell is from episode 2 (Frieren Wiki): Frieren conjures a field of Himmel's favourite flowers; it was Flamme's favourite spell. The clip (238364) cuts from Frieren's face straight to the finished field: the show does not animate the flowers growing.

## The effect language in eight rules

1. **Flat cel light.** Effects are flat colour shapes with hard edges and a white core; gradients are rare. On Roblox: untextured beams for lines and bands, few layers, hard-edged sprites.
2. **Thin lines.** Vertical light pillars, horizontal streaks, the firing line, glowing heads on moving lights. Lines carry the motion; blobs do not.
3. **Four-point star glints** mark the points of power: the circle's centre, the muzzle, a new barrier cell, the light in the hands.
4. **Geometric magic.** Circles of rings, spokes, rune bands and small sub-circles; barriers of hex cells. In this show the geometry is the look. It is drawn as thin bright lines over a faint flat fill, never as solid shapes.
5. **Calm before, burst after.** The caster holds still while the light gathers; the release is one or two frames of burst, then a white-out (timings below).
6. **Light tells the beat.** The scene takes the spell's colour; figures drop to silhouettes (251534, the violet and red scenes of episode 25). On Roblox: a PointLight on the caster and at the hit, a white screen flash on the release.
7. **Cel aftermath.** Two-tone grey smoke with hard edges, black debris silhouettes, white-yellow spark lines, a thin shock ring.
8. **Defence where the hit lands.** Barrier cells form 1 to 4 at a time where a hit comes and break after 0.3 to 0.4 s; a full hex sphere is the rare big form (episode 26).

The second pass added: Zoltraak has sizes (a thin violet line in practice, fat white comets in Fern's volley, the finisher's circle and beam), and each takes the scene's tint over a white core; the release throws wind back past the caster; hits leave dashes, thin arcs and radial spikes, not round sparks; the flower field is a round patch of dense flowers with big flat petals streaming through it.

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

Fern's volley (241286, 12 fps strip): the first bolt leaves a circle at 2.03 s; 3 circles by 2.37 s, 5 by 2.95 s; 4 bolts in the air at 3.03 s; a bolt passing the camera fills the frame at 3.37 to 3.62 s; white-out at 4.03 s. About 5 bolts in the first second.

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
| flower field (238364) | #a8b1e5, #888fc8, #6f79b4, #4a62a1 (pale to deep periwinkle); centres #c1c4ea, #d1c2d8 |
| flying petals | #7d98d6, #96aedf, #737cc4, #4c61c5 |
| sunset sky behind the field | #f9f5db, #f8e5a8, #f0b57c |

`Config.frieren.lua` holds them as `Config.Palette` (petal #a8b1e5, heart #d1c2d8, drift #7d98d6). The green fringe, the ink partner, the smoke greys and the stem are chosen, not measured.

## The builds

Install: `Config.frieren.lua` as `ReplicatedStorage.Frieren.Config`, `Tw.lua` and `FrierenVfx.lua` as `ReplicatedStorage.Frieren.Modules.Tw` and `.FrierenVfx`, then run `FrierenTemplates.lua` once in Edit mode (command bar or `execute_luau`). It builds the templates as a real instance tree in `ReplicatedStorage.Frieren.Assets.Vfx` (714 instances) and the `StarterGui.FrierenFlash` ScreenGui. The runtime clones the templates on the client into `workspace.FrierenFx`. Textures are ids from his packs (`Emitters.TEX`).

Each effect runs on the schedule of its clip in `roblox-r6-animation/scripts/ExampleFrieren.lua`.

### Zoltraak (`FrierenVfx.zoltraak(character)`, 2.4 s)

| Time | Clip event | Effect |
| --- | --- | --- |
| 0 to 1.3 s | the head finds the target, the arm rises | `Updraft`: motes, thin rising streaks and small glints at the feet (the hair lift) |
| 0.4 s | the arm rises | `Pillars`: 10 thin vertical light beams round the body flick on over 0.2 s and fade by 0.9 s |
| 0.65 s | circle | `Circle` 2 studs ahead of the hand, facing the aim: 160 beams (outer, band, inner, mid and core rings, 8 spokes, 36 rune ticks, 8 sub-circles) draw on in 0.4 s by an `Order` attribute while the circle grows from 0.35 to 1 of radius 3 and spins down from 6.2 to 1.2 rad/s over 0.65 s (the finisher's 16 drawings) |
| 1.3 s | fire | the firing line: a 0.07 stud white beam to the hit point for 0.13 s (3 drawings) |
| 1.43 s | beam | a flash and a star glint in the circle, specks, 30 thin streaks thrown back past the caster (`Gust`, the release wind), 3 thin rings flying out along the beam (`Hoops`), the white screen flash (0.1 transparency, fading from 0.08 s over 0.2 s), the beam (white core 0.55, lilac glow 1.25, green fringe 1.55, ink edge 1.9 behind it) grows in 0.06 s; streaks fly along it at 70 a second; at the hit a flash, a glint, a thin ring, 24 sparks, 10 cel smoke puffs, 12 black debris, 12 white spikes (`Burst` at 1.4: 0.22 wide tapering to 0, 2.2 to 4.3 studs long, out in 0.03 s and gone by 0.2 s) and a lilac light at 3, with sparks and smoke every 0.12 s |
| 2.05 s | beamEnd | the beam shrinks over 0.18 s, the circle over 0.3 s |

`Config.Zoltraak` sets the radius, the distance ahead, the circle time, the line time, the hold, the range, a width scale and the flash. No impact frames: his move-rung pick is a flash under 0.1 s.

### Volley (`FrierenVfx.volley(character)`, 2.0 s)

Fern's volley on the schedule of the `ZoltraakVolley` clip: from 0.15 s a `SmallCircle` (52 beams: two rings of 1.1 and 0.85, a core, 6 spokes, 16 rune ticks) appears every 0.18 s, the first in front of the hand and the next four on a ring of 1.6 round the aim line; each grows in 0.18 s and draws on in 0.1 s; 0.2 s after it appears it flashes and fires a `Bolt` (a fat white comet: a lilac shell 1.1 wide and a white body 0.7 wide tapering to nothing over 5 studs, a round glow head, dashes shed behind) that flies at 160 studs/s and checks the ray every frame; at a hit or at 120 studs a small hit (flash, glint, ring, 10 sparks, smoke and debris on a hit, spikes at 0.8, a light at 2). Shots at 0.35, 0.53, 0.71, 0.89 and 1.07 s; the circles fade 0.35 s after the last shot. `Config.Volley` sets the count, the gap, the delay, the speed, the range, the ring radius and the distance ahead.

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
| 2.25 s | bloom | 110 flower clumps (3 blooms each: a stem, 5 broad petals in #a8b1e5, a pale lilac heart) spread outward at 14 studs/s from 2.5 to 14 studs, each rising out of the floor in 0.3 s with a back-out ease; every third one pops specks and a glint; drifting specks over the field; 36 flat petals (`Petal`, #7d98d6) spawn over 2 s across the field 0.4 to 3.4 studs up and drift with the wind (1.8 to 2.8 studs/s one way, a sway and a tumble) for 2.5 to 4 s, fading over their last 0.5 s |
| bloom + 7 s | | each flower fades and sinks in 0.8 s, in the order it came |

Flowers stand on the floor under each spot (a raycast), at least 1.1 studs apart. The show cuts straight to the finished field; the outward spread is a choice for a game, where the field has to appear in front of the player.

## What was checked offline and what was not

Checked without Studio (a scratch harness that runs the builder and the runtime in the Luau command line tool against the Roblox API dump: every class, property name, value type and enum item, sequence keypoint rules, tweenable types, a clock that drives `task`, tweens and `RenderStepped`): the builder makes the tree above; the four effects run to the end with no error, also under a TimeScale of 4, with two casts overlapping, with 14 hits from every side (one straight down, which first gave a NaN axis and is fixed), with a drop straight after the raise, and with no floor under the flowers; every instance is cleaned up (0 left in `FrierenFx`); the circle reaches radius 3 facing the aim; the beam line stops at a wall; barrier corners sit 3.28 from the centre with 0.7 edges; flowers reach their floor height. Peaks: Zoltraak 459 instances and 187 beams, the volley 810 instances and 302 beams, the barrier with two hits 696 instances and 336 beams (14 hits in 0.7 s: 882 beams), the flower field 4481 instances (2310 flower parts and the petals). A box preview of the geometry from the player camera set the circle radius (3, not 2.2: at 2.2 the body hid half of it) and the barrier lift (1.2: at 0.5 the panel was behind the body).

Not checked offline (the Studio results are in the next section):

- The width axis of the flat beams (`FaceCamera = false`): the band ring and the hex fill assume the width runs along each attachment's Y axis, as the torrent joints did (water.md). If they show edge-on, swap the attachments' X and Y.
- That an untextured beam draws as a solid strip, and how each pack texture looks at these sizes.
- The frame cost: 336 beams on the barrier, 5 volley circles and 2310 flower parts are guesses at a budget; profile the first cast. Each barrier cell carries 6 rim beams; dropping them halves the barrier's beams if it is too heavy. The flower fade tweens 21 parts per clump, about 2000 tweens over one second.
- The flash and the white core on his day lighting.

## Checked in Studio (2026-09-26)

Place: an empty baseplate with a clean grey R6 StarterCharacter (his pick for readable captures). Install as above, plus `Tw`, `Poser`, `Feet`, `ExampleClips` and `ExampleFrieren` in `ReplicatedStorage.Anim.Modules` (the animation skill's pipeline.md) and `scripts/FrierenClient.lua` in StarterPlayerScripts. The client plays CalmIdle and CalmWalk instead of the default idle and walk (the walk clip speed is the ground speed divided by the clip's `travel`). His keys: 1 Zoltraak, 2 Volley, 3 Flowers, Q LeanDodge, hold F for the barrier. Test hooks: the player attributes `Cast` (a move name, `Barrier` or `Drop`) and `BarrierHit` (a world point). A cast roots the body and turns it to the camera heading (his casting rule). All modules were installed with no comments.

- **The engine adds `Animate`.** A StarterCharacter without an `Animate` script still spawns with the default one, which plays its idle track under Poser. The client destroys it and stops its tracks on spawn.
- **Flat beams lie flat.** The band ring and the hex fill (`FaceCamera = false`) put their width on each attachment's Y axis. No swap was needed.
- **`ZOffset` is a real shift toward the camera, not only a sort key.** With the first values (0 to 4 studs), the layers split apart when the circle was off the screen centre. At 13 studs, the white rings (2) drew 18% larger than the band (0) and to one side of it, and each hex cell showed two ghost outlines. The offsets are now 0 to 0.08 (0.02 for each step of the old order). The order holds and no split shows.
- **Untextured beams draw as solid strips** at every width used.
- **Three textures were sheets or discs.** Each id was put on a 5 x 5 decal in front of a dark and a light backdrop:
  - `ring` 1084982817 is a filled disc, so the hoops and the cell fragments drew discs. They now use the `shock` sheet 16477162837 (4 x 4, rings in the first 8 frames) as a OneShot flipbook.
  - `rocks` 12111686783 is a 2 x 2 sheet, so each debris particle drew four rocks. It is now `Grid2x2` with `FlipbookStartRandom` and a frame rate of 0 (one random rock for each particle).
  - `specs` 9997556038 is a 4 x 4 sheet with one dot in the first cell. At 0.04 to 0.12 studs that dot is smaller than a pixel and off centre, so every mote, speck and drift particle was invisible. They now use `glow` at 2.5 times the old sizes.
  - `glow`, `spark` (a thin four-point glint), `shards` and `smoke` (one puff) are single sprites. `star` has a black square background and is used only at LightEmission 1.
- **The clips match the offline numbers.** `Poser.check` and `_G.feet` in Studio give the offline table exactly (for example Zoltraak still 43.4%, rest 49.7%, contrast 10.7). The planted soles slide 0.00, the hip gap is 0.01 or less, and CalmWalk slides 0.04 with its travel included.

The schedules, first casts at normal speed (the effects land one to two frames after the schedule):

| Move | Clip | Effect |
| --- | --- | --- |
| Zoltraak | arm on the aim 0.60 (key 0.62), kick peak 1.37 (key 1.36), lowering from 2.20 | pillars 0.42, circle 0.68, firing line 1.32, beam, flash and hit 1.46, circle gone 2.45 |
| Volley | shots keyed 0.35 + 0.18 k, kick peaks 0.05 later | circles 0.17, 0.34, 0.52, 0.72, 0.89; bolts 0.39, 0.57, 0.75, 0.94, 1.11 (on the kick peaks); hits 0.16 to 0.19 s later |
| Barrier | raise 0.30 | 19 panel cells from 0.34; a hit from the side, behind or above forms about 5 cells where it lands |
| Flowers | gather 0.75, release 1.9, bloom 2.25 | cup 0.77, rise 1.92, field 2.27, first flowers 2.56 |

A barrier hit from the front lands on the raise panel and only flashes it (by design).

Cost of the first casts, with the idle at a median of 16.5 ms:

| Effect | Peak instances, beams | Median, p95, worst frame |
| --- | --- | --- |
| Zoltraak | 459, 187 | 16.5, 20.8, 71 ms |
| Volley | 810, 302 | 17.2, 20.3, 31 ms |
| Barrier raise | 551, 266 | 16.6, 18.1, 20 ms |
| Barrier with six hits | 1305, 630 | 17.4, 21.3, 24 ms |
| Flowers (the first build) | 4481, 2 (2348 parts) | 17.0, 29.5, 106 ms |

The flower fade was the only real cost. For 1 s, 110 flowers each started 21 transparency tweens (2310 tweens) and moved by `PivotTo` every frame, and the frames reached 106 ms. The loop now moves every flower part with one `workspace:BulkMoveTo` call per frame and fades the transparency in the same loop. It runs clean: each flower fades over 0.8 s from 9.9 s, 23 are left at 11.0 s, and the folder is empty at 11.5 s. Its frame cost is not measured yet. Studio then held 3.9 GB of private memory on the 6 GB machine. Later casts stalled 0.1 to 1.7 s at random times with a clean idle, so those numbers are paging, not the effects.

Captures from the player camera (12.5 studs behind, 4.7 up), in slow motion with `TimeScale` 20 to 40 and the call waiting until just before each beat (a capture arrives about 4.5 s after the call returns):

- **The circle** fills about 12% of the frame width at full spin, and the head and the torso hide about 40% of it. The white rings and the band read against the sky and a dark block.
- **The beam does not read from behind.** It points straight away from the camera, so it projects to a short streak behind the head and the circle; only a glint in the circle centre and the hit show. From the side it reads as a pale light tube: the white core reads, the lilac glow reads grey-white on the day lighting, the ink edge is a faint grey band, and the green fringe does not show.
- **The flash** holds 0.08 s at 0.1 transparency and fades over 0.2 s: about 80% white over the whole frame for 0.28 s. It hides the release it marks.
- **The barrier panel** shows over the head and the shoulders from behind; from the front it is a curved panel of thick glowing white hex outlines (the pale cyan edge reads white under bloom) with an almost invisible fill. A side hit cluster faces sideways and reads as a thin vertical strip from behind.
- **The flower field** reads as clumps of pale periwinkle flowers round the caster, sparse next to the dense carpet of the reference.
- The grey cel smoke and the single black rocks at a hit read as meant.

## Where this meets his earlier rules

- "Too geometric" was said of Neon solids, and of UI rings and borders on a water block. The Frieren circle and hexes are geometric because the reference is; here they are thin light beams over faint flat fills with glints and fragments. Ask him about the geometry on the first review.
- No impact frames on a move (his Bull Leap pick): the finisher's inverted frames are not built; the release gets a 0.08 s white flash (his water laser pick).
- No text: the rune band is ticks of three lengths, not glyphs.
- No Highlight on the rig.
- The identity rule still holds: a character with its own look (water, anti-magic) keeps its vocabulary; the Frieren rules decide how it is drawn.
