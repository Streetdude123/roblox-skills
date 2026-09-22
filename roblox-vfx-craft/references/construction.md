# Editable instances and runtime integration

Author the actual hierarchy first. Adapt these names to the project's conventions.
This is a construction contract, not a claim that the following assets are shipped
in this repository. See modules.md for the older bundled helpers' different inputs.

## Contents

- [Example impact template](#example-impact-template)
- [Coordinate spaces](#coordinate-spaces)
- [Playback contract](#playback-contract)
- [Timing and ownership](#timing-and-ownership)
- [Lifecycle](#lifecycle)
- [Handoff](#handoff)

## Example impact template

Create a Model named `Impact` under the project's replicated VFX template folder.
The following paths are relative to that Model and describe real Instances.

| Path | Class | Purpose and initial state |
|---|---|---|
| `Origin` | Part | Invisible carrier; anchored; collision, query, touch, and shadow disabled |
| `Origin/Contact` | Attachment | Contact pivot and emission direction |
| `Origin/Contact/Flash` | ParticleEmitter | Primary shape; disabled; Rate 0 |
| `Origin/Contact/Fragments` | ParticleEmitter | Directional support; disabled; Rate 0 |
| `Origin/Contact/Dust` | ParticleEmitter | Optional material tail; disabled; Rate 0 |
| `Ring` | MeshPart | Optional ground accent with verified axes and pivot; hidden until triggered |

Set the model pivot deliberately. Store verified texture/mesh references and authored
curves on these Instances. Remove unused rows from the actual template. Do not create
dummy layers just to match the example.

For a beam, use real `Start` and `End` Attachments under the relevant carrier parts,
and assign the Beam's `Attachment0` and `Attachment1` to them. For a weapon trail,
place real `BladeBase` and `BladeTip` Attachments on the weapon and reference both
from a Trail. A folder of unparented emitters is not a working effect.

For requested screen effects, author the actual ScreenGui, Frames, ImageLabels,
gradients, and optional ViewportFrame/Camera as an editable template. Runtime code
controls the template. Keep the UI optional and separate from the world effect.

## Coordinate spaces

Record each layer's space and when it stops following:

| Space | Use | Check |
|---|---|---|
| Object-local | Charge on a moving hand; persistent aura | Carrier follows the actual attachment through animation |
| World | Contact burst, detached smoke, debris | Emitted material does not teleport with the caster |
| Surface-aligned | Ground crack, splash, scorch | Orientation uses the hit normal and lies just above the surface |
| Camera-facing | A deliberate sprite/card | Oblique angles and camera crossing do not expose a wrong plane |

For a surface effect, use the confirmed hit position and normal. Project an intended
forward direction onto the contact plane, or select a nonparallel basis direction
when the projection degenerates. Map that basis to the asset's documented axes.
This is geometric handling of a valid surface, not a silent missing-asset fallback.

Do not apply a universal 90-degree rotation to every ring. Asset local axes differ.
An anchored carrier welded to an unanchored character can anchor the assembly;
use the project's existing attachment/follow method and verify its physics behavior.

## Playback contract

Use a small typed configuration for counts, offsets, durations, and existing event
names. Keep visual properties on the template when practical. If the project uses
`EmitCount`, `EmitDelay`, or `EmitDuration` attributes, document their reader: these
are custom conventions and do nothing automatically in Roblox.

Keep an explicit schedule rather than inferring every behavior from descendants.
At a burst event, position and parent the clone before calling `Emit`. For a loop,
enable emission for the agreed active window, then disable it and let its tail finish.
For a trail, clear old segments before a new swing or a teleport, not halfway through
an intended continuous sweep.

New template Models use `PivotTo`; the old `Kit.spawn` expects a BasePart. Do not
pass the new Model layout into that helper unchanged.

## Timing and ownership

Use the project's actual animation markers or ability events. For a scheduled
sequence, compute phase from elapsed time. Fire each discrete beat once when time
crosses it; at a slow frame process crossed beats in order without replaying them.
Do not compare floating time for equality or advance by one frame per callback.

Keep animation, particles, mesh motion, camera, and audio on a documented timing
contract. A delayed callback is not an exact audiovisual clock. If networking needs
aligned playback, use the existing shared timestamp/event policy; document how
late arrivals skip obsolete buildup or show a current state. Do not invent a second
networking system for a cosmetic improvement.

Server gameplay decides hits and state. Clients render their allowed cosmetic
presentation. Do not use a cosmetic raycast as a new damage authority. Test both
the caster and another client, including anchors that are not currently streamed.
Use the project's explicit streamed-target policy rather than indexing an assumed
character or silently replacing it with another target.

## Lifecycle

Define `start`, `stop emission`, `tail`, and `dispose`, plus the allowed interruption
points. Track connections, tweens, scheduled tasks, attachments, sounds, and models
per cast. Cancel pending work and release owned resources when the cast ends.

Disabling an emitter does not prevent a queued callback from calling `Emit` later.
Invalidate the cast before canceling work, and let callbacks distinguish an active
cast from an old one. Tween completion also fires on cancellation; a completion
handler must not treat every completion as permission to start the next beat.

Calculate disposal from the last emission plus the longest particle/trail/tween/audio
tail. At a constant particle speed factor `q > 0`, a particle lifetime `L` occupies
approximately `L / q` wall-clock seconds. Frozen particles need explicit clear or
resume handling; there is no finite expiry estimate at `q = 0`.

On an immediate reset, clear particles and trail history. On a graceful stop, retain
the carriers needed for the tail. For recasts or pooled objects, reset changed
properties and attachment references before reuse. Pool only when measurement
shows that reuse solves a problem.

Do not return an instance with a pending destruction timer to a pool. A timer from
the previous cast can otherwise destroy the next cast's reused object.

Camera, UI, lighting, and movement must each have one owner. Use the project's state
controller to restore the correct state; do not reset global values to guessed
defaults or restore another active effect's snapshot. Two overlapping casts must
not release each other's camera or destroy each other's instances.

## Handoff

Keep the template, runtime entry point, parameters, and a repeatable preview route
in the project's existing layout. If Studio is unavailable, distinguish prepared
source from an instantiated and verified tree. Export the requested native artifact
only after checking its contents; never substitute a screenshot for editable VFX.
