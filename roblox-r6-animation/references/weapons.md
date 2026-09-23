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
