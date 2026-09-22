# Effect construction recipes

Use these as starting designs, not copied results or certified particle budgets.
All timings and counts in the worked example are illustrative authoring choices.
Fit the reference, camera, animation, and target device before calling them final.

## Contents

- [Impact](#impact)
- [Sword slash](#sword-slash)
- [Projectile](#projectile)
- [Beam and lightning](#beam-and-lightning)
- [Aura and summon](#aura-and-summon)
- [Elemental and environmental effects](#elemental-and-environmental-effects)

## Impact

**Read:** contact, incoming direction, material response, then clear the subject.
Build the `Impact` tree in construction.md. Place its origin at the confirmed
contact and orient support motion from the hit normal and attack direction.

For a small stylized impact with a 0.6-second decorative tail, an initial experiment:

| Layer | Start / lifetime in seconds | Initial burst | Motion and role |
|---|---|---|---|
| `Flash` | Contact / 0.09 | 1 | Stationary primary contour; clear before support dominates |
| `Fragments` | Contact / 0.18-0.32 | 6 | Narrow ejection cone; direction follows the hit |
| `Dust` | Contact + 0.025 / 0.35-0.55 | 3 | Slower expansion; only if the surface/material needs it |

For a 1.5-stud flash, try normalized Size keypoints `(0, 1.2)`, `(0.2, 1.5)`,
`(1, 0.7)` and Transparency `(0, 0)`, `(0.35, 0.15)`, `(1, 1)`.
These are starting curves, not defaults for a weapon class. Counts are per emitter.
Dispose after the last delayed emission and maximum tail, not after the flash.

For a heavy impact, first compare the leading expansion, compressed buildup if the
animation has one, and delayed mass against the light hit. Increase visual scale
only as the mechanic allows. Optional dust or debris should not imply a larger
damage radius. Do not add a screen flash or hit stop merely to sell the contact.

**Diagnose:** weak = late peak or soft contour; white blob = additive overlap;
floating = wrong contact space; confetti = uniform fragments; cut-off = early cleanup.

## Sword slash

**Read:** the blade's swept path and direction, then the actual contact.

| Real instances | Placement and purpose |
|---|---|
| `BladeBase`, `BladeTip` Attachments | Verified positions on the moving weapon |
| `BladeTrail` Trail | Uses those attachments; disabled outside the intended swing |
| Optional `SlashArc` MeshPart | Author its pivot and contour to the actual swing plane |
| Separate `Impact` clone | Spawns at confirmed contact; not at a fixed point beside the caster |

Match the animation's fastest spacing. Clear stale trail history before enabling
the swing, disable new segments on recovery, and retain existing segments for their
tail. Tune attachment width before hiding an error with more particles.

An authored crescent should align with the sweep; an oversized full circle can
erase which way the weapon moved. Preserve negative space between the body and
outer contour. Let fragments or torn wisps follow the cut rather than forming a
radial blast around the body.

**Diagnose:** teleport streak = stale trail; flat wedge = wrong plane/width; a slash
that looks slow = broad persistent trail; bright arc beside the weapon = wrong anchor.

## Projectile

**Read:** source, heading, active flight, impact, and disappearance.

Author a `Projectile` Model with a carrier, a primary head, two trail Attachments,
a Trail, and optional wake emitters. Use separate cast and impact templates so the
projectile can end without erasing its detached impact or remaining trail.

The head leads; wake and detail lag. Keep the core visible against the current map
without hiding the target. Update the cosmetic pose from the existing projectile
system. Keep its trail consistent at different speeds and update rates.

On contact, stop the flight presentation at the confirmed event, detach/retain the
tail as appropriate, and place the impact at the reported position and normal.
On a miss or expiry, use an intentional exit without a false hit confirmation.

**Diagnose:** impact inside a wall = contact data/orientation; double hit = duplicate
event ownership; teleporting smoke = locked emission; white rope = excessive wake.

## Beam and lightning

**Read:** a connected path from source to endpoint. Author endpoint Attachments and
Beam instances; assign their references explicitly. For a laser, a stable narrow
core may suffice. Add broad support only if it improves the silhouette.

For branching lightning, author an ordered main path and subordinate branches with
bounded displacement. Vary the path at an intentional cadence, not random noise on
every render frame. Keep endpoint contact stable. A seed can reproduce authored
variation in debugging; Roblox particles themselves need not be deterministic.

Use attachment axes for curves. Inspect the ribbon from several angles and while
either endpoint moves. Tune the curve resolution instead of increasing segments
without a visible need. Animate whole-beam appearance explicitly; its sequence
gradient describes position along the path.

**Diagnose:** disconnected = endpoint references; paper-thin = facing; rubber hose
= overly smooth undulation; incoherent electricity = branches competing with core.

## Aura and summon

**Read:** whose state changed, what the state means, and when it ends.
Use a named attachment on the actual rig plus an optional separate ground carrier.
For a moving aura, decide which particles stay attached and which detach into the
world. A floor ring must follow ground contact rather than intersect stairs.

Create an entrance, stable state, and exit. Offset supporting rhythms so the entire
effect does not pulse at once unless that is its identity. Keep important body
poses and repeated combat contacts readable. Do not add a camera sequence to a
simple toggle without a request.

For a summon, time the reveal to the animation and silhouette becoming readable.
Choose imagery from the character's identity; clockwork and frozen motion are one
project's vocabulary, not a default for every stand. Repeated toggles must not stack
idle emitters or lights.

**Diagnose:** noisy = synchronized accents or coverage; appears weak = no readable
state transition; aura left behind = ownership/anchor; pop on stop = missing tail.

## Elemental and environmental effects

Start from the physical or fictional process. Give the large motion a clear source
and sink, then layer distinct scales of breakup. Roblox's volcano tutorial is a
useful concrete study of several emitters serving one environment.

| Effect | Real instances and motion | Specific review |
|---|---|---|
| Fire | Volume carrier or flame mesh/flipbook; separate fine embers if useful | Base remains connected; tongues evolve rather than stamp |
| Smoke | Shaped source with expanding, drifting sprites/flipbooks | Rolling masses, no obvious cards, readable subject in overlap |
| Water | Beam/mesh for continuous flow; contact splash plus detached droplets | Flow reaches the surface; splash follows its normal |
| Ice | Authored shard meshes and restrained frost breakup | Faceted silhouette and distinct growth/fracture timing |
| Wind | Directed ribbons or sparse streaks; optional carried dust | Direction reads without a solid opaque tube |
| Ground slam | Surface carrier, outward accent, staggered dust/debris | Fit slopes and ledges; do not float a perfect horizontal disc |
| Portal | Authored opening/edge plus controlled motion into or along it | Inside/outside views, local-space motion, closing transition |

For a continuous environment, inspect entry, several cycles, exit, and the crowded
camera view. Avoid a synchronized restart that reveals the system. Reuse textures
where useful, but do not make all layers share the same size, speed, and lifetime.
