export const meta = {
  name: 'r6-animation-research-run1',
  description: 'Run 1 of the R6 animation research at max effort: R6 craft, anime craft, human motion data, polish and critique; independent source check per file; integration, critic and fixes; progress pushed per topic',
  phases: [
    { title: 'Research', detail: 'one draft per topic' },
    { title: 'Check', detail: 'independent re-read of every source and R6 check per draft' },
    { title: 'Integrate', detail: 'sources.md, SKILL.md, README, CHANGELOG, plan file' },
    { title: 'Critic', detail: 'R6 appeal, links, contradictions, invented API' },
    { title: 'Fix', detail: 'fix what the critic found' },
  ],
}

const ROOT = '/home/user/roblox-skills'
const SK = ROOT + '/roblox-r6-animation'
const DR = SK + '/projects/drafts'
const SCR = '/tmp/claude-0/-home-user-roblox-skills/2b6990f4-3335-5095-bc18-8fc48fc1ed6b/scratchpad'
const BRANCH = 'claude/animation-vfx-research'
const BASE = '5afb68a'

const AUTH = `AUTHORIZATION: The user started this run themselves ("yes save it and start the first run, lets start now make sure this looks good on r6 okay?") and asked for maximum effort and the best possible quality. Usage is handled by running everything inside this one workflow, sized to one usage window; earlier messages about usage were about how agents are launched and do not ask you to do less. Do your task fully and thoroughly within your time budget.`

const SKILL = `You are improving the agent skill roblox-r6-animation in ${SK}. It authors Roblox R6 character animation in code with a Luau runtime called Poser. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; no face rig by default; parts cannot scale; clips are authored at 60 fps.`

const QUALITY = `QUALITY BAR: the goal is R6 animation that a senior Roblox animator with 20 years of experience would be proud of. It reads as a human body on 6 rigid parts and looks good (appeal, clear poses, rhythm, timing contrast), not only realistic. Acclaimed TV anime such as Frieren is the reference for taste and timing, never something to copy. For every finding, decide whether it survives on 6 rigid parts and which R6 substitute reads the same (for example, a knee bend becomes the leg sliding up into the torso plus a hip rotation). Drop findings that cannot read on R6, or list them under "Does not transfer to R6" with the reason. Search Roblox and R6 sources first (Roblox DevForum, Moon Animator, R6 animators' posts and portfolios), then general sources. Real-life data stays as the target for timing, weight and balance, always translated through the R6 rig, never copied raw.`

const WEB = `Web rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured), save it under your own new folder in ${SCR}/ (never inside the repo), and read only the relevant passages (grep with context), not whole pages. Europe PMC's REST API (https://www.ebi.ac.uk/europepmc/webservices/rest/) serves open-access full texts of papers; Roblox engine facts are in the creator-docs YAML files at https://github.com/Roblox/creator-docs; Roblox DevForum threads have a JSON view at https://devforum.roblox.com/t/<id>.json. YouTube transcripts and web.archive.org were unreachable through this proxy before. A video counts only if you read its transcript or description text. Every finding must come from a page you fetched in this run (or from local measurement, where your task allows it); never write a finding from memory. State each claim exactly as strong as its source, with numbers where given, naming the study, game, studio or person when a number or rule belongs to it.`

const FORMAT = (title) => `Format: follow ${SK}/references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "${title} research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation (joint, degrees, studs, frames at 60 fps, which Poser field) that would look good on 6 parts. Translations may use only Poser fields and helpers that exist in ${SK}/references/pipeline.md and ${SK}/scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and ${SK}/references/r6-mechanics.md; where a technique needs new runtime code, say so plainly. Write links as they must work from references/ (for example [combat.md](combat.md)), because the file moves there after the check. Plain short sentences, active voice, one term per meaning, no filler, no emoji. Any Luau has no comments. End with "## Does not transfer to R6" (findings that cannot read on 6 parts, one line each with the reason) and "## Not covered" (sub-topics searched without a usable source).`

const TRAILER = `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01SkJrrpwtQAWv9TdWqphBVZ`

const GITRULES = `Git rules: work in ${ROOT} on branch ${BRANCH} only. Stage only the paths you name (never git add -A). Commit with git commit -m "<subject>" -m "<the two trailer lines below>" -- <the same paths>, then git push origin ${BRANCH}, retrying up to 4 times with 2, 4, 8 and 16 second waits on network errors. Another agent may commit at the same moment: if git reports an index.lock, wait 5 seconds and retry. Never push to main, never force-push, never open a pull request. The two trailer lines, exactly:
${TRAILER}`

const TIME = (min) => `Time budget: about ${min} minutes, so the whole run fits inside the user's usage window. Run date -u at the start and check it now and then. When ${min - 5} minutes have passed, stop gathering and finish your file with what you have; quality of what you keep matters more than quantity.`

const finalLine = (t) => `Checked N findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [${t.file}](${t.file}). The sources below were read as text; no video stream was opened.`

const TOPICS = [
  {
    key: 'r6craft', file: 'r6-craft.md', title: 'R6 craft: making six parts read human',
    existing: ['r6-mechanics.md', 'stylized-and-roblox.md', 'principles.md', 'weapons.md', 'quality-review.md', 'keyframe-workflow.md', 'lesson-videos.md'],
    sources: 'Roblox DevForum tutorials, resources and critique threads by experienced R6 animators; Moon Animator documentation and community guides; Roblox creator docs on the Animation Editor and the R6 rig; Creator Store pages of professional R6 animation packs by named animators; animators\' portfolio and talent pages where the text is readable; Reddit threads only when the poster shows experience. General animation sources only to explain why an R6 trick works.',
    extra: ` Local evidence you may also use: ${SK}/references/decodes/ holds decoded professional R6 clips. You may measure them with ${SK}/scripts/motion_check.js and ${SK}/scripts/check_decode.py (read their usage first) for facts the existing files do not state yet; cite the decode file and the command as the source, and write the command in the sources table so the checker can rerun it.`,
    focus: 'how experienced R6 animators make 6 rigid parts read as a human body and look good: faking knees, elbows, the spine curve, a shoulder shrug and the wrist with part rotation and translation (limbs sliding up into the torso, piston moves along the limb, torso tilt against the hips, head counter-motion); which real anatomy reads on blocky parts and which disappears; silhouette and line of action on blocky shapes; how much exaggeration reads on R6; what reads on R6 against R15; common R6 beginner mistakes and how veterans fix them; how professional R6 packs (combat, emotes, locomotion, idles) are structured and timed; the R6 animation tools and workflow (Moon Animator, the Roblox Animation Editor, Blender R6 rigs); the styles of popular R6 games (battlegrounds and anime games) and what makes their animation feel good. Aim for 30 to 45 findings.',
  },
  {
    key: 'anime', file: 'anime-craft.md', title: 'Anime craft: timing, acting and action on six parts',
    existing: ['stylized-and-roblox.md', 'combat.md', 'lesson-videos.md', 'principles.md', 'keyframe-workflow.md'],
    sources: 'interviews with the production staff of acclaimed TV anime (Frieren: Beyond Journey\'s End as the main quality reference, plus other acclaimed series), the Sakuga Blog (blog.sakugabooru.com) articles and episode analyses, Anime News Network and Crunchyroll interviews, studio and production notes, writing on Japanese animation production methods and terms (tame and tsume, nakawari, genga and douga, timing sheets, animating on 1s, 2s and 3s), animators\' own posts. Roblox DevForum posts on anime-style R6 animation for the translation side.',
    focus: 'what makes acclaimed TV anime look good, taken as taste and timing, never copied: naturalistic acting with restraint, small gestures and quiet holds that keep living; tame (the held beat before an action) and tsume (compressed fast motion); animating on 2s and 3s and when anime switches to 1s; contrast between holds and fast spacing; how action sequences are timed and staged (anticipation, impact, follow-through, the hold after); how character personality shows in movement; what transfers to a 6-part rig that plays smoothly at 60 fps and what does not (faces, hair, cloth, drawing, camera work); test the claim that anime timing sense works best inside smooth playback, with full stepped timing only where it suits (emotes, finishers), and report what the sources say for and against it. Translate each finding to R6 in frames at 60 fps and Poser fields. Aim for 30 to 40 findings.',
  },
  {
    key: 'motion', file: 'human-motion-data.md', title: 'Human motion data: gait, running, strikes and jumps',
    existing: ['body-mechanics.md', 'locomotion.md', 'combat.md', 'principles.md', 'r6-mechanics.md'],
    sources: 'papers and biomechanics datasets (PubMed Central and Europe PMC open-access papers, journal pages, university course notes), then Roblox DevForum posts on R6 locomotion and combat for the translation side.',
    focus: 'measured human joint kinematics used as the target for timing, weight and balance, each translated through the R6 rig. Walking: hip flexion and extension range and timing over the cycle; knee and ankle (to know what R6 must fake with leg slides); pelvis rotation, tilt and obliquity; trunk rotation against the pelvis; arm swing range and phase; vertical and lateral COM motion; stance and swing shares; head stability. Running: the same plus flight phase, ground contact time by speed, trunk lean, arm swing, step frequency by speed. Starts and stops. The kinetic chain in punches, throws and kicks: the order and timing (ms) of peak angular velocities of pelvis, trunk, upper arm and hand or thigh and shank; peak fist and foot speeds; step and weight transfer timing. Jumps: countermovement depth and timing, takeoff duration, landing absorption. Turning and pivoting. The Shoulder joint is the whole arm and the Hip joint the whole leg, so elbow and knee motion folds into limb rotation plus the short translation the skill uses to suggest a bend. Aim for 30 to 45 findings.',
  },
  {
    key: 'polish', file: 'polish-and-critique.md', title: 'Polish and critique: what separates professional motion',
    existing: ['keyframe-workflow.md', 'principles.md', 'lesson-videos.md', 'quality-review.md', 'motion-metrics.md'],
    sources: 'R6 animators\' critique and polish advice on the Roblox DevForum first; then animators\' own blogs and articles (Animation Mentor blog, iAnimate, Keith Lango, Jason Ryan, Kenny Roy, Victor Navone, Sir Wade Neistadt, Jonathan Cooper\'s Game Anim site), GDC talks and slides, studio blogs, gamedeveloper.com, 80.lv, Cartoon Brew, AnimSchool.',
    focus: 'concrete polish techniques and the notes leads give in dailies, judged by whether they make 6 parts look better: spacing charts and favouring; breaking up even timing; overlap offsets in frames per joint down a chain; settles (how many bounces, how fast they decay); fixing floaty motion; contact, weight and impact cues; curve practice (tangent types per situation, cleaning curves, overshoot); tracking arcs on hands, feet and head; twinning; silhouette and line of action; holds and moving-hold durations; the breakdown that sells the arc; anticipation sizing; how to watch your own animation critically (flip, loop, frame by frame, at speed, fresh eyes); common notes students receive and their fixes; game polish (responsiveness against weight, blending into and out of clips, seamless loops). Numbers wherever sources give them. Aim for 30 to 45 findings.',
  },
]

const existingList = (t) => t.existing.map(f => SK + '/references/' + f).join(', ')

const researchPrompt = (t) => `${AUTH}

${SKILL}

${QUALITY}

YOUR TASK: research "${t.title}" and write a draft reference file.
Draft: ${DR}/${t.file} (create the folder if needed). Do not write into references/; an independent checker moves the file there after re-reading your sources.
Existing files not to repeat: ${existingList(t)}. Do not repeat their rules; point to them by file and section in plain text, for example "combat.md, Hitstop". If a finding contradicts an existing rule, keep both, say when each applies, and report it.
Leads: ${SK}/projects/research-in-progress.md may list pages an earlier stopped run opened for this file under a heading "#### ${t.file}". Re-read any you use; they are leads, not findings.${t.extra || ''}

Focus: ${t.focus}

${WEB}
Prefer these sources: ${t.sources}

${FORMAT(t.title)}

Also write ${DR}/${t.file}.sources.md containing "## ${t.title} research", the line "Checked N findings (pending independent check).", and a table "| Source | Supports |" with one row per source (a markdown link, then what it supports in one sentence).

${TIME(55)}

Save when both files are written: stage and commit exactly these two paths: ${DR}/${t.file} ${DR}/${t.file}.sources.md, with the subject "roblox-r6-animation: draft ${t.file} (unchecked)", and push. ${GITRULES}

Return the structured result.`

const checkPrompt = (t) => `${AUTH}

${SKILL}

${QUALITY}

YOUR TASK: independent checker for the draft ${DR}/${t.file} ("${t.title}") and its source table ${DR}/${t.file}.sources.md. Another agent wrote them; trust nothing in them.

1. Facts. For each source in the table and each link in the draft, fetch it yourself and judge every sentence that relies on it: supported (keep); partly (rewrite to exactly what the source supports); unsupported (remove the sentence, or the whole bullet when its lead claim goes); unreachable (first try a publisher mirror, the creator-docs GitHub source, the DevForum JSON view or Europe PMC; if still unreachable, remove). For a finding measured from a local decode file, rerun the command in the sources table and compare. Be strict: when unsure, remove. Never rescue a claim from your own knowledge. Count the findings you judged, kept, corrected and removed.
2. R6. Every "On R6" translation must read as a human body on 6 rigid parts and look good to a senior R6 animator; rewrite a weak or generic translation into a concrete one, or move the finding to "Does not transfer to R6" with the reason. Every Poser field and helper named must exist in ${SK}/references/pipeline.md or ${SK}/scripts/Poser.lua (grep each one). Every translation must respect "R6 rules that bite" in SKILL.md and ${SK}/references/r6-mechanics.md (no elbows, knees or scaling; the overhead reach limit; the feet rule).
3. Overlap. Read ${existingList(t)}. Remove rules the draft repeats from them and point to them instead. Every contradiction with an existing rule must say when each rule applies.
4. Format. The Contents list matches the headings exactly; the intro names sources.md "${t.title} research"; links work from references/; any Luau has no comments; plain short sentences.
5. Sources file. Remove rows for sources no longer used. Replace the line "Checked N findings (pending independent check)." with "${finalLine(t)}" where N is the number of findings you judged (change the last sentence if you read a transcript or measured a local decode).

${WEB}

${TIME(40)}

6. Move and save. Run git mv ${DR}/${t.file} ${SK}/references/${t.file} (leave the .sources.md in drafts for the integration step). Stage and commit exactly these paths: ${DR}/${t.file} ${SK}/references/${t.file} ${DR}/${t.file}.sources.md, with the subject "roblox-r6-animation: check ${t.file} (N judged, K kept)" using your counts, and push. ${GITRULES}

Return the structured result.`

const RESEARCH = {
  type: 'object',
  properties: {
    file: { type: 'string' },
    sections: { type: 'array', items: { type: 'string' } },
    finding_count: { type: 'number' },
    source_count: { type: 'number' },
    not_transferring: { type: 'number' },
    not_covered: { type: 'array', items: { type: 'string' } },
    conflicts: { type: 'array', items: { type: 'string' } },
    committed: { type: 'boolean' },
  },
  required: ['file', 'sections', 'finding_count', 'source_count', 'not_transferring', 'not_covered', 'conflicts', 'committed'],
}
const CHECK = {
  type: 'object',
  properties: {
    file: { type: 'string' },
    judged: { type: 'number' },
    kept: { type: 'number' },
    corrected: { type: 'number' },
    removed: { type: 'number' },
    r6_rewrites: { type: 'array', items: { type: 'string' } },
    api_fixes: { type: 'array', items: { type: 'string' } },
    overlap_fixes: { type: 'array', items: { type: 'string' } },
    open_issues: { type: 'array', items: { type: 'string' } },
    moved: { type: 'boolean' },
    committed: { type: 'boolean' },
  },
  required: ['file', 'judged', 'kept', 'corrected', 'removed', 'r6_rewrites', 'api_fixes', 'overlap_fixes', 'open_issues', 'moved', 'committed'],
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
  (t) => agent(researchPrompt(t), { label: `draft:${t.key}`, phase: 'Research', schema: RESEARCH, effort: 'max' }),
  async (r, t) => {
    if (!r) { log(`${t.key}: no draft`); return { t, draft: null, check: null } }
    log(`${t.key}: draft with ${r.finding_count} findings from ${r.source_count} sources`)
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

${QUALITY}

YOUR TASK: integrate the checked research of run 1 into the skill. Checked files now in ${SK}/references/:
${JSON.stringify(summary, null, 1)}
Not finished in this run (leave their drafts alone): ${JSON.stringify(missing)}

1. sources.md: for each checked file, append the section from ${DR}/<file>.sources.md to ${SK}/references/sources.md, in the order listed, keeping all existing content. Then git rm those .sources.md files.
2. SKILL.md:
 a. Add one row per new file to the "Read only what the task needs" table (what the file holds, one sentence).
 b. Extend step 4 of "Start with the actual task" so the right new file is read for its purpose (r6-craft.md for every clip, anime-craft.md for style and timing, human-motion-data.md for timing targets, polish-and-critique.md for the polish and review passes).
 c. Distil at most 8 short rules from the new files that change how every clip is made and make it look good on 6 parts, each placed where it belongs (the principles table checks, "The method" bullets or "R6 rules that bite") and each naming its reference file. Use only rules the checked files state. SKILL.md style: no person names, dates or quotes; plain short sentences. Do not change or contradict existing rules; where research differs from a rule, leave that in the reference file.
 d. Update the frontmatter description only if a new capability needs naming, keeping it under 1024 characters.
3. ${ROOT}/README.md: in the roblox-r6-animation section, name the new reference topics in the same style.
4. ${ROOT}/CHANGELOG.md: add an entry at the top (below the intro paragraph, above the newest entry) headed "## 2026-10-13 - roblox-r6-animation: R6 craft, anime craft, human motion data and polish research, run 1 (user-authorized)", in the style of the existing entries: the new files and what each covers; per file how many findings were judged and kept; the SKILL.md changes.
5. ${SK}/projects/research-in-progress.md: in "Runs", mark run 1 done with the date and the finished files; delete the lead lists under "#### human-motion-data.md" and "#### polish-and-critique.md" for finished files; keep everything else. Remove ${DR} if it is empty.
6. Save: stage and commit exactly the paths you changed or deleted, with the subject "roblox-r6-animation: integrate run 1 research (sources, SKILL.md, README, CHANGELOG)", and push. ${GITRULES}

${TIME(35)}

Return the structured result.`, { label: 'integrate', phase: 'Integrate', schema: INTEG, effort: 'max' })

phase('Critic')
const critic = await agent(`${AUTH}

${SKILL}

${QUALITY}

YOUR TASK: critic for run 1. Read the new files ${done.map(d => SK + '/references/' + d.t.file).join(', ')} and run git diff ${BASE} -- ${SK} ${ROOT}/README.md ${ROOT}/CHANGELOG.md in ${ROOT} to see every change of this run. Do not edit anything. Report concrete issues (file, line, problem, fix):
- R6 appeal: translations that would not read as a human body on 6 parts, or would not look good to a senior R6 animator, or are generic; SKILL.md rules that would make clips look worse on R6;
- statements that contradict each other, or contradict older files, without saying when each applies;
- Poser fields or helpers that do not exist in scripts/Poser.lua or references/pipeline.md; advice an R6 rig cannot follow (elbows, knees, scaling, reach beyond references/r6-mechanics.md);
- SKILL.md rules added in this run that no checked file backs, or that use person names, dates or quotes;
- relative links that do not resolve; Contents lists that do not match the headings; sources.md sections whose counts or links do not match the files; Luau with comments; leftover drafts.
Also list important sub-topics for making R6 animation look senior-level that are still missing, in missing_topics.

${TIME(20)}`, { label: 'critic', phase: 'Critic', schema: CRITIC, effort: 'max' })

let fix = null
if (critic && critic.issues.length) {
  phase('Fix')
  fix = await agent(`${AUTH}

${SKILL}

${QUALITY}

YOUR TASK: fix the issues below in place. For any fix that changes a fact, re-read its source first and follow the source; if the source cannot confirm it, remove the claim. Keep each fix minimal and change nothing else.

${WEB}

Issues:
${JSON.stringify(critic.issues, null, 1)}

Save: stage and commit exactly the files you changed, with the subject "roblox-r6-animation: fix run 1 critic findings", and push. ${GITRULES}

${TIME(30)}

Return the structured result.`, { label: 'fix', phase: 'Fix', schema: FIX, effort: 'max' })
}

return {
  topics: results.map(x => x && ({ file: x.t.file, findings: x.draft && x.draft.finding_count, not_transferring: x.draft && x.draft.not_transferring, judged: x.check && x.check.judged, kept: x.check && x.check.kept, removed: x.check && x.check.removed, moved: x.check && x.check.moved, open: x.check && x.check.open_issues })),
  missing,
  integ,
  critic_issues: critic ? critic.issues.length : null,
  missing_topics: critic ? critic.missing_topics : null,
  fix,
}
