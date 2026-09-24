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
- "also the ragdoll is really laggy and not smooth which is why it also doesn't feel clean either" (2026-09-23): a hit
  feels dirty when the body it launches steps. A server-simulated dummy reached the attacker's client every 3 to 5 frames;
  the attacker's client now runs the dummy's flight, and he said "issue fixed". Smooth motion of the target is part of how
  clean a hit feels, the same as the effects.
- "I sent a reference for bull leap if you want to look at it" and "don't forget to make bull leap VFX too" (2026-09-24):
  he picked "Reference + Asta" over "Asta palette only": the reference's broken floor, white shockwave and tan dust column,
  with his black-red flame, red crack and embers on top. The cracked floor is the floor he stands on (its own material and
  colour), not a generic rock. He picked "kick only" for the camera: no impact frame on a move even when the reference has one.
- "better realistic animations and better vfx to the dashing" (2026-09-24): realistic dust takes the floor's colour; dark
  generic dust on a pale floor reads as soot.
- "more vfx for when an attack is blocked and parried please" and "change guardbreak too" (2026-09-24): he picked white-gold
  metal sparks with Asta's red under them for a blade clash, not the all-red palette; a parry is a big clash without a camera
  change; a block is a smaller clang plus a brace at the feet. Kit star sprites at full size read as a sparkle field; keep
  clash glints few and small.

- "Make sure this water VFX looks really cool for me alright?" (Water Mage, 2026-09-24): a water mage's identity is bubbles, foam
  and flowing water in blue with pale foam; a clean glass ball reads as a crystal, not water, until foam and swirling water sit on it.
- "Don't really like how it cuts off here not smoothly" (2026-09-24, a screenshot of the laser start): he reads the edges of an
  effect first. A beam must grow out of its source (taper and fade in), never start at full width.
- "Make the gui super bareboens and insanely simple" (2026-09-24, the character select): plain buttons in a list, one text line,
  no menu, no tweens, no corners.
- "What we should take note on how this guy uses vfx to make his VFX look amazing, improve the water vfx significantly please it
  needs to look just amazing and anime like" (2026-09-24, with a Roblox "I AM ATOMIC" recreation) and "Don't copy the text though".
  The lessons are in study-atomic.md: a dark stage in the effect's hue, one hue family with white-hot cores, thin lines everywhere,
  an ambient layer in every frame, foreground depth, a rim light on the body, cel textures, and few repeated shapes. His picks for
  the water: a flash and a stronger kick on the laser (no impact frame, no world darkening, no speed lines), deep blue with a white
  core and white foam, an ambient layer only while casting, and a water trail on the dash. Never copy a reference's text cards.
- "Laser doesn't look natural like the bubbles it doesn't look as good, anime style though like get references from black
  clover and demon slayer on the internet" (2026-09-24). Straight stacked beams read as a light bar, not water. What reads as
  anime water: one thick body in deep navy and blue with flow stripes scrolling along it (Demon Slayer bands), width surges that
  travel along the stream, a thin wavy white core instead of a flat white bar, white spiral strokes around the body, and water
  blobs and foam curls streaming along and peeling off (the same flipbook sprites that make the bubbles look natural). Asked if
  the laser should get a dragon head: "No, torrent only".
- "Oh yeah sea dragon roar should be made as first ability" (2026-09-24). His picks: a homing curve toward the target under the
  crosshair, Bull Thrust numbers (12 damage, knockback and ragdoll, 10 s cooldown, breaks a block), a flash and a camera kick at
  the launch and the hit (the camera stays his), and a free model dragon head turned into water. The water look that won the
  comparison: SmoothPlastic blue at 0.35, a Neon cyan shell 1.07x at 0.82 and a white outline; Glass with a Highlight fill reads
  flat and dark, ForceField reads noisy.
- "Make the sea dragons roar slower and more dramatic and cooler" (2026-09-24). A 0.5 s flight was too fast to see. His picks: a
  2 s cast where the dragon forms first (rooted about 1.6 s), a speed ramp (slow 30 studs/s for 0.4 s so the whole dragon reads,
  then 90), the camera stays his (a low rumble while it forms, hard kicks on the roar and the crash), a bigger dragon, a whirlpool
  at the feet and water rain after the crash; no sound yet. "Dramatic" on a move means build-up, a hero beat and a speed ramp,
  not a cutscene.
- "Make sure it's blockable and parryable" and "I also think the sea dragon roar is a bit too much, tone it down" (2026-09-24,
  right after the dramatic pass). An ability may break a guard only when he says so; the Roar now blocks like an M1 and a parry
  cancels it. "Too much" was the size and the length, not the screen work: his picks were the dragon about 25% smaller and a
  1.6 s cast (launch 0.9, rooted 1.2); the rumble, flashes, whirlpool, crash and rain stayed. When a first dramatic pass lands too
  big, trim size and length first and ask before cutting the beats.
- "Remove the rain at the impact please" and "And make sure players can dodge sea dragons roar too" (2026-09-24). An aftermath
  layer (the rain) was one layer too many on a move. A homing move must stay dodgeable: his pick was that the dragon stops
  homing 15 studs from the target and flies at the target's last position, so a late sidestep or dash makes it miss, and dash
  i-frames still cancel the hit. Every attack he adds must answer block, parry and dodge.
- He sent a full "Water Knight Moveset" (Water Lance, Sea Dragon's Roar, Aqua Shield, Water Spear Rush, Valkyrie Armor ultimate)
  and wrote "Create aqua shield only please" (2026-09-24). Build only the item he names from a list, and do not rearrange the rest
  (the Roar stayed on key 1 although his list numbers it 2). Aqua Shield picks: key 3, 3 s with a slow walk and no attacks (the
  key again drops it), blocks all hits from all sides, and anyone within 7 studs is pushed 12 studs with 5 damage once per shield.
  Look: a translucent water sphere (SmoothPlastic 0.74 with a Neon glow shell and a white outline) with two thin torrent rings
  spinning round it like a gyroscope, foam and blobs on its surface, a splash on the side a blocked hit comes from, and a burst at
  the end. A large foam-ring flipbook sprite at the size of the sphere reads as smoke plumes at its edges; do not use it as a rim.
- "Create water spear rush now please" (2026-09-24). From his list: "Dashes toward an enemy while creating several water spears.
  The final hit launches the opponent." Picks: key 2, a dash with a spear volley (three stabs, then one big spear), 4 + 4 + 4 then
  10 with a ragdoll launch, block stops each hit, a dash dodges, a parry stops the rush and stuns the caster 1 s. Taste rules
  from the captures: the spears must read from his own rear camera (above the shoulders, clear of his companion accessory);
  a launch must visibly fly (the dummy travels about 18 studs); a miss must look like a miss (no splash on a target that dodged).

## Related feedback on animation

His animation feedback lives in the `roblox-r6-animation` skill. The one that crosses over: the
clip and the effects must key off the same schedule, and gameplay moves never lock the body for
more than a second.
