# Sources and tutorial map

Research checked 2026-09-22. Use primary artist explanations and official Roblox
API documentation. Links below identify exactly what was available to inspect.
The workflows and recipes in this skill are original synthesis, not copied course
material or a claim that their example settings are prescribed by these artists.

## Artist instruction and production breakdowns

| Source | Read it for | Evidence and scope |
|---|---|---|
| [Riot Games - Visual Effects](https://www.riotgames.com/en/artedu/visual-effects) | Gameplay communication and coherent visual language | Public artist-education article and linked episode; article inspected, episode not watched in this revision |
| [Jason Keyser - Block-ins and Timing](https://realtimevfx.com/t/block-ins-and-timing/29830) | Simplifying a design to isolate timing and composition | Author's public explanation and case-study descriptions; text inspected |
| [VFX Apprentice - The Soul of Effects](https://www.vfxapprentice.com/blog/the-soul-of-effects-what-is-timing-in-vfx) | Impulse/rhythm, timing charts, and reference-based timing exercises | Public article inspected; embedded video lessons not independently watched |
| [David Hall - Creating VFX Style Guides for Games](https://www.vfxapprentice.com/blog/creating-vfx-style-guides-for-games) | A VFX director's account of Sparkball's shape, value, and timing decisions | First-person production article inspected; its bold shapes and fast decay are project choices, not universal rules |
| [Ali Sorensen - Hand-Painted Textures for Stylized FX](https://www.vfxapprentice.com/courses/hand-painted-textures-stylized-fx) | Silhouettes, edge control, impact/ring textures, and tiling strips | Public curriculum inspected; paid lesson contents not accessed |
| [Dan Elder - FX Design Principles](https://www.vfxapprentice.com/courses/fx-design-principles) | Intention, physical properties, composition, and FX design study | Public curriculum inspected; paid lessons not accessed |
| [Dan Elder - FX Timing Principles](https://www.vfxapprentice.com/courses/fx-timing-principles) | Frame planning, spacing, anticipation, and follow-through study | Public curriculum inspected; paid lessons not accessed |
| [VFX Apprentice - Flipbooks in Game FX](https://www.vfxapprentice.com/blog/what-are-flipbooks-in-games) | Animated texture workflows and per-frame resolution tradeoffs | Public article inspected; use Roblox's actual layout/API limits instead of general engine assumptions |
| [Kevin Leroy / Sirhaian - League VFX fan-art breakdown project](https://realtimevfx.com/t/releasing-my-league-vfxs-fan-arts-for-study-purposes/1435) | How a working artist exposes layers, textures, meshes, and animation for study | Author's public release post inspected; project not downloaded or executed; study permission is not blanket asset reuse permission |
| [Riot Games - 2023 VFX contest criteria](https://www.riotgames.com/en/news/vfx-contest-league-valorant-2023) | A concrete external review framework: cohesion, satisfaction, style, and a full cast-to-outro sequence | Public criteria inspected; contest presentation restrictions are not general production requirements |

For deeper study, follow the actual lesson/video linked by the author when access
is available. Extract the principle, compare its example to the current brief,
and map it to a supported Roblox technique. Do not claim a course outline proves
what is demonstrated inside a gated video.

## Roblox documentation

Creator Hub's rendered API pages sometimes omit property descriptions. In that
case the corresponding YAML in Roblox's official creator-docs repository was
inspected. Both are primary Roblox sources, not community API guesses.

| Source | Verified topic |
|---|---|
| [Particle emitters](https://create.roblox.com/docs/effects/particle-emitters) | Parenting, texture workflow, source region, and graphics-quality review |
| [ParticleEmitter API](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ParticleEmitter.yaml) | TimeScale, Squash, emission, blending, ZOffset, and flipbook semantics |
| [Beams](https://create.roblox.com/docs/effects/beams) | Endpoint construction, local-axis curvature, texture repetition, facing |
| [Beam API](https://create.roblox.com/docs/reference/engine/classes/Beam) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Beam.yaml) | Sequence domain and segment/keypoint requirements |
| [Trails](https://create.roblox.com/docs/effects/trails) | Attachments and movement-generated ribbons |
| [Trail API](https://create.roblox.com/docs/reference/engine/classes/Trail) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Trail.yaml) | Segment lifetime, WidthScale, MinLength, and clearing |
| [NumberSequence](https://create.roblox.com/docs/reference/engine/datatypes/NumberSequence) | Keypoint representation; property-specific interpretation |
| [TweenService](https://create.roblox.com/docs/reference/engine/classes/TweenService) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TweenService.yaml) | Supported interpolated types and competing property writes |
| [TweenBase.Completed](https://create.roblox.com/docs/reference/engine/classes/TweenBase/Completed) | Completion also fires on cancellation; inspect PlaybackState before chaining |
| [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ContentProvider.yaml) | Essential-asset preload, status reporting, invisible asset behavior, SurfaceAppearance limitations |
| [ServerStorage](https://create.roblox.com/docs/reference/engine/classes/ServerStorage) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ServerStorage.yaml) | Client access/replication and script versus ModuleScript behavior |
| [BloomEffect](https://create.roblox.com/docs/reference/engine/classes/BloomEffect) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/BloomEffect.yaml) | Brightness threshold, enabled state, placement, and quality dependence |
| [SurfaceAppearance](https://create.roblox.com/docs/reference/engine/classes/SurfaceAppearance) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/SurfaceAppearance.yaml) | PBR maps and runtime-edit constraints; not an arbitrary shader graph |
| [AnimationTrack](https://create.roblox.com/docs/reference/engine/classes/AnimationTrack) / [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/AnimationTrack.yaml) | Existing animation markers as event sources |
| [Design for performance](https://create.roblox.com/docs/performance-optimization/design) | Baseline devices, replication, memory, and emulator limitations |
| [Improve performance](https://create.roblox.com/docs/performance-optimization/improve) | Transparency overdraw and emitter/property-update cost; relevant official search excerpts inspected |
| [MicroProfiler](https://create.roblox.com/docs/performance-optimization/microprofiler) | Frame-time spikes and identifying workload rather than guessing from particle count |
| [Create volcanic eruptions with VFX](https://create.roblox.com/docs/tutorials/use-case-tutorials/vfx/create-volcanoes) | Roblox-native layered environmental effect construction; written tutorial inspected |

## Apply the research without creating false rules

Use Keyser's simplified motion studies for block-in review, Hall's production
account to understand why style rules change with context, and the texture/flipbook
resources to identify asset problems. Confirm engine facts with Roblox documentation.

Particle counts, durations, palettes, and staging in effect-recipes.md are illustrative
choices made for this skill. Historical benchmarks in project-history.md were
preserved from the previous revision and were not rerun. No source read here proves
that a generated effect achieves professional quality without playback review.
