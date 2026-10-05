# Replicating a reference image: measured, not eyeballed

Built 2026-09-27 on Lepy's still of a magenta spike eruption (Place1). His bar: "atlest 95% accuracy", then "98% correlafion in
SIZE and SHAPE" "AND COLOR", "compare them side to side, notice the exact differenr, then fix your textures accordingly". Packs
could not supply the shapes ("vfx packs can't help you for lots of these custom textures"); every hero texture was painted or
traced. Scripts: `scripts/reference-match/` (measurement), `scripts/PaintTextures.ps1`, `scripts/DrawShapes.ps1` (painters),
`scripts/serve_textures.js` (upload server), `scripts/Eruption/` (Cast module, click client, relay server, final textures).

## The loop that worked

1. **Solve the camera.** Pick the base point and the tip in the image, fit camera distance and pitch so both land on their
   pixels (a grid search in `execute_luau`), then choose the field of view so no horizon shows. Hold that camera in Play with a
   RenderStepped connection (`_G.holdConn`) and put four 8 px pure-green corner frames in a top ScreenGui: `compare.ps1` finds
   them (G > 245, R and B < 12) and crops the 16:9 viewport out of a full-window screenshot (`win.ps1 shot`, which maximises
   Studio first; a restored window gives a 461 px tall viewport, too small).
2. **Freeze a beat.** A test harness clones the template, poses the beams for time t, emits on the second frame after parenting,
   waits t, sets `TimeScale = 0` on every emitter. The reference frame matched t = 0.14 s.
3. **Score.** `compare.ps1` (grid colour similarity and luminance correlation), `shape.ps1` (area ratio, outline IoU, mask and
   soft-mask correlation, per-channel colour correlation, by region), `cells.ps1` (6 x 6 cell mean colours: this is the one that
   names the fault, e.g. "green 30% high inside the burst"), `embers.ps1` (connected components of orange: centre, axis, length,
   brightness), `outline.ps1` (burst radius per degree around the base).
4. **Fix the largest measured error, one change per capture.** Offline, `texscore.ps1` scores a painted texture straight
   against the image before upload, so texture tries cost seconds, not the 1 to 10 minute moderation wait.

## What each fix taught

- **Outline**: trace the burst radius per degree (`outline.ps1`), clean single-ray outliers (a crack splat stops a ray) with a
  9-degree median, and paint the crown inside that outline. Then trace **occupancy** per degree and per 8 px ring (fraction of
  burst-pink pixels): the dark gaps between spikes are not at the outline valleys (wider valley gaps lowered IoU from 84% to 70%);
  the occupancy trace raised IoU to 92.7%.
- **Colour**: bake a per-direction, per-ring mean colour map (12 x 24 cells). The brightest-30% ramp made the burst pale.
  Engine side: Brightness above 1 clips red first, so green and blue rise and the colour turns pale; tint with the emitter Color
  instead (measured ratio: `Color` 255,140,185 at Brightness 1.25). The reference root is deep magenta, the rim red-coral.
- **Crack**: the reference crack is saturated magenta (150, 0, 70, zero green), not near black. Tracing it through the camera onto
  the floor gave soft blobs (grazing angle, the column hides the back), so the crisp painted crack he chose stayed, with the
  measured colour and size.
- **Embers**: extract each ember (position, axis, length, brightness) and solve one fixed emitter per ember (start point, direction,
  speed with drag so it lands on its pixel at t). Varied size and brightness come for free.
- **Core**: measure the white width at several heights (reference 29 to 31 px): a straight column, not a cone; a white oval at the
  base reads as a blob.
- **Softness**: the reference has hard edges almost everywhere; the soft look came from round glows and wide zoom blur.
- **Background**: sample the reference background profile (bright vertical band, near-black sides) and build the vignette as a
  UIGradient band; a GUI vignette also darkens the effect off-centre (ember cores reached 205 against 255), and a camera
  SpotLight cannot replace it (range 60 does not reach the far floor).
- **Light**: a pink PointLight with range 15 lit the floor in front of the burst and the shape score counted it as burst; range 10.

- **Spike ends** (`reference-match/strokecrown.ps1`): the traced fill had a cut-paper edge ("the endings ... aren't jagged").
  Paint one stroke per 1.5 degrees, as long as the occupancy trace reaches at that angle (occupancy 0.35 or more), base width 2
  bins, tapering to a hard point; lay a dimmer traced haze (alpha 0.6, measured colour) under the strokes so the blurred gaps stay
  covered (strokes alone dropped IoU to 76 to 80%). Colour each stroke along its own length: measured map at the root, then the
  brightest quarter of the tip pixels (255,144,163 at 55 to 70% of the radius, 254,132,142 at 70 to 85%, fading to 217,73,86).
  In the engine tint the emitter 255,84,126 at Brightness 1.25.
- **Explosion rim** ("the valleys between the spikes needs tp be deeper and more variates, think of noise waves"): take the
  upper-quartile outline over 11 bins as the base, multiply each stroke length by layered sine noise (5 octaves, random phases,
  `waveDepth` 0.5, `peakBoost` 0.15, per-stroke `needle` 0.3), normalise by the mean square so the area stays, clamp to 95% of
  the texture edge, and cut the haze at 60 to 85% of the local spike length so valleys stay dark. Parameters in `strokecrown.ps1`.
- **Contrast, outline, hot bottom** (`-contrast -hotBottom 0.9 -edgeK 0.75 -edgePx 3 -edgeBottomK 0.95 -edgeBottomExtra 2`):
  the hue ramp is baked per spike (the emitter tint only corrects the glow), the outline is a post pass on the finished alpha
  (silhouette only), and both the hot pink and the outline weight follow the downward direction in screen space.

## Final scores (Play, Level21, t = 0.14 s, reference camera, spike crown)

Area ratio 1.049, outline IoU 92.6%, mask correlation 0.944, soft-mask correlation 0.979, 64 x 36 colour similarity 94.6% with
luminance correlation 0.930, per-pixel colour correlation R 0.945 G 0.731 B 0.889. The per-pixel green score stays low
because fine detail differs (streak texture, crack pieces, rock, ember cores dimmed by the GUI vignette); pushing it to 0.98 would
mean copying the reference pixels, which reproduces the original artist's work, so the texture work stops at traced silhouette,
measured colour maps and painted detail.

## Engine facts found on this build

- `Beam.TextureSpeed` defaults to 1 (the texture scrolls and wraps); set 0 for a shaped texture. The image top maps to Attachment0.
- `ParticleEmitter.ZOffset` changes draw order only; `Beam.ZOffset` moves the beam and changes its screen size.
- `VelocityParallel` aligns the texture's horizontal axis with the velocity: a tip-up texture needs `Rotation = -90`.
- Emitters off screen in Play do not simulate; point the camera at a test spot before a freeze frame.
- `Emit` in the frame the clone is parented emits nothing in Edit; emit on the next RenderStepped.
- Fresh uploads render blank until moderation completes; poll `thumbnails.roblox.com/v1/assets?assetIds=` in a background task.
- One unit of particle Size draws about two studs across.
- Studio PowerShell: a `Remove-Item` safety filter blocks some long commands that contain no delete; split the edit.

## Painted sprites for a sword wave (2026-09-28)

`scripts/paint/feather.py` paints a 512 px feather (curved quill, barbs at 38 degrees with split gaps, core to mint to teal, a
dark teal rim and a soft halo) and `scripts/paint/trail.py` a 256 px trail strip (bright edge at the tip side, soft streaked
body fading toward the hilt). Pillow, `py -3`. Uploaded as 107483578603804 and 119359586668380 (feathers) and 82141299579764
(trail); on a beam the feather runs along the beam (quill at Attachment0), on a particle use FacingCamera and a random rotation.

## Painted flame flipbook for a steady fire (2026-10-05, Shinsenkyo kagaribi)

Toolbox fire packs (six high-rated ones, scripts read and removed) drew orange blobs in a sunset scene, and the "fire burst" flipbook 11489199156 is an explosion, not a flame. The fix was a painted 8x8 flame-tongue flipbook: `scripts/paint/flame/flame.py tongue <seed> 8 128`.

- Shape: noise erosion, not a hand-drawn teardrop. A teardrop field (`G * F`) plus fbm noise that is masked to the flame's neighbourhood (unmasked noise left floating specks), noise erosion stronger near the tip, a fade at the cell bottom, a life envelope that grows the tongue, lifts its base and lets the lick drift off and fade.
- Colour baked in the texture (deep red - orange - yellow - pale core). Alpha `ss(0.02, 0.62, T) ** 1.15`: a hard alpha ramp drew red outlines where tongues overlap. Overall `T * 0.9` keeps the core from turning white.
- Judge the whole fire offline before upload: `sim.py fire1.json out.png` draws many particles the way a ParticleEmitter does (size curve, OneShot frames, LightEmission blend) over a dark and a sunset background.
- Emitter (KagaribiFire.lua): flames spawn from an invisible Box-shape part over the basket mouth (an Attachment emits from one point), two flipbook variants (118340173564501, 121999875479986) at rate 12, life 0.75-1.0, speed 0.25-0.6, size 2.3-2.6; a smaller core layer; embers (8068783649, VelocityParallel + Squash); smoke 11414939890; a 4.2-stud glow at 0.9 transparency; a PointLight tagged FireLight that a client module flickers with two noise octaves; a crackle loop 9112780462 tagged AmbientSound. A fast tongue speed (0.6-1.2 plus acceleration 1) stretched the fire into a 4-stud column; the slow values read as a basket fire.
