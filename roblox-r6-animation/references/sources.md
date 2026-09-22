# Source map

Reviewed 2026-09-22. Use these primary references for the claims identified below. Read the relevant source again when changing an engine integration. The animation articles were read as text; this revision does not claim frame-by-frame inspection of their embedded videos.

## Roblox engine and editor

| Primary source | Supports |
| --- | --- |
| [Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D) and its [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Motor6D.yaml) | Transform is an animation offset, is not replicated, and is applied after PreSimulation. The official source was read where the rendered page was unavailable. |
| [Task scheduler](https://create.roblox.com/docs/performance-optimization/microprofiler/task-scheduler) | Write custom Motor6D transforms in PreSimulation. |
| [Pose](https://create.roblox.com/docs/reference/engine/classes/Pose) and its [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Pose.yaml) | Pose names and hierarchy map to connected parts; Pose.CFrame supplies the motor animation transform without replacing the rest offsets. |
| [PoseBase](https://create.roblox.com/docs/reference/engine/classes/PoseBase) and its [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/PoseBase.yaml) | Native easing describes travel toward the next pose. Do not assume Poser's destination-key convention is identical. |
| [KeyframeSequence](https://create.roblox.com/docs/reference/engine/classes/KeyframeSequence) | Sequence, keyframe, and nested pose instances represent animation data. |
| [Animator](https://create.roblox.com/docs/reference/engine/classes/Animator) and its [official source](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Animator.yaml) | Native track loading and server/client replication requirements. The LoadAnimation source was read. |
| [Animation events](https://create.roblox.com/docs/animation/events) | Timeline markers and GetMarkerReachedSignal for native playback. |
| [Animation Editor](https://create.roblox.com/docs/animation/editor) | The supported editor workflow; a local animation save and a published asset are different deliverables. |
| [Create character animations](https://create.roblox.com/docs/tutorials/use-case-tutorials/animation/create-an-animation) | Reference-led key poses, walk landmarks, and playback review. Its demonstrated rig is R15; transfer the principles, not its knee or waist controls, to R6. |

## Animation craft

| Primary source | Supports |
| --- | --- |
| [Jason Martinsen / Animation Mentor - Timing and spacing](https://www.animationmentor.com/blog/tutorial-animate-with-timing-and-spacing-in-mind/) | Reference, blocking, interpolation, and polish as distinct stages; use spacing and rhythm to shape the action. |
| [Wayne Gilbert / Animation Mentor - Believable weight](https://www.animationmentor.com/blog/how-to-create-believable-weight-in-animation/) | Communicate weight through force, balance, posture, and movement. |
| [Drew Adams / Animation Mentor - Follow-through and overlapping action](https://www.animationmentor.com/blog/follow-through-and-overlapping-action-the-12-basic-principles-of-animation/) | Separate follow-through and overlap from the main action; avoid one undifferentiated body movement. |
| [Animation Mentor - Building appealing character poses](https://www.animationmentor.com/blog/tutorial-building-appealing-character-poses-for-animation/) | Design a clear gesture and weight relationship rather than relying on interpolation. |
| [Joseph White / Animation Mentor - Pushing and pulling](https://www.animationmentor.com/blog/tutorial-animating-pushing-and-pulling-motions/) | Plan effort and object interaction through reference and blocking. |
| [Denis Dvoryankin / Animation Mentor - Lifting a heavy object](https://www.animationmentor.com/blog/how-to-animate-weight-and-force-lifting-heavy-object/) | Make preparation and support communicate weight. |

## Evidence boundaries

- The rotation, contact-solve, and loop-measurement procedures are derived for this skill's Poser convention. They are not quoted tutorial recipes.
- Module behavior in pipeline.md comes from reading the bundled code. Reading source is not a Roblox runtime test.
- The World text decodes are bundled and can be reanalyzed. They are rounded samples; they omit source features such as pose weights and do not establish the original asset's authorship or license.
- The idle/run/landing, community walk, and sword tables preserve prior measurements. Their original clips and capture records are not included here. Treat labels such as professional in historical notes as prior descriptions, not independently verified credentials.
- Project review history records preferences for named actions. Do not generalize it into mandatory overshoot, joint offsets, movement budgets, or editor restrictions.
- Current Moon Animator save internals were not verified. Inspect the installed plugin and actual export rather than inventing a schema.
