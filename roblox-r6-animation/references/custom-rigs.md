# Custom creature rigs and other Motor6D rigs

Poser works on any Motor6D rig because it keys joints by `Part1.Name`; `Feet.lua` and `EditStrip.lua` are R6-only. `scripts/examples/quadruped/QuadRig.lua` (the leg solver) and `QuadClips.lua` (walk, sprint, pivot, crouch, get-up) are a tested example on a small four-legged creature with MainTorso, Neck, Head, Jaw, two ears, two front legs (`LeftArm`, `RightArm`) and ONE hind block that holds both hind feet. Copy and adapt the leg names and the floor.

## Contents

- Before any clip
- The foot solver
- Gait numbers that read well
- Baking loops
- Get-up from a physics ragdoll
- Momentum for a Humanoid creature
- Turning in place
- Limits seen
- Moving clips between two rigs of one model
- A crouch walk
- Legs that shrink instead of sliding into the body
- Movement lessons: camera turns, lean, terrain, preload
- Procedural creature movement on bigger rigs

## Before any clip

- Read every joint: `C0`, `C1`, the parent, the part size and the welded decoration parts. Compute the rest sole of each leg in root space and the floor height (on the example creature: floor at root y -1.642, front legs 1.544 from pivot to sole, hind block 1.399). Stock R6 numbers put a creature's feet in the wrong place.
- A Humanoid with RigType R6 and no R6 leg parts sits in Freefall. Set RigType R15 and HipHeight (root bottom to floor), and switch collision off on every part but the root, decorations included.
- Check each joint's `C0` rotation before you decode a stock R6 reference clip onto the rig. A decode gives each channel in the parent joint's axes. With identity `C0` rotations it maps 1:1 onto the rig's channels; otherwise decode with wraps read from the rig (`Poser.wrapsOf(rig)`, pipeline.md), not the stock R6 wraps.

## The foot solver

- Each leg is a rigid box. `solveLeg` aims the leg at a sole target with lift and side only, and slides it along its own axis up into the torso to shorten it (clamped by `tuck`). It never lengthens a leg.
- The corner raise runs on every solve, swing included: the sole centre goes up until the LOWEST corner of the leg group (decorations counted) is on the target height. Without it a swing foot near lift-off went 0.16 studs into the floor.
- A rigid box leg at 31 degrees touches with its heel corner and the sole centre sits 0.18 up, so the needed body drop is small (0.04 on the example walk). That is correct, not a bug.
- Stance feet move with the ground in root space: straight `(0, 0, v)`, turning `(-w z, 0, v + w x)` (rotation about the turn centre at `x = -v / w`). Swing is a Hermite whose end speeds equal the ground speed, so the foot lifts moving back and lands moving back, with no slide at either contact.
- The torso drop is found per frame for the front and hind girdles, then smoothed upward (the envelope never goes under the need), and applied as a drop plus a pitch. Authored torso keys ride on top.

## Gait numbers that read well

On the example creature:

| Clip | Cycle | Speed | Legs (phase, duty, swing height) |
| --- | --- | --- | --- |
| Walk | 0.40 s | 8 | fronts 0 / 0.5, duty 0.45, h 0.2; hind block 0.22, duty 0.42, h 0.18 |
| Sprint (half-bound) | 0.34 s | 20 | hind 0, duty 0.24, h 0.5, 0.3 forward; fronts 0.42 / 0.50, duty 0.24, h 0.55 |
| Pivot | 0.40 s | 8 at 240 deg/s | as the walk, turning flow; mirror for the other side |
| Crouch | 1.00 s | 1.3 | fronts 0 / 0.5, duty 0.7, h 0.16; hind 0.25, duty 0.68; body -0.45 |

A front swing of 0.32 read as a prance from the side; 0.2 read as a walk. Measured: walk rest 0%, contrast 1.2, feet within 0.004 of the floor, slide 0.13 to 0.69 studs/s.

## Baking loops

- Bake with a warm-up of one loop (`Poser.bake(clip, rig, 60, name, clip.length, clip.length)`) so springs (ears) are in their steady cycle at the seam.
- `life` on a loop samples noise on a circle of the loop length, so a baked loop has no jump at the wrap.
- Set `Weight = 0` on every pose whose joint the clip does not key (the Animation Editor does the same). A neck-only bite then layers over a walk instead of pinning the torso.

## Get-up from a physics ragdoll

- Start the clip from a pose close to a collapse: the torso low, the head down, the legs lying flat. Rigid legs whose feet sit forward of the leg cannot fold backward under the chest (the feet dug 0.46 studs into the floor); a sphinx pose with the front legs forward works. The example `GetUp`: head first, the front feet step back under the shoulders and the chest rises, then the hind block steps back under the hips, a small head shake, 1.13 s. Checks: rest 37%, contrast 3.9, feet within 0.08.
- The joints come back where the ragdoll left them only if code holds them: capture every Motor6D's Part0 and Part1 CFrame when the downed state clears, hold `C0:Inverse() * Part0:Inverse() * Part1 * C1` in PreSimulation (root joint against the current root CFrame) and lerp into the Animator's pose, which reads back in PreSimulation. Stand the root upright at hip height in `PreAnimation` on the owning client first, or the Humanoid's lift during the step pops the body 0.36 studs. Measured worst rendered frame 2.8 degrees and 0.053 studs. Without a clip, the get-up snaps in one frame.

## Momentum for a Humanoid creature

The Humanoid reaches any WalkSpeed at once and `Move(Vector3.zero)` brakes in one frame. Keep a speed variable, ramp it (16 up, 14 down, studs/s2 on the example, about 4.5 and 3.9 m/s2), keep calling `Move(heading)` while it coasts, cap it at the real speed plus 1 so a wall takes the momentum, and pick the gait clip from the speed, not from the keys. The clips then play through the coast at speed divided by their authored speed.

Scale the ramps with the creature's weight: about 4 s from rest to sprint for a heavy creature down to 0.8 s for a light one, and a slope limit by weight class of 40, 50 and 60 degrees, heavy to light. Weight-scaled ramps make each species read as its mass.

## Turning in place

A pivot that walks a tight arc reads as walking in a circle. The turn centre must be the animal: creep at 0.5 studs/s so AutoRotate still turns the body (radius about 0.16 studs), rotate the heading with angular momentum (accelerate at 720 deg/s2 toward `min(top, sqrt(2 * accel * remaining))`, so it eases in and stops on the heading, never instantly, because an instant turn hides the rotation), and bake the pivot clips with the ground flow at v 0.5 and the pivot rate so the feet step around the body. When the player asks for a direction behind while walking, brake harder than a coast (28 against 14 studs/s2), then pivot; a running animal never pivots and turns on its radius; the walking trigger angle is wider than the standing one (135 against 90 degrees). Real animal footage shows the head and front leading, the body curving behind, about 150 deg/s with eased starts and stops.

A turn in place never plays the walk clip: the walk's feet slide over the ground while the body turns. Play a pivot clip baked with the turning flow as above, or keep the idle playing and let the planted feet step one at a time in short arcs. The clip-free turn for big creatures is in the last section (a large biped turned 169 degrees in 3.6 s with 0.28 to 0.31 studs of planted slide in total).

## Limits seen

A 1.4 stud rigid hind block cannot fold under a sitting body: with the rump on the floor the block is 0.1 to 0.2 studs under it. The sit that fits pitches the torso 38 degrees and plants the block at an angle under the belly; its top shows through the rump.

## Moving clips between two rigs of one model

A model rigged again by its designer can keep the same parts at the same places but add a joint under the root, hang the limbs from it, turn the part frames 90 degrees and rename the parts. A clip keys joints by `Part1.Name` in joint space, so the old clips play nothing on the new rig. Check first that it is the same model: compare parts of equal size, not names (every welded decoration sat 0.0067 studs off its twin relative to the root on both rigs).

The exact transfer (`scripts/RigTransfer.lua`): for each frame, run forward kinematics on the old rig with the old poses, take each old part's root-space CFrame, multiply by the rest offset `oldRest^-1 * newRest` of the matching new part, then solve the new rig top down with `T = C0^-1 * parentRel^-1 * target * C1`. A new joint with no old twin follows the old part it replaces. Pivots may differ, so `T` may carry a translation; that is correct. Worst error 0.00001 studs in the math and 0.0007 on the played Animator pose. An overlay clip (Weight 0 on the parents) transfers with the parents at rest and only the keyed joints weighted. Raise the new root by the rest offset (HipHeight + 0.0067 on the example) so the feet stay on the floor. The authoring tools keep working on the old rig; author there and transfer.

Scripts find joints by name too. Before you call a replacement rig connected, confirm that every movement script runs on it: search the scripts for `WaitForChild` on joint and part names, and read the Output for infinite-yield warnings. Name the joints as the system expects. After one swap the clips still played while the procedural scripts waited forever for R6 joint names, so half of the movement system was off with no error.

## A crouch walk

At a crouch speed of 3 studs/s, a 0.7 s cycle with a 0.45 drop and duty 0.68 swung the legs -44 to +54 degrees and read as a crawl. The kept one: 0.6 s, drop 0.36, duty 0.66, lift 0.18 with `early` 0.7: legs -35 to +42, frozen 0, rest 1.8%, contrast 1.4, feet within 0.02 of the floor, planted slide 0.000. The head counters the torso sway on its own frames so the face stays level (a stalk). A game that pauses the clip (speed 0) when the body stops needs every frame to read as a crouch.

## Legs that shrink instead of sliding into the body

When the leg solver shortens a rigid leg by sliding it up its own axis (`tuck`, up to 0.7), the leg tops in a crouch or a get-up came 0.29 to 0.30 studs out of the back. Scaling the leg parts fixes it without re-posing:

- **Runtime** (every client, every creature, in the PreSimulation body layer): scale each leg part along its length about the hip pivot. Leg `Size.Y * s`, `Motor6D.C1.Position.Y * s`; each welded decoration keeps `C0 = (rel.Position with Y * s) * rel.Rotation`, `C1 = identity`, and scales its size on the axis that runs down the leg (`rel.Rotation:VectorToObjectSpace(Y)`). The scale comes from the playing tracks: per clip and per leg a key curve (smoothstep between keys) read at `track.TimePosition` and weighted by `track.WeightCurrent`, so it eases with the fades and observers match the owner. Write sizes only when the scale moves more than 0.002. Hold a ragdoll blend with the C1 captured at the blend start, so a shrinking leg stays on its hip.
- **Authoring** (`QuadRig`): `V.read(model, pivots)` takes the runtime pivot in each old leg's frame (the new rig's `C1` mapped through the rest offset); `geo.scale` is a number or `function(leg, t)`; the solver, the floor check, `V.feet` and the strips use the scaled leg (`V.legPoint`). `gait.tuck` and `gait.needTuck` limit the slide. Transfer the bake with `RigTransfer` as usual: it keeps each pivot frame, so the runtime scale hangs the short leg from the same point.
- **Numbers.** Crouch at scale 0.75 with a 0.15 slide limit kept the same body height (-0.35 to -0.38) and swing (-35 to +43); every leg corner 0.16 inside the body (was 0.30 out), feet within 0.013. A get-up needs a curve per leg: shrinking while a foot is still planted far away drops the body under the floor (-2.76 measured), so each leg shrinks only while it swings and grows back with the rising body (front 1 to 0.14 s, 0.75 at 0.34 to 0.45, 1 at 0.85; hind 1 to 0.47, 0.75 at 0.6, 1 at 0.76; slide limit 0.2): 0.15 inside the body (was 0.29 out), rest 38.9%, contrast 3.8.
- **Trap.** A KeyframeSequence registered with `RegisterKeyframeSequence` loads asynchronously; `StepAnimations` on a track whose `Length` is still 0 poses nothing. Wait for `Length > 0` before stepping, or every number is the rest pose.

## Movement lessons: camera turns, lean, terrain, preload

- Humanoid AutoRotate trails the move direction by about 0.12 s, and an eased turn with angular acceleration a trails a turning camera by w^2 / 2a (measured 16.7 degrees at 90 deg/s and 45 at 180). Feed the camera's own yaw step into the heading (capped at the turn rate), rotate the input by the same step (it is one frame stale), and set the root facing yourself with AutoRotate off: 0.00 degrees after.
- Lean into a turn from physics: `atan(speed * yawRate / gravity)`, times how far the speed is between walk and run, clamped (12 degrees); pivot about the floor under the root. Measured 9.0 degrees at 20 studs/s and 90 deg/s (the formula gives 9.1).
- Terrain alignment: tilt the body to the averaged hit normals of five rays (the centre and the front, back, left and right of the root), and skip rays that hit more than 0.35 of the leg reach from the centre hit; rotate the root joint about the floor point under the root. Pitch and roll from four ray heights tracked a 20 degree ramp (mean 21 degrees with the walk's own pitch on top) but on bigger rigs tilt from ray heights pitched the body 20 degrees nose-down at a plateau edge (next section).
- A clip's first play waits for its asset download (1.2 to 1.6 s measured); `ContentProvider:PreloadAsync` on the Animation objects at spawn removes it.

## Procedural creature movement on bigger rigs

A controller plus a body layer that writes `Motor6D.Transform` in PreSimulation over the existing clips (measured on 14 R6-style dinosaur rigs with no bones):

- **Lean** must scale with each species' own acceleration (`acc / accel`, 7 degrees forward, up to 10.5 back). A gravity-based lean (`atan(acc / g)`) gave a slow giant 4 degrees, too small to read, and a small fast one over 20.
- **Terrain tilt** from front and back ray heights tilted the body 20 degrees nose-down at a plateau edge (the front ray hit the floor 10 studs below). Average the hit normals of five rays instead, and skip rays more than 0.35 of the leg reach from the centre hit; quadrupeds keep the front and back height difference only inside that band.
- **Foot IK on slopes.** Solve the IK for the joint the foot turns about, not the top of the shin. Get the lift from the distance from that joint to the ground plane along the hit normal: `(max(c0, 0) + jointHeight - (joint - hit):Dot(n)) / n:Dot(up)`, with `c0` and `jointHeight` measured with the body tilt removed. Turn the planted foot by `tilt * bodyTilt:Inverse() * (r2 * r1):Inverse()`. Before this, both feet of a large biped on a 38 degree ramp floated 1.8 to 2.3 studs; after it, 0.01 to 0.34 (the idle clip floats 0.32 on flat ground).
- A box cast returns the uphill edge of the footprint on a slope, so its hit height is too high there; use the hit point and normal as a plane.
- **Too steep ahead.** Probe down at the front along the move direction; if the normal is steeper than the species' slope limit and higher than the floor, set the target speed to 0. Without it a large biped pushed into a 45 degree ramp and its speed swung between +12.9 and -4.5 for 5 s.
- **Deep water.** With the water line within 1 stud of the root centre, turn off the terrain tilt and the leg IK; otherwise the body tilts to the lake bed and the head goes under while the creature floats. A swim hold (BodyPosition at the current height) keeps a large root in the water region so it cannot climb the bank: release the hold whenever the water at the ground under the root is shallower than its standing height (with 0.5 stud hysteresis) and let it wade out.
- **Climbing with AlignOrientation.** Cast the wall ray along the stored wall normal, not along the root's up vector, because the align takes about 0.5 s to turn the root onto the wall. With the root's up vector the first ray hit the ground and the climb quit at once in a loop.
- **State changes.** Fade a change of state (walk to swim, ground to climb) over about 1 s across the leg IK, the body tilt and the clip set. Each layer holds a different pose in each state, so a switch in one frame read as too snappy.
- **Input handlers.** A handler must not call a function that yields: clear the button state first and `task.spawn` the ability, or the hold check reads the button as still held.
- **Turn in place without a clip.** The controller turns the root with no forward creep and the idle plays. In the body layer, while the root's flat speed is under 0.12 x walk, each foot's horizontal position and yaw lock in the world; the height comes every frame from the ground plane at the free foot position (locking the height stored a stale first-frame height: feet 1.4 studs off on a ramp). A foot steps when it is 0.1 x leg length away or 24 degrees behind the body: smoothstep travel, a sin arc of 0.07 x leg length (0.12 to 1.4 studs), 0.28 + 0.22 x weight-factor seconds, aimed ahead by 0.6 x the step time of the turn rate, and the foot turns to the new heading during the swing. The leg with the largest need goes first; a blocked leg makes the others wait, and a diagonal partner may step with it (taking the first clear leg let one diagonal pair step forever while the other pair dragged 1.4 studs). The body sways 0.035 x reach toward the planted side. Measured with an Edit-mode turn test (root turned at the game rate, idle frozen): a large biped 169 degrees in 3.6 s, 6 alternating steps, planted slide 0.28 to 0.31 studs in total; a light biped 182 degrees in 2 s, slide 0.1; a quadruped's pairs alternate, slide 0.24 to 0.85.
