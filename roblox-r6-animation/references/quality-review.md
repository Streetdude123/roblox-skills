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

- Plant drift: maximum horizontal distance from the chosen world contact target during its contact interval.
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

The tool reads the format written by `ReadClips.lua`. It reports local pose endpoint differences, sampled rotation steps, sample gaps, non-linear easing, markers, and local translation velocity mismatch. It reconstructs rotations before comparing them, so a 179-to-minus-179 Euler wrap is not mistaken for a 358-degree turn.

Use those measurements to choose what to inspect. Large steps can be intentional. A small local seam does not prove world-space foot contact. Rounded decodes cannot prove sub-frame or sub-centimeter precision; they also omit some source information, including pose weights. The tool checks input structure, not whether an animation is good.

## Record evidence without performing a ritual

For each actual correction, record the source revision, clip time, view, visible issue, reason for the edit, and the recheck. Compare from the same view and scale. If a capture tool caches images, confirm freshness through its supported controls; a tiny camera nudge is a workaround only when observed for that tool.

Finish when the relevant checks pass. Do not require two arbitrary edits, mandatory overshoot, or a forced change to a correct clip. If playback cannot be inspected, report that specific limit and provide the source work that was completed.

When performance is in scope, profile on the target configuration and compare against a baseline there. Record hardware or device, quality settings, visible character count, sample duration, and first-use versus steady-state behavior. Do not equate one foreground Studio frame-time reading with a device budget.
