export const meta = {
  name: 'r6-animation-research-finish',
  description: 'Finish the R6 animation research at max effort: 13 research topics and 2 saved-finding checks, an independent source check per file, integration, critic and fixes, pushing progress per topic',
  phases: [
    { title: 'Research', detail: 'one draft per topic (research, or check saved findings then write)' },
    { title: 'Check', detail: 'independent re-read of every source behind each draft' },
    { title: 'Integrate', detail: 'sources.md, SKILL.md, README, CHANGELOG, project notes' },
    { title: 'Critic', detail: 'links, contents, contradictions, invented API, R6 limits' },
    { title: 'Fix', detail: 'fix what the critic found' },
  ],
}

const ROOT = '/home/user/roblox-skills'
const SK = ROOT + '/roblox-r6-animation'
const DR = SK + '/projects/drafts'
const SCR = '/tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad'
const BRANCH = 'claude/animation-vfx-research'
const BASE = '3625af6'

const AUTH = `AUTHORIZATION: The user started this workflow themselves ("Start the workflow, lets get started") after asking for maximum effort on every agent and the best possible quality, so the skill reaches the judgment of a senior animator with 20+ years of experience. Usage is handled by running everything inside this one workflow; earlier messages about usage were about how agents are launched and do not ask you to do less. Do your task fully and thoroughly.`

const SKILL = `You are improving the agent skill roblox-r6-animation in ${SK}. It authors Roblox R6 character animation in code with a Luau runtime called Poser at a professional hand-keyed standard. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; no face rig by default; parts cannot scale; clips are authored at 60 fps.`

const WEB = `Web rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured), save it under your own new folder in ${SCR}/ (never inside the repo), and read only the relevant passages (grep with context), not whole pages. Europe PMC's REST API (https://www.ebi.ac.uk/europepmc/webservices/rest/) serves open-access full texts of papers; Roblox engine facts are in the creator-docs YAML files at https://github.com/Roblox/creator-docs. YouTube transcripts and web.archive.org were unreachable through this proxy in an earlier run. A video counts only if you read its transcript or description text. Every finding must come from a page you fetched in this run; never write a finding from memory. State each claim exactly as strong as its source, with numbers where given, naming the study, game, studio or person when a number or rule belongs to it.`

const FORMAT = (title) => `Format: follow ${SK}/references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "${title} research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation (joint, degrees, studs, frames at 60 fps, which Poser field). Translations may use only Poser fields and helpers that exist in ${SK}/references/pipeline.md and ${SK}/scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and ${SK}/references/r6-mechanics.md; where a technique needs new runtime code, say so plainly. Write links as they must work from references/ (for example [combat.md](combat.md)), because the file moves there after the check. Plain short sentences, active voice, one term per meaning, no filler, no emoji. Any Luau has no comments. End with "## Not covered" listing sub-topics searched without a usable source.`

const TRAILER = `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01SkJrrpwtQAWv9TdWqphBVZ`

const GITRULES = `Git rules: work in ${ROOT} on branch ${BRANCH} only. Stage only the paths you name (never git add -A). Commit with git commit -m "<subject>" -m "<the two trailer lines below>" -- <the same paths>, then git push origin ${BRANCH}, retrying up to 4 times with 2, 4, 8 and 16 second waits on network errors. Another agent may commit at the same moment: if git reports an index.lock, wait 5 seconds and retry. Never push to main, never force-push, never open a pull request. The two trailer lines, exactly:
${TRAILER}`

const finalLine = (t) => `Checked N findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [${t.file}](${t.file}). The sources below were read as text; no video stream was opened.`

const TOPICS = [
  {
    key: 'motion-data', kind: 'research', file: 'human-motion-data.md', title: 'Human motion data: gait, running, strikes and jumps',
    existing: ['body-mechanics.md', 'locomotion.md', 'combat.md', 'principles.md', 'r6-mechanics.md'],
    sources: 'papers and biomechanics datasets (PubMed Central and Europe PMC open-access papers, journal pages, university course notes), GDC talks and slides, studio blogs, gamedeveloper.com, 80.lv, Animation Mentor, iAnimate, animators\' own blogs.',
    focus: 'measured human joint kinematics an animator can copy as numbers. Walking gait: hip flexion/extension range and timing over the cycle, knee and ankle (to know what R6 must fake), pelvis rotation, tilt and obliquity, trunk rotation counter to the pelvis, shoulder (arm) swing range and its phase against the legs, vertical and lateral COM excursion, stance/swing percentages, head stability. Running: the same plus flight phase, ground contact time by speed, trunk lean, arm swing range, step frequency by speed. Starts and stops: acceleration lean, first steps. The kinetic chain in punches, throws and kicks: the order and timing (ms) of peak angular velocities of pelvis, trunk, upper arm and forearm/hand or thigh/shank, peak fist and foot speeds, step and weight transfer timing (boxing punch kinematics papers, baseball pitching kinetic chain such as ASMI/Fleisig, soccer and martial arts kick studies). Jumps: countermovement depth and timing, takeoff duration, landing absorption time and depth. Turning and pivoting. Translate each number to R6: the Shoulder joint is the whole arm and the Hip joint the whole leg, so elbow and knee contributions fold into limb rotation plus the short translation the skill already uses to suggest a bend. Aim for 30 to 45 findings.',
  },
  {
    key: 'polish', kind: 'research', file: 'polish-and-critique.md', title: 'Polish and critique: what separates professional motion',
    existing: ['keyframe-workflow.md', 'principles.md', 'lesson-videos.md', 'quality-review.md', 'motion-metrics.md'],
    sources: 'animators\' own blogs and articles (Animation Mentor blog, iAnimate, Keith Lango, Jason Ryan, Kenny Roy, Victor Navone, Sir Wade Neistadt, Jonathan Cooper\'s Game Anim site), GDC talks and slides, studio blogs, gamedeveloper.com, 80.lv, Cartoon Brew, AnimSchool, Roblox DevForum posts by experienced animators.',
    focus: 'concrete polish techniques and the notes leads give in dailies, from professional feature-film and game animators. Spacing charts and favouring; breaking up even timing ("texture" in timing); overlap offsets in frames per joint down a chain; settles (how many bounces, how fast they decay); fixing floaty motion; contact, weight and impact cues; curve-editor practice (tangent types per situation, cleaning curves, avoiding flat tangents everywhere, overshoot via tangents); tracking arcs on hands, feet, head and nose; twinning; silhouette and line of action checks; holds and moving-hold durations; favour keys and the breakdown that sells the arc; anticipation sizing; how to watch your own animation critically (flip, mute, loop, frame by frame, at speed, fresh eyes); common notes students receive and how they are fixed; game-specific polish (responsiveness against weight, blending into and out of clips, loops without visible seams). Numbers wherever sources give them. Aim for 30 to 45 findings.',
  },
  {
    key: 'acting', kind: 'research', file: 'acting-and-performance.md', title: 'Acting and performance',
    existing: ['keyframe-workflow.md', 'lesson-videos.md', 'principles.md', 'stylized-and-roblox.md'],
    sources: 'interviews and articles by veteran animators and supervisors (Disney, Pixar, DreamWorks, Sony, Laika veterans such as Glen Keane, Andreas Deja and Eric Goldberg; Frank Thomas and Ollie Johnston quotes in primary texts; Ed Hooks "Acting for Animators" articles; Animation World Network; Cartoon Brew; Animation Mentor blog; iAnimate; Spline Doctors; Keith Lango; Shawn Kelly\'s "Tips and Tricks"), GDC talks on character performance in games, 80.lv, gamedeveloper.com.',
    focus: 'what senior character animators know about performance: thinking characters (the thought precedes the action, how many frames ahead), subtext and intention, choosing the less obvious acting choice, gesture vocabulary and avoiding cliché gestures, specificity of character (age, weight, status, mood shown through posture and rhythm), status and power in posture, eye and head direction as the first readable signal of thought, hands and their acting, rhythm and pauses, contrast between stillness and action, physical comedy timing, reading in silhouette and from far away, staging a performance for the camera, how veterans shoot and use reference without copying it, performance in games (short loops, idles with personality, emotes, victory poses, taunts; character carried by locomotion), notes veterans give juniors about acting. R6 has no face by default, so translate facial acting into head, torso and hand acting. Aim for 30 to 40 findings.',
  },
  {
    key: 'micro', kind: 'research', file: 'human-micro-motion.md', title: 'Life in still poses: sway, breath, gaze and fidgets',
    existing: ['locomotion.md', 'principles.md', 'body-mechanics.md', 'lesson-videos.md', 'stylized-and-roblox.md'],
    sources: 'papers (PubMed Central and Europe PMC open-access papers, journal pages), GDC talks and slides, studio blogs, gamedeveloper.com, 80.lv, Animation Mentor, iAnimate, animators\' own blogs.',
    focus: 'the measured micro-motion that makes real people never still. Quiet standing postural sway: centre-of-pressure amplitude and frequency, anterior-posterior against medial-lateral, effects of stance width, fatigue and attention. Weight shifts during prolonged standing: how often, how large, how long they take. Breathing: rate at rest and after exertion, recovery time, chest, shoulder and abdomen displacement, inhale/exhale time ratio. Head and gaze: head-eye coordination (eyes lead, head latency, the share of a gaze shift done by the head, head turn speeds and durations by amplitude), blink rate and duration, saccade timing. Fidgets and self-touching frequency. How game and film animators build idles and moving holds that feel alive (Naughty Dog, Ubisoft, Rockstar, Animation Mentor; idle break frequency, randomisation, avoiding visible loops). What motion capture contains that keyframed animation lacks (micro variation, asymmetry, no exact repeats) and how animators add it back. Translate every number into R6 life-layer amplitudes (degrees on torso, head and arms; studs on RootJoint), periods and frame counts. Aim for 30 to 45 findings.',
  },
  {
    key: 'body', kind: 'research', file: 'body-types-and-scale.md', title: 'Body types, weight and scale',
    existing: ['body-mechanics.md', 'locomotion.md', 'principles.md', 'custom-rigs.md', 'weapons.md'],
    sources: 'biomechanics and allometry papers (Froude number and dynamic similarity, R. McNeill Alexander\'s work, gait of children, older adults and people with obesity, load carriage), animators\' articles on weight and character types (Animation Mentor, iAnimate, Animator Island, Keith Lango), GDC talks on animating giants, small creatures and heavy characters, studio blogs, gamedeveloper.com, 80.lv, Roblox DevForum posts by experienced animators.',
    focus: 'how mass, size, age, strength and fatigue change motion, so every character gets its own timing and posture. Dynamic similarity and the Froude number (preferred walking speed and the walk-run transition as functions of leg length; how stride frequency scales with size); how timing scales for giants and small creatures; heavy against light characters (contact time, sink on landing, recovery length, momentum on stops and turns, arm swing); gait and posture of children, older adults and heavy people; load carriage; fatigue and injury in gait (limp patterns, timing asymmetry); strength against effort cues (a strong character lifts easily, a weak one strains); keeping one weight class consistent across a whole clip set. Whole R6 characters can be built at different sizes, and creature rigs exist (custom-rigs.md). Aim for 30 to 40 findings.',
  },
  {
    key: 'direction', kind: 'research', file: 'game-animation-direction.md', title: 'Game animation direction',
    existing: ['combat.md', 'locomotion.md', 'keyframe-workflow.md', 'stylized-and-roblox.md', 'principles.md'],
    sources: 'GDC talks, Vault pages and slides by lead and director-level game animators (Naughty Dog, Santa Monica Studio, Insomniac, Ubisoft, Blizzard, Riot, Respawn, Bungie; FromSoftware and Nintendo interviews), Jonathan Cooper\'s Game Anim book site and blog, gamedeveloper.com postmortems, 80.lv interviews, animators\' own blogs.',
    focus: 'the judgment senior and lead game animators apply beyond single clips: the responsiveness against weight trade-off and how leads settle it per action, designing a character\'s animation set (which clips, how many, transitions, idle-to-move, turn and stop sets), keeping style and weight consistent across a whole set, defining a character\'s weight class, readability rules for gameplay (silhouette from the gameplay camera, telegraph hierarchy, distance readability through pose), first-frame and last-frame rules for blending, how animation, design, VFX and audio agree on event timings, blocking in engine first, reviewing in game rather than in the viewport, polish priorities under deadlines, the most common mistakes leads see from mid-level animators, and how direction differs between stylised (Overwatch, Fortnite, Genshin) and realistic (The Last of Us, God of War) projects. Aim for 30 to 40 findings.',
  },
  {
    key: 'procedural', kind: 'research', file: 'procedural-layers.md', title: 'Procedural layers that make few keys look rich',
    existing: ['stylized-and-roblox.md', 'pipeline.md', 'principles.md', 'custom-rigs.md', 'combat.md', 'locomotion.md'],
    sources: 'GDC Vault pages and slides, the speakers\' own blogs and code (Daniel Holden theorangeduck.com, Ryan Juckett, Wolfire blog), papers, studio tech blogs, gamedeveloper.com, Roblox creator docs (create.roblox.com and the creator-docs YAML on GitHub), DevForum posts by experienced developers.',
    focus: 'David Rosen\'s GDC 2014 "Animation Bootcamp: An Indie Approach to Procedural Animation" (Overgrowth: very few key poses, physics-driven interpolation, springs, procedural run and jump); inertialization (David Bollo, GDC 2016/2018, Gears of War) and how it replaces cross-fades; motion matching core ideas (Simon Clavet, GDC 2016) that help choose or blend clips; critically damped springs and spring-damper math for secondary motion (Daniel Holden "Spring-It-On", Ryan Juckett), half-life parameterisation; procedural lean from acceleration and turn rate; procedural look-at with limits, lag and the eye/head/torso split; foot IK and pelvis lowering; additive layers (breathing, recoil, hit flinch) and their weights; stride and orientation warping; root motion against in-place; blending pitfalls (foot sliding, pops, pose averaging collapse) and fixes; physics-based secondary on capes and hair; Roblox runtime facts that bound all of this (Motor6D.Transform written in PreSimulation, IKControl types and properties, AnimationTrack weights). Poser already has springs, lag, life, warp, post and Feet.flat. Give formulas and constants where sources give them. Aim for 30 to 45 findings.',
  },
  {
    key: 'dodges', kind: 'saved', file: 'dodges-and-dashes.md', title: 'Dodges, rolls, dashes and evasion',
    section: '## Dodges, rolls, dashes and evasion', lines: 'lines 256 to 506',
    existing: ['combat.md', 'locomotion.md', 'body-mechanics.md', 'principles.md'],
  },
  {
    key: 'traversal', kind: 'saved', file: 'traversal.md', title: 'Traversal: climb, mantle, vault, slide, wall run, swim',
    section: '## Traversal: climb, mantle, vault, slide, wall run, swim', lines: 'lines 5 to 255',
    existing: ['locomotion.md', 'body-mechanics.md', 'custom-rigs.md', 'principles.md'],
  },
  {
    key: 'aerial', kind: 'research', file: 'aerial-combat.md', title: 'Aerial combat: launchers, air combos and slams',
    existing: ['combat.md', 'body-mechanics.md', 'principles.md', 'weapons.md'],
    sources: 'frame-data wikis (ultimateframedata.com, ssbwiki.com, dustloop.com, supercombo.gg), GDC talks and slides, studio blogs and interviews, gamedeveloper.com, 80.lv, Roblox creator docs, DevForum posts by experienced developers.',
    focus: 'launchers (uppercuts and launch attacks), juggles, air combos, air strings and air recovery, ground bounce and wall bounce, plunging attacks, ground slams and dive kicks, air dash, hang time or float during air combos (gravity scaling in Devil May Cry, Bayonetta, fighting games, Roblox battlegrounds games), landing lag and landing recovery frames, how the attacker stays airborne (momentum, small hops), the COM and rotation physics of airborne strikes, readability of aerial attacks from a third-person camera, frame data for aerial attacks (Smash aerials: startup, active frames, landing lag; anime fighters\' air normals). Aim for 25 to 35 findings.',
  },
  {
    key: 'knockdowns', kind: 'research', file: 'knockdowns-and-deaths.md', title: 'Knockback, knockdown, get-up, stun and death',
    existing: ['combat.md', 'principles.md', 'body-mechanics.md', 'custom-rigs.md'],
    sources: 'GDC talks and slides, studio blogs and interviews, gamedeveloper.com, 80.lv, frame-data wikis (ssbwiki.com, dustloop.com, supercombo.gg), papers on physics-based characters, Roblox creator docs (create.roblox.com and the creator-docs YAML on GitHub), DevForum posts by experienced developers.',
    focus: 'knockback and launch reactions by strength, knockdown and the fall onto the ground (hard against soft knockdown, tech or quick rise), get-up animations, their frame counts and invulnerability, wake-up options, stagger and stun states (dizzy loops), guard break, block stun and posture break (Sekiro, For Honor, fighting games), wall splat, death animations (directional deaths, ragdoll hand-off, blending from animation to physics, powered ragdoll, active ragdolls), hit reaction directions (front, back, left, right, high, low) and how many a game needs, additive hit reactions, Roblox specifics: ragdoll on R6 (BallSocketConstraints replacing Motor6Ds, the Physics humanoid state, BreakJointsOnDeath), getting up from a ragdoll back into animation, network ownership effects on knockback. Aim for 25 to 35 findings.',
  },
  {
    key: 'grabs', kind: 'research', file: 'grabs-throws-and-finishers.md', title: 'Grabs, throws, counters and finishers',
    existing: ['combat.md', 'principles.md', 'weapons.md', 'stylized-and-roblox.md'],
    sources: 'GDC talks and slides, studio blogs and interviews, gamedeveloper.com, 80.lv, frame-data wikis (dustloop.com, supercombo.gg, ssbwiki.com, glossary.infil.net), Roblox creator docs, DevForum posts by experienced developers.',
    extra: ' The same file, section "Raw notes from the first grabs researcher", holds 24 unchecked notes from an earlier researcher on this topic: use them as leads and re-read each source before using a note.',
    focus: 'command grabs and throws (startup, whiff recovery, throw tech windows), paired or synced animations between two characters (attacker and victim aligned to a shared origin, how studios author and align them, distance and angle checks before a synced animation plays, warping into alignment), finishers, executions and takedowns (God of War, Doom Eternal glory kills, Sekiro deathblows, Assassin\'s Creed, The Last of Us), parry and counter-attack sequences (parry timing windows, riposte), cinematic finishers with camera, keeping both characters\' contacts matched, Roblox specifics: welding or anchoring the victim to the attacker during a grab, playing two clips in sync on two Animators, network ownership and latency when two players\' animations must line up. Aim for 25 to 35 findings.',
  },
  {
    key: 'abilities', kind: 'research', file: 'abilities-and-casts.md', title: 'Abilities, casts, charges and projectiles',
    existing: ['combat.md', 'stylized-and-roblox.md', 'principles.md', 'weapons.md'],
    sources: 'official game wikis with data (League of Legends wiki cast times, Dota 2 wiki cast point and backswing), GDC talks and slides (Overwatch, League, Genshin animation talks), studio blogs and interviews, gamedeveloper.com, 80.lv, Roblox creator docs, DevForum posts by experienced developers.',
    focus: 'ability and spell cast animations: cast time and wind-up, charge-up loops (hold-to-charge, charge levels and how the pose escalates), channelled abilities (looping hold poses with life), release and recoil after a cast, projectile throws (a fireball, a grenade, a punch that fires a wave), beam firing poses (two-hand beams, sustained beam recoil), summoning, transformation and power-up sequences, ultimate moves and their cinematic timing, cast-time numbers from MOBAs and action RPGs (League of Legends, Dota, Overwatch, Genshin Impact), anime fighting games and Roblox battlegrounds games for move timing, how animation telegraphs an ability so opponents can react, and how animation syncs with VFX through markers or events. Aim for 25 to 35 findings.',
  },
  {
    key: 'ranged', kind: 'research', file: 'ranged-weapons.md', title: 'Guns, bows and thrown weapons',
    existing: ['weapons.md', 'combat.md', 'principles.md', 'locomotion.md'],
    sources: 'GDC talks and slides (Naughty Dog, Gears of War, Destiny, Call of Duty, Respawn), studio blogs and interviews, gamedeveloper.com, 80.lv, animators\' blogs, Roblox creator docs, DevForum posts by experienced developers (R6 gun systems, pointing arms at the camera). Also grep scripts/WeaponRig.lua before naming a weapon helper.',
    focus: 'third-person shooter animation: aim poses and aim offsets (the upper body follows camera pitch and yaw, how the spine shares the rotation), hip fire against aim-down-sights stance, recoil animation (procedural against keyed recoil, kick and recovery frames, per-weapon strength), reload animations (timing, the beat structure of a reload, empty against tactical reload), equip, draw and holster timing, sprinting with a weapon, bow draw, hold and release and arrow nocking, throwing grenades and knives, how R6 games point the arms and head at the camera (Motor6D C0 or Transform on the shoulders and neck, replication of aim), studio talks and articles on shooter animation. Aim for 25 to 35 findings.',
  },
  {
    key: 'runtime', kind: 'research', file: 'combat-runtime.md', title: 'Running combat and movement clips in Roblox',
    existing: ['stylized-and-roblox.md', 'pipeline.md', 'combat.md', 'locomotion.md'],
    sources: 'Roblox creator docs (create.roblox.com) and their YAML sources on github.com/Roblox/creator-docs, Roblox DevForum announcements and posts by Roblox staff and experienced developers, the default Animate script as tracked in github.com/MaximumADHD/Roblox-Client-Tracker. Note the date of each announcement. stylized-and-roblox.md already covers fades, priorities, weights, markers, easing traps, LOD and masks; add only what is new.',
    focus: 'how combat and movement animation is played in Roblox games: upper-body attacks while walking on R6 (keying only the arm and torso joints, priorities, weights), AnimationTrack AdjustSpeed and AdjustWeight behaviour, client against server playback and replication (who plays the attacker\'s animation, replication delay, hit detection timing against animation, client-loaded animations replicating to others), preloading animations (ContentProvider:PreloadAsync) and first-play hitches, limits on tracks per Animator, Animator:LoadAnimation against the deprecated Humanoid:LoadAnimation, track stacking and cleanup bugs, overriding or disabling the default Animate script during combat, newer Roblox animation features announced 2023 to 2026 (animation graph or state machine features, IKControl and its types, AnimationConstraint, R6 IK support, root motion, compression or sampling changes), IKControl for planting feet and aiming on R6, and the facts about Motor6D.Transform that procedural layers rely on. Aim for 25 to 35 findings.',
  },
]

const existingList = (t) => t.existing.map(f => SK + '/references/' + f).join(', ')

const researchPrompt = (t) => `${AUTH}

${SKILL}

YOUR TASK: research "${t.title}" and write a draft reference file.
Draft: ${DR}/${t.file} (create the folder if needed). Do not write into references/; an independent checker moves the file there after re-reading your sources.
Existing files not to repeat: ${existingList(t)}. Do not repeat their rules; point to them by file and section in plain text, for example "combat.md, Hitstop". If a finding contradicts an existing rule, keep both, say when each applies, and report it.
Leads: ${SK}/projects/research-in-progress.md, heading "#### ${t.file}", lists pages an earlier stopped run opened for this topic. Re-read any you use; they are leads, not findings.${t.extra || ''}

Focus: ${t.focus}

${WEB}
Prefer primary sources: ${t.sources}

${FORMAT(t.title)}

Also write ${DR}/${t.file}.sources.md containing "## ${t.title} research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (a markdown link, then what it supports in one sentence).

Save when both files are written: stage and commit exactly these two paths: ${DR}/${t.file} ${DR}/${t.file}.sources.md, with the subject "roblox-r6-animation: draft ${t.file} (unchecked)", and push. ${GITRULES}

Return the structured result.`

const savedPrompt = (t) => `${AUTH}

${SKILL}

YOUR TASK: independent checker, then writer, for "${t.title}". The file ${SK}/projects/research-in-progress.md, section "${t.section}" (${t.lines}), holds about 35 raw findings another researcher extracted. None has been checked, except four traversal verdicts listed under "Checker verdicts recorded before the stop"; re-check those too. For each distinct source URL, fetch it yourself and judge each finding ONLY against what its source says: supported; partly (the core is there but something is overstated, a number differs or the attribution is wrong; write the corrected claim exactly as the source supports it); unsupported; unreachable (first try an archive copy, the creator-docs GitHub source, or the same article at another URL of the same publisher). Be strict: when unsure, unsupported. Never rescue a claim from your own knowledge. Also judge each draft "On R6" translation against the R6 rules and fix it; mark anything the researcher labelled "our inference" as inference.

Then write the draft ${DR}/${t.file} (create the folder if needed) from supported and corrected findings only. Do not write into references/; a second checker moves it there. Existing files not to repeat: ${existingList(t)}; point to them by file and section in plain text.

${WEB}

${FORMAT(t.title)} In "## Not covered", list the sub-topics the researcher listed as not found plus any topic left empty after checking.

Also write ${DR}/${t.file}.sources.md containing "## ${t.title} research", then the line "${finalLine(t)}" with N = all findings you judged, then a table "| Source | Supports |" with one row per source used.

Save when both files are written: stage and commit exactly these two paths: ${DR}/${t.file} ${DR}/${t.file}.sources.md, with the subject "roblox-r6-animation: draft ${t.file} (saved findings checked)", and push. ${GITRULES}

Return the structured result, with the verdict counts in "verdicts".`

const checkPrompt = (t) => `${AUTH}

${SKILL}

YOUR TASK: independent checker for the draft ${DR}/${t.file} ("${t.title}") and its source table ${DR}/${t.file}.sources.md. Another agent wrote them; trust nothing in them.

1. Facts. For each source in the table and each link in the draft, fetch it yourself and judge every sentence that relies on it: supported (keep); partly (rewrite to exactly what the source supports); unsupported (remove the sentence, or the whole bullet when its lead claim goes); unreachable (first try a publisher mirror, the creator-docs GitHub source or Europe PMC; if still unreachable, remove). Be strict: when unsure, remove. Never rescue a claim from your own knowledge. Count the findings you judged, kept, corrected and removed.
2. Translations. Every Poser field and helper named in an "On R6" line must exist in ${SK}/references/pipeline.md or ${SK}/scripts/Poser.lua (grep each one). Every translation must respect "R6 rules that bite" in SKILL.md and ${SK}/references/r6-mechanics.md (no elbows, knees or scaling; the overhead reach limit; the feet rule). Fix or remove violations.
3. Overlap. Read ${existingList(t)}. Remove rules the draft repeats from them and point to them instead. Every contradiction with an existing rule must say when each rule applies.
4. Format. The Contents list matches the headings exactly; the intro names sources.md "${t.title} research"; links work from references/; any Luau has no comments; plain short sentences.
5. Sources file. Remove rows for sources no longer used. ${t.kind === 'saved' ? 'Keep its "Checked N findings" line; if you removed findings, add the sentence "A second independent check removed K more." with your count.' : 'Replace the line "Checked N findings (pending independent check)." with "' + finalLine(t) + '" where N is the number of findings you judged (change the last sentence if you read a transcript).'}

${WEB}

6. Move and save. Run git mv ${DR}/${t.file} ${SK}/references/${t.file} (leave the .sources.md in drafts for the integration step). Stage and commit exactly these paths: ${DR}/${t.file} ${SK}/references/${t.file} ${DR}/${t.file}.sources.md, with the subject "roblox-r6-animation: check ${t.file} (N judged, K kept)" using your counts, and push. ${GITRULES}

Return the structured result.`

const RESEARCH = {
  type: 'object',
  properties: {
    file: { type: 'string' },
    sections: { type: 'array', items: { type: 'string' } },
    finding_count: { type: 'number' },
    source_count: { type: 'number' },
    not_covered: { type: 'array', items: { type: 'string' } },
    conflicts: { type: 'array', items: { type: 'string' } },
    verdicts: { type: 'string', description: 'Saved-finding checks only: counts of supported, partly, unsupported, unreachable' },
    committed: { type: 'boolean' },
  },
  required: ['file', 'sections', 'finding_count', 'source_count', 'not_covered', 'conflicts', 'committed'],
}
const CHECK = {
  type: 'object',
  properties: {
    file: { type: 'string' },
    judged: { type: 'number' },
    kept: { type: 'number' },
    corrected: { type: 'number' },
    removed: { type: 'number' },
    api_fixes: { type: 'array', items: { type: 'string' } },
    r6_fixes: { type: 'array', items: { type: 'string' } },
    overlap_fixes: { type: 'array', items: { type: 'string' } },
    open_issues: { type: 'array', items: { type: 'string' } },
    moved: { type: 'boolean' },
    committed: { type: 'boolean' },
  },
  required: ['file', 'judged', 'kept', 'corrected', 'removed', 'api_fixes', 'r6_fixes', 'overlap_fixes', 'open_issues', 'moved', 'committed'],
}
const INTEG = {
  type: 'object',
  properties: {
    changed: { type: 'array', items: { type: 'string' } },
    skill_rules_added: { type: 'array', items: { type: 'string' } },
    deleted: { type: 'array', items: { type: 'string' } },
    committed: { type: 'boolean' },
  },
  required: ['changed', 'skill_rules_added', 'deleted', 'committed'],
}
const CRITIC = {
  type: 'object',
  properties: {
    issues: {
      type: 'array',
      items: {
        type: 'object',
        properties: { file: { type: 'string' }, line: { type: 'string' }, problem: { type: 'string' }, fix: { type: 'string' } },
        required: ['file', 'line', 'problem', 'fix'],
      },
    },
    missing_topics: { type: 'array', items: { type: 'string' } },
  },
  required: ['issues', 'missing_topics'],
}
const FIX = {
  type: 'object',
  properties: {
    fixed: { type: 'array', items: { type: 'string' } },
    unfixed: { type: 'array', items: { type: 'string' } },
    committed: { type: 'boolean' },
  },
  required: ['fixed', 'unfixed', 'committed'],
}

const results = await pipeline(
  TOPICS,
  (t) => agent(t.kind === 'saved' ? savedPrompt(t) : researchPrompt(t), { label: `draft:${t.key}`, phase: 'Research', schema: RESEARCH, effort: 'max' }),
  async (r, t) => {
    if (!r) { log(`${t.key}: no draft`); return { t, draft: null, check: null } }
    log(`${t.key}: draft with ${r.finding_count} findings from ${r.source_count} sources${r.verdicts ? ' (' + r.verdicts + ')' : ''}`)
    const c = await agent(checkPrompt(t), { label: `check:${t.key}`, phase: 'Check', schema: CHECK, effort: 'max' })
    if (c) log(`${t.key}: ${c.judged} judged, ${c.kept} kept, ${c.removed} removed, moved ${c.moved}`)
    return { t, draft: r, check: c }
  },
)

const done = results.filter(x => x && x.check && x.check.moved)
const missing = TOPICS.filter(t => !done.find(d => d.t.key === t.key)).map(t => t.file)
if (missing.length) log(`not finished: ${missing.join(', ')}`)
if (!done.length) return { error: 'no topic finished', missing }

const summary = done.map(d => ({ file: d.t.file, title: d.t.title, sections: d.draft.sections, judged: d.check.judged, kept: d.check.kept, conflicts: d.draft.conflicts, open_issues: d.check.open_issues }))

phase('Integrate')
const integ = await agent(`${AUTH}

${SKILL}

YOUR TASK: integrate the checked research into the skill. Checked files now in ${SK}/references/:
${JSON.stringify(summary, null, 1)}
Not finished (leave their drafts and notes alone): ${JSON.stringify(missing)}

1. sources.md: for each checked file, append the section from ${DR}/<file>.sources.md to ${SK}/references/sources.md, in the order listed, keeping all existing content. Then git rm those .sources.md files.
2. SKILL.md:
 a. Add one row per new file to the "Read only what the task needs" table (what the file holds, one sentence).
 b. Extend step 4 of "Start with the actual task" so the right new file is read for its clip type.
 c. Distil at most 12 short rules from the new files that change how every clip is made (for example kinetic-chain timing, life-layer amplitudes, acting choices, weight class), each placed where it belongs (the principles table checks, "The method" bullets or "R6 rules that bite") and each naming its reference file. Use only rules the checked files state. SKILL.md style: no person names, dates or quotes; plain short sentences. Do not change or contradict existing rules; where research differs from a rule, leave that in the reference file.
 d. Extend the frontmatter description with the new clip types (dodges, traversal, aerial attacks, knockdowns, grabs and finishers, ability casts, ranged weapons, acting), keeping it under 1024 characters.
3. ${ROOT}/README.md: in the roblox-r6-animation section, name the new reference topics in the same style.
4. ${ROOT}/CHANGELOG.md: add an entry at the top (below the intro paragraph, above the newest entry) headed "## 2026-10-13 - roblox-r6-animation: motion data, acting, polish, combat, movement and ability research (user-authorized)", in the style of the existing entries: the new files and what each covers; per file how many findings were judged and kept; the SKILL.md changes.
5. ${SK}/projects/: if nothing is listed as not finished, git rm projects/research-in-progress.md and projects/research-prompts.md, remove the drafts folder if empty, and update projects/README.md; otherwise keep only the unfinished parts and the plan for them.
6. Save: stage and commit exactly the paths you changed or deleted, with the subject "roblox-r6-animation: integrate the new research (sources, SKILL.md, README, CHANGELOG)", and push. ${GITRULES}

Return the structured result.`, { label: 'integrate', phase: 'Integrate', schema: INTEG, effort: 'max' })

phase('Critic')
const critic = await agent(`${AUTH}

${SKILL}

YOUR TASK: completeness and consistency critic for the research just added to the skill. Read the new files ${done.map(d => SK + '/references/' + d.t.file).join(', ')} and run git diff ${BASE} -- ${SK} ${ROOT}/README.md ${ROOT}/CHANGELOG.md in ${ROOT} to see every change since this run started. Do not edit anything. Report concrete issues (file, line, problem, fix):
- relative links that do not resolve; Contents lists that do not match the headings;
- statements in different new files, or in a new file and an older file, that contradict each other without saying when each applies;
- Poser fields or helpers that do not exist in scripts/Poser.lua or references/pipeline.md;
- advice an R6 rig cannot follow (elbows, knees, scaling, reach beyond references/r6-mechanics.md);
- SKILL.md rules added in this run that no checked file backs, or that use person names, dates or quotes;
- sources.md sections whose counts or links do not match the files;
- Luau with comments; leftover drafts or notes that should have been removed.
Also list important sub-topics of combat, movement, abilities, acting and motion quality that are still missing, in missing_topics.`, { label: 'critic', phase: 'Critic', schema: CRITIC, effort: 'max' })

let fix = null
if (critic && critic.issues.length) {
  phase('Fix')
  fix = await agent(`${AUTH}

${SKILL}

YOUR TASK: fix the issues below in place. For any fix that changes a fact, re-read its source first and follow the source; if the source cannot confirm it, remove the claim. Keep each fix minimal and change nothing else.

${WEB}

Issues:
${JSON.stringify(critic.issues, null, 1)}

Save: stage and commit exactly the files you changed, with the subject "roblox-r6-animation: fix critic findings on the new research", and push. ${GITRULES}

Return the structured result.`, { label: 'fix', phase: 'Fix', schema: FIX, effort: 'max' })
}

return {
  topics: results.map(x => x && ({ file: x.t.file, findings: x.draft && x.draft.finding_count, verdicts: x.draft && x.draft.verdicts, judged: x.check && x.check.judged, kept: x.check && x.check.kept, removed: x.check && x.check.removed, moved: x.check && x.check.moved, open: x.check && x.check.open_issues })),
  missing,
  integ,
  critic_issues: critic ? critic.issues.length : null,
  missing_topics: critic ? critic.missing_topics : null,
  fix,
}
