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
2. **Write the palette and the schedule.** A `Config.Palette` (one dominant hue, one accent, a pale
   core, a dark rim), a `Config.Sparkle` list, and one `T` table of beat times that the clip, the effects,
   the camera and the sound all key off. Name the hero element of every phase. See `references/cinematic.md`.
3. **Block in the timing in grey first** with carriers and plain textures until the gather, the overload and
   the dissipation read (`references/principles.md`), then **build phase by phase** with the modules in
   `scripts/` (`references/modules.md`): each phase is one function that spawns into a `workspace` model,
   and `cleanup` destroys the model.
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

## Principles from the style guides (short form; `references/principles.md` has the sources)

- Readability first: every phase names ONE hero element that gets the brightest value, the most saturated colour and the largest size; secondaries sit a step down (`Kit.scale` 0.5 to 0.8, `LightEmission` 0.6 to 0.8). The hit point shows a flash and a ring; sparks and smoke leave it so the body stays visible.
- Scale of importance: size, brightness, duration, camera and sound all scale with the move's tier (light hit 1 to 3 studs 0.3 s; heavy 3 to 6 studs 0.6 s with a kick; special 6 to 15 studs 1 to 2 s with a build-up; ultimate 50 to 300 studs in waves). A summon that looks like an ultimate makes the ultimate small.
- Value and colour: pale cores, not white (white only for a flash under 0.1 s); a dark rim (smoke, `deep`) under every glow so the burst has weight; one dominant hue, one accent, a pale core, a dark rim per effect; a damaging effect has more contrast than a friendly one.
- Shapes: every hard mesh gets a soft partner (a glow particle, a puff, a Beam) and sits at 0.35+ transparency; sparks are stretched 2 to 4x with `Squash` and `VelocityParallel`; one flipbook hero per burst, not one per layer.
- Timing: anticipation (an inward gather 0.2 to 0.6 s on a move, 1 to 3 s on an ultimate), then the overload in one or two frames (`Emit` bursts, the flash, the light spike), then process time that is longer than the impulse but short (sparks 0.3 to 0.6 s, smoke 0.8 to 1.5 s, rings 0.4 to 0.8 s). Nothing linear: bursts ease out, gathers ease in, sparks arc under gravity and drag. A big blast is waves, not one bang.
- Block in the timing first in grey with plain textures; style hides bad timing. When a burst reads soft, fix the timing before adding particles.
- Juice on every hit: contact flash and sparks, the target flashes white for 2 to 3 frames, camera kick 0.1 to 0.9, hit stop 0.05 to 0.09 s, bass under the hit, debris and dust that linger and fade.


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
- 2026-09-22 (Asta, Grimoire Battlegrounds): "the 5 lead clover which is demonic so make sure VFX is
  black and dark red, electric sort of", then while it was being built: "yeah definitely not electric,
  just match the vfx with the references". The references (the show's frames) have no lightning: a
  black blade with a red outline, black smoky anti-magic, red glowing pages. The vocabulary built from
  his kit: black flame wisps (the `Fire-Aura-01` flipbook 16676455805 tinted black, LightEmission 0) over
  a dark red rim copy (LightEmission 0.9), red specks 8068783649 as embers, the black ash flipbook
  16955854038, the `Shoot-01` ring as black under dark red, the `Slash-Impact-01` and `Punch-01`
  flipbooks tinted red over black on hits, `Crack-01` in black for the slam, and a Neon red plate plus a
  red light (1.4 / 8) on the open pages. Palette: black 8,5,6; smoke 22,14,16; rim 120,6,14; core
  200,22,30; pale 255,96,96. Move rung for the M1s (a kick 0.14 to 0.42, hit stops 0.05 to 0.1),
  summon rung for the draw and the sheathe (no camera).
- Lessons from that build: the `Smoke-01` flipbook tinted pure black draws flat black balls, so puffs
  use the dark smoke sheet 10180479311 at 0.45 transparency instead; hit effects spawned at the
  victim's root hide inside its torso, so move them 1.1 studs toward the attacker; an untinted kit
  piece keeps its own colour (`Big-Crack-01` flashed orange), so tint every piece; page smoke at rate
  34 engulfed the whole body, 16 reads; a floating companion prop (the grimoire) is a world-space
  spring (f 1.7, damping 0.85) toward a spot at the shoulder with a bob and a sway on three unrelated
  beats and a lean from its own velocity, stiffer (f 5.5) when it is presented; with 10 s of tool
  latency a sub-second hit effect needs TimeScale 30, not 6 to 10, to be in a capture.
- 2026-09-22 (Asta, late): "make sure the animations looks the BEST as possible, animations need to be
  cinematic and dramatic please, you can slow or speed up for effect", then "Make sure the animations need
  to be cinematic and dramatic okay? And that it looks the best, don't send me screenshots also its okay".
  The clips got speed curves (slow contact hangs, a slow hero pose in the draw, a slowed swallow in the
  sheathe) and the effects followed the new beats without taking the camera: the open pages boil at 2.4x
  and the page light flickers while he strains on the hilt, the raised blade flares (34 wisps, 22 rim, 18
  embers and a dark red flash at mid blade) on the hero beat, the flourish cuts get the smear trail, the
  slam and the spin landing get a black-over-red ground ring with grey dust, the spin takeoff a smaller
  ring, and kicks of 0.22 on the pop, 0.16 on the slam and 0.18 on the spin landing. The spin smear is
  0.12 s: at 2700 degrees a second a 0.24 s smear draws a full black disk. Effects keyed to a warped clip
  fire on the clip clock, so a delay after an event is in real seconds (the pop wisps moved from 0.07 to
  0.15 s because the pop now plays at 0.35x). Locks stay near one second (0.96 draw, 0.88 sheathe, 1.01
  finisher). He does not want screenshots sent; captures are for Claude's own review.
- 2026-09-22 (Asta, later): "i'd like if the vfx and animation combos would be more flashier and amazing,
  like its pretty nice im not gonna lie but i want it to be flashier, more amazing looking combos" (with the
  heavy two-handed rebuild of the combo). Added on the MOVE rung, never taking the camera: a slash arc on
  every hit from the kit's anime slash plates (`FancySlashDark` black under `FancySlash` in the core red and
  a pale copy; the crescent is an arc of 0.45 of the plate round its centre, so the plate centre sits on the
  fists, the plate lies in the swing plane taken from the blade's turn over the last frames (walk back until
  it turned 25 degrees, which works for a 2700 degree a second spin and a slowed clock), and it sweeps on 22
  to 40 degrees while it grows 0.82 to 1.1 and fades over 0.34 to 0.45 s); a dark red Neon afterimage of the
  body and the blade on each hit (a black second one on hits 3 and 4, three during the spin); a thin black
  cut with a pale core across the body that was hit along each swing's line; red sparks and grey grit when
  the blade tip drags on the floor (one raycast a frame while the tip moves); a dust puff where the lead foot
  lands; on the slam slate chunks thrown up and falling under gravity, a red crack and the `Big-Crack` burst;
  on the spin the kit's wind ring flat round him in black over red spinning with the whirl; on the
  finisher's hit two impact frames (blood red with black cutouts 0.05, the void with red cutouts 0.04) and
  a 0.85 speed line pulse. Hit stops 0.07/0.07/0.09/0.12, kicks 0.2/0.2/0.34/0.55 for the weight.
- Lessons from that pass: a flat slash plate in a vertical swing plane is edge on to a camera behind the
  player (a chop from behind drew nothing), so each client tips the plate toward its own camera until it
  faces it by at least 0.55; the rock meshes 3027924097, 1254390558 and 4933939521 on a SpecialMesh load at
  their own huge size (giant spiked balls on the first slam), so debris is plain slate blocks and wedges
  sized in studs; screen_capture does include ScreenGuis (the speed lines showed); to catch a sub-second
  hit effect, hold the clip just before the hit (a debug hold attribute), set TimeScale 12 to 20, release,
  and capture 1 to 2 s later; the impact frame viewport still cost one 41 ms frame on the first finisher of
  a session after the join warm-up.
- 2026-09-22 (Asta, night): "make sure the swings have full range of motion and the vfx isn't too geometrical
  please". Taken out: the Neon block afterimages of the body, the Neon cut bars, the slate block debris
  and the solid wind ring mesh. In their place: a burst of the blade's black flame and red rim with a soft
  dark flame breath off the torso; the cut as camera facing Beams from the middle out with the kit's light
  ray texture 1053548563 (black 2.2 wide, core red 1.4, pale 0.5) pinching off over 0.26 s; slam debris as a
  burst of the ash flipbook thrown up under gravity plus a rolling dark dust wall; the spin as the kit's
  `Tornado-01` wind swirl sprites in black over red. The kit's "rock" meshes 3027924097, 1254390558 and
  4933939521 are faceted spiky shapes (2.3, 16.3 and 5.0 studs native), not rocks: never use them as debris.
- 2026-09-22 (Asta, last): "use the vfx pack kit for the little vfx spin thing cause it's too geometric with
  its squares and stuff". The spin already used the kit's `Tornado-01`, but one of its sprites (`Windspin3`,
  12685367098) has a solid black background: tinted black at LightEmission 0 it drew a black square. A
  test sheet of every kit sprite tinted black at LightEmission 0 found the same square behind `Crack-01`
  Floor1 (used black under the slam and the drag), `Slash-Impact-01` SlashImpact1, the Explosion specks and
  the Wind smoke, and the Sparkle/Sparkles textures. Such sprites only work additive (LightEmission 1,
  where black adds nothing); on a dark tint use the ones with clean alpha (`Windspin1`, `2`, `4`, `5`,
  `Crack` Floor2). Render every kit sprite dark before using it dark.
- 2026-09-22 (Asta, after the grip pass): "make the grimoire covering in a red vfx when the sword is out9
  like the same vfx that's on the sword but like loads of it to the point where the vfx covers the book and
  makes it's general shape with its quantity", then a reference frame (the open grimoire lit red, its
  outline burning in thick red smoke with dark streaks, the pages still readable). Three passes. One box
  emitter over the whole closed book read as red patches on a dark slab. The frame came from four thin
  strips on the book's edges, but the `smoke` texture 16669188960 drew as round bubbles and the additive
  glow read pink on the pale floor. The final layers per stud of edge (rates scale with the strip length):
  a line of `glow` 34/s (size 0.3 to 0.46, LightEmission 0.6, 255/26/26 to 190/10/16), a bloom of `glow`
  12/s (0.5 to 0.95, LE 0.5), red smoke from the `darksmoke` texture 20/s (LE 0.4), dark crimson blotches of
  `darksmoke` 12/s (60/4/8 to black, LE 0), the blade's red flame 10/s and its black flame 4/s, all
  `LockedToPart`; a thin `glow` veil over the covers (16/s at 0.8 transparency) and two red PointLights 0.9
  off each cover (brightness 3, range 4). About 630 particles a second; idle frames stayed at 16.6 ms median
  and 18.9 worst. A shape made of particles is an edge frame, not a filled box: the eye reads the outline,
  and the face stays visible inside it the way the reference shows. See taste.md.
- 2026-09-23 (Asta ultimate): "i'd like you to create an ultimate ability like this please where asta raises
  the sword above his head gripping it with 2 hands and the sword grows with astronomical size by pressing Q
  and once it grows to it's full size it can be slammed down in the direction the player is facing when
  pressing Q again. Make sure it's a cutscene copying the video I sent you and make it look really cool with
  amazing VFX please", then "/roblox-vfx-craft make sure cutscene is cinematic", "send ss of the ultimate"
  (he now wants screenshots of the ultimate), "asta hold's the handle of the sword above his head by the way,
  fix that" and, after the R6 reach limit was explained, "Nevermind just keep it like that". He answered the
  open choices: turn only in the hold with a 15 s auto slam, 55 damage plus a launch and a 30 s cooldown,
  keep the current (day) lighting, Q only with the sword out. Rules he set the same day: every UI and VFX piece
  is a real instance tree (templates in `Assets.Ult` and a ScreenGui in StarterGui, cloned and driven by
  code), no comments in code, few defensive guards, nothing he did not ask for. The build is in
  cinematic.md ("The phases of the Asta sword ultimate"). What the captures taught:
  - The giant blade is an anchored clone of the blade mesh placed at the hilt every frame (len x70 = 384,
    width x16 = 24.6), its direction low-passed (lag 0.3 s growing, 0.05 s slamming) so the tower moves with
    weight, and clamped at -1.5 degrees so the tip never dives. It casts no shadow: its shadow darkened him in
    every close shot. Grow the length first and the width late; wide early read as a slab.
  - The clip's lightning (thick black bolts with magenta-crimson rims) is a template of 13 attachments and
    12 core + 12 rim Beams with no texture: core black LE 0, rim 205/14/44 LE 0.7, width tapered to points,
    the path re-jittered every 0.04 to 0.08 s. Widths must scale with the camera: 1 to 1.5 studs in close shots,
    7 to 11 studs and 60 to 170 studs long at 300 studs, four to six alive at once.
  - The kit's `Fire-01` flipbook (13818306392) is an orange texture: tinted white it stays orange. Use the
    grayscale fire aura flipbook 16676455805 for white flames.
  - White flames on a day sky: at LightEmission 0.85 the eruption became one white blob that hid him; a ring
    (Disc with ShapePartial 0.55) of white flames at LE 0.25 plus a ring of black flames reads as flames with
    him dark in the middle.
  - An avatar's accessories and the raised arms block close shots; pick angles per shot and capture them.
  - Tests: a covered Studio does not render (RenderStepped 0) and captures time out; bring it forward with
    user32 first. Slowing only the client desynced the server's hold timer; the server delays now multiply by
    the TimeScale attribute set on the server. Screenshots he asked for come from a desktop capture of the
    Studio window cropped to the viewport (shot.ps1 with offsets), sent with SendUserFile.
  - Measured at normal speed: both dummies in the line 300 to 245 and launched, the one outside untouched;
    frames median 19.8 ms over the whole cast, worst 50 ms on the first cutscene frame, 34 and 36 ms at the
    impact; 0 warnings on client and server.
  - Then on the eruption: "Make sure you use wind vfx instead of that smoke thing for the growing, it's just
    covers up too much", and after a wind version: "no no keep the smoke but it has to be angled behind him on
    the ground not floating", "see?" with the clip's frame (a wall of white flame spikes growing from the
    ground behind him and to both sides, him dark in front). The eruption is now a 46 x 10 stud strip 8 studs
    behind him that burns 0.8 s (white 238/244/255 to 165/185/230, LE 0.25, rising 6 to 16 studs a second,
    plus a few black flames) with the rising wind streaks round him; the wind spiral was taken out because the
    frame has none. An effect that sits between the camera and the body reads as "covers up too much" even
    when it is the right element: put it behind the body relative to the shot.
  - Then "zoom in so i don't see the ends of the wind": the eruption shot moved in until the wind streaks
    leave the frame on both sides. An effect whose ends show in frame reads as a prop; crop it with the lens.
- 2026-09-23 (refactor): "fix the scripts all of them and make them modular and follow the rules i give you",
  scope "All 27 scripts", and "Delete the script" for an empty font READ ME. Every emitter, trail, light and
  carrier the combo VFX built with `Instance.new` became a saved template in `Assets.Fx` (the book aura is a
  Model with its offset from the book saved as a CFrame attribute, measured from the old runtime bounds); the
  impact frame and speed line ScreenGuis are saved in StarterGui with Enabled false. Trap: a Camera saved
  inside a StarterGui ViewportFrame does not reach the client (Cameras do not replicate), so the viewport
  camera is made on the client the first time. Prove a refactor did not change the look with numbers: every
  clip pose against the backup (3.6e-7 studs), the solve cache hit count, spawn lists per hit, then captures.
- 2026-09-23 (Asta, after the videos): "don't add an impact frame for the last m1 please but it should still be impactful
  without an impact frame" (he chose a longer freeze and kick plus a bigger burst: hit stop 0.12 to 0.18 s on both bodies, the
  server delays the knockback by the same 0.18 s so the target hangs before it flies, kick 0.55 to 0.75, ring 2.2 to 3.1, crack
  0.45 to 0.63, embers 34 to 48, ash 16 to 22, puffs 1.4x); "Clean up the impact frame on the sword by the way it looks kind of
  bad, especially those speed lines" / "Like the ultimate pact frame" (the slam impact frame keeps white, black and red with
  no lines, and the camera now stays frozen until the red frame ends: a cut on a fixed delay landed inside the frames and
  the blade jumped); "yeah also remove the speedline for the m1's those don't look good". The procedural speed lines are
  gone from every Asta move: do not use them for him. Then "make the falling of the sword way More cinematic" (he chose a
  slow-motion fall with cuts, and shadow plus air pressure): the fall is 0.95 to 2.46 s through the clip warp (slow hang at the
  top at 0.12x, a violent last drop at 2.4x) over three shots: a low shot from the SIDE looking up (from the front an
  edge-first blade is a needle), a ride on the blade (camera follow on a point at 30% of the blade, the lens near the tip
  looking down at him and the arena; looking up the blade showed only sky and the sun), and the wide side shot for the last
  0.3 s. The shadow is a soft black `glow` image on a SurfaceGui projected along `Lighting:GetSunDirection()`: a straight
  down projection hid under the blade in every shot. The air pressure is dust and wind streaks blown sideways off the line
  0.2 s before contact (dark dust 96/88/80, light dust vanished on the pale floor from 300 studs).
- Capture trap from that pass: after hours of pushes and Play sessions Studio held 4.5 GB private on his 6 GB machine and
  stalled for 0.6 to 1.9 s during takes; a recorder at 75% size with two JPEG threads and closing every browser tab gave
  clean takes again. The fix that lasts is a save and a Studio restart, which is his call.
- 2026-09-23 (Asta block and dash, MOVE rung): "Create a blocking and dashing system now, I frames for the dash frames, asta is
  strong but make sure to incorporate it's weight as asta use's the sword's real weight to attack", "perfect block is none, i
  want it parry based like deepwoken", "don't mlae UI for the guard meter please", "By the way clicking f activates the parry,
  if you click f you'll be vulnerable, holding f means you're just blocking". No UI, no sounds (the kit has none), no camera
  take, no speed lines. Dash: push = dirt puff 5, ash 4, a 0.55 black-over-red ring at the feet, blade wisps 16 and rim 8 with
  the smear on for 0.16 s, kick 0.08; the i-frames read as two `Echo` afterimage bursts (life 0.26, alpha 0.6) at 0.16 and
  0.24 s that leave black smoke along the path; skid = puff 7 and rubble 3, kick 0.14 armed and 0.08 sheathed. Block = a pale
  flash 2.6 for 0.06 s, 14 embers, `Hit` 0.7 pale to rim, kick 0.12 on the blocker and 0.08 on the attacker. Parry = a pale
  flash 6 for 0.08 s, a 1.7 ring facing the attacker, 36 embers, puff 5, `SlashImpact` 1.2 with 8 + 8 specs, 0.1 s hit stop
  on both bodies, kick 0.35. Guard break = a core red flash 5 for 0.1 s, `BigCrack` 0.5 red over black, 30 embers, ash 16, puff
  8, kick 0.45. Measured first casts: dash median 20.0 ms worst 23.8 against an idle 17.9 / 22.8; first guard and parry median
  19.5 worst 23.9 against an idle worst of 25.6.
- Two traps from that build. The kit's `Crack` Floor2 sprite tinted black at LightEmission 0 draws an opaque dark square about
  6 studs wide (seen on the guard break floor hit; the shared `floorBite` helper of the M1 floor hits uses the same call), so
  the guard break uses a ring, dust and embers instead. The floating grimoire's spring (f 1.7, z 0.85) lags 2 x z x v / w
  studs: 2.5 at walk speed, about 14 at a 90 stud/s dash; feed the body's velocity into the spring above 20 studs/s (full at
  60) and raise f to 4 during a dash so the walk float stays as he liked it.

- 2026-09-23 (Asta Bull Thrust, MOVE rung): "add vfx to bull thrust please", his picks "Trail, bursts, shockwave" and
  "No camera effect", then "vfx for thrust needs to be more dramatic, it's a strong move okay?" and, with the manga
  panel of Bull Thrust, "don't include the bull though, look at your reference, see the vfx?". The panel's effects:
  big curved wind arcs spiralling round the thrust axis and meeting at the tip, straight streaks along the path, a white
  flare at the tip on contact and heavy black jagged spikes out of the impact. Built from his kit: brace = red `Crack`
  under the back foot, grit, the blade's flames and the grimoire straining; burst = a black-over-red `Shock` ring 1.5
  behind the launch, a red-only `Shock` 3.4 under it, red `Crack` 1.3 and `BigCrack` Impact1 red over Impact2 black
  (0.6, Top), dust 12, rubble 8, ash 12, two slash crescents (radius 5.5 and 6) wrapping back round him, a `Tornado`
  vortex (Windspin1/2/4/5 only, black LE 0 under red LE 0.8) with its Y axis on the thrust line at the tip, a red-only
  forward `Shock` ring ahead of the tip, a pale tip flash 5; flight = every 0.045 s a slash crescent in the plane
  across the thrust axis whose middle turns 75 degrees per tick (a drill tunnel of crescents along the path), two
  cut-line streaks 1.8 studs to each side at 0.4 width, a pale tip flash 2.4, the tip vortex every second tick, an echo
  every third, dust under him; hit = pale flash 9, `Hit` black 2.4 under pale 1.9, `BigCrack` Impact1 red over Impact2
  black (0.9, Front), `SlashImpact` 1.8 with 10 + 10 specs, a red ring, embers 44, ash 16. No kick. Measured: thrust
  frames median 17.0 to 18.4 ms against an idle 16.9 to 17.5 (the worst frames matched Studio's own idle stalls).
- Traps from that build: a black-under-red `Shock` ring facing the camera draws as a solid black disc in its first
  frames and hid the body (use a red-only additive ring for anything between the lens and the body); a camera-facing
  cut-line beam along the view axis (the player's camera behind a straight dash) degenerates into a huge dark wedge
  over the lower screen, so keep path streaks off the centre line and thin; a clip hold (`AstaHoldAt`) freezes the
  body but not a spawn loop, so judge a moving trail from a timed capture at TimeScale 20 instead.
- 2026-09-23 (other players' view, team test): "the animation and VFX is visually broken for other players ... especially
  the ultimate where the sword grows not upwards", "Observe my teamtest right now, when i die everything get's buggy",
  "make sure camera resets when you're hit on the ult", "ult can be interupted", a screenshot of his friend's screen
  "after having his ult interuppted" (bars, blur and the cutscene camera stuck), "Also my friend can't attack or dash",
  "it happens after a ragdoll". Causes: the cutscene released the camera only on its last event, so an interrupt left
  the camera, bars and depth of field; a controller was never stopped on death (a deferred AncestryChanged is dropped
  when the body is destroyed), so a dead body's burning grimoire stayed and its render step errored every frame; the
  stun end time was the server's os.clock read against each client's own clock. Now any non-ult action that interrupts
  the ult runs the full cutscene stop on that client, and the server's cancel sets an attribute every client listens to.
  He chose: a hit in any phase cancels the ult with the full 30 s cooldown, and the eruption pushes everyone within
  26 studs away with the ult's knockback (70 out, 100 up).

- 2026-09-23 (ult landing): "the ultimate is WAYY Too hard to land" with "armor" in all phases, "Wider impact, Faster fall, Aim assist". The slam fall (a cinematic slow hang he asked for) now runs 0.42 to 0.5x instead of 0.12 to 0.18x through the hang: the impact lands 1.19 s after the press instead of 2.45 s, and the cutscene shots, keyed to the clip events, still read (a low side shot looking up at the tilting blade at clip 0.5). Gameplay needs beat a hang: a cinematic beat that gives opponents 2.4 s to walk out of a line is too long for a move that must land.

## Reference index

- [taste.md](references/taste.md) - his taste in full, why each rule exists, and the identity rule for stands.
- [kit-workflow.md](references/kit-workflow.md) - quarantine, backdoor scan, archive, catalogue, mesh gallery, dead sounds, template folder, warm-up.
- [modules.md](references/modules.md) - Tw, Emitters, Kit, CameraRig, ScreenFx, ImpactFrames, SpeedLines: API and traps.
- [cinematic.md](references/cinematic.md) - the schedule pattern, clip drive, camera language, phases of the ultimate, the summon's phases.
- [sound.md](references/sound.md) - the mix, Mirelo clips, measuring a recording, dead private audio.
- [verification.md](references/verification.md) - quality level, capture cache, occluded Studio, phase polling, frame profiling.
- [principles.md](references/principles.md) - the style guide and tutorial principles (readability, scale of importance, value and colour, shapes, timing, block-ins, juice) translated to Roblox properties and numbers, with sources.

## Scripts

- `scripts/Tw.lua`, `scripts/Emitters.lua`, `scripts/Kit.lua` - tween, code emitters and kit template helpers.
- `scripts/CameraRig.lua`, `scripts/ScreenFx.lua`, `scripts/ImpactFrames.lua`, `scripts/SpeedLines.lua` - the cinematic layer.
- `scripts/SummonVfx.lua` - the small rung worked example (DIO summon: the clock gather, the tick pop, gold echoes, the charge and heartbeat idle, the join-time warm-up, `afterimage`, `standParts` that skips `Tr 1` parts, `rigOf`).
- `scripts/Moves.lua`, `scripts/TimeStop.lua`, `scripts/MovesServer.lua` - the move rung (barrage with fist streaks, flashes, arm echoes and a finisher) and the cinematic move (the time stop call, the freeze, the resume) with the server that runs hitboxes, freezes the world, queues damage in stopped time and launches knockback through a 0.22 s `LinearVelocity`.
- `scripts/UltimateVfx.lua` - the cinematic rung worked example (sword ultimate, 2272 lines).
- `scripts/RebuildStandPlace.lua` + `scripts/rebuild/` - rebuild the whole DIO place from a fresh baseplate that holds his packs, the old Stand model and the free model.
- `scripts/RoadRoller.lua` - the second cinematic piece (the road roller: a procedural root and roller on one beat table, the land, the rush on the deck, the boom, the fade; the server side is `startRoadRoller` and `blast` in `MovesServer.lua`).
- `scripts/ScanPack.lua`, `scripts/MeshGallery.lua`, `scripts/BlankDeadSounds.lua` - the pack intake tools.
