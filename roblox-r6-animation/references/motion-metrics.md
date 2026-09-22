# Motion metrics

Measured 2026-09-22 in the DIO place (`jojo stand`). Every clip was sampled at 60 fps and written as ReadClips decode text (0.1 degree and 0.01 stud rounding), then measured with `scripts/motion_check.js`. `Poser.check` computes the same numbers on exact samples inside Studio. The numbers describe motion quality proxies, not taste: a clip can pass every range and still have a weak pose. Use them to find stops, freezes, unison and sliding feet before a capture, and to compare with the professional clips.

## Contents

- Definitions
- Professional reference clips
- Earlier Claude clips
- What the engine alone changes
- The example clips
- Targets
- How to measure

## Definitions

Speeds are central differences over 4 frames (so decode rounding cannot fake a stop). A joint's speed is degrees per second of turn plus 30 times studs per second of slide (the end of a 2 stud limb moves 1 stud in 30 degrees). A joint is active when its peak speed reaches 60.

| Name | Meaning | Why it matters |
| --- | --- | --- |
| frozen% | Frames where no joint turns over 1.5 deg/s or slides over 0.06 stud/s across a 16 frame window | A frozen body reads as a paused game. Breath and drift count as life here. |
| still% and longest | Frames where no joint turns over 12 deg/s or slides over 0.3 stud/s, and the longest such run | In an action, a still run reads as a still frame. |
| rest% | Mean over active joints of the time spent under a tenth of that joint's own peak speed | High rest is snap-then-dead motion. |
| stops/s | Rests of 4 frames or more per active joint per second | Each is a full stop of that part. |
| unison/s | Moments per second when three or more active joints start resting together | Joints that stop together read as a robot. |
| contrast | Peak body speed over median body speed | Over 10 means the body snaps between near-stills. |
| spread | Standard deviation of the frames where each active joint peaks | Near 0 means every part peaks on one frame. |
| lag | Frame offset of the best speed correlation between the torso and each joint (positive trails) | Overlap. |

## Professional reference clips

| Clip | Length | frozen% | still% | rest% | stops/s | unison/s | contrast | spread |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TW RightPunch (Moon Animator, chained) | 0.42 | 0 | 0 | 39.8 | 1.2 | 2.4 | 10.6 | 2.6 |
| TW LeftPunch | 0.42 | 0 | 0 | 26.9 | 0.8 | 0 | 3.0 | 2.6 |
| TW LeftUpperCut | 0.42 | 0 | 0 | 22.2 | 0.4 | 4.8 | 4.0 | 0 |
| TW RightKick | 0.33 | 0 | 0 | 36.5 | 1.5 | 3.0 | 5.4 | 0 |
| TW LeftStab | 0.33 | 0 | 0 | 15.7 | 1.5 | 3.0 | 3.4 | 0 |
| TW HeavyPunch | 0.50 | 0 | 0 | 22.5 | 0.7 | 2.0 | 2.0 | 4.6 |
| TW Barrage (loop) | 0.67 | 0 | 2.4 | 15.9 | 0 | 9.0 | 1.5 | 12.1 |
| sword hit1 | 0.82 | 0 | 0 | 42.5 | 2.1 | 3.7 | 7.5 | 4.1 |
| sword hit2 | 0.82 | 0 | 0 | 33.2 | 2.0 | 3.7 | 5.0 | 1.4 |
| sword hit3 | 0.73 | 0 | 0 | 29.8 | 1.9 | 2.7 | 3.5 | 3.1 |
| old swing 1 | 0.90 | 0 | 0 | 50.2 | 2.0 | 3.3 | 6.5 | 1.5 |
| sword equip | 0.98 | 0 | 0 | 35.0 | 2.2 | 2.0 | 4.4 | 1.0 |
| Land Anim | 0.47 | 0 | 0 | 7.2 | 0.4 | 2.1 | 2.3 | 5.5 |
| Walk2 (emm1gar) | 0.92 | 0 | 0 | 2.8 | 0 | 0 | 1.5 | 4.0 |
| Run | 0.53 | 0 | 0 | 1.0 | 0 | 0 | 1.4 | 3.3 |
| Idle (the one Lepy named the model) | 3.0 | 0 | 100 | 0 | 0 | 0 | 1.7 | 0 |
| TW idle (float) | 2.5 | 0 | 42 | 0 | 0 | 0 | 2.4 | 0 |
| sword idle (a static weapon overlay) | 4.15 | 100 | 100 | 0 | 0 | 0 | 5.5 | 0 |

Readings: no professional one-shot has a still frame. Their parts rest 16 to 50% of the time, never all at once for long, and the peak speed stays within about 2 to 10 times the median. The model idle is slow (still at the 12 deg/s action threshold) but never frozen. A weapon idle that is a static overlay relies on a lower layer to breathe.

## Earlier Claude clips

Authored in `Clips.lua` with the legacy per-key eases (`cubic` departures, `back` arrivals, `sine` creep holds, keys shared across joints).

| Clip | Length | frozen% | still% | longest still | rest% | contrast |
| --- | --- | --- | --- | --- | --- | --- |
| DioHeavy | 0.60 | 0 | 0 | 0 | 39.6 | 4.9 |
| WorldAppear | 1.00 | 0 | 0 | 0 | 65.6 | 9.1 |
| DioKnifeThrow | 1.05 | 0 | 0 | 0 | 65.9 | 10.3 |
| DioSummon | 1.20 | 0 | 0 | 0 | 66.7 | 20.8 |
| DioRollerOff | 1.20 | 0 | 0 | 0 | 56.4 | 12.1 |
| DioRollerUp | 3.60 | 0 | 29.5 | 0.40 | 81.1 | 39.4 |
| WorldTimeStop | 3.90 | 2.6 | 42.1 | 1.33 | 81.3 | 52.5 |
| DioTimeStop | 3.90 | 1.3 | 60.9 | 0.98 | 89.8 | 104.5 |

A short strike (DioHeavy) sits near the sword kit. Every move of a second or more spends 56 to 90% of its time with each part parked, and the long moves have still runs of up to 1.3 s: the "still frames" Lepy saw. Rounding-free `Poser.check` on the same clips also found 3 to 12 one-frame jolts each (a part leaving a full stop at nearly half its peak speed).

A first version of the analyzer counted every speed dip on the rounded decodes and reported 10 to 16 stops per second for these clips. That number was mostly rounding noise; the 4 frame window above replaced it. Keep that in mind before trusting a metric on rounded data.

## What the engine alone changes

The same keys with their eases removed, played as `curve = "spline"` (V1), plus `lag` (V2), plus `springs` (V3), plus `life = 1.5` (V4):

| Clip | rest% legacy / V1 / V2 / V3 | contrast legacy / V1 / V2 / V3 |
| --- | --- | --- |
| DioHeavy | 39.6 / 32.9 / 39.2 / 35.4 | 4.9 / 3.8 / 2.4 / 2.1 |
| WorldAppear | 65.6 / 45.9 / 48.7 / 48.7 | 9.1 / 5.1 / 5.1 / 5.1 |
| DioKnifeThrow | 65.9 / 53.9 / 56.0 / 57.0 | 10.3 / 7.1 / 6.0 / 5.1 |
| DioSummon | 66.7 / 56.8 / 59.0 / 57.9 | 20.8 / 13.2 / 11.9 / 10.1 |
| DioTimeStop (still%) | 60.9 / 62.6 / 57.6 / 52.9 | 104.5 / 130.9 / 108 / 88.8 |

The spline removes about a quarter to a third of the parked time and roughly halves the contrast; lag and springs lower the contrast further. The remaining gap is authoring: holds that barely move and long slow returns. Life at 1.5 degrees does not change the action numbers (it is slower than 12 deg/s by design); it removes frozen frames. So the engine is necessary and not sufficient: the principles.md holds and recoveries do the rest.

## The example clips

`scripts/ExampleClips.lua`, authored on the method from scratch:

| Clip | frozen% | still% | rest% | stops/s | unison/s | contrast | spread | feet |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Cross (0.72 s) | 0 | 0 | 38.1 | 2.1 | 4.2 | 6.0 | 0.7 | corners 0.00, slide 0.00, hip gap 0.00 |
| Guard (3.2 s loop) | 0 | 100 | 0 | 0 | 0 | 1.2 | 0 | corners 0.00, slide 0.00, hip gap 0.00 |

The Cross took five measured rounds. The first draft slid its feet 0.84 and 0.94 studs and sank them 0.26 because the torso turned 60 degrees over rigid legs; the post pass fixed the slide, the waist offset kept the hips over the stance, and a search over turn, drop and stance width found the 34 degree contact turn with a 0.36 drop that keeps every hip closed. Then the numbers showed the face 40 degrees off the target at the contact (a lagged head on a follow spring: now it counters the torso on its frames and stays within 3 degrees), the torso 7 degrees short of its contact key (a lead spring: now its overshoot is keyed), and the lead hand at waist height 1.9 studs out to the side (the lagged lead arm carried by the turn and an Euler path around the outside: now no lag, a crossed breakdown and a chin cover 0.5 stud from the chin). Final checks by forward kinematics: the fist at the contact is 2.95 studs ahead of the root and 0.79 right of centre, the face stays within 5 degrees of the target from 0.12 to 0.5 s, the lead hand never goes wider than 1.0 stud (its guard line is 0.76).

## Targets

For a one-shot action of 0.3 to 1.5 s:

| Check | Target | Pro range |
| --- | --- | --- |
| frozen% | 0 | 0 |
| still% / longest | 5 or less / 0.1 s or less (a `Rig:hold` hitstop excepted) | 0 |
| rest% | 45 or less (50 for slow heavy moves) | 16 to 50 |
| contrast | 2 to 10 | 2 to 10.6 |
| stops/s | 3 or less | 0.4 to 2.7 |
| unison/s | 5 or less | 0 to 4.8 |
| spread | information only (three pro strikes peak every part on one frame) | 0 to 5.7 |
| planted feet | lowest corner within 0.03, slide 0.05 or less, hip gap 0.12 or less | not measured |

For a loop or a held pose: frozen 0%. Walks and runs sit at rest under 8% and contrast under 2.

## How to measure

In Edit mode with `serve.js` serving the scripts folder, run `scripts/LoadTest.lua`, then:

```lua
local P = require(game.ServerStorage.PoserTest.Modules.Poser)
print(P.check(clip).text)
-- the foot check and strips: run scripts/EditStrip.lua once, then
print(_G.feet(clip))
```

For a decoded professional clip or a baked sequence: `node scripts/motion_check.js clip.txt`. `Poser.dump(clip, 60, name)` writes a Poser clip in the same format so both can be compared in one table.
