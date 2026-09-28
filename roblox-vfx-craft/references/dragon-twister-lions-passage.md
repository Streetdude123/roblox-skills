# Dragon Twister and Lion's Passage (move rung, 2026-09-28)

The second and third moves of the "Three-Blade Swordsman" sheet for Lepy's client Moon, after Caliber Phoenix
(`caliber-phoenix.md`). Sources: `Desktop/roblox/Samurai` (FxTwister.lua, FxLion.lua, FxKit.lua, ServerTwister.lua,
ServerLion.lua, tools/BuildFx2.lua). Palette as Phoenix: core 232,255,246; mint 150,255,220; jade 30,235,185; teal
0,170,140; deep 0,62,60; dark 4,30,32.

His picks: keys "X and C"; Twister "Spin in place" (multi-hit, then an outward burst); Lion "Dash through" (30 studs,
the cut lands late with a cross flash and a lion image, then the knockback); a video "Yes, with sound".

## Dragon Twister (X, 2.48 s real)

| Beat | Clip | What shows |
| --- | --- | --- |
| Gather | 0.05 | Blade glow, inward wisps, the Twist sound. |
| Launch | 0.42 | The tornado grows in over 0.28 s. |
| Spin | 0.5 to 1.52 | 1440 degrees of root yaw (`K.monotone`), slash flashes every 0.075 s, a spectral dragon sweep, server ticks every 0.16 s. |
| Burst | 1.62 | The funnel parts expand 1.9x and fade, 8 crescent flashes radiate out, a ground ring, a full impact, a kick. |

- **Tornado.** A pack TornadoMesh (127665443435661) in ForceField jade, 17 studs tall, an inner Neon copy at 0.8, three
  jade Neon rings at 0.6 to 0.72, and a core carrier with wisps, streaks and debris. Spin each part with
  `c * CFrame.new(off) * CFrame.Angles(0, a, 0) * base.Rotation`: the yaw goes before the part's own rotation, or the
  rings tumble about their tilted axis.
- **Slash flashes on the far side only.** A small crescent at 3 to 5.5 studs from the body, scale 0.7 to 1.1, spawned on
  the half away from the local camera. Near-side flashes covered the whole player view.
- **The dragon is a sweep, not an orbit.** A ForceField mint dragon with Neon jade cores at 0.72 (height 23). Inside the
  funnel it was invisible; orbiting outside it filled the frame. It now sweeps over the far side once:
  `a = camAngle + pi - 1.65 + 3.3u`, radius 11 - 1.5u, height 1.5 + 9u, fading in and out. ForceField alone never
  reads on a bright sky; the Neon core does.
- **Toned down.** White wisps and white rings read as mess; everything off-white became mint or jade.

## Lion's Passage (C, 1.78 s real)

| Beat | Clip | What shows |
| --- | --- | --- |
| Gather | 0.02 | A pull carrier welded to the root: inward streaks 110/s and motes 40/s, a light to 1.2, blade glow. |
| Dash | 0.42 to 0.5 | 30 studs in about 0.1 s; a thin jade dash line at knee height, a ground ring at the start, ForceField ghosts every 6 studs, trails, kick 0.3. |
| Arrive | 0.5 | Dust at the stop. |
| Click | 0.97 (1.2 s real) | Shing 0.08 s early; per hit a cross flash, a lion head and an impact; then Roar; the server damages and launches. |

- **Dash line.** Core, Glow and Streak beams, thin and jade, from the start to the stop at root height -1.6, plus a Wind
  emitter. A wide white beam read as a bar.
- **Ghosts.** Clone only the Parts as ForceField mint (0.1 to 1 over 0.3 s), one per 6 studs. Neon ghosts read as white
  blocks.
- **Cross and lion scale with the camera distance** (`near = clamp(d / 18, 0.25, 1)`). The lion head sits behind the
  target on the camera ray (+3.5 studs, +3 up) and never closer than 17 studs to the camera: push it along the ray, so it
  keeps its screen position. A small impact variant under near 0.6.
- **Lion model.** A free lion head mesh in ForceField mint with a Neon jade core at 0.6 (SpecialMesh scale 0.96). Keep
  only parts with a FileMesh; the pack's sphere part drew a solid block in the mouth.
- **Knockback away from the lens.** The target launches to its side of the dash line and a little back
  (`(side * 0.9 - dir * 0.45) * 30 + up 48`). Sent straight back, it flew into the player camera's line.

## Traps found

- **Poppercam.** The default camera zooms in front of any CanCollide part with transparency under 0.25 between the
  camera and the subject. A launched target crossing that line pulled the camera from 12.8 to 5.2 studs from the head for
  300 ms. The server sets the caster's `Player.DevCameraOcclusionMode` to Invisicam from the cast start to 1.2 s after
  the click, then restores it. Set it at the cast start: a switch that lands during the dash showed one frame with the
  camera left at the start. A LocalScript and the MCP client VM cannot set this property; the server can.
- **Effect parts must not collide.** Check CanCollide, CanQuery and CanTouch on every template part before blaming the
  camera.
- **Other clients see the spin and the dash through replication.** The owner's client drives the root in PreRender
  (spin yaw, dash lerp with an ease-out), the server uses the same clip times for hits.

## Checks (2026-09-28)

- Twister clip: frozen 0, still 2.1%, rest 67.4% (the spin is root motion, so the joints rest while the body turns),
  contrast 18.8, unison 2.13/s. First cast worst frame 25.6 ms.
- Lion clip: frozen 0, still 2.1%, rest 55.1%, contrast 10.0, unison 1.94/s. First casts: 19.7, 21.8 and 31.1 ms worst
  frame on a 17.1 ms idle; one earlier run had a 394 ms frame after the click that did not come back.
- Player view: the camera stays 12.6 studs from the head through the click. Console clean on client and server.
- Video: 16.8 s, six shots, AAC peaks at 0.88.

## Particle pass (2026-09-28, third pass)

His note: the lion mesh "ruins" the move; every effect more particle heavy, the tornado most; flashier from now on.

- **Lion spirit sprite.** Source: a public-domain (OpenClipart, freesvg.org) front roaring lion badge, rendered to 1024 px in the
  browser. `scripts/paint/lion.py`: drop the round badge ring by the mean radius of each ink component (over 0.41 x size), treat all
  pixels the outside cannot reach as the lion (the white muzzle and fangs stay), then map value to colour: white features to the core
  (232,255,246) at alpha 1, face fur to jade-mint at 0.5 to 0.85, mane to teal at 0.16 to 0.36, edges plus 0.75 alpha toward the
  core, a jade halo at 0.35 and a 28-step outward zoom blur. Uploaded as 129170861176068.
- **LionRoar template** (one carrier, 13 x 13 x 0.5, facing the camera, at least 17 studs from it): Face (the sprite, Size 8 to 16,
  LightEmission 0.3, Brightness 2, emit 2 stacked), Echo (mint, 12 to 22, at 0.1 and 0.34 s), then at 0.34 s the break-up: 170 spark
  shards, 40 claw flakes, 90 rising embers, 26 wisps. At 17 studs, Size 14 draws a face about 60% of the view; Size 5.6 drew only 25%.
  With LightEmission 0.55 the face washed out on the bright sky; 0.3 keeps the jade. A mint flare 14 to 22 and a white spiky shock hid
  the first quarter second of the face; the flare is now jade 6 to 10 at 0.55 and the shock cool at 0.4.
- **Storm (particle tornado).** Four carrier layers (diameter 5, 8, 11.5, 15; heights 3 to 4.5; y 1.5 to 13) spun in RenderStepped
  at 12.5 to 20 rad/s, alternating direction. Every emitter is `LockedToPart` with a Cylinder Surface shape, so turning the carrier
  turns its particles: a spinning funnel with no per-particle code. Per layer: claw/hook curls (Rate 40 to 58, cool colours at 0.35),
  thin swooshes, rising spark streaks (70), motes (36); glow on the middle layers, outward dust at the bottom. Rates live in a `Rate`
  attribute and `FxKit.rated(model, k)` scales them for the grow-in. First pass used white-hot curls at 1.4x the rate: from the
  player camera the funnel was a white-out that hid the body; jade curls, 35% fewer, smaller, kept it dense and readable.
- **StormBurst**: claws 70, wing slashes 18, streaks 200 at 60 to 110 studs/s, swooshes 60, motes 150, a spiky ring, a floor ring and
  44 dust, all from a Cylinder Surface with ShapeInOut Outward (radial for free).
- **Dash trail**: a Box carrier stretched along the dash, streaks 220 along it (EmissionDirection Front, VelocityParallel), 60
  swooshes, 130 motes, 30 dust.
- **Phoenix**: a WingBurst when the wings open in the air (feathers 24 + 18, claws 12, sparks 90, a flat thin ring) and a smaller one
  at the apex, a Landing burst at the release (ring, dust 44, sparks 120), the crescent at streaks 200 and cuts 120. The first pass
  (feathers 40 + 30 per burst and 40/s on the crescent, white claws 4.5 studs) covered the whole player view for 0.4 s.
- **First casts after the pass** (no recorder, idle 16.6 ms): Phoenix worst 26.2 ms, Twister 29.1 ms, Lion 21.8 ms, none over 34 ms.

### Recording traps on the 6 GB machine

- Overlapping recorder sets (the previous take's audio still running) gave idle frames of 234 ms and an 819 ms stall; wait for
  `audio.wav` of the last take before the next one.
- MCP tool calls took up to 20 s under load, so a 10 to 16 s window missed the cast; use a 30 s window and cast after "live".
- Frozen stretches in a take (identical images while the timestamps advance) mean Studio stopped drawing; retake, do not encode.
- Fade the audio (0.05 s in, 0.35 s out) in the encoder: a long roar cut at the last frame clicks.
