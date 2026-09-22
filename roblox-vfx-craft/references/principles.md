# Principles from the VFX tutorials and style guides, translated to Roblox

Read 2026-09-22 at Lepy's request ("search up tutorials like the animation and stuff and improve the
VFX skill"). Every rule is restated in this skill's terms with the Roblox property or the number it
implies. Where a source disagrees with something he asked for, his sentence wins and the disagreement
is noted. Sources at the end.

## 1. Readability first: one focal point, then secondaries (Riot style guide)

An effect exists to tell the player what happened, where, and how big. The primary shape must read
in one glance; secondary elements support it with lower value and saturation and never compete. "If
it's distracting, the effect isn't doing its job."

Roblox translation:
- Every phase of an effect names ONE hero element (the ring, the pillar, the clock, the flash). It
  gets the brightest value, the most saturated colour and the largest size. Everything else sits one
  or two steps down in value and size (`Kit.tint` with the palette's pale or deep colour, `Kit.scale`
  0.5 to 0.8 on supporting pieces, `LightEmission` 0.6 to 0.8 instead of 1).
- Never put the busiest element on the hit point itself: the hit point shows a flash and a ring; the
  sparks and smoke leave it. The player must still see the body that got hit.
- This is his "you are doing a little too much so it feels kinda messy" in the guide's words: layer
  count, not particle count, is what breaks readability.

## 2. Scale of importance (Riot style guide)

A jab and an ultimate must not look the same size. Size, brightness, saturation, duration, camera
work and sound all scale with the mechanical tier of the move. This is the tone ladder in SKILL.md
with a reason behind it: a summon that looks like an ultimate makes the real ultimate feel small.

Ladder in numbers: light hit 1 to 3 studs, 0.3 s, one flash and sparks; heavy 3 to 6 studs, 0.6 s,
flash + ring + debris + a kick; special 6 to 15 studs, 1 to 2 s, a build-up phase; ultimate 50 to 300
studs, 10 to 16 s, waves.

## 3. Value range and illumination (Riot style guide, DevForum)

Stay out of the extremes: never pure black or pure white as a whole element, and never 0 or 100
percent saturation; the mid range defines the palette and a WIDE range inside one effect draws the
eye (a white-hot core against a dark smoke rim). Add glow to push contrast where it matters.

Roblox translation:
- Cores are pale, not white: the summon palette's `pale (255, 240, 170)` for a core, `gold` for the
  body of the effect, `deep (40, 10, 70)` or dark smoke for the rim. A pure white flash lasts under
  0.1 s and is the only time white is allowed.
- `LightEmission` 1 with `LightInfluence` 0 is the additive glow layer; the smoke and rock layers keep
  `LightEmission` 0 and `LightInfluence` 1 so they read as solid and dark against it. Both layers in
  every burst, or the effect floats with no weight.
- Bloom is the illumination knob: threshold 1, size 32, intensity 0.55 in his places; at Level01 quality
  none of this shows, so check the quality level before judging a value.
- A damaging effect has HIGHER contrast than a friendly one: darker darks next to the whites (Keyser).

## 4. Colour: one dominant, one complementary secondary (Riot style guide)

Two complementary colours work only when one is clearly dominant and the other is the accent;
competing colours are noise. Elements carry meaning: green heals, blue is cold, orange-red is
gunpowder and heat. Palettes stay small.

Roblox translation: a `Config.Palette` per effect with one dominant hue (gold for The World), one
accent (lavender or violet), a pale core and a dark rim; the sparkle list is variations of those, not
a rainbow, unless the piece is the Megumin ultimate where the rainbow IS the identity. This is also
his "star vfx doesn't suit the world": the vocabulary comes from the character's identity and its
two colours.

## 5. Shapes: hand-drawn, soft plus hard, then moved (Riot style guide)

Good FX shapes are hand painted, a mix of soft and hard edges, and never layered so thickly that they
turn to mud. A shape must then MOVE with directional blur or stretch to read as motion and to say
where it is going.

Roblox translation:
- His "too geometric" rule is the same rule: clean Neon primitives are hard shapes with no soft
  partner. Every hard mesh (a ring, a crescent, a shard) gets a soft partner (a glow particle behind it,
  a smoke puff, a Beam) and sits at 0.35+ transparency.
- Directional stretch is `ParticleEmitter.Squash` (negative stretches along the velocity) plus
  `Orientation = VelocityParallel` for sparks and streaks, and `Beam`/`Trail` for anything that sweeps.
  Sparks that are round dots read as dust; stretched 2 to 4x they read as sparks.
- Flipbooks are strong but he already owns thousands of them: use a flipbook for one hero element per
  burst (a lightning pop, an explosion sheet), not for every layer (DevForum advice: do not overuse).

## 6. Timing: anticipation, overload, then time to process (Keyser, VFX Apprentice, Riot)

"Lead the brain with anticipation and then overload the brain in that moment that it's been waiting
for, and then give the brain time to process what just happened." The seven FX timing principles:
number of frames, keyframing versus straight ahead, ease in and out, anticipation (a crouch, a wind
up, a pull back before the main action), impulse versus rhythm, follow through, arcs applied to the
whole effect, stretch and smear.

Roblox translation, with the numbers the two builds settled on:
- Anticipation: a gather that pulls INWARD (`ShapeInOut = Inward`, rates rising, a light climbing) for
  0.2 to 0.6 s on a move, 1 to 3 s on an ultimate. It says where to look and how big the hit will be.
- Impulse: the hit is one or two frames of the biggest, brightest state (`Emit(n)` bursts, a flash at
  0.35 to 0.5 transparency, the light spike), then decay. Impulse effects appear in a strong burst and
  disappear the same way; rhythm effects (auras, idle loops) change gradually and loop.
- Process time: the dissipation is longer than the impulse but never long enough to stay in the way:
  sparks 0.3 to 0.6 s, smoke 0.8 to 1.5 s, rings gone in 0.4 to 0.8 s, embers up to 2 s at low
  opacity. "If your FX feel long, they're waaaaay too long."
- Ease: nothing linear. Size and transparency sequences ease out (fast start, slow end) on a burst,
  ease in on a gather; the flash grows in 1 frame and fades over 6 to 15.
- Arcs: give sparks and debris `Acceleration` (gravity -20 to -40) and `Drag` 1 to 3 so they arc and
  slow, never fly in straight lines forever; apply the same to secondary elements so nothing drops out
  abruptly.
- Follow through: a ring keeps expanding as it fades; smoke keeps drifting after the flash is gone;
  the light decays over 0.4 to 0.6 s, not with the flash.
- Rhythm inside a long piece: waves. Three bursts at +0, +0.44, +0.9 s read as one huge explosion;
  one bigger burst reads as a pop.

## 7. Block in the timing in greyscale first (Keyser, realtimevfx)

Strip textures, colour and shaders, keep simple shapes, and adjust the timing until the effect has
its punch; then dress it. Style hides bad timing. Re-mapping the same block-in from slow to fast turns
a friendly spell into a damaging one.

Roblox translation: build a phase with `Emitters.carrier` parts and plain `circle`/`core`/`smoke`
textures in white and grey, capture the phase attribute timeline, and only then swap in the kit
pieces with `Kit.burst` and the palette. When a burst reads soft, fix the timing (shorter lifetimes,
fewer frames to peak, a bigger first frame) before adding particles.

## 8. Game feel: the juice list (Nijman, Vlambeer; Jonasson and Purho)

The "art of screenshake" tricks that apply to a melee or stand game: basic animation and sound on
everything; impact effects so a hit never just disappears; a hit flash on the target (flat white for a
few frames); knockback; permanence (debris and dust that linger and fade slowly); camera lerp;
screen shake on explosions; sleep (hit stop) of a few frames on a deadly hit; kick the camera in the
direction of the action; bass under hits; bigger explosions; dust after big explosions that fades
slowly.

Roblox translation:
- Every hit: a `Kit.burst` flash and sparks at the contact point, a target flash (the hit parts to
  Neon white for 2 to 3 frames, then restored from attributes), a `CameraRig.kick` 0.1 (light) to 0.9
  (ultimate), a `rig:hold` hit stop 0.05 to 0.09 s on the animation, and a hit sound in the hits group.
- Permanence: rock plates, dust rings and embers stay 2 to 5 s at low opacity after a big move; the
  ultimate's debris rain and aftermath smoke are this rule.
- Shake decays; it never sits at a constant level, and spectators get it with distance falloff.

## 9. Roblox particle craft (DevForum tutorials, his kit)

- `ZOffset` orders layers: fire in front of smoke, flash in front of the ring, the hero element on top.
- `Squash` stretches, `RotSpeed` with a random `Rotation` range keeps sprites from reading as stamps,
  `Lifetime` and `Speed` as ranges add variety; static values read as dull, but do not animate every
  property either (DevForum: keep some things simple, a static size can look better).
- One emitter is never enough for a good effect; a burst is 3 to 6 emitters with different textures,
  sizes and lifetimes (a flash, a ring, sparks, debris, smoke, embers). Beams and Trails make the shapes
  emitters cannot (sweeps, rune rings, pillars, lightning).
- `Emit(n)` for anything that is a moment; `Rate` only for gathers, auras and loops. `TimeScale` on
  emitters follows the effect's time scale so slow-motion captures line up.
- Warm every mesh, material and sprite once at join (the first-draw hitch), and keep the pack out of
  the streamed scene.

## Where the sources and his taste disagree

- Riot: "if it feels long it's way too long." Lepy on the ultimate: "WAY more dramatic and longer".
  Both hold: the CINEMATIC rung is a reel piece and may run 16 s; gameplay effects follow Riot.
- Riot: mid-range values, no pure white. His impact frames are pure white and black by design; they
  are a screen effect, not a particle, and last three frames.
- Vlambeer: more of everything. His "too much feels messy" caps it: add juice to the hit moment, not
  to every frame.

## Sources

- Riot Games, League of Legends VFX Style Guide (Jin Ho Yang), via VFX Apprentice, "10 Design Tips
  from the League of Legends VFX Style Guide" (2022) and the guide's public deck outline.
- Jason Keyser, "Block-ins and Timing", Real Time VFX forum (2025); VFX Apprentice course outlines
  "FX Timing Principles" and "FX Design Principles" (Dan Elder).
- Jan Willem Nijman (Vlambeer), "The Art of Screenshake" (2013), via the artificials.ch list of the
  30 tricks; Martin Jonasson and Petri Purho, "Juice It or Lose It" (2012).
- VisuallyFX, "Introduction to VFX: Particles", Roblox DevForum (2022); Meioua's answer in "How to make
  Emitter effects look good?", Roblox DevForum (2025).
- Johnston and Thomas, The Illusion of Life (the twelve principles), shared with the animation skill.
