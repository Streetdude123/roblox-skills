# Animation craft for R6

The rules a professional animator applies, translated to R6 and to Poser fields. Sources are in [sources.md](sources.md); numbers marked "measured" come from [motion-metrics.md](motion-metrics.md) or the decoded clips. Frames are at 60 fps.

## Contents

- Poses first: the posing checklist
- Motion is the curve, not the keys
- Timing and spacing in frames
- Overlap: successive breaking of joints
- Moving holds and settles
- Follow-through and springs
- Game feel: anticipation, contact, hitstop, recovery, cancel
- Weight and support
- Arcs and paths
- Motion recipes: idle, walk, run, locomotion controller, jump and landing, attack and combo, guard and parry, hit reactions, emote, companions, weapons, procedural motion
- A worked example

## Poses first: the posing checklist

Motion cannot rescue a weak pose. Check every key pose from the player's camera and from the side:

1. **Intent.** One sentence: what the character does and why (a committed strike, a wary guard, a tired recovery).
2. **Line of action.** One C or S curve runs through the body. In R6 build it from the torso lean and roll, the head, the leg split and the arm line; a straight vertical body reads stiff.
3. **Contrapposto.** Shoulders and hips are not parallel. The torso roll and twist set the shoulders; the leg split and the weight foot set the hips.
4. **No twinning.** Arms and legs are not mirror images and do not reach the same angle on the same frame, unless the action is deliberately symmetric (a two-handed swing, a ritual, a wide V of both arms).
5. **Negative space.** Leave gaps between the arms and the torso and between the legs so the silhouette reads as a shadow.
6. **Weight.** In a held pose the mass sits over the support foot or between the feet. In motion it may leave the support when a step, a fall or a force explains it.
7. **Push it.** Push the lean, the twist and the reach 10 to 20% past natural, then pull back only what breaks the read. Game poses are hyper-real.
8. **Head and hands.** The head is tilted and turned with a purpose (it often leads a look or counters the torso to keep the eyes on a target); a hand is either doing something or hanging relaxed, never stiff.
9. **Clarity of overlap.** When limbs cross the body, the front one must still read.
10. **Measure what makes the pose read.** Find the feature that carries the read (hand separation, an angle off vertical, a distance from the chest) and push it until it reads. An arm X needs the hands far across and close to the chest: 0.57 across and 0.81 forward read as arms held out, 0.89 and 0.46 read as an X. A V needs the arms well off vertical: 26 degrees read as arms up, 39 as a V.

Block these poses with the curve stepped or as a strip (`EditStrip`), judge them, and only then do the motion pass.

## Motion is the curve, not the keys

A key is a pose; the curve between keys is the animation. Professional graph editors use spline tangents: a key in the middle of a move (a breakdown) keeps the speed flowing through it, and only an extreme (where a channel turns around) or a deliberate stop has a flat tangent. Maya's auto tangent does exactly this: flat at extremes, smooth on transitional keys, clamped so nothing overshoots between keys.

Poser's legacy eases do the opposite: `quad`, `cubic`, `quart`, `sine`, `expo` and `back` all arrive at zero speed, so every key is a stop, and a key that departs with an `out` ease jumps from zero to full speed in one frame (a jolt). That is the measured cause of the dead look.

- Write `curve = "spline"` on every new clip. Keys default to `auto` (the Maya behaviour). Use `flat` on a planted stop, the true apex of an anticipation that should read as a stop, or a hitstop pose. Use `smooth` (no clamp) when the curve may pass beyond a key between keys. `tn` from 0 to 1 tightens a key toward flat; below 0 loosens it.
- A breakdown key exists to shape the path or the timing (an arm going out and around the body, a torso squaring on the way through). It must not be a pose that the body stops in.
- Keep a named ease only for a shape the spline cannot make: a hard snap into a pose (`quart` or `expo` out), a stepped hold (`step`).
- Loops: close the last key on the first pose; the spline wraps its tangents so the seam keeps its speed.

## Timing and spacing in frames

Timing is when poses happen; spacing is how far the part travels each frame. Speed equals distance over time; slower reads heavier, faster reads lighter. Avoid even spacing (every frame the same distance): acceleration and deceleration carry the weight.

Starting ranges (60 fps; adapt to the gameplay contract and the reference):

| Beat | Frames | Notes |
| --- | --- | --- |
| Anticipation for a player's move | 1 to 8 (light), contact on frame 15 to 30 (heavy) | Responsiveness beats weight. The press is the expectation, so even one frame of anticipation reads; the pose must still read (a clear wind-up silhouette). Shipped light attacks hit on frame 2 to 7 (combat.md). |
| Anticipation for a telegraphed or NPC attack | 12 to 30 | Longer means more warning; tie it to the damage. An attack meant to be blocked on reaction needs about 26 frames (433 ms) from the clip start to the contact (combat.md). |
| Anticipation hold | 4 to 8 | Keeps winding 5 to 15% further (measured on the stand's heavy punch: 10 degrees over 6 frames). |
| Strike, apex to contact | 3 to 6 | Fastest frame in the middle (measured torso steps 10, 30, 45, 29, 9 degrees). |
| Hitstop on contact | about 8 / 12 / 16 by strength (0.13 to 0.27 s); shorter per hit in a barrage | The victim shakes (largest on the first frame) and the attacker creeps on a `warp` near 0; a dead `Rig:hold` freezes springs too. Never drop hitstop to zero on a melee hit (combat.md). |
| Follow-through past contact | 4 to 8 | Overshoot 5 to 10% of the strike (measured: 4 degrees torso and 9 degrees arm after a 124 degree whip). |
| Over-extended recovery hold | 6 to 12 | Drifts, then pops back. |
| Return to guard | 8 to 15 | Striking limb first, torso and head 1 to 3 frames behind. |
| Combo link | 20 to 30 per hit | End pose of hit N is the first pose of hit N + 1 (measured on the stand set). |
| Weighty stop | arrive, overshoot, settle | Each stage about half the amplitude and a couple of frames shorter; one or two bounces at most. |
| Head turn | 20 to 28 | A quick look or dart 8 to 12 with a one or two frame hold. |

For a strike decide where the fastest spacing is: before, at or through the contact. A committed hit accelerates into the contact and keeps going (the spline does this when the contact key is a breakdown between the apex and the follow-through). A soft contact brakes early (a `flat` contact key).

### Strike speed and retiming

- **The strike is the fastest motion in its window.** The eye reads the fastest motion as the action. Print each joint's peak speed and slow any anticipation, reload or counter-motion that outruns the striking limb: a raise that peaked at 3404 deg/s against an 876 deg/s whip had to be stretched to 0.24 s. Recheck after compressing or speeding a clip (a cast compressed from 2.2 to 1.6 s made a free-arm snap of 1955 deg/s against a 1777 whip; 0.03 s more fixed it).
- **Retime only before the hit.** To fit a reference strike to the game's hit time, keep the strike segment (about the last 0.12 s of fist travel; four reference punches travelled from the pull-back's end to the hit in 0.112 to 0.119 s) at its authored speed, stretch only the pull-back, and play the rest as authored. Never stretch a whole wind-up past about 1.5 times: uniform stretches up to 2.18 read slow, pull-back-only stretches of 2 and 3.3 kept the snap.
- **A speed cap when compressing.** Cap joint speed near 1500 deg/s (25 degrees per frame at 60 fps): pin the hit key, retime gaps that exceed the cap and take the time from the slower gaps. Squeezing a wind-up from 0.28 to 0.18 s drove an arm to 4683 deg/s, a snap; under the cap no joint passed 50 degrees per frame and most stayed under 35. The cap is for compressing a clip; a swung weapon tip may turn 42 to 86 degrees per frame on its strike frames alone (weapons.md).
- **Speed a move up per beat.** Shorten the holds most and the wind-up and recovery a little (wind-up 0.8x, a channel from 1.0 to 0.62 s, recovery 0.93x), compress after the hit too, then measure the lock time in Play. Uniform scaling hurries the beats that carry the read; per-beat scaling cut a lock from 1.72 to 1.23 s, and pre-hit 0.643 with post-hit 0.65 gave 0.46 to 0.50 s punches that chained on a 0.42 s cooldown.
- **More range without losing the posture.** Scale each channel's change about its first frame (a one-shot) or its mean (a loop), never about zero, then retime under the speed cap (an uppercut scaled 1.4x kept its hit key under 1520 deg/s; a walk's arm swing scaled 1.3x about its mean).

## Overlap: successive breaking of joints

Things do not stop all at once: the part that drives moves first and the parts it carries follow. Along a chain each link trails the one before it; the tip lags most. At a reversal the base turns first while the tip is still travelling (the blade of grass, the pendulum).

- Decide the driver per beat: the hips and torso drive a punch or a throw, the head drives a look, the hand drives a reach, the feet drive a step.
- Offset the carried parts 1 to 2 frames per link (increasing: 1, 2, 3). In Poser use `lag` for a whole-curve offset, or move individual keys by hand when only one beat should trail.
- Keep hard contacts synchronised: the striking fist and the torso land on the contact frame; a two-handed grip never separates because of a lag.
- Break the three times apart: when a part starts, when it arrives and when it settles. They do not need the same offset.
- Measured overlap in the stand set: the arms trail the torso 5 to 8 frames in the barrage and the heavy punch; the head trails 2 to 6 frames in the idles.
- A part that acts on purpose does not trail either: a hand pulled back to guard during a punch was carried 1.95 studs out to the side by the torso's turn when it wore a 2 frame lag.
- A head that holds the eyes on a target leads, it does not trail: it counters the torso twist on the torso's own frames (measured: head -49 against torso +48 on the same five frames of the stand's right punch). A head that lagged four frames in the example cross pointed 40 degrees off the target at the contact.

## Moving holds and settles

A perfectly static pose looks lifeless within a few frames. A moving hold keeps the pose alive:

- It drifts in the direction of the last momentum, then settles: a key at the start of the hold and a second key 5 to 15% further along, with `auto` tangents so the part glides in and out.
- Breathing: the chest and shoulders rise and fall; it can build momentum into the next action.
- The head follows the same momentum as the body; an unmotivated head move breaks the weight.
- Different parts settle at different times: the hips settle first, then the arms, the head last.
- A key pose that is hard to see in play is shorter than the time it takes to read: hold it longer (0.3 s more made a load readable) and move the chain and lock times by the same amount. Never key a hold as a flat pose of all joints; a flat hold made a follow-through read as a still.
- Mark the climax of a long hold with one accent on its beat (the torso tips a few degrees, the arms drop) that settles within a few frames (0.08 s), and keep the hold around it moving; holds that crept 1.5 degrees every 0.15 s measured 61% still.
- A channelled or stirring move needs about 20 degrees per key with keys about 0.3 s apart and the torso and head swaying; a spline stops at each turnaround, so 10 degrees every 0.35 s left still runs while 20 every 0.3 s gave still 0. In a long channel, let the casting hand draw the effect's own motion (circles of about 0.1 s per key round a cone) with the head and torso following it (rest 54% to 41.4%, contrast 10.8 to 6.1).
- `life` adds slow noise to the upper body so a long hold is never frozen; it does not replace a drift that has a direction.
- A long dramatic hold (a 3 s sword hold) still needs motion over 12 deg/s somewhere. A slow drift plus a 0.4 degree tremble measured 35% still with a 1.4 s still run; a 1 degree tremble growing to 2.4 and a 1.3 degree breath every 1.6 s cut it to 18% and 0.13 s. Ramp a tremble in and out over 0.1 to 0.3 s, or it pops when it switches. In a looped hold, sample the noise on a circle (`math.noise(cos(a) r, sin(a) r, seed)` with `a = 2 pi t / length`), or it jumps at the loop seam.
- Show charging as a hold that keeps deepening with a growing tremble (torso -60 to -70, crouch 0.55 to 0.64, tremble 0.6 to 1.3 degrees at 12 to 15 Hz). Under a heavy weight overhead, arch the torso back (17 to 18), tip the head forward (13) and tremble at the top (1.2 degrees on the arms, 0.6 on the torso, 14 Hz).

## Follow-through and springs

Follow-through is what the body does after the main action stops: loose parts keep going and come back. `springs` simulate it on the sampled curve (second order dynamics: f is the speed of response, z the damping, r the initial response; r above 1 overshoots at the start, below 0 anticipates):

| Preset | f, z, r | On a 100 degree snap in 0.08 s | Trail on a steady move | Use on |
| --- | --- | --- | --- | --- |
| lead | 8, 0.6, 1.25 | overshoots 6, settles in 7 frames | 0.5 frame | a carried part that should stay close (a weapon, a guard hand) |
| follow | 6, 0.5, 0.5 | overshoots 8, settles in 10 | 1.2 frames | the head in an idle or a reaction, a carried arm |
| drag | 5, 0.45, 0 | overshoots 12, settles in 12 | 1.7 frames | the free arm; for free-hanging cloth, hair or a cape use a custom `{f = 0.8 to 1.9, ...}` (body-mechanics.md, swing periods) |
| heavy | 4, 0.65, 0 | no bounce | 3.1 frames | a heavy weapon arm, a big body |

A custom table `{f = , z = , r = }` works too. Springs react to every key, so a creep hold also settles softly. They run in clip time: a `Rig:hold` freezes them, a hitstop `warp` near 0 slows them almost to a stop, and a slow-motion time scale slows them.

Do not put a spring on a part that must be on its key at a contact. Measured on the example's torso (a 76 degree turn into the contact at 850 deg/s): `lead` arrived 7 degrees short, `follow` 20, `drag` 34, `heavy` 47. The only spring that arrived on time (r = 2) overshot a stop by 16%, which reads as rubber. Key the leading part's overshoot instead: one key past the contact 4 to 8 frames later, then a drifting hold.

## Game feel: anticipation, contact, hitstop, recovery, cancel

- **Response first.** Too little anticipation and a move has no weight; too much and it feels unresponsive. Keep a player's anticipation short and readable; put the weight into the contact, the hitstop and the follow-through instead.
- **Separate the felt timing from the system timing.** The hit event can come early while the animated follow-through stays long; give the player control back before the clip ends (a cancel frame) and let the rest blend out. Open cancels at the hit event with about 0.05 s of server slack for network delay. Keep a move's lock near one second; in a cinematic move put the movement cancel inside its last slow beat. End the server's busy window about 0.3 s before the clip ends. Use one number for a combo window on the input and on the server, or input accepts clicks the server rejects.
- **Contact.** The hit event sits on the contact key. Hitstop by strength: about 8, 12 or 16 frames (0.13, 0.2, 0.27 s), shorter per hit in a barrage; the attacker creeps through it on a `warp` segment near 0 (0.05), never a dead `Rig:hold` (combat.md, "Hitstop"). Push the victim or the weapon further than reality to sell the force. When the task includes hit feel, a landed hit gets its hitstop, a small camera shake and a louder, bassier hit sound (about +6 dB); without impact cues a hit reads as a touch. Align each swing sound's peak to the hit frame (start the file partway in if needed), and time every hit-linked event (step, sound, hit) from the same wind-up value as the clip, so a retime moves them together.
- **Recovery.** The recovery pose shows the momentum: over-extended, off-balance. For a cancellable move stay in it a little longer than feels natural, then pop back quickly. Never scale the recovery linearly back to idle; a slow even return blurs when the character can act again and counts as unison (6.45 stops/s against 3.23 with a pop). A finisher may return slowly (the measured sword hits spend 30 of 50 frames returning) if the return is one continuous deceleration with the parts offset.
- **Chains.** A combo is one motion: each hit starts where the last ended, and the recovery of one hit is the load of the next. Hits 0.35 to 0.45 s apart (0.36 to 0.39 measured) read fast and heavy.
- **Power.** Stronger moves use fewer, faster transition frames and a bigger wind-up silhouette; long slow movement reads as weak.
- **Telegraph a long wind-up, do not slow the strike.** When the server needs a long wind-up, fill it with a readable load and keep the strike fast. For 0.4 s: pull-back 0.03, load 0.11, a moving hold winding 5 to 10% further until 0.31, strike 0.31 to 0.40, overshoot at 0.46, the fist pops back first, a bouncing guard tail. Measured: rest 35 to 45%, contrast 5 to 8, still 0 to 2%, unison under 5.3/s, feet 0 slide. A load that stops dead reads as a freeze.
- **Hits meant to be parried or dodged** on reaction land about 0.43 s (26 frames) after the swing starts (combat.md). 0.24 s is an absolute floor (human visual reaction is about 0.25 s; hits at 0.18 s left the player no time); an eight-parry chain against an AI defender reacting in 0.10 to 0.14 s worked at 0.24 s (0.32 for an uppercut). An AI defender's reaction must fall inside the wind-up when the parry is checked at the hit.
- **A slow ability gets interrupted.** Shorten press-to-impact by speeding the slowest hang (a slam's hang from 0.12-0.18x to 0.42-0.5x cut press-to-impact from 2.45 to 1.19 s), and give armour through its phases if it must land.
- **A launcher's rise reaches its apex before its chain time.** The next clip replaces it and the rise stops there (a follow-up at 0.4 s left the attacker at +7.3 under a victim at +9).
- **Each state gets its own clip, at least as long as the state.** A hurt, block, parry or stun clip lasts at least as long as its gameplay state (0.62 s for a 0.6 s stun, 0.42 s for a 0.25 s parry, 1.0 to 1.13 s for a 1 s stun): ending early leaves a stunned body idle, ending late animates a player who has control. A block-and-parry kit needs a parry stance, a walking guard, a raise, a block recoil, a lower, a parry swat, a parried recoil and a guard break; a directional dash needs a clip per direction per held state. Two moves that share one clip read as the same move.

## Weight and support

Choose the support at each beat and keep the mass over it in held poses. Show the sequence of effort: prepare support, apply force, accelerate, absorb or release, regain support. A heavy action can strike fast after a demanding preparation; slowing the whole clip does not make it heavy. The centre of mass rules (balance over the support area, push before speed, a braced stop, rotation about the COM, a ballistic airborne path) are in [r6-mechanics.md](r6-mechanics.md) and lesson-videos.md section 5.

In R6, compression is a torso drop with the legs standing flat on their floor targets (`Feet.flat`): a leg may slide up into the torso or off its socket while at least half of its top stays under the torso and it touches (SKILL.md, feet rule). Lean from the waist (the `waist` offset), or the hips swing back and the feet slide. Turning the torso turns the hips around the feet; plan the drop with the turn (`Feet.gap` gives the need).

- **Force is range of motion.** A big wind-up and follow-through of the whole body and the weapon read as force; a wrist turn in front of the chest stays weak at any timing. Ranges that read: the torso turning 56 one way then 64 the other; a slam arching 32 back then folding 42 to 46 forward with a 220 degree blade whip; a cast coiling 40, arching 26, then throwing 36 to 38 forward with a 1.45 stud step. Check the hand travel, the weapon arc and the torso range before tuning timing.
- **A move that reads small needs the whole body.** Before tuning anything else, add a deep coil with a drop and a turn, steps and lunges, a real leap on one gravity parabola (its own hang time near the apex, no added hold), spins, and a follow-through that keeps sinking. Arm-only stationary moves and a half-stud hop read weak; a rebuilt flurry (0.6 s coil, drop 0.64, 64 degree turn, a lunge per cut, a 311 degree hop spin) measured rest 34.5%, contrast 3.3.
- **Travel that reads.** A lunge's root travel must be a stud or more to show from the player's camera (a 0.26 lunge did not; step-ins of 1.15 to 2.95 did). A wide stance must be wide sideways as well as along the target line; from behind, feet split only along the line overlap and look narrow.
- **A heavy weapon rises slower than it falls.** Make the lift about five times the down stroke (0.40 s against 0.08 s read as real weight; equal times read as a light prop), with a moving hold at the top and no ease into the contact.

## Arcs and paths

Track the part that carries the action (the fist, the sole, the blade tip, the head top) in world space; a good joint curve can still draw a bad path. Natural motion travels on arcs; a jab may be near straight. Add a breakdown to control a path (a hand going out and around the chest, a blade clearing the head), not to add keys. Poser interpolates Euler channels: a turn over 180 degrees needs an intermediate key in the chosen direction. Arms that move from the sides into a pose in front of or across the body pass through the torso unless a breakdown key sends them out and forward first.

## Motion recipes

### Idle or held stance

1. Block an expressive rest pose: the loaded foot, the gaze, the hands' purpose, contrapposto.
2. One engine: a breath on the torso (lean 2 to 4 degrees, a 0.03 to 0.04 stud sink), 3 to 5 s for a calm idle (a resting adult breathes 12 to 20 times a minute; the reference idle uses 3.0 s), 2 to 2.5 s after exertion. The inhale is slower than the exhale. The head and arms answer it about a fifth of a cycle later at half the size (measured on the reference idle in idle-run-land.md); in Poser use `lag`. A flat wave on every joint measured still near 100% and contrast near 1; with a head lag of 0.25 s, an arm lag of 0.45 s and a few beats it measured frozen 0 and contrast 3.9.
3. Add a few motivated beats: a glance with a small anticipation dip, or a prop pulled back, hitched and settled on a spring.
4. Add `life` of 1 to 1.5 degrees. Frozen must read 0%.
5. A professional idle that looks still is moving. Measure its small motion and copy it: a traced commissioned idle moved the torso about 1.3 degrees, the head up to 4.8, the arms 4 to 6, the legs 2 to 3, a held weapon 4 to 7 and the torso height 0.04 studs.
6. For long idles add macro variation every three to six loops (a weight shift to the other leg, a look around, a fidget) and blend it in so the body is never still.

### Walk

- **Keyed poses, not sines.** Author a walk as keyed poses (contact, down, passing, up) calibrated against a measured hand-keyed reference, with splines, per-joint lags, small life, the waist offset and a plant pass. Never generate a cycle from symmetric sines, with or without springs: lockstep sines give even spacing and no weight shift, and hand-keyed legs swing further back than forward.
- **Support.** Keep each foot planted more than half the cycle with double support at each footfall: about 55 to 60%. At 50% the weight never settles and under 55% the walk reads as tiptoeing (20 of 40 frames down read as barely touching; 24 of 40 over 3.2 studs read planted). Roll the planted foot on its lowest edge and let the torso height follow the legs' reach: a smooth bob of the body's own, kept under what the legs can reach, with no hard clamp. Never push a planted leg down into the floor to keep it planted.
- **Landmarks.** Support transfer, toe-off, swing clearance. The torso bobs by geometry (lowest about 2 frames after contact, highest after passing, an even bob near 0.10), leans 4 to 7 degrees, twists 3 to 5 against the hips with the head countering; arms swing opposite the legs 30 to 40 degrees with a wrist twist that follows the swing, trailing the legs by a frame or two. Measured community walks: rest under 8%, contrast under 2.
- **Remove robotic tells.** No part a pure sine in lockstep. The weight shifts over the stance foot (sway and roll toward it, feet solved so they do not slide sideways). The head, the free arm and a carried prop trail through springs or lags instead of copying the torso. A walk bobs highest over the stance foot (it vaults over a stiff stance leg); a run bobs lowest there (it compresses into it).
- **Starting amounts for a walk's life.** Torso roll about 3.5 degrees toward the stance foot, sway 0.05 to 0.07, phased from the first harmonic of the sole heights; head counter-roll about 0.7 of the torso, 2 to 4 frames late; the free arm out 4 to 6 degrees; a carried arm bouncing 4 degrees 3 frames behind the bob; springs at 3 to 6 Hz with damping 0.4 to 0.6. Keep a plain walk restrained (knee lift near 0.32, twist near 8): a 0.6 knee lift, a 12 degree twist and a big bob on a 1.24 s step read as overacting.
- **A strong or heavy character keeps the torso nearly level.** Roll about 1 degree (range about 2), hip sway under 0.05, chest yaw swing 5 to 6, the free arm's arc about 2; the life goes into the legs, the bob and the free arm. A roll range of 6.9, a sway of 0.26 and a 16 degree chest swing read as a shaky toy.
- **Cycle and speed.** Pick the cycle from the game speed: 1.0 to 1.1 s reads unhurried, about 0.84 s brisk (SKILL.md, locomotion speed). To plant a reference walk at a slower move speed, slow its time and scale its leg swing together (0.6x time and 0.6x legs planted 1.39 studs/s for a 1.4 move), then measure the plant speed against the move speed in Play.
- **Choosing a walk reference.** Play each candidate on the target character in side strips beside the current walk, after measuring its plant share on that rig, and say which never plant (on 2.4 stud legs most community walks planted only 4 to 25% of the cycle). Prefer a hand-keyed cycle with a back kick after toe-off, a driving knee and a wide arm swing, re-keyed as a cyclic spline that settles where the legs cross, so a stop has a clean pose.
- **Styles and directions.** Give each character class its own walk: a style table of cyclic channels (leg swing, knee, leg roll, dip, lean, twist, roll, nod, arm swing, arm out, arm lag) with its own stride, on one solver. If the game turns the hips toward the move, one walk serves all directions; play backward as the forward clip reversed. A run strafe may turn the body about 90 degrees while a walk strafe keeps the chest forward; that is taste, so show both.
- Test starts, stops, turns and speed changes.

### Run

- **Judged by the legs.** Swing the leg up to about 80 degrees against the torso and pull it 0.7 to 0.95 studs up into the hip so it reads as a knee; kick the back leg to about -50 after push-off; keep each foot on the floor about 25% of the cycle so the body flies between steps; ride high with a shallow dip (0.14 to 0.31). A cycle near 0.66 to 0.7 s with the free arm near plus or minus 55 to 62 and a lean of 19 to 23 degrees read well; a 0.9 s cycle with a 15 degree lean and duty 0.34 read as a walk, and legs kept under the body read as a slow shuffle.
- **Phases.** Contact, compression, push-off, flight, next contact. R6 has no knee: suggest the tuck with whole-leg swing (-78 to +54 in the reference run, which leans 26 to 28) and a lifted leg translation up into the torso; the hips twist with the head countering. Retune cycle distance and speed together; never a sped-up walk.
- **The head stays level.** Hold the head level against the torso's lean and roll, dip it twice per cycle with one counter-twist, pump the free arm 1 frame late and give a shouldered prop a lagged bounce. A head that rides the bob and roll reverses with it and reads as shaking (2 to 5 reversals per channel is the target).
- Torso roll in a run starts near 4.5 degrees toward the stance foot (about 1 for a strong character) with sway near 0.05.

### Locomotion controller

Play the walk at speed / reference, switch to the run above a threshold, crossfade by a state table, and choose a light, medium or heavy landing by the drop height from the fall start (near 4 and 15 studs); a professional movement pack worked this way (walk rate speed / 14.5, run at 1.3x from WalkSpeed 20). If the game pauses a clip when the body stops, every frame of it must read as the pose, because the player sees whatever frame it stopped on.

### Jump and landing

- Separate takeoff, air and landing. Use the character's real motion state; a fixed clock cannot know when a jump lands.
- **A quick dip and a long rise.** A 0.36 dip at 0.13 s and the apex at 0.58 s of a 1.25 s rise read as a jump, not a float (still 5.1%, rest 34.9%, contrast 3.2).
- **A leap.** Crouch with the arms swept back, throw the arms up on the takeoff, brace on the landing (torso forward about 30, head down, hands pressed down and forward). A powerful leap: a long crouch load (about 0.9 s) with a tremble, a forward takeoff, a tuck, an arch of 46 to 50 with the weapon up and back, an overhead slam on the landing (rest 33.9%, contrast 4.6, slide 0.04).
- **One parabola.** Move an airborne root on one gravity parabola with no hang at the apex; a leap eased into its apex floats. A gravity lower than the game's is a style choice; state it.
- **A jump that does not move the gameplay root** lifts the torso and both feet with an air curve at least the rise, starting as the legs straighten (weapons.md, "Cinematic moves").
- **Landing.** Contact first, then the absorb (the measured landing drops 1.1 studs by 0.10 s while the torso pitch arrives at 0.23 s, separate arrivals), then settle into the next state, which may be a run. The arms and head carry through the contact (lesson-videos.md, through motion).

### Attack or combo

- Record startup, active interval, recovery and cancel window from the game. Block a target-directed anticipation, contact, follow-through and exit. Put the event on the contact. Choose whether the feet plant, pivot or step; a back heel may pivot on the ball (a foot target whose yaw changes). Check the previous clip's exit and the next clip's entry in motion.
- **Punches are pistons.** The arm angle holds through the strike and the arm slides 0.3 to 0.6 studs while the torso whip does the reach (measured on reference punches).
- **Aim punches in root space** allowing for the lean and the drop: a lean of 11 to 16 and a drop of 0.24 to 0.38 need an aim dy of 0.6 to 0.78 for a chin at root y 0.8 to 1.0. Turn the torso so the striking shoulder drives forward. Solve straight-punch breakdowns onto the strike line and check the fist paths by forward kinematics: aimed as if the shoulders were at rest, a jab and a cross landed at chest and belly height while the strips looked fine.
- **A hook reads from the torso.** The arm moves in the horizontal plane (lift 16 to 62, side -98 to -132) while the torso turns about 80 degrees, with breakdowns so the fist does not dip. Across a flurry, keep the torso twisting further each hit (12, 17, 22) with staggered keys; rocking back per jab stops the torso and arms together (unison 6.21/s against 3.45).
- **A wide throw loads across the body.** The throwing arm high to the opposite collar, the free arm low behind the hip, the chest turned away (26 degrees), the body dropped (0.35), the hand 0.86 across at collar height; then fling both arms out past the body through mid keys that keep them in front.
- **Dash and strike.** Crouch and push (0.1 s), dash on a monotone root curve leaning about 22, jabs 0.1 s apart, an overhead wind-up (0.14 s), a throw with a lunge, the feet stepping back (rest 40.4%, contrast 4.2).
- **Overhead whip cast.** Raise up and back (0.24 s), a moving coil (0.1), the whip over (0.12), a follow-through 0.12 later, a moving hold, the recovery; the free arm forward on the coil, back to the hip on the launch, forward in the recovery; the lead foot steps on the whip. The opposing free arm cut rest from 47.6 to 43.0%.
- **A spin from one yaw curve.** Drive the torso, the head, the arms (torso-frame directions turned by the yaw) and the feet (turned by the yaw plus the stance's own torso turn) from one yaw curve; forgetting the stance turn gave 61 degree leg twists. Give the head about 0.35 of the yaw to hold a target, or let it lead by about 25 degrees.
- **Two versions of a big attack.** A full-body standing version with a planted step, and an upper-body version for moving that keys only the arms, the head and the torso rotation, so locomotion plays under it; planted leg keys skate or freeze the legs in a run.
- **Beams and projectiles** with an over-the-shoulder camera launch from beside the head or above the shoulder, with their visual weight along the beam axis; fired straight ahead at shoulder height they start hidden behind the body.

### Guard, block and parry

- **A guard is a full-body brace.** Feet wide, the body dropped 0.42 to 0.5, the torso 15 to 18 forward and about 20 into the shield, the head behind the rim, joints lagged 1 to 7 frames, a tremble on the shield arm, plus an upper-body copy for walking. An upper-body guard on idle legs with symmetric arms reads as a stiff toy. For a calmer stance cut the drop, lean and turn by about a third (0.28, 10, 16) and halve the tremble.
- **An R6 boxing guard** puts the fists by the face with the arms pointing up 20 to 35 degrees; with no elbow only a raised arm brings the fist to the face, and near-level arms (lift 80 to 84) put the fists 2 studs ahead and read stiff.
- **The parry or block window opens on the press**, not after the raise (a 0.3 s raise before the window made presses 0.3 to 0.5 s early). Keep the raise short (the weapon up by 0.1 s of 0.2) with an overshoot: the arms start about 35 degrees low in front, snap about 5 past the guard by 0.07 s, settle and lean in. A guard that appears in pose reads as a pop. Lock the guard out briefly after an attack's chain time (0.15 to 0.3 s) and queue a held press, or hit and block land on one instant.

### Hit reactions

- **Timing at 60 fps.** Snap by frame 3 (the torso with the push, the head 1 frame later, the arms flung 2 frames late, the knees give), stagger by frame 9 going about 30% further, a catch step by frame 18 (the push-side foot out, the body folding against the push), overshoot at 28, base at 37. Force reaches the torso first; the catch step regains support. Measured: torso 16 degrees, catch foot 0.45, rest 30 to 34%, contrast 4.9 to 6.1.
- A knock into a guard break or a reel lands within about 0.2 s (a 0.53 s knock-in read soft). Strengthen an additive flinch by scaling its lean, not its twist (scaling a whole flinch 1.6x turned it 103 degrees).
- **One parametric builder.** Build reactions from the push side in the victim's space on each body base, the victim keeping its facing and pushed along the attacker's, with less arm flail under a heavy weapon. In a combo, stun the victim until the next hit plus about 0.25 s at walk speed 0 and slide it as far as the attacker steps (stuns 0.77 to 1.27 s, slides 0.8 to 1.3).
- One source clip may serve two linked roles at two lengths: a guard break for the defender and its first second as the attacker's reel.

### Emote or acting

Intention, attention and a change of thought. The head and the body timing show the turn of attention; a quiet action stays quiet. R6 body language carries the performance without a face. When a character stands and commands while something else acts, keep the body planted and quiet: breath and life only; a pumping body under a still intent reads as moving for no reason. The platform's catalog emotes (or their R6 conversions) are a good reference set for gestures and moods: they are built to read on small avatars from a game camera.

### Companions and floating bodies

- A floating companion and its grounded user are different bodies. Decide from the reference whether the user leads, copies, commands or holds still. When the user strikes with the companion, copy the companion's torso, head and arm channels, scale them down as a start (torso roll about 0.45, arm translation about 0.4), solve planted legs and contacts on the target rig, inspect, and start the user's copy about 3 frames ahead, so the user throws and the companion's fist lands. Scale factors only start the fit; they are not retargeting (pipeline.md, importing sequences).
- A floating body moves as one mass: all joints in phase, 2 to 3 times a grounded idle's limb amplitude, a bob near 0.27 studs (measured on the stand clips in the-world-clips.md). Its punches are pistons: the arm angle held, the arm sliding 0.3 to 0.6 along itself, the torso whip reaching.
- Bring a summoned companion in on one continuous root path that ends in its guard; never pop a guard pose in. One entrance that read well: out from behind, a limb flare at the top of the arc, a swoop into the guard, a hover with trailing arms. Take the beats from the reference.
- A floating prop (a book, an orb) follows as a damped spring toward an anchor beside the body (frequency 1.7, damping 0.85 trailed a walk and settled on a stop), with bob and sway on unrelated periods and a lean from its velocity. Do not orbit it; an orbit reads mechanical.

### Weapons and props

A two-handed weapon is a contact problem: solve both grips in prop space and rework the stance if R6 opens a joint. Everything else is in [weapons.md](weapons.md).

### Procedural motion

A procedural flail runs periodic functions at unrelated rates (arm circles 1.8 and 2.1 Hz, kicks 2.4 Hz) with an impact jolt, panic bursts and a final drop pose; unrelated rates never sync, so no loop shows.

## A worked example

`scripts/ExampleClips.lua` is a right cross from an orthodox guard (0.72 s, contact at 0.29):

| Frame | Beat | What moves |
| --- | --- | --- |
| 0 | Guard | Left side to the target, hands up, weight low, breathing. |
| 7 | Load | Sink onto the back leg, shoulders turn away, rear fist draws back. |
| 7 to 12 | Moving hold | The load keeps winding 6 degrees; nothing freezes. |
| 15 | Breakdown | Hips and shoulders square, fist half way, speed flowing. |
| 17 | Contact | Shoulder through, body sits down 0.36, fist pistoned 0.35, lead hand to the chin, back heel pivots out 30 degrees. |
| 21 | Follow | The body keeps going past the contact; springs overshoot and settle. |
| 21 to 27 | Extended hold | Drifts 2 degrees further. |
| 33 | Pop back | The fist returns first; torso and head trail. |
| 43 | Guard | The chain pose for the next move. |

Layers: `curve = "spline"`, no lag (the lead hand is pulled back on purpose), `springs` (lead arm `follow`), keyed overshoot on the torso and the fist, head keys that counter the torso on its frames, `life = 0.6`, `post = Feet.post` with the heel pivot as a function of time. The example predates `Feet.flat`; use `Feet.flat` in new clips. The measurements are in motion-metrics.md.
