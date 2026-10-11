# Locomotion: walks, runs, turns, stops, jumps and idles

Researched numbers for locomotion and their R6 translation. The authoring recipes are in principles.md (Walk, Run, Locomotion controller, Jump and landing, Idle); this file gives the measurements behind them. Every finding was checked against its source (sources.md, "Locomotion research"). Film timings are at 24 fps; 60 fps conversions multiply by 2.5 and are marked "our conversion". Human-to-R6 scaling uses 5 studs for a 1.75 m body unless stated.

## Contents

- Frames per step
- Walk landmarks and mirrors
- Walk body motion
- Speeds, cadence and the walk-run boundary
- Runs
- Mood in a walk
- Starts, stops and turns
- Keeping feet planted across speeds and directions
- The Roblox jump
- Idles and breathing

## Frames per step

The frame count per step decides what a gait reads as. Williams' chart, per step at 24 fps (at 60 fps, our conversion):

| Frames per step | At 60 fps | Reads as |
| --- | --- | --- |
| 4 | 10 | a very fast run |
| 6 | 15 | a run or a very fast walk |
| 8 | 20 | a slow run or a cartoon walk |
| 12 | 30 | a brisk natural walk |
| 16 | 40 | a stroll |
| 20 | 50 | an elderly or tired walk |
| 24 | 60 | a slow step |
| 32 | 80 | a very slow walk |

A giant takes about one step per second. Choose the frames per step for the read you want, then set the clip speed to stride divided by step time. A planted R6 stance covers about 2.4 studs, so a slide-free cycle at WalkSpeed 16 needs a step every 9 frames: a very fast run. A walk read needs about 30 frames per step at 4 to 5 studs/s.

## Walk landmarks and mirrors

- **Williams' walk.** Contacts on frames 1, 13 and 25 with the body in the same place; the down pose 3 frames after a contact, the passing pose exactly halfway between contacts with the body up a bit, the push-off (up) 3 frames before the next contact. For a 30-frame step at 60 fps: contact 0, down 7 to 8, passing 15, up 22 to 23, next contact 30. Torso `py` is lowest at the down pose and highest at the up pose. Leave the keys `auto` and put `flat` only on the `py` extremes.
- **Mirror the halves.** Every pose has a mirror half a cycle later; halves that are not mirrored make the cycle jerk or limp. Author one step, then build the second at exactly half the cycle by swapping the left and right joints and negating side, twist and `px` on the torso and the head (check the limbs' sign convention). Break the symmetry only on purpose (a limp, a carried weapon). At passing, in an in-place cycle, the planted foot sits halfway between where it landed and where it will toe off, roughly under the hip; in the world a planted foot does not move.
- **Double support.** Each foot is on the ground about 60 to 62% of a walk cycle (59% at 1.5 m/s), so both feet are down twice per cycle for about 10% each. For a 1.08 s walk (65 frames), plant each foot for about 39 frames with two double-support windows of about 6 frames; lift the trailing foot only after the leading foot is planted. Stance under 50% means a flight phase, which reads as a run.

## Walk body motion

- **The COM path.** About 5 cm of rise and fall, twice per cycle, lowest in double support and highest at midstance and midswing; about 6 cm of side sway, once per cycle, toward the stance leg. On R6: torso `py` range about 0.14 studs, lowest on the contact frames; `px` sway about 0.17 studs in total, at half the bob's frequency. The decoded community walks used 0.08 to 0.11 studs of `py`.
- **A steady upper trunk.** In walking the upper trunk moves little in world space: about 6.9 degrees of rotation range, 3.3 of side tilt and 4.0 of forward-back tilt; against the pelvis it moves far more (13.7 and 13.0), because the pelvis turns and tilts under it. A walk torso on R6: twist about +-3.5 degrees, roll about +-1.7, lift oscillating about +-2 twice per cycle. The R6 torso also carries the hips, so put the pelvis's extra motion into the legs (a small forward `pz` on each leg at its forward extreme and a backward `pz` at its back extreme, and a degree or two of torso roll toward the swing side at passing while that leg lifts) rather than into a bigger torso twist; a big torso twist reads as a plod. Keep the torso twist and the arm swing in counter-phase to the legs: the arms cancel the legs' turning about the vertical axis.

## Speeds, cadence and the walk-run boundary

- **Walk speeds.** Normal walking 0.95 to 1.7 m/s (mean 1.27), fast walking 1.7 to 2.4 m/s (mean 1.96): about 4.5 and 7.0 studs/s at 28 cm per stud, 3.6 and 5.6 scaled by body height.
- **The walk-run switch.** Humans switch from walking to running at a Froude number `v^2 / (g L)` of about 0.5. With an R6 leg of 2 studs and Earth gravity (35 studs/s^2, the gravity viewers judge gait against), that is about 5.9 studs/s. Build R6 walks for about 3 to 5.5 studs/s and runs for over 6. At the default WalkSpeed 16 a body reads as running fast, so a walk clip there must slide or look sped up.
- **The default script's scaling.** The default animation script scales movement animations by the current speed relative to 16 studs/s. The decoded default R6 walk (0.67 s at speed 16) covers about 10.7 studs per cycle, more than twice what a planted 2-stud leg covers, so it slides. A custom cycle authored for speed `v_ref` must play at `AdjustSpeed(speed / v_ref)`: store `v_ref` (stride per cycle over cycle length) with each locomotion clip and replace the default scaling when you ship custom cycles.

## Runs

- **Keys.** Contact (front leg near straight), down (lowest, most squashed, the stance leg bent), push (leaving the ground), peak (highest, fully airborne, the knees held from the previous pose). The contact leg buckles to the low point on the pose right after the full stride, not on it: at 20 frames per step, put the torso `py` minimum and the stance leg's slide up into the torso about 5 frames after the contact key, and keep the long straight-leg silhouette on the contact frame. Across the peak, hold the leg angles nearly still for 2 to 3 frames while the torso rides its arc. Keep the run's foot targets narrow, near the hips.
- **Cadence.** Distance runners step at 2.75 to 3.25 Hz and speed up mainly by lengthening the step, not stepping faster, until a sprint finish raises the cadence. A run step at 60 fps is 18 to 22 frames (a 0.62 to 0.73 s cycle); a sprint about 17. Build jog, run and sprint near the same cadence and lengthen the stride and the flight; raise cadence only once the R6 stride limit is reached.
- **Where the foot lands.** A running step is the foot ahead of the COM at contact, the foot's travel in stance, the foot behind the COM at toe-off, and the flight. Flight distance separates fast runners from slow ones and is very small in slow running. Landing ahead of the body and braking is normal. Put the contact foot's target a little ahead of the torso centre; make a faster run by adding flight frames and stride, not only bigger leg angles. At midswing the knee folds to 55 to 60 degrees: on R6 a lift of the swing leg into the hip (0.7 to 0.95 studs).
- **Lean.** A realistic top-speed lean is about 14 degrees from vertical; the 19 to 28 degrees of good R6 runs is style. In a sprint start the first 2 to 4 steps land behind the centre of gravity, low and leaning, and the body rises over those steps before the feet land ahead of it.

## Mood in a walk

Emotion changes a walk's speed, posture and size. Mean speeds: anger 1.82 m/s, happiness 1.31, fear 0.83, sadness 0.68. Sad gait drops the head strongly (about 19 degrees against neutral) and moves smaller than its speed predicts; angry and happy walkers swing their arms more than their speed predicts; angry and fearful walkers bend the elbows more, and fear also pulls the upper arms back and bends the knees. Head inclination is the main cue for sadness, and posture barely depends on speed. On R6: sad, the head down about 19 degrees all cycle, smaller swings, about half the happy speed; angry, about 1.4x the happy speed, a bigger arm swing, the arms carried forward with a short lift up the limb for bent elbows; fear, the arms back and in, the torso lowered with the legs sliding into it, short steps.

## Starts, stops and turns

- **Stopping from a run** took adults about 5 steps (5.13) over 0.72 s and 3.1 leg lengths; the steps were 77% of leg length and the COM stayed below standing height (0.86 of it) and behind the feet. On R6 (our scaling): about 5 short steps of about 1.5 studs over about 43 frames, the torso dropped about 0.35 and leaning back so the COM stays behind the planted feet until the final plant. A one-step stop is the hard-stop extreme; the default is several short braking steps.
- **A sharp turn** pivots the body around its COM while the head stays nearly still. For a 90 degree turn at a run, one plant goes ahead of the COM to brake and redirect, the next behind it to push into the new heading. Counter the torso yaw with the head on the torso's frames (the head leads), plant 1 ahead of the torso with a lean back and a dip, plant 2 behind it with a lean into the new direction, and allow a heel pivot (a time-varying foot yaw) instead of locking both feet; feet planted too rigidly create a pivot at the ground.
- **A responsive 180 degree run turn** can snap the character's facing in one frame and cover it with a turn clip that starts facing the old way and ends in the run at run speed. Author a left-foot and a right-foot version, pick by the run's phase, and play with no fade (a blended turn jerks the root through a twist).
- **Turning in place.** Keep the feet planted while idle by countering the root's turn with an equal and opposite root-joint yaw offset; when the offset or the waiting time passes a threshold, play a turn-step clip that steps the feet and unwinds the offset. Hold the offset through a start and blend it to 0 entering the run. (custom-rigs.md has a clip-free version.)

## Keeping feet planted across speeds and directions

- **Directions are slower than forward.** One motion capture set ran just over 4 m/s forward, just under 3 sideways and about 2 backward; walked about 1.75, 1.5 and 1.25. Build the strafe run for about 70 to 75% of the forward run speed and the backpedal for about 50% (walk: side about 85%, back about 70%). If the game moves at one speed in every direction, give the strafe a longer stride or cap the speed. A little foot sliding often looks much less wrong than breaking the pose badly: match the clip's speed and acceleration first, and never wreck a pose to pin a foot.
- **Stride warping.** Scaling the planted-foot travel by `gameSpeed / clipSpeed` (with the pelvis adjusted on a spring) fits one cycle to several speeds; turning the lower body toward the movement direction with a counter-rotation up the body gives a full 180 degrees of lower-body direction from one forward cycle. On R6: scale each planted foot's travel (and the swing lift) by the speed ratio inside the 2.4-stud stance limit; twist the legs up to about 45 degrees toward the travel, turn the torso part way and counter with the head; past 45 degrees switch to a strafe or backpedal clip. When a cycle plays slower or shorter than authored, scale the swing leg's lift by the same factor as the stride.
- **Phase sync.** Blended cycles stay in phase when every walk, run, start, stop and strafe clip carries markers at each foot-down and starts on the same foot; the follower takes its time position each frame from the leader's phase between markers. Keep blended cycle lengths close (for example a 0.84 s walk with a 0.7 s run), switch clips only while a foot is on the ground, and never mid-air.
- **Distance matching.** Drive a start, stop or pivot by distance instead of time: store the root distance left at each frame of a stop clip and, at runtime, set the track's time position (speed 0) to the frame whose distance left equals the distance to rest; land the same way on height above the floor. Clamp the implied rate and let the stride scale absorb the rest.
- **Clean plants.** Put a new plant at the foot's mean position over its first few planted frames, not at its first contact point, and fade the solver's corrections (torso drop, leg slide) in and out with smoothstep over 3 to 6 frames on each side of a plant, so nothing pops when a plant switches.

## The Roblox jump

The default jump (JumpHeight 7.2 studs under 196.2 studs/s^2) leaves the ground on the input frame with a 53.2 studs/s takeoff, reaches the apex at frame 16 and lands after about 33 frames on flat ground; the body is above 75% of its apex height for the middle half of the airtime (body-mechanics.md). The takeoff clip has no room for a pre-crouch: a 2 to 4 frame stretch at the start, the airborne peak pose across about frames 8 to 24, the legs reaching down by about frame 26. Drive the landing from `Humanoid.StateChanged` (Landed), not from a timer.

- **Landing weight.** Push the landing lower than the takeoff crouch; as the hips start to rise, keep the head and arms going down about 4 to 5 frames at 60 fps (lag or key offsets); bunch the spacing at the peak; delay one leg 3 to 5 frames in the air and offset the arms so the airborne pose does not twin; let the legs settle flat within about 5 frames of contact; end in a moving hold of about 25 frames that keeps drifting in the direction of the move.
- **Scale the landing by impact.** One platformer scales its landing squash by `min(fallSpeed / 240, 1)` and recovers in about 0.34 s from a full squash. R6 cannot scale: make the landing compression a torso drop of `maxDrop * min(fallSpeed / vRef, 1)` (as the landing track's weight, or by choosing a light or heavy landing clip) and recover over 0.2 to 0.35 s. Apex hang (halved gravity near the apex while jump is held) belongs to the controller, not the clip.

## Idles and breathing

- **Breath rate.** A resting adult breathes 12 to 20 times a minute: 3 to 5 s per breath. A calm idle breath takes 3 to 5 s (180 to 300 frames); 2.5 s reads slightly winded. Use 2 to 2.5 s for an idle after a run and ramp back to 3 to 5 s over several breaths.
- **Fidgets.** Space fidgets and head turns so each happens once every few breaths (about every 10 to 20 s), bring a look back to rest, and close the loop on the first pose so the spline wraps its tangents.
- **Weight from equipment.** A load on one side pulls the combined COM toward it, so the body counter-leans away from a one-sided weapon (or back from a weight held in front): a small roll or offset away from the load, the torso a little lower, the stance a little wider.
