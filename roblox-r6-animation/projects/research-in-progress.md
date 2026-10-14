# Research in progress (unverified)

Raw findings from two stopped research passes (2026-10-11 and 2026-10-12), stopped at the user's request before the source check. Each finding below was read from its source by a researcher, but no independent re-read has checked it yet, except where "Checker verdicts" says so. Do not move any of it into the skill until a checker has re-read its source (see "Plan to finish"). The skill does not load this file.

## Traversal: climb, mantle, vault, slide, wall run, swim

Target file: `references/traversal.md`. Status: researched, not checked.

### traversal-01 (Roblox states and default behaviour)

- Claim: Roblox's engine reference says a Humanoid climbs at 70% of its WalkSpeed and swims at 87.5% of it (11.2 and 14 studs/s at the default WalkSpeed 16). A Humanoid slides down any slope steeper than its MaxSlopeAngle, which ranges from 0 to 89 degrees and defaults to 89, so by default a Humanoid almost never slides down a slope. The Climbing and Swimming events do not always fire with speed 0 when the Humanoid stops.
- Source: [Roblox creator-docs, Humanoid class reference (Humanoid.Climbing, Humanoid.Swimming, Humanoid.MaxSlopeAngle)](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Humanoid.yaml)
- Evidence: "Humanoids climb at 70% of their Humanoid.WalkSpeed." ... "Humanoids swim at 87.5% of their Humanoid.WalkSpeed." ... "If the angle of a slope is greater than a humanoid's MaxSlopeAngle, they will slide down the slope." ... "It defaults to 89°"
- On R6 (draft): Read WalkSpeed and MaxSlopeAngle from the place before building. At the defaults, build the ladder clip for about 11.2 studs/s and the swim clip for about 14 studs/s. A slope-slide clip only plays where the place lowers MaxSlopeAngle below the angle of its slopes, so ask before building one. Do not end a climb or swim clip on a speed-0 event; drive the exit from StateChanged.

### traversal-02 (Roblox states and default behaviour)

- Claim: In the default Animate script tracked from the Roblox client (Roblox-Client-Tracker, the server-authority variant humanoidAnimateSAuth.lua), the R6 climb clip plays at |vertical velocity| / 12, after dividing by the character's scale, with a 0.1 s fade (R15 divides by 5). Because it uses the absolute value, the default plays the climb clip forward when climbing down as well as up.
- Source: [Roblox-Client-Tracker: humanoidAnimateSAuth.lua (default Animate script as shipped in the Roblox client)](https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/avatar/scripts/humanoidAnimateSAuth/humanoidAnimateSAuth.lua)
- Evidence: elseif currentState == Enum.HumanoidStateType.Climbing then speed = math.abs(relVelocity.Y) ... if isR6 then ... local CLIMBING_SCALE = 12.0 queueAnimation(animState, "Climbing", CLIMB_TRANSITION_TIME, speed / CLIMBING_SCALE) ... local CLIMB_TRANSITION_TIME = DEFAULT_TRANSITION_TIME (0.1)
- On R6 (draft): A custom R6 climb clip that replaces the default must be authored so that at 1.0x it covers 12 studs of climb per second: the gripping hand moves down in root space 12 studs/s. At the default climb speed (11.2 studs/s, traversal-01) it then plays at 0.93x. The fade is 6 frames, so the first pose must be close to the last ground pose. For a descent that reads right, the place needs its own handler that picks a down clip. Creator-docs TrussPart.yaml (read this session) says a TrussPart must be 2 x 2 x n studs with n a multiple of 2; spacing hand reaches 2 studs apart lines the hands up with truss segments (our inference).

### traversal-03 (Swimming)

- Claim: The same default Animate script has no R6 swim clip. With the client flag UserCCLNoSwimAnimationsFix on, an R6 swimmer plays the Running (walk) clip at speed / 10, never below 0.2x, with a 0.1 s fade; with the flag off it plays Running at its default rate while moving and Standing while still. R15 plays dedicated swim and swimidle clips at speed / 10 with 0.4 s fades and switches at 1.025 studs/s going up and 0.975 going down.
- Source: [Roblox-Client-Tracker: humanoidAnimateSAuth.lua (default Animate script as shipped in the Roblox client)](https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/avatar/scripts/humanoidAnimateSAuth/humanoidAnimateSAuth.lua)
- Evidence: "-- R6 doesn't have swim animations; map to Running/Standing instead" ... queueAnimation(animState, "Running", DEFAULT_TRANSITION_TIME, math.clamp(speed / SWIMMING_SCALE, 0.2, math.huge)) ... local SWIM_TRANSITION_TIME = 0.4 ... SWIM_START_THRESHOLD = 1.025 ... SWIM_STOP_THRESHOLD = 0.975
- On R6 (draft): By default an R6 swimmer at 14 studs/s plays the land walk at 1.4x. An R6 swim needs its own swim and swimidle clips and a handler in the place's Animate script. Copy the R15 constants: a 24-frame fade between swim and swimidle, a switch at about 1 stud/s with the hysteresis, and the swim stroke authored for 10 studs/s at 1.0x if the handler keeps the /10 scaling.

### traversal-04 (Roblox states and default behaviour)

- Claim: In the same default Animate script, R6 jump-to-fall timing is fixed: the jump clip holds the character for JUMP_ANIM_DURATION 0.3 s, a Freefall that starts during the jump waits out that remaining time, and the fall clip fades in over 0.3 s (R15: 0.31 and 0.2 s). Landed only queues Standing with a 0.1 s fade (R15 0.2 s): the default plays no landing clip.
- Source: [Roblox-Client-Tracker: humanoidAnimateSAuth.lua (default Animate script as shipped in the Roblox client)](https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/avatar/scripts/humanoidAnimateSAuth/humanoidAnimateSAuth.lua)
- Evidence: local FALL_TRANSITION_TIME = if isR6 then 0.3 else 0.2 / local LANDING_TRANSITION_TIME = if isR6 then DEFAULT_TRANSITION_TIME else 0.2 / local JUMP_ANIM_DURATION = if isR6 then 0.3 else 0.31 ... queueAnimation(animState, "FreeFall", FALL_TRANSITION_TIME, nil, animState.currentAnimTimeRemaining) ... Landed then queueAnimation(animState, "Standing", LANDING_TRANSITION_TIME)
- On R6 (draft): At 60 fps the jump clip owns frames 0 to 18 and the fall pose is only fully in by about frame 36. A default flat-ground jump lands after about 33 frames (body-mechanics.md), so the fall pose never fully arrives before landing (our derivation): make the jump clip's last 15 frames the readable airborne pose. The landing weight is absent by default, a 6-frame snap to idle; play your own landing clip on StateChanged Landed.

### traversal-05 (Swimming)

- Claim: A 2025 DevForum bug report states that Roblox buoyancy normally brings an R6 swimmer's head halfway above the water when not jumping, and that continuously updating a Weld's C0 on the character stops it just below the waterline. A Roblox engineer answered that each Weld CFrame update resets the buoyancy contact points (the buoyant force drops to zero) and that a Motor6D offset behaves stably and costs less.
- Source: [Roblox DevForum: Character stops exactly below water surface when Weld.C0 is updated continuously (bug report and staff reply)](https://devforum.roblox.com/t/4036735.json)
- Evidence: "Normally, Roblox buoyancy brings the head halfway above water when swimming (without pressing Jump)." ... reply: "you can use the Motor6D class to achieve the same. It behaves more stably" ... "When the buoyancy contacts are reset, buoyant force goes to zero."
- On R6 (draft): Key an R6 swim or treading pose with the head centre at the waterline: the body hangs under it, so the arm strokes and leg kicks must read from a camera above and behind. Poser writes Motor6D transforms, which keeps buoyancy stable; never animate a held prop or a swim rig through a Weld C0 written every frame.

### traversal-06 (Slides and crouch)

- Claim: Roblox's Character Controller Library Studio Beta (official DevForum post, September 2026, updated October 2026) adds default Sprint and Crouch abilities: Sprint multiplies movement speed by 1.5; Crouch drops the character to 0.55x hip height for R6 (0.67x for R15) and moves at 0.5x speed.
- Source: [Roblox DevForum: [Studio Beta] Expanding the Character Controller Library: New Default Abilities & Custom Abilities API](https://devforum.roblox.com/t/4863739.json)
- Evidence: "Sprint: increases movement speed by 1.5x when toggled." ... "Crouch: drops the character into a low stance (0.55x hip height for R6, 0.67x hip height for R15), and reduces them to 0.5x movement speed."
- On R6 (draft): At WalkSpeed 16 a CCL crouch walk moves at 8 studs/s and a sprint at 24 studs/s. Build the crouch walk for 8 studs/s, not a slow sneak. A 24 studs/s sprint is past the R6 stride limit (SKILL.md: build the run near 15 studs/s and play it faster). Check in Studio what height the CCL measures before setting the crouch drop. If it is the root's height above the floor (3 studs on R6), 0.55x is a 1.35-stud drop: more than leg slides alone give, so pitch the torso forward and angle the legs.

### traversal-07 (Ladders and free climbing)

- Claim: Ladder studies name four limb patterns: two-beat lateral (right hand and foot move nearly together, then the left pair), two-beat diagonal (right foot with left hand), four-beat lateral (RF RH LF LH) and four-beat diagonal (RF LH LF RH). Unprompted climbers' choice depends on ladder angle: for ascending, Hammer and Schmalz found two-beat lateral preferred at 90 degrees, four-beat lateral at 70 and four-beat diagonal at 50. On a vertical ladder, Pliner and Beschorner's 38 subjects used four-beat diagonal 31.3% and two-beat lateral 28.2%. In Jensen and Holland's own lab study, 11 of 79 tasks slid the hands up the side rails with no pattern. Descent reverses the order.
- Source: [Jensen & Holland (2020), Ladder Safety: A Taxonomy of Limb-Movement Patterns for Three Points of Control, IJERPH 17:2897](https://mdpi-res.com/d_attachment/ijerph/ijerph-17-02897/article_deploy/ijerph-17-02897.pdf)
- Evidence: "The two-beat lateral pattern involves nearly simultaneous movement of the right hand and foot alternating with the left hand and foot." ... "At 90°, two-beat lateral was preferred; At 70°, four-beat lateral was preferred; At 50°, four-beat diagonal was preferred."
- On R6 (draft): For a vertical truss or ladder on R6, the simplest readable cycle is two-beat lateral: Right Arm and Right Leg rise together while the left pair holds, then swap, each beat half the cycle. For a slanted ladder or stair-ladder, move one limb at a time in four beats, one limb a quarter cycle after the last, so three limbs always hold. Rails held by sliding hands are a valid cheaper cycle: the legs step and the arms slide up the rails.

### traversal-08 (Ladders and free climbing)

- Claim: Firefighters climbing instrumented aerial ladders (30, 52.5 and 75 degree slopes) at a self-chosen speed moved about 0.38 to 0.44 m/s along the ladder. Narrowing the rung spacing from 356 to 305 mm raised speed 4.6% overall (women 0.38 to 0.41 m/s; men 0.43 to 0.44, not significant). Descending was 8.8% slower than ascending. At 75 degrees the speeds were 0.353 m/s (356 mm) and 0.376 m/s (305 mm), against 0.323 m/s that Dewar reported for 255 mm rungs. The US fire apparatus standard spaces rungs 298 to 356 mm.
- Source: [Simeonov et al. (2020), Effects of aerial ladder rung spacing on firefighter climbing biomechanics, Applied Ergonomics 82:102911](https://stacks.cdc.gov/view/cdc/214290/cdc_214290_DS1.pdf)
- Evidence: "reducing the rung spacing from 356 mm to 305 mm resulted in a 4.6% increase (p = 0.0017) in climbing speed" ... "climbing down (descending) resulted in a decrease (8.8%...) in climbing speed" ... "self-selected climbing speed (0.323 m/s) for a 75° ladder ... 356 mm rung spacing (0.353 m/s) and 305 mm rung spacing (0.376 m/s)"
- On R6 (draft): A real ladder climb is about 1.4 studs/s at 28 cm per stud (1.1 scaled by body height), with rungs every 1.1 to 1.3 studs (0.9 to 1.0 scaled); our conversion. The Roblox default climb, 11.2 studs/s (traversal-01), is about 8 to 10 times that: a scramble, not a climb. A deliberate R6 ladder clip (cutscene, NPC, slowed custom climb) should place each hand and foot on rungs about 1 stud apart, go up at about 1.1 to 1.4 studs/s and come down about 9% slower.

### traversal-09 (Ladders and free climbing)

- Claim: In a study of 9 elite climbers and 9 controls, the experts kept their centre of mass about 5 cm further from the wall than controls, in both static and moving phases. They also showed side-to-side COM oscillations about 1.3 times larger, tied to alternating shifts of body weight between the limbs during double support, and tended toward a more diagonal climbing strategy. Controls restrained the lateral motion.
- Source: [Zampagni et al. (2011), Idiosyncratic control of the center of mass in expert climbers, Scand J Med Sci Sports (abstract via Europe PMC)](https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=EXT_ID:21917019%20AND%20SRC:MED&resultType=core&format=json)
- Evidence: "they tended to maintain larger COM distances from the wall relative to controls ... (by ∼5 cm in both cases)." ... "all EC demonstrated systematic COM oscillations (∼1.3 times larger) associated with a significant alternating dynamic redistribution of the body weight between the limbs during the double support phase."
- On R6 (draft): Do not glue the R6 torso to the wall in a free-climb cycle. Hold the torso about 0.15 to 0.2 studs further off the wall than a hugging pose. Before each reach, sway torso px toward the side whose limbs take the weight (larger than a cautious novice), and pair limbs diagonally: Right Arm reaches while Left Leg pushes.

### traversal-10 (Ladders and free climbing)

- Claim: Naughty Dog (Uncharted 4) says that climbing a wall themselves showed how much of a climber's weight is on the feet. The team made Drake's feet look for an edge instead of dangling and swinging. Full-body IK drives all four limbs plus the root. When the stick points where nothing is reachable, the body starts to move in that direction. The motion came from a parkour athlete climbing an adjustable mocap wall with movable handholds.
- Source: [PlayStation Blog (October 2022): Naughty Dog breaks down Uncharted 4's climbing evolution](https://blog.playstation.com/?p=370798)
- Evidence: Schatz: noticed "how much your weight is on your feet". Broner: wanted the feet to "actually look for an edge instead of having them just dangling and swinging." Yates: "full-body [inverse kinematics] working with all four limbs" plus the root. Pushing the stick with nothing in reach, "you see the body start to move in a certain direction."
- On R6 (draft): In an R6 wall climb, keep the leg soles on holds and raise the torso with the legs, not only by arm angles: the torso rises over the frames while the legs straighten under it. Give an input with no reachable hold its own short clip: the torso leans and the reaching arm extends toward the input direction, then returns. Never play nothing.

### traversal-11 (Ladders and free climbing)

- Claim: For Assassin's Creed III's climb (Jonathan Cooper, animation director), a visit to an indoor climbing wall showed that the original climb system did not set up the arms and legs to maximise reach, so the new climb inverted them. The team added a set of 45-degree animations for faster movement in all directions. They added follow-through by physics so a climb move could finish without the Assassin stopping in place, keeping momentum.
- Source: [Game Anim (Jonathan Cooper): Animating The 3rd Assassin, page 5 (Parkour, Climb)](https://www.gameanim.com/2014/02/11/animating-3rd-assassin/5/)
- Evidence: "the arms and legs were not set up correctly in the original climb system so as to maximise reach. As such, the first port of call for our new climb was to invert the arms and legs." ... "added a set of 45 degree animations" ... "follow-through to play out without requiring the Assassin to stop in place"
- On R6 (draft): Give an R6 wall climb diagonal moves (up-left, up-right) as their own clips, not only up and sideways. Pair a reaching arm with the leg that extends the reach furthest. Do not end each climb move on a settle: let the torso and head carry their follow-through (springs, lag) into the next move's start, so chained moves keep momentum.

### traversal-12 (Ledge hang and climb-up)

- Claim: Swansong's animation sheet (EIRTeam, a Godot game's public spec) asks for a looping braced ledge idle with the feet on the wall in a frog- or cat-like crouch, and a dangling ledge idle with no foot support whose head sits lower. An edge slide-down crouches and pivots on the right hand to drop off a low ledge. A standing-to-ledge-grab pivots 180 degrees on the hand. The vault uses a hand on the object as support while momentum carries the body over. Every traversal one-shot must use warped motion. Approximate lengths are 40 to 50 frames per hang idle, about 70 for the vault, 40 for the roll landing and 70 for the hard landing; the sheet does not state the frame rate.
- Source: [EIRTeam docs: Swansong animation sheets](https://eirteam-docs.readthedocs.io/en/latest/documentation/swansong/swansong_animation_sheets.html)
- Evidence: "hanging off a ledge with their feet on the wall. Acquiring a posture similar to a frog or a cat. 40-50 frames" ... "feet not supported by anything, the head height should be lower than the normal ledge grabbed idle." ... "Animations marked with (W) must use warp motion."
- On R6 (draft): R6 braced hang: both legs lifted forward at the hips until the soles touch the wall below the hands, the torso close to the wall and pitched slightly back, and the arms up to the lip. Dangling hang: legs straight down, arms fully extended, so the torso and head sit lower by the leg lift. Time a hard landing well over a roll landing (about 1.75x in the sheet).

### traversal-13 (Ledge hang and climb-up)

- Claim: Prince of Persia's 1989 Apple II source (Jordan Mechner) builds a medium jump-to-hang from 11 jump frames plus 3 catch frames. The hang that follows is 43 ticks that run back and forth through its hang poses: out to pose 99, back to 87, then out only to 96 before returning. The swing does not stop at the catch; the second swing is smaller (our reading of the frame list). Mechner planned the game at 15 frames per second (Animation Obsessive, read this session).
- Source: [Prince of Persia (Apple II) source code, SEQTABLE.S (sequence table)](https://raw.githubusercontent.com/jmechner/Prince-of-Persia-Apple-II/master/01%20POP%20Source/Source/SEQTABLE.S)
- Evidence: jumphangMed: db 67,68,69,70,71,72,73,74,75,76,77 / db act,2 / db 78,79,80 / goto hang. hang: db 91 / hang1 db 90,89,88,87,87,87,88,89,90,91,92,93,94,95 / db 96,97,98,99,97,96,95,94,93,92 / db 91,90,89,88,87,88,89,90,91,92,93,94,95,96 / db 95,94,93,92
- On R6 (draft): After an R6 ledge catch, swing the dangling body about the hands instead of freezing: pitch the torso (and the legs with it) forward and back with a smaller second swing, then a moving hold. The catch itself is quick: 3 of 14 frames, about 12 frames at 60 fps if played at 15 fps. For the swing period use the pendulum rule in body-mechanics.md with the hands-to-COM length (about 3.1 studs on R6: 2-stud arm plus 0.5 to the shoulder joint plus 0.64 to the COM; our derivation). That gives about 0.8 s per swing at gravity 196.2 and 1.9 s at 35.

### traversal-14 (Ledge hang and climb-up)

- Claim: In Prince of Persia's source, the climb-up from a hang is 14 frames. After the sixth, the character's coordinates jump up 63 pixels (BlockHeight, one floor, per TABLES.S) and forward 5, and the last 8 frames are drawn from the new upper position. The sprite pose stays continuous while the logical position moves to the ledge top in one step, about 43% into the move. At the planned 15 fps the climb-up lasts about 0.93 s.
- Source: [Prince of Persia (Apple II) source code, SEQTABLE.S (climbup sequence); BlockHeight = 63 in TABLES.S](https://raw.githubusercontent.com/jmechner/Prince-of-Persia-Apple-II/master/01%20POP%20Source/Source/SEQTABLE.S)
- Evidence: climbup / db act,1 / db 135 / db 136 / db 137 / db 138 / db 139 / db 140 / db chx,5 / db chy,-63 / db up / db 141 / db 142 / db 143 / db 144 / db 145 / db 146 / db 147 / db 148
- On R6 (draft): For an R6 climb-up, move the gameplay root (HumanoidRootPart) to the ledge top in one step at the frame where the torso passes the lip (about 40 to 45% in). Author the clip in two parts whose root offsets cancel that jump, so the visible body never pops. At 15 fps scaled to 60 fps that is about 56 frames: 24 hauling up from the hang, 32 getting the legs over and standing.

### traversal-15 (Falls and landings)

- Claim: Prince of Persia tiers landings by fall height in its source comments. softland (1 story) jars, takes two frames into a crouch and ends looping the crouch pose. medland (1.5 to 2 stories) jars, holds the crouch pose for 29 ticks, then rises through 12 ticks to stand. hardland (more than 2 stories) is a single collapse pose and death.
- Source: [Prince of Persia (Apple II) source code, SEQTABLE.S (softland, medland, hardland)](https://raw.githubusercontent.com/jmechner/Prince-of-Persia-Apple-II/master/01%20POP%20Source/Source/SEQTABLE.S)
- Evidence: softland ;1 story ... :crouch db 109 / db goto / dw :crouch ... medland ;1 1/2 - 2 stories ... db 108 / db 109,109,... (29 times) ... db 110,110,110 / db 111 ... db 119 / db goto / dw stand ... hardland ;> 2 stories ... db 185 / db die
- On R6 (draft): Choose the landing clip by drop height measured from the fall start (principles.md uses about 4 and 15 studs as the bounds). Make the medium tier visibly costly: at 15 fps the 29-tick crouch is about 1.9 s (about 116 frames at 60 fps), then about 48 frames to stand. Key that crouch as a moving hold that keeps sinking and breathing, never a frozen pose. Give the light tier no hold: crouch and hand control back.

### traversal-16 (Mantles, vaults and fitting to geometry)

- Claim: ALS-Community (the C++ port of the Advanced Locomotion System V4 for Unreal) picks the high mantle when the ledge is more than 125 cm above the capsule base and the low mantle otherwise; a mantle started in the air is a FallingCatch. The clip's starting position and play rate are mapped linearly, and clamped, from the ledge height between the asset's LowHeight and HighHeight. The actor is moved along a correction curve that blends its horizontal and vertical offsets separately toward the animated start, then to the ledge target. An initial blend-in prevents pops when the object is lower than the animated mantle.
- Source: [ALS-Community, ALSMantleComponent.cpp (Advanced Locomotion System V4 mantle)](https://raw.githubusercontent.com/dyanikoglu/ALS-Community/main/Source/ALSV4_CPP/Private/Components/ALSMantleComponent.cpp)
- Evidence: MantleType = MantleHeight > 125.0f ? EALSMantleType::HighMantle : EALSMantleType::LowMantle; ... StartingPosition = GetMappedRangeValueClamped({LowHeight, HighHeight}, {LowStartPosition, HighStartPosition}, MantleHeight) ... "This prevents pops when mantling an object lower than the animated mantle."
- On R6 (draft): Author two R6 mantles, low and high, split near 125 cm: about 4.5 studs at 28 cm per stud, or 3.6 scaled by body height. For a ledge lower than the clip's authored height, start the clip later (skip part of the reach and hang) and adjust its rate, instead of squashing the poses. Move the HumanoidRootPart with separate horizontal and vertical blend curves, so the body can rise to the lip before it travels forward over it.

### traversal-17 (Mantles, vaults and fitting to geometry)

- Claim: Epic's Motion Warping documentation adjusts a character's root motion to reach a target inside named warp windows set as notify states in the montage. The worked punch example's window begins near the start and ends at the moment the character strikes. For a mantle, the starting warp region should cover the moment the hand is placed on the obstacle. Skew Warp makes the root motion match the target's location and rotation by the end of the window. Warp Rotation Time Multiplier finishes the rotation early: a 2-second window with 0.5 reaches the final rotation in 1 second.
- Source: [Epic Games: Motion Warping in Unreal Engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/motion-warping-in-unreal-engine)
- Evidence: "dynamically adjust a character's root motion to align to targets" ... the window "begins near the start of the animation, and ends at the moment the character strikes" ... "likely need to ensure your starting warp region covers the area when the character places their hand on the obstacle"
- On R6 (draft): In a vault or mantle on R6, correct the HumanoidRootPart only from the clip start to the hand-plant key and have the correction complete on that key. Finish the yaw correction in the first half of the window. After the plant, apply no root correction while the hand is on the obstacle, or the hand slides on it.

### traversal-18 (Mantles, vaults and fitting to geometry)

- Claim: Unity's target matching manual puts a jumping character's left foot onto a platform with Animator.MatchTarget over normalized clip time 0.141 to 0.78. 0.141 is where the character begins to leave the ground and 0.78 is where it is about to land. Matching works only on the base layer, and only one match target can be queued at a time.
- Source: [Unity Manual: Target Matching](https://docs.unity3d.com/Manual/TargetMatching.html)
- Evidence: The example passes AvatarTarget.LeftFoot with start 0.141f, where "the character is beginning to get off the ground", and end 0.78f, where "the character is about to land on its feet". (Scripting reference: "Target matching only works on the base layer (index 0).")
- On R6 (draft): Fit an R6 jump-to-platform or gap jump by correcting the root only in the airborne span, from the takeoff frame to the contact frame. In a 60-frame clip that is about frames 8 to 47. The takeoff push and the landing absorb then keep their authored root motion and planted feet.

### traversal-19 (Mantles, vaults and fitting to geometry)

- Claim: Gears of War 4 (David Bollo, SIGGRAPH 2017) fits vaults to obstacles of varying height, width and slope with warp points. Animators place markers at physical landmarks of the environment in their animation scenes, the game places matching warp points at runtime, and playback bends the character's trajectory so the authored points meet the runtime ones. Per warp point, animators time the translation, rotation and facing warps independently. It runs over twice as fast as a blend-space approach. On return to locomotion, the cycle's foot phase is matched from the left foot's position relative to the right, projected on the velocity.
- Source: [Bollo (2017), High Performance Animation in Gears of War 4, SIGGRAPH Talks](https://history.siggraph.org/wp-content/uploads/2022/09/2017-Talks-Bollo_High-Performance-Animation-in-Gears-of-War-4.pdf)
- Evidence: "the animators augment their animation scenes with markers ("warp points") that correspond to physical landmarks in the environment. At runtime, the game ... places appropriate runtime warp points" ... "animators have independent control over the timing of when to warp the character's translation, rotation and facing towards its target."
- On R6 (draft): Mark each R6 vault or mantle with named KeyframeMarkers at its landmark contacts (hand on the near edge, foot or hand at the far edge, feet on the landing floor). At runtime, correct the root between markers so each lands on the measured geometry. Time the yaw correction separately from the travel. On exit into the run, start the run at the phase whose leading foot matches the clip's last frame.

### traversal-20 (Mantles, vaults and fitting to geometry)

- Claim: For Uncharted 4's buddy boosts (one character boosting another up a ledge), Naughty Dog first aimed for a general system handling different directions, speeds and ledge heights. They ended with over 20 unique scenes, partly because they wanted all the hands and fingers to touch exactly what they grab, and found 20 unique scenes easier to maintain. The final camera move when climbing out plays relative to the player, because the end position is unknown.
- Source: [Game Anim: Interactive Cinematics In Uncharted 4](https://www.gameanim.com/2018/03/09/interactive-cinematics-in-uncharted-4/)
- Evidence: "Entering from different directions, different speeds, handling varying ledge heights" ... "we ended up with over 20 unique scenes for buddy boosts" ... "we want all the hands and fingers to perfectly touch everything they grab" ... "it's actually easier to maintain on our end if we just have 20 unique scenes"
- On R6 (draft): For scripted or hero traversal on one known piece of geometry (a story ledge, a boost, a door climb), author a unique R6 clip on that geometry with the hands keyed onto its edges, and keep the root correction for repeated generic geometry. Blend the exit from the player's actual position.

### traversal-21 (Mantles, vaults and fitting to geometry)

- Claim: A motion-capture vendor's climbing guide (MoCap Online) says one mantle clip covers about a 0.5 m range of ledge height cleanly, so two or three mantles (short, medium, tall) cover the rest. A mantle authored for a 1.2 m ledge looks broken on a 0.9 or 1.5 m ledge without warping. Speed scaling works within a 2x range. A minimal climbing system needs about 15 to 20 clips and a full parkour system 50 to 100. Shimmy hand placement should update by IK every step.
- Source: [MoCap Online: Climbing Animation for Games: Ledge Grabs, Walls, and Traversal Systems](https://mocaponline.com/blogs/mocap-news/climbing-animation-games-guide)
- Evidence: "Typically a single mantle animation can cover a 0.5m range cleanly." ... "Without warping, a mantle authored for a 1.2m ledge will look broken on a 0.9m or 1.5m ledge." ... "This works well within a 2x speed range" ... "A minimal system needs about 15–20 clips."
- On R6 (draft): Plan one R6 mantle per band of about 1.8 studs of ledge height (0.5 m at 28 cm per stud; 1.4 scaled by body height) and keep playback rates within 0.5x to 2x. R6 has no hand IK, so a shimmy or mantle must hit the ledge by root correction plus keyed arm angles. Check with the hand forward kinematics that the arm bottoms touch the lip on every contact frame.

### traversal-22 (Parkour game timing)

- Claim: In Mirror's Edge (per Daniel Fernandes' mechanics review, critpoints.net), hitting a ledge at about shin level triggers the speed vault, the shortest vault, which instantly brings Faith up to top running speed. Pressing crouch before landing from a higher height turns the landing into a roll that keeps a little speed instead of losing it all to a heavy landing. Heavy landings stop Faith completely, and an air kick while falling straight down can turn a heavy fall-damage animation into a light one. Faith normally takes 8 seconds to reach top speed.
- Source: [critpoints.net: Mirror's Edge Review (2020)](https://critpoints.net/2020/10/31/mirrors-edge-review/)
- Evidence: "Normally Faith takes 8 seconds to get to top speed." ... "If you press the crouch button before landing from a higher height, you'll roll when you hit the ground." ... the speed vault is "the shortest of all of them" and "instantly brings you up to top running speed."
- On R6 (draft): Make the low-obstacle R6 vault end in the run at full run speed, with no slowdown pose. Give drops three exits: light (absorb into the run), heavy (a full stop with a long recovery) and roll (chosen by an input pressed shortly before contact). The roll should end in a run, not a stand.

### traversal-23 (Parkour game timing)

- Claim: Techland's Dying Light designers (Game Developer deep dive) found that each parkour animation locked the player in until it had played out in full. They shortened the animations and released the camera so it no longer centred and locked during them, which the lead designer called a really tangible difference. Their context system picks climb, jump-over or slide-under actions from the surrounding geometry and the player's speed and position, after an earlier stage of more than 50,000 hand-placed hooks.
- Source: [Game Developer: Game Design Deep Dive: Dying Light's Natural Movement system](https://www.gamedeveloper.com/design/game-design-deep-dive-i-dying-light-i-s-natural-movement-system)
- Evidence: "Each animation basically locked the player in until it had played out in full." ... "Just release the camera so it no longer centers and locks during the animations" ... "very soon we had more than 50,000 of these interactive hooks on a map"
- On R6 (draft): Keep R6 traversal one-shots short and give each one a cancel window right after its last contact (hand off the obstacle, feet planted) into run, jump or attack. Leave the player's camera free during the clip; the clip carries the body, not the view.

### traversal-24 (Wall run and wall jump)

- Claim: Expert parkour athletes running at a wall to climb it (Journal of Experimental Biology, force plates in ground and wall) used a run-up of 4.70 ± 0.40 m/s; the model's optimum was 4.49 m/s. The athletes' ground-foot contact was at -1.17 m horizontally (model -0.99) and the wall-foot contact at 1.01 m (model 0.88). The athletes showed a brief non-contact ballistic phase between ground and wall, about 0.14 s in the paper's reference case, which the model's optimisation cut by 10% to 0.126 s.
- Source: [Croft, Schroeder & Bertram (2019), Determinants of optimal leg use strategy: horizontal to vertical transition in the parkour wall climb, J Exp Biol 222](https://journals.biologists.com/jeb/article/222/1/jeb190983/33884/Determinants-of-optimal-leg-use-strategy)
- Evidence: Run-up speed: athletes 4.70 ± 0.40 m/s; optimal model 4.49 m/s. Ground foot -1.17 m (model -0.99); wall foot 1.01 m (model 0.88). Athletes showed a "brief non-contact, ballistic phase"; "the time of non-contact is decreased by 10% (from 0.140 to 0.126 s)".
- On R6 (draft): For an R6 wall run-up (a vertical wall scramble to a ledge), approach at about 13 to 17 studs/s (4.7 m/s scaled by body height or at 28 cm per stud), near the default WalkSpeed 16. Plant the last ground foot about 3.3 to 4.2 studs before the wall, fly about 8 frames, and put the first wall foot about 2.9 to 3.6 studs up. Do not let the takeoff foot and the wall foot touch at once.

### traversal-25 (Wall run and wall jump)

- Claim: Titanfall 2's multiplayer pilot settings (pilot_mp.set from a dump of the game's scripts) limit a wall run to 1.75 s. They cap wall-run speed at 420 units/s horizontal and 225 vertical, against a stand speed of 173.5 and a sprint of 260 (a wall run is about 1.6x the sprint). Crouch speed is 80, about 46% of the stand speed. A wall jump launches at 205 outward and 230 up, plus 80 toward the input direction. Gravity is scaled 0.8. The base file's stand hull is 72 units tall and the crouch hull 47.
- Source: [Titanfall 2 game scripts (community dump): scripts/players/mp/pilot_mp.set](https://raw.githubusercontent.com/Syampuuh/Titanfall2/master/scripts/players/mp/pilot_mp.set)
- Evidence: gravityscale 0.80 ... wallrun_timeLimit 1.75 ... wallrunJumpOutwardSpeed 205 / wallrunJumpUpSpeed 230 / wallrunJumpInputDirSpeed 80 ... wallrunMaxSpeedVertical 225 / wallrunMaxSpeedHorizontal 420 ... "crouch" speed 80 ... "stand" speed 173.5 / sprintspeed 260
- On R6 (draft): Scaled by body height (72 units = 5 studs; our conversion): sprint 18 studs/s, wall run up to 29, crouch 5.6. A wall-run loop has to read for about 105 frames, then hand off to a fall or a jump. A wall jump leaves about 48 degrees above horizontal (230 up vs 205 out): key the push-off pose with the body already leaning out from the wall along that line, the wall-side leg extended and the arms thrown up and away.

### traversal-26 (Wall run and wall jump)

- Claim: In a 2020 DevForum wall-run feedback thread, the system moves the character along the cross product of the wall's face normal and the up vector with a BodyVelocity, allows only vertical flat faces (checked by normals) and slides faster on low-friction materials such as ice. Two reviewers criticised the animation: the character never starts going down during the wall run, and the running clip looks like shuffling across. A third said the slide-down animation looked good.
- Source: [Roblox DevForum: Feedback on wallruns! (2020)](https://devforum.roblox.com/t/738376.json)
- Evidence: "the character never start going down while wall run" ... "the running one looks a little weird though, it honestly looks like your shuffling across." ... "to get the velocity i get the cross product of the face normal and Vector3.new(0,1,0)"
- On R6 (draft): An R6 wall run must arc: rise at entry, then lose height across the run (pair the clip with a vertical root curve or the controller's gravity). Its leg cycle needs full run-sized leg swings (about +-50 to 80 degrees at the hip) with the soles meeting the wall, not small steps. Mirror the clip by the sign of cross(normal, up) relative to the facing, for left-wall and right-wall versions.

### traversal-27 (Wall run and wall jump)

- Claim: Celeste's player code (NoelFB/Celeste, Player.cs) gives a 0.1 s jump grace (coyote) time after leaving the ground and allows a wall jump from up to 3 pixels away. The wall jump launches at 130 px/s away and 105 px/s up. If the player was holding a direction, it forces the horizontal direction away from the wall for 0.16 s. It sets the sprite scale to 0.6 wide by 1.4 tall on the wall-jump frame, and the scale eases back toward 1 at 1.75 per second.
- Source: [Celeste source (NoelFB/Celeste), Source/Player/Player.cs](https://raw.githubusercontent.com/NoelFB/Celeste/master/Source/Player/Player.cs)
- Evidence: JumpGraceTime = 0.1f; WallJumpCheckDist = 3; WallJumpForceTime = .16f; WallJumpHSpeed = MaxRun + JumpHBoost (90 + 40); JumpSpeed = -105f ... WallJump: forceMoveXTimer = WallJumpForceTime; ... Sprite.Scale = new Vector2(.6f, 1.4f); ... Sprite.Scale.X = Calc.Approach(Sprite.Scale.X, 1f, 1.75f * Engine.DeltaTime);
- On R6 (draft): R6 parts cannot scale, so the stretch is a long pose on the wall-jump takeoff frame: legs extended along the push, arms up, torso pitched along the launch line. Return to the air pose over about 14 frames (the 0.4 stretch at 1.75/s takes 0.23 s). Keep the pose facing away from the wall for about 10 frames before input may turn it, and accept the wall-jump input for 6 frames after the character leaves the wall or ledge.

### traversal-28 (Ladders and free climbing)

- Claim: Celeste's player code climbs a wall up at 45 px/s, down at 80 px/s and slips at 30 px/s, from 110 stamina. Climbing up drains 100/2.2 (about 45.5) per second and holding still 10 per second, so a full bar lasts about 2.4 s of climbing up or 11 s of hanging still. Below 20 stamina the player is tired and the sprite flashes red. Reaching the top of a wall triggers an automatic climb hop of 120 px/s up and 100 px/s forward, with input forced for 0.2 s.
- Source: [Celeste source (NoelFB/Celeste), Source/Player/Player.cs](https://raw.githubusercontent.com/NoelFB/Celeste/master/Source/Player/Player.cs)
- Evidence: ClimbMaxStamina = 110; ClimbUpCost = 100 / 2.2f; ClimbStillCost = 100 / 10f; ClimbTiredThreshold = 20f; ClimbUpSpeed = -45f; ClimbDownSpeed = 80f; ClimbSlipSpeed = 30f; ClimbHopY = -120f; ClimbHopX = 100f; ClimbHopForceTime = .2f ... Stamina -= ClimbUpCost * Engine.DeltaTime ... if (IsTired && flash) Sprite.Color = Color.Red;
- On R6 (draft): For a stamina-based R6 wall climb, build the down cycle to play about 1.8x faster than the up cycle and add a tired variant (slower reaches, shaking arms, a lower hang) below about 18% stamina. In a fast game, top out with a quick hop over the lip (about 12 frames of forced travel) instead of a slow mantle.

### traversal-29 (Slides and crouch)

- Claim: Five college baseball players' planned feet-first slides into a base (3D video at 60 Hz, last 7.62 m) split into sprint 0.38 s, getting into the sliding position 0.11 s, airborne 0.16 s and sliding 0.57 s. Unplanned slides, cued by a base coach, took 0.54, 0.24, 0.10 and 0.22 s. Over the 7.62 m, planned slides took 1.23 s against 1.07 s for running through. Peak centre-of-mass speed was about 6.4 to 6.8 m/s in all conditions; the average was 5.11 m/s for planned slides and 6.14 for running.
- Source: [Hanson & Hsieh (2015), Baseball feet-first sliding technique, ISBS Conference Proceedings](https://ojs.ub.uni-konstanz.de/cpa/article/view/6561/5924)
- Evidence: Table 1: Planned: peak 6.40 m/s, average 5.11, total 1.23 s, sprint .38, attainment .11, air time .16, sliding .57 s. Unplanned: 6.45, 5.61, 1.09, .54, .24, .10, .22. Run: 6.83, 6.14, 1.07.
- On R6 (draft): An R6 run-to-slide at 60 fps: about 7 frames dropping into the slide shape (torso pitching back, lead leg forward), about 10 frames airborne while the body falls to the floor, then about 34 frames sliding on a decelerating root. The slide loses speed (5.1 vs 6.1 m/s average), so the root curve slows, never holds. An input-cued slide gets a longer setup (about 14 frames) and a shorter slide.

### traversal-30 (Falls and landings)

- Claim: Ten men dropping from 0.75 m onto a force plate landed with peak vertical forces of 3.2 body weights (parkour precision landing, forefoot only), 2.9 (parkour roll, a forefoot landing followed at once by a shoulder roll) and 5.2 (traditional landing, forefoot lowering to the heel). Loading rates were 83, 64 and 154 BW/s. Peak force came about 80 ms after contact for precision and roll landings against about 40 ms for the traditional landing.
- Source: [Puddle & Maulder (2013), Ground reaction forces and loading rates associated with parkour and traditional drop landing techniques, J Sports Sci Med 12:122](https://jssm.org/jssm-12-122.xml-Fulltext)
- Evidence: Precision "involves a forefoot contact with no rear-foot contact"; roll "involves an initial forefoot landing immediately followed by a shoulder roll"; traditional "involves landing on the forefoot and lowering to the rear-foot". Peak force: precision 3.2 BW, roll 2.9 BW, traditional 5.2 BW; time to peak about 80 ms vs 40 ms.
- On R6 (draft): On R6 the hardest slowing of a stiff, heel-down landing peaks 2 to 3 frames after contact. A skilled parkour landing spreads it over about 5 frames: the torso keeps dropping through frame 5 with legs angled and the arms forward as counterweight. Use the 2-to-3-frame peak only for a character landing badly or heavily.

### traversal-31 (Falls and landings)

- Claim: Twenty parkour practitioners landing from 0.9, 1.8 and 2.7 m took 0.169 s and 0.224 s in a stiff landing (feet only, aiming to run on at once), against about 0.38 s from 0.9 m for squat, forward and roll landings. Roll landings took 0.364 s from 1.8 m and 0.320 s from 2.7 m. The roll moves support from the feet to the hands to the back. It arrived with the most forward speed (1.8 to 2.6 m/s against about 1.4 for squat landings) and shed the least vertical speed in the first 100 ms. At 0.9 m, hip flexion at contact was 67 degrees for the roll against 42 for the stiff landing; peak knee flexion was 120 against 77. Stiff landings were not collected from 2.7 m.
- Source: [Dai et al. (2020), Kinematic Analyses of Parkour Landings from as High as 2.7 Meters, J Hum Kinet](https://pmc.ncbi.nlm.nih.gov/articles/PMC7126243/)
- Evidence: Landing time (ms): 0.9 m squat 377, forward 381, roll 380, stiff 169; 1.8 m roll 364, stiff 224; 2.7 m roll 320. Roll: "a rolling motion from the feet to the hands and to the back." Stiff: "a goal to moving from a landing to a forward run as fast as possible."
- On R6 (draft): At 60 fps, an R6 stiff landing straight into a run absorbs in about 10 to 13 frames. A squat or roll landing takes about 19 to 23 frames from foot contact until the body stops sinking, with the roll then continuing over the shoulder. Key the roll's contact frame already folded: torso pitched about 65 degrees forward against the legs (about 40 for a stiff landing). Keep the root's forward speed through the roll, then feet, hands, back in that order.

### traversal-32 (Swimming)

- Claim: Fourteen national-level male swimmers at 75 to 100% of their 25 m top speed divided each front-crawl arm cycle into entry and catch 34.7%, pull 22.4%, push 14.2% and recovery (the over-water return) 28.4%. Only pull and push are propulsive. Arm coordination is called catch-up when there is a gap between the two arms' propulsive phases, opposition when one starts as the other ends, and superposition when they overlap.
- Source: [Cortesi et al. (2019), Inertial Sensors in Swimming: Detection of Stroke Phases through 3D Wrist Trajectory, J Sports Sci Med 18:438](http://jssm.org/volume18/iss3/cap/jssm-18-438.pdf)
- Evidence: "The mean values of entry, pull, push and recovery phases duration ... were 34.7 (± 6.8)%, 22.4 (± 5.8)%, 14.2 (± 4.4)%, 28.4 (± 4.5)%." ... "When the propulsive phase of one arm started when that of the other arm ended, the coordination was called 'opposition' (IdC = 0%)."
- On R6 (draft): For an R6 front-crawl loop of 72 frames (50 cycles a minute), give each arm about 25 frames of entry and glide forward, 16 of pull, 10 of push and 20 of recovery over the top. R6 has no elbow, so the recovery is a straight-arm windmill at the shoulder. Run the other arm half a cycle (36 frames) behind for opposition timing. The pull and push are the fast part; the recovery stays smooth.

### traversal-33 (Swimming)

- Claim: Eighteen elite swimmers swimming submaximal front crawl (about 1.3 m/s) rolled their hips to peaks of about 45 to 54 degrees per side, at a mean roll frequency of 0.54 Hz. With one-sided breathing the preferred breathing side rolled 54.2 against 44.6 degrees. Cited studies report shoulder (upper-body) roll of 66 degrees when breathing and 57 when not, and roll 8 to 9 degrees larger on breathing strokes.
- Source: [Barden & Barber (2022), The Effect of Breathing Laterality on Hip Roll Kinematics in Submaximal Front Crawl Swimming, Sensors 22:2324](https://pmc.ncbi.nlm.nih.gov/articles/PMC8950838/)
- Evidence: Table 2 peak hip roll: unilateral preferred 54.2 (8.8), non-preferred 44.6 (8.0); bilateral 51.6 / 46.9; snorkel 47.2 / 44.9 degrees. Mean hip roll fundamental frequency 0.54 Hz. Payton et al.: upper body roll 66 degrees breathing vs 57 non-breathing.
- On R6 (draft): In an R6 crawl, roll the whole torso about the swim direction about 45 to 55 degrees to each side, one full left-right roll per arm cycle (about 111 frames at 0.54 Hz for an easy pace; faster strokes shorten it). The R6 torso carries both hips and shoulders, so use the larger shoulder value (55 to 65) only on breathing strokes, with the head turning up to the side on those strokes and staying down otherwise.

### traversal-34 (Swimming)

- Claim: Measured with the right ankle's farthest extension marking each cycle, the natural eggbeater (treading-water) kick frequency was 74.6 ± 3.56 cycles per minute for water polo players and 82.8 ± 4.70 for artistic swimmers. Participants kept the upper edge of the sternum above the water, one arm held fully above the water and the other hand on the hip, with sculling forbidden.
- Source: [Vathagavorakul, Gonjo & Homma (2020), The effect of experience in movement coordination with music on polyrhythmic production: artistic swimmers and water polo players during eggbeater kick performance, PLoS One](https://pmc.ncbi.nlm.nih.gov/articles/PMC7447008)
- Evidence: "The average EBK frequencies amongst ASs and WPs were 82.8 ± 4.70 bpm and 74.6 ± 3.56 bpm, respectively." Participants kept "the upper edge of their sternum above the water"; sculling was "strictly forbidden" in Task 1.
- On R6 (draft): An R6 treading-water loop: one leg cycle of about 43 to 48 frames (0.72 to 0.80 s), with the other leg half a cycle behind. Skilled treaders hold the chest up; an ordinary character sits lower (head half out, traversal-05). R6 legs cannot circle at a knee, so swing each leg in a small cone at the hip (pitch and roll a quarter cycle apart). Add slow arm sculls (side-to-side sweeps at shoulder height under the water) when the character is not this skilled.

### traversal-35 (Falls and landings)

- Claim: The United States Parachute Association's neutral belly-to-earth freefall position is: chin high, shoulders back and down, hands in front of the shoulders at about shoulder height with the elbows in front of and just below the shoulders. The arch comes from pressing the hips and glutes down. The knees are about shoulder-width apart with the lower legs extended just beyond 90 degrees, and the feet slightly closer together than the knees with the toes pointed.
- Source: [USPA (Steve Lefkowitz, 2019): Foundations of flight | Neutral Body Position](https://www.uspa.org/foundations-of-flight-neutral-body-position)
- Evidence: "Your shoulders should be back and down with your hands in front of your shoulders at about shoulder height." ... elbows "in front of and just below your shoulders" ... "Arch by pressing your hips and glutes down." ... "Your knees should be about shoulder-width apart" ... lower legs "just beyond 90 degrees"
- On R6 (draft): For a long R6 fall loop (skydive, a fall from a great height), pitch the RootJoint about 90 degrees so the belly faces the ground. Raise both arms about 80 to 90 degrees out from the sides and slightly forward, the hands at head level ahead of the shoulders, with the head pitched up against the torso. Spread the legs about shoulder width; R6 cannot bend the knees, so lift them a little back to suggest the bend. Add a slow flutter or drift with life so the loop never freezes, and keep the body's fall on the gravity parabola (body-mechanics.md).

Searched without a usable source: Mirror's Edge GDC talk (Creating First Person Movement for Mirror's Edge): GDC Vault page needs a login; secondary write-ups give no vault, wall-run or roll frame counts; Assassin's Creed Unity parkour-up/down: only previews and retrospectives, no developer timing data; Prince of Persia: The Sands of Time wall-run timing: no primary or postmortem source found; Titanfall 1 wall-run duration on the Titanfall fandom wiki (HTTP 402; the Titanfall 2 game-data file was used instead); Breaststroke phase percentages (Takagi et al. 2004 and the 2005 Thieme glide study were blocked or abstract-only); Ledge shimmy: no source with frame counts or a hand-and-foot order for the side shuffle; Vault frame counts at a known frame rate from a studio (Swansong gives frame counts without stating its frame rate); Parkour vault biomechanics (speed vault, kong vault): no study found; only gymnastics vault studies; Sprint start and sprint stop frame counts for game characters: only AC3's qualitative sprint impulsion and Titanfall 2 sprint settings whose purpose the file does not state; Studio-stated tolerance in centimetres for hand and foot contact on ledges (only a mocap vendor's 0.5 m-per-clip rule); Animation Mentor climbing and hanging tutorial (Cloudflare 403; no archive copy); Wall-run body lean angle against the wall: only a vendor's ambiguous 45 to 60 degrees; Falling-loop craft advice from a professional animator: nothing usable found; Roblox DevForum ledge-grab and wall-run systems by experienced developers with measured timings: threads found were beginner help or showcases without numbers; Roblox default R6 climb clip content: the clip itself (asset 180436334) could not be fetched or decoded in this session; Mirror's Edge Wiki speedrunning page (HTTP 402).

## Dodges, rolls, dashes and evasion

Target file: `references/dodges-and-dashes.md`. Status: researched, not checked.

### dodges-01 (Frame budgets and weight classes)

- Claim: Dark Souls (DS1 wiki roll chart): every roll type has 11 i-frames (13 for the Dark Wood Grain Ring 'ninja flip'), and equip load changes only what comes after them. Fast roll (25% load or less): 21 to 24 frames in total, with 3 recovery frames after the i-frames and 7 to 8 instability frames. Mid roll (26 to 50%): 31 to 33 frames, with 4 and 14. Fat roll (51 to 100%): 46 to 48 frames, with 9 and 25. Instability frames take 1.4x damage. In every row the columns add up to the total, so the chart puts the i-frames at the very start of the roll (our reading of the table). The page does not state its frame rate.
- Source: [Rolling (Dark Souls Wiki), read through the wiki's parse API](https://darksouls.fandom.com/wiki/Rolling)
- Evidence: 'all roll types have 11 iframes except for the roll type associated with Dark Wood Grain Ring... The main differences between roll types is the overall length of the animation coupled with Recovery Frames and Instability Frames.' Chart rows: 0% Fast Roll 11/3/7/0, total 21; 100% Fat Roll 11/9/25/3, total 48.
- On R6 (draft): Build the light, medium and heavy rolls from one evasive opening and stretch only the get-up, in a ratio of about 1 : 1.4 : 2 (21–24, 31–33 and 46–48 chart frames). If the chart counts 30 fps frames, as the Souls wikis usually do, that is about 42–48, 62–66 and 92–96 frames at 60 fps (our conversion). Key the tuck and the travel the same way in all three over the first ~22 frames and put the i-frame start and end events there. Give the heavy roll's extra ~50 frames to a slow rise out of the crouch (torso py climbing, one hand pushing off the floor), with the cancel event at its end. This is a counter-example to weapons.md's dash-through, where invulnerability lasts the whole travel: a roll is protected only at its start.

### dodges-02 (Frame budgets and weight classes)

- Claim: Elden Ring (Eldenpedia, which counts at 30 fps): a roll gives 14 i-frames at light or medium equip load and 13 at heavy load (about 0.47 and 0.43 s). A backstep gives 7 to 8 i-frames only while the character wears the Fine Crucible Feather Talisman or the Talisman of All Crucibles: 7 with most one-handed and paired light weapons, and 8 with one-handed large weapons and two-handed (not paired) light weapons.
- Source: [Invincibility Frames (Eldenpedia, Elden Ring wiki)](https://eldenring.wiki.gg/wiki/Invincibility_Frames)
- Evidence: 'Rolling while in light or medium Equip Load: 14 i-frames'; 'Rolling while in heavy Equip Load: 13 i-frames'; 'Backstepping while wearing the Fine Crucible Feather Talisman or Talisman of All Crucibles: 7-8 i-frames'; 'This wiki uses 30 frames per second as a baseline'.
- On R6 (draft): At 60 fps a roll's protected window is about 26 to 28 frames (our conversion), and a heavy roll loses only 2 of them. Weight therefore goes into the recovery, not into a shorter or later window. The backstep is the small evasion, with 14 to 16 protected frames at 60 fps when the gear grants any. Author it as a short upright hop back, a much smaller shape than the roll's tuck, so the clip does not look safer than it is.

### dodges-03 (Frame budgets and weight classes)

- Claim: Elden Ring (Eldenpedia, Equip Load): a load under 30% of the maximum is Light, 30 to 70% is Medium and over 70% is Heavy. Over 100% the character cannot roll or backstep. Light and medium rolls have the same recovery time, and the light roll travels further. The heavy roll's recovery animation is almost twice as long. The page gives no frame counts.
- Source: [Equip Load (Eldenpedia, Elden Ring wiki)](https://eldenring.wiki.gg/wiki/Equip_Load)
- Evidence: 'Light Load rolls and Medium Load rolls are equally effective and have the same recovery time'... 'the former will roll a longer distance'... 'Heavy Load rolls meanwhile face an almost twice as long recovery animation'... 'Exceeding 100% weight load will result in being Overloaded, rendering the Tarnished unable to roll or backstep'.
- On R6 (draft): You can get three weight classes from one roll clip. Light and medium share every key time and differ only in root travel: give the light roll the longer distance. The heavy roll keeps the same opening and plays its recovery at about half speed, either through a `warp` of about 0.5 over the get-up or a get-up authored twice as long, with a deeper crouch and a hand push.

### dodges-04 (Invulnerability windows and how the body shows them)

- Claim: Elden Ring (Eldenpedia): a jump gives 25 i-frames (at 30 fps), but only to the torso and legs. The arms and head stay hittable, and two-handing a large weapon such as a greatsword lifts the still-damageable arms slightly.
- Source: [Invincibility Frames (Eldenpedia, Elden Ring wiki)](https://eldenring.wiki.gg/wiki/Invincibility_Frames)
- Evidence: 'The i-frames for jumping are more complicated: they only affect the lower parts of the body'... 'two-handing larger weapons such as Greatswords will move the still-damageable arms the slightest bit upwards.' 'I-frames for the torso and legs only (not arms and head): 25 i-frames'.
- On R6 (draft): Invulnerability can apply to some parts and not others. A jump that evades low sweeps protects the legs for about 50 frames at 60 fps (our conversion). Lift both legs high and fast at takeoff, slid 0.3 to 0.4 up into the torso (weapons.md, 'A jump without moving the root'), and keep them above the sweep height for the whole window. Per-part windows need per-part hit checks in the game, so tell the requester when the hit test reads the clip's shape.

### dodges-05 (Frame budgets and weight classes)

- Claim: Super Smash Bros. Ultimate (SmashWiki roll table): every forward roll becomes intangible on frame 4. Fresh forward rolls last 26 frames for Fox, Sheik, Zero Suit Samus and Little Mac (intangible 4–12). They last 28 frames for a small, fast group (4–14), 29 for most of the cast (4–15), 30 for Captain Falcon, Donkey Kong, Ike and others, and 32 for Bowser, Charizard, Ganondorf, King Dedede, King K. Rool and Ridley (4–16). Back rolls carry about five more frames of ending lag (32 to 37 frames) and start intangibility a frame later for most characters. Repeated rolls go stale: duration D × (1 + P), with P rising 0.06 per forward roll (capped at 0.3) and 0.1 per back roll (capped at 0.5). Fully stale rolls become intangible four frames later. The penalty resets after about one second without any dodge.
- Source: [Roll (SmashWiki), Ultimate rolling frames table](https://www.ssbwiki.com/Roll)
- Evidence: 'back rolls have received more ending lag by five frames on average, and grant intangibility one frame later for most characters'; 'D * (1 + P)... increases by 0.06 for every forward roll, and 0.1 for every back roll... caps at 0.3... 0.5'; 'When fully stale, all rolls grant intangibility four frames later'. Fox 4-12/26; Bowser 4-16/32.
- On R6 (draft): A combat roll at 60 fps (combat.md counts fighting-game frames at 60 fps) runs 26 frames for a light character, 29 for a medium one and 32 for a heavy one. Put the i-frame start event on frame 3, so the first three frames are the push, and the end event on frame 12 to 16. That protects about 35 to 41% of the clip; the other 55 to 65% is recovery. Make a back roll's recovery about 5 frames longer than the forward roll's. If the game stales repeated dodges, play the same clip slower by 1/(1 + P) and move the i-frame start 4 frames later, instead of authoring new poses.

### dodges-06 (Directional sets and facing)

- Claim: SmashWiki (Roll): after a roll a character always ends up facing the direction it came from. A back roll keeps the facing and a forward roll turns the character around, so a roll past a nearby opponent ends facing them. A roll cannot carry a character off a ledge: the movement stops at the edge while the rest of the animation plays. Slow rolls are easier to react to and short rolls are easier to punish.
- Source: [Roll (SmashWiki)](https://www.ssbwiki.com/Roll)
- Evidence: 'After rolling, characters will always end up facing the direction they came from. That is, characters that roll backwards will remain facing the same way, while characters that roll forwards will turn around.' 'should they roll towards an edge, the character's movement will instantly halt at the edge while the remainder of the animation continues.'
- On R6 (draft): Give a forward roll, through or past the enemy, a 180 degree root yaw on the `turn` channel (weapons.md, whole-body turn and flip channels). Finish the yaw during the get-up so the character lands facing the threat. Side and back rolls keep their facing. When a wall or ledge raycast clamps the travel, stop the root at that point and let the body finish the clip in place; never cut the clip.

### dodges-07 (Frame budgets and weight classes)

- Claim: Smash Ultimate (SmashWiki): every spot dodge becomes intangible on frame 3. Most of the cast is intangible on frames 3–17 of 25 frames. The fastest group (Fox, Sheik, Zero Suit Samus, Little Mac, Diddy Kong) is intangible on 3–14 of 23. A larger group (Captain Falcon, Donkey Kong, Ike, Samus and others) gets 3–17 of 26, and the heaviest (Bowser, Charizard, Ganondorf, King Dedede, King K. Rool, Ridley) 3–18 of 28. Any ground attack can cancel a spot dodge 5 frames earlier than usual. Fully stale spot dodges become intangible three frames later. The animation leans the character into the background or foreground while it stays in place.
- Source: [Spot dodge (SmashWiki), Ultimate frame list](https://www.ssbwiki.com/Spot_dodge)
- Evidence: 'every character gains intangibility starting on frame 3'; 'all characters' spot dodges can now be canceled 5 frames earlier than usual into any ground attack'; 'When fully stale, all spot dodges grant intangibility three frames later'; 'the spot dodge animation shows the character leaning into the back or foreground'.
- On R6 (draft): An in-place evade (lean, duck or sway) runs about 23 to 28 frames at 60 fps, by weight. Reach the evasive shape by frame 2: torso dropped and rolled away from the attack, head off the attack's line, feet planted with `Feet.flat`. Hold it as a moving hold to about frame 16, then recover over about 8 frames. Put a cancel event 5 frames before the end, leading into the counterattack's load pose. R6 parts cannot scale, so the 'into the background' lean becomes a torso roll or a lean back off the attack line.

### dodges-08 (Anticipation, burst and stop)

- Claim: Smash Ultimate (SmashWiki): a directional air dodge first moves the character a small distance the opposite way 'in a slingshot fashion', then gives full momentum in the chosen direction, and the character starts to fall shortly afterwards. It lasts over a second in total. Landing during it costs 11 to 19 frames of landing lag, and the earlier the landing, the longer the lag. A neutral air dodge keeps the character's momentum, lasts 49 to 50 frames on average and has 10 frames of landing lag.
- Source: [Air dodge (SmashWiki)](https://www.ssbwiki.com/Air_dodge)
- Evidence: 'characters first shift a small distance towards the opposite direction in a slingshot fashion (such as left and upward if the air dodge was aimed right and downward), then receive the full momentum in the chosen direction and begin to fall shortly afterwards'... 'landing lag, which increases the earlier the character lands (ranging from 11 to 19 frames)'.
- On R6 (draft): Give an air dash a counter-move anticipation: 2 to 4 frames (a starting value) in which the root and torso drift opposite to the dash while the body gathers (pz back for a forward dash, px left for a right dash), then the burst. Let gravity take over soon after the burst. Pick the landing clip by when the dash lands: about 11 frames if it lands late, up to 19 if it lands early.

### dodges-09 (Dash speed curves and distance)

- Claim: Smash Ultimate (SmashWiki, Dash): the initial dash lasts 7 to 16 frames depending on the character (median 10 in the table, our count). It has its own speed limit, separate from the run: 0.6 to 1.49 times the run speed (median 1.1, our count). When the initial dash is faster, traction slows it down to run speed. A dash turned the other way waits 3 frames before accelerating, against 1 frame for a regular dash. The skid after a run gets longer the closer the character was to its maximum run speed. In Smash 4, Bowser, Charizard, Ganondorf and Lucario had very short skids.
- Source: [Dash (SmashWiki)](https://www.ssbwiki.com/Dash)
- Evidence: 'turnaround dashes now have 3 frames of delay before fighters begin accelerating, as opposed to the 1 frame delay of a regular dash'; 'if it is higher, the character's traction value is used to decrease it down to their run speed'; skid length 'can also vary depending on the speed the character is running at relative to their maximum running speed'.
- On R6 (draft): Build a ground dash out of idle as a burst of 7 to 16 frames whose root speed may start above the run speed and bleed down to it, then hand over to the run. A dash away from the facing needs a 3-frame turn and brace before the root moves; a dash along the facing needs 1. Scale the skid frames with the speed at release. A heavy character that must act quickly after a dash can still skid briefly: weight does not have to mean a long skid.

### dodges-10 (Frame budgets and weight classes)

- Claim: Guilty Gear Strive (Dustloop character stats, 60 fps): backdash length and invulnerability grow with how slow and heavy the character is. Millia Rage ('swift and graceful aerial movement', damage received ×1.09): 16 frames, invulnerable on frames 1–4. Sol Badguy (×0.94): 20 frames, 1–5. Potemkin ('a slow moving grappler', ×0.91): 24 frames, 1–6. In all three the invulnerability covers exactly the first quarter of the backdash (our derivation). The Millia and Sol values come from their own Dustloop pages, which were also read.
- Source: [GGST/Potemkin (Dustloop); also GGST/Millia_Rage and GGST/Sol_Badguy](https://www.dustloop.com/w/GGST/Potemkin)
- Evidence: Potemkin: 'Potemkin is a slow moving grappler who deals tremendous damage once foes are within his grasp'; Backdash '24F duration', '1-6F invuln'. Millia Rage: '16F duration', '1-4F invuln'. Sol Badguy: '20F duration', '1-5F invuln'.
- On R6 (draft): Make a backstep clip 16 frames for a light character, 20 for a medium one and 24 for a heavy one, at 60 fps. Put the i-frame events from frame 0 to frame 4, 5 or 6: the first quarter, which covers the push and the lift. The other three quarters are travel, landing and settle. The skill's 0.17 s (10-frame) 'dodge' read is the move itself; the full clip with its landing runs 1.6 to 2.4 times longer.

### dodges-11 (Anticipation, burst and stop)

- Claim: Guilty Gear Strive (Dustloop, Controls): a backdash moves the character back a preset distance, with a brief invincibility starting on its very first frame. A forward air dash pauses the character in the air briefly before propelling it forward, and any other action taken during that pause cancels the dash's momentum.
- Source: [GGST/Controls (Dustloop)](https://www.dustloop.com/w/GGST/Controls)
- Evidence: 'Backdashes move the character back for a preset distance. There is a brief period of invincibility starting from the very first frame'... forward air dash: 'the character pauses in the air briefly before propelling forward'; any other action during that pause cancels its momentum.
- On R6 (draft): Ground evasions have no vulnerable startup: protection starts on frame 0. An air dash may hold first instead. Stop the fall for 2 to 4 frames (a starting value) on a gathered pose, with the legs piked up into the torso, the arms drawn in and the head toward the target, then burst. Open the attack cancel during that hold, and drop the dash's travel if the cancel fires.

### dodges-12 (Dash speed curves and distance)

- Claim: Celeste (the Player class its developers published on GitHub): a dash calls a 0.05 s freeze at its start (`Celeste.Freeze(.05f)`). One frame later it sets the speed to 240 px/s in the aimed direction, keeping the earlier horizontal speed if that was already faster in the same direction. It holds that speed for 0.15 s, then cuts it to 160 px/s (two thirds; an upward dash also multiplies the vertical part by 0.75) and returns to the normal state. Run speed is 90 px/s, so the dash is 2.67 times the run. Above run speed the normal state brakes at 400 px/s² while the stick is held that way, and at 1000 px/s² toward rest without input. Afterimage trails spawn at the start, at 0.08 s and at the end, and the dash cooldown is 0.2 s.
- Source: [Celeste Player.cs (NoelFB/Celeste, published by the Celeste developers)](https://github.com/NoelFB/Celeste/blob/master/Source/Player/Player.cs)
- Evidence: 'DashSpeed = 240f; EndDashSpeed = 160f; EndDashUpMult = .75f; DashTime = .15f; DashCooldown = .2f'; 'MaxRun = 90f'; 'RunReduce = 400f'; DashBegin: 'Celeste.Freeze(.05f)'; 'dashTrailTimer = .08f'; 'yield return DashTime'; 'Speed = DashDir * EndDashSpeed'.
- On R6 (draft): Use a three-stage dash profile instead of a single ease. First, a 3-frame hold on the gather pose (0.05 s). Then 9 frames (0.15 s) at a constant speed about 2.7 times the run. Then a step down to two thirds of that speed and a linear brake back to run speed over about 10 frames (160 to 90 px/s at 400 px/s² takes 0.175 s, our derivation). At WalkSpeed 16 this is about 43 studs/s for 9 frames (6.4 studs), dropping to 28 studs/s at the cut (our scaling). Key the long stretch pose over the constant-speed frames and the brace on the step down (feet ahead, torso leaning back, py dropping). Place trail or afterimage events at frame 0, frame 5 and the end.

### dodges-13 (Roblox battlegrounds and platformer dashes)

- Claim: Roblox's Platformer template, read from the Constants and action modules in a DevForum user's R6 copy of it posted in the announcement thread (the user says they edited scripts to add R6 animations): one key rolls on the ground and dashes in the air. The roll drives a LinearVelocity at 60 studs/s in the ground plane and tweens it to 0 over 0.35 s with Quart In easing, with a 0.2 s cooldown. The air dash sets a full-vector LinearVelocity of 60 studs/s forward for 0.2 s, so by our reading it also holds the vertical speed at 0. A jump within 0.3 s of a roll's start turns the roll into a long jump (60 studs/s, 7 studs high). Action animations fade in over 0.1 s.
- Source: [New Platformer Template! (Roblox DevForum announcement; constants read from post #80's PlatformerR6.rbxl)](https://devforum.roblox.com/t/new-platformer-template/3088494)
- Evidence: 'ROLL_SPEED = 60', 'ROLL_TIME = 0.35', 'ROLL_COOLDOWN = 0.2'; 'DASH_SPEED = 60', 'DASH_TIME = 0.2'; 'LONG_JUMP_WINDOW = 0.3'; 'ACTION_ANIMATION_FADE_TIME = 0.1'; 'TweenInfo.new(Constants.ROLL_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.In)'; 'PlaneVelocity = Vector2.zero'. Announcement: 'Press shift... to roll on the ground or dash in the air.'
- On R6 (draft): Roblox's own roll speed, 60(1 − u⁴), stays above 94% of full speed to mid-roll and is still at 59% at 80% of the roll, then stops hard. It covers about 16.8 studs in 21 frames (our derivation). Author the R6 roll with the tuck over frames 0 to 15, while the speed is high, and the get-up in the last 6 frames as the speed collapses, landing in a braced crouch (feet ahead, torso low, leaning back). The air dash is a flat 12-frame stretch with no fall, covering 12 studs. Every roll frame up to frame 18 must blend cleanly into a long-jump takeoff. With a 0.1 s fade the first 6 frames show at partial weight, so make the opening pose read early.

### dodges-14 (Roblox battlegrounds and platformer dashes)

- Claim: The same template copy also leans the character in code on every Stepped. It computes a pitch of up to 5 degrees and a bank of up to 15 degrees from the root-relative velocity divided by WalkSpeed (clamped to ±1), eases toward that target at a rate of 10 per second, and multiplies the result onto the root joint's Transform after the animation. By our sign reading of the code it leans forward into forward travel and banks toward the side it moves to.
- Source: [New Platformer Template! (CharacterLeanScript in post #80's PlatformerR6.rbxl)](https://devforum.roblox.com/t/new-platformer-template/3088494)
- Evidence: 'local ROLL_ANGLE = math.rad(15)'; 'local PITCH_ANGLE = math.rad(5)'; 'local LEAN_SPEED = 10'; 'local pitch = math.clamp(relativeVelocity.Z / humanoid.WalkSpeed, -1, 1) * PITCH_ANGLE'; 'rootJoint.Transform = leanCFrame * rootJoint.Transform'.
- On R6 (draft): A dash or roll at 60 studs/s is far past WalkSpeed, so a script like this adds its full 5 and 15 degrees on top of the clip. Before keying a dash's lean, check the place for velocity-lean scripts. Either author the clip's lean as the target minus the script's lean, or switch the script off while an evasive clip plays. The script writes its angles in the joint's own frame, and R6 motors compose Transform through C0 (r6-mechanics.md, 'Transform convention'), so test the lean axes on the R6 rig before reusing it.

### dodges-15 (Roblox battlegrounds and platformer dashes)

- Claim: The Strongest Battlegrounds (games.gg combat guide, third-party): the dash key plus a direction gives three different moves. The forward dash deals about 4% damage on contact and can be steered mid-dash. The side dashes are fast lateral movement and a core combo tool. The back 'tumble' rolls backward twice and is invincible to normal attacks. One side or back dash breaks the character out of a ragdoll, at most once every 30 seconds.
- Source: [The Strongest Battlegrounds combat guide (games.gg)](https://games.gg/roblox/guides/the-strongest-battlegrounds-combat-guide/)
- Evidence: Forward Dash: 'Deals ~4% damage on contact; direction adjustable mid-dash'. Side Dash: 'Fast lateral movement; core combo tool'. Back Tumble: 'Rolls backward twice; invincible to normal attacks during frames'. Ragdoll Cancel: 'a single side or back dash breaks you out immediately'... 'once every 30 seconds'.
- On R6 (draft): Author a battlegrounds dash set as three clip types, not one clip mirrored. The forward dash is a strike-ready pose that the root yaw can steer: keep the pose close to symmetric and bank it into turns. The left and right dashes are low lateral slides that keep the facing. The back dash is two backward rolls with the i-frame events across them. Side and back dashes must also be able to start from a ragdoll: start from the rig's last written pose (SKILL.md, the hand-over rule) and reach the first upright key within a few frames.

### dodges-16 (Roblox battlegrounds and platformer dashes)

- Claim: A DevForum reply comparing a developer's side dash with The Strongest Battlegrounds' dash: in that game the dash velocity slows down progressively instead of ending at once, and the side dash animation's weight lowers as the dash ends.
- Source: [How can I make a smoother side dash? (Roblox DevForum)](https://devforum.roblox.com/t/how-can-i-make-a-smoother-side-dash/2883288)
- Evidence: 'The velocity from the strongest battle ground's dashes progressively slow down and don't instantly end. Think of lerping the velocity value down instead of just destroying it when the time's up.' 'Edit: The animation's weight also lowers with the ending of the side dash so experiment with that as well.'
- On R6 (draft): End a side dash with a decay, not a cut. Slow the root over the end of the travel (the last third is a starting value), and as it slows, fade the dash track's weight toward the locomotion track, with an AdjustWeight fade as long as the decay, so the legs hand over to the run or idle as the slide dies. Key the dash's last pose close to the locomotion pose it fades into, or the fade shows a blend of two different stances.

### dodges-17 (Roblox battlegrounds and platformer dashes)

- Claim: A DevForum developer found that rotating the torso in a front dash animation changed the dash's direction, because the dash direction was tied to the torso. The side dash, whose torso was not rotated, kept its direction. The thread shows no fix.
- Source: [Dash Using Movedirection Doesn't Work With Animation Because Movedirection Relies On Torso Rotation (Roblox DevForum)](https://devforum.roblox.com/t/dash-using-movedirection-doesnt-work-with-animation-because-movedirection-relies-on-torso-rotation/3280735)
- Evidence: 'The issue is when i animate the torso's rotation, the movedirection changes according to it.' ... 'as you see, the torso's rotation is changed in the front dash, but its not in the side dash.'
- On R6 (draft): Take the dash direction from HumanoidRootPart, the camera or Humanoid.MoveDirection, never from Torso.CFrame. On R6 the clip rotates the Torso through RootJoint, so a front dash's forward lean tips Torso.LookVector toward the floor, and any twist turns its yaw. Capture the direction at the press, or steer it from the camera, and let the clip lean freely.

### dodges-18 (Anticipation, burst and stop)

- Claim: An analysis of the Dark Souls dodge roll (Parry Everything): the roll has little to no anticipation and comes out when its button is released (the same button held down sprints). Its i-frames start almost immediately, and its vulnerable frames sit almost entirely at the end. Even the heaviest roll comes out almost immediately on input. The roll moves the character in a burst of speed much faster than the walk.
- Source: [The Dark Souls Dodge Roll: Immediacy in Player Action (Parry Everything)](https://parryeverything.com/2021/07/30/the-dark-souls-dodge-roll-immediacy-in-player-action/)
- Evidence: 'There is little to no anticipation in the dodging animation'; 'The dodge roll specifically comes out when its associated button is released'; i-frames 'start almost immediately'; 'the vulnerable frames of animation are almost entirely back-loaded on the action'; even 'the heaviest, slowest, clunkiest version of the dodge roll' is near-immediate.
- On R6 (draft): A player dodge gets zero anticipation frames, fewer than the 1 to 8 the skill allows a light attack. On frame 0 the body already drops and leans toward the travel, and by frame 1 the root is moving. Put the weight and the read into the landing and the get-up instead. NPC dodges are not bound by this; give them a readable 4 to 8 frame tell when players must punish them (our suggestion).

### dodges-19 (Invulnerability windows and how the body shows them)

- Claim: critpoints.net on i-frames: a dodge does two jobs, passing through an attack on its i-frames with good timing, or moving out of the way early. Rolling toward an incoming hitbox passes through it; rolling away in the direction the attack travels lets it catch up, because the roll is not invincible throughout. An early roll relies on its movement, not its i-frames. The author likes Nioh's dodges, which move quickly but have very few i-frames.
- Source: [How iFrames Augment Dodge Rolls (critpoints.net)](https://critpoints.net/2017/07/25/how-iframes-augment-dodge-rolls/)
- Evidence: 'if you dodge towards the hitbox coming at you, you'll go through it'; 'if you dodge away, in the same direction as it's going, then it will likely catch up to you'; 'you're not invincible through the whole roll'; 'if you roll early, then you're getting out of the way of the enemy attack instead of relying on iframes'.
- On R6 (draft): Stage NPC and showcase dodges against the attack. To dodge through a sweep, the roll must cross the blade during its i-frame events, so time the crossing frame to the attack's active frames. To dodge away from a lunge, the root travel must exceed the attack's reach, because the window closes while the attack is still moving. A quick dodge with few i-frames (Nioh's style) needs its travel early: put most of the root speed at the start.

### dodges-20 (Invulnerability windows and how the body shows them)

- Claim: A Gameplay Ability System write-up (Quod Soler): the i-frame window belongs on the dodge animation as a notify window that the animator stretches over the safe frames, with a tighter nested window for a perfect dodge. A fixed timer breaks when the roll is retimed, leaving the character invulnerable before it moves and vulnerable while it is still in the air. Different dodges want different windows; Souls games give light, medium and fat rolls different invulnerability.
- Source: [Dodge i-Frames with GAS: Anim Notify Windows and Perfect Dodges (Quod Soler)](https://www.quodsoler.com/blog/i-frames-are-animation-data-not-code)
- Evidence: 'The animator can stretch it over the frames that should be safe.' A timer fails because 'The timer still has its old duration', leaving the character 'invulnerable before moving and vulnerable while still in the air.' 'The inner one is tighter and grants CombatWindowPerfectDodge'.
- On R6 (draft): Store the window as event times on the clip: iframeStart and iframeEnd, plus perfectStart and perfectEnd inside them if the game rewards a perfect dodge. Poser has no marker dispatcher, so schedule these from the clip's own clock, bake them as KeyframeMarkers, and scale them with every retime (pipeline.md). Never drive invulnerability from a separate wait().

### dodges-21 (Invulnerability windows and how the body shows them)

- Claim: Enter the Gungeon (wiki): the dodge roll lasts about 0.7 s from input to regaining control. For its first half the player is invulnerable to all damage, and while in the air is also immune to floor hazards. In the second half the player keeps moving but can be hit. The direction cannot change once the roll starts. Rolling into an unflipped table slides the player over it and returns control sooner than a full roll.
- Source: [Dodge Roll (Move) (Enter the Gungeon Wiki)](https://enterthegungeon.wiki.gg/wiki/Dodge_Roll_(Move))
- Evidence: 'The total dodge roll lasts about 0.7 seconds.' 'For the first half of the dodge roll, the player is invulnerable to all damage.' In the second half, 'the player continues moving but becomes vulnerable to gunfire.' 'While in the air during a dodge roll, the player is immune to floor hazards'.
- On R6 (draft): Let the silhouette carry the window. The protected part is the dive: body off the floor, legs piked, arms forward. The unprotected part is the grounded slide or roll-out. Put iframeEnd on the touchdown frame so players learn that airborne means safe. Lock the travel direction at the press.

### dodges-22 (Invulnerability windows and how the body shows them)

- Claim: James Margaris's informal tests of the Lies of P demo dodge (a critic's tests, not frame data): the dodge shows its vulnerability visually, because in a forward dodge the character becomes vulnerable at about the point where it starts to stand back up. The roll travels further and has a more recognizable animation than the short locked-on hop.
- Source: [Dodging in the Lies of P Demo Kinda Works (On Video Games, James Margaris)](https://jmargaris.substack.com/p/dodging-in-the-lies-of-p-demo-kinda)
- Evidence: The dodge is 'visually well-communicated': 'when you dodge forward the part of the animation where you begin to stand back up is about when you become vulnerable.' The roll 'goes farther and has a more recognizable animation'.
- On R6 (draft): Put iframeEnd on the frame where the get-up starts: torso py leaves its lowest point and the first foot plants under the body. Everything after that frame reads as recovery.

### dodges-23 (Invulnerability windows and how the body shows them)

- Claim: Bayonetta (Bayonetta Wiki): Witch Time, which slows enemies down for counter-attacks, is most easily triggered by dodging an attack at the last possible moment. Pressing dodge on the exact frame Bayonetta takes damage turns her into a flock of bats for a moment ('Bat Within'); this also triggers Witch Time, with a slightly longer duration.
- Source: [Witch Time (Bayonetta Wiki), read through the wiki's parse API](https://bayonetta.fandom.com/wiki/Witch_Time)
- Evidence: 'Witch Time is most commonly and easily activated by dodging an enemy's attack at the last possible moment.' 'Pressing the dodge button the frame Bayonetta takes damage will cause her to transform into a flock of bats for a moment before reassembling herself. When this happens, Witch Time will also be activated and have a slightly increased duration.'
- On R6 (draft): A perfect dodge plays a different result, not the same dodge. Author a perfect variant, a tighter and closer evade that ends in a counter-ready pose, and switch to it when the hit lands inside the perfect window (dodges-20). Any slow-down belongs to the game's time scale. Poser springs and warps run on clip time (principles.md), so check that the clip still settles while the game is slowed.

### dodges-24 (Cancels and chains)

- Claim: Bayonetta and Bayonetta 2 (Bayonetta Wiki, Dodge Offset): holding an attack button while dodging keeps the current combo. After the dodge the player releases the button and continues the combo as if no dodge had happened. Several dodges can be chained while the button is held, and a dodge can interrupt an unfinished attack without losing the combo.
- Source: [Dodge Offset (Bayonetta Wiki), read through the wiki's parse API](https://bayonetta.fandom.com/wiki/Dodge_Offset)
- Evidence: 'Dodge Offset is performed by holding down the Punch or Kick while dodging and, then continuing the combo by releasing the attack button and pressing another button in the sequence after the dodge has been completed.' 'the player can interrupt an uncompleted attack with a dodge and still continue with the combo'.
- On R6 (draft): Let dodges sit inside combos. Keep the combo index through the dodge, and end every dodge clip on a pose that blends into the next swing's load (a guard or the next load pose; SKILL.md, 'Combo flow'). Keep the weapon on the attack side during the dodge, so the resumed swing does not have to cross the body.

### dodges-25 (Cancels and chains)

- Claim: Devil May Cry 3 (Devil May Cry Wiki, Trickster Style): the Dash 'contains invincibility frames', but the Double Dash and Triple Dash that follow it in rapid succession do not. The aerial Sky Star and the Air Trick teleport both contain invincibility frames.
- Source: [Trickster Style (Devil May Cry Wiki), read through the wiki's parse API](https://devilmaycry.fandom.com/wiki/Trickster_Style)
- Evidence: Dash: 'A quick burst of speed propels the player forward. This technique helps get the player out of tight situations and contains invincibility frames.' Double Dash: 'perform the Dash maneuver again in rapid succession. Does not contain invincibility frames.' Triple Dash: 'Does not contain invicibility frames.'
- On R6 (draft): In a chained dash only the first dash is evasive. Put i-frame events on dash 1 only, and author dashes 2 and 3 as shorter, flatter repeats (no tuck, a smaller change of lean), chained end to start, so the body shows which dash protects.

### dodges-26 (Directional sets and facing)

- Claim: Devil May Cry (Devil May Cry Wiki, Actions): while locked on, left or right plus jump is a side roll ('Roll to the side to avoid attacks') and back plus jump is a backflip. Nero's Table Hopper, a 'Just' side roll timed just before an enemy attack hits, evades 'with a slight movement of the body' that makes counter-attacks easier, and can be done up to three times in a row.
- Source: [Actions (Devil May Cry Wiki), read through the wiki's parse API](https://devilmaycry.fandom.com/wiki/Actions)
- Evidence: Roll (lock-on + left/right + jump): 'Roll to the side to avoid attacks.' Backflip (lock-on + back + jump): 'Flip out of the way from incoming...'. Table Hopper: 'Evade an enemy attack with a slight movement of the body, allowing for easier counter-attacks... Can be performed up to 3 times in a row.'
- On R6 (draft): Under lock-on or shift-lock, give each direction its own action. Side is a lateral roll that keeps the facing. Back is a backflip: a pitch flip on the `flip` channel, turning about the COM (body-mechanics.md). Add a separate small 'just' evade for a perfectly timed press: a torso sway with the feet planted, which can repeat up to three times.

### dodges-27 (Directional sets and facing)

- Claim: God of War (2018) (official PlayStation guide): a single tap of the evade button sidesteps an incoming swipe; for a bigger attack, a quick double tap with the stick held rolls 'clear of the impact'.
- Source: [The official PlayStation guide to God of War (PlayStation)](https://www.playstation.com/en-sg/editorial/the-playstation-guide-to-god-of-war/)
- Evidence: 'Tap Circle once to side step an incoming swipe' and 'for a bigger attack, quickly double-tap Circle with the left stick held to roll away clear of the impact.'
- On R6 (draft): Give an R6 kit two evasions sized to the threat. The sidestep is about as long as a spot dodge, 23 to 28 frames, with a short slide and the feet low (dodges-07, dodges-34). The roll is 26 to 32 frames plus its travel (dodges-05). The roll's travel must clear the area of the biggest attack it answers; the sidestep only has to take the body off the swipe's line.

### dodges-28 (Directional sets and facing)

- Claim: Unreal Engine forum (Character and Animation thread on an 8-way roll): one-off actions such as dives and rolls are played as montages, and blend spaces are for continuous directional movement (idle, walk, jog, run). An 8-way roll takes eight roll montages, chosen by an integer built from the forward and right input values.
- Source: [Need help setting up an 8 way roll dodge blend space (Epic Developer Community Forums)](https://forums.unrealengine.com/t/need-help-setting-up-an-8-way-roll-dodge-blend-space/132465)
- Evidence: 'Action animations … one offs like dives/rolls etc should be done via montage'; blend spaces suit 'constant directional animation (idle/walk/jog/run etc)'; 'create each of the montage rolls ( 8 of them )'; 'You can use these values to set a new var (int) as a controlling state for which roll montage you want to play.'
- On R6 (draft): Author 4 or 8 separate roll or dash clips and play the one for the input's sector as a one-shot. In an 8-way set the diagonals are clips of their own. Never blend two dodge clips by weight: two blended rolls average their rotations, and the body turns through poses that neither clip contains (our reasoning).

### dodges-29 (Directional sets and facing)

- Claim: Lords of the Fallen (2023) Steam discussion (player reports, not frame data): the opening post called the four-direction dodge 'unnecessarily cumbersome'. Other players reported locked-on dodges going a way they did not press: opposite the stick, always toward the boss, or overridden by logic based on available space and enemy positions. This got players killed near ledges.
- Source: [The four directional dodge is unacceptable (Lords of the Fallen, Steam Community discussions)](https://steamcommunity.com/app/1501750/discussions/0/6644556627476459213/)
- Evidence: 'You can only dodge in four directions which makes things unnecessarily cumbersome.' A player 'dodged in a direction I WAS NOT pressing towards.' Another: 'your dodge always goes towards the boss.' Another: the direction 'is overriden by some logic based on space available, mobs position etc'.
- On R6 (draft): Never send a dodge somewhere the input did not ask for. Pick the clip from the stick direction relative to the camera (or to the root under shift-lock) and move the root exactly that way. With only 4 clips, turn the root yaw by the leftover angle, up to 45 degrees, instead of snapping the travel to the clip's axis (our method).

### dodges-30 (Rolls: body mechanics)

- Claim: Breaking Muscle (gymnastics roll against parkour roll): a gymnastics roll puts the hands directly in front and rolls straight along the spine, so the head, neck and vertebrae take the impact, and it comes up with the weight even on both feet. A parkour roll puts the hands down in a diamond, tucks the chin toward the opposite armpit and rolls across the back along a diagonal, from one shoulder toward the opposite hip. The feet land one at a time, one tucked under the body and the other partly extended, the roller pushes off the feet to carry the roll forward, and stands once the weight is on both feet. The diagonal keeps contact off bony surfaces.
- Source: [How Do You Roll? Gymnastics vs. Parkour (Breaking Muscle)](https://breakingmuscle.com/how-do-you-roll-gymnastics-vs-parkour/)
- Evidence: Parkour roll: hands form a diamond; the roll goes 'across your back along a diagonal'; one foot tucked under the body, the other partly extended; the chin tucks toward the opposite armpit; the roller pushes off the feet 'to propel the roll forward'; it 'minimizes contact with bony surfaces'.
- On R6 (draft): Make an R6 combat roll a shoulder roll. Rotate the body about the COM on an axis tilted about 35 to 45 degrees from the side axis toward the travel: on the R6 torso's 2-by-2 back, the line from a shoulder to the opposite hip lies about 37 degrees off vertical (our geometry). Lead with one arm reaching down and forward, with the head pitched down and turned to the opposite side. Keep the legs piked into the torso while the body is inverted. On the way up, plant the tucked leg first under the body with the other leg reaching forward, then shift onto both feet and rise. Never roll straight over the top of the head.

### dodges-31 (Rolls: body mechanics)

- Claim: JitsuIQ (forward roll mechanics): the core starts the roll, lifting the hips slightly, and a push off the back foot gives the momentum. One arm extends diagonally forward, as if reaching for the opposite foot, to guide the roll. The chin tucks and the eyes look in the direction of the roll. The roll goes over one shoulder, not the neck, tracing a diagonal from one shoulder to the opposite hip. The legs stay tucked in a tight, compact shape, and the roll finishes in a stable base or standing.
- Source: [Forward Roll (JitsuIQ, Movement Mechanics)](https://jitsuiq.com/movement-mechanics/forward-roll.html)
- Evidence: 'Use your Core to initiate the roll, lifting your hips slightly.' 'Push off your back foot to generate Momentum.' 'Extend one arm diagonally forward (like reaching for the opposite foot) to guide the roll.' 'Tuck your chin to protect your neck and look in the direction of the roll.'
- On R6 (draft): Order the roll's opening keys. On frame 0 the torso drops and pitches forward with the back foot planted (`Feet.flat`). On frames 1 to 3 the back leg pushes (torso pz forward) while the leading arm swings forward and across toward the opposite foot, with the head pitched down. Start the rotation while the back foot is still down, because all rotation starts at takeoff (body-mechanics.md). Keep the legs piked through the inverted frames; the pike is R6's tightest shape (body-mechanics.md).

### dodges-32 (Rolls: body mechanics)

- Claim: Puddle and Maulder (2013) tested ten traceurs dropping from 0.75 m. A parkour roll (a forefoot landing immediately followed by a shoulder roll that leads with one side of the body and finishes on the other) cut peak vertical force from 5.2 to 2.9 body weights (−42.9%) and the loading rate from 154.3 to 64.1 BW/s (−62.8%) compared with a traditional landing. A precision landing cut them by 38.4% and 54.2%. Both parkour landings took about 80 ms to reach peak force, against 40 ms for the traditional landing.
- Source: [Ground Reaction Forces and Loading Rates Associated with Parkour and Traditional Drop Landing Techniques (Puddle and Maulder, JSSM 12, 2013)](https://jssm.org/jssm-12-122.xml-Fulltext)
- Evidence: Roll: 'an initial forefoot landing immediately followed by a shoulder roll leading with one side of the body and finishing on the opposite side of the body.' Peak force: traditional 5.2 BW, precision 3.2 (−38.4%), roll 2.9 (−42.9%). Parkour landings 'reach maximal vertical force in a mean time of 80 ms'; traditional 40 ms.
- On R6 (draft): A roll landing starts on the contact. Plant the forefoot (a flat sole on R6) on the landing frame, absorb for about 5 frames (80 ms), then go straight into the shoulder roll with no pause in between. Do not hold a pose on the landing frame: the roll begins immediately in the source.

### dodges-33 (Rolls: body mechanics)

- Claim: Croft and Bertram (2017) tested parkour athletes dropping from 0.60 to 2.30 m. Several switched from a two-footed precision landing to a roll as the drop grew, but not all did: some never rolled, and 2.3 m did not force a roll in every participant. Athletes with greater body mass and less explosive leg power were more likely to roll, and switched to the roll at a lower height.
- Source: [Affordance Boundaries Are Defined by Dynamic Capabilities of Parkour Athletes in Dropping from Various Heights (Croft and Bertram, Frontiers in Psychology, 2017)](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2017.01571/full)
- Evidence: Box heights: '0.60, 0.80, 1.05, 1.25, 1.50, 1.70, 1.85, 2.10, 2.30 m'; 'those with greater body mass and less explosive leg power, were more likely to transition to a roll' at a lower height; the highest height 'was not high enough to force a roll in every participant'.
- On R6 (draft): Make the roll landing a high-drop tier with a threshold that depends on the character. In human terms the switch fell within about 2 to 8 studs of drop (0.6 to 2.3 m at 28 cm per stud, our conversion). A heavy or less athletic character switches to the roll at a lower drop than a light, explosive one. In the skill's light, medium and heavy landing chooser (thresholds near 4 and 15 studs, principles.md), let the roll replace the heavy landing when the body is also travelling forward (our suggestion).

### dodges-34 (Sidesteps and side dashes)

- Claim: Evolve University (the boxing sidestep): to step right from an orthodox stance, push sharply off the front foot. The rear foot lifts slightly and glides on the floor instead of stepping, and the front foot follows the push to restore the stance. To step left, push off the back foot while the front foot glides. The legs never cross.
- Source: [What You Need To Know About The Sidestep In Boxing (Evolve University)](https://evolve-university.com/blog/what-you-need-to-know-about-the-sidestep-in-boxing/)
- Evidence: 'Push sharply off your front foot.' 'You shouldn't actually take a step with your back foot; it should just glide on the floor.' The front foot ends 'restoring your stance as it catches up with your back foot.' Left: 'push off your back foot towards your left.' The legs never cross.
- On R6 (draft): Key a sidestep or short side dash as a push, then a glide. On frame 0 torso px shifts over the pushing foot. On frames 1 and 2 the far foot slides out toward the travel with a small lift, soles near flat. The pushing foot follows and plants last, restoring the stance width. Never cross the legs. For a longer side dash, repeat the push and glide, or slide both feet.

### dodges-35 (Sidesteps and side dashes)

- Claim: DeRosia et al. (36 female athletes, cuts aimed at 90 degrees): the cuts actually turned 62.7 degrees when planned and 52.0 degrees when reacting to a light. A lower centre of mass during the final step went with a sharper cut in both conditions; the COM height on the step before showed no relationship.
- Source: [Relationships Between Center of Mass Height and Cutting Angle During Planned and Reactive Side-Step Cutting (IJES abstracts, vol. 8 iss. 11)](https://digitalcommons.wku.edu/ijesab/vol8/iss11/49)
- Evidence: 'The mean cutting angles in planned and reactive conditions were 62.7 ± 6.7° and 52.0 ± 11.9°.' 'Lower COM height during the final step was associated with a sharper cutting angle in both conditions.' 'No relationship between COM height and cutting angle was identified during the penultimate step.'
- On R6 (draft): When a run or dash turns into a side dash, drop the torso on the plant step itself, not on the step before, and drop it deeper for a sharper turn. A reactive turn, such as dodging an NPC's swing, turns less than intended: let it travel diagonally, about 50 to 60 degrees off the old line, rather than a clean 90.

Searched without a usable source: Monster Hunter (World, Rise, Wilds) evade i-frame counts and roll timing: the Monster Hunter Wiki and Kiranico describe Evade Window only qualitatively; numbers appear only in Steam forum posts; God of War (2018) dodge and roll frame data, and the content of the GDC 2019 Kratos animation talk (GDC Vault not readable; the official guide gives inputs and uses only); Devil May Cry and Bayonetta dodge frame counts (startup, invulnerable and recovery frames): the wikis say i-frames exist but give no numbers; Street Fighter 6 backdash frame data and invulnerability (SuperCombo wiki blocked by bot protection); Tekken backdash and Korean-backdash frame counts (wavu.wiki unreachable; cthor.me's charts are images and its KBD section is unfinished); Skullgirls backdash frame data (Mizuumi wiki blocked by bot protection); Dark Souls III roll frame data (no DS3 rolling page found; the Reddit comparison could not be fetched); Sekiro and Bloodborne step and quickstep i-frames from a non-mod source (only Nexus mod pages and forum claims); Hades and Hollow Knight dash speed and duration values (no wiki page with numbers found); A measured COM path, duration and contact timing of a forward or shoulder roll (only practitioner guides and a phase-model abstract without numbers); A GDC talk or studio article on authoring dodge or roll animation (anticipation, tuck, get-up) with frame counts; An authoritative studio source comparing 8-way and 4-way directional dodge sets (only engine-forum and player-forum posts); Roblox DevForum posts by experienced animators critiquing dash or dodge animation (the threads found were scripting questions; the only official Roblox numbers came from the Platformer template); Exact frame rate of the Dark Souls 1 roll chart (the wiki page does not state it).

## Stopped pass, 2026-10-12

Fifteen agents (13 research topics and 2 checkers) were started, restarted at max effort at the user's request, and stopped after about 10 minutes when the user said "Save everything, we'll continue this later". No agent had written its file. They left the sources they opened, the searches they ran, four checker verdicts and one researcher's notes, all below. The downloaded pages stayed in the session scratchpad and are not kept. Treat every source here as a lead to re-read, not as a checked finding.

### Checker verdicts recorded before the stop

- Traversal: the checker found traversal-08, traversal-09, traversal-10 and traversal-11 supported (traversal-11: author and role confirmed on page 1 of its source). The other traversal findings and all dodge findings have no recorded verdict.

### Raw notes from the first grabs researcher (unchecked)

Short paraphrases written while reading; the sources are in the grabs list below.

- critpoints paired animation: hero+enemy align, play one animation together, neither moves independently; animators manipulate victim limbs directly (catch a punch). AC pre-Origins all combat paired; Batman Arkham paired for punches, counters, takedowns; Dark Souls backstabs/ripostes; Doom glory kills; every fighting game throws. DX:HR multi-takedown cut to black. Smash: grabs can be hit; hyper armor on throw. Drawbacks: no multi-hit, snapping erases circumstances, often invincible, clipping. Use where required (grapples); ok when one hit kills. Limited snapping ok.
- askagamedev: participants act relative to common point; exact distance and orientation; needs flat ground, space, no objects; failures: midair, punch miss by a mile, phantom judo throw, clip through; engineering finds good places near position/orientation.
- gameanim Doom: glory kills 30 to 60 frames, 1-1.5 s at outside (quoting RPS).
- avadev GDC2019 Spider-Man AI: sync joints: each combat anim extra joint; match attack and response sync joints so they play at right distance; each attack needs matching response per character -> lots of work.
- UE motion warping: root motion; warping windows notify states; warp target name; translation, ignore Z, rotation; rotation type default (match target rotation) or facing; skew warp matches location+rotation at end of window; warp rotation time multiplier; punch example: skew warp window ending at strike.
- ssbwiki Grab: standing grab fastest startup lowest ending lag, shortest range; dash grab more startup + heavier ending lag; pivot grab most startup. Ultimate gave grabs more ending lag. Grab duration Brawl+: 90 + 1.7p frames; mash -14.4 frames/input in Smash4/Ult; min 19 frames; release invuln 60 frames Ult; both grab at once -> cancel out (grab parrying).
- ssbwiki Throw: invulnerable throughout throw in Ultimate (frame 1 to throw frame); Melee/Brawl weight-dependent throw speed weight/100 multiplier; Smash4 total + 26*(w/100-1); Ult removed. Release hitbox only affects target; collateral hitboxes only bystanders.
- UFD Mario: grab 6/34, dash 9/42, pivot 10/36; fthrow 13/27, bthrow 44/59, uthrow 18/39, dthrow 18/39. Incineroar grab 7/37, dash 11/45, pivot 12/43; Alolan Whip (command grab) startup 16 total 57 grab active 16-32; lariat follow window frame 43-47.
- infil KI basics: throws 5f startup, active 2f, 7 frames after connect to tech, very long whiff recovery, hard knockdown ~60 frames; command grabs can't be teched; avoid by moving out of range or throw-invincible move.
- EventHubs SF6 beta: throws same startup/active as SF5; +6 recovery frames -> 30 frames total (24 in SF3/4/5); whiffed throw easier to punish (punish counter).
- infil glossary: Throw tech -> both pushed apart to neutral. Command throw: can't tech; often longer range. Running bear grab: slower, visual tell, reactable. Throw protection: SF4/5/6 2f wakeup, 3S 6f, Strive 5f, KI none. Chain grab: Smash 4+ thrown once -> cannot be thrown again ~1s. Perfect Parry SF6: at most 2 frames before attack hits; screen freeze briefly, recover almost immediately. Parry SF3 tight window. Hit throw: animates like a throw if it hits, blockable. Screen freeze: dark, camera angle change, pose. Cinematic: camera cuts, ok as long as not too long.
- TLOU2 gamedeveloper: melee attack contains attacker and target animations; start conditions range, facing, line of motion; if not met melee doesn't start; timeline tags hit frames, target tracking, invincibility.
- Game Informer UC4: decoupled; enemy no longer slides unnaturally to line up with Drake; sync only when grappling; openers and attacks unsynced; hit reactions chosen by angle and where hit on body.
- Unreal forum (users): both skeletons in one scene, roots known distance; snap enemy root to known position before; trigger both simultaneously; hand IK for height diff or separate anims. (users only)
- DevForum how-to-make-grab: weld + PlatformStand (excessenergy quote); disable AutoRotate both; play anim on each humanoid; correct relative position key; animate both in Moon Animator; grab snaps attacker or victim into position; anchoring works if positioned.
- DevForum issues-with-grab: Part0 of weld gets network ownership (jova); TSB comparison.
- DevForum network ownership stolen: welded parts share ownership with assembly base part; remove weld then reset ownership at release.
- Roblox docs network ownership: anchored parts server-owned, can't change; SetNetworkOwner nil conservatively jittery; owned parts no latency; can't verify client physics.
- Roblox docs assemblies: weld/Motor6D -> assembly; root part priority: Anchored > Massless false > RootPriority > size (HumanoidRootPart, Torso weighting); root part used for replication and network ownership.
- DevForum syncing two characters (631262): TimePosition not replicated; server can't read/write player char TimePosition; setting it overwritten.
- DevForum syncing perfectly (1534896): slight delay inevitable; set TimePosition on first sync; GetServerTimeNow start with server time and advance track by delay.
- DevForum anims same time not synced: ownership to initiator fixed dummy, not player pair; real problem LinearVelocity knockback.
- AnimationTrack docs: TimePosition, Speed, IsPlaying, WeightCurrent tagged Not Replicated.
- For Honor 2.60.1: Cavalier Dance parry window 166 ms (400-566), removed last frame before hit; reason players could react earlier. 2.38: parry follow-up input window +66ms; impaling riposte from parry 800 ms from 900.

### Sources opened and searches run, per target file (unchecked leads)

#### dodges-and-dashes.md

Dodges, rolls, dashes and evasion.

Sources opened:

- <https://darksouls.fandom.com/api.php?action=parse&page=Rolling&prop=wikitext&format=json>
- <https://eldenring.wiki.gg/wiki/Invincibility_Frames>
- <https://eldenring.wiki.gg/wiki/Equip_Load>
- <https://www.ssbwiki.com/api.php?action=parse&page=Roll&prop=wikitext&format=json>
- <https://www.ssbwiki.com/api.php?action=parse&page=Spot_dodge&prop=wikitext&format=json>
- <https://www.ssbwiki.com/api.php?action=parse&page=Air_dodge&prop=wikitext&format=json>
- <https://www.ssbwiki.com/api.php?action=parse&page=Dash&prop=wikitext&format=json>
- <https://www.dustloop.com/wiki/api.php?action=parse&page=GGST/Potemkin&prop=wikitext&format=json>
- <https://raw.githubusercontent.com/NoelFB/Celeste/master/Source/Player/Player.cs>
- <https://eldenring.wiki.gg/api.php?action=parse&page=Invincibility_Frames&prop=wikitext&format=json>
- <https://eldenring.wiki.gg/api.php?action=parse&page=Equip_Load&prop=wikitext&format=json>
- <https://www.dustloop.com/wiki/api.php?action=parse&page=GGST/Millia_Rage&prop=wikitext&format=json>
- <https://www.dustloop.com/wiki/api.php?action=parse&page=GGST/Sol_Badguy&prop=wikitext&format=json>
- <https://www.dustloop.com/wiki/api.php?action=parse&page=GGST/Controls&prop=wikitext&format=json>
- <https://bayonetta.fandom.com/api.php?action=parse&page=Witch_Time&prop=wikitext&format=json>
- <https://bayonetta.fandom.com/api.php?action=parse&page=Dodge_Offset&prop=wikitext&format=json>
- <https://devilmaycry.fandom.com/api.php?action=parse&page=Trickster_Style&prop=wikitext&format=json>
- <https://devilmaycry.fandom.com/api.php?action=parse&page=Actions&prop=wikitext&format=json>
- <https://enterthegungeon.wiki.gg/api.php?action=parse&page=Dodge_Roll_(Move)&prop=wikitext&format=json>
- <https://archive.org/wayback/available?url=eldenring.wiki.gg/wiki/Invincibility_Frames>
- <https://archive.org/wayback/available?url=eldenring.wiki.gg/wiki/Equip_Load>
- <https://archive.org/wayback/available?url=enterthegungeon.wiki.gg/wiki/Dodge_Roll_(Move>
- <https://enterthegungeon.wiki.gg/wiki/Dodge_Roll_(Move>
- <https://devforum.roblox.com/t/3088494.json>
- <https://devforum.roblox.com/t/3088494/80.json>
- <https://devforum.roblox.com/uploads/short-url/6OFsFGdW3deAasMoS9VnHGscRoF.rbxl>
- <https://devforum.roblox.com/t/2883288.json>
- <https://devforum.roblox.com/t/3280735.json>
- <https://forums.unrealengine.com/t/need-help-setting-up-an-8-way-roll-dodge-blend-space/132465.json>
- <https://games.gg/roblox/guides/the-strongest-battlegrounds-combat-guide/>
- <https://parryeverything.com/2021/07/30/the-dark-souls-dodge-roll-immediacy-in-player-action/>
- <https://critpoints.net/2017/07/25/how-iframes-augment-dodge-rolls/>
- <https://www.quodsoler.com/blog/i-frames-are-animation-data-not-code>
- <https://jmargaris.substack.com/p/dodging-in-the-lies-of-p-demo-kinda>
- <https://www.playstation.com/en-sg/editorial/the-playstation-guide-to-god-of-war/>
- <https://steamcommunity.com/app/1501750/discussions/0/6644556627476459213/>
- <https://breakingmuscle.com/how-do-you-roll-gymnastics-vs-parkour/>
- <https://jitsuiq.com/movement-mechanics/forward-roll.html>
- <https://jssm.org/jssm-12-122.xml-Fulltext>
- <https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2017.01571/full>
- <https://evolve-university.com/blog/what-you-need-to-know-about-the-sidestep-in-boxing/>
- <https://digitalcommons.wku.edu/ijesab/vol8/iss11/49>
- <https://darksouls.fandom.com/api.php?action=parse&page=Rolling&format=json&prop=wikitext&formatversion=2>
- <https://darksouls.fandom.com/api.php?action=parse&page=Rolling&format=json&prop=text&formatversion=2>
- <https://eldenring.wiki.gg/api.php?action=parse&page=Invincibility_Frames&format=json&prop=wikitext&formatversion=2>
- <https://eldenring.wiki.gg/api.php?action=parse&page=Equip_Load&format=json&prop=wikitext&formatversion=2>
- <https://eldenring.wiki.gg/wiki/Invincibility_Frames?action=raw>
- <https://web.archive.org/web/2026/https://eldenring.wiki.gg/wiki/Invincibility_Frames>
- <https://web.archive.org/web/2026id_/https://eldenring.wiki.gg/wiki/Invincibility_Frames>

#### traversal.md

Traversal: climb, mantle, vault, slide, wall run, swim.

Sources opened:

- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Humanoid.yaml>
- <https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/avatar/scripts/humanoidAnimateSAuth/humanoidAnimateSAuth.lua>
- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/TrussPart.yaml>
- <https://devforum.roblox.com/t/4036735.json>
- <https://devforum.roblox.com/t/4863739.json>
- <https://devforum.roblox.com/t/738376.json>
- <https://mdpi-res.com/d_attachment/ijerph/ijerph-17-02897/article_deploy/ijerph-17-02897.pdf>
- <https://stacks.cdc.gov/view/cdc/214290/cdc_214290_DS1.pdf>
- <https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=EXT_ID:21917019%20AND%20SRC:MED&resultType=core&format=json>
- <https://blog.playstation.com/?p=370798>
- <https://www.gameanim.com/2014/02/11/animating-3rd-assassin/5/>
- <https://www.gameanim.com/2014/02/11/animating-3rd-assassin/>
- <https://eirteam-docs.readthedocs.io/en/latest/documentation/swansong/swansong_animation_sheets.html>
- <https://raw.githubusercontent.com/jmechner/Prince-of-Persia-Apple-II/master/01%20POP%20Source/Source/SEQTABLE.S>
- <https://raw.githubusercontent.com/jmechner/Prince-of-Persia-Apple-II/master/01%20POP%20Source/Source/TABLES.S>
- <https://animationobsessive.substack.com/p/how-the-little-guy-moved>
- <https://raw.githubusercontent.com/dyanikoglu/ALS-Community/main/Source/ALSV4_CPP/Private/Components/ALSMantleComponent.cpp>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/motion-warping-in-unreal-engine>
- <https://docs.unity3d.com/Manual/TargetMatching.html>
- <https://docs.unity3d.com/ScriptReference/Animator.MatchTarget.html>
- <https://history.siggraph.org/wp-content/uploads/2022/09/2017-Talks-Bollo_High-Performance-Animation-in-Gears-of-War-4.pdf>
- <https://www.gameanim.com/2018/03/09/interactive-cinematics-in-uncharted-4/>
- <https://mocaponline.com/blogs/mocap-news/climbing-animation-games-guide>
- <https://eirteam-docs.readthedocs.io/en/latest/documentation/swansong/swansong_pitch.html>

Searches run:

- Animation Obsessive Prince of Persia Jordan Mechner rotoscoping 15 frames per second

#### human-micro-motion.md

Life in still poses: sway, breath, gaze and fidgets.

Sources opened:

- <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11688309/>
- <https://www.scielo.br/j/rbfis/a/hFQTppgw4q3jGBCDKV9fdCH/?lang=en>
- <https://bmclab.pesquisa.ufabc.edu.br/pubs/nl00.pdf>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC11688309/>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC4393163/>
- <https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2021.722732/full>
- <https://pro.univ-lille.fr/fileadmin/user_upload/pages_pros/cedrick_bonnet/2012a_Bonnet.pdf>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC2290269/>
- <https://bmclab.pesquisa.ufabc.edu.br/pubs/pmcvii.pdf>
- <https://ntnuopen.ntnu.no/ntnu-xmlui/handle/11250/271477>
- <https://hdl.handle.net/11250/271477>
- <https://stacks.cdc.gov/view/cdc/224973/cdc_224973_DS1.pdf>
- <https://nva.sikt.no/registration/0198ed33c8e9-285c52ba-b057-4011-ab65-2322c62f4d33>
- <https://pubmed.ncbi.nlm.nih.gov/?term=Age-related+changes+in+human+postural+control+of+prolonged+standing+Freitas>
- <https://pubmed.ncbi.nlm.nih.gov/?term=Age-related+difference+on+weight+transfer+during+unconstrained+standing>
- <https://pubmed.ncbi.nlm.nih.gov/?term=Stabilographic+analysis+of+unconstrained+standing+Duarte+Harvey+Zatsiorsky>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=prolonged+standing+Freitas+Duarte+2005+age-related&retmode=json>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=(prolonged+standing[Title])+AND+Duarte+M[Author]&retmode=json>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=19084411,18696056,16274914&rettype=abstract&retmode=text>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC10170532/>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC5534162/>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC3309333/>
- <https://hal.univ-lille.fr/hal-02159217/document>
- <https://ebm.ufabc.edu.br/publications/md/G07.pdf>
- <https://lilloa.hal.science/hal-02159217/document>
- <https://pro.univ-lille.fr/fileadmin/user_upload/pages_pros/cedrick_bonnet/2016c_Bonnet_and_Baudry.pdf>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC2605952/>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC4370616/>
- <https://pubmed.ncbi.nlm.nih.gov/10333006/>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=10333006&rettype=abstract&retmode=text>
- <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4369292/>
- <https://www.med.upenn.edu/solomon/images/Barany2002.pdf>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC4369292/>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=Bentivoglio[Author]+AND+blink+rate+patterns+normal+subjects&retmode=json>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=9399231&rettype=abstract&retmode=text>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC4043155/>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC5973601/>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC3387343/>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=Tobin[Author]+AND+Breathing+patterns+normal+subjects[Title]&retmode=json>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=1142186&rettype=abstract&retmode=text>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=6354586,6872603&rettype=abstract&retmode=text>
- <https://ijpp.com/IJPP archives/1998_42_3/417-420.pdf>
- <https://publications.ersnet.org/content/erj/66/suppl69/oa5400>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2605952>
- <https://research.lancaster-university.uk/en/publications/eye-head-and-torso-coordination-during-gaze-shifts-in-virtual-rea/>
- <https://research.lancaster-university.uk/files/274732202/Eye_Head_and_Torso_Coordination_During_Gaze_Shifts_in_Virtual_Reality.pdf>

Searches run:

- normative center of pressure quiet standing sway amplitude frequency anterior-posterior medial-lateral healthy adults open access
- Duarte Zatsiorsky patterns of center of pressure migration prolonged unconstrained standing shifting fidgeting drifting
- Duarte Freitas 2010 revision of posturography based on force plate for balance evaluation
- quiet standing body sway angle degrees inverted pendulum COM RMS mm healthy young adults Loram
- stance width effect on postural sway mediolateral anterior-posterior feet together versus apart COP pmc
- "public data set of human balance evaluations" Santos Duarte PeerJ COP
- Winter Patla Prince 1998 stiffness control of balance in quiet standing J Neurophysiol COM COP range mm
- prolonged standing postural changes frequency per minute center of pressure shifts 30 minutes Duarte Ergonomics 2000 unconstrained standing
- Wiltman Rekant Chambers prolonged standing weight shifts fidgets frequency increase over time discomfort
- Prado Dinato Duarte 2011 age-related difference on weight transfer during unconstrained standing number of weight transfers 30 min
- Freitas Wieczorek Marchetti Duarte age-related changes postural control prolonged standing COP shifts per minute
- quiet stance COP RMS amplitude mm anteroposterior mediolateral young adults eyes open table "RMS" "mm" postural sway reference
- head displacement quiet standing mm sway head marker young adults anteroposterior mediolateral amplitude
- SwayStar normative trunk sway angle pitch roll range degrees standing two legs eyes open healthy
- dual task cognitive attention effect quiet standing postural sway decreases or increases young adults COP review open access
- Freedman coordination of the eyes and head during visually guided behavior head contribution gaze shift amplitude PMC
- human eye-head gaze shifts head movement onset latency relative to eye ms head contribution percent amplitude head peak velocity deg/s open access
- human head rotation kinematics natural behavior head saccade amplitude duration peak velocity main sequence degrees per second study
- Stahl 1999 amplitude of human head movements associated with horizontal saccades eye-only range head movement range
- human head movement velocity "deg/s" gaze shift 40 degrees head turn duration ms Zangemeister Stark head movement dynamics
- high-speed camera characterization of voluntary eye blinking kinematics Kwon J R Soc Interface blink duration ms
- breathing effect on postural sway quiet standing respiration COP oscillation amplitude hip ankle compensation open access
- quiet breathing inspiratory time expiratory time ratio Ti/Ttot healthy adults resting breathing pattern tidal volume values
- chest wall surface displacement quiet breathing mm anteroposterior rib cage abdomen optoelectronic structured light healthy adults
- spontaneous sigh frequency humans per hour tidal volume twice normal Vlemincx sigh resets breathing variability
- respiratory rate recovery after exercise time to return to baseline minutes healthy adults breathing frequency post-exercise recovery kinetics
- Duarte Zatsiorsky "prolonged unconstrained standing" shifting fidgeting drifting pdf
- Sidenmark Gellersen "Eye, Head and Torso Coordination During Gaze Shifts in Virtual Reality" pdf head latency contribution
- eprints.lancs.ac.uk Sidenmark Gellersen eye head torso coordination gaze shifts virtual reality

#### procedural-layers.md

Procedural layers that make few keys look rich.

Sources opened:

- <https://theorangeduck.com/page/spring-roll-call>
- <https://www.gameanim.com/?p=15568>
- <https://gamedeveloper.com/design/video-an-indie-approach-to-procedural-animation>
- <https://www.gdcvault.com/play/1020583/Animation-Bootcamp-An-Indie-Approach>
- <https://polycount.com/discussion/comment/2093086>
- <https://www.youtube.com/watch?v=LNidsMesxSE>
- <https://hub.jmonkeyengine.org/t/dynamic-procedural-character-animation-system/29460>
- <https://youtubetotranscript.com/transcript?v=LNidsMesxSE>
- <https://www.youtube.com/watch?v=LNidsMesxSE&hl=en>
- <https://vimeo.com/2360652>
- <https://wolfire.com/blog/2010/02/initial-animation-and-scripting>
- <https://github.com/WolfireGames/overgrowth/tree/main/Data/Scripts>
- <https://github.com/WolfireGames/overgrowth/tree/main/Data/Animations>
- <https://raw.githubusercontent.com/WolfireGames/overgrowth/main/Data/Scripts/aircontrols.as>
- <https://www.gdcvault.com/play/1025331/Inertialization>
- <https://www.gdcvault.com/play/1025165/Inertialization>
- <https://theorangeduck.com/page/dead-blending>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/animation-blueprint-inertialization-in-unreal-engine>
- <https://media.gdcvault.com/gdc2018/presentations/bollo_david_inertialization_high_performance.pdf>
- <https://media.gdcvault.com/gdc2016/Presentations/Clavet_Simon_MotionMatching.pdf>
- <https://media.gdcvault.com/gdc2016/Presentations/Clavet_Simon_Motion_Matching.pdf>
- <https://www.ryanjuckett.com/damped-springs/>
- <https://theorangeduck.com/page/code-vs-data-driven-displacement>
- <https://gdcvault.com/play/1025165/Inertialization-High-Performance-Animation-Transitions>
- <https://history.siggraph.org/?p=84136>
- <https://ubm-twvideo01.s3.amazonaws.com/o1/vault/gdc2018/presentations/Bollo_David_Inertialization_High_Performance.pdf>
- <https://ubm-twvideo01.s3.amazonaws.com/o1/vault/gdc2018/presentations/BolloDavid_Inertialization.pdf>
- <https://media.gdcvault.com/gdc2018/presentations/Bollo_David_Inertialization_High_Performance.pdf>
- <https://cdn.gearsofwar.com/thecoalition/publications/SIGGRAPH%202017%20-%20High%20Performance%20Animation%20in%20Gears%20ofWar%204%20-%20Abstract.pdf>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/animation-blueprint-blend-nodes-in-unreal-engine>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/pose-warping-in-unreal-engine>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/foot-placement-in-unreal-engine>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/[a-z0-9-]*foot[a-z0-9-]*>
- <https://docs.unrealengine.com/PythonAPI/class/FootPlacementPlantSettings.html>
- <https://docs.unrealengine.com/PythonAPI/class/FootPlacementPelvisSettings.html>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/python-api/class/FootPlacementPelvisSettings>
- <https://api.unrealengine.com/INT/PythonAPI/class/AnimNode_FootPlacement.html>
- <https://research.cs.wisc.edu/graphics/Papers/Gleicher/Animation/RegistrationCurves.pdf>
- <https://runevision.com/multimedia/thesis/Rune_Skovbo_Johansen_-_Thesis_-_Automated_Semi-Procedural_Animation_for_Character_Locomotion.pdf>

Searches run:

- David Rosen "An Indie Approach to Procedural Animation" GDC 2014 transcript Overgrowth
- David Bollo Inertialization High-Performance Animation Transitions Gears of War GDC 2018 slides pdf
- wolfire blog Overgrowth procedural animation keyframes interpolation run cycle David Rosen
- "Rosen" Overgrowth GDC animation bootcamp "two keyframes" OR "13 keyframes" OR "few keyframes" run cycle springs notes
- youtube GDC "An Indie Approach to Procedural Animation" David Rosen
- site:blog.wolfire.com animation keyframes interpolation
- wolfire.com blog Overgrowth "animation" David Rosen procedural run jump physics blog post
- Overgrowth angelscript "time_step" 120 hz update script character
- Bollo inertialization quintic polynomial "x0" "v0" blend time "-5" overshoot formula
- theorangeduck dead blending inertialization
- "inertialization" Bollo slides "Gears of War 4" quintic polynomial blend time overshoot "inertialization" explanation blog
- Bollo "Inertialization: High-Performance Animation Transitions in Gears of War" GDC 2018
- Bollo inertialization quintic polynomial "x0" "v0" t1 "-5 x0 / v0" acceleration formula slides
- inertialization Gears of War quintic polynomial blend "Bollo" explanation overshoot clamp duration
- Unreal Engine "Foot Placement" animation node documentation pelvis "Plant Speed Threshold" settings
- Kovar Gleicher "Flexible automatic motion blending with registration curves" pdf
- Rune Skovbo Johansen "Automated Semi-Procedural Animation for Character Locomotion" thesis pdf

#### aerial-combat.md

Aerial combat: launchers, air combos and slams.

Sources opened:

- <https://www.ssbwiki.com/Landing_lag>
- <https://ultimateframedata.com/mario>
- <https://www.ssbwiki.com/Fast_fall>
- <https://www.ssbwiki.com/Meteor_smash>
- <https://www.dustloop.com/w/Glossary>
- <https://www.dustloop.com/w/GGST/Movement>
- <https://www.dustloop.com/wiki/api.php?action=query&list=search&srsearch=air+dash+landing+recovery&srlimit=20&format=json>
- <https://www.dustloop.com/wiki/api.php?action=query&list=search&srsearch=wall+bounce+ground+bounce&srlimit=20&format=json>
- <https://www.dustloop.com/wiki/api.php?action=parse&page=GGST/Damage&prop=wikitext&format=json>
- <https://wiki.supercombo.gg/api.php?action=query&list=search&srsearch=launcher+air+combo+ground+bounce&srlimit=30&format=json>
- <https://wiki.supercombo.gg/api.php?action=query&list=search&srsearch=launcher&srlimit=30&format=json>
- <https://wiki.supercombo.gg/w/Ultimate_Marvel_vs_Capcom_3/Game_Mechanics>
- <https://wiki.supercombo.gg/api.php?action=parse&page=Ultimate_Marvel_vs_Capcom_3/Game_Mechanics&prop=wikitext&format=json>
- <https://wiki.supercombo.gg/api.php?action=parse&page=Ultimate_Marvel_vs_Capcom_3/System&prop=wikitext&format=json>
- <https://wiki.supercombo.gg/api.php?action=query&prefix=Ultimate_Marvel_vs_Capcom_3/&list=allpages&aplimit=100&apprefix=Ultimate%20Marvel%20vs%20Capcom%203/&format=json>
- <https://devforum.roblox.com/t/best-to-use-for-air-combat/3112442>
- <https://the-strongest-battlegrounds.fandom.com/api.php?action=query&list=search&srsearch=downslam&srlimit=20&format=json>
- <https://the-strongest-battlegrounds.fandom.com/api.php?action=query&list=search&srsearch=uppercut&srlimit=20&format=json>
- <https://the-strongest-battlegrounds.fandom.com/api.php?action=parse&page=The_Strongest_Hero&prop=wikitext&format=json>
- <https://raw.githubusercontent.com/NoelFB/Celeste/master/Source/Player/Player.cs>
- <https://blogs.jccc.edu/dpatter/2016/03/15>
- <https://www.gdcvault.com/play/1023148/Math-for-Game-Programmers-Building>
- <https://www.ssbwiki.com/Stall-then-fall>
- <https://wavu.wiki/w/api.php?action=query&list=search&srsearch=juggle&srlimit=20&format=json>
- <https://wavu.wiki/w/api.php?action=query&list=search&srsearch=tornado&srlimit=20&format=json>
- <https://peerj.com/articles/18000/>
- <https://www.ncbi.nlm.nih.gov/pmc/?term=angular+momentum+jump+serve+volleyball>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc&term=angular+momentum+airborne+volleyball+jump+serve&retmode=json>
- <https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pmc&id=12843030,12751981,12475051,11365485,10302913,7481710,1725243&retmode=json>
- <https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json/PMC11365485/unicode>
- <https://create.roblox.com/docs/reference/engine/classes/Camera>
- <https://create.roblox.com/docs/reference/engine/classes/Camera.md>
- <https://wavu.wiki/w/api.php?action=query&prop=revisions&rvprop=content&rvslots=main&format=json&titles=Juggle>

Searches run:

- dustloop Guilty Gear Strive system mechanics air dash landing recovery wall bounce gravity juggle
- Devil May Cry air combo enemy hangs in air gravity "Aerial Rave" Dante stays airborne attacks slow fall
- PlatinumGames blog action game design aerial combo enemy float gravity Bayonetta developer
- gamedeveloper.com air juggle combat design launcher enemies airborne hang time action game
- devforum.roblox.com air combo battlegrounds uppercut keep player in air velocity juggle
- The Strongest Battlegrounds wiki uppercut downslam M1 combo jump space
- Kyle Pittman "Building a Better Jump" GDC 2016 slides pdf faster gravity falling
- volleyball spike biomechanics airborne angular momentum legs counter-rotate trunk arm swing conservation PMC
- John Nesky "50 Game Camera Mistakes" jump camera should not follow vertical summary
- 80.lv animator interview aerial attack jump attack animation combat weight landing

#### knockdowns-and-deaths.md

Knockback, knockdown, get-up, stun and death.

Sources opened:

- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Humanoid.yaml>
- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/enums/HumanoidStateType.yaml>
- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/BallSocketConstraint.yaml>
- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Players.yaml>
- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/physics/network-ownership.md>
- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/BasePart.yaml>
- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/physics/constraints/ball-socket.md>
- <https://www.ssbwiki.com/index.php?title=Floor_getup&action=raw>
- <https://glossary.infil.net/glossary.json>
- <https://glossary.infil.net/>
- <https://glossary.infil.net/glossary.js>
- <https://glossary.infil.net/js/glossary.js>
- <https://glossary.infil.net/json/glossary.json>
- <https://www.dustloop.com/w/GGST/Damage>
- <https://www.dustloop.com/wiki/api.php?action=parse&page=GGST/Damage&prop=wikitext&format=json>
- <https://www.dustloop.com/wiki/api.php?action=parse&page=GGST/Frame_Data&prop=wikitext&format=json>
- <https://wiki.supercombo.gg/api.php?action=query&list=search&srsearch=Street%20Fighter%206%20knockdown%20wakeup&format=json&srlimit=20>
- <https://wiki.supercombo.gg/api.php?action=query&list=allpages&apprefix=Street%20Fighter%206/&aplimit=200&format=json>
- <https://www.redbull.com/us-en/sekiro-shadows-die-twice-interview>
- <https://www.psu.com/news/32685/for-honor-update-1-0-5-patch-notes>
- <https://support.activision.com/sekiro/articles/sekiro-shadows-die-twice-game-mechanics>
- <https://www.ubisoft.com/en-us/game/for-honor/news-updates/7hqWcY0hNa6Ynj7m7pdJcm/patch-notes-2681-for-honor>
- <https://ubisoft.com/it-it/game/for-honor/news-updates/1nwGEXUmVA2kWXSPZcVkjR/patch-notes-2531-for-honor>
- <https://graphics.cs.ucr.edu/projects/dynResp/mocsim2.html>
- <https://history.siggraph.org/?p=113900>
- <https://api.unpaywall.org/v2/10.1145/1073204.1073249?email=test@example.com>
- <https://api.semanticscholar.org/graph/v1/paper/DOI:10.1145/1073204.1073249?fields=title,openAccessPdf,abstract>
- <https://2018.cedec.cesa.or.jp:443/2010/archive/files/C10_I0052/C10_I0052.pdf>
- <https://devforum.roblox.com/t/4298561.json>
- <https://devforum.roblox.com/t/4656414.json>
- <https://devforum.roblox.com/t/3266099.json>

Searches run:

- Roblox DevForum R6 ragdoll BallSocketConstraint Motor6D attachments getting up GettingUp state
- Roblox "Avatar Joint Upgrade" AnimationConstraint BallSocketConstraint physics ragdoll announcement
- ssbwiki tech window 20 frames lockout missed tech prone getup
- For Honor patch notes guard break counter window ms "guard break" stagger out of stamina
- Sekiro posture break deathblow design interview Miyazaki posture system why
- ubisoft.com For Honor patch notes "wall splat" guaranteed heavy stun duration ms
- Sekiro posture recovery rate guarding HP fextralife posture break frames deathblow window
- ubisoft.com for-honor "out of stamina" knocked down guard break throw "ground attack" guide
- "Dynamic Response for Motion Capture Animation" Zordan Majkowska Chiu Fast pdf
- GDC physics animation ragdoll blend death animation hit reaction powered ragdoll slides pdf Uncharted OR "Last of Us" OR "Red Dead"
- PuppetMaster BehaviourPuppet documentation get up prone supine blend to animation unpinned knockOutDistance
- Zordan 2005 dynamic response motion capture "ballistic" "search" recovery motion simulation blend 0.1 seconds pdf
- "Dynamic Response for Motion Capture Animation" filetype:pdf
- "Physics Meets Animation" "Just Cause 2" Fuller Nilsson GDC pdf
- Michal Mach "Physics Animation in Uncharted 4" GDC slides ragdoll hit reaction
- gamedeveloper.com euphoria NaturalMotion active ragdoll interview Torsten Reil character falls protect head
- Avatar Joint Upgrade Studio Beta physically simulated characters AnimationConstraint devforum ragdoll get up
- ssbwiki floor recovery getup attack roll intangible frames lying down "jab reset"
- supercombo wiki Street Fighter V quick rise back rise hard knockdown frames wake up timing
- dustloop GGST wakeup timing face up face down frames knockdown Strive system data

#### grabs-throws-and-finishers.md

Grabs, throws, counters and finishers.

Sources opened:

- <https://critpoints.net/2020/03/24/what-the-fuck-is-paired-animation/>
- <https://askagamedev.tumblr.com/post/739600621064372224/how-do-paired-animations-work-like-ive-heard>
- <https://www.gameanim.com/?p=13952>
- <https://grrava.blogspot.com/2019/03/gdc-2019-part-one.html>
- <https://blog.avadev.be/2019/04/gdc-2019-part-one.html>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/motion-warping-in-unreal-engine>
- <https://www.ssbwiki.com/Grab>
- <https://dustloop.com/w/Throws>
- <https://words.infil.net/w03-sf6beta-p4.html>
- <https://glossary.infil.net/?t=Throw%20Tech>
- <https://glossary.infil.net/json/glossary.json>
- <https://wiki.supercombo.gg/w/Street_Fighter_6/Game_Data>
- <https://ki.infil.net/basics3.html>
- <https://wiki.supercombo.gg/w/Street_Fighter_6/Offense>
- <https://www.eventhubs.com/news/2022/nov/02/street-fighter-6-change-throw/>
- <https://ultimateframedata.com/mario>
- <https://ultimateframedata.com/incineroar>
- <https://www.ssbwiki.com/Throw>
- <https://amara.org/subtitles/Dkszke7reRsm/en/1/download/Which%20Dark%20Souls%20Has%20the%20Best%20Parry%20Animation.en.vtt>
- <https://amara.org/subtitles/Dkszke7reRsm/en/1/download/Which%20Dark%20Souls%20Has%20the%20Best%20Parry%20Animation.en.srt>
- <https://www.gamedeveloper.com/design/how-naughty-dog-defined-melee-attacks-and-behaviors-in-i-the-last-of-us-part-ii-i->
- <https://www.gameinformer.com/b/features/archive/2015/01/23/how-uncharted-4-is-taking-game-technology-to-the-next-level.aspx>
- <https://forums.unrealengine.com/t/animations-how-to-plan-and-create-synchronized-animations-for-a-melee-combat-game/13924>
- <https://discussions.unity.com/t/melee-and-animation-sync-attacker-and-victim/81568>
- <https://blog.playstation.com/?p=370399>
- <https://www.gameanim.com/2018/04/20/god-of-war-iii-animation-process>
- <https://www.gdcvault.com/play/1012720/>
- <https://devforum.roblox.com/t/how-to-make-a-grab-move/2435254>
- <https://devforum.roblox.com/t/issues-with-a-grab-skill/3678608>
- <https://devforum.roblox.com/t/network-ownership-stolen-by-player/2809860>
- <https://create.roblox.com/docs/physics/network-ownership>
- <https://create.roblox.com/docs/physics/assemblies>
- <https://devforum.roblox.com/t/syncing-up-animations-between-two-characters-on-all-clients/631262>
- <https://devforum.roblox.com/t/syncing-animations-perfectly-across-the-network/1534896>
- <https://devforum.roblox.com/t/animations-played-at-the-same-time-but-not-synced/2496434>
- <https://create.roblox.com/docs/reference/engine/classes/Animator>
- <https://create.roblox.com/docs/reference/engine/classes/AnimationTrack>
- <https://create.roblox.com/docs/animation/using>
- <https://www.ubisoft.com/en-au/game/for-honor/news-updates/1uyGJ38RqfLbgGnZBHC0wr/patch-notes-2601-for-honor>
- <https://www.ssbwiki.com/Perfect_shield>
- <https://www.ssbwiki.com/Counterattack>
- <https://bethesda.net/en-AU/news/the-guts-and-gore-of-doom-glory-kills>
- <https://gamingbolt.com/sekiro-shadows-die-twice-dev-talks-about-how-combat-differs-from-dark-souls-and-the-challenges-of-developing-it>
- <https://pcgamer.com/doom-hands-on-teaching-old-demons-new-tricks>
- <https://doomwiki.org/wiki/Glory_kill>
- <https://critpoints.net/2017/06/10/the-majesty-of-dark-souls-3s-backstab/>
- <https://twvideo01.ubm-us.net/o1/vault/gdc2019/presentations/Sheth_Mihir_EvolvingCombat.pdf>
- <https://videohighlight.com/v/hE5tWF-Ou2k>
- <https://gdconf.com/news/see-how-god-wars-combat-evolved-match-its-new-camera-system-gdc>
- <https://askagamedev.tumblr.com/search/synced+animation>
- <https://askagamedev.tumblr.com/post/[^>
- <https://dev.epicgames.com/documentation/unreal-engine/API/Plugins/ContextualAnimation/UContextualAnimSelectionCriterio-_2>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/python-api/class/ContextualAnimCriterionConeMode>
- <https://docs.unrealengine.com/PythonAPI/class/ContextualAnimCriterionConeMode.html>
- <https://www.gamedeveloper.com/programming/designing-ai-to-do-anything-a-spider-can-in-i-marvel-s-spider-man-i->
- <https://www.gameanim.com/?p=67957>
- <https://shazoo.ru/2021/05/18/110048/gejmdev-sozdanie-ii-vragov-i-sinhronnyh-animacij-marvels-spider-man>
- <https://podwise.ai/episodes/1458953>
- <https://www.youtube.com/watch?v=LxWq65CZBU8>
- <https://www.youtube.com/youtubei/v1/get_transcript?prettyPrint=false>
- <https://youtubetotranscript.com/transcript?v=LxWq65CZBU8>
- <https://www.youtube.com/api/timedtext?v=LxWq65CZBU8&lang=en>
- <https://www.youtube.com/api/timedtext?v=LxWq65CZBU8&lang=en&kind=asr>
- <https://video.google.com/timedtext?lang=en&v=LxWq65CZBU8>
- <https://www.youtube.com/youtubei/v1/player?prettyPrint=false>
- <https://www.ssbwiki.com/Grab_release>
- <https://www.gameanim.com/?s=glory+kill>

Searches run:

- GDC paired animations synchronized melee attacker victim alignment animation talk
- Unreal Engine motion warping warp target root motion documentation
- Doom Eternal glory kill animation length design interview id Software
- devforum roblox grab system weld victim to attacker animation sync network ownership
- Rock Paper Shotgun Doom glory kills 600-700 milliseconds design momentum
- Unreal Engine Contextual Animation plugin scene asset roles selection criteria distance angle synchronized
- "Unsynced" The Last of Us melee system GDC 2014 slides synced animations
- Batman Arkham freeflow combat GDC animation warping counter takedown
- Sekiro deathblow animation design interview FromSoftware posture deflect window frames
- dustloop throw tech window frames Guilty Gear Strive throw startup 2 frames whiff
- Street Fighter 6 throw startup 5 frames throw tech window throw whiff recovery supercombo
- Capcom SF Seminar column throws throw escape command grab
- "throw tech window" frames "Street Fighter 6" OR "Tekken 8" OR "Strive" whiff animation
- For Honor parry window milliseconds patch notes Ubisoft parry riposte guard break
- Sekiro deflect window frames datamine perfect deflect 0.2 seconds
- Dark Souls parry window frames riposte animation critical attack wiki frame data
- Uncharted 4 melee decoupled animations Drake opponent synced grappling Game Informer
- gamedeveloper.com "synced animations" OR "paired animations" executions takedown animator interview
- For Honor executions animation motion capture two actors interview animator Ubisoft Montreal
- Ryse Son of Rome execution animation system GDC Crytek QTE slow motion camera
- God of War 2018 stun grab finisher animation sync enemy Santa Monica animator GDC talk
- devforum roblox sync two players animations grab desync latency play animation on both clients same time
- devforum roblox carry grab system "CFrame" heartbeat victim follows attacker smooth replication jitter
- For Honor patch notes "parry window" "100ms" OR "parry" "light attacks" reaction design ubisoft.com news-updates
- Sekiro interview Kitao OR Miyazaki deflect sword clash sparks sound "deathblow" design intention
- Doom 2016 GDC "push forward combat" glory kill stagger animation length talk summary
- critpoints paired animations grapples assassin's creed batman arkham dark souls backstab
- askagamedev synced animations paired animation distance orientation flat ground
- "Evolving Combat in God of War" GDC 2019 Mihir Sheth pdf slides
- askagamedev tumblr "synced" animations takedown "common point" flat ground
- Unreal Engine Contextual Animation plugin documentation scene asset roles warp points paired interaction
- UContextualAnimSelectionCriterion_Angle OR "ContextualAnimSelectionCriterion_Distance" unreal API
- Marvel's Spider-Man GDC 2019 AI combat "sync joint" synced animations attack response Insomniac
- Noonchester Spider-Man AI postmortem notes sync joint "each attack" response animation extra joint distance
- youtube GDC "Marvel's Spider-Man" "AI Postmortem" Adam Noonchester

#### abilities-and-casts.md

Abilities, casts, charges and projectiles.

Sources opened:

- <https://leagueoflegends.fandom.com/wiki/Cast_time>
- <https://dota2.fandom.com/wiki/Cast_Animation>
- <https://wiki.leagueoflegends.com/en-us/Cast_time>
- <https://liquipedia.net/dota2/Cast_Animation>
- <https://dota2.fandom.com/api.php?action=parse&page=Cast_Animation&prop=wikitext&format=json>
- <https://liquipedia.net/dota2/api.php?action=parse&page=Cast_Animation&prop=wikitext&format=json>
- <https://web.archive.org/web/2024id_/https://dota2.fandom.com/wiki/Cast_Animation>
- <https://wiki.leagueoflegends.com/en-us/Varus>
- <https://wiki.leagueoflegends.com/en-us/Xerath>
- <https://wiki.leagueoflegends.com/en-us/Lux>
- <https://wiki.leagueoflegends.com/en-us/Karthus>
- <https://www.surrenderat20.net/2014/09/red-post-collection-champion-animation.html>
- <https://nexus.leagueoflegends.com/2017/05/dev-on-animating-xayah/>
- <https://wiki.supercombo.gg/api.php?action=parse&page=Street_Fighter_6/Ryu/Data&prop=wikitext&format=json>
- <https://wiki.supercombo.gg/api.php?action=parse&page=Street_Fighter_6/Ryu&prop=wikitext&format=json>
- <https://wiki.supercombo.gg/w/Street_Fighter_6/Ryu/Data>
- <https://wiki.supercombo.gg/api.php?action=parse&page=Street_Fighter_6/Game_Data&prop=wikitext&format=json>
- <https://glossary.infil.net/?t=Super%20Freeze>
- <https://glossary.infil.net/>
- <https://glossary.infil.net/js/glossary.js>
- <https://glossary.infil.net/json/glossary.json>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC3445080/>
- <https://library.keqingmains.com/combat-mechanics/frames>
- <https://wiki.leagueoflegends.com/en-us/api.php?action=parse&page=Cast_time&prop=wikitext&format=json>
- <https://wiki.leagueoflegends.com/en-us/api.php?action=parse&page=Channeling&prop=wikitext&format=json>
- <https://wiki.leagueoflegends.com/en-us/api.php?action=query&list=search&srsearch=channel%20interrupt&srnamespace=0|4|10&format=json&srlimit=20>
- <https://wiki.leagueoflegends.com/en-us/api.php?action=query&list=allpages&apprefix=Chan&format=json&aplimit=20>
- <https://wiki.leagueoflegends.com/en-us/api.php?action=parse&page=Channel&prop=wikitext&format=json>
- <https://dota2.fandom.com/api.php?action=parse&page=Cast_animation&prop=wikitext&format=json>
- <https://dota2.fandom.com/api.php?action=parse&page=Cast_Animation&prop=wikitext&format=json&redirects=1>
- <https://dota2.fandom.com/api.php?action=cargoquery&tables=abilities&fields=source,title,cast_point,cast_backswing&where=source%20IN%20(%27Lina%27,%27Pudge%27,%27Mirana%27,%27Sniper%27,%27Lion%27,%27Zeus%27,%27Earthshaker%27,%27Windranger%27,%27Crystal%20Maiden%27,%27Enigma%27,%27Shadow%20Fiend%27)&limit=200&format=json>
- <https://dota2.fandom.com/api.php?action=parse&page=Channeling&prop=wikitext&format=json&redirects=1>
- <https://overwatch.fandom.com/api.php?action=parse&page=Ultimate_ability&prop=wikitext&format=json&redirects=1>
- <https://overwatch.fandom.com/api.php?action=parse&page=Ability&prop=wikitext&format=json&redirects=1>
- <https://overwatch.fandom.com/api.php?action=parse&page=Ability/stats&prop=wikitext&format=json&redirects=1>

Searches run:

- League of Legends champion animation cast readability Riot animator interview spell windup
- GDC Overwatch animation talk third person readability abilities ultimate animator
- Genshin Impact elemental burst animation frames invincibility i-frames frame count library
- Street Fighter 6 Ryu Hadoken frame data startup recovery official
- overhand throwing biomechanics phases duration arm cocking acceleration milliseconds stride foot contact ball release percent of pitch
- Roblox DevForum sync VFX with animation keyframe marker projectile spawn release frame
- Overwatch ultimate voice line enemy hears different louder sound design GDC "play by sound"

#### ranged-weapons.md

Guns, bows and thrown weapons.

Sources opened:

- <https://devforum.roblox.com/t/character-arms-follow-camera/1492007>
- <https://devforum.roblox.com/t/how-do-i-make-the-right-arm-point-to-what-the-camera-is-looking-at-on-the-y-axis/2321579>
- <https://devforum.roblox.com/t/how-to-replicate-to-server-side/1517777>
- <https://mein-mmo.de/warum-spielt-sich-destiny-so-gut-die-tricks-entwickler-153/>
- <https://playvalorant.com/en-us/news/dev/how-the-valorant-arsenal-was-built/>
- <https://blog.activision.com/call-of-duty/2019-07/Modern-Warfare-Initial-Intel-Detailing-Advancements-in-Animation-and-Authenticity>
- <https://www.engadget.com/2012-11-08-infinity-ward-animator-talks-first-person-flourishes.html>
- <https://eprints.bournemouth.ac.uk/24308/7/Callaway_Archery_ArchiveCopy.pdf>
- <https://jyx.jyu.fi/bitstream/123456789/50039/1/URN%3aNBN%3afi%3ajyu-201606022817.pdf>
- <https://learn.microsoft.com/en-us/halo-master-chief-collection/h2/art/animation/animationsfpanims>
- <https://www.cryengine.com/docs/static/engines/cryengine-5/categories/23756816/pages/25535363>
- <https://developer.valvesoftware.com/wiki/Blend_sequence>
- <https://www.cryengine.com/docs/static/engines/cryengine-5/categories/23756816/pages/23308006>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/aim-offset-in-unreal-engine>
- <https://dev.epicgames.com/documentation/unreal-engine/creating-an-aim-offset-in-unreal-engine>
- <https://www.ea.com/ea-play/news/ignite-mid-season-patch-notes>
- <https://playvalorant.com/en-gb/news/game-updates/valorant-patch-notes-1-08/>
- <https://pcgamesn.com/insurgency-sandstorm/insurgency-sandstorm-reloading>
- <https://ea_dice.artstation.com/blog/jMao/animating-weapons-for-battlefield-v>
- <https://bestofama.com/amas/12jpl2>
- <https://www.gamesradar.com/call-of-duty-modern-warfare-animation-director-details-the-reboots-slick-gun-animations/>
- <https://devforum.roblox.com/t/{tid}.json>
- <https://devforum.roblox.com/t/{tid}/posts.json?{q>
- <https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent>
- <https://create.roblox.com/docs/scripting/events/remote>
- <https://create.roblox.com/docs/reference/engine/classes/Motor6D>
- <https://create.roblox.com/docs/reference/engine/classes/Motor6D.md>
- <https://www.gdcvault.com/play/1012300/>
- <https://media.gdcvault.com/gdc08/slides/S6169i1.pdf>
- <https://pages.cpsc.ucalgary.ca/~bdstephe/585_W13/d401_animation.pdf>
- <https://www.gameanim.com/2017/04/03/art-destinys-first-person-animation/>
- <https://destiny.bungie.org/n/1421>
- <https://archive.org/details/GDC2015Helsby>
- <https://www.gdcvault.com/play/1017633/Animation-Bootcamp-Giving-Purpose-to>
- <https://www.gamedeveloper.com/art/the-secret-to-apex-legends-gorgeous-first-person-animation-mouth-cameras>
- <https://blog.wolfire.com/2013/04/GDC13-Summary-Animation-Bootcamp-Part-5-6>
- <https://www.gameanim.com/2018/05/24/battlefield-1-weapon-animation-breakdowns/>
- <https://gamerant.com/destiny-smooth-fps-boxing/>
- <https://media.gdcvault.com/GDC2014/Presentations/Duffin_Ryan_Animation_Bootcamp_Using.pdf>
- <http://archive.org/wait/web/2021/https://ea_dice.artstation.com/blog/jMao/animating-weapons-for-battlefield-v>
- <https://web.archive.org/web/2021id_/https://ea_dice.artstation.com/blog/jMao/animating-weapons-for-battlefield-v>

Searches run:

- aim offset animation third person shooter spine distribute pitch yaw GDC
- gamedeveloper.com third person shooter animation aiming upper body blend
- 80.lv first person weapon animation reload breakdown animator tips
- devforum roblox R6 arms follow camera Motor6D C0 replicate
- devforum roblox community resource replicated look direction neck shoulder R6 interpolate other clients unreliable remote
- GDC vault Uncharted animation aiming gun third person Naughty Dog talk
- "first person" weapon animation recoil procedural keyframed GDC talk Titanfall Respawn animator
- Destiny Bungie first person animation interview reload weapon feel animator
- "Helsby" Destiny "first person" animation GDC 2015 camera arms weapon talk notes
- Gears of War animation GDC cover shooter aiming blindfire roadie run animator talk
- Call of Duty Infinity Ward animator interview reload animation weapon first person
- Valorant weapon equip time animation Riot dev blog first person
- procedural recoil animation spring weapon kick recovery article game developer
- devforum roblox tutorial "R6" head and arms follow mouse neck C0 math.asin replicated smooth
- create.roblox.com UnreliableRemoteEvent frequent updates character look direction
- archery shot cycle phases duration draw anchor aiming release follow-through seconds study elite archers
- overhand throwing phases timing milliseconds stride arm cocking acceleration follow-through biomechanics
- bow draw animation game animator article hold release arrow nock Horizon Tomb Raider third person
- Lyra aim offset pitch yaw additive "aim offset" unreal documentation mesh space spine
- "The Division" OR "Uncharted 4" GDC animation aiming cover third person shooter weapon pose layering talk slides pdf
- valve developer community aim_yaw aim_pitch pose parameter weapon aim layer spine blend
- gameanim.com first person weapon animation tips reload recoil Jonathan Cooper
- Max Payne 3 animation aiming system interview Rockstar animator upper body independent legs shootdodge
- "Last of Us" OR "Uncharted" animator interview aiming weapon handling animation "third person" reload weight
- Respawn Apex Legends first person animation interview weapon inspect reload animator 80.lv OR gamedeveloper
- Apex Legends patch notes "tactical reload" "empty reload" time seconds deploy holster time
- Warzone patch notes "sprint to fire" ms "ADS time" ms weapon tuning
- Valorant patch notes "equip time" seconds weapon change
- Insurgency Sandstorm developer blog weapon animation procedural recoil sway
- 80.lv interview first-person animator weapon animations reload timing recoil "animator"
- gamedeveloper.com "reload" animation design shooter readability reload animation beats article
- "third person" shooter animation GDC talk aiming "upper body" "lower body" layering locomotion weapon "pose" Gears 5 OR "Ghost Recon" OR "The Division" OR "Splinter Cell"
- GDC talk third person shooter aiming animation additive aim poses spine distribution
- Unreal Engine Aim Offset documentation additive mesh space aim poses pitch yaw
- devforum.roblox.com R6 arms follow camera mouse replicate Motor6D C0 shoulder neck
- first person weapon animation reload tactical empty animator interview frames timing
- Gears of War animation GDC talk cover shooter aiming blending upper body
- Destiny Bungie GDC animation first person third person weapon animation talk
- Respawn Titanfall Apex Legends first person weapon animation GDC talk animator
- Call of Duty animator interview weapon animation reload inspect first person third person
- EgoMoose "first person element of a first person shooter" devforum tutorial
- devforum replicate head and arm aim to other clients UnreliableRemoteEvent look angle interpolate R6
- Headstackk "How to animate Tool Parts" Guns Knifes devforum Motor6D
- "Travis McIntosh" Uncharted "Animation and Player Control" slides pdf additive aiming
- Naughty Dog GDC talk The Last of Us aiming animation third person gun additive layers upper body
- Polygon Destiny first-person animation GDC 2015 Helsby motion sickness weapon
- Ryan Duffin "first-person animation" GDC Medal of Honor Warfighter talk summary weapon
- "Animating weapons for Battlefield V" DICE enter points reload timing hitting holding strong actions

#### combat-runtime.md

Running combat and movement clips in Roblox.

Sources opened:

- <https://devforum.roblox.com/t/avatar-joint-upgrade-for-physically-simulated-character-movement-is-now-live/4298561>
- <https://devforum.roblox.com/t/avatar-joint-upgrade-aju-phase-2-rollout-updated-migration-recommendations/4656414>
- <https://devforum.roblox.com/t/4739840>
- <https://api.github.com/repos/Roblox/creator-docs/contents/content/en-us/animation>
- <https://github.com/Roblox/creator-docs>
- <https://devforum.roblox.com/t/ik-controls-are-now-out-of-beta/2156480>
- <https://devforum.roblox.com/t/ik-controls-are-now-out-of-beta/2156480?page=5>
- <https://github.com/MaximumADHD/Roblox-Client-Tracker>
- <https://devforum.roblox.com/t/deprecating-loadanimation-on-humanoid-and-animationcontroller/857129>
- <https://devforum.roblox.com/t/tool-error-animation-track-limit-of-256-tracks-for-one-animator-exceeded/2622870>
- <https://devforum.roblox.com/t/animationtrack-limit-exceeded-error-is-unhelpful/4067247>
- <https://devforum.roblox.com/t/animator-reaches-256-tracks-and-no-more-are-played/2052138>
- <https://devforum.roblox.com/t/2422221>
- <https://devforum.roblox.com/t/animation-engine-runtime-changes-and-fixes/1320674>
- <https://devforum.roblox.com/t/animation-priorities-set-in-local-scripts-are-no-longer-being-replicated/3867910>
- <https://devforum.roblox.com/t/replicated-animations-not-ending/3878962>
- <https://devforum.roblox.com/search?q=%22AnimationTrack.Looped%20Does%20Not%20Replicate%22>
- <https://devforum.roblox.com/search.json?q=AnimationTrack.Looped%20Does%20Not%20Replicate>
- <https://devforum.roblox.com/t/{tid}.json>
- <https://devforum.roblox.com/t/{tid}/posts.json?{q>
- <https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us>
- <https://devforum.roblox.com/t/4298561.json>
- <https://devforum.roblox.com/t/4656414.json>
- <https://github.com/MaximumADHD/Roblox-Client-Tracker/tree/roblox/avatar/scripts>
- <https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox>
- <https://github.com/MaximumADHD/Roblox-Client-Tracker/tree/roblox/avatar>
- <https://github.com/MaximumADHD/Roblox-Client-Tracker.git>
- <https://about.roblox.com/newsroom/2026/07/creating-responsive-cheat-resistant-games-roblox-server-authority>
- <https://devforum.roblox.com/[^>

Searches run:

- Roblox animation graphs R6 support devforum
- IKControl R6 character arm LookAt devforum
- "IKControl" studio beta announcement 2022 devforum inverse kinematics R6
- devforum "Deprecating LoadAnimation on Humanoid and AnimationController"
- "AnimationTrack limit of 256 tracks for one animator exceeded"
- roblox animator 256 tracks limit LoadAnimation memory leak staff reply devforum
- roblox release notes 2026 "AnimationTrack" limit warning improved animator
- roblox AnimationTrack.Priority replicate fix announcement devforum priority now replicates
- devforum "AnimationTrack.Looped" does not replicate engine bug
- Roblox server authority animations prediction AnimationTrack rollback devforum announcement
- devforum.roblox.com "Server Authority" beta announcement client prediction rollback Studio

#### acting-and-performance.md

Acting and performance.

Sources opened:

- <https://www.thinkinganimation.com/acting-for-animators-2>
- <https://blog.animschool.edu/category/cliche/>
- <https://ianimate.net/more/articles/mastering-acting-for-animators-tips-and-tricks-from-the-pros>
- <https://content.animationmentor.com/pdfs/TipsAndTricks_Volume1.pdf>
- <https://content.animationmentor.com/pdfs/TipsAndTricks_Volume2.pdf>
- <https://www.awn.com/blog/acting-vs-moving-illustrations>
- <https://renderu.com/en/articles/post/13139>
- <https://www.awn.com/animationworld/watch-ed-hooks-talks-good-and-bad-acting-animation-fmx-2015>
- <https://www.awn.com/print/blog/acting-vs-moving-illustrations>
- <https://80.lv/articles/david-gibson-animating-mei-in-overwatch>
- <https://www.gameanim.com/2017/04/29/first-person-animation-overwatch>
- <https://www.invenglobal.com/articles/1187/how-overwatchs-first-person-animation-breathed-life-into-heroes>
- <https://babel.speldesign.uu.se/?p=113918>
- <https://destructoid.com/a-neat-look-at-what-goes-into-animating-overwatch-highlight-intros>
- <https://futureofstorytelling.org/case-study/glen-keane-revisited-good-true-and-beautiful/>
- <https://www.slashfilm.com/577363/glen-keane-over-the-moon-interview/>
- <https://www.philonfilm.net/2011/01/interview-glen-keane.html?m=1>
- <https://archive.org/metadata/disney-animation-the-illusion-of-life>
- <https://archive.org/download/disney-animation-the-illusion-of-life/Disney%20Animation-The%20Illusion%20of%20Life_djvu.txt>
- <https://archive.org/stream/disney-animation-the-illusion-of-life/Disney%20Animation-The%20Illusion%20of%20Life_djvu.txt>
- <https://archive.org/download/disney-animation-the-illusion-of-life/Disney%20Animation-The%20Illusion%20of%20Life_hocr_searchtext.txt.gz>
- <https://education.siggraph.org/static/HyperGraph/animation/character_animation/principles/ollie_johnston.htm>
- <https://www.frankanollie.com/AnimationNotesFromOllie.html>
- <https://thinkinganimation.com/acting-for-animators>
- <https://eclass.aegean.gr/modules/document/file.php/511154/Theory/ollie_johnston_notes.pdf>
- <http://www.edhooks.com/archives.html>
- <http://web.archive.org/web/2017/http://www.edhooks.com/archives.html>
- <https://www.edhooks.com/>
- <https://edhooks.com/quick-acting-tips/>
- <https://edhooks.com/>
- <https://www.gameanim.com/?p=2897>
- <https://jimhillmedia.com/andreas-deja-shares-the-lessons-he-learned-from-those-animation-masters-disneys-nine-old-men/>
- <https://create.roblox.com/docs/en-us/avatar/emotes/specifications.md>
- <https://www.gdcvault.com/play/1023473/Animation-Bootcamp-Overwatch-How-A>
- <https://www.leagueoflegends.com/en-us/news/dev/ask-riot-let-s-talk-clarity/>
- <https://www.surrenderat20.net/2014/09/red-post-collection-champion-animation.html>
- <https://gamedeveloper.com/art/video-designing-and-animating-the-heroes-of-i-overwatch-i->

Searches run:

- Ed Hooks acting for animators essential acting principles thinking tends to lead to conclusions emotion tends to lead to action
- Shawn Kelly animation tips and tricks acting cliche gestures avoid obvious choice
- Carlos Baena shooting video reference animation article don't copy reference
- Keith Lango animation tips acting subtle "thinking" character essay
- Ed Hooks AWN article acting animation "status" OR "objective" OR "obstacle" animators essay
- Glen Keane interview animate what the character is thinking feeling "thinking" drawing acting
- Overwatch animation GDC talk heroes personality idle emote highlight intro animators
- Team Fortress 2 illustrative rendering paper silhouette read character class from distance Mitchell Francke Eng
- "Illusion of Life" Thomas Johnston full text archive.org "acting" chapter "the thinking character"
- Andreas Deja blog Milt Kahl acting advice "thinking" character pose deja view
- Eric Goldberg interview Genie animation acting gestures caricature advice animators
- Ed Hooks "seven essential acting concepts" animators thinking tends to lead to conclusions
- Ollie Johnston notes to animators "illustrate ideas or thoughts" attitudes list
- Carlos Baena video reference article animators "reference" Pixar how to shoot
- Ed Hooks awn.com article acting animation "status" OR "gesture" OR "empathy"
- edhooks.com essay animators acting "thinking" "emotion" action objective obstacle
- Animation Mentor blog acting tips avoid cliche gestures "acting choices" animators
- Shawn Kelly "Tips and Tricks" animation mentor acting "subtext" "specific" choice cliché
- Andreas Deja blog Milt Kahl acting advice "thinking" character animation
- gameanim.com Jonathan Cooper idle animation personality character game animation
- GDC talk character personality through gameplay animation idles locomotion "personality" animator
- Overwatch animators interview personality idle emote highlight intro victory pose animation readability
- Roblox creator docs emotes requirements animation length loop "emote" guidelines avatar marketplace
- David Gibson Overwatch GDC animation talk idle personality Tracer wide stance gamedeveloper
- League of Legends animator champion personality idle "recall" animation dev blog Riot readability silhouette
- animation "take" comedy timing anticipation hold frames cartoon double take tutorial animator
- Chuck Jones Road Runner coyote fall timing frames "puff" dust disappear interview timing gag
- Eric Goldberg animation comedy timing advice interview gesture "Character Animation Crash Course"

#### game-animation-direction.md

Game animation direction.

Sources opened:

- <https://www.riotgames.com/en/news/dev-clarity-in-league>
- <https://www.gamedeveloper.com/design/the-challenge-of-having-both-responsiveness-and-naturalness-in-game-animation>
- <https://www.gameanim.com/2017/04/29/first-person-animation-overwatch>
- <https://na.leagueoflegends.com/en-us/news/dev/clarity-in-league/>
- <https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/>
- <https://www.gameanim.com/2018/04/20/god-of-war-iii-animation-process>
- <https://www.gamedeveloper.com/programming/common-mistakes-in-game-animation>
- <https://www.gamedeveloper.com/art/more-than-movements-solving-animation-problems>
- <https://game.watch.impress.co.jp/docs/news/1175860.html>
- <https://80.lv/articles/learn-the-anatomy-of-attacks-in-combat-games-with-this-article/>
- <https://www.gameanim.com/?p=18866>
- <https://cgworld.jp/feature/201709-cedec2017-platinum-2.html>
- <https://cgworld.jp/feature/201709-cedec2017-platinum-3.html>
- <https://cgworld.jp/feature/201709-cedec2017-platinum-5.html>
- <https://www.invenglobal.com/articles/1187/how-overwatchs-first-person-animation-breathed-life-into-heroes>
- <https://babel.speldesign.uu.se/?p=113918>
- <https://www.gamedeveloper.com/art/video-designing-and-animating-the-heroes-of-i-overwatch-i->
- <https://www.gdcvault.com/play/1023473/Animation-Bootcamp-Overwatch-How-A>
- <https://www.gamedeveloper.com/production/the-12-principles-of-animation-in-video-games>
- <https://www.linkedin.com/pulse/five-fundamentals-video-game-animation-jonathan-cooper>
- <https://www.gameanim.com/?s=fundamentals>
- <https://repository.upenn.edu/hms/141>
- <https://www.gameanim.com/>
- <https://www.gameanim.com/?p=52801>
- <https://www.jumbla.com/news/game-animation-fundamentals>
- <https://www.youtube.com/watch?v=Q-ZRKHOaAOw>
- <https://youtubetranscript.com/?server_vid2=Q-ZRKHOaAOw>
- <https://www.youtube.com/api/timedtext?v=Q-ZRKHOaAOw&lang=en>
- <https://80.lv/articles/studying-game-animation-principles>
- <https://80.lv/articles/animation-in-games-function-and-automation>
- <https://80.lv/articles/animation-tips-from-industry-experts>
- <https://80.lv/articles/the-work-behind-creating-animation-reels>
- <https://www.gamedeveloper.com/game-platforms/12-principles-for-game-animation>
- <https://www.gamedeveloper.com/art/animation-feature>
- <https://www.gameanim.com/?p=115>
- <https://www.gameanim.com/[^>
- <https://www.gameanim.com/wp-json/wp/v2/categories?per_page=100>

Searches run:

- Jonathan Cooper game anim blog responsiveness weight animation
- GDC animation bootcamp responsiveness vs fidelity character movement talk slides
- Overwatch animation GDC character weight silhouette readability animator talk
- Riot Games animation readability champion silhouette dev blog
- gameanim.com Jonathan Cooper idle pose first frame transitions "game anim" article
- "animation director" game interview most common mistakes junior animators gameplay 80.lv
- God of War 2018 animation director Bruno Velazquez Kratos weight animation interview
- gamedeveloper.com excerpt "Game Anim" Jonathan Cooper book chapter
- For Honor animation GDC talk combat animation readability Ubisoft Montreal animation director
- Insomniac Marvel's Spider-Man animation director interview gameplay animation responsiveness
- Takahisa Taura GDC 2018 NieR Automata combat animation flags cancel tool talk report
- PlatinumGames CEDEC animation action game "アニメーション" キャンセル フラグ 攻撃 予備動作 レポート
- gamedeveloper.com Jonathan Cooper animation article Uncharted "Naughty Dog" game animation
- "animation bootcamp" GDC "first frame" blending gameplay animation pose matching start idle
- Overwatch heroes animation "weight" Tracer Reinhardt animator interview animation style pose to pose
- Normoyle Jörg "Trade-offs between responsiveness and naturalness for player characters" pdf results delay
- Jonathan Cooper gameanim.com blog animation responsiveness vs weight game animation
- GDC animation bootcamp lead animator "animation set" idle starts stops turns transitions talk
- Overwatch animation GDC David Gibson stylized animation readability silhouette gameplay
- "Game Anim" Cooper excerpt "five fundamentals" feel fluidity readability context elegance
- gamedeveloper.com Jonathan Cooper animation article "Naughty Dog" game animation tips readability
- God of War 2018 animation director Bruno Velazquez Kratos weight responsiveness interview animation
- For Honor animation GDC talk heroes weight classes animation readability telegraph Ubisoft Montreal animator
- Riot Games League of Legends champion animation readability blog animator silhouette gameplay camera
- 80.lv lead animator interview gameplay animation "responsiveness" "readability" tips
- gamedeveloper.com gameplay animation lead "animation set" transitions idle "first frame" blend postmortem
- gdcvault animation bootcamp "gameplay animation" lead animator prototype blocking in engine talk overview
- Almudena Soria animation prototyping Uncharted 4 GDC talk summary animators prototype features
- Kristjan Zadziuk motion matching "dance card" For Honor animators GDC 2016 article
- "animation director" interview game "weight" "responsiveness" balance "we cut" anticipation frames player character combat

#### body-types-and-scale.md

Body types, weight and scale.

Sources opened:

- <https://www.ebi.ac.uk/europepmc/webservices/rest/PMC1571302/fullTextXML>
- <https://cob.silverchair.com/jeb/article-pdf/2638526/jexbio_138_1_301.pdf>
- <https://www.sfu.ca/locomotionlab/assets/dynsimwalk1997.pdf>
- <https://jov.arvojournals.org/article.aspx?articleid=2192576>
- <https://pmc.ncbi.nlm.nih.gov/articles/PMC1571302/>
- <https://www.originalwisdom.com/wp-content/uploads/bsk-pdf-manager/2019/10/Heglund-and-Taylor_1988_Speed-and-stride-frequency-and-energy-cost-per-stride-how-do-they-change-with-body-size-and-gait.pdf>
- <https://www.sccs.swarthmore.edu/users/08/bblonder/phys120/docs/biewener.pdf>
- <https://www.nature.com/articles/srep28825>
- <https://art.torvergata.it/handle/2108/19932>
- <https://www.originalwisdom.com/wp-content/uploads/bsk-pdf-manager/2019/03/Ruiz-and-Torices_2013_Humans-running-at-stadiums-and-beaches-and-the-accuracy-of-speed-estimation-from-fossil-trackways.pdf>
- <https://www.biomotionlab.ca/size-and-speed-demo/>
- <https://www.gameanim.com/?p=76076>
- <https://www.vfxvoice.com/weta-digital-gives-weight-to-the-giant-monsters-of-rampage/>
- <https://tamulur.itch.io/big-robots-walking-vr-demo>
- <https://cinematography.net/edited-pages/MiniatureFormula.htm>
- <https://www.marxists.org/archive/haldane/works/1920s/right-size.htm>
- <https://tore-knabe[^>
- <https://www.gameanim.com/downloads/5_Rules_of_Giant_Character_Animation.pdf>
- <https://tore-knabe.com/game-development-how-much-to-slow-animation-down-for-giant-creatures/>

Searches run:

- Jokisch Troje 2003 "Biological motion as a cue for the perception of size" Journal of Vision
- Alexander "Bipedal animals, and their differences from humans" Journal of Anatomy Froude number dynamic similarity
- Heglund Taylor 1988 "Speed, stride frequency and energy cost per stride" body size Journal of Experimental Biology
- Kram Domingo Ferris 1997 reduced gravity preferred walk-run transition speed Froude number
- preferred walking speed Froude number 0.25 humans animals leg length
- Alexander 1976 Nature estimates of speeds of dinosaurs relative stride length 2.3 Froude 0.3 formula
- Vaughan Langerak O'Malley neuromaturation of human locomotion non-dimensional scaling children Froude
- Biewener "Biomechanical consequences of scaling" Journal of Experimental Biology 2005 limb posture effective mechanical advantage
- Jokisch Troje "perception of size" gait frequency pendulum "stride frequency" observers walker size estimate jov.arvojournals.org
- miniature effects frame rate square root of scale shooting speed model "square root" overcrank
- animating giants game animation scale weight slower timing GDC talk
- Haldane "On Being the Right Size" full text giant thigh bones mouse mine shaft
- Hamilton Joyce Flanagan Frith Wolpert 2007 "Kinematic cues in perceptual weight judgement and their origins in box lifting"
- Runeson Frykholm visual perception of lifted weight kinematic specification of dynamics box lifting observers
- Ko Stenholm Ferrucci characteristic gait patterns in older adults with obesity Baltimore Longitudinal Study of Aging step width

## Plan to finish (decided with the user on 2026-10-13)

Quality bar for every agent: R6 animation that a senior Roblox animator with 20 years of experience would be proud of. It reads as a human body on 6 rigid parts and looks good (appeal, clear poses, rhythm), not only realistic. Acclaimed TV anime such as Frieren is the reference for taste and timing, never something to copy. Every finding states whether it survives on 6 rigid parts and which R6 substitute reads the same; findings that cannot read on R6 are dropped. Roblox and R6 sources come first.

Decisions:

- Real-life data stays as the target for timing, weight and balance, always translated through the R6 rig, never copied raw.
- Anime timing sense (sharp contrast between holds and fast motion) goes inside smooth 60 fps playback; full stepped timing only where it suits, such as emotes and finishers. The anime-craft research tests this instead of assuming it.
- Much of what makes TV anime beautiful (faces, hair, cloth, drawing, camera work) cannot move to R6. Each file separates what transfers from what does not.
- The strongest R6 evidence is measuring professional R6 clips. When the user has Roblox Studio open, add a run that decodes and measures the best professional R6 animation packs with the skill's tools.

How to run: one Workflow per run, every agent at max effort, sized to finish inside one 5-hour usage window (the container runs 2 agents at a time). No background work outlives a run, and nothing is scheduled. Each topic: a research agent writes a draft in `projects/drafts/` and pushes it; an independent checker re-reads every source, checks the R6 translations and Poser fields, moves the file to `references/` and pushes it. Each run ends with integration (`sources.md`, `SKILL.md`, README, CHANGELOG), a critic pass and a fix pass.

Runs:

1. `r6-craft.md` (new), `anime-craft.md` (new), `human-motion-data.md`, `polish-and-critique.md`. Started 2026-10-13. Done 2026-10-14: all four files checked, moved to `references/` and integrated (`sources.md`, `SKILL.md`, README, CHANGELOG); the lead lists for `human-motion-data.md` and `polish-and-critique.md` are removed.
2. `acting-and-performance.md`, `human-micro-motion.md`, `body-types-and-scale.md`, `game-animation-direction.md`. Script: `research-workflow-run2.js`, scheduled for 2026-10-14 07:26 UTC.
3. `procedural-layers.md`, `dodges-and-dashes.md` and `traversal.md` (check the saved raw findings above, then write), `aerial-combat.md`.
4. `knockdowns-and-deaths.md`, `grabs-throws-and-finishers.md`, `abilities-and-casts.md`.
5. `ranged-weapons.md`, `combat-runtime.md`, and the Studio measurement run when available.

Use the run 1 script, `research-workflow-run1.js`, as the template for later runs. The prompts for the older topics are in `research-prompts.md`; add the quality bar above to each before reuse. `research-workflow.js` is the stopped all-in-one script.

## Notes for the next run (observed 2026-10-12)

- 2026-10-14 (user rule): start each run 5 to 8 minutes before the current 5-hour usage window resets. The run crosses only that one reset and must finish before the next reset, so it opens only one new window. Read the reset time from `rate_limit_info.resetsAt` in the get_session result before starting.

- 2026-10-13: the whole pass was started as one Workflow at max effort (`research-workflow.js`) and stopped by the user after about 8 minutes because of usage; no file was written. Its estimate: 33 agents (15 drafts, 15 checks, integration, critic, fix), 2 at a time, likely over 10 million tokens of agent work at max effort, roughly 8 to 14 hours. Before rerunning, agree the scope and effort with the user (for example fewer topics, or normal effort).

- The container had 4 CPUs, so a Workflow ran only 2 agents at a time. Separate background agents ran all 15 at once.
- Every background agent wakes the main session when it finishes, and each wake-up is a new request carrying the whole conversation. A Workflow wakes it once. Start the next pass from a new, short session so each wake-up stays small.
- The agents reported that YouTube transcripts were blocked and that web.archive.org dropped connections through the proxy. Europe PMC's REST API worked through curl for open-access papers, and the creator-docs YAML files on GitHub worked for Roblox engine facts.
