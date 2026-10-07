# Changelog

Maintenance history for this repository. Entries were previously kept as dated
`CHANGELOG-*.md` files inside the `roblox-resource-acquisition` package; they
now live here so the shipped skill package carries only what an agent using it
needs.

## 2026-10-07 - Region pass: big terrain in strips (user-authorized)

- roblox-modeling: `references/organic-and-terrain.md` adds "Big terrain in strips" (strip generation with a halo for a 13,312-stud heightmap on a 6 GB machine, float16 fields for scatter, clearings from one shared list, ground patches as a client layer, Studio Play memory with three copies, ruin placement). `references/taste.md` logs his approval of the A2 hair ("looks good, get to work on regions now").

## 2026-10-06 - Sculpted clump hair and the bangs rules (user-authorized)

- roblox-modeling: `references/hair.md` adds rules 9 and 10 (the cut fits the character's life - a convict is unkempt, no groomed middle part; bangs straight and clean to the eye line, never wavy or wet) and "Construction: sculpted clumps" (mass with dome and whorl bump, lens-section blade clumps on centripetal Catmull-Rom paths with transported frames and buried point roots, voxel union, decimated low, a baked hair-flow attribute for the strand texture) with the traps found while building it. `SKILL.md` rule 10 names both rules and the method. `references/taste.md` logs "try not a middle part, a convict wouldnt have well maintained hair, maybe bangs, like toji sort of" and "those bangs look stupid, stop making it wavy and wet, straight and clean to the eye level."

## 2026-10-06 - Hair rules moved into the modeling skill (user-authorized)

- roblox-modeling: `SKILL.md` rule 10 (hair is designed, not generated: reference pick, big-medium-small, tapered blades with thickness, flow from the part and the crown whorl, no visible scalp, painted strand texture) and the meaning of "push what you learned" (write the lesson into SKILL.md and its reference, then push). `references/hair.md` rewritten: rules first, his verdicts on the four rejected hairs, the research (design, modeling, real hair, texture, Roblox UGC), study method, measurements, the coverage test, traps, and the rejected constructions kept for their numbers. `references/character-from-reference.md` points hair work to `hair.md`. `references/taste.md` logs "Push what you learned and remake your hair for the convicts" and "I mean push what you learned to the modelong skill".

## 2026-10-06 - Hair research after "Your hair design is horrible" (user-authorized)

- roblox-modeling: `references/hair.md` adds "No gaps" (part-line roots, roots tucked into the scalp, a ray coverage test that grows filler locks, a blended comb at the crown, the green-cap test render) and "Research 2026-10-06: what good hair needs" (why the gravity-drape hair failed, measured against stylized hair guides, real hair growth and natural fall, the Roblox UGC middle-part study, five rules for every new hair, and the sources). `references/taste.md` logs "Fill this gap" and "Your hair design is horrible, search up hair design modeling tips, real life hair, and modeling hair tips online".

## 2026-10-06 - Hair from catalog and anime study (user-authorized)

- roblox-modeling: new `references/hair.md` (study method with hair-only catalog search, `InsertService:LoadAsset` test heads and FOV-26 captures; measured pro and anime hair sizes; the volume-mass plus thick-clump construction; traps such as crown spikes, face-corner panels, one-eye fringes and the 14-colour ID palette; hair shading values). `references/taste.md` logs his four hair messages ("tacky", "look at real professional ugc hair", "needs more volume ... gabimaru's hair, lelouch's hair ...") and the island change request.

## 2026-10-06 - Shinsenkyō convict picks and the first convict review (user-authorized)

- roblox-modeling (later): `references/taste.md` logs his HA1 hair pick and the originality call ("aren't these supposed to be original convicts?"): each convict keeps the archetype and clothing language of its canon pick, but hair colour and cut, colour scheme and signature items are new; variants go on a numbered sheet.
- roblox-modeling: `references/taste.md` logs his convict picks (P3 + P6 combo, designs A2 B2 C2 D2 E2 F1 G1 H1, faceless, giants at the same height), the body-frame answers (B1, then B2 slim R6 blocks, then shorter and wider after the A2 review), the size rule (scale every part together, never stretch single limbs), and the A2 review ("more detail please more complex design", hair "so flat", then "tacky"): hair now gets its own numbered reference sheet before it is modeled.

## 2026-10-06 - Shinsenkyō Hōrai outer section (user-authorized)

- roblox-modeling: `references/bake-and-texture.md` adds "Several assets in one Blender run" (hide finished assets during AO bakes, smooth SDF meshes before a metal bake, cache the high mesh, gold values for Roblox light); `references/organic-and-terrain.md` adds "Statue faces from an SDF" (smiling eyes, brows that do not frown, a laughing mouth).

## 2026-10-06 - Shinsenkyō Hōrai court and the "keep going" instruction (user-authorized)

- roblox-modeling: `references/taste.md` logs "Start now" and "Just leep goi" (start the character work at once and keep working without stopping, except for his picks); `references/organic-and-terrain.md` adds "Paved courtyards on terrain" (MaterialVariant overrides on unused terrain materials, ReplaceMaterial strips, slab values that read from the player camera, moat arms, focus Studio before a capture).

## 2026-10-06 - Shinsenkyō Hōjō valleys and the player character request (user-authorized)

- roblox-modeling: `references/taste.md` logs his request to replace the player characters with custom R6 convict models (new convicts with heavy inspiration from the anime's convicts, correct proportions, a numbered sheet for each design, after Hōjō); `references/organic-and-terrain.md` adds "Wasteland set" (code-built dead trees, stone stacks with plane cuts, text tiles for canon details with no frame, set pieces that snap each child to the terrain).

## 2026-10-06 - Shinsenkyō Eishū colour and ground fill (user-authorized)

- roblox-modeling (later): `references/taste.md` logs his approval of the Eishū fill ("Beautiful i love it").
- roblox-modeling: `references/taste.md` logs four requests from the Eishū pass (far more colour and flower species, the whole colour wheel, more than 8 colours in every view, no empty ground and more props) and what fixed the last one; `references/organic-and-terrain.md` adds "Lush ground fill" (terrain grass hides anything under about 2 studs, tall meadow tiles and two client clutter layers measured at 1 to 1.5 ms, collidable scenery on the server, find the cost with `Stats` and `LocalTransparencyModifier` before you cut).

## 2026-10-06 - Shinsenkyō island ambient effects (user-authorized)

- roblox-vfx-craft: new `references/ambient.md` (canopy light shafts from real gaps, butterflies as beams on moving attachments after moving parts measured 2 ms per 30, zone mist with Atmosphere and ColorCorrection presets, beam axis and `Segments = 1` facts, the MCP camera reset); `scripts/ambient/` gains the island builder and the `Shafts`, `Butterflies` and `Mist` modules; `scripts/paint/` gains the wing, body and shaft painters; `SKILL.md` and `references/taste.md` log the canon requests.

## 2026-10-05 - Shisenkyo lobby request (user-authorized)

- roblox-modeling (later): `references/taste.md` logs his lobby picks (LOOK 2 sunset canon, SHIP S1 bezaisen, plan v1, the name Shinsenkyō) and the rule that a lobby is a living scene (dense props, wind, fire, water, life and sound).
- roblox-modeling: `references/taste.md` logs the Hell's Paradise lobby request (canon selection beach at Edo, semi-realistic models in the spirit of MAPPA's art, no rush) and the note to read the open place name from Studio instead of asking.

## 2026-10-05 - lobby loading screens, top bar and gamepad checks in Play (user-authorized)

- roblox-ui-design: `references/taste.md` logs the loading-screen picks (join screen with a tower parade, teleport screen with a map card, the title, progress bar, tips and SKIP, the six tips, the Forest arrival script); `references/verification.md` adds section 9 (check full-screen UI in Play against the real top bar with `GuiService.TopbarInset`, the Roblox player list, the selection leak when a selected button hides, the mirrored second touch in the touch emulator, the Controller Emulator key map and its Studio warning, probe and attribute methods for short screens); `SKILL.md` adds the two traps.
- roblox-ui-design (later the same day): `references/components.md` adds the built recipe for the join, teleport and arrival screens; `references/taste.md` logs the switch and publish answers (lobby v1360, Forest v189).

## 2026-10-04 (late night, lobby shop) - shopkeeper cutscene, counter shop, emote picks, custom prompt (user-authorized)

- roblox-ui-design: `references/taste.md` logs the shop redesign picks (counter cutscene, tap to skip, counter carousel, the stat hexagon kept), the custom prompt pick (key chip + word), and four traps (BillboardGui buttons in the touch simulator, prompt style changes on a shown prompt, prompt line of sight under an occluder, a child named Name).
- roblox-r6-animation: `references/project-style.md` logs the Forest lumberjack idle picks and grip rules, and the shopkeeper mood emotes (picks, uploads, and his praise for the Roblox catalog emote style, with the note that those clips are references, not authored clips).
- roblox-modeling: `references/taste.md` logs the shopkeeper outfit pick, the figurine base from the stand mesh, and the rules on coplanar overlapping parts (z-fighting) and rig root transparency.

## 2026-10-04 (night, lobby) — Untitled TD 4x lobby and talking dummy villagers (user-authorized)

- roblox-modeling: `references/taste.md` logs the 4x lobby plan pick and the villager picks from a numbered sheet of Toolbox dummies (one shared body in the towers' colours, the variety in what they wear and hold, player size, classic smile), with the staging and capture method and the rule to ask when his words and a pick conflict.
- roblox-ui-design: `references/taste.md` logs the speech bubble pick; `references/roblox-ui-engine.md` adds the NPC speech bubble recipe (offset-sized BillboardGui, `SizeOffset` so the bottom edge sits on the offset, `AlwaysOnTop`, typed text with `MaxVisibleGraphemes`).

## 2026-10-04 (evening) — Noob King clips published and wired, entrance cutscene (user-authorized)

- roblox-r6-animation: `references/quality-review.md` adds the one-frame arm flip when a raised-arm hold blends with a down-arm clip (start holds under the attack clip at full weight, lower the arm with a reversed clip) and the one-shot that drops to the rest pose before the next clip (play the next clip underneath). `references/project-style.md` logs his "Publish the clips" and the Play measurements after wiring.
- roblox-vfx-craft: `references/taste.md` logs the entrance cutscene build: the hole driven by the hands, the hidden King with a ghost in the homeland view, the gold light-gathering template, and the lessons on the dialogue panel, shot framing under letterbox bars, the font warm-up and the Play capture crop.

## 2026-10-04 (late) — Noob King clips: planted steps, arm crosses, live holds (user-authorized)

- roblox-r6-animation: `references/r6-mechanics.md` adds the arm-cross shoulder gap and its post-pass fix, scaled rigs (offsets times `Torso.Size.Y / 2`), stance changes as foot target tracks with steps, and the rule that a forward lunge step needs the torso turned toward the stepping hip. `references/principles.md` adds the numbers for a long dramatic hold and periodic noise for looped trembles. `references/project-style.md` logs the King clips shown before publishing.
- roblox-vfx-craft: `references/taste.md` logs the Noob King scene rework request, the audio requirement and the side-view rift fix.

## 2026-10-04 (night) — Forest cutscenes: radio dialogue, rift portal, camera clearance (user-authorized)

- roblox-vfx-craft: `references/taste.md` logs the cutscene requests and picks (portal with the homeland seen through it, letterbox + CRT, freeze during scenes), the video request, the thinner rift frame, "super cinematic", the dialogue under the letterbox bar and the camera collisions, with the clearance check method (oriented-box distance, terrain rays, line of sight) and the reveal path numbers.
- roblox-ui-design: `references/taste.md` logs the instance-tree rule, the emoji icons replaced by flat pixel icons, the radio panel text fitting facts and traps, and the DisplayOrder rule for dialogue over a cutscene layer.
- roblox-modeling: `references/taste.md` logs the lobby reminders and the portal and homeland model requests.
- roblox-r6-animation: `references/project-style.md` logs the Noob King animation request, his picks and the order of work.

## 2026-10-04 (evening) — Lobby stud village, detailed towers, preview VFX, Shop on phones (user-authorized)

- roblox-modeling: `scripts/studio/stud/` (part builders `Village.lua`, `Towers.lua` with `tower2` and `roundTower2`, `Paths.lua`, and the plan and colour tools) and `references/stud-maps.md` (style read, plan-first rule, colour by sampling, traps). `references/taste.md` logs his reference pick, the plan answers, the walk-time target and the tower detail request.
- roblox-vfx-craft: `scripts/ambient/PreviewFx.lua` (themed map preview portals) and `scripts/ambient/fade_server.js` (edge fade for a decal image through EditableImage, a PNG server and `upload_image`); SKILL.md feedback entry with the numbers and three traps; `references/taste.md` logs "make the VFX stronger" and the edge fade request.
- roblox-ui-design: `scripts/examples/ShopPhoneLayout.lua` (a phone `Layout` module for an authored scale-built panel) and the SKILL.md file entry; `references/taste.md` logs the Shop phone fix, the result screen and dialogue picks, and the always-use-the-skill rule.

## 2026-10-04 (later) — UI: Forest-style result screens and lobby, the frost meter rule (user-authorized)

- roblox-ui-design: `references/taste.md` logs "Make sure the frost meter only appears if the frosty peaks map is loaded though when it's selected in the lobby" and what was built for Untitled Tower Defense: win/lose screens rebuilt from clones of the upgrade panel (striped header, stat cells, green and red buttons side by side for 44 px+ phone targets, a 720 x 456 cap so desktop keeps the old size), the lobby Shop restyled to the Forest tokens without renames, queue billboards moved from `Instance.new` code to a template, and an open phone-layout issue.
- roblox-modeling: `scripts/studio/StyleScan.lua` read `CollisionFidelity` on plain Parts and failed; it now reads it only on `TriangleMeshPart`. `references/taste.md` notes the lobby map case for rule 9.

## 2026-10-04 — Modeling: the samurai is the baseline (user-authorized)

- roblox-modeling: `SKILL.md` rule 9 and `references/taste.md` log "looks good already, make sure to store what you learned in the modeling skill please, this type of modeling should be the baseline minimum for modeling, unless the game's style or quality calls for quality less of this". The finished `scripts/blender/examples/samurai.py` (R6 character on a picked reference; stages block, highs, full and compose; 16,670 low and 610k high triangles; 0 open and 0 non-manifold edges) is now the minimum standard, with its sheet in `references/sheets/samurai.png`. New: the mask cache plus saved UVs for compose rounds (Blender's UV pack is not repeatable), `scripts/blender/restore_export.py`, `scripts/studio/ImportAlign.lua`, the verified Import 3D flow and the backlit-baseplate light check in `references/studio-preview.md`, the lacquer, chainmail and straw recipes, and the boolean and lathe traps.

## 2026-10-03 (after midnight) — Modeling: the character-from-reference method (user-authorized)

- roblox-modeling: new `references/character-from-reference.md` (numbered picks from the ArtStation and Sketchfab search APIs, a measured spec from the pick's views, the pick's own texture values sampled in the browser, questions on conflicts, plate frames that build the low and the high, colour views from the pick's angles side by side before the bake) and `scripts/blender/examples/samurai.py` (R6 heavy lamellar samurai on the user's pick: plate frames, rope sweeps with a twisted high, brass slots, tie loops and rivets in the high only, chainmail height turned into normals). `rbx.height_normal` converts a UV-space height map into the tangent normal; `rbx.mat` sets the viewport colour; more ID colours. `SKILL.md` rule 8 and `references/taste.md` log "Much better, i really like this remember how you built this but the model has to be significantly more detailed and intricate complex".

## 2026-10-03 (end of night) — Modeling: heavy references, faceless characters (user-authorized)

- roblox-modeling: `SKILL.md` rules 6 and 7 and `references/taste.md` log "The clothing looks horrible and the proportions are terrible, keep it faceless" and "Please use references, just like how you animate use heavy reference" (after the samurai v1): no blockout before the user picks a reference from a numbered sheet, match the pick closely, faceless characters unless asked. Lessons from the samurai work: `rbx.cut` defaults to the MANIFOLD solver (EXACT returned an empty mesh with a joined multi-piece cutter), `pack_parts(boost=...)` for hero islands, painted graphics as signed distances with a one-pixel ramp, tapered sweeps need evenly resampled paths, polished metal renders black in the dark studio rig, `rbx.mat` sets the viewport colour for Workbench colour renders, new helpers `loft_open`, `ring_sample`, `rr`, `coverage` and `edit_mode` diagnostics.

## 2026-10-03 (late night) — New skill: roblox-modeling (user-authorized)

- roblox-modeling: new skill. Studied the three assigned videos (CG Cookie's six modeling principles, FlippedNormals' game modeling workflow, Digitalist's modeling concepts) and researched the Roblox Creator Docs (mesh, texture, SurfaceAppearance, export, Importer and its 25:7 stud-per-meter change, MeshPart fidelity, collision, performance, rigid accessory and body budgets), the Polycount wiki on face weighted normals and texture baking, the Blender 5.2 manual and PBR value ranges. Built and reviewed four practice models in Blender: a mid-poly crate, a high-to-low longsword, a terrain rock formation and an ornate chest with controlled imperfection, then previewed them inside Studio through EditableMesh and SurfaceAppearance (sizes matched Blender exactly). `references/taste.md` logs the user's modeling feedback: professional level, intricate detail on items, calm terrain, not too perfect, and a style scan of the game before modeling.

## 2026-10-03 (night) — New skill: roblox-ui-design (user-authorized)

- roblox-ui-design: new skill. Studied the five assigned videos (Jesse Showalter's C.R.A.P., Kole Jain's UI/UX concepts, Riot's UI design episode, BiteMe Games with Rive, Design Doc's inventory UX) and researched the Roblox UI docs (styling, UIShadow, UIStroke and UIGradient updates, flex, insets, ViewportDisplaySize, PreferredInput, accessibility settings), staff guidance on scaling, Refactoring UI, the Laws of UX, Material and Apple motion, Microsoft's TV guidelines and game HUD design. Device numbers come from `StudioDeviceSimulatorService` presets and the PlayerModule touch-control source. Tools: `Build.lua`, `Ui.lua`, `Fit.lua`, `Preview.lua`, `Devices.lua`, `Audit.lua`, `Install.lua`, `serve.js`, `icons.html`, `capture/` and `examples/PixelLab.lua`, proven on an Undertale-style sample captured on phone, tablet, desktop and Xbox presets (two fix rounds, audits clean, first open 0.3-7.2 ms). `references/taste.md` collects every UI sentence of the user's feedback since 2026-08.

## 2026-10-03 (late) — Skinned Bone rigs in Blender (user-authorized)

- roblox-r6-animation: new `references/skinned-bone-rigs.md` (why the first Chara pass looked buggy: the collarbone posed as the upper arm, unbent elbows, a knife turning in the hand, a review camera in front; the IK pose solver with blade-driven hands, chest-frame channels, hair and vine springs, metrics on 17 joints, an 18 degree player camera and preview colours) and `scripts/blender/` (`pose3.py`, `rtools.py`, `clip_tools.py`, `video_render.py`, `grid.ps1` and the Chara clip specs as worked examples). `references/project-style.md` logs "Make sure you actually uss real references from undertale or something" and "These animations look super buggy, unnatural, and just isn't as cool as i expected, fix it".

## 2026-10-03 — Every high-rated Toolbox pack plus web VFX (user-authorized)

- roblox-vfx-craft: `SKILL.md` rule and feedback log entry: for every kit, use all the high-rated VFX packs on the first Toolbox page and search the internet for more effects and textures.

## 2026-10-01 (late) — Upper-body abilities, in-between keys (user-authorized)

- roblox-r6-animation: `references/project-style.md` logs Crit's review of the warrior Brave Slash and Guard Up (in-between keys that bridge the poses, take time on quality, no leg keys on upper-body abilities because the warrior moves during them, no cape keys) and the R6 limit that a torso twist turns the walk legs.

## 2026-10-01 (night) — Less VFX, faster punches (user-authorized)

- roblox-vfx-craft: feedback log entry (his sentence, only the parry clash kept, a small fist glint replaces every punch effect, the Glint numbers).
- roblox-r6-animation: `references/project-style.md` logs the faster pace (server hit 0.40 -> 0.28, retime only before the hit) and the lesson on stretched wind-ups.

## 2026-10-01 (evening) — Pick videos per move, limb gap check (user-authorized)

- roblox-r6-animation: `SKILL.md` reference step 3 now asks for one labeled video per move, a limb-to-torso gap check on every frame (over 0.12 studs is dropped), no R15 clips on R6, and labeled mirror or slide-removed fixes when no clean clip exists; `references/project-style.md` logs his sentences about the pick videos, the picks, the wind-up bridge and the mirror method.

## 2026-10-01 (later) — Always animate from a reference (user-authorized)

- roblox-r6-animation: `SKILL.md` opens with "Always animate from a reference" (his rule of 2026-10-01: every clip, not only locomotion, starts from a reference he picks, from anime clips or the Toolbox; the five steps from search to report); `references/project-style.md` logs the pass 2 requests and picks (camera-facing 4-way walk and run, look pitch, copied Toolbox locomotion played by a synced phase) and the traps found while solving the punch rework.

## 2026-10-01 — Scripter Combat Trial: fist chain, parry, punch kit sounds (user-authorized)

- roblox-r6-animation: `references/project-style.md` logs his sentences for the trial (phases, Deepwoken reactive parry, the enemy AI, the video at the end) and six lessons: the up Euler form for a fists-up R6 guard, aiming strikes against the forward lean, the hook from the torso sweep, a forearm bar that clears the face, a long telegraph on a 0.4 s server wind-up, and a client clip player that fades in on play age with additive flinches.
- roblox-vfx-craft: `SKILL.md` feedback log entry (white and gold hit, clash, tell, guard and daze templates from two Toolbox packs; both known backdoors found again with their ids; the gold-blooms-white fix; Bloom threshold 2 on a new Baseplate; first-cast frame numbers); `references/sound.md` gains "Punch kit" (ProSoundEffects ids with measured onsets and placement).

## 2026-09-30 (fourth pass) — Verix legs shrink instead of sliding into the body (user-authorized)

- roblox-r6-animation: `scripts/QuadRig.lua` takes per-leg scale about the runtime hip pivot (`V.read(model, pivots)`, `geo.scale`, `V.legPoint`, `gait.tuck`/`needTuck` for the slide limit); `references/custom-rigs.md` gains "Legs that shrink instead of sliding into the body" (runtime scaling from the playing tracks, the get-up per-leg curves and the planted-foot trap, the async `RegisterKeyframeSequence` trap); `references/project-style.md` logs his sentences (videos, legs, a much simpler GUI).

## 2026-09-30 (third pass) — Verix re-rigged, rig transfer, crouch walk (user-authorized)

- roblox-r6-animation: `references/custom-rigs.md` gains "Moving clips between two rigs of one model" (exact transfer by matching part frames, 0.00001 studs), "Crouch walk" (0.6 s at 3 studs/s, two review rounds with the leg swing numbers) and movement lessons (camera-follow turning without AutoRotate, lean from physics, four-ray terrain tilt, preload against the first-play delay); new `scripts/RigTransfer.lua`; `references/project-style.md` logs his sentences and his designer's; `SKILL.md` lists the new script. Also carries unpushed 2026-09-30 warrior notes from another session (`references/pipeline.md`, `references/weapons.md`, `references/project-style.md`).

## 2026-09-30 (second pass) — Warrior Brave Slash and Guard Up (user-authorized)

- roblox-r6-animation: `references/weapons.md` gains "A horizontal slash keeps the wrist" (solve the contact grip once, then only the arm; edge along the sweep tangent; the blade hides behind the torso from a camera straight behind); new `scripts/blender/wa.py` (numpy FK, sword solver with a fixed grip, leg and reach solvers for background Blender); `references/project-style.md` logs his picks (two slash clips, shield on the left fist only in Guard Up, walk speed 8).
- roblox-vfx-craft: `references/taste.md` logs his brief (gold like the model, tech hard-light for the lore, redo the wave, add sounds), the textures that read in gold, the squash-before-rotation trap and the two backdoor families found in the packs.

## 2026-09-30 — Welded carry in idle and walk, edits in Blender (user-authorized)

- roblox-r6-animation: `references/weapons.md` gains "A carried weapon is welded in idle and walk" (one constant weapon pose shared by the idle and the walk; a carry may leave the shoulder joint but must touch the body, measured per frame); new `scripts/blender/contact_fix_bg.py` (background Blender: weld the grip, slide the arm onto the torso side, smoothed); `references/project-style.md` logs his sentences, including the rule that every clip edit is made in Blender and shown before import; earlier unpushed files from 2026-09-29 are included (`references/video-rotoscope.md`, `scripts/loco_author.py`, `scripts/offline/warrior/`) with `references/principles.md` updates.

## 2026-09-28 (fourth pass) — Slash and cut sounds (user-authorized)

- roblox-vfx-craft: `references/sound.md` gains "Slash and cut sounds" (swish, cut and impact layers; licensed Sever Metal Hit and Sword Whip picks with measured peaks, skips and volumes; the high-pass check); the `SKILL.md` feedback log and `references/taste.md` carry his sentence.

## 2026-09-28 (third pass) — Flashier by default, particle-heavy samurai moves (user-authorized)

- roblox-vfx-craft: `SKILL.md` gains the rule "Flashier by default" and his sentences; `references/dragon-twister-lions-passage.md` gains "Particle pass" (a painted lion spirit sprite replaces the mesh head, LockedToPart spinning carriers for a particle tornado, burst numbers, what washed out or hid the hero, first-cast frame times) and recording traps; new `scripts/paint/lion.py` (a public-domain line art to a glowing sprite) and `scripts/BuildFx3_samurai.lua` (the particle templates); `references/taste.md` logs his sentences.
- roblox-r6-animation: `references/project-style.md` logs the Phoenix rework (leap, spin, dive, lunge; checks); `references/weapons.md` gains root motion as one `clip.root` field and the double-mark trap; `scripts/samurai/` updates ClipPhoenix.lua, Strip.lua (fresh module copies, root motion) and adds Anim.lua; `scripts/video/encode_av.html` fades the audio in and out.

## 2026-09-28 (later) — Dragon Twister and Lion's Passage (user-authorized)

- roblox-vfx-craft: new `references/dragon-twister-lions-passage.md` (a spin-in-place tornado and a dash-through with a late cut: far-side slash flashes, the dragon sweep, the lion impression scaled by camera distance, the Poppercam trap and Invisicam for the caster, checks); the `SKILL.md` feedback log and `references/taste.md` carry his sentences.
- roblox-r6-animation: `references/weapons.md` gains "Root motion in a three-sword move" (`spin` and `dash` clip fields, blade tips after a dash, busy time); `scripts/samurai/` adds ClipTwister.lua and ClipLion.lua, `K.monotone` in ClipKit.lua and the new shots in TakeCam.lua; `references/project-style.md` logs his sentences.

## 2026-09-28 — Three swords, a flying sword wave, videos with sound (user-authorized)

- roblox-r6-animation: `references/weapons.md` gains "Three swords: two hands and one in the mouth" (a free-model katana as a grip joint, the mirrored left-hand solver, the mouth sword on the Head, an upper-body stance loop over the Animator's legs, readability from behind); `scripts/WeaponRig.lua` adds `Rig.mirror` and `Rig.solveLeft`; new `scripts/samurai/` (the three-sword clip kit, Caliber Phoenix clip, stance loop, an Edit strip and onion tool for any Motor6D rig, the take probe); `scripts/video/record_audio.ps1` (WASAPI loopback placed by QPC time) and `scripts/video/encode_av.html` (crop, H.264 + AAC mux); `references/pipeline.md` item 9 documents takes with sound and cinematic cuts; `references/project-style.md` logs his sentences.
- roblox-vfx-craft: new `references/caliber-phoenix.md` (a flying sword wave on the move rung: beats, recoloured beam crescent, feather beams, trail and streak traps, warm-up in view, checks); `references/sound.md` gains licensed ProSoundEffects picks with measured onsets and the Skip technique; `references/textures.md` and `scripts/paint/` add the feather and trail painters; the `SKILL.md` feedback log and `references/taste.md` carry his sentences.

## 2026-09-27 (pivot) — Pivot in place with angular momentum (user-authorized)

- roblox-r6-animation: `references/custom-rigs.md` gains "Pivot means turning in place" (creep speed, eased angular momentum, brake then pivot, pivot clips baked turning in place); `scripts/QuadClips.lua` pivot gaits at v 0.5 and 180 deg/s; `references/project-style.md` logs the feedback.

## 2026-09-27 (last) — Pet-sim egg hatch and egg carousel (user-authorized)

- roblox-vfx-craft: the `SKILL.md` feedback log and `references/taste.md` gain the Wacky Pets pass: a ScreenGui hatch scene built from 2D sprites (particles never draw inside a ViewportFrame), rarity tiers for wobbles, charge, shake and hold with measured frame times, a tilted pet carousel around the egg with per-pet silhouettes, and the traps found (BillboardGui adornee set before parenting, absolute `Model:ScaleTo`, visible templates in a Folder, the four-frame spotlight seam, Beam `TextureSpeed` direction, capture stalls).

## 2026-09-27 (late night) — Ragdoll get-up blend, Humanoid momentum (user-authorized)

- roblox-r6-animation: `references/custom-rigs.md` gains "Get-up from a physics ragdoll" (sphinx start pose, capture and hold the ragdoll joints in PreSimulation, stand the root in PreAnimation, measured 2.8 degrees worst frame) and "Momentum for a Humanoid creature"; `scripts/QuadClips.lua` adds the GetUp clip; `references/project-style.md` logs his sentences.

## 2026-09-27 (night) — Custom quadruped rigs, seamless baked loops (user-authorized)

- roblox-r6-animation: new `references/custom-rigs.md` (non-R6 Motor6D rigs: Humanoid R15 + HipHeight setup, the rigid-leg foot solver with the corner raise, ground flow for straight and turning gaits, girdle drop and pitch, gait numbers for walk, half-bound sprint, pivot and crouch, limits of a rigid hind block); new `scripts/QuadRig.lua` and `scripts/QuadClips.lua` (the tested Verix example); `scripts/Poser.lua` loops sample wrapped time, `life` noise runs on a circle of the loop length, `bake` takes a warm-up pre-roll; `references/pipeline.md` documents the bake warm-up; `references/project-style.md` logs his sentences and the Verix numbers.

## 2026-09-27 (later) — Replicating a reference image by measurement (user-authorized)

- roblox-vfx-craft: new `references/textures.md` (camera solve, freeze frame, size/shape/colour scoring against the image, traced outline and occupancy, per-direction colour maps, one emitter per ember, painters, engine facts); new `scripts/reference-match/` (compare, shape, cells, embers, outline, colormap, texscore, reach, refcrown2, tracecrack, column); `scripts/PaintTextures.ps1`, `scripts/DrawShapes.ps1`, `scripts/serve_textures.js`; `scripts/Eruption/` (Cast module, click client, relay server, final textures); `references/taste.md` and the `SKILL.md` feedback log carry his sentences.

## 2026-09-27 — Tools held by the engine grip, two-handed mop scrub (user-authorized)

- roblox-r6-animation: `references/weapons.md` gains "A tool held by the engine grip" (blend the RightGrip weld C1 during a clip, why a square fist cannot mop, the two-handed long-handle pose family, the gimbal carry key, breakdowns that keep a floor contact out of the floor, the hand-back to a running Animator, replication); `references/project-style.md` logs his sentences and the mop scrub numbers; `references/pipeline.md` notes the source-server ports other sessions hold.

## 2026-09-29 (later) — Warrior idle, walk and run rebuild; RigFeet for custom rigs; weapon grip in a run (user-authorized)

- roblox-r6-animation: new `scripts/RigFeet.lua` (planted feet from any rig's own leg geometry) and `scripts/WarriorClips.lua` (the Licensed To Strike warrior idle, walk and run on the lesson-video method, gait feet, built for the game's real speeds); `references/pipeline.md` documents both, the speed and stance-length limits and grid-aligned loop bakes; `references/weapons.md` gains the grip rule for a held weapon in a running arm and his forward-pointing preference; `SKILL.md` lists the scripts and two new rules; `references/project-style.md` logs his sentences and the numbers.

## 2026-09-29 — Lesson videos: the 12 principles, timing and spacing, beginner mistakes, a beginner method (user-authorized)

- roblox-r6-animation: new `references/lesson-videos.md` (four videos Lepy assigned, studied from full transcripts and frame grids, each translated to Poser: timing-meaning table, favour keys, pull-back, settle, bounce, stepped time for an animatic look, a hand-off checklist); `SKILL.md` gains the seven core rules, the reference row and the checklist step; `references/sources.md` lists the videos; `references/project-style.md` logs his sentence.

## 2026-09-26 (night) — Whole-body turn and flip channels, trail cleanup rule, Dragon Form R and T (user-authorized)

- roblox-r6-animation: `references/pipeline.md` documents the `turn` and `flip` root channels; `references/project-style.md` logs his sentence and the Vortex and Tail numbers.
- roblox-vfx-craft: `SKILL.md` feedback log (trails off on finish and interrupt, giant constructs to the side of the player camera, multi-hit keys by instance).

## 2026-09-26 (later) — R6 two-handed lance, whole-body spin, skewer throw, kit piece colours (user-authorized)

- roblox-r6-animation: `references/weapons.md` gains the measured R6 two-handed spear rules (chest-centre rear hand, shaft 25 to 45 degrees across the chest, side-on torso, per-frame front-hand solve, the shaft slide); `references/project-style.md` logs his sentences and the lance combo, spin and skewer numbers and traps.
- roblox-vfx-craft: `references/water.md` section 10 (Toolbox kit pieces in the form moves, recolour near-black meshes on water, a small see-through whirl, rise geysers from the floor); `SKILL.md` feedback log entry.

## 2026-09-26 (final) - Finder split into its own skill (user-authorized)

- New skill `roblox-sfx-finder`: `find.py`, `build.py`, `Audition.lua` and the references `sources.md`, `frieren.md`, `layering.md` moved here from `roblox-sfx-synth`, with its own `check.py` (reads any format) and `requirements.txt`. `build.py` loads synth presets from `roblox-sfx-synth` only for `synth` layers.
- `roblox-sfx-synth` restored to synthesis only (`SKILL.md`, `recipes.md`, `check.py`, `requirements.txt` as first added).

## 2026-09-26 (latest) - roblox-sfx-synth finds real sounds first (user-authorized)

- `roblox-sfx-synth`: `scripts/find.py` searches BigSoundBank, freesound (CC0), Mixkit, 効果音ラボ and Kenney, downloads, measures and ranks results with licenses, and searches the Roblox Creator Store partner library (ProSoundEffects, APMOfficial). `scripts/build.py` layers found recordings and synth presets from a JSON recipe through pedalboard and writes credits. `scripts/check.py` reads any audio format. `scripts/Audition.lua` measures store IDs in Studio (untested). New references `sources.md`, `frieren.md`, `layering.md`. `SKILL.md` rewritten find-first, synthesis last; the user's feedback logged.

## 2026-09-26 (later) - New skill roblox-sfx-synth (user-authorized)

- `roblox-sfx-synth`: a numpy/scipy synth (`scripts/sfx.py`) with 16 anime SFX presets (hits, whooshes, charge/aura/summon, UI), a checker (`scripts/check.py`) for peak, RMS, envelope, band energy, loop seam and a spectrogram PNG, `SKILL.md` with the workflow, rules and measured numbers, and `references/recipes.md`.

## 2026-09-26 — Parry signals, Bull Leap rebuild, smooth walks, clean ragdoll (user-authorized)

- roblox-vfx-craft: attack tells (white, amber, red), parry vs block by value, wall stop for forced motion; his feedback logged.
- roblox-r6-animation: Bull Leap wind-up rebuild, smooth-max walk height (no snap), per-style walks, ragdoll settle and per-part push; his feedback logged.

## 2026-09-25 (later) — Water Mage block rebuilt with the water rules (user-authorized)

- `roblox-vfx-craft`: `references/water.md` section 8 (centre attachments for facing sprites, rim attachments for edge spray, the Glass lens trap, white stacking, the blotchy dark partner, rim-first hit reactions for the player camera, the take camera that turns the body, the cost). `SKILL.md` feedback log and `references/taste.md` log his sentences.

## 2026-09-25 — Water construct research and the Judgement's Hammer rebuild (user-authorized)

- `roblox-vfx-craft`: new `references/water.md` (VFX Apprentice, the Creator Hub waterfall tutorial, DevForum mesh VFX and water threads, Real Time VFX, 2D water animation guides, translated to Roblox: the four water properties, edge break-up, line/fill/shadow/foam layers, the waterfall numbers, mesh VFX practice, and what the hammer rebuild proved: framing for the player camera, a free model hand mesh, fractional torrent textures, camera-facing swing trails, the cost of a big construct). `SKILL.md` gains three rules, the feedback log entry and the reference index line; `references/taste.md` logs his sentences.

## 2026-09-24 (night, final) — Basketball commission feedback (user-authorized)

- `roblox-r6-animation`: `references/project-style.md` logs his sentences on the basketball clips and the code style, with the held-ball method (the ball as a Motor6D keyed in torso space, hands reached after the torso) and the measured numbers.
- `roblox-vfx-craft`: feedback log (`SKILL.md`) and `references/taste.md` ("The kit rule") log his sentences on collecting free VFX packs and a barebones UI, the prize tier template ladder, the confetti texture trap and the first-cast frame times.

## 2026-09-24 (night, last) — Reference study and the water VFX overhaul (user-authorized)

- `roblox-vfx-craft`: new `references/study-atomic.md` (what a Roblox "I AM ATOMIC" recreation does to look amazing: a dark stage in the effect hue, one hue family with white-hot cores, thin lines, an ambient layer in every frame, foreground depth, a rim light, cel textures, repeated shapes, ground reaction, editing; and how it maps to a MOVE rung). `references/taste.md` and the feedback log (`SKILL.md`) gain his sentences (including "Don't copy the text though"), his picks, the water overhaul (dark partner layers, anime sprites from the kit, thin lines, spiral trail streams, lights on caster and target, a casting aura, a dash wake, a real ScreenGui flash) and five traps (Glass hides inner parts, per-frame Trail sampling jags fast spirals, a dark partner inside an orb reads grey, recorder scale 0.6 under memory pressure, F5 when the MCP play start sticks).

## 2026-09-24 (night, later) — Video rule changed; Water Mage video notes (user-authorized)

- `roblox-r6-animation`: `references/pipeline.md` records his new rule ("Record videos from now on please, until i say stop recording videos") and adds step 8 (memory pressure and a warm-up run before takes, hide the cursor, turns that follow the camera, a high rear camera past his accessory); `references/project-style.md` logs the sentence.
- `roblox-vfx-craft`: feedback log (`SKILL.md`) logs the sentence and the water video.

## 2026-09-24 (night) — Water Mage kit: water VFX, wand overlay clips (user-authorized)

- `roblox-vfx-craft`: feedback log (`SKILL.md`) and `references/taste.md` gain the Water Mage entry: the water vocabulary built
  from the kit's water sheets and waterfall beams (bubble, charge, splash, laser), his sentences on the wand, the water VFX,
  the beam start ("cuts off here not smoothly") and the simple selector GUI, and eight traps (disabled template emitters never
  emit from Rate, black-background beam textures need LightEmission 1, a beam must taper and fade in at its source, a glass
  ball reads as a crystal, mist puffs read as smoke, curved long beams do not spiral, muzzle mist hides the beam, name clashes).
- `roblox-r6-animation`: `references/project-style.md` gains the Water Mage entry: upper-body overlay clips over the walk with
  root-space arm and head keys, the wand as a pointer joint, the checks, and three traps (an upside-down union, WeldConstraint
  parts in Edit strips, a hold that overshoots an event).

## 2026-09-24 (later) — Block, parry and guard break clash VFX (user-authorized)

- `roblox-vfx-craft`: feedback log (`SKILL.md`) and `references/taste.md` gain the guard clash entry: white-gold metal sparks
  with Asta's red, new `Clash` and `ShieldBreak` templates from the kit, the layer sizes and counts per kind, the first-cast
  frame times, and five traps (full-size kit stars read as a sparkle field, additive gold blooming to white, red shards
  turning pink, a ring that lay flat, a puppet spawned before the server saw the move).

## 2026-09-24 — Smooth ragdoll, Deepwoken parry, Bull Leap, grounded dash (user-authorized)

- `roblox-r6-animation`: feedback log (`references/project-style.md`) gains the ragdoll smoothness entry (the attacker's
  client runs a ragdolled dummy's physics; a server-run body stepped every 3 to 5 frames) and the 2026-09-24 entry: a
  Deepwoken guard (parry window and block from the press, parry only while stunned after a 0.2 s shaky time, the queued
  block that must re-wait an extended stun), a grounded dash (foot contacts of 2 to 3 frames at 55 studs/s, the `carry`
  swing capped at 0.4 studs, a two-key skid, blade drag angles, a square trailing grip) and Bull Leap (R6 two-hand limits,
  the `lift` root curve, late landing feet), with the measured checks and the camera-lock trap for side takes.
- `roblox-vfx-craft`: feedback log (`SKILL.md`) and `references/taste.md` gain the ragdoll entry and the Bull Leap and dash
  VFX: the reference read, the floor-material crater with an open rear arc, flat slabs, no smear during root travel, kit
  `Wind1` rings instead of view-axis streaks, floor-tinted dust, and how to judge a fast effect (emitter TimeScale 0.08 or
  video) with the frame numbers.

## 2026-09-22 (night) — Weapons on R6 and the Asta anti-magic vocabulary (user-authorized)

- `roblox-r6-animation`: new `references/weapons.md` from the Asta greatsword kit (draw from the grimoire,
  sheathe by a toss into the pages, a four-hit combo): the grip as a three-axis joint (R6 has no visible wrist),
  sword keys written as a hand direction and a blade direction solved on the arm with Nelder-Mead, the physical
  twist limit (the shoulder pivots on the arm's inner edge), Euler branch continuity and slerp midpoints (a
  branch flip sent the blade tip 2.5 studs under the floor), blade tip and turn checks, the onion-skin view,
  props that grow out of props, the memoized solve cache (4.8 s to 0.07 s) and the welded-part resize cost.
  New `scripts/WeaponRig.lua` and `scripts/WeaponStrip.lua`; SKILL.md index and the feedback log updated.
- `roblox-vfx-craft`: feedback log and taste updated with "definitely not electric, just match the vfx with the
  references" and the anti-magic vocabulary built from the kit (black flame wisps over a dark red rim, red
  specks, black ash, red pages), plus the lessons on black puffs, hit placement, untinted kit pieces, a
  floating companion prop and capture time scales.

## 2026-09-22 (late) — Motion-first animation: spline curves, overlap, springs, planted feet, measured (user-authorized)

- `roblox-r6-animation`: rewritten around the measured cause of "too much still frames": Poser's legacy eases
  arrive at zero speed, so every key was a stop (authored moves over 1 s parked 56 to 90% of the time against
  16 to 50% in the professional references). `Poser.lua` gains `curve = "spline"` (auto, flat, smooth, step
  keys with tension), `lag`, `springs` (second order dynamics presets), `life`, a `post` pass, the inertial
  blend, `check`, `dump`, `posesAt` and `each`; legacy clips sample identically. New `Feet.lua` (R6 legs
  planted on floor targets after the torso), `EditStrip.lua` (Edit-mode pose strips and the foot check),
  `LoadTest.lua`, `ExampleClips.lua` (a guard and a right cross built on the method) and `motion_check.js`.
  New `references/motion-metrics.md`; `principles.md` rewritten with the research (posing checklist, timing in
  frames, overlap, moving holds, springs, game feel, recipes); SKILL.md, pipeline, review, sources, template and
  feedback log updated. `tests/test_motion_check.py` covers the Node checker.

## 2026-09-22 (night, last) — Walk2 walk, bladed idle, rigid-leg feet (user-authorized)

- `roblox-r6-animation`: DIO's walk rebuilt on Walk2 (emm1gar) from the user's BestWalkAnimR6 pack after a
  side-strip audition of all four references; `cyclic` hermite key curves, `legDepth` sole-corner body height,
  `legIK` / `dropFor` rigid-leg foot targets for the copied chain, a bladed idle, a landing fold that folds
  legs straight up into the hips. New sections "Planted feet on rigid legs" (r6-mechanics.md) and "Walk2 as
  DIO's walk" (walk-cycles.md); the feedback and the measurements in project-style.md.

## 2026-09-22 (night, later) — The knife throw, the hip rule (user-authorized)

- `roblox-r6-animation`: the hip rule — a limb key's translation is the joint gap; `attachLegs` in
  `scripts/Clips.lua` moves every authored DIO leg placement into the hip angles and clamps a drop at 0.12
  (SKILL.md pass 2, `references/r6-mechanics.md` "Joint gaps", the measurement and the feedback in
  `references/project-style.md`). `DioKnifeThrow` recorded with its numbers and two strip rounds.
- `roblox-vfx-craft`: the knife throw as a MOVE rung piece (`Moves.knives`, `startKnives` / `knifeStep`
  in `MovesServer.lua`): server flown knives that hang while any time stop holds the world and fly at
  the resume, the shimmer and light that keep them visible in the darkened stop, the sounds.

## 2026-09-22 (night) — Rebuild of the lost place, the road roller on the metal (user-authorized)

- `roblox-vfx-craft`: `scripts/RebuildStandPlace.lua` and `scripts/rebuild/` rebuild the whole
  DIO place from a fresh baseplate (kit archive, templates, sounds, the free model rig, dead sounds,
  modules, dummy, bake rig) after the unpublished place was lost. The road roller layout is measured
  with rays over the mesh: DIO on the rear hood, The World pitched 65 down over the front housing with
  its fists 0.3 studs into the metal, every contact effect placed in the roller's frame; the rush glow
  cut so the stand reads as a body. Two Studio traps logged (a runaway bake of a held clip, the
  50k instance kit doubling in play on a 6 GB machine).
- `roblox-r6-animation`: `Poser.bake` refuses a length over 60 s; `Bake.lua` takes a bake length per
  clip and the held `DioPoint` entry; the road roller numbers and the night's feedback in
  `references/project-style.md`.

## 2026-09-22 — Canon ZA WARUDO, the road roller cutscene (user-authorized)

- `roblox-r6-animation`: `DioTimeStop` remade from the show's two frames (arms crossed in an X
  in a forward crouch, then flung up and out into a wide V) after the user rejected the quiet
  one-hand version; the accepted numbers and the two strip rounds are under ZA WARUDO in SKILL.md.
  New `DioRollerUp` and `DioRollerOff` for the road roller with a procedural root;
  `WorldRollerBarrage` leans the stand's raw barrage into the deck. `references/principles.md`
  (animation principles translated to R6) is now in the package. The strip helper needs
  `Character.Archivable = true` in play.
- `roblox-vfx-craft`: `scripts/RoadRoller.lua`, a 12 s cinematic keyed to the RoadRollerDA voice
  line (leap, sky cut, land with the roller in the impact frames, the rush on the deck, the boom,
  the fade); the road roller phases in `references/cinematic.md`; two traps in SKILL.md (the client
  must not restore WalkSpeed the server owns; the impact-frame viewport is a first draw the warm-up
  now covers). Scripts synced: SummonVfx, MovesServer, StandClient, Config.summon.

## 2026-09-21 — The World stand set, raw sequence playback, barrage and time stop (user-authorized)

- `roblox-r6-animation`: new reference `the-world-clips.md` decoding the eight Moon
  Animator clips of a free-model The World (piston punches, a torso-engine barrage at six
  hits a second, end-to-start combo chaining, a 2.5 s float idle, 1 to 2 stud limb
  translations) with the raw decodes under `references/decodes/` and
  `scripts/AnalyzeClips.js` to summarise them.
- `Poser.fromSequence`, `Poser.wrapsOf` and `Poser.sample` play a KeyframeSequence
  through the Poser with no upload; `Clips.lua` now carries the stand float, barrage,
  heavy, combo, time stop and stopped clips plus DIO's bladed point and time stop poses.
- SKILL.md: a stand rush rung in the decision framework, the stand numbers, piston punch
  and combo chaining rules, the still bladed point the user holds, and three feedback entries.
- `roblox-vfx-craft`: The World's time vocabulary (clock gather, tick pop, gold echoes,
  charge and heartbeat idle), the barrage and time stop numbers, the voice-line beat table,
  the dead-mesh diagnosis, and worked examples `Moves.lua`, `TimeStop.lua`,
  `MovesServer.lua` with the reworked `SummonVfx.lua`.

## 2026-09-22 — Added the roblox-r6-animation skill (user-authorized)

- New package `roblox-r6-animation`: SKILL.md, five references (idle-run-land,
  walk-cycles, attack-timing, pipeline, moon-animator) and seven scripts (Poser,
  Locomotion, Clips, ReadClips, Strip, Bake, serve.js).
- Numbers come from decoded KeyframeSequences: a professional idle, run and
  landing set, four community R6 walks, a professional sword kit and the Roblox
  default walk and idle.
- README gained a section for the new package. No changes to
  `roblox-resource-acquisition` or the test suite.

## 2026-08-12 — Review, polish, and repository cleanup (user-authorized)

- `validate_skill.py`: fixed the observable-verb heuristic used by pass-condition
  checks — `send(?:s|sent)?` matched "send"/"sends" but never the past tense
  "sent"; it is now `send(?:s)?|sent`.
- `validate_resource_record.py`: removed a redundant duplicate error — an empty
  `canonical_url` on a verified-acquisition record was reported twice (once by
  the required-fields loop, once by a trailing check that could never fire
  independently).
- Added `tests/test_quality_heuristics.py` locking both fixes.
- Repository cleanup: real README, changelogs consolidated into this file and
  removed from the skill package, `.gitignore` extended, CI workflow added to
  run the test suite.

## 2026-08-12 — PyYAML required, shared module, tests (user-authorized)

### Fix 1 — PyYAML is now a required dependency; fallback parsers removed

The registry, learnings, and record validators previously treated PyYAML as
optional, each carrying a ~200-line bundled fallback YAML parser. The two
parse paths could disagree: a registry entry with a bare `package_id:` was
FAIL (untrusted) with PyYAML installed and PASS (trusted) without it, and 19
of 21 probed inputs diverged (tab indentation, octal-like integers,
case-folded booleans, resolved duplicate keys such as `yes:`/`true:`, block
scalars, anchors). A trust verdict must not depend on which parser happens to
be installed (`references/curated-registry.md`: a malformed entry must not be
silently treated as trusted).

- `MiniYamlError`, `strip_comment`, `split_inline_list`, `parse_scalar`, and
  the flat/record fallback parsers are deleted (~640 lines).
- A missing PyYAML now exits with code 2 and an install hint on stderr
  (exit 1 remains validation failure, 0 pass).
- requirements.txt and SKILL.md `compatibility` now declare PyYAML>=5.4 as
  required.

### Fix 2 — empty-value semantics made deterministic

YAML parses a bare `key:` as null while the templates spell the same intent
as `key: ""` / `key: []`. Values are now normalized before schema checks:
null becomes `""` (or `[]` for declared list fields, including nested dotted
paths such as `resource_proof.unavailable_claims`). This matches the template
spelling and the old fallback's behavior. Required-field checks still reject
empty strings and empty lists, so nothing absent gains trust.

### Fix 3 — shared `scripts/_common.py` module

The four scripts duplicated ~800 lines (URL/host validation ×4, HTTPS policy
×3, sensitive-query regex ×4, version-evidence detection ×2, date validation
×4, YAML loader preamble ×3, file collection ×2), with five behavioral drift
points already present (e.g. `validate_resource_record.py` alone rejected the
plain scalar `say "hi"`). The mechanisms now live once in
`scripts/_common.py`; policy checks and error wording remain in each script.
The scheme comparison is unified on the case-insensitive form.

### Fix 4 — validate_skill.py frontmatter is parsed as YAML

The hand-rolled frontmatter parser rejected any line without a colon and
stripped quotes unconditionally, so a generated skill using a folded
description (`description: >-`) false-failed validation. Frontmatter is now
parsed with the shared duplicate-key-rejecting YAML loader; values must be
scalars and are coerced to strings. Duplicate frontmatter fields still fail.

### Test evidence

- New pytest suite at repository root `tests/` (run `python3 -m pytest`):
  regression tests for the PASS/FAIL trust flip, end-to-end fixture runs for
  all four validators, `_common` unit tests (URL host, HTTPS policy, dates,
  version evidence, duplicate keys), frontmatter folded-value and
  duplicate-key cases, and a missing-PyYAML fail-fast subprocess test.
- Existing 10-case end-to-end CLI suite re-run on Python 3.10 and 3.11: all
  pass with identical verdicts to the pre-change PyYAML path (except the two
  documented empty-value fixes above).

## 2026-08-10 — Validator fixes (user-authorized)

### Fix 1 — validate_skill.py: Alternatives shape heuristic

- Replaced the inline six-verb regex with the named `ALTERNATIVES_DECISION_RE`
  constant covering genuine decision language (preferred/prefers, rather than,
  better fit/suited/choice, sufficient/suffices, is enough, covers the same,
  equivalent, closest, chosen, compared) in addition to the original verbs.
- Strictly more permissive; word-count, vagueness, list-form, and
  explicit-no-alternative paths unchanged. Generic filler prose still fails.

### Fix 2 — validate_learnings_store.py: advisory directive warning

- New `DIRECTIVE_STATEMENT_RE` + `entry_warnings()` emit `WARN:` lines when a
  learning statement reads as an imperative directive (statement-initial
  Always/Never/Ignore/Skip/Do not/Disable/Bypass, or policy-override phrases
  such as "in future runs", "from now on", "ignore the repair budget",
  "skip/bypass/disable verification").
- Warnings are advisory only: exit code, trust, and verification semantics are
  untouched. Factual uses of always/never do not warn.
- references/learnings-store.md updated with one paragraph documenting the
  warning channel and restating the consumption rule it supplements.

### Not changed

- Finding 3 (learnings edit gating is behavioral, one-file-per-observation) is
  a documented property of the design, left as-is.

### Test evidence

- Targeted: 25/25 (testlab/run_targeted.py) — 9 alternatives cases including
  3 negative guards; 8 directive cases including 3 injections, 1 benign
  imperative nudge, 3 factual no-warn guards, 1 pre-existing error case.
- Full harness regression: 67/67 (testlab/run_tests.py), rerun twice to
  confirm idempotence. Seeded child now fails with exactly the 3 real defects
  (alternatives false-FAIL eliminated) and repairs in 4 bounded cycles.

## 2026-09-29 (last) — Clip previews of unpublished clips, camera angle for a forward weapon (user-authorized)

- roblox-r6-animation: `references/pipeline.md` ("Video of a clip") gains the Edit-mode clip preview for unpublished clips, the rear three-quarter angle that shows a weapon held forward, and a check that the take mark sits inside the recording window; `references/project-style.md` logs his video request and what the takes show.

## 2026-09-29 (after the videos) — Brisk warrior walk, a weapon arm that pumps in a run (user-authorized)

- roblox-r6-animation: `scripts/WarriorClips.lua` walk rebuilt for 4.8 studs/s (0.84 s cycle, 2.38 stud stance) and the run's sword arm pumping 2 to 60 degrees with a 15 degree wrist give; `SKILL.md` rules "Held weapon, pumping arm" and "Locomotion speed" updated; `references/weapons.md` and `references/pipeline.md` carry the numbers; `references/project-style.md` logs his sentence.

## 2026-09-29 (run rejected) — Warrior run deleted (user-authorized)

- roblox-r6-animation: `references/project-style.md` logs his rejection of the warrior run; `scripts/WarriorClips.lua` marks its run as a rejected record not to reuse.
