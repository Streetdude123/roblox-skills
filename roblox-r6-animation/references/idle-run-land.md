# Recorded R6 idle run and landing measurements

These are preserved measurements and interpretations from earlier project work. Use the current SKILL.md and principles.md for authoring decisions. Do not treat the ranges, inferred timing patterns, or historical style choices as universal requirements. See sources.md for provenance limits.

## Contents

- Ranges
- Idle every 0.3 s
- Run, every frame of the 0.533 s cycle
- Landing, every frame of 0.467 s
- What this idle demonstrates
- How the run works
- How the landing works
- Choices to consider when adapting this set

Read on 2026-09-22 from `Workspace."idle, run and landing animation r6".AnimSaves` (Idle 3.0 s loop at Idle priority, Run 0.533 s loop at Movement priority, Land Anim 0.467 s at Action priority), Linear baked poses. The idle and run tables use roughly 30 fps sampling; the landing table contains more densely spaced keys. Use each recorded timestamp rather than assuming one rate for all three clips. Lepy previously used this set as a style reference. Decoding as in walk-cycles.md; lift + on the torso is a lean back, so the negative values below are forward leans.

## Ranges

```
#Idle len=3.000 loop=true frames=91 prio=Idle
   Torso      lift   -6.0..-2.3   twist   -0.0..-0.0   side   -0.0..-0.0   y -0.11..-0.07 z -0.07..-0.03
   Head       lift   -2.1..0.0    twist   -0.0..-0.0   side    0.0..0.0    y  0.00..0.00  z  0.00..0.00 
   Right Leg  lift  -11.2..-4.4   twist  -11.9..-11.7  side    2.8..3.4    y  0.10..0.12  z -0.39..-0.28
   Left Leg   lift   -3.0..3.7    twist    3.3..3.7    side   -4.9..-4.8   y  0.13..0.17  z -0.53..-0.41
   Left Arm   lift   -1.0..3.4    twist   13.3..13.4   side   -2.6..-2.5   y -0.06..-0.05 z -0.08..-0.05
   Right Arm  lift   -4.2..0.4    twist   -7.6..-7.3   side    3.4..3.5    y -0.08..-0.06 z  0.01..0.04 
#Run len=0.533 loop=true frames=17 prio=Movement
   Torso      lift  -27.9..-26.1  twist  -24.6..24.6   side   -2.0..2.0    y -0.45..-0.28 z -0.30..-0.29
   Head       lift    3.7..9.5    twist  -24.0..24.0   side   -2.3..2.3    y -0.00..-0.00 z  0.00..0.00 
   Right Leg  lift  -78.3..53.6   twist  -90.3..37.5   side  -91.4..3.1    y -0.51..0.97  z -1.50..0.34 
   Left Leg   lift  -73.0..48.9   twist  -39.7..82.1   side   -3.2..84.2   y -0.66..0.94  z -1.11..0.39 
   Left Arm   lift  -62.3..79.3   twist -162.7..170.4  side  -45.9..134.7  y -0.72..-0.03 z -0.51..0.68 
   Right Arm  lift  -40.5..84.3   twist -173.2..179.6  side -130.8..37.8   y -0.61..-0.08 z -0.87..0.55 
#Land Anim len=0.467 loop=false frames=23 prio=Action
   Torso      lift  -41.8..-0.0   twist   -0.0..-0.0   side    0.0..0.0    y -1.18..-0.09 z -0.43..0.00 
   Head       lift  -38.4..-4.0   twist    0.0..0.0    side    0.0..0.0    y -0.00..-0.00 z -0.00..-0.00
   Right Leg  lift  -18.6..15.7   twist   -9.7..-1.3   side    5.4..8.6    y  0.13..1.41  z -1.14..-0.39
   Left Leg   lift   -1.6..43.1   twist    1.3..16.3   side   -9.9..1.1    y  0.01..1.19  z -1.00..0.02 
   Left Arm   lift  -25.3..46.2   twist -103.7..-20.4  side  -53.2..61.5   y -0.50..-0.11 z -0.28..0.31 
   Right Arm  lift  -37.5..63.7   twist  -13.8..103.7  side  -54.5..57.2   y -0.51..-0.04 z -0.37..0.20 
```

## Idle every 0.3 s

Columns: t | torso lift twist side | x y z | head lift twist side | right arm lift twist side y | left arm lift twist side y | right leg lift side y | left leg lift side y

```
 0.00 |  -3.6  -0.0  -0.0 |  0.00 -0.07 -0.04 |   0.0  -0.0   0.0 |  -4.2  -7.3   3.5 -0.06 |  -1.0  13.3  -2.6 -0.05 |  -6.8   3.3  0.10 |   1.6  -4.9  0.13
 0.30 |  -4.9  -0.0  -0.0 |  0.00 -0.07 -0.06 |  -0.2  -0.0   0.0 |  -3.7  -7.3   3.5 -0.07 |  -0.6  13.3  -2.6 -0.05 |  -5.2   3.4  0.10 |   3.1  -4.9  0.14
 0.60 |  -5.7  -0.0  -0.0 |  0.00 -0.08 -0.07 |  -0.8  -0.0   0.0 |  -2.6  -7.4   3.5 -0.07 |   0.5  13.4  -2.6 -0.05 |  -4.5   3.3  0.11 |   3.7  -4.9  0.15
 0.90 |  -6.0  -0.0  -0.0 |  0.00 -0.08 -0.07 |  -1.4  -0.0   0.0 |  -1.2  -7.5   3.4 -0.07 |   1.9  13.4  -2.6 -0.05 |  -4.7   3.2  0.12 |   3.4  -4.9  0.16
 1.20 |  -5.5  -0.0  -0.0 |  0.00 -0.09 -0.06 |  -1.9  -0.0   0.0 |  -0.1  -7.5   3.4 -0.08 |   3.0  13.4  -2.5 -0.05 |  -6.1   3.0  0.12 |   2.0  -4.8  0.17
 1.50 |  -4.5  -0.0  -0.0 |  0.00 -0.10 -0.05 |  -2.1  -0.0   0.0 |   0.4  -7.6   3.4 -0.08 |   3.4  13.4  -2.5 -0.06 |  -8.5   2.9  0.12 |  -0.3  -4.8  0.17
 1.80 |  -3.3  -0.0  -0.0 |  0.00 -0.11 -0.04 |  -1.9  -0.0   0.0 |  -0.1  -7.5   3.4 -0.08 |   3.0  13.4  -2.5 -0.05 | -10.4   2.8  0.12 |  -2.2  -4.8  0.17
 2.10 |  -2.5  -0.0  -0.0 |  0.00 -0.11 -0.03 |  -1.4  -0.0   0.0 |  -1.2  -7.5   3.4 -0.07 |   1.9  13.4  -2.6 -0.05 | -11.2   2.8  0.11 |  -3.0  -4.8  0.16
 2.40 |  -2.4  -0.0  -0.0 |  0.00 -0.10 -0.03 |  -0.8  -0.0   0.0 |  -2.6  -7.4   3.5 -0.07 |   0.5  13.4  -2.6 -0.05 | -10.9   2.9  0.11 |  -2.6  -4.8  0.15
 2.70 |  -2.7  -0.0  -0.0 |  0.00 -0.09 -0.03 |  -0.2  -0.0   0.0 |  -3.7  -7.3   3.5 -0.07 |  -0.6  13.3  -2.6 -0.05 |  -9.4   3.1  0.10 |  -1.1  -4.8  0.14
 3.00 |  -3.6  -0.0  -0.0 |  0.00 -0.07 -0.04 |   0.0  -0.0   0.0 |  -4.2  -7.3   3.5 -0.06 |  -1.0  13.3  -2.6 -0.05 |  -6.8   3.3  0.10 |   1.6  -4.9  0.13
```

Frame 0 of the idle is the stance: torso lean 3.6 forward, crouch 0.07, shifted forward 0.04; right leg rotated back 7 with the foot turned out 12 (twist) and the part moved forward 0.3 and up 0.1; left leg rotated forward 2 with the part moved forward 0.5 and up 0.13; arms almost at rest but asymmetric (right lift -4 twist -7 side 3.5, left lift -1 twist 13 side -2.6) and dropped 0.05.

## Run, every frame of the 0.533 s cycle

```
 0.00 | -27.9 -24.6  -2.0 |  0.02 -0.37 -0.30 |   9.5  24.0  -2.3 | -36.5  -9.0  37.8 -0.08 |  45.9 166.2 134.7 -0.58 | RL  53.6  0.38 -0.61 | LL -57.7 -0.36  0.39
 0.03 | -27.6 -22.4  -1.7 |  0.02 -0.41 -0.30 |   8.7  21.9  -1.8 | -38.6 -10.9  35.0 -0.09 |  44.2 170.4 128.6 -0.62 | RL  26.8  0.65 -0.86 | LL -66.5 -0.66  0.13
 0.07 | -27.0 -16.9  -1.1 |  0.01 -0.43 -0.29 |   6.7  16.5  -0.9 | -40.5 -18.9  23.8 -0.18 |  56.3 -162.7 106.0 -0.72 | RL   7.8  0.45 -1.00 | LL -73.0 -0.66 -0.44
 0.10 | -26.4  -9.0  -0.5 |  0.01 -0.41 -0.29 |   4.6   8.8  -0.2 | -23.0 -23.3   9.1 -0.16 |  79.3   8.1 -18.2 -0.52 | RL  -3.1  0.14 -0.82 | LL -50.8  0.31 -0.95
 0.13 | -26.1   0.0   0.0 | -0.00 -0.35 -0.29 |   3.7  -0.0  -0.0 |  33.2  -9.3  26.9 -0.25 |  51.0  33.6 -45.9 -0.43 | RL  -5.0 -0.06 -0.30 | LL -23.3  0.70 -1.11
 0.17 | -26.4   9.0   0.5 | -0.01 -0.29 -0.29 |   4.6  -8.8   0.2 |  61.8  17.0  17.6 -0.36 |  13.6  17.9 -35.6 -0.25 | RL -13.0 -0.09  0.05 | LL   2.5  0.94 -0.98
 0.20 | -27.0  16.9   1.1 | -0.01 -0.28 -0.29 |   6.7 -16.5   0.9 |  66.6 177.7 -118.1 -0.51 | -14.1   5.4 -29.1 -0.05 | RL -42.9 -0.33 -0.19 | LL  26.7  0.91 -0.83
 0.23 | -27.6  22.4   1.7 | -0.02 -0.31 -0.30 |   8.7 -21.9   1.8 |  45.0 -171.7 -129.8 -0.49 | -47.8  10.2 -24.8 -0.03 | RL -57.6 -0.51  0.05 | LL  47.2  0.61 -0.75
 0.27 | -27.9  24.6   2.0 | -0.02 -0.37 -0.30 |   9.5 -24.0   2.3 |  36.6 -171.4 -130.8 -0.50 | -57.1  13.3 -20.9 -0.07 | RL -60.1 -0.41  0.34 | LL  48.9  0.63 -0.83
 0.30 | -27.6  22.4   1.7 | -0.02 -0.42 -0.30 |   8.7 -21.9   1.8 |  31.8 -173.2 -127.2 -0.53 | -62.3  17.0 -17.8 -0.15 | RL -65.6 -0.35  0.27 | LL  32.4  0.81 -0.90
 0.33 | -27.0  16.9   1.1 | -0.01 -0.45 -0.29 |   6.7 -16.5   0.9 |  35.7 179.6 -119.1 -0.56 | -20.6   7.5 -14.9 -0.17 | RL -73.7 -0.48 -0.23 | LL  11.9  0.67 -1.01
 0.37 | -26.4   9.0   0.5 | -0.01 -0.44 -0.29 |   4.6  -8.8   0.2 |  60.3 154.4 -106.5 -0.61 |  16.5   4.3  -7.8 -0.13 | RL -78.3 -0.42 -1.14 | LL  -6.8  0.41 -1.01
 0.40 | -26.1   0.0   0.0 | -0.00 -0.39 -0.29 |   3.7  -0.0  -0.0 |  84.3  66.3 -40.3 -0.49 |  35.9 -12.1   4.2 -0.13 | RL -46.6  0.38 -1.50 | LL -17.9  0.09 -0.70
 0.43 | -26.4  -9.0  -0.5 |  0.01 -0.34 -0.29 |   4.6   8.8  -0.2 |  52.2  -5.4  30.4 -0.39 |  50.8 -42.5  -3.1 -0.41 | RL -12.4  0.95 -1.23 | LL -16.0 -0.03 -0.02
 0.47 | -27.0 -16.9  -1.1 |  0.01 -0.31 -0.29 |   6.7  16.5  -0.9 |   2.1  -7.2  26.2 -0.19 |  78.4 -148.4  87.1 -0.57 | RL  20.0  0.97 -0.85 | LL -24.1 -0.05  0.30
 0.50 | -27.6 -22.4  -1.7 |  0.02 -0.32 -0.30 |   8.7  21.9  -1.8 | -32.5  -9.9  36.3 -0.08 |  55.1 168.3 131.5 -0.58 | RL  43.6  0.62 -0.67 | LL -40.9 -0.17  0.37
 0.53 | -27.9 -24.6  -2.0 |  0.02 -0.37 -0.30 |   9.5  24.0  -2.3 | -36.5  -9.0  37.8 -0.08 |  45.9 166.2 134.7 -0.58 | RL  53.6  0.38 -0.61 | LL -57.7 -0.36  0.39
```

Legs in the run columns are lift then y then z (twist and side are unreliable near a 90 degree lift).

## Landing, every frame of 0.467 s

```
 0.00 | torso  -0.0 | -0.09  0.00 | head -17.2 | RA -37.5 -13.8  45.8 | LA -25.3 -22.9 -53.2 | RL   0.5  0.13 -0.46 | LL  15.2  0.01 -0.54
 0.02 | torso  -1.1 | -0.26 -0.01 | head -17.8 | RA -26.0  -6.3  52.1 | LA -17.3 -21.2 -51.3 | RL  -9.5  0.29 -0.83 | LL   7.9  0.24 -0.81
 0.05 | torso  -3.9 | -0.64 -0.04 | head -19.4 | RA   5.9   5.0  57.2 | LA   4.1 -20.4 -44.1 | RL -17.4  0.64 -1.13 | LL   5.3  0.68 -0.94
 0.07 | torso  -8.0 | -0.99 -0.09 | head -21.9 | RA  40.5  18.4  48.2 | LA  27.2 -28.5 -28.5 | RL -15.3  1.05 -1.08 | LL  13.2  1.05 -0.70
 0.08 | torso -12.9 | -1.13 -0.14 | head -24.9 | RA  59.4  43.2  22.0 | LA  39.8 -46.0  -5.9 | RL  -8.7  1.27 -0.89 | LL  21.6  1.17 -0.44
 0.10 | torso -18.4 | -1.15 -0.20 | head -28.1 | RA  63.3  61.3   1.0 | LA  42.5 -61.6  12.1 | RL  -3.4  1.33 -0.77 | LL  26.5  1.19 -0.32
 0.13 | torso -24.2 | -1.16 -0.27 | head -31.2 | RA  63.7  65.5  -5.6 | LA  42.6 -70.2  21.5 | RL   1.9  1.38 -0.65 | LL  31.3  1.18 -0.20
 0.15 | torso -29.9 | -1.17 -0.33 | head -34.1 | RA  63.7  68.3  -9.9 | LA  42.4 -75.5  27.3 | RL   7.1  1.40 -0.54 | LL  35.8  1.17 -0.10
 0.17 | torso -35.3 | -1.18 -0.38 | head -36.4 | RA  63.5  70.4 -13.0 | LA  42.4 -79.3  31.4 | RL  11.7  1.41 -0.45 | LL  39.8  1.14 -0.02
 0.18 | torso -39.6 | -1.18 -0.41 | head -37.9 | RA  63.1  72.0 -15.3 | LA  42.5 -82.1  34.3 | RL  15.1  1.40 -0.39 | LL  42.8  1.11  0.02
 0.22 | torso -41.7 | -1.17 -0.43 | head -38.4 | RA  62.6  73.2 -17.2 | LA  42.8 -84.2  36.6 | RL  15.7  1.39 -0.40 | LL  43.1  1.10  0.02
 0.23 | torso -41.8 | -1.13 -0.43 | head -37.6 | RA  62.0  74.2 -18.6 | LA  43.2 -85.9  38.3 | RL  13.8  1.36 -0.47 | LL  40.8  1.11 -0.04
 0.25 | torso -41.8 | -1.08 -0.43 | head -35.5 | RA  61.5  77.0 -22.0 | LA  43.8 -88.1  40.8 | RL  12.0  1.31 -0.54 | LL  38.4  1.10 -0.12
 0.27 | torso -41.8 | -1.02 -0.43 | head -32.4 | RA  61.1  83.8 -30.0 | LA  44.4 -91.8  45.7 | RL  10.5  1.26 -0.61 | LL  36.2  1.09 -0.19
 0.30 | torso -41.8 | -0.96 -0.43 | head -28.8 | RA  60.0  93.4 -41.2 | LA  44.6 -96.9  52.4 | RL   9.4  1.21 -0.67 | LL  34.3  1.07 -0.26
 0.32 | torso -41.8 | -0.91 -0.43 | head -24.8 | RA  57.8 101.6 -51.2 | LA  44.4 -101.7  58.8 | RL   8.5  1.15 -0.71 | LL  32.8  1.04 -0.32
 0.33 | torso -40.3 | -0.84 -0.42 | head -20.6 | RA  55.3 103.7 -54.5 | LA  44.3 -103.7  61.5 | RL   6.0  1.08 -0.78 | LL  29.3  1.01 -0.41
 0.35 | torso -37.0 | -0.77 -0.39 | head -16.4 | RA  53.0  99.5 -50.2 | LA  44.9 -101.5  58.7 | RL   1.3  0.97 -0.88 | LL  23.3  0.97 -0.54
 0.38 | torso -32.8 | -0.69 -0.35 | head -12.6 | RA  50.2  91.2 -40.8 | LA  46.2 -93.9  50.0 | RL  -4.2  0.85 -0.98 | LL  16.5  0.91 -0.68
 0.40 | torso -28.5 | -0.63 -0.31 | head  -9.2 | RA  46.0  80.9 -28.9 | LA  46.2 -80.6  35.9 | RL  -9.5  0.73 -1.05 | LL   9.8  0.83 -0.81
 0.42 | torso -24.6 | -0.58 -0.27 | head  -6.5 | RA  40.2  71.5 -17.8 | LA  42.6 -64.7  20.6 | RL -14.1  0.62 -1.10 | LL   4.0  0.75 -0.91
 0.43 | torso -21.8 | -0.55 -0.24 | head  -4.7 | RA  34.2  64.1  -8.5 | LA  35.2 -51.3   7.6 | RL -17.3  0.54 -1.13 | LL  -0.0  0.68 -0.97
 0.47 | torso -20.7 | -0.53 -0.23 | head  -4.0 | RA  30.9  60.8  -3.7 | LA  30.0 -46.0   1.7 | RL -18.6  0.50 -1.14 | LL  -1.6  0.65 -1.00
```

## What this idle demonstrates

1. One engine. The chest breath is a single 3 s wave: torso lean 2.3 to 6.0 degrees forward (peak lean at 0.85 s, upright at 2.25 s) with the root sinking 0.04 and moving forward 0.04 as it leans. There is no second or third frequency and no yaw or roll; the breath lives in the pitch plane.
2. Everything else is secondary to it. The head nods 2 degrees and peaks at 1.5 s, 0.65 s after the torso (about a fifth of the cycle), at half the amplitude. Both arms swing 2 to 4 degrees and peak with the head. The legs shift weight in phase with the torso: the back leg swings 4 to 11 degrees, the front leg -3 to +4.
3. The stance is built with translation, the motion with rotation. Feet are placed with 0.3 to 0.5 stud offsets on Z and 0.1 to 0.17 on Y, the back foot is turned out 12 degrees with twist, the arms hang 0.05 lower. Rotation alone cannot stagger the feet without lifting them.
4. Several low-amplitude channels drift by 0.1 to 0.3 degrees while others remain effectively constant in the rounded data. The final sample matches the first; inspect boundary velocity as well.
5. The pose reads at frame 0: asymmetric arms, staggered feet, a small forward lean. The breath is decoration on a pose that already says something.

## How the run works

- The torso leans 26 to 28 forward the whole cycle and twists plus or minus 24.6 with the hips (toward the forward leg); the head counters that twist one to one and lifts 4 to 9 so the face stays level and forward. The root sits 0.28 to 0.45 low with two bobs per cycle (low at contact, high in flight) and 0.3 forward.
- Legs swing -78 to +54 and the leg PARTS translate: up to 0.97 up and 1.5 forward at knee drive, 0.5 to 0.66 down at full extension. Arms swing -62 to +84 with twists near 170 (the forearm crossing the body) and translations up to 0.87 forward and 0.72 down. Cycle 0.533 s at Movement priority.

## How the landing works

- The root reaches most of its drop around 0.10 s, while torso pitch reaches about -42 at 0.23 s. These are separate arrivals, not a whole-body fold completed in five frames. The table records upward leg translations of 1.2 to 1.4 studs and the arms moving forward for balance.
- The torso stays near its deepest pitch from about 0.22 to 0.30 s while its height starts recovering earlier. The head leads the remaining pitch recovery, and the clip ends mid recovery. Inspect the blend to the next state to judge the complete landing.

## Choices to consider when adapting this set

- This idle is torso-led with delayed head and arm motion. Reuse that relationship when the new action calls for it; do not impose its phase offsets on contacts or every other action.
- Head counters torso twist one to one and torso lean partially; in a recovery the head leads.
- Scale amplitude to energy: idle 2 to 6 degrees, walk 30 to 45, run 60 to 80 plus stud size translations, landing a 42 degree fold and a 1.1 stud drop.
- Use part translation where the rigid R6 pose needs it, then inspect contact and joint gaps. Translation suggests a tuck or reach but does not create another joint.
- Inspect loop pose and velocity continuity. Keep channels still when their purpose or contact requires it.
