# Frieren study: the default style

Lepy (2026-09-26): "Frieren i think has the most beautiful and amazing animation i have ever seen ... I want you to be able to animate roblox rigs as well as frieren does their animation". His pick: Frieren is the default style for every new animation. The Moon Animator fight ([study-moon-practice2.md](study-moon-practice2.md)) stays the reference for the mechanics of fast fight beats (snap, hold, smears, staged anticipation).

This file is the measured study and its translation to R6. The effects half is in the VFX skill (`roblox-vfx-craft/references/study-frieren.md`).

## Contents

- Sources
- Measured drawing timing
- The style in six rules
- The cast beat, measured
- R6 translation
- Worked examples (`scripts/ExampleFrieren.lua`)
- What changes from the Moon target

## Sources

Clips from Sakugabooru (`https://www.sakugabooru.com/post.json?tags=sousou_no_frieren%20order:score`), 19 downloaded, sheeted frame by frame with `scripts/video/ref_sheets.py` and read at 2 fps overviews. The clips are not committed.

| Post | Tags that matter | Used for |
| --- | --- | --- |
| 238377 | Hanwen Ye, Toru Iwazawa, impact frames, beams | the Zoltraak finisher, beat by beat |
| 262048 | Kouki Fujimoto, fighting | the barrier cells forming where hits land |
| 241271, 241268 | Kouki Fujimoto, character acting | acting timing |
| 241863, 238332, 239509, 244153 | character acting | acting timing and holds |
| 244648 | Myoun, dancing | full-body performance timing |
| 248169, 251830 | Tatsuzou Nishita, Toru Iwazawa, character acting and fighting | action timing |
| 251534 | Vercreek | beams, debris, the effect-lit silhouettes |
| 249521 | Kouki Fujimoto | light lines, hex panels, cel smoke |

Articles (read through a page fetch; the quotes are as the fetch returned them):

- Sakuga Blog, "Resourcefulness Reigns Supreme - Frieren Production Notes 05-10": Toru Iwazawa's boards: "Weighty walk builds up tension" before the fight, the boards establish objective scale and then "progressively betray it as it explodes into a spectacular setpiece". On Kouki Fujimoto's episode 9 and his deadpan Fern: "All the information packed in mere loops of hair", cuts from "one explosion in one fight to fluttering hair in another", "Lighting effects visible across them both"; Akiko Takase's corrections add "Complex fabric" that shows how mannerisms move the clothes.
- Sakuga Blog, "Crafting A Tangible, Aging World - Frieren Production Notes 01-04".
- SHINSEIKI, Keiichiro Saito and Shoji Hata interview (2024-04-07): on Himmel's ring scene, "To expose those feelings in the anime adaptation seemed tasteless"; the pacing follows "the flow of the emotions, not for the sake of drama".
- Frieren Wiki, Episode 2: Frieren conjures a field of Himmel's favourite flowers for his statue; the flower field spell was Flamme's favourite.

## Measured drawing timing

`timing.py` (scratch): a frame is a new drawing when the mean grey difference to the previous frame is 1.2 or more (a cut at 40). Share of screen time on ones, twos, threes and held drawings of four frames or more, at 23.976 fps. Holds count only runs of 4+ frames.

| Clip | Kind | Ones | Twos | Threes | 4+ | Hold median | Hold p90 | Longest |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 241271 | acting | 12.8 | 41.9 | 5.2 | 40.1 | 0.33 s | 1.05 s | 1.08 s |
| 241268 | acting | 10.4 | 23.9 | 15.3 | 50.3 | 0.96 s | 4.68 s | 8.22 s |
| 241863 | acting | 24.6 | 8.6 | 31.2 | 35.5 | 0.38 s | 1.70 s | 1.84 s |
| 238332 | acting | 26.8 | 6.8 | 35.0 | 31.4 | 0.92 s | 2.20 s | 3.00 s |
| 239509 | acting | 4.6 | 32.6 | 0 | 62.8 | 1.23 s | 2.54 s | 6.34 s |
| 244153 | acting (night flight, the ring) | 21.3 | 7.3 | 30.1 | 41.4 | 0.50 s | 2.22 s | 5.84 s |
| 244648 | dance | 67.6 | 21.6 | 6.5 | 4.3 | | | |
| 248169 | action and acting | 70.0 | 14.8 | 4.1 | 11.1 | | | |
| 251830 | action | 40.5 | 9.9 | 17.4 | 32.2 | | | |

Camera moves and effects count as new drawings, so the ones in the action rows are partly camera. The acting rows are the point: 31 to 63% of acting screen time is a held drawing, a typical hold lasts 0.3 to 1.2 s, and the movement between holds is mostly on twos and threes. In a held drawing the hair and the effects often keep moving under the 1.2 threshold.

## The style in six rules

1. **Two registers.** Acting is calm: holds 31 to 63% of the time, movement on twos and threes. Action and dance are full-body and mostly on ones (the dance 67.6% ones). Pick the register per beat, not per clip.
2. **A calm body, busy secondary.** Faces and bodies hold while hair, cloth and effects move: in 244153 the close-up of Frieren (12 to 17.5 s) holds the face while the hair streams; in the Zoltraak finisher the eyes stay calm for 0.46 s while the hair lifts. Fern's feeling is "packed in mere loops of hair".
3. **Restraint.** "To expose those feelings ... seemed tasteless" and "the flow of the emotions, not for the sake of drama". One small action carries a beat: a glance, one hand, a turn of the head.
4. **The effect carries the power.** In the finisher the only body action is the staff raise (0.21 s); the circle, the firing line, the impact frames and the white-out do the rest. In the barrier clip (262048) the body does not react at all: the cells form where the hits land.
5. **Weight and scale in fights.** "Weighty walk builds up tension", then the scale is betrayed by a spectacular set piece.
6. **Light tells the beat.** Scenes take the spell's colour and characters drop to silhouettes (251534: blue-black figures under the red beam; violet and red scenes in episode 25); that part lives in the VFX study.

## The cast beat, measured

The Zoltraak finisher (238377, 23.976 fps):

| Time | Frames | Beat |
| --- | --- | --- |
| 55.09 to 55.46 s | 9 | calm close-up, eyes on the target, hair drifting |
| 55.50 to 55.59 s | 3 | the head turns a little as the wind rises and the hair whips |
| 55.59 to 55.80 s | 5 | wide: the staff up in front of the body, soft white light pillars rise round her |
| 55.88 to 56.55 s | 16 | the rune circle draws and spins up until it fills the frame |
| 56.42 to 56.55 s | 3 | a thin horizontal firing line across the circle, then a band, then a cross of lines |
| 56.59 s, 56.63 s | 1 + 1 | inverted impact frames: black splat, ring and cross on white; a white star glint on black |
| 56.67 to 56.71 s | 2 | a white burst in the circle's centre with a green chromatic fringe |
| 56.76 to about 60.5 s | | white-out, then the beam seen from the side with a green-black fringe |

The body moves in one place only (the staff raise, 5 drawings). Everything before it is attention (eyes, head, hair); everything after it is the effect.

## R6 translation

R6 has no face, no hair joints, no cloth and no elbows. What carries over:

- **Register per beat.** Acting, casting, idles and reactions use the calm register. Strikes, dodges, leaps and dance use the Moon mechanics (snap, hold, smears) with Frieren staging: the head and the eyes stay on the target, weight is shown before the hit, the scale builds then breaks.
- **One part acts, the rest holds.** Measured on the examples: the Zoltraak cast turns the casting arm 107 degrees while the torso turns 13 and the free arm 10 (the Cross turns them 88, 121 and 126). Keep the non-acting parts under about 20 degrees over the beat.
- **Attention first.** The head leads: it turns to the target 0.2 to 0.3 s before the hand moves (the finisher's head turn and hair whip come before the staff).
- **Gesture timing.** The acting part moves over 0.2 to 0.5 s (the staff raise 0.21 s; cupping hands 0.5 s), with spline keys into a moving hold. Do not snap a calm gesture: a peak of about 250 to 500 deg/s on the arm is the range the examples settled at.
- **Holds.** A held drawing becomes a moving hold with `life` 0.6 to 1.0 and a slow key drift (a hand rising 0.03 to 0.06 studs, 4 to 6 degrees over a second). Frozen stays 0% always (Lepy's "too much still frames" rule). In the calm register `still` may sit in the reference's hold share (the one-shot examples read 15 to 44%), a still run up to about 0.6 s (the reference's median hold), and a loop or a held pose may read 100% still as the Guard does.
- **The release is small.** At the moment of power the body gives at most 5 to 7 degrees (the Zoltraak arm kicks 7 up, the torso leans back 5 over 0.06 s, then settles). The effect is the hit.
- **Secondary goes to the effect layer.** Hair and cloth motion becomes updraft motes, wind streaks, trails and light that move while the body holds (the VFX study builds them). A carried prop can take a `follow` spring.
- **Fight checks that do not apply.** `faults.py` assumes a strike: in a calm cast "outruns the strike" (the gesture is faster than the release) and "small silhouette change" are expected. Keep the checks that still mean something: frozen, pops, twinning, feet, floor, the staging of the acting hand. When the acting hand is hidden from the player camera by nature (hands in front of the belly), the effect has to read over the shoulder; say so in the report.
- **Chains start in the calm stand.** A fade from the default stand into the stand slid the feet 0.12 in the runtime; start with `fade=0` or from a clip that ends in the stand.

## Worked examples (`scripts/ExampleFrieren.lua`)

Six clips on one calm stand (upright, feet 0.2 apart in depth, the right arm relaxed, the left forearm forward at 30 degrees so the arms never twin and the pose is never the default stand). Measured 2026-09-26 with `poser_offline.py`, `motion_check.js`, `feet_check.py` and `faults.py`:

| Clip | frozen% | still% | longest still | rest% | contrast | range torso, rArm, lArm | feet |
| --- | --- | --- | --- | --- | --- | --- | --- |
| CalmIdle (4 s loop) | 0 | 100 | loop | 0 | 1.4 | 4, 4, 4 | slide 0.01, gap 0.00 |
| Zoltraak (2.8 s) | 0 | 43.4 | 0.57 s | 49.7 | 10.7 | 13, 107, 10 | slide 0.01, gap 0.01 |
| BarrierRaise (0.7 s) | 0 | 44.2 | 0.32 s | 51.2 | 7.8 | 4, 62, 12 | slide 0.01, gap 0.00 |
| BarrierHold (3.2 s loop) | 0 | 100 | loop | 0 | 1.4 | 3, 2, 3 | slide 0.01, gap 0.00 |
| BarrierHit (0.45 s) | 0 | 21.4 | 0.10 s | 37.5 | 5.1 | 4, 6, 0 | slide 0.01, gap 0.00 |
| Flowers (3.6 s) | 0 | 15.2 | 0.40 s | 49.5 | 7.7 | 6, 119, 123 | slide 0.01, gap 0.01 |

- **Zoltraak** (events circle 0.65, fire 1.3, beam 1.43, beamEnd 2.05): the head lifts to the target at 0.25 and turns onto it by 0.55; the right arm starts slowly (0.4) and rises onto the aim in 0.22 s; a moving hold creeps forward 0.04 studs while the circle spins up (0.65 s, the finisher's 16 drawings); at the fire the arm kicks 7 degrees and the torso leans back 5 over 0.06 s; the hold carries the beam; the arm lowers over 0.75 s. `faults.py --strike 1.3` lists only the two fight checks named above.
- **Barrier** (raise 0.3): the reference shows no gesture, so the raise is small: the right hand comes forward and down (the staff line) in 0.18 s. The cells are the read. The hit reaction is 5 degrees on the hand and 3 on the torso, back in 0.45 s.
- **Flowers** (gather 0.75, release 1.9, bloom 2.25): the head looks down first (0.15), the hands cup in 0.5 s, the gather hold rises 4 degrees and 0.06 studs while the head follows the light, the release opens the hands outward over 0.4 s, the head lifts with the light, then turns across the field. Rounds: the first cup (44 and 56 degrees forward, 40 and 34 in) left the hands 1.67 apart at hip height; a search over arm angles (FK on the renderer) found 62/-80 and 68/92, 0.83 apart at the navel, which is the highest a straight R6 arm reaches the centre line; the gather drift first opened the hands to 1.15 until the drift also turned them in (4 and 10 degrees). The first release (open hands in front) twinned for 0.4 s; the release now spreads the arms outward with the left arriving 0.06 s later.
- Runtime (`poser_offline.py --runtime`): CalmIdle, BarrierRaise then BarrierHold, a BarrierHit at 2.0 back into BarrierHold, and CalmIdle again; CalmIdle, Zoltraak, CalmIdle, Flowers, CalmIdle. Feet slide 0.01, hip gap 0.00 to 0.01 across both chains.

Unverified: the clips have not been played in Studio or seen next to the effects; the box preview is not the game.

## What changes from the Moon target

- The Moon study stays the target for fight mechanics: 2 to 9 frame snaps, moving holds of 0.17 to 0.9 s, staged anticipation, smears on the fastest frames.
- The default for everything else is now calm: one acting part, attention first, gestures over 0.2 to 0.5 s, holds that drift, a small release, and the power in the effect.
- Lepy's measured complaint still binds both: frozen 0%, no dead holds, no neutral poses, no twinning, planted feet.
