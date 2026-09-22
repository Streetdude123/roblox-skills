# Archived DIO and sword showcase measurements

Use only when continuing these exact projects. This is preserved review history from
September 2026. The timings and performance reports below were recorded by the old
skill and were not independently reproduced during this revision. Asset availability
and the current place must be checked again.

These paragraphs describe old implementations. They are not general VFX requirements.
Use SKILL.md and the current technical references when an archived statement conflicts.
In particular do not copy fixed particle budgets or first draw warm-up guarantees.

## Contents

- [Recorded settings](#recorded-settings)
- [Feedback log](#feedback-log)
- [Original cinematic breakdowns](#original-cinematic-breakdowns)

## Recorded settings


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
- 2026-09-22: "search up tutorials like the animation and stuff and improve the VFX skill" - read the League of Legends VFX style guide takeaways, Jason Keyser on block-ins and timing, the VFX Apprentice timing and design principles, Vlambeer's screenshake tricks and the Roblox DevForum particle guides; the rules that survived translation are the Principles section and `references/principles.md`. Biggest changes: one hero element per phase, pale cores with a dark rim, stretched sparks, and gather-overload-process timing with short dissipation on gameplay effects.

- 2026-09-22 (night): "I lost all my changes to my place cause my pc restarted, reapply all the changes ...
  he's not even punching the road roller and he doesn't even touch it. Fix it and reapply all the
  changes with improved vfx and animations." The place had never been published. Rebuilt in one pass
  with `scripts/RebuildStandPlace.lua` and the four scripts in `scripts/rebuild/` (the kit archive,
  the 53 templates + 28 meshes + 23 sound picks, the 70 stand sounds and the dusk lighting, the free
  model rig and its 8 clips, the 54 dead kit sounds), the road roller re-inserted (asset
  121007269169300, scaled 16/50, one MeshPart named Body). The roller now lies along DIO's line
  (`Angles(tilt, 0, 0)`), DIO stands on the rear hood (top 1.2 above the centre, measured with rays
  over the mesh in its own frame: a 5 x 8 grid of downward casts), The World dives at the front
  housing (top 3.4 at z -5) with the fist flashes, a gold `RingShock` 1.1 every six beats, `Hit2`
  0.55 every three, `PackF` shards every six and sparks that fly up off the metal (Top emission,
  gravity -40) all placed in the ROLLER's frame at `DECK (0, 3.4, -5)`, never beside DIO. The rush
  glow was cut (stand light 1.6 to 0.7, echoes every 0.45 s at 0.82, flash 1.2, one per beat): at the
  old values the stand read as a gold blob on the housing, not a body hammering.
- Two Studio traps from that night. A `Poser.bake` of a held clip (`length = 100000`) with no bake
  length loops for millions of frames, floods memory (his machine has 6 GB), and Studio dies behind a
  "Save File Failure" dialog that blocks every MCP call; bake in batches of five with a length, and
  publish first. The full VFX kit in `ServerStorage.VfxKit` is 50,066 instances (36,661 of them
  `Wing Rigs`); a play test doubles the place in memory, so once the templates are extracted the kit
  folder should be saved to an .rbxm and removed from the place.
- 2026-09-22 (night, later): "create the iconic knife throw dio does ... in timestop it should only move
  after time begins again". A MOVE rung piece in `Moves.knives` + `startKnives` / `knifeStep` in
  `MovesServer.lua`. The knife is the free model 210335386's Handle (mesh 202083123, 0.2 x 0.4 x 2,
  tip at -Z, kept in `Assets.Knife`); the fans in the hands are client welds, the seven flying knives
  are server parts flown 115 studs a second for 1.3 s with a cast ahead each frame (7 damage, a wall
  stick for 5 s), fanned 34 degrees with `|u|^2.5` so the middle three meet a target at 22 studs, every
  knife aimed from its hand at a point 30 studs out on the fan line so the fan converges. While any
  time stop holds the world (`stop.frozenNow`) a knife flies 0.14 s then hangs where it is and flies
  on at the resume; measured: seven knives at the same position from 4.85 to 6.87 s, the dummy
  untouched, then 14 to 21 damage after the resume. Each knife carries a faint `core` shimmer (rate 7,
  size 1.3, 0.3 transparency) and a gold PointLight 0.6 / 7 or it vanishes in the darkened stopped
  world; a Trail (pale to gold, 0.12 s) draws only while it moves. Sounds: `KnifeShine` on the draw,
  `KnifeThrown` + `ThrowVoiceline` on the release, `KnifeShing` on a body hit, `KnifeShing2` on a wall
  stick; a 0.18 kick and a pale `Slashes` streak at each hand on the release. The time stop already
  has its end voice: `TSEndSFX` (2.07 s) fires on the resume signal 1.6 s before time moves and
  `TSEndVoice` (1.01 s) on the resume itself.


## Original cinematic breakdowns

The following is the original cinematic reference for the same projects. Treat its
shot lists and implementation decisions as examples only. General production rules
live in cinematic.md. Renderer and bridge workarounds require current reproduction.

# Historical sequence notes

## One schedule for everything

The effect module owns one table `T` of beat times in seconds from the cast. The clip speed changes,
every phase, every camera shot and every sound key off `T`, and `Tw.wait(T.b - T.a)` walks the
sequence in one coroutine. Spectators run the same `T` without the camera and with `CameraRig.rumble`.
The server only gates the cooldown and fires `Cast(player, originCFrame)` to all clients; every client
runs the full effect locally (`isLocal` decides camera, screen and humanoid lock).

State goes in one table made by `setup` and torn down by `cleanup(state, failed)` inside a `pcall`, so a
phase that throws still returns the camera, the lighting, the anchored root, the sound groups and the
effect models. Effects spawn into two workspace models, `FxHard` (things impact frames may silhouette)
and `FxSoft` (particles and glows that must not).

## Driving a published clip on wall-clock beats

`driveClip` plays the clip Looped (frame 0 equals the last frame, so a late freeze is safe) and changes
`AdjustSpeed` at `T` beats, never trusting the clip's own timing. A `ramp(track, dur, span, shape)`
helper integrates a shape curve so the clip lands exactly on a target frame at the end of a beat
(a P term `err * 6` corrects drift; without it the raise landed at 0.88 instead of 1.0). During a hold
the pose sways by 0.012 s of clip so the body breathes instead of freezing like a statue. Hit stops are
`AdjustSpeed(0)` for 0.14 s. The return decelerates on `1 - u^2` into the freeze.
For code-posed clips (the stand, DIO) the `roblox-r6-animation` skill's Poser holds a frame with a
zero-speed play instead.

## Camera language (the ultimate's cut list, which he liked)

1. Raise: push in over the hold (angle 82, dist 12.4, height 3.4, fov 58, roll 3) with the DoF racking to 12.
2. Quiet hold: hard cut to a low front hero shot (angle 178, dist 9.8, height 1.3, lookY 5, fov 48) that
   only creeps in (dist 8.6, height 1.0, roll 4). Two seconds of wind and a rising rumble, nothing else.
3. Charge: blade close up at the energy snap (angle 118, dist 7.8, fov 44).
4. Slash: an angle whip (angle 106, dist 8.6, roll -8) with no fov change and three pink afterimages.
5. Impact: the rig freezes for the cutout frames (white 0.06, black 0.05, white 0.05); when the hit stop
   releases, a hard cut wide (fov 66, dist 20 to 24, angle 104), kick 0.9, one 0.35 s speed line pulse,
   a red-then-cyan tint glitch over two frames, exposure +0.6, a cyan flare at the impact, DoF to 24.
6. Pillar: long lens (angle 150, dist 128 to 135, fov 54), tint cool (226, 232, 255).
7. Mid frame: low base shot (angle 250, height 3, lookY 70).
8. Freeze: tight on the frozen body (angle 206, dist 9.5, fov 40).
9. Collapse: wide (angle 262, dist 64); burst at 125 studs with roll +6, wave three at 150.
10. Aftermath, then fade to black 0.8 s, `CameraRig.cut` behind the body while black, fade in 0.5 s.

Rules: shots are Sine InOut on number values under an exponential follow, cuts snap, the floor shake
0.16 never stops, a FOV punch never pairs with a dolly the other way, the camera stays dead still
through cutout frames, and nothing ever pans back to the rig.

## World and post-processing (cinematic rung only)

- A `ColorCorrectionEffect` for the glitch (tint 255,140,140 then 140,215,255 over 0.05 s, back over 0.2)
  and the cool pillar tint; saturation, brightness and contrast return to 0 over 0.5 s at cleanup.
- `Lighting.ExposureCompensation` flashes: +0.6 hit, +0.4 pillar, +1.1 burst, 0.04 s up and the
  restore delayed 0.06 (through `Tw.play`, never `DelayTime`).
- World dim over the raise: Brightness 2.2 to 1.1, ambients down, Atmosphere density 0.42 to 0.55,
  returned in the aftermath.
- `DepthOfFieldEffect` racks: 13 body, 24 dome, 40 crown, 120 to 140 pillar, 70 collapse, 120 to 160
  burst, 100 to 60 aftermath. Under DoF plus particles at Level21 a 13.6 s run took 17 s, so offer a
  config toggle for DoF and the vignette.
- Bloom 0.55 intensity, size 32, threshold 1. Threshold 2 disables bloom entirely; check it first.
- Letterbox bars 12 percent, vignette 0.4, both in over 0.5 to 0.8 s at the start.

## The phases of the ultimate (what each one is made of)

- **Pre-wind**: blade emitters and a torso aura, pebbles lifting, two wind gusts (0 and 0.8 s), a
  Rumble bed rising to 0.3. The raise itself only moves air so the body reads clean.
- **Charge**: a sigil, orbit rings, a pull-in (inward emitters whose rates tween x2.2 over the hold),
  lightning bolts, two sparkle fields; Charge plays twice (0.85 speed, then 1.1 rising to 1.3).
- **Peak**: a pulse, a second pulse halfway through the 0.8 s hold.
- **Slash**: crescents and a Trail on the blade, afterimages.
- **Impact**: white/black/white frames, a screen flash 0.6 over 0.25 s, the raw Impact sound.
- **Dome**: at the blade tip, plates rise, crack, rocks, smoke rings, a sparkle burst; crown of five
  spiked meshes with blue frames.
- **Pillar**: 160 studs, 3 cylinders, sleeves, four camera-facing Beams, rings every 0.08 s, vertical
  rings, sparks, spark rain, floating rocks, ground wind, bolts, sky rings, a sparkle field, a mid frame;
  PillarLoop pitches 0.95 to 1.18.
- **Collapse**: an inward suck, the loop dives and muffles.
- **Burst**: wave 1 (frames, screen flash, a spear of light as a Beam, urchin, three shells, rings,
  crowns, 16 stars, sparkle burst, plates flung), wave 2 at +0.44 s (a sky star 70 studs up, a cracked
  sphere), wave 3 at +0.9 s (240 stud dome, 340 stud ripple, smoke mushroom, debris rain, six sparkle pops).
- **Aftermath**: a loop in, debris and smoke linger, the mix muffles and ducks to zero with the black.

## The phases of the summon (the small rung)

- **Setup**: find the parts, `groundBelow` for the floor, a `StandFx` model, follows, one mix group,
  `remember` the stand's materials, hold the appear clip at frame 0 (folded inside the body), hide,
  lock the humanoid (WalkSpeed 0, JumpPower 0, AutoRotate off) until 0.85 s, rumble for spectators.
- **Gather (0 to 0.25)**: inward stars and dots on a carrier pinned behind the torso, a violet back
  light rising to 1.2, an Ambience clip at 0.35.
- **Pop (0.25)**: kill the gather, ghost the stand gold Neon at 0.35 transparency, one Hit2, one floor
  Shock ring, two Lightning pops, seven sparkles, light spike 3 then 0.6, kick 0.22, SummonSound and StandSFX.
- **Rise (0.27)**: play the appear clip, materialise after 0.12 s over 0.22 s, a star trail on the
  torso at 26/s, a gold stand light to 1.6.
- **Settle (0.55)**: kill the trail, lights down, the idle aura (4 + 6 per second) welded to the stand
  torso and reused by name on the next summon.
- **Done (1.3)**: the hover clip fades in over 0.45 s; the camera offset slides to (-1.4, 0.2, 0) so the
  stand on the right shoulder never covers the body.
- **Dismiss**: the vanish clip, camera offset back, Desummon clip, six sparkles, parts fade to 1 over
  0.26 s after a 0.08 s wait, the rig stops at 0.36 s, the aura disables, lights destroyed.

## The phases of the road roller (the second cinematic piece)

One `T` table again (`Config.RoadRoller.Beats`), every phase a function into `state.fx`, `cleanup` at the end. The body is anchored and its root written every Heartbeat from `rootAt(t)`; the roller is one anchored MeshPart moved by `PivotTo` from `rollerCF(t)`. Only the caster runs the camera; every client runs the bodies, the roller and the effects, so the spectators see the same roller fall.

1. **Call (0 to 0.3)**: `DioRollerUp` from its LOAD crouch, the voice line, the bed and the wind-up start, a close rear take at dist 16, bars and vignette.
2. **Leap (0.3 to 1.8)**: a gold `Shock` ring at the feet, the jump sound, a `Wind` trail under the root pointing down, a 0.6 speed line pulse, a shot to dist 21 looking at the apex minus 2. The root rises 36 on a `quad` out over 1.3 s. The roller appears at 1.3 (transparency 0 plus its gold light) 75 up and falls.
3. **Catch (1.8 to 3.0)**: a small `Impact`, a cut to the sky looking down (angle 200, height 44) that falls with them to height 12 on a `quad` in; the root settles onto the roller top.
4. **Land (3.0)**: `BigCrack`, `RingShock`, rocks, tan smoke, an amber light, the land sound + `Bass` + `GroundSlamSFX`, a 0.15 freeze, impact frames with the roller, kick 1.0, speed lines 0.8, flash 0.6; the server blasts 45 in radius 14. 0.2 s later a cut to angle 40 dist 22 drifting to angle 110 over the rush.
5. **Rush (3.5 to 8.5)**: `DioPoint` on the body, the stand's raw barrage leaned into the deck, a fist flash and sparks every beat, a hit sound every six beats, a 0.09 kick per beat, arm echoes every 0.25 s, the roller sinking 1.25 with a 12 Hz jitter.
6. **Boom (8.5)**: the roller hidden, `BigExplosion` + `RealExplosion` + `PackExplosion` + shards + dark smoke, light 6 / 60, impact frames gold-red-white, kick 1.2, flash 0.7, speed lines 0.9; the server blasts 30 in radius 18. `DioRollerOff` leaps the body 14 back; a wide cut (dist 44, fov 66) drawing to 36.
7. **Off (9.3)**: the anchor and the freeze released, `DioMove` under the walk 0.5 s later, the laugh runs on the voice line.
8. **Fade (11.2 to 12.0)**: fade to black in 0.4, the default camera wakes behind the body, bars and vignette off, fade in 0.5. The server restores WalkSpeed and JumpPower at done; the client never touches them.

## Reference material he sent

- A DevForge Studio TikTok for the ultimate: white flash frame, red dome, spiked crown, pillar with
  rings, inverted frame.
- A Megumin Explosion still from KonoSuba for the colour field.
- For a stand summon he wants the identity of the stand, not the ultimate's field (see taste.md).
