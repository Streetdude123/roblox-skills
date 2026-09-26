# Runtime and export contracts

Read this before using the bundled scripts. These contracts describe the current source, not an idealized animation engine. Preserve the existing project runtime unless changing it is part of the task. Engine references are linked in [sources.md](sources.md).

## Contents

- Inspect and install only what is needed
- Poser clip contract
- Locomotion and overlays
- Importing sequences
- Baking and export
- Native Animator playback
- Source transfer and review tools

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
| Clips ModuleScript | Modules | `scripts/ClipsLocomotion.lua` |
| Locomotion ModuleScript | Modules | `scripts/Locomotion.lua` |
| Client entry | StarterPlayerScripts | Adapt to the requested controls and existing controller. |

`Clips.lua` is the larger DIO example and depends on project Config and assets. It is not standalone. `LocomotionClient.lua` includes sprint and PoseHold behavior; do not install those controls for an unrelated animation request. Create a separate inspected R6 rig for export when needed.

## Poser clip contract

A clip is `{name, length, loop, joints}` plus the optional motion fields below. Times and length are seconds. Each joint key is `{t, r, p, e, d, s, tn}`: r is `{lift, twist, side}` in degrees, p is a parent-axis Vector3 offset, e names the curve into the key, d and s are the direction and parameter of a named ease, tn is the key's tension.

| Field | Meaning |
| --- | --- |
| `curve = "spline"` | Keys without e are `auto`: a cubic Hermite curve per channel (lift, twist, side, x, y, z) whose tangent keeps the speed through a breakdown, is flat where the channel turns around, and is clamped (Fritsch-Carlson) so nothing overshoots between keys. Without this field a key without e is the legacy `quad out`, so old clips play exactly as before (checked: eleven DIO clips sampled identically at 60 fps). |
| `e` | `auto`, `flat` (zero speed at this key), `smooth` (unclamped Catmull-Rom), `linear`, `step` (hold the previous key until this one), or a legacy ease name (`quad`, `cubic`, `quart`, `sine`, `expo`, `back`, `elastic`, `snap`) that shapes the segment into this key. `auto`, `flat`, `smooth` and `step` also work inside a legacy clip. |
| `tn` | 0 normal, 1 flat, below 0 looser. |
| `lag = {[joint] = seconds}` | Samples that joint's curve later. A one-shot is done at `length` plus the largest lag; a loop wraps. |
| `springs = {[joint] = preset or {f, z, r}}` | Second order dynamics on the sampled channels (presets `lead`, `follow`, `drag`, `heavy`, principles.md). State resets on `play`; `hold` and speed 0 freeze it; `play` with `startAt` runs it from 0 so a paused pose matches. |
| `life` and `lifeRate` | Slow two-octave noise on the rotation channels: a number spreads its degrees over the torso (1), head (1.4) and arms (1.2), a table gives degrees by joint; legs get none. Default rate 0.35 Hz. |
| `post(poses, t, ctx)` | Runs after curves, lag, life and springs on the pose-space CFrames of every joint (the torso pose is in root space). `Feet.post` plants the legs here. It may only replace poses of joints listed in `joints`. |
| `events` | Plain data such as `{hit = 0.29}` for the caller to schedule from the clip clock. |
| `warp = {{t, speed}, ...}` | A speed curve on the clip's own clock, linear between points (the Asta kit, 2026-09-22). Play advances the clip by `dt * speed * warpAt(t)`, so a load can run at 0.8, a strike at 1.3 and the contact hang at 0.3 to 0.45 without rekeying. Keys, lag, events and props stay in clip time. `Poser.warpAt(clip, t)` reads it, `Poser.realTime(clip, t)` converts a clip time into real seconds (feed the server's hit and lock times from it), `Poser.check(clip, {real = true})` measures in real seconds, and `Poser.bake` bakes in real seconds so the asset plays at the speed play shows. Springs step in clip time, as in play. |

Keys must be nonempty, finite, ordered by unique time, and inside the declared duration. `compile` sorts and caches CFrames, but does not validate that contract. After changing keys, rebuild the clip or clear its compiled state before resampling. A procedural joint receives `(t, ctx)` and returns a pose table or a pose-space CFrame. It must receive the context fields it actually uses.

The easing belongs to the destination key in Poser. Roblox PoseBase documents easing toward the next pose, so do not copy native easing fields onto destination keys without converting their semantics. The current importer instead uses linear interpolation throughout.

`attach` gathers Motor6Ds by Part1.Name. `play` has one active clip per attached rig and options `fadeIn`, `speed`, `startAt`, `onDone`, `blend`. `blend = "inertial"` (the default for spline clips) keeps the new clip moving from its first frame under an offset from the old pose that dies away on a smoothstep over `fadeIn`; `"cross"` (the legacy default) fades from the frozen old pose. Neither carries the old clip's velocity. `sample` returns an authored pose-space CFrame, not a world frame. `hold` pauses the clip time temporarily; `setSpeed(0)` holds sampling time, but procedural joints that read a changing ctx can still move. Freeze the relevant context as well when a true hold is required.

`Poser.check(clip, opts)` returns the motion metrics (motion-metrics.md) with a `text` line; `Poser.dump(clip, fps, name)` returns decode text for `motion_check.js`; `Poser.posesAt(clip, t)` returns every joint's final pose (springs run from 0, post applied); `Poser.each(clip, fps, visit)` visits the clip as play would show it. All four accept `opts.ctx` or `clip.ctxAt` for procedural joints.

Transforms are written in PreSimulation. Do not add another writer to the same joint unless composition and write order are explicit. Changing C0 each frame is not the ordinary authoring path. The fade blends from the pose the rig last wrote (`rig.last`), not from `motor.Transform`: the Humanoid's Animator zeroes every Transform between PreAnimation and PreSimulation, so a `play` called inside a step (an `onDone` hand-over to the idle) used to blend from the default pose and the body jumped for a frame (weapons.md, "The twitch when a move hands back to the idle"). The fade smooths pose differences but does not prove a clean path or matching velocity.

## Locomotion and overlays

`Locomotion.start` controls idle/walk/run/air/land through `Clips.DioMove`. It stops the default tracks for the custom setup. Its Heartbeat update supplies speed, phase, walk, run, air, jump, land, and stand context.

The current controller uses a 13-stud cycle distance and a run blend over speeds 18 to 26. Those are project choices. Its landing envelope is time-based and is not scaled by measured fall speed. Changing documentation does not change that runtime behavior.

`Locomotion.override` replaces the rig's one active clip. Omitted joints are not sampled from locomotion; with no other writer they retain their previous Transform. For a walking upper-body action, build an explicit composite clip: take selected upper-body joints from the action and evaluate remaining joints from the current locomotion context. Alternatively use the project's native masked playback. Never describe a sparse override as an automatic overlay.

An interrupted play replaces the previous callback. The caller must manage cancellation and restoration of movement state; do not rely on the interrupted `onDone`. Restore captured movement settings at the intended state transition, not a hard-coded universal one-second limit.

Poser has no marker dispatcher. Schedule project events from the same animation clock with clear pause, speed, and cancel behavior. For skipped frames, detect crossings of event times, not floating-point equality. Do not schedule a gameplay hit with an unrelated wall-clock delay and expect it to follow hit-stop automatically.

Motor6D.Transform is not replicated. A custom networked action needs the project's authoritative action identity and timing, then local playback for observers. Verify it with a second client. Keep hit validation in the existing server gameplay system; a locally posed fist is not a server hitbox.

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

Roll scaling decomposes orientation into Euler angles and is not general retargeting near a singularity. For a grounded user copying a floating stand, solve contacts on the target rig and inspect the result instead of relying on scale factors alone.

## Baking and export

`Poser.bake` creates real KeyframeSequence, Keyframe, and nested Pose instances from the same simulation as play (lag, life, springs and the post pass included, stepped at 60 fps and kept on the bake grid plus the exact end, so bake at 60 fps or at a rate that divides it). It refuses a length over 60 s: a held clip such as `DioPoint` carries `length = 100000` so it never ends in play, and a bake of it with no explicit length looped for millions of frames, flooded memory and crashed Studio behind a "Save File Failure" dialog on 2026-09-22 (the unsaved place was lost). Pass a bake length for every held clip and bake at most five clips per `execute_luau` call. It samples procedural clips using `ctxAt(t)` when provided. `Bake.lua` is an Edit-mode project helper with configurable root, rig, and clip list; inspect and adapt those inputs first.

Account for the current baker's behavior before delivering its output:

| Behavior in bundled source | Required delivery check or repair |
| --- | --- |
| Sets Action priority for every clip | Set the appropriate project priority on the actual sequence, including Idle or Movement when intended. |
| Creates ancestor poses with weight 1 | Inspect ancestor channels on partial-body exports. Do not unintentionally key the torso or suppress underlying motion. Use the target editor/runtime's supported masking behavior and verify it. |
| Emits Linear samples | Inspect fast strikes, stepped holds, and curved paths between samples. Increase sampling or preserve authored keys where needed. |
| Does not write markers | Add required KeyframeMarker instances at the exact planned event times and verify playback. |

Keep the source and exported copy separately. Check the hierarchy against the rig's Motor6D tree, not a guessed naming scheme. Root hierarchy poses must not introduce unintended motion. Preserve required markers when removing editor metadata; KeyframeMarker is animation data.

A KeyframeSequence stored in AnimSaves is not automatically a published animation asset. Verify how the installed editor loads it. Do not claim successful publication or an animation ID until that operation returns one.

## Native Animator playback

Use the project's Animator and `Animator:LoadAnimation` for published animation assets. Verify asset access, priority, loop state, fades, and intended joint coverage. AnimationTrack priority is evaluated per joint; avoid unnecessary keys that take ownership of otherwise untouched body parts.

For replication, the Animator must originate on the server. Player-character tracks started on that player's client can replicate through it; non-player rigs need server-started playback to replicate. A locally created Animator does not provide that replication. Check current official docs when modifying this integration.

Connect `GetMarkerReachedSignal` for native animation markers when the project uses them. Keep cosmetic events and authoritative gameplay decisions in their existing roles. Test the entry, exit, and interruption paths relevant to the action.

## Planted feet

`scripts/Feet.lua` works on a stock R6 rig. `Feet.stand(torsoPose, side, x, z, yaw, lift)` returns the leg pose that puts the sole centre on a floor point in root space (x right, z forward negative, the floor 3 under the root) with the toe at yaw degrees, and the hip gap it needed. The leg only slides along the torso's up axis (up is hidden inside the torso, down is a gap), the rotation carries the sole across, and four passes raise the aim until the lowest corner is on the floor. A pivot turns the leg about the hip-to-sole line, so the sole centre stays put. `Feet.post(targets)` returns a post function and a stats table; a target is `{x, z, yaw}` or a function of time returning `{x, z, yaw, lift}`. `Feet.gap` says how far a torso pose leaves a leg short. Plan the torso drop with the turn: a rigid leg cannot bend.

## Source transfer and review tools

`LoadTest.lua` (Edit, with `serve.js` serving the scripts folder on port 8767) creates a fresh `ServerStorage.PoserTest` with new ModuleScripts each run, checking syntax first, so a changed module is really required again. Delete the folder at the end of the task. `EditStrip.lua` (Edit) adds `_G.editStrip` (anchored ghosts posed by forward kinematics, a floor and two lights, painted as a mannequin unless `plain = false`; it returns the `screen_capture` camera and look-at points), `_G.feet` (lowest corner, planted slide of the sole centre and hip gap per leg) and `_G.clearStrip`. A night sky hides the poses: raise `Lighting.ClockTime` for the capture and restore it right after.


Use the available Studio source-edit API or project sync. If the existing workflow needs the local source server, `node scripts/serve.js <outDir> <luaDir> 8766` serves `/stand/<Name>.lua` and accepts decoded text at `/put?name=...`. It is an optional transport, not an animation dependency. Restore temporarily changed Studio settings after the task.

After updating ModuleScript.Source, use fresh module instances or a fresh session when require caching would otherwise hide the update. Read back the source if an editor or sync tool can overwrite it. Validate only in the execution context supported by the bridge.

`Strip.lua` and `StandStrip.lua` create actual ghost rig instances for Client-mode pose inspection. Adapt their paths, contexts, views, and sampled times; remove temporary ghosts when finished. `ReadClips.lua` reads Edit-mode sequences and writes rounded pose decodes through the server. Its stock C0 rotations must be replaced with inspected wraps for a custom rig.

Before cloning a live character, check `Archivable`. If it is false, `Clone()` returns nil. Save the original value, enable it for the inspection clone, and restore it afterward. The bundled `StandStrip.lua` sets it true without restoring it; account for that when adapting the helper. Its exported function is `_G.standStrip(clipName, times, spacing, facing, zOff, dioClip, dioOffset)`, not `_G.strip2`.

For an inspected stock arm, `root.CFrame:VectorToObjectSpace(-arm.CFrame.UpVector)` reports the arm direction in root axes (X sideways, Y up, negative Z forward). This normalized direction does not measure hand position, grip error, or a world-space contact; use the endpoint checks in [r6-mechanics.md](r6-mechanics.md) for those.

Without Studio, decode text is enough to look and measure: `scripts/r6_render.py` draws the stock R6 box figure with the same C0 and C1 offsets and the same pose convention as Poser (a part = its parent x C0 position x pose x its offset), so `Poser.dump` output, `ReadClips.lua` decodes and the motion capture retarget all render the same way; `scripts/beats.py` measures moves and holds of the tips. They need Python 3 with numpy and pillow. The workflow and its limits are in [real-motion.md](real-motion.md).

Poser itself also runs without Studio. `scripts/poser_offline.py` runs a clip module (`ExampleClips.lua` or any ModuleScript source that returns a table of clips) with the real `Poser.lua`, `Tw.lua`, `Feet.lua` and whatever else it requires, on the Luau command line tool with a Roblox API stand-in (`scripts/offline/roblox_shim.luau`: Vector3, CFrame, `typeof`, stub services). It prints `Poser.check` for every clip and writes `Poser.dump` decode text, which `r6_render.py`, `beats.py`, `motion_check.js` and `scripts/feet_check.py` (the `_G.feet` numbers on decode text) then read. Get `luau` from the Luau releases page (github.com/luau-lang/luau/releases, `luau-ubuntu.zip`, `luau-macos.zip` or `luau-windows.zip`) and pass `--luau` or put it on PATH.

```sh
python3 scripts/poser_offline.py scripts/ExampleClips.lua out --luau ./luau
python3 scripts/feet_check.py out/Cross.txt
python3 scripts/r6_render.py out/Cross.txt sheets --view rear34,side --every 2 --trail "Right Arm"
```

Checked on 2026-09-26: the Luau `math.noise` gives the Roblox value (0.5098056793212891 at 1.25, 5.75), so the life layer matches; rounding every CFrame and Vector3 to 32-bit floats, as Roblox stores them, changed no number. With the `Feet.lua` of the commit that recorded the Studio numbers, the offline Cross gives frozen 0, still 0, rest 38.9 (Studio 38.1), stops 2.08 (2.1), unison 4.17 (4.2), contrast 5.9 (6.0), spread 0.7 (0.7) and the Guard contrast 1.2 (1.2). The rest differs by about one joint frame; the cause was not found. The foot check on decode text reads within 0.01 stud of Studio's (the decode rounds to 0.1 degree and 0.01 stud). The runtime (`Rig:play`, the inertial blend, Motor6D writes, replication) does not run offline; play it in Studio.

`AnalyzeClips.js` gives legacy Euler range tables. Use `check_decode.py` for rotation-aware local seam and sample measurements. Neither tool sees world-space contacts or proves successful playback. Use live observations for those claims.

## Video of a clip for Lepy (scripts/video)

When to record: on 2026-09-24 (night) he said "Record videos from now on please, until i say stop recording videos", which replaces "only record a video when I ask you to" (2026-09-23). Until he says stop, record and send an MP4 of every move or effect you finish or change; after he says stop, record only when a request asks. Measured on his machine (Ryzen 5 2400G, 6 GB, SATA QLC SSD) on 2026-09-23.

1. Bring Studio to the front, start Play, set QualityLevel 21. Hide nothing in the game: the Roblox top bar cannot be turned off from execute_luau (`SetCore("TopbarEnabled")` returns ok and does nothing), so crop it: `record.ps1 -top 233` (window rect offsets left 11, top 233, right 470, bottom 231 give the 1454 x 584 viewport under the top bar).
2. Start `record.ps1 -dir <take> -seconds <n> -scale 1.0` in the background, then drive the take from one execute_luau call. The call runs about 2 to 3 s after the recorder starts; put 1.5 s of lead in the take script and write `DateTime.now().UnixTimestampMillis` marks; `times.txt` starts with the recorder's Unix ms, so a mark minus that gives the frame time. Keep every loop bounded in time: a `repeat until` on a MoveTo arrival hung the call until execute_luau timed out.
3. `GDI CopyFromScreen` costs 35 to 42 ms per frame in Play, so the recorder gives 25 to 27 fps with a 1 ms timer (`timeBeginPeriod`). JPEG work runs on four threads from a queue of 16. Do not write raw frames: 76 MB/s of raw frames on this disk stalled the recorder for 6.8 s and Studio for 0.7 s. Check `frames median/worst` from the take and the recorder's gaps; one 1.9 s Studio stall came from paging (commit 15.6 of 18.9 GB); close heavy browser tabs before recording.
4. `node serve_frames.js <scratchpad> 8790`, open `http://localhost:8790/encode.html` in the built-in browser. `javascript_tool` runs in an isolated world: start work by injecting a `<script>` element (`encode([{dir, from, to}], "name.mp4", 8e6)`) and read progress from the page text. The page encodes H.264 baseline with WebCodecs from the real frame times and writes a faststart MP4 with its own muxer (Windows and Chrome both read it).
5. Check the result with `peek.js` (inject it with `demux.html` loaded): it decodes with `VideoDecoder`. A `<video>` seek in a hidden browser pane does not repaint, so a canvas grab returns the same frame every time; that once made a good Game Bar recording look frozen.
6. Camera: a scripted camera bound after `Enum.RenderPriority.Camera` shows the body; add `hrp.CFrame:VectorToWorldSpace(hum.CameraOffset)` to keep the combo's camera kick. Test every angle with `sheet.ps1` contact sheets: on his avatar a companion accessory stands at the right side and the burning grimoire at the left, and the combo steps forward into the dummy, so each side angle has one blocker. A cinematic move needs open space: an obstacle within the front shot's distance fills the frame.
7. Xbox Game Bar (Win+Alt+R through `keybd_event`) does record Studio, at the same 26 fps, but its video starts about 3 s before the file's CreationTime, and the first press after idle is often ignored.
8. Water Mage takes (2026-09-24): with 487 MB free and Studio at 6 GB private, a take dropped 185 frames (13.7 fps) and Studio stalled 1.6 s; a Play restart plus one unrecorded warm-up run of the moves (textures loaded, first ragdoll done) gave four clean takes at 20.5 to 21.3 fps with 0 drops. Hide the cursor during a take (`UserInputService.MouseIconEnabled = false`; a Scriptable camera releases the camera lock and shows it). A move that turns toward the camera look (the water laser) turns toward a scripted side camera; make such turns follow the aim point. Over-the-shoulder shots are blocked by his avatar's companion accessory and the floating grimoire; a high rear camera (7 up, 10.5 back) looks over the head to the target. `-scale 0.75` gives 1090 x 438; three takes of 6 to 9 s made a 23 s, 13.6 MB MP4.
