# Animation decisions for R6

Use these decisions during blocking and polish. Sources are linked in [sources.md](sources.md). The R6 applications and diagnostic procedures here are authoring guidance, not numeric rules taken from a tutorial.

## Contents

- Intent and staging
- Weight and support
- Timing and spacing
- Arcs and breakdowns
- Overlap and holds
- Motion recipes
- A worked timing decision

## Intent and staging

Write one sentence about what the character is doing and why: a cautious reach, a committed strike, a tired recovery. Make posture communicate that intent before adding motion.

Check the silhouette at the actual gameplay distance. Separate a hand from the torso when that improves readability, but preserve the action's target and direction. Evaluate the prop tip as well as the body. A pose that looks impressive from the front may hide its action behind the torso in play.

Use a clear gesture through the whole body. R6 has one rigid torso, so imply a chest/hip relationship through root orientation, leg placement, shoulders, and head. Do not write keys for a nonexistent waist joint. Mirror a pose only when the action calls for symmetry; asymmetry is a choice, not a quality score.

## Weight and support

Choose the supporting foot or other contact at each beat. In a settled pose, keep the apparent mass supported. During a dynamic action, let it move beyond the support when a step, jump, fall, or opposing force explains what happens next. Static balance is not a universal constraint on action poses.

Show a sequence of effort: prepare support, apply force, accelerate, absorb or release, regain support. A heavy action can strike quickly after a demanding preparation. Slowing the whole clip does not automatically make it heavy.

For R6 compression, lower and orient the torso while arranging the rigid legs to maintain plausible contact. Translation can suggest a tuck or reach; it does not create a bending knee or elbow. Inspect gaps and limb intersections before increasing offsets.

Do not solve every movement by bobbing the root. A planted point may have nearly no body motion. A hard landing needs a distinct compression and recovery. A floating stand can have a different support model from its user.

## Timing and spacing

Treat timing as when poses happen and spacing as how far the endpoint travels between samples. Both matter. Compare equal time samples of the hand or weapon tip, not just Euler values.

For a strike, decide whether the fastest spacing occurs before, at, or through the contact. A soft contact brakes early; a committed hit may accelerate into contact and continue into follow-through. These need different curves.

Use stepped blocking to decide pose durations, then add breakdowns and interpolation. Keep a deliberate held pose if it serves the action. Use reference rhythm before stylizing it; retime the preparation, strike, and recovery separately.

In Poser, ease names describe the interpolation weight. `cubic out` moves quickly near the start and slows near the destination. Using it for every strike can make the hand brake before impact. `back out` extrapolates beyond the destination; it cannot replace a planned contact response.

Do not prescribe a recovery percentage, uniform combo duration, or fixed number of strike frames. Respect gameplay timing and choose a visual recovery that makes the next state clear. A held extension followed by a quick return is one style; a continuous return can also work.

## Arcs and breakdowns

Track the endpoint that carries the action. Use a local point at the hand, sole, or blade tip and calculate its world position through the full joint chain.

Add a breakdown to control a path, not to increase key count. A hand crossing the chest may need an out-and-around key. A weapon may need clearance above the head. A foot needs a swing path that clears the floor.

Use near-straight paths for actions that require them. A jab need not draw a large arc. Inspect reversals for an unplanned hook or pause. Do not hide a broken path with effects.

CFrame interpolation follows a short rotational path. For intentional turns greater than 180 degrees, insert intermediate orientations that preserve the chosen direction. A start and end angle cannot encode a full revolution by themselves.

## Overlap and holds

Choose a lead based on the action. Head-led attention, hand-led reach, torso-led throw, and foot-led step are different patterns. Secondary movement should respond to that choice.

Separate three decisions: when a part starts, when it arrives, and when it settles. They do not need equal offsets. A striking hand and target contact may share a frame while the free arm settles later. A two-handed grip must not separate because of a timing ladder.

Add follow-through where momentum or soft attachment explains it. Keep hard contacts fixed until their release. Author recoil as a visible response to force; an easing function named `back` does not describe which direction the body recoils.

Use moving holds selectively. Keep breathing small enough that it does not weaken a pose. Stillness can communicate confidence, attention, tension, or a supernatural freeze. Avoid unrelated sine waves on every joint.

## Motion recipes

### Idle or held stance

Block an expressive rest pose first. Identify the loaded foot, gaze, and hand purpose. Add one restrained breathing or weight-shift pattern only if appropriate. Inspect the still silhouette and repeat several cycles. Use a separate unwrapped clock for nonperiodic behavior; a baked loop must close its own motion.

### Walk

Start with contact, down, passing, and up landmarks for each step. Determine support transfer, stance travel, toe-off, swing clearance, and next contact. Record the phase convention; the bundled controller uses a different origin from a contact-at-zero example.

For a moving root, the planted foot's motion relative to that root must oppose travel. Match cycle distance and playback speed, then measure world-space drift during stance. Distance-driven phase alone is insufficient when the foot trajectory or stride length is wrong.

Add torso response and arm swing after support works. Test acceleration, deceleration, turns, and a change of speed. Do not simply speed up a walk and call it a run.

### Run

Identify contact, compression, push-off, flight, and the next contact in reference. Decide whether the intended style actually has flight. R6 lacks knee flexion, so use whole-leg swing and restrained translation to suggest the tuck, with a readable torso lean and arm rhythm.

Check the silhouette and ground clearance at contact and flight. Preserve support timing when blending from walk. Retune cycle distance and speed together.

### Jump and landing

Separate takeoff pose, airborne pose, and landing response. Use the character's actual motion state for an interactive jump; a fixed clip clock cannot know when every jump will land. Do not add a long anticipation that delays an already responsive jump input without a gameplay requirement.

At landing, place contact before the body absorbs the fall. Scale the response from observed impact conditions when the controller supports it. Settle into the next state, which may be a run instead of idle. The current bundled controller does not implement fall-speed weighting automatically.

### Attack or combo

Record startup, active interval, recovery, and any cancel window from the game. These are gameplay intervals, not mandatory pose counts. A combo may inherit its next load from the previous hit.

Block target-directed preparation, contact, follow-through, and exit. Put the hit event at the intended contact time. Keep the hand or blade trajectory consistent with the hit direction. Choose whether the feet plant, pivot, or step; do not let a visual lunge imply unimplemented world displacement.

Check the previous clip's exit and next clip's entry in motion. Match or intentionally blend pose and velocity. Do not copy a 30-frame recovery or a 4-frame return solely because another game used it.

### Emote or acting

Use intention, attention, and a change of thought. Let head and body timing communicate the turn in attention. Keep a quiet action quiet. Check whether the pose reads without facial animation; R6 body language carries much of the performance.

### Stand or weapon interaction

Treat a floating stand and a grounded user as different bodies. Use a supplied canon reference to decide whether the user leads, copies, commands, or remains still. Do not impose the recorded DIO solution on every stand.

Inspect grip transforms and the prop's pivot before posing. A two-handed weapon is a contact problem, not just matching shoulder angles. Rework the stance if maintaining both contacts creates visible R6 joint separation.

## A worked timing decision

Suppose the supplied gameplay contract specifies a 0.6-second planted right-hand hit with contact at 0.2 seconds. At an explicitly chosen 60 fps these are frames 36 and 12. The following is a planning example, not a measured clip or a universal recipe:

| Frame | Pose purpose | Contact and timing decision |
| --- | --- | --- |
| 0 | Existing guard | Match incoming pose; establish foot targets. |
| 7 | Loaded silhouette | Turn away enough to communicate direction; preserve gaze. |
| 10 | Strike breakdown | Place the hand on its intended path; begin larger spacing. |
| 12 | Contact | Meet the target and event time; keep support. |
| 15 | Follow-through | Continue or recoil according to the impact; preserve any active grip. |
| 24 | Readable recovery | Regain support while honoring the cancel contract. |
| 36 | Exit | Match the chosen next state. |

If the hand slows too early, inspect spacing from frames 10 to 12 and revise that interval. If the foot slides, fix contact rather than offsetting its key times. If the silhouette is weak, change the pose before increasing overshoot. Keep successful constraints fixed while repairing the visible failure.
