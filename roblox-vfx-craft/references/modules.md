# The modules

All of them live in `ReplicatedStorage.<Feature>.Modules` next to a `Config` and an `Assets` folder,
and as copies in this skill's `scripts/`. The feature folder carries a `TimeScale` attribute that
stretches every duration, so a slowed capture still lines up.

## Tw.lua - tweens and sequences

- `Tw.S()` reads the `TimeScale` attribute (1 in play).
- `Tw.play(inst, props, dur, style, dir, delayTime)` creates and plays a tween. **A tween created with
  `TweenInfo.DelayTime` cancels the running tween on the same property the moment `Play` is called**,
  so every "snap up then ease back" written as two tweens was silently dead (the light spike, the FOV
  punch, the pillar pulse, the audio duck). `Tw.play` waits the delay with `task.delay` and creates
  the tween when due, returning `{Completed = BindableEvent.Event}` so callers can still `:Once`.
- `Tw.wait(dur)`, `Tw.seq({{t, v, envelope}})` for NumberSequences, `Tw.cseq({{t, color}})` for ColorSequences.

## Emitters.lua - code emitters

- `Emitters.TEX` is the texture vocabulary (all from his packs):
  `star4 1084970835`, `spark 8037777212`, `lightrays 1084975295`, `lightray 1053548563`,
  `core 1075864321`, `flare 867619398`, `circle 1084982817`, `specs 9997556038`, `shards 10439119562`,
  `blackshards 12130244331`, `rocks 12111686783`, `smoke 16669188960`, `smokeB 14006773822`,
  `darksmoke 10180479311`, `shock 16477162837`, `impact 16954586568`, `impactB 16670162492`,
  `burst 9573351641`, `windspin 16669803246`, `windspinB 16669505937`, `crackA 16937144632`,
  `crackB 16937229477`, `crescentRing 11948622097`, `fire 11395089850`, `stars 1851669703`,
  `windRing 16950679789`, `windA 10337713824`, `glow 12082081459`.
- `Emitters.make(parent, spec)`: spec keys are emitter properties plus `texture` (a TEX name or an id)
  and `flip = {layout, mode, fps}` for flipbooks. Defaults: disabled, rate 0, LightEmission 1,
  LightInfluence 0, TimeScale from `Tw.S()`.
- `Emitters.carrier(parent, cf, size)`: an anchored invisible part that gives an emitter a volume and a
  world position (CanQuery and CanTouch off, no shadow).
- `Emitters.burst(parent, cf, size, spec, count, life)`: one shot that cleans itself.
- `Emitters.sparkles(parent, o)`: the Megumin field; `o.size`, `o.rate`, `o.speed`, `o.drag`, `o.accel`,
  `o.spread`, `o.life`, `o.shape`, `o.style`, `o.inOut`, `o.zoffset`, `o.enabled`. Returns a list of
  `{e, mul}`; `Emitters.setSparkles(list, on)` toggles it; `Emitters.sparkleBurst(parent, cf, size, count, o)`
  emits the set once with `count` stars per colour.

## Kit.lua - his templates

- `Kit.spawn(name, cf, parent)` clones `Assets.Vfx[name]` anchored at a CFrame with every emitter still
  off. `Kit.mesh(name, parent, cf, size, color, transparency)` clones `Assets.Meshes[name]`.
- `Kit.each(inst, fn, filter)` visits emitters (filter is a name or a set of names); `Kit.eachBeam`.
- `Kit.tint(inst, color, color2, filter)` (two colours fade over the life), `Kit.scale(inst, k, filter)`
  scales every size keypoint and beam width, `Kit.glow(inst, le)`, `Kit.set(inst, props, filter)`.
- `Kit.emit(inst, counts)` with a number or a table keyed by emitter name or texture id digits.
- `Kit.enable(inst, on, filter)`; `Kit.beams(inst, on, dur, delayTime)` grows beams in from width 0
  with Back Out (a rune ring never pops on) and shrinks them out with Quad In before disabling; the
  original widths are kept in `W0`/`W1` attributes.
- `Kit.kill(inst, life)` disables everything and lets the last particles die before Debris removes it.
- `Kit.burst(name, cf, parent, counts, o)` = spawn + tint/scale/glow/set + emit + Debris; `o.life`
  defaults to 3 s.
- Trap fixed on the way: `A and (B or C) or D` in the count lookup compared a table with a number; use
  an explicit if/else.

## CameraRig.lua - the cinematic camera

- `CameraRig.take(originCF, params)` makes the camera Scriptable and binds a RenderStep after the
  camera priority. Shot values live in NumberValues (`angle`, `dist`, `height`, `lookY`, `fov`, `roll`);
  angle 0 sits behind the origin's facing. Every frame: `smoothCF = smoothCF:Lerp(target, 1 - exp(-dt * 9))`,
  fov lerp 12, plus the shake.
- Shake: `math.noise(t * 13, channel, seed)` on three axes and three rotations, scaled by
  `max(trauma, floorTrauma) ^ 2`, 2.6 studs and 0.05 rad. Low frequency reads as a heavy rumble, not a
  jitter. `CameraRig.floor(0.16)` keeps a handheld breath; `CameraRig.kick(amount)` adds trauma that
  decays at 1.5 per second.
- `CameraRig.shot(params, dur, style, dir, delayTime)` tweens the values (Sine InOut default; a delayed
  shot waits before creation for the same reason as Tw.play). `CameraRig.cutTo(params)` cancels the
  running tweens, snaps the values and the smoothed CFrame so the next frame is the new shot.
- `CameraRig.freeze(dur)` skips updates for the length of an impact frame set.
- `CameraRig.cut(character)` unbinds, returns to Custom, fov 70, and places the camera 12 studs behind
  and 5 above the body: call it while the screen is black.
- `CameraRig.rumble(pos)` / `stopRumble()` give spectators only the shake with a distance falloff
  (full inside 40 studs, gone by 260) on top of their own camera. A summon uses only this.

## ScreenFx.lua - the screen layer

One ScreenGui (IgnoreGuiInset, DisplayOrder 60): a white flash Frame (ZIndex 1), a four-edge gradient
vignette (there is no radial gradient), an anamorphic flare ImageLabel (texture 867619398 at 2.4 x 0.16
of the screen plus a 3 x 0.035 line) pinned with `WorldToViewportPoint`, letterbox bars at 12 percent
each (ZIndex 5), a black fade Frame (ZIndex 9).
`fade(to, dur)`, `flash(strength, dur, color)`, `bars(on, dur)`, `vignette(strength, dur)`,
`flare(worldPos, color, strength, dur)`, `reset()`. None of this is used on the summon rung.

## ImpactFrames.lua - anime cutout frames

`ImpactFrames.play(targets, pattern)` with `pattern = {{"white", 0.05}, {"black", 0.05}, {"white", 0.05}}`
and styles white, black, blue (0, 225, 255 on navy 8, 10, 70) and red. The recipe that works:
1. A ScreenGui with an opaque `Frame` in the background colour (a `ViewportFrame` background renders
   gamma shifted; a plain Frame is exact).
2. A transparent `ViewportFrame` over it with its own Camera synced to `workspace.CurrentCamera`
   every RenderStepped.
3. Every visible BasePart of the targets cloned and stripped to its DataModelMesh with textures
   blanked, CFrame synced each frame. Light fills: Neon clone in the fill colour under white Ambient.
   Dark fills: white SmoothPlastic clone with `vp.Ambient = fill`, because a black Neon clone renders
   grey (60) and a black plastic clone under white Ambient renders grey (100).
4. On every colour step destroy and re-create the clones (recolouring a clone inside a viewport
   renders stale grey).
What failed: `Lighting.FogStart = 0, FogEnd = 0.001` painted geometry grey (60, 60, 60) in play under
dusk lighting and never covered the sky; six 600 stud slabs around the camera covered it but inherited
the same dim colour. `Highlight` draws a clean silhouette over fog but skips the transparent root part.

## SpeedLines.lua

The pack's radial ray texture at screen scale is one soft haze, not lines. Draw them: 36 tall thin
Frames, AnchorPoint centre, positioned at `centre + dir * (r0 + len / 2)` with `Rotation = angle`, a
UIGradient rotation 90 transparent at the inner end, re-rolled (angle jitter 9 degrees, length 0.3 to
0.58 of the height, 40 percent hidden) every third frame so they boil. `set(value, dur)`,
`pulse(value, dur)` (0.12 s in, then stop over `dur`), `stop(dur)`. Pulses on hits only.

## Helpers inside the effect modules (worth lifting)

- `groundBelow(originCF, character)`: raycast 30 studs down, keep the facing, so floor rings and
  cracks sit on the real floor. Rock plates probe their own floor each so a dais edge never leaves a
  slab poking out.
- `startFollows` / `follow(state, part, target, offset)`: a Heartbeat table that pins carriers to a
  body part while the clip moves it (gather behind the torso, the trail on the stand).
- `startSpinners` / `spin(state, part, w, extra)`: spinning parts compose their CFrame every frame on
  top of a tweened base.
- `bolt(p0, p1, color, width, life)`: six jittered attachments on Terrain joined by FaceCamera Beams;
  `arcs(...)` keeps throwing bolts around a moving centre for a duration.
- `afterimage(state, color, count, gap, life)`: Neon clones of the body at 0.5 transparency left along
  a swing, faded and destroyed.
- `flatShock`, `flatCrack`, `floorGlow`, `popStar`, `glowBurst`, `smokeRing`, `rockBurst`, `sparkBurst`,
  `shardBurst`: the one-shot vocabulary of the ultimate, each a carrier plus one `Emitters.make`.
- `remember` / `ghost` / `materialize` / `hide` in the summon: the stand's real Material, Color and
  transparency live in `Mat`/`Col`/`Tr` attributes set once, so a gold Neon ghost can be restored
  without a clone. `materialize` tweens transparency from 0.6 to the stored value over 0.22 s.
