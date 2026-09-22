---
name: roblox-r6-animation
description: Create, refine, inspect, and export Roblox R6 character animation in code. Use for R6 idle, walk, run, jump, landing, attacks, combos, emotes, weapon motion, and stand animation; fixing stiff poses, floaty timing, sliding feet, and broken transitions; studying reference clips; and KeyframeSequence or Moon Animator handoff. Follow a reference-led blocking, breakdown, polish, and verification workflow using the existing Poser pipeline or the project's Animator pipeline.
---

# Roblox R6 animation

Make the action read through posing, weight, timing, and contact. Treat professional quality as a result to inspect, not a preset or a promise. Keep the requested action and style intact. Do not add VFX, camera motion, combat mechanics, sprint controls, or a replacement locomotion system unless the task requires them.

## Start with the actual task

1. Read project instructions and inspect the animation setup. Discover available Studio tools; `execute_luau` and `screen_capture` are examples, not guaranteed capabilities.
2. Extract the action, intent, reference, duration, loop or one-shot, target rig, camera, props, movement permission, and delivery format. Ask about missing details that would change the animation. Do not ask again for information already supplied or visible in the project.
3. Inspect parts, sizes, `Motor6D.Part0`, `Part1`, `C0`, `C1`, root, weapon grip, start pose, and existing controller. Confirm R6. Do not assume standard joints or a `ReplicatedStorage.Stand` folder.
4. Read [principles.md](references/principles.md), then the relevant motion reference below. Read [pipeline.md](references/pipeline.md) before running bundled scripts. Use [project-style.md](references/project-style.md) only for the recorded Lepy or DIO setup.
5. Use [clip-plan.md](templates/clip-plan.md) for task notes. Fill only the decisions needed for this clip. Keep a simple edit brief.

Separate engine facts, source observations, and authoring choices. Label chosen timing as a choice. A measured number describes its source clip; it does not make other motion wrong. The measurement tables preserve earlier work; their original assets and captures are not all bundled.

## Choose the pipeline

| Situation | Action |
| --- | --- |
| Existing Poser project | Preserve that runtime. Author keyed or procedural clips, inspect them in Studio, then bake if requested. |
| Existing Animator project | Preserve Animator and its state controller. Deliver an editable sequence or animation asset using the existing priorities and events. |
| Matching supplied animation | Inspect it before reauthoring. Use native playback when the custom importer cannot preserve its features. |
| New place or unknown setup | Inspect tools and ask which handoff is needed before installing a controller or changing default character animation. |
| No Studio connection | Improve source, plans, and offline checks. Leave visual, playback, and replication checks explicitly unverified. Never fabricate captures. |

Authoring in code does not require banning AnimationTracks or the Animation Editor. They are playback and editing tools, not causes of stiff animation. Avoid TweenService as a competing writer on animated joints. Give each joint one owner or an explicit blend in the final pose evaluation.

## Pass 1 - study reference and plan the action

Use the supplied reference first. For unfamiliar mechanics, find a reference that clearly shows the support and action. Record its URL or asset path, useful timestamps, source frame rate when known, and what was actually inspected. If only text or a transcript is available, do not claim to have watched the motion.

Identify intent, preparation, weight transfer, action, contact or release, follow-through, and recovery. Some actions omit phases or inherit them from the previous action. Separate camera movement from body movement. Translate the reference to R6's rigid limbs; do not invent elbows, knees, or wrists.

Build a beat table:

| Frame and seconds | Beat and silhouette | Support or contact | Leading action | Secondary response | Event or constraint |
| --- | --- | --- | --- | --- | --- |
| From reference or brief | What the pose communicates | Planted feet or grips | What initiates motion | What follows or stays stable | Impact, release, cancel, or loop boundary |

Choose and record authoring FPS. Convert with `seconds = frame / fps`; playback remains time-based. Do not interpret every reference as 60 fps. Obtain required impact and cancel times from the gameplay contract before retiming them.

## Pass 2 - block readable poses

Create the few poses that explain the action with stepped timing. In Poser, `snap` on the destination key holds the previous pose until that key. Keep synchronized body keys while blocking when that makes poses easier to judge.

- State the intent and direction of force. Arrange the torso, head, and limbs into a readable gesture.
- Place support before adding a lean or reach. Transfer weight before releasing a foot.
- Check silhouette from the actual player camera and a second useful angle. Keep hands and props readable without changing the requested action just to expose a limb.
- Use asymmetry for weight or character. Preserve deliberate symmetry in a two-handed action, ritual, or designed stance.
- Use the least limb translation needed for the R6 pose. A limb key's translation IS the joint gap: the hip pivots at the leg's top corner, so a leg slid 0.45 forward for a stance or pulled 0.3 down to plant a foot leaves daylight between the torso and the leg. Keep leg translations under 0.12 and put the stance into the hip angles instead (a 13 degree swing moves the foot 0.45); plant a foot by dropping the torso onto the legs, never by pulling the leg out of the hip; a leg shoved UP into the torso is hidden and allowed. Arms may carry up to 0.25 where the part overlaps the torso. Measure the gap in torso space before a capture (`references/r6-mechanics.md`). "it can be a TINY little bit off the body but not like that" (2026-09-22, a circled hip gap).

Do not smooth a weak pose. Review blocking before adding breathing, overshoot, or decorative movement.

## Pass 3 - add breakdowns and spacing

Place breakdowns where the path changes: torso clearance, foot lift, weapon crossing, reversal, or contact. Track hand, foot, head, and weapon tip in world space. A good joint-angle curve can still produce a bad endpoint path.

| Desired spacing | Poser choice to consider | Check |
| --- | --- | --- |
| Accelerate toward a strike | `quad` or `cubic` **in** | Speed increases toward the target. |
| Snap away then brake | `quad`, `cubic`, or `quart` **out** | The largest step occurs early; arrival decelerates. |
| Gentle reversal or breath | `sine` **inout** | Pause and arc match the intent. |
| Uniform spacing between sampled poses | `linear` | The reference is actually sampled densely enough. |
| Deliberate stepped hold | `snap` | The jump occurs at the intended frame. |
| Loose overshoot and settle | Explicit overshoot keys, or `back` on an unconstrained channel | The motion preserves plants, grips, and collisions. |

Poser stores easing on the **destination** key. `back` extrapolates past a target; it is not impact or recoil by itself. Its parameter is not an overshoot percentage. Use explicit keys when contact, direction, or exact overshoot timing matters.

Add overlap by cause: head may lead a look, torso may lead a throw, hands may lead a reach, and arms may absorb a landing. Offset releases and settles where useful. Keep required contacts synchronized. Do not shift every joint by a fixed lag ladder.

Keep purposeful holds. Breathing belongs where a living character should breathe; a planted foot, locked grip, statue, or time-stop can be still. Vary preparation, action, and settle instead of making every clip use the same snap-and-bounce pattern.

## Pass 4 - solve contacts and transitions

Read [r6-mechanics.md](references/r6-mechanics.md) for pose space, forward kinematics, endpoint checks, and contact correction.

- Record each plant's world-space target and contact interval. Check horizontal drift and floor penetration throughout it. A Y-only correction does not prevent sliding.
- Preserve grips in prop space. Check both hands on two-handed weapons. Revise the pose when R6's rigid limbs cannot satisfy the constraints.
- Separate visual torso offset from `HumanoidRootPart` world travel. A RootJoint pose does not implement gameplay displacement or server hitboxes.
- Match locomotion phase to traveled distance, then verify plants. Test relevant starts, stops, turns, speed changes, and landings.
- Match pose and motion direction at loops and handoffs. Check the final interval into the first. Do not return every attack to idle when the next attack is its recovery.
- Explicitly compose overlays with locomotion. The bundled `Locomotion.override` replaces its active clip; omitted legs do not automatically continue walking.

## Pass 5 - polish at playback speed

Review full playback, then scrub problem intervals. Check weight, rhythm, endpoint arcs, contact, silhouette, and recovery in that order. Add restrained secondary movement after the action works.

Identify the frame, affected part, and cause before editing. Change the smallest relevant pose, timing, or path, then recheck that interval and its transitions. Do not change a correct number merely to meet an iteration quota.

Use [quality-review.md](references/quality-review.md) for diagnosis and evidence. A motion strip shows poses; it cannot prove timing, impact, or a clean playback transition.

## Pass 6 - verify and hand off

1. Check joint names, increasing times, clip bounds, start and end poses, event times, and joint ownership.
2. Inspect blocking and final playback from the player camera. Use another view to resolve occlusion or penetration. Tie captures to the source revision and clip times.
3. Exercise relevant integration paths: loop, transition, cancel, interruption, speed change, respawn, or remote observer. Check Studio output.
4. Inspect the exported `KeyframeSequence` instance tree and replay it. Check duration, endpoint, hierarchy, priority, loop flag, keyed joints, and markers. Read [pipeline.md](references/pipeline.md) for baker and importer limitations.
5. Report the artifact or instance path, key decisions, checks performed, and remaining limits. Distinguish **authored**, **structurally checked**, **visually reviewed**, **runtime tested**, and **user accepted**. One does not imply the others.

Keep editable source keys. Bake a separate delivery copy at a rate that preserves the action; include exact event and final times. Do not present a dense bake as an editable Moon Animator project. A script passing or a successful upload does not prove professional quality.

## Read only what the task needs

| Resource | Use |
| --- | --- |
| [principles.md](references/principles.md) | Posing, weight, spacing, overlap, acting, and motion-specific decisions. |
| [r6-mechanics.md](references/r6-mechanics.md) | R6 transforms, contacts, and reach limits. |
| [quality-review.md](references/quality-review.md) | Diagnose visible faults and record evidence. |
| [pipeline.md](references/pipeline.md) | Module contracts, installation, playback, and export limits. |
| [moon-animator.md](references/moon-animator.md) | Inspect an editor round trip without assuming plugin internals. |
| [sources.md](references/sources.md) | Linked primary references and what each supports. |
| [project-style.md](references/project-style.md) | Existing review history scoped to Lepy or DIO tasks. |
| [idle-run-land.md](references/idle-run-land.md) | Recorded idle, run, and landing measurements. |
| [walk-cycles.md](references/walk-cycles.md) | Recorded walk poses and controller phase convention. |
| [attack-timing.md](references/attack-timing.md) | Recorded sword timing; compare the action, not just the numbers. |
| [the-world-clips.md](references/the-world-clips.md) | Bundled stand decodes and their recorded interpretation. |
| [clip-plan.md](templates/clip-plan.md) | Reusable brief, beat table, contact plan, and review record. |

Use `scripts/Clips.lua` as a project-specific example, not a standalone installation. Use `ClipsLocomotion.lua` only when that locomotion setup is requested. Inspect inputs before running `Strip.lua`, `StandStrip.lua`, `ReadClips.lua`, or `Bake.lua`. Use `scripts/check_decode.py` for decoded local endpoint seams and sampling limits; it does not judge quality or world-space contacts.
