# Hand-held weapons on R6

Learned 2026-09-22 building the Asta kit (Demon-Slayer greatsword, 8.1 studs long, grimoire draw and sheathe, a four-hit combo) for Lepy. The solver and the review tools are `scripts/WeaponRig.lua` and `scripts/WeaponStrip.lua`; the clips that use them are in the project folder `Desktop/roblox/Asta` (`AstaClips.lua`).

## Contents

- The grip is a joint with three axes
- Key the sword in world terms and solve the arm
- The arm's physical twist, not the twist channel
- Euler branches and the spline
- Measure the blade, not only the body
- Look at a swing as an onion skin
- Props that come out of other props
- Runtime cost
- Cinematic moves: speed curves, jumps and spins
- Weight: a heavy blade, two hands, a step every swing
- A combo that holds, a rest pose from a reference frame
- A fist holds the handle across the forearm

## The grip is a joint with three axes

R6 has no visible wrist: the arm block ends and the handle leaves the fist at any angle, and the part of the handle that would be inside the forearm hides inside the arm block. So weld the weapon with a Motor6D from the arm (`SwordGrip`, C0 at the fist `(0, -0.9, 0)` with a rotation that maps the handle's axes to the arm's, C1 at the grip point on the handle) and key it as a Poser joint (the joint name is the handle part's name). Give it all three rotations. The only real limit is the blade folding back up into the forearm (blade direction against the arm's up axis); penalise that, nothing else.

A first solver that limited the wrist to human ranges (45 degrees of deviation) missed the hand by 0.5 to 0.9 studs on most swing keys: the targets asked for a blade in line with the arm, which every R6 sword clip does.

## Key the sword in world terms and solve the arm

Write each key as a hand point and a blade direction (and optionally the direction the leading edge faces) in root space, and solve the arm (lift, twist, side) and the grip (three angles) with Nelder-Mead: `WeaponRig.solveSword(tp, hand, blade, edge, seed)`. Rules that made the solutions usable:

- A rigid arm cannot reach a point closer than its length (1.49 from the shoulder pivot to the fist), so match the hand by its direction from the shoulder and put the fist at arm's length; slide the arm in the socket (p) by at most 0.32 for the rest. Keep one exact point only where a contact needs it (the grab on the hilt).
- Continuity by the physical rotation from the previous key's arm and grip, not by channel differences. Several arm solutions look alike at a key and whip the sword around between them.
- A forehand contact reads with the fist front-right and the blade crossing forward-left and down; a backhand contact with the arm forward-left and the blade forward-right rising. A blade target nearly parallel to the arm is where a bad solution starts.
- The other hand on the handle is a reach solve to a point one stud up the handle (`solveReach`).

## The arm's physical twist, not the twist channel

The R6 shoulder pivots on the arm's inner top edge, so twisting the arm about its own length swings the whole block around that edge: at 180 degrees the arm sits inside the torso. Limit the physical twist (`WeaponRig.physTwist`: a swing-twist split against the same arm swung straight from pointing forward), soft 35 and hard 65 degrees. Limiting the Euler twist channel does not work: the same pose on the other Euler branch reads a small twist channel and a 180 degree physical twist.

## Euler branches and the spline

Poser splines each Euler channel. `{l, t, s}` and `{180 - l, t + 180, s + 180}` are the same rotation, so two keys that look alike can sit on different branches and the spline spins the joint the long way round between them. Measured: the sword tip dove 2.5 studs under the floor between two nearly identical grip keys. After all keys are made:

1. Rewrite every key on the branch nearest the previous key (`WeaponRig.nearestEuler`), and run the pass again after any key is inserted (a single pass before an insertion left one key on the old branch).
2. Between two arm or grip keys more than 45 degrees apart, insert a slerp midpoint so the spline takes the short way.

## Measure the blade, not only the body

`Poser.check` sees the body. For a weapon also sample per frame: the lowest blade tip height (under the floor means a flip or a bad key), the fastest blade turn per frame (a spike far over the strike frames means a spin), and the miss and blade error of every solved key. The Asta clips ended with tips at 0.15 or more above the floor and the fastest turns 42 to 73 degrees per frame, only on the strike frames.

## See the blade without Studio

`scripts/poser_offline.py` runs `WeaponRig.lua` (the solves run when the clip module loads; the sword draw's nine keys take about 3 s), and `scripts/r6_render.py` draws a `Sword` joint from the Right Arm with WeaponRig's grip (the fist at `(0, -0.9, 0)`, `GRIP_R`, the grip point 0.35 up the handle, the pommel at 1.81 and the tip at -6.33 in handle space: the Asta greatsword; change `PROPS` in the renderer for another weapon). Its tip matched `Rig.handle` to four decimals on a test pose. `--trail Sword` draws the tip one dot per frame (the arc and the spacing of a swing); `faults.py` checks the blade for one-frame turns over 90 degrees and for going under the floor.

`scripts/ExampleSword.lua` keys the studied noob's draw (study-moon-practice2.md) with `Rig.body` definitions and `Rig.nearestEuler` between keys: the hand on the hilt at the left hip with the blade back in the sheath, the draw out through a horizontal cut to the right (0.15 s), a glint hold, a raised stance drifting 0.2 s, the blade brought down in front into a low stance with the blade level. Three rounds: the first dropped from the raised to the low stance in 0.08 s and whipped both arms faster than the draw itself; the second gave that change 0.16 s and a breakdown with the tip coming down in front; the third drifted the low stance, which had moved 0.02 studs (still 8.8% to 1.8%). The reference cut the camera between the two stances; a game clip has to animate that change. The lowest tip is 0.12 above the floor at the first frame.

## Look at a swing as an onion skin

A strip of ghosts is too small to read a swing from. `_G.astaOnion(clip, bodies, t0, t1)` in `WeaponStrip.lua` puts one or two bodies on one root and a faded, colour-ramped copy of the sword every frame from t0 to t1; capture it from above (the arc), from the front three quarter (the height of the arc) and from behind (the player's view).

## Props that come out of other props

A hilt that rises out of a thin book hangs its guard and tang out of the bottom of the book on every frame before it is fully out. Grow it instead: scale the prop uniformly from 0 to 1 with its lower end pinned to the page, and grow the blade (a MeshPart scaled along its length only) so the tip stays on the page while the hand pulls. The fist then grips the grown hilt, so present the book lower (hip height) and further out.

A thrown weapon that goes back into a book: fly an anchored copy from the release frame (captured from the real handle), let it climb and turn over, drop point first, and shrink the blade with its tip pinned to the page.

## Runtime cost

- Solving every key at require time took 4.8 s. Memoize the solver by its inputs and bake the results into a module (`WeaponRig.dumpCache`, `AstaSolveCache`, 54 entries): a fresh build then takes 0.07 s with no misses. Round the fresh results the way the cache stores them, or the next key's lookup string differs.
- Resizing a part welded into a character every frame rebuilt the assembly: 25 to 30 ms frames for a quarter second. Draw a growing part on an anchored copy placed at the welded part's frame, and switch back when it stops changing.

## Cinematic moves: speed curves, jumps and spins

Learned 2026-09-22 when Lepy asked for the Asta moves to be "cinematic and dramatic" and allowed slowing and speeding for effect.

- **Speed curve, not rekeying.** A clip's `warp` (pipeline.md) plays its own clock faster or slower. What read well: the load at 0.75 to 0.85, the strike at 1.3 to 1.5, a hang of 0.3 to 0.45 for 0.03 to 0.05 clip seconds right after the contact, then 1.0 for the recovery. A hero hold in a draw at 0.35 for 0.12 clip seconds (0.34 s real). A strain on a grip at 0.55 with a tremble post layer (noise at 22 per second, 3 degrees on the arm, 1.4 on the torso) so the slow part is not a freeze. Keep hit, lock and chain times on the server from `Poser.realTime`, never from hand-typed seconds.
- **A jump without moving the root.** Lift the torso (`rise` in the body def) and lift both feet with an air curve that is at least the rise (0.3 to 0.4 more tucks the legs up into the hips). A lift curve behind the torso opens a hip gap on the takeoff frame (0.12 at 0.15 s); start the lift as the legs straighten. Hand targets in root space must rise with the body or the arm hangs below the shoulder and the blade tip goes under the floor (0.52 under at the apex). A split in the air (the front foot 0.45 forward, the back foot 0.75 back) reads as a leap; straight legs read as a float.
- **Spins past 360.** Key the torso twist straight through (-68, -12, 75, 165, 255, 325, 388) and keep the Euler branch fix off the torso and head, only on the arms and the grip. Key the blade in torso space (`swordLocal`) so it rides the spin, and give it an edge along the spin (edge = the spin axis crossed with the blade). The feet turn round the root with the torso while airborne; land with the chest 25 to 35 degrees past the hips, then pivot one foot at a time back to the stance. A blade held out level in torso space points down once the torso leans forward: at a 19 degree lean it went 1.67 under the floor; tilt it up by the lean.
- **Chains start where the last move held.** Start each combo clip from the previous hold pose and its feet (a step window of `{-0.01, 0}` puts a foot there at t = 0), and step the feet back inside the new clip.
- **Numbers after the pass.** Swings 28 to 47% rest in real time with contrast 3.3 to 5.8; the long cinematic draw and sheathe sit at 62 to 67% rest in real time because of their deliberate slow beats (still 3% or less, frozen 0). Locks stay near one second (the VFX skill's rule): the draw's movement cancel sits inside its hero hold at 0.96 s.

## Weight: a heavy blade, two hands, a step every swing

Learned 2026-09-22 (later) when Lepy said the combo moved "like a toy sword" and asked for its real weight, for both hands on the sword, and for a step forward on every attack.

- **What read as a toy.** One-handed whips, the blade changing direction as fast as the arm, a wrist flick back to the shoulder, and the body standing still under the swing. What reads as weight: the body loads first and leads (the torso turns 1 to 2 frames before the arms and 2 frames before the grip: `lag` of 0.01 to 0.03 on `Right Arm`, `Left Arm` and the grip on the load and top beats, none on the contact beat), a slow load (warp 0.7 to 0.85), a fast strike (1.45), a contact hang (0.4), a follow-through where the blade drags the body down (crouch 0.36 to 0.44) and the tip scrapes the floor, and a heave: the legs push up, the torso leans back and both hands lift the blade in front before it goes onto the shoulder. The chain starts from the drag, not from a reset.
- **Two hands on R6.** A fist reaches 1.49 studs from its shoulder (plus a 0.3 slide), the shoulders are 2 studs apart, and the second fist sits 1.05 up the handle toward the pommel. So in torso space a two-handed blade never points left of the body (the pommel fist would cross over), and a blade pointing straight forward puts the pommel fist inside the chest (`b.z` below -0.66). Key the blade in torso space (`swordLocal`), let a small Nelder-Mead place the grip (both fists within reach, both fists at least 0.62 in front of the torso centre, near a preferred spot in front of the chest; `two()` in the Asta clips), and let the torso twist turn the blade to the world direction. The left fist stayed within 0.16 of the handle on every key. The blade points forward-right in torso space at contact; a 30 to 55 degree twist of the torso to the left makes it point at the target.
- **The floor limits the angle.** With the fists about 2.2 studs above the floor, a 6.7 stud blade can point only about 17 degrees down before the tip reaches the floor. A torso lean adds its angle to the blade. So the contact blade is nearly level (world pitch -8 to -20 degrees), and the drag and the slam bite at most 0.3.
- **A step every swing without sliding (`travel` in the Asta clips).** The clip carries `root(t)`, a monotone cubic of studs travelled forward, and the owning client pushes the root with a plane `LinearVelocity` at `root'(t) * warp * speed` along the facing the move started with (0 during a hit stop or a stun). Every sole stays planted in the world while the root travels: in root space its z grows by the travel. Only inside its step windows (or an air window) does it float, and it lands where the rest of the travel carries it back onto its stance spot by the time it lifts again. The lead foot steps in on the load and strike, the rear foot snaps up after the hit, and the stance is whole again at the chain time. Measured travel per swing: 1.30, 1.15, 2.48 (the leap), 2.95 (the spin). A rigid R6 leg reaches about 1.1 studs back from the hip at a 0.35 crouch, so the root travels at most 0.8 before the rear foot lifts. The foot check must judge a planted sole in the world (root space minus the travel), or every planted sole reads as sliding.
- **Toes follow the hips.** A floating foot turns its toe late in the step (`u * u`) and the planted feet pivot with the hips on the load and the follow-through, or the leg twists 57 to 78 degrees against the torso. Keep the twist of a planted leg against the torso under about 45 degrees (the foot check prints it).
- **Measured after the pass.** Swings rest 43 to 47% (real time 48 to 54% with the contact hangs), contrast 2.7 to 4.3, stops 2.0 to 2.5 a second; soles within 0.06, slide 0.06 or less in the world, hip gap 0.09 or less, twist 45 or less; tips 0.05 to 0.16 above the floor except the slam's 0.32 bite.

## A combo that holds, a rest pose from a reference frame

Learned 2026-09-22 (late) from Lepy: "don't reset the m1's after every attack, leave the sword in the corresponding m1 position for like 1.5 second before pulling it so players can attack with varying rhythm, just like in boxing", "make the idle and walk anim adopt this pose" (a devil union frame of Asta: chest up, the big sword held out low to the side in the right hand), "sword is pointed the wrong way, blade needs to be facing up, like the sharp side facing up", and "try to get a full range of motion with the swings".

- **Held combo.** Each swing clip is swing, then a 1.5 s moving hold of its end pose, then a recovery to the rest. The hold has a middle breath key (the blade lifts a little, the torso rises) and an end key a touch further along the move, with staggered lags (torso -0.08, head +0.1, grip +0.12) so the joints never breathe together; life 0.9. The next swing starts from the hold pose, so a click anywhere in the hold chains cleanly. The combo window is 1.5 s after the chain time (the input and the server use the same number), and the finisher's cooldown counts from its chain time, not from the end of its hold. Measured over the whole clip the hold reads 28 to 55% still (under 12 deg/s) but never frozen; measure the swing part (up to the chain time) against the one-shot ranges. Rhythm test: clicks 1.4, 0.7 and 1.9 s apart all chained 1-2-3-4.
- **Rest pose from a frame.** Put the reference's arm and blade into the rest spec in torso space (hand out low to the side at arm's length, blade level past the hand) and let the idle and the walk ride it: the pose lives on the upper body, the legs keep their cycle. "Sharp side facing up" means the blade stands on its edge with the flat to the front: rest edge `(0, 1, 0)` in torso space; the Demon-Slayer blade is double edged and symmetric (checked on a render), so either edge may be up. The solver treats the edge as a soft preference (weight 10 against 40 for the blade), so log the edge error per key: the swings sat at 1 to 7 degrees, the rest at under 10.
- **Full range.** Lay the blade out behind for the load (torso space `(0.28, 0.3, 0.91)` with the torso twisted 56 right and leaning back 12) and carry the follow-through past the front (torso twisted 64 left). Pivot the feet with the hips on the same frames or the planted leg twists past 45 degrees: a pivot that ends after the hips (0.03 to 0.2 against a wind-up that peaks at 0.12) read 51 degrees; retimed to 0.02 to 0.12 it read 45.

## A fist holds the handle across the forearm

Learned 2026-09-22 (night, last) from Lepy: "the grip of the sword is really weird, no one holds a sword like that so it ends up look unnatural", worst on the rest pose; the whirlwind, where both arms were forward and the blade out to the side, "is correctly gripped". He also said "great, i love how you animate this session please take note": the method of this file (weight, two hands, planted steps, the held combo, full range, speed curves) is the one to keep.

- **The rule.** A real fist wraps across the handle, so the handle runs roughly square to the forearm (a blade to forearm angle of about 65 to 115 degrees). On a block R6 arm a handle more than about 25 degrees off square looks like it is run through the arm, because the block has no hand to hide the angle. The solver's free three-axis grip had only a fold-back limit, so poses like "arm down and out, blade level along the arm line" put the handle 45 degrees off.
- **In the solver.** Penalise `abs(handleUp . armUp) > 0.42` (60 times the excess squared) and log the angle per key (`gripErr`, `leftGripErr`). In the two-handed grip search, hold the right forearm within 20 degrees of square (`abs((rh - SR).Unit . b) <= 0.34`) and prefer the left within 30.
- **In the poses.** Pick the arm direction and the blade so they are square before solving: a rest with the blade level out to the side needs the arm hanging nearly straight down (15 degrees out gave 6 degrees off square), a blade to the sky needs the arm out level to the side (not straight up), a cut that ends across the front needs the blade pointing across the body, not along the forearm. Measured after: rest 6 degrees, combo swings 3 to 15, the worst keys (wind-ups behind the body, the draw's rip) 21 to 26.
- **The left fist.** With R6 shoulders 2 studs apart the left arm usually runs along the handle to reach the pommel end (55 to 77 degrees off square), and he read the whirlwind with the left at 77 as correct. The right fist is what reads.

## A combo flows from the end of the last swing

Learned 2026-09-22 (night, after the grip pass) from Lepy, with a capture of the old M1 3: "the way the sword is positioned here in m1 3 is kinda weird, don't do this pose do something that comes more natural from the end position of m1 2, this applies for all of the m1s, it should naturally flow from the end positions of the m1s, keep this in mind and take note for your skill."

- **The fault.** The old M1 2 ended with the blade high over the left shoulder and the old M1 3 started by carrying it back across the head to a load over the right shoulder before the jump. Each swing was designed as a good move on its own, from its own ideal load. In a chain, the first frames of the next swing then undo the end of the last one, and the detour reads as a weird pose even when every key is clean.
- **The rule.** Plan the chain as one path before any key. Key 0 of swing N+1 is swing N's hold pose (`Clips.M1[N].holdPose`: the same torso, head and `swordLocal`), and its first keys carry the blade on in the direction it was travelling or round on its own arc: never back through the guard, never across to a new load. The end of a swing is the load of the next one. If a wanted swing needs a load that the last swing does not end in, change the last swing's follow-through, not the start of the next one.
- **The Asta chain as one path.** M1 1 chops from the blade laid out behind the right shoulder down across the front and ends low left. M1 2 starts low left and rises straight up the diagonal to the blade vertical over the right shoulder. M1 3 starts there: the body sinks while the blade goes on back over the head, jumps, and drives the blade straight down in front (the chest turned so the blade points ahead). M1 4 starts from the slam's end. Check it in Play with a hold on the last swing's hold and on the next swing's early keys (0.1, 0.25 and the contact) from the side: the blade must keep travelling one way.
- **Measured after.** M1 2 and M1 3 grips 15 degrees off square or less, leg twist 46 or less, tips 0.07 and -0.25 (a slam bite); in a 60 fps step of every move the only single-frame peaks are the strike frames themselves (blade 60 to 86 degrees a frame with the torso and both arms at their peak on the same frame, then the contact hang).

## The twitch when a move hands back to the idle

Learned the same night: "the body like kind of twitches or like glitches after pulling out the sword and transitioning to idle, or when pulling back the sword and transitioning to idle, not sure, it just twitches you can check it out yourself."

- **Two causes, found in order.** First, snaps inside the clips: the sheathe flick turned the torso 36 degrees in one frame (two keys 0.04 apart after a slow warp hold, with opposing torso lags), and the draw's flourish started on the same frame as a leg step. Fixed by spacing the keys, dropping the opposing lags and easing the warp out of the hold. Second, the hand-over itself, which an Edit-mode step never shows: the Humanoid's Animator zeroes every `Motor6D.Transform` between PreAnimation and PreSimulation (a probe read the right shoulder at 13.6 degrees in PreAnimation and PreRender and 0.0 in PreSimulation). `Rig:play` captured the old pose from `motor.Transform`, and a move's `onDone` calls `play` from inside the step, so the idle blended from the default pose: every joint stopped for one frame and then jumped (the right arm 27.9 degrees, the torso 9.8) at the end of the draw, the sheathe and every M1 recovery. `Poser` now keeps the pose each rig last wrote (`rig.last`) and blends from that.
- **How to find it.** In Play, record each body part's CFrame relative to the root on every RenderStepped through the end of the move and one second of idle, turn it into degrees per 1/60 s and flag frames over 3 degrees and over 2.2 times both neighbours. Ignore a flag that follows a long frame (a hitch, not the animation). After the fix: no flag at any hand-over, draw, sheathe or M1.

## Overhead holds, a giant blade and a cutscene clip

Learned 2026-09-23 on the Asta ultimate (raise the sword two-handed, it grows to 384 studs, hold and aim, slam). He asked "asta hold's the handle of the sword above his head by the way, fix that", then, after the limit below, "Nevermind just keep it like that".

- **R6 overhead reach.** The fist grip point is 1.487 from the shoulder joint (joint at torso (1, 0.5), grip at arm offset (0.5, -1.4)). Its highest point is torso y 1.99, straight over the shoulder; the head top is 2.0. Over the head centre it reaches only y 1.6 (forehead), and in front of the face less. Two fists on a vertical handle above the head need the arms slid out of the shoulders. Say this before building an overhead pose, with the options (slide the arms up with a visible gap, the maximum reach at forehead height, or one hand). The accepted pose: fists in front of the forehead (arm direction (-0.8, 0.45, -0.4) from the right shoulder in root space), the blade vertical, the left fist 0.8 below on the handle (`lGrip = 0.8` in `Rig.body`, default 1.05); grips 10 to 21 degrees off square, left miss 0.24 or less.
- **Grow, hold, slam as three clips.** The grow is the cutscene (6.6 s, clip time = real time, events on the reference's shot changes) and its `onDone` plays a looping hold clip (4.2 s, a breath key and a strain tremble on the arms) that stays until the slam replaces it. The hold aims by turning the root toward the camera at a limited rate while the humanoid's AutoRotate is off.
- **A giant prop is not the welded weapon.** Resizing a part welded into the character rebuilds the assembly every frame, so the giant blade is an anchored clone placed at the hilt each frame from clip props (`props.giant` with `len`, `wide` curves and a `lag`), and the welded blade hides (`k = 0`). Low-pass its direction (0.3 s while it grows, 0.05 s in the slam) and clamp how far below level it may point, so a 2 degree wrist error does not swing a 384 stud tip 13 studs.
- **Turn the edge in the wind-up.** The blade held flat to the front looks wide from the front shots; for the slam the edge must lead (his earlier rule) and the side camera must see the flat, so the wind-up turns the edge from the side to forward over 0.28 s. On a giant blade this turn reads as a beat of its own.
