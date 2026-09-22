---
name: roblox-r6-animation
description: Author, verify and hand off high quality R6 character animations in code for Lepy's Roblox places - walk and idle cycles, attacks and summons, stand or weapon overlays - using the Poser and Locomotion modules, numbers measured from professional community clips, motion strip verification, KeyframeSequence baking and the Moon Animator round trip. Use whenever a Roblox animation must be created, judged, fixed, decoded or exported.
---

# Roblox R6 animation

This skill is Lepy's own animation practice. It exists because he cannot animate by hand, Claude cannot watch a clip play, and the first code posed clips were "horrid". Every rule below was measured from real clips (four community walk cycles, a professional sword kit, the Roblox defaults) or learned from his feedback. Read the references before authoring; do not guess amplitudes.

## Decision framework

- **Locomotion (idle, walk, run, jump, land)**: procedural clip driven by a per character controller. Speed drives the walk phase so feet plant. See `references/walk-cycles.md`.
- **A move (attack, summon, cast, dodge)**: a keyed clip played as an override, then hand back to locomotion. Timing is snap, hold, snap, settle, long recovery. See `references/attack-timing.md`.
- **A weapon or stand overlay (idle with a sword, guard, stance)**: an Action priority clip that drives Torso, Head and Arms only and leaves the legs to locomotion. Static pose, breathing comes from the layer under it.
- **A cutscene**: only for a reel piece (the ultimate). Gameplay moves never take the camera and lock the body under one second.
- **Mocap or a commission**: when a clip needs full body acrobatics or realistic locomotion beyond what the numbers below give.

## Workflow

1. Read the reference for the kind of clip, then write keys in the parent axis pose space (`references/pipeline.md`). Start from a copy of `scripts/Clips.lua`.
2. Push the module, play, and verify with a motion strip (`scripts/Strip.lua`) or a `PoseHold` sheet. Read limb directions back as numbers when a pose looks wrong.
3. Bake to the rig's AnimSaves (`scripts/Bake.lua`) so Lepy can polish in Moon Animator or the Animation Editor (`references/moon-animator.md`).
4. When he returns an export, decode it with `scripts/ReadClips.lua`, learn the delta, and update the numbers and this skill.

## The model for everything: how a professional idle works

Lepy set the idle in `references/idle-run-land.md` as the guide for all animation. Its structure is the checklist for every clip:

1. **One engine.** Pick the joint that drives the motion (the torso in an idle, a walk, a run, a landing, a swing) and animate it first as one clean wave or one clean arc. No stacked random frequencies.
2. **Everything else is secondary.** Head and arms follow the engine about a fifth of a cycle later at about half the amplitude; legs shift weight in phase. In a recovery the head leads.
3. **Translation builds the pose, rotation carries the motion.** Feet are placed with 0.3 to 0.5 stud offsets, the back foot is turned out with twist, arms hang 0.05 to 0.3 lower, knees drive a stud forward in a run, legs fold a stud up in a landing. On R6 translation is the joint you do not have.
4. **Amplitude follows energy.** Idle 2 to 6 degrees and 0.04 studs; walk 30 to 45; run 60 to 80 with stud size translations; landing a 42 degree fold and a 1.1 stud drop; strike 130 degrees in 3 frames.
5. **Nothing is still and the loop never pops.** Every channel drifts, the last frame equals the first, and the pose already reads at frame 0.

## The numbers that matter

**Idle, run and landing (from a professional R6 set)**
- Idle: one 3 s breath, torso lean 2.3 to 6 forward with a 0.04 sink, head nods 2 a fifth of a cycle later, arms 2 to 4, legs shift 4 to 11 in phase, staggered feet built with 0.3 to 0.5 stud offsets and a 12 degree turned out back foot.
- Run: 0.533 s cycle, torso lean 27 with hips twisting 25 each way and the head countering one to one, root 0.28 to 0.45 low with two bobs, legs -78 to +54 with the leg parts driving 1 stud up and 1.5 forward, arms -62 to +84 with forearm twists.
- Landing: fold to -42 and drop 1.1 studs in 5 frames, legs fold up 1.4, arms fly forward 64, hold 5 frames, recover on a decelerating curve with the head first.


**Walk (from four community cycles and the Roblox default)**
- Cycle 0.76 s (run) to 0.92 s (walk) at speed 16; STRIDE 13 studs per cycle in the controller.
- Legs asymmetric: -45..+30 walk, -40..+50 run. Back leg pushed DOWN 0.1 to 0.27 studs so the planted foot stays on the floor; forward pass LIFTED 0.22 to 0.37 (the knee).
- Torso lean forward 5 to 7 (run 5 to 12), bob 0.1 up twice per cycle at the passing poses, run crouch 0.2 to 0.3. Torso twist 3 to 5 with the head countering 2 to 4.
- Arms 30 to 40 swing (60 run), wrist twist 20 to 30 following the swing, elbows out 5 to 12, arm parts dropped 0.1 to 0.3.

**Attack (from a professional sword kit at 60 fps)**
- Snap into the wind up in 3 to 4 frames, hold 2 to 4 frames, strike in 3 frames, follow through 4 frames with 15 percent overshoot, then 30 frames of smooth recovery. Over half the clip is recovery.
- Wind up: torso leans back 15 to 19 and twists 20 to 28 away, head looks down and counters the twist, weapon arm goes up and over, free arm out for balance.
- Strike: torso swings 32 degrees of pitch and 48 of yaw in 3 frames, arm sweeps about 130 degrees in 3 frames, head snaps the other way and keeps the face on the target through the whole swing.
- Weapon idles are static bladed poses (torso twist 15 to 20 with the head counter turned, sword arm lift 65 side 47) with half a degree of drift.

**Idle (what Lepy accepts)**
- A clear stance with intent: bladed, chin up, lead hand forward, feet apart with one ahead. Breathing at 0.3 Hz on the chest with arms and head a beat behind, plus a slow weight shift. Not a static mannequin, not a drift.

**R6 posing rules**
- Feet float when the root rises; drop the root 0.1 to 0.2 on wide stances, lift the chest and chin to say "up".
- Arm twist over 20 degrees on an idle reads as a broken block; use it in walks (wrist follow) and strikes only.
- Overlap: head and free arm land two to three frames after the torso. Never move every joint on the same frame.
- Arcs: an arm that crosses the body needs a middle key (up and over, or forward and out); a two key lerp cuts through the torso.
- Holds must breathe: add small keys through a hold instead of leaving it flat.

## Feedback log

- 2026-09-21: "animations kind of suck, its a simple summon so no cutscenes" - drop camera takeover on gameplay moves; add idle and walk cycles.
- 2026-09-21: "these are horrid" on a sine walk at 27 degrees and 1.78 Hz plus a drifting idle - calibrate against real clips, never a symmetric sine.
- 2026-09-22: he supplied the community walks and the sword kit to learn from and asked for this skill; Moon Animator is his tool of choice for hand polish.
- 2026-09-22: "analyze the idle animation ... use how it works as a way for all animation guidance for everything" - the one engine, lag, translation and energy rules above come from that idle and its run and landing.

## Reference index

- [idle-run-land.md](references/idle-run-land.md) - the professional idle, run and landing decoded, and why the idle is the model for every clip.
- [walk-cycles.md](references/walk-cycles.md) - the four community walks decoded, the Roblox default, and the derived walk recipe.
- [attack-timing.md](references/attack-timing.md) - the sword kit decoded frame by frame and the snap hold snap settle pattern.
- [pipeline.md](references/pipeline.md) - pose space, Poser, Locomotion, verification, reading clips, baking.
- [moon-animator.md](references/moon-animator.md) - what Moon Animator and the Animation Editor read and write, and the round trip.

## Scripts

- `scripts/Poser.lua`, `scripts/Locomotion.lua`, `scripts/Clips.lua` - the runtime modules and the DIO clips as worked examples.
- `scripts/ReadClips.lua` + `scripts/serve.js` - decode KeyframeSequences to text files.
- `scripts/Strip.lua` - the motion strip for one capture verification.
- `scripts/Bake.lua` - bake every clip into a rig's AnimSaves.
