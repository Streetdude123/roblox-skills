# Water constructs: what the tutorials teach, translated to Roblox

Read 2026-09-25 at Lepy's request, after the second "too geometric" on Judgement's Hammer: "make sure use a
TON of vfx academy and vfx tutorials for roblox and try again, the hammer looks okay for vfx but im not
aiming for okay im aiming for AMAZING", then "After learning, update the vfx skill". Every rule is
restated with the Roblox instance, property or number it implies. The last sections record what the
hammer rebuild proved in Studio. Sources at the end.

## 1. The four properties that make a shape read as water (VFX Apprentice)

A shape reads as water when it shows transparency, reflection, bubbles and ripples. Take one away and
it reads as glass, plastic or smoke.

Roblox translation:
- Transparency: the body sits at 0.35 to 0.6 with a Neon core one step brighter inside it at 0.72 to
  0.8 (`Glow`, `ArmCore`). A body at 0 is plastic; a body at 0.8 with no core is smoke.
- Reflection: `Material.Glass` with `Reflectance` 0.05 to 0.1 on the body parts. At quality level 21
  Glass refracts what is behind it and catches a hard highlight, which SmoothPlastic never does.
  Neon parts keep `Reflectance` 0.
- Bubbles: a `bubble` sprite emitter on the surface (`ShapeStyle.Surface`), speed 4 to 9 outward,
  drag 2, life 0.35 to 0.6, size shrinking 0.9 to 0.3.
- Ripples: flowing texture on every long shape. A beam with `TextureSpeed` 3 to 8, or the `Torrent`
  chain. A static texture on a long shape reads as a painted pipe.

## 2. No hard edges, and the edge is where water breaks up (VFX Apprentice)

Water has only round contours. At the edge of a mass the water breaks into smaller and smaller pieces:
blobs, then bubbles and droplets, then mist. The bubbles follow the flow, not random directions.

Roblox translation:
- Round every silhouette: sphere `SpecialMesh` ellipsoids and organic meshes, never a Block part.
  A Cylinder part is allowed only when a torrent, a whirl or particles hide its rims.
- Put the break-up on the edge emitters, not on the centre: `Flick` crescents (speed 6 to 11, drag 3),
  `Bubbles` and `Spray` droplets (`VelocityParallel`, squash -1.6) on the surface shape of the part,
  moving outward and falling (`Acceleration` y -20 to -50).
- The flow lines are structure: spiral strands around a mass show which way it turns. The torrent's
  helix strands (`H1`, `H2`) are these lines. Keep them, but hide the solid white `H3` stroke and the
  `W` core line on short tubes: on a forearm they read as a lightsaber line.

## 3. Layer it: line, fill, shadow, foam (VFX Apprentice, the 2D animation guides)

A stylized water mass is four layers: a dark shadow shape under it, the fill, bright lines on top, and
white foam where the water moves fastest or hits something. The edge of a foam patch is its densest
part. White droplets around the foam finish it.

Roblox translation:
- Shadow: a `DEEP` (6, 40, 120) layer at `LightEmission` 0 and `ZOffset` -0.3 to -0.4 under every
  bright layer (the `Shade` beam of the torrent, the `Shade` burst of a whirl).
- Fill: the Glass body plus a `blobs` flipbook locked to the part (size 2 to 4, transparency 0.3).
- Lines: `streak` beams and `crescent` sprites at `LightEmission` 0.5 to 1.
- Foam: `crescent` sprites in white to pale on the rims and on the cut (life 0.2 to 0.34, spin 200),
  and on every impact the `Crown` and `Spikes` of the slam.

## 4. The Roblox waterfall numbers (Creator Hub, "Create waterfalls")

The official tutorial builds water only from Beams and ParticleEmitters. Its numbers are a good start:
- Cascade beams: `TextureSpeed` 1.0 to 1.3, `TextureLength` 1.5 to 2, width growing 5 to 10 or 20,
  colour light blue (208, 247, 255) to white to a dark blue, `Segments` high enough to curve.
- Splash: rate 30, life 0.25 to 0.35, speed 20 to 35, `LightEmission` 0.5, `LightInfluence` 0.1.
- White water: `LightEmission` 0.6. Foam: rate 5, size 5 to 20, `LightEmission` 0.25.
- Mist: speed 35 to 50, life 0.5 to 1. A rainbow sheet: `LightEmission` 1.

## 5. How battlegrounds games build big constructs (DevForum mesh VFX threads)

- Mesh VFX are parts that tween in and out: size, transparency and spin, driven by a module, never by
  the Animation Editor. Mesh flipbooks swap `MeshId` or `TextureID` every frame from a script.
- The hard shader tricks of other engines (fresnel rims, erosion masks, vertex animation) have no
  Roblox property. The substitutes: a Glass body for the rim highlight, a Neon core for the inner
  glow, sprite flipbooks for erosion, and beams for moving surfaces. A `Highlight` outline is 1 px:
  it is not a rim.
- An organic silhouette (a hand, a head, a creature) comes from a mesh, not from primitives. Four
  sphere fingers read as stacked discs or rings from the player camera; a free model fist mesh read as
  a hand at once (section 7).
- Plugins exist for this (VFX Forge: particles, beams, trails, mesh VFX and flipbooks in one editor),
  and paid courses teach it (the EnhanceBlox VFX masterclass, Udemy Roblox VFX courses). Their free
  material repeats the rules above.

## 6. Tutorials for splashes and trails (DevForum community resources)

- The open source water interaction resource: splash and mist emitters on attachments, a trail beam
  whose transparency fades over 0.4 s, splash sounds with volume 25 to 35% and pitch 80 to 120%.
- Painted water trails (Real Time VFX): a chain of meshes with the texture animated over them, and the
  foam as billboards that shrink over their life. In Roblox: the `Torrent` beam chain plus shrinking
  `crescent` foam.

## 7. What the Judgement's Hammer rebuild proved (measured 2026-09-25)

- Frame for the player camera first. A 20-stud construct seen from behind the caster is foreshortened
  along its axis: the old arm pointed away from the lens and hid behind its own fist ("Where's the
  water arm controlling the hammer?"). Measure the hero on screen with `Camera:WorldToViewportPoint`
  in the take script and keep its centre at least one radius inside the frame during the hold. At zoom
  14 the frame top is about 5 + 0.4 x depth studs above the root.
- A forearm reads when it stands across the view (vertical or diagonal), not when it points at the
  target. Swing the construct so the forearm is upright during the hold.
- A hand needs a hand mesh. The primitive fist (a palm ellipsoid, four finger rolls, a thumb) read as
  a stack of discs in every take. The free model "giant bendy hand/fist" (mesh 75041501802813, no
  scripts, re-coloured, texture removed, Glass 0.36 with a Neon copy at 0.8 scale inside) read as a
  water hand in the first Edit capture. Its grip runs across the fist, so the handle crosses the forearm
  and the head axis is parallel to the forearm; the head then lands face down only with the forearm
  vertical, so the elbow rides up and forward during the slam.
- Short torrent segments need fractional texture repeats. With `rep` 7 and 0.6-stud segments each
  segment showed the whole texture once: 12 bright stripes along the arm (a ribbed hose). The
  `fine` option of `Torrent.new` sets `TextureLength` to `len / rep` in 0.05 steps.
- A trail whose attachments span the swing plane is seen edge-on from behind as a thin vertical line of
  light. Set `FaceCamera` true on swing trails that the player sees from behind.
- Cost of a big water construct on his machine: the fist-mesh hammer (four torrents, two face whirls,
  surface emitters, a Glass mesh) added about 9 ms per frame (first cast median 27.9 ms on an 18.7 ms
  idle). The Lua of four torrents was 1.76 ms; the face whirls and the halo about 2 ms; Glass against
  SmoothPlastic about 0; beam `Segments` 12 to 4 saved about 1 ms. Idle frame time drifts up over a long
  session (18.6 to 27 ms), so compare a cast with the idle measured just before it.
- Stills at a frozen `TimeScale` lie for a move: the clip clock and the construct clock drifted and three
  captures showed the same pose. Judge a move from a recorded take (a contact sheet by time).

## 8. What the block rebuild proved (measured 2026-09-25)

- Facing sprites (`VelocityPerpendicular`, `LockedToPart`) on a flat 4 x 4 carrier part spawn anywhere in the
  part's box, so a whirl built from them is scattered blots, not a whirlpool. Parent them to one centre
  `Attachment` and they are concentric. Ripple rings need the same centre point.
- A `Disc` shape on a flat part with the default `EmissionDirection` (Top) sprays upward from a thin line, not
  from the rim. For rim spray that breaks off the edge, use attachments round the rim (8 on a 2-stud ring) with
  their Y axis pointing outward and `EmissionDirection` Top, spread 22 to 30 degrees, gravity -18 to -40.
- A Glass lens over a sprite-built surface hides the sprites inside it and reads as a crystal disc (the
  "crystal ball" trap again). The shine comes from a fixed white crescent sprite at the upper left instead.
- White layers stacked on one centre read as a white cloud. Keep the fill blue (70, 170, 250 to 25, 100, 225 at
  `LightEmission` 0.3), white only on thin crescents (7 a second) and the rim foam.
- The radial droplet burst sprite (13580371343) as the dark partner drew scattered ink blots; a soft `glow`
  sprite in `DEEP` behind the whirl gives the dark rim without shapes.
- From the player camera behind the caster, the body hides the centre of a small chest-height block; what reads
  is the rim (the torrent ring, the rim spray, the ripples at the edge). Put the hit reactions where they show:
  radial rim spray, a ripple at the contact point, and a wobble of the torrent ring (radius times
  1 + k sin(34u) e^(-7u) sin(2a + side), k 0.1 on a block and 0.16 on a parry).
- Test trap: a take camera placed in front of the caster turns the body toward the camera heading, so a later
  hit comes from behind and counts as a "drop" (the hit lands). Keep the camera behind the caster for guard tests.
- Cost: holding the new block cost median 21.7 to 21.9 ms, p95 about 25, on an 18.7 to 19.0 ms idle (about 3 ms).

## 9. What the Dragon Form rebuild proved (2026-09-26)

A 20 s worn form (wings, horns, claw, tail, lance, body wraps) seen from the player camera the whole time.

- A Glass membrane on a mesh wing reads as glossy white plastic under the sky (the refraction goes white). `ForceField`
  material on the same mesh (colour 30, 130, 255, transparency 0) reads as translucent water with a bright rim. Add two
  `Texture` overlays on the Front and Back faces (the waterfall texture 12781828706 tinted 40, 160, 255 at 0.3 and the sheen
  streaks 10365550877 at 0.55), scrolled each frame through `OffsetStudsU/V`: the ripples stay clipped to the silhouette.
- Map a mesh before placing effects on it: a 5 x 5 grid of coloured Neon markers over the part and one front capture give the
  local coordinates of the root, the leading edge, the tip and the rib ends. Bright bone lines are curved FaceCamera beams
  between attachments on those points (layers Base, Flow, Sheen, Core); drips hang on the rib ends and the scallops.
- A ForceField part stays faintly visible near transparency 1. Parent the worn model out of the workspace while it is hidden.
- Sprite traps: 15011478368 is a foam RING flipbook (white "o" rings when it floats in the air; keep it flat on the ground);
  16924362907 is a 4 x 4 POP flipbook (without the flipbook settings it draws the whole 16-bubble sheet); floating bubbles
  are 110703113355989 (Grid4x4, OneShot); the crescent 16924704235 reads as a white hook or smoke curl when it floats alone.
- Horns from an accessory mesh: find where its base is before scaling. HornsAncient (521793597) has its curled base at the
  front; mesh scale (0.95, 1.7, 1.9) at head offset (0, 0.6, 0.34) tilted -22 degrees puts the base in the temples. A
  uniform 1.9 scale put both horns beside the head.
- A water tail = the torrent chain on a follow chain: each node eases toward its parent plus the rest segment (rate 24 at
  the root to 9 at the tip) and keeps its length. A verlet chain with velocity carry folded into loops on a fast turn; the
  follow chain measured a 23 degree maximum bend between segments. Give the rest shape a sideways curl, or from behind it
  reads as a pole. Two small ForceField wing meshes at the tip make a fluke.
- He rejected full-body coverage twice: FaceCamera beams laid over each limb showed hard rectangle edges, and scrolling
  `Texture` overlays on every limb face "covered the whole body" and cost 8 ms a frame (60 textures). What he picked:
  wraps on chosen areas (forearms, shoulders, chest and collar) that leave the body as trailing ribbons.
- Trailing ribbon = a static helix of beams on the limb (a carrier part welded to it) whose last attachment carries
  `Trail` (rest direction in torso space), `Width`, `Nodes`, `Seg` and `Wave`; at run time a template part with 9 attachments
  and 8 x 3 wired beams continues it: node 0 on that attachment with its tangent, the rest on a follow chain toward the rest
  direction plus a sideways and a vertical wave, width swelling like a flag (1 + 0.9 sin(0.8 pi x)) (1 - 0.6 x), alpha
  fading by x cubed. From behind, a ribbon that trails straight back points at the lens: give the rest direction a strong
  sideways part.
- Coils with more than about 0.7 turns per limb read as stacked rings; 0.55 to 0.6 turns read as a current along the limb.
- Cost on his machine: beams cost about 1.5 ms a frame per 100 at `Segments` 10. Scale `Segments` with length (3 to 10),
  drop the torrent's `Core` and `H3` strokes on a thin tail, and use three plain beams for a short jet. The final form:
  hover median 20.5 ms, moving 22.3 ms, on a 16.6 ms idle.

## 10. Toolbox kit pieces in the Dragon Form moves (2026-09-26)

- Three free model pieces went into the form variants after a script scan: TideRing (six Shockwave meshes, a flat ring 20.6 studs across, stored standing up, so lay it flat with a 90 degree turn about X), WaterWhirl (four swirl meshes, 17.8 studs tall) and WaterGeyser (67 parts: splayed water columns plus a white splash base, 29.5 studs tall, pivot at the base). The builder copies them to `Assets.Dragon.Pieces`, anchored, no collision, no shadow, transparency at least 0.25 with the value kept in a `Base` attribute for fades, and the join warm-up draws them once.
- Kit pieces often carry a near-black mesh as a dark rim. On water it reads as black ink strands ("not water"). Recolour any part whose brightest channel is under 0.15 to deep water blue (18, 64, 140).
- A whirl around a spinning body must stay small and see-through: at scale 0.7 and full opacity it hid the enemy on the lance; scale 0.5 at 0.6 alpha, 0.62 s.
- Animate a big piece with ScaleTo and PivotTo on one PreRender connection per spawn, keep the part list and base transparencies from the spawn, and destroy the model at the end. A geyser rises from under the floor (pivot at the base) instead of scaling up.

## Sources

- VFX Apprentice, "How to Make Water VFX and Use Properties of Water for Stylized VFX" and "How to Draw
  Stylized Water" (blog).
- Roblox Creator Hub, "Create waterfalls with VFX" (use-case tutorial).
- Roblox DevForum: "How do I use meshes as VFX instead of particle emitters?", "Roblox 3D VFX for
  MeshVFX", "VFX Tutorial Roblox", "What are mesh flipbooks?", "Full Beginner's Guide on scripting
  Anime/Fighting VFX", "Realistic Water Interaction - Splash, Trails, Bubbles OPEN SOURCE", "How to
  make Animated Slashes 2.0!", "How to make a realistic water splash effect", "[Plugin] VFX Forge".
- Real Time VFX forum: "This painted style water trails", "Stylized Waterfall Breakdown".
- Animationclub School, "How to Draw Water in 2D Animation"; Simon Schreibt, "Stylized VFX in RiME,
  water edition".
- Black Clover Wiki (search summary): Sea God's Hammer is "an enormous forearm wielding an
  equally-large hammer that levitates above the user", swung the way the user swings the arm.
