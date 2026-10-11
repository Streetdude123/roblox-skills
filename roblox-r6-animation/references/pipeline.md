# Runtime and export contracts

Read this before using the bundled scripts. These contracts describe the current source, not an idealized animation engine. Preserve the existing project runtime unless changing it is part of the task. Engine references are linked in [sources.md](sources.md).

## Contents

- Inspect and install only what is needed
- Poser clip contract
- Locomotion and overlays
- Networked actions, hits and knockback
- Importing sequences
- Baking and export
- Native Animator playback
- Planted feet
- Custom r6-style rigs
- Source transfer and review tools
- Review videos (scripts/video)
- Blender review videos

## Inspect and install only what is needed

Find the current controller, animation instances, rig, module dependencies, and input entry point. Confirm whether a Studio bridge can inspect instances, write source, run Edit/Client/Server code, and capture the viewport. Do not invent missing capabilities.

In an existing Poser place, use its module locations. For an explicitly requested fresh Poser locomotion setup, create real instances with these relationships:

| Instance | Parent | Source |
| --- | --- | --- |
| Anim Folder | ReplicatedStorage | Module container |
| Modules Folder | Anim | Runtime modules |
| Tw ModuleScript | Modules | `scripts/Tw.lua` |
| Poser ModuleScript | Modules | `scripts/Poser.lua` |
| Feet ModuleScript | Modules | `scripts/Feet.lua`, for clips with planted feet |
| Clips ModuleScript | Modules | `scripts/examples/locomotion-starter/ClipsLocomotion.lua` |
| Locomotion ModuleScript | Modules | `scripts/examples/locomotion-starter/Locomotion.lua` |
| Client entry | StarterPlayerScripts | Adapt `scripts/examples/locomotion-starter/LocomotionClient.lua` to the requested controls and existing controller. |

`scripts/examples/stand-combat/Clips.lua` is a larger example that depends on its project's Config and assets. It is not standalone. `LocomotionClient.lua` includes sprint and PoseHold behavior; do not install those controls for an unrelated animation request. Create a separate inspected R6 rig for export when needed.

## Poser clip contract

A clip is `{name, length, loop, joints}` plus the optional motion fields below. Times and length are seconds. Each joint key is `{t, r, p, e, d, s, tn}`: r is `{lift, twist, side}` in degrees, p is a parent-axis Vector3 offset, e names the curve into the key, d and s are the direction and parameter of a named ease, tn is the key's tension.

| Field | Meaning |
| --- | --- |
| `curve = "spline"` | Keys without e are `auto`: a cubic Hermite curve per channel (lift, twist, side, x, y, z) whose tangent keeps the speed through a breakdown, is flat where the channel turns around, and is clamped (Fritsch-Carlson) so nothing overshoots between keys. Without this field a key without e is the legacy `quad out`, so old clips play exactly as before (checked: eleven legacy clips sampled identically at 60 fps). |
| `e` | `auto`, `flat` (zero speed at this key), `smooth` (unclamped Catmull-Rom), `linear`, `step` (hold the previous key until this one), or a legacy ease name (`quad`, `cubic`, `quart`, `sine`, `expo`, `back`, `elastic`, `snap`) that shapes the segment into this key. `auto`, `flat`, `smooth` and `step` also work inside a legacy clip. |
| `tn` | 0 normal, 1 flat, below 0 looser. |
| `lag = {[joint] = seconds}` | Samples that joint's curve later. A one-shot is done at `length` plus the largest lag; a loop wraps. |
| `springs = {[joint] = preset or {f, z, r}}` | Second order dynamics on the sampled channels (presets `lead`, `follow`, `drag`, `heavy`, principles.md). State resets on `play`; `hold` and speed 0 freeze it; `play` with `startAt` runs it from 0 so a paused pose matches. |
| `life` and `lifeRate` | Slow two-octave noise on the rotation channels: a number spreads its degrees over the torso (1), head (1.4) and arms (1.2), a table gives degrees by joint; legs get none. Default rate 0.35 Hz. |
| `post(poses, t, ctx)` | Runs after curves, lag, life and springs on the pose-space CFrames of every joint (the torso pose is in root space). `Feet.flat` and `Feet.post` plant the legs here. It may only replace poses of joints listed in `joints`. |
| `events` | Plain data such as `{hit = 0.29}` for the caller to schedule from the clip clock. |
| `warp = {{t, speed}, ...}` | A speed curve on the clip's own clock, linear between points. Play advances the clip by `dt * speed * warpAt(t)`, so a load can run at 0.8, a strike at 1.3 and the contact hang at 0.3 to 0.45 without rekeying. Keys, lag, events and props stay in clip time. `Poser.warpAt(clip, t)` reads it, `Poser.realTime(clip, t)` converts a clip time into real seconds (feed the server's hit and lock times from it), `Poser.check(clip, {real = true})` measures in real seconds, and `Poser.bake` bakes in real seconds so the asset plays at the speed play shows. Springs step in clip time, as in play. |

Keys must be nonempty, finite, ordered by unique time, and inside the declared duration. `compile` sorts and caches CFrames, but does not validate that contract. After changing keys, rebuild the clip or clear its compiled state before resampling. A procedural joint receives `(t, ctx)` and returns a pose table or a pose-space CFrame. It must receive the context fields it actually uses.

The easing belongs to the destination key in Poser. Roblox PoseBase documents easing toward the next pose, so do not copy native easing fields onto destination keys without converting their semantics. The current importer instead uses linear interpolation throughout.

`attach` gathers Motor6Ds by Part1.Name. `play` has one active clip per attached rig and options `fadeIn`, `speed`, `startAt`, `onDone`, `blend`. `blend = "inertial"` (the default for spline clips) keeps the new clip moving from its first frame under an offset from the old pose that dies away on a smoothstep over `fadeIn`; `"cross"` (the legacy default) fades from the frozen old pose. Neither carries the old clip's velocity. `sample` returns an authored pose-space CFrame, not a world frame. `hold` pauses the clip time temporarily; `setSpeed(0)` holds sampling time, but procedural joints that read a changing ctx can still move. Freeze the relevant context as well when a true hold is required.

`Poser.check(clip, opts)` returns the motion metrics (motion-metrics.md) with a `text` line; `Poser.dump(clip, fps, name)` returns decode text for `motion_check.js`; `Poser.posesAt(clip, t)` returns every joint's final pose (springs run from 0, post applied); `Poser.each(clip, fps, visit)` visits the clip as play would show it. All four accept `opts.ctx` or `clip.ctxAt` for procedural joints.

Transforms are written in PreSimulation. Do not add another writer to the same joint unless composition and write order are explicit. Changing C0 each frame is not the ordinary authoring path. The fade blends from the pose the rig last wrote (`rig.last`), not from `motor.Transform`: the Humanoid's Animator zeroes every Transform between PreAnimation and PreSimulation, so a `play` called inside a step (an `onDone` hand-over to the idle) used to blend from the default pose and the body jumped for a frame (weapons.md, "The twitch when a move hands back to the idle"). The fade smooths pose differences but does not prove a clean path or matching velocity.

These blend rules hold for any clip player: Poser, or a client player that writes baked sequences over the Animator.

- Play an additive hit reaction as an offset from its own first frame, and fade it out over its last 0.12 s. It adds to whatever plays, so a hit does not cancel the victim's own attack.
- Blend a later clip from the base pose before the additive, not from the written pose. A blend from a pose that already held the flinch added it twice (one-frame steps of 60 to 70 degrees).
- When a new additive replaces a running one, fade the old offset out over 0.1 s instead of dropping it.
- Run a client fade-in on the time since the play call, not on clip time. A clip that started late opened mid-fade and popped 18.5 degrees in one frame.
- Size a blend from the pose distance: distance / 1000 deg/s, clamped to 0.08 to 0.2 s. A fixed 0.1 s blend into a 170 degree change snapped.
- Start the next clip under a one-shot, at a lower priority, before the one-shot ends. One-shots without it flashed the rest pose for a frame.

## Locomotion and overlays

In the locomotion starter (`scripts/examples/locomotion-starter`), `Locomotion.start` controls idle/walk/run/air/land through one procedural clip (`Clips.DioMove`). It stops the default tracks for the custom setup. Its Heartbeat update supplies speed, phase, walk, run, air, jump, land, and stand context.

The starter controller uses a 13-stud cycle distance and a run blend over speeds 18 to 26. Those are project choices. Its landing envelope is time-based and is not scaled by measured fall speed. Changing documentation does not change that runtime behavior.

`Locomotion.override` replaces the rig's one active clip. Omitted joints are not sampled from locomotion; with no other writer they retain their previous Transform, so an override froze the legs. For an upper-body action while moving, build an explicit composite clip: take the arms and head from the action over the locomotion joints with a weight envelope (in, hold, out), add the action's torso as an offset that bends at the waist, and blend the legs to the walk when the root moves faster than about 2 studs/s (the legs of a standing action slide when the body travels). Alternatively use the project's native masked playback, and give a partial action Weight 0 on every parent pose it does not key: weight-1 parents pinned a walk under a neck-only action. Never describe a sparse override as an automatic overlay.

An interrupted play replaces the previous callback. The caller must manage cancellation and restoration of movement state; do not rely on the interrupted `onDone`. Restore captured movement settings at the intended state transition, not a hard-coded universal one-second limit. Give every cutscene phase an exit that runs the full reset (camera, depth of field, bars, input), not only its last event; an interrupted cutscene left the camera and input stuck. An effect that a clip event switches on must also switch off on the action's finish and interrupt paths; a trail whose stop event never fired kept drawing after the move. Stop a per-character controller on `Humanoid.Died` and when its body leaves the world, checked in its own frame step: with deferred signals an `AncestryChanged` handler on a destroyed character never ran, and the dead controller errored every frame. Guard a controller against a second start while the first one yields.

Poser has no marker dispatcher. Schedule project events from the same animation clock with clear pause, speed, and cancel behavior. For skipped frames, detect crossings of event times, not floating-point equality. Do not schedule a gameplay hit with an unrelated wall-clock delay and expect it to follow hit-stop automatically.

Keep one set of event times taken from the clip clock (`Poser.realTime` on a warped clip) and let the game config read it, so the server, the client and the effects use the same numbers; hand-typed seconds drift as soon as a speed curve changes. Alternatively store each hit time on the clip and warp playback so the hit lands at the server's wind-up: keep the last 0.12 s before the hit at rate 1 and stretch only the pull-back (principles.md, "Retime only before the hit"). With stored hit times, swing to hit measured 0.22 to 0.33 s in Play.

Key cutscene beats to the audio, not by ear: sample the voice `Sound.PlaybackLoudness` at 60 Hz and place poses on its phrases and peaks. Timing by ear drifts; the loudness curve placed a scream, shouts and a laugh within a frame.

Motor6D.Transform is not replicated. A custom networked action needs the project's authoritative action identity and timing, then local playback for observers: the server fires a remote with the character and the clip, and every client plays it. Without the remote, other players see a still character. Verify it with a second client. Animate on a clean R6 character and apply each player's avatar with `HumanoidDescription` on spawn, so every clip fits every avatar. Pose held props locally on each client; do not make them part of the character model. Keep hit validation in the existing server gameplay system; a locally posed fist is not a server hitbox (hit detection: Networked actions, hits and knockback).

Build a walk or run for the speed the game really moves at: read the config (`WalkSpeed` and any animation reference speeds), because a game plays a clip at speed / reference. If the configured speed is too slow to read as a walk, build a brisk walk and change the game speed to match the clip (a 2 studs/s walk read as far too slow; 4.8 studs/s with a 0.84 s cycle read well). A rigid leg travels about 2.4 studs in one stance, so a 25 studs/s sprint cannot plant at a natural cadence: build the run for about 15 studs/s and play it faster.

Detect the local player's movement from `Humanoid.MoveDirection`, not body speed: root travel from a strike left more than 2.5 studs/s and cut held end poses short. Guard every layer that divides by move speed or direction at zero; a turning layer returned NaN joints at a WalkSpeed of 0.

## Networked actions, hits and knockback

These rules apply when the task builds or changes a game's action code. In an existing project, keep its systems and check them against these rules.

- **Input.** Block or queue input until a locking clip ends. Give a tap a minimum run time and count cooldowns from the action's end. Presses during a 1.3 s summon clip fired nothing or skipped to the finisher; a 1.4 s wait after the summon and a 1.0 s minimum tap fixed it. When a queued action wakes, read its end time again: a block queued for the end of a stun woke after a new hit had extended the stun and gave a free parry.
- **Hits.** Detect a melee hit on the attacker's client at the clip's hit frame, then validate it on the server: the swing token, a time window around the hit time, the range and the side (a window of -0.2 to +0.8 s, a 14 stud range and at most 3 studs behind worked). The attacker's screen is what the player judged. The server sees a client-driven dash 0.1 to 1.0 s late and in bursts, so never sweep it on the server's own clock; sweep it on the client that drives it. Sort hit targets by distance from the weapon line and take the nearest first, so a hit box that touches several targets does not grab one behind. Skip any body without the standard joints: one rig without them threw an error that aborted the whole hit loop. For a dash that passes through characters, use collision groups (characters do not collide with each other but still collide with floors and walls); CanCollide false drops the body through the floor.
- **Clocks.** Share times between machines as `workspace:GetServerTimeNow()`, never `os.clock()`: in one test the server's `os.clock()` read about 1900 while the client's read 138561.
- **Network ownership.** Push a body through its network owner. A player's body belongs to its own client: the server fires a remote with the launch, hold or ragdoll, and that client applies it. Server pushes on client-owned bodies were ignored. For an NPC hit by a player, give every assembly of the NPC to the attacker's client one Heartbeat after the joint swap (`SetNetworkOwner(attacker)`), let that client apply the push, and take ownership back (`SetNetworkOwner(nil)`) when the ragdoll ends. A ragdoll simulated on the server reached the attacker's screen only every 3 to 5 frames.
- **Carries and air holds.** Carry a grabbed victim by setting its CFrame every Heartbeat on the owning client with zero velocity, and zero the velocity again at the release, so only the throw's knockback sets the distance. A carry by velocity lagged 5 to 7 studs behind a fast blade tip and flung the victim 244 studs. During an air hitstop keep the vertical mover on at 0 studs/s; a disabled mover left the body rising at 91 studs/s and it overshot the apex to 17 to 20 studs against 9.
- **Ragdoll knockback.** Swap the Motor6Ds to ball sockets, clamp each limb into its socket cone and twist limit, and add socket friction torque (`MaxFrictionTorque` about 40 neck, 60 shoulders, 80 hips). Then set the Physics state and give each assembly one impulse with its own mass. The root mover must skip the Physics state. A held `LinearVelocity` on the root read as a carried body, and a push on the torso alone spun it at 16 to 27 rad/s and flung the limbs. Retune knockback speeds for a free body against ballistic airtime: speeds tuned for a carried body slid a free body 62.5 studs; after retuning, airtime measured 1.01 s against 1.02 s ballistic.
- **Root travel from the clip.** Drive a knockback slide and any vertical root travel from curves on the clip (studs by clip time) that the owning client's mover reads: a plane `LinearVelocity` for ground travel (weapons.md, "A step every swing without sliding") and a second `LinearVelocity` in Line mode for height. One curve keeps the pose and the travel in step: slides measured 1.88 to 1.99 studs for a 2.0 stud curve. Give a hover clip explicit still travel curves; a mover that skipped clips with only a vertical curve let a hover fall. Clamp downward travel to a floor raycast, with vertical speed no lower than -(h - 3) x 25 studs/s, where h is the root's height above the floor (a standing R6 root sits 3 studs up). An unclamped dive hit the floor at -287 studs/s and bounced the body 17 studs up.
- **Tests.** Each limit below gave a false or missing result:
  - Automation cannot press number keys. Test those actions through a test hook and say that the keys were not pressed.
  - The Play client cannot `HttpGet` or use `VirtualInputManager`.
  - One client cannot show what observers see. Drive a server-owned puppet (a clone of the character with network owner nil, played through the observer remote), or connect to the requester's team test and watch it read-only.
  - `BasePart.ReceiveAge` reads 0 for a part the local client simulates and also for a part that does not move, so it does not prove local simulation.
  - Record network motion in one client call and align it with server records through `GetServerTimeNow`. A server push sent from a separate call squeezed the flight into a few client frames.
  - Restart Play after a failed test.
  - Test timing windows with a scripted puppet that presses at set offsets from the hit. A puppet at offsets found a free-parry bug that hand play could not repeat.

## Importing sequences

`fromSequence(kfs, wraps, opts)` converts sampled Pose transforms into the Poser convention. `wrapsOf(model)` obtains C0 rotations. The current implementation:

- Loads positive-weight Poses and skips HumanoidRootPart; it does not preserve fractional pose weight behavior.
- Builds linear tracks, discarding source easing and any curve semantics.
- Does not carry KeyframeMarkers or native playback priority into a marker-aware runtime.
- Applies `trimStart` by discarding earlier keys; it does not interpolate an exact boundary sample.
- Supports name mapping, joint filtering, extra procedural tracks, translation scaling, and roll scaling.
- Does not retarget proportions, rest-frame differences, reach, or contacts.

Use it for inspected, densely sampled linear clips when the above losses are acceptable. Even then compare native and imported playback. Do not call the general round trip lossless. Preserve the native sequence for sparse eased clips, events, or weights that matter, or implement and test the required conversion first.

Map and filter by the target joint names expected by the loader. If using a pScale table, include numeric entries for every imported joint: the current Lua expression can select the table itself when an entry is absent. Do not enable this option with a partial table.

Roll scaling decomposes orientation into Euler angles and is not general retargeting near a singularity. For a grounded user copying a floating companion's clip, scale factors (a roll scale, an arm scale) only start the fit: solve contacts on the target rig and inspect the result.

To keep a picked reference clip exact in a game that plays native animations, bake it through the Animator at 60 fps into quaternion data and replay that, or play the original sequence; do not reauthor it by eye. The bake: in Edit, set the track's `TimePosition`, call `StepAnimations(0)`, and store each joint as a position plus a quaternion of `r * Motor6D.Transform * r^-1` (r is the C0 rotation). Quaternions avoid the gimbal flips of Poser's Euler channels, where a punching arm sits at lift 90. The replay matched the Animator within 0.15 degrees and 0.0007 studs. Wait for the track's `Length` to rise above 0 before stepping (a registered sequence loads asynchronously, and a step before that poses nothing), and after `track:Play(0)` step three times with 0.001 s, set `TimePosition` again, then step with 0. A single `StepAnimations(0)` right after `Play(0)` left the track at weight 0 and the rig at rest.

To mirror a clip, reflect every part's root-space frame across the root's YZ plane (S R S with S = diag(-1, 1, 1), x negated), swap the left and right parts, and solve each Transform back through C0 and C1. Negating Euler channels is exact only on joints whose C0 has no rotation. The mirrored reach numbers swap sides exactly.

## Baking and export

`Poser.bake` creates real KeyframeSequence, Keyframe, and nested Pose instances from the same simulation as play (lag, life, springs and the post pass included, stepped at 60 fps and kept on the bake grid plus the exact end, so bake at 60 fps or at a rate that divides it). It refuses a length over 60 s: a held clip that carries `length = 100000` so it never ends in play, baked with no explicit length, looped for millions of frames, flooded memory and crashed Studio behind a "Save File Failure" dialog (the unsaved place was lost). Save the place before any bake or other long Studio operation. Pass a bake length for every held clip and bake at most five clips per `execute_luau` call. It samples procedural clips using `ctxAt(t)` when provided. `Bake.lua` is an Edit-mode helper with configurable root, rig, and clip list; inspect and adapt those inputs first.

`Poser.bake(clip, rig, fps, name, length, warm)` pre-rolls `warm` seconds before the first recorded frame; pass one loop length for a loop with springs so the seam is in the steady cycle. Make the warm-up a whole number of frames on the 60 fps grid (for example five cycles), or the first key starts late and the seam check shows a false jump. A loop's `simulate` samples wrapped time past its length, and its `life` noise runs on a circle of the loop length, so a baked loop repeats with no jump.

Account for the current baker's behavior before delivering its output:

| Behavior in bundled source | Required delivery check or repair |
| --- | --- |
| Sets Action priority for every clip | Set the appropriate project priority on the actual sequence, including Idle or Movement when intended. |
| Creates ancestor poses with weight 1 | Inspect ancestor channels on partial-body exports. Do not unintentionally key the torso or suppress underlying motion. Set Weight 0 on every ancestor pose the clip does not key (the Animation Editor does the same); weight-1 parents pinned a walk under a neck-only action. Use the target editor/runtime's supported masking behavior and verify it. |
| Writes `Loop` from `clip.loop` | A KeyframeSequence made any other way starts with Loop true. Set Loop false on every one-shot at bake time. When a player starts to honour a flag (Loop, Priority), audit that flag on every clip it already plays: once a player honoured Loop, every punch and dash repeated until the next clip. |
| Emits Linear samples | Inspect fast strikes, stepped holds, and curved paths between samples. Increase sampling or preserve authored keys where needed. |
| Does not write markers | Add required KeyframeMarker instances at the exact planned event times and verify playback. |

Keep the source and exported copy separately. Check the hierarchy against the rig's Motor6D tree, not a guessed naming scheme. Root hierarchy poses must not introduce unintended motion. Preserve required markers when removing editor metadata; KeyframeMarker is animation data.

Change a clip only in its source of truth (the Poser source, or the Blender file when the clips come from Blender), then bake or export again. A grip patched straight into published sequences broke the link to the source and had to be reverted. A script call (`execute_luau`) leaves no undo point, so keep a copy of anything before a script call deletes it.

To slow an accepted clip, stretch it evenly: scale every key time, tangent handle and marker, the end time, and the game's event times (hit, trail, arc) by the same factor. Re-keying changes poses the requester already accepted, and unscaled event times fire early.

A KeyframeSequence stored in AnimSaves is not automatically a published animation asset. Verify how the installed editor loads it. Do not claim successful publication or an animation ID until that operation returns one. Publish under the account or group that owns the place that plays the clips, because an asset loads only where the place owner may use it. Verify each id with `KeyframeSequenceProvider:GetKeyframeSequenceAsync` and `MarketplaceService:GetProductInfo`. When the place runs under another account, ship the sequences inside the place and play them with a client player; a reviewer's account played nothing from ids that another user owned.

## Native Animator playback

Use the project's Animator and `Animator:LoadAnimation` for published animation assets. Verify asset access, priority, loop state, fades, and intended joint coverage. AnimationTrack priority is evaluated per joint; avoid unnecessary keys that take ownership of otherwise untouched body parts.

For replication, the Animator must originate on the server. Player-character tracks started on that player's client can replicate through it; non-player rigs need server-started playback to replicate. A locally created Animator does not provide that replication. Check current official docs when modifying this integration.

Connect `GetMarkerReachedSignal` for native animation markers when the project uses them. Keep cosmetic events and authoritative gameplay decisions in their existing roles. Test the entry, exit, and interruption paths relevant to the action.

Preload every Animation at spawn with `ContentProvider:PreloadAsync`. A first play waits 1.2 to 1.6 s for the asset download; one clip started 2.5 s late, so its impacts landed on the rest pose. Warm clips and effects by playing them once out of sight; a warm-up removed a summon hitch. Profile before you fix a hitch, because not every hitch is a first load (quality-review.md, "First-use hitch").

An unpublished clip can be previewed in Edit mode: a rig clone, `KeyframeSequenceProvider:RegisterKeyframeSequence`, and one Heartbeat connection that calls `StepAnimations(dt)`, moves the root at the clip's built speed and sets the camera. Wait for the track's `Length` to rise above 0 before the first step (Importing sequences). Such a preview is not a test of the game's movement system; that needs the published clip and the real input path.

## Planted feet

`scripts/Feet.lua` works on a stock R6 rig. Floor targets are in root space (x right, z forward negative, the floor 3 under the root); a target is `{x, z, yaw}` or a function of time returning `{x, z, yaw, lift}` so a foot can step or pivot.

- `Feet.flat(targets)` is the default post pass for authored clips. A copy of a reference keeps its own leg motion unless the requester chose replanted feet (SKILL.md, "Always start from a reference", step 4). Each leg stands straight up on its floor target with the sole flat; it slides under the torso or up into it to stay connected (at least half of its top face under the torso's bottom face, touching it), and tilts only for the distance a slide cannot cover. `Feet.flatLeg(tp, s, spec)` solves one leg.
- `Feet.post(targets)` is the older solver: it aims every leg from its hip and tilts the sole. The leg only slides along the torso's up axis (up is hidden inside the torso, down is a gap), and four passes raise the aim until the lowest corner is on the floor. A pivot turns the leg about the hip-to-sole line, so the sole centre stays put. Use it only where a request asks for it.
- `Feet.stand(torsoPose, side, x, z, yaw, lift)` returns the leg pose that puts the sole centre on a floor point with the toe at yaw degrees, and the hip gap it needed. `Feet.gap` says how far a torso pose leaves a leg short. Plan the torso drop with the turn: a rigid leg cannot bend.

## Custom r6-style rigs

`scripts/RigFeet.lua` is `Feet.lua` with the rig's geometry as input, for rigs that are not stock R6 (joints named by part, hips at the top centre of longer legs). `RigFeet.fromRig(rig, "Torso", "RightLeg", "LeftLeg")` reads the hips from the leg joints' C0, the leg vector from C1 and the part height, the sole from the part size and the floor from the rest pose; `RigFeet.new(geom)` gives `stand`, `post` (the same target format as `Feet.post`, plus a `stats.gap`) and `sole(poses, s)` for the foot check. The joints' C0 and C1 must have no rotation. `Poser.fromSequence(kfs, Poser.wrapsOf(rig))` and `Poser.bake(clip, Poser.attach(rig), 30, name, length, warm)` work on such rigs as they are.

`scripts/examples/armored-warrior/WarriorClips.lua` is a worked example: idle, walk and run keyed as loop rows `{u, lift, twist, side, x, y, z}`, the torso bent at the waist, and each foot a `gaitFoot` (planted for the duty fraction while the sole slides back exactly at the root speed, then a Catmull-Rom swing through `{w, zFrac, lift}` points). Its walk runs 4.8 studs/s on a 0.84 s cycle, duty 0.59 and a 2.38 stud stance, with 0 slide and 0 hip gap. Foot check: the lowest sole corner within 0.005 of the floor counts as planted; report the planted slide, the hip gap and any corner under the floor; in Play, sample the leg bottoms each Heartbeat while the character moves at the game's speed.

For creatures and other Motor6D rigs, see [custom-rigs.md](custom-rigs.md).

## Source transfer and review tools

Other sessions may run their own `serve.js` on the usual ports; check what is listening (`netstat -ano` on Windows) and the process command line, start yours on a free port and change `PORT` in the loader. `LoadTest.lua` (Edit, with `serve.js` serving the scripts folder on port 8767) creates a fresh `ServerStorage.PoserTest` with new ModuleScripts each run, checking syntax first, so a changed module is really required again. `serve.js` serves one folder flat by file name; to load an example's modules, serve a folder that holds the core modules and the example's modules side by side. Delete the test folder at the end of the task.

`EditStrip.lua` (Edit) adds `_G.editStrip` (anchored ghosts posed by forward kinematics, a floor and two lights, painted as a mannequin unless `plain = false`; it returns the `screen_capture` camera and look-at points), `_G.feet` (lowest sole corner, planted slide, hip gap, planted sole tilt, torso contact and the share of the leg top that hangs off the torso, per leg) and `_G.clearStrip`. A night sky hides the poses: raise `Lighting.ClockTime` for the capture and restore it right after.

Do not review motion with bursts of full-screen copies. A copy every 0.4 s stalled Studio for 300 to 2300 ms and returned stale frames. Use `screen_capture` in Play, or hold the pose (the `PoseHold` attribute in `LocomotionClient.lua`) and capture once; record a video (Review videos) when motion must be seen.

Studio traps in strips and captures:

- Parts joined by `WeldConstraint` do not follow an anchored root moved by CFrame in an Edit strip. Place each part by its offset.
- A pause at an event time can overshoot by a frame and fire the event. Pause a few frames before it.
- A helper that closes over a clip table keeps measuring the old clips after the clip module reloads. Rebuild the helper after every reload.
- On some rigs the Motor6Ds carry the names of their Part1 parts, so `FindFirstChild(name, true)` can return the motor before the part. Resolve parts through `motor.Part1`.
- The Edit camera turns back to its focus. Set `Camera.Focus` together with `Camera.CFrame`.
- The strip lights (brightness 3) blow out a daytime place whose bloom threshold is 1. Dim the lights or the bloom for the capture and restore the place's lighting after it.
- When Studio opens on the start page behind an access dialog for another place, reopen the place with `-task EditPlace`.

Use the available Studio source-edit API or project sync. If the existing workflow needs the local source server, `node scripts/serve.js <outDir> <luaDir> 8766` serves `/stand/<Name>.lua` and accepts decoded text at `/put?name=...`. It is an optional transport, not an animation dependency. Restore temporarily changed Studio settings after the task.

After updating ModuleScript.Source, use fresh module instances or a fresh session when require caching would otherwise hide the update. Read back the source if an editor or sync tool can overwrite it. Validate only in the execution context supported by the bridge.

After refactoring clip source, sample every pose of every clip against a backup of the old source and compare the numbers, and confirm that the weapon solve cache (`WeaponRig.lua`) still hits every entry. Only a numeric diff proves a refactor changed nothing: a split of one clip module matched within 3.6e-7 studs, with 169 of 169 cache hits.

`Strip.lua` and `scripts/examples/stand-combat/StandStrip.lua` create actual ghost rig instances for Client-mode pose inspection. Adapt their paths, contexts, views, and sampled times; remove temporary ghosts when finished. `ReadClips.lua` reads Edit-mode sequences and writes rounded pose decodes through the server. Its stock C0 rotations must be replaced with inspected wraps for a custom rig.

Before cloning a live character, check `Archivable`. If it is false, `Clone()` returns nil. Save the original value, enable it for the inspection clone, and restore it afterward. `StandStrip.lua` sets it true without restoring it; account for that when adapting the helper. Its exported function is `_G.standStrip(clipName, times, spacing, facing, zOff, dioClip, dioOffset)` (the last two pose the user's body clip beside the companion's).

For an inspected stock arm, `root.CFrame:VectorToObjectSpace(-arm.CFrame.UpVector)` reports the arm direction in root axes (X sideways, Y up, negative Z forward). This normalized direction does not measure hand position, grip error, or a world-space contact; use the endpoint checks in [r6-mechanics.md](r6-mechanics.md) for those.

`AnalyzeClips.js` gives legacy Euler range tables. Use `check_decode.py` for rotation-aware local seam and sample measurements. Neither tool sees world-space contacts or proves successful playback. Use live observations for those claims.

## Review videos (scripts/video)

When the requester asks for videos, record and send an MP4 of every move or effect you finish or change until they say stop; otherwise record only when a request asks. These tools run on Windows. The numbers below were measured on a modest machine (4-core CPU, 6 GB RAM, SATA SSD).

1. Bring Studio to the front, start Play, set QualityLevel 21. The Roblox top bar cannot be turned off from execute_luau (`SetCore("TopbarEnabled")` returns ok and does nothing), so crop it with the recorder's window offsets (`record.ps1 -top 233` and the matching left, right and bottom offsets for the viewport under the top bar).
2. Start `record.ps1 -dir <take> -seconds <n> -scale 1.0` in the background, then drive the take from one execute_luau call. The call runs about 2 to 3 s after the recorder starts; put 1.5 s of lead in the take script and write `DateTime.now().UnixTimestampMillis` marks; `times.txt` starts with the recorder's Unix ms, so a mark minus that gives the frame time. Keep every loop bounded in time: a `repeat until` on a MoveTo arrival hung the call until execute_luau timed out. An execute_luau call once arrived 16 s after the recorder started: record 18 s windows and check that the take mark sits inside the window before you encode.
3. `GDI CopyFromScreen` costs 35 to 42 ms per frame in Play, so the recorder gives 25 to 27 fps with a 1 ms timer (`timeBeginPeriod`). JPEG work runs on four threads from a queue of 16. Do not write raw frames: 76 MB/s of raw frames stalled the recorder for 6.8 s and Studio for 0.7 s. Check `frames median/worst` and the recorder's gaps. Paging causes stalls (one 1.9 s stall at 15.6 of 18.9 GB committed); close heavy browser tabs before recording. With little free memory a take dropped to 13.7 fps; a Play restart plus one unrecorded warm-up run of the moves gave clean takes at 20.5 to 21.3 fps. After about an hour of Studio a 6 GB machine dropped 14 to 22% of frames; restart Studio before recording (0 to 6% dropped after the restart). Record shots as separate short takes: one 75 s take dropped 548 frames at 14 fps, 10 to 22 s takes at `-scale 0.6` ran 20 to 22 fps with 0 drops.
4. `node serve_frames.js <scratchpad> 8790`, open `http://localhost:8790/encode.html` in the built-in browser. `javascript_tool` runs in an isolated world: start work by injecting a `<script>` element (`encode([{dir, from, to}], "name.mp4", 8e6)`) and read progress from the page text. The page encodes H.264 baseline with WebCodecs from the real frame times and writes a faststart MP4 with its own muxer.
5. Check the result with `peek.js` (inject it with `demux.html` loaded): it decodes with `VideoDecoder`. A `<video>` seek in a hidden browser pane does not repaint, so a canvas grab returns the same frame every time; that once made a good recording look frozen.
6. Camera: a scripted camera bound after `Enum.RenderPriority.Camera` shows the body; add `hrp.CFrame:VectorToWorldSpace(hum.CameraOffset)` to keep a move's camera kick. Test every angle with `sheet.ps1` contact sheets: accessories and floating props block side angles, and a move that steps forward into a target puts the target in one of them. A cinematic move needs open space: an obstacle within the front shot's distance fills the frame. A weapon held forward hides behind the body from a camera straight behind, and back pieces hide the far leg. A high rear camera (7 up, 10.5 back) looks over the head to the target. Hide the cursor during a take (`UserInputService.MouseIconEnabled = false`). A move that turns toward the camera look turns toward a scripted side camera; make such turns follow the aim point. When the body follows the camera look (`RotationType` CameraRelative), aim the camera at the target every frame of a test, or every punch whiffs, and switch that rotation off for side takes. Put review cameras on the same shoulder as the game camera: a camera on the other shoulder hid the arm in every capture. Pick angles where the key parts show: for a held weapon, a rear three-quarter view about 58 degrees off the back on the weapon side (from 22 degrees the blade hid behind the fist).
7. Xbox Game Bar (Win+Alt+R through `keybd_event`) records Studio at the same 26 fps, but its video starts about 3 s before the file's CreationTime, and the first press after idle is often ignored.
8. **Sound.** `record_audio.ps1 -dir <take> -seconds <n>` captures the default output device with WASAPI loopback (C# COM interop, no install), places every packet by its QPC time so silence and stalls cannot shift the timeline, and writes `audio.wav` (16-bit PCM), `audio_start.txt` (Unix ms of sample 0) and `audio_live.txt` (written the moment capture starts). `encode_av.html` (served by `serve_frames.js`) takes segments `{dir, from, to, crop: {x, y, w, h}, audio: "<dir>/audio.wav"}`, slices the WAV to each segment by the two start times, encodes H.264 High plus AAC-LC 160 kbps with WebCodecs, and muxes both tracks: `encode(segments, name, bitrate, gain)`. Check the result with `decodeAudioData` on the file (duration, peak, samples over 0.99) and `peek.js` for the frames. The capture already reaches full scale, so encode at gain 0.9 (1.4 clipped at 1.16). The audio recorder started 1.2 s after the video recorder; expect the video to start 1.1 to 1.4 s before the audio.
9. **Traps in takes.** `execute_luau` resets a Scriptable camera to Custom when the call returns, and calls to the same Studio run one after another, so a scripted camera cannot hold while a key is pressed from another call. What worked: a probe LocalScript authored in Edit (`scripts/examples/three-sword-kit/TakeCam.lua`) watches a workspace attribute, places the character, keeps the default camera behind so the cast still aims along the camera look, and switches to a scripted shot the frame the cast starts, then back. Delete it afterwards. The recorders need 2 to 14 s to compile under memory pressure: start them in the background and press the key only after `f00001.jpg` and `audio_live.txt` exist. Trim each cinematic segment to start at the cast mark plus 40 to 60 ms, or it opens on the reset camera. Real keys from `keybd_event` do nothing in Play until one click inside the game view gives it keyboard focus. Studio's device emulation letterboxes the game, so find the game rectangle on a full screenshot first and set the recorder offsets from it. A Play client whose `CurrentCamera.ViewportSize` reads 1, 1 draws no frames even with Studio in front: restart Play. Attribute signals are deferred, so an attribute set to 0 and then 3 in one call fires its handler twice with 3; set it once per take to a new value. The client VM cannot HttpGet and cannot use VirtualInputManager (other test limits: Networked actions, hits and knockback).
10. **Setting up a take.** Record a demo of the game's movement or combat through its real input path (real key presses into its own camera and controllers); a scripted `Humanoid:Move` and camera bypassed the game's feel. Use a scripted camera or Move only for a special angle the requester asks for. Place the player's character from the client: a server `PivotTo` on it did not hold. To show combat, script a demo pilot or an attacking dummy; block and parry clips need an attacker. Start every fighter at full health and outside aggro range, move the player in on the same timer as the demo, and end the video before a death.

## Blender review videos

A render script that stops at the scene end cuts any clip longer than the scene and jumps back each loop (six of eight reference walks were cut at frame 40). Pass the last frame of the cycle (`frames - 1`) for every loop video and look at a sheet of the rendered frames before sending.
