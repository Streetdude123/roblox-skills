---
name: roblox-vfx-craft
description: Design, build, critique, and optimize Roblox VFX through reference breakdowns, shape and timing block-ins, editable instance templates, layered particle and mesh work, and Studio playback review. Use for ability effects, impacts, slashes, projectiles, beams, auras, elemental and environmental effects, summons, and cinematic sequences. Supports supplied VFX packs and new assets, with current Roblox API guidance and optional adapters for the bundled Kit, Emitters, Tw, and camera modules.
---

# Roblox VFX craft

Make the action readable and the motion intentional. Work like an effects artist:
study the reference, design the effect, block its motion, build its assets, review
playback, and refine the weakest part. A long script or dense particle burst is not
evidence of professional quality.

## Working contract

- Read the current project instructions and inspect its effect hierarchy, runtime,
  camera, rig, assets, and existing visual language before changing them.
- Ask targeted questions when the reference, gameplay meaning, timing, scale, target
  device, or allowed camera treatment is missing and changes the result. Do not
  assume a pack, character, shader feature, or animation marker exists.
- Build UI and VFX as a real instance tree. Author named, editable templates in
  Studio or the project's native instance format. Runtime code clones, positions,
  plays, and disposes of those templates. A design table alone is not the effect.
- Keep required inputs explicit. Do not add defensive guards, silent fallbacks,
  broad error swallowing, or a new framework to conceal a broken asset contract.
- In new or edited Luau, use plain `--` comments only. Keep them lowercase, without
  punctuation, and limited to reasons for a bug fix or a rejected option. No banners
  or top documentation block.
- Respect existing gameplay. VFX does not authorize new damage, knockback, character
  locks, hit stop, camera takeover, screen flashes, sound, or global lighting changes.
- Use available Studio tools according to their actual capabilities. Without Studio,
  prepare the requested source/assets and identify what remains unverified. Never
  claim to have watched, instantiated, profiled, or published something you did not.

## Read only the references needed for this task

| Task | Read |
|---|---|
| Every new design or visual critique | [Principles](references/principles.md), [art direction](references/art-direction.md) |
| Build or integrate an effect | [Instance construction](references/construction.md), [Roblox API details](references/roblox-api.md) |
| Choose textures, meshes, or flipbooks | [Asset craft](references/asset-craft.md) |
| Impact, slash, projectile, beam, aura, or environment | [Effect recipes](references/effect-recipes.md) |
| Use a supplied pack | [Kit workflow](references/kit-workflow.md) |
| Use the bundled example modules | [Module contracts](references/modules.md); then read the actual selected script |
| Cinematic or requested audio work | [Cinematics](references/cinematic.md), [sound](references/sound.md) |
| Review or optimize | [Verification](references/verification.md) |
| Check a claim or study an artist | [Sources and tutorials](references/sources.md) |
| Continue the original DIO/sword places | [Project preferences](references/taste.md), [archived measurements](references/project-history.md) |

Use [effect-plan.md](templates/effect-plan.md) as a compact working brief. Record
results in [review.md](templates/review.md). These are working aids, not mandatory
long reports to the user.

## 1. Define the effect's job

Record what happened, where it happened, who needs to read it, and when it matters.
Separate the gameplay boundary from decorative spill. Establish the cast, release,
contact, active, and end events supplied by the project. A projectile must not
show a hit before the authoritative contact; a fading aura must not imply a buff
remains active after it ends.

Choose the viewing context before the spectacle:

| Context | Design priority |
|---|---|
| Repeated gameplay hit or toggle | Contact, direction, readable body, rapid visual recovery |
| Persistent aura, hazard, or environment | State, occupancy, restrained rhythm, clean start and stop |
| Signature ability | Distinct silhouette and buildup within the actual gameplay window |
| Requested cinematic | Shot composition, escalation, contrast, deliberate handoff |

Do not impose a fixed duration or number of layers on a category. An ultimate can
be brief; a persistent environmental effect can be quiet. Use the real brief.

## 2. Study reference before tuning properties

Inspect supplied footage or find relevant artist breakdowns and real phenomena.
Use a small set with a purpose: one for motion, one for visual language, and the
current game for integration. Research deeply enough to answer the actual unknown;
do not collect unrelated links or imitate a famous game's entire style by default.

Record source/timecode, camera, silhouette, leading edge, focal point, intensity
change, material behavior, and disappearance. Separate observations from inferred
implementation. A still supports shape and color judgments, not timing. A search
snippet or course outline is not a watched tutorial.

Turn observations into decisions using [art-direction.md](references/art-direction.md).
Choose what to retain, change, and omit. If creative direction is authorized,
compare a few silhouette or timing options before detailing one.

## 3. Plan a small number of purposeful layers

Name the dominant shape and motion in plain language, such as "a narrow hot cut
that opens into torn smoke." Avoid designing from an emitter shopping list.

For each layer record its role, instance path, anchor/coordinate space, asset,
start/stop event, curve, tail, and importance at reduced quality. Every layer must
contribute information, motion, material, or controlled contrast.

Separate primary motion, supporting motion, and small detail. Their peaks, travel
distance, edge character, and disappearance should not all be identical. Reserve
quiet space around the subject and gameplay boundary. A primary element need not
be simultaneously the largest, brightest, and most saturated.

## 4. Block the motion and judge it in playback

Use real carriers, simple particles, beams, trails, or meshes in a neutral palette.
Keep the gameplay camera, timing, surface, and body scale. Build only enough to
prove direction, speed, footprint, contact, and the transition out.

Review start, anticipation if present, peak, breakup, and tail at normal speed.
Inspect slow playback to diagnose a defect, then return to normal speed. Use elapsed
time and event crossings, not a count of render frames, for runtime timing.

If the block-in lacks force, test peak timing, travel spacing, silhouette change,
and the contrast between active and quiet phases before adding detail. Do not add
anticipation to an instantaneous hit confirmation or slow a gameplay attack just
to fit an attractive buildup.

## 5. Build and polish the assets

Choose the tool for the silhouette, not the reverse. Use a particle for a sprite,
a trail for swept motion, a beam for a controlled connection, and a mesh when
volume/parallax matters. Inspect supplied pieces individually before layering.

Use [asset-craft.md](references/asset-craft.md) and the relevant recipe. Match edge
quality, directional flow, texture density, and material behavior to the reference.
Do not promise Unity/Unreal shader operations through unrelated Roblox properties.

Refine in this order: silhouette and spacing, timing, value hierarchy, color,
material breakup, then small detail. Isolate each layer; restore it only if the
whole effect improves. Revisit an earlier pass when it is the actual problem.

## 6. Integrate with explicit ownership

Follow [construction.md](references/construction.md). Use the current gameplay
events and networking model. Keep cosmetic instances on the client where the
project supports it; keep gameplay authority in its existing server system.

Give each cast an owner and lifecycle. Stop emission before destroying its tails.
Cancel scheduled work on interruption. Clean up attachments, temporary models,
connections, sounds, and requested camera/UI state on normal completion and cancel.
Treat cancellation as required behavior, not an excuse to hide errors.

Keep the editable template and a repeatable preview trigger available. Validate
the final instance paths and asset references after integration.

## 7. Review against a professional quality bar

Use [verification.md](references/verification.md). Capture the same event and camera
before and after a change. Look at normal speed, selected frames, and the actual
gameplay distance. Review in context as well as on a neutral background.

Require evidence for each relevant gate:

- **Meaning:** action, direction, state, and gameplay boundary read correctly.
- **Design:** a distinct silhouette and coherent material language survive small
  screen size; detail supports the subject.
- **Motion:** contact lands on time, spacing expresses force, and tails finish
  intentionally without accidental holds or cutoffs.
- **Integration:** moving anchors, slopes, interruption, rapid recasts, and multiple
  viewers behave as required.
- **Performance:** first use, repeated use, and plausible overlapping use meet the
  agreed budget on the target device and quality level.
- **Handoff:** the actual editable tree, controls, preview route, and limitations
  are present and accurately described.

Fix the most visible failing gate, replay, and compare. Stop when the relevant
gates pass; do not add layers simply because time remains. Mark untested gates as
unverified. Documentation checks cannot certify artistic quality.

## Bundled examples

`scripts/` contains the original DIO and sword showcase implementations, not a
drop-in VFX framework or a complete asset library. The referenced Roblox templates,
asset permissions, and companion animation modules are not all packaged here.
Use [modules.md](references/modules.md) before reusing one. Do not run a whole-place
rebuild to create an isolated effect.

Preserve useful project preferences without turning them into universal rules.
Do not invent review quotes or automatically write a new user's feedback into this
shared skill. Keep task-specific observations with the project.
