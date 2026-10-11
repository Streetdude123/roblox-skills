# R6 geometry and contact

Use the inspected rig, not assumed stock offsets. The equations below derive the Poser convention from Motor6D transforms. They are not a claim that every R6 avatar has the same proportions or rest frames.

## Contents

- Rig and pose hierarchy
- Transform convention
- Direction and rotation checks
- Joint gaps (legs, arms and crosses)
- Scaled rigs
- Lean from the waist
- Centre of mass and balance
- Planted feet on rigid legs (torso height, walk and run legs, stance changes as steps)
- World-space contacts (surfaces and reach)
- Loops and world travel

## Rig and pose hierarchy

Inspect the six character motors connecting root to torso, torso to head, and torso to the four limbs. Extra prop or stand motors are additional joints. Resolve joints by their actual Part0/Part1 connections.

For a standard R6 sequence, create real KeyframeSequence, Keyframe, and Pose instances. The pose mapping is:

| Pose | Parent pose | Driven connection |
| --- | --- | --- |
| HumanoidRootPart | Keyframe | Structural root |
| Torso | HumanoidRootPart | RootJoint into Torso |
| Head | Torso | Neck into Head |
| Right Arm | Torso | Right Shoulder into Right Arm |
| Left Arm | Torso | Left Shoulder into Left Arm |
| Right Leg | Torso | Right Hip into Right Leg |
| Left Leg | Torso | Left Hip into Left Leg |

Pose names identify parts, not motor names. Extend the hierarchy for props according to their motor chain. Poser indexes motors by Part1.Name; duplicate names in the same attached model are ambiguous. Scope each attachment to a model with unique driven part names.

The legs hang from the Torso pose. An upper-body clip that keys the Torso rotation therefore turns the walking legs with it: a 38 degree slash twist turned the walk. Keep the torso twist of such a clip as small as the move allows, and tell the requester that the twist turns the legs.

## Transform convention

For a joint with a rootward Part0, calculate the child frame as:

```text
W1 = W0 * C0 * T * inverse(C1)
```

Here W0 and W1 are parent and child world CFrames, and T is Motor6D.Transform. Evaluate from the fixed root through the inspected chain. A Pose.CFrame supplies T; it is not a child world CFrame or a replacement C0.

Poser authors a parent-axis offset at the joint pivot:

```lua
local p = Vector3.new(px, py, pz)
local a = CFrame.Angles(0, 0, math.rad(side))
    * CFrame.Angles(math.rad(lift), 0, 0)
    * CFrame.Angles(0, math.rad(twist), 0)
local authoredPose = CFrame.new(p) * a
local r0 = motor.C0.Rotation
local transform = r0:Inverse() * authoredPose * r0
```

The rotation order is Z, X, Y in the product. Multiplication is not commutative. Keep this convention consistent when exporting, decoding, and constructing contacts. Leave C0 and C1 as the rig's rest offsets during ordinary animation.

For a standard upright rest pose: positive lift swings a limb forward, lifts the gaze, and leans the torso backward. Negative parent-space Z is forward; positive Y is up. Positive torso twist turns toward the character's left. Verify these signs with the actual rest frames before reusing stock values.

## Direction and rotation checks

For a stock limb whose local down axis is its hand direction, the authored rotation gives:

```text
d = (cos(lift) * sin(side), -cos(lift) * cos(side), -sin(lift))
```

Use radians in trigonometric functions. This is an XYZ vector: its negative Z component points forward. Twist around the original local down axis does not change this vector, but it does change the block face and a weapon's orientation.

Solve an arm from the direction you want; do not key it by feel. For a wanted torso-frame direction `(dx, dy, dz)`, `lift = asin(-dz)` and `side = atan2(dx, -dy)`. With the Z, X, Y order, `side` on an arm that points forward is only a roll, so a guard arm keyed by feel pointed straight ahead until it was solved this way. Read the result in root space after the torso twist: an arm keyed sideways pointed 0.80 forward (a unit-vector component) under a 16 degree twist. When you pick a rotation sign by forward kinematics, check the forward and down components together. Two rotations gave the same hand height, and a check on height alone picked the one that swung the arms back over the head.

For a modified rig or an offset grip, derive the endpoint using W1 instead. Inspect `W1:PointToWorldSpace(contactLocal)` and the actual prop frame. Do not apply the stock hand formula to an arbitrary C1.

Compare rotations as CFrames or matrices. Euler angles are non-unique; a 100-degree lift can decompose to another angle triple with the same orientation. Near gimbal configurations, edit the intended orientation and inspect its endpoint rather than changing a suspicious Euler value in isolation.

Key a raised arm (lift over 90 degrees) in the up form: `lift = 180 - asin(-dz)`, `side = atan2(-dx, dy)`. Both forms describe one rotation, because `(l, t, s)` equals `(180 - l, t + 180, s + 180)`, but the spline interpolates each channel, so keys on mixed forms turn the long way. After all keys exist, rewrite each key onto the branch nearest the previous key, and run that pass again after any key is inserted. Write a gimbal pose on its neighbours' branch (`{90, 88, -88}`, not `{90, 0, 0}`). Add a slerp midpoint between two keys more than 45 degrees apart. Where a flipped arm and a changing grip interpolate together, add a solved breakdown with the grip slerped halfway. Mixed branches swung an arm 200 degrees between a guard and a strike, dove a blade tip 2.5 studs under the floor, and snapped a variant 61 degrees in one frame. weapons.md, "Euler branches and the spline", has the passes (`WeaponRig.nearestEuler`).

Limit the arm's physical twist, not its twist channel: soft 35 and hard 65 degrees, measured by a swing-twist split against the same arm swung straight from pointing forward (`WeaponRig.physTwist`). The shoulder pivots on the arm's inner edge, so a twist about the arm's length swings the whole block round that edge. A limit on the channel fails because another Euler branch shows a small channel value for a 180 degree physical twist.

A short-arc rotation difference between matrices R and S is `acos(clamp((trace(transpose(R) * S) - 1) / 2, -1, 1))`. The decode checker uses this measurement. It cannot recover a full spin lost between sparsely sampled keys.

## Joint gaps

A pose translation `p` on a limb moves the whole part away from its joint. The R6 hip C0 sits at the torso's bottom corner `(+-1, -1, 0)` and C1 at the leg's top corner `(+-0.5, 1, 0)`, so with `p = 0` those two points coincide whatever the rotation, and any `p` separates them by `|p|`. Daylight shows when the leg goes below or sideways: measure it in torso space as `c = torso.CFrame:PointToObjectSpace((leg.CFrame * CFrame.new(+-0.5, 1, 0)).Position)`, `below = max(0, -1 - c.Y)`, `slide = sqrt((c.X -+ 1)^2 + c.Z^2)`. The leg must touch the torso on every frame (SKILL.md, Feet rule). It may slide sideways, forward or back while at least half of its top face stays under the torso's bottom face; it may never hang below the torso with daylight between them. A positive `p.Y` pushes the leg up inside the torso and is hidden. Move a planted foot by sliding the leg under the torso (sideways, forward or back, with at least half of its top face under the torso) or up into it, and tilt it only for what a slide cannot cover (SKILL.md, feet rule). Never translate it down: a 0.3 stud drop for a plant (with a 0.5 stud forward slide) opened a gap a reviewer saw at once. The older method, from before the feet rule, swung the hip instead: a forward offset `z` becomes `lift += deg(asin(-z / 2))`, a sideways offset `x` becomes `side += deg(asin(x / 2))`, and the foot rises `2 (1 - cos)` (0.05 at 13 degrees), which a torso drop of the same amount plants again. `scripts/examples/stand-combat/Clips.lua` applies this as `attachLegs` to every clip after the keys are written, so authors may still think in foot offsets. Measured after a reviewer circled a hip gap: seven clips went from 0.30 to 0.65 of daylight to 0.00 to 0.12.

Measure the limb gaps on every clip before you change anything: idles, runs, landings, the output of a foot solver, and pack clips used as is. A first measure found legs out of their hips in an idle, a run and a landing; a solver that placed only the sole point pulled a leg 3.3 studs out of its hip on a kick; a pack's jump left a leg 0.54 studs off the body. On a pack clip used as is, shorten the leg slides until every gap is 0.10 studs or less. A leg you author or solve must touch the torso.

An arm follows the same contact rule: it may leave its shoulder, but it must touch the torso on every frame, above all when it holds a prop. Measure the arm-to-torso gap per frame before the first strip. Close a gap by sliding the arm onto the torso side, and smooth that slide over about 7 frames so it does not pop. A sword carry 0.22 studs off the torso read as disconnected; gaps of 0.069 and 0.257 studs closed with slides of 0.11 and 0.29 studs.

An arm has the same trap in a cross. The shoulder pivot sits on the arm's inner face half a stud below its top, so an arm that points across the body (a two-handed slash ending on the far side) swings its top face outward off the torso. Measured on a two-handed slash release: 0.215 of daylight during the recovery from the cross, not on the key itself, because the spline holds the crossed direction while the slide key already fades. Fix it as a post pass after every other change: put the arm's top-face points (3 x 3 grid) into torso space with `CFrame.new(C0.p) * P * C0.rotation * C1:Inverse()`, find the point nearest the torso box, and slide the arm pose toward the box by the excess over 0.05 (a `stick` post pass). All seven clips of that set then measured 0.05 or less.

An arm that crosses at chest or neck height must also pass under the chin. Measure it against the head box as well as the torso box, and pitch the arm down at the cross end: carried 52 degrees across at neck height, an arm went 0.35 studs into the chest and 0.05 into the chin. For a forearm-bar block, put the arm's centre about 0.5 studs in front of the face. A 1-stud arm needs that room: a bar clipped the face until it slid 0.6 studs forward.

## Scaled rigs

`Feet.lua` and the numbers above assume the stock 1 x 2 x 1 limbs. For a scaled R6 rig (one boss rig measured 1.109) scale every offset by `S = Torso.Size.Y / 2`: the hip `(+-S, -S, 0)`, the leg vector `(-+0.5 S, -2 S, 0)`, the sole corners `+-0.5 S`, the floor `-3 S`. Read the scale from the rig, never type 1.109.

## Lean from the waist

The torso turns about its own centre, so a pitch or a roll also moves the hips: a 15 degree forward lean swings the hip centre 0.26 back and a roll swings it sideways. A real body bends at the hips. Add the offset that keeps the hip centre where the key's translation puts it: for a pose rotation R, `p += (0, -1, 0) - R * (0, -1, 0)`, which for lift l and side s is `(-sin s cos l, -1 + cos s cos l, sin l)` (twist does not move the hip centre). `waist` and the torso key helper `T` in `scripts/ExampleClips.lua` do this. Without it the feet of the example cross slid and the lead leg needed 0.47 more reach.

## Centre of mass and balance

A viewer reads an R6 character as a human body, so weigh its parts with human segment fractions, not by their block volume. Winter's table gives Head 0.081, Torso 0.497, each Arm 0.050, each Leg 0.161, each at its own segment centre; on the stock rig those centres sit at the head part centre, at `(0, -0.25, 0)` in the torso (halfway between the hip line and the shoulder joints), at `(0, -0.295, 0)` in each arm and at `(0, 0.106, 0)` in each leg (body-mechanics.md has the formula and its sources). The standing COM sits 0.64 below the torso centre and 2.36 above the floor, in the lower half of the torso where a pelvis would be. Compute it per frame from the evaluated part CFrames (forward kinematics or the live parts). Scale every offset by `S = Torso.Size.Y / 2` on a scaled rig.

- **Support area.** The floor box around the planted soles (each leg's bottom face is 1 x 1 studs). In a held pose or a slow move, keep the COM's floor projection inside it. Over the edge reads as falling: allow it only when a step, a push, a hit or a jump explains it, and put the next support under the COM. Check from the side and from the front; a pose that balances from one camera can fall from another. The Humanoid never falls, so the animation alone sells balance.
- **Rotation about the COM.** RootJoint pivots at the torso centre. A flip, spin or big lean keyed there turns the body about a point 0.64 above the standing COM (the gap changes as the limbs move), the most common beginner error in rotations. Keep the COM on its path by adding the translation `p += c - R * c`, with `c` the COM in torso space at that frame and `R` the torso rotation; it is the waist correction with the COM as the pivot.
- **Flight.** When a clip moves the body through the air itself, move the COM, not the torso, on the ballistic path: constant horizontal speed, a parabola in height. Match the game's gravity (`workspace.Gravity`, 196.2 studs/s^2 by default) unless the style asks for hang time; when the Humanoid jumps by physics, the clip adds no vertical arc of its own. The spin rate stays constant in the air, rises while the limbs tuck in and falls while they spread.
- **Speed needs support.** The COM gains speed only while a planted foot pushes (a compressed back leg released like a spring, or a lean that falls into a step) and loses it only through a braced leg planted ahead of it with the torso leaning back and sinking.
- **Weight shows in a spread brace, not in leg angle.** A crouch alone does not read as weight on R6. A kneeless leg slides up into the torso, so a 0.46 stud drop with the feet under the hips left both legs within 2 to 16 degrees of vertical, and the body looked like it stood normally. Brace one foot forward and out, slide its leg toward the torso's edge so the sole stays flat (tilt about 8 degrees or less, feet rule), and put the weight on the other leg with the torso drop and lean. A 29 degree slanted brace (0.45 studs forward and 0.25 out) once read as load but predates the feet rule; tilt a brace further only for what a slide cannot cover.

## Planted feet on rigid legs

`scripts/Feet.lua` holds the planted-foot solvers, run after the torso is final (springs included). `Feet.flat`, the default, stands each leg straight up on its floor target with a flat sole and slides it under or into the torso (pipeline.md, "Planted feet"). `Feet.post`, the older solver, aims the leg from its hip, puts the lowest corner on the floor, slides the leg only along the torso's up axis and turns a heel or toe pivot about the hip-to-sole line. Turning the torso turns the hips around the feet, so a big turn needs a lower torso: in the example a 56 degree turn from guard to contact kept every hip gap at 0 only with a 0.36 drop (found by a search with `Feet.gap`). The older helpers below predate both.

Measure the floor contact at the LOWEST SOLE CORNER, not the sole centre. The corner of a swung rigid leg sits `2 cos a + 0.5 sin a` below the hip for a combined swing `a = acos(cos lift * cos side)`: a 30 degree swing lifts the leg centre 0.27 but the heel corner only 0.02, a 14 degree swing puts the corner 0.06 BELOW the rest floor, and 45 degrees lifts it 0.23. So a box leg swung 31 degrees needs the hip only about 0.04 studs lower to plant its corner; that small drop is correct, not a bug. Larger swings force a real drop: straight legs swung to 42 degrees in a run dropped the body up to 0.47 studs. Plan that drop with the pose. Never push a planted leg down to keep its sole on the floor. `legDepth` in `scripts/examples/stand-combat/Clips.lua` gives the corner depth below the hip (`depth - 2` below the rest floor), with the torso lean added to the leg angle because the legs hang from the torso. "Walk and run legs" below says how a walk sets its body height.

Under a torso that twists, leans and rolls (a hit copied from a floating companion's clip), keep `Feet.flat` and give each foot a target that turns with the torso's heading. The stand-combat example's older `legIK` / `dropFor` aims each leg from its hip instead (like `Feet.post`), and its lessons: the target turns with the torso's heading (the feet pivot with the hips; with fixed targets a 124 degree whip put the targets out of reach and dropped the torso 2.4 studs), the torso drops only as far as the farther target needs, a too-close target is pushed out along the floor, and, for an aimed leg, two passes fix the sole: aim the centre, measure the real lowest corner (twist and roll change which corner it is), aim again with the error removed. `legIK` / `dropFor` in `scripts/examples/stand-combat/Clips.lua`; measured on a copied combo chain: 0.00 hip gap, planted corners -0.05..+0.05, a 0.22 to 0.73 crouch.

Set the torso height so every planted leg reaches and touches:

- **A rising torso.** Vertical legs on flat soles lose contact when the torso lifts. Where the torso rises above its rest height or leans back, drop it 0.05 to 0.13 studs on those frames so the legs still touch. At a planted strike's release, dip the torso slightly instead of rising: a 0.12 stud dip kept the hips closed. To raise a planted leg into the torso, drop the torso by the same amount: legs moved 0.15 studs up stayed planted only with the torso 0.15 lower.
- **Crouch depth.** Keep the drop of an upright deep crouch near 0.75 to 0.86 studs: a 1.15 stud drop pushed the legs 1.5 studs into the torso and read stubby. A crouch with one hand on the floor takes about 1.3 studs of drop with a 60 degree lean and the back foot behind (z about 0.75 studs); without the lean and the back foot it read as crawling. Find a seated or crouched torso height by bisection on `Feet.gap` until both legs just reach; bisection gives the exact drop that closes the gap.
- **Targets within reach through blends.** Keep every planted target within leg reach of its hip, also during a blend. At takeoff and landing, move the target up under the hip: targets out of reach flipped legs 75 to 84 degrees, and lifting them 1.0 to 1.2 studs fixed it. Blend a leg from planted to free as a rotation (`planted:Lerp(free, w)`), not by moving its target: a flat leg has no toe heading, and a target blend spun its yaw from -174 to 117 degrees. When a leg passes vertical under a low hip, slide it up into the torso by the dip instead of cutting the blend: the vertical pass pushed a sole 0.34 studs through the floor, and cutting the blend weight jumped the leg 88 degrees.

### Walk and run legs

- **A straight floor track.** Solve a walk's stance foot to a straight floor track: planted for the duty fraction with the sole sliding back at exactly the root speed, then a smooth swing (`gaitFoot` in `scripts/examples/armored-warrior/WarriorClips.lua`). Planted means the lowest corner within 0.005 studs of the floor. Never build a walk from pendulum legs: they slipped 1.2 to 1.6 studs/s at their own speed. Planted, a walk slipped 0.06 studs/s in Play, and a walk built on the track measured 0 slide and 0 hip gap.
- **The body's own bob.** Give the body its own smooth bob, taken from the reference's bob curve or built from a few harmonics, and shift it to sit under the leg-reach limit. Let the stance leg slide up into the torso where the curve is lower than its reach. At the very end of stance the leg may sit up to 0.1 stud below its hip: it is swung back there, so one edge of its top face rises `0.5 sin a` and still touches the torso. Never set the height frame by frame from the stance leg with a hard max or a clamp. A hard max of the two leg depths put a corner in the height curve at every leg crossing and snapped the body up every step (420 studs/s^2); a smooth max gave 44 to 48 studs/s^2. A clamp held the torso flat at the reach limit for 16 frames, then dropped it 0.12 studs in 3 frames, a mechanical clunk. The reference's smooth 0.25 stud wave, shifted under the reach, read human. The stand-combat example still takes the hard max of its two `legDepth` values; treat that as the older method.
- **Keep the swing slide.** The swing leg's slide up into the hip is the R6 knee cue: 0.37 studs in a reference walk, 0.7 to 0.95 studs in a run. A swing leg kept at full length reads as one block. A replanting solver must keep that slide. When you re-solve the legs after an upper-body change, fix them in the world instead of solving their slides away.
- **Stride costs height.** At a fixed speed a rigid leg pays for a longer step or more planted frames with a lower torso. At 8 studs/s on 2.4 stud legs, a 48-frame cycle put the torso 0.44 to 0.56 studs below rest and a 52-frame cycle 0.60 to 0.72 studs; in the 52-frame cycle, 27 planted frames held the torso at -0.45 studs and 28 dropped it to -0.60 studs. Work out the stance height before you promise a slower cadence, a longer stride or a higher duty, and ask the requester what to give up when the drop becomes a crouch.
- **Dash contacts.** A leg spans about 2.5 studs of travel (1.26 studs on each side of the hip at a 0.45 stud crouch), so at 55 studs/s a foot touches for about 0.04 s, only 2 to 3 frames. A leg that leaves a planted hold carries the foot's speed into the swing (weight `(1 - s)^2`), with the carried travel capped near 0.4 studs: without the carry the foot jerks, and without the cap a leg flipped 150 degrees. Key a skid as two equal root-space foot keys, so the sole stays fixed to the body and slides in the world; a world-planted foot under a sliding root stretches the leg.
- **Measure live.** Measure a live walk with a ray under each lowest corner every frame. A floor height read once at the start of a walk sample reported a 1.0 stud float that was the SpawnLocation under the path.

### Stance changes as steps

A keyed stance change slides the feet: clips that keyed the legs as hip angles slid 1.1 to 4.6 studs per clip while "planted". Never key a stance change as leg angles. Give each foot a target track instead: planted positions in root space and steps between them, then solve both legs every frame and drop the torso only as far as the farther leg needs (until each leg touches the torso with at least half its top face under it: torso contact 0 or more, top off about 50% or less). Slides fell to 0.07 or less. Move one foot at a time, each in its own window, offset about 0.1 s from the other foot's window: one ramp that moved both feet back to stance slid 0.62 and 0.33 studs, and separate windows gave 0.05. Ease the travel across the floor (smoothstep) and lift the foot by `sqrt(sin(pi u)) * height`, so the sole leaves the floor before it moves; a plain `sin(pi u)` lift scrapes. Lift at least 0.12 studs, about 0.2 for a return step, and 0.2 to 0.32 for a heavy body: a 0.06 stud lift read as a drag (1.12 studs of slide in the foot check). Plant the feet 0.02 to 0.03 s after the root travel stops; a foot planted during the travel slides with the last of it. The twist must agree with the step: a left foot that lunges forward needs the torso turned right so the left hip comes forward; with the torso turned left the left hip went back and up, the drop needed to reach sank the body and pushed the back leg 1.31 studs up into the torso. Check the leg slide-up in the baked sequence (the hip pose Position.Y); in an ordinary stance over about 0.6 studs a planted leg reads short. A deliberate deep crouch may go to about 0.86 ("Crouch depth"); over about 1 it reads stubby. A run's swing leg may slide further (up to 0.95 studs, "Keep the swing slide" above).

- **Toes and pivots.** Turn a floating foot's toe late in the step (`u * u`). Pivot the planted feet with the hips, and finish the pivot no later than the hips: without pivots a planted leg twisted 57 to 78 degrees against the torso; a pivot that ended after the hips read 51, and retimed it read 45. A 24 degree pivot of the back foot cut a 58 degree twist to 38. Start a return step before the torso unwinds: a late return step left a 58 degree twist, and starting it 0.14 s earlier fixed it. weapons.md, "Toes follow the hips", has the timing.
- **Lunges.** In a lunge, keep the planted back sole fixed and turn only its yaw: a back foot that followed the stance ramp slid 0.15 studs. In a long lunge, step or drag the back foot. A leg reaches about 1.1 studs back from its hip at a 0.35 stud crouch; a back foot left behind through a 0.8 stud lunge overstretched the leg, which flipped 177 degrees and dropped the body until a held blade dug 2.58 studs into the floor. A wider stance lowers the solved torso and whatever it holds, so recheck the crouch and any held tip after every change of stance width.

## World-space contacts

Choose an actual local support point. For the sole center of a rectangular leg use `(0, -Size.Y / 2, 0)` in that part's coordinates. Also test the four bottom corners for penetration. For a hand or weapon grip use its inspected attachment or local offset.

Find a surface to stand on or strike with a grid of downward rays in the mesh's own frame, not with its bounding box. On a large vehicle mesh the box top sat 4.3 studs above the centre while the deck was at 1.2, so a character placed on the box floated a body height above the deck; a 5 x 8 grid of rays found the deck.

For a strike that must hit an object, measure the limb's reach at full extension, place the root so the fist lands slightly inside the surface, and check the lowest fist point live. A rush that reaches 2.7 studs at full extension, with the root 2.45 studs above and 1.1 behind the landing point, drove the fists 0.3 studs into the surface and read as hitting; leaned beside the target, the same fists swung in the air. Check the reach before you plan any contact: the end of a straight arm reaches about 1.83 studs from the shoulder, so a hand cannot touch the floor from an ordinary crouch on the feet with the shoulders 2.1 to 2.35 studs above it, and a hand plant planned from such a crouch could not be built. A hand plant needs the deep, leaned crouch in "Planted feet on rigid legs" (Crouch depth). SKILL.md, "Overhead reach", gives the upper limit.

Record the target world point when contact begins. During a plant, compare the evaluated contact against that fixed target. A moving platform needs a target stored in platform space and transformed each sample. A rolling foot needs an explicitly changing support point rather than an accidental slide.

To preserve one point at a chosen authored rotation A, solve the Poser translation p. Starting from the joint equation:

```text
B = W0 * C0 * inverse(R0)
D = R0 * inverse(C1)
contactWorld = B * (translation(p) * A) * D * contactLocal
p = inverse(B) * targetWorld - A * (D * contactLocal)
```

In the last line the first term is a point transform and the second is a rotation of a vector. An equivalent Luau expression is:

```lua
local r0 = motor.C0.Rotation
local b = parentWorld * motor.C0 * r0:Inverse()
local d = r0 * motor.C1:Inverse()
local p = b:PointToObjectSpace(targetWorld)
    - authoredRotation:VectorToWorldSpace(d:PointToWorldSpace(contactLocal))
```

Feed p back into the parent-axis pose. Use the parent's evaluated frame at that time. This solves one positional contact for a chosen rotation; it is not a knee IK solver and does not constrain orientation or other contacts.

If the result opens a visible hip or shoulder gap, revise torso position, stance, target, or rotation. Do not accept arbitrary limb displacement just because the point matches. R6 cannot simultaneously keep every corner of a flat foot on the floor and give that rigid leg arbitrary pitch. Choose a plausible pivot or revise the pose.

The older `legY` and `solveFootY` helpers correct height under their specific assumptions. Neither fixes horizontal drift, all sole corners, different proportions, or moving platforms. Do not describe their outputs as fully planted without measuring them.

## Loops and world travel

Separate three frames of reference: authored joint pose, evaluated character pose, and root motion through the world. Keep world travel on the HumanoidRootPart, driven by the controller; the clip poses the joints only. A visually translated Torso does not move the gameplay root or the server's hitbox model.

For in-place locomotion with cycle distance D, `phase += 2*pi*distanceTraveled/D` is a useful clock. Check the actual foot path against root travel during stance. Play a directional locomotion set (forward, back, strafes, walk and run) on one normalized phase, and offset each clip so its right foot is lowest at phase 0. Unaligned clips scissor when blended; aligned, the diagonal and walk-to-run blends kept their steps. The bundled locomotion examples use the passing pose as phase 0 instead; never mix two phase meanings in one blended set.

For an ordinary loop, match the boundary pose and compare incoming and outgoing local velocity. Inspect angular motion as well as translation. A closed pose with a reversed velocity still jerks. Keep every wrapped procedural component periodic over the declared loop length, or keep nonperiodic motion outside the baked loop.
