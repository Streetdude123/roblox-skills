# Cinematic shots: animating for a camera

Use this for a cutscene, an ultimate, a trailer or any request for a "cinematic" fight. A gameplay move under the player's camera does not take the camera; the VFX skill's tone ladder decides that. The numbers come from [study-moon-practice2.md](study-moon-practice2.md) unless marked otherwise.

## Plan shots before keys

Write a shot list before any key: for each shot the framing (wide, medium, close, insert), the camera move, the action, the length and the cut point. Then write one beat table `T` for the whole sequence (the VFX skill's cinematic.md pattern) that the clips, the camera, the effects and the sound all read.

Rhythm measured on the reference: about 27 shots in 28.2 s. An exchange of blows cuts every 0.1 to 0.4 s. A story shot runs 1.1 to 2 s. After every climax comes a breather of 1.3 to 1.9 s.

## Pose for the lens

- Each key is posed for the camera of its shot, not for a neutral front view. A pose that reads from the side can hide its reach from a rear camera. Check the strip ghost from the shot's camera.
- The main action sits in the centre or on a third of the frame, with room in the direction the character faces or moves.
- One action at a time. Let an action finish before the next character acts, unless the overlap is the point.
- The heavy character is shot low and close; the light one is shot wider so its jumps have space.

## Cut on the action

- Cut on the contact frame of a hit or a landing. The new shot starts on the compression or the recoil, not on the approach.
- Cut on a turn or a whip so the motion carries the eye across the cut.
- A whip pan or a lens-skimming move (0.1 to 0.3 s) can join two shots in a fast sequence.

## Entrances and exits

- A big entrance: hold the empty frame 0.2 to 0.3 s, show the shadow first, then drop the body in from the frame edge.
- An exit: leave through the frame edge or past the lens; keep the camera on the empty frame for a beat.
- Bodies and objects that fly at the lens (a bomb, a fist, a thrown orb) sell depth; let them fill the frame for one or two capture frames.

## Camera behaviour

- Follow with a slight lag (the VFX skill's `CameraRig` smooths with `1 - exp(-dt * 9)`).
- Shake on landings and heavy contacts (`CameraRig.kick`), a handheld breath at other times (`CameraRig.floor`).
- Push in slowly on a stare. A close-up stare may stay nearly still for about 1.2 s (the reference holds the golem's eyes 1.15 s); keep a slow push or a breath so it is not a paused frame.
- Freeze the camera during impact frames (`CameraRig.freeze`).

## Impact frames and smears

- Impact frames go on the one to three biggest hits of a sequence only: five to seven unique frames at a 30 fps capture (inverted colour, flat colour, black and white silhouettes), then a white flash. The pose on those frames is the strongest silhouette of the sequence. Build them with the VFX skill's `ImpactFrames`.
- Smears go on the fastest frames of the body and the props (principles.md, "Smears and multiples").
- Speed lines on a dash or a flight: the VFX skill's `SpeedLines` pulse.

## Holds and comedy

- After a climax, hold the aftermath (smoke, debris, a character catching breath) 1.3 to 1.9 s with slow drift.
- A reveal lands after a hold: something bursts out of the cloud at the lens, then the character pops out.

## Build it in this repository

- Each character plays Poser clips keyed off `T`; the camera is the VFX skill's `CameraRig` (`shot`, `cutTo`, `kick`, `freeze`, `cut`); the screen layer is `ScreenFx`, `ImpactFrames` and `SpeedLines`. Restore the default camera behind the body while the screen is black.
- When the user animates by hand in Moon Animator 2, deliver the beat table, the shot list and the key poses; do not guess its file format (moon-animator.md).
- Review the sequence with a recorded take and frame sheets (reference-study.md), shot by shot against the reference.
