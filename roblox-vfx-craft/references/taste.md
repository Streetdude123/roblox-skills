# Lepy's VFX taste

Everything here is a sentence he said and what it turned out to mean in practice. He judges from a
recording or from play, by feel, and he does not explain. The rule is the meaning we found.

## Dense but readable

"The explosion at the end needs to be WAY more dramatic and longer ... too much empty space, not
enough particles." A clean first cut read as thin. He judges a frame by how full it is.

- Fill every phase: ambient sparkle fields across the whole arena, not only at the focus point.
- A climax is three waves (burst, sky star and cracked sphere, then a 240 stud dome with a 340 stud
  ripple and a smoke mushroom), debris rain and lingering smoke after. Bursts in the hundreds.
- Then the same night: "the speed marks kinda ruin it ... camera needs to zoom out more since its a big
  vfx ... you are doing a little too much so it feels kinda messy now." The fix that landed: forty
  percent fewer particles, two pillar sleeves and one beam removed, speed lines only as 0.4 s pulses
  on hits, every wide shot about 1.6x farther out.
- Layer count matters more than particle count for mess: one clean sleeve beats three overlapping.

## The Megumin vocabulary (for the ultimate only)

He sent a Megumin Explosion still from KonoSuba: "recreate all those colorful sparkles". Rainbow
four-point stars (cyan, green, yellow, magenta, pink, lavender, white) with tiny rings, dots and rays.
Keep the crimson core and wrap it in that field. It was the single biggest look win of the piece.

But: on the stand summon he said "star vfx doesn't really suit the world, try coming up with more
creative VFX that fits the world more and stands." So the sparkle field is not a default. It belongs
to the sword ultimate's look. Every character or stand gets a vocabulary from its own identity.

## The identity rule for stands and characters

Before any particle, write three words for what the character IS, then pick pieces that say those
words. Generic sparkles say nothing about a stand.

- The World (DIO): time, clockwork, menace. Candidate language: a clock face or ring that ticks and
  stops, gold and lavender energy with a dark core, a ripple of stopped time (a grey-out sphere edge),
  cracked glass shards, afterimage silhouettes in gold, the menacing "ゴゴゴ" aura as a slow heavy
  distortion rather than twinkles, a single hard pulse on the summon instead of a burst of stars.
- A fire stand would be embers and heat shimmer, an ice stand shards and frost rings, and so on.
- Asta (Black Clover): anti-magic, devil, raw strength. He first asked for "black and dark red,
  electric sort of", then "definitely not electric, just match the vfx with the references". The
  show has no lightning on Asta: black smoky flame on the blade with a red outline, red glowing
  pages. Match the reference frames over the adjective in the first request.
- The kit is large enough for this: `Auras` (rune ring with chain beams, gold beam fan, green floor
  rays), `Anime` (charge, shiny, lightning flipbooks, shield break rings, crack, shockwave, punch hits,
  wind, smoke, portal), `Big`, `Beams`, `vfx pack` (purple explosion kit), `VFX` (rings, spirals,
  spheres, spikes, EyeRing). Pick by meaning, then tint to the palette.

## No Highlight on the rig

"Don't highlight the character." A `Highlight` aura looked like a UI outline, not an effect.
Silhouettes inside impact frames are fine because they are the frame, not an outline on the body.

## Camera

"Camera needs to be even smoother, also don't pan back to the character at the end, when the vfx is
about to end, fade the screen black and bring it back."

- Sine in-out shots, an exponential follow lerp, low-frequency noise shake, always drifting.
- Far enough back that a 160 stud pillar and a 300 stud ring fit the frame.
- Impact frames want a dead still camera: freeze the rig for the frame length, no kick, no shot, and
  never combine a FOV punch with a dolly the other way (a dolly zoom reads as a wrong pan).
- End on a fade to black; wake the default camera behind the rig while black; fade in. No pan.
- He liked the cut list of the final ultimate as it was (raise push, blade close up, low front hero
  on the hold, angle whip on the slash, hard cut wide on the hit stop, long lens on the pillar, low
  base shot on the mid frame, tight on the frozen body, wide on the collapse). Keep that grammar.
- He wanted the opening slower: raise with wind only, then a QUIET two second hold at the top with a
  hero low shot and the pose breathing, then the charge, the peak, the slam. Quiet before loud.

## No text

An anime attack name card (Bangers font whip on the freeze) was built and removed the same night:
"text ruins it". Do not add text cards, subtitles or labels to his VFX.

## Too geometric

"Too geometric" on the pillar. He reads clean Neon solids (perfect cylinders, tori, outline rings,
flash balls, box slabs) as cheap. Build glow from Beams, soft particles, hand-stroke and ripple
meshes; keep any mesh solid at 0.35+ transparency with a glow particle behind it; rocks are real rock
meshes at random turns, not slabs.

## The kit rule

"Use the VFX kit I have given you, store the vfx you don't need in the server storage to be used for
later. I checked for backdoors already its fine." And later: "I'll always add vfx packs you can use."

- Every place will have his packs. Catalogue them first, build from them, archive the rest.
- Still run the script scan on every pack. A free pack shipped a `require(assetId)` backdoor once and a
  free crate carried a Command Bar social-engineering payload in a byte array; his check is a start,
  not a guarantee. See kit-workflow.md.

## The summon rung

"Animations kind of suck, its a simple summon so no cutscenes." Then: "don't make it so laggy when
you summon him, no change in quality though. Also don't make the VFX so crazy like impact frames for
summoning please, just lower down the tone its simple small vfx for summoning a stand."

- A summon is a gameplay toggle: no camera takeover, no letterbox, no vignette, no impact frames, no
  exposure flash, no world dimming, no body scaling, 1.0 to 1.5 s total, the humanoid free again under
  a second.
- "No change in quality" means the look stays; the lag fix is a join-time draw warm-up, not fewer pieces.
- It still needs a beat structure: gather, pop, rise, settle. Small is not flat.

## Cinematic character moves (2026-09-22, Asta)

- "animations need to be cinematic and dramatic please, you can slow or speed up for effect": on a
  character kit he wants speed ramps (slow contact hangs, a slow hero beat) and big beats, not a cutscene.
  The camera stays his: kicks only, no takeover, and the body is free again near one second.
- "i want it to be flashier, more amazing looking combos" and "It's a heavy sword remember": a combo gets
  a slash arc, an afterimage and a cut line on every hit, debris and cracks on the heavy ones, impact frames
  and speed lines on the finisher only, and heavier hit stops and kicks. The weight is in the motion first.
- "the vfx isn't too geometrical" (2026-09-22 night, again): no solid Neon copies, bars or blocks on a move;
  soft flame, beams with a streak texture, particle debris and kit sprites only.
- "don't send me screenshots also its okay": he judges in Studio himself. Take captures for review and
  report what they show in words.
- "the vfx covers the book and makes it's general shape with its quantity" (the grimoire while the sword is
  out) with a reference frame: an object drawn by an effect is a thick frame of particles on its edges,
  bright red right on the edge fading out into red smoke with dark crimson streaks, and the object's face
  left visible and lit red inside it. A filled box of flame buries the object instead of drawing it.
  Deep saturated red, not pink: keep LightEmission at 0.4 to 0.6 on the red layers when the background is
  pale. The code emitter `smoke` texture 16669188960 reads as bubbles at small sizes; use `darksmoke`.
- "Make sure it's a cutscene copying the video I sent you" (the Asta ultimate, 2026-09-23): copy the reference
  shot by shot (the same shot order, the same angles, the same beat lengths), then fix what Roblox changes:
  his day lighting (he kept it, so white energy needs a dark partner), his avatar's accessories, R6 reach.
  The screenshot rule changed for this: "send ss of the ultimate" - when he asks for screenshots, send them.
- The same day he set standing code rules: UI and VFX as real instance trees, no comments, few guards, ask
  before assuming, nothing extra. See the animation skill's project-style.md and his memory.

- "look at your reference, see the vfx?" (Bull Thrust, 2026-09-23): when he gives or approves a reference, read its
  effects before building and name them (the arcs, the streaks, the flare, the spikes), then build those in his palette.
  An effect list chosen from the kit's habits instead of the reference read as "not dramatic" for a strong move.
  "don't include the bull": copy the effects of a panel, not its creatures or props.

## Related feedback on animation

His animation feedback lives in the `roblox-r6-animation` skill. The one that crosses over: the
clip and the effects must key off the same schedule, and gameplay moves never lock the body for
more than a second.
