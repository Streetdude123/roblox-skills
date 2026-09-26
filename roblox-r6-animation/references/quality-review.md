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
| Still frames, dead holds | `Poser.check`: rest% over 45, still runs, contrast over 10 | `curve = "spline"` so breakdowns keep their speed; holds that drift 5 to 15% further; recoveries that hold then pop back instead of a slow ease to idle. |
| Robotic, everything stops together | unison over 4/s, spread under 1 frame, keys on the same times for every joint | Offset carried parts with `lag` or by moving their keys 1 to 3 frames; springs on carried parts. |
| Snap then freeze | contrast over 10, a jolt (a part leaving a full stop at half its peak speed) | Remove the legacy ease that stops at the key before the snap; a moving anticipation hold; keyed follow-through. |
| Twitch when a move ends and the idle takes over (Play only) | Part CFrames per RenderStepped in Play: one frozen frame, then every joint jumps on the same frame | A blend that starts inside the step read `motor.Transform` after the Animator zeroed it; blend from the rig's last written pose (fixed in Poser). A single snap inside a clip is keys too close after a slow warp hold or opposing lags. |
| Next combo swing looks weird | The blade at the last swing's hold against the next swing's first keys | The next swing detours to its own load; start it from the hold pose and carry the blade on (weapons.md, "A combo flows"). |
| Head off the target at a contact | Torso twist plus head twist at the contact frame | Head keys that counter the torso on the torso's frames; no lag or spring on that head. |
| Feet slide or sink when the torso turns | `_G.feet`: slide, lowest corner, hip gap | `post = Feet.post`; lean from the waist; drop the torso with the turn (`Feet.gap` gives the need). |
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
- Planted feet: `_G.feet(clip)` from `scripts/EditStrip.lua` (lowest sole corner, slide of the sole centre while planted, hip gap).
- Common faults: `python3 scripts/faults.py <decode>`. Each flag gives the time span and a first repair:

| Flag | Rule | Calibration |
| --- | --- | --- |
| twinning | both arms within 8 degrees of each other's mirror image for 0.25 s, both 25 degrees or more from hanging | the first landing draft's recovery (0.53 to 1.40 s) and a later draft's end stance with the arms crossed in front |
| dead arm | an arm within 15 degrees of straight down and under 20 degrees a second for 0.4 s while the torso leans 15 degrees or more | the synthetic test only; the first landing draft's lifeless arms pointed 20 to 30 degrees back, not down, and were caught as twinning instead |
| neutral pose | every joint within 12 degrees of the default stand for 3 frames away from the clip's first and last 0.1 s | the reference study: no key is neutral |
| pop | a part turns more than 90 degrees in one frame | the pro heavy punch turns an arm 67 to 70 degrees in a frame and passes; the throw's whip (113) is flagged because it needs a smear |
| through the floor | a corner of an arm, the head or the torso more than 0.05 below the floor | a landing draft's bracing arm went 0.14 under |
| flat leg | a planted leg more than 55 degrees from vertical | the pro landing angles its legs 25 to 40 degrees back; the first two landing drafts (57 to 68) read flat; a kneel is flat on purpose |
| leg twist | a planted toe more than 60 degrees off the torso's heading | the examples read 5 to 51; the first throw draft 97 to 111 |
| hip gap, foot slide | the foot check over 0.12 and 0.05 | SKILL.md |
| hidden strike | at the strike frame the striking limb shows under 20% of its pixels from the player camera (`--view`, default `rear34`) and the whole figure keeps more than 70% of its start silhouette | the first M1 jab (1%, 83%) and hook (0%, 73%); the pro left stab hides its arm (4%) but keeps only 46% of its silhouette and passes |
| small silhouette change | the strike frame keeps more than 75% of the start silhouette from the player camera | the pro strikes keep 46 to 67%; the throw's whip frame keeps 77% (the arm passes over the head, inside the outline) and stays flagged |
| outruns the strike | an arm, the head or the torso has its fastest world speed more than 6 frames from the strike and more than 0.9 of its speed at the strike | the seven pro stand clips pass; raw motion capture flags recoveries and hooks where the fastest whole-body moment is not the strike, so name it with `--strike` |

The seven pro stand clips and the stand's idle in `references/decodes` pass with `--float`; the example clips pass except the flags kept on purpose (the throw's whip: a pop that needs a smear and a small silhouette change; the superhero kneel's flat leg). The staging checks skip a clip whose fastest moment is its first frames (a landing). Name the strike with `--strike` on a clip with several hits.

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

It needs Python 3, which Lepy's machine does not have on its path; `motion_check.js` runs on Node. The tool reads the format written by `ReadClips.lua`. It reports local pose endpoint differences, sampled rotation steps, sample gaps, non-linear easing, markers, and local translation velocity mismatch. It reconstructs rotations before comparing them, so a 179-to-minus-179 Euler wrap is not mistaken for a 358-degree turn.

Use those measurements to choose what to inspect. Large steps can be intentional. A small local seam does not prove world-space foot contact. Rounded decodes cannot prove sub-frame or sub-centimeter precision; they also omit some source information, including pose weights. The tool checks input structure, not whether an animation is good.

## Record evidence without performing a ritual

For each actual correction, record the source revision, clip time, view, visible issue, reason for the edit, and the recheck. Compare from the same view and scale. If a capture tool caches images, confirm freshness through its supported controls; a tiny camera nudge is a workaround only when observed for that tool.

Lepy's standard of done (CLAUDE.md): a clip is done when a capture from the player's camera was taken, read and iterated on at least twice, the console is clean, and the report shows the captures and the numbers. Each iteration fixes something the capture or a number showed; do not change a correct pose just to count a round. If playback cannot be inspected, report that specific limit and provide the source work that was completed.

When performance is in scope, profile on the target configuration and compare against a baseline there. Record hardware or device, quality settings, visible character count, sample duration, and first-use versus steady-state behavior. Do not equate one foreground Studio frame-time reading with a device budget.
