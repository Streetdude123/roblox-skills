# Principles of VFX, translated to Roblox

Two reading passes. The first (2026-09-22, "search up tutorials like the animation and stuff and improve the
VFX skill") read the League of Legends style guide takeaways, Keyser on block-ins, the VFX Apprentice timing
outline, Vlambeer and the DevForum particle guides. The second (2026-09-26) read the VFX Apprentice playlist
"Artistic Principles of VFX" that Lepy sent ("these are VFX principles, right now your VFX is pretty good but
it can be improved if you know these principles, please analyze and research on VFX, don't just use these
videos just research you have to make AMAZING stunning beautiful VFX"), then the sources in the list at the end.

The playlist has six principles: gameplay, shape, value, colour, timing and composition. This file follows
that order. Every rule is restated with the Roblox instance, property or number it implies. A number marked
"estimate" comes from no source and no measurement: try it in a take before you trust it. Where a source
disagrees with one of Lepy's sentences, Lepy's sentence wins, and the conflict is in section 9.

The playlist was read from its full captions. YouTube blocked the video download, so the slides and the
example clips were not seen. Where the teacher says "look at this", the rule below comes from the teacher's
words only.

## 1. Gameplay first

"I think of myself first as a game developer and secondly as an artist." An effect that looks good and hurts
the game is a failure (Keyser, #1 and the Bootcamp). For Lepy's game, gameplay means PvP combat: every attack
must answer block, parry and dodge, and the player must see what hit them.

### Three pillars per project

Keyser narrows every game to three effect goals (Ori: ambient life, dreamlike, mysterious magic; Battle
Chasers: impact and ceremony; Overwatch: punchy, personality, competitive integrity with effects that "get in
and out of the environment quickly"). "Stylized" or "realistic" is not specific enough.

Lepy's sentences so far point to these three for the Grimoire Battlegrounds kits. Confirm them with Lepy before
treating them as fixed:
1. Anime power: "AMAZING", "anime like", "flashier", "more dramatic".
2. Readable PvP: "Make sure it's blockable and parryable", "make sure players can dodge sea dragons roar too",
   "you are doing a little too much so it feels kinda messy", "it's just covers up too much".
3. Character identity: "star vfx doesn't really suit the world", "just match the vfx with the references",
   "it's water it's flowly".

Judge every new layer against the three. A layer that serves none of them is noise.

### The effect shows the real hitbox

The gameplay shape is the effect's primary shape. Sona's old ultimate tapered, but its hitbox was a plain
rectangle, so players misread it. Teemo's mushroom skin kept a clear outer edge on the real area.

Roblox translation:
- Read the hit radius or box from the server code before building (the Roar's hit radius 4.5, the spear rush
  hit area 6.5 studs ahead, Aqua Shield's 7-stud push, the ult eruption's 26-stud push). Size the primary edge
  (the ring, the crack line, the leading edge of the projectile) to that number.
- The inside of an area is flavour; the edge carries the contrast (section 3).
- A projectile that is much bigger than its hitbox promises splash damage (Hearthstone's Starfall). Every piece
  that looks like damage must be damage, and a single-target hit must look single-target.
- An option some games use (VFX Apprentice, "The FX Artist's Guide to Area of Effect"): draw the caster's own
  area slightly smaller than the hitbox and an enemy's area slightly larger, so edge hits feel earned and near
  misses feel like escapes. Each client runs the effect, so the caster's client can scale its copy. This is a
  design choice: ask Lepy before doing it.

### The brightness budget

A frequent effect spends little; a rare, decisive one spends a lot. Lux's basic attack is subdued, her
ultimate is where "the budget of brightness" goes. Riot's categories, mapped to Lepy's kits:

| Riot category | In Lepy's kits | Budget |
|---|---|---|
| Idle | the settle aura, the book aura, a casting aura | lowest: low opacity, small, slow |
| Basic attack | M1 chains, water bubbles | subdued and small: many players cast them at once |
| Defensive | block, parry, Aqua Shield, the vortex block | medium, small and centred on the body |
| Damaging | numbered abilities | medium to high, sized to the hitbox |
| Game changer | guard break, the bubble trap, a grab, anything the player must react to | the strongest warning |
| Ultimate | the sword ultimate, the time stop | the peak, then out |

- A game changer punishes the player who does not react. The effect must warn early enough to act on, with
  its highest contrast on the warning and the danger edge, not on the decoration.
- If idle and basic effects already use the high contrast, the game changer has nothing left to stand out
  with. This is the tone ladder in SKILL.md with its reason: a summon that looks like an ultimate makes the
  real ultimate feel small.
- Size, brightness, saturation, duration, camera work and sound all scale with the tier. The ladder in
  numbers: light hit 1 to 3 studs, 0.3 s, one flash and sparks; heavy 3 to 6 studs, 0.6 s, flash + ring +
  debris + a kick; special 6 to 15 studs, 1 to 2 s, a build-up phase; ultimate 50 to 300 studs, 10 to 16 s,
  waves.
- The right amount depends on how many effects share the screen. Tristana's rocket jump: the subtle version
  fits a game with 200 of her on screen, the huge version fits a single-player power fantasy, League shipped
  the middle one. A battlegrounds server has many players casting M1s at once, so M1 effects stay small.

### Clean in, clean out

- Riot: "If your FX feel long, they're waaaaay too long."
- An effect leaves the play space once its gameplay impact is over. Syndra's ice splotch stayed on the ground
  after the damage and read as a slippery hazard; the shipped skin pops and fades. A lingering bright shape
  says "still dangerous".
- Ultimates: "get these in and out of the gameplay space pretty quickly."
- What stays (debris, dust, embers) must look inert: LightEmission 0, desaturated, low contrast, no pulse, and
  never on top of a hit area that is no longer live.

### Tell the cause and the result

- Twisting Nether: the overdraw version covered the whole board and lost the story of why the minions died. A
  big effect still shows the cause (the vortex) and the result (the minions pulled in).
- Atiesh (Medivh's weapon): the source flared and the summoned minion popped out of nowhere; the shipped
  version hands the focus from the source to the minion. In Roblox the brightest point moves with the
  gameplay object: the cast flash dims as the projectile leaves, and the impact is brighter than the cast.
- Hearthstone adds "a sense of ceremony" to rare, turn-based moments. The cinematic rung is that ceremony.

## 2. Shape

"Shape is the primary way to communicate." Sharp and jagged says danger; round and bubbly says friendly
(Keyser, #2). Shape also marks the boundary of the area. The water kit is round (blobs, bubbles, crescents) and
Asta's anti-magic is jagged (flame licks, cracks, slashes); keep it that way.

### Components, not one painted picture

A particle effect is many cards. Each texture carries one simple shape (a flame lick, a spark, a smoke puff);
together they build one silhouette. A texture painted with its own highlights, curves, jagged edges and lens
flare looks great alone and turns to noise when 30 copies overlap.

Roblox translation: pick sprites with one clear shape each. The kit star sprites at full size filled a frame
with sparkles (the clash trap in SKILL.md). When a burst reads as noise, remove textures before you lower
counts.

### Primary and secondary elements

An effect exists to tell the player what happened, where, and how big. The primary shape reads in one glance;
the secondary elements support it and never compete. "If it's distracting, the effect isn't doing its job."
Riot's style guide lists the traits (quoted from secondary summaries of the guide; the original PDF did not
open): primary elements have a high value range, strong contrast in value or saturation, a clear silhouette,
high opacity, a strong shape and intense movement. Secondary elements have a lower value range, a small size,
a blurry silhouette, low opacity, a simple shape and subtle movement.

Roblox translation:

| Trait | Primary layer | Secondary layer |
|---|---|---|
| Texture | crisp edge (slash, shard, streak, crack) | soft (glow, smoke, mist) |
| Transparency | 0 to 0.3 | 0.4 to 0.8 (estimate) |
| LightEmission | full for the core; the dark partner at 0 | 0.3 to 0.7 |
| Size | the largest | `Kit.scale` 0.5 to 0.8 |
| Speed and RotSpeed | fast | slow, drifting |
| Count | few | more, smaller |

- Every phase names ONE hero element (the ring, the pillar, the clock, the flash). It gets the brightest
  value, the most saturated colour and the largest size; everything else sits one or two steps down
  (`Kit.tint` with the palette's pale or deep colour, `Kit.scale` 0.5 to 0.8, `LightEmission` 0.6 to 0.8).
- Never put the busiest element on the hit point itself: the hit point shows a flash and a ring; the sparks
  and smoke leave it, so the body that got hit stays visible.
- Layer count, not particle count, is what breaks readability. This is Lepy's "you are doing a little too much
  so it feels kinda messy" in the guide's words.
- Bold, simple shapes at the leading edge; fuzzier, dimmer, smaller shapes in the trail. The team's example had
  complex circuitry in the tail and "big simpler bolder shapes" at the tip where the damage is.
- "Wrangle" the shapes: keep the interesting ones, but tone them down so they stop fighting. If every shape has
  "the same level of prominence and scale and sharpness and energy", they bleed together.

### Shapes show motion even when still

A missile texture with a painted trail reads as travelling in a still frame; a round one reads as parked.
Riot: add blur as the shape moves to show direction, importance and power.

Roblox translation: `Orientation = VelocityParallel` with a streak texture, negative `Squash` to stretch
along the velocity (sparks that are round dots read as dust; stretched 2 to 4x they read as sparks), a `Trail`
or a `Beam` behind anything fast, and slash sprites painted with a thin leading edge and a wide trailing
smear. Genshin's slash meshes: "a razor-sharp front edge and a dynamically expanding
trailing edge" (VFX Apprentice's Genshin breakdown).

### Hard and soft

- Crisp edges with a little glow read sharp and punchy.
- Sharp first, soft after reads as a punch followed by a dissipation. Roblox has no material that animates
  contrast, so do it with two emitters: a crisp flipbook or shard layer with a short life, then a soft glow and
  smoke layer that starts 1 to 3 frames later and lives longer.
- Hard and soft at the same time reads magical and ethereal.
- Riot's rule: textures mix soft and hard shapes with no "noisy superfluous detail", never layered so
  thickly that they turn to mud.
- Lepy's "too geometric" is the same rule from the other side: a clean Neon primitive is a hard shape with no
  soft partner. Every hard mesh (a ring, a crescent, a shard) gets a soft partner (a glow particle behind it, a
  smoke puff, a Beam) and sits at 0.35+ transparency.
- Flipbooks are strong, but use one flipbook for the hero element of a burst (a lightning pop, an explosion
  sheet), not one per layer (DevForum advice: do not overuse).

### Variety, not sameness

Keyser links a tutorial on good versus bad shape where the good row has dynamic, varied shapes and the bad row
repeats one. Roblox: `Rotation` as a range, `RotSpeed` as a range, `Size` and `Lifetime` as ranges, and
`FlipbookStartRandom` true. With `FlipbookFramerate` 0, each particle is one random frame of the sheet, so one
flipbook becomes many shape variants (Creator Hub, particle emitters).

### Big, medium, small

The composition video (#6): a few big shapes, a group of medium ones and many small ones; "the smaller detail
is, the bigger quantity of them there are". The sizes change over the effect, but the ratio stays.
Roblox: a burst is 1 to 3 hero pieces, 5 to 12 medium pieces and 20 to 60 small ones (counts are an estimate;
the clash numbers fit it: a ring, 8 to 16 streaks, 34 embers).

### Anime shapes

- Large, simple shapes with thick and thin lines for balance; no overly detailed or realistic textures
  (the Sparkball style guide, VFX Apprentice).
- Hard-edged, vector-like silhouettes instead of soft gradients (Genshin breakdown).
- The existing water and anti-magic vocabularies already follow this: cel water sprites, crescents, black
  flame licks with a red rim.

## 3. Value

"If shape is the way to most clearly communicate what something is, value is the thing you use to most easily
get somebody's attention" (Keyser, #3). The brightest brights next to the darkest darks grab the eye. Check
value before colour: values decide where the player looks.

### Spend contrast where the player must look

- Many high-contrast effects on screen at once and the eye cannot decide where to look (the old League
  screenshots). Contrast is a budget like brightness.
- A dangerous projectile has its highest contrast at the head and fades toward the tail. The fireball fix: the
  too-bright version lit the whole trail, so players could not tell they were safe behind the head; the shipped
  version put "a hotter core" (a simple glow ball) at the head and dark smoke wisps off the back. The dark wisps
  give the head its contrast and stay transparent enough to see through.
- An area puts its highest contrast on the outer edge, with the flavour lower inside (Akali's shroud).
- Riot's value ranges: UI at the top, characters wide, the environment darker, and effects allowed the widest
  range, but only the most important effects use it.

Roblox translation:
- Two layer kinds in every burst. `LightEmission` 1 with `LightInfluence` 0 is the additive glow layer; the
  smoke and rock layers keep `LightEmission` 0 and `LightInfluence` 1 so they read as solid and dark against it.
  Without both, the effect floats with no weight.
- A damaging effect has HIGHER contrast than a friendly one: darker darks next to the whites (Keyser).
- The projectile head: a pale core (LightEmission 1, small, crisp) over a dark partner (LightEmission 0,
  `DEEP` or smoke). The trail: mid values, higher transparency, soft textures.
- Dark smoke wisps off the back of a projectile: `darksmoke` or the black flame at LightEmission 0,
  transparency 0.4 to 0.6, short life, emitted from the moving part.
- An area: the edge ring at full value and contrast; the fill at 0.5 to 0.8 transparency.

### Near white, never white

- Stay out of the extremes: never pure black or pure white as a whole element. The mid range defines the
  palette, and a WIDE range inside one effect (a white-hot core against a dark smoke rim) draws the eye.
- "We like to reserve that white-white for UI." Effects come close to white and stop. Cores are pale, not
  white: the summon palette's `pale (255, 240, 170)` for a core, `gold` for the body, `deep (40, 10, 70)` or
  dark smoke for the rim. Lepy's exception is the flash under 0.1 s and the impact frames (section 9).
- Stacked additive cards blow out to white. In Roblox every layer at LightEmission 1 adds to the one behind
  it. Count the additive layers that overlap the core; when the core reads as a flat white blob, cut layers or
  lower LightEmission before you add colour. The Asta arena showed this: gold at LightEmission 1 bloomed to
  white, gold at 0.7 with a deep second colour stayed gold.

### Mid-tones and the soft glow

- A full set of mid-tones between a clear bright core and the darks reads "magical" and is "attention grabbing
  without being hard on the eyes" (the Ziggs example in #3). Three value steps is the minimum:
  core, body, dark rim.
- A little glow around the outer edge sells that the effect is a light source living in the world. "It's
  surprising how little glow you need." Roblox: one large `glow` sprite at 0.85 to 0.92 transparency behind the
  body (estimate), and a PointLight in the effect colour so the ground and the bodies are lit (the water pass
  already does this).
- Riot: illumination tells "power, direction, and duration".
- Bloom is the illumination knob: threshold 1, size 32, intensity 0.55 in Lepy's places. At Level01 quality none
  of this shows, so check the quality level before judging a value.

### Colour-blind players

A red on green effect can vanish for colour-blind players. For reddish abilities Riot bumps the value, but
only at the part that matters, never the whole trail. Asta's red on a green or grey floor needs the value step
from the black partner, not only the hue.

### The greyscale check

Riot works in greyscale at some point in every gameplay effect. Two traps from the videos: a plain "switch to
greyscale" in some tools gives wrong values, and the Windows greyscale filter exaggerates contrast because it
is an accessibility feature. Use a luminance conversion. The squint test is the quick version: blur your eyes
until you see only the big value shapes. Commands are in section 8.

### Value in smoke

Flat smoke shapes read as stickers. Value variation inside the smoke (lighter where it faces the light or the
effect, darker in the folds) accentuates the motion (Keyser's smoke wisp tutorial). Roblox: two smoke layers,
a lighter one in front and a darker one behind with a negative `ZOffset`, or a smoke flipbook that carries its
own shading.

### The pale day arena

The "I AM ATOMIC" study got its contrast from a dark stage (study-atomic.md). Lepy's places are pale and lit by
day, so the darks must come from the effect itself: the dark partner layers, the black flame, the deep blue
water shade. Additive layers alone read as grey haze on a pale floor.

## 4. Colour

"Color can define schools of magic, and within those, how the energy behaves" (Keyser, #4).

### Context changes meaning

Yellow with touches of pink feels light, fairy or holy; the same yellow at the centre of a saturated red is
"infernal intense heat". A colour means what its neighbours make it mean.

### Colour depth

One hue per element makes elements overlap: light and air, water and ice looked the same in single-hue
versions of Elementalist Lux. The shipped versions add a second and third hue and change saturation: air is
ice's hues, desaturated. Paladin in Hearthstone is not one yellow; it has value variation and a bit of hue.

Roblox translation: a `Config.Palette` per effect with one dominant hue (gold for The World), one accent
(lavender or violet), a pale core and a dark rim, so every palette has at least two hues. The sparkle list is
variations of those, not a rainbow, unless the piece is the Megumin ultimate where the rainbow IS the identity.
Change hue AND saturation between kits, not hue alone. Move hue, saturation and value independently.

### Saturation limits

- Riot: never 0% or 100% saturation, so effects do not blend into the environment or the UI.
  "Don't go full-blown out ... 255 red."
- Higher saturation draws the eye, like value.
- Dark and saturated works: Yorick's shipped palette keeps its blues and greens saturated but dark around a
  bright cyan core. A colour does not have to be bright to be saturated.

### How energy is coloured

- Fire: yellow-white at the hot core, then orange, then red, then smoky browns at the cool outer edge. Invert
  it on purpose for something unnatural.
- Energy: a near-white core (like a camera that cannot expose for the hottest light) and the most saturated
  colour in the glow and the fringes, where the energy cools. Super Galaxy: a pale pink core, yellow and orange
  at the tip, burning off to saturated pink, blues and purples, with a few green accents.
- Xerath's hierarchy: near-white core, saturated yellow, a fully saturated orange that is darkened so it
  supports the core instead of screaming, then a sandy brown outside.

Roblox has no gradient map (Overwatch paints its flipbooks in greyscale and colours them with a gradient map;
Nick Eberle on realtimevfx). Two substitutes:
1. Concentric layers of the same shape: a small pale core (LightEmission 1), a larger saturated body
   (0.7 to 0.9), a larger darkened saturated halo (0.3 to 0.5, transparency 0.6 to 0.8) and the dark rim
   (0). This is the Xerath hierarchy in emitters. The LightEmission numbers are an estimate.
2. A greyscale sprite with a `ColorSequence` over the particle's life (colour by age, not by value): hot
   and pale at birth, saturated in the middle, dark and desaturated at death. Fire and sparks cool this way.

### The hue shift

Keyser's "secret sauce": hold saturation and value almost constant and shift the hue a little. "When you're
making something pure red, just shift it a little bit to pink, a little bit orange, with red in the middle."
Roblox: build the `ColorSequence` with `Color3.fromHSV`, keep S and V near constant and move H by a few
degrees either side (about 10 to 20 degrees, estimate). ColorSequence and NumberSequence take at most 20
keypoints (Creator Hub).

### Complementary colours

A complementary pair (red and green, purple and yellow, blue and orange) at full saturation side by side
vibrates. One of the two must be desaturated, more transparent, or smaller, "or all of the above". Done right,
the accent makes the main colour feel more itself (Lulu's shield vibrates; another example keeps a dominant,
saturated yellow with transparent, desaturated purples behind it).

### Values can hide bad hues

With good values, an effect full of clashing saturated hues can still look "kind of okay", with a feeling that
something is off. Do values first, then look for saturated neighbours that vibrate. The composition video adds
a split to aim for: about 60% main colour for the volume, 30% secondary for detail, 10% accent to push contrast
at the focal point.

### Character harmony and cultural meaning

- The effects take the character's colours so the ability belongs to its caster. Hearthstone builds each class
  palette from its power source (the warrior: dust, metal, blood; the mage: unnatural pinks, purples, blues).
- One character's moves pull different amounts from the same palette (Darkstar Thresh: much yellow on one
  move, touches of it on another). Keep the palette, vary the mix.
- Colour has prior meaning. Green heals, blue is cold, orange-red is gunpowder and heat. Green water reads as
  acid or goo, grey as tar or oil, red as blood. The water kit stays blue, cyan and white. A familiar element
  in an unfamiliar colour (green, inverted or solid gold fire) reads as special and magical at once (Bootcamp).
- Limited palettes of analogous or triadic colours work best; crunch the gradients into hard steps at the
  highlights for an anime look (the Sparkball style guide).

## 5. Timing

"Lead the brain with anticipation, then overload the brain at the moment it's been waiting for,
then give the brain time to process what just happened" (a World of Warcraft lead class designer, quoted by
Keyser in #5). An effect is a sequence of beats, like music.

### Intensity over time

Every property can animate, which makes timing hard to talk about. Keyser reduces them all to one curve:
intensity, meaning how much the effect grabs the eye at that moment. Motion speed, brightness, flicker, spin
and size all raise it.
- An explosion starts at maximum intensity, although it is small, because it expands fastest in the first
  moment; then it decelerates hard and the intensity falls fast.
- A blinking light is on and off beats, like an EKG. A portal is a slow sine shimmer.
- Intensity is change. A light that flashes on and stays on loses intensity, because the difference is gone.
- Levers in the order they read fastest (Bootcamp Q&A): movement speed and lifetime first, then colour, then
  contrast. Shape stays nearly constant because it carries the area.

Roblox translation: give every beat in the `T` table an intensity from 0 to 10 and draw the curve before you
build. A damaging move has one spike. If the curve is flat or has several equal peaks, the effect will feel
floaty or noisy whatever the particles look like.

### The numbers the builds settled on

The VFX Apprentice course outline names seven FX timing principles: number of frames, keyframing versus
straight ahead, ease in and out, anticipation (a crouch, a wind up, a pull back before the main action),
impulse versus rhythm, follow through, arcs applied to the whole effect, and stretch and smear.

- Anticipation: a gather that pulls INWARD (`ShapeInOut = Inward`, rates rising, a light climbing) for 0.2 to
  0.6 s on a move, 1 to 3 s on an ultimate. It says where to look and how big the hit will be.
- Impulse: the hit is one or two frames of the biggest, brightest state (`Emit(n)` bursts, a flash at 0.35 to
  0.5 transparency, the light spike), then decay. Impulse effects appear in a strong burst and leave the same
  way; rhythm effects (auras, idle loops) change gradually and loop.
- Process time: longer than the impulse, never long enough to stay in the way: sparks 0.3 to 0.6 s, smoke 0.8
  to 1.5 s, rings gone in 0.4 to 0.8 s, embers up to 2 s at low opacity.
- Ease: nothing linear. Size and transparency sequences ease out (fast start, slow end) on a burst and ease in
  on a gather; the flash grows in 1 frame and fades over 6 to 15.

### The main action in the first quarter

"The main action of an effect occurs and finishes, or begins to dissipate, within the first quarter of its
lifetime," then it fades through an erosion or another interesting dissipation (the Sparkball style guide).
Roblox: on a burst, `Size` reaches most of its final value by 0.25 of the life, `Transparency` is lowest in the
first 0.1 to 0.25, and the rest is decay.

### Timing tells the threat

- Damage versus heal with the same shapes and colours (Reaper Soraka): damage is a long, quiet build of dread,
  an instant spike, and a short fall-off. The heal hits maximum at once, falls quickly, then leaves a long,
  slow tail of friendly sparkles that drift and orbit.
- Firelands versus Moonglade portals: the same beats and nearly the same length, but the dangerous one has fast,
  roiling secondary flames and embers and the friendly one has slow, drifting mist and leaves with a long slow
  out. The threat lives in the speed of the secondary elements.
- The heartbeat rule: a pulse faster than a heartbeat reads aggressive; slower than about 60 per minute reads
  friendly or inviting (VFX Apprentice, "How to master good timing").

Roblox translation: dangerous = short `Lifetime`, high `Speed`, high `RotSpeed`, flicker, sharp spikes of a
PointLight; friendly = long `Lifetime`, low `Speed` with `Drag`, orbits, a slow light swell. An aura that pulses
twice a second reads as a threat; once every 1.2 s or slower reads calm.

### Even, compressed, pushed

Keyser retimed Ekko's ultimate three ways. An even rise and fall felt floaty. The same curve at double speed
felt "jumpy" and still unsatisfying, with no build and no payoff. The shipped timing: a subtle build, a huge
spike, a short payoff, and variation in the timing of the small bits. When a pass feels weak, do not just speed
it up. Rebuild the curve.

Timing comes last, when the artist is tired of the effect. "Always ask yourself: can I push the timing harder?"

### Four animation principles

1. Squash and stretch. Two projectiles at the same speed: the stretched one feels faster and does not strobe,
   because its frames blend together. Roblox: negative `Squash`, `VelocityParallel`, trails.
2. Anticipation. The same pop feels stronger after a build-up. Use the character animation too: a sword
   wind-up, a raised arm.
3. Slow in and slow out. Two effects with the same lifetime and the same scale points feel different: scale up
   fast then grow slowly, fade in fast then fade out slowly. A long, gentle fade-out also gives satisfaction to
   instant abilities that have no time for anticipation.
4. Secondary action. A trail that wobbles and fades feels alive; particles that "spawn spawn spawn" in place
   read as a particle system. Roblox: emit from attachments that move with the body, use
   `VelocityInheritance`, and give trails a slight wobble instead of a straight line of stamps.

### Layer offsets

A stylised explosion breakdown on realtimevfx (18 layers, 0.5 s): the shockwave fires first and fills the
background for the flash; the dark smoke starts almost at once and lives to the end; the instant flash lasts 2
to 3 frames; the burst core throws fast particles with heavy drag that fade before they stop; the ring expands
and dissolves; the sparks (some with trails, some stretched) die slightly after the ring. The start times differ
by only 2 to 3 frames, and those offsets made the effect. Critique on the same thread: vary the spark lifetimes
so they do not all die together, let the smoke outlive the sparks, fast at the start and slow at the end.

Roblox: 2 to 3 frames is 0.033 to 0.05 s. Stagger `Emit` calls with `task.delay` by those amounts instead of
emitting every layer on one frame.

### Nature first

"As a visual effects artist, you are a student of nature." The particle editor's default physics looks like
fire, but the artist should know which levers make it move believably. Fire rises in S-curves that turn into
C-curves; chunks break off, keep curling and shrink as they rise; the base stays stable (flashfx, "Fire").
Study reference before tuning.

### Anime timing

- Hold frames. Overwatch's Pharah rocket flipbook plays at 24 to 30 frames a second, "ever so studdery just like
  anime fx animation where they hold frames" (realtimevfx). Roblox: `FlipbookFramerate` goes up to 30; with
  `FlipbookMode` OneShot the frame rate is the lifetime divided by the frame count, so a 16-frame sheet over
  0.67 s plays at 24 (Creator Hub).
- Framerate modulation. Anime effects run on ones while fast, then switch to threes at the impact so the frames
  pop; the impact pose is held longer (Wave Motion Cannon). The hit stops in these kits are the hold.
- Limited animation. Guilty Gear Xrd turned off interpolation between keys, used no simulation because "it
  just doesn't look 2D", used scale animation everywhere, and deformed the mesh on every key so a shape never
  moves through perspective as a rigid object (Motomura, GDC 2015). Roblox translation, not yet tried in Lepy's
  places: update a mesh VFX's CFrame and Size on steps of 2 to 3 frames instead of a smooth tween, and add a
  small random scale jitter on each step. Show Lepy a take before switching a kit to it.
- Stepped fades. A cartoon explosion feels more staggered with a stepped alpha than a smooth fall-off
  (realtimevfx critique). Roblox: two `Transparency` keypoints almost on the same time (0.499 and 0.5) make a
  hard step; 20 keypoints allow about nine steps.
- Genshin's impact: one to two frames of white or desaturated overlay, then an inverted frame. The impact frames
  in this skill already do this; on a move they need Lepy's yes.

## 6. Composition

The composition video (#6, a Riot VFX artist and VFX Apprentice instructor whose name is garbled in the
captions): every stage of an effect has one clear focal point, shape and motion lead the eye to it, and
anticipation carries the eye from one focal point to the next.

In Roblox the frame is the camera. For moves it is the player camera behind the character; for the cinematic
rung it is the CameraRig shot. Compose for that frame, not for a free camera in Edit mode.

### Balance

- Symmetrical balance pulls the eye to the centre and feels heavy and "in your face". It suits explosions,
  slams, a parry clash. It is not a mirror: sizes and placements vary around the centre.
- Asymmetrical balance creates movement and tension. A big shape on one side is balanced by small shapes far
  on the other, which work as a lever and also show where the thing came from (Keyser's fireball). It suits
  dashes, thrusts and projectiles.

### Line of action

Start the effect with a line of action, then place the big, medium and small volumes along it, curved and
pointed to support it. In a healing spell the character squashes and the effect curls inward along the pose;
then the pose stretches up and the effect goes up with it.

Roblox translation: the effect follows the clip's pose lines. A slash arc lies in the swing plane (the Asta
rule), a gather curls along the crouch, an eruption rises with the stretch. The animation skill's clip plan has
the poses; draw the effect's line on the same beats.

### Complementary movement

Keep the main force (an outward expansion), then dissolve the shape with a complementary motion (a curl or a
swirl) for variety (Alex Redfish's nether poof). Mark the force lines with arrows while planning.

### Rhythm and contrast

- Show a pattern, then break it at the focal point. A ring of even streaks with one big flare at the contact
  point reads better than twelve flares.
- Soft and pointy shapes can alternate with the speed of the motion.
- Timing contrast follows big, medium, small: a medium action over a medium time, a fast action in a short time,
  a slow action over a long time. The fast-short action next to the slow-long one gives the biggest contrast, so
  put it on the main action.
- Save the lightest value against the darkest value for the main point of interest (the lightning strike point
  in the concept example).

### The onion skin

Look at the whole effect in one image. For a flipbook, the onion skin shows the overall volume and spacing.
For a take, blend its frames (section 8).

### The questions

From the composition video, in order:
1. Where is the focal point, and how do I lead to it?
2. What is most important in each stage? Which line of action shows it best?
3. What else is in the frame (the character, the arena, other players)? Can I complement it?
4. How do I balance the shapes around it?
5. Polish: is the most important stage felt as the most important? Can I push the contrast of timing and
   spacing? Can I push the colour and value?
6. "What do I, as a viewer, notice the most, and is it what I wanted the viewer to look at at this moment?"

## 7. Game feel: the juice list (Nijman, Vlambeer; Jonasson and Purho)

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
  Lepy's later sentences override parts of this per kit ("No, sparks only" on Asta's fast combat).
- Permanence: rock plates, dust rings and embers stay 2 to 5 s at low opacity after a big move; the
  ultimate's debris rain and aftermath smoke are this rule. They must look inert (section 1).
- Shake decays; it never sits at a constant level, and spectators get it with distance falloff.

## 8. Roblox craft and the checks

### Engine facts that change the look

From the Creator Hub reference and guides (read 2026-09-26):
- `LightEmission` 0 is normal blending, 1 is additive. It does not light the environment; a PointLight does.
  A greyscale texture with no alpha works only at LightEmission 1, where black adds nothing (the black square
  trap in SKILL.md).
- `LightInfluence` 0 ignores the world's lighting; 1 is lit like a part. `Brightness` scales the emitted light
  when LightInfluence is 0 (particles) or below 1 (beams); on a beam it goes up to 10000. How values above 1
  interact with a bloom threshold of 1 is untested: capture it before relying on it.
- `Squash`: above 0 shrinks horizontally and grows vertically; below 0 the reverse. It is a NumberSequence, so
  a particle can stretch at birth and relax as it slows.
- Flipbooks: 2x2, 4x4, 8x8 or custom; `FlipbookFramerate` up to 30; OneShot ties the frames to the lifetime;
  `FlipbookStartRandom` with framerate 0 gives a random static frame per particle. Frames need transparent
  spacing or mip filtering bleeds them together. Clients low on memory turn flipbooks off, and reusing one
  texture costs less memory than many unique ones.
- `Drag` is the rate at which particles lose half their speed. `TimeScale` runs 0 to 1. `ZOffset` moves the
  render position toward or away from the camera without changing the on-screen size, which orders layers.
- A beam's `Color` and `Transparency` need at least n - 1 `Segments` for n keypoints. `TextureMode` Wrap or
  Static repeats the texture every `TextureLength` studs; Stretch repeats it `TextureLength` times.
- `ColorCorrectionEffect.Saturation` -1 removes all colour; `TintColor` multiplies the channels.
- `BloomEffect.Threshold` 1 blooms only pure white; 0 blooms everything.

### Particle habits (DevForum tutorials, Lepy's kit)

- `ZOffset` orders layers: fire in front of smoke, flash in front of the ring, the hero element on top.
- `Squash` stretches, `RotSpeed` with a random `Rotation` range keeps sprites from reading as stamps,
  `Lifetime` and `Speed` as ranges add variety; static values read as dull, but do not animate every
  property either (DevForum: keep some things simple, a static size can look better).
- One emitter is never enough for a good effect; a burst is 3 to 6 emitters with different textures,
  sizes and lifetimes (a flash, a ring, sparks, debris, smoke, embers). Beams and Trails make the shapes
  emitters cannot (sweeps, rune rings, pillars, lightning).
- Every element moves. A DevForum critique of a slash effect: "the orb in the middle seemed still and lifeless,
  while everything else was moving", and the loop had "an abrupt start and stop".
- `Emit(n)` for anything that is a moment; `Rate` only for gathers, auras and loops. `TimeScale` on
  emitters follows the effect's time scale so slow-motion captures line up.
- Warm every mesh, material and sprite once at join (the first-draw hitch), and keep the pack out of
  the streamed scene.
- Arcs: sparks and debris get `Acceleration` (gravity -20 to -40) and `Drag` 1 to 3 so they arc and slow,
  never flying in straight lines forever; secondary elements get the same so nothing drops out abruptly.
- Follow through: a ring keeps expanding as it fades, smoke drifts after the flash, the light decays over
  0.4 to 0.6 s.
- Waves inside a long piece: three bursts at +0, +0.44 and +0.9 s read as one huge explosion; one bigger burst
  reads as a pop.

### Block in first (Keyser, realtimevfx)

Strip textures, colour and shaders, keep simple shapes, and adjust the timing until the effect has its punch;
then dress it. Style hides bad timing. Build a phase with `Emitters.carrier` parts and plain `circle`, `core`
and `smoke` textures in white and grey, capture the phase attribute timeline, and only then swap in the kit
pieces with `Kit.burst` and the palette. When a burst reads soft, fix the timing (shorter lifetimes, fewer
frames to peak, a bigger first frame) before adding particles. Re-mapping the same block-in from slow to fast
turns a friendly spell into a damaging one. Bootcamp Q&A: plan the beats and the keyframes first, then basic
shapes (how big, how much space the smoke takes, whose colours, how scary, how much people
need to look at it), so the tool does not end up deciding the look.

### The review pass before a take goes to Lepy

Run it on the recorded take (the recording method is in the animation skill's pipeline.md) or on captures.
The ffmpeg commands assume a take at `take.mp4`; pick the seconds of the effect.
1. Greyscale: `ffmpeg -ss A -t D -i take.mp4 -vf "fps=6,format=gray,scale=480:-1,tile=4x3" gray_%02d.jpg`
   (a luminance conversion). In Studio, a client `ColorCorrectionEffect` with `Saturation` -1 during a capture
   is the quick version; compare it once with the ffmpeg frames before trusting it. Check: the focal point has
   the highest contrast, the core, the body and the rim are three distinct values, and no second spot competes.
2. Squint: `ffmpeg -ss A -t D -i take.mp4 -vf "fps=6,scale=120:-1,tile=4x3" squint_%02d.jpg`. The effect's
   read (where, how big, which way) must survive at thumbnail size.
3. Onion skin: `ffmpeg -ss A -t D -i take.mp4 -vf "tmix=frames=20,select='eq(n\,19)'" -frames:v 1 onion.jpg`
   averages the first 20 frames of the window into one image. Check the overall volume, the line of action and
   the spacing. (All three commands were tested on a generated clip, not yet on one of Lepy's takes.)
4. Intensity: step through the take frame by frame and mark the intensity per beat. Compare it with the curve
   planned in `T`: one spike for a damaging move, the main action inside the first quarter of each burst.
5. Gameplay: the primary edge matches the hitbox; nothing bright stays after the hit is over; a miss looks like
   a miss; the body that got hit is visible.
6. Colour: two or more hues, no fully saturated neighbours that vibrate, roughly 60/30/10, the character's
   colours.
7. The last question: what do I notice first, and is it what the player must notice now?

## 9. Where the sources and Lepy's taste disagree

- Riot: "if it feels long it's way too long", and get ultimates in and out fast. Lepy on the ultimate: "WAY
  more dramatic and longer". Both hold: the CINEMATIC rung is a reel piece and may run 16 s; gameplay effects
  follow Riot.
- Riot and Keyser: never pure white. Lepy's impact frames are pure white and black by design; they are a screen
  effect, not a particle, and last three frames.
- Vlambeer: more of everything, and permanence. Lepy's "too much feels messy" caps it: add juice to the hit
  moment, not to every frame. Riot's linger rule adds that anything that stays must look inert.
- Genshin and anime practice: impact frames and speed lines on hits. Lepy removed speed lines from every Asta
  move and wants no impact frame on a move unless asked for ("don't add an impact frame for the last m1
  please").
- Guilty Gear: no simulation. This skill still arcs sparks and debris under gravity, because they are physical
  matter and Lepy has approved them. Stepped, hand-shaped motion for energy shapes is an option to show
  Lepy, not a default.
- An area drawn smaller or larger than its hitbox per viewer is a gameplay decision; ask first.

## Sources

The playlist (VFX Apprentice, "Artistic Principles of VFX", read from the full captions on 2026-09-26):
- #1 Gameplay, Jason Keyser, https://www.youtube.com/watch?v=BOE8osaPzOY
- #2 Shape, Jason Keyser, https://www.youtube.com/watch?v=Wb7r6_L9Fyk
- #3 Value, Jason Keyser, https://www.youtube.com/watch?v=3DaBs-7oFhM
- #4 Color, Jason Keyser, https://www.youtube.com/watch?v=8iTkIDYupu4
- #5 Timing, Jason Keyser, https://www.youtube.com/watch?v=WLMVpcK0WvA
- #6 Composition, a Riot VFX artist and VFX Apprentice instructor, https://www.youtube.com/watch?v=zPl0oVanDV0
- Visual Effects Bootcamp: Artistic Principles of VFX, Jason Keyser (Riot) and Deidre Chamberlin (Blizzard,
  Hearthstone), https://www.youtube.com/watch?v=-L2JvngkkWw

Further reading (2026-09-26):
- VFX Apprentice blog: "10 Design Tips from the League of Legends VFX Style Guide", "The FX Artist's Guide to
  Area of Effect (AoE)", "How Style Guides Define The Look Of Your Game and VFX" (Sparkball), "How to master
  good timing in VFX and animation?", "Deconstructing Anime Combat Magic: How Genshin Impact Achieves
  Legendary VFX".
- Riot Games, League of Legends VFX Style Guide (Jin Ho Yang, 2017). The primary and secondary element traits
  come from summaries of the guide; the original PDF did not open.
- Real Time VFX forum: "Stylized Frag Launcher Explosion - Overwatch Inspiration - Breakdown Posted" (the 18
  layer breakdown and its critique), "Overwatch FX - Pharah Rocket Study" (with Nick Eberle of the Overwatch FX
  team on flipbooks, gradient maps and alpha erosion).
- Junya C. Motomura, "Guilty Gear Xrd's Art Style: The X Factor Between 2D and 3D", GDC 2015 handout.
- Wave Motion Cannon, "An Introduction to Framerate Modulation" (2016).
- Flash FX Animation, "#12 Fire" (2015).
- Roblox Creator Hub: the Beam, ColorCorrectionEffect, BloomEffect, NumberSequence and ColorSequence reference
  pages and the "Particle emitters" guide.
- Roblox DevForum: "How can I make my visual effects look better?" (2024).

From the first pass (2026-09-22):
- Riot Games, League of Legends VFX Style Guide, via VFX Apprentice and the guide's public deck outline.
- Jason Keyser, "Block-ins and Timing", Real Time VFX forum (2025); VFX Apprentice course outlines
  "FX Timing Principles" and "FX Design Principles" (Dan Elder).
- Jan Willem Nijman (Vlambeer), "The Art of Screenshake" (2013), via the artificials.ch list of the
  30 tricks; Martin Jonasson and Petri Purho, "Juice It or Lose It" (2012).
- VisuallyFX, "Introduction to VFX: Particles", Roblox DevForum (2022); Meioua's answer in "How to make
  Emitter effects look good?", Roblox DevForum (2025).
- Johnston and Thomas, The Illusion of Life (the twelve principles), shared with the animation skill.
