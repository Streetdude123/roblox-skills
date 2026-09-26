# Animation craft for R6

The rules a professional animator applies, translated to R6 and to Poser fields. Sources are in [sources.md](sources.md); numbers marked "measured" come from [motion-metrics.md](motion-metrics.md) or the decoded clips. Frames are at 60 fps.

## Contents

- Poses first: the posing checklist
- Keys, extremes and breakdowns
- Motion is the curve, not the keys
- Timing and spacing in frames
- Snap and hold
- Anticipation in stages
- Exaggerate fast actions
- Overlap: successive breaking of joints
- Moving holds and settles
- Follow-through and springs
- Game feel: anticipation, contact, hitstop, recovery, cancel
- Weight and support
- Arcs and paths
- Smears and multiples
- Limited timing for anime hits
- Jumps, entrances and landings
- Weight by character
- Staging for the viewer
- Motion recipes: idle, walk, run, jump and landing, attack and combo, emote, stand and weapon
- A worked example

## Poses first: the posing checklist

Motion cannot rescue a weak pose. Check every key pose from the player's camera and from the side:

1. **Intent.** One sentence: what the character does and why (a committed strike, a wary guard, a tired recovery).
2. **Line of action.** One C or S curve runs through the body. In R6 build it from the torso lean and roll, the head, the leg split and the arm line; a straight vertical body reads stiff.
3. **Contrapposto.** Shoulders and hips are not parallel. The torso roll and twist set the shoulders; the leg split and the weight foot set the hips.
4. **No twinning.** Arms and legs are not mirror images and do not reach the same angle on the same frame, unless the action is deliberately symmetric (a two-handed swing, a ritual, the ZA WARUDO V).
5. **Negative space.** Leave gaps between the arms and the torso and between the legs so the silhouette reads as a shadow.
6. **Weight.** In a held pose the mass sits over the support foot or between the feet. In motion it may leave the support when a step, a fall or a force explains it.
7. **Push it.** Push the lean, the twist and the reach 10 to 20% past natural, then pull back only what breaks the read. Game poses are hyper-real.
8. **Head and hands.** The head is tilted and turned with a purpose (it often leads a look or counters the torso to keep the eyes on a target); a hand is either doing something or hanging relaxed, never stiff.
9. **Clarity of overlap.** When limbs cross the body, the front one must still read.

Block these poses with the curve stepped or as a strip (`EditStrip`), judge them, and only then do the motion pass.

## Keys, extremes and breakdowns

Pose to pose works in levels: keys (the story poses), then extremes (the farthest point of each move in each direction), then breakdowns (how one extreme turns into the next), then the curve does the rest. Finish each level before the next. In the studied Moon Animator reference ([study-moon-practice2.md](study-moon-practice2.md)) every key is an extreme; no key is a neutral pose.

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
| Anticipation for a player's move | 4 to 8 | Responsiveness beats weight. The pose must still read (a clear wind-up silhouette). |
| Anticipation for a telegraphed or NPC attack | 12 to 30 | Longer means more warning; tie it to the damage. |
| Anticipation hold | 4 to 8 | Keeps winding 5 to 15% further (measured on the stand's heavy punch: 10 degrees over 6 frames). |
| Strike, apex to contact | 3 to 6 | Fastest frame in the middle (measured torso steps 10, 30, 45, 29, 9 degrees). |
| Hitstop on contact | 4 to 12 (0.07 to 0.2 s) | `Rig:hold`; springs freeze too. Pair with a camera kick and a flash. |
| Follow-through past contact | 4 to 8 | Overshoot 5 to 10% of the strike (measured: 4 degrees torso and 9 degrees arm after a 124 degree whip). |
| Over-extended recovery hold | 6 to 12 | Drifts, then pops back. |
| Return to guard | 8 to 15 | Striking limb first, torso and head 1 to 3 frames behind. |
| Combo link | 20 to 30 per hit | End pose of hit N is the first pose of hit N + 1 (measured on the stand set). |
| Weighty stop | arrive, overshoot, settle | Each stage about half the amplitude and a couple of frames shorter; one or two bounces at most. |
| Head turn | 20 to 28 | A quick look or dart 8 to 12 with a one or two frame hold. |

For a strike decide where the fastest spacing is: before, at or through the contact. A committed hit accelerates into the contact and keeps going (the spline does this when the contact key is a breakdown between the apex and the follow-through). A soft contact brakes early (a `flat` contact key).

## Snap and hold

The studied reference moves between keys in 0.03 to 0.15 s (2 to 9 frames at 60: the throw's whip one capture frame, its release 0.07 s, the lunge 0.13 s, the sword draw 0.15 s) and holds between them for 0.17 to 0.9 s while the pose drifts. The pro sword kit shows the same shape at gameplay scale ([attack-timing.md](attack-timing.md): a snap into the wind-up, a 2 to 4 frame hold, a 3 to 4 frame strike).

- The snap is a short segment between two keys a few frames apart. Spline keys carry the speed; use `quart` or `expo` only for a hard arrival.
- The hold is a moving hold: a second key 5 to 15% further along with `auto` tangents. Never a frozen pose, never a slow ease back toward rest.
- Snap from extreme to extreme. The reference never spends a slow segment between two extremes; its slow parts are the drifting holds and the slow out after a whip.
- In a gameplay one-shot the checks still apply (still 5% or less, because the holds drift). A cinematic sequence with long holds may pass contrast 10; report it and say why.
- Real people are slower than keyed game strikes: measured real punches take 9 to 17 frames from the low point to full reach (boxers 8 to 11) and return in 8 to 27 (boxers 15 to 30); the pro stand strikes take 3 to 6. Real fists are fastest 3 to 6 frames before full reach and hold 3 to 6 frames there (mocap-timing.md). Keep the real order and the hold; compress the strike on purpose.

## Anticipation in stages

A big action winds up in stages: a load, a wind-up, a further wind-up, then the snap. The studied throw: a load 0.17 s, a turn away 0.17 s, a hard twist away 0.17 s, a whip of one capture frame, a slow out of 0.3 s as the arm pushes forward, then a release snap. A punch can wind out, wind up, then throw the other arm back before it strikes (Alan Becker, sources.md).

A player's gameplay move keeps its whole anticipation inside the 4 to 8 frame window; use stages on heavies, finishers, enemy telegraphs and cinematics.

`scripts/ExampleMoves.lua` keys that throw on a stock R6 (1.45 s): ready, the ball up to the face with a lean back (0.12), the arms spread as the body turns away (0.29), a coil with the arm cocked up and back while the front foot steps (0.47), a two-frame whip over the top (0.53 to 0.56), a push forward with shrinking spacing (to 0.86), the release snap (0.93), a fold (1.06), a recoil (1.18) and the step back to ready. Measured offline: every active joint peaks on the whip (spread 0.9 frames), contrast 8.0, rest 49.2%. In a draft the first wind-up turned the arm 140 degrees in 0.1 s, faster at the shoulder than the whip (1861 against 1729 degrees a second), so `Poser.check` read a spread of 7.6 frames; in world space the whip was still 1.7 times faster, because the torso's turn adds to it. Judge the hierarchy in world speed (`scripts/faults.py`, "outruns the strike").

## Exaggerate fast actions

An extreme that is on screen for one frame reads weaker than the same still frame. Hold the extreme 2 to 4 frames as a moving hold, or push it further. Push until it is too much, then pull back.

Range of motion carries force. Measure it (`range` and `sweep` in motion-metrics.md) and compare with a pro clip of the same kind: the pro stand strikes turn the torso 77 to 120 degrees in 0.33 to 0.5 s. Two reviews flagged strikes that moved too little (2026-09-22 and 2026-09-24, project-style.md).

## Overlap: successive breaking of joints

Things do not stop all at once: the part that drives moves first and the parts it carries follow. Along a chain each link trails the one before it; the tip lags most. At a reversal the base turns first while the tip is still travelling (the blade of grass, the pendulum).

- Decide the driver per beat: the hips and torso drive a punch or a throw, the head drives a look, the hand drives a reach, the feet drive a step.
- Offset the carried parts 1 to 2 frames per link (increasing: 1, 2, 3). In Poser use `lag` for a whole-curve offset, or move individual keys by hand when only one beat should trail.
- Keep hard contacts synchronised: the striking fist and the torso land on the contact frame; a two-handed grip never separates because of a lag.
- Break the three times apart: when a part starts, when it arrives and when it settles. They do not need the same offset.
- Measured overlap in the stand set: the arms trail the torso 5 to 8 frames in the barrage and the heavy punch; the head trails 2 to 6 frames in the idles.
- Measured on 376 real punches (mocap-timing.md): the hips reach their fastest turn about 6 frames before the fist, the shoulders about 3. On kicks the shoulders reach their fastest turn about 17 frames before the foot's fastest point.
- A part that acts on purpose does not trail either: a hand pulled back to guard during a punch was carried 1.95 studs out to the side by the torso's turn when it wore a 2 frame lag.
- A head that holds the eyes on a target leads, it does not trail: it counters the torso twist on the torso's own frames (measured: head -49 against torso +48 on the same five frames of the stand's right punch). A head that lagged four frames in the example cross pointed 40 degrees off the target at the contact.

## Moving holds and settles

A perfectly static pose looks lifeless within a few frames. A moving hold keeps the pose alive:

- It drifts in the direction of the last momentum, then settles: a key at the start of the hold and a second key 5 to 15% further along, with `auto` tangents so the part glides in and out.
- Breathing: the chest and shoulders rise and fall; it can build momentum into the next action.
- The head follows the same momentum as the body; an unmotivated head move breaks the weight.
- Different parts settle at different times: the hips settle first, then the arms, the head last.
- `life` adds slow noise to the upper body so a long hold is never frozen; it does not replace a drift that has a direction.

## Follow-through and springs

Follow-through is what the body does after the main action stops: loose parts keep going and come back. `springs` simulate it on the sampled curve (second order dynamics: f is the speed of response, z the damping, r the initial response; r above 1 overshoots at the start, below 0 anticipates):

| Preset | f, z, r | On a 100 degree snap in 0.08 s | Trail on a steady move | Use on |
| --- | --- | --- | --- | --- |
| lead | 8, 0.6, 1.25 | overshoots 6, settles in 7 frames | 0.5 frame | a carried part that should stay close (a weapon, a guard hand) |
| follow | 6, 0.5, 0.5 | overshoots 8, settles in 10 | 1.2 frames | the head in an idle or a reaction, a carried arm |
| drag | 5, 0.45, 0 | overshoots 12, settles in 12 | 1.7 frames | the free arm, loose parts |
| heavy | 4, 0.65, 0 | no bounce | 3.1 frames | a heavy weapon arm, a big body |

A custom table `{f = , z = , r = }` works too. Springs react to every key, so a creep hold also settles softly. They run in clip time: a hitstop freezes them and a slow-motion time scale slows them.

Do not put a spring on a part that must be on its key at a contact. Measured on the example's torso (a 76 degree turn into the contact at 850 deg/s): `lead` arrived 7 degrees short, `follow` 20, `drag` 34, `heavy` 47. The only spring that arrived on time (r = 2) overshot a stop by 16%, which reads as rubber. Key the leading part's overshoot instead: one key past the contact 4 to 8 frames later, then a drifting hold.

## Game feel: anticipation, contact, hitstop, recovery, cancel

- **Response first.** Too little anticipation and a move has no weight; too much and it feels unresponsive. Keep a player's anticipation short and readable; put the weight into the contact, the hitstop and the follow-through instead.
- **Separate the felt timing from the system timing.** The hit event can come early while the animated follow-through stays long; give the player control back before the clip ends (a cancel frame) and let the rest blend out.
- **Contact.** The hit event sits on the contact key. Hitstop 0.07 to 0.2 s with `Rig:hold`. Push the victim or the weapon further than reality to sell the force.
- **Recovery.** The recovery pose shows the momentum: over-extended, off-balance. For a cancellable move stay in it a little longer than feels natural, then pop back quickly. Never scale the recovery linearly back to idle; a slow even return blurs when the character can act again. A finisher may return slowly (the measured sword hits spend 30 of 50 frames returning) if the return is one continuous deceleration with the parts offset.
- **Chains.** A combo is one motion: each hit starts where the last ended, and the recovery of one hit is the load of the next.
- **Power.** Stronger moves use fewer, faster transition frames and a bigger wind-up silhouette; long slow movement reads as weak.
- **The victim.** A hit reaction built for the project (project-style.md, 2026-09-23 hitstun) and keyed again as `HitFlinch` in `scripts/ExampleMoves.lua` (0.62 s, a hit from the front on the example guard): the torso snaps 16 degrees with the push in 3 frames, the head a frame later, the arms flung against the push 2 frames late; the stagger keeps going about 30% further to frame 9; the foot on the push side steps back 0.45 and plants at frame 18 while the body folds against the push; a small overshoot at frame 28 and the guard at 37. The slide itself (about 2 studs, most in the first 0.15 s) is root motion in the game. Offline it measures still 2.6%, rest 30.8%, stops 1.34/s, unison 4.84/s, contrast 3.5, close to the project clip's Studio numbers (still 2.6%, rest 30 to 34%, stops 1.3 to 1.6/s, unison 4.84/s, contrast 4.9 to 6.1).

## Weight and support

Choose the support at each beat and keep the mass over it in held poses. Show the sequence of effort: prepare support, apply force, accelerate, absorb or release, regain support. A heavy action can strike fast after a demanding preparation; slowing the whole clip does not make it heavy.

In R6, compression is a torso drop with the legs re-aimed at their floor targets (`Feet.post`), never a leg pulled out of its hip. Lean from the waist (the `waist` offset), or the hips swing back and the feet slide. Turning the torso turns the hips around the feet; plan the drop with the turn (`Feet.gap` gives the need).

## Arcs and paths

Track the part that carries the action (the fist, the sole, the blade tip) in world space; a good joint curve can still draw a bad path. Natural motion travels on arcs; a jab may be near straight. Add a breakdown to control a path (a hand going out and around the chest, a blade clearing the head), not to add keys. Poser interpolates Euler channels: a turn over 180 degrees needs an intermediate key in the chosen direction.

## Smears and multiples

When a limb, a blade or the whole body travels more than about its own width between two frames, the eye sees it jump. Put a smear on that frame, as 2D animators and stylised 3D films do (Spider-Verse used stretched geometry, extra limbs and speed lines, sources.md). Kinds seen in the studied reference, each on screen one to three capture frames (2 to 6 frames at 60):

- **Swoosh**: a crescent that follows the tip of a blade or a fist along its arc, dark or in the effect colour, fading toward the tail.
- **Stretch**: one shape in the limb's colour stretched along the motion from the start position to the end position (the golem's legs became long spikes on a launch).
- **Streaks**: flat strips in the character's own colours along a dash path.
- **Multiples**: extra copies of the moving part at in-between positions on its arc, partly transparent, most transparent at the tail.
- **Ground marks**: scrape lines along a skid, radial lines at a landing.

Build each smear as a real instance tree on the client: a Folder in `workspace` per play; each smear a Part or a MeshPart with `Anchored` true and `CanCollide`, `CanQuery`, `CanTouch` and `CastShadow` false. At runtime read the moving part's `CFrame` every frame; when its tip moves more than its width in one frame, place the smear between the previous and the current frame, then destroy it after its frames. The VFX skill builds blade swooshes from slash plates and Trails. This skill has not yet built or captured a body smear in Studio: capture the first one frame by frame and log what it shows.

`python3 scripts/faults.py <decode> --smears` lists the frames where a hand, a foot or a `Sword` tip moves more than 1 stud (a limb's width) in one frame, with the tip's path in world space, so the smear is placed before the game runs. Measured on 2026-09-26: the pro stand strikes move their fists 1.1 to 2.4 studs a frame on 2 to 5 strike frames (the barrage on every punch); the example throw's whip moves the hand 3.9, the leap strike's dive 1.9 to 2.2, the sword draw's tip up to 6.4.

## Limited timing for anime hits

Guilty Gear Xrd keyed its 3D characters without in-betweens and removed frames on purpose to look like 2D anime (for example 4 frames held at the chest, 2 for the transition, 4 for the punch; sources.md). In Poser that is `e = "step"` on the keys of the strike beats. Use it only when the requested style is limited anime animation; the studied Moon Animator reference and the pro stand set move on every frame of their capture. The checks count a stepped hold of 4 frames or more as a stop; state that the style is stepped when you report the numbers.

## Jumps, entrances and landings

- **Takeoff**: a crouch, then the launch in about 4 frames (the studied hop and launch). Real small jumps (mocap-timing.md): 19 frames down into a crouch 0.38 studs deep, 15 frames from the lowest point to takeoff, 15 frames in the air. A big launch can stretch the legs into a smear.
- **Air**: the body travels on an arc and slows near the top. Ease the height only; keep the travel even. The studied golem hangs 0.3 s at the top of a hop before it lunges.
- **Landing**: the contact with the legs spread and the torso still moving down, then the compression (the lowest point) 3 to 6 frames later (the studied golem; real small jumps take 12 frames and sink as deep as the takeoff crouch, then stand in 10), then a skid and a recovery for a heavy body or a quick recoil for a light one. The body settles on an arc, not straight down. R6 compresses by dropping the torso over planted feet (`Feet.post`).
- **Superhero landing** (measured): a fall of 0.1 s, the contact with radial lines, one knee and one fist down held 0.9 s with only the head rising, a push up of 0.15 s, the body straight after 0.3 s more.
- `scripts/ExampleMoves.lua` keys both on a stock R6. `HeavyLand` (1.4 s): the contact with the arms still up, the lowest point at 0.10 with one arm braced forward and down and the free arm flung back, a skid to 0.40 in which the torso pitches further forward (the feet are slowed and the body is not), an overshoot at the stop, two breaths in a crouch with a head turn, and a rise to a wide stance. `HeroLand` (1.6 s): the back knee drops in three frames, the fist planted within 0.07 of the floor through a 0.9 s hold in which the body breathes and only the head lifts, the push up, a stance with attitude. Numbers and rounds: motion-metrics.md.
- `LeapStrike` in `scripts/ExampleMoves.lua` keys the studied hop, hang and lunge as an in-place leap attack (1.3 s): a crouch with the arms thrown back, the arms swung up over 12 frames, the takeoff with the legs trailing, a tucked hang of 0.3 s turned side on with the fist cocked behind the head, a 0.1 s dive with the punch over the top, the contact in a wide crouch, the rise to guard. The clip carries the height (the torso rises 2.15 studs); the game moves the root forward, and a move that needs the root itself in the air moves it from the clip's events.
- **Entrances and exits** for a camera: [cinematic-shots.md](cinematic-shots.md).

## Weight by character

Write each character's weight before keying: stance depth, skid length, recovery time, time in the air. The same move then changes most after the contact; the snap into the contact stays fast for every body. For walks and runs, mocap-timing.md measures 15 styles (angry, giant, happy, proud, old, tired, thug and more): steps, bob, lean, sway, twist and arm swing that give a character its personality.

| | Heavy (the studied golem) | Light (the studied noob) |
| --- | --- | --- |
| Stance | low and wide, deep crouches | narrower; the legs split on a wind-up or a sword stance |
| Steps | about 0.1 s apart, the whole body drops on each | quick, often airborne |
| After the action | a skid of 0.3 s and a recovery of 0.6 to 0.9 s after a landing | a recoil of 0.12 s after the throw; straight from a dash landing into the draw |
| Camera | low and close | wider, room to fly |

`HeavyLand` in `scripts/ExampleMoves.lua` is the heavy column keyed: a 1.1 drop, a 0.3 s skid, a 0.6 s recovery in a crouch, arms hanging wide at the end.

## Staging for the viewer

- The main action sits in the centre or on a third of the frame, with room in the direction the character faces.
- One action at a time; let one finish before the next starts, unless the overlap is the point.
- Show a hand before it does something (a draw, a reach into a pocket), or the viewer misses it.
- Big actions read from far away, expressions from close up.
- When a character stands up, offset the top half from the bottom half.
- Secondary action is a gesture that supports the main action (the free hand, the head); overlap is the timing offset of the carried parts. They are different tools.
- The player sees a gameplay move from behind and to the right (`rear34`). From there the torso hides a lead-hand strike of an orthodox stance: the first M1 jab and hook showed their striking arm on 0 to 1% of its pixels and kept 73 to 83% of the start silhouette. The pro stand strikes keep only 46 to 67% of their start silhouette at the strike frame, and when their striking arm is hidden (the left stab shows 4% of it) the whole body changes shape instead. So a hand the camera cannot see needs the body to sell it: a step-in lean, a bigger turn, the rear hand tucked to the chin, a wind-up that swings the arm out past the body's edge first. `faults.py` measures both ("hidden strike", "small silhouette change").

## A gameplay M1 string

`scripts/ExampleMoves.lua` keys four hits on the example guard: `M1Jab` (from the guard, contact at 0.10 s), `M1Cross` (0.09), `M1Hook` (0.10) and `M1Upper` (0.17, a finisher that drops, then rises onto the punch and hangs 0.16 s). Each hit after the first starts from the end pose of the one before (`JAB_END`, `CROSS_END`, `HOOK_END`), and the alternation makes that end pose the next hit's load: the jab leaves the torso turned right, which cocks the cross; the cross leaves it turned left, which winds the hook; the hook leaves it turned right and low for the uppercut. An extra torso load key on the cross only added a stop (unison 7.1 per second, then 4.8 without it). Each startup sits in the 4 to 8 frame window and each clip still recovers to the guard when the string stops. They share the guard's post pass (`Ex.Guard.post`), so the runtime keeps the feet planted through the blends between hits (r6-mechanics.md). Played through the real runtime with a 0.06 s hitstop on each contact, a 0.1 s one on the finisher and the next hit started 0.1 s after each stop (`poser_offline.py --runtime "0 play Guard fade=0; 0.3 play M1Jab; 0.4 hold 0.06; 0.56 play M1Cross; 0.65 hold 0.06; 0.81 play M1Hook; 0.91 hold 0.06; 1.07 play M1Upper then Guard; 1.24 hold 0.1"`), the contacts land at 0.40, 0.65, 0.92 and 1.25 s and the string hands back to the guard at 1.85 s; slide 0.01, hip gaps 0.

## Motion recipes

### Idle or held stance

1. Block an expressive rest pose: the loaded foot, the gaze, the hands' purpose, contrapposto.
2. One engine: a breath of 2.5 to 3.5 s on the torso (lean 2 to 4 degrees, a 0.03 to 0.04 stud sink). The head and arms answer it about a fifth of a cycle later at half the size (measured on the idle Lepy named the model); in Poser use `lag`.
3. Add `life` of 1 to 1.5 degrees. Frozen must read 0%.
4. For long idles add macro variation every three to six loops (a weight shift to the other leg, a look around, a fidget) and blend it in so the body is never still.
5. A floating stand moves as one mass: all joints in phase, 2 to 3 times the limb amplitude, a 0.27 stud bob (measured on The World).

### Walk

Contact, down, passing and up landmarks per step; support transfer; toe-off; swing clearance. Match cycle distance to speed and measure the stance foot's slide. The torso bobs by geometry (lowest at contact, highest after passing), leans 4 to 7 degrees, twists 3 to 5 against the hips with the head countering; arms swing opposite the legs 30 to 40 degrees with a wrist twist that follows the swing, trailing the legs by a frame or two. Measured community walks: rest under 8%, contrast under 2. Test starts, stops, turns and speed changes.

### Run

Contact, compression, push-off, flight, next contact. R6 has no knee: suggest the tuck with whole-leg swing (-78 to +54 measured) and a lifted leg translation up into the torso; lean 26 to 28, hips twisting 25 with the head countering. Retune cycle distance and speed together; never a sped-up walk.

### Jump and landing

Separate takeoff, air and landing. Use the character's real motion state; a fixed clock cannot know when a jump lands. Landing: contact first, then the absorb (the measured landing drops 1.1 studs by 0.10 s while the torso pitch arrives at 0.23 s, separate arrivals), then settle into the next state, which may be a run.

### Attack or combo

Record startup, active interval, recovery and cancel window from the game. Block a target-directed anticipation, contact, follow-through and exit. Put the event on the contact. Choose whether the feet plant, pivot or step; a back heel may pivot on the ball (a foot target whose yaw changes). Check the previous clip's exit and the next clip's entry in motion. Stand punches are pistons: the arm angle holds through the strike and the arm slides 0.3 to 0.6 studs while the torso whip does the reach (measured).

### Emote or acting

Intention, attention and a change of thought. The head and the body timing show the turn of attention; a quiet action stays quiet. R6 body language carries the performance without a face.

### Stand or weapon interaction

A floating stand and a grounded user are different bodies. Use the canon reference to decide whether the user leads, copies, commands or holds still. A two-handed weapon is a contact problem: solve both grips in prop space and rework the stance if R6 opens a joint.

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

Layers: `curve = "spline"`, `lag` (lead arm 2 frames), `springs` (lead arm `drag`), keyed overshoot on the torso and the fist, head keys that counter the torso on its frames, `life = 0.6`, `post = Feet.post` with the heel pivot as a function of time. The measurements are in motion-metrics.md.
