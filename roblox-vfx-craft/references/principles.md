# VFX design principles

Use these as decisions to evaluate, not a checklist of decorations. The Roblox
applications are this skill's synthesis. Source scope is recorded in sources.md.

## Contents

- [Meaning and hierarchy](#meaning-and-hierarchy)
- [Shape and flow](#shape-spacing-and-flow)
- [Value and color](#value-and-color)
- [Timing and spacing](#timing-and-spacing)
- [Material behavior](#material-behavior)
- [Critique](#critique-before-adding-intensity)

## Meaning and hierarchy

Riot's artist education emphasizes a clear action and a consistent visual language
across a game. Apply that by identifying the event's focal point and the information
that must survive overlapping effects. Rank those needs before choosing intensity.

| Decision | Practical test |
|---|---|
| Focal point | At gameplay distance, identify the intended subject without searching |
| Gameplay boundary | Compare the perceived footprint and contact to the actual mechanic |
| Primary versus support | Disable the detail layer; the action should still make sense |
| Scale of importance | Compare this effect to its neighboring abilities in the same game |
| Quiet space | Check whether the target, weapon, aim area, and floor remain readable |

Size, value, saturation, speed, edge sharpness, and location all attract attention.
Choose which carries the focal point. A broad dim dust shape can support a small
sharp contact. Do not maximize every attention cue on every layer.

## Shape, spacing, and flow

Start with a recognizable outer contour and an intentional direction. Distribute
large masses, medium breakup, and small accents with unequal spacing. Uniform
scales, angles, and gaps usually reveal the emitter rather than the action.

Use asymmetry with a cause: an impact normal, swing direction, flow, pressure, or
wind. Keep randomness within that design. A spherical burst is appropriate when
energy radiates; it is inappropriate when a blade needs to show a narrow cut.

Alternate edge character where the material calls for it. A sharp liquid leading
edge can break into round droplets. Hot fragments can sit against softer smoke.
Hard geometry, pure white, dark shapes, and a single emitter are all valid when
they achieve the intended result. No mandatory transparency or glow partner.

## Value and color

Review a grayscale view and a small thumbnail. If the action vanishes, correct
contrast or contour before increasing color saturation. Judge in the real
environment: a pale flash can disappear against a bright sky.

Assign palette roles, then choose their values: body, focal accent, and optional
support. Preserve the game's established team and state meanings. Hue alone should
not carry an essential distinction. A healing effect does not have to be green;
a dangerous effect does not have to be red.

Avoid additive overlap that clips different layers into one white mass. Reduce
overlap, opacity, brightness, or bright screen area according to the cause. Bloom
can support a silhouette but cannot replace one. A dark rim is an option, not a
requirement for fire, water, smoke, or magic.

## Timing and spacing

Keyser's block-in approach isolates motion using simple shapes and grayscale.
Use it to evaluate the effect before expensive asset work. The VFX Apprentice
timing article distinguishes short impulses from recurring rhythms; select the
pattern that matches the action instead of forcing every effect into a buildup.

| Motion intention | Curve decision | Failure to look for |
|---|---|---|
| Immediate impact | Strong first state, quick expansion, separate tail | Slow fade-in that feels late |
| Charge | Increasing tension toward a known release | Repetitive pops that look like early hits |
| Heavy release | Fast leading motion, lagging mass, diminishing residual motion | Every layer moving at one speed |
| Constant jet/laser | Stable travel with authored intensity changes | Unnecessary easing that suggests acceleration |
| Living loop | Bounded variations around a stable state | Synchronized pulses and a visible restart |

Timing is duration; spacing is distance traveled between samples. Compare both.
Design a few meaningful changes in speed rather than applying the same easing to
all properties. Linear motion can be correct. Keyframes, curves, and physics are
tools; none is automatically the professional choice.

David Hall's Sparkball account illustrates why a project's style guide must allow
exceptions: an abrupt state ending can communicate more clearly than a decorative
fade. Preserve that distinction when the disappearance itself carries gameplay meaning.

State timings in seconds and include a reference frame rate when studying frames.
Three frames at 60 fps means 0.05 seconds, not three runtime render callbacks.
Let the main action finish before residual motion settles where the brief allows.
Give a loop a deliberate entrance and exit as well as a stable middle.

## Material behavior

Identify what moves the material and how it loses energy. Use these questions to
guide stylization; do not impose physically realistic simulation on an anime brief.

| Material | Useful motion distinction |
|---|---|
| Fire | A moving tongue or volume breaks apart; fine embers separate from the mass |
| Smoke | Coherent lobes expand and roll; fading alone should not expose repeated stamps |
| Electricity | A readable connected path changes in discrete bursts; branches stay subordinate |
| Water | A sheet or jet stretches, breaks into droplets, then responds to gravity/contact |
| Dust/debris | Initial ejection leads to ballistic fragments and slower suspended dust |
| Magic | Define an invented rule, then apply it consistently to shape, rhythm, and exit |

## Critique before adding intensity

Translate feedback into a visible cause and a controlled change. "Needs more power"
may mean a weak contact, too much buildup, no scale cue, or a slow leading edge.
"Messy" may mean excessive coverage, overlapping values, competing directions, or
too many simultaneous peaks. Reducing layer count alone does not diagnose all four.

Choose one hypothesis, change the smallest relevant set of variables, and compare
the same view. Keep the change only if the intended read improves. Camera shake,
screen flashes, bass, and hit stop cannot repair a weak world-space effect.
