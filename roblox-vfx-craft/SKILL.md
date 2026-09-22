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
- `scripts/SummonVfx.lua` - the small rung worked example (DIO summon with the join-time warm-up).
- `scripts/UltimateVfx.lua` - the cinematic rung worked example (sword ultimate, 2272 lines).
- `scripts/ScanPack.lua`, `scripts/MeshGallery.lua`, `scripts/BlankDeadSounds.lua` - the pack intake tools.
