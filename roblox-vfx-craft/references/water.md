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
