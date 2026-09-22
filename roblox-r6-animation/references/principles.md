# Principles from the tutorials, translated to R6 code posing

Read 2026-09-22 at Lepy's request ("observe a bunch of animating tutorials online ... take reference to
update your own animation skill"). Sources are listed at the end; every rule below is restated in this
skill's own terms with the numbers it implies for Poser keys. Where a tutorial disagrees with a
measured clip in this skill, the measured clip wins and the disagreement is noted.

## 1. The four core poses of a hit (doc7090, Rivals library, Capcom)

Every M1 is idle -> wind up -> hit -> recoil, and those are KEY poses, not in-betweens. Fighting games
call the same three spans startup (idle to hit), active (the hit frames, where the hitbox lives) and
recovery (recoil back to idle).

- Wind up: the body turns AWAY from the hit ("turning in the opposite direction of where they're
  going to hit") while the head and the front foot already face the target. The stronger the attack,
  the bigger and longer the wind up. On R6: torso twist 20 to 28 away, head twist onto the target,
  weapon arm up and over, root drop 0.3 to 0.5.
- Hit: the fully extended pose, the most exaggerated silhouette of the clip, and the frame the VFX,
  the sound and the hitbox sit on.
- Recoil: the body bounces back OPPOSITE to the attack's travel (the `back` overshoot in our arrivals
  is exactly this), off balance and over extended.
- Every hit in a combo has the same duration; cut a chain at the frame right before the next hit's
  idle so the recovery of one is the load of the next (matches `the-world-clips.md`).

## 2. Clarity beats smoothness (Rivals library, Guilty Gear Xrd)

"The character needs to get into their pose fast, and stay clearly in that pose." Transition frames
that belong to no pose are the enemy; fewer of them read as more power. Guilty Gear Xrd went all the
way and turned interpolation OFF: every frame is a posed key, fewer frames with more information in
each, "expressiveness over accuracy", while the camera stays smooth.

R6 translation:
- A snap is 4 to 7 frames, never 12. If a pose still reads soft, cut frames before adding amplitude.
- For an anime hit, the strike key may use the `snap` ease (the pose changes in one frame) with an
  afterimage covering the jump; everything else keeps continuous eases. Never step the camera.
- Sustain the anticipation pose and the recovery pose; those two holds are what make the snaps read.

## 3. The recovery is a held pose, then a pop (Rivals library)

Our measured sword kit recovers over 30 smooth frames, and that is right for a cinematic or a summon.
For a gameplay attack with a cancel window the fighting game rule is different and it is a
gameplay rule, not taste: stay in the over extended recovery pose as long as possible with secondary
follow through (the free arm, the head, a cape), then pop back to idle in 4 to 6 frames. Never ease
linearly from the recovery into the idle, because the player cannot tell the frame they may act on,
and "the game will feel clunky and unresponsive".

R6 translation: recovery = two or three keys that drift on the over extended pose (the moving hold),
then one `quart` out key of 0.07 to 0.10 s back to REST or to the next hit's first key. A small squash
before the push off and a stretch as the chest comes up, with an overshoot flourish, is allowed and
adds personality.

## 4. Anticipation shows direction (Rivals library, MonkeyDev)

The wind up must say WHERE the hit goes, not only that one is coming: the head looks at the target
and the shoulders load away from it. MonkeyDev's punch: load slower than you think ("you're not
punching yet"), a brief still moment at the top, then the punch "very quickly", then the finish. That
is our snap, hold, snap, settle with the load allowed to be slower than the strike by 3 to 4x.

## 5. Squash and stretch on a rig that cannot deform (Disney, Jespone, Rivals)

Volume changes are not available on R6, but the whole body can squash and stretch:
- Squash = root drop 0.3 to 0.5 plus torso fold forward plus knees up (p.Y) - before a jump, on a
  landing, on any change of direction, at the bottom of a wind up.
- Stretch = root rise plus torso lean INTO the travel plus limbs extended along the travel - the
  apex of a jump, the hit frame of a lunge, the launch of a summon.
- Stands stretch by translating limbs 1 to 2 studs along the strike (the piston punch in
  `the-world-clips.md`); humanoids stay under 0.5.
- Guilty Gear scales hands and feet up on the hit frame for readability. On R6 the equivalent is
  translating the striking limb 0.3 to 0.5 studs further forward on the hit frame only.

## 6. Twinning, gesture lines and silhouettes (Disney, Jespone, Rivals)

- Twins: a pose whose left and right halves mirror reads lifeless. Every stance and every hit has
  the two arms and the two legs at different angles and offsets (the hover's right claw is 12 degrees
  higher than the left; the idle's back foot is turned out and 0.15 further back).
- Jespone uses "twinning" for a second sin: every joint keyed on the same frame. That is our lag
  ladder rule; a straight column of keys in the timeline is wrong before it plays.
- Gesture line: design each key pose as ONE curve through feet, hips, chest, head and the lead arm.
  An idle is a nearly vertical line; a strike is a sharply bent C or S; the line must change
  noticeably between the wind up and the hit. Check it on the rear three quarter capture.
- Silhouette: the anticipation of a powerful attack needs the most distinct silhouette of all,
  because the opponent has a handful of frames to read it.

## 7. Smears (Rivals library)

A movement fast enough to change pose in one frame needs a smear: it starts near the previous
frame's position, follows the arc, thins toward the tail, and dissipates over a few frames. Smears
imply hitboxes. R6 has no mesh smear, so use afterimages: Neon clones of the striking limb or the
whole body left at the previous key, fading over 0.2 to 0.3 s (the ultimate's three pink
afterimages 0.02 s apart, the summon's gold echoes). A sweeping attack gets the kit's crescent or a
Trail on the limb for the same reason.

## 8. Arcs, follow through, secondary action (Disney, Wikipedia)

- Arcs flatten as speed rises: a jab is nearly straight, a haymaker is a wide arc with a middle key.
- Follow through: loose parts keep going past the stop and get pulled back (our `back` ease);
  overlapping action: parts move on different timings (the lag ladder); drag: parts take frames to
  catch up when the body starts (the head and arms lag the root on a burst).
- Secondary action supports the main one and must not compete with it: put it at the start and the
  end of a strike (a head turn on the wind up, a hand flourish in the recovery), never during the
  three strike frames.
- The moving hold: nothing is ever still; a held pose drifts 2 to 4 degrees.

## 9. Timing is weight (Disney, Capcom, Williams)

Fewer frames between keys = faster = lighter; more frames = slower = heavier. A light hit: startup 3
to 4 frames, active 2 to 3, recovery 6 to 8 (under 0.3 s). A heavy: startup 10 to 12 with a hold that
creeps, active 2 to 4, recovery 16 to 30. The strike itself is never the slow part; the weight is
shown in the load and the recovery around it. Williams: the breakdown between two keys is "favoured"
toward one of them to shape the ease; in Poser the ease name on the arrival key is that favouring.

## 10. Exaggerate first, tone down later (Rivals, Jespone)

"GO CRAZY AT FIRST. It's so much easier to tone something down." Author every move at the top of
the amplitude band (limbs 140, root 1.5 studs, twist 30) and pull back after the capture. Realism is
not the target; readability and power are.

## 11. Study references frame by frame (Onii, Jespone)

Play a reference at 0.25x, step with `,` and `.`, match the editor camera to the reference camera,
and ask on every frame: what changed since the last frame and by how much. That is the same
question `ReadClips` and the speed segmentation answer for a decoded clip. Then repeat an old clip,
copy a good one, and polish.

## Where the tutorials and this skill disagree

- Sword kit: 30 frames of smooth recovery. Fighting games: hold then pop. Both stay: smooth for a
  cinematic or a summon, hold-then-pop for a cancellable gameplay hit.
- Jespone: "Sine In, Quad Out" as the natural pair. Our measured clips prefer `cubic`/`quart` out
  into a pose and `back` out on an arrival; sine only on breaths and recoveries.
- Guilty Gear: no interpolation at all. We keep interpolation and borrow the stepped strike as an
  option, because R6 blocks with no mesh deformation read as broken when every frame jumps.

## Sources

- MonkeyDev, "How to make PUNCH animations in ROBLOX STUDIO! [Moon Animator Tutorial]" (YouTube, transcript).
- doc7090, "Roblox Animation for Beginners - part 6 M1 Comboes" (YouTube, transcript).
- Jespone, "Jespone's guide to animations", Roblox DevForum Community Tutorials, 2019.
- OniiCh_n, "Q&A: Onii's Guide to Animation", Roblox DevForum, 2018.
- Rivals Workshop Community Library: "Anticipation, Action, Recovery", "Posing", "Advancing Frames" (quotes from Dan Fornace, jasontomlee, BountyXSnipe, Trail Mix).
- Capcom, SF Seminar "Hour 9: The Basics of Attack Composition" (startup, active, recovery).
- Junya Motomura, "GuiltyGearXrd's Art Style: The X Factor Between 2D and 3D", GDC 2015 (YouTube transcript).
- Johnston and Thomas, The Illusion of Life (the twelve principles, via Wikipedia's summary).
- Richard Williams, The Animator's Survival Kit (timing and spacing, favouring, moving holds, walk contacts) from general knowledge of the book; not re-read here.
