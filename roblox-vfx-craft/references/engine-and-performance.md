# Engine features and performance

This file covers the engine facts behind the effects: ParticleEmitter and Trail limits and properties, what a change does to live particles, Highlight cost, where visuals should run, cleanup and pooling, quality scaling, profiling, lights and post effects. The sources are mainly the Roblox creator docs, plus a Rendering Team announcement and two DevForum resources. Every finding was read from its source and re-checked by an independent reader on 2026-10-11. Each rule is restated with the instance, property or number it implies. Where a source disagrees with his taste or a SKILL.md rule, his rule wins and the file says so. Sources are at the end.

## 1. Rate caps at 400, and the cost is in pixels and overlap (creator-docs particle guide, Improve performance)

One ParticleEmitter emits at most 400 particles per second from Rate (100 per second on mobile), and particle Lifetime is capped at 20 s. The docs advise keeping Rate as low as possible and getting density from size and other properties.

Particle size costs through fill rate: the more screen pixels particles cover, the more GPU time. Particle count costs through overdraw, especially when particles overlap: the more layers of transparent effects on screen, the more GPU time.

Flipbooks cost texture memory, and clients low on memory (likely older phones) deactivate flipbooks automatically. Fewer unique animated effects, smaller textures and reused textures reduce the risk.

The performance guide adds that decals, textures and particles do not batch well and add draw calls, and it singles out property changes on ParticleEmitters as able to hurt performance dramatically.

Roblox translation:
- Any Rate above 400 is wasted. The ambient rain's Near layer (650/s) and Mid layer (1200/s) in ambient.md really emit 400, and 100 on a phone.
- When a stream must be denser (a cinematic sparkle field, a barrage stream), split it across two or three emitters on the same carrier, or raise Size and Lifetime instead of Rate.
- The cap is stated for Rate only. The docs give no cap for `Emit` counts.
- Anything meant to linger past 20 s, such as long aftermath smoke, must be re-emitted. It cannot be one long-lived particle.
- The expensive particle is a big one near the camera that overlaps others, not a high count. Screen-filling smoke sheets, flares and stacked glow sprites on a cinematic shot cost far more per frame than hundreds of small stars across the arena.
- This backs the SKILL.md rule that near-camera claws, feathers and flares are the first to cut. When a cinematic frame hitches, look first at the large layers near the lens: the smoke mushroom, flash balls, stacked glows.
- Keep the sparkle field and the bursts in the hundreds. His taste ("not enough particles") wins over a lower count.
- A flipbook hero can silently vanish on a spectator's old phone. Every flipbook hero needs a non-flipbook soft partner (the `glow` particle, a ring, a puff) that still reads alone. That fits the "every hard piece gets a soft partner" rule.
- Reuse one kit sheet tinted several ways rather than pulling a unique sheet for each layer. The "one flipbook hero per burst" rule (principles.md section 5) also keeps memory down.
- Set a spawned template's tint, scale, glow and LightInfluence once, before its first Emit, then leave the emitter alone.
- Do not pulse an aura by writing Rate, Size or Color on emitters every Heartbeat. Put the pulse in the Size and Transparency curves over life, or on a PointLight (the summon's heart light).
- If a follow loop or a spinner writes emitter properties each frame, measure it before keeping it. Measure before cutting anything too: he wants no loss in quality.

## 2. What a change does to live particles and trails (creator-docs ParticleEmitter, Trail)

Turning off `Enabled` stops new particles but leaves live ones until they expire; `Clear()` removes them at once. Changes to Rate and Lifetime reach only new particles. Changes to Color, LightEmission and ZOffset apply to particles already in flight. A Lifetime of 0 prevents emission entirely.

`ParticleEmitter.TimeScale` runs from 0 to 1: 1 is normal speed, 0.5 half speed, 0 frozen. Particles can be slowed or frozen, never sped up.

`Trail.Lifetime` runs from 0.01 to 20 s (default 2). A change applies at once to existing segments: segments older than the new Lifetime are removed immediately. `Enabled = false` lets existing segments age out, and `Clear()` removes them; to clear and stop new segments, do both. `WidthScale` is a 0 to 1 multiplier on the distance between the two attachments. `Brightness` (0 to 10000) acts only while LightInfluence is below 1.

Roblox translation:
- `Kit.kill` disables everything and lets the last particles die before Debris removes the model. That is the right soft ending.
- For a hard cut (the snap to black before `CameraRig.cut`, an impact-frame cut, a cancelled move), call `Clear()` on every emitter so nothing hangs into the next shot.
- A late `Kit.tint` recolours particles already in the air, which suits a colour drain such as the time stop's lavender. A Rate or Lifetime change waits for the next particle.
- `Emitters.make` sets `e.TimeScale = 1 / Tw.S()` for slowed captures, and the time stop freezes particles at TimeScale 0. Both sit inside the documented range.
- Keep the feature's `TimeScale` attribute at 1 or above. A value below 1 would ask the emitters for a TimeScale above 1, which they cannot play. A fast-forward or rewind beat shortens Lifetime and raises Speed instead.
- Tweening a Trail's Lifetime down shortens a live sword or lance trail at once: a fast tail-off on the last swing.
- At a cut or at the end of a form, set the Trail's `Enabled = false` and call `Clear()` together. The Dragon Form leftover lance trail in SKILL.md is this bug.
- The attachment gap sets a Trail's maximum width. Place the blade attachments at the full width you want and shape it with WidthScale (movement-fx.md section 2).
- A Trail at LightInfluence 0 can have its Brightness pushed for the hero swing.

## 3. Flipbooks, light and draw order (creator-docs ParticleEmitter)

`FlipbookLayout` is None, Grid2x2 (4 frames), Grid4x4 (16), Grid8x8 (64) or Custom (FlipbookSizeX and Y), and the texture size must be an exact multiple of the layout. `FlipbookFramerate` is capped at 30 fps. In OneShot mode the framerate is ignored and the sheet plays once over each particle's Lifetime. Random mode crossfades between frames. `FlipbookStartRandom` with framerate 0 gives each particle one static random frame.

`LightInfluence` defaults to 1 when an emitter is inserted with Studio tools and to 0 when it is created with `Instance.new()`. `Brightness` scales the emitter's light only when LightInfluence is 0. `LightEmission` sets the blending (0 normal, 1 additive) and does not light the environment. With LightEmission above 0, darker colours look more transparent.

`Squash` is a curve over the lifetime: values above 0 make particles narrower and taller, values below 0 wider and flatter. `ZOffset` moves particles toward the camera (positive) or away (negative) in studs without changing their screen size. It accepts fractions and applies to current particles. Values negative enough render the particles inside or behind the parent part.

Roblox translation:
- For a OneShot hero burst (`Hit2`, `Hit3`, an explosion sheet), Lifetime is the playback speed. A 16-frame Grid4x4 at Lifetime 0.5 shows each frame for about 31 ms. Retime the burst by changing Lifetime, not FlipbookFramerate.
- In `Emitters.make`, `flip = {layout, mode, fps}` with an fps above 30 does nothing in Loop or PingPong. The `flatShock` helper passes fps 32 with OneShot, where the fps is ignored; its Lifetime sets the speed.
- For shard and debris variety from one multi-frame sheet, use FlipbookStartRandom with FlipbookFramerate 0, so each particle is a different static piece. Random mode suits slow twinkles.
- Code emitters from `Emitters.make` start at LightInfluence 0. Kit templates made in Studio likely sit at 1 unless the pack author changed them, so a kit piece beside a code emitter can read dull under a dusk sky or the time-stop grade. Read the value, and `Kit.set` LightInfluence 0 on glow pieces.
- Raising Brightness above 1 at LightInfluence 0 is the cheap way to make the hero the brightest value without adding particles.
- A dark layer at LightEmission 0 is the only way to get a true dark: dark colours on an additive layer fade toward transparent.
- Particles never light the world. A hit still needs a PointLight spike.
- Squash is a NumberSequence, so a spark can start as a long streak and collapse to a dot (Squash from high to 0 over life), and an impact flash can go wide and flat on its first frame (negative). Capture once to confirm which screen axis "taller" is under VelocityParallel.
- Use ZOffset to settle the draw order where layers share a point. Give the hero flash or flare a small positive ZOffset so it draws over the smoke and the dark rim, and push the dark rim and the smoke slightly negative. `Emitters.sparkles` already exposes `o.zoffset`.
- Particle ZOffset changes draw order only; a Beam's ZOffset also changes its screen size (textures.md).

## 4. Emission shapes and inherited motion (creator-docs ParticleEmitter)

`ShapePartial` changes meaning with the Shape. On a Disc it is the inner radius proportion (1 emits only from the outer rim). On a Sphere it is the hemispherical angle (1 is the full sphere, 0.5 a half dome, 0 a single point at the north pole). On a Cylinder it is the top radius proportion (0 makes a cone). `ShapeStyle` picks volume or surface emission, and `ShapeInOut` picks outward, inward or both.

With `LockedToPart`, live particles move in lock step with the parent. `VelocityInheritance` (0 to 1) gives new particles a share of the parent BasePart's velocity, and with Drag they appear to "shed" from a moving part. Drag decays speed exponentially, and a negative Drag makes the velocity grow. `WindAffectsDrag` makes particles follow `Workspace.GlobalWind`, but only while Drag is above 0.

Roblox translation:
- Particle-only shapes need no mesh, which fits the "particles over meshes" rule.
- A ground shock of dust or sparks: Disc, ShapePartial 1, Surface, ShapeInOut Outward, emitted once from a flat carrier. Check it in a capture first: water.md measured a flat Disc with the default EmissionDirection spraying from a thin line instead of the rim.
- A dome blast for an explosion wave: Sphere at ShapePartial 0.5.
- A cone of sparks off a strike, or a fountain: Cylinder at ShapePartial 0.
- A gather: ShapeInOut Inward on a Sphere with Surface pulls particles to the centre with no code.
- Sphere and Cylinder emitters go on a BasePart, not an Attachment (movement-fx.md section 7).
- Use LockedToPart only where the shape must stay rigid on its carrier, such as the whirlpool crescents or a spinning disc.
- For a dash wake, embers off a swung blade, or a stand's rise trail, use VelocityInheritance with Drag above 0, so the particles leave with the body and fall behind.
- Inheritance reads the part's velocity, and the follow carriers are anchored and moved by CFrame. Check in a capture that they report a velocity before relying on it.
- A negative Drag gives streaks that accelerate away from an impact.
- Ambient smoke with WindAffectsDrag drifts with GlobalWind for free.

## 5. Highlights: the first one costs, adding one spikes (Roblox Rendering Team, creator-docs)

Since 2025-11-10 an experience may hold up to 255 Highlight instances. Community replies put the old cap at 31; one says 32. The Rendering Team warns that each highlighted object is drawn individually at a draw-call cost, and that any visible highlight adds a post-processing cost.

The highlighting guide adds that the first Highlight on screen carries most of the cost (up to 1 ms of GPU time on mobile), and later ones add little. Adding or removing a Highlight can trigger a geometry rebuild with performance spikes, while changing its properties is lightweight. A disabled Highlight still holds one of the 255 slots. On mobile the cost grows with screen coverage, and an invisible Highlight (disabled or fully transparent) costs nothing.

Roblox translation:
- The old cap no longer limits a white hit flash on every enemy in a crowd, or Highlight silhouettes in an impact frame set.
- His rule "don't highlight the character" stands, because it comes from his taste, not from the limit. It gives way only when he asks, as with the white dash Highlight (taste.md).
- Budget a Highlight as one extra draw per highlighted model, plus one post pass while any Highlight is on screen.
- If a target flash uses a Highlight, do not `Instance.new` and `Destroy` one per hit: the rebuild spike lands on the hit frame, the frame that must not hitch.
- Create one Highlight per target when it spawns (or at its first hit, during warm-up) with FillTransparency 1 and OutlineTransparency 1, and tween FillTransparency for the flash. Destroy it when the target dies, since a disabled Highlight still holds a slot.

## 6. Build visuals on the clients; clean up through one parent; pool what repeats (creator-docs, PartCache)

Roblox's performance guide says visual effects such as an explosion or a spell blast need not be replicated instances. The server only needs the location to decide the outcome, and the clients create the visuals locally. Tweens should run on the client, because a server-side tween replicates the property to every client every frame and looks jittery as latency changes.

In Roblox's laser tag sample, the caster's client shows its own blast at once through a local BindableEvent while it sends the blast to the server. The server validates the blast, applies damage, then replicates it with `FireClient` to every player except the caster. The blast fires on input Begin, because "a blasting mechanic doesn't feel responsive unless it occurs the instant the button goes down."

`Debris:AddItem` destroys an object later without yielding and runs outside the calling script, so the destruction still happens if the script is disabled or destroyed. A `task.delay` callback never runs in that case. Debris has a hardcoded maximum of 1,000 objects; past that, the oldest items are destroyed instantly.

PartCache (Xan_TheDragon, 2019) pre-creates parts from a template and, instead of destroying a returned part, moves it far away by CFrame. The author reports that creating parts with `Instance.new()` "can get very laggy", that reparenting is slower than moving, and that pooling roughly tripled the performance of his laser demo. Moving a part far away removes it from its render cluster, so it must be re-added when brought back.

Roblox translation:
- The current remotes already follow the guide: `Remotes.Cast:FireAllClients(player, hrp.CFrame)`, `Remotes.Hit:FireAllClients(model, kind, pos)`. Keep payloads to a CFrame, a kind and a few numbers.
- The exception to revisit is server-owned moving visuals: the seven knives flown as server parts at 115 studs/s (SKILL.md). Let the server raycast the flight and each client draw its own knife. That matches the ragdoll lesson in taste.md: a body a viewer watches in flight must be simulated on that viewer's client.
- Today the caster's own move goes client to server to `FireAllClients` and back (`Remotes.Move` in `MovesServer.lua`), so he sees his own M1, barrage or summon one round trip late.
- On the move and summon rungs, have `StandClient` play the caster's effect locally on `InputBegan`. The server then fans out to the other players only: `FireClient` in a loop that skips the caster, or the caster's `OnClientEvent` ignores `caster == LocalPlayer`.
- Hits stay server-authoritative through the Hit remote, and server state such as the WalkSpeed zeroing stays on the server.
- Debris is right for `Kit.burst` and `Kit.kill`, whose cleanup must survive a character respawn that destroys the effect script.
- A cinematic that hands every shard, rock, bolt attachment and carrier to Debris on its own can pass 1,000 queued items (bursts in the hundreds, three waves, debris rain). The oldest pieces then vanish mid-shot. Parent the pieces to the phase model and hand Debris the model as one item, or destroy the model in the effect's cleanup.
- `Tw.play`'s `task.delay` is fine where losing the callback on script death is harmless.
- Pool parts that are spawned again and again in one fight: barrage fist echoes, afterimage clones, the knife volley, slam rocks. Fill the pool at join; it doubles as the first-draw warm-up in kit-workflow.md.
- Do not pool what was measured cheap: `Kit.burst` clones and Debris are cheap (verification.md).
- Moving anchored parts every frame costs about 2 ms per 30 parts (ambient.md). Pool pieces that sit still once placed, and move fliers as attachments or particles.

## 7. Scale filler by quality, read the right setting, and profile by phase (Mystifine, creator-docs)

In a DevForum performance guide (thread from Oct 2020, first post last edited 2023), Mystifine says particles are optimised automatically by graphics level when they are enabled, but `:Emit()` ignores that optimisation. His module emits the full amount when SavedQualityLevel is Automatic and otherwise multiplies the amount by `QualityLevel.Value / 10`. Replies show an earlier version divided by 21.

`UserGameSettings.SavedQualityLevel` ("the graphics quality level set by the client") is a SavedQualitySetting with read and write security None. The enum has Automatic = 0 and QualityLevel1 to QualityLevel10 = 1 to 10. `UserGameSettings.GraphicsQualityLevel` ("the current graphics quality level being used by the client") has RobloxScriptSecurity, so ordinary game scripts cannot read it.

The MicroProfiler opens with Ctrl+F6 in Studio and the desktop client. `debug.profilebegin(label)` and `debug.profileend()` wrap code into a named bar on the timeline. In the frame graph, orange bars are frames where worker jobs (scripts, physics, animation) took longer than rendering, and blue bars are render-bound frames. Red bars are render-bound frames with a GPU wait above 2.5 ms, often from object complexity, texture size and visual effects. The docs call mobile the best place to profile, since most players are on phones and tablets.

Roblox translation:
- Almost every burst in the skill is an Emit (`Kit.emit`, `Kit.burst`, `Emitters.sparkleBurst`). If Mystifine is right, a phone on low settings gets the full count while enabled streams are thinned.
- That is a 2020 community claim, not confirmed by the current docs. Measure on a low setting before relying on it.
- If it holds, route `Kit.emit` through one quality helper that scales only the filler (sparkles, specs, dust, smoke) on low settings and keeps the hero at full count.
- On Automatic, and on his machine at QualityLevel 21, every count stays as built.
- The helper reads `UserSettings():GetService("UserGameSettings").SavedQualityLevel.Value` on the client. Treat 0 (Automatic) as full quality, since the real level is unknown; scale only explicit low values.
- The saved setting has 10 steps. Do not compare it with the 21-step `settings().Rendering.QualityLevel` that verification.md sets in Studio.
- Read it per cast rather than once at join, since the player can change it mid-session.
- Wrap each phase function in `debug.profilebegin("Ult.pillar")` and `debug.profileend()`, so a first-cast hitch names its phase.
- Read the bar colour first. Blue or red on the first cast means first draw or GPU: fix it with the join warm-up and by trimming big near-camera layers. Orange means Lua, like the summon's 3 ms (SKILL.md).
- This extends verification.md's RenderStepped worst-dt method; it does not replace it.

## 8. Effect lights without shadows; grades on the right camera (creator-docs)

Shadows from lights are expensive. The engine lowers shadow quality as the client's graphics quality drops and disables shadows altogether below quality level 4. The guide recommends turning off `Light.Shadows` where not needed, limiting light range and angle, using fewer lights, and disabling shadows on moving objects.

Post-processing effects (Bloom, Blur, ColorCorrection, DepthOfField, SunRays, ColorGrading) placed under Lighting display to all players. Placed under the Camera, they display only to that player. `ColorGradingEffect.TonemapperPreset` switches between the post-2019 tone mapper (Default) and the pre-2019 look (Retro). Depending on Studio settings, some effects may not appear at a low Editor Quality Level.

Roblox translation:
- Effect lights (the summon's gather and stand lights, the light spikes on hits, the knife PointLights) get Shadows off and the smallest Range that reads.
- Use one light per phase, moved and re-tinted, rather than a light per burst.
- A shadow-casting effect light would also look different on a low-quality phone, where shadows are gone below level 4.
- No documented cap on the number of lights was found.
- A caster-only grade (the cinematic's DoF, a blur on the hold, a flash tint) belongs under `workspace.CurrentCamera` on the caster's client. Spectators keep their own picture, and a crash mid-ultimate cannot leave a grade stuck in Lighting.
- The shared `Lighting.TimeStopCC` is right where every viewer must see the world drain.
- Verify grades at QualityLevel 21 (verification.md), since some post effects do not show at low quality.

## Where the sources and his taste disagree

- The particle guide: keep Rate low and big layers few. His "not enough particles" wins for bursts and sparkle fields in the hundreds; the first cuts are the large near-lens layers, and only after a measurement.
- Mystifine's quality scaling. Only the filler scales, the hero stays at full, and his QualityLevel 21 and Automatic counts stay as built ("no change in quality").
- The Highlight limit is gone. His "don't highlight the character" stands unless he asks.
- The performance guide on emitter property changes. Measure before cutting a per-frame writer; he wants no loss in quality.

## Not covered

- A documented cap on the number of PointLights and SpotLights rendered at once. There is none in the creator-docs light sources page, the Light and PointLight YAML, or DevForum search; only community discussion of light Range.
- Official 2024 to 2026 DevForum announcements of new ParticleEmitter, Beam or Trail features. Only the 2025-11-10 Highlight limit change turned up; search found community plugins and help threads, not release posts.
- Official (docs or staff) confirmation that `Emit()` counts are not scaled by graphics quality. Only Mystifine's 2020 community guide (section 7).
- A DevForum post by an experienced developer on particles not rendering when the emitter is far away. The one hit (topic 3930460, 2025) is a ChatGPT-written workaround with no confirming replies, so it was not used.
- A creator-docs page on Lighting post effects with per-effect performance costs. The post-processing guide gives no costs.

## Sources

- Roblox creator-docs, Particle emitters guide, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/effects/particle-emitters.md - the 400/s and 20 s caps, fill rate and overdraw, flipbook memory (section 1).
- Roblox creator-docs, ParticleEmitter class reference, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/ParticleEmitter.yaml - Enabled and Clear, live property changes, flipbooks, LightInfluence defaults, Squash, ZOffset, ShapePartial, TimeScale, inheritance and drag (sections 2, 3 and 4).
- Roblox creator-docs, Trail class reference, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Trail.yaml - Lifetime, Enabled and Clear, WidthScale, Brightness (section 2).
- Roblox Rendering Team, "Lights, Camera, More Highlights!", Roblox DevForum (2025-11-10), https://devforum.roblox.com/t/lights-camera-more-highlights/4061534 - the 255 Highlight limit and its draw and post costs (section 5).
- Roblox creator-docs, Highlighting objects, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/effects/highlighting.md - first-Highlight cost, rebuild spikes, disabled slots (section 5).
- Roblox creator-docs, Debris class reference, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Debris.yaml - cleanup outside the script and the 1,000 item cap (section 6).
- Roblox creator-docs, Improve performance, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/performance-optimization/improve.md - client-side visuals and tweens, batching and emitter property changes, light shadows (sections 1, 6 and 8).
- Roblox creator-docs, Implement blaster behavior (gameplay scripting curriculum), https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/tutorials/curriculums/gameplay-scripting/implement-blasters.md - caster-local visuals and server fan-out that skips the caster (section 6).
- Xan_TheDragon, "PartCache, for all your quick part-creation needs", Roblox DevForum (2019-03-01), https://devforum.roblox.com/t/partcache-for-all-your-quick-part-creation-needs/246641 - pooling parts by moving them (section 6).
- Mystifine, "Performance considerations, improvements, and optimizations when making a game", Roblox DevForum (2020-10-12), https://devforum.roblox.com/t/performance-considerations-improvements-and-optimizations-when-making-a-game/817499 - Emit and graphics-level scaling (section 7).
- Roblox creator-docs, UserGameSettings class reference with the SavedQualitySetting enum, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/UserGameSettings.yaml - which quality setting a game script can read (section 7).
- Roblox creator-docs, MicroProfiler, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/performance-optimization/microprofiler/index.md - profile labels and bar colours (section 7).
- Roblox creator-docs, Post-processing effects, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/environment/post-processing-effects.md - Lighting against Camera placement, TonemapperPreset, low-quality visibility (section 8).
