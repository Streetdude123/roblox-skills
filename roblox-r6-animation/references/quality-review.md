# Review and diagnosis

Review the action in the environment where it will be seen. Use the sources in [sources.md](sources.md) for principles, and the clip brief for artistic intent. These checks are a practical review procedure, not an automatic professional-quality score.

## Inspect in this order

1. Intent and silhouette: can the main poses explain the action at gameplay distance?
2. Support and weight: what supports the character, and when does that support change?
3. Timing and spacing: where does the action accelerate, contact, brake, and settle?
4. Paths and contacts: do hands, feet, and props follow the intended paths between keys?
5. Transitions: does the clip enter, loop, exit, or cancel as intended?
6. Secondary movement: does it support the action without weakening a hold?

Use stepped poses for the first check and real-time playback for timing. Use slow playback and frame stepping to locate faults. A strip cannot demonstrate frame spacing or contact stability between its selected samples. Inspect the source and exported playback separately.

## Match a symptom to a cause

| Symptom | Inspect | First repair to consider |
| --- | --- | --- |
| Still frames, dead holds | `Poser.check`: rest% over 45, still runs, contrast over 10. When rest stays high after the fixes, print each joint's speed curve and find the beat that holds its peak. | `curve = "spline"` so breakdowns keep their speed; holds that drift 5 to 15% further; recoveries that hold then pop back instead of a slow ease to idle. Make the main action each joint's fastest beat: rest counts the time under a tenth of a joint's own peak, so one fast wrong beat raises the threshold and the rest of the joint's motion counts as rest. A raise at 3404 deg/s before an 876 deg/s whip held rest at 54.8%; a slower raise made the whip the peak and rest fell to 47.6%. |
| Robotic, everything stops together | unison over 4/s, spread under 1 frame, keys on the same times for every joint | Offset carried parts with `lag` or by moving their keys 1 to 3 frames; springs on carried parts. |
| A walk or run cycle reads robotic while rest, contrast and unison pass | Measure the tells first: torso roll under 1.5 degrees with no sideways sway (no weight over the stance foot); a carried arm that moves only 2 to 4 degrees; head reversals per cycle (8 on a run head, against 2 to 5 per channel); a bob that glides flat through each stance, then drops. A strong or heavy character keeps roll near 1 degree and sway under 0.05 on purpose, so low roll alone is not its fault. | Shift the weight over the stance foot with roll and sway toward it; a head counter-roll 2 to 4 frames late; a head held level; a weapon arm that pumps with the stride (about 60% of the free arm's range); a smooth bob shaped from the reference, never clamped into a plateau. Starting amounts: principles.md, "Walk" and "Run". A strong or heavy character gets its life from the legs, the bob and the free arm. |
| Snap then freeze | contrast over 10, a jolt (a part leaving a full stop at half its peak speed) | Remove the legacy ease that stops at the key before the snap; a moving anticipation hold; keyed follow-through. |
| Jumps between holds in a saved or supplied clip | The easing column of a `ReadClips.lua` decode (`check_decode.py` lists each joint's easing): `Constant` | A `Constant` key holds its pose, then jumps to the next key, so treat every one as a snap. Rebuild the clip on spline keys. |
| Twitch when a move ends and the idle takes over (Play only) | Part CFrames per RenderStepped in Play: one frozen frame, then every joint jumps on the same frame (the turn check under "Measure only what answers a question") | A blend that starts inside the step read `motor.Transform` after the Animator zeroed it; blend from the rig's last written pose (fixed in Poser). A single snap inside a clip is keys too close after a slow warp hold, opposing lags, or a flourish that starts on a leg-step frame. |
| One-frame arm flip (40 to 98 degrees) at the start or end of a hold (Play only) | A per-frame part log: the jump lands while two tracks fade, one with the arm raised and one with it down | Blending two poses near 180 degrees apart takes the short way and flips. Start a raised-arm hold track only after the attack clip is at full weight (0.2 s later, under it at a lower priority), and bring the arm down with a clip (the raise clip played backward: `TimePosition = Length`, `AdjustSpeed(-1)`) before the walk fades in. Measured on a boss rig: 74 and 98 degree flips gone, every transition 8 degrees per frame or less. |
| A one-shot ends in the rest pose before the next clip (Play only) | The track list in the log: the one-shot drops to 0 before the next clip has weight | A server wait of the clip length overshoots and the non-looped track stops at its end. Put the next clip (the hold or an idle) underneath it at a lower priority from the start, so its end reveals the next pose. |
| Next combo swing looks weird | The blade at the last swing's hold against the next swing's first keys | The next swing detours to its own load; start it from the hold pose and carry the blade on (weapons.md, "A combo flows"). |
| Head off the target at a contact | Torso twist plus head twist at the contact frame | Head keys that counter the torso on the torso's frames; no lag or spring on that head. |
| Feet slide or sink when the torso turns | `_G.feet`: slide, lowest corner, sole tilt, torso contact | `post = Feet.flat`; lean from the waist; drop the torso with the turn. |
| Feet stand on a corner (tilted soles) | `_G.feet`: sole tilt over about 8 degrees | `Feet.flat` instead of `Feet.post`; bring the foot target under the torso; drop the torso where it rises or leans back. |
| Stiff | Repeated pose shapes, equal timing, parts moving as one without intent | Improve the main pose and contrast of timing; then add motivated overlap. |
| Floaty | Support changes, slow braking before impact, unearned root rise | Restore contact and weight transfer; reshape spacing around the impact. |
| Weak strike | Target path, fastest interval, incoming pose, contact silhouette | Correct direction and acceleration; preserve the required impact time. |
| Rubber body | `back` applied everywhere, excessive translations, too many reversals | Remove unmotivated overshoot and fix joint gaps. |
| Sliding foot | World-space sole positions during stance | Fix horizontal contact and stride; a Y-only solve is insufficient. |
| Floor penetration | Sole corners between keys, not just center height | Adjust orientation, support point, torso height, or breakdown. |
| Wandering grip | Both hand endpoints in prop space | Solve contacts together or revise the stance and prop path. |
| Body intersection | Mid-interval paths and shoulder/hip translations | Add clearance breakdowns or simplify the pose. |
| Jitter | Competing joint writers, controller discontinuity, Euler branch flips | Establish ownership; compare rotation matrices before editing angles. |
| Loop hitch | Endpoints plus incoming/outgoing velocity and wrapped procedural periods | Repair the seam; matching frame zero alone is insufficient. |
| Frozen legs in attack | Override replaced the whole locomotion clip | Compose legs from locomotion explicitly or choose a true masked runtime. |
| Correct source, wrong export | Easing, markers, weights, priorities, exact duration | Compare the native export with the source and repair the conversion. |
| First-use hitch | Profiler trace, asset loads, first use versus repeated playback | Fix the measured cause; do not assume every hitch is mesh warm-up. |

## Measure only what answers a question

- Motion quality: `Poser.check(clip).text` in Studio or `node scripts/motion_check.js clip.txt` on a decode. Ranges and definitions: [motion-metrics.md](motion-metrics.md). Compare with a professional clip of the same kind, not only with the targets.
- Planted feet: `_G.feet(clip)` from `scripts/EditStrip.lua` (lowest sole corner, slide of the sole centre while planted, sole tilt, torso contact, top-off share). The hip gap only shows how far a leg slid; it is not a fault on its own.
- One-frame pops: a per-frame turn check next to `Poser.check`. Rest, contrast and unison average over the clip, so a one-frame pop passes them (leg flips of 75 to 84 degrees passed the motion check). In Play, record each part's CFrame relative to the root on every RenderStepped, convert it to degrees per 1/60 s, and flag frames over 3 degrees and over 2.2 times both neighbours. Ignore a flag right after a long frame: that is a hitch, not the animation. Look for snaps inside clips (keys close together after a slow warp hold, opposing lags, a flourish on a leg-step frame; a sheathe turned the torso 36 degrees in one frame from keys 0.04 s apart) and at every hand-over. Strike frames are the expected peaks: a blade's world direction may turn 42 to 86 degrees a frame there, while a single joint on a strike squeezed into fewer frames stays under about 25 degrees a frame (1500 deg/s; weapons.md, "Measure the blade").

- Plant drift: maximum horizontal distance from the chosen world contact target during its contact interval. Measure each foot's contact windows on their own: after a root-motion dash that glides by design, one anchor across the dash hid 0.62 and 0.33 studs of real slide in the recovery. Judge a foot that pivots in place by the point it turns on (its centre), not by a corner: a corner sweeps a circle as the foot turns and reads as slide (0.25 studs of false slide on a ground spin whose pivot foot was fixed in the world).
- Floor error: signed height of the selected support point and the lowest sole corner relative to the actual floor.
- Grip error: distance between the intended hand contact and the target in prop space.
- Arc spacing: endpoint distances at equal time intervals. Include the intervals immediately before and after impact.
- Loop pose seam: positional distance and shortest rotation difference between matching start/end transforms.
- Loop motion seam: compare finite differences immediately before and after the boundary in the same coordinate space.
- Timing error: difference between intended and observed contact/event time, in seconds and at the chosen FPS.

Choose tolerances for the rig scale, camera distance, style, and export precision. State them before using them as acceptance criteria. Do not invent a universal foot-slip tolerance or frame-time target.

## Use the bundled decode check

Run from the skill directory:

```sh
python3 scripts/check_decode.py references/decodes/TW_idle.txt
python3 scripts/check_decode.py references/decodes/*.txt --json
```

It needs Python 3; where Python is missing, `motion_check.js` runs on Node. The tool reads the format written by `ReadClips.lua`. It reports local pose endpoint differences, sampled rotation steps, sample gaps, non-linear easing, markers, and local translation velocity mismatch. It reconstructs rotations before comparing them, so a 179-to-minus-179 Euler wrap is not mistaken for a 358-degree turn.

Use those measurements to choose what to inspect. Large steps can be intentional. A small local seam does not prove world-space foot contact. Rounded decodes cannot prove sub-frame or sub-centimeter precision; they also omit some source information, including pose weights. The tool checks input structure, not whether an animation is good.

## Audit an existing character

Before fixing a character's clips, audit them three ways: decode each clip (`ReadClips.lua`), run forward kinematics on the decode, and log every part per frame with a client probe in Play. One audit of a boss rig found every fault below at once:

- Planted-foot speed against the move speed: a walk that planted at 3.6 studs/s on a character moving at 1.4 studs/s skated.
- Feet under the floor: planted soles sat 0.13 studs under on average and 0.43 at worst.
- Single-frame holds: a hold clip of one pose froze the character for the whole wait (10 to 15 s).
- Shared clips: two moves played the same 0.53 s clip.
- Keys on joint names the rig does not have: a clip that keys `Handle` on a rig whose weapon joint has another name never moves the weapon.
- Rest-pose flashes: one frame of the rest pose between two clips.
- Chain gaps: a 0.3 s gap between a wind-up and its hold, then a 129 degree arm jump in one frame.
- One-frame turns: the body turned 111 degrees in one frame toward a target and back. Turn toward a target over about 0.3 s.
- Late first plays: a clip that was not loaded ahead started 2.5 s late, so the impacts landed on the rest pose. Load every clip before its first use.
- Per-frame arm steps: 28 to 40 degrees per frame in slams and wind-ups.

Check what each clip the code references contains, not only its name: the track the code called the idle held the arms-up charge pose, and the character had no idle clip. After the fixes the probe showed no rest-pose gaps, every transition at 8 degrees per frame or less, the turn toward the target over 0.3 s, and the stance foot sliding 0.1 to 0.13 studs per step at 1.4 studs/s.

## Record evidence without performing a ritual

For each actual correction, record the source revision, clip time, view, visible issue, reason for the edit, and the recheck. Compare from the same view and scale. If a capture tool caches images, confirm freshness through its supported controls; a tiny camera nudge is a workaround only when observed for that tool.

Standard of done: a clip is done when a capture from the player's camera was taken, read and iterated on at least twice, the console is clean, and the report shows the captures and the numbers. Each iteration fixes something the capture or a number showed; do not change a correct pose just to count a round. If playback cannot be inspected, report that specific limit and provide the source work that was completed.

When performance is in scope, profile on the target configuration and compare against a baseline there. Record hardware or device, quality settings, visible character count, sample duration, and first-use versus steady-state behavior. Do not equate one foreground Studio frame-time reading with a device budget.
