---
name: roblox-r6-animation
description: Create, refine, inspect, and export Roblox R6 character animation in code at a professional hand-keyed standard. Use for R6 idle, walk, run, jump, landing, attacks, combos, emotes, weapon and prop motion, companion or stand animation, and creature rigs; fixing stiff, still, snap-then-freeze, floaty or off-balance motion, sliding or sinking feet, joints that stop together, and broken transitions; studying reference clips and videos; and KeyframeSequence or Moon Animator handoff. Applies the 12 principles of animation and body physics (centre of mass, balance, momentum) directly through the Poser pipeline: spline curves, joint offsets, follow-through springs, a life layer and planted-foot solving, measured with Poser.check and the foot check against professional clips.
---

# Roblox R6 animation

The target is motion that a viewer cannot tell from a professional animator's hand-keyed work. Poses alone do not get there. Professional motion obeys the principles below on every frame: parts start, arrive and settle at different times, holds keep drifting, the body stays balanced over its support, strikes carry speed through the contact, and feet stay where they stand. Keep the requested action and style. Do not add VFX, a camera takeover, a cutscene, combat mechanics or a new locomotion system unless the task asks for them; offer them as a question. Work through what the place already has: its animation runtime, its movement system and its transitions.

## The principles, applied directly

Every clip applies every row. The method below says where each one is done; the checklist at hand-off asks each one again. The lesson videos behind them, with their R6 translations, are in [lesson-videos.md](references/lesson-videos.md); the craft detail is in [principles.md](references/principles.md).

| Principle | Apply in the clip | Check |
| --- | --- | --- |
| **Timing** | Count every beat in frames at 60 fps and give it the duration that says what it means (a 0.17 s change reads as a dodge, 0.46 s as a stretch). Time the action from real life or the reference; the usual error is too slow. | Each beat against the timing table in lesson-videos.md and the reference's frame count. |
| **Spacing, slow in and slow out** | `curve = "spline"`: keys stay `auto` so speed flows through breakdowns; `flat` only where a part turns round or truly stops. No ease into an impact; ease the rebound. Favour keys for snap. Never constant speed on a living part. | `Poser.check`: rest, stops, still runs. |
| **Anticipation** | A pull-back before every move, sized to it (one to three levels: a small move the other way, the load, a counter-limb back). Keep a player's light-attack anticipation short (1 to 8 frames; the press is the expectation) and an NPC's telegraph long (12 to 30 frames). Wind up on the side and height where the hit will land. | The load pose reads as a silhouette from the player's camera. |
| **Follow-through and overlapping action** | The driver moves first and the carried parts follow 1 to 3 frames later down the chain (`lag`, key offsets). Key the overshoot of every part that must hit a frame; springs on loose parts. Nothing stops at once: at a contact the arms, head and props keep going and settle with shrinking bounces. | `Poser.check`: unison, spread, lag. No part freezes at a contact. |
| **Arcs** | Hands, feet, head top, props and the torso travel on arcs; add a breakdown that bends a straight path. | Paths in root space by forward kinematics; onion skins for props. |
| **Squash and stretch** | R6 parts cannot scale. Squash is a compact pose on the contact frame (torso drops, legs slide up into it, arms in); stretch is a long pose on the fastest frames only. | The fastest frames show the longest silhouette. |
| **Staging** | One main action at a time, clear from the player's camera behind and above the character. Move hands and weapons to the side the camera sees. | Capture from the player's camera at the contact and the recovery. |
| **Pose to pose and straight ahead** | Block the body pose to pose; loose parts (hair, tails, capes, chains) follow straight ahead through springs and lag chains. | The blocking strip reads before any motion work. |
| **Secondary action** | A free hand, the head or a prop supports the main action and the mood, without upstaging it. | It shows in the capture and does not compete. |
| **Exaggeration** | Push each key pose 10 to 20% past natural, then pull back only what breaks the read. A fast extreme must be bigger or held longer. | The extreme reads at full speed. |
| **Solid drawing: weight and balance** | Line of action, shoulders against hips, no twinning, gaps between limbs and body. The centre of mass (COM) stays over the support in held poses; speed is gained only through a planted push and lost through a braced stop; flips and spins turn about the COM; an airborne COM follows a parabola. | COM projection inside the support area from two views (r6-mechanics.md, "Centre of mass and balance"; body-mechanics.md); feet check. |
| **Appeal** | Clear, varied, readable shapes; magnify what defines the character. | The silhouette reads without colour. |
| **Game feel** | Response first; weight goes into the contact, hitstop and follow-through. The strike is the fastest motion in its window. Event on the contact key, hitstop by strength (about 8, 12, 16 frames) with the victim shaking and the attacker creeping, cancels open from the hit, recovery over-extended then popping back, combo hits chained end to start ([combat.md](references/combat.md)). | Each joint's peak speed; event times against the gameplay contract; chain test in Play. |

## Always start from a reference

Animate every clip from a reference: idles, walks, runs, strafes, attacks, blocks, parries, hit reactions, stuns, emotes, companion moves. A clip invented from numbers alone is not done, even when every check passes.

1. Find candidates yourself before the first key and before asking the requester. When the character or move comes from existing media, take the reference from that source first (its frames, sprites, cutscenes, its own description of the move, fan animations of it), build the key silhouettes from those frames, and add no gesture or lunge the source does not show. Other sources: a clip the requester sends; film, anime, game footage or preview videos of commercial animation packs, studied as frame grids (note the move's time range) and copied by [video-rotoscope.md](references/video-rotoscope.md) when an exact copy is wanted; Creator Store packs from named animators, found through the animator's own published links (look-alike re-uploads dominate store search). Ask the requester for footage only as a last resort.
2. Treat every free model as unsafe. Insert packs into `ServerStorage`, read and delete every script, keep only the KeyframeSequences and the parts you need, then decode and measure them (`ReadClips.lua`, `Poser.check`, forward kinematics of the fists and feet). Delete on sight a result with no KeyframeSequence whose content is a script hidden under the root joint that requires a module by an id stored in a value: a require by a stored id loads remote code (a backdoor).
3. When the requester picks, show the candidates on their character as one short video per move, with a text label over each character that names the move and the option ("JAB 1", "JAB 2"); a reviewer cannot see file names. Show only clips whose limbs stay on the body: measure the gap from each limb box to the torso box on every frame and drop any clip over 0.12 studs, and drop R15 clips (UpperTorso, elbows) for an R6 rig. When a move has no clean clip, say so, and offer a mirror of a clean clip or the clean clip with only the limb slide removed, labeled as such. Ask how to bridge any gap between the reference and the game (speed, timing, distance) before building.
4. Copy the pick as authored: its timing and every channel, leg slides included. Change only what the game needs (event times, a step-in) and state each change and its size. When the reference plants at a different speed from the game, ask first: an exact copy whose feet slide, or replanted feet that lose leg motion (replanting dropped a reference's leg slides and the copy was rejected). To keep a picked clip exact, bake it through the Animator at 60 fps or play the original sequence (pipeline.md). When a professional set or the team's own clips exist for the character, play them unchanged and author only what is missing, starting and ending on the set's idle frame.
5. In the report, name the reference that each clip copies and list how the clip differs from it.

## Why code-authored clips look dead (measured)

Earlier clips authored in code were measured against professional reference clips with `scripts/motion_check.js` (numbers in [motion-metrics.md](references/motion-metrics.md)):

| Measure | Professional clips | Earlier code-authored clips over 1 s |
| --- | --- | --- |
| Time an active joint spends under a tenth of its peak speed (rest%) | 16 to 50% | 56 to 90% |
| Peak body speed over median body speed (contrast) | 2 to 10.6 | 9 to 104 |
| Body fully still (nothing over 12 deg/s) in a one-shot | 0% | up to 61%, runs up to 1.3 s |

The causes, each fixed by the method below:

1. **Every key was a stop.** A key eased with `quad`, `cubic`, `sine` or `back` arrives at zero speed, so each breakdown was a full stop. Professionals spline through breakdowns and stop only where a part turns around.
2. **Joints shared key times,** so three or more stopped on the same frame (unison stops). Professionals offset keys one or two frames per link down the chain.
3. **Holds crept 1 to 2 degrees,** which reads as a freeze. A moving hold keeps travelling in the direction of the move.
4. **Snap then a long slow settle** (contrast 10 to 100). Professionals hold the over-extended pose briefly, then pop back with the parts trailing.
5. **Feet slid and sank and hips opened** when the torso turned, because R6 legs hang from the torso.

## Start with the actual task

1. Read the project instructions and inspect the animation setup. Discover the Studio tools that exist; do not assume them.
2. Extract the action, intent, reference, duration, loop or one-shot, rig, player camera, props, movement permission, impact and cancel times, and delivery format. Ask only about missing details that change the result.
3. Inspect parts, sizes, `Motor6D.Part0`, `Part1`, `C0`, `C1`, root, grips and the existing controller. Confirm R6 (a creature or another Motor6D rig: [custom-rigs.md](references/custom-rigs.md)).
4. Read [lesson-videos.md](references/lesson-videos.md) and [principles.md](references/principles.md) before the first key, then the research file for the clip: [body-mechanics.md](references/body-mechanics.md) for balance, jumps, falls and flips, [combat.md](references/combat.md) for attacks and reactions, [locomotion.md](references/locomotion.md) for walks, runs, turns and idles, [keyframe-workflow.md](references/keyframe-workflow.md) for blocking, polish and acting, [stylized-and-roblox.md](references/stylized-and-roblox.md) for anime-style timing and native playback. Read [pipeline.md](references/pipeline.md) before running bundled scripts.
5. Keep notes in [clip-plan.md](templates/clip-plan.md).
6. When a person reviews the work, follow [process.md](references/process.md): ask the choices that change the result, show options as labelled videos, change only what was named, and report the reference behind each clip.

## The method

### 1. Plan in frames (timing, anticipation, staging, game feel)

Count at 60 fps and write the beat table: anticipation, strike or action, contact event, follow-through, recovery, exit pose. Check each beat's duration against what it should mean and against the reference. Record which feet are planted, where the COM must be, and which part leads each beat. Use the timing ranges in principles.md as a start and the gameplay contract for event times. A chained move ends on the next move's first pose.

### 2. Block the poses (solid drawing, balance, exaggeration, appeal, squash and stretch)

Few poses, each one readable from the player's camera: line of action (one C or one S), shoulders against hips (torso roll against the leg split), no twinned limbs, gaps between the limbs and the body, the COM over the support, pushed 10 to 20% past natural; a compact pose on the contact and a long one on the fastest frames. Name the golden pose (usually the load or the follow-through extreme) and give it the longest hold. Block whole poses: key all six joints at the same times on `step` keys and play it at speed; the stepped strip should carry about 80% of the read. Review it from the side and the front before any motion work. Do not smooth a weak pose.

### 3. The motion pass, in layers (physics, spacing, overlap, follow-through, arcs, secondary)

Author with `curve = "spline"`. Work in this order, and do not polish a later layer on a body whose weight does not read yet: the torso translation and the legs (where the COM goes, pushes and stops), then the torso rotation, then the arms, then the head, then loose parts and life. Field reference: pipeline.md; worked example: `scripts/ExampleClips.lua`.

- **Spline through breakdowns.** Keys default to `auto`: speed flows through a breakdown and stops only where the channel turns around. Put `e = "flat"` only on a real stop. Keep a named ease (`quart`, `back`, ...) only for a shape the spline cannot give, such as a hard snap into a pose.
- **Push before speed, stopper before stop.** Root travel starts with a compression and a push from a planted foot (or a lean that falls into the first step) and ends with a braced leg planted ahead of the COM, the torso leaning back and sinking.
- **Rotate about the COM.** RootJoint pivots at the torso centre, 0.64 above the standing COM; for a flip, spin or big lean add the translation that keeps the COM on its path (r6-mechanics.md, body-mechanics.md). In the air the COM's horizontal speed is constant and its height a parabola; all rotation starts at the takeoff, a pike (legs lifted straight, arms in) spins about 2x a layout, spread limbs slower, and only the landing stops a spin.
- **Offset the chain.** `lag = {Head = 0.4}` delays a joint's whole curve. Trail loose, carried parts 1 to 4 frames behind what drives them. Do not lag a part that acts on purpose: the striking limb, the torso, a head that holds the eyes on a target (it counters the torso twist on the torso's frames) and a hand pulled back to guard (a lagged guard hand was carried 1.95 studs out by the torso's turn). Also stagger key times by hand so no three joints share every key.
- **Follow-through and through motion.** Key the overshoot of every part that must hit a frame (the striking fist, the torso of a strike): a key past the contact, then a drifting hold. Contact keys stay `auto`: nothing freezes or eases into a hit. Put springs on the other parts: `springs = {["Left Arm"] = "follow"}`. On a snap `lead` overshoots about 6% and settles in 7 frames, `follow` 8%, `drag` 12%, `heavy` has no bounce; on a steady move they trail 0.5, 1.2, 1.7 and 3.1 frames, which is why a spring never goes on a part that must be on its key. Never add bounces afterwards as same-size flicks.
- **Arcs and paths.** Poser interpolates Euler channels, so a limb that crosses the body can swing around the outside on the way. Check the hand, foot, head-top and prop-tip paths in root space (forward kinematics, pipeline.md) and add a breakdown that keeps each on its arc.
- **Life.** `life = 0.6` to `1.5` degrees of slow drift on the upper body so no hold ever freezes; idles also get a breath (3 to 5 s calm, the inhale slower than the exhale).
- **Planted feet, flat soles.** `post = Feet.flat({r = {x, z, yaw}, l = {x, z, yaw}})` solves both legs after the torso, springs included (feet rule below). A foot target may be a function of time for steps and heel pivots. Lean the torso from the waist (`waist` in ExampleClips) so a forward lean does not swing the hips back.
- **Moving holds.** A hold keeps travelling 5 to 15% further in the direction of the move over its frames, with `auto` keys so it glides in and out. Never key a hold as two equal poses.
- **Recoveries.** For a move the player can chain or cancel, stay in the over-extended follow-through pose 6 to 12 frames while it drifts, then pop back in 8 to 15 frames with the striking limb first and the torso and head 1 to 3 frames behind. A long return suits a finisher; keep it one continuous deceleration with the parts offset, never a creep of a degree or two.

### 4. Measure before you look

In Edit mode (`scripts/LoadTest.lua` loads the modules fresh, `scripts/EditStrip.lua` adds the helpers):

- `Poser.check(clip).text` for a one-shot of 0.3 to 1.5 s must show: frozen 0%, still 5% or less with no still run over 0.1 s (an intended hitstop excepted), rest 45% or less, contrast 2 to 10, stops 3 or fewer per second, unison 5 or fewer per second. A loop or a long held pose must show frozen 0%.
- `_G.feet(clip)` must show every planted lowest corner within 0.03 of the floor, slide 0.05 or less, sole tilt about 8 degrees or less on planted frames, torso contact 0 or more (no gap) and top off about 50% or less (51 to 52% passed review on finished attacks). The hip gap number only shows how far a leg slid; it is not a fault on its own. Print every quantity a rule limits (leg twist against the torso, grip angle, blade tip height): a limit nobody prints is not checked.
- The COM: in every held pose its floor projection lies inside the support area; in the air it follows a parabola (r6-mechanics.md).
- Speeds: print each joint's peak speed. The striking limb is the fastest in its window; no joint passes about 1500 deg/s (25 degrees per frame) after a clip is compressed (principles.md, strike speed).
- A number outside its range names the fault: rest or contrast high means stops and dead holds; unison high means keys on shared frames; slide or gap means the torso outruns the legs; a COM outside the support means the pose falls. Fix the cause, then measure again.

### 5. Look, then iterate

1. `_G.editStrip(clip, times, {facing = "side"})` then `screen_capture` with the returned camera: one ghost per beat. Check the silhouettes, the line of action, the balance and the arcs of the hand and the foot. Repeat from `rear34` (the player's view) and `front`.
2. Play the clip on the character in Play mode and capture from the player's camera at the contact and the recovery. Read each capture; state what it shows.
3. Change the smallest pose, timing, lag or spring that fixes what you saw; measure and capture again. Two rounds minimum. Stop when the checks pass and the captures read, not after a fixed count.
4. Review with fresh eyes: look at a horizontally flipped copy of each capture, and give the captures without the brief to a fresh reviewer and ask what the character does and feels (keyframe-workflow.md). Record that answer apart from the requester's acceptance.

## Verify and hand off

1. Check joint names, increasing key times, clip bounds, start and end poses, event times and joint ownership.
2. Report `Poser.check` and `_G.feet` numbers next to the professional ranges, and the captures you read (times and views). Answer the checklist at the end of [lesson-videos.md](references/lesson-videos.md) against the captures: one answer per principle.
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
| Only a video of the professional clip | Replicate it by computer, not by eye: export the rig, fit the cameras and the pose to the video, mark thin props by hand, track the motion, export and check from the fitted cameras ([video-rotoscope.md](references/video-rotoscope.md)). |
| New place or unknown setup | Ask which handoff is needed before installing a controller or replacing the default character animation. |
| No Studio connection | Author and reason about the source; leave measurement, visual and runtime checks marked unverified. Never fabricate captures or numbers. |

Give each joint one writer. Avoid TweenService on animated joints.

## R6 rules that bite

- **Feet rule.** Keep planted soles flat on the floor. A leg may slide off its hip socket, sideways, forward, back or up into the torso, while at least half of its top face stays under the torso's bottom face and it touches the torso (never a gap; up to half the leg inside is fine). Tilt a leg only for what a slide cannot cover, and bring a brace or stride foot 0.2 to 0.3 studs closer under the body before you accept a tilt over about 8 degrees (straight-leg braces tilted 35 to 37 degrees; sliding cut that to 2 to 8). The same contact rule holds for arms. `Feet.flat` does this; `_G.feet` prints the sole tilt, the torso contact and the top-off share. Measured on finished attacks: planted tilt 2 to 8 degrees (12 for a few frames in a follow-through), contact 0 to 0.46, top off 51 to 52%.
- **Waist rule.** The torso turns about its centre, so a lean swings the hips. Add the waist offset so the body bends at the hips.
- **Centre of mass.** The standing R6 COM sits 0.64 below the torso centre and 2.36 above the floor (Winter's human segment weights, body-mechanics.md). Rotations keyed on RootJoint turn about the torso centre; correct big spins and flips so they turn about the COM (r6-mechanics.md).
- **Rigid legs.** Turning the torso turns the hips around the feet. A 56 degree turn from a guard to a punch kept both feet planted only with the torso dropped 0.36; plan the drop with the turn, and use `Feet.gap` to see what a pose needs. A crouch is limited by the leg length; a deeper crouch slides the legs further into the torso than reads.
- **Toe yaw.** Keep the twist of a planted leg against the torso under about 45 degrees and pivot the feet with the hips; the foot checks print `twist`.
- **Fist grip.** A held weapon's handle runs within about 25 degrees of square to the forearm or the block arm looks pierced. The solver penalises it and logs `gripErr`; pick arm directions and blades that are square before solving (weapons.md).
- **Combo flow.** Each swing starts from the last swing's end pose and carries the weapon on the way it was going; the end of one swing is the load of the next. Plan the chain as one path before keying (weapons.md).
- **Hand-over twitch.** The Animator zeroes `Motor6D.Transform` before PreSimulation, so a blend that starts inside a step must come from the rig's last written pose (Poser does this). Check every move's end into the idle with a per-frame part record in Play; an Edit-mode step cannot show it.
- **Held weapon, pumping arm.** Keep the handle within about 20 degrees of square to the forearm; never counter-rotate it in the fist to hold a world angle. The weapon arm still pumps (about 60% of the free arm's range); let the wrist give up to 15 degrees so the tip clears the floor, and check the blade tip height (weapons.md).
- **Locomotion speed.** Build a walk or run for the speed the game moves at: read `WalkSpeed` and the animation reference speed (a clip plays at speed / reference) and measure the clip's planted-foot speed at 1.0x. Check the cadence: cycles per second = speed / stride, with a rigid leg planting about 2.4 studs per stance (about 3.2 studs per walk cycle, 6 per run cycle). Far above 1 to 1.5 cycles a second, lower the game speed, or build a brisk walk and let the game follow it (4.8 studs/s on a 0.84 s cycle read well; 2 studs/s read far too slow), or build the run near 15 studs/s and play it faster (pipeline.md).
- **Runs are judged by the legs.** Swing leg up to about 80 degrees against the torso and pulled up into the hip 0.7 to 0.95 studs (a knee), the back leg kicked to about -50, each foot on the floor about 25% of the cycle, a cycle near 0.66 to 0.7 s (0.9 s reads as a walk), a lean of 19 to 23 degrees, the body riding high with a shallow dip. Legs kept under the body read as a slow shuffle (principles.md).
- **Walks need double support.** Each foot stays planted about 55 to 60% of the cycle; at 50% the weight never settles. Author walks as keyed poses from a measured reference, never as symmetric sines (principles.md).
- **No elbows or knees.** Suggest a bend with a short translation up into the torso or a piston along the limb (fists slide 0.3 to 0.6 studs on strike frames in the reference punches).
- **Overhead reach.** An R6 fist reaches at most torso y 1.99, straight over the shoulder, and the head top is 2.0; over the head centre it reaches only forehead height. A two-handed grip above the head is impossible without sliding the arms out of the shoulders. Explain the limit and ask before building such a pose (weapons.md).

## Read only what the task needs

| Resource | Use |
| --- | --- |
| [lesson-videos.md](references/lesson-videos.md) | Five lesson videos: the 12 principles, timing and spacing, beginner mistakes, a beginner method (favour frames, mixed holds, pull-back, settle, bounce), and physics in animation (centre of mass, balance, rotation, momentum, through motion), each translated to Poser, with the timing-meaning table and the hand-off checklist. |
| [principles.md](references/principles.md) | Posing checklist, timing in frames, overlap, moving holds, springs, game feel, weight and support, recipes for idles, walks, runs, jumps, attacks, emotes, companions and weapons. |
| [body-mechanics.md](references/body-mechanics.md) | Researched physics on R6: segment weights and the COM formula, limits of stability, weight shift, Roblox gravity and the default jump, hang time and the odd rule, takeoff and landing timing, flips (spin rate against shape), the walk's COM path, action and reaction, carrying and pushing, falling and swinging parts. |
| [combat.md](references/combat.md) | Researched combat timing: startup, active and recovery budgets, hitstop by strength, victim shake and attacker creep, cancel windows, reaction-time telegraphs, readability from a pulled-back camera, smears and trails, stepped anime strikes. |
| [locomotion.md](references/locomotion.md) | Researched locomotion: frames per step, walk landmarks and mirrors, double support, trunk motion, walk and run speeds, the walk-run boundary, run keys and cadence, mood in a walk, starts, stops and turns, stride warping, phase sync, the Roblox jump, breathing and fidgets. |
| [keyframe-workflow.md](references/keyframe-workflow.md) | Researched professional workflow: the style dial, thumbnails and the golden pose, whole-pose blocking, stepped to spline, layering, arc tracking, twin fixes, retiming, posing, contrast and phrasing, acting, review with fresh eyes. |
| [stylized-and-roblox.md](references/stylized-and-roblox.md) | Anime-style stepped animation (hold lists, twos, impact frames) and the native Roblox Animator's behaviour (fades, priorities, weights, markers, easing traps, LOD, masks), with R6 animators' own critique. |
| [r6-mechanics.md](references/r6-mechanics.md) | R6 transforms, the centre of mass, joint gaps, the waist, planted feet on rigid legs, contacts and reach. |
| [motion-metrics.md](references/motion-metrics.md) | The measured professional and code-authored numbers, metric definitions, targets, the engine experiment. |
| [quality-review.md](references/quality-review.md) | Symptom to cause table and evidence. |
| [pipeline.md](references/pipeline.md) | Poser fields, Feet, EditStrip, LoadTest, bake and import limits, review videos. |
| [weapons.md](references/weapons.md) | Swords, spears, tools, shields and props: the three-axis grip joint, the arm solver, physical twist, Euler branches, the square grip, weight, reach limits, combo flow, slashes, weapons in locomotion, cinematic speed curves and root motion, growing and giant props. |
| [custom-rigs.md](references/custom-rigs.md) | A creature or any non-R6 Motor6D rig: the leg solver, ground flow for straight and turning gaits, gait numbers, baking loops, get-up from a ragdoll, momentum, turning in place, clip transfer between rigs, shrinking legs, procedural creature movement. |
| [video-rotoscope.md](references/video-rotoscope.md) | A 1:1 copy of a clip from a screen recording: rig export, camera and pose fit, hand-marked prop points, motion tracking, export, Studio checks, and what goes wrong. |
| [skinned-bone-rigs.md](references/skinned-bone-rigs.md) | A skinned Bone rig animated in Blender: find the collarbone before posing, the IK pose solver (`scripts/blender/pose3.py`), the blade-driven hand, chest-frame channels, hair and vine springs, metrics on 17 joints, review renders. |
| [idle-run-land.md](references/idle-run-land.md), [walk-cycles.md](references/walk-cycles.md), [attack-timing.md](references/attack-timing.md), [the-world-clips.md](references/the-world-clips.md) | Decoded reference clips and what they show. |
| [moon-animator.md](references/moon-animator.md) | Editor handoff and round trip. |
| [process.md](references/process.md) | Working with a requester: questions before building, labelled option videos, review modes, restoring versions, delivery. |
| [sources.md](references/sources.md) | The research behind each rule. |
| [clip-plan.md](templates/clip-plan.md) | Brief, beat table, motion layers, measurements, review record. |

`projects/` holds the raw history of the projects this skill was built on (the review log and pre-rewrite snapshots). The rules above already contain what it taught; do not load it for a new task.

Scripts (core, in `scripts/`): `Poser.lua` (runtime, check, dump, bake), `Tw.lua`, `Feet.lua` (planted legs), `RigFeet.lua` (planted legs for custom r6-style rigs from their own geometry), `WeaponRig.lua` (the weapon arm solver, physical twist, Euler branches, the solve cache), `RigTransfer.lua` (exact clip transfer to a re-rigged copy of the same model), `ExampleClips.lua` (a guard and a cross on the method, passing every check), `EditStrip.lua` (Edit-mode strips and the foot check), `Strip.lua` (Play-mode strips), `LoadTest.lua` (fresh module copies from `serve.js`), `motion_check.js` (the metrics on decode text), `ReadClips.lua` (decode a KeyframeSequence), `Bake.lua`, `check_decode.py`, `AnalyzeClips.js`; `video/` (Windows review-video recording and encoding, with sound) and `blender/` (the skinned-rig solver and renders).

Worked examples (in `scripts/examples/`): `locomotion-starter/` (idle, walk, run, air and land for a fresh place), `stand-combat/` (a stand and its user, legacy eases, with Play-mode stand strips), `armored-warrior/` (a custom r6-style rig: idle, walk and run on `RigFeet`, plus the offline tools that traced it), `greatsword/` (Edit strips, onion skin and foot and tip checks for a two-handed greatsword), `three-sword-kit/` (two hands and the mouth, root spin and dash fields, the take camera), `quadruped/` (the creature leg solver and its clips). Adapt their module paths before use.
