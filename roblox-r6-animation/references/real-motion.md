# Start from real motion, stylize it, and see it without Studio

Claude authors motion as numbers and cannot watch playback (project-style.md, 2026-09-22). This pipeline answers that: take the motion from professional motion capture, put it on R6, push it toward the keyed style on purpose, and read every frame as images, all in a session with Python and no Studio. Studio then only needs the final checks.

Tools (Python 3 with `pip install numpy pillow`, plus `imageio-ffmpeg` for videos):

| Script | Does |
| --- | --- |
| `scripts/bvh_to_r6.py` | Motion capture (BVH, or CMU `.amc` with its `.asf`) to R6: decode text for the checks and a Poser clip (`curve = "spline"`, reduced keys) as Lua. |
| `scripts/r6_render.py` | Renders decode text (from the retarget, `Poser.dump` or `ReadClips.lua`) as an R6 box figure: contact sheets from any view, onion skins, a one-dot-per-frame path of a hand or foot, an MP4. |
| `scripts/beats.py` | Measures each hand, foot and the head: moves, holds, frames to the fastest point, frames to the stop, peak speed, drift in holds. |
| `scripts/mocap_study.py` | Measures strikes, jumps and walk styles on the capture itself (mocap-timing.md holds the results). |
| `scripts/stylize.py` | Pushes dense motion toward the keyed style: exaggeration, the cartoon animation filter, a speed time warp, slow in and slow out at the extremes. |
| `scripts/poser_offline.py` | Runs a Poser clip module with the real `Poser.lua` on the Luau command line tool: `Poser.check` for every clip and its `Poser.dump` decode text (pipeline.md, "Source transfer and review tools"). |
| `scripts/feet_check.py` | The `_G.feet` numbers on decode text: lowest sole corner, slide while planted, hip gap, toe twist against the torso. |

## 1. Get the motion

| Source | Licence | What is useful | How to get it |
| --- | --- | --- | --- |
| CMU Graphics Lab Motion Capture Database | Free to use, may be included in products, may not be resold as data | Boxing, kicks, a jump kick, jumps, flips, falls (120 fps ASF/AMC) | `http://mocap.cs.cmu.edu/subjects/<n>/<n>_<take>.amc` and `<n>.asf` |
| Bandai Namco Research Motion Dataset | CC BY-NC 4.0 (no commercial use) | Punch, kick, slash, walk, run, dash, 15 styles by professional actors | `git clone https://github.com/BandaiNamcoResearchInc/Bandai-Namco-Research-Motiondataset` |
| Ubisoft La Forge LaFAN1 | CC BY-NC-ND 4.0 (no commercial use, no derivatives) | Fights, jumps, falls and get ups, pushes, sprints | `https://media.githubusercontent.com/media/ubisoft/ubisoft-laforge-animation-dataset/master/lafan1/lafan1.zip` |

For a commercial game use CMU clips, or another source whose licence allows it, as the base of a shipped clip; use the non-commercial sets only to study and measure. Do not copy a dataset into the repository.

Takes found and checked on 2026-09-26 (seconds are the peak of the move in the take):

| Move | Take | Time | Cut used |
| --- | --- | --- | --- |
| Jab (left straight) | CMU 14_01 | 44.47 | peak - 0.45 to peak + 0.4 |
| Cross (right straight) | CMU 14_03 | 36.43 | same |
| Lead hook | CMU 14_02 | 16.57 | same |
| Rear hook | CMU 14_03 | 17.20 | same |
| Uppercut (right) | CMU 13_17 | 1.98 | same |
| Front kick | CMU 74_03 | about 1.7 | 1.1 to 2.6 |
| Jump kick | CMU 75_16 | about 2.0 | 1.3 to 2.85 |
| Forward jump | CMU 13_11 | about 1.8 | 0.9 to 2.9 |

Boxing takes are long rounds; the boxers weave and turn, so a cut starts and ends in their guard, not in the project's guard. Blend or rekey the ends.

## 2. Put it on R6

```sh
python3 scripts/bvh_to_r6.py 14_01.amc out --name Jab --from 44.02 --to 44.87
```

How each R6 part is made (the rig math is in `r6_render.py`, the same C0 and C1 offsets as the stock R6 rig):

- **Torso**: up from the hip centre to the neck; facing from the shoulder line (65%) and the hip line (35%), `--blend`. R6 has no waist, so a hip-shoulder twist becomes one turn of the whole torso.
- **Arms and legs**: the straight line from the shoulder to the wrist and from the hip to the ankle. The roll comes from the elbow (it points back) and from the toes (they point forward). A bent elbow becomes a slide of the arm up into the shoulder (`--arm-piston 0.75`, at most 0.6 studs, the stand fists' range); a bent knee slides the leg up into the torso (at most 1.2), as SKILL.md allows.
- **Head**: its turn relative to the first frame, laid on the torso's first frame. Start a cut on a neutral head.
- **Root**: travel goes into the Torso's `p`, so a step or a lunge moves the body.
- The first frame is turned to face -Z; the floor is the lowest toe; the scale puts the standing hips at 2 studs.

Limits to fix by hand: R6 has no elbow, so the bend itself never shows; the slide carries the reach instead (measured on the CMU jab: the R6 fist peaks at 11.7 studs/s against 13.0 on the real wrist). When the shoulders twist against planted feet, R6 legs swing with the torso: plant them with `Feet.post` in Studio.

## 3. Look at it

```sh
python3 scripts/r6_render.py out/Jab.txt sheets --view side,front34,rear34 --every 2 --trail "Left Arm"
python3 scripts/r6_render.py out/Jab.txt sheets --view rear34 --video
```

Views: `side`, `front`, `rear`, `rear34` (the player's camera), `front34`, `top`, `low`, or `--yaw` and `--pitch`. `--follow` keeps a travelling clip in frame. `--onion 4` ghosts the frames before each cell. The trail draws one dot per frame for the tip of a part: uneven gaps are the spacing, the dotted line is the arc. The head and torso fronts are lighter so the facing reads.

## 4. Stylize

```sh
python3 scripts/stylize.py out/Jab.txt styled --gain 1.25 --cartoon 8 --snap 0.6 --siso 0.6
```

| Option | Method | Effect |
| --- | --- | --- |
| `--gain` | Scales each joint's rotation away from its 0.75 s moving average (rotation vectors, so no Euler flips near 90 degrees of lift) | Pushes every pose further, keeps the base. |
| `--cartoon` | The cartoon animation filter (Wang et al. 2006): the curve minus a Gaussian-smoothed copy of its second derivative | Adds anticipation before and overshoot after each change. This implementation uses a normalised Gaussian with a width of 1/ω, where ω is the dominant frequency of the joint's velocity in a 32 frame window (1.5 to 12 frames); the paper's own normalisation is not stated, so strength values are not comparable to its 3. |
| `--snap` | Plays each frame at a rate of (body speed / median) ^ snap, clamped 0.5 to 2.5, same total length | Fast parts faster, slow parts slower: snap and hold. |
| `--siso` | Slow in and slow out at the extremes (White, Loken and van de Panne 2006): finds the body's speed minima and warps time so playback slows to zero at each | Holds at the extremes, faster in-betweens. |

Measured on a jab from the Bandai punch take (`dataset-1_punch_normal_001`, 0.6 to 1.6 s; left arm in torso space, `beats.py --local`; motion checks from `motion_check.js`):

| | Move | To fastest | To stop | Peak | Hold | rest% | contrast |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Real (Bandai jab) | 18.5 frames | 7.5 | 10 | 6.9 studs/s | none | 11 | 2.7 |
| Stylized (the command above) | 12 | 6.5 | 4.5 | 12.1 | 6 frames, 0.2 drift | 36 | 6.2 |
| Pro stand strikes (TW, for comparison) | 5 to 15 | 1.5 to 5 | 2 to 9 | 5.4 to 27.4 | 0 to 7 | 16 to 40 | 2 to 10.6 |

Eight CMU cuts stylized with those values (jab, cross, both hooks, uppercut, front kick, jump kick, forward jump): frozen and still 0, stops 2.2/s or fewer, unison 2.4/s or fewer, contrast 2.7 to 8.9. Rest was 14 to 42% on six of them; the cross reached 45.5% (just over the 45% target) and the jump kick 48.8% (within the 50% allowed for a slow heavy move). The styled clips were read as frames with the renderer; they have not been played in Studio.

## 5. Finish it as an animator

The stylized clip is a base, not the finished animation. Then, in this order:

1. Replace the start and end with the project's guard and chain poses.
2. Push the key poses for the camera (principles.md), compress the strike toward the keyed range (mocap-timing.md: keyed strikes are two to three times faster than real ones), keep a hold at the contact.
3. Add the smears on the fastest frames and the hitstop at the contact.
4. `Feet.post` for planted feet, then `Poser.check` and the foot check: offline with `poser_offline.py` and `feet_check.py`, or in Studio with `_G.feet`. Then a recorded take in Studio read frame by frame (reference-study.md).

The Lua clip has keys on the extremes plus enough in-betweens to stay within 1.5 degrees and 0.03 studs of the source (`--tol`); raise the tolerance for fewer keys to edit by hand.
