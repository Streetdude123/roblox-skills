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
- "Use the free models from workspace, just search up VFX and get all the vfx packs from there" and "You
  need to get as much VFX packs as possible to create customized VFX" (2026-09-24, a basketball
  commission with no kit in the place). When a place has no packs, pull free packs from the Creator
  Store into one `ServerStorage` folder, scan them, and build custom templates from their emitters and
  textures; the shipped effects keep only the copied pieces (`ReplicatedStorage.Assets.<Feature>.Fx`).
  The prize tiers were a size ladder on one template shape: Make (2 emitters and a sound), Common (3
  emitters), Rare (5), Epic (10, two sounds), Legendary (21 emitters, 2 beams, 3 sounds, a coin rain,
  firework streaks and a gold screen flash for the shooter only). A confetti texture drew dark squares
  at LightEmission 0.25; check every borrowed texture at the real LightEmission in a capture. The first
  Legendary cast measured 17.8 ms average and one 30.4 ms frame at QualityLevel 21 while the recorder ran.
- "UI should be super barebones, and very simple please" (same commission). A scripting test wants
  plain labels and one bar: the cash label, a gain label and the meter; no panels, no popups.

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
- "i kind of want water spear rush to function like the one star mantra ice blade in deepwoken, but more flashier and cooler, just
  search it up" (2026-09-24). He names a reference from another game and expects me to look it up: read the wiki rules and watch the
  GIF before asking. Deepwoken's Ice Blade: two ice sabers, a 0.5 s windup, a rapid flurry of 4 forward slashes (first hit hardest),
  a 10 s cooldown, a parry cancels it, a right-click after any slash cancels it, and the sabers shatter into shards at the end.
  His picks: flurry only (no dash, about 6 studs of steps), shatter plus launch, a water saber over the wand plus one in the left
  hand, the right-click cancel, the first hit hardest (6, 4, 4, 5). "Flashier" meant: layered water blades, a water swipe sprite in
  every slash plane, a crossed-sabers glint, a crossed water X on the last slash, and a shard burst. Traps: full-blade saber trails
  with FaceCamera off draw flat pale panels in the player's camera, so trail only the outer half of the blade with a streak texture;
  a dark trail under a fast blade draws big dark smears; a Grid8x8 crescent flipbook starts as a full white disc, which reads as a
  10-stud white blob.
- "i don't like the water shield vfx's its just so basic and just has too much space as in not much vfx" (2026-09-24). Picks: spiral
  water streams, orbiting drops and bubbles, mist and splash pulses, and the sphere kept with moving ripples, a brighter rim and a
  second shell turning the other way. A single translucent ball with two rings and edge foam read as empty; fill the surface itself
  (caustic flipbook sprites locked to two counter-turning shells), the space around it (8 spiral Trails from the ground to the top,
  orbiting bubbles and glints) and the ground (mist, a splash ring every 0.5 s). Pale caustics on a pale shell disappear: the shell
  needs a deeper blue and a dark caustic layer for contrast.
- "the vfx and animation for the water spear rush needs to be more dramatic and flashier" (2026-09-24). His picks: water
  afterimages, hit stop on hits, bigger arcs and ground spray (not stronger kicks or a flash). Flashier for him means more
  layers that trace the body's motion (afterimages, a ring round the spin, spray under the steps, a frozen instant on each
  hit), not a bigger single burst: a finisher burst that fills the frame hides the launch. Afterimages must read as water, not
  as solid blocks.
- "M1's must lock the player in place for rotation by the way and movement", "shots just face where you are looking at not
  where your cursor is" (2026-09-24). Casting attacks root the caster: no walking, no turning, and shots follow the camera
  heading, never the cursor.
- "water magic currently aims to the floor right now, it needs to aim straight ahead from the body, perpendicular from the
  torso and in the direction it's facing" (2026-09-24 night). The camera heading is its yaw only: a shot flies flat along the
  body's facing. Aiming at the point the camera centre ray hits sends every shot into the floor, because his camera looks
  down at the body.

## Replicating a reference image (2026-09-27, pink ground spike eruption)

- "Using VFX packs or online resources on the internet for custom images for VFX, replicate this exact VFX with nearly 100 PERCENT
  accuracy please" (a still of a magenta spike shooting out of a dark concrete floor). His picks: click on the ground, a quick burst of
  about 1 s with the crack staying a little longer, the dark scene matched (floor, light, vignette), visuals only.
- "search up vfx in the toolbox and click on every vfx pack that has a high rating use that" and "only look at the first page by the
  way". The first page of the Toolbox search "vfx"; ratings come from `apis.roblox.com/toolbox-service/v1/items/details?assetIds=`
  (upVotes, downVotes); nine packs had 95% or more with 40 or more votes. Scan them one at a time (6 GB machine), delete each after
  noting the texture ids that fit.
- "look's nothing like the reference??" He watches Studio while I build: an unfinished frame is judged as the result. Say what is
  still missing before he sees it, and get the hero layer on screen first.
- "Remember you'll have to either learn how to make your own VFX textures with super high quality or learn the internet for searching
  exact textures needed, vfx packs can't help you for lots of these custom textures". The pack pieces only approximated the shapes;
  the build started to match the image only after I painted the hero textures myself (the crown of motion-blurred wedges, the
  streaky spire, the torn crack ring) and compared each paint against a crop of the reference. The method and the engine facts are in
  `references/textures.md`.
- He then sent a zip of textures that ChatGPT had picked (Kenney's CC0 particle pack with a read-me). Most overlapped with the painted
  set; the tall ragged flame (02_beam_fringe) was new and became the white-hot flame at the spike base. Judge a supplied texture by
  what it adds to the reference, and say plainly which pieces were not used.
- "you're close, sparks need to be closer ... and the jagged outter ring outaide the beam is too symmetrical"; he picked the
  asymmetric crack variant ("that bottom right one looks aamzing"). A crack ring is uneven: pieces of different sizes, irregular
  gaps, an off-round outline, zigzag strokes.
- "atlest 95% accuracy please", "yes compare them side to side, notice the exact differenr, then fix your textures accordingly",
  and later "Please please make sure you get 98% correlafion in SIZE and SHAPE" + "AND COLOR". He wants numbers, not impressions:
  capture the Play frame from a camera solved to the reference framing, score it against the image (outline overlap, mask and
  colour correlation, per-region colour statistics), fix the largest measured error, repeat.
- "fix the flame vfx in the middle, the top matches the shape but the base needs some work" and "Make the flame thinner": the core
  is a straight column (measure its width in pixels at several heights), not a cone, and never ends in a wide white oval.
- "the inner bright white pink burst needs to match the shape of thw flame though and be jagged, assymetrical, unpredictable like
  fire": no round glows in the centre; a flickering flipbook of jagged tongues.
- "i personally think your vfx is too soft ... rarely any stuff inbthe VFX reference is soft": hard 1 to 2 px edges, streaks inside
  each shape, sharp tips, dark gaps between shapes; soft glows only where the reference glows.
- "Embers need to vary in size. Strength, and brightness" and "Can you match the exact position, sizes, and brightness of the embers
  in the reference": extract every ember from the image (connected components: centre, axis, length, brightness), solve a start
  point, direction and speed per ember so it lands on its pixel at the reference moment, one fixed emitter per ember.
- "you're missing all those color variatiions for the outee spikes ring, look at the dark pink in the center and expands to a
  lighter pink": sample the colour by distance from the base (and by sector) and bake that ramp; the root is deep magenta pink,
  not pale.
- "The endings of the spiky circle aren't jageed???" and "the ends of the circle need to be bright pink look at the color": a
  traced silhouette alone gives a cut-paper edge. A burst is many separate spear strokes that end in sharp points (one stroke
  per 1.5 degrees, each as long as the image shows at that angle), over a dimmer traced haze. Colour the ends from the brightest
  quarter of the tip pixels (bright coral pink), not the mean, which the blur mixes with the dark floor.
- "this is like an explosion, the valleys between the spikes needs tp be deeper and more variates, think of noise waves": an
  explosion rim is lobes, not an even fringe. Spike lengths follow layered sine noise around the circle (4, 9, 17, 31 and 53
  waves per turn with random phases, valleys cut to half the radius, peaks 15% past it), with only a little per-spike randomness
  (too much makes needles), normalised so the area stays the same; the haze stops early in the valleys so they read dark.
  Following his taste here lowers the outline overlap with the image (92% to 69%) at the same size: his look wins over the score.
- "Bigger color contrast between the outer and the inner spikee curcle": one emitter tint over the whole crown flattens the hues
  together. Bake a strong hue ramp along each spike (pale pink at the root, hot magenta 255,70,210 in the inner circle, coral-orange
  255,125,95 in the outer ring, deep red 205,64,64 at the tips) and use only a mild corrective tint (255,160,210, Brightness 1.1,
  LightEmission 0.6), because the glow alone lifts green about 1.6 times and turns both ends pastel.
- "Now all the spikes need a tiny dark outline, the bottom of the spike in the perspective of thw image ... needs to be a hotter
  pink than the rest of thw circle" (with the area circled on a capture). The outline goes on the silhouette of the whole burst,
  not on each painted stroke (per-stroke edges made every thin stroke stripy): after painting, darken to maroon every opaque pixel
  within 3 texture px (about 1.5 screen px) of transparency. The lower front of the circle (below the base in screen space, inner
  60% of the spike length) blends to a warm hot pink (255, 40, 115), and the base fire and floor ring follow it.
- "Darker outline at thw hottom": the silhouette outline grows with the downward direction: at the bottom it is 5 texture px
  (about 2.5 screen px) at 95% darkness with less green and blue (near-black maroon); at the top it stays 3 px at 75%.

## Related feedback on animation

His animation feedback lives in the `roblox-r6-animation` skill. The one that crosses over: the
clip and the effects must key off the same schedule, and gameplay moves never lock the body for
more than a second.
- "it should be natural on the block, just water vfx only", "i don't like how the block looks, redesign it to your liking so it looks
  visually amazing!", "make sure the block vfx is much smaller and centered" (2026-09-24 night). Water effects must be water: no UI rings,
  strokes or borders drawn on top, even for a tile look borrowed from another show. A defensive piece is small and centered on the body.
- "Make the hammer less geometric please ... it's got a shape but it's flowly and isn't fully trapped into that specific shape it has some
  freedom, it's water it's flowly" (2026-09-24 night). A water construct keeps its silhouette loose: lumpy lobes, wobble, surface blobs,
  flicks off the edges and flowing strands, over translucent parts. "make sure the hand and part of the forearm cuts off cleanly like in the
  reference": a conjured limb ends in a clean flat cut, not a stream back to the caster.
- "if the judgement hammer is parried, let it fall, like there's nothing supporting the water anymore" (2026-09-24 night). A parried water
  construct loses its shape: it is knocked back, then falls and splashes.
- "Where's the water arm controlling the hammer? Also again, the water hammer is too geometric… make sure use a TON of vfx academy and
  vfx tutorials for roblox and try again, the hammer looks okay for vfx but im not aiming for okay im aiming for AMAZING, lets do this"
  (2026-09-25). "Okay" is a fail: the bar is AMAZING. A conjured limb must read as a limb from the player camera, so the forearm stands
  across the view and the hand is a real hand mesh, not primitives. When he says "too geometric" twice, change the method (mesh, flow
  beams, break-up at the edges), not the numbers. "After learning, update the vfx skill": research goes into the skill
  (references/water.md) before the work is called done.
- "now with what you learned, improve the VFX from the block if you need to rebuild it or anything.", then "the water mage block"
  (2026-09-25). A lesson learned on one effect is applied to the related ones without being asked twice: after the hammer research
  he expected the water block to be checked against the same water rules.
- "I know this is fist to fist combat but i want to make the combat feel like this, fast paced and engaging. (Don't inclide UI)"
  and "No, sparks only" (2026-09-25). Fast combat reads from the tempo (hits 0.35 to 0.5 s apart), a stagger of the victim on each hit
  and short spark streaks at the contact. It does not come from a white flash on the body or from UI. The reference showed a hit
  every 0.2 to 0.3 s, sparks, the victim staggered, the attacker stepped in, a knockback with a dash follow-up that the player inputs,
  and an uppercut into an air string that ends in a slam crater.
- "Reference for down slam" (2026-09-25), a Black Clover frame: a huge clear water fist driven straight down onto a victim whose legs stick
  out of the ground, chunky rocks thrown out of a broken crater, and long white spray ribbons whipping across the frame. From the
  player's camera behind the caster, a fist that punches away from the camera is foreshortened into a blue blob at the top of the frame;
  brought in diagonally from the upper side (up 6.5, right 5.5 of the contact) its forearm crosses the view and reads as an arm. Spiral
  streams drawn with the full torrent read as a drill; the white W path alone reads as ribbons. A crater move does not want the
  hammer's floor flash: light 6 to 2.5, no Flash emit.
- "Fist needs to go straight down and the geyser can't go through the body maybe foams at the top or it ends at the top" (2026-09-25).
  A conjured slam follows the reference's direction even when a side entry reads better from the player camera: the fist now forms
  7 studs over the contact and drops vertically. A launcher column never passes through the body it lifts: it grows with the target
  and ends under its feet (the top follows the lifted root, leaning to its x and z), a foam crown (`Fx.Spout` at high rates) sits on
  the top, and the burst particles are slowed so none rise past the feet (jet 24 to 34, foam 18 to 30, drops 16 to 30, streaks 40 to
  55 studs/s; the crown splash at 0.45 with no spikes or rain).
- "Rocks nees to form also under the geyser please to have a source where it's forming from" (2026-09-25). An eruption needs a
  visible source in the ground: the rocks tell where the force comes from. A small cracked ring rises at the load (`Burst.bowl`
  radius 2.6, 7 rocks, a floor-coloured puff), then a wider ring bursts at the eruption (radius 4.6, 12 rocks, 8 flying debris,
  a puff) and stays after the column collapses.
- "improve egg hatching animations please", "Make suee your GUI matches the style of the game" and "think of it like a carousel
  around the egg for these stuff" (2026-09-27, Wacky Pets). A pet-sim hatch is a UI effect: it matches the game's panels (FredokaOne,
  dark outline stroke, gradient bodies) and says what you got (name, rarity colour, NEW on a first find); anticipation grows with
  rarity (more wobbles, a charge, a shake, a second burst). Preview pets orbit their egg on a ring tilted toward the camera, so they
  never bunch up and the ones behind the egg pass out of sight. "maka sure the z index for the pet stats is high and none of it is
  covered please": information labels (name, rarity, chance) are AlwaysOnTop; a flat 1 px seam in a dim overlay is a visible defect
  to him ("I don't like this line", "the line is here too???"). Full entry in SKILL.md, feedback log.
- "make animation and VFX for this based on clients request, make sure it's really cool, you can use free models for the r6 rig,
  asian samurai with a straw hat" (2026-09-28, a paid test for his client Moon: the "Three-Blade Swordsman" sheet). His picks:
  "Caliber Phoenix", "Showcase + working move" (key, a dummy with knockback, a video for Moon), "Two in hands, one in mouth",
  "Yes, find SFX". Built on the move rung with a recoloured pack crescent, feather beams on its trailing edge, three arcs that
  merge, painted feather and trail textures, licensed ProSoundEffects sounds and a 14 s video with sound from five angles.
  Method, numbers and traps in references/caliber-phoenix.md. Not yet judged by him or Moon.
- "Rest of the abilities" and "Male sure itt looks super good okay?" (2026-09-28, Moon's sheet: Dragon Twister and Lion's Passage). Picks:
  "X and C", "Spin in place", "Dash through", "Yes, with sound". "Super good" meant no frame that a piece covers: slash flashes
  and the dragon go on the far side of the body from the camera, the lion head scales with the camera distance and stays 17 studs
  from the lens, the target launches away from the camera line. ForceField alone never reads on a bright sky; a Neon core at 0.6 to
  0.72 inside it does. Details in references/dragon-twister-lions-passage.md. Not yet judged by him or Moon.
- "the dragon at the end ruins the vfx for the lion's passage, please find an alternative for that by subsituting particles for it",
  "i'd like if all these VFX were more particle heavy especially the tornado ability", "from now on, your animations and VFX needs
  to be significantly more flashier" (2026-09-28). He called the ForceField lion head "the dragon": a see-through mesh creature reads
  as a blob, not as a lion. Picks: "Lion face sprite + burst", "Yes, all three moves". Then "Make the videos short, three separate
  videos for each moves, and keep in one perspective don't switch please" (player camera): a showcase for him is one short clip per
  move, no cuts. Not yet judged.
- "you're missing slash sound effects" (2026-09-28): a swish alone does not read as a sword; he expects a metal cut on the frame the blade
  lands and a slash with a ring on each swing, in every move. Not yet judged.
- 2026-09-30 (LTS warrior, Brave Slash and Guard Up): "the VFX should match the game style and lore please, as well as match the model's design" and "Make sure these animations and VFX look really cool". His picks: "Gold like the model" (sword edges and claws glow yellow-gold on dark tech armour; the lore calls his kit "the new gear Xhris cooked up", so hard-light hexagons and electric crackle fit), "Yes, redo the wave", "Yes, add sounds". The old hit effects came from a free pack whose Parry carried the disabled PoseTexture/TextureConfiguration backdoor; the two emoji-named packs inserted this time carried the LightConfig/Type MarketplaceService scam. Pack textures that read well in gold: crescent 7094330807, thin arcs 10558425570/10558510611, cut streak 7046374898, spike 7016382152, splash burst 10357935135, star flash 9973334259, soft ring 9973574373, four-point spark 11136725107, streak 7458821155, soft disc 284205403, smoke 8529175248, crackle 11492870634, hexagons 14482391301 (thin) and 73224038558737 (bold). A camera-facing crescent rotated -90 reads as a horizontal sweep from behind only with a positive Squash (squash scales before the rotation). Sounds from ProSoundEffects only (the store search returns ripped game audio first).
- 2026-10-01 (Scripter Combat Trial): "The vfx isn't clean, personally that white vfx is too much" about the parry clash (25 emitters: white slashes, explosions, a 7.4 stud flash, crescents and a ring covering both fighters for 0.23 s). His pick: "small yellow sparks". Kept two emitters only: 14 spark streaks (VelocityParallel, size 0.16, Squash -2.2, spread 180, speed 20-32, drag 6, gravity 35, life 0.12-0.26) and 8 specks (0.35), gold 255,225,120 -> 255,185,40 -> 255,110,10 at Brightness 1.6 (at 3 the gold bleached to white). Placed 2 studs up instead of 1.3: from the shoulder camera the contact point sits behind the player's back and small sparks there were invisible.
