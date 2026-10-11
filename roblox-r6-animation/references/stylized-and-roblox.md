# Anime-style animation and the native Roblox Animator

Two topics that decide how a finished clip looks in a game: the stepped, held timing of anime-style action, and what the Roblox Animator does to a clip when it plays (fades, priorities, weights, markers, easing, level of detail, masks). It ends with what experienced R6 animators say in critique. Every finding was checked against its source (sources.md, "Stylized and Roblox research"). Film timings are at 24 fps; 60 fps conversions multiply by 2.5 and are marked "our conversion".

## Contents

- Stepped anime timing
- Holds and contrast
- Exaggeration without scaling
- Smears and impact frames
- Rhythm, idle and readability in action games
- The Animator: fades, priorities and weights
- Track control traps
- Markers and easing
- Sampling, quaternions and length
- Level of detail and masks
- R6 critique from experienced animators

## Stepped anime timing

- **Pose every displayed frame; do not thin a smooth curve.** A shipped anime-style 3D fighter first animated at 60 fps on curves and thinned the frames, and it looked like 3D graphics with dropped frames. It switched off interpolation: every displayed frame is a key the animator poses (about 500 bones per character, to pack more into fewer frames). On R6, for an anime-stepped clip key one pose per held step with `e = "step"` and pose each step by hand: push the extreme and reshape the line of action on each step. Quantised sampling of a spline (lesson-videos.md, "Mixed holds") is a twos look, not this one.
- **Hold lengths are set per move.** In that fighter's battle moves, how many 60 fps frames each pose stays on screen is set per pose and differs from move to move (an example list: 2, 3, 3, 1, 1, 2, 2, 3, 4 frames, 9 poses over 21 frames). Cut-scenes use about 15 poses per second (a flat 4-frame hold), a little more than the 8 to 12 of cel anime. The jump arc and projectiles still update at 60 fps while the poses step: keep root motion smooth. Give a stepped Poser clip an explicit hold list in 60 fps frames; short holds on the fastest strike poses and longer holds into the recovery is a sensible start (our reading, not the source's). Put the hit marker on the first frame of the contact pose and check hitboxes against the held poses only, since no in-between is ever shown. A 1-frame hold may never reach other players under Animator LOD (below).
- **Twos without losing flow.** A feature film on twos animated on ones, baked, then deleted every second key and stepped it: posing directly on every second frame looked posed and lost flow. Hair and cloth still simulated on ones. On R6: run the full Poser stack (spline, lag, springs, life, `Feet.flat`) at 60 fps and quantise only the final sampled pose; hold each sample 5 frames for 12 poses per second (our conversion). Never feed stepped keys into springs.

## Holds and contrast

- **Irregular holds inside one move.** Anime action changes the hold length often and irregularly: light, fast parts on ones and twos, heavy bodies and settles on threes and fours, and a long hold that cuts to the next pose with no in-between makes a change sudden. At 60 fps (our conversion): ones about 2.5 frames, twos 5, threes 7.5, fours 10. Use 2 to 3 frame steps on the strike and on effects, 5 on ordinary motion, 7 to 10 on settles and on a giant's whole body; end a hold of about 15 frames with a cut to the next pose to make a change read as sudden.
- **Short sharp motion against long holds.** A TV anime fight lands blows at three a second (8 frames each at 24 fps; 20 frames per hit at 60 fps), lunges in 18 frames (about 45 at 60 fps), builds up for about five and a half seconds and stretches a miss into nearly seven seconds of slow motion. Fast, rapid-fire strikes read as comic. For a serious beat, keep the burst short, lengthen the build-up, and you may stretch the moment around the contact into slow motion or a long hold.

## Exaggeration without scaling

Anime-style 3D gives up 3D accuracy for the picture: every key gets small imperfections, limbs, hands and feet are scaled at impacts to exaggerate perspective (fists enlarged at points of impact, legs stretched for kicks), and nothing is simulated. R6 parts cannot scale in a clip. Exaggerate with the 0.3 to 0.6 stud piston along the arm's own length and with a bigger pose: more twist, a longer lean, a wider stance. Push parts toward a camera, or hide overlaps from it, only when the camera is known (a cut-scene, a side-view or locked-camera game); in free-camera play check the contact frame from several angles, because other players see it from other sides. In a stepped clip nudge the non-driving joints (head, free arm, torso roll) on every step; key loose parts by hand in the anime style and keep springs in the smooth style.

## Smears and impact frames

- **A smear on the part that leads the eye.** Smearing the hand is usually enough. Start the arc in the frames before the smear, keep it from changing direction, and give its leading and trailing edges steady acceleration or it jitters. A free-camera 3D game must make a smear read from every angle, so games lean on trails (combat.md). With no part scaling, the R6 smear is VFX: a Trail or Beam on one attachment at the fist or blade tip, on only over the fast frames and off before the reversal. Smears read well for one or maybe two film frames (2 to 5 frames at 60 fps); more distracts.
- **Impact frames on Roblox are screen effects:** a ViewportFrame, a ColorCorrection flash or a hand-drawn image sequence, shown while the body holds its impact pose, then a subtle camera shake. Fire the impact frame from a marker on the contact key and hold the contact pose (hitstop or `step` keys) for exactly as long as the flash, so the flash shows the body's real pose; it doubles as a silhouette test of the R6 contact pose. Prefer ViewportFrame or ColorCorrection flashes (particles vanish at ColorCorrection brightness 1 or -1). Image sequences stutter until loaded, and preloading was reported not to fix it: warm the sequence by playing it off-screen and test in a live server. Set `ScreenInsets` to None or `IgnoreGuiInset` so the flash covers the whole screen.

## Rhythm, idle and readability in action games

- **Idle is the neutral base.** Every move starts and ends in the idle, so it must not get in the way or look aggressive: raise a weapon or claws inside the attack's anticipation, not in the idle. Attacks are tension and damage reactions are release; author two or three hit reactions per damage tier, and a big reaction tells the player they can win.
- **Enemy attacks must be readable and avoidable,** with contrast and rhythm. In one playtest a jump attack that held in mid-air before dropping was very hard to dodge, so its rise and fall were retimed to similar durations. Keep dramatic apex holds for player moves and cinematics (our inference).
- **A jump attack that lands as it cuts** must already lean forward in the air, so the landing and the strike happen on one frame instead of two steps (land, then lean, then cut). Key the airborne pose pitched forward with the blade raised, and make the plant frame and the blade's contact key the same frame.

## The Animator: fades, priorities and weights

- **Default fades are 0.1 s.** `AnimationTrack:Play`, `Stop` and `AdjustWeight` fade over 0.1 s by default (6 frames). While a track fades in, its weight is below 1, so lower-priority tracks (the idle, the default Core animations) still show on every joint: an Action attack's arm and torso drift toward the idle pose while it fades in. For a strike that must snap, play with a short fade (or 0) from a clip whose first pose equals the pose on screen, or keep a matching hold pose underneath at a lower priority. Read the blend from a per-frame part record in Play, not in Edit.
- **Same priority blends by weight.** Two tracks at the same priority and weight 1 blend 50/50; the later `Play` does not win (four tracks at 0.5 each get 0.25). Weights normalise when they sum above 1, and joints are evaluated from high to low priority until the weight sum reaches 1. Default and catalog animations play at Core; Idle to Action4 are for developers. `Poser.bake` sets Action on every clip, so set the real priority before delivery: Idle for idles, Movement for locomotion, Action for moves, Action2 to Action4 for a move that must override another move. Never leave two full-body clips at full weight on the same priority; a crossfade between them is fine because the weights sum to about 1.
- **Suppress, do not stop.** `Stop()` or weight 0 can flash the default stance for a moment, especially on a first play or with 0 fades; `AdjustWeight(0.0001)` avoids it. Hand a move to the next by starting the next before the old one fades.

## Track control traps

- `Stop` with fadeTime 0 on Motor6Ds whose MaxVelocity is 0 freezes the joints in place; cut a move with a short non-zero fade. After `Stop`, further `Stop` or `AdjustWeight` calls do nothing until `Play`.
- `Length` is 0 until the animation has loaded: wait for `Length > 0` before the first `Play`, a marker hookup or stepping in Edit.
- `TimePosition` can be set only while the track plays; `AdjustSpeed(0)` freezes it at a chosen point and negative speeds play backward. For hitstop on a native baked clip, use `AdjustSpeed(0)` or a very small speed for the stop frames, then `AdjustSpeed(1)`.
- `Animator:LoadAnimation` always creates a new track; load each move's track once per character at spawn and keep it (`GetTrackByAnimationId` finds one already loaded).

## Markers and easing

- **Markers.** Native events come from KeyframeMarkers through `GetMarkerReachedSignal`, which passes the marker's parameter string; a name can repeat (a FootStep on each foot) and fires each time. `Poser.bake` writes no markers: add a KeyframeMarker at each contact key, use one name for a combo's hits and pass the hit index as the parameter. Until mid-2026 a marker on the last keyframe did not fire; keep events off the final key as a habit (a key one frame earlier, or the track's `Stopped` event).
- **Pose easing traps.** `Pose.EasingStyle` defaults to Linear; Constant snaps; Elastic and Bounce overshoot. Cubic is a legacy alias with a direction-reversal bug between the editor and the runtime: use CubicV2 for new work. `PoseEasingDirection` In and Out are named backwards from TweenService and most tools. Poser's dense Linear bake avoids every trap. If you export sparse eased keys, check the direction by sampling the played track instead of trusting the enum name. For a stepped export, write keys only at the step times with Constant easing, and check the direction, or each step shows the next pose one step early.

## Sampling, quaternions and length

Dense, evenly spaced, linear keyframes are the Animator's fast path: they are stored as quaternions (memory down to about 40%) with a faster cache layout. Playback slerps by the short path, so a sparse export of a turn over 180 degrees between keys spins the wrong way; dense samples avoid it. A looping clip does not interpolate from its last key to its first: make the last baked key equal the first. The highest Keyframe time sets the clip length. The Animation Editor runs at 30 fps by default and caps clips near 30 s; split longer cinematics that must open in the editor. Bake at a uniform 60 fps with Linear poses.

## Level of detail and masks

- **Other players may not see 1-frame details.** `Animator.PreferLodEnabled` is true by default: the engine may evaluate remotely simulated characters less often by distance, screen coverage and frame budget, reusing the last pose. Do not let a move's read depend on a 1 or 2 frame key (a 1-frame impact pose, a smear pose); carry the read on held poses of several frames. Set `PreferLodEnabled = false` on bosses and showcase NPCs (it costs performance across many animators). A Poser layer written over a native track must skip frames where `Animator.EvaluationThrottled` is true, or it fights the stale pose.
- **No joint mask on plain tracks.** Plain AnimationTrack playback offers priority, weight, speed and fade but no runtime joint mask or additive layer; Animation Graphs (full release mid-2026) add Mask, Over, Add and Subtract nodes and phase-synced blends. On R6 the hips hang from the Torso and RootJoint drives the Torso, so an attack overlay that twists RootJoint swings the walking legs even when a mask gives the hips to locomotion. While moving, keep an attack's torso twist small, or author a moving variant that keys its own legs and bake its planted feet.
- **Swapping a prop between hands.** Swapping Motor6D parents through animation events during a clip is prone to desync. Give a hand-swapping prop a joint whose Part0 is the Torso or HumanoidRootPart, compute its key each frame from the holding hand's grip by forward kinematics, and switch which hand drives it at the swap frame (avoid swapping on an extreme pose); the reach solve puts the receiving hand on the handle.

## R6 critique from experienced animators

- **The knee is the leg's far upper edge.** Experienced R6 animators fake the knee with the top edge of the leg that is in front: a walk sends the foot out in front, back to centre and out behind, with the knee brought out before the foot. On a forward-lifted R6 leg the edge the viewer reads as the knee is the far upper edge, between its front and bottom faces once the leg is near horizontal, about 2 studs from the hip. Place the lift so that edge leads the step on a clean arc from the player's camera, pair each lift with a small torso rise and turn, and never swing the same-side arm and leg forward together.
- **Three common faults in R6 combos.** Limbs that look detached when pushed far forward (tilt a far-reaching arm's top back toward the shoulder socket and keep every limb joined to the torso); punches aimed off-centre (aim at the centre of a dummy opponent's torso, get the aim from the torso twist, not from an arm swung sideways, and check the fist's closest approach on each contact key); and strikes that are slow when only the pauses should be long (shorten the strike frames before the holds between hits). Turn the free hand in toward the head instead of pointing it at nothing. R6 has no bends, so a move that is not exaggerated enough looks bad.
