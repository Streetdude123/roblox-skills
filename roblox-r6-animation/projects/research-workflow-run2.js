export const meta = {
  name: 'r6-animation-research-run2',
  description: 'Run 2 of the R6 animation research at max effort: acting and performance, micro-motion, body types and scale, game animation direction; independent source check per file; integration, critic and fixes; progress pushed per topic',
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
const SCR = '/tmp/claude-0/-home-user-roblox-skills/66461c85-5953-594d-966b-29e18d73891d/scratchpad'
const BRANCH = 'claude/animation-vfx-research'
const BASE = '5e552ef'

const AUTH = `AUTHORIZATION: The user asked for this run themselves ("Start run 2 in 27 minutes") after run 1 finished, and asked for maximum effort and the best possible quality. Usage is handled by running everything inside this one workflow, sized to one usage window; earlier messages about usage were about how agents are launched and do not ask you to do less. Do your task fully and thoroughly within your time budget.`

const SKILL = `You are improving the agent skill roblox-r6-animation in ${SK}. It authors Roblox R6 character animation in code with a Luau runtime called Poser. Read its SKILL.md first. R6: Head, Torso, Left/Right Arm, Left/Right Leg joined by Motor6Ds to the Torso; the Torso joined to HumanoidRootPart by RootJoint; no elbows or knees; no face rig by default; parts cannot scale; clips are authored at 60 fps.`

const QUALITY = `QUALITY BAR: the goal is R6 animation that a senior Roblox animator with 20 years of experience would be proud of. It reads as a human body on 6 rigid parts and looks good (appeal, clear poses, rhythm, timing contrast), not only realistic. Acclaimed TV anime such as Frieren is the reference for taste and timing, never something to copy. For every finding, decide whether it survives on 6 rigid parts and which R6 substitute reads the same (for example, a knee bend becomes the leg sliding up into the torso plus a hip rotation). Drop findings that cannot read on R6, or list them under "Does not transfer to R6" with the reason. Search Roblox and R6 sources first (Roblox DevForum, Moon Animator, R6 animators' posts and portfolios), then general sources. Real-life data stays as the target for timing, weight and balance, always translated through the R6 rig, never copied raw.`

const WEB = `Web rules: load the web tools with ToolSearch query "select:WebSearch,WebFetch". If WebFetch fails on a site, fetch it with curl through the Bash tool (the HTTPS proxy is preconfigured), save it under your own new folder in ${SCR}/ (never inside the repo), and read only the relevant passages (grep with context), not whole pages. Europe PMC's REST API (https://www.ebi.ac.uk/europepmc/webservices/rest/) serves open-access full texts of papers; Roblox engine facts are in the creator-docs YAML files at https://github.com/Roblox/creator-docs; Roblox DevForum threads have a JSON view at https://devforum.roblox.com/t/<id>.json. YouTube transcripts and web.archive.org were unreachable through this proxy before. A video counts only if you read its transcript or description text. Every finding must come from a page you fetched in this run (or from local measurement, where your task allows it); never write a finding from memory. State each claim exactly as strong as its source, with numbers where given, naming the study, game, studio or person when a number or rule belongs to it.`

const FORMAT = (title) => `Format: follow ${SK}/references/combat.md: a "# Title"; one intro paragraph saying what the file holds and that every finding was checked against its source (sources.md, "${title} research"); a "## Contents" list matching the headings exactly; "## Section" headings; bullets that open with a **bold lead sentence.**, then the source fact, then "On R6: ..." with a concrete translation (joint, degrees, studs, frames at 60 fps, which Poser field) that would look good on 6 parts. Translations may use only Poser fields and helpers that exist in ${SK}/references/pipeline.md and ${SK}/scripts/Poser.lua (grep before naming one) and must respect "R6 rules that bite" in SKILL.md and ${SK}/references/r6-mechanics.md; where a technique needs new runtime code, say so plainly. Write links as they must work from references/ (for example [combat.md](combat.md)), because the file moves there after the check. Plain short sentences, active voice, one term per meaning, no filler, no emoji. Any Luau has no comments. End with "## Does not transfer to R6" (findings that cannot read on 6 parts, one line each with the reason) and "## Not covered" (sub-topics searched without a usable source).`

const TRAILER = `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01XdYgne4K6SA6eCV53JDDKw`

const GITRULES = `Git rules: work in ${ROOT} on branch ${BRANCH} only. Stage only the paths you name (never git add -A). Commit with git commit -m "<subject>" -m "<the two trailer lines below>" -- <the same paths>, then git push origin ${BRANCH}, retrying up to 4 times with 2, 4, 8 and 16 second waits on network errors. Another agent may commit at the same moment: if git reports an index.lock, wait 5 seconds and retry. Never push to main, never force-push, never open a pull request. The two trailer lines, exactly:
${TRAILER}`

const TIME = (min) => `Time budget: about ${min} minutes, so the whole run fits inside the user's usage window. Run date -u at the start and check it now and then. When ${min - 5} minutes have passed, stop gathering and finish your file with what you have; quality of what you keep matters more than quantity.`

const finalLine = (t) => `Checked N findings against their sources with an independent re-read; only supported or partly supported findings (with the checker's correction) are used in [${t.file}](${t.file}). The sources below were read as text; no video stream was opened.`

const TOPICS = [
  {
    key: 'acting', file: 'acting-and-performance.md', title: 'Acting and performance on six parts',
    existing: ['anime-craft.md', 'r6-craft.md', 'polish-and-critique.md', 'keyframe-workflow.md', 'lesson-videos.md', 'principles.md', 'stylized-and-roblox.md'],
    sources: 'Roblox DevForum posts by experienced R6 animators on emotes, idles and character acting first; then interviews and articles by veteran animators and supervisors (Disney, Pixar, DreamWorks, Sony and Laika veterans; Frank Thomas and Ollie Johnston in primary texts; Ed Hooks "Acting for Animators" articles; Animation World Network; Cartoon Brew; Animation Mentor blog; iAnimate; Spline Doctors; Keith Lango; Shawn Kelly\'s "Tips and Tricks"), GDC talks on character performance in games, 80.lv, gamedeveloper.com.',
    focus: 'what senior character animators know about performance, translated to a rig with no face and no elbows or knees: thinking characters (the thought precedes the action, and by how many frames); subtext and intention; choosing the less obvious acting choice; gesture vocabulary and avoiding cliché gestures; specificity of character (age, status, mood shown through posture and rhythm); status and power in posture; head direction as the first readable signal of thought when there are no eyes to animate; hands and arms as the main acting tools on R6; rhythm and pauses; contrast between stillness and action; physical comedy timing; reading in silhouette and from far away; staging for the player camera; how veterans shoot and use reference without copying it; performance in games (idles with personality, emotes, victory poses, taunts, character carried by locomotion); notes veterans give juniors about acting. Every facial acting idea must become head, torso or arm acting, or go under "Does not transfer to R6". Aim for 30 to 40 findings.',
  },
  {
    key: 'micro', file: 'human-micro-motion.md', title: 'Life in still poses: sway, breath, gaze and fidgets',
    existing: ['locomotion.md', 'principles.md', 'body-mechanics.md', 'lesson-videos.md', 'stylized-and-roblox.md', 'human-motion-data.md', 'polish-and-critique.md', 'r6-craft.md'],
    sources: 'papers (PubMed Central and Europe PMC open-access papers, journal pages) for the measured numbers; Roblox DevForum posts on R6 idles for the R6 side; GDC talks and slides, studio blogs, gamedeveloper.com, 80.lv, Animation Mentor and iAnimate for how animators build idles.',
    extra: ` Local evidence you may also use: ${SK}/references/decodes/TW_idle.txt is a decoded professional R6 idle. You may measure it with ${SK}/scripts/motion_check.js (read its usage first); cite the decode file and the command as the source and write the command in the sources table so the checker can rerun it.`,
    focus: 'the measured micro-motion that makes real people never still, scaled to what reads on 6 rigid parts. Quiet standing postural sway: amplitude and frequency, front-back against side to side, effects of stance width, fatigue and attention. Weight shifts during prolonged standing: how often, how large, how long. Breathing: rate at rest and after exertion, recovery time, chest and shoulder motion, inhale and exhale ratio. Head and gaze: eyes lead and the head follows (the share of a gaze shift the head does, head turn speeds and durations by amplitude), blink rate. Fidgets and their frequency. How game and film animators build idles and moving holds that feel alive (idle breaks, randomisation, avoiding visible loops). What motion capture contains that keyframes lack and how animators add it back. Translate each number into R6 life-layer amplitudes (degrees on torso, head and arms; studs on RootJoint), periods and frame counts, and say which amplitudes are too small to read on R6 from the player camera. Aim for 30 to 45 findings.',
  },
  {
    key: 'body', file: 'body-types-and-scale.md', title: 'Body types, weight and scale on six parts',
    existing: ['body-mechanics.md', 'locomotion.md', 'principles.md', 'custom-rigs.md', 'weapons.md', 'human-motion-data.md', 'r6-craft.md'],
    sources: 'biomechanics and allometry papers (Froude number and dynamic similarity, R. McNeill Alexander\'s work, gait of children, older adults and heavy people, load carriage) for the numbers; Roblox DevForum posts on animating heavy, giant, small or old R6 characters for the R6 side; animators\' articles on weight and character types (Animation Mentor, iAnimate, Animator Island, Keith Lango); GDC talks on animating giants, small creatures and heavy characters; 80.lv; gamedeveloper.com.',
    focus: 'how mass, size, age, strength and fatigue change motion, so every R6 character gets its own timing and posture even though all R6 bodies share the same six blocks. Dynamic similarity and the Froude number (walking speed and the walk-run transition as functions of leg length, stride frequency by size); how timing scales for giant and small R6 characters built at other sizes; heavy against light characters (contact time, sink on landing, recovery length, momentum on stops and turns, arm swing); posture and gait of children, older adults and heavy people expressed only through block angles, offsets and timing; load carriage; fatigue and limps (timing asymmetry); strength against effort cues; keeping one weight class consistent across a whole clip set. Aim for 30 to 40 findings.',
  },
  {
    key: 'direction', file: 'game-animation-direction.md', title: 'Game animation direction',
    existing: ['combat.md', 'locomotion.md', 'keyframe-workflow.md', 'stylized-and-roblox.md', 'principles.md', 'polish-and-critique.md', 'r6-craft.md', 'anime-craft.md'],
    sources: 'Roblox DevForum posts by lead animators of popular R6 and battlegrounds games first; then GDC talks, Vault pages and slides by lead and director-level game animators (Naughty Dog, Santa Monica Studio, Insomniac, Ubisoft, Blizzard, Riot, Respawn, Bungie; FromSoftware and Nintendo interviews), Jonathan Cooper\'s Game Anim book site and blog, gamedeveloper.com postmortems, 80.lv interviews, animators\' own blogs.',
    focus: 'the judgment senior and lead game animators apply beyond single clips, applied to R6 games: the responsiveness against weight trade-off and how leads settle it per action; designing a character\'s animation set (which clips, how many, transitions, idle to move, turn and stop sets, battle idle against neutral idle); keeping style and weight consistent across a whole set; defining a character\'s weight class; readability rules for gameplay (silhouette from the third-person and shift-lock cameras, telegraph hierarchy, distance readability through pose); first-frame and last-frame rules for blending; how animation, design, VFX and audio agree on event timings; blocking in engine first; reviewing in game rather than in the editor; polish priorities under deadlines; the most common mistakes leads see from mid-level animators; how direction differs between stylised (Overwatch, Fortnite, Genshin, anime battlegrounds games) and realistic (The Last of Us, God of War) projects. Aim for 30 to 40 findings.',
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

YOUR TASK: integrate the checked research of run 2 into the skill. Checked files now in ${SK}/references/:
${JSON.stringify(summary, null, 1)}
Not finished in this run (leave their drafts alone): ${JSON.stringify(missing)}

1. sources.md: for each checked file, append the section from ${DR}/<file>.sources.md to ${SK}/references/sources.md, in the order listed, keeping all existing content. Then git rm those .sources.md files.
2. SKILL.md:
 a. Add one row per new file to the "Read only what the task needs" table (what the file holds, one sentence).
 b. Extend step 4 of "Start with the actual task" so the right new file is read for its purpose (acting-and-performance.md for emotes, idles and character acting, human-micro-motion.md for idles, holds and the life layer, body-types-and-scale.md for heavy, light, small, giant, young or old characters, game-animation-direction.md for planning a clip set and its blends).
 c. Distil at most 6 short rules from the new files that change how every clip is made and make it look good on 6 parts, each placed where it belongs (the principles table checks, "The method" bullets or "R6 rules that bite") and each naming its reference file. Use only rules the checked files state. SKILL.md style: no person names, dates or quotes; plain short sentences. Do not change or contradict existing rules; where research differs from a rule, leave that in the reference file. Prefer sharpening an existing rule over adding a new one, and keep SKILL.md under about 210 lines.
 d. Update the frontmatter description only if a new capability needs naming, keeping it under 1024 characters.
3. ${ROOT}/README.md: in the roblox-r6-animation section, name the new reference topics in the same style.
4. ${ROOT}/CHANGELOG.md: add an entry at the top (below the intro paragraph, above the newest entry) headed "## 2026-10-14 - roblox-r6-animation: acting, micro-motion, body types and game animation direction research, run 2 (user-authorized)", in the style of the existing entries: the new files and what each covers; per file how many findings were judged and kept; the SKILL.md changes.
5. ${SK}/projects/research-in-progress.md: in "Runs", mark run 2 done with the date and the finished files; delete the lead lists under "#### acting-and-performance.md", "#### human-micro-motion.md", "#### body-types-and-scale.md" and "#### game-animation-direction.md" for finished files; keep everything else. Remove ${DR} if it is empty.
6. Save: stage and commit exactly the paths you changed or deleted, with the subject "roblox-r6-animation: integrate run 2 research (sources, SKILL.md, README, CHANGELOG)", and push. ${GITRULES}

${TIME(35)}

Return the structured result.`, { label: 'integrate', phase: 'Integrate', schema: INTEG, effort: 'max' })

phase('Critic')
const critic = await agent(`${AUTH}

${SKILL}

${QUALITY}

YOUR TASK: critic for run 2. Read the new files ${done.map(d => SK + '/references/' + d.t.file).join(', ')} and run git diff ${BASE} -- ${SK} ${ROOT}/README.md ${ROOT}/CHANGELOG.md in ${ROOT} to see every change of this run. Do not edit anything. Report concrete issues (file, line, problem, fix):
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

Save: stage and commit exactly the files you changed, with the subject "roblox-r6-animation: fix run 2 critic findings", and push. ${GITRULES}

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
