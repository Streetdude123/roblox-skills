---
name: roblox-vfx-craft
description: Build Roblox ability VFX for Lepy's places from his own VFX packs - small summons, moves, and full cinematic ultimates with camera, impact frames, screen effects and a sound mix - using the Kit, Emitters, Tw, CameraRig, ScreenFx, ImpactFrames and SpeedLines modules, the tone ladder, the numbers measured on the DIO summon and the sword ultimate, and the verification routine for Studio captures. Use whenever a Roblox effect, cutscene, particle system, screen effect or ability sound mix must be designed, built, judged, profiled or fixed.
---

# Roblox VFX craft

This skill is everything learned while building two effects for Lepy in 2026-09: a 16 second sword
ultimate for his portfolio and a 1.3 second DIO stand summon. He supplies VFX packs in every place
("I'll always add VFX packs you can use"), he judges by feel from a recording, and he says what he
does not like in a sentence. Every rule and number below was either measured in Studio or came from
one of those sentences. Read the references before building; do not invent particle counts.

## Decision framework: the tone ladder

Pick the rung first. The biggest mistake made so far was a summon built with ultimate tools.

| Rung | What it is | Length | Camera | Screen | Sound |
|---|---|---|---|---|---|
| **Summon / toggle** | a stand or weapon comes out | 1.0 to 1.5 s | none for the caster; a rumble for spectators | none | 2 to 3 clips in one limiter group |
| **Move** | a strike, a dash, a barrage hit | 0.3 to 2 s | a kick on the hit, one short pulse of speed lines | one flash under 0.1 s at most | hit into the hits group |
| **Cinematic ultimate** | a reel piece | 12 to 16 s | full rig: shots, cuts, freeze, roll, DoF | bars, vignette, flare, impact frames, fade to black | two groups, ducks and muffles |

Rules that follow from the ladder:
- A summon never takes the camera, never dims the world, never scales the body, never shows impact
  frames. He asked for "simple small vfx for summoning a stand" and "no impact frames".
- A cinematic wants no empty frame: sparkle fields across the whole arena, bursts in the hundreds,
  three waves for a climax, debris rain and smoke after. He asked for "WAY more dramatic and longer".
- The ceiling is real on both rungs: "you are doing a little too much so it feels kinda messy". Fewer
  layers beat fewer particles when a shot is messy.

## Workflow

1. **Catalogue the pack** before touching anything: scan for scripts, archive the whole pack to
   `ServerStorage`, render the meshes at real proportions, blank dead sounds. See
   `references/kit-workflow.md`. Build from his pieces; hand-roll only carriers, code emitters and glue.
2. **Write the palette and the schedule.** A `Config.Palette`, a `Config.Sparkle` list, and one `T`
   table of beat times that the clip, the effects, the camera and the sound all key off. See
   `references/cinematic.md`.
3. **Build phase by phase** with the modules in `scripts/` (`references/modules.md`): each phase is one
   function that spawns into a `workspace` model, and `cleanup` destroys the model.
4. **Verify in Studio** at QualityLevel 21 with a slowed `TimeScale`, phase attributes and captures
   that move the camera each time; profile the first cast for frame hitches. See `references/verification.md`.
5. **Mix the sound** last, from a recording when he sends one. See `references/sound.md`.
6. **Log his sentence** in `references/taste.md` and update the numbers here.

## The rules he taught (short form)

- Build from his kit; archive the unused pieces to `ServerStorage`; never hand-roll a primitive that the kit has.
- No empty space in any frame of a cinematic; explosions long and in waves.
- Never put a `Highlight` on the player's rig for an effect.
- Camera smooth and slow, always drifting, far enough back for the biggest piece; never pan back to the
  rig at the end: fade to black, wake the default camera behind the body while black, fade in.
- No text on screen ("text ruins it").
- Speed lines are a 0.4 s pulse on a hit, never an overlay on a phase.
- "Too geometric": clean Neon solids read as cheap. Glow comes from Beams, soft particles, hand-stroke
  and ripple meshes; a mesh solid sits at 0.35 or more transparency with a glow particle behind it.
- A summon is small and never lags: preload assets at join AND draw every piece once at join nearly
  invisible so the first cast has no first-draw hitch.
- The effect vocabulary must fit the character. Rainbow four-point stars are the sword ultimate's
  Megumin vocabulary; on The World he said "star vfx doesn't really suit the world". A stand's effects
  come from its identity (The World: time, clockwork, gold and lavender menace, stopped-time ripples),
  not from the generic sparkle set.

## The numbers that matter

**Sparkle field (`Emitters.sparkles`)**: seven `star4` emitters, one per `Config.Sparkle` colour, white
to colour, twinkle size curve `{0,0} {0.12,s} {0.4,0.45s} {0.62,s} {1,0}` with `s = size * (1.6 + (i % 3) * 0.9)`;
tiny white stars at 3x rate; three `crescentRing` colours at 0.5x; four `circle` dots at 1.2x; three
`lightray` rays at 0.5x. `sparkleBurst(count)` is stars per colour: 45 throws about 450 pieces. A
90 x 150 x 90 field at rate 30 fills a cinematic frame; a summon uses 6 to 7 at size 0.5.

**Summon (small rung, measured)**: gather 0.25 s of inward `star4` at 24/s and `circle` at 16/s on a
carrier behind the torso, a violet PointLight rising to 1.2; pop = one `Hit2` at scale 1.1, one `Shock`
ring at the feet at scale 1.2 (carrier rotated 90 degrees about X), two `Lightning` pops at scale 1.4,
seven sparkles, light spike 3 then 0.6, camera kick 0.22; rise = a `star4` trail at 26/s while the
stand materialises over 0.22 s; settle = an idle aura at 4 + 6 per second welded to the stand. Beats:
pop 0.25, rise 0.27, settle 0.55, lock 0.85, done 1.3.

**The World's vocabulary (built 2026-09-21, replaces the stars on every stand beat)**: gather = a
`ChainRing` rune ring stood on its edge behind the back (tint gold to pale, scale 1.5, floor emitters
on with RotSpeed 120 to 160, chain beams off) inside an `EyeRing` rim (Neon, 5.2 studs, 0.5
transparency) with one `lightray` Beam hand on a carrier the follow loop spins up from 3 to 14 turns
a second, plus a gold light; pop = the hand stops dead on twelve and the rim flashes white for three
frames, `Crack` at the back (pale, scale 1.3), `ShieldBreak` (14 specs, gold to pale, scale 1.2), 12
`shards` at speed 6 to 14 with gravity, one `Shock` at the feet in lavender; rise = three gold echoes
(`SummonVfx.afterimage`: the visible parts cloned as Neon gold at 0.5 fading over 0.3 to 0.42 s) at
0.06, 0.13 and 0.20 while the clock fades; settle = the `Charge` piece welded to the torso at rate 4
(gold to amber, scale 0.7, core off) and a green heart light pulsing 0.25 to 1.0 every 0.86 s.
Barrage = the `Wind` piece at the fists pointing forward (rate 28, speed 26 to 40, life 0.16 to 0.26,
spread 14, gold to pale), a `glow` fist flash of 2 per beat at 12 a second in a 2.6 stud box, an echo
of the arm meshes every other beat for 0.18 s, `MudaRush` + `BarrageSFX`, camera kick 0.09 per beat;
finisher = `Hit3` 1.5, `RingShock` 1.6, `SlashImpact` with 10 + 8 specs, `StrongMuda`, `HitStrong`,
three echoes, kick 0.55. Hits on a target: `Hit1` gold with `HitSoundTW` limited to one per 0.11 s;
frozen hits lavender with `LMB1`; the release burst `Hit3` 2.0 + `ShieldBreak` 1.8 + `RingShock` 2.2
+ 18 lavender shards + `HitStrong` + `Bass`.

**Time stop (cinematic move, 3.1 s call + 6 s stopped)**: beats from the "the world 2" envelope:
call 0 (za warudo 0.13 to 0.85), pause 0.85, command 1.35 (toki wo tomare 1.35 to 2.88), snap 2.45,
frames 2.5, done 3.1; the resume voice "Zero..." starts 1.6 s before time moves. Shots: front push-in
angle 148 to 158 dist 13.5 to 10.8 fov 62 with bars; a cut to a low shot up at the stand at angle 196
dist 9.6 height 0.5 lookY 5.4 fov 58 roll -3 drifting to 8.6 and +2 with a 0.35 vignette and one
`Heartbeat`; the `Rays` fan (gold to lavender, scale 1.6) opens on the command while the stand light
climbs to 3.2 and the clock (scale 2.6, rim 4 x scale) races; the snap = clock stop, `Bass`, `Shock`,
`ShieldBreak` at both hands (16 specs, scale 1.6), a `Crack` plane facing the camera at scale 2.6,
three gold echoes, a 0.5 pale flash, impact frames gold 0.05 / purple 0.05 / white 0.04 with the
camera frozen, kick 0.6, and the ripple: a `FancySphere` in ForceField lavender 2 to 260 studs over
0.8 s + a Glass ball 2 to 240 over 0.72 s + the `Ripple` ground mesh 4 to 140 + `RingShock` scale 3;
the colour drains through a shared `Lighting.TimeStopCC` (brightness 0.25 and tint 190,160,255 for
two frames, then saturation -1, contrast 0.12, tint 215,212,240 over 0.45 s); pull back to a rear
three quarter angle 32 to 18 dist 17 to 13.5 and hand the default camera back with `CameraRig.cut`.
Resume = the ripple runs back in over 0.5 s, saturation to 0 over 0.4 s, two lavender echoes, queued
hits land at once with the release burst.

**Cinematic (final schedule)**: hold 1.4, charge 3.4, peak 3.95, slash 4.5, impact 4.55, follow 4.69,
crown 4.77, crownEnd 5.2, pillar 5.36, ret 6.41, mid 6.85, freeze 7.29, collapse 7.85, burst 8.11,
wave2 8.55, wave3 9.0, after 10.35, fade 11.25, black 12.05, fadeIn 12.55; 16 s, cooldown 20.

**Camera**: follow lerp `1 - exp(-dt * 9)`, fov lerp 12, shake from `math.noise` at `t * 13` scaled by
trauma squared times 2.6 studs and 0.05 rad, floor trauma 0.16 for breath, shots Sine InOut, cuts snap
the values, freeze for the length of an impact frame set. Wide shots 1.6x farther than instinct:
pillar at 100 to 135 studs with fov 54, burst 125, wave three 150. Roll 2 to 6 degrees on hits.

**Impact frames**: steps of 0.05 s (three frames), white-black-white on a hit, cyan with navy figures as
the inverted frame. Speed lines: 36 rays re-rolled every third frame with 40 percent hidden, pulse
0.12 s in and 0.4 s out.

**Too geometric fix**: pillar = 3.5 stud white core at 0.1 transparency + 9 stud crimson tube at 0.55 +
four camera-facing Beams (`lightray` 22, `windspin` 34, `windA` 28, `core` 46 studs) + a rising column
of soft particles; sleeves at 0.45 to 0.72; flash balls 0.35 to 0.5 with a glow particle; rocks are
mesh ids 3027924097, 1254390558, 4933939521 at random turns.

**Sound**: two SoundGroups (bed ducks and muffles, hits only get limited), a CompressorSoundEffect on
each at Threshold -9 Ratio 12 Attack 0.001 Release 0.12, +3 dB high shelf, stacked layers 8 to 10 dB
lower than instinct, slowed sub hits faded after 0.3 to 0.4 s, `InverseTapered` rolloff 40/500 for a
big effect and 25/300 for a summon.

**Performance**: the summon's Lua cost is 3 ms; the 57 ms first-cast frame was the first draw of 60
mesh parts, the Neon ghost material and the kit sprites. Drawing them once at join at 0.98
transparency for two frames brought it to 26 ms on a 17 ms idle.

## Feedback log

- 2026-09-19: first ultimate cut - "explosion needs to be WAY more dramatic and longer, too much empty
  space, not enough particles, don't highlight the character, camera smoother, don't pan back, fade to
  black". Then a Megumin still: "recreate all those colorful sparkles".
- 2026-09-19: dense cut - "speed marks kinda ruin it, camera needs to zoom out more, you are doing a
  little too much so it feels kinda messy". Forty percent fewer particles, two sleeves and a beam gone.
- 2026-09-20: "too geometric" on Neon cylinders and tori; the attack name card - "text ruins it".
- 2026-09-20: he liked the camera angles as they were; he wanted a quiet two second hold at the top before the charge.
- 2026-09-21: "use the VFX kit I have given you, store the vfx you don't need in the server storage".
- 2026-09-21: "don't make it so laggy when you summon him, no change in quality though" and "don't make
  the VFX so crazy like impact frames for summoning, lower down the tone, simple small vfx".
- 2026-09-21: "star vfx doesn't really suit the world, try coming up with more creative VFX that fits
  the world more and stands" and "I'll always add vfx packs you can use".
- 2026-09-21 (later): "i have vfx packs in server storage use that please" while the World vocabulary
  above was built; every piece came from `Assets.Vfx` (his kit) plus carriers, beams and code emitters.
  The old stand's mesh ids had died and drew as orange boxes ("what is this? appeared on my second
  summon"): a MeshPart whose mesh fails to load renders as a plain box of its Size and Color, and
  `ContentProvider:PreloadAsync` on id strings reports Failure for meshes that load fine, so judge a
  dead mesh by a capture of the model, not by the preload status. The stand body is now his free model.
- 2026-09-21 (later): he asked for a "super cool cinematic cutscene" for the time stop with voice
  lines; the beat table came from the voice line's `PlaybackLoudness` envelope (see sound.md), and
  the cutscene locks the body 3.1 s, which he accepted for this move.
- 2026-09-21 night (later): "make everything more dramatic please except for the summon". What went
  up one notch on the MOVE rung: barrage ticks 3.0 and a 22 finisher with a 62 stud LinearVelocity
  fling, a 0.08 s hit stop on both rigs, two impact frames (gold 0.05, white 0.04) with the camera
  frozen, a 0.9 speed line pulse, a 0.35 pale flash, `Wry` under `StrongMuda`, `Hit3` 2.0 +
  `RingShock` 2.2 + `SlashImpact` 14/12 + `ShieldBreak` 16, kick 0.8, spark bursts of 3 per beat;
  the M1 chain gets a gold `Slashes` streak per hit, `Punch` + `HitSoundTW` on contact, hit stops
  0.05 on hits 3 and 4 and 0.08 on the fifth with `ShieldBreak`, two echoes and a 0.4 kick. The time
  stop (CINEMATIC rung) grew a front orbit that pushes in (angle 140 to 172), a profile close up on
  "toki wo" (angle 96, dist 5.6, fov 50), a push to dist 7.2 with roll -5 for "tomare", a four step
  impact frame set, a 0.7 flash, a double `Bass`, both rigs held 0.1 s on the thrust, exposure -0.35
  and contrast 0.2 for the stopped world, a hard cut to dist 26 drawing to 15, a 0.15 vignette while
  stopped, and `Laugh` 0.35 s after the hand back. The summon was not touched.
- 2026-09-22: "for the cutscene i want some sort of sphere to extend out to the point where it looks
  like it's super big". The bubble of stopped time is now the kit's striped `Sphere` mesh (a wireframe
  energy shell, MeshSize 5) in neon lavender at 0.55 over a glass ball at 0.45: both grow 2 to 80 studs
  on a `Quad In` over 0.85 s under a far rear three quarter camera (angle 34, dist 58 to 44, height 16,
  fov 70, still letterboxed) so it dwarfs the two bodies, then blast to 520 in 0.55 s; the grey and the
  exposure drop sweep in at `engulf` (3.35 s, when the shell passes the lens) instead of on the snap,
  with a lavender flash and a 0.35 kick, the bars drop there and the hand back is at 3.9 s. The veined
  `FancySphere` was dropped: in ForceField it stays visible near full transparency and once the lens is
  inside it the whole sky is smeared veins. The ground `Ripple` ring stops at 120 studs; at 400 it read as
  thick yellow streaks. A slowed client (TimeScale) desyncs from the unscaled server resume, whose reverse
  ripple then lands inside the slowed cutscene; judge the bubble from an isolated spawn of the same
  objects, and never trust a scaled capture taken after the server's resume time.
- 2026-09-22 (later): "Add the truck roller too, make sure thats a cutscene please. You may use a
  free model for the truck". `RoadRoller.lua` is the second cinematic rung piece: 12 s keyed to the
  `RoadRollerDA` voice line (call 0.7 to 1.7, the fall silent to 3.0, the scream 3.1 to 8.5, the laugh
  to 11.8) with `RoadRollerStart` as the bed. Beats: leap 0.30, reach 1.30, catch 1.80, land 3.00,
  brace 3.10, point 3.50, boom 8.50, off 8.55, fade 11.2, done 12.0. The roller is the free model's
  one MeshPart (`Assets.RoadRoller`, 10 x 8.6 x 16) anchored and driven by `PivotTo` from y 75 to the
  ground; it carries a gold PointLight 1.6 / 44 from the moment it shows or the catch shot is a black
  lump. Land: `BigCrack` 2.2, `RingShock` 4, `PackF` rocks 22, tan `Smoke` 40 (165, 150, 125), a 0.15
  freeze, impact frames white-black-gold with the roller in the silhouette, kick 1.0, speed lines 0.8.
  Rush: the stand's raw barrage on the deck, a fist flash and sparks every 0.083 s, a hit sound every
  six, a 0.09 kick per beat. Boom: the roller hidden under `BigExplosion` 2.4 + `RealExplosion` 2.6 +
  `PackExplosion` 2.2 + `PackF` shards + dark `Smoke` 60, light 6 / 60, impact frames gold-red-white,
  kick 1.2, flash 0.7. Camera: a close rear take (angle 150, dist 16), the leap shot at dist 21 looking
  at the apex minus 2 (at dist 28 looking at apex minus 6 the pair filled a tenth of the frame at the
  top: an empty sky shot), a sky cut looking down (angle 200, height 44) that falls with them to
  height 12, a cut to angle 40 dist 22 at the land drifting to 110, a wide cut at the boom (dist 44,
  fov 66) drawing to 36, fade at 11.2, the default camera wakes behind the body in the black.
  The leap gets a `Wind` trail welded under the root pointing down (rate 34, speed 30 to 46) and a
  0.6 speed line pulse so the sky shot is not empty.
- Two traps from the road roller. The server zeroes WalkSpeed and JumpPower at the cast and restores
  them at done; the client MUST NOT restore them from a value it read at start (the server's zero
  had already replicated, so the client put the body back to 0 after the server's 16). The client
  owns only AutoRotate and the anchor. Second: the impact frames draw Neon clones inside a
  ViewportFrame, a first draw the world warm-up does not cover; the first road roller hitched 884 ms
  on the land. `SummonVfx.warm` now holds a ViewportFrame at ImageTransparency 0.99 with flat Neon
  clones of the body, the stand and the roller for two frames at join.

## Reference index

- [taste.md](references/taste.md) - his taste in full, why each rule exists, and the identity rule for stands.
- [kit-workflow.md](references/kit-workflow.md) - quarantine, backdoor scan, archive, catalogue, mesh gallery, dead sounds, template folder, warm-up.
- [modules.md](references/modules.md) - Tw, Emitters, Kit, CameraRig, ScreenFx, ImpactFrames, SpeedLines: API and traps.
- [cinematic.md](references/cinematic.md) - the schedule pattern, clip drive, camera language, phases of the ultimate, the summon's phases.
- [sound.md](references/sound.md) - the mix, Mirelo clips, measuring a recording, dead private audio.
- [verification.md](references/verification.md) - quality level, capture cache, occluded Studio, phase polling, frame profiling.

## Scripts

- `scripts/Tw.lua`, `scripts/Emitters.lua`, `scripts/Kit.lua` - tween, code emitters and kit template helpers.
- `scripts/CameraRig.lua`, `scripts/ScreenFx.lua`, `scripts/ImpactFrames.lua`, `scripts/SpeedLines.lua` - the cinematic layer.
- `scripts/SummonVfx.lua` - the small rung worked example (DIO summon: the clock gather, the tick pop, gold echoes, the charge and heartbeat idle, the join-time warm-up, `afterimage`, `standParts` that skips `Tr 1` parts, `rigOf`).
- `scripts/Moves.lua`, `scripts/TimeStop.lua`, `scripts/MovesServer.lua` - the move rung (barrage with fist streaks, flashes, arm echoes and a finisher) and the cinematic move (the time stop call, the freeze, the resume) with the server that runs hitboxes, freezes the world, queues damage in stopped time and launches knockback through a 0.22 s `LinearVelocity`.
- `scripts/UltimateVfx.lua` - the cinematic rung worked example (sword ultimate, 2272 lines).
- `scripts/RoadRoller.lua` - the second cinematic piece (the road roller: a procedural root and roller on one beat table, the land, the rush on the deck, the boom, the fade; the server side is `startRoadRoller` and `blast` in `MovesServer.lua`).
- `scripts/ScanPack.lua`, `scripts/MeshGallery.lua`, `scripts/BlankDeadSounds.lua` - the pack intake tools.
