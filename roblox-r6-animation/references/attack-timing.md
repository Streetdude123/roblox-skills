# Attack timing from a professional R6 sword kit

Read on 2026-09-22 from `Workspace."this is SO 2006 roblox retro core...".Sword.AnimSaves` (block hit, block idle, block start, block end, charge, equip, finish, hit1, hit2, hit3, idle) and the folder `old animations (feb 2022)` (charged idle, charged swing, charging, equip, finish, idle, swing 1, swing 2). All exported at 60 fps with Linear poses. Decoding as in walk-cycles.md. The rig has an extra Handle motor (Right Arm to Handle) and a Sword motor.

## Ranges per clip

```
#sword/block end len=0.400 loop=false frames=25 prio=Action
   Torso      lift    0..0    twist  -22..20   side   -0..-0   y  0.00..0.00 
   Head       lift    0..0    twist  -20..21   side    0..0    y  0.00..0.00 
   Left Arm   lift   -9..74   twist -174..174  side   -2..138  y -0.82..-0.02
   Right Arm  lift   65..88   twist  -33..173  side -127..63   y -0.64..-0.17
#sword/block hit len=0.400 loop=false frames=25 prio=Action
   Torso      lift    0..0    twist  -35..-20  side   -0..-0   y  0.00..0.00 
   Head       lift    0..0    twist   20..36   side    0..0    y  0.00..0.00 
   Left Arm   lift   22..25   twist  141..160  side  138..139  y -0.82..-0.81
   Right Arm  lift   46..70   twist  170..177  side -120..-109 y -0.77..-0.62
#sword/block idle len=3.317 loop=true frames=200 prio=Action
   Torso      lift    0..0    twist  -22..-22  side   -0..-0   y  0.00..0.00 
   Head       lift    0..0    twist   21..21   side    0..0    y  0.00..0.00 
   Left Arm   lift   24..24   twist  157..158  side  137..138  y -0.85..-0.82
   Right Arm  lift   65..65   twist  173..174  side -111..-111 y -0.67..-0.64
#sword/block start len=0.367 loop=false frames=23 prio=Action
   Torso      lift   -0..-0   twist  -23..20   side   -0..-0   y  0.00..0.00 
   Head       lift    0..0    twist  -20..24   side    0..0    y  0.00..0.00 
   Left Arm   lift   -8..80   twist -174..170  side  -11..139  y -0.85..-0.02
   Right Arm  lift   64..87   twist  -39..178  side -135..75   y -0.64..-0.17
#sword/charge len=1.567 loop=false frames=95 prio=Action
   Torso      lift  -17..1    twist  -30..78   side  -14..12   y  0.00..0.00 
   Head       lift   -6..6    twist  -75..30   side   -0..10   y -0.00..-0.00
   Left Arm   lift   -9..80   twist -179..176  side  -55..107  y -0.32..-0.02
   Right Arm  lift  -55..67   twist  -48..17   side   39..108  y -0.36..-0.11
#sword/equip len=0.983 loop=false frames=60 prio=Action
   Torso      lift   -8..-0   twist  -65..20   side   -2..3    y -0.01..0.00 
   Head       lift  -15..-0   twist  -20..57   side   -0..7    y  0.00..0.00 
   Left Arm   lift  -19..1    twist    3..46   side  -12..-2   y -0.08..-0.00
   Right Arm  lift  -37..87   twist -175..6    side -157..84   y -0.74..-0.03
#sword/finish len=3.200 loop=true frames=193 prio=Action
   Torso      lift  -44..19   twist  -32..20   side   -5..4    y -0.40..0.00 
   Head       lift  -28..0    twist  -22..34   side   -1..12   y -0.00..-0.00
   Right Leg  lift  -20..47   twist  -37..27   side   -4..36   y -0.20..0.76 
   Left Leg   lift  -27..1    twist   -1..42   side   -0..19   y -0.18..0.27 
   Left Arm   lift  -15..84   twist -158..173  side  -58..174  y -0.35..0.57 
   Right Arm  lift  -33..85   twist -179..177  side -178..180  y -0.50..0.33 
#sword/hit1 len=0.817 loop=false frames=50 prio=Action
   Torso      lift  -19..19   twist  -28..37   side   -0..13   y -0.03..0.00 
   Head       lift  -29..11   twist  -35..26   side   -6..1    y -0.00..-0.00
   Left Arm   lift  -35..51   twist -146..21   side  -37..80   y -0.43..0.08 
   Right Arm  lift  -18..80   twist -172..23   side -179..171  y -0.48..-0.13
#sword/hit2 len=0.817 loop=false frames=50 prio=Action
   Torso      lift  -19..19   twist  -37..28   side  -13..0    y -0.03..0.00 
   Head       lift  -29..11   twist  -26..35   side   -1..6    y -0.00..-0.00
   Left Arm   lift  -14..15   twist   -4..15   side  -22..-2   y -0.12..-0.02
   Right Arm  lift    5..83   twist -174..180  side -151..145  y -0.59..-0.15
#sword/hit3 len=0.733 loop=false frames=45 prio=Action
   Torso      lift  -17..1    twist  -30..78   side  -14..12   y  0.00..0.00 
   Head       lift   -6..6    twist  -75..30   side   -0..10   y -0.00..-0.00
   Left Arm   lift   -9..80   twist -176..175  side  -55..108  y -0.32..-0.02
   Right Arm  lift  -55..67   twist  -48..17   side   39..108  y -0.36..-0.11
#sword/idle len=4.150 loop=true frames=250 prio=Action
   Torso      lift   -0..-0   twist   20..20   side   -0..-0   y  0.00..0.00 
   Head       lift    0..0    twist  -20..-20  side    0..0    y -0.00..-0.00
   Left Arm   lift   -8..-8   twist    3..3    side   -2..-2   y -0.02..-0.02
   Right Arm  lift   65..66   twist  -33..-31  side   46..48   y -0.18..-0.17
#old/charged idle len=0.983 loop=true frames=60 prio=Action
   Torso      lift  -11..-11  twist  -27..-27  side   -0..-0   y  0.00..0.00 
   Head       lift    8..8    twist   24..24   side   -5..-5   y  0.00..0.00 
   Left Arm   lift   28..28   twist  172..172  side   92..92   y -0.50..-0.50
   Right Arm  lift  -19..-19  twist  -13..-13  side   78..78   y -0.36..-0.36
#old/charged swing len=0.700 loop=false frames=43 prio=Action
   Torso      lift  -10..3    twist  -22..32   side    0..3    y  0.00..0.00 
   Head       lift   -5..8    twist  -32..21   side   -5..0    y -0.00..-0.00
   Left Arm   lift   -6..67   twist -178..176  side  -30..92   y -0.50..-0.00
   Right Arm  lift  -13..71   twist  -30..0    side   37..81   y -0.36..-0.10
#old/charging len=0.983 loop=false frames=60 prio=Action
   Torso      lift  -11..-0   twist  -27..15   side   -0..0    y  0.00..0.00 
   Head       lift    0..8    twist  -15..24   side   -5..0    y  0.00..0.00 
   Left Arm   lift   -5..61   twist -178..178  side   -5..92   y -0.50..-0.00
   Right Arm  lift  -19..68   twist  -33..-13  side   38..78   y -0.36..-0.10
#old/equip len=0.733 loop=false frames=45 prio=Action
   Torso      lift   -0..-0   twist   -0..15   side   -0..-0   y  0.00..0.00 
   Head       lift    0..0    twist  -15..0    side    0..0    y  0.00..0.00 
   Left Arm   lift   -5..0    twist   -0..5    side   -0..0    y -0.00..-0.00
   Right Arm  lift   10..72   twist  -29..-0   side    0..38   y -0.10..-0.00
#old/finish len=1.650 loop=false frames=100 prio=Action
   Torso      lift   -7..-0   twist   15..29   side   -0..0    y  0.00..0.00 
   Head       lift  -15..-0   twist  -31..-15  side   -8..-0   y  0.00..0.00 
   Left Arm   lift  -16..-5   twist    5..11   side    0..14   y -0.00..-0.00
   Right Arm  lift   52..76   twist -131..-29  side   38..152  y -0.15..0.28 
#old/idle len=3.317 loop=true frames=200 prio=Action
   Torso      lift   -0..-0   twist   15..15   side   -0..-0   y  0.00..0.00 
   Head       lift    0..0    twist  -15..-15  side    0..0    y  0.00..0.00 
   Left Arm   lift   -5..-5   twist    5..5    side    0..0    y -0.00..-0.00
   Right Arm  lift   68..68   twist  -29..-29  side   38..38   y -0.11..-0.10
#old/swing 1 len=0.900 loop=false frames=55 prio=Action
   Torso      lift  -20..15   twist  -30..26   side   -2..4    y  0.00..0.00 
   Head       lift  -14..16   twist  -22..31   side   -0..4    y -0.00..-0.00
   Left Arm   lift  -17..62   twist -174..13   side  -35..87   y -0.83..-0.00
   Right Arm  lift   -8..72   twist -174..148  side -163..173  y -1.14..0.06 
#old/swing 2 len=0.900 loop=false frames=55 prio=Action
   Torso      lift  -20..20   twist  -18..55   side   -8..1    y  0.00..0.00 
   Head       lift  -18..15   twist  -54..12   side  -13..2    y  0.00..0.00 
   Left Arm   lift  -14..-5   twist    1..22   side  -19..1    y -0.01..0.00 
   Right Arm  lift    3..85   twist  -33..165  side -122..47   y -0.76..-0.10
```

## hit1 frame by frame

Columns: t | torso lift twist side y | head lift twist | right arm lift twist side | left arm lift side

```
0.000 |    -0    20    -0  0.00 |     0   -20 |    66   -33    48 |    -8    -2
0.017 |     1    17     0  0.00 |    -2   -17 |    72   -55    73 |     0    -2
0.033 |     5     9     1  0.00 |    -6   -10 |    62  -122   150 |    21     7
0.050 |     9    -2     4  0.00 |   -13    -0 |    29  -139  -179 |    35    40
0.067 |    13   -13     6  0.00 |   -20    10 |     0  -137  -165 |    26    66
0.083 |    16   -22     8  0.00 |   -25    18 |   -12  -134  -158 |    16    73
0.100 |    18   -26     9  0.00 |   -28    23 |   -15  -132  -157 |    14    75
0.117 |    18   -28     9  0.00 |   -29    25 |   -17  -132  -157 |    13    78
0.133 |    18   -28     9  0.00 |   -29    26 |   -18  -131  -158 |    13    80
0.150 |    19   -27     8  0.00 |   -29    25 |   -18  -133  -163 |    16    80
0.167 |    19   -23     6  0.00 |   -28    21 |   -14  -140  -174 |    24    78
0.183 |    18   -14     4  0.00 |   -25    13 |     0  -149   171 |    36    70
0.200 |     9    -2     2 -0.00 |   -14     1 |    29  -161   155 |    49    49
0.217 |    -5    10     2 -0.01 |     1   -11 |    66  -172   147 |    51    11
0.233 |   -13    20     5 -0.01 |     7   -20 |    80    23   -56 |    36   -18
0.250 |   -16    27     8 -0.01 |    10   -27 |    49    13   -48 |    17   -30
0.267 |   -17    32    11 -0.02 |    11   -31 |    27    14   -48 |     2   -35
0.283 |   -18    35    12 -0.02 |    11   -34 |    17    15   -48 |   -10   -36
0.300 |   -18    36    13 -0.02 |    10   -35 |    17    17   -49 |   -18   -37
0.317 |   -19    37    13 -0.02 |    10   -35 |    21    18   -49 |   -24   -36
0.333 |   -19    36    12 -0.03 |    10   -35 |    25    20   -48 |   -28   -35
0.350 |   -18    36    12 -0.02 |     9   -35 |    28    21   -46 |   -31   -34
0.367 |   -18    35    11 -0.02 |     9   -34 |    30    21   -42 |   -33   -32
0.383 |   -16    34    10 -0.02 |     8   -34 |    32    21   -38 |   -34   -31
0.400 |   -15    33    10 -0.02 |     7   -33 |    33    20   -32 |   -35   -30
0.417 |   -14    31     9 -0.02 |     7   -32 |    35    19   -27 |   -35   -28
0.433 |   -12    30     8 -0.02 |     6   -31 |    37    18   -21 |   -34   -27
0.450 |   -11    28     7 -0.01 |     5   -30 |    39    16   -16 |   -34   -25
0.467 |   -10    27     6 -0.01 |     4   -28 |    42    14   -11 |   -33   -24
0.483 |    -8    26     5 -0.01 |     4   -27 |    44    12    -7 |   -31   -22
0.500 |    -7    25     5 -0.01 |     3   -26 |    48    10    -2 |   -29   -20
0.517 |    -6    24     4 -0.01 |     2   -25 |    51     7     2 |   -27   -18
0.533 |    -4    22     3 -0.01 |     2   -24 |    54     3     7 |   -25   -16
0.550 |    -3    22     2 -0.00 |     1   -22 |    57    -1    12 |   -22   -14
0.567 |    -2    21     2 -0.00 |     0   -21 |    60    -5    17 |   -20   -12
0.583 |    -1    20     1 -0.00 |    -0   -20 |    62   -10    23 |   -17   -10
0.600 |    -0    19     1 -0.00 |    -1   -20 |    64   -15    28 |   -14    -8
0.617 |     0    19     1 -0.00 |    -1   -19 |    66   -21    34 |   -12    -6
0.633 |     1    18     0 -0.00 |    -1   -18 |    67   -26    39 |   -10    -4
0.650 |     1    18    -0  0.00 |    -1   -18 |    68   -30    44 |    -8    -2
0.667 |     1    18    -0  0.00 |    -1   -18 |    68   -33    47 |    -7    -1
0.683 |     1    18    -0  0.00 |    -1   -18 |    68   -35    49 |    -6    -0
0.700 |     1    18    -0  0.00 |    -1   -18 |    68   -36    50 |    -6    -0
0.717 |     1    19    -0  0.00 |    -1   -18 |    68   -37    51 |    -6    -0
0.733 |     1    19    -0  0.00 |    -1   -19 |    67   -36    50 |    -6    -0
0.750 |     1    19    -0  0.00 |    -0   -19 |    67   -36    50 |    -7    -1
0.767 |     0    20    -0  0.00 |    -0   -19 |    67   -35    49 |    -7    -1
0.783 |     0    20    -0  0.00 |    -0   -20 |    66   -34    48 |    -8    -2
0.800 |     0    20    -0  0.00 |    -0   -20 |    66   -34    48 |    -8    -2
0.817 |    -0    20    -0  0.00 |     0   -20 |    66   -33    48 |    -8    -2
```

## Speed segments of every attack

Torso and right arm angular change per frame, tagged hold (under 4 deg) move (4 to 15) fast (15 to 40) STRIKE (over 40).

```
#sword/hit1 len=0.817 loop=false frames=50 prio=Action
fast@0.02 STRIKE@0.03 fast@0.08 move@0.10 hold@0.12 move@0.15 fast@0.17 STRIKE@0.20 fast@0.25 move@0.28 hold@0.30 move@0.32 hold@0.67 
#sword/hit2 len=0.817 loop=false frames=50 prio=Action
move@0.02 STRIKE@0.03 fast@0.07 move@0.10 hold@0.13 move@0.15 hold@0.18 fast@0.20 STRIKE@0.22 fast@0.27 move@0.28 hold@0.32 move@0.35 hold@0.38 move@0.57 hold@0.62 move@0.68 hold@0.70 
#sword/hit3 len=0.733 loop=false frames=45 prio=Action
hold@0.02 move@0.08 fast@0.15 STRIKE@0.18 fast@0.20 move@0.27 hold@0.32 move@0.42 hold@0.62 
#old/swing 1 len=0.900 loop=false frames=55 prio=Action
fast@0.02 STRIKE@0.03 fast@0.07 move@0.12 fast@0.17 STRIKE@0.22 fast@0.25 move@0.28 hold@0.33 move@0.45 hold@0.72 
#old/swing 2 len=0.900 loop=false frames=55 prio=Action
move@0.02 STRIKE@0.03 fast@0.05 move@0.12 fast@0.17 STRIKE@0.22 fast@0.25 move@0.30 hold@0.35 
#sword/block start len=0.367 loop=false frames=23 prio=Action
hold@0.02 move@0.03 fast@0.08 STRIKE@0.10 fast@0.12 move@0.13 hold@0.18 
#sword/block end len=0.400 loop=false frames=25 prio=Action
hold@0.02 move@0.08 STRIKE@0.17 move@0.18 hold@0.27 
#sword/equip len=0.983 loop=false frames=60 prio=Action
hold@0.02 move@0.08 fast@0.12 STRIKE@0.17 fast@0.22 move@0.27 hold@0.33 move@0.48 hold@0.77 
#old/equip len=0.733 loop=false frames=45 prio=Action
hold@0.02 move@0.08 hold@0.30 
```

## The pattern

Every attack is snap, hold, snap, settle, then a long recovery:

1. Frames 1-4 (0.02-0.07 s): a FAST move into the wind up. The wind up itself is a snap, not a slow ease. The torso leans BACK 15-19 degrees and twists 20-28 away from the swing, the head looks down and counters the twist, the sword arm goes up and over (lift 66 to -18, side through 150 to -160, so the blade travels behind the head), the free arm comes up and out for balance.
2. Frames 5-8 (0.08-0.15 s): a HOLD at the wind up, 2-4 frames, values drifting by 1-3 degrees. This is the anticipation the eye reads.
3. Frames 9-13 (0.17-0.23 s): the STRIKE. The torso whips from lean back +19 to lean forward -13 and from twist -28 to +20 in 3-4 frames (a 32 degree pitch swing and a 48 degree yaw swing), the sword arm covers about 130 degrees in 3 frames, the head snaps the other way. Nothing is eased here; it is 3 frames of near linear motion.
4. Frames 14-18 (0.23-0.32 s): FOLLOW THROUGH. The torso overshoots past the end pose (lean -19, twist +37 against an end value of about -16 / +33), the arm continues down and across, the free arm swings behind.
5. Frames 19-50 (0.32-0.82 s): a SLOW recovery, 30 frames, every joint easing back to the idle pose on a smooth decelerating curve with no bounce. Over 60 percent of the clip is this recovery.

Other facts:

- The head counter rotates the torso twist almost one to one (head twist about minus torso twist) so the face stays on the target through the swing. Head pitch dips 25-29 on the wind up and rises 10 on the strike.
- Torso translation is tiny in attacks (y down 0.03) except taunt or finish poses (finish crouches 0.4).
- Priority is Action for every weapon clip; the weapon idles only move Torso Head and Arms and leave the legs to the core idle or walk.
- The sword idle is a static bladed pose: torso twist +20 with head -20, sword arm lift 65 side 47 twist -32, and only a half degree of drift over 4 s. The old idle is the same with twist 15. Breathing comes from the core layer under it, not from the overlay.
- Block start and end are 0.37-0.40 s with the same snap hold shape; block hit is a 0.4 s recoil.
- Equip is 1.0 s: hold, a fast draw at 0.12-0.22 (STRIKE speed), settle by 0.33, then a 0.5 s hold.
