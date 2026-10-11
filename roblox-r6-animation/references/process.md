# Working with the requester

How to run an animation task with a person who reviews it. Each rule came from a round of review that went wrong without it.

## Before building

- List the choices that change the result and ask them as short multiple-choice questions, only those. Guessed choices caused rebuilds; asked choices needed no rework. When told to assume or proceed, decide, and state each assumption in the report.
- Ask how the requester reviews (videos, stills, nothing) and follow the latest instruction. When videos are wanted, send a short one per finished or changed move, from one fixed player camera so versions compare, until told to stop. Otherwise keep the captures for your own review.
- When building a character's moves, check its idle and walk too: moves that start and end on stock locomotion pop at both ends.
- Tell the requester what code-authored animation cannot judge: numbers fix stops and slides, not feel, which shows only in playback. Start from real motion when feel matters, and offer a hand polish pass in the editor they use, delivering a sequence it opens (moon-animator.md).

## Picking references and options

- Show reference candidates in one video per move. Label each candidate on screen with the move and the option ("JAB 1", "JAB 2"); include the current clip, labelled as such; play candidates at game length; state the arm lift and torso lean; drop duplicates (packs repeat clips); retarget onto the rig's prop grip and watch the result yourself first (raw prop grips made every candidate look broken); label body and staging sources separately. When no clean clip exists, say so and offer a labelled mirror or a slide-fixed version.
- Send the candidate videos with the pick question.
- For taste choices (paths, rig-limit compromises, which way a blade points, turn style, strafe style), show labelled options and let the requester pick. Rendered options got picks in one round.
- When a note is ambiguous, ask whether it describes what is wanted or what is disliked; a misread note cost a rebuild. When feedback names a fault, ask which part and offer concrete fixes.

## While working

- Author, measure and fix clips in one working thread; it holds the captures and numbers for the next fix. A review swarm added time without better clips.
- Treat a reference's numbers as a measurement of that clip, not a recipe: scale holds, overshoots and travel to the new move, never key the legs on the torso's frames, and keep iterating. Copying one kit's 0.06 s holds and 0.26 stud lunges onto unrelated moves read flat.
- Write a status line after each step of long work. Offer speed options as multiples of the built speed. Never trade quality for speed: a fast batch read robotic.
- On a vague polish complaint, list the measured faults as stills before fixing; the list becomes the acceptance check.
- Change only the clips the request names. Never reuse a rejected clip's keys.
- Show a candidate beside the reference before building a change, and revert at once when the earlier version is preferred. To restore an earlier version, confirm it by showing it and carry every accepted fix onto it (a restored walk once lost three accepted fixes).
- Show renders of offline fixes and early side-by-side videos before importing them.
- Ask before changing playback speed for drama.

## Delivering

- In the report, name each clip's reference and how the clip differs from it, or say it has none. Use only the named part of a reference video. Say plainly when praised work is a copied reference.
- Propose game-setting changes (walk speed, gravity, cooldowns) with the delivery, not silently.
- Clear test hooks, probe scripts and temporary folders before the requester plays; a leftover aim hook once broke play.
- Keep every rule a clip depends on in the skill text, not only in example code: rules that lived only in code were invisible to a fresh session. Test changes to this skill with a cold start.
