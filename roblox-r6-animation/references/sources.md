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

## Motion research

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
- The project history in `projects/` records preferences for named actions. Its universal lessons are already rules in SKILL.md and the references; do not generalize its remaining taste notes into mandatory overshoot, joint offsets, movement budgets, or editor restrictions.
- The research tables below were read as text pages and re-checked by an independent reader. Numbers the skill derives from them (frame conversions, R6 scalings) are marked as derivations where they are used.
- Current Moon Animator save internals were not verified. Inspect the installed plugin and actual export rather than inventing a schema.

## Lesson videos

Studied from the full caption transcripts plus frame grids of the demonstrations; the notes are in [lesson-videos.md](lesson-videos.md).

| Primary source | Supports |
| --- | --- |
| [AlanBeckerTutorials, "12 Principles of Animation (Official Full Series)"](https://youtu.be/uDqjIdI4bF4) | Squash and stretch with volume, levels of anticipation, staging, pose to pose against straight ahead, follow-through and drag, slow in and out (no ease into a collision), arcs and smears, secondary action, the frames-to-meaning timing example, exaggeration, twinning, appeal. |
| [NobleFrugal Studio, "The #1 Animation Principle (How To In-Between)"](https://youtu.be/6UXjRCORV44) | Timing against spacing, frames against drawings, halves, thirds and favours, stopwatch timing, the timing chart for a hammer slam. |
| [Kuzillon, "6 Beginner ANIMATION MISTAKES to avoid!"](https://youtu.be/-WUhB9DLrqo) | Too slow, constant speed, the fading domino of body motion, arcs, simplify first, edges. |
| [Bluebiscuits, "How to do Basic Animation from a beginner to a beginner"](https://youtu.be/Al_k9hmd4ws) | Start and end frames first, favour frames, mixed 2-3-4-2 holds, circles, squash and pull on in-betweens, the settle, the pull-back, the bounce, staggered secondary parts. |
| [Alexander Rudenko, "Physics in animation"](https://youtu.be/x3jaDhGUHuw) | Centre of mass, balance against the support area, rotation around the COM, ballistic COM, speed gained and lost only through support (spring leg, stopper leg), spin speed against pose, through motion and harmonic settles, the common contact-freeze mistakes, bouncing-ball points, the layered method, arcs. Studied from the caption transcript and the 226 storyboard frames; the video stream was blocked, so the demos were not frame-stepped. |

## Body mechanics research

Checked 23 findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [body-mechanics.md](body-mechanics.md). The sources below were read as text; no video stream was opened.

| Source | Supports |
| --- | --- |
| [BSP_DempsterWinter.txt (data behind the notebook 'Body segment parameters', BMClab)](https://raw.githubusercontent.com/BMClab/BMC/master/data/BSP_DempsterWinter.txt) | Winter's version of Dempster's table gives these whole-segment mass fractions: head-neck 0.081, trunk 0.497, each total arm 0.050, each total leg 0.161. |
| [Roblox units](https://create.roblox.com/docs/en-us/physics/units.md) | Roblox documents default gravity as 196.2 studs/s^2 and 1 stud as 28 cm. |
| [Humanoid (Engine API reference)](https://create.roblox.com/docs/reference/engine/classes/Humanoid.md) | Humanoid jump defaults: JumpHeight 7.2 studs, JumpPower 50 (allowed range 0 to 1000). |
| [Galileo Got Game: 5 Things You Didn't Know About the Physics of Basketball](https://empiricalzeal.com/2014/04/23/basketball-physics/) | A jumper spends 71% of the hang time in the top half of the jump height, because fall time grows with the square root of fall distance (empiricalzeal). |
| [Principles of Animation Physics, Part 1: Timing, Spacing, and Scale](https://www.animatorisland.com/physics-in-animation-how-important-is-it/) | Under constant gravity, the spacing from the apex grows in odd numbers: 1, 3, 5, 7; Gravity-driven timing tells the viewer how big things are. |
| [Do some athlete's inertial properties give them a natural advantage when performing pure somersaults?](https://ojs.ub.uni-konstanz.de/cpa/article/view/6056/5536) | Median τr (moment of inertia relative to layout, somersault axis): layout arms up 1.16, layout 1.00, open pike 0.70, pike 0.49, tuck 0.46, tight tuck 0.34 (cowboy tuck 0.35). |
| [Rotating Bodies and Angular Momentum: Diving (transcript)](https://media-podcast.open.ac.uk/feeds/mst209-rotating-bodies/transcript/mst207rotating3.pdf) | All rotation is created at take-off, by a torque while the feet still push. |
| [Identifying Consistent Metrics from the Force-Time Curve of the Countermovement Jump in Combat Fighters and Physically Active Men](https://pmc.ncbi.nlm.nih.gov/articles/PMC10464753/) | In a countermovement jump with self-selected depth (heights 39 to 44 cm), the phases last: unweighting (dropping) 287 to 305 ms, braking 115 to 168 ms, propulsion 256 to 300 ms. |
| [The analysis of knee joint loading during drop landing from different heights and under different instruction sets in healthy males](https://pmc.ncbi.nlm.nih.gov/articles/PMC5243232/) | In drop landings from 22 and 44 cm, peak knee flexion was 75 to 88° for soft landings, 51 to 67° for natural ones and 45 to 59° for stiff ones. |
| [Kinematic analyses of gait](https://ouhsc.edu/bserdac/dthompso/web/gait/KNMATICS/gait.htm) | In normal adult walking, the COM moves about 5 cm up and down with two peaks and two troughs per gait cycle. |
| [Trajectory of the Human Body Mass Centre During Walking at Different Speed (DESIGN 2002)](https://www.designsociety.org/download-publication/29655/Trajectory+of+the+Human+Body+Mass+Centre+During+Walking+at+Different+Speed) | Measured walking speeds: normal walking 0.95 to 1.7 m/s (mean 1.27), fast walking 1.7 to 2.4 m/s (mean 1.96). |
| [Physics in Animation: Weight Gain and Loss](https://www.animatorisland.com/physics-in-animation-weight-gain-and-loss/) | Moving against gravity (rising while speeding up, or falling while slowing down) adds apparent weight. |
| [Limits of stability](https://en.wikipedia.org/wiki/Limits_of_stability) | A standing person can sway safely within a cone of about 12.5° front to back and 16° side to side. |
| [Principles of Animation Physics, Part 4: Center of Gravity](https://www.animatorisland.com/principles-of-animation-physics-part-4/) | Shifting the centre of gravity a few inches to one side is enough to cause a significant weight shift; A character carrying a load leans so the combined centre of gravity stays over the base of support: forward for a backpack, and with the load held close to the body for a heavy object in front. |
| [Anticipation / Reaction](https://brianlemay.com/Pages/animationschool/animation/animationexamples/anticipation.html) | Before a foot can lift, the weight must move from between both feet onto one foot. |
| [Animating Weight](https://blog.animschool.edu/2025/05/02/animating-weight/) | A character pushing a heavy object leans, braces and moves the centre of gravity: the feet push backward and the torso leans forward. |
| [Physics in Animation: Action-Reaction](https://www.animatorisland.com/physics-in-animation-action-reaction/) | Every action force has an equal and opposite reaction on the other body. |
| [Physics in Animation: Momentum and Force](https://www.animatorisland.com/physics-in-animation/) | For the same hit, a heavier character recoils and deflects less than a lighter one. |
| [Terminal velocity](https://en.wikipedia.org/wiki/Terminal_velocity) | Terminal velocity is V_t = √(2mg/(ρAC_d)), so through drag, mass matters only relative to area and drag coefficient. |
| [Pendulum](https://en.wikipedia.org/wiki/Pendulum) | A pendulum's small-swing period is T = 2π·sqrt(L/g), whatever its mass. |
| [Animation Alley - Arcs](https://www.renderosity.com/amp/article/10557/animation-alley---arcs) | In a walk, the hips shift side to side onto the supporting leg while bobbing up and down like a bouncing ball. |

## Combat research

Checked 27 findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [combat.md](combat.md). The sources below were read as text; no video stream was opened.

| Source | Supports |
| --- | --- |
| [SF Seminar column: hit stop, hit stun and frame advantage (Capcom Fighters Network)](https://game.capcom.com/cfn/sfv/column/131545) | Fighting games set hitstop per game, usually rising with attack strength; A projectile hit freezes only the victim. |
| [Hitlag](https://www.ssbwiki.com/Hitlag) | Smash computes hitlag from damage (Ultimate: floor((0.65d + 6) x multipliers)), capped at 20 frames in Melee and 30 from Brawl on, so bigger hits get longer holds; Multi-hit moves and crowded fights get shorter hitstop. |
| [Thinking About Hitstop - Sakurai's Famitsu Column, Vol. 490-1 (translation)](https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/) | During hitstop the victim vibrates and the attacker keeps moving very slowly. |
| [Game developers explain what makes God of War (2018)'s combat tick](https://blog.playstation.com/?p=370399) | The victim reaches its hit pose on the contact frame with no blend; God of War's pulled-back camera and reduced camera shake trade impact for legibility. |
| [SF Seminar: cancels](https://game.capcom.com/cfn/sfv/column/132455?lang=en) | In Street Fighter a special cancel is input during the hitstop and replaces the rest of the normal move, so a longer hold gives a wider cancel window. |
| [Combat Canceled: God of War & Action Game Design](https://www.gamedeveloper.com/game-platforms/combat-canceled-i-god-of-war-i-action-game-design) | Action games split cancels into pre-hit and post-hit windows. |
| [Interruptible](https://www.ssbwiki.com/Interruptible) | An attack's animation keeps playing past the first actionable frame. |
| [Ultimate Frame Data: Mario (and the Ganondorf page, https://ultimateframedata.com/ganondorf)](https://ultimateframedata.com/mario) | In these Smash Ultimate examples, light and heavy ground strikes differ mostly in startup (2-7 vs 15-29 frames) and recovery (16-18 vs 30-38 frames), with 2-4 active frames. |
| [Using Frame Data](https://dustloop.com/w/Using_Frame_Data) | In Dustloop's GGAC examples, Jam's 5K totals 15 frames and her three-hit 5H totals 42. |
| [SF Seminar: frame advantage and punishing](https://game.capcom.com/cfn/sfv/column/131611?lang=en) | In Capcom's light-punch example the victim's 13-frame hit stun outlasts the attacker's 9 remaining frames, giving +4, so a 4F-startup move combos. |
| [Hitstun](https://www.ssbwiki.com/Hitstun) | Smash scales the victim's stun with knockback at 0.4 frames per knockback unit, so the reaction length follows the hit's strength. |
| [For Honor Patch Notes 2.47.1](https://www.ubisoft.com/es-es/game/for-honor/news-updates/68EofQM7GDkbnHKlRnWp1r/patch-notes-2471-for-honor) | Ubisoft tested a PvP opener at 500, 466, 433 and 400 ms against measured player reaction times and fixed it at 433 ms. |
| [Tips on Weapon Attack Animation From God of War Animator](https://80.lv/articles/tips-on-weapon-attack-animation-from-god-of-war-animator) | Rotate the weapon so more of the blade faces the viewer. |
| [The 12 Principles of Animation in Video Games](https://www.gamedeveloper.com/production/the-12-principles-of-animation-in-video-games) | In a punch the head and torso lead and the arm snaps forward just before impact. |
| [This Is Not An Overwatch Glitch](https://kotaku.com/this-is-not-an-overwatch-glitch-1777612546) | Overwatch's smear frames stand in for missing motion blur. |
| [Rivals Workshop Guide: Posing (Smears, Exaggeration, Silhouette)](https://www.rivalslib.com/workshop_guide/art/pose.html) | A smear tapers toward its tail, runs on an arc from near the previous frame's position, implies the hitbox, and fades over a few frames. |
| [Biarc Interpolation](https://ryanjuckett.com/biarc-interpolation) | A frame-sampled trail draws straight chords between frames, and a fast swing gives very few samples, while a sword tip really moves on a circle. |
| [Tips on Making Fluid and Powerful Animations](https://80.lv/articles/tips-on-making-fluid-and-powerful-animations) | One overshoot frame past the target, then a pull back, adds power. |
| [GuiltyGear Xrd's Art Style: The X Factor Between 2D and 3D (GDC 2015 slides)](https://www.ggxrd.com/Motomura_Junya_GuiltyGearXrd.pdf) | Guilty Gear Xrd animates its 3D characters with no interpolation between keys; every frame is a hand-posed key, because interpolation made the characters look 3D. |
| [Rivals Workshop Guide: Anticipation, Action, Recovery](https://www.rivalslib.com/workshop_guide/art/anticipation_action_recovery.html) | An anticipation must show where the attack will hit, the active pose must show the hitbox's size and duration, and the last frames of the recovery must not look like the idle. |
| [Interview with the Developers of Dead Cells](https://80.lv/articles/interview-with-the-developers-of-dead-cells) | Dead Cells sells a critical hit with a 1-frame freeze, then a slow-down of a few tenths of a second, a blood spray and a specific impact sound. |
| [Hitstop/Hitfreeze/Hitlag/Hitpause/Hitshit](https://critpoints.net/2017/05/17/hitstophitfreezehitlaghitpausehitshit/) | Removing hitstop weakens hits. |
| [How Naughty Dog defined melee attacks and behaviors in The Last of Us Part II](https://www.gamedeveloper.com/design/how-naughty-dog-defined-melee-attacks-and-behaviors-in-i-the-last-of-us-part-ii-i-) | The Last of Us Part II lengthened NPC melee tells so players could spot and dodge them. |
| [The role of animations in hit effects](https://www.gamedeveloper.com/programming/the-role-of-animations-in-hit-effects) | When an enemy's attack cannot be interrupted, play an additive shake on its body instead of a hit reaction. |

## Locomotion research

Checked 30 findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [locomotion.md](locomotion.md). The sources below were read as text; no video stream was opened.

| Source | Supports |
| --- | --- |
| [Movement: Walk Cycle (timing chart adapted from The Animator's Survival Kit)](https://animation.monmouth.edu/instruct/?p=351) | Halving the page's cycle lengths, which come from Williams, gives frames per step at 24 fps: 4 is a very fast run, 6 a run or very fast walk, 8 a slow run or cartoon walk, 12 a brisk natural walk, 16 a stroll, 20 an elderly or tired walk, 24 a slow step and 32 a very slow walk; In Williams' walk, the contacts fall on frames 1, 13 and 25 with the body in the same place. |
| [Animation Assignment #6 Character Walk Cycle](https://www.brianlemay.com/Pages/animationschool/animation/1stsemesteranimation/walks/06walkcycle.html) | Every drawing in a walk cycle has a mirror half a cycle later (1 and 9, 5 and 13, 3 and 11, 7 and 15). |
| [Kinematic analyses of gait](https://ouhsc.edu/bserdac/dthompso/web/gait/knmatics/gait.htm) | In a normal walk the centre of gravity rises and falls about 5 cm. |
| [Kinematic aspects of trunk motion and gender effect in normal adults (J Neuroeng Rehabil 2010)](https://pmc.ncbi.nlm.nih.gov/articles/PMC2843703/) | In walking the upper trunk moves little in world space: about 6.9 degrees of rotation range, 3.3 degrees of side tilt and 4.0 degrees of forward-back tilt. |
| [Stance Phase Duration: normative values](https://clinicalgaitanalysis.com/data/stance.html) | In walking each foot is on the ground about 60 to 62% of the cycle (59% at 1.5 m/s), so both feet are down twice per cycle for about 10% each. |
| [The biomechanics of distance running (chapter in The Science and Practice of Middle and Long Distance Running)](https://eprints.leedsbeckett.ac.uk/id/eprint/7491/6/TheBiomechanicsOfDistanceRunningAM-HANLEY.pdf) | Distance runners step at 2.75 to 3.25 Hz (165 to 195 steps per minute); A running step has four components: foot ahead of the COM at contact, foot movement during stance, foot behind the COM at toe-off, and flight distance; In gait the pelvis twists to carry each hip forward as that leg swings forward, so part of the step length comes from the pelvis. |
| [The Key Poses of a Run Cycle](https://blog.animschool.edu/2024/04/10/the-key-poses-of-a-run-cycle/) | The run's keys are contact (front leg near straight), down (lowest, most squashed, stance leg bent), push (leaving the ground, sometimes already airborne) and peak (highest, fully airborne, with the knees held from the previous pose). |
| [Animation Assignment: 8 drawing run cycle](https://www.brianlemay.com/Pages/animationschool/animation/1stsemesteranimation/21runs/21runcycle.html) | A basic run is 8 drawings per cycle: two keys and two breakdowns (the full stride and the mid-stride passing), with both feet off the ground in flight. |
| [The Apollo Number: Space Suits, Self-Support, and the Walk-Run Transition (PLoS One 2009)](https://pmc.ncbi.nlm.nih.gov/articles/PMC2719915) | Humans switch from walking to running at a Froude number v^2/(gL) of about 0.5, where L is the leg length. |
| [Expression of emotions through full-body movement (doctoral thesis; includes Roether, Omlor, Christensen and Giese 2009, Journal of Vision)](https://www.compsens.uni-tuebingen.de/compsens//files/publications/thesisroether2011.pdf) | Emotion changes a walk's speed, posture and movement size. |
| [Dynamic stability during running gait termination: differences in strategies between children and adults to control forward momentum](https://pmc.ncbi.nlm.nih.gov/articles/PMC4570872/) | The claim is unchanged. |
| [Kinematics of transition during human accelerated sprinting (Biology Open 2014)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4133722) | In a sprint start, the first steps land behind the CG. |
| [Head over heels: Upper body movement in gameplay](https://www.gamedeveloper.com/art/head-over-heels-upper-body-movement-in-gameplay) | In a sharp turn the head stays nearly still while the body pivots under it around its centre of mass (mid to lower torso). |
| [The Challenge of Having Both Responsiveness and Naturalness in Game Animation](https://www.gamedeveloper.com/design/the-challenge-of-having-both-responsiveness-and-naturalness-in-game-animation) | A responsive 180 degree run turn can snap the character's facing in one frame and cover it with a turn clip. |
| [Animation in Lyra Sample Game](https://dev.epicgames.com/documentation/en-us/unreal-engine/animation-in-lyra-sample-game-in-unreal-engine) | Lyra keeps the feet planted during idle turning with a root yaw offset that fully counters the actor's rotation. |
| [Pose Warping in Unreal Engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/pose-warping-in-unreal-engine) | Stride warping scales the planted-foot positions by StrideScale = LocomotionSpeed / RootMotionSpeed and adjusts the pelvis with a spring, so one cycle fits several speeds. |
| [Animation Sync Groups in Unreal Engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/animation-sync-groups-in-unreal-engine) | Blended locomotion cycles stay in phase through sync groups. |
| [Distance Matching in Unreal Engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/distance-matching-in-unreal-engine) | Distance matching drives a start, stop, pivot or landing by distance instead of time. |
| [The Right Foot in the Wrong Place: Character Locomotion in Half-Life: Alyx (SIGGRAPH 2021 Talks)](https://history.siggraph.org/wp-content/uploads/2022/06/2021-Talks-Heuvel_The-Right-Foot-in-the-Wrong-Place.pdf) | Half-Life: Alyx keeps feet from sliding with a 'footbase': a horizontal shadow of the foot that the lowest part of the foot always touches. |
| [Footskate Cleanup for Motion Capture Editing (SCA 2002)](http://www.cs.wisc.edu/graphics/Papers/Gleicher/Mocap/cleanup.pdf) | Footskate cleanup places each new plant at the foot's position averaged over the next few frames, not its first-contact point. |
| [Code vs Data Driven Displacement](https://theorangeduck.com/page/code-vs-data-driven-displacement) | Real locomotion is slower sideways and backward than forward. |
| [Humanoid class reference (official Roblox creator-docs source)](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Humanoid.yaml) | A default Roblox jump uses JumpHeight 7.2 studs (or JumpPower 50 when UseJumpPower is on) under workspace.Gravity 196.2 studs/s^2; The default Humanoid WalkSpeed is 16 studs/s, and the default animation script scales the movement animations by the current speed relative to 16 studs/s. |
| [Celeste Player.cs (official source release)](https://raw.githubusercontent.com/NoelFB/Celeste/master/Source/Player/Player.cs) | Celeste adds apex hang: gravity is halved while the vertical speed is under 40 px/s and jump is held (takeoff speed 105 px/s, gravity 900 px/s^2). |
| [06. How to animate a jump](https://caveacademy.com/?p=10622) | For weight in a jump, push the landing lower than the takeoff squash. |
| [Respiratory Rate: A Vital Sign](https://www.lung.org/blog/respiratory-rate-vital-signs) | A resting adult breathes 12 to 20 times a minute, which is 3 to 5 s per breath. |
| [4 Quick Tips for a Better Idle Animation Cycle](https://blog.animschool.edu/2018/06/08/4-quick-tips-for-a-better-idle-animation-cycle/) | In an idle cycle, space fidgets and head turns so each happens 'once every few breath cycles'. |

## Workflow, posing and acting research

Checked 29 findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [keyframe-workflow.md](keyframe-workflow.md). The sources below were read as text; no video stream was opened.

| Source | Supports |
| --- | --- |
| [Animation Tips & Tricks Volume II: 'What Kind of Workflow Do You Use or Recommend?' and 'Workflow for Fully Rigged Character'](https://content.animationmentor.com/pdfs/TipsAndTricks_Volume2.pdf) | Block in whole poses; To change a polished section, wall it off with full-body keys on both edges, reduce the inside to all-channel keys at the frames where something important happens, and retime by sliding key groups; Weight is shown as opposing forces; Set the style dial before blocking. |
| [Posing, posing, and POSING!](https://blog.animschool.edu/?p=379) | Find the one golden pose that tells the whole moment. |
| [Animation Tips & Tricks Volume I: Tip #18 'Black out your character'](https://content.animationmentor.com/pdfs/TipsAndTricks_Volume1.pdf) | In a strike, the anticipation and the follow-through must read in silhouette; Thumbnail several rough pose ideas before keying, and expect the first idea to be the most clichéd; In action-heavy shots, hide the legs and block the body first; Track arcs frame by frame from the camera the audience will see, in a fixed order starting at the hips; Fix twinned timing beat by beat: keep the accent part on its frame, let the head hit its extreme a couple of frames early, and delay the other hand a few frames; Break a twinned pose through a chain of fixes: push one foot further out than the other; Put contrast into the timing: any sequence of three or more actions must not be timed evenly like a metronome; Power moves contain reversals: the line of action through the spine flips from one curve to its opposite; Put an emotional or attitude change where the head moves least, for example the top of a jog's bounce; In a multi-character moment, only one character does the primary action; You cannot judge your own shot with fresh eyes. |
| [Principles of Traditional Animation Applied to 3D Computer Animation (SIGGRAPH 87), section 2.7 Slow In and Out](https://www.ics.uci.edu/~fowlkes/class/ics162/exercises/lasseter.pdf) | Converting stepped blocking to spline often turns the motion to mush and loses its snap, because each stepped change used to happen in one frame; In keyframe systems the same spline sets both path and timing, so the faster the action (the fewer the inbetweens), the flatter its arc; Layer a hop from the root outward; Never bring an action to a complete stop before starting the next: the second action overlaps the first; The anticipation needed depends on what the audience expects. |
| [Blocking Plus Workflow: Arcs](https://blog.animschool.edu/2025/08/15/blocking-plus-workflow-arcs/) | When the head rises with the body too quickly in a vertical move, delay its rotation slightly so it drags. |
| [Straights & Curves (Designing Cartoon Characters for Animation Vol. 2, online course)](https://brianlemay.com/Drawingcourse/StraightsandCurves.html) | The line of action is one C curve or one S curve. |
| [Tricks to Animating Characters with a Computer (SIGGRAPH 94 course notes)](https://education.siggraph.org/static/HyperGraph/animation/character_animation/principles/lasseter_s94.htm) | Lead with the eyes, then the head, then the body. |
| [Johnston's Rules of Expressions for Eyes, and Time Travel (reproducing Ollie Johnston's 12 rules)](https://flong.com/archive/blog/2009/johnstons-rules-of-expressions-for-eyes-and-time-travel/index.html) | Change the expression before or after a body move, never during a fast one. |
| [Acting for Animators (notes from Ed Hooks' 1999 class)](https://thinkinganimation.com/acting-for-animators) | Play an action until something happens that makes the character play a different one (Hooks). |
| [Breathing Life Into Your Animation (AnimSchool blog, November 2024)](https://blog.animschool.edu/2024/11/) | Animate a breath as a chain. |
| [Blocking Plus Workflow: Timing](https://blog.animschool.edu/2025/08/08/blocking-plus-workflow-timing/) | Blocking-plus timing: a jump's anticipation often holds for more frames than the jump itself, the peak gets some hang time, and the landing snaps in quickly. |
| [Euler filter](https://en.wikipedia.org/wiki/Euler_filter) | Euler rotation channels can flip between equivalent angle triples while the actual rotation stays continuous. |

## Stylized and Roblox research

Checked 22 findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [stylized-and-roblox.md](stylized-and-roblox.md). The sources below were read as text; no video stream was opened.

| Source | Supports |
| --- | --- |
| [「GUILTY GEAR Xrd -SIGN-」で実現された「アニメにしか見えないリアルタイム3Dグラフィックス」の秘密，後編 (4Gamer)](https://www.4gamer.net/games/216/G021678/20140714079/) | A stepped anime look comes from posing every displayed frame by hand; In Xrd battle moves, how many 60 fps frames each pose stays on screen is set per frame in script and differs from move to move (example: 2F, 3F, 3F, 1F, 1F, 2F, 2F, 3F, 4F). |
| [Spider-Man: Into the Spider-Verse - how they got that mind-blowing look (CG Spectrum)](https://cgspectrum.com/blog/spider-man-into-the-spider-verse-how-they-got-that-mind-blowing-look) | To get twos in 3D without losing flow, animate on ones, bake, then hold every second frame. |
| [GuiltyGear Xrd's Art Style: The X Factor Between 2D and 3D (GDC 2015 talk handout)](https://www.ggxrd.com/Motomura_Junya_GuiltyGearXrd.pdf) | Anime-style 3D gives up 3D accuracy for the picture the camera sees. |
| [The Kanada style in context (Animétudes)](https://animetudes.com/2021/03/06/the-kanada-style-in-context/) | Anime action changes the hold length often and irregularly inside one move. |
| [Timing Example #1 – Anime](https://www.nakedrabbit.com/timing-example-1-anime/) | TV anime gets its snap from contrast between short, sharp motion and long holds. |
| [Smearframes in Video Games (Master's thesis, FH Hagenberg, 2018)](https://theses.fh-hagenberg.at/index.php/system/files/pdf/Lendenfeld18.pdf) | A smear works only on the part that leads the eye. |
| [Thoughts on Hitstop (Sakurai's Famitsu column vol. 490, fan translation)](https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/) | Good hitstop is not a dead freeze. |
| [アクションゲームの鍵を握るアニメーションの極意とは？プラチナゲームズ流の制作手法～「CEDEC2017」レポート (CGWORLD)](https://cgworld.jp/feature/201709-cedec2017-platinum-4.html) | Idle is the neutral base (土台), attacks are tension and damage is release. |
| [実はあんな動きも撮れちゃいます！アニメチックなモーションキャプチャーを実現するための工夫と実演【CEDEC2023】 (GameBusiness.jp)](https://www.gamebusiness.jp/article/2023/09/14/22228.html) | For a jump attack that lands as it cuts, the body must already lean forward in the air, so the landing and the strike happen on the same frame instead of as two steps. |
| [AnimationTrack (Roblox creator-docs source)](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/AnimationTrack.yaml) | AnimationTrack:Play, Stop and AdjustWeight fade over 0.1 s by default; Native track control has traps. |
| [Animation Engine - Runtime Changes and Fixes (Roblox DevForum announcement)](https://devforum.roblox.com/t/1320674) | Two playing tracks at the same priority blend by weight; the later Play call does not win; Dense, evenly spaced, linear keyframes are the Animator's fast path. |
| [Animation events (Roblox creator-docs source)](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/animation/events.md) | Native events come from KeyframeMarkers through GetMarkerReachedSignal, which also passes a string parameter. |
| [PoseEasingStyle enum (Roblox creator-docs source)](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/enums/PoseEasingStyle.yaml) | Native Pose easing has legacy traps. |
| [Animator (Roblox creator-docs source)](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Animator.yaml) | Roblox may evaluate other players' characters less often by distance, screen size and frame budget, reusing the last pose. |
| [[Full Release] Animation Graphs: Create Complex Character Motion Visually (Roblox DevForum)](https://devforum.roblox.com/t/4739840) | Plain AnimationTracks have no runtime joint mask. |
| [Comments on Character Animations (Roblox DevForum)](https://devforum.roblox.com/t/1585523) | Experienced R6 animators fake the knee with the top front edge of the lifted leg. |
| [Feedback on R6 combo animation (Roblox DevForum)](https://devforum.roblox.com/t/707780) | R6 combat critique keeps returning to three faults: limbs that look detached when pushed far forward, punches aimed off-centre, and strikes that are slow when only the pauses should be long. |
| [R6 IK + FK Blender Rig (Roblox DevForum), ZeroKey GLocking section](https://devforum.roblox.com/t/3586405) | To move a weapon from one hand to the other mid-clip, key the prop's own joint to follow the hand. |
| [A Simple Impact Frame Showcase (Roblox DevForum)](https://devforum.roblox.com/t/4355157) | On Roblox, impact frames are built as screen effects: a ViewportFrame, a ColorCorrection flash, or a hand-drawn image sequence. |
