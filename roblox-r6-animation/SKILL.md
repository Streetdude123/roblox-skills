---
name: roblox-r6-animation
description: Author, verify and hand off high quality R6 character animations IN CODE for Lepy's Roblox places - idle, walk and run cycles, attacks, summons, stand and weapon moves, time stops - with the Poser and Locomotion modules, numbers measured from professional clips, motion strip captures, KeyframeSequence baking and the Moon Animator round trip. This skill supersedes the generic roblox-animation skill for any character motion; never reach for the Animation Editor, TweenService on joints or AnimationTracks. Use whenever a Roblox animation must be created, judged, fixed, decoded or exported.
---

# Roblox R6 animation

This is Lepy's own animation practice. He cannot animate by hand, Claude cannot watch a clip play, and the first code posed clips were "horrid". The clips he loved were made with one process: design the beats as silhouettes, author with the move template below, push, capture a motion strip from the player's camera, read what the capture shows, change numbers, capture again, then bake. A session that skips the loop ships stiff clips. Every number here was measured from real clips or came from his feedback; do not guess amplitudes.

## What made the good clips good (read this before anything)

Snap keys 0.06 to 0.12 s apart on `cubic` or `quart` out. Every arrival key on `"back", "out"` with overshoot 1.2 to 1.5, never a hand placed overshoot key. Holds 0.10 to 0.20 s that keep creeping 2 to 4 degrees. The lag ladder: engine at T, head T + 1 to 2 frames, arms T + 2 to 3, legs T + 3 to 4, no two joints on the same key time in a snap. Limbs 60 to 140 degrees and the root 0.5 to 1.5 studs on a move; translation builds every pose. A recovery of at least 40 percent of the clip in two or three `sine inout` keys, the last equal to frame 0 or the next clip's first key. Beats named as silhouettes that read from behind and above, where the player's camera is. And nothing shipped without a strip capture.

## Session start (mandatory, before any key is typed)

1. Load this skill by name (`/roblox-r6-animation`) and read the reference for the kind of clip (`references/`), then the worked example of that kind in `scripts/Clips.lua` end to end.
2. Check the place: `get_studio_state`, then find `Poser`, `Locomotion`, `Clips` under `ReplicatedStorage.<Feature>.Modules` and the client that starts Locomotion. If they are missing, follow **Install into a fresh place** below first.
3. Start the source server (`node scripts/serve.js <outDir> <luaDir> 8766`) so long modules push through `HttpService:GetAsync`; `multi_edit` is the fallback for short files.
4. Set `settings().Rendering.QualityLevel = Enum.QualityLevel.Level21` in play and ask Lepy to keep Studio in front for captures and frame times.
5. Write the beat table in frames (time, engine pose, silhouette name, ease) and compute the hand direction of every arm key with the formula in the sign table. Only then write keys.
6. Plan the two captures now: rear three quarter first (the player's view), front second.

## Decision framework

- **Locomotion (idle, walk, run)**: one procedural clip driven by a per character controller; speed drives the walk phase so feet plant. Jump takeoff and landing are BEATS inside it and get move timing: a per joint envelope with the lag ladder, not one scalar. See `references/walk-cycles.md`, `references/idle-run-land.md`.
- **A move (attack, summon, cast, dodge)**: a keyed clip from the move template, played as an override, then handed back to locomotion. See `references/attack-timing.md`.
- **A weapon or stand overlay (guard, stance, point)**: a clip that drives Torso, Head and Arms only and leaves the legs to locomotion. A stand move wants the user planted: whip into a bladed point, then a breath only.
- **A stand rush, combo or finisher**: play the stand's own animation set raw through `Poser.fromSequence` (the model's clips beat anything authored by hand) with a procedural root for the float, and author only what the set lacks. See `references/the-world-clips.md`.
- **A cutscene**: only for a reel piece (the ultimate) or a move he asks for as cinema (the time stop). A gameplay move never takes the camera. Its body lock (WalkSpeed 0, AutoRotate off) lasts at most 1.0 s or ends at the settle key, whichever is first; the recovery blends under the walk with `fadeOut` 0.3.
- **Mocap or a commission**: when a clip needs full body acrobatics beyond what these numbers give.

## The move template (copy it, then fill the poses)

Frames are 60 fps (1 frame = 0.0167 s). Name every beat as a silhouette in a comment before the keys.

```lua
-- beats: FOLD (anticipation) -> APEX (the flare, "V flare") -> LAND (the pose, "raised claws") -> settle
Clips.Move = {
	name = "Move", length = 1.0,
	joints = {
		-- the engine: one clean arc, authored first
		["Torso"] = {
			K(0.00, REST.torso, REST.torsoP),
			K(0.08, COIL.torso, COIL.torsoP, "cubic", "out"),              -- snap in, 4 to 5 frames
			K(0.20, COIL.torso + creep(2), COIL.torsoP, "sine", "inout"),  -- the hold keeps moving 2 to 4 deg
			K(0.30, HIT.torso, HIT.torsoP, "back", "out", 1.25),           -- strike arrives with the overshoot in the ease
			K(0.42, HIT.torso, HIT.torsoP + V3(0, 0.03, 0), "quad", "out"),-- settle 6 to 8 frames later
			K(0.70, HIT.torso, HIT.torsoP, "sine", "inout"),               -- recovery keys every 0.25 to 0.3 s
			K(1.00, REST.torso, REST.torsoP, "sine", "inout"),             -- last key = frame 0 (or the next clip's first key)
		},
		-- the lag ladder: the same shape shifted per joint; never the engine's times
		["Head"]      = shifted 0.02 to 0.03 s, counters the torso twist one to one
		["Right Arm"] = shifted 0.03 to 0.05 s, an arc gets a middle key (up and over), arrival "back" 1.2 (pose) to 1.5 (flare)
		["Left Arm"]  = shifted 0.04 to 0.06 s
		["Right Leg"] = shifted 0.05 to 0.07 s, knee lift through p.Y, arrival "back" 1.3
		["Left Leg"]  = shifted 0.06 to 0.08 s
	},
}
```

Ease table: snap = `cubic`/`quart` out over 4 to 7 frames; arrival = `back` out 1.2 (a landing pose), 1.25 (a root drop), 1.3 (legs), 1.5 (a flare); hold = two `sine inout` keys 0.10 to 0.20 s apart that creep in the wind up direction; settle = `quad` out 6 to 8 frames after the arrival; recovery = `sine inout`, two or three keys, at least 40 percent of the clip. The sword kit's strikes read linear because they were hand keyed at 60 fps; in Poser, `quart` out into the hold and `back` out into the strike pose reproduce that shape with fewer keys. Use explicit overshoot keys only when Lepy will edit the clip in Moon Animator.

The caller for a gameplay move:

```lua
Locomotion.override(character, Clips.Move, {fadeIn = 0.06, fadeOut = 0.3})  -- fadeIn at most half the snap
humanoid.WalkSpeed, humanoid.AutoRotate = 0, false                          -- heavy moves only
task.delay(SETTLE_TIME, function() restore the humanoid end)                -- never through the recovery, never over 1 s
```
The VFX and the sound cue sit on the strike key, not the clip midpoint. An override writes only the joints it keys, so a walkable light hit overlays its legs on the locomotion pose. An interrupted clip drops its `onDone`; combo state lives in the caller, the cancel window opens at the settle key, early presses buffer to it. Hit stops: `rig:hold(0.05)` light, `0.09` heavy.

## Definition of done (every gate, every clip)

1. Pushed through the source server: `HttpService.HttpEnabled = true`, `GetAsync("http://127.0.0.1:8766/stand/<Name>.lua")`, `loadstring` syntax check, write `.Source`, then require a fresh clone of the whole feature folder (the Edit VM caches `require`). An open editor tab reverts a push; re-read `.Source`.
2. Strip round one from the rear three quarter (`scripts/Strip.lua`, `scripts/StandStrip.lua`), then one front capture. Move the camera 0.1 stud between captures. Describe what each ghost shows in words and compare with the beat table.
3. Read at least three limb directions as numbers even when it looks right. Change at least one number from what the capture showed.
4. Strip round two. A second round is mandatory; the second capture must show the change.
5. Run the move live with the real input, then `get_console_output`.
6. Profile: two seconds of idle frames with Studio in front (16 to 18 ms), then the first cast under 26 ms; warm meshes at join if not.
7. Bake to AnimSaves: moves at 60 fps, loops at 30 (`scripts/Bake.lua`).
8. Report with the beat table, the captures and the numbers read back. Never report after the first push. Never write "should look good" or "should read": either it was captured and read, or it is not done.

## The model for everything: how a professional idle works

Lepy set the idle in `references/idle-run-land.md` as the guide for all animation:

1. **One engine.** Pick the joint that drives the motion (the torso in an idle, a walk, a run, a landing, a swing) and animate it first as one clean wave or one clean arc.
2. **Everything else is secondary.** Head and arms follow the engine about a fifth of a cycle later at about half the amplitude; legs shift weight in phase on an idle, and land last on a move. In a recovery the head leads.
3. **Translation builds the pose, rotation carries the motion.** Feet placed with 0.3 to 0.5 stud offsets, the back foot turned out, arms hanging 0.05 to 0.3 lower, knees driving a stud forward in a run, legs folding a stud up in a landing. On R6 translation is the joint you do not have.
4. **Amplitude follows energy.** Idle 2 to 6 degrees and 0.04 studs; walk 30 to 45; run 60 to 80 with stud size translations; landing a 42 degree fold and a 1.1 stud drop; strike 130 degrees in 3 frames.
5. **Nothing is still and the loop never pops.** Every channel drifts (a constant twist or side moves 0.2 to 0.3 degrees on a slow sine), the last frame equals the first, the pose already reads at frame 0, and every period inside a procedural joint divides the loop length.

## The numbers that matter

**Authored move (what Lepy accepts, from the summon and The World remake)**
- Root: 0.5 to 1.5 studs of travel (a 1.6 stud burst in 4 frames, an apex 1.0 to 1.3 above the rest point, an overshoot 0.05 to 0.2 past it, a crouch 0.3 to 0.5, a lunge 0.5 to 1.0). Humanoid LIMBS stay under 0.5 studs of offset; stand limbs may travel 1 to 2.
- Limbs 60 to 140 degrees (a V flare `{22, 0, 128}`, a raised claw `{140, -20, -41}`, an arm sweep of 170 degrees of side).
- Holds 0.10 to 0.20 s in code (the sword kit's "2 to 4 frames" is a hand keyed 60 fps clip; the accepted code holds are 0.08 to 0.14 s of anticipation and 0.15 to 0.25 s on the landed pose).
- Follow through overshoot about 15 percent of the swing (`settle value = end value + 0.15 * swing`), supplied by the `back` ease.
- Feet: `legY = -torsoY - 2 * (1 - cos(lift)) + 0.02` keeps a crouch or a lunge on the floor.

**Idle, run and landing (from a professional R6 set)**
- Idle: one 3 s breath, torso lean 2.3 to 6 forward with a 0.04 sink, head nods 2 a fifth of a cycle later, arms 2 to 4, legs shift 4 to 11 in phase, staggered feet built with 0.3 to 0.5 stud offsets and a 12 degree turned out back foot.
- Run: 0.533 s cycle, torso lean 27 with hips twisting 25 each way and the head countering one to one, root 0.28 to 0.45 low with two bobs, legs -78 to +54 with the leg parts driving 1 stud up and 1.5 forward, arms -62 to +84 with forearm twists.
- Landing: fold to -42 and drop 1.1 studs in 5 frames, legs fold up 1.4, arms fly forward 64, hold 5 frames with a breath, recover on a decelerating curve with the head first, torso next, legs last. Weight it by fall speed: `landPeak = clamp((-vY - 12) / 38, 0.3, 1)` so a step down is a dip.
- Takeoff (target until a clip is decoded): driving knee 60 to 90 with 0.5 up and 0.6 forward, arms thrown 60 to 80 out, torso back 8 then forward 10, 3 frames of snap with a `back` 1.3 arrival, a 0.15 s apex hold with drift.

**Walk (from four community cycles and the Roblox default)**
- Cycle 0.76 s (run) to 0.92 s (walk) at speed 16; STRIDE 13 studs per cycle in the controller.
- Legs asymmetric: -45..+30 walk, -40..+50 run. Back leg pushed DOWN 0.1 to 0.27 studs so the planted foot stays on the floor; forward pass LIFTED 0.22 to 0.37 (the knee). Stance is 62 to 70 percent of the cycle with a plateau under the body; the swing is the other third with the knee driven up within two frames of toe off. A symmetric-time sine cannot make this; prefer an eight key cyclic table.
- Torso lean forward 5 to 7 (run 5 to 12), bob 0.1 up twice per cycle at the passing poses, run crouch 0.2 to 0.3. Torso twist 3 to 5 peaking at foot contact with the head countering 2 to 4.
- Arms 30 to 40 swing (60 run), wrist twist 20 to 30 following the swing, elbows out 5 to 12, arm parts dropped 0.1 to 0.3.
- Phase convention: 0 and pi are the passing poses; right foot contact at 1/8 of a walk cycle and 3/16 of a run cycle; leg p.Z negative is the foot forward. Run blends in from speed 18, so a place needs a sprint (26 gives the 0.5 s cycle).

**Attack (from a professional sword kit at 60 fps)**
- Snap into the wind up in 3 to 4 frames, hold, strike in 3 frames, follow through 4 frames with 15 percent overshoot, then 30 frames of smooth recovery. Over half the clip is recovery.
- Wind up: torso leans back 15 to 19 and twists 20 to 28 away, head looks down and counters the twist, weapon arm goes up and over, free arm out for balance.
- Strike: torso swings 32 degrees of pitch and 48 of yaw in 3 frames, arm sweeps about 130 degrees in 3 frames, head snaps the other way and keeps the face on the target through the whole swing. The kit's animator did not translate the torso; Lepy's clips should.
- Weapon idles are static bladed poses (torso twist 15 to 20 with the head counter turned, sword arm lift 65 side 47) with half a degree of drift.

**Stand clips (from The World's animation set, 60 fps)**
- Punch: 10 frames of load decelerating into the hold, 5 frames of strike with the biggest step in the middle, 5 of follow through (arm +9, lean +4), 5 of settle. Torso twist 124 degrees on the strike; the head counters 117 the other way; the fist keeps its angle and translates 0.62 studs (a piston). The end pose IS the next clip's start pose.
- Heavy: 12 load, 6 hold that keeps creeping 10 degrees, a 2 frame strike with the arm arcing over the head through one key, a leg thrown 1.1 up and 1.3 forward, 5 hold, 5 settle.
- Kick and stab: no load (the previous clip is the load), 10 frames of decelerating snap (39, 19, 12, 6, 2), 10 of drift. Roll is the strike channel on the stab (-5 to -55) and the uppercut (+30 to -33).
- Barrage: a 40 frame loop of 4 swings; each half beat is 5 frames from one extreme to the other (torso -47 to +62, head +44 to -65), snap then settle, instant reversal, 6 punches a second, root dead still.
- Float idle: 2.5 s, torso pitch -14.7 at the top to -19.5 at the bottom (1.5 s in, 1.0 s out, a sine in-out fits to 0.01 stud) with the torso part dropping 0.29 studs; head, arms and legs in phase. A stand idle is 2 to 3x a humanoid idle in the limbs and 6x on the bob. Never re-author a clip the set already has; if a procedural extra fights the loop, fix the extra.

**Idle (what Lepy accepts)**
- A clear stance with intent: bladed, chin up, lead hand forward, feet apart with one ahead. Breathing at 0.3 Hz on the chest with arms and head a beat behind, plus a slow weight shift.
- The user under a stand move: the Jotaro point from his reference image, held still. The pointing arm dead straight at the enemy at shoulder height, 10 degrees down (`aim(10, 0.05)` with the torso turned 10 so the pointing shoulder leads; `aim(tw, down)` in `Clips.lua` solves `{lift, 0, side}` so the hand reads dead ahead in root space whatever the torso twist), the fist pushed 0.3 forward, the free arm a bent forearm rising from the left ribs to the collar (`{150, 0, -10}` with `p (0.45, -0.75, -0.25)`: the block dropped and swung up reads as an elbow; the live hand lands at root (-0.98, 0.84, -1.0)), chin down 14 with the eyes up from under the brow, lead foot forward 0.3 and rear foot back 0.35 turned out 12, root dropped 0.12 with the legs solved by `legY`. A 4 frame quart whip from a wound stance 0.32 behind, the arms 3 frames later through an out-and-forward arc on a `back` 1.4, then a 3.4 s breath with the head and arms a fifth behind and a 9 s weight shift. "It needs to stay still and point ... the pointing pose should look like that" (the image).

## Pose space and the sign table

Keys are `r = {lift, twist, side}` in degrees in the PARENT part's axes plus `p` in studs. Pose = `CFrame.new(p) * Angles(0, 0, side) * Angles(lift, 0, 0) * Angles(0, twist, 0)`; `Transform = C0.Rotation:Inverse() * pose * C0.Rotation`.

- `+lift`: a limb swings forward, the head looks up, the torso leans BACK.
- `+twist` on the torso turns the chest to the character's LEFT (right shoulder forward): a right hand move winds at negative twist and strikes at positive. The head's counter is minus the torso twist because the head lives in torso axes.
- `+side` on the torso leans the top to the left; on the right arm it is OUT and on the left arm IN, and past lift 90 the sign flips.
- `p.Z` negative is forward; `p.Y` positive is up.
- Hand direction in parent axes: `(cos L * sin S, -cos L * cos S, sin L)`; its third component is forward (Roblox -Z). A raised right claw `{140, -20, -41}` gives out 0.50, up 0.58, forward 0.64; its left mirror is `{128, 15, 47}`; a low V flare is `{22, 0, 128}`. Run this for every arm key with lift over 60 before any capture; never adjust a twist by guess. Past lift 90 the Euler read back lies (100 reads as 80 with twist 180); trust the formula.

## R6 posing rules

- Feet float when the root rises; drop the root 0.1 to 0.2 on wide stances, lift the chest and chin to say "up".
- Arm twist over 20 degrees on an idle reads as a broken block; use it in walks (wrist follow) and strikes only.
- Lag ladder: engine at T, head T + 1 to 2 frames, arms T + 2 to 3 (the weapon arm may share the strike frame but its cock and settle lag), legs T + 3 to 4. A clip whose joints share key times is wrong before it is captured. `lagged(keys, dt)` in `scripts/Clips.lua` shifts a key list.
- Arrival keys: every key a joint lands on after a snap is `"back", "out", 1.2..1.5`; the departure key is `cubic` or `quart` out 0.06 to 0.12 s earlier; the settle is `sine inout`.
- Arcs: an arm that crosses the body or goes over the head needs a middle key (up and over, or forward and out); a two key lerp cuts through the torso.
- Holds must breathe: two keys that creep, never a flat hold. Recoveries have two or three keys, never one.
- Every clip must read from the player's camera: behind and above at a three quarter angle. A limb pointing straight forward vanishes into the body; put the strike arm up, out or across the front (hand vector up or out above 0.5). Name each beat as a silhouette and check the stand's or the arm's height on screen against the user's head in the rear capture; raise the apex until it clears by a head.
- Piston punches: on the strike frames freeze the arm angle, translate the arm part forward, and let the torso twist make the reach. Move the arm angle only in the follow through.
- Combo clips chain: author the last key of one hit as the first key of the next and skip the return to idle; the recovery is the next load.
- A hand-off between an authored clip and a raw sequence must land on the sequence's frame 0 pose (read it from the decode) or the blend pops.
- A frozen body (someone's time stop) is both rigs at speed 0 and the emitters at TimeScale 0; a stopped Poser clip keeps its last pose in the engine.

## Install into a fresh place

1. `get_studio_state`; confirm R6 (a `Torso`, six Motor6Ds, shoulder and hip C0 `Angles(0, +-pi/2, 0)`).
2. Make a bake rig in Edit: `Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R6)` into `ServerStorage.AnimRig`.
3. Create `ReplicatedStorage.Anim` with `Modules.{Tw, Poser, Clips, Locomotion}` (`multi_edit` creates ModuleScripts; `execute_luau` cannot) from `scripts/Tw.lua`, `scripts/Poser.lua`, `scripts/ClipsLocomotion.lua` (idle, walk, run, air, land and the bake clips, no Config or Assets), `scripts/Locomotion.lua`; and `StarterPlayerScripts.LocomotionClient` from `scripts/LocomotionClient.lua` (starts Locomotion for every character, Shift sprint to 26, the `PoseHold` hook).
4. Push long Sources through `serve.js`; validate on a fresh clone.
5. First playable in twenty minutes: idle and walk only, one strip, then run and jump/land.
6. `Strip.lua` and `Bake.lua` resolve `ReplicatedStorage.Anim` or `ReplicatedStorage.Stand`; pass the clip list and fps to Bake.

## Feedback log (newest last)

- 2026-09-21 morning: "animations kind of suck, its a simple summon so no cutscenes" - no camera takeover on gameplay moves; add idle and walk cycles.
- 2026-09-21: "these are horrid" on a sine walk at 27 degrees and 1.78 Hz plus a drifting idle - calibrate against real clips, never a symmetric sine.
- 2026-09-21: he supplied the community walks and the sword kit and asked for this skill; Moon Animator is his tool for hand polish.
- 2026-09-21: "analyze the idle animation ... use how it works as a way for all animation guidance for everything" - the one engine, lag, translation and energy rules come from that idle and its run and landing.
- 2026-09-21 evening: "remake the entire animation for the world's stand" after a guard pose appear - the remake he liked is one root arc out of the back, a V flare at the apex, a swoop into raised claws with `back` arrivals, and a hover with lagged arms (`Clips.WorldAppear`). "do not make it so laggy" - the first draw hitch, fixed by a join time warm up. "lower down the tone, simple small vfx".
- 2026-09-21 night: he dropped a free model of The World with eight Moon Animator clips, "SUPER high quality ... take reference". Decoded in `references/the-world-clips.md`; the stand plays that set raw through `Poser.fromSequence`.
- 2026-09-21 night: "it needs to stay still and point ... a bladed point like in boxing" - the user under a stand move is planted; a pumping body read as "moving around weirdly".
- 2026-09-22: "Claude isn't getting it ... doesn't make it cool like yours and snappy" when a fresh chat loads this skill. A cold start test showed why: fresh sessions copied the sword kit's numbers verbatim (0.06 s holds, 5 percent overshoot on hand placed keys, 0.26 stud lunges, legs on the torso's frames, `quart` arrivals) and reported after one push. The move template, the lag ladder, the `back` arrivals, the stud size root travel, the silhouette rule for the player's camera and the definition of done above are the fix; they were only in `Clips.lua` before.
- 2026-09-21 night (later): "wire m1s, make your own animations, posing for the actual character sucks, follow the skill, make everything more dramatic except the summon, the pointing pose should look like that" with a Jotaro point image. The first pass had pumped the body, then a bladed boxing point he did not want; the set that passed the strips is `DioPoint` (the image), `DioHeavy`, `DioM1_1..5` (command gestures chained end to start under the stand's five hits: jab point, left chop, fist straight up, lean back and sweep out, lunge point 0.55 forward), `DioTimeStop` (dip, ZA WARUDO with the fist bent overhead and the left arm flung out, tremble through the pause, coil, a 0.6 stud lunge into the point on the last syllable), all on the template: `cubic` departures, `back` arrivals, creeping holds, the lag ladder, `legY` feet. Two strip rounds and the live run are in the DIO memory. He also said "why the subagents, you can do this yourself": author clips in the main loop, no panels.

## Reference index

- [idle-run-land.md](references/idle-run-land.md) - the professional idle, run and landing decoded, and why the idle is the model for every clip.
- [walk-cycles.md](references/walk-cycles.md) - the four community walks decoded, the Roblox default, and the derived walk recipe.
- [attack-timing.md](references/attack-timing.md) - the sword kit decoded frame by frame, the snap hold snap settle pattern, and how it scales to code.
- [the-world-clips.md](references/the-world-clips.md) - The World's eight stand clips decoded: the piston punch, the torso engine barrage, combo chaining, the float idle, the bladed point.
- [pipeline.md](references/pipeline.md) - pose space, Poser, Locomotion, the push recipe, wiring a move, verification, reading clips, baking.
- [moon-animator.md](references/moon-animator.md) - what Moon Animator and the Animation Editor read and write, and the round trip.

## Scripts

- `scripts/Tw.lua`, `scripts/Poser.lua`, `scripts/Locomotion.lua`, `scripts/Clips.lua` - the runtime modules and the DIO and The World clips as worked examples (`WorldAppear` is the move template filled in; `DioSummon` predates the lag ladder). `Poser.fromSequence(kfs, wraps, opts)` plays a KeyframeSequence raw; `Poser.wrapsOf(model)`; `Poser.sample(clip, joint, t)`.
- `scripts/ClipsLocomotion.lua`, `scripts/LocomotionClient.lua` - the Config free locomotion module and the client entry for a fresh place.
- `scripts/ReadClips.lua` + `scripts/serve.js` - decode KeyframeSequences to text files; the same server pushes module sources.
- `scripts/Strip.lua`, `scripts/StandStrip.lua` - the motion strip for one capture verification (walk phases or keyed clip times; rear three quarter and front presets).
- `scripts/Bake.lua` - bake a list of clips into a rig's AnimSaves at a given fps.
- `scripts/AnalyzeClips.js` - ranges, frame tables and speed segmentation over decoded clips.
