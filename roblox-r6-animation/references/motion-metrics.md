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
| range | Per joint, the largest turn between any two frames of the clip, in degrees | How far a part swings. Force needs range of motion. |
| sweep | Per joint, the total turn along the clip, in degrees | How much a part travels, reversals included. |

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

## Range of motion in the professional clips

`node scripts/motion_check.js references/decodes/*.txt --json` (added 2026-09-25):

| Clip | Length | Torso range / sweep | Right Arm range / sweep | Left Arm range / sweep | Head range |
| --- | --- | --- | --- | --- | --- |
| TW RightPunch | 0.42 | 120 / 130 | 13 / 21 | 29 / 36 | 118 |
| TW LeftPunch | 0.42 | 90 / 110 | 78 / 116 | 102 / 109 | 88 |
| TW LeftUpperCut | 0.42 | 106 / 141 | 68 / 134 | 75 / 79 | 75 |
| TW HeavyPunch | 0.50 | 77 / 117 | 104 / 194 | 95 / 144 | 48 |
| TW RightKick | 0.33 | 82 / 85 | 8 / 14 | 50 / 56 | 53 |
| TW LeftStab | 0.33 | 83 / 90 | 12 / 12 | 44 / 45 | 40 |
| TW Barrage (loop) | 0.67 | 110 / 837 | 83 / 168 | 67 / 284 | 110 |
| TW idle | 2.5 | 6 / 14 | 14 / 28 | 8 / 17 | 7 |

Readings: every pro strike turns the torso 77 to 120 degrees in a third to a half of a second. The striking arm of a piston punch barely turns (8 to 13 degrees) because the torso whip does the reach; a hook or an uppercut swings the arm 68 to 104 degrees. The Stand floats, so a grounded body with planted feet turns less (the example cross needed a torso drop for a 56 degree turn, SKILL.md "Rigid legs"); compare with a pro clip of the same kind and support, and report the difference.

## Spacing shape of the professional clips

`python3 scripts/beats.py references/decodes/TW*.txt references/decodes/Barrage.txt --local` (added 2026-09-26): each arm's tip in torso space, split into moves (above a fifth of its peak speed and 1.5 studs/s) and holds. "To fastest" and "to stop" are the frames from the start of a move to its fastest frame and from there to its end; the medians are shown.

| Clip | Arm | Moves | Move frames | To fastest | To stop | Peak (studs/s) | Hold frames |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Barrage | Right Arm | 5 | 3 | 1 | 1 | 8.8 | 3 |
| Barrage | Left Arm | 8 | 4 | 2 | 1 | 16.1 | 0 |
| TWHeavyPunch | Right Arm | 2 | 7.5 | 3 | 3.5 | 27.4 | 6 |
| TWHeavyPunch | Left Arm | 2 | 5 | 1.5 | 2.5 | 22.7 | 7 |
| TWLeftPunch | Right Arm | 2 | 8.5 | 4.5 | 3 | 18.1 | 0 |
| TWLeftPunch | Left Arm | 2 | 7.5 | 3.5 | 3 | 12.1 | 0 |
| TWLeftStab | Right Arm | 1 | 15 | 5 | 9 | 9.5 | 0 |
| TWLeftStab | Left Arm | 1 | 10 | 5 | 4 | 24.6 | 0 |
| TWLeftUpperCut | Right Arm | 2 | 9 | 3.5 | 4.5 | 16.7 | 0 |
| TWLeftUpperCut | Left Arm | 2 | 6.5 | 2.5 | 3 | 19.8 | 0 |
| TWRightKick | Right Arm | 2 | 5.5 | 2.5 | 2 | 5.5 | 2 |
| TWRightKick | Left Arm | 1 | 7 | 3 | 3 | 16.0 | 0 |
| TWRightPunch | Right Arm | 2 | 7.5 | 2 | 4.5 | 5.7 | 2 |
| TWRightPunch | Left Arm | 1 | 10 | 3 | 6 | 8.1 | 0 |

Readings: a pro strike moves in 5 to 10 frames (the stab's slow arm 15), reaches its fastest frame after 1.5 to 5 and stops 2 to 9 frames later; the barrage beats are 3 to 4 frames. Real motion capture moves 2 to 3 times slower (real-motion.md, mocap-timing.md). Compare a new clip's `beats.py` table with this one next to the motion checks.

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
| Cross (0.72 s) | 0 | 0 | 40.0 | 2.08 | 4.17 | 6.6 | 0.5 | corners -0.01 to 0.01, slide 0.01, hip gap 0.00, toe twist 30 right, 51 left |
| Guard (3.2 s loop) | 0 | 100 | 0 | 0 | 0 | 1.4 | 0 | corners -0.01 to 0.01, slide 0.01, hip gap 0.00, toe twist 5 right, 31 left |
| HeavyLand (1.4 s, `ExampleMoves.lua`) | 0 | 3.5 | 48.4 | 2.38 | 3.57 | 6.9 | 2.3 | corners -0.01 to 0.01, slide 0.01, hip gap 0.00, toe twist 38 right, 25 left |
| HeroLand (1.6 s, `ExampleMoves.lua`) | 0 | 0 | 77.7 | 1.35 | 1.25 | 43.2 | 1.5 | planted corners -0.01 to 0.01, slide 0.02, hip gap 0.00, fist -0.03 to 0.07 over the floor in the hold; the kneeling leg's twist reads 74 and does not apply |
| LeapStrike (1.3 s, `ExampleMoves.lua`) | 0 | 0 | 50.8 | 2.18 | 3.08 | 5.4 | 13.5 | planted corners -0.01 to 0.01, slide 0.03, hip gap 0.00; `faults.py --strike 0.7` finds nothing |
| SwordDraw (0.92 s, `ExampleSword.lua`) | 0 | 1.8 | 43.4 | 2.17 | 3.26 | 8.8 | 4.1 | corners -0.01 to 0.01, slide 0.01, hip gap 0.00; `faults.py --strike 0.15` finds nothing; lowest blade tip 0.12 |
| M1Jab (0.42 s, `ExampleMoves.lua`) | 0 | 0 | 21.6 | 0.40 | 4.76 | 3.8 | 1.6 | slide 0.01, hip gap 0.00, toe twist 31 right, 56 left |
| M1Cross (0.42 s) | 0 | 0 | 26.5 | 1.98 | 4.76 | 2.7 | 1.5 | slide 0.01, hip gap 0.00, toe twist 42 right, 40 left |
| M1Hook (0.45 s) | 0 | 0 | 32.7 | 1.85 | 4.44 | 5.4 | 2.2 | slide 0.01, hip gap 0.00, toe twist 33 right, 59 left |
| M1Upper (0.67 s) | 0 | 0 | 35.3 | 2.49 | 2.98 | 7.1 | 0.6 | slide 0.01, hip gap 0.00, toe twist 44 right, 47 left |
| HitFlinch (0.62 s, `ExampleMoves.lua`) | 0 | 2.6 | 30.8 | 1.34 | 4.84 | 3.5 | 7.0 | planted corners -0.01 to 0.01 (the catch step lifts 0.23), slide 0.02, hip gap 0.00; `faults.py` finds nothing |
| Throw (1.45 s, `ExampleMoves.lua`) | 0 | 0 | 49.2 | 2.07 | 3.45 | 8.0 | 0.9 | planted corners -0.01 to 0.01 (the stepping foot lifts 0.29), slide 0.01, hip gap 0.04, toe twist 37 right, 42 left |
| CalmIdle (4 s loop, `ExampleFrieren.lua`) | 0 | 100 | 0 | 0 | 0 | 1.4 | 0 | slide 0.01, hip gap 0.00, toe twist 12 right, 4 left |
| Zoltraak (2.8 s, `ExampleFrieren.lua`, calm register) | 0 | 43.4 | 49.7 | 1.38 | 1.03 | 10.7 | 20.4 | slide 0.01, hip gap 0.01, toe twist 22 right, 8 left; range torso 13, casting arm 107, free arm 10 |
| BarrierRaise (0.7 s, calm) | 0 | 44.2 | 51.2 | 1.43 | 0 | 7.8 | 0 | slide 0.01, hip gap 0.00 |
| BarrierHold (3.2 s loop) | 0 | 100 | 0 | 0 | 0 | 1.4 | 0 | slide 0.01, hip gap 0.00 |
| BarrierHit (0.45 s, calm) | 0 | 21.4 | 37.5 | 1.11 | 0 | 5.1 | 0.5 | slide 0.01, hip gap 0.00; `faults.py` finds nothing |
| Flowers (3.6 s, calm) | 0 | 15.2 | 49.5 | 0.99 | 0.54 | 7.7 | 9.5 | slide 0.01, hip gap 0.01; cupped hands 0.83 to 0.85 apart through the gather |
| ZoltraakVolley (1.9 s, `ExampleFrieren.lua`) | 0 | 7.5 | 60.0 | 1.31 | 1.01 | 12.3 | 1.2 | slide 0.01, hip gap 0.00 |
| CalmWalk (1.1 s loop, travel 2.4) | 0 | 0 | 4.1 | 0 | 0 | 1.2 | 16.5 | slide 0.04 and 0.05 with `--travel 2.4`, hip gap 0.00 |
| LeanDodge (0.8 s) | 0 | 16.3 | 37.4 | 1.46 | 2.50 | 5.5 | 0.8 | slide 0.01, hip gap 0.00; `faults.py` finds nothing |

Measured 2026-09-26 offline (`poser_offline.py`, `feet_check.py` on the decode, which rounds to 0.01 stud). The calm-register rows (study-frieren.md) are not held to the one-shot fight targets for still, rest and contrast: their holds follow the reference's hold share and their power is in the effect. The first numbers (Studio, rest 38.1, contrast 6.0, spread 0.7, Guard contrast 1.2, corners 0.00) came before the `Feet.lua` toe-turn fix: the turn axis pointed down the leg and turned every toe the wrong way (toe twist 127 and 143 degrees on the Cross). The fixed feet change the leg motion, so rest, contrast and spread moved.

The Cross took five measured rounds. The first draft slid its feet 0.84 and 0.94 studs and sank them 0.26 because the torso turned 60 degrees over rigid legs; the post pass fixed the slide, the waist offset kept the hips over the stance, and a search over turn, drop and stance width found the 34 degree contact turn with a 0.36 drop that keeps every hip closed. Then the numbers showed the face 40 degrees off the target at the contact (a lagged head on a follow spring: now it counters the torso on its frames and stays within 3 degrees), the torso 7 degrees short of its contact key (a lead spring: now its overshoot is keyed), and the lead hand at waist height 1.9 studs out to the side (the lagged lead arm carried by the turn and an Euler path around the outside: now no lag, a crossed breakdown and a chin cover 0.5 stud from the chin). Final checks by forward kinematics: the fist at the contact is 2.95 studs ahead of the root and 0.79 right of centre, the face stays within 5 degrees of the target from 0.12 to 0.5 s, the lead hand never goes wider than 1.0 stud (its guard line is 0.76).

The Throw took five offline rounds (poser_offline.py, feet_check.py, r6_render.py sheets). Draft 1: rest 55%, the legs twisted 97 and 111 degrees against the torso, the front foot slid 0.31 and could not reach its step, and the body folded 45 degrees after the release and read as a crumple. Draft 2 capped the torso twist at 48, pivoted both feet on the ball and folded less: twist 37 and 40, slide 0.01. Draft 3 gave the push real travel, but it stayed under a tenth of the whip's speed and still counted as rest. Draft 4 pushed the load (the ball to the face, a lean back), swung the first wind-up arm out to the side so it clears the torso from the player's camera and cocked the arm up and back; its load rose too high and opened the left hip to 0.12, and a lower load closed it to 0.04. Draft 5 slowed the first wind-up, which had peaked the throwing arm's joint speed before the whip (spread 7.6), until every joint peaked on the whip. In world speed the whip was already 1.7 times the wind-up in draft 4 (4285 against 2461 degrees a second, torso turn included), so this round fixed the joint-space spread, not a hierarchy a viewer would see.

HeavyLand took five rounds. Draft 1 keyed the arms for an upright body; under the 40 degree lean they hung dead behind it, the front leg slid out of sight into the torso and the recovery did not move (rest 64%). Draft 2 keyed the arms forward by the lean and widened the stance; the back leg then lay nearly flat. Draft 3 eased the lean and brought the feet in, and the back leg still measured 52 to 58 degrees from vertical, traced to the slide along the leaned torso's up axis. Draft 4 moved the feet under the hips (back leg 17 to 46 in the crouch). Draft 5 pitched the torso forward through the skid, added the stop overshoot and the rebound, hung the arms wide at the end, turned the back toe in (twist 47 to 38) and let the braced arm press with each breath (rest 51.2 to 48.4).

HeroLand took four rounds. Draft 1 left the fist 0.4 to 0.5 above the floor (hips 0.55 up), kept the back foot 1.8 behind after the body stood, and held a dead pose (still 12.4%, contrast 63). Draft 2 lowered the hips to 0.42 with a 40 degree lean and stepped the back foot in during the rise; the fist touched but lifted to 0.21 on every breath. Draft 3 moved the breath into the height and a small roll with the lean held and gave the end a drifting stance (still 0). Draft 4 lifted the back foot as it swings out. Its rest is 77.7% because the 0.9 s hold is the reference's own; frozen and still are the checks that apply to a hold.

LeapStrike took four rounds, read with `faults.py` and sheets that follow the torso up. Draft 1: the legs hung limp on the rise, the torso rose above the legs' reach while the feet were still planted (hip gap 0.12), and at the landing the back leg lay 61 degrees from vertical and both feet slid 0.15. Draft 2 trailed the legs then tucked them, took the feet off a frame earlier and set the landing feet closer; the arms then swung 190 degrees in 5 frames (a 95 degree pop) and the contact frame opened the front hip 0.12. Draft 3 spread the swing over 12 frames and lowered the torso at the contact: nothing found. Draft 4 gave the hang and the end more drift (still 5.1 to 0). Its spread is 13.5 frames because the takeoff and the strike are separate peaks.

The example strikes' spacing sits inside the pro ranges of the table above (`beats.py --local`, the striking arm): the M1 hits, the throw and the cross move 3 to 8 frames, reach their fastest in 0.5 to 3.5 and stop in 1.5 to 3, and peak at 14 to 24 studs/s.

A two-frame whip sets each joint's peak so high that every drifting hold counts as rest (under a tenth of that peak), so the target snap-and-hold style lands near the 45% line (the throw at 49.2%). Report rest next to the beat chart (`beats.py`) instead of slowing the snap to pass the number.

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
| range / sweep | compare with a pro clip of the same kind; report the torso and the striking limb | torso 77 to 120 on the stand strikes |
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

Without Studio: `python3 scripts/poser_offline.py <clip module> out` prints `Poser.check` for every clip with the real Poser on the Luau command line tool and writes the decode text; `python3 scripts/feet_check.py out/<clip>.txt` gives the foot check (pipeline.md, "Source transfer and review tools").

For a decoded professional clip or a baked sequence: `node scripts/motion_check.js clip.txt`. `Poser.dump(clip, 60, name)` writes a Poser clip in the same format so both can be compared in one table.
