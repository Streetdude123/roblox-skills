# Research prompts (2026-10-12)

The exact prompts of the stopped max-effort research pass, one per target file in `references/`. The skill does not load this file. To resume, launch one agent per prompt at max effort (the user asked for max effort on every subagent). Replace the scratchpad path `/tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/` with the new session's scratchpad first. The two checker prompts read the raw findings in `research-in-progress.md` by line number and by section heading.

## dodges-and-dashes.md

Dodges, rolls, dashes and evasion. Kind: check the saved raw findings, then write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

YOUR JOB: independent checker, then writer. The file projects/research-in-progress.md, section "## Dodges, rolls, dashes and evasion" (from line 256 to the "## Plan for the rest of the pass" heading), holds about 35 raw findings another researcher extracted. None has been checked. Load the web tools with ToolSearch query "select:WebSearch,WebFetch"; if WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured). For each distinct source URL, fetch it yourself (if it fails, try an archive.org copy, the creator-docs GitHub source, or the same article at another URL of the same publisher) and judge each finding ONLY against what its source says: supported; partly (the core is there but something is overstated, a number differs or the attribution is wrong; write the corrected claim exactly as the source supports it); unsupported; unreachable. Be strict: when unsure, unsupported. Never rescue a claim from your own knowledge. Also judge each draft "On R6" translation against the R6 rules and fix it.

Then write references/dodges-and-dashes.md (title "Dodges, rolls, dashes and evasion") from supported and corrected findings only, in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "Dodges, rolls, dashes and evasion research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules in references/combat.md, references/locomotion.md, references/body-mechanics.md or references/principles.md; point to them by file and section. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing the sub-topics the researcher listed as not found plus any topic left empty after checking.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/dodges-and-dashes.md.sources.md containing "## Dodges, rolls, dashes and evasion research", then "Checked N findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [dodges-and-dashes.md](dodges-and-dashes.md). The sources below were read as text; no video stream was opened." (N = all findings judged), then a table "| Source | Supports |" with one row per source used.

Edit no other files (do not edit research-in-progress.md). Final answer, under 200 words: verdict counts (supported, partly, unsupported, unreachable), file sections, sources used.
```

## traversal.md

Traversal: climb, mantle, vault, slide, wall run, swim. Kind: check the saved raw findings, then write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

YOUR JOB: independent checker, then writer. The file projects/research-in-progress.md, section "## Traversal: climb, mantle, vault, slide, wall run, swim" (from line 5 to the "## Dodges, rolls, dashes and evasion" heading), holds about 35 raw findings another researcher extracted. None has been checked. Load the web tools with ToolSearch query "select:WebSearch,WebFetch"; if WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured). For each distinct source URL, fetch it yourself (if it fails, try an archive.org copy, the creator-docs GitHub source, or the same file at another URL of the same publisher) and judge each finding ONLY against what its source says: supported; partly (the core is there but something is overstated, a number differs or the attribution is wrong; write the corrected claim exactly as the source supports it); unsupported; unreachable. Be strict: when unsure, unsupported. Never rescue a claim from your own knowledge. Also judge each draft "On R6" translation against the R6 rules and fix it; mark anything the researcher labelled "our inference" as inference in the file.

Then write references/traversal.md (title "Traversal: climb, mantle, vault, slide, wall run, swim") from supported and corrected findings only, in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "Traversal research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules in references/locomotion.md, references/body-mechanics.md, references/custom-rigs.md or references/principles.md; point to them by file and section. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing the sub-topics the researcher listed as not found plus any topic left empty after checking.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/traversal.md.sources.md containing "## Traversal research", then "Checked N findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [traversal.md](traversal.md). The sources below were read as text; no video stream was opened." (N = all findings judged), then a table "| Source | Supports |" with one row per source used.

Edit no other files (do not edit research-in-progress.md). Final answer, under 200 words: verdict counts (supported, partly, unsupported, unreachable), file sections, sources used.
```

## human-motion-data.md

Human motion data: gait, running, strikes and jumps. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML; Europe PMC's REST API (https://www.ebi.ac.uk/europepmc/webservices/rest/) serves open-access full texts of papers. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: papers and biomechanics datasets (PubMed Central and Europe PMC open-access papers, journal pages, university course notes), GDC talks/slides, studio blogs, gamedeveloper.com, 80.lv, Animation Mentor, iAnimate, animators' own blogs, Roblox creator docs, DevForum posts by experienced developers. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the study/game/studio when a number belongs to it.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation (joint, degrees, studs, frames at 60 fps). Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/human-motion-data.md
Title: Human motion data: gait, running, strikes and jumps
Existing files not to repeat: references/body-mechanics.md, references/locomotion.md, references/combat.md, references/principles.md, references/r6-mechanics.md
Focus: measured human joint kinematics that an animator can copy as numbers. Walking gait: hip flexion/extension range and timing over the cycle, knee and ankle (to know what R6 must fake), pelvis rotation, tilt and obliquity, trunk rotation counter to the pelvis, shoulder (arm) swing range and its phase against the legs, vertical and lateral COM excursion, stance/swing percentages, head stability. Running: the same plus flight phase, ground contact time by speed, trunk lean, arm swing range, step frequency by speed. Starts and stops: acceleration lean, first steps. The kinetic chain in punches, throws and kicks: the order and timing (ms) of peak angular velocities of pelvis, trunk, upper arm and forearm/hand or thigh/shank, peak fist/foot speeds, step and weight transfer timing (boxing punch kinematics papers, baseball pitching kinetic chain such as ASMI/Fleisig, soccer kick and martial arts kick studies). Jumps: countermovement depth and timing, takeoff duration, landing absorption time and depth. Turning and pivoting. Translate each number to R6: the Shoulder joint is the whole arm and the Hip joint the whole leg, so elbow and knee contributions must be folded into limb rotation plus the short translation the skill already uses to suggest a bend. Aim for 30 to 45 findings.
```

## human-micro-motion.md

Life in still poses: sway, breath, gaze and fidgets. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML; Europe PMC's REST API (https://www.ebi.ac.uk/europepmc/webservices/rest/) serves open-access full texts of papers. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: papers (PubMed Central and Europe PMC open-access papers, journal pages), GDC talks/slides, studio blogs, gamedeveloper.com, 80.lv, Animation Mentor, iAnimate, animators' own blogs, Roblox creator docs, DevForum posts by experienced developers. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the study/game/studio when a number belongs to it.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation (joint, degrees, studs, seconds, frames at 60 fps). Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one; for example life, springs, lag, curve, warp) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/human-micro-motion.md
Title: Life in still poses: sway, breath, gaze and fidgets
Existing files not to repeat: references/locomotion.md ("Idles and breathing"), references/principles.md (idle recipe, moving holds), references/body-mechanics.md, references/lesson-videos.md, references/stylized-and-roblox.md
Focus: the measured micro-motion that makes real people never still. Quiet standing postural sway: centre-of-pressure amplitude and frequency, anterior-posterior versus medial-lateral, effects of stance width, fatigue and attention. Weight shifts during prolonged standing: how often, how large, how long they take. Breathing: rate at rest and after exertion, recovery time, chest/shoulder/abdomen displacement, inhale/exhale time ratio. Head and gaze: head-eye coordination (eyes lead, head latency, share of a gaze shift done by the head, head turn speeds and durations by amplitude), blink rate and duration, saccade timing. Fidgets and self-touching frequency. How game and film animators build idles and moving holds that feel alive (Naughty Dog, Ubisoft, Rockstar, Animation Mentor, idle break and idle variation practice: frequency of idle breaks, randomisation, avoiding visible loops). What motion capture contains that keyframed animation lacks (micro variation, asymmetry, no exact repeats) and how animators add it back. Translate every number into R6 life-layer amplitudes (degrees on torso, head, arms; studs on RootJoint), periods and frame counts. Aim for 30 to 45 findings.
```

## polish-and-critique.md

Polish and critique: what separates professional motion. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: animators' own blogs and articles (Animation Mentor blog, iAnimate, Keith Lango, Jason Ryan, Kenny Roy, Victor Navone, Sir Wade Neistadt, Jonathan Cooper's Game Anim site), GDC talks/slides, studio blogs, gamedeveloper.com, 80.lv, Cartoon Brew, AnimSchool, Roblox DevForum posts by experienced animators. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the person/studio when a rule belongs to them.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation (joint, degrees, frames at 60 fps, which Poser field). Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/polish-and-critique.md
Title: Polish and critique: what separates professional motion
Existing files not to repeat: references/keyframe-workflow.md, references/principles.md, references/lesson-videos.md, references/quality-review.md, references/motion-metrics.md
Focus: concrete polish techniques and the notes leads give in dailies, from professional feature-film and game animators. Spacing charts and favouring; breaking up even timing ("texture" in timing); overlap offsets in frames per joint down a chain; settles (how many bounces, how fast they decay); fixing floaty motion; contact, weight and impact cues; curve-editor practice (tangent types per situation, cleaning curves, avoiding flat tangents everywhere, overshoot via tangents); tracking arcs on hands, feet, head and nose; twinning; silhouette and line of action checks; holds and moving holds durations; "favour" keys and the breakdown that sells the arc; anticipation sizing; how to watch your own animation critically (flip, mute, loop, frame-by-frame, watch at speed, fresh eyes); common notes students receive and how they are fixed; game-specific polish (responsiveness versus weight, blending into and out of clips, loops without visible seams). Numbers wherever sources give them. Aim for 30 to 45 findings.
```

## procedural-layers.md

Procedural layers that make few keys look rich. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: GDC Vault pages and slides, the speakers' own blogs and code (Daniel Holden theorangeduck.com, Ryan Juckett, Wolfire blog), papers, studio tech blogs, gamedeveloper.com, Roblox creator docs (create.roblox.com and github.com/Roblox/creator-docs YAML), DevForum posts by experienced developers. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with formulas, constants and numbers where given, naming the game/studio/person.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one; Poser already has springs, lag, life, warp, post, Feet.flat) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Where a technique needs new runtime code, say so plainly instead of pretending Poser has it. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/procedural-layers.md
Title: Procedural layers that make few keys look rich
Existing files not to repeat: references/stylized-and-roblox.md, references/pipeline.md, references/principles.md ("Procedural motion"), references/custom-rigs.md, references/combat.md, references/locomotion.md
Focus: David Rosen's GDC 2014 "Animation Bootcamp: An Indie Approach to Procedural Animation" (Overgrowth: very few key poses, physics-driven interpolation, springs, procedural run and jump); inertialization (David Bollo, GDC 2016/2018, Gears of War) and how it replaces cross-fades; motion matching core ideas (Simon Clavet, GDC 2016) that help choose or blend clips; critically damped springs and spring-damper math for secondary motion (Daniel Holden "Spring-It-On", Ryan Juckett damped springs), half-life parameterisation; procedural lean from acceleration and turn rate; procedural look-at with limits, lag and the eye/head/torso split; foot IK and pelvis lowering; additive layers (breathing, recoil, hit flinch) and their weights; stride warping and orientation warping; root motion versus in-place; blending pitfalls (foot sliding, pops, pose averaging collapse) and fixes; physics-based secondary on capes and hair; Roblox runtime facts that bound all of this (Motor6D.Transform written in PreSimulation, IKControl types and properties, AnimationTrack weights). Give formulas and constants where sources give them. Aim for 30 to 45 findings.
```

## aerial-combat.md

Aerial combat: launchers, air combos and slams. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: frame-data wikis (ultimateframedata.com, ssbwiki.com, dustloop.com, supercombo.gg), GDC talks/slides, studio blogs and interviews, gamedeveloper.com, 80.lv, Roblox creator docs, DevForum posts by experienced developers. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the game/studio when a number belongs to it.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/aerial-combat.md
Title: Aerial combat: launchers, air combos and slams
Existing files not to repeat: references/combat.md, references/body-mechanics.md (flips, jumps, falls), references/principles.md, references/weapons.md
Focus: launchers (uppercuts and launch attacks), juggles, air combos, air strings and air recovery, ground bounce and wall bounce, plunging attacks, ground slams and dive kicks, air dash, hang time or float during air combos (gravity scaling in Devil May Cry, Bayonetta, fighting games, Roblox battlegrounds games), landing lag and landing recovery frames, how the attacker stays airborne (momentum, small hops), the COM and rotation physics of airborne strikes, readability of aerial attacks from a third-person camera, frame data for aerial attacks (Smash aerials: startup, active frames, landing lag; anime fighters' air normals). Aim for 25 to 35 findings.
```

## knockdowns-and-deaths.md

Knockback, knockdown, get-up, stun and death. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: GDC talks/slides, studio blogs and interviews, gamedeveloper.com, 80.lv, frame-data wikis (ssbwiki.com, dustloop.com, supercombo.gg, fextralife only when it cites data), papers on physics-based characters, Roblox creator docs (create.roblox.com and github.com/Roblox/creator-docs YAML), DevForum posts by experienced developers. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the game/studio when a number belongs to it.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/knockdowns-and-deaths.md
Title: Knockback, knockdown, get-up, stun and death
Existing files not to repeat: references/combat.md (The victim on contact), references/principles.md (Hit reactions), references/body-mechanics.md, references/custom-rigs.md (get-up from a ragdoll)
Focus: knockback and launch reactions by strength, knockdown and the fall onto the ground (hard versus soft knockdown, tech or quick rise), get-up animations, their frame counts and invulnerability, wake-up options, stagger and stun states (dizzy loops), guard break, block stun and posture break (Sekiro, For Honor, fighting games), wall splat, death animations (directional deaths, ragdoll hand-off, blending from animation to physics, powered ragdoll, Euphoria/NaturalMotion style active ragdolls), hit reaction directions (front, back, left, right, high, low) and how many a game needs, additive hit reactions, Roblox specifics: ragdoll on R6 (BallSocketConstraints replacing Motor6Ds, the Physics humanoid state, BreakJointsOnDeath), getting up from a ragdoll back into animation, network ownership effects on knockback. Aim for 25 to 35 findings.
```

## grabs-throws-and-finishers.md

Grabs, throws, counters and finishers. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: GDC talks/slides, studio blogs and interviews, gamedeveloper.com, 80.lv, frame-data wikis (dustloop.com, supercombo.gg, ssbwiki.com), Roblox creator docs, DevForum posts by experienced developers. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the game/studio when a number belongs to it.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/grabs-throws-and-finishers.md
Title: Grabs, throws, counters and finishers
Existing files not to repeat: references/combat.md, references/principles.md (Guard, block and parry), references/weapons.md, references/stylized-and-roblox.md
Focus: command grabs and throws (startup, whiff recovery, throw tech windows), paired or synced animations between two characters (attacker and victim aligned to a shared origin, how studios author and align them, distance and angle checks before a synced animation plays, warping into alignment), finishers, executions and takedowns (God of War, Doom Eternal glory kills, Sekiro deathblows, Assassin's Creed, The Last of Us), parry and counter-attack sequences (parry timing windows, riposte), cinematic finishers with camera, keeping both characters' contacts matched, Roblox specifics: welding or anchoring the victim to the attacker during a grab, playing two clips in sync on two Animators, network ownership and latency when two players' animations must line up (DevForum discussions). Aim for 25 to 35 findings.
```

## abilities-and-casts.md

Abilities, casts, charges and projectiles. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: official game wikis with data (League of Legends wiki cast times, Dota 2 wiki cast point and backswing), GDC talks/slides (Overwatch, League, Genshin animation talks), studio blogs and interviews, gamedeveloper.com, 80.lv, Roblox creator docs, DevForum posts by experienced developers. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the game/studio when a number belongs to it.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/abilities-and-casts.md
Title: Abilities, casts, charges and projectiles
Existing files not to repeat: references/combat.md, references/stylized-and-roblox.md, references/principles.md, references/weapons.md
Focus: ability and spell cast animations: cast time and wind-up, charge-up loops (hold-to-charge, charge levels and how the pose escalates), channelled abilities (looping hold poses with life), release and recoil after a cast, projectile throws (a fireball, a grenade, a punch that fires a wave), beam firing poses (two-hand beams, sustained beam recoil), summoning, transformation and power-up sequences, ultimate moves and their cinematic timing, cast-time numbers from MOBAs and action RPGs (League of Legends cast times, Dota cast point and backswing, Overwatch ability timings, Genshin Impact), anime fighting games and Roblox battlegrounds games for move timing, how animation telegraphs an ability so opponents can react, and how animation syncs with VFX through markers or events. Aim for 25 to 35 findings.
```

## ranged-weapons.md

Guns, bows and thrown weapons. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: GDC talks/slides (Naughty Dog, Gears of War, Destiny, Call of Duty, Respawn), studio blogs and interviews, gamedeveloper.com, 80.lv, animators' blogs, Roblox creator docs, DevForum posts by experienced developers (R6 gun systems, pointing arms at the camera). A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the game/studio when a number belongs to it.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md, scripts/Poser.lua and scripts/WeaponRig.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md, references/r6-mechanics.md and references/weapons.md. Do not repeat rules already in the existing files named below; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/ranged-weapons.md
Title: Guns, bows and thrown weapons
Existing files not to repeat: references/weapons.md, references/combat.md, references/principles.md, references/locomotion.md
Focus: third-person shooter animation: aim poses and aim offsets (the upper body follows camera pitch and yaw, how the spine shares the rotation), hip fire versus aim-down-sights stance, recoil animation (procedural versus keyed recoil, kick and recovery frames, per-weapon strength), reload animations (timing, the beat structure of a reload, empty versus tactical reload), equip, draw and holster timing, sprinting with a weapon, bow draw, hold and release and arrow nocking, throwing grenades and knives, how R6 games point the arms and head at the camera (Motor6D C0 or Transform on the shoulders and neck, replication of aim), studio talks and articles on shooter animation (Naughty Dog, Gears of War, Destiny, Call of Duty first and third person). Aim for 25 to 35 findings.
```

## combat-runtime.md

Running combat and movement clips in Roblox. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: Roblox creator docs (create.roblox.com) and their YAML sources on github.com/Roblox/creator-docs, Roblox DevForum announcements and posts by Roblox staff and experienced developers, the default Animate script as tracked in github.com/MaximumADHD/Roblox-Client-Tracker. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given. Note the date of each announcement.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules already in the existing files named below (references/stylized-and-roblox.md already covers fades, priorities, weights, markers, easing traps, LOD and masks; read it carefully and add only what is new); point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/<file>.sources.md containing "## <Title> research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (markdown link, then what it supports in one sentence).

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts with existing rules.

YOUR TOPIC
File: references/combat-runtime.md
Title: Running combat and movement clips in Roblox
Existing files not to repeat: references/stylized-and-roblox.md, references/pipeline.md, references/combat.md, references/locomotion.md
Focus: how combat and movement animation is played in Roblox games: upper-body attacks while walking on R6 (keying only the arm and torso joints, priorities, weights), AnimationTrack:AdjustSpeed and AdjustWeight behaviour, client versus server playback and replication (who plays the attacker's animation, replication delay, hit detection timing against animation, animations loaded on the client replicating to others), preloading animations (ContentProvider:PreloadAsync) and first-play hitches, limits on tracks per Animator, Animator:LoadAnimation versus deprecated Humanoid:LoadAnimation, track stacking and cleanup bugs, overriding or disabling the default Animate script during combat, any newer Roblox animation features announced 2023-2026 (animation graph or state machine features, IKControl and its types, AnimationConstraint, R6 IK support, root motion, animation compression or sampling changes), IKControl for planting feet and aiming on R6, and the facts about Motor6D.Transform that procedural layers rely on. Aim for 25 to 35 findings.
```

## acting-and-performance.md

Acting and performance. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; no face rig by default; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: interviews and articles by veteran animators and supervisors (Disney, Pixar, DreamWorks, Sony, Laika veterans: Glen Keane, Andreas Deja, Eric Goldberg, Frank Thomas and Ollie Johnston quotes in primary texts, Ed Hooks "Acting for Animators" articles, Animation World Network, Cartoon Brew, Animation Mentor blog, iAnimate, Spline Doctors, Keith Lango, Shawn Kelly's "Tips and Tricks"), GDC talks on character performance in games, 80.lv, gamedeveloper.com. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, naming the person.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation (pose, timing in frames at 60 fps, which joint leads, which Poser field). Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. R6 has no face by default, so translate facial acting into head, torso and hand acting. Do not repeat rules in references/keyframe-workflow.md ("Acting"), references/lesson-videos.md, references/principles.md ("Emote or acting") or references/stylized-and-roblox.md; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered".

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/acting-and-performance.md.sources.md containing "## Acting and performance research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source.

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts.

YOUR TOPIC
File: references/acting-and-performance.md
Title: Acting and performance
Focus: what senior character animators know about performance: thinking characters (the thought precedes the action, how many frames ahead), subtext and intention, choosing the less obvious acting choice, gesture vocabulary and avoiding cliché gestures, specificity of character (age, weight, status, mood shown through posture and rhythm), status and power in posture, eye and head direction as the first readable signal of thought, hands and their acting, rhythm and pauses in a performance, contrast between stillness and action, physical comedy timing, how a performance reads in silhouette and from far away, staging a performance for the camera, reference shooting and how veterans use reference without copying it, performance in games (short loops, idles with personality, emotes, victory poses, taunts; how character is carried by locomotion), notes veterans give juniors about acting. Aim for 30 to 40 findings.
```

## game-animation-direction.md

Game animation direction. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale; clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: GDC talks and Vault pages and slides by lead and director-level game animators (Naughty Dog, Santa Monica Studio God of War, Insomniac Spider-Man, Ubisoft Assassin's Creed and For Honor, Blizzard Overwatch, Riot, FromSoftware interviews, Nintendo interviews, Respawn, Bungie), Jonathan Cooper's Game Anim book site and blog, gamedeveloper.com postmortems, 80.lv interviews, animators' own blogs. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers where given, naming the game/studio/person.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation. Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules in references/combat.md, references/locomotion.md, references/keyframe-workflow.md, references/stylized-and-roblox.md or references/principles.md; point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered".

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/game-animation-direction.md.sources.md containing "## Game animation direction research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source.

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts.

YOUR TOPIC
File: references/game-animation-direction.md
Title: Game animation direction
Focus: the judgment senior and lead game animators apply beyond single clips: the responsiveness versus weight trade-off and how leads settle it per action, designing an animation set for a character (which clips, how many, transitions, idle-to-move, turn and stop sets), consistency of style and weight across a whole set, defining a character's "weight class" and keeping it in every clip, readability rules for gameplay (silhouette from the gameplay camera, telegraph hierarchy, colour-blind and distance readability through pose), first-frame and last-frame rules for blending, how animation, design and VFX/audio agree on event timings, prototyping with blocking in engine first, how leads review animation in game rather than in the viewport, iteration and polish priorities under deadlines (what to polish first), the most common mistakes leads see from mid-level animators, and how animation direction differs between stylised (Overwatch, Fortnite, Genshin) and realistic (The Last of Us, God of War) projects. Aim for 30 to 40 findings.
```

## body-types-and-scale.md

Body types, weight and scale. Kind: research and write.

```text
AUTHORIZATION: The user explicitly asked for deep, extensive animation research with as many subagents as needed, every subagent at maximum effort, so the skill reaches the judgment of a senior animator with 20+ years of experience. Do your task fully and thoroughly; do not skip or shrink it to save usage.

You are improving the agent skill roblox-r6-animation in /home/user/roblox-skills/roblox-r6-animation. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; parts cannot scale (but whole characters can be built at different sizes, and creature rigs exist, see references/custom-rigs.md); clips are authored at 60 fps.

Research rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured) and strip the HTML; Europe PMC's REST API (https://www.ebi.ac.uk/europepmc/webservices/rest/) serves open-access full texts of papers. Every finding must come from a page you fetched in this session; never write a finding from memory. Prefer primary sources: biomechanics and allometry papers (Froude number and dynamic similarity, R. McNeill Alexander's work, gait of children and the elderly, obesity gait, load carriage), animators' articles on weight and character types (Animation Mentor, iAnimate, Animator Island, Keith Lango), GDC talks on animating giants, small creatures and heavy characters, studio blogs, gamedeveloper.com, 80.lv, Roblox DevForum posts by experienced animators. A video counts only if you read its transcript or description text. State each claim exactly as strong as its source, with numbers and formulas where given, naming the study/game/person.

Writing rules: write the new file in the format of references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "<Title> research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation (timing in frames at 60 fps, speeds in studs/s, pose changes, which Poser field). Translations may use only Poser fields and helpers that exist in references/pipeline.md and scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and references/r6-mechanics.md. Do not repeat rules in references/body-mechanics.md, references/locomotion.md, references/principles.md ("Weight and support"), references/custom-rigs.md or references/weapons.md ("Weight"); point to them by file and section. If a finding contradicts an existing rule, keep both, say when each applies, and report it. Plain short sentences, active voice, no filler, no emoji. Any Luau has no comments. End with "## Not covered".

Also write /tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad/anim-sources/body-types-and-scale.md.sources.md containing "## Body types, weight and scale research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source.

Edit no other files. Final answer, under 250 words: file written, section list, finding count, source count, not-covered list, conflicts.

YOUR TOPIC
File: references/body-types-and-scale.md
Title: Body types, weight and scale
Focus: how mass, size, age, strength and fatigue change motion, so every character gets its own timing and posture. Dynamic similarity and the Froude number (preferred walking speed and the walk-run transition as functions of leg length; how stride frequency scales with size), how timing must scale for giants and for small creatures (time scaling with the square root of size), heavy versus light characters (contact time, sink on landing, recovery length, momentum on stops and turns, arm swing), gait and posture of children, elderly people and overweight people, load carriage (posture and gait changes with a heavy load), fatigue and injury in gait (limp patterns, the timing asymmetry), strength versus effort cues (how a strong character lifts something easily versus a weak one), and how animators keep a consistent weight class across a whole clip set. Aim for 30 to 40 findings.
```
