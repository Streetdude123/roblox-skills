# R6 geometry and contact

Use the inspected rig, not assumed stock offsets. The equations below derive the Poser convention from Motor6D transforms. They are not a claim that every R6 avatar has the same proportions or rest frames.

## Contents

- Rig and pose hierarchy
- Transform convention
- Direction and rotation checks
- World-space contacts
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

For a modified rig or an offset grip, derive the endpoint using W1 instead. Inspect `W1:PointToWorldSpace(contactLocal)` and the actual prop frame. Do not apply the stock hand formula to an arbitrary C1.

Compare rotations as CFrames or matrices. Euler angles are non-unique; a 100-degree lift can decompose to another angle triple with the same orientation. Near gimbal configurations, edit the intended orientation and inspect its endpoint rather than changing a suspicious Euler value in isolation.

A short-arc rotation difference between matrices R and S is `acos(clamp((trace(transpose(R) * S) - 1) / 2, -1, 1))`. The decode checker uses this measurement. It cannot recover a full spin lost between sparsely sampled keys.

## Joint gaps

A pose translation `p` on a limb moves the whole part away from its joint. The R6 hip C0 sits at the torso's bottom corner `(+-1, -1, 0)` and C1 at the leg's top corner `(+-0.5, 1, 0)`, so with `p = 0` those two points coincide whatever the rotation, and any `p` separates them by `|p|`. Daylight shows when the leg goes below or sideways: measure it in torso space as `c = torso.CFrame:PointToObjectSpace((leg.CFrame * CFrame.new(+-0.5, 1, 0)).Position)`, `below = max(0, -1 - c.Y)`, `slide = sqrt((c.X -+ 1)^2 + c.Z^2)`. Keep both under 0.12. A positive `p.Y` pushes the leg up inside the torso and is hidden. To move a foot without a gap, swing the hip: a forward offset `z` becomes `lift += deg(asin(-z / 2))`, a sideways offset `x` becomes `side += deg(asin(x / 2))`, and the foot rises `2 (1 - cos)` (0.05 at 13 degrees), which a torso drop of the same amount plants again. `Clips.lua` applies this as `attachLegs` to every authored DIO clip after the keys are written, so authors may still think in foot offsets. Measured on 2026-09-22 after a circled hip gap: the seven DIO clips went from 0.30 to 0.65 of daylight to 0.00 to 0.12.

## Planted feet on rigid legs

Measure the floor contact at the LOWEST SOLE CORNER, not the sole centre. The corner of a swung rigid leg sits `2 cos a + 0.5 sin a` below the hip for a combined swing `a = acos(cos lift * cos side)`: a 30 degree swing lifts the leg centre 0.27 but the heel corner only 0.02, a 14 degree swing puts the corner 0.06 BELOW the rest floor, and 45 degrees lifts it 0.23. So a walk needs no pushed-down back leg: solve the torso height from the stance foot's corner (`depth - 2`, with the torso lean added to the leg angle because the legs hang from the torso) and the body bobs by geometry, highest just after passing and lowest at contact (0.10 on Walk2's angles). `legDepth` in `scripts/Clips.lua`.

For a planted foot under a torso that twists, leans and rolls (a copied stand hit), aim each rigid leg from its hip at a floor target instead of translating it: the target turns with the torso's heading (the feet pivot with the hips; with fixed targets a 124 degree whip put the targets out of reach and dropped the torso 2.4 studs), the torso drops only as far as the farther target needs, a too-close target is pushed out along the floor, and two passes fix the sole: aim the centre, measure the real lowest corner (twist and roll change which corner it is), aim again with the error removed. `legIK` / `dropFor` in `scripts/Clips.lua`; measured on the DIO chain: 0.00 hip gap, planted corners -0.05..+0.05, a 0.22 to 0.73 crouch.

Measure a live walk with a ray under each lowest corner every frame. A floor height read once at the start of a walk sample reported a 1.0 stud float that was the SpawnLocation under the path.

## World-space contacts

Choose an actual local support point. For the sole center of a rectangular leg use `(0, -Size.Y / 2, 0)` in that part's coordinates. Also test the four bottom corners for penetration. For a hand or weapon grip use its inspected attachment or local offset.

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

Separate three frames of reference: authored joint pose, evaluated character pose, and root motion through the world. A visually translated Torso does not move the gameplay root or the server's hitbox model.

For in-place locomotion with cycle distance D, `phase += 2*pi*distanceTraveled/D` is a useful clock. Check the actual foot path against root travel during stance. Use the same phase meaning for all blended clips; the bundled locomotion examples use passing poses at phase zero.

For an ordinary loop, match the boundary pose and compare incoming and outgoing local velocity. Inspect angular motion as well as translation. A closed pose with a reversed velocity still jerks. Keep every wrapped procedural component periodic over the declared loop length, or keep nonperiodic motion outside the baked loop.
