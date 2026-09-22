# The World stand clips decoded

Lepy dropped a free model of The World (a WIP mesh stand on a standard R6 rig, no scripts) into
Place1 on 2026-09-21 and said its animations are "SUPER high quality" and to learn from them. Its
`AnimSaves` held eight Moon Animator clips baked at 60 fps as Linear keys: `TW idle`, `TWLeftPunch`,
`TWRightPunch`, `TWLeftUpperCut`, `TWRightKick`, `TWLeftStab`, `Barrage`, `TWHeavyPunch`. They were
decoded with `scripts/ReadClips.lua` into parent-axis poses (lift, twist, side, offset). Everything
below is measured. The clips now play in the place through `Poser.fromSequence` (see pipeline.md);
the raw sequences live in `ReplicatedStorage.Stand.Assets.Anims`.

## Why these clips read as high quality

1. **One engine per clip, always the torso.** Every strike is a torso rotation (twist 110 to 124
   degrees, or roll 50 degrees) and the limbs ride it. The barrage is nothing but the torso swinging
   -47 to +62 and back every five frames.
2. **The head counters the torso one to one** so the face never leaves the target: right punch
   torso -76 to +48 (124 degrees), head +68 to -49 (117 degrees) on the same five frames.
3. **The fist is a piston, not a swing.** During the five strike frames of a punch the arm rotation
   does not change at all; the arm part translates 0.62 studs forward and the torso twist does the
   reach. The arm angle only moves in the five follow-through frames after the hit (+9 degrees).
4. **Limbs float.** A stand has no skeleton to respect, so the animator translates limbs freely:
   the left arm swings 2.1 studs (z +0.76 to -1.37) on the stab, a leg lifts 1.13 up and 1.26 forward
   on the heavy punch, the barrage fists pump 0.3 to 0.6 studs. Humanoid clips stay under 0.5.
5. **Combo clips chain end to start.** LeftPunch ends at torso {-19, -76, -5}, which is exactly
   RightPunch frame 0. RightPunch ends at {-19, 46, 8} = LeftUpperCut frame 0, and so on through
   RightKick and LeftStab. There is no return to idle between hits; the recovery of one hit is the
   load of the next, so each clip is only 20 to 25 frames.
6. **Arc keys over the head.** The heavy punch arm goes {53, 99, -80} to {40, -97, 112} through a
   single frame at {81, -131, 148}: up and over, never through the torso.
7. **Roll is a strike channel.** The uppercut is torso roll +30 to -33 with the twist, the stab is
   roll -5 to -55; the sword kit only used pitch and yaw.

## Timing (60 fps frames)

| Clip | Frames | Load | Strike | Follow | Settle | Notes |
|---|---|---|---|---|---|---|
| LeftPunch | 25 | 0-10 | 10-15 | 15-20 | 20-25 | ends in RightPunch's start |
| RightPunch | 25 | 0-10 | 10-15 | 15-20 | 20-25 | torso twist 124 in 5 frames |
| LeftUpperCut | 25 | 0-10 | 10-15 | 15-20 | 20-25 | roll +30 then -33 |
| RightKick | 20 | none | 0-10 | 10-20 | - | leg 78 degrees, biggest step first |
| LeftStab | 20 | none | 0-10 | 10-20 | - | roll -55, arm thrust 0.7 studs |
| HeavyPunch | 30 | 0-12 | 18-20 | 20-25 | 25-30 | hold 12-18 creeps 10 degrees further |
| Barrage | 40 loop | 0-5 entry | 5 per swing | - | - | 4 swings per loop, 6 punches a second |
| idle | 150 loop | - | - | - | - | 2.5 s breath |

- A load is 10 frames and decelerates into the hold (the steps shrink toward frame 10).
- A strike is 5 frames with the biggest step in the middle (torso steps 10, 30, 45, 29, 9), or 2
  frames on the heavy. The kick and the stab have no load because the previous clip's end pose is
  the load; their strike is 10 frames of decelerating snap (steps 39, 19, 12, 6, 2).
- Follow-through is a second, slower motion after the hit: the torso lean deepens 4 degrees and
  the arm angle moves 9 degrees over 5 frames. Overlapping action, not a hold.
- The heavy punch hold is not flat: from frame 12 to 18 the wind-up creeps 10 degrees further in
  the same direction (anticipation keeps moving).
- The barrage half-beat is 5 frames from one extreme to the other with a decelerating profile
  (39, 30, 22, 13, 4) and an instant reversal: snap then settle, every punch.

## The stand idle (the float)

- 2.5 s loop, one breath on the torso: pitch -14.7 to -19.1 (leans in), roll -6 to -9, and the torso
  part drops 0.27 studs (p.y 0.46 to 0.19). That drop is the float bob; the root never moves.
- Re-measured from `decodes/TW_idle.txt` every 0.25 s: the bottom sits at 1.5 s (60 percent of the cycle),
  torso {-19.5, -9.2, -9.3} p.y 0.17, head {-3.3, 13.5, -1.8}, right arm {-13.7, -92.5, 63.7}, left arm
  {18.4, -92.3, 124.0}, right leg {-54.5, -2.2, 27.0}, left leg {-45.9, -0.3, -8.1}; the top is frame 0
  (torso {-14.7, -8.1, -6.0} p.y 0.46). The breath is 1.5 s down and 1.0 s up, and a sine in-out from top
  to bottom and back reproduces the decoded y to within 0.01 stud.
- Never re-author a clip the set already has. If a procedural extra (the float root) fights the loop, fix
  the extra: its periods must divide 2.5 s.
- Head nods 6.6 degrees (+3.8 to -2.8) with a constant 13.5 twist that counters the torso's -8.
- Right arm out at side 53 to 64, lift -6 to -14, twist -93, dropped back 0.36. Left arm raised
  across the chest: side 124, lift 26 to 18, twist -92, dropped 0.62.
- Legs trail: right lift -42 to -54 side 27 pulled forward 0.55; left lift -34 to -46 side -8
  pulled forward 1.0 and up 0.37.
- Every joint is in phase (extremes within 0.1 s of each other). A floating body moves as one mass;
  there is no ground to lag against, unlike the humanoid idle where the head trails a fifth of a cycle.
- Amplitudes are 2 to 3x a humanoid idle in the limbs and 6x on the vertical bob, at a slower
  2.5 s cycle. The curve is smooth in-out with soft extremes, not a pure sine.

## Barrage numbers

- Torso twist -47.5 to +61.9, pitch -14 to -20, roll -2.5 to -6; head twist +44 to -65; root still.
- Right arm holds {55..67, -77..-70, 76..84} and pumps x 0.28 to -0.03, z -0.12 to 0.08.
- Left arm swings {61..72, -67..+11, 73..3} with x -0.6 to -0.17 and y 0.55 to -0.07: the two
  arms are not mirrored, one pistons in place and the other swings wide.
- Right knee up: y 0.46 to 0.78, side 41. Left leg side -18 to -3 in phase.
- The authored loop pops 160 degrees on the right arm at the seam because frames 0 to 5 are the
  entry from idle. Trim the first 0.083 s and loop 0.083 to 0.667; that seam is a normal beat.

## Key poses in parent-axis space

- Idle frame 0: Torso {-14.7, -8.1, -6.0} p(0, 0.46, 0); Head {3.8, 13.5, -3.5}; Right Arm
  {-5.6, -93.5, 53.3} p(0.16, -0.07, -0.36); Left Arm {26.3, -92.4, 124.4} p(0.16, -0.62, -0.15);
  Right Leg {-42.3, -1.7, 27.6} p(0.09, 0.13, -0.55); Left Leg {-33.6, -0.2, -8.0} p(-0.24, 0.37, -1.0).
- Right punch load (frame 10): Torso {-23, -76, -3.5}; Head {18, 68, -4}; Right Arm {55, -99, 114}
  p(-0.12, -0.17, 0.36); Left Arm {70, 136, -140} p(0.04, -0.02, 0.25); Right Leg {1.5, -9, 9}
  p(0.22, 0.68, -0.63); Left Leg {-46, -5.5, -19} p(0.06, -0.13, -0.29).
- Right punch hit (frame 15): Torso {-15, 48, 12}; Head {15, -49, -7}; Right Arm same angles,
  p(0.03, -0.07, -0.26); Left Arm {58, 117, -119} p(0.10, -0.08, 0.50).
- Heavy punch hit (frame 20): Torso {-33, -41, -15}; Head {-37, -3, -17}; Right Arm {40, -97, 112}
  p(-0.05, -0.70, -0.28); Left Arm {62, 139, -144} p(0.06, 0.39, -0.77); Left Leg p(0.34, 1.13, -1.26).

## What changed in the practice because of these clips

- A stand's clips now come from its own animation set played raw through `Poser.fromSequence`;
  Claude authors only the pieces the set lacks (appear, vanish, the time stop) and re-targets its
  own poses to the set's idle frame so nothing pops on the hand-off.
- A rush loop is a torso engine at 6 beats a second with the head countering; fists ride.
- The user's ZA WARUDO is the show's two frames and nothing else: arms crossed in an X in a forward
  crouch, then flung up and out into a wide V with the chest out and the head back, held with a
  tremble and one jolt on the freeze. A quiet one-hand version and an arms-flung-then-lunge version
  were both rejected; the numbers that passed are in `SKILL.md` under ZA WARUDO.
- On the road roller the stand plays its own `Barrage` sequence raw with a procedural root leaned
  38 degrees down at the deck and a 12 Hz shiver (`WorldRollerBarrage`); the user holds the Jotaro
  point on top. The stand never gets an authored clip for it.
- Combo clips must chain end pose to start pose; author the last key of one as the first key of the next.
- Piston punches: freeze the arm angle on the strike frames, translate the part, let the torso reach.
- Stand limbs may translate 1 to 2 studs; humanoid limbs stay under 0.5.
- The user's body under the barrage holds still in the Jotaro point from his reference image (arm dead
  ahead at the enemy, the free forearm to the collar, chin down). Under the five hit chain he COPIES the
  stand's own clips (the show's stand user throws the punch and the stand's fist lands): the same
  sequence on his torso, head and arms with the arm offsets scaled 0.4 and the torso roll 0.45, authored
  planted legs, started three frames ahead. Authored command gestures read as "sitting back while the
  stand does the work" and were cut. `aim(tw, down)` and `solveFootY` are in `scripts/Clips.lua`.
