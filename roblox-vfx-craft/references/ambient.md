# Ambient world effects: light shafts, insects, zone mist

Built 2026-10-06 for the Shinsenkyō island place (Hell's Paradise survival game). Lepy: "Just mke it canon to the anime",
with his picks LOOK 1 (ep 4: light shafts, orange-black butterflies near a mossy stone head), E1 (ep 9: misty flower
jungle) and H1 (ep 9: Hōjō "covered in a thick mist", grey-violet). Ambient effects are not on the tone ladder: they never
take the camera, they run for the whole session, and their budget is "no measurable cost".

## Shape of the system

- Templates are real instances in `ReplicatedStorage.Client.Island.Fx` (built once in Edit by `scripts/ambient/IslandFxBuild.lua`):
  `Shaft` (a part with Top/Bottom attachments and two beams), `Butterfly` (a static part with six attachments and three beams),
  `Mist` (a part with three emitters whose zone rates are attributes), `Zones/<Zone>/{Atmosphere, ColorCorrection}` presets.
- One module per effect (`Shafts`, `Butterflies`, `Mist`), started by the existing client entrypoint. Clones go under
  `workspace.CurrentCamera`, so nothing replicates.
- Everything is pooled and placed near the camera; nothing is placed across the whole map.

## Light shafts through a canopy

- Find real gaps, do not scatter shafts. The tree leaves were `CanQuery = false`, so the module keeps an analytic crown list
  (centre, top, bottom, radius = 0.42 x mean width of the leaves part) in 128-stud cells, built from the streamed tree folder
  (`ChildAdded`/`ChildRemoved`, cache cells within 4 cells of a changed tree are cleared).
- A ground point is lit when the sun ray from it is clear of crowns at heights 30, 60, 90, 120, 150. A shaft spot is lit while
  at least 4 of 6 points 30 studs around it are dark (a pool of light). Width grows with the lit points at 11 studs.
- The shaft starts at the mean mid-crown height of the crowns within 89 studs, not at a fixed height: a fixed 150 studs put the
  top of the beam into the open sky above the canopy, where it drew as a pale band.
- Candidates are deterministic per 34-stud cell (hash jitter), cached, solved nearest first under a 1.5 ms per frame budget.
  The Edit VM needed 225 ms for 225 cells in one go, so never solve a whole ring in one frame.
- Two beams: `Glow` (DevForum light-beam texture 2382169232, width 24/28, transparency 0.86 mid) and `Body` (a painted streak
  texture, width 13/15, 0.62 to 0.66 mid), LightEmission 1, FaceCamera, fade in 1.6 s. 18 shafts within 230 studs.
- Painted streaks must run along the image's vertical axis (see the beam axes below); the first upload had them horizontal and
  the shafts drew as flat slabs with hard edges.

## Butterflies (or any small flying creature in numbers)

- Parts are expensive to move: 30 anchored parts moved every frame with `BulkMoveTo` cost about 2 ms per frame (decals or not,
  under the camera or a workspace folder); static parts cost nothing. 10 three-part butterflies cost 2.7 to 3.4 ms.
- Attachments are free to move: 60 attachments with 30 beams moved every frame measured 38.4 ms against a 38.4 ms baseline.
  So each butterfly is one static part at the origin holding six attachments: BackL/FrontL and BackR/FrontR for the wings
  (one beam per wing, `FaceCamera = false`, width = wing span), Tail/Head for a camera-facing body beam with a painted body.
  The module writes `Attachment.CFrame` (the part sits at the identity, so it is the world CFrame). 10 butterflies on
  and off measured inside the 2 ms run-to-run noise (36.5/35.9 ms on, 35.8/37.7 off).
- Beams are double sided, so one wing texture gives a mirrored pair: give both wing beams the attachment Y axis pointing out
  from the body and run both from back to front.
- Flight that reads as a butterfly: heading from `math.noise` (3 rad/s) plus a turn back home scaled by
  `1 - exp(-d^2 / 140)`, 3 to 4.6 studs/s, height 2 to 6 above the home ground plus noise, a vertical bob of 1.6 studs/s in
  phase with the flap, flaps 5.5 to 7.5 Hz with a fast downstroke (0.38 of the cycle, +69 to -26 degrees), short glides,
  landings on a point 2 studs above the terrain (0.8 hid them in the terrain grass) with wings folded and slowly opening.
- Homes are the streamed flower patches (0 to 4 per patch from a position hash); 32 at most within 150 studs, re-picked every
  second, pooled.
- Wingspan 1.6 studs: a butterfly shape at 5 to 9 studs, a small dark insect at 12 to 16 studs.

## Zone mist and mood

- Zone weights from the distance to the island centre with smoothstep bands 120 to 160 studs wide; Atmosphere and
  ColorCorrection follow the weighted preset with `1 - exp(-dt * 1.2)`. The client may change Lighting locally.
- Emitter rate per zone is an attribute on each template emitter (`Eishu`, `Hojo`, `Horai`); template emitters are saved
  enabled at rate 0 (disabled ones never emit from `Rate`).
- Thick mist needs mist near the player: a 3 x 3 grid of 110-stud cells left the player in clear air with banks far away;
  a 5 x 5 grid of 64-stud cells (25 carriers, raycast to the ground once per cell change, no mist over water) reads as
  "covered". The Hōjō look came mostly from the Atmosphere: density 0.55, offset 0.6 (greys the sky), haze 3.2, glare 0,
  colour 176/176/190, decay 110/106/128, ColorCorrection saturation -0.25, contrast -0.04, tint 230/228/245.
- Textures from the Toolbox scan: 12565968570 (dense bank), 244514423 (broad layer), 1077212019 (faint haze);
  LightInfluence 0.2 to 0.5.
- Cost in the thick mist: 17.9 ms average, 19.3 p95 (the bare island measured 17.9 / 19.4 before the forest).

## Engine facts found on the way

- Beam with `Segments = 1` samples its Transparency only at the two ends: a curve that is 1 at both ends draws nothing.
- Beam with `FaceCamera = false`: the width runs along the attachments' Y axis. Texture image vertical axis runs along the beam
  with image top (y = 0) at Attachment1; the horizontal axis runs across the width with x = 0 on the +Y side.
- Decals on a part's Top face show the image rotated 180 degrees against the Bottom face as seen from each side, so a two-sided
  decal wing needs a mirrored second texture; beams avoid this.
- DevForum light-beam ids were Decal ids; `InsertService:LoadAsset(id)` gave the image ids (2382169264 -> 2382169232,
  9616406359 -> 9616406328).
- Studio MCP: `execute_luau` sets `CameraType` back to Custom after the call; hold a shot with a self-ending
  `BindToRenderStep` at `RenderPriority.Camera + 1`, then grab the Studio window. In Play, `screen_capture` views with camera
  arguments showed no camera-parented effects, while window grabs showed them; use window grabs for these effects.
