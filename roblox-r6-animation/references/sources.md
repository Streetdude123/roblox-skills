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

## Motion research (2026-09-22, for the motion-first rewrite)

Read as text through web fetches and summaries; no video was watched frame by frame. Numbers taken from these pages are marked as starting ranges in principles.md; the measured numbers come from the decoded clips.

| Source | Supports |
| --- | --- |
| [Autodesk Maya: Graph Editor tangents](https://help.autodesk.com/cloudhelp/2019/ENU/Maya-Animation/files/GUID-43A4FE2C-4863-4EA6-B6AE-6D2B6757F6C7.htm) | Auto tangents: flat at extremes, smooth on transitional keys, clamped between close keys. The `auto` curve in Poser. |
| [Kochanek-Bartels spline](https://en.wikipedia.org/wiki/Kochanek%E2%80%93Bartels_spline) and [Kochanek and Bartels, SIGGRAPH 1984](https://dl.acm.org/doi/10.1145/964965.808575) | Hermite keys with tension; Catmull-Rom as the zero-tension case. `smooth` and `tn`. |
| [t3ssel8r, Giving Personality to Procedural Animations using Math](https://www.youtube.com/watch?v=KPoeNZZ6H4s) with the [code transcript](https://github.com/SalvatoreScalia/Giving-Personality-to-Procedural-Animations-using-Math) | Second order dynamics (f, z, r, the k2 stability clamp). The springs; the presets were measured here. |
| [Daniel Holden, Spring-It-On](https://theorangeduck.com/page/spring-roll-call) | Critically damped springs, halflife damping, inertialization as a decaying offset. The inertial blend. |
| [David Rosen, An Indie Approach to Procedural Animation (GDC 2014)](https://www.gdcvault.com/play/1020583/Animation-Bootcamp-An-Indie-Approach) | Fluid, responsive characters from very few key poses plus interpolation and procedural layers (Overgrowth: four poses per walk and run cycle). |
| [Little Polygon, Procedural locomotion](https://blog.littlepolygon.com/posts/loco1/) | Lean from acceleration, bob at half the cadence for roll, springs with a duration-based omega. |
| [Jonathan Cooper, The 12 principles in video games](https://www.gamedeveloper.com/production/the-12-principles-of-animation-in-video-games) and [the five fundamentals](https://www.linkedin.com/pulse/five-fundamentals-video-game-animation-jonathan-cooper) | Anticipation against response, control returned before the follow-through ends, fast-in slow-out swings, holds after a swing, feel, fluidity and settling. |
| [Rivals Workshop: anticipation, action, recovery](https://www.rivalslib.com/workshop_guide/art/anticipation_action_recovery.html) | Readable anticipation silhouettes, over-extended recoveries that pop back, long slow motion reads weak. |
| [Sunstrike Studios, Timing in animation](https://sunstrikestudios.com/en/blog/timing_in_animation/) | Arrive, overshoot, settle halving each stage; one or two bounces; hit pauses of 2 to 6 frames; even spacing syndrome. |
| [AnimSchool, Moving holds](https://blog.animschool.edu/2024/11/27/create-moving-holds-animating-nothing/) and [idles](https://blog.animschool.edu/2024/06/14/breathing-life-into-idle-animations/) | Drift in the direction of the last momentum, breathing, head support; hips drive and overlap travels up the spine; macro variation over three to six loops; never still. |
| [Overlap and successive breaking of joints](https://rbossert27.wixsite.com/mysite-2/post/creating-overlap) (after Richard Williams) and [Animation Mentor pendulum overlap](https://www.animationmentor.com/blog/tutorial-overlap-pendulum-motion-animation/) | The tip trails the base; one or two frame offsets per link; things do not stop all at once. |
| [AnimSeeds, posing principles](https://www.animseeds.com/post/21-posing-principles-for-animation-and-figure-drawing-for-animators) | Line of action, contrapposto, twinning, negative space, push the pose, head and hand gesture. The posing checklist. |
| [MoCap Online, idle design](https://mocaponline.com/blogs/mocap-news/idle-animation-game-dev-guide) | Additive breathing layers and idle variations. |

## Evidence boundaries

- The rotation, contact-solve, and loop-measurement procedures are derived for this skill's Poser convention. They are not quoted tutorial recipes.
- Module behavior in pipeline.md comes from reading the bundled code. Reading source is not a Roblox runtime test.
- The World text decodes are bundled and can be reanalyzed. They are rounded samples; they omit source features such as pose weights and do not establish the original asset's authorship or license.
- The idle/run/landing, community walk, and sword tables preserve prior measurements. Their original clips and capture records are not included here. Treat labels such as professional in historical notes as prior descriptions, not independently verified credentials.
- Project review history records preferences for named actions. Do not generalize it into mandatory overshoot, joint offsets, movement budgets, or editor restrictions.
- Current Moon Animator save internals were not verified. Inspect the installed plugin and actual export rather than inventing a schema.
