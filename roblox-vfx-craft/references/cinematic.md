# Building a sequence: the schedule, the clip, the camera, the phases

## One schedule for everything

The effect module owns one table `T` of beat times in seconds from the cast. The clip speed changes,
every phase, every camera shot and every sound key off `T`, and `Tw.wait(T.b - T.a)` walks the
sequence in one coroutine. Spectators run the same `T` without the camera and with `CameraRig.rumble`.
The server only gates the cooldown and fires `Cast(player, originCFrame)` to all clients; every client
runs the full effect locally (`isLocal` decides camera, screen and humanoid lock).

State goes in one table made by `setup` and torn down by `cleanup(state, failed)` inside a `pcall`, so a
phase that throws still returns the camera, the lighting, the anchored root, the sound groups and the
effect models. Effects spawn into two workspace models, `FxHard` (things impact frames may silhouette)
and `FxSoft` (particles and glows that must not).

## Driving a published clip on wall-clock beats

`driveClip` plays the clip Looped (frame 0 equals the last frame, so a late freeze is safe) and changes
`AdjustSpeed` at `T` beats, never trusting the clip's own timing. A `ramp(track, dur, span, shape)`
helper integrates a shape curve so the clip lands exactly on a target frame at the end of a beat
(a P term `err * 6` corrects drift; without it the raise landed at 0.88 instead of 1.0). During a hold
the pose sways by 0.012 s of clip so the body breathes instead of freezing like a statue. Hit stops are
`AdjustSpeed(0)` for 0.14 s. The return decelerates on `1 - u^2` into the freeze.
For code-posed clips (the stand, DIO) the `roblox-r6-animation` skill's Poser holds a frame with a
zero-speed play instead.

## Camera language (the ultimate's cut list, which he liked)

1. Raise: push in over the hold (angle 82, dist 12.4, height 3.4, fov 58, roll 3) with the DoF racking to 12.
2. Quiet hold: hard cut to a low front hero shot (angle 178, dist 9.8, height 1.3, lookY 5, fov 48) that
   only creeps in (dist 8.6, height 1.0, roll 4). Two seconds of wind and a rising rumble, nothing else.
3. Charge: blade close up at the energy snap (angle 118, dist 7.8, fov 44).
4. Slash: an angle whip (angle 106, dist 8.6, roll -8) with no fov change and three pink afterimages.
5. Impact: the rig freezes for the cutout frames (white 0.06, black 0.05, white 0.05); when the hit stop
   releases, a hard cut wide (fov 66, dist 20 to 24, angle 104), kick 0.9, one 0.35 s speed line pulse,
   a red-then-cyan tint glitch over two frames, exposure +0.6, a cyan flare at the impact, DoF to 24.
6. Pillar: long lens (angle 150, dist 128 to 135, fov 54), tint cool (226, 232, 255).
7. Mid frame: low base shot (angle 250, height 3, lookY 70).
8. Freeze: tight on the frozen body (angle 206, dist 9.5, fov 40).
9. Collapse: wide (angle 262, dist 64); burst at 125 studs with roll +6, wave three at 150.
10. Aftermath, then fade to black 0.8 s, `CameraRig.cut` behind the body while black, fade in 0.5 s.

Rules: shots are Sine InOut on number values under an exponential follow, cuts snap, the floor shake
0.16 never stops, a FOV punch never pairs with a dolly the other way, the camera stays dead still
through cutout frames, and nothing ever pans back to the rig.

## World and post-processing (cinematic rung only)

- A `ColorCorrectionEffect` for the glitch (tint 255,140,140 then 140,215,255 over 0.05 s, back over 0.2)
  and the cool pillar tint; saturation, brightness and contrast return to 0 over 0.5 s at cleanup.
- `Lighting.ExposureCompensation` flashes: +0.6 hit, +0.4 pillar, +1.1 burst, 0.04 s up and the
  restore delayed 0.06 (through `Tw.play`, never `DelayTime`).
- World dim over the raise: Brightness 2.2 to 1.1, ambients down, Atmosphere density 0.42 to 0.55,
  returned in the aftermath.
- `DepthOfFieldEffect` racks: 13 body, 24 dome, 40 crown, 120 to 140 pillar, 70 collapse, 120 to 160
  burst, 100 to 60 aftermath. Under DoF plus particles at Level21 a 13.6 s run took 17 s, so offer a
  config toggle for DoF and the vignette.
- Bloom 0.55 intensity, size 32, threshold 1. Threshold 2 disables bloom entirely; check it first.
- Letterbox bars 12 percent, vignette 0.4, both in over 0.5 to 0.8 s at the start.

## The phases of the ultimate (what each one is made of)

- **Pre-wind**: blade emitters and a torso aura, pebbles lifting, two wind gusts (0 and 0.8 s), a
  Rumble bed rising to 0.3. The raise itself only moves air so the body reads clean.
- **Charge**: a sigil, orbit rings, a pull-in (inward emitters whose rates tween x2.2 over the hold),
  lightning bolts, two sparkle fields; Charge plays twice (0.85 speed, then 1.1 rising to 1.3).
- **Peak**: a pulse, a second pulse halfway through the 0.8 s hold.
- **Slash**: crescents and a Trail on the blade, afterimages.
- **Impact**: white/black/white frames, a screen flash 0.6 over 0.25 s, the raw Impact sound.
- **Dome**: at the blade tip, plates rise, crack, rocks, smoke rings, a sparkle burst; crown of five
  spiked meshes with blue frames.
- **Pillar**: 160 studs, 3 cylinders, sleeves, four camera-facing Beams, rings every 0.08 s, vertical
  rings, sparks, spark rain, floating rocks, ground wind, bolts, sky rings, a sparkle field, a mid frame;
  PillarLoop pitches 0.95 to 1.18.
- **Collapse**: an inward suck, the loop dives and muffles.
- **Burst**: wave 1 (frames, screen flash, a spear of light as a Beam, urchin, three shells, rings,
  crowns, 16 stars, sparkle burst, plates flung), wave 2 at +0.44 s (a sky star 70 studs up, a cracked
  sphere), wave 3 at +0.9 s (240 stud dome, 340 stud ripple, smoke mushroom, debris rain, six sparkle pops).
- **Aftermath**: a loop in, debris and smoke linger, the mix muffles and ducks to zero with the black.

## The phases of the summon (the small rung)

- **Setup**: find the parts, `groundBelow` for the floor, a `StandFx` model, follows, one mix group,
  `remember` the stand's materials, hold the appear clip at frame 0 (folded inside the body), hide,
  lock the humanoid (WalkSpeed 0, JumpPower 0, AutoRotate off) until 0.85 s, rumble for spectators.
- **Gather (0 to 0.25)**: inward stars and dots on a carrier pinned behind the torso, a violet back
  light rising to 1.2, an Ambience clip at 0.35.
- **Pop (0.25)**: kill the gather, ghost the stand gold Neon at 0.35 transparency, one Hit2, one floor
  Shock ring, two Lightning pops, seven sparkles, light spike 3 then 0.6, kick 0.22, SummonSound and StandSFX.
- **Rise (0.27)**: play the appear clip, materialise after 0.12 s over 0.22 s, a star trail on the
  torso at 26/s, a gold stand light to 1.6.
- **Settle (0.55)**: kill the trail, lights down, the idle aura (4 + 6 per second) welded to the stand
  torso and reused by name on the next summon.
- **Done (1.3)**: the hover clip fades in over 0.45 s; the camera offset slides to (-1.4, 0.2, 0) so the
  stand on the right shoulder never covers the body.
- **Dismiss**: the vanish clip, camera offset back, Desummon clip, six sparkles, parts fade to 1 over
  0.26 s after a 0.08 s wait, the rig stops at 0.36 s, the aura disables, lights destroyed.

## The phases of the road roller (the second cinematic piece)

One `T` table again (`Config.RoadRoller.Beats`), every phase a function into `state.fx`, `cleanup` at the end. The body is anchored and its root written every Heartbeat from `rootAt(t)`; the roller is one anchored MeshPart moved by `PivotTo` from `rollerCF(t)`. Only the caster runs the camera; every client runs the bodies, the roller and the effects, so the spectators see the same roller fall.

1. **Call (0 to 0.3)**: `DioRollerUp` from its LOAD crouch, the voice line, the bed and the wind-up start, a close rear take at dist 16, bars and vignette.
2. **Leap (0.3 to 1.8)**: a gold `Shock` ring at the feet, the jump sound, a `Wind` trail under the root pointing down, a 0.6 speed line pulse, a shot to dist 21 looking at the apex minus 2. The root rises 36 on a `quad` out over 1.3 s. The roller appears at 1.3 (transparency 0 plus its gold light) 75 up and falls.
3. **Catch (1.8 to 3.0)**: a small `Impact`, a cut to the sky looking down (angle 200, height 44) that falls with them to height 12 on a `quad` in; the root settles onto the roller top.
4. **Land (3.0)**: `BigCrack`, `RingShock`, rocks, tan smoke, an amber light, the land sound + `Bass` + `GroundSlamSFX`, a 0.15 freeze, impact frames with the roller, kick 1.0, speed lines 0.8, flash 0.6; the server blasts 45 in radius 14. 0.2 s later a cut to angle 40 dist 22 drifting to angle 110 over the rush.
5. **Rush (3.5 to 8.5)**: `DioPoint` on the body, the stand's raw barrage leaned into the deck, a fist flash and sparks every beat, a hit sound every six beats, a 0.09 kick per beat, arm echoes every 0.25 s, the roller sinking 1.25 with a 12 Hz jitter.
6. **Boom (8.5)**: the roller hidden, `BigExplosion` + `RealExplosion` + `PackExplosion` + shards + dark smoke, light 6 / 60, impact frames gold-red-white, kick 1.2, flash 0.7, speed lines 0.9; the server blasts 30 in radius 18. `DioRollerOff` leaps the body 14 back; a wide cut (dist 44, fov 66) drawing to 36.
7. **Off (9.3)**: the anchor and the freeze released, `DioMove` under the walk 0.5 s later, the laugh runs on the voice line.
8. **Fade (11.2 to 12.0)**: fade to black in 0.4, the default camera wakes behind the body, bars and vignette off, fade in 0.5. The server restores WalkSpeed and JumpPower at done; the client never touches them.

## The phases of the Asta sword ultimate (the third cinematic piece, 2026-09-23)

Copied shot by shot from a 6.4 s Black Clover clip he sent (studied as a contact sheet at 0.4 s, then 0.1 s, from a Node page that draws seeked frames into a canvas; its audio would not decode in the browser). Q starts a 6.6 s grow cutscene, he then holds the giant blade and turns to aim (70 degrees a second), Q again (or 15 s) brings the slam cutscene of 3.3 s. The clip events drive both the camera (caster only) and the effects (every client); the camera rig is `AstaCamera` (the skill's CameraRig ported), the screen is `AstaScreen` driving a saved ScreenGui tree, the effects are `AstaUltFx` over templates saved in `Assets.Ult`.

Grow (clip time = real time):
1. **Face 0.0**: close-up on the head (angle 180, dist 3.4 to 2.8, fov 38), bars and vignette 0.35 in, DoF focus 3.
2. **Under 0.18**: from under the fists looking up the blade (origin the hilt, dist 2.6, height -2.6, lookY 3 to 5, fov 80) so the fists, the crossguard and his face sit under the growing blade. Looking straight up the blade (height -1.4, lookY 9) lost the body and read as a monolith only.
3. **Front 0.34**: front pull-back (dist 11 to 17, height 0.2, lookY 2.4 to 4.2, fov 55). A higher lookY put his legs under the bottom bar.
4. **Burst 0.98**: impact frames `ink` (white figure on black, the clip's white flame shape) 0.06 then `white` 0.04 with the camera frozen 0.1, kick 0.5, a crack at the feet.
5. **Erupt 1.06**: low front wide (dist 30 to 26, height -1.2, lookY 6, roll 4), the eruption ring, the black wing, six black bolts round him.
6. **Far 1.6**: the obelisk from 320 to 300 studs (angle 202 to 194, height 10, lookY 150 to 200, fov 52); the arena walls stand in for the clip's tree line; long bolts snake along the blade every 0.1 to 0.18 s.
7. **Low 3.85**: low Dutch profile from his left (angle 255 to 242, dist 5 to 4.6, height -0.5, lookY 1.7, roll 12 to 9) with the burning grimoire, the black wing, light pillars and motes. From the front the raised arms hid the face; from the right his avatar's big cutout accessory filled the frame.
8. **Eye 5.3**: the right eye from 28 degrees off front (dist 1.3 to 1.05, fov 34) with a red eye glow; straight on, the hilt covered the face.
9. **White 5.95**, **done 6.3**: fade to white 0.2, hand the default camera back under the white, bars and vignette out, white out 0.5.

Slam:
1. **Wind 0.02**: side shot at the middle of the line (angle 90 to 96, dist 340 to 300, height 40 to 26, lookY 170 to 30 on a quad in so the frame falls with the tower), bars, bolts every 0.12 to 0.22 s, the blade aura doubled. The blade turns its edge toward the target in the wind-up so the side camera sees the full 25 stud flat as it falls; flat-leading it was a thin pole from the side.
2. **Fall 0.4**: the blade trail on (a Trail between Base and Tip attachments that follow the blade length).
3. **Impact 0.9**: freeze 0.16, kick 1, speed lines 0.8 for 0.45, impact frames white/ink/blood 0.05 each with the giant blade in the silhouette, then the line: every 24 studs a dust wall to each side (8 dust at 16 to 44 studs), 12 clods, 8 black flame bursts (18 to 36 studs, 40 to 70 up), 8 crimson fire, one white flash sprite, a crack every second point, a ring every third, a bolt every third, a red light every third. 0.16 s later a cut to a high three quarter over the middle of the line (angle 125 to 118, dist 95 to 110, height 55 to 62): the half buried edge-down blade is a low wall, so a ground camera beside it saw only the wall.
4. **Dissolve 1.85**: the blade shrinks to normal over 0.5 s inside a burst of its own black flames and embers; an aerial from behind looking down the whole line (origin 120 studs along, angle 8 to 2, dist 175 to 160, height 95 to 85).
5. **Back 2.4**: fade to black 0.3, default camera, fade in 0.45.

## The Frieren cutscenes (the fourth cinematic set, 2026-09-26)

`scripts/FrierenCinema.lua` holds three 13 to 15 s cutscenes (Zoltraak, Volley, Flowers) on one engine. Lepy's verdict on the first cut was "below average cinematic ... your BEST WORK possible, good enough to showcase and go on my portfolio", so the engine grew these pieces:

- **Timeline.** `timeline(warps)` owns the cutscene clock `tl.t`, advanced each RenderStepped by `dt / TimeScale * rate`. A warp `{t0, t1, rate}` is a speed ramp with smooth 25% ease in and out. Events go through `tl.at(t, fn)` and `tl.after(dt, fn)`; handlers must not yield (`frames` runs in `task.spawn`). `tl.drive(rig, clip, opts)` plays a Poser clip and keeps it on the clock with `setSpeed(rate + drift * 4)`. Every `ParticleEmitter` under the fx folder gets `TimeScale = rate / TimeScale`, so slow motion slows particles too. The VFX kit takes the clock and the queue (`kit.clock(fn, tl.after)`) and reads a continuous `now()`, so circles, flowers and petals follow holds and ramps. At the hand back the pending events go back to `task.delay` so late effects (the flowers) finish in real time.
- **Hold hook.** A `CineHold` number attribute on the Frieren folder freezes the whole cutscene at that time (rate 0: camera, bodies, particles, kit clock). Captures at exact beats come from it; clear it after tests.
- **Camera.** Shots `{t, len, a = {pos, look, fov, roll}, b = {...}, ease, drift, focus, depth}` in caster-local space; `pos` and `look` may be functions for tracking (the dragon's flat frame, its chest, its mouth). Each shot starts at its `a`, so a new shot is a hard cut. Shake noise runs on cutscene time. `DepthOfField` focus follows the look distance.
- **Screen.** Letterbox bars 10%, a `CanvasGroup` vignette of four gradient frames, a black `Fade` (every cutscene starts black and fades in over 0.8 to 0.9 s), a `White` flash, impact frames. The existing `Lighting.Grade` and `DepthOfField` are driven and restored (`stage`, `grade`, `unstage`).
- **Face the sun.** Each cutscene turns the caster to the sun direction first, so shots behind her look into the sunset and reverse shots light her face.

What the captures taught (all Play mode, QualityLevel 21, frozen with `CineHold`):

- **Tall grass.** The field grass stands about 3 studs. Every camera below caster-local y 0.5 (3.5 above the floor) filled the frame with blades; clamp tracking cameras above the grass and use a low camera only when the blades are a deliberate foreground. Props under 3 studs vanish: the flower spell now scales flowers by 2.6 so they rise above it.
- **An 80 stud wingspan.** A camera within about 40 studs of the dragon's side got a wing across the frame. Track from its flat (yaw-only) frame, never its banked CFrame (a 20 degree bank swung a 38 stud offset 13 studs up).
- **Stacked additive circles go white.** Three Zoltraak circles seen down the barrel axis summed into one white disc; 40 degrees off the axis they separate and the pattern reads.
- **Blown-out caster.** White robes under bloom went white from rising glow motes (50 a second round the body), a charge light of 3 to 6 near the body and a cup light of 4; 14 to 18 motes, lights of 1.2 to 2 fixed it.
- **Dust.** A blast `Smoke` burst in all directions hid the landing dragon; a ground-hugging radial `DustWave` (one emitter moved round a ring, emitting outward) reads as a landing. Dense dust at the caster's feet read as a boulder.
- **Wind direction.** A gale blowing straight at the lens reads as rain; film wind across the frame.
- **Close shots.** Cameras 2 studs from the caster ended inside the hair or the sleeves once the pose moved the head forward; measure the pose (`Head`, arms, the cup point) in the held frame and place the camera from those numbers.
- **Line of action.** Two consecutive profile shots from opposite sides crossed the line; keep the side.
- **A Beam samples its Transparency only at its segment points.** With `Segments = 1` a sequence like `{0, 1} {0.06, 0} {0.94, 0} {1, 0.7}` becomes a straight blend from 1 to 0.7: the Zoltraak beam drew at about 85% transparency (the "mid" grey slab he saw) and the light pillars (`{0, 1} ... {1, 1}`) never showed at all. Give every beam with inner transparency keypoints 10 to 12 segments.
- **Beam texture axes.** A Beam maps the image's vertical axis along its length (TextureLength) and the horizontal axis across its width. A strip texture that should run along the beam is tall: 256 wide by 512 high for a 1:2 width to length, with the band centred left to right. The first upload was wide and the white band crossed the beam.
- **The Zoltraak look (Sakugabooru 238377, 57.1 to 57.8 s).** A huge pure-white column with sawtooth teeth along both edges, a dark grainy rim with green and magenta speckles, a darkened world (exposure -0.85, saturation -0.3, contrast +0.18 during the beam) and, head-on, a white jagged disc with the same rim. `scripts/beam_texture.py` draws the matching body (white core, teeth, grain), core (the white only, additive, Brightness 1.6), glow and disc textures from one tooth outline; the body is alpha blended so the dark rim can darken the sky. Brightness 4 on the additive core bloomed over the teeth.
- **Single-sided membranes.** The dragon is one skinned `MeshPart` with `DoubleSided` off, so from below or in front the wing membranes were culled and the wings read as sticks (the roar display, the flight seen from the ground, the hover). `DoubleSided = true` on the asset (settable from the command bar or a plugin context) fixed every one of those views. Check it on any imported creature with thin wings, sails or capes.
- **A membrane reads only across the view.** A wing spread to the side is edge-on from the caster's camera. For a shot from the front, sweep the wings forward with the wrists high (the threat display, also used for the landing balance) so the membrane faces the lens.
- **Endings on a medium shot.** A head turn or a lowered staff does not read from 8 studs behind; each ending cuts to a medium shot on the face from the free-hand side, and the action starts 0.2 to 0.5 s after the cut.
- **Cost on his machine.** Field idle 40.8 ms median. Real-time runs: Zoltraak median 50.4 to 50.7 ms, p95 59.2 to 59.6, worst 71 to 123; Volley 50.5 / 60.2 / 78.8; Flowers 48.1 / 61.0 / 70.7. The first run of a session hitched up to 519 ms. After the calm rework and the double-sided dragon (first cast of a fresh session): Zoltraak 51.5 / 61.5 / 233.9, Volley 49.9 / 62.2 / 78.1; Flowers with 460 blooms 48.2 / 90.7 / 206.2 in a warm session, but its first cast in a fresh session froze one frame for 3.5 s (p95 173.8) until `FrierenClient` drew every template once at join (`warm`: `PreloadAsync` on the assets, one clone of each VFX template and the dragon 14 studs in front of the camera at 0.98 transparency, one emitted particle per emitter, lights off, three frames). After it the fresh first cast measured 49.1 / 90.7 / 326.3, and the 326 ms frame falls after the hand back.
- **Studio memory on his machine.** After a long session Studio held 4.9 GB of private memory with 480 MB free on the 6 GB machine; casts then froze 7 to 10 s (every script, core scripts too, hit the script timeout) while the same cast on a warm run hitched 0.3 to 0.8 s. The fix is a Studio restart after he saves; stopping Play and clearing test globals freed nothing.
- **Recording at TimeScale 4.** With the frame step capped at 0.1 s, a stalled frame loses cutscene time, so a take can run far past 4 times its length: one Zoltraak take needed 87 s instead of 66 s and a 72 s recording missed the release. Record 100 s for a 15 s cutscene and arm the cast within 5 s of the recorder start.

## Reference material he sent

- A DevForge Studio TikTok for the ultimate: white flash frame, red dome, spiked crown, pillar with
  rings, inverted frame.
- A Megumin Explosion still from KonoSuba for the colour field.
- For a stand summon he wants the identity of the stand, not the ultimate's field (see taste.md).
