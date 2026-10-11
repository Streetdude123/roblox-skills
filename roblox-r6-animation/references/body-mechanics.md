# Body mechanics and physics on R6

The physics a viewer checks without knowing it: where the mass is, what holds it up, how it gains and loses speed, how it turns and how it falls. Lesson-videos.md section 5 gives the method; this file gives the researched numbers and their R6 translation. Every finding was checked against its source (sources.md, "Body mechanics research"). Numbers marked "our derivation" are computed here from the sourced ones.

## Contents

- Centre of mass on R6
- Balance and weight shift
- Gravity, jumps and falls on Roblox
- Takeoff and landing
- Flips and spins
- Walk mechanics
- Force, reaction and momentum
- Carrying, pushing and lifting
- Loose parts: falling, swinging, drag

## Centre of mass on R6

Winter's version of Dempster's table (8 cadavers, older men) gives whole-segment mass fractions and centre positions:

| Segment | Mass fraction | COM position |
| --- | --- | --- |
| Head and neck | 0.081 | at the ear (the distal end) |
| Trunk | 0.497 | halfway from the hip joint to the shoulder joint |
| Each total arm | 0.050 | 0.530 of the shoulder-to-wrist length from the shoulder |
| Each total leg | 0.161 | 0.447 of the hip-to-ankle length from the hip |

They sum to 1.000. Scans of young adults (Zatsiorsky, de Leva) give a thigh 42 to 48% heavier and a trunk 13 to 14% lighter; the rough table is enough to see balance.

On the stock R6 rig, in each part's own space (scale every offset by `S = Torso.Size.Y / 2` on a scaled rig):

| Part | Weight | COM point |
| --- | --- | --- |
| Head | 0.081 | part centre |
| Torso | 0.497 | `(0, -0.25, 0)`: halfway between the hip line (y -1) and the shoulder joints (y 0.5) |
| Each arm | 0.050 | `(0, -0.295, 0)`: 0.795 below its shoulder joint |
| Each leg | 0.161 | `(0, 0.106, 0)`: 0.894 below its hip |

```text
com = 0.081 * Head.Position
    + 0.497 * Torso.CFrame * (0, -0.25, 0)
    + 0.050 * (RightArm.CFrame * (0, -0.295, 0) + LeftArm.CFrame * (0, -0.295, 0))
    + 0.161 * (RightLeg.CFrame * (0, 0.106, 0) + LeftLeg.CFrame * (0, 0.106, 0))
```

The standing COM sits 0.64 below the torso centre and 2.36 studs above the floor (47% of the 5-stud body; our derivation), at belly-button height as a human's does. Part centres alone give 0.52 below. Add a heavy prop to the sum with its own fraction (0.3 at the hands is an example value for a heavy load).

## Balance and weight shift

- **Support area.** The COM's floor projection inside the box around the planted soles means the body stands; outside, it falls unless a step or a hold catches it.
- **Limits of stability.** A standing person sways safely within a cone of about 12.5 degrees front to back and 16 degrees side to side; at the limit they must step or grab a support. On R6, measure a lean as the angle from the centre of the stance soles up to the COM: starting limits about 6 degrees forward or back (0.26 studs of COM offset) and 8 degrees to the side (0.33 studs) (our derivation, halving the totals). Past those, a held pose reads as tipping and needs a step, a brace or a cause.
- **Weight shift.** Moving the centre of gravity a few inches to one side shifts the weight onto that foot; a human shows it with the hip rising and the shoulder dropping on the weight-bearing side. For an idle weight shift on R6, move torso `px` 0.15 to 0.3 studs toward the stance foot and let `Feet.flat` keep both soles. The R6 torso is rigid, so one roll tilts the hip line and the shoulder line the same way: choose a small roll that drops the stance-side shoulder, unweight the free leg with a slight lift or side splay so its hip reads relaxed, and optionally drop the stance-side arm and counter-tilt the head.
- **The shift is the anticipation of a step.** Before a foot lifts from a stand, the weight moves from between the feet onto one foot. Key the torso (and the COM) over the stance sole first, then lift the swing foot 2 to 4 frames after the COM arrives (a starting value). A foot that lifts while the COM is still between the feet reads as floating. In a continuous walk the COM never fully reaches one foot before the lift; this delay is for steps taken from a stand.

## Gravity, jumps and falls on Roblox

- **Units.** Roblox documents 1 stud = 28 cm and a default `workspace.Gravity` of 196.2 studs/s^2 (54.9 m/s^2, about 5.6 times Earth). Its units page lists a realistic gravity of 35 studs/s^2 (9.8 m/s^2). Scaled by body height instead (5 studs = 1.75 m), Earth gravity is about 28 studs/s^2 (our derivation).
- **Choose the gravity a clip reads under** before keying any hop, drop or loose part. At 60 fps the per-frame drop grows by g/3600 each frame: 0.0545 studs at 196.2, 0.0097 at 35.
- **The default jump.** Humanoid defaults: JumpHeight 7.2 studs, JumpPower 50 (`UseJumpPower` picks which applies), WalkSpeed 16. At g = 196.2, JumpHeight 7.2 gives a takeoff speed of 53.2 studs/s, the apex at 0.271 s (frame 16) and 0.542 s in the air (33 frames); JumpPower 50 gives a 6.37 stud peak, the apex at frame 15 and 31 frames in the air (our derivation). A Roblox jump has human air time but rises about 1.4 body heights. Read the place's StarterPlayer values first; with the defaults, time the airborne clip (takeoff stretch, apex pose, landing reach) to 31 to 33 frames with the apex near frame 15 or 16. When the Humanoid jumps by physics, the clip adds no vertical arc of its own.
- **Hang time.** A jumper spends 71% of the hang time in the top half of the jump height, because fall time grows with the square root of the fall distance; the peak is at the midpoint of the hang time, and h = g T^2 / 8. In a 33-frame jump about 23 frames fall in the top half and about 16 in the top quarter (our derivation): make the air pose a moving hold across those middle frames; the takeoff stretch and the landing reach get about 8 frames each.
- **The odd rule.** Under constant gravity the spacing from the apex grows as 1, 3, 5, 7. At half the time from the apex to the ground the body has fallen only a quarter of the distance ("fourth down at half time"). For a hop carried by torso `py`, key the apex `flat`, put a breakdown a quarter of the way down at the time midpoint, and key the contact `auto` with no ease into it. Check the sampled steps with `Poser.dump`.
- **Timing tells size.** Gravity-driven timing sets how big things read: a 20% change in timing makes a 6 ft character read about 4 ft tall. Time falls, swings and settles by the square root of size: a rig twice R6 size takes 1.41x the frames, a half-size rig 0.71x (our derivation). Copying R6 timing onto a giant makes it read small. Live Humanoid physics still uses the place's single gravity.

## Takeoff and landing

- **A real standing jump.** In a countermovement jump (heights 39 to 44 cm) the phases last: unweighting 287 to 305 ms, braking 115 to 168 ms, propulsion 256 to 300 ms; the landing 233 to 411 ms. At 60 fps the prep is about 40 to 46 frames: torso `py` drops with growing speed for about 18 frames, stops in 7 to 10 (a `flat` bottom key), drives up for 15 to 18 and leaves at full speed (`auto`, no ease out at the takeoff). A player's jump leaves on input, so use this full timing only for NPC and cutscene jumps; a player jump shows at most the propulsion.
- **Drive down to go up.** The faster the body drives down before the push, the higher the jump reads; throw the shoulders and arms up on the push frames, not after the feet leave the floor.
- **Landing.** In drop landings the knee load peaked about 0.07 s into the landing at every height; soft landings flexed the knee 75 to 88 degrees, natural 51 to 67, stiff 45 to 59, and stiff landings loaded the knee more (20.2 against 11.8 N/kg). R6 has no knee, so the torso drop stands in: keep the torso's downward speed through the contact frame, put the hardest slowing in the first 4 frames, and let the bottom come later. A soft landing is about 1.5x deeper than a stiff one; a stiff landing is short and shallow. After a landing, add steps, weight shifts or small bounces instead of a sudden stop.

## Flips and spins

- **All rotation starts at takeoff.** The torque comes while the feet still push; in the air the angular momentum is conserved. A dive is two motions: the COM on a parabola, and the body rotating about the COM. The root must already be turning on the takeoff frame: start the lean and the turn during the push while `Feet.flat` still holds the soles. In the air a spin can neither start nor stop; a shape change only speeds it up or slows it down, and only the landing contact stops it. Key the open-out 4 to 8 frames before the contact (a starting value) so the spin slows into the landing; opening too early or too late under- or over-rotates.
- **Spin rate against shape.** Median moment of inertia relative to the layout (somersault axis): layout with arms up 1.16, layout 1.00, open pike 0.70, pike 0.49, tuck 0.46, tight tuck 0.34. Spin rate is the inverse. R6 cannot fold at the knee, so its tightest flight shape is a pike (both legs lifted straight at the hip, arms in): about 2.0x the layout rate; an open pike about 1.4x; arms overhead about 14% slower. Keep 2.2x to 2.9x for deliberate stylization. Example (our derivation): one back flip in a 0.54 s jump, open for 0.1 s at each end and piked for 0.34 s, needs about 6.4 degrees per frame open and 13.9 piked; ramp the rate over the frames where the legs lift.
- **Turn about the COM.** RootJoint pivots at the torso centre, 0.64 above the standing COM, and the gap changes as the legs lift; add the root translation each frame that keeps the computed COM on its parabola while the body turns about it (r6-mechanics.md, "Centre of mass and balance").

## Walk mechanics

- **The COM path.** In a normal adult walk the COM moves about 5 cm up and down, twice per cycle: lowest in the two double-support phases, highest at midstance and midswing. It moves about 6 cm side to side, once per cycle, furthest toward the stance side at the end of midstance. Scaled by body height: torso `py` travels about 0.14 studs, lowest at each double support; torso `px` sways about 0.17 studs in total, peaking over each stance foot.
- **Speeds.** Normal walking runs 0.95 to 1.7 m/s (mean 1.27), fast walking 1.7 to 2.4 m/s (mean 1.96). At 28 cm per stud that is about 4.5 and 7.0 studs/s; scaled by body height, 3.6 and 5.6. The default WalkSpeed of 16 studs/s is a run in human terms, so a default locomotion clip at that speed must be a run, or the feet slide.
- **Apparent weight through the cycle.** Moving against gravity (rising while speeding up, falling while slowing down) adds apparent weight. In a walk of about 1 s per cycle the load on the feet swings from about 220 to 140 lb around a 170 lb rest; in a fast walk it nearly vanishes at passing and goes over twice body weight around contact; in a very slow walk it stays nearly constant. Shape torso `py` by speed: a slow walk gets a soft, near-sine bob; a fast walk or run gets a sharp turn at the bottom just after contact and a long, rounded top through passing, close to a free-fall arc. Put the sink with planted feet on the contact frames, not at passing.
- **Weight shift grows as the walk slows.** The slower the cadence and the wider the feet, the more side-to-side shift. Scale the torso `px` sway and side roll up for a slower cycle or a wider stance.
- **Hips and hands on curves.** The hips shift side to side onto the supporting leg while bobbing like a bouncing ball, and the hands follow a horizontal figure eight. On R6, give each arm a small side oscillation at twice its lift frequency so the hand traces a figure eight in root space instead of a straight swing; check the arm-bottom path by forward kinematics. A twist about the arm's own long axis barely moves the hand on a rigid arm.

## Force, reaction and momentum

- **Action and reaction.** Every force has an equal and opposite reaction: a man pushing a rock is pushed back by it, and his legs must push the ground at least as hard as his arms push the rock. A puncher's fist takes the force it delivers. On the contact frame of a strike, give the attacker a small reaction: the striking limb loses speed and the torso eases backward a little. Skip it only when the style wants a hero with no recoil. In a push, the back leg drives the torso forward over the planted feet while the arms press.
- **Mass and recoil.** For the same hit, a heavier character recoils and deflects less than a lighter one; a small character running three times faster carries the momentum of one three times heavier. Scale a hit reaction's travel by about the inverse of the victim's mass.
- **Spacing shows the force.** A constant force (sliding friction) changes momentum steadily, so the spacing shrinks by the same step each frame (7, 5, 3, 1): exactly a `quad` out ease. `cubic` and `quart` out brake hardest at once and fade into a long creeping tail, like a hard hit that coasts out. `sine` out brakes harder toward the stop and reads as a squeezed brake and an abrupt halt.

## Carrying, pushing and lifting

- **Carrying.** A character carrying a load leans so the combined COM stays over the support: forward for a backpack, the load held close for a heavy object in front. Accelerating the load upward makes it effectively heavier, so a quick lift is harder to balance. A pose that stays balanced with the load held out says the load is light. On R6, add the prop to the COM sum, lean the torso back for a load in front or forward for a load on the back until the combined COM is over the soles, and widen the stance or step for a fast lift.
- **Pushing.** A character pushing a heavy object leans, braces and moves its COM: the feet push backward and the torso leans forward, with the COM's floor point ahead of the feet so only the object holds the body up. Lots of effort with little effect reads heavy; little effort with a big effect reads light. Keep the object's travel per frame small while the body strains (a torso sink, a moving hold, a growing tremble). A failed attempt needs a visible readjustment (re-plant the back foot with a step) and a harder try.
- **Reversals in power moves.** The line of action flips from one curve to its opposite: in a heavy lift it goes from ")" to "(" as the shoulders heave and the hips come forward under the load, then reverses again as the weight settles. R6 has no spine: build the reversal from torso lift, torso `pz` and the head (load: torso forward, head down; heave: torso swings to a back lean while `pz` moves forward over the feet, the head 1 to 3 frames behind; then a smaller reverse). Look for one in every throw, overhead slam and uppercut, and check the COM over the feet at each held pose.

## Loose parts: falling, swinging, drag

- **Everything falls together.** Over a short fall drag is negligible: the body, a held weapon and dense props share one parabola. Never drop a heavy sword faster than its wielder. Only light, wide parts (cape, cloth, hair, ribbons, paper) lag and fall slower, because terminal velocity `V_t = sqrt(2mg / (rho A C_d))` falls with area against mass (a belly-down skydiver needs about 3 s to reach half of about 55 m/s); give those parts springs or lag, never the body.
- **Swing periods.** A pendulum's small-swing period is `T = 2 pi sqrt(L / g)` whatever its mass; a uniform rod pivoted at one end swings like a simple pendulum two-thirds its length. A uniform 2-stud part hung from its top swings with T about 1.23 s at 35 studs/s^2 and 0.52 s at 196.2; an R6 arm hung from its shoulder joint gives about 1.15 to 1.23 s at 35, close to a natural 1.0 to 1.1 s walk cycle (our derivation). A Poser spring's `f` is its natural frequency in Hz (`w = 2 pi f` in `Poser.lua`), so a free-hanging cape wants `f` near 1/T: about 0.8 Hz at human scale, about 1.9 Hz at the default gravity. The 4 to 8 Hz presets suit muscle-held parts.
