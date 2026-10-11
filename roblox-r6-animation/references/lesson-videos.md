# Lesson videos

Five lesson videos on the craft, each studied in full. The first four were studied in a browser: the full caption transcript of each (turn captions on in the player, capture the player's own `timedtext` response, parse the json3 events), plus frame grids of the key demonstrations (canvas `drawImage` of the video at chosen times inside a modal `<dialog>`). This file keeps what each video teaches, in our words, and translates it to R6 clips authored in code with Poser. Where a number is ours (a conversion to 60 fps, a Poser setting), it says so.

| Video | Length | What it is |
| --- | --- | --- |
| [AlanBeckerTutorials, "12 Principles of Animation (Official Full Series)"](https://youtu.be/uDqjIdI4bF4) | 24 min | The Thomas and Johnston principles, one chapter each, with stick-figure demonstrations. |
| [NobleFrugal Studio, "The #1 Animation Principle (How To In-Between)"](https://youtu.be/6UXjRCORV44) | 12 min | Timing and spacing: frames against drawings, ways to divide space, a timing chart for a hammer slam. |
| [Kuzillon, "6 Beginner ANIMATION MISTAKES to avoid!"](https://youtu.be/-WUhB9DLrqo) | 4 min | Six mistakes: too slow, constant speed, cut corners, straight paths, detail too early, lazy screen edges. |
| [Bluebiscuits, "How to do Basic Animation from a beginner to a beginner"](https://youtu.be/Al_k9hmd4ws) | 16 min | "Half animation half animatic": simple shapes, start and end frames, favour frames, mixed holds, pull-back, settle, bounce, squash and pull on the in-betweens. |
| [Alexander Rudenko, "Physics in animation"](https://youtu.be/x3jaDhGUHuw) | 37 min | Centre of mass (balance, rotation around it, speed gained and lost only through support), rotation speed against pose, inertia ("through motion") and settles, bouncing-ball points, the layered method, arcs. |

## Contents

- The short version
- 1. Alan Becker: the 12 principles, translated to R6
- 2. NobleFrugal Studio: timing and spacing
- 3. Kuzillon: six beginner mistakes
- 4. Bluebiscuits: the practical tricks
- 5. Alexander Rudenko: physics in animation
- Hand-off checklist (one answer per principle)

## The short version (read this first)

1. **Movement first, detail last.** Block the start and end poses with simple shapes, get the motion right, then add detail. (Bluebiscuits, Kuzillon; our blocking strips are this step.)
2. **Timing is meaning.** The same pose change says a different thing at a different frame count. Time the action from real life (act it out with a stopwatch) and expect beginners, and us, to go too slow.
3. **Spacing is the feel.** Close spacing near the keys, wide in the middle; favours for snap. Never constant speed on a living body. No ease into an impact: the ease belongs on the rebound.
4. **Everything travels on arcs** and the whole body takes part: a big move in one part fades out through the parts next to it, like dominoes.
5. **Every move has three small extras:** a pull-back before it (anticipation, one to three levels), a follow-through and settle after it, and appendages that trail and overshoot.
6. **Exaggerate, then back off.** Push a pose until it is too much, then wind it back. A fast extreme must be bigger, or held longer, or nobody sees it.
7. **Stage it for one viewer.** One main action at a time, clear from the camera that sees it. On Roblox that is the player's camera behind the character.
8. **Physics underneath.** The centre of mass stays over the support or the body falls; it gains and loses speed only through a planted push or a braced stop; rotations turn around it; in the air it follows a parabola. Loose parts carry their speed through every contact and settle with shrinking bounces.

## 1. Alan Becker: the 12 principles, translated to R6

**Squash and stretch.** Speed, momentum, weight and mass show as the shape getting longer or flatter, with the volume kept. A soft body squashes a lot and a stiff one barely. The stretch comes only near the fastest point (just before the ball lands), not for the whole fall. A character stretches on the way down and squashes after it lands, then settles.
- R6 parts cannot scale. Squash is a compact pose: the torso drops, the legs translate up into the torso (hidden, allowed by the feet rule in SKILL.md), the arms pull in and the head tucks. Stretch is a long pose: full extension along the line of action, the root rising, the limbs reaching. Put the stretch pose on the frames of peak speed only and the squash on the contact frame, then settle.
- Trails, afterimages and smears carry the rest of the stretch on the fastest frames (see Arcs).

**Anticipation.** The prep tells the viewer what comes next and gives the action its power: crouch before a jump, arm back before a punch; without it the energy comes from nowhere and the punch reads weak. Make the prep visible (the hand goes up before it goes into the pocket; the eyes and head look where the next thing happens). The frames showed a punch with several levels: the body first leans forward (a wind-out), then winds back, then throws the other arm back, then punches.
- In code: a small move the other way before the load (level 1 of anticipation), the load itself (level 2), a counter-limb swinging back (level 3) for the heavy hits. Scale the levels with the move's tier.

**Staging.** Present one idea so it cannot be misread: control where the viewer looks, one main action at a time, no competing actions, and let one action finish before the next starts. Wide shots for big actions, close shots for expressions; the main action in the centre or on a third, with space in front of where the character faces. Insert a pause when the viewer needs time to take something in.
- On Roblox the player's camera sits behind and above the character. A thrust straight away from the camera hides behind the body (and any wings, cape or back piece) (measured on a lance thrust), so move the hands and the weapon to the side that the camera sees, or let the VFX carry the line. A giant summoned construct must rise to the side, never between the camera and the body.

**Straight ahead and pose to pose.** Pose to pose gives control for the body: keys, then extremes (the farthest each way), then breakdowns (how the extremes connect), then in-betweens, perfecting each level before the next. Straight ahead suits things driven by physics: fire, water, dust, explosions, and floppy parts such as ears, hair and tails. Animate the body pose to pose without those parts, then add them straight ahead.
- This is our split: body keys in Poser, then springs, follow chains and lag for the tails, capes, hair, ribbons and VFX (a tail's follow chain, `springs`, `lag`).

**Follow-through, overlapping action and drag.** Parts keep moving after the body stops (follow-through), parts move at an offset from the body (overlap), parts lag behind the body (drag). The tip of an appendage catches up last and overshoots farthest before it settles. The whole body also follows through and comes back when it stops, and a landing follows through as the jump anticipated. The amount of drag says the mass (a stiff antenna against a feather). The elbow leads, then the forearm, then the hand, even in a walk. Offset the arms from the legs, and the top half from the bottom half when a character stands up.
- R6 has no elbow: the shoulder rotation leads, the hand and the held weapon trail one to three frames, and a short translation up the limb suggests the bend. Use `lag` on loose parts, the spring presets on carried parts, and keep striking limbs off the lag list.

**Slow in and slow out.** Almost all motion starts slow, speeds up and ends slow; constant speed looks robotic. In 3D this is a spline curve instead of linear. Do not ease into a collision (the ball hits the ground at full speed; the ease is on the way back up) or out of a gun (the bullet), but do ease the gun's recoil. A very fast move can have a single in-between, with the frames next to the keys skewed toward the motion. A character never goes from still to top speed in one frame.
- `curve = "spline"` with `auto` keys is the default; a `flat` key only where a part turns round; the contact key of a strike keeps its speed (no flat ease into the hit), the recoil after it eases.

**Arcs.** Living things move on curved paths; a midpoint in-between looks mechanical and can shrink the shape. For a thrown ball keep x constant and ease y. Arc a head turn (a small dip), a landing settle, the body's rise and fall before a step, a kick's follow-through. When a move is too fast to read, draw the arc as a smear from the start to the end pose.
- Check the hand and tool paths in root space (per-frame poses from `Poser.posesAt`, chained by r6-mechanics.md, "Transform convention"); add a breakdown to bend a straight path; use swing trails as the smear.

**Secondary action.** Gestures that support the main action and show how the character feels: an angry walk swings the arms and bobs the head; the free hand while knocking tells the mood (a fist, a dainty tap, tucked in while the head checks behind). It must not upstage the main action and must not go unnoticed; give it its own moment.

**Timing.** The number of frames between two poses sets the meaning. The video's head-lean example, as durations at 24 fps on ones (our conversion, one in-between = one more frame of about 0.042 s; double them for twos):

| In-betweens | About | Reads as |
| --- | --- | --- |
| 0 | 0.04 s | struck by a huge force |
| 1 | 0.08 s | hit by an object |
| 2 | 0.13 s | a muscle twitch |
| 3 | 0.17 s | a dodge |
| 4 | 0.21 s | "get out of here" |
| 5 | 0.25 s | a friendly "come on" |
| 6 to 7 | 0.29 to 0.33 s | sees something great, tries to see better |
| 8 to 9 | 0.38 to 0.42 s | searching, appraising |
| 10 | 0.46 s | stretching a sore muscle |

Use it as a meaning check for a strike or a reaction: a lunge whose strike takes 0.3 s reads as looking, not hitting. Twos are the common default in 2D: half the work, smoother slow moves and more snap; ones for very fast or busy action.

**Exaggeration.** Make the essence of the action more convincing, not more distorted: sadder, brighter, wilder. Even a "finished" clip gains power from more exaggeration (the frames showed a pan hit where the exaggerated victim folds in a deep arc and the attacker winds up much bigger). A pose that looks too extreme as a still reads normal in motion, because only one frame is extreme; so push it until it is too much, then wind it back.
- On a fast strike, make the extreme pose bigger or hold it a few frames longer (our moving holds).

**Solid drawing.** Weight and balance in three dimensions; for 3D animators, avoid twinning (both arms or legs doing the same thing): shift the weight, a hand on a hip, a slouch.

**Appeal.** Clear, varied shapes; magnify what defines the character; keep it simple enough to animate many times.

## 2. NobleFrugal Studio: timing and spacing

- Timing is when a drawing happens (its frame number); spacing is where it is. Motion needs both. The frame rate sets the most drawings you can show; animating on ones, twos or threes changes how many you make. More drawings do not make a smoother or better animation; the spacing does.
- There are two kinds of motion: constant (even spacing) and accelerating or decelerating (spacing that grows or shrinks).
- Three ways to split the space between two poses: **halves** (smooth, good when there are many frames), **thirds** (snappier: momentum builds or dies quickly), **favours** (snappiest: the in-between barely leaves its key and leans toward it). With only a few frames, favour both keys and the move still reads.
- To choose a duration, act the move out against a stopwatch and multiply the seconds by the frame rate.
- Make a timing chart for each pair of keys: ease in, ease out, both, constant, or none. The video's hammer slam: the wind-up slower (more drawings), the slam fast; the chart packs the in-betweens near the raised pose so the hammer leaves it slowly, then leaves big gaps so it arrives fast, and the last in-between favours the landing pose to put the motion to rest.
- In code: a favour is a breakdown key close to its key in both time and value (for example 1 to 2 frames after the start at 5 to 10% of the travel). A slam is a slow departure (keys packed near the top) and a fast arrival with no ease into the contact, then an ease into the rest.

## 3. Kuzillon: six beginner mistakes

1. **Too slow.** Beginners draw every stage of the action and end up far slower than real life; nobody animates too fast. Time from the real duration, with fewer frames. (Our clips are often long for the same reason: check each beat against the timing table.)
2. **Constant speed.** Evenly spaced frames look weak and artificial; vary the spacing through the move.
3. **Cutting corners.** Moving only the part that matters (only the legs of a running animal) looks dead. Motion spreads like a fading domino chain: the arm moves a lot, the shoulder less, the upper body near it a little, and beyond that nothing. A part that moves hard must not be attached to a part that is dead still.
4. **Straight paths.** Put the midpoint a little off the direct line; organic motion curves, even slightly.
5. **Detail too early.** Draw simple lines and shapes first, fix the pose and the motion, then add detail. (Block in grey strips before polish; fix timing before adding VFX.)
6. **Lazy edges.** A subject entering or leaving the frame still needs full drawings; work outside the camera area. (For moves that leave the player's view, plan the whole motion, not only the part on screen.)

## 4. Bluebiscuits: the practical tricks

The style: a simple flat character, bold readable poses, snappy timing with holds, and small tricks that make each move pop. The method, as shown in the video and its onion skins:

1. **Keys first.** Draw the start pose and the end pose, simply. Everything else connects them.
2. **Favour frames.** Copy the start pose, nudge it a little toward the end; copy the end pose, nudge it a little back toward the start. With those four drawings the move already "flicks" across; add a middle drawing only when the poses are far apart or the move must be slower. In the onion skins, the first in-between hugs the start pose and the next one travels on an arc, with the arm trailing and then flicking up.
3. **Mixed holds.** Hold drawings for 2, then 3, then 4, then 2 frames inside one move: fast, slow, fast. A tip from the video: step through animations you like frame by frame (the comma and period keys on YouTube) and count the frames.
4. **Circles.** Moving parts follow a loose circular path, never a straight line.
5. **Squash and pull the in-betweens.** Squash when falling, stretch when taking off and when landing.
6. **The settle.** After a move ends, add one or two frames at almost the same pose, nudged slightly, then the final pose. It lets the motion rest and looks much livelier.
7. **The pull-back.** Just before a move, one frame nudged the opposite way (on ones or twos), then release.
8. **The bounce.** For a small move, an expression change or a line of speech, shift the character up slightly on the frames just before the final pose, then drop into it: a little hop.
9. **Stagger the secondary parts.** Eyes, mouth and each arm change a bit on each in-between rather than all at once; an arm lags and then flicks into place.

### The same tricks in Poser (our translation, 60 fps)

| Trick | Poser version |
| --- | --- |
| Favour frames | A key 1 to 2 frames (0.017 to 0.033 s) after the start at 5 to 10% of the travel, and a key 2 frames before the end at 90 to 95%, both `auto`; the travel between them is the fast part. |
| Pull-back | 2 to 4 frames (0.03 to 0.07 s) moving 3 to 8 degrees (or 0.05 to 0.15 studs) against the coming move, before the load. |
| Settle | 2 to 5 frames after the end pose: overshoot 4 to 8% and return. The `lead` spring gives about 6% and settles in 7 frames; key it by hand on the striking limb. |
| Bounce | On the 3 to 6 frames before the final pose, torso `py` up 0.05 to 0.12 studs and back; stagger the head 1 frame later. |
| Mixed holds | Poser plays at the frame rate, so a hold is a moving hold (5 to 15% drift). For the stepped, animatic look, sample the clip on quantised time: `t = math.floor(t * 12) / 12` for twos, or a per-segment step size for 2-3-4-2 holds. Offer it as a style option; never apply it to player locomotion without asking. Quantised sampling gives a twos look; an anime-style stepped strike instead poses each held step by hand on `step` keys with a hold list (stylized-and-roblox.md). |
| Squash and pull | See squash and stretch above: a compact pose on contact, a long pose on the fastest frames. |
| Stagger the parts | `lag` on loose parts, key offsets of 1 to 3 frames down the chain, the head answering the torso. |

## 5. Alexander Rudenko: physics in animation

[Alexander Rudenko, "Physics in animation"](https://youtu.be/x3jaDhGUHuw) (37 min, 2024). By a lead gameplay animator trained at a studio built on physical animation. Studied on 2026-10-11 from the full caption transcript (947 caption events) and all 226 YouTube storyboard frames (160 x 90, one every 10 s). The video stream itself was blocked by YouTube's bot check, so fine motion in the demos was not frame-stepped; the storyboard frames confirm the setups described below.

The video names four parts of a good animation: the centre of mass, rotation speed, the inertia of body parts, and arcs. Realism is the base; stylized work breaks these rules on purpose, and only an animator who knows them can break them well.

### Centre of mass (COM)

- The COM is the point where the body's mass balances. It tells how speed is gained and lost, whether the body stands or falls, and whether a rotation is correct.
- The video's rig: a locator in each joint (feet, shins, thighs, pelvis, chest, head, shoulders, forearms, wrists), one COM locator point-constrained to all of them with rough segment weights, a vertical line from the COM to the floor, and a plane skinned to the feet that shows the support area (seen in the frames as a green line and a blue plane). Rough weights are enough; the aim is to see it.
- **Balance.** While the COM's floor projection stays inside the support area (the region between the support points), the character stands. When it leaves the area, the character falls unless a new support point catches it (a step). The nearer the edge, the harder the stand. On one foot the COM must stay over that foot, and it is never static: it keeps making small corrections.
- **Quick balance check without a rig.** Look along the line of the support points, draw a vertical line up from the support, and compare the body volume on each side. Similar volumes mean a balanced pose. A dynamic pose can look right from one camera and fall over from another; check two views.
- **Standing up and recovering** throw the COM: a push (hands or legs) gives the COM speed, it crosses into the support area, then the body brings it to a comfortable place.
- **Rotation happens around the COM, not the pelvis.** Rotating around the root control is the most common beginner error: with heavy arms or legs held out, a pelvis pivot reads wrong. Fix: put a locator at the approximate COM, rebake the root onto it, and zero the old translates. In a flip, the COM (not the pelvis) follows the ballistic curve. In the air the COM's horizontal speed is constant and its height follows a parabola.
- **Acceleration and deceleration need support.** The COM cannot speed up or slow down on its own. To start, a back leg compresses like a spring and releases while it is on the ground; a start from one leg needs a fall forward first. Every step is a fall caught by a leg; a run is a chain of falls. To stop, plant a stopper leg ahead of the COM in the direction of travel, lean the body back and sink; a leg placed without tension, or not ahead of the COM, only stumbles. A soft stop takes several steps; a hard stop is one braced, extended leg and a deep squat.

### Rotation speed

- In the air (and in a static pose), the spin rate stays constant; air drag is ignored. On the ground, friction slows it.
- The spin rate depends on the pose: limbs far from the axis spin slowly, a tucked body spins fast (the skater who pulls the arms in). The axis passes through the COM, and the support foot draws a small circle to keep the COM over it.
- The spin graphs in the video: the curve is flatter while the arms are out and steepens as they come in.

### Inertia, or "through motion"

- Nothing stops at once. When the skeleton stops (a landing, a fall on the back), the muscles, hair and clothes keep going at the speed they had, stretch, then come back in a decaying oscillation: the settle is harmonic damping.
- **Mistakes shown side by side:** a freeze or slow-down at the moment of contact (the arms stick in the air, the head waits, the pelvis hangs) - "you should never do that", and the graph editor shows it as a slow-down; a "magnetic cushion" landing that eases into the floor; a hand that stops mid-air; bounces added afterwards as quick flicks of the same amplitude, which no mass can do; a part that leaves its arc for another direction.
- A human has few inertia points; props add more (backpacks, guns, swords). Track them.
- **Everything is a bouncing ball.** The video reduces a character to a set of balls: the top of the head (not the head), shoulders, hands, pelvis, feet, and props. Each ball follows bouncing-ball rules: an arc, spacing that shows gravity and impacts, no sudden change of direction. Raw motion capture looks the same, with more points.
- **Layered method.** Block, then spline, the pelvis and the legs first, until you believe the body could move that way; then the back; then the arms and the head.

### Arcs

Everything moves on arcs and circles (the ribbon character in the frames). Arcs from a reference are cleaned and made more beautiful, not copied with their wobbles.

### Realism and style

Real motion is slow and plain next to game animation; combat moves are pushed for sharpness and impact. Understand the physics first, then push it or break it on purpose.

### The same rules on an R6 rig (our translation)

R6 parts cannot be weighed from their size: a viewer reads the character as a human, so use human segment fractions (Winter's table): Head 0.081, Torso 0.497, each Arm 0.050, each Leg 0.161, each at its own segment centre (the formula is in body-mechanics.md). The standing COM sits 0.64 below the torso centre and 2.36 above the floor, in the lower half of the torso where a pelvis would be. Compute it per frame from the evaluated part CFrames. Scale with `S = Torso.Size.Y / 2` on a scaled rig.

| Rule | R6 version |
| --- | --- |
| Balance | The support area is the floor box under the planted soles (each leg's bottom face is 1 x 1; two planted feet make the box around both). In a held pose or a slow move, keep the COM's floor projection inside it. Over the edge reads as falling: allow it only when a step, a push, a hit or a jump explains it, and land the next support under the COM. The Humanoid never falls, so the animation alone sells balance. |
| Two views | Check the balance from the side and the front, not only from the player's camera. |
| Rotation about the COM | RootJoint rotates about the torso centre, 0.64 above the standing COM. For a flip, spin or big lean, add the translation that keeps the COM where it should be: `p += c - R * c` with `c` the COM in torso space (the same correction as the waist rule, with the COM as the pivot). In the air move the COM on the arc, not the torso. |
| Ballistic flight | When a clip moves the body through the air itself, the COM's horizontal speed is constant and its height is a parabola. Match the game's gravity (`workspace.Gravity`, 196.2 studs/s^2 by default) unless the style asks for hang time. When the Humanoid jumps by physics, the clip does not add its own vertical arc. |
| Spin speed | Constant in the air; faster when the limbs tuck, slower when they spread. A tuck in the middle of a flip speeds up the root rotation for those frames. |
| Push before speed | A dash, lunge or jump starts with a compression of the back leg (torso drop) and a push while the foot is planted; or the body leans and falls into the first step. No root travel without a planted push. |
| Stopper before stop | A stop puts a braced leg ahead of the COM, leans the torso back and sinks. A slide into a stop takes several small steps. |
| Through motion | At a landing or a stop, the arms, head and props keep travelling along their arcs, then settle with each bounce smaller and shorter. Contact keys stay `auto`, never `flat` or eased; springs (`follow`, `drag`) give the decaying settle; never add same-size flicks afterwards. |
| Bouncing balls | Track the head top, both shoulders (arm tops), both hands (arm bottoms), the pelvis (torso bottom), both soles and prop tips in root space. Each path must be an arc with readable spacing, with no stall at a contact and no change of direction mid-arc. |
| Layered method | Animate the torso translation and the legs first (`Feet.flat` targets), then the torso rotation, then the arms, then the head. Do not polish arms on a body whose weight does not read. |

## Hand-off checklist (one answer per principle)

Answer each against the captures and the numbers before hand-off.

- **Timing.** Does each beat's duration match what it should mean (the timing table)? Is anything slower than real life or the reference?
- **Spacing.** Is the speed ever constant on a living part? Is there an ease into an impact that should hit at full speed?
- **Anticipation.** Is there a pull-back or wind-up before each major move, sized to the move?
- **Follow-through and overlap.** Is there a follow-through and settle after each move? Do the loose parts trail and overshoot more than the body? Does the motion spread to the neighbouring parts and fade out, with no hard-moving part next to a frozen one? At each contact, do the arms, head and props keep moving through it and settle with shrinking bounces, with no freeze?
- **Arcs.** Does every moving part travel on an arc (hand, foot, tool tip, head top, root)?
- **Squash and stretch.** Is the contact a compact pose and the fastest frame a long one?
- **Staging.** Is the main action clear from the player's camera, with nothing in front of the body and one action at a time?
- **Pose to pose and straight ahead.** Did the blocking read before the motion pass? Do loose parts follow through springs or lag chains?
- **Secondary action.** Does the free hand, the head or a prop support the action without competing?
- **Exaggeration.** Is each extreme pushed far enough to read at speed (bigger, or held longer)?
- **Solid drawing, weight and balance.** Does each key pose have one C or S line of action, shoulders tilted against the hips, and gaps between the limbs and the body? No twinning in any held pose? In every held pose, is the COM's floor projection inside the support area, checked from two views? Does every fall over the edge have a cause and a catch? Does every gain of speed come from a planted push, and every stop from a braced leg ahead of the COM? Does every flip, spin or big lean rotate around the COM, and does an airborne COM follow a parabola at constant horizontal speed?
- **Appeal.** Does the silhouette of each key pose read clearly and say what defines the character?
- **Game feel.** Is the player's anticipation short (1 to 8 frames for a light attack)? Is the striking limb the fastest joint in its window? Does each melee contact have a hitstop sized to its strength with the attacker creeping? Is the event on the contact key, the cancel window before the end, the recovery over-extended then popping back, and the next move's first pose equal to this move's end?
