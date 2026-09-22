# Roblox VFX API decisions

Checked against Creator Hub and Roblox's creator-docs source on 2026-09-22.
Follow the current documented API if it changes. Links are in sources.md.

## Choose the rendering primitive

| Primitive | Appropriate use | Design consequence |
|---|---|---|
| ParticleEmitter | Many sprites or animated sprites | Inspect orientation, overlap, lifetime, and silhouette |
| Beam | A controlled connection | Attachment positions and axes define the path |
| Trail | A ribbon left by moving attachments | Motion creates the shape; a stationary preview is insufficient |
| MeshPart | An authored volume or contour | Check mesh axes, pivot, UVs, and camera angles |
| Light | Illumination of nearby geometry | Use only when environmental lighting contributes |
| Post effect/UI | Requested camera-local treatment | Give it explicit ownership and an exit path |

## ParticleEmitter corrections

- `Enabled` with `Rate` produces continuous emission; `Emit(count)` requests a burst.
  `Enabled = false` stops new automatic emission; `Clear()` removes live particles.
- `TimeScale` is a speed factor from 0 to 1, not a duration multiplier. Zero freezes.
- `LockedToPart` moves existing particles with the emitter's parent. Choose it for
  attached material, not automatically for every moving source.
- Positive `Squash` narrows horizontally and stretches vertically; negative does the
  reverse. Check the texture axes with the selected `Orientation` and `Rotation`.
- `LightEmission` controls blending, not lighting of the surrounding world.
- `ZOffset` shifts rendered depth in studs. It is not `ZIndex` or a sorting guarantee.
- `FlipbookMode.OneShot` plays across the particle lifetime and ignores
  `FlipbookFramerate`. Match `FlipbookLayout` to the sheet; current API also supports
  `Custom` with `FlipbookSizeX` and `FlipbookSizeY`.

Emitter parenting matters: an Attachment gives a point source; a BasePart permits
a source region controlled by its bounds/shape. For an inward gather with a visible
radius, use an actual source volume; a point source does not become a shell because
`ShapeInOut` says inward. Verify direction by emitting a few particles in isolation.

Choose `LightInfluence` for the material's response to scene lighting. A luminous
accent and dark smoke need not share a setting. Review both low and high quality.
Texture alpha, blending, and scene contrast all affect the result.

## Sequences and tweening

`NumberSequence` keypoint time runs from 0 to 1. Include endpoints at 0 and 1 with
ordered intermediate times. Its meaning comes from the property using it:

| Property family | Sequence domain |
|---|---|
| Particle color, size, transparency | Normalized particle age |
| Beam color/transparency | Position along the beam |
| Trail color/transparency/width scale | Age of each trail segment |

A Beam transparency gradient will not fade the entire beam over wall-clock time.
Animate supported scalar properties or explicitly rebuild a sequence when necessary;
do not send NumberSequence or ColorSequence values directly as TweenService goals.
Use authored keypoints to approximate the required spacing; NumberSequence does not
carry TweenInfo easing. Avoid rebuilding many sequences every frame without need.

Two tweens writing the same property compete. Schedule a follow-on tween when it is
needed or chain from completion. A delayed helper must expose its actual return
type and cancellation behavior; see the bundled `Tw.play` limitations in modules.md.

## Beam setup

Assign two real Attachments. A beam is a ribbon, not a cylinder; inspect edge-on
views and choose `FaceCamera` deliberately. Curve control uses each attachment's
local X direction: positive X from the start and negative X from the end for the
two interior Bezier control points.

Use enough `Segments` for curvature and the color/transparency keypoints, then
inspect at gameplay distance. The documented minimum for `n` sequence keypoints
is `n - 1` segments. Set `TextureMode` and `TextureLength` together: Wrap/Static
measure repeat length in studs; Stretch uses the number of repetitions.

## Trail setup

Attachment separation establishes width; `WidthScale` multiplies it as segments
age. `Lifetime` controls persistence, not how long the Trail stays enabled.
`MinLength` affects creation of new segments. Test the actual swing at slow and
fast speeds. `Enabled = false` stops drawing new segments; `Clear()` removes old
ones. Explicitly handle teleport, respawn, and reuse to avoid a connecting streak.

## Assets, storage, and post effects

Preload only required content with `ContentProvider:PreloadAsync` and inspect its
reported status plus actual rendering. Do not preload the entire Workspace or
assume successful fetching proves a hitch-free first draw. SurfaceAppearance has
documented preloading limitations; use the current API description when diagnosing.

`ServerStorage` is not replicated to clients, but still occupies server/Studio
memory. Scripts there do not run as ordinary active scripts; ModuleScripts can
still be required by server code. Storage location alone is not a security boundary.

Bloom depends on enabled state, threshold, intensity, scene brightness, and graphics
quality. A threshold of 2 does not universally disable it. Keep essential effect
information readable without relying on a particular bloom setting.
