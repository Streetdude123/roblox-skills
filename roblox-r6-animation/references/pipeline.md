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
| Clips ModuleScript | Modules | `scripts/ClipsLocomotion.lua` |
| Locomotion ModuleScript | Modules | `scripts/Locomotion.lua` |
| Client entry | StarterPlayerScripts | Adapt to the requested controls and existing controller. |

`Clips.lua` is the larger DIO example and depends on project Config and assets. It is not standalone. `LocomotionClient.lua` includes sprint and PoseHold behavior; do not install those controls for an unrelated animation request. Create a separate inspected R6 rig for export when needed.

## Poser clip contract

A clip is `{name, length, loop, joints}`. Times and length are seconds. Each joint key is `{t, r, p, e, d, s}`: r is `{lift, twist, side}` in degrees, p is a parent-axis Vector3 offset, and e/d/s select easing, direction, and the back-ease parameter.

Keys must be nonempty, finite, ordered by unique time, and inside the declared duration. `compile` sorts and caches CFrames, but does not validate that contract. After changing keys, rebuild the clip or clear its compiled state before resampling. A procedural joint receives `(t, ctx)` and returns a pose table or a pose-space CFrame. It must receive the context fields it actually uses.

The easing belongs to the destination key in Poser. Roblox PoseBase documents easing toward the next pose, so do not copy native easing fields onto destination keys without converting their semantics. The current importer instead uses linear interpolation throughout.

`attach` gathers Motor6Ds by Part1.Name. `play` has one active clip per attached rig and options `fadeIn`, `speed`, `startAt`, `onDone`. `sample` returns an authored pose-space CFrame, not a world frame. `hold` pauses the clip time temporarily; `setSpeed(0)` holds sampling time, but procedural joints that read a changing ctx can still move. Freeze the relevant context as well when a true hold is required.

Transforms are written in PreSimulation. Do not add another writer to the same joint unless composition and write order are explicit. Changing C0 each frame is not the ordinary authoring path. The fade blends from captured live transforms; this smooths pose differences but does not prove a clean path or matching velocity.

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

`Poser.bake` creates real KeyframeSequence, Keyframe, and nested Pose instances. It samples procedural clips using `ctxAt(t)` when provided. `Bake.lua` is an Edit-mode project helper with configurable root, rig, and clip list; inspect and adapt those inputs first.

Account for the current baker's behavior before delivering its output:

| Behavior in bundled source | Required delivery check or repair |
| --- | --- |
| Uses `floor(length * fps + 0.5)` | A non-grid duration can miss its exact endpoint. Include the exact duration sample when adapting the export, then compare final pose and duration. |
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

## Source transfer and review tools

Use the available Studio source-edit API or project sync. If the existing workflow needs the local source server, `node scripts/serve.js <outDir> <luaDir> 8766` serves `/stand/<Name>.lua` and accepts decoded text at `/put?name=...`. It is an optional transport, not an animation dependency. Restore temporarily changed Studio settings after the task.

After updating ModuleScript.Source, use fresh module instances or a fresh session when require caching would otherwise hide the update. Read back the source if an editor or sync tool can overwrite it. Validate only in the execution context supported by the bridge.

`Strip.lua` and `StandStrip.lua` create actual ghost rig instances for Client-mode pose inspection. Adapt their paths, contexts, views, and sampled times; remove temporary ghosts when finished. `ReadClips.lua` reads Edit-mode sequences and writes rounded pose decodes through the server. Its stock C0 rotations must be replaced with inspected wraps for a custom rig.

Before cloning a live character, check `Archivable`. If it is false, `Clone()` returns nil. Save the original value, enable it for the inspection clone, and restore it afterward. The bundled `StandStrip.lua` sets it true without restoring it; account for that when adapting the helper. Its exported function is `_G.standStrip(clipName, times, spacing, facing, zOff, dioClip, dioOffset)`, not `_G.strip2`.

For an inspected stock arm, `root.CFrame:VectorToObjectSpace(-arm.CFrame.UpVector)` reports the arm direction in root axes (X sideways, Y up, negative Z forward). This normalized direction does not measure hand position, grip error, or a world-space contact; use the endpoint checks in [r6-mechanics.md](r6-mechanics.md) for those.

`AnalyzeClips.js` gives legacy Euler range tables. Use `check_decode.py` for rotation-aware local seam and sample measurements. Neither tool sees world-space contacts or proves successful playback. Use live observations for those claims.
