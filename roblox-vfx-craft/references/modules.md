# Bundled module contracts

These are source-inspected examples from the original DIO/sword places, not an
installed framework. Runtime, assets, and rendering were not reverified in Studio
in this revision. Read the selected script before adapting it.

## Contents

- [Required layout](#required-layout-and-assets)
- [Small helpers](#small-helper-contracts)
- [Kit](#kit-contracts)
- [Presentation](#presentation-modules)
- [Larger examples](#larger-examples-and-intake-tools)

## Required layout and assets

Most helpers expect `script.Parent` to contain sibling modules and
`script.Parent.Parent` to contain `Config` and `Assets`. Kit expects `Assets.Vfx`
and `Assets.Meshes`. The named templates are in the original place, not included
as model files here. Emitters also expects the applicable Config palette/sparkle
list. Select the matching summon or ultimate configuration; they are not interchangeable.

Do not import the full ability server to obtain one visual helper. The example
servers include cooldowns, damage, movement, time stop, and other gameplay behavior.
Those systems are outside a request for an isolated cosmetic effect.

## Small helper contracts

| Helper | Actual behavior | Limit or required adaptation |
|---|---|---|
| `Tw.S()` | Reads feature `TimeScale`, defaults to 1 | This custom attribute multiplies durations; it is not ParticleEmitter.TimeScale |
| `Tw.play(inst, props, dur, style, dir, delayTime)` | Returns a Tween immediately, or a table with only `Completed` for delayed creation | Delayed result has no `Cancel`; pending work is not managed per cast |
| `Tw.wait`, `Tw.seq`, `Tw.cseq` | Scaled wait and sequence constructors | Waits can accumulate drift; constructors do not turn sequences into tweens |
| `Emitters.make(parent, spec)` | Creates an emitter from properties plus `texture` and optional `flip` | Sets particle TimeScale to `1 / Tw.S()`; defaults to additive, unlit particles |
| `Emitters.carrier(parent, cf, size)` | Creates an anchored invisible Part with physics interaction and shadow off | A following character attachment needs an explicit follow method |
| `Emitters.burst(...)` | Creates a carrier/emitter, emits, then schedules destruction | Default cleanup is 3 scaled seconds; caller must fit the actual tail |
| `Emitters.sparkles`, `sparkleBurst` | A specific multicolor multi-emitter field | Count is multiplied across layers/colors, not a total particle budget |

`Tw.S()` must be positive. Values below 1 produce an inverse particle speed above
the documented maximum of 1; this helper is not a general fast-forward system.
Changing the attribute does not automatically retime existing tweens, existing
emitters, trails, animation, server events, or audio. A consistent preview needs
those clocks handled explicitly.

The delayed Tw path creates a BindableEvent and does not provide ownership-based
cancellation/disposal. Do not assume the immediate and delayed return values have
the same interface. Adapt scheduling to the current project's lifecycle.

## Kit contracts

| Function | Source behavior |
|---|---|
| `spawn(name, cf, parent)` | Clones `Assets.Vfx[name]`, assigns `.CFrame`, updates descendant particle TimeScale, parents it |
| `mesh(name, parent, cf, size, color, transparency)` | Clones the selected mesh template and assigns the listed properties |
| `each`, `eachBeam` | Visits matching descendants; does not apply to the root itself |
| `tint` | Particle colors vary over age; beam colors vary along the beam |
| `scale` | Multiplies emitter Size keypoints/envelopes and beam widths |
| `glow` | Sets emitter LightEmission and forces LightInfluence to 0 |
| `emit` | Uses a count for each emitter, or name/texture-ID keyed counts |
| `enable` | Toggles matching descendant ParticleEmitters |
| `beams` | Animates beam widths, storing original W0/W1 attributes |
| `kill` | Disables particle emission and beams, then schedules destruction |
| `burst` | Applies selected overrides, emits, and schedules destruction |

`spawn` requires a BasePart template because it assigns `.CFrame`. It does not
anchor the clone or disable its effects; those must already be authored on the
template. It is incompatible with construction.md's Model template until adapted.

`scale` does not scale the source region, attachment positions, mesh geometry,
particle speed, or lifetime. Repeated calls compound. It is not whole-effect scaling.
Choose what a larger effect should actually change before adjusting it.

`kill` does not calculate maximum lifetime or manage trails. Fixed cleanup can
truncate long tails. The helpers contain nil-return guards; new integration should
resolve the required asset contract rather than copy silent skips into user code.

The beam shutdown callback ignores the Tween completion state. Cancellation can
therefore disable a beam that a newer action has just re-enabled. Adapt it to the
cast owner and distinguish successful completion from cancellation before reuse.

## Presentation modules

- `CameraRig`: shot values and smoothing, cuts, shake, and rumble. Module-level state
  and fixed render-step names make it unsuitable for concurrent independent camera
  owners without adaptation. `cut` hard-codes Custom and FOV 70 instead of restoring
  arbitrary prior camera state.
- `ScreenFx`: creates a ScreenGui with flash, edge vignette, flare, bars, and fade.
  Reuse its composition only when requested; author an editable UI template for new
  work and connect it to the project's ownership/lifecycle.
- `ImpactFrames`: creates a ViewportFrame with cloned silhouettes. Inspect performance
  of that actual render path. Historical color/capture workarounds are observations
  from the old place, not universal renderer guarantees.
- `SpeedLines`: a specific procedural Frame/UIGradient composition. Its ray counts
  and pulse durations are artistic settings, not quality requirements.

## Larger examples and intake tools

SummonVfx, Moves, TimeStop, RoadRoller, and UltimateVfx depend on original assets,
configs, animation code, and client/server wiring. Use them to inspect how a beat
was assembled, then extract only the requested behavior. They are not self-contained
replacements for the current project's effect system.

RebuildStandPlace and scripts/rebuild are whole-place recovery tools. They relocate
Workspace content and alter scripts/assets/settings. Do not run them for routine
VFX authoring. ScanPack and MeshGallery also require inspection and an explicit
scope. BlankDeadSounds mutates sound IDs and should only repair selected working
copies after a confirmed failure.
