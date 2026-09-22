# Cinematic VFX direction

Use only for a requested cinematic or an existing cinematic being refined.
See project-history.md for the original sword, time-stop, and road-roller shot lists.
Those durations, flash patterns, and camera settings are project examples.

## Give every shot a job

Build a shot sheet: beat/event, subject, visible action, camera position, framing,
transition, world VFX, and optional audio. Confirm the largest silhouette fits the
frame while the important body action remains readable.

Use contrast across the sequence. A quiet preparation can make a short release
feel larger. A wide shot can establish scale; a close shot can show compression or
contact. Empty space can direct attention. Do not fill every frame automatically.

Choose each cut for information or rhythm. Preserve direction of travel unless a
clear re-establishing shot explains a change. Avoid a cut that hides the actual
contact or makes a miss look like a hit. Recheck on the target aspect ratio.

## Synchronize the action

Use the existing animation/event contract. Published animation markers can drive
VFX when those markers exist; code-driven animation can share a beat table. Choose
one timing authority for each event instead of letting effects, animation, and
server gameplay drift on separate waits.

Separate discrete events from continuous state. For preview, replay from the start
to the sample time so prior emission and trails exist; seeking only the camera or
mesh does not reconstruct particle history. Slow all participating systems through
a consistent preview clock, then validate at normal speed.

Do not force a one-shot animation to loop solely to make late scheduling safe.
Do not change animation speed, gameplay locks, or hit stop without the requested
scope. Author around the real action or raise the timing conflict.

## Camera and post effects

Prefer the project's camera controller and explicit ownership. Record the starting
camera mode, subject, FOV, and other state the effect owns. Return through the
controller's handoff; do not hard-code Custom and FOV 70 for every project.

A moving camera is not mandatory. Use a fixed frame to evaluate the world effect
without presentation hiding weak motion. Add shake, roll, FOV changes, letterbox,
flashes, and depth of field only when requested and useful to the shot.

Keep shake amplitude, duration, and frequency intentional. Avoid a constant shake
floor as a universal default. Follow the project's reduced-motion/flash settings
when they exist. Preview intense screen changes at normal speed, not only as stills.

UI must be an editable ScreenGui tree. Separate world VFX, UI, and camera ownership.
Spectators should receive the intended world presentation without an unrequested
camera takeover. Test interruption, death/respawn, and a second effect starting.

## World composition

Stage the effect at the actual contact and surface. Keep scale cues: a character,
ground plane, or known object. Increasing the radius without a scale cue often
looks less convincing than a smaller controlled expansion.

For large shells, test before and after the camera enters the mesh. Check inside
faces, depth, foreground coverage, and overlap with sky or terrain. A shell that
looks attractive from outside may fill the whole camera with an unintended pattern.

Layer intensity over time. A second pulse needs a distinct job, such as opening a
larger shape or revealing an aftermath. Repeating the same burst three times is
not automatically a stronger climax.

## Exit and evidence

Choose the ending that fits the brief: settle into gameplay, cut, dissolve, or fade.
A fade to black is one option, not a required repair for a bad camera handoff.
Stop emission, finish or clear tails deliberately, cancel scheduled events, and
release all owned UI, lighting, camera, and temporary instance state.

Review the whole sequence, isolated critical beats, and the handoff. Record what
was actually captured. The old scripts' global state and fixed render-step names
need adaptation before concurrent cinematic use; see modules.md.
