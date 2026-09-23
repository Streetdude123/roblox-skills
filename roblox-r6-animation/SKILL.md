---
name: roblox-r6-animation
description: Create, refine, inspect, and export Roblox R6 character animation in code at a professional hand-keyed standard. Use for R6 idle, walk, run, jump, landing, attacks, combos, emotes, weapon motion, and stand animation; fixing stiff, still, snap-then-freeze or floaty motion, sliding or sinking feet, joints that stop together, and broken transitions; studying reference clips; and KeyframeSequence or Moon Animator handoff. Uses the Poser pipeline with spline curves, joint lag, follow-through springs, a life layer and planted-foot solving, measured with Poser.check and the foot check against professional clips.
---

# Roblox R6 animation

The target is motion that a viewer cannot tell from a professional animator's hand-keyed work. Poses alone do not get there. Professional motion never stops everywhere at once: parts start, arrive and settle at different times, holds keep drifting, strikes carry speed through the contact, and feet stay where they stand. Keep the requested action and style. Do not add VFX, camera work, combat mechanics or a new locomotion system unless the task asks for them.

## What made earlier AI clips look dead (measured 2026-09-22)

Lepy: "the animations that AI creates have too much still frames and aren't dynamic enough". The clips were measured against his professional references with `scripts/motion_check.js` (the numbers are in [motion-metrics.md](references/motion-metrics.md)):

| Measure | Pro clips (stand set, sword kit) | Earlier Claude clips over 1 s |
| --- | --- | --- |
| Time an active joint spends under a tenth of its peak speed (rest%) | 16 to 50% | 56 to 90% |
| Peak body speed over median body speed (contrast) | 2 to 10.6 | 9 to 104 |
| Body fully still (nothing over 12 deg/s) in a one-shot | 0% | up to 61%, runs up to 1.3 s |

The causes, each fixed below:

1. **Every key was a stop.** A Poser key eased with `quad`, `cubic`, `sine` or `back` arrives at zero speed, so each breakdown and each "creep" key was a full stop. Pros spline through breakdowns and stop only where a part turns around.
2. **Joints shared key times,** so three or more stopped on the same frame (unison stops). Pros offset keys one or two frames per link down the chain.
3. **Holds crept 1 to 2 degrees,** which reads as a freeze. A moving hold keeps travelling in the direction of the move.
4. **Snap then a long slow settle** (contrast 10 to 100). Pros keep the recovery moving: they hold the over-extended pose briefly, then pop back with the parts trailing.
5. **Feet slid and sank and hips opened** when the torso turned, because R6 legs hang from the torso.

## Start with the actual task

1. Read the project instructions and inspect the animation setup. Discover the Studio tools that exist; do not assume them.
2. Extract the action, intent, reference, duration, loop or one-shot, rig, player camera, props, movement permission, impact and cancel times, and delivery format. Ask only about missing details that change the result.
3. Inspect parts, sizes, `Motor6D.Part0`, `Part1`, `C0`, `C1`, root, grips and the existing controller. Confirm R6.
4. Read [principles.md](references/principles.md) (posing, timing, overlap, holds, recoveries, idles) before the first key. Read [pipeline.md](references/pipeline.md) before running bundled scripts. Read [project-style.md](references/project-style.md) for Lepy or DIO work.
5. Keep notes in [clip-plan.md](templates/clip-plan.md).

## The method

### 1. Plan in frames

Count at 60 fps and write the beat table: anticipation, strike or action, contact event, follow-through, recovery, exit pose. Record which feet are planted and which part leads each beat. Use the timing ranges in principles.md as a start and the gameplay contract for event times. A chained move ends on the next move's first pose.

### 2. Block the poses

Few poses, each one readable from the player's camera: line of action, shoulders against hips (torso roll against the leg split), no twinned limbs, gaps between the limbs and the body, weight over the support, pushed 10 to 20% past natural. Review the blocking as a strip before any motion work. Do not smooth a weak pose.

### 3. The motion pass (this is where clips come alive)

Author with `curve = "spline"` and give every clip these layers. Field reference: pipeline.md; worked example: `scripts/ExampleClips.lua`.

- **Spline through breakdowns.** Keys default to `auto`: speed flows through a breakdown and stops only where the channel turns around. Put `e = "flat"` only on a real stop. Keep a named ease (`quart`, `back`, ...) only for a shape the spline cannot give, such as a hard snap into a pose.
- **Offset the chain.** `lag = {Head = 0.4}` delays a joint's whole curve (the example guard's head answers the breath 0.4 s late). Trail loose, carried parts 1 to 4 frames behind what drives them. Do not lag a part that acts on purpose: the striking limb, the torso, a head that holds the eyes on a target (it counters the torso twist on the torso's frames) and a hand pulled back to guard (a lagged lead arm in the example cross was carried 1.95 studs out by the torso's turn). Also stagger key times by hand so no three joints share every key.
- **Follow-through.** Key the overshoot of every part that must hit a frame (the striking fist, the torso of a strike): a key past the contact, then a drifting hold. Put springs on the other parts: `springs = {["Left Arm"] = "follow"}`. On a snap `lead` overshoots about 6% and settles in 7 frames, `follow` 8%, `drag` 12%, `heavy` has no bounce; on a steady move they trail 0.5, 1.2, 1.7 and 3.1 frames, which is why a spring never goes on a part that must be on its key.
- **Paths.** Poser interpolates Euler channels, so a limb that crosses the body can swing around the outside on the way. Check the hand path in root space (forward kinematics, pipeline.md) and add a breakdown that keeps it where it belongs.
- **Life.** `life = 0.6` to `1.5` degrees of slow drift on the upper body so no hold ever freezes; idles also get a breath.
- **Planted feet.** `post = Feet.post({r = {x, z, yaw}, l = {x, z, yaw}})` solves both legs after the torso, springs included, so the soles stay on their floor targets while the torso turns, leans and lunges. A foot target may be a function of time for steps and heel pivots. Lean the torso from the waist (`waist` in ExampleClips) so a forward lean does not swing the hips back.
- **Moving holds.** A hold keeps travelling 5 to 15% further in the direction of the move over its frames, with `auto` keys so it glides in and out. Never key a hold as two equal poses.
- **Recoveries.** For a move the player can chain or cancel, stay in the over-extended follow-through pose 6 to 12 frames while it drifts, then pop back in 8 to 15 frames with the striking limb first and the torso and head 1 to 3 frames behind. A long return (the sword kit takes 30 frames after a hit) suits a finisher; keep it one continuous deceleration with the parts offset, never a creep of a degree or two.

### 4. Measure before you look

In Edit mode (`scripts/LoadTest.lua` loads the modules fresh, `scripts/EditStrip.lua` adds the helpers):

- `Poser.check(clip).text` for a one-shot of 0.3 to 1.5 s must show: frozen 0%, still 5% or less with no still run over 0.1 s (an intended hitstop excepted), rest 45% or less, contrast 2 to 10, stops 3 or fewer per second, unison 5 or fewer per second. A loop or a long held pose must show frozen 0%.
- `_G.feet(clip)` must show every planted lowest corner within 0.03 of the floor, slide 0.05 or less and hip gap 0.12 or less (aim for 0).
- A number outside its range names the fault: rest or contrast high means stops and dead holds; unison high means keys on shared frames; slide or gap means the torso outruns the legs. Fix the cause, then measure again.

### 5. Look, then iterate

1. `_G.editStrip(clip, times, {facing = "side"})` then `screen_capture` with the returned camera: one ghost per beat. Check the silhouettes, the line of action and the arcs of the hand and the foot. Repeat from `rear34` (the player's view) and `front`.
2. Play the clip on the character in Play mode and capture from the player's camera at the contact and the recovery. Read each capture; state what it shows.
3. Change the smallest pose, timing, lag or spring that fixes what you saw; measure and capture again. Two rounds minimum. Stop when the checks pass and the captures read, not after a fixed count.

## Verify and hand off

1. Check joint names, increasing key times, clip bounds, start and end poses, event times and joint ownership.
2. Report `Poser.check` and `_G.feet` numbers next to the pro ranges, and the captures you read (times and views).
3. Exercise the loop, the transition, the cancel, the speed change, the respawn or the second client that applies. Check the Studio output.
4. Inspect the exported `KeyframeSequence` and replay it. `Poser.bake` includes lag, life, springs and the post pass. Check duration, end pose, hierarchy, priority, loop flag, keyed joints and markers (pipeline.md).
5. Report the instance path, key decisions, checks and remaining limits. Distinguish **authored**, **measured**, **visually reviewed**, **runtime tested** and **user accepted**. One does not imply the others.

Keep the editable key source. Never claim a clip looks good; report what the numbers and the captures show.

## Choose the pipeline

| Situation | Action |
| --- | --- |
| Existing Poser project | Keep the runtime. Author spline clips with the motion layers, measure, capture, bake if asked. Legacy clips play unchanged. To lift an old clip, set `curve = "spline"`, drop its eases, then rework its holds and recoveries; the engine alone closes only part of the gap (motion-metrics.md). |
| Existing Animator project | Keep the Animator and its controller. Author in Poser, measure, then deliver a baked sequence with the project's priorities and events. |
| Supplied professional animation | Inspect and measure it first (`ReadClips.lua` then `motion_check.js`); play it raw through `Poser.fromSequence` instead of reauthoring. |
| New place or unknown setup | Ask which handoff is needed before installing a controller or replacing the default character animation. |
| No Studio connection | Author and reason about the source; leave measurement, visual and runtime checks marked unverified. Never fabricate captures or numbers. |

Give each joint one writer. Avoid TweenService on animated joints.

## R6 rules that bite

- **Hip rule.** A leg key's translation is the gap at the hip: the hip pivots at the leg's outer top corner. Put a stance into hip angles or `Feet.post`, never into leg slides; a leg pushed up into the torso is hidden and allowed. Keep any downward gap under 0.12. "it can be a TINY little bit off the body but not like that" (2026-09-22).
- **Waist rule.** The torso turns about its centre, so a lean swings the hips. Add the waist offset so the body bends at the hips.
- **Rigid legs.** Turning the torso turns the hips around the feet. A 56 degree turn from a guard to a punch kept both feet planted only with the torso dropped 0.36 (a search in the example); plan the drop with the turn, and use `Feet.gap` to see what a pose needs.
- **Toe yaw.** `Feet.stand` turned toes the wrong way until 2026-09-22 (the left idle toe ended 98 degrees off its target and nothing flagged it). The foot checks now print `twist` (a planted leg against the torso); keep it under about 45 degrees and pivot the feet with the hips.
- **Fist grip.** A held weapon's handle runs within about 25 degrees of square to the forearm or the block arm looks pierced ("no one holds a sword like that", 2026-09-22). The solver penalises it and logs `gripErr`; pick arm directions and blades that are square before solving (weapons.md).
- **Combo flow.** Each swing starts from the last swing's end pose and carries the blade on the way it was going; the end of one swing is the load of the next ("it should naturally flow from the end positions of the m1s", 2026-09-22). Plan the chain as one path before keying (weapons.md).
- **Hand-over twitch.** The Animator zeroes `Motor6D.Transform` before PreSimulation, so a blend that starts inside a step must come from the rig's last written pose (Poser does this now). Check every move's end into the idle with a per-frame part record in Play; an Edit-mode step cannot show it.
- **No elbows or knees.** Suggest a bend with a short translation up into the torso or a piston along the limb (the stand fists slide 0.3 to 0.6 studs on the strike frames).
- **Overhead reach.** An R6 fist reaches at most torso y 1.99, straight over the shoulder, and the head top is 2.0; over the head centre it reaches only forehead height. A two-handed grip above the head is impossible without sliding the arms out of the shoulders. Explain the limit and ask before building such a pose (weapons.md, "Overhead holds").

## Read only what the task needs

| Resource | Use |
| --- | --- |
| [principles.md](references/principles.md) | Posing checklist, timing in frames, overlap, moving holds, springs, recoveries, idles, walks, attacks. |
| [motion-metrics.md](references/motion-metrics.md) | The measured pro and Claude numbers, metric definitions, targets, the engine experiment. |
| [r6-mechanics.md](references/r6-mechanics.md) | R6 transforms, joint gaps, contacts and reach. |
| [quality-review.md](references/quality-review.md) | Symptom to cause table and evidence. |
| [pipeline.md](references/pipeline.md) | Poser fields, Feet, EditStrip, LoadTest, bake and import limits. |
| [sources.md](references/sources.md) | The research behind each rule. |
| [project-style.md](references/project-style.md) | Lepy and DIO feedback history. |
| [idle-run-land.md](references/idle-run-land.md), [walk-cycles.md](references/walk-cycles.md), [attack-timing.md](references/attack-timing.md), [the-world-clips.md](references/the-world-clips.md) | Decoded reference clips and what they show. |
| [clip-plan.md](templates/clip-plan.md) | Brief, beat table, motion layers, measurements, review record. |
| [weapons.md](references/weapons.md) | Swords and held props: the three-axis grip joint, keys as hand and blade directions solved on the arm, physical twist, Euler branch continuity, blade tip checks, onion skins, props growing out of props, the solve cache. |

Scripts: `Poser.lua` (runtime, check, dump, bake), `Feet.lua` (planted legs), `WeaponRig.lua` (the sword arm solver, physical twist, Euler branches, the solve cache) and `WeaponStrip.lua` (Edit-mode strips with the weapon and props, the onion skin, the foot and blade tip check), `ExampleClips.lua` (a guard and a cross on the method, passing every check), `EditStrip.lua` (Edit-mode strips and the foot check), `LoadTest.lua` (fresh module copies from `serve.js`), `motion_check.js` (the same metrics on decode text), `ReadClips.lua` (decode a KeyframeSequence), `Clips.lua` and `ClipsLocomotion.lua` (the DIO project, legacy eases), `Strip.lua` and `StandStrip.lua` (Play-mode strips), `Bake.lua`, `check_decode.py`, `AnalyzeClips.js`.
