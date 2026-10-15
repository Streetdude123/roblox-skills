# Impacts and camera shake

This file covers the hit moment: how an explosion's layers are timed, hit stop, camera shake, a directional camera punch, shaking the Roblox camera without taking it over, crater rings, and the limits on screen flashes. The sources are explosion breakdowns and critiques, fighting-game designers, engine examples and the Roblox docs. Every finding was read from its source and re-checked by an independent reader on 2026-10-11. Each rule is restated with the instance, property or number it implies. Where a source disagrees with his taste or a SKILL.md rule, his rule wins and the file says so. Sources are at the end.

## 1. Start the layers 2 to 3 frames apart (Atif, Real Time VFX)

Atif's breakdown of a stylized explosion has 18 layers and a 0.5 s life. He groups the layers into six: shockwave, smoke, instant flash, burst core, burst ring and sparks. The shockwave fires first and also lights the background behind the coming flash. The instant flash lasts only 2 to 3 frames. The layers start only 2 to 3 frames apart, and he calls that offset critical to the feel. The burst core is fast particles with heavy drag. They slow almost to a halt and fade out before they fully stop. The sparks spawn on the same frame as the core, in two types: one with trails and one with stretched particles. They die slightly after the burst ring dies.

Roblox translation:
- Stagger the emits inside the skill's one-or-two-frame overload (principles.md section 6). Do not fire every layer on the same frame.
- Frame 0: the ring or shock (`Kit.burst("RingShock", ...)`, or an emitter with the `shock` texture). About 0.033 s later (2 frames at 60 fps, through `task.delay`): the white instant flash, with a Lifetime of 0.033 to 0.05 s. That fits his rule that white appears only in a flash under 0.1 s. The core and the sparks fire on the flash's frame.
- The soft glow that fades over 6 to 15 frames (principles.md) stays a separate, slower layer.
- On the move rung, keep the whole hit near 0.5 s.
- Core emitter: a high Speed and a high Drag, with a Transparency sequence that reaches 1 before the speed reaches 0. The gas never visibly stops.
- Tie the spark life to the ring. The maximum spark Lifetime is the ring's life plus 2 to 4 frames: a 0.5 s ring gets sparks at 0.35 to 0.56 s. That stays inside the skill's sparks (0.3 to 0.6 s) and rings (0.4 to 0.8 s).
- Use two spark layers: a stretched one (`Squash` with `Orientation = VelocityParallel`, as in principles.md section 5) and a trailed one (a short Trail or beam streak).

## 2. Time the hit to the contact and to real footage (aarku, ryangatts, Jamie_Clark, smou, Travis, Sirhaian, Doggett)

aarku's method: study real explosion footage frame by frame and note the timing of each main element, taking the frame rate into account. The elements he commonly uses are a flash, a shockwave, embers (some with smoke trails), debris (some with trails), a fireball, lingering smoke, and the moment the object disappears. Check the relative speeds against the footage, for example whether the shockwave outruns the smoke and debris or the whole thing is one expanding wave. For the vehicle explosion he reviewed: the smoke should not outpace the shockwave. Switch to the destroyed mesh when the flash is brightest, not right away. Make the smoke last much longer, at least about 5 s, and much longer off mobile, where fill rate is less of an issue.

ryangatts: flash elements must not move. They stand for light shafts and lens flare and stay at the explosion's centre. A second shockwave aligned to the ground gives the expanding gas volume and roundness. Sparks look best grouped into jets or spears launched in similar directions, not spread evenly. Jamie_Clark: give the sparks more gravity or a lower lifetime for more punch, and make the flash go away faster, because it "hangs out too long".

On a stylized lightning strike, smou saw the impact shockwave land slightly before the actual impact and asked for a delay of about 0.1 to 0.15 s. He also said a blank frame adds dynamic and a bit more punch. Travis: the emitter ran close to 1.9 s; cut it to about 0.75 s. Sirhaian: shorten the impact burst to just a few frames. Doggett: the bolt needs a big flash or glow, and the impact shockwave should expand and fade faster.

Roblox translation:
- Fire the ring, the flash and the kick on the contact frame: the clip's hit event or the hitbox confirm. Never fire them on the cast or the swing start. A ring that leads the contact by 0.1 s weakens the hit.
- Make the ring's growth (its Size tween or Speed) the fastest thing in the burst. Keep smoke Speed well under the ring's expansion rate. Whether the ring also outruns the debris is a check against the reference, not a rule.
- Put every state change on the flash's peak frame: hiding the road roller, breaking a part, showing the crack, ghosting a body. The flash hides the pop.
- Anchor the flash carrier at the contact point (`Emitters.carrier`). Never weld it to a fist or a blade that keeps moving.
- On anything bigger than a light hit, pair the camera-facing ring with a flat floor ring: the ultimate's `groundBelow` and `flatShock` helpers (modules.md).
- Build directional sparks from 2 or 3 narrow-cone emits instead of one even sphere: a small SpreadAngle around chosen axes, such as the hit direction and its glancing reflection. For more punch, raise the downward Acceleration or shorten Lifetime. Do not add particles.
- For bolt pops (the ultimate's `bolt` helper, the kit's `Lightning` pops), try a one-frame gap in the bolt. smou does not say where the blank frame goes. Test it just before the main strike first.
- Gameplay hits on the move rung finish in about 0.75 s or less. That matches the Riot "too long" rule in principles.md. The cinematic rung is exempt by his request.
- Smoke: 5 s fits the cinematic aftermath and the 2 to 5 s permanence window. On the move rung smoke stays at 0.8 to 1.5 s (principles.md). His move-rung limits win over aarku's minimum.

## 3. Hit stop: scale it with damage, cap it, and shake the victim (Sakurai, Dustloop)

Sakurai's rules for hitstop: attacker and victim freeze for exactly the same time. More damage means a longer freeze, but there is a cap that no attack exceeds. Projectiles get comparatively less hitstop, and electric attacks get more. He keeps it short because a frozen pair gives a third player a chance to strike.

During hitstop the victim vibrates instead of only freezing, which simulates shock. The attacker vibrates slightly too. Grounded characters vibrate side to side and airborne ones up and down, so feet never clip into the floor. Hurtboxes stay where they are; only the visual moves. The vibration scales with the camera distance, is strongest at the start of the freeze and then shrinks. A 4-frame blend takes the victim from the flinch to the hurt animation.

Granblue Fantasy Versus Rising (Arc System Works) sets hitstop from a per-attack level table: 10, 10, 12, 14 and 16 frames for levels 0 to 4. A counter hit adds 2, 2, 4, 8 or 12 more frames, and that extra applies only to the opponent.

Roblox translation:
- Derive the stop from damage with a clamp instead of hand-picking it per move, for example `stop = math.clamp(0.04 + damage * k, 0.05, 0.18)`. That keeps his measured range: 0.05 to 0.09 s on moves and 0.12 to 0.18 s on finishers (SKILL.md).
- Both bodies already freeze for the same time: `rig:hold` runs on the attacker and the victim in `Moves.lua`. Ranged hits (water spears, thrown pieces) take the low end. An electric hit may sit higher.
- The cap matters in his multiplayer arenas. A body frozen longer than about 0.18 s is open to other players.
- Victim vibration (the skill has none today): while `rig:hold` holds the victim, offset only the visual. Write a decaying jitter into the root joint's Transform or C0 each RenderStep. Use the camera's right vector when the victim is grounded and world up when it is airborne. Start at full amplitude, shrink to 0 by the end of the stop, and scale the amplitude with the camera distance. Leave the HumanoidRootPart (the hitbox) in place.
- Give the attacker a small share of the victim's amplitude. About a third is a value to test; the source says only "slightly".
- Blend the victim into the hurt clip over 4 frames, about 0.067 s of fade time.
- At 60 fps the GBVSR table is 0.17 to 0.27 s, longer than his moves. His values win, because he tuned them on his own combos.
- What carries over from GBVSR is the structure. Give each move a level in Config (light, heavy, finisher) that sets the stop, the kick and the burst scale together. Add an extra freeze on the victim only for a counter, a parry or a guard break. For example, a parry victim holds 0.15 s while the attacker is released at 0.08 s, so the punish window reads.

## 4. Shake is trauma squared on smooth noise (Bevy after Eiserloh, KidsCanCode, aarku)

Bevy's official camera-shake example follows Squirrel Eiserloh's GDC 2016 talk "Juicing Your Cameras With Math". Trauma runs from 0 to 1 and decays at 0.5 per second, so full trauma is gone in 2 s. Shake is trauma squared, because a linear ramp does not feel punchy. The maximum angle is 10 degrees, the maximum translation 20 px, and the noise speed 20 ("fairly fast"); lower speeds give a "more dreamy" shake. Each event adds 0.4 trauma. Three noise channels are offset by 0, 100 and 200. The transform is restored each frame, so gameplay logic never sees the shake.

The KidsCanCode Godot recipe uses the same trauma model. It decays trauma at 0.8 per second and recommends a power of 2 or 3: "a square or cube relationship is typically the best". It caps roll at 0.1 rad with the note "use sparingly". It uses gradient noise (2 octaves, period 4) instead of random numbers, because random values swing wildly from frame to frame and feel erratic. Its warning: "When misused, players hate it."

aarku adds that the screen shake of a big explosion feels better when it is delayed by distance, as if it travels with the shockwave.

Roblox translation:
- `CameraRig` already uses this model: `math.noise` on three axes and three rotations, separate channels, scaled by trauma squared. The differences are tuning, and his values stay. His decay is 1.5 per second (a 1.0 kick is gone in 0.67 s), his noise rate is 13 (a heavier rumble than 20), and his rotation is 0.05 rad, about 3 degrees, far under 10.
- The decay is fixed at 1.5 inside `decay(dt)`. To vary the feel by tier, make it a parameter: keep 1.5 per second on moves and use about 0.5 to 0.8 only for cinematic waves, where the shake should hang on.
- For combos, an exponent of 3 separates the hits more. An M1 kick of 0.2 gives 0.04 shake squared but 0.008 cubed, while a finisher at 0.8 keeps 0.51. Light hits barely move the camera and the finisher still slams, which suits his "too much feels messy" rule.
- Keep roll at 0.1 rad or less on gameplay shake. The roll in his cinematic shots (cinematic.md) is a shot choice, not part of the shake.
- `CameraRig.rumble(pos)` scales the shake by distance (full inside 40 studs, gone by 260) but starts it at the same moment for every spectator. Also delay each spectator's kick by distance divided by the ring's speed. For example, a ring whose edge moves out at 165 studs/s reaches a viewer 100 studs away about 0.6 s late. Use this on cinematic waves and big slams, not on light moves.

## 5. A directional punch is a damped spring (Valve, Source SDK 2013)

In Source SDK 2013, `DecayPunchAngle` in gamemovement.cpp models the view punch as a damped spring. Each tick the angle advances by velocity times frametime. The velocity is multiplied by `max(0, 1 - 9 * frametime)`, and a spring force of `65 * frametime` (clamped 0 to 2) times the angle is subtracted from it. The code comment says the system currently overshoots and would not with larger damping. Angle and velocity reset to zero once both squared lengths are 0.001 or less. `ViewPunch` in baseplayer_shared.cpp adds the punch as velocity: `m_vecPunchAngleVel += angleOffset * 20`.

Roblox translation:
- `CameraRig.kick` adds noise trauma, which shakes in no particular direction. The "kick the camera in the direction of the action" from principles.md section 8 needs a second piece beside it. `CameraRig` has no directional punch today.
- The spring, per hit: `vel += impulse * 20` once. Per frame: `angle += vel * dt`, `vel *= math.max(0, 1 - 9 * dt)`, `vel -= angle * math.clamp(65 * dt, 0, 2)`. Compose `CFrame.Angles` of the angle after the shake. Zero both when their squared lengths fall to 0.001.
- What the constants give (arithmetic, not from the source): a natural frequency of about 8 rad/s and a damping ratio of 0.56. The peak is about 1.3x the passed angle at about 0.15 s, with one small overshoot, settled by about 0.9 s.
- Uses: pitch down 1 to 2 degrees on a slam landing, yaw away from the struck side on a side hit. Add it to his trauma kick; it does not replace the kick.
- On the move and summon rungs the punch rides the same CFrame multiply as the shake (section 6).

## 6. Shake the Roblox camera without taking it (creator-docs, EZ Camera Shake thread)

The default camera scripts also set `Camera.CFrame`. To move the camera, either set `CameraType` to Scriptable so the default scripts stop updating the CFrame (the simplest way, recommended in most cases), or replace the default camera scripts completely (recommended only when no default camera behaviour is needed). `Enum.RenderPriority.Camera` has the value 200.

`Camera.Focus` tells the engine which area of 3D space to prioritise for work such as lighting. Dynamic lighting from PointLights may not render far from the focus. Focus does not update by itself while `CameraType` is Scriptable, so set it every frame with `BindToRenderStep` at the Camera priority.

In the community port of EZ Camera Shake, the original example applies the shake as `camera.CFrame = camera.CFrame * shakeCf` at the Camera priority. Later users bound it at `Camera.Value + 1` and found that the shake built up additively: the camera stopped in a different place from where it started. The fix that worked binds a step at `RenderPriority.First` and restores the previous frame's unshaken CFrame before the camera scripts run. The module's author said a Heartbeat reset also works. A related bug made the shake frame-rate dependent: it called `Update(60)` instead of `Update(dt)`.

`Humanoid.CameraOffset` is applied to the camera subject's position when the camera's `CameraSubject` is that Humanoid. It is in object space, relative to the HumanoidRootPart's orientation: (0, 10, 0) puts the camera 10 studs above. The Camera docs say the default camera scripts factor `CameraOffset` in.

Roblox translation:
- Cinematic rung: `CameraRig.take` goes Scriptable and owns the camera, as it already does.
- Move and summon rungs: his rule is that the camera stays his, kicks only. Never go Scriptable there. Apply the shake after the default scripts, at `Enum.RenderPriority.Camera.Value + 1` (201), as a multiply on their output (`cam.CFrame * shakeCF`). Never overwrite it with a CFrame built from the root, or the player loses zoom and pan.
- `CameraRig.rumble` does exactly that multiply at Camera + 1 with no undo: the pattern reported to drift on a default camera. Store the unshaken CFrame before multiplying. Bind a second step at `Enum.RenderPriority.First.Value` that puts it back while a rumble or kick runs on the player's own camera. Unbind both at the end.
- Drive decay and noise time from dt or the clock, never a fixed step. `CameraRig` already decays through `decay(dt)` and samples noise from `os.clock()`.
- For translation-only rumble on the move and summon rungs, write `hum.CameraOffset = base + noiseOffset * s` each RenderStep. The default camera composes it with zoom and pan, so it cannot drift. It carries no rotation, so roll and pitch still go through the CFrame multiply.
- The summon tweens `CameraOffset` to (-1.4, 0.2, 0) for the stand (`SummonVfx.lua`). Add the shake to that base, never overwrite it, and restore exactly the base at the end.
- `CameraRig.lua` never sets `cam.Focus`. In its RenderStep, set `cam.Focus = CFrame.new(lookPoint)`, where `lookPoint` is the shot's look-at point (the impact, the pillar base), not the camera position. The impact PointLights in the ultimate's wide shots keep rendering only if the focus sits at the effect. Check this in a capture before blaming a light's Range.

## 7. Crater rings from a raycast, rocks from a pool (DevForum)

A DevForum answer by RobloxSessionId builds a crater ring. Raycast 25 studs down from just above the centre and return early if nothing is hit. Place N rocks (8 in the example): rotate the centre by `2 * pi * (i / N)` about Y and step out along the rotated LookVector by an offset (4.5). Give each rock a random rotation from -pi to pi on all three axes. Copy Material and Color from the hit instance. The rocks are 3-stud cubes.

Flipitagainpls' open-source RockModule (Nov 2023), in its example, places 15 rocks on a radius-8 circle (angle step `2 * pi / Amount`) at size 3.5. Each rock tweens from size 0 to full over 0.5 s. After `Time` seconds (default 3, 5 in the example) it tweens back to 0 over 0.5 s and returns to a PartCache of 100 parts. The despawn delay starts at the same time as the grow tween. CanCollide is false. An Amount of 100 or more is reset to 15, so PartCache does not create too many parts. `Generate()` errors on the server: "PLEASE CALL ROCK MODULE ON CLIENT EX: FIREALLCLIENTS".

Roblox translation:
- The slam already takes the floor colour through `GetMaterialColor` (SKILL.md). On Terrain, `cast.Instance` is the Terrain itself, so read `RaycastResult.Material` and pass it to `Terrain:GetMaterialColor`. That call throws on Air and Water, so guard both.
- His rules win on the shape. The source's cubes with full random spin read as blocks (SKILL.md: flat slabs 0.35 to 0.55 of the width read as broken floor). For a rim, tilt each piece outward from the centre with a small random spin, and vary the sizes and the gaps (taste.md: a crack ring is uneven).
- Leave the rear arc (60 degrees) toward the player's camera open (SKILL.md slam trap).
- Craters belong to the every-client path the skill already uses: the server fires the cast and each client builds.
- Pool the rocks. A combo with cracks on every heavy hit otherwise creates and destroys dozens of parts per second. Warm the pool at join with the other first-draw meshes.
- A 0.5 s grow from 0 is too slow for a slam's contact frame. Pop the rim to about 70 percent size on the hit frame and ease out to full over 0.1 to 0.2 s, so the rocks are already there under the flash (section 2). Hold 2 to 5 s for permanence, then sink and shrink over 0.5 s.

## 8. Limit full-screen flashes and honour Reduce Motion (Xbox Accessibility Guidelines, creator-docs)

Xbox Accessibility Guideline 118 (photosensitivity) defines a flash as a 10 percent change in luminance, with the darker state below 0.8. Flashing fails when it happens more than about three times per second over about 20 percent or more of the screen. A saturated red flash, where R / (R + G + B) is at least 0.8, fails at a lower luminance change. The fixes are to reduce the contrast, the frequency or the size, and to desaturate the red. Guideline 117 says to avoid camera shake, camera bobbing and motion blur, or to provide an option to turn them off.

`GuiService.ReducedMotionEnabled` (ReadOnly, NotReplicated, Hidden, read security None) is true when the player has asked for motion effects and animations to be reduced or completely removed. It maps to the Reduce Motion toggle in the Roblox and in-experience Settings menus.

Roblox translation:
- A white-black-white impact frame set is a full-screen series of luminance flips in 0.15 s: about two flashes. His impact frames on finishers and cinematics stay. Allow no more than one full-screen set (`ImpactFrames.play` or `ScreenFx.flash`) in any one-second window.
- On a rush, keep the per-beat fist flashes as world sprites well under a fifth of the screen. Never fire a `ScreenFx.flash` per beat.
- Red sets: Asta's 200, 22, 30 gives 200 / 252 = 0.79, just under the line. Pure 255, 0, 0 crosses it. Keep the red frames at that blood red.
- Read `GuiService.ReducedMotionEnabled` in `CameraRig` and `SpeedLines`, which run on the client. Add one per-player shake scale (0 to 1) in Config; none exists yet.
- When reduced motion is on: trauma times 0.25, the 0.16 floor trauma off, the directional punch halved, speed-line pulses off, and cinematic shots cut instead of tweened. Hit stop, bursts and sound stay, because they carry the weight without camera motion.
- The default path, the one he tunes, does not change. His kicks and rumble stay as he set them.

## Where the sources and his taste disagree

- aarku: smoke for at least 5 s. On the move rung smoke stays at 0.8 to 1.5 s; 5 s belongs to the cinematic aftermath.
- GBVSR: 10 to 16 frames of hitstop (0.17 to 0.27 s). His 0.05 to 0.09 s on moves and 0.12 to 0.18 s on finishers stay.
- Bevy: decay 0.5 per second, 10 degrees, noise speed 20. His decay of 1.5, 0.05 rad and rate 13 stay.
- Travis: cut the strike to about 0.75 s. This holds for gameplay; the cinematic rung runs longer because he asked for "WAY more dramatic and longer".
- XAG 117: avoid camera shake. His kicks and rumble stay on the default path. Reduce Motion is the opt-out the guideline asks for.
- XAG 118: his impact frames stay, limited to one full-screen set per second.
- The DevForum crater cubes with full random spin: his uneven, outward-tilted rim and the open rear arc win.

## Not covered

- Eiserloh's own slides or transcript for "Juicing Your Cameras With Math" (GDC 2016). The GDC Vault page lists no slides, mathforgameprogrammers.com shows only an "under construction" page, and web.archive.org could not be fetched. The model here comes from Bevy's example, which credits the talk. Eiserloh-specific claims, such as rotation-only shake in 3D, are unverified and left out.
- A FOV punch on impact (a value and a duration for a brief FOV change). No primary or studio source was found, only an unvetted blog. cinematic.md's rule (never pair a FOV punch with a dolly the other way) stays the only guidance.
- Ground crack decals and directional sparks aligned to the hit normal. No fetched source gave a method or numbers beyond "group sparks into jets" (section 2).
- Fighting-game hitstop tables for KOF XIII (the SRK wiki is behind bot protection) and Killer Instinct (Infil's "The Basics" has no hitstop section).
- The crater creation module (DevForum 2196023). The post gives setting names (fadeInTime, fadeOutTime, timeBeforeRemoval, forceNumberDebris) but no algorithm or default values.
- The Real Time VFX thread on experienced artists who excel at timing. It is qualitative only (a "breath" between the main blast and the secondaries), with no frame counts.
- EZ Camera Shake preset values (Bump, Explosion, Earthquake magnitude, roughness, fade). They are not in the original post.
- Atif's per-layer frame timeline. It exists only as a screenshot; only the flash (2 to 3 frames), the 2 to 3 frame offsets and the 0.5 s life are in text.

## Sources

- Atif, "Stylized Frag Launcher Explosion (Overwatch inspiration) - breakdown", Real Time VFX (2017), https://realtimevfx.com/t/stylized-frag-launcher-explosion-overwatch-inspiration-breakdown-posted/1894?page=2 - the six layer groups, the 2 to 3 frame flash and offsets, the drag core, the spark timing (section 1).
- "Explosion effect help needed", Real Time VFX, replies by aarku, ryangatts and Jamie_Clark, https://realtimevfx.com/t/explosion-effect-help-needed/16021 - studying footage, smoke against shockwave, the swap on the flash peak, 5 s smoke, fixed flashes, the ground shockwave, spark jets, shake delayed by distance (sections 2 and 4).
- "Lightning Strike! (stylized) what do you guys think? (Update)", Real Time VFX, feedback by smou, Travis, Sirhaian and Doggett, https://realtimevfx.com/t/lightning-strike-stylized-what-do-you-guys-think-update/1972 - the delayed shockwave, the blank frame, 1.9 s cut to 0.75 s, a few-frame impact burst (section 2).
- "Thoughts on Hitstop", Sakurai's Famitsu column vol. 490, Source Gaming translation (2015), https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/ - equal freeze, damage scaling with a cap, projectile and electric hitstop, victim vibration, the 4-frame blend (section 3).
- Dustloop wiki, "Frame Data Glossary - GBVSR", https://dustloop.com/w/Template:FrameDataGlossary-GBVSR - the attack level hitstop table and the counter-hit addition (section 3).
- Bevy examples, "2D Screen Shake" (follows Squirrel Eiserloh, GDC 2016), https://bevy.org/examples/camera/2d-screen-shake/ - the trauma model and its constants (section 4).
- KidsCanCode, "Screen Shake", Godot Recipes, https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/ - decay 0.8, power 2 or 3, roll 0.1 rad, gradient noise (section 4).
- Valve, Source SDK 2013, gamemovement.cpp (`DecayPunchAngle`) and baseplayer_shared.cpp (`ViewPunch`), https://github.com/ValveSoftware/source-sdk-2013/blob/master/src/game/shared/gamemovement.cpp - the damped spring punch (section 5).
- Roblox creator-docs, Camera.yaml (CFrame, CameraType, Focus, CameraSubject) and enums/RenderPriority.yaml, https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Camera.yaml - Scriptable versus default scripts, the Camera priority, Focus and lighting (section 6).
- sleitnick, "EZ Camera Shake ported to Roblox", Roblox DevForum, replies by DaDude_89, batin1597, sleitnick and Mashiusam, https://devforum.roblox.com/t/ez-camera-shake-ported-to-roblox/98482?page=8 - the additive drift at Camera + 1, the restore at First, the dt bug (section 6).
- Roblox creator-docs, Humanoid.yaml (CameraOffset), https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Humanoid.yaml - the object-space camera offset (section 6).
- RobloxSessionId (wav), "How to create a crater?", Roblox DevForum (2023), https://devforum.roblox.com/t/2538543 - the raycast crater ring (section 7).
- Flipitagainpls, "New rock effect module", Roblox DevForum (2023), https://devforum.roblox.com/t/new-rock-effect-module/2706114 - the rock ring, the grow and despawn tweens, the PartCache pool, client only (section 7).
- Microsoft, Xbox Accessibility Guideline 118 (photosensitivity), https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/118 - the flash definition and limits, the red flash rule (section 8).
- Roblox creator-docs, GuiService.yaml (ReducedMotionEnabled), https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/GuiService.yaml, with the linked production/publishing/accessibility.md and Xbox Accessibility Guideline 117 - the Reduce Motion setting and the camera shake guideline (section 8).
