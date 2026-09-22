# Visual review and performance verification

Treat visual quality, runtime correctness, and performance as separate evidence.
A source review cannot prove any rendered result. Use the actual Studio/client
capabilities available in the session and keep captures tied to a revision.

## Contents

- [Repeatable view](#establish-a-repeatable-view)
- [Quality review](#quality-review)
- [Diagnosis](#common-diagnosis-paths)
- [Performance](#runtime-and-performance-pass)
- [Lifecycle cases](#lifecycle-cases)
- [Tool limitations](#tool-limitations)

## Establish a repeatable view

Record effect/template revision, parameters, camera, animation/event, scene,
quality level, device, and playback speed. Preview in a simple scene and the real
gameplay scene. Include a human-scale reference where scale matters.

Capture normal-speed playback before relying on stills. Select frames at onset,
peak, breakup, and tail. Compare the same view before and after an edit. Inspect
front, side, player view, and a moving camera when relevant. For randomness, repeat
several casts; use a fixed seed for code-authored variation during comparisons.

Test low and high graphics settings, with the target device deciding the budget.
Do not force maximum quality as the only valid review. Essential gameplay cues
must remain readable without a particular bloom or post-processing setting.

## Quality review

| Gate | Evidence | Typical corrective action |
|---|---|---|
| Meaning | Normal-speed view with actual hit/state events | Correct contact, timing, or gameplay footprint |
| Silhouette | Small gameplay view and isolated primary layer | Redesign contour, coverage, or direction |
| Hierarchy | Grayscale and full color in the real map | Separate values, reduce overlap, change edge contrast |
| Timing | Whole cast plus selected intervals | Adjust leading spacing, peak, lag, or exit |
| Material | Layer isolation and oblique views | Fix texture evolution, flow, volume, or breakup |
| Integration | Moving anchors, slopes, fast casts, two clients | Correct coordinates, event ownership, or lifetime |
| Completion | Normal end and interruption | Cancel work and clean up owned state |

Review notes must identify a visible symptom and time/capture. Fix one important
cause, replay, and compare. Do not award a professional-quality label based on a
checklist or arbitrary score without examining the output.

## Common diagnosis paths

| Symptom | Inspect first | Avoid as an automatic fix |
|---|---|---|
| Soft or late hit | First visible contour and time to peak | More particles |
| White blob | Additive overlap and bright coverage | More bloom |
| Flat cards | Orientation, contour, and camera angle | More copies of the same sprite |
| Identical repeated stamps | Texture evolution, distribution, rotation | Unbounded randomness |
| Ground ring floats | Surface normal, pivot, and carrier position | A larger ZOffset |
| Tail vanishes | Last emit time and cleanup ownership | A fixed long Debris delay everywhere |
| Motion feels noisy | Competing directions and synchronized peaks | Smoothing every layer equally |
| Recast leaves fragments | Connections, pending events, and trail history | Silently skipping errors |

## Runtime and performance pass

Choose realistic simultaneous use from the game, not an arbitrary particle count.
Measure idle, fresh-session first use, repeated use, and overlapping use. Record
frame-time spikes and the workload that caused them; average FPS alone hides hitches.
Use the MicroProfiler to distinguish scripting, simulation, rendering, and asset work.

At normal particle speed, approximate steady population as
`Rate * average Lifetime`; add all emitters and overlapping bursts. This estimate is
not a GPU budget. Large overlapping transparent sprites can cost more than many
small sparse ones. Inspect screen coverage and overdraw as well as instance count.

At 60 fps the whole frame has about 16.67 ms; at 30 fps it has about 33.33 ms.
Allocate the effect's budget within the game, not the entire frame to VFX. Test a
real baseline device. Studio's device emulator checks layout and controls; it does
not reproduce that device's memory or thermal performance.

Optimize the measured cause:

- Reduce wasteful transparent coverage, overlapping layers, unnecessary property
  updates, and redundant lights where rendering is the cost.
- Reuse useful assets and keep unused kits out of replicated content.
- Preload essential assets and measure any warm-up; do not guarantee invisible
  draws solve first use or simply move a hitch into joining.
- Pool/reuse only when allocation or creation cost is demonstrated. Reset all
  relevant state before reuse and verify memory returns to a stable level.
- Preserve the primary gameplay cue when dropping secondary detail by distance or
  quality. Test transitions so LOD changes do not pop or change apparent hit range.

## Lifecycle cases

Run relevant cases: normal finish, cancel during buildup, cancel at peak, cancel
during tail, immediate recast, overlapping casters, moving/removed target, respawn,
and trail teleport. Check temporary instance counts after tails finish and confirm
no callbacks continue writing to a disposed effect.

If slow preview changes particle speed, account for tail duration and all other
clocks. A slowed client beside an unscaled server is not valid timing evidence.
Never judge real-time performance from a slowed capture.

## Tool limitations

A screenshot is evidence of one frame, not fluidity. Tool round-trip delay is not a
precise capture scheduler. Use a project preview phase/time control or a recording.
A particle system needs replay/simulation history to represent a later frame.

Verify camera/phase/time in captures before suspecting caching. If a bridge appears
stale, test a visible state change and document its behavior. Do not bake blanket
claims about screenshot caches, CoreGui visibility, isolated VMs, or editor writes
into an engine rule. Follow the actual bridge documentation.

If Studio is unfocused or throttled, compare with a foreground run and label that
condition. There is no universal valid idle frame time. If visual tools are absent,
finish supported source work and leave visual/runtime/performance gates unverified.
