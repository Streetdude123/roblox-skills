# The code posing pipeline

Everything here lives in `ReplicatedStorage.Stand.Modules` in Lepy's places and as copies in this skill's `scripts/`.

## Pose space

A key pose is written in the PARENT part's axes at the joint pivot, so the same numbers work on any R6 rig:

- `r = {lift, twist, side}` in degrees. `lift` rotates about X: a limb swings forward for positive, the head looks up for positive, the torso leans BACK for positive. `twist` rotates about the limb's own Y. `side` rotates about Z toward +X, so the right arm goes out for positive and the left arm goes out for negative.
- `p` is a Vector3 offset in studs in the same axes. Legs use `p.Y` for knee lift and foot planting, arms use `p.Y` for dropped shoulders, the torso uses all three for crouch, bob, sway and lunge.
- The pose CFrame is `CFrame.new(p) * Angles(0,0,side) * Angles(lift,0,0) * Angles(0,twist,0)`.
- `Motor6D.Transform = C0.Rotation:Inverse() * pose * C0.Rotation`. The reverse decode is `P = C0.Rotation * Transform * C0.Rotation:Inverse()`, then `lift = asin(r21)`, `twist = atan2(-r20, r22)`, `side = atan2(-r01, r11)` from `P:GetComponents()`.
- Standard R6 C0 rotations: shoulders and hips are `Angles(0, +-pi/2, 0)` (right positive), Neck and RootJoint are `CFrame.new(0,0,0, -1,0,0, 0,0,1, 0,1,0)`.

## Poser.lua

- `Poser.attach(model, ctx)` collects every Motor6D keyed by `Part1.Name`, so a stand inside a character never collides with the body's own "Right Shoulder". `ctx` is a shared table a controller fills every frame.
- A clip is `{name, length, loop, joints = {[partName] = keys or function}}`. Keys are `K(t, r, p, ease, dir, overshoot)`; the ease on a key is the ease INTO that key. Eases: linear quad cubic quart sine expo back elastic snap, dirs in out inout.
- A joint may instead be `function(t, ctx)` returning a key table or a CFrame. That is how idle, walk, air and land blend inside one clip (`Clips.DioMove`) and how the stand's float reads the walk phase.
- `rig:play(clip, {fadeIn, speed, startAt, onDone})` blends from the live transforms. `speed = 0` holds a frame (pose sheets). `rig:hold(dur)` is a hit stop. `rig:stop(fade)` eases back to rest.
- Transforms are written in `RunService.PreSimulation` every frame. A one shot write from a normal thread is overwritten by the Animator, so a held pose must be a zero speed play.
- `Poser.bake(clip, rig, fps, name, length)` samples a clip into a KeyframeSequence with Linear poses nested by Part0. Procedural clips give `ctxAt(t)` so phase and speed exist per frame.

## Locomotion.lua

One controller per character on every client. It disables the Roblox `Animate` script on the owner (which also stops the replicated tracks), plays `Clips.DioMove`, and each Heartbeat fills `ctx`: `speed` (smoothed ground speed), `walk` (0..1 from speed 0.6 to 4.1), `phase` (advances by `2pi * speed / STRIDE`, STRIDE 13 studs per cycle gives a 0.81 s cycle at speed 16), `air` from Freefall/Jumping, `jump` for the first part of a jump, `land` set to 1 on Landed and decaying at 3.2 per second, `stand` when a Stand model is present. A stopped walk settles the phase to the nearest passing pose. `Locomotion.override(character, clip, opts)` plays a move and hands back to DioMove; `Locomotion.release` returns early.

## Verification without watching

- Pose sheet: `player:SetAttribute("PoseHold", "walk:0.25" | "idle" | "DioSummon:0.36")` freezes the live body; nil releases.
- Motion strip (`scripts/Strip.lua`): clone the character (set `Archivable = true` first) six to eight times along a line, anchor each root, hold each at a different time or phase with a zero speed play, light them, and capture once from the side. Ghosts must face the camera: with the camera at local -z use facing 0 for a front view or `-pi/2` for a side view.
- Numbers: read limb direction vectors back in root space (`-part.CFrame.UpVector` is the hand direction) when a pose looks wrong in a capture.
- Studio play must run at QualityLevel 21 for glow; captures without camera arguments use the game camera.
- Two captures with identical camera arguments return the same cached image; move the camera a tenth of a stud between captures of a changed scene.
- Frame time reads are valid only while the Studio window is in front: an occluded Studio runs at 15 fps or freezes for seconds, so measure a 2 s idle first and trust a run only when idle frames are 16 to 18 ms.
- Two Poser rigs on one model coexist when their clips drive different joints (a stand rig and a body rig on the same clone); two rigs on the same joints fight in hash order, so rebuild the clone instead of stacking a test clip on it.
- A first summon hitches on the first draw of new meshes, materials and sprites, not on Lua: draw every piece once at join at 98 percent transparency for two frames (`SummonVfx.warm`) and the 57 ms frame becomes 26 ms.

## Reading other people's clips

`scripts/ReadClips.lua` decodes every KeyframeSequence under a container into one text file per clip (`clip|joint|t|lift|twist|side|px|py|pz|ease|dir`) through a local node server (`scripts/serve.js`, POST `/put?name=`). Then awk over the files: ranges per joint, frame by frame tables, and a speed segmentation (hold under 4 deg per frame, move 4-15, fast 15-40, STRIKE over 40) that exposes the snap hold snap settle structure of an attack. `KeyframeSequenceProvider:GetKeyframeSequenceAsync("rbxassetid://id")` works in Edit mode for published clips, including the Roblox defaults.

## Handing clips to an animator

`scripts/Bake.lua` writes every clip into `ServerStorage.StandAnimRig.AnimSaves` (a rig with the stand attached). The Roblox Animation Editor loads a KeyframeSequence from a rig's AnimSaves and publishes it; Moon Animator imports a published id or reads exported KeyframeSequences (see moon-animator.md). To learn from a clip that comes back, run ReadClips on it and, if it should drive the game, convert its keys into a Clips entry with `e = "linear"` at the exported frame rate.
