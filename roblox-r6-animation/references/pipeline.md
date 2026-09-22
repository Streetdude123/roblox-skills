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

## Playing a clip that came back, without an upload

`Poser.fromSequence(kfs, wraps, opts)` makes a clip straight from a KeyframeSequence instance (a rig's AnimSaves, a free model's set, a Moon export). Every `Pose.CFrame` is already a `Motor6D.Transform`, so the loader wraps it into pose space with the rig's C0 rotation (`Poser.wrapsOf(template)`) and `toTransform` undoes the wrap at play time: the round trip is exact to the decimal (the float torso sampled back as -14.7, -8.1, -6.0 with y 0.456, the decode's own numbers). Options: `map` renames pose names to the rig's joint names (`Torso` to `Stand Torso`), `trimStart` drops a lead-in so a loop's seam is a normal beat, `extra` adds procedural joints (the float root that lives outside the sequence), `loop` overrides the sequence flag, `length` overrides the last key, `only` keeps a set of joints (the user copies a stand's torso, head and arms and gets authored legs), `pScale` (a number or a table by joint) scales the offsets so a floating stand's 2 stud limb travel fits a planted body, and `rollScale` (a table by joint) scales the side channel alone so a stand's 55 degree torso roll becomes 25 on a standing body while the lift and the twist stay exact. Keys carry `e = "linear"`; a 60 fps bake has 150 keys per joint and plays fine. Strip the Moon Animator metadata (`Ease` folders, IntValues, StringValues) before shipping a sequence to ReplicatedStorage; only Keyframes and Poses are needed.

Blending in from an authored clip: `Rig:play` lerps from the live Transform, so an authored clip that hands to a sequence must end on the sequence's frame 0 pose. Read that pose from the decode and paste it as the authored clip's last key.

`player:SetAttribute("PoseHold", "Stand:WorldBarrage:0.25")` holds a frame of a stand clip on the live stand rig (the body hook stays `"DioBarrage:0.8"`); an empty value releases both. Hold poses only when no move is running, because a move's own hand-off overrides a hold.

The Edit VM caches `require` per module across `execute_luau` calls: after a Source push, validate on a fresh clone of the whole folder (`Stand:Clone()` then require the clone's module), not on the live instance, or the old Poser answers.

## Pushing a module (the source server)

Studio's `multi_edit` handles short files; a long module goes through `scripts/serve.js`:

1. `node scripts/serve.js <outDir> <luaDir> 8766` (PowerShell `Start-Process node.exe` keeps it up; the Bash tool has no node).
2. In the Edit VM: `HttpService.HttpEnabled = true`, `local src = HttpService:GetAsync("http://127.0.0.1:8766/stand/Clips.lua")`, `assert(loadstring(src))` for a syntax check, then `module.Source = src`.
3. Validate on a fresh clone of the whole feature folder (`folder:Clone()` then `require` the clone's module): the Edit VM caches `require` per module, so the live instance answers with the old code.
4. An open script editor tab reverts a push when it saves; close the tab or re-read `.Source` after.
5. The Edit datamodel is unavailable while play runs: stop, push, start.

## Wiring a move

- `Locomotion.override(character, clip, {fadeIn, fadeOut, onDone})` plays the clip on the body rig and hands back to `Clips.DioMove` when it ends. `fadeIn` at most half the snap (0.04 to 0.06) or the cock smears; the default 0.12 is for idles.
- An override writes only the joints the clip keys. Unkeyed legs freeze mid stride, so a walkable light hit keys its legs from `moveJoint` (the locomotion pose) or leaves them out on purpose for a planted heavy.
- An interrupted clip drops its `onDone` silently. Combo state lives in the caller: the cancel window opens at the settle key, an early press is buffered to it, the next clip's frame 0 is the previous clip's settle key.
- Humanoid lock: `WalkSpeed = 0`, `JumpPower = 0`, `AutoRotate = false` only on a heavy or a summon, restored at the settle key or 1.0 s, whichever is first; the recovery blends under the walk.
- Hit stop: `rig:hold(0.05)` for a light hit, `0.09` for a heavy; the camera kick and the sound sit on the same frame.
- Replication: Poser writes `Transform` locally on every client. A move reaches other clients by a remote rebroadcast; every client calls `Locomotion.override` on that character. The server never sees the pose (nothing goes through the Animator), so hitboxes are timed in clip seconds from the remote, not read from the rig.
- Sword rigs: the Handle motor's C0 decides which arm twist lays the blade flat for a horizontal cut or edge on for an overhead; `inspect_instance` it before choosing strike twists.
- A stand and its user: the stand rig is `Poser.attach(character, loco.ctx)` (joints keyed by `Part1.Name`, so `Stand Right Arm` never collides with `Right Arm`); the appear clip chains to the float with `onDone`; the body plays its own clip through `Locomotion.override` at the same time.

## Sign facts and the phase convention

- `+twist` on the torso turns the chest to the character's left (right shoulder forward). The head counters with minus the torso twist.
- The hand direction formula's third component is forward in pose space, which is Roblox -Z.
- Walk and run phase 0 and pi are the passing poses (legs together); right foot contact is at 1/8 of a walk cycle and 3/16 of a run cycle; leg `p.Z` negative puts the foot forward; torso side and head side move the same way in the run.
- Every period inside a procedural joint must divide the loop length (a 5 s sway on a 2.5 s loop flips its velocity at the seam), or the joint reads `ctx.t` on a counter that never wraps.

## Where the tools run

- `Strip.lua` and `StandStrip.lua` run in the Client datamodel under Play through `execute_luau`; the string they return goes straight into `screen_capture` as `camera_position` and `look_at_position`. Nudge the camera 0.1 stud between captures of a changed scene.
- `Bake.lua` and `ReadClips.lua` run in the Edit datamodel.
- Remotes cannot be fired from the Edit VM; fire them from the Client VM in play, or use the `CastStand` / `CastUlt` attribute hooks.

`solveFootY(tp, r, p, sideSign)` in `Clips.lua` puts a planted foot on the floor under a copied torso that leans and rolls: the foot bottom is `torsoPose * hip(sideSign, -1, 0) * legPose * (-0.5 sideSign, -2, 0)` in root axes, so the leg offset is one linear solve to y -3. `legY(torsoY, lift, torsoLift)` is the cheap form for authored poses; the torso pitch swings the hips, so a 10 degree forward lean makes a 28 degree rear leg read 38 and float 0.19 without that term.
