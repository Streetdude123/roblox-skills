# Combat animation and game feel

How shipped action and fighting games time, hold, cancel and stage their attacks, and how to do the same on R6 with Poser. Every finding was checked against its source (sources.md, "Combat research"). Fighting-game frame counts are at 60 fps, the same rate Poser authors at. The beat-by-beat craft (telegraphs, guards, hit reactions, punches) is in principles.md; this file holds the numbers behind it.

## Contents

- Frame budgets: startup, active, recovery
- Hitstop
- The victim on contact
- Cancels and the first actionable frame
- Telegraphs and reaction time
- Readability from a pulled-back camera
- Smears and trails
- Anime-style stepped strikes

## Frame budgets: startup, active, recovery

- **Light and heavy strikes differ in startup and recovery.** Smash Ultimate examples: a jab hits on frame 2 to 7 and recovers 16 to 18 frames after its last active frame; a forward smash hits on frame 15 to 29 and recovers 30 to 38 frames. Ground strikes stay active 2 to 4 frames; sweeping or lingering moves stay active longer (7 frames on one up tilt). On R6: a light attack keys its contact on frame 2 to 7 and returns to guard 16 to 18 frames after it; a heavy or charged hit keys its contact on frame 15 to 30 and recovers 30 to 40 frames. Keep the contact pose itself 2 to 4 frames. The skill's 4 to 8 frame player anticipation fits light attacks; heavy hits take longer.
- **Multi-hit spacing.** A three-hit fighting-game normal hits on frames 13 to 15, 19 to 21 and 25 to 27: 3 active frames each, 6 frames from hit to hit. For a barrage, key a contact every 6 frames (10 per second) and hold each contact pose about 3 frames, so the arm pistons in and out within 6 frames. Count startup to the contact frame inclusive when you place the hit event.
- **Stun outlasts recovery for a combo.** In Capcom's light-punch example the victim's 13-frame hit stun outlasts the attacker's 9 remaining frames, giving +4, so a 4-frame-startup move combos. Make the victim's flinch at least as long as the attacker's recovery after contact plus the next hit's startup, and show the attacker back in guard a few frames before the victim recovers.

## Hitstop

- **Every melee contact holds.** Removing hitstop weakens hits and makes them harder to see (one well-known action RPG has none; another's lighter beta hitstop felt weaker than its developers intended). When a hold feels too heavy, shorten it per tier and add sound instead of dropping it to zero.
- **Length rises with strength, set per game.** Capcom gives 8, 12 and 16 frames for light, medium and heavy hits as one possible scheme; most fighting games measure about 9, 11 and 13; one classic used about 14 for every strength. Smash computes it from damage (Ultimate: `floor(0.65 * damage + 6)` frames, so 10 damage gives 12 frames and 20 gives 19), capped at 30 frames; electric hits multiply by 1.5. On R6: about 8 frames (0.13 s) for a light hit, 12 (0.2 s) for a medium, 16 (0.27 s) for a heavy hit or finisher. The skill's 4 to 12 frame range is the action-game low end.
- **Shorter in a crowd and on multi-hits.** Multi-hit moves get shorter holds so they do not feel heavy, and Smash ramps holds over 10 frames down with the player count (`scale = 1 - (H - 10) / 20 * (1 - pc)`, with pc 0.862 for 4 players and 0.75 for 8; a 20-frame hold becomes about 18 frames with 4 players). In a barrage give each hit a shorter hold than a single heavy hit.
- **Neither fighter is a dead freeze.** Attacker and victim freeze for the same length. The victim vibrates to show shock: side to side on the ground, up and down in the air (vertical shake on the ground clips the feet), largest on the first frame and shrinking to zero, larger when the camera is far. The attacker keeps moving at a speed too slow to notice in one frame. On R6, do not hold the attacker dead with `Rig:hold`: run its clip through the contact with a `warp` near 0 (0.05 is a starting value) so the follow-through creeps. Shake the victim's torso through RootJoint `px` on the ground or `py` in the air, leave HumanoidRootPart still and let `Feet.flat` keep the soles.
- **A projectile hit freezes only the victim.** The shooter keeps moving; never key a hang into a cast clip for an impact that lands later.
- **A critical hit.** One shipped game sells a crit with a 1-frame freeze, then a slow-down of a few tenths of a second, a blood spray and a specific impact sound. On R6: hold 1 frame on contact, then a `warp` segment below 1 for a few tenths of a second (0.3 to 0.45 is a starting speed), with the effects fired on the same contact event.

## The victim on contact

- **The hit pose appears on the contact frame, with no blend.** One studio pops the target into the hit pose and holds both fighters on that first frame; another eases from the flinch pose into the hurt pose over 4 frames inside the hitstop; cross-fades into hit animations should be zero. Start the victim's reaction clip with `fadeIn = 0` on the flinch pose at t = 0, optionally ease into the hurt pose over about 4 frames of the hold, then after the hold make the first frames travel the most and flatten the end key: a hit reaction starts very fast and ends slowly.
- **Tiers by strength.** Smash scales the victim's stun with knockback (0.4 frames per knockback unit; at least 4 frames for any flinch). Author hit reactions in tiers, not one flinch for every hit, and let the game pick the tier from the hit's force.
- **An enemy that cannot be interrupted** gets an additive shake on its body instead of a hit reaction: keep its attack clip playing and layer a short, decaying torso and head shake per hit, composed in an explicit order (one writer per joint). Heavy attacks get bigger, faster camera shakes. Choose any reaction's direction from the attack's direction.

## Cancels and the first actionable frame

- **Cancels open at the hit and run through the hitstop.** In a fighting game a special cancel is input during the hitstop and replaces the rest of the normal move, so a longer hold gives a wider cancel window. Open the chain or cancel event on the contact frame and keep it open through the hold. The next move may then start from the contact pose, so check hit N+1's first key against hit N's contact pose as well as its end pose.
- **Pre-hit and post-hit windows.** A shipped action game lets jump, roll, magic and guard cancel a basic attack before its hit, and walking or a weapon swap only after it. Its example: a 60-frame swing with hit frames 15 to 20, the next swing buffered over frames 0 to 21 and instant over 21 to 60, block instant over 0 to 60. On R6, give each attack events for hit start, hit end and chain open, and open the defensive cancels from frame 0. Make the follow-through travel toward the next swing's load pose, so an early cancel never reverses direction.
- **The animation runs past the first actionable frame.** The frames after it are filler that shows only when the player gives no input (one smash attack runs 56 frames and can be cancelled from frame 48). Put a `cancel` event on the first actionable frame and keep authoring the settle after it. The pose at that event must make a clean blend source with no limb mid-snap, because the inertial blend starts the next clip from whatever the rig shows there.
- **The recovery must not look like the idle.** If the last recovery frames look like the idle, players act early and miss inputs. Keep the over-extended pose until the cancel event, so the first idle-like frame is the first actionable frame, then pop back quickly.

## Telegraphs and reaction time

- **Reaction-time telegraphs.** One studio tested a PvP attack at 500, 466, 433 and 400 ms against measured player reactions: reaction times fell from 500 to 466 and from 466 to 433 ms, but not from 433 to 400, so it fixed those attacks at 433 ms. An attack defenders should block or parry on reaction needs about 26 frames (433 ms) from the clip start to the contact; 30 frames (500 ms) is easier. Put the readable wind-up silhouette early in that window.
- **Expected or unexpected.** An action the audience expects can be very fast; an unexpected fast action needs a bigger anticipation or a slower action, or it is missed. The player's own button press is the expectation, so a player move may use a very short anticipation (even one frame of anticipation makes a move much more readable). An NPC attack is unexpected: use the long telegraph (12 to 30 frames) or a slower strike. One studio lengthened its NPC melee tells so players could spot and dodge them; add a `trackEnd` event a few frames before contact so the attacker follows the target before it and keeps its direction after it, and a dodge can beat it.
- **The anticipation shows where the hit lands; the active pose shows its size.** Wind up on the side and at the height of the target zone (a low sweep loads low, an overhead loads high), away from the body so the camera behind sees it. Anticipation poses need a silhouette distinct from the idle.

## Readability from a pulled-back camera

- **Big arcs replace camera shake.** One studio pulled its camera back and cut camera shake for legibility, and made up the impact with very large arcs, powerful follow-throughs and reactions that break reality (huge pose changes, flips, juggles). The Roblox player camera also sits back: swing in wide arcs across the camera's view with a long follow-through, and give the victim a whole-body reaction through the torso and the root, not a head nod.
- **Show more of the blade.** Turning a blade so more of its flat faces the viewer gives it a bigger shape in gameplay. On the swing and contact frames, turn the weapon at the grip so the flat faces the camera behind and above; check it in the `rear34` strip, because edge-on from behind the blade disappears.
- **Lead with the body, snap the arm.** In a punch the head and torso lead and the arm snaps forward just before impact; a punch over 2 frames reads faster than one over 5. Key the torso and head turn first and land the arm's main rotation in the last 1 to 2 frames before contact. Hold a strong pose after a swing so the player sees it, and return control before the follow-through ends. A sword that bursts to full speed looks light; add weight with a slow out.
- **One overshoot frame.** One frame past the target, then a pull back, adds power. Key the striking limb 1 frame past its contact pose, a few degrees further, and back over the next 1 to 2 frames; this snap is separate from the 4 to 8 frame follow-through.

## Smears and trails

- **Smears stand in for motion blur, at a fixed camera.** One studio made smears by yanking limbs out on fast frames, mostly for fixed-camera moments, because from other angles they look grotesque. R6 parts cannot stretch and the player orbits the camera, so do not fake a smear in a gameplay clip by sliding a limb out of its socket; keep body-breaking smears for fixed-camera moments (an emote, a finisher cutscene) and use trails in gameplay.
- **A good smear tapers, arcs and fades.** It grows thinner toward its tail, runs on an arc from near the previous frame's position, implies the hitbox, and fades over a few frames. Put a `Trail` between attachments at the blade base and tip (or around a fist) with `WidthScale` from 1 at the head to 0 at the tail and a `Lifetime` of 1 to 3 frames (0.017 to 0.05 s), so the tail reaches about the previous frame. Enable it only over the active arc, then set `Enabled = false` (old segments expire).
- **A trail draws chords.** A Roblox Trail connects each frame's attachment positions to the previous frame's, and a fast swing gives very few samples, while the tip really moves on a circle. The chord sags 1 - cos(angle / 2) of the radius: 3.4% at 30 degrees per frame, 7.6% at 45. Above about 30 degrees per frame the trail shows corners: spread the arc over one more frame with a breakdown, or draw the arc yourself.

## Anime-style stepped strikes

A shipped anime-style 3D fighter animates with no interpolation between keys: every frame is a hand-posed key, because interpolation made the characters look 3D, and every bone is adjusted on every key to break the perfect transition. For an anime-style strike on R6, author the beats with `e = "step"` keys so each pose holds until the next, and make each held pose a full, slightly different key instead of a copy. Offer it as a style; gameplay clips stay on the spline by default.
