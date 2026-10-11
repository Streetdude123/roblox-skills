# Keyframe workflow, posing and acting

How professional keyframe animators plan, block, spline, polish and review a shot, and how each step maps onto R6 clips in Poser. Every finding was checked against its source (sources.md, "Workflow, posing and acting research"). Film sources count at 24 fps; conversions to 60 fps multiply by 2.5 and are marked "our conversion".

## Contents

- Plan before keying
- Block in whole poses
- From stepped to spline
- Layer by layer
- Polish: arcs, offsets, retiming
- Posing
- Contrast and phrasing
- Acting
- Review with fresh eyes

## Plan before keying

- **Set the style dial first.** Cartoony work blocks stepped and hits strong poses with a big anticipation against a fast action; hyper-real and creature work often blocks in spline from the start and spends its effort on offsets, so parts never land at the same time. Record the style in the clip plan (snappy anime or cartoon combat, or grounded and realistic) and use one exaggeration level for all of a character's clips; at review, pull a clip that went past it back to the set level.
- **Thumbnail several ideas.** The first idea is usually the most clichéd. A stick figure needs only the hip angle, the shoulder angle, the head angle and the limb positions; on R6 those are the leg split and torso lean, the torso roll, the head key and the limb keys. Before keying, write three candidate golden poses as these numbers, capture them in one strip from the side and `rear34`, and drop the first unless it clearly wins. Spend about a fifth of the effort on the reference and the beat table before the first key.
- **Find the golden pose.** One pose tells the whole moment; audiences remember pictures, not movement. Name it in the clip plan. For an attack it is usually the load or the follow-through extreme, not the contact. Give it the clip's longest moving hold and check its silhouette, head direction and COM over the support from the player's camera before polishing any other pose.

## Block in whole poses

- On every key pose, key every joint, even the ones that did not move, and break the keys apart only after the blocking reads. A key pose is any moment where something important changes, not only an extreme. With good planning the clip is about 80% done when blocking ends.
- On R6: block with all six joints keyed at the same times with `e = "step"` and play it at speed. Add offsets, lag, springs and life only after the stepped strip reads. If the stepped strip does not carry about 80% of the read, fix the poses first.
- **In action-heavy clips, block the body first and let it place the feet.** Key the torso, arms and head with no step targets; step through with `_G.feet`; on the frame where a planted leg would break the feet rule, start that foot's step one frame earlier, and plant it where the torso path comes down onto it. For balance-critical clips (idles, braced stops) keep the legs-first order (lesson-videos.md, layered method).

## From stepped to spline

- **Splining softens the timing.** Converting stepped blocking to spline often turns motion to mush, because each stepped change used to happen in one frame. An unclamped spline also overshoots next to a stationary key when a large change happens over few frames (a heavy base dipped under the floor before and after a hop). Poser's `auto` tangent is clamped and does not overshoot, but `smooth` does: never use `smooth` on torso `py` or a planted part next to a held value.
- **A copied pair is a dead stop.** Under `auto`, a key next to a flat segment gets a zero tangent. After removing `step`, check the holds first: move a hold's second key 5 to 15% further along the move. Where the stepped version snapped, add a breakdown that favours the arriving key.
- **Fast moves lose their arcs.** The same spline sets both the path and the timing, so the faster the action, the flatter its arc. A dash or lunge keyed only at its start and end draws a straight root path: add one mid key that bows torso `p` (up, or toward the outside of a turn). For a 3 to 6 frame strike, trace the fist by forward kinematics and add a breakdown that keeps it on an arc around the shoulder.

## Layer by layer

- **A hop from the root outward.** Set the travel timing with two translation keys (takeoff and landing), then the height with one apex key, then the parts that show anticipation, stretch and the landing shock (in the classic example, the arms snapped together two frames after the base landed). On R6: key torso `px`/`pz` only at takeoff and landing, add one torso `py` key at the apex, plant the feet, and key the compression (torso drop, arms in) about 5 frames after the contact (our conversion), then settle with smaller bounces. When the Humanoid jumps by physics, skip the first two steps.
- **Breath as a chain.** The inhale is slower than the exhale; the chest's translation and its turn do not peak together; the shoulders react after the chest, the arms drag behind, the head follows subtly. In an idle breath, give the inhale more of the cycle, put the torso `py` peak and the torso turn peak a few frames apart, lag the arms and let the head follow at a small amplitude.

## Polish: arcs, offsets, retiming

- **Track arcs from the camera that matters, in a fixed order.** At 80 to 90% done, dot each tracked point every frame, draw the wanted path and move keys onto it. Order: hips, hands, feet, prop tips, head. Clean arcs are often the difference between amateur and professional work. On R6: the torso centre first (it carries everything), the fist ends of the arms, the soles, the prop tip, the head's front face; project each into the `rear34` camera and the side view and look for kinks, reversals and corners.
- **Redistribute before adding keys.** When one frame pops off an arc, change the time or value of the neighbouring keys before adding one. When the head rises with the body too quickly in an upward move, delay its lift keys 1 to 3 frames behind the torso (key offsets, not lag, when its yaw must hold a target).
- **Fix twinned timing locally.** Keep the accent part on its frame, let the head hit its extreme a couple of film frames early (about 5 at 60 fps) and delay the other hand a few (about 7 to 8). Edit those keys only, not a whole-curve lag. Even a deliberately simultaneous two-handed move gets 2 to 3 frames at 60 fps between the hands in realistic work.
- **Retime by walls and key groups, not by scaling.** To change a polished section, key every joint at its two edges, reduce the inside to all-joint keys at the frames where something important happens, and slide key groups. Uniform scaling gives no control over the eases, and a key pose can land between frames. Keep every key time on the 60 fps grid (`t * 60` an integer) and put extremes and contacts on even frames when the clip bakes at 30 fps. After a key reduction, `Poser.check` and `_G.feet` must give the same numbers as before.
- **Euler flips.** Euler channels can jump between equivalent angle triples while the rotation stays continuous; an Euler filter picks, sample by sample, the triple that keeps the curves continuous. In Poser lift is the middle axis, so at lift +-90 (an arm straight forward or back) side and twist turn about the same axis. Near there, keep side and twist continuous with the neighbouring keys, check the fist by forward kinematics, and run `WeaponRig.nearestEuler` as the filter on any clip decoded or solved (weapons.md).

## Posing

- **Silhouette where it matters.** Black out the character: if the action does not read, it is badly staged. In a strike, the anticipation and the follow-through must read in silhouette; the contact frame may overlap the body. In a strip from `rear34`, shade the rig one flat colour and check the load and follow-through: the striking arm sits outside the torso's outline with a visible gap; swing the wind-up to the side the camera sees.
- **Line of action: one C or one S.** A W or M shape breaks the flow. Read the line from the support foot through the torso to the head or the leading hand, and let it change direction at most once; where the head and a raised arm both continue the line, make them follow the same curve.
- **Break a twinned pose through a chain.** Push one foot further out than the other; that forces the hips over and down, which tilts the shoulders against the hips, and the result is a line of action from the toe up the body. On R6: move one `Feet.flat` target further out, shift torso `px` toward it and drop torso `py` until the leg keeps contact (`Feet.gap`), roll the torso so the shoulder over the wider foot drops, then give the two arms different lift and twist.

## Contrast and phrasing

- **No metronome.** Any sequence of three or more actions must not be evenly timed: "step, step, punch" at even timing reads robotic; "step-step ... PUNCH" (a long pause before the climax) is far stronger. Build each clip around one crescendo, often after a pause, and keep everything else smaller or slower. In a combo, give the beats different lengths, put a held load before the finisher (`warp` stretches a pause without rekeying) and make the finisher the biggest silhouette and the fastest strike. Read the key-time list: equal gaps mean the timing is still a metronome.
- **Variation without breaking a cycle.** In a long non-looping walk, vary the step length by about one frame in twelve; keep a short looping cycle symmetric, because any oddity shows the loop, and put variation in macro idle variants.
- **Overlap the phrases.** Never bring an action to a complete stop before starting the next: a character who knows what it will do does not stop and think before each step. In a multi-beat clip, start the next beat's lead joint while the previous beat's carried parts are still settling; a `Poser.check` still run over 0.1 s between two beats means the phrases do not overlap.
- **Jump timing in blocking.** A jump's anticipation often holds for more frames than the jump itself, the peak gets some hang time, and the landing snaps in fast. A transition between two strong poses may need only a few carefully chosen frames: about 7 to 8 at 60 fps (3 film frames, our conversion); shorten only if it still reads.

## Acting

- **Thought leads action.** The eyes move first, then the head, then the body; the lead is long for a big decision and a couple of film frames for a reflex. An outside force reverses it: the body moves first and the head trails. R6 has no eyes, so the head is the lead: for a decided action key the head's yaw and lift to the target several frames before the torso starts (longer for a weightier decision; about 5 frames at 60 fps for a reflex). For a hit reaction, lag or a follow spring on the head is right.
- **Change attitude in a quiet moment.** Change the expression before or after a fast body move, never during it; the eyes lead the accent by about 3 film frames. On R6, put a change of attitude (a new head tilt, a face-decal swap) in a quiet moment, and lead the accent with the head about 7 to 8 frames at 60 fps. In locomotion, place a look or attitude change at the top of the torso bob, where the head moves least. In a cutscene or emote that starts on a camera cut, keep the first and last 15 to 20 frames at 60 fps free of direction and attitude changes; the audience needs that long to register a cut.
- **One thought, one action.** Play one action until something happens that makes the character play a different one. For an emote, write a one-line interior monologue and list its thought changes; let each action finish into a short moving hold, then lead the new action with the head. Blinks (face decals) fall on thought shifts, to show or hide emotion, or in the middle of a fast head turn, never on a timer. Status reads in stillness: a confident character holds the head level and still with a direct look; a nervous one drops the head and fidgets. Stifled emotion can hit harder than a full display.
- **One primary actor at a time.** In a multi-character moment only one character does the primary action; the others do secondary actions, and the roles swap at the hand-off, with the next actor anticipating before the current one finishes. For a companion and its user, decide per beat who is primary; point the secondary character's head at the primary to lead the eye.

## Review with fresh eyes

You cannot judge your own clip with fresh eyes, and neither can the requester who wrote the brief. Show the captures to someone who has not seen the brief (another person, or a fresh reviewer given only the frames) and ask what the character is doing and feeling, and why. If they cannot say, the clip is not done; exaggeration has gone too far when such a viewer is confused. Record that answer separately from the requester's acceptance. Also review a horizontally flipped copy of each capture: the mirror tricks the eye into seeing the clip fresh.
