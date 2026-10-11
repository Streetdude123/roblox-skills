# Movement effects

This file covers the effects that follow the body: dashes, trails, landing and jump dust, footsteps, wakes, jump rings and afterimages. The sources are a Game Maker's Toolkit study of Celeste, the Roblox creator docs, Real Time VFX and DevForum threads. Every finding was read from its source and re-checked by an independent reader on 2026-10-11. Each rule is restated with the instance, property or number it implies. Where a source disagrees with his taste or a SKILL.md rule, his rule wins and the file says so. Sources are at the end.

## 1. Plain movement is small and short; an ability dash is flashier (Game Maker's Toolkit, colbert2677)

In Celeste, landing kicks up tiny dust particles and rumbles the controller to sell the impact. The dash has a four-frame pause and a microscopic screen shake, plus a trail of shadows and a blazing white contrail that emphasise the speed and the direction. Mark Brown says Celeste is not a "bonkers Vlambeer-style juice fest", but these "subtle and short-lived effects do a lot of heavy lifting" for game feel and input feedback.

On the DevForum, colbert2677 advised downloading a reference video and breaking it into frames. From one frame he guessed, with a hedge ("I won't talk as if I know completely how it was done"), that the dash has three parts. First, an afterimage that clones the basic rig parts in Glass and fades very quickly. Second, many thin parts stretched from the afterimage to slightly past the character, repositioned, resized and rotated each frame; he suspected these "could be beams". Third, a hollow circle that spawns a bit in front of the afterimage and fades outward. He warned that other glass parts do not show through glass.

Roblox translation:
- Celeste sets the floor for plain movement that repeats every few seconds (jump, land, run): small and short.
- An ability dash follows his "flashier" rule instead (taste.md).
- A four-frame pause at 60 fps is about 0.067 s. Apply it to the caster only, inside the dash's camera kick.
- Use two layers with two jobs: one bright pale streak for the direction (a Trail, section 2) and dark or ghost afterimages for the speed. Do not add a third layer that also shows the direction.
- colbert's three-part structure fits the move rung: a start ghost, connector streaks from the ghost to the body, and a ring at the leading edge. The connectors have length across the screen as the body leaves, so they avoid the SKILL.md trap where wind streaks along a straight dash lie on the view axis and vanish.
- His look replaces the Glass: ghosts as his accepted Neon or translucent copies (`Assets.Fx.Ghost`), connectors as thin Beams or pale `Wind1` sprites, the ring as a pack `Shock` or `Wind1` ring.
- Reading a reference frame by frame is already his workflow.

## 2. A Trail samples once per frame (creator-docs, Trail)

A Trail records the positions of its two attachments every frame and fills the polygon between this frame's points and the last frame's. Changing Attachment0 or Attachment1 while it draws deletes every segment drawn so far. `Enabled = false` stops new segments, and the old ones expire over Lifetime. `Clear()` removes them at once.

`Lifetime` defaults to 2 s and can be set from 0.01 to 20. Color and Transparency are sequences mapped over each segment's age. A change to Lifetime applies to existing segments at once: segments older than the new value are removed immediately.

`WidthScale` is a NumberSequence over the trail's lifetime. Its values run from 0 to 1, multiply the distance between the two attachments, and the result stays centred between them. Two attachments 2 studs apart at WidthScale 0.5 give a 1-stud trail.

`MinLength`: if neither attachment has moved at least this many studs, no new segment is created and the current segment's endpoints move to the attachments. Changing it affects only new segments. `MaxLength` is the maximum trail length in studs; the default 0 means no maximum, and segments expire by Lifetime.

Roblox translation:
- A body at 60 to 90 studs/s lays 1 to 1.5 stud flat segments, one per frame. That is the reason behind the SKILL.md trap: a blade smear trail during root travel drew a huge plane over the frame.
- At the dash stop, set `Enabled = false` so the tail drains over Lifetime and reads as slowing down.
- On an interrupt, a teleport, a respawn or the effect's cleanup, also call `Clear()`. Otherwise a streak can join the old and the new positions: the Dragon Form leftover lance trail in SKILL.md.
- Never re-point a live trail to another limb. Give each limb its own trail.
- The 2 s default is far too long for movement. His accepted trails run 0.12 s (knife) and 0.22 s (fist), so a dash streak starts around 0.12 to 0.25 s. Key Transparency over the same age so the tail fades before it dies.
- Because a Lifetime change is retroactive, tweening Lifetime toward 0.01 at the stop shortens the whole tail at once: a sharper end than letting it drain.
- The attachment spacing sets the widest the trail can be; WidthScale can only shrink it. Place the two attachments at the full head width you want, about 1 stud for his fist trail.
- Taper with WidthScale from 1 at age 0 to 0 at the end, so the old end thins to a point instead of ending in a flat square edge.
- `MaxLength` caps the streak by distance at any speed, so it guards against the Bull Leap "huge plane" trap. About 8 to 12 studs is a value to test, not one from the source.
- A small `MinLength` (0.1 to 0.25 studs, also untested) stops a crumpled knot of tiny segments while the body sits still at the skid.
- Build the streak as a saved template, a Folder like his fist trail (taste.md). Reparent the two attachments to the body at cast, because an Attachment under a Folder has no world position.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local streak = Instance.new("Folder")
streak.Name = "DashStreak"

local top = Instance.new("Attachment")
top.Name = "Top"
top.Position = Vector3.new(0, 0.5, 0)
top.Parent = streak

local bottom = Instance.new("Attachment")
bottom.Name = "Bottom"
bottom.Position = Vector3.new(0, -0.5, 0)
bottom.Parent = streak

local trail = Instance.new("Trail")
trail.Name = "Trail"
trail.Attachment0 = top
trail.Attachment1 = bottom
trail.Texture = "rbxassetid://1075864321"
trail.TextureMode = Enum.TextureMode.Stretch
trail.Lifetime = 0.18
trail.MaxLength = 10
trail.MinLength = 0.15
trail.WidthScale = NumberSequence.new(1, 0)
trail.Transparency = NumberSequence.new(0.35, 1)
trail.LightEmission = 1
trail.LightInfluence = 0
trail.FaceCamera = true
trail.Enabled = false
trail.Parent = streak

streak.Parent = ReplicatedStorage.Assets.Fx
```

## 3. Pick the TextureMode by what the trail must do (creator-docs Trails guide, Kassyndra)

How the texture moves depends on `TextureMode`. Stretch spreads the texture over the trail's lifetime and shrinks it inward when the attachments stop. Wrap tiles it as the trail grows, with the tiles fixed relative to the attachments. Static rolls the texture out as the attachments move and leaves it in place until its lifetime ends; the docs call this ideal for "stamped" marks such as paw prints or tire tracks.

On Real Time VFX, Kassyndra (no credentials stated) wrote that a simple stretched texture is widely used for a "motion line" because it needs no obvious pattern. A scrolling texture mostly emulates "ribbon" smoke, like a blown-out candle, and some more magical things. Tiled ribbons suit repeatable tiles such as chains, vines or arrows. The thread's poster, who says he is not a VFX artist, raised the problem that a stretched ribbon cannot "stay in place" because its tail is dragged with the head. Kassyndra said scrolling the texture solves it; the poster replied that the tail still moves with the head.

Roblox translation:
- A speed line is TextureMode Stretch with a soft gradient streak and no pattern. Patterned strips on fast bodies drew panes in the Caliber Phoenix build (caliber-phoenix.md). Stretch also pulls the streak in by itself when the dash stops.
- Wrap is for chains and runes along a path.
- Anything that should stay where it was laid is Static or particles. For skid scuffs, slide marks and a scorched dash line, use Static with two attachments a few tenths of a stud apart near the floor, Lifetime 1 to 3 s and Transparency fading out.
- The Trails guide also says to check trails at the lowest and the highest Editor Quality Level.

## 4. Trigger landing and jump effects from StateChanged (creator-docs Humanoid, DevForum)

`FreeFalling` can fire with `active = false` if the state changes while the Humanoid is falling, so the docs say to use `StateChanged` and listen for the Landed state to detect a landing. `Jumping` fires with `active = true` and shortly afterwards with false; that second firing does not mean a landing. There is no idle state: use the `Running` event or the root part's velocity to tell when the Humanoid is standing still.

`Humanoid.FloorMaterial` is read-only and works with both Parts and Terrain voxels. It reads Air when the Humanoid is not standing on a floor. The character model must be able to collide with the floor, or the floor is not detected. It cannot test swimming; use `GetState` for that. `Terrain:GetMaterialColor` throws an error when passed Air or Water.

A 2018 DevForum thread on crack effects (RuizuKun_Dev and RedDuck765) gates a landing effect on fall height. While falling, track the highest Y the root reaches. Take `FallHeight = MaxHeight - landing Y`, and fire the effect only when it is more than `LowestFallHeight = 15` studs and the floor is not Air or Water. Place the mark with a downward raycast that uses the surface normal, so it sits flat on slopes.

Roblox translation:
- Use one `StateChanged` handler per character, run on each client for the effects.
- `new == Jumping`: emit the take-off puff or ring at the feet. `new == Freefall`: record the root's Y and keep its peak. `new == Landed`: drop = peak - Y, then emit the landing dust scaled by the drop.
- Take the thread's method, not its code: the posted loop uses `math.abs(Y)` and `wait()`, and it relies on FreeFalling, which is unreliable.
- Scale the dust Emit count and the ring size by `math.clamp(drop / 15, 0.3, 2)`. A plain hop gets a tiny puff; a big drop gets a ring with debris. Show no crack below the 15-stud threshold.
- `FloorMaterial == Air` is the cheap check that skips ground dust in the air.
- For the dust colour, raycast down. On a part, use its Color. On Terrain, use `GetMaterialColor(result.Material)`, with Air and Water guarded; Water gets a splash, not dust.
- Then apply his rule: mix the floor colour 35% toward grey-brown, so dust on a pale floor never reads as soot (SKILL.md).

## 5. Footstep dust lands on the contact frame (creator-docs Animation events, DevForum)

Animation event markers line effects up with exact frames. `AnimationTrack:GetMarkerReachedSignal("FootStep")` fires on a named marker, and the marker's Parameter string arrives as the argument. A marker made once can be reused anywhere in the animation, for example the same FootStep marker at the left and the right foot contact.

On the DevForum, TaBigMemesGuy's WalkingParticles LocalScript (StarterCharacterScripts) creates one emitter on each foot (RightFoot and LeftFoot on R15, Right and Left Leg on R6) with Transparency 0.7 to 0.9, Size 0.3, Lifetime 1, SpreadAngle 10, 10 and EmissionDirection Back. On `Humanoid.Running` it enables them with `Rate = RunSpeed * 2.5` when RunSpeed is at least 1 and disables them otherwise. The point is to "render footsteps on clients only rather than using the server's resources."

Roblox translation:
- Put FootStep markers with the parameter "L" or "R" on the contact frames of the run, sprint and skid clips. On each marker, Emit a few floor-tinted puffs at that foot's attachment.
- The puffs land on the contact frames instead of in a continuous stream, which keeps run dust from cluttering.
- The same hook can drive the dash's "floor-tinted dust from every contact" (SKILL.md).
- The forum script is an answer, not a measured rule. At WalkSpeed 16 it gives 40 puffs a second per foot, which is too dense for his "too much feels messy" ceiling on constant locomotion.
- Keep its faint 0.7 to 0.9 transparency and its client-only rendering, but prefer the per-step Emit. If a Rate is used, set it only inside `Running`, never every frame.

## 6. Space a wake by distance and let it shed from the body (creator-docs ParticleEmitter)

The `ParticleEmitter:Emit` code sample "Emit Particles Over Distance" measures how far the emitter's parent moved on each `RunService.Stepped` and emits `math.floor(distance * PARTICLES_PER_STUD)`, with the emitter's own `Enabled` set to false. `Emit(n)` emits n particles instantly; the default n is 16.

`VelocityInheritance` (0 to 1) is how much of the parent part's velocity a particle gets when it is emitted. `Drag` is the time in seconds for a particle to lose half its speed. Together they make an emitter appear to "shed" particles from a moving part. `LockedToPart` makes live particles move in lock step with the parent.

Roblox translation:
- Space a dash or slide wake by studs, not seconds. The density then stays the same at 30 or 90 studs/s and at any frame rate, unlike the skill's dust wake every 0.035 s through the skid (SKILL.md).
- Keep the fractional remainder between frames so slow movement still emits. The sample does not do this.
- A starting value to test: 0.5 to 1 puff per stud.
- For dash wind wisps and slide sparks that leave with the body and then stall behind it, use partial VelocityInheritance with a short Drag. Values to test, not from the docs: 0.3 to 0.6 inheritance and 0.1 to 0.25 s drag.
- Keep LockedToPart off for anything left behind. Turn it on only for auras welded to the body.
- Inheritance reads the part's velocity. A carrier anchored and moved by CFrame may not report one; see engine-and-performance.md section 4.

## 7. Build jump rings from particles (creator-docs Particle emitters, DevForum)

A ParticleEmitter `Shape` can be Box, Sphere, Cylinder or Disc. `ShapeStyle` Surface emits only from the outside of the shape. `ShapeInOut` Outward sends particles away from it. On a Disc, `ShapePartial` inversely sets the inner radius. Sphere and Cylinder do not display correctly when the emitter is parented to an Attachment; use them only on a BasePart.

A 2025 DevForum thread (0bby_d0g3 and ThatOneNoobOnTheTeam) makes a particle ring from one emitter. Put it on an attachment rotated to the plane you want, give the particles Speed and Drag, and set a Transparency sequence that keeps them invisible until they reach the ring's radius. A rotating parent attachment can also spin child emitter attachments around a centre; LockedToPart must be false so emitted particles stay where they spawned.

Roblox translation:
- Code fallback for a jump, double-jump or landing ring when no pack ring (such as `Shock`) fits: a small flat carrier part at the feet with a Disc emitter, ShapeStyle Surface, ShapeInOut Outward, Emit 16 to 24 soft puffs, Speed with Drag, life 0.25 to 0.4 s. The counts and life are values to test.
- water.md section 8 measured that a Disc on a flat part with the default EmissionDirection (Top) sprayed up from a thin line instead of the rim. Check the Disc ring in a capture first. If it does the same, use attachments round the rim as water.md describes.
- Put the mid-air ring under the feet.
- Give the ring a Transparency of 1 for the first 15 to 25% of its life, then visible. That hides the dense centre, so it reads as a hollow ring and not a blob over the feet.
- It suits his dislike of solid geometric rings: the ring is soft puffs, not a Neon mesh.

## 8. Afterimages come from a pool, and every overlap costs (DevForum, creator-docs)

In a 2022 DevForum code review (loudbytes and homeworldcata), an afterimage cloned the character on every Heartbeat and faded each clone over 1.5 s. That kept 90 to 100 clones alive at once, every part tweening, and caused heavy lag. The fix was fewer clones per second and a cap on layers. The poster then built all the layers in advance and cycled through them, which doubled the frame rate.

In a 2026 thread (hello2e6 and Denneisk), a battlegrounds afterimage dropped the frame rate from 144 to about 90. The advice: Humanoids are costly, so strip each clone to its BaseParts and accessories, set them Anchored, CanCollide off and Transparency 0.5. Generate the clones in advance and recycle them through a list, with an index on the freshest so the next one is the oldest. `Instance:Clone` was also said to be slow.

thefightboy_yt's Afterimage Module draws each clone in its own full-screen ViewportFrame whose CurrentCamera is `workspace.CurrentCamera`. It fades a clone with ImageTransparency and tints it with ImageColor3 and LightColor. Its parameters are active time, time between images, base transparency, fade-in time, hold before fade-out and fade-out time. The author lists two cons: the afterimages show through other objects, and it is not well optimised.

The creator-docs performance guide: decals, textures and particles do not batch well and add draw calls, and property changes to ParticleEmitters can have a dramatic impact on performance. Partly transparent objects placed near each other force the engine to render the overlapping pixels multiple times.

Roblox translation:
- Live ghosts = fade life / spawn gap for a continuous stream: 0.3 / 0.035 is about 9. His accepted white dash spawns 5 ghosts every 0.035 s, each fading over 0.3 s, so at most 5 are alive per dash (arithmetic, not from the source).
- Build a pool from `Assets.Fx.Ghost` when the player joins, sized to the most ghosts that can be alive at once, and move and re-fade them instead of cloning on cast. That fits his real-instance-tree rule and the warm-at-join rule.
- A ghost template has no Humanoid and no scripts: only the six R6 parts (plus accessories if the silhouette needs them), Anchored, with CanCollide, CanQuery and CanTouch off. Keep it in a ring buffer with an index on the freshest.
- The posts disagree on whether clothing survives without a Humanoid. That does not matter for his ghosts, which are flat Neon or plastic tints with no clothing.
- The module's parameter list is a useful shape for the skill's `afterimage` helper, which only fades: add a short fade-in and a hold before the fade.
- A ViewportFrame ghost fades as one flat image, so overlapping translucent limbs cannot stack into a solid block (an inference). But it ignores depth and draws over walls and bodies. Use it only for a brief self-dash in open space, never in cutscene shots.
- Movement effects run all the time. Do not tween emitter properties every frame for run dust; set them on events.
- Keep stacked translucent ghosts few and fade them fast, since every overlap is overdraw.
- Check every movement effect at Quality Level 1 as well as his usual 21. A dash that reads only at 21 needs a non-particle backbone: a Trail or a ring.

## Where the sources and his taste disagree

- Celeste's subtle, short-lived dash. That stays the floor for plain locomotion; an ability dash follows his "flashier" rule.
- colbert2677's Glass ghosts. His accepted Neon or translucent ghosts replace them.
- The WalkingParticles rate (40 puffs a second per foot at WalkSpeed 16). It is too dense for "too much feels messy"; per-step Emit replaces it.
- A Trail on a dash against the SKILL.md trap "no trail during root travel". The trap stands for blade smear trails. A dash streak is allowed only short, capped by MaxLength, and judged in a capture.
- The Disc ring from the particle guide. The water.md measurement that a flat Disc sprayed from a thin line comes first: check it in a capture before relying on it.

## Not covered

- Slide sparks and slide dust. No game-specific breakdown was found on Real Time VFX, Game Developer or the DevForum, only general spark tutorials and a student project.
- A DevForum dash VFX tutorial by an experienced developer with property values. Only beginner help threads (585162, 3078334, 665567) with no usable numbers turned up.
- Afterimage spacing and fade numbers from a professional artist. The 80.lv Niagara afterimage article had no interval, lifetime or count, only a GPU and memory cost warning.
- Landing dust scaled by fall speed from a professional or game source. None was found; only the DevForum 15-stud threshold (section 4).
- A double-jump ring from a professional source. Only DevForum threads (section 7).
- A Riot, VALORANT or League article on dash and blink readability (start and end markers). Not found.
- The default values of `Trail.WidthScale`, `MinLength`, `FaceCamera` and `Transparency`. They are not listed in the creator-docs Trail YAML.
- The full verbatim Lua of the "Emit Particles Over Distance" sample. The GitHub path returned 404 and create.roblox.com returned 502 to curl; the method was read through the rendered page only.
- The Celeste developer's own thread (Maddy Thorson, via Gigazine). It covers input forgiveness (coyote time, buffering), not VFX, so it was not used.

## Sources

- Game Maker's Toolkit (Mark Brown), "Why Does Celeste Feel So Good to Play?", transcript in the Hugging Face dataset taesiri/GMTK-Transcripts (rows 33571 to 33581), https://huggingface.co/datasets/taesiri/GMTK-Transcripts - Celeste's landing dust, four-frame dash pause, shadows and contrail (section 1).
- colbert2677, "How to achieve this dashing effect", Roblox DevForum (2021), https://devforum.roblox.com/t/how-to-achieve-this-dashing-effect/1084983 - the three-part dash guess and the frame-by-frame method (section 1).
- Roblox creator-docs, Trail class reference, https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Trail.yaml - per-frame sampling, Enabled and Clear, Lifetime, WidthScale, MinLength and MaxLength (section 2).
- Roblox creator-docs, Trails guide, https://github.com/Roblox/creator-docs/blob/main/content/en-us/effects/trails.md - the three TextureModes and stamped Static marks (section 3).
- Kassyndra, "Confusion about trails", Real Time VFX (2021), https://realtimevfx.com/t/confusion-about-trails/16495 - stretched, scrolling and tiled ribbons (section 3).
- Roblox creator-docs, Humanoid class reference and HumanoidStateType enum, https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Humanoid.yaml, with Terrain.yaml (GetMaterialColor) and RaycastResult.yaml - StateChanged and Landed, FloorMaterial, the Air and Water error (section 4).
- RuizuKun_Dev and RedDuck765, "How do I make a crack effect?", Roblox DevForum (2018), https://devforum.roblox.com/t/how-do-i-make-a-crack-effect/186287 - the 15-stud fall height gate and the normal-aligned mark (section 4).
- Roblox creator-docs, Animation events, https://github.com/Roblox/creator-docs/blob/main/content/en-us/animation/events.md - GetMarkerReachedSignal and reusable FootStep markers (section 5).
- TaBigMemesGuy, "I want to make a dust effect so like a particle when I walk", Roblox DevForum (2021), https://devforum.roblox.com/t/i-want-to-make-a-dust-effect-so-like-a-particle-when-i-walk/1295770 - per-foot dust emitters driven by Running (section 5).
- Roblox creator docs, ParticleEmitter (Emit and the "Emit Particles Over Distance" sample), https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter - emitting by distance (section 6).
- Roblox creator-docs, ParticleEmitter class reference, https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ParticleEmitter.yaml - VelocityInheritance, Drag and LockedToPart (section 6).
- Roblox creator-docs, Particle emitters guide, https://github.com/Roblox/creator-docs/blob/main/content/en-us/effects/particle-emitters.md - Shape, ShapeStyle, ShapeInOut, ShapePartial, and the Attachment limit on Sphere and Cylinder (section 7).
- 0bby_d0g3 and ThatOneNoobOnTheTeam, "How would I make a ring of particles?", Roblox DevForum (2025), https://devforum.roblox.com/t/how-would-i-make-a-ring-of-particles/3433456 - the hollow particle ring (section 7).
- loudbytes and homeworldcata, "Trail optimization", Roblox DevForum Code Review (2022), https://devforum.roblox.com/t/trail-optimization/1642067 - clone counts and pre-built layers (section 8).
- hello2e6 and Denneisk, "Need help optimizing afterimage effect", Roblox DevForum (2026), https://devforum.roblox.com/t/need-help-optimizing-afterimage-effect/4231914 - stripped, recycled clones (section 8).
- thefightboy_yt, "Afterimage Module", Roblox DevForum Community Resources (2025), https://devforum.roblox.com/t/afterimage-module/3446986 - the ViewportFrame ghost and its parameters (section 8).
- Roblox creator-docs, Improve performance, https://github.com/Roblox/creator-docs/blob/main/content/en-us/performance-optimization/improve.md - batching, particle property changes and transparency overdraw (section 8).
