# R6 walk cycles from four community animators

These are preserved measurements and interpretations from earlier project work. Use the current SKILL.md and principles.md for authoring decisions. Do not treat the ranges, inferred timing patterns, or historical style choices as universal requirements. See sources.md for provenance limits.

## Contents

- Ranges per clip
- Walk2 by emm1gar, every key (hand keyed, 8 keys per 0.917 s cycle)
- Walk4 by roblox_boi8913, a run, every 4th frame of 0.76 s
- Walk3 by Gusthavuo777, a light crouched walk, every 4th frame of 0.867 s
- Patterns recorded in these examples

Read on 2026-09-22 from `Workspace.BestWalkAnimR6.R6.AnimSaves` (Walk1 by haynob, Walk2 by emm1gar, Walk3 by Gusthavuo777, Walk4 by roblox_boi8913) plus the Roblox default R6 walk (rbxassetid 180426354). Every pose is decoded into the parent part axes: lift = swing forward (+) or back (-), twist = rotation about the limb, side = out to +X. Torso lift + is a lean back. Positions are studs in the parent axes. All four exports are baked at 30 or 60 fps with Linear poses, so the timing lives in the curves.

## Ranges per clip

```
#walk/Walk1 len=3.000 loop=true frames=91 prio=Movement
   Torso      lift   -4..-1   twist   -2..2    side   -2..2    y -0.03..0.08  z -0.09..-0.00
   Head       lift    3..3    twist   -0..0    side   -2..2    y  0.00..0.00  z -0.00..-0.00
   Right Leg  lift  -27..24   twist   -4..3    side   -4..1    y -0.08..0.25  z -0.51..0.11 
   Left Leg   lift  -27..24   twist   -3..4    side   -1..4    y  0.01..0.22  z -0.51..0.11 
   Left Arm   lift   -8..28   twist  -20..14   side   -6..-2   y -0.29..-0.23 z -0.09..0.21 
   Right Arm  lift   -8..28   twist  -14..20   side    2..6    y -0.29..-0.24 z -0.07..0.21 
#walk/Walk2 len=0.917 loop=true frames=9 prio=Action
   Torso      lift   -5..-5   twist   -5..5    side   -0..0    y  0.00..0.11  z -0.01..0.00 
   Head       lift    0..0    twist   -4..4    side   -0..0    y  0.00..0.00  z -0.00..-0.00
   Right Leg  lift  -54..28   twist   -9..4    side   -7..2    y -0.27..0.22  z -1.09..-0.04
   Left Leg   lift  -54..28   twist   -4..9    side   -2..7    y -0.27..0.22  z -1.09..-0.04
   Left Arm   lift  -33..40   twist   -8..12   side  -12..0    y -0.34..-0.18 z -0.16..0.12 
   Right Arm  lift  -30..37   twist  -19..29   side   -7..8    y -0.36..-0.25 z -0.14..0.11 
#walk/Walk3 len=0.867 loop=true frames=41 prio=Movement
   Torso      lift   -7..-6   twist   -4..4    side   -0..0    y -0.16..-0.08 z -0.10..-0.08
   Head       lift   -4..-3   twist   -2..3    side   -2..2    y  0.02..0.02  z -0.00..-0.00
   Right Leg  lift  -31..30   twist   -4..4    side   -2..0    y -0.06..0.37  z -0.84..0.06 
   Left Leg   lift  -31..30   twist   -4..4    side   -0..2    y -0.06..0.37  z -0.84..0.06 
   Left Arm   lift  -17..18   twist  -21..18   side  -10..-4   y -0.14..-0.07 z -0.05..0.19 
   Right Arm  lift  -17..18   twist  -18..21   side    4..10   y -0.14..-0.07 z -0.05..0.19 
#walk/Walk4 len=0.760 loop=true frames=49 prio=Core
   Torso      lift  -12..-5   twist   -5..5    side   -1..1    y -0.31..-0.18 z -0.12..-0.03
   Head       lift    0..8    twist   -5..6    side   -2..1    y -0.00..-0.00 z  0.00..0.00 
   Right Leg  lift  -40..51   twist   -9..10   side   -6..3    y  0.00..0.31  z -0.65..0.30 
   Left Leg   lift  -40..51   twist  -10..9    side   -3..6    y  0.00..0.31  z -0.65..0.30 
   Left Arm   lift  -46..61   twist   -7..13   side  -22..-4   y -0.22..-0.09 z -0.27..0.23 
   Right Arm  lift  -46..61   twist  -13..7    side    4..22   y -0.22..-0.09 z -0.27..0.23 
```

Roblox default walk (180426354): cycle 0.67 s at speed 16, right leg +45..-74, left leg -59..+45, right arm -45..+63, left arm +56..-30, torso and head still. Default idle (180435571): a 0.03 stud torso dip over 1 s and nothing else.

## Walk2 by emm1gar, every key (hand keyed, 8 keys per 0.917 s cycle)

Columns: t | torso lift twist side | x y z | head lift twist side | right arm lift twist side | left arm lift twist side | right leg lift side y | left leg lift side y

```
0.000 |   -5    3    0 |  0.00  0.00  0.00 |    0   -4   -0 |   37   29   -7 |  -33   12   -3 |  -45   -5 -0.27 |   28   -2 -0.01
0.117 |   -5    1    0 |  0.00  0.00  0.00 |    0   -2   -0 |   14    9    4 |  -17    5   -5 |  -54   -7 -0.14 |    7   -2  0.12
0.233 |   -5   -0    0 | -0.00  0.11 -0.01 |    0    1    0 |  -13   -2    6 |   15   -2   -9 |  -23   -5  0.03 |    4   -2 -0.09
0.350 |   -5   -5   -0 | -0.00  0.11 -0.01 |    0    4    0 |  -23   -6    5 |   29    1   -4 |   -4    2  0.22 |  -24    1 -0.09
0.467 |   -5   -3   -0 |  0.00  0.00  0.00 |    0    1    0 |  -30  -19   -3 |   40   -8    0 |   28    2 -0.01 |  -45    5 -0.27
0.583 |   -5   -1   -0 |  0.00  0.00  0.00 |    0   -3   -0 |  -22  -14   -0 |   35    1   -5 |    5    2  0.03 |  -54    7 -0.14
0.700 |   -5    0   -0 |  0.00  0.11 -0.01 |    0    1    0 |   -6   -4    5 |    6    6   -8 |    4    2 -0.09 |  -23    5  0.03
0.817 |   -5    5    0 |  0.00  0.11 -0.01 |    0   -3   -0 |   17    6    8 |  -24   11  -12 |  -24   -1 -0.09 |   -4   -2  0.22
0.917 |   -5    3    0 |  0.00  0.00  0.00 |    0   -4   -0 |   37   29   -7 |  -33   12   -3 |  -45   -5 -0.27 |   28   -2 -0.01
```

## Walk4 by roblox_boi8913, a run, every 4th frame of 0.76 s

```
0.000 |   -5   -3   -1 |  0.00 -0.18 -0.07 |    0    3    1 |    4    2    5 |    5    2   -4 |   -4    3  0.05 |  -16    1  0.31
0.063 |   -6   -0   -1 |  0.00 -0.19 -0.04 |    2    0    0 |   32   -2    8 |  -32    1   -6 |  -22    1  0.02 |   29    1  0.16
0.127 |   -7    3   -0 |  0.00 -0.26 -0.05 |    4   -3    0 |   54   -9   16 |  -45   -6  -11 |  -36   -3  0.02 |   49    5  0.02
0.190 |   -8    4   -1 | -0.00 -0.31 -0.12 |    6   -4    1 |   61  -13   22 |  -46   -7  -13 |  -40   -4  0.03 |   51    6  0.00
0.254 |  -12    5   -0 | -0.00 -0.29 -0.09 |    8   -5    1 |   49   -5   13 |  -34   -3  -10 |  -35   -5  0.11 |   33    3  0.15
0.317 |  -10    5    0 | -0.00 -0.23 -0.07 |    6   -5    0 |   29   -1    6 |  -15   -1   -7 |  -29   -4  0.24 |   10   -0  0.17
0.381 |   -5    3    1 | -0.00 -0.18 -0.07 |    0   -3   -1 |    5   -2    4 |    4   -2   -5 |  -16   -1  0.31 |   -4   -3  0.05
0.443 |   -6    0    1 | -0.00 -0.19 -0.04 |    2   -0   -1 |  -32   -1    6 |   32    2   -8 |   29   -1  0.16 |  -22   -1  0.02
0.507 |   -7   -3    0 | -0.00 -0.26 -0.05 |    4    4   -1 |  -45    6   11 |   54    9  -16 |   49   -5  0.02 |  -36    3  0.02
0.570 |   -8   -4    1 |  0.00 -0.31 -0.12 |    6    4   -1 |  -46    7   13 |   61   13  -22 |   51   -6  0.00 |  -40    4  0.03
0.633 |  -12   -5    0 |  0.00 -0.29 -0.09 |    8    5   -2 |  -34    3   10 |   49    5  -13 |   33   -3  0.15 |  -35    5  0.11
0.697 |  -10   -5   -0 |  0.00 -0.23 -0.07 |    6    5   -1 |  -15    1    7 |   29    1   -6 |   10    0  0.17 |  -29    4  0.24
0.760 |   -5   -3   -1 |  0.00 -0.18 -0.07 |    0    3    1 |    4    2    5 |    5    2   -4 |   -4    3  0.05 |  -16    1  0.31
```

## Walk3 by Gusthavuo777, a light crouched walk, every 4th frame of 0.867 s

```
0.000 |   -7   -4   -0 |  0.00 -0.16 -0.09 |   -3    3    2 |  -15  -18    9 |   15  -21   -5 |   27   -2  0.05 |  -19    1 -0.03
0.083 |   -7   -3   -0 |  0.00 -0.16 -0.10 |   -3    3    1 |  -17  -16    9 |   18  -19   -5 |   20   -1  0.09 |  -31    2 -0.04
0.167 |   -6   -1   -0 |  0.00 -0.11 -0.09 |   -3    1    0 |  -14   -6   10 |   15   -9   -7 |    3   -0  0.13 |  -27    1  0.17
0.267 |   -6    1    0 | -0.00 -0.08 -0.08 |   -4   -0   -0 |   -4    5    9 |    5    3  -10 |   -9   -0  0.03 |  -11   -0  0.36
0.350 |   -6    3    0 | -0.00 -0.11 -0.09 |   -4   -2   -1 |    7   15    7 |   -7   13  -10 |  -10   -0  0.00 |    8    0  0.30
0.433 |   -7    4    0 | -0.00 -0.16 -0.09 |   -3   -2   -2 |   15   21    5 |  -15   18   -9 |  -19   -1 -0.03 |   27    2  0.05
0.517 |   -7    3    0 | -0.00 -0.16 -0.10 |   -3   -2   -1 |   18   19    5 |  -17   16   -9 |  -31   -2 -0.04 |   20    1  0.09
0.600 |   -6    1    0 | -0.00 -0.11 -0.09 |   -3   -0   -0 |   15    9    7 |  -14    6  -10 |  -27   -1  0.17 |    3    0  0.13
0.700 |   -6   -1   -0 |  0.00 -0.08 -0.08 |   -4    1    0 |    5   -3   10 |   -4   -5   -9 |  -11    0  0.36 |   -9    0  0.03
0.783 |   -6   -3   -0 |  0.00 -0.11 -0.09 |   -4    3    1 |   -7  -13   10 |    7  -15   -7 |    8   -0  0.30 |  -10    0  0.00
0.867 |   -7   -4   -0 |  0.00 -0.16 -0.09 |   -3    3    2 |  -15  -18    9 |   15  -21   -5 |   27   -2  0.05 |  -19    1 -0.03
```

## Walk2 as DIO's walk (2026-09-22)

DIO's locomotion plays Walk2's keys re-keyed on u = ((t - 0.30) / 0.917) mod 1, so u 0 and 0.5 are where the legs cross (the controller settles there on a stop). Right leg lift / abduction by u: 0.055 -4 / 2 (knee up 0.22), 0.182 +28 / 2 (contact), 0.309 +5, 0.436 +4, 0.564 -24 / -1, 0.673 -45 / -5, 0.800 -54 / -7 (toe off), 0.927 -23 / -5 (knee 0.03); the left leg is the same curve half a cycle later with the abduction mirrored. Arms, torso twist and head twist are Walk2's columns at the same u. Changes from the source: leg y below zero clamped to 0 (the torso height comes from the sole corner instead), arms dropped 0.15 instead of 0.18 to 0.36, curves hermite through the keys instead of linear.

## Patterns recorded in these examples

1. Cycle length 0.76 s (run) to 0.92 s (walk) at speed 16; a slow walk is 1.5 s. The Roblox default is 0.67 s.
2. Legs swing further back than forward: about -45..+30 for a walk, -40..+50 for a run. Choose the stance and swing timing from support; a symmetric sine alone does not establish a foot plant.
3. Legs translate on Y. The back leg is pushed DOWN (-0.1 to -0.27) so the planted foot does not rise off the floor, and the leg is LIFTED (+0.22 to +0.37) as it passes forward, which reads as a knee. This is the single biggest difference from a naive R6 walk.
4. Torso leans forward 5 to 7 degrees in a walk and 5 to 12 in a run, bobs up 0.1 twice per cycle at the passing poses, and a run sits 0.2 to 0.3 lower. Torso twist is only 3 to 5 degrees and the head counters it with 2 to 4.
5. Arms swing 30 to 40 (60 in a run) with a wrist twist of 20 to 30 that follows the swing (twist about 0.6 x lift on the right arm, about -0.3 x lift on the left), elbows out 5 to 12, and the arm parts sit 0.1 to 0.3 lower than rest (relaxed shoulders, no clipping).
6. Walk2 demonstrates a cycle with eight hand-placed keys plus its repeated endpoint. Add breakdowns where the new rig or path needs them; key count alone does not determine quality.
