# Real human timing, measured from motion capture

Measured 2026-09-26 with `scripts/mocap_study.py` on professional motion capture, scaled to R6 (standing hip height = 2 studs, the R6 hip pivot line). Frames are at 60 fps. Use these as the real-motion baseline, then stylize on purpose: the studied pro keyed clips and anime references are faster and hold longer than real people.

Data (measured, not redistributed): the Bandai Namco Research Motion Dataset 1 (CC BY-NC 4.0, three professional actors, 15 styles), Ubisoft La Forge LaFAN1 (CC BY-NC-ND 4.0, fights, jumps), and the CMU Graphics Lab Motion Capture Database (boxing, kicks, jumps). Sources: sources.md.

## Strikes

A strike runs from the last low point of limb extension (shoulder to wrist, or hip to ankle, over the limb length) to the next peak above 0.85 of full reach with a gain of at least 0.2. Arms count only when the wrist ends at least 0.55 limb lengths in front of the chest; kicks only when the ankle rises above 0.9 studs. Wind-up: frames still retracting before the strike starts. Hold: frames within 0.03 of full reach. Return: full reach to the next low point. Lead: frames between the peak turn speed of the hips (or the shoulder line) and the peak speed of the fist or foot.

Numbers are 25th percentile / median / 75th percentile.

| | Punches, all (376) | Boxers only, CMU (167) | Kicks (47) |
| --- | --- | --- | --- |
| Strike (frames) | 9 / 11 / 17 | 8 / 9 / 11 | 11 / 12 / 14 |
| Wind-up (frames) | 3 / 4 / 6 | 3 / 3 / 5 | 2 / 2 / 3 |
| Hold at full reach (frames) | 3 / 4 / 6 | 3 / 3 / 4 | 4 / 5 / 7 |
| Return (frames) | 8 / 16 / 27 | 15 / 24 / 30 | 8 / 13 / 17 |
| Peak speed of the fist or foot (studs/s) | 8.1 / 10.4 / 13.1 | 9.5 / 11.2 / 13.2 | 13.9 / 17.2 / 19.4 |
| Speed peaks before full reach (frames) | 3 / 4 / 6 | 4 / 4 / 5 | 5 / 6 / 8 |
| Hips lead the fist or foot (frames) | 1 / 6 / 13 | 3 / 6 / 10 | 1 / 8 / 17 |
| Shoulders lead (frames) | -1 / 3 / 8 | 1 / 3 / 5 | 1 / 17 / 24 |

Readings:

- **The kinetic chain is real and measurable.** The hips reach their fastest turn about 6 frames before the fist, the shoulders about 3 frames before. This is the overlap rule with numbers: the driver leads, the carried part trails by a few frames per link (principles.md, "Overlap").
- **Fast out, slow back.** Boxers strike in 9 frames and return in 24. The return is two to three times the strike.
- **Real limbs brake into full reach.** The fist is fastest 3 to 6 frames before full reach, then holds 3 to 6 frames at reach. A keyed "hang" at the contact has a real basis.
- **Keyed game strikes are two to three times faster than real ones.** The pro stand strikes go from the wind-up to the contact in 3 to 6 frames (attack-timing.md, principles.md); real boxers take 8 to 11. Use real timing for the order and the shape of a move, then compress the strike on purpose.
- **Kicks start in the upper body far earlier**: the shoulders reach their fastest turn about 17 frames before the foot's fastest point (the direction of that turn was not measured).

## Jumps

64 clean jumps from LaFAN1 `jumps1` (flight of 8 to 60 frames, hips rising at least 0.1 studs). Depths are in studs below standing hip height (2 studs).

| Phase | 25th / median / 75th |
| --- | --- |
| Descent into the crouch (frames) | 17 / 19 / 21 |
| Lowest point to takeoff (frames) | 14 / 15 / 23 |
| Crouch depth (studs) | 0.32 / 0.38 / 0.43 |
| Flight (frames) | 11 / 15 / 19 |
| Hips above standing at the top (studs) | 0.25 / 0.29 / 0.32 |
| Landing to the lowest point (frames) | 10 / 12 / 15 |
| Landing depth (studs) | 0.33 / 0.38 / 0.44 |
| Lowest point to standing (frames) | 8 / 10 / 14 |

Readings: a real person spends about 0.55 s getting into and out of the crouch before a small jump, and absorbs the landing as deep as the takeoff crouch. The studied Moon Animator golem hangs 0.3 s at the top of a hop (study-moon-practice2.md), longer than the whole median flight of a real small jump (15 frames, 0.25 s): the hang is a stylistic choice.

## Walk, run and dash styles

The first take of each style from the Bandai dataset. Speeds are real human speeds at R6 scale: a real walk is 2 to 4 studs/s while the default Roblox WalkSpeed is 16. Use the columns as the character's proportions (steps, bob, lean, sway, twist, arm swing), not its speed. Lean: minus leans forward. Twist: range of the shoulder line against the hip line. Arm swing: range of the arm's forward angle. Proud and sad walks did not give clean foot contacts, so their step counts are missing.

### Walk

| Style | Speed (studs/s) | Frames per step | Hip bob (studs) | Lean (deg) | Side sway (deg) | Twist (deg) | Arm swing (deg) | Head bob (studs) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| normal | 2.8 | 32 | 0.089 | 0.8 | 5.0 | 20.1 | 63.5 | 0.005 |
| active | 3.34 | 32.5 | 0.159 | -1.7 | 4.5 | 29.8 | 62.6 | 0.011 |
| angry | 4.26 | 24 | 0.139 | -11.8 | 7.7 | 38.5 | 122.9 | 0.03 |
| childish | 2.18 | 31 | 0.117 | -6.8 | 6.5 | 30.7 | 80.7 | 0.017 |
| chimpira (thug) | 2.97 | 28 | 0.138 | -3.4 | 12.1 | 24.5 | 85.1 | 0.04 |
| feminine | 2.04 | 40 | 0.057 | 2.4 | 6.2 | 24.6 | 27.0 | 0.01 |
| giant | 2.49 | 40 | 0.246 | -7.7 | 12.2 | 35.2 | 62.1 | 0.036 |
| happy | 2.94 | 31 | 0.226 | -3.5 | 6.1 | 30.6 | 104.0 | 0.008 |
| masculinity | 3.15 | 31 | 0.1 | 0.8 | 3.6 | 19.9 | 66.2 | 0.007 |
| musical | 2.92 | 33 | 0.12 | 1.6 | 7.1 | 34.6 | 263.3 | 0.018 |
| not-confident | 1.19 | 39 | 0.052 | -9.4 | 10.2 | 5.7 | 4.9 | 0.037 |
| old | 1.56 | 35 | 0.1 | -16.5 | 10.3 | 11.2 | 33.5 | 0.099 |
| proud | 2.08 | - | 0.049 | 3.7 | 7.9 | 24.6 | 75.9 | 0.018 |
| sad | 1.65 | - | 0.037 | -0.5 | 5.1 | 7.9 | 15.5 | 0.003 |
| tired | 2.27 | 35.5 | 0.157 | -9.6 | 6.5 | 14.9 | 42.7 | 0.063 |

### Run

| Style | Speed (studs/s) | Frames per step | Hip bob (studs) | Lean (deg) | Side sway (deg) | Twist (deg) | Arm swing (deg) | Head bob (studs) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| normal | 6.03 | 20 | 0.2 | -7.3 | 1.8 | 25.7 | 58.1 | 0.011 |
| active | 5.5 | 28 | 0.428 | -9.0 | 9.3 | 44.9 | 73.3 | 0.022 |
| angry | 6.39 | 20 | 0.161 | -12.7 | 7.6 | 56.4 | 125.4 | 0.033 |
| childish | 4.21 | 22 | 0.245 | -10.8 | 6.7 | 24.6 | 87.1 | 0.033 |
| chimpira (thug) | 7.37 | 23 | 0.249 | -9.5 | 13.4 | 46.5 | 154.5 | 0.061 |
| feminine | 4.36 | 24 | 0.257 | -2.4 | 7.3 | 59.5 | 58.7 | 0.01 |
| giant | 5.39 | 26 | 0.25 | -12.7 | 9.1 | 46.6 | 85.0 | 0.049 |
| happy | 4.11 | 23 | 0.235 | -5.1 | 5.8 | 38.7 | 95.6 | 0.008 |
| masculinity | 7.55 | 22.5 | 0.301 | -14.7 | 7.5 | 33.0 | 81.9 | 0.062 |
| musical | 7.35 | 19 | 0.168 | -8.9 | 8.5 | 14.5 | 127.5 | 0.25 |
| not-confident | 4.23 | 20 | 0.189 | -14.8 | 7.8 | 23.4 | 19.2 | 0.032 |
| old | 4.81 | 20 | 0.17 | -24.3 | 8.6 | 8.9 | 50.9 | 0.102 |
| proud | 3.95 | 24 | 0.226 | -0.2 | 7.7 | 33.9 | 66.9 | 0.016 |
| sad | 3.63 | 24 | 0.221 | -14.9 | 9.9 | 39.6 | 69.3 | 0.053 |
| tired | 3.85 | 26 | 0.3 | -21.7 | 5.1 | 27.3 | 80.5 | 0.246 |

Readings for giving a character its personality:

- **Angry**: short fast steps, the biggest arm swing, a forward lean, a big twist.
- **Giant**: slow steps, the biggest bob, heavy side sway: weight shows in the vertical and the sideways motion.
- **Happy**: a big bob and a big arm swing at a normal pace: bounce.
- **Proud and feminine**: lean back, little bob.
- **Not confident, sad, old**: almost no twist and almost no arm swing; old and tired lean forward 10 to 21 degrees and nod the head.
- **Thug (chimpira)**: side sway twice normal with a big arm swing.

## Game feel numbers from other sources

- Dark Souls 3 enemy attacks (Game Developer, "Anatomy of an Enemy Attack"): human reaction takes about 240 ms; the attack signal plus the attack should give at least 340 ms for a familiar move; an end pose that baits lasts at least 240 ms, one that confirms the attack ended at least 170 ms; a response time of 50 to 100 ms feels tight.
- Ninja Gaiden combos (Game Developer, "Improving the Combat Impact of Action Games"): impacts at 0.23, 0.53 and 0.97 s for a light string; at 30 fps two impacts less than about 5 frames apart (0.17 s) read as one.
- Dan Da Dan fight sakuga (Japan Powered): hard keys with few soft in-betweens, a follow-through frame held 3 frames, a rhythm of one frame of motion then two of pause, limbs lengthened on the fastest frames.
