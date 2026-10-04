---
name: roblox-modeling
description: Model, texture and export 3D assets for Roblox in Blender at a professional standard - props, weapons, items, accessories, character parts, terrain pieces and VFX meshes. Use for any Roblox mesh work - style scan of the target game, blockout at stud scale, hard-surface mid-poly with weighted normals, high-to-low normal map bakes, organic rock and terrain forms, controlled imperfection, UV layout and texel density, PBR textures composed from baked masks, triangle budgets, FBX export, Studio preview through EditableMesh, Import 3D, and the review renders that prove the result.
---

# Roblox modeling

The target is a model that a Roblox studio would ship: it matches the game's style, reads from the player camera, holds the triangle and texture budget, and looks made by a skilled artist, not by a generator. All modeling runs in Blender 5.2 through Python (background mode); Studio is the final check.

## Lepy's standard (read first, every time)

He set these rules on 2026-10-03 while this skill was built. They override any default in this file.

1. "Super advanced professional level" - portfolio quality, not a proof of concept.
2. Characters, props, weapons and items: bring out creativity and intricate detail - layered primary, secondary and tertiary forms, ornament, trims, rivets, straps, engraving, inlays.
3. Terrain (rocks, cliffs, ground pieces): dial the intricacy down - clean big forms, few strong breaks, quiet texture.
4. "Perfect but not too perfect" - every model gets a controlled imperfection pass (see [imperfection.md](references/imperfection.md)).
5. "Scan the game before you make models" - run the style scan and write a style brief before the first vertex (see [style-scan.md](references/style-scan.md)).
6. "Please use references, just like how you animate use heavy reference" - no blockout before he picks a reference. Show 6-8 numbered candidates on one sheet, he picks, then match the pick closely: silhouette, proportions, layer order, piece shapes, colour blocking. Make the design original (no copy of a named character), but take every construction decision from the pick. The samurai v1, designed without a picked reference, got "The clothing looks horrible and the proportions are terrible".
7. Characters stay faceless unless he asks for a face (samurai, 2026-10-03: "keep it faceless").
8. "Much better, i really like this remember how you built this" - for every character, follow [character-from-reference.md](references/character-from-reference.md): numbered picks, a measured spec from the pick, the pick's own texture values, questions on conflicts, plate frames, and the side-by-side check before the bake. In the same sentence: "the model has to be significantly more detailed and intricate complex" - the first rebuilt samurai was not detailed enough even after rule 2.
9. "looks good already, make sure to store what you learned in the modeling skill please, this type of modeling should be the baseline minimum for modeling, unless the game's style or quality calls for quality less of this" (2026-10-04, on the finished samurai). The samurai is the minimum standard for every model: a picked reference matched closely, high-to-low bakes with intricate high-only detail (lamellar scallops and grooves, stitching, lacing, rivets, slots, twisted rope, strands), texture height for fine patterns, a layered composite with values sampled from the reference, controlled imperfection, audit at zero open and non-manifold edges, a side-by-side check before the bake, and a real Import 3D check from the player camera. Go below it only when the target game's style scan shows a simpler or lower-fidelity style; say so in the style brief.

Log every sentence of his feedback in [taste.md](references/taste.md) and push the skill folder.

## Start with the actual task

1. **Target game.** Find which place the model is for. Run `scripts/studio/StyleScan.lua` (read only) and take player-camera captures. Write the style brief: stylized or realistic, textured or colour-driven, palette, saturation, edge treatment, triangle density, lighting. A model that ignores the brief is wrong even when it is well made.
2. **Reference (heavy, picked by him).** Collect candidates before modeling: finished Roblox models of the same kind (ArtStation, Sketchfab, X posts of Roblox artists), the game's own assets for style, real objects for construction. Put 6-8 on one numbered sheet in the built-in browser, let him pick, then keep the pick open during every pass and compare the blockout and each render with it side by side. Name the reference in the report.
3. **Class and budget.** Classify the asset and take its budget from the table below. Ask about anything the request leaves open that changes the result (size, style, budget, use as tool or prop).
4. **Scale and frame.** 1 Blender unit = 1 stud. Front faces Blender -Y, Z is up. An R6 character is 5 studs tall (legs 2, torso 2, head 1); put `rbx.dummy()` beside the model in every review.
5. **Read the references** for the method: [lesson-videos.md](references/lesson-videos.md) (fundamentals Lepy assigned), [roblox-specs.md](references/roblox-specs.md), and the reference for the asset class.

## Budgets

| Class | Triangles | Texture | Visible texel density | Method |
| --- | --- | --- | --- | --- |
| Small prop (cup, tool, bolt box) | 300 - 1,500 | 256 - 512 | 50 - 80 px/stud | mid-poly or flat colour |
| Medium prop (crate, barrel) | 1,500 - 4,000 | 512 - 1024 | 60 - 110 px/stud | mid-poly + mask texture |
| Hero prop or item (chest, shrine) | 4,000 - 8,000 | 1024 | 80 - 130 px/stud | high-to-low bake + mask texture |
| Held weapon | 800 - 3,000 | 512 - 1024 | 200 - 400 px/stud | high-to-low bake |
| Rigid accessory (UGC) | max 4,000 (Roblox limit) | max 2048 | - | single mesh, watertight |
| Character body (UGC) | max 10,742 total, head 4,000 | max 2048 | - | R15 parts, cages |
| Terrain cluster | 1,000 - 3,000 | 1024 | about 50 px/stud | cleaved block + coded sculpt |
| VFX mesh | 50 - 800 | gradient or scroll texture | - | sweep with unit UVs |

Hard limit: 20,000 triangles per mesh. Roblox's own texture guide is 256 px for a 5 x 5 stud object, 512 for 10 x 10, 1024 for 20 x 20 (about 51 px/stud). Weapons near the camera may go higher.

## The method

1. **Blockout at scale** with primitives. Check the silhouette from the Roblox camera (70 degree FOV, about 12 studs behind the player) with the R6 dummy. Fix proportion here, not later.
2. **Work in passes over the whole model**: big forms, then secondary forms, then small detail. Do not finish one corner first (CG Cookie principle 2).
3. **Choose the carrier for each detail** by its size on screen: silhouette and anything over about 6 screen pixels at review distance is geometry; surface detail goes into a high poly and is baked; anything smaller is texture.
4. **Hard surface**: mid-poly (bevel modifier with harden normals + weighted normal modifier, no normal map) or high-to-low bake. Recipes, segment budgets and traps: [hard-surface.md](references/hard-surface.md).
5. **Organic and terrain**: cleaved block, voxel remesh, coded displacement; or the flat-shaded vertex-colour variant. [organic-and-terrain.md](references/organic-and-terrain.md).
6. **Imperfection pass**: small rotations, offsets, uneven gaps, chips, dents, per-part tint, uneven wear. [imperfection.md](references/imperfection.md).
7. **UV**: chart seams, hidden-face shrink, stacked copies, multi-object pack, cut long islands. [uv-and-texel.md](references/uv-and-texel.md).
8. **Bake and texture**: per-part bakes against matched high parts, mask maps (ID, AO, normal, curvature, position, world normal, per-part tint), a layered composite in numpy, coverage dilation, one material with colour, normal, roughness and metalness maps. [bake-and-texture.md](references/bake-and-texture.md).
9. **Review loop**: render the sheet (high clay, low wire, low with normal map, beauty front and back, close-up, Roblox camera, UV over colour), read the audit numbers, fix, and render again. [review.md](references/review.md).
10. **Export and Studio check**: FBX for Import 3D, mesh JSON and raw maps for the local EditableMesh preview. [studio-preview.md](references/studio-preview.md).

## Definition of done

- The style brief exists and the model matches it; the reference is named.
- The review sheet was read and fixed at least twice; the report shows the final sheet and the numbers: triangles (low and high), visible texel density, UV use, materials = 1, open edges = 0, non-manifold edges = 0, size in studs, pivot.
- The model was checked in Studio (preview or import) from the player camera in the target game's lighting, and the check objects were removed afterwards.
- His feedback is logged in taste.md and the skill folder is pushed to `Streetdude123/roblox-skills`.

## Tools in this skill

- `scripts/blender/rbx.py` - the library. Building: `box`, `cyl`, `lathe`, `sweep` (profile along a path, world or unit UVs, per-point up vectors), `loft`, `prism`, `extrude_x`, `cleaved`, `torus`, `dome`, outlines (`chamfer_rect`, `rect`, `circle`, `leaf`, `trefoil`, `star`, `offset2d`, `fillet`, `resample`), `orient`, `place`. Modifiers: `bevel`, `wn`, `tri`, `cut`, `apply`, `join`, `tidy`. UV: `chart_seams`, `uv_unfold`, `cut_rings`, `pack_parts`, `visibility_parts`, `stack_uvs`, `same_topology`, `shift_tagged`. Bakes: `bake`, `bake_ids`, `mask_bake` with `edge_build`, `pos_build`, `nrm_build`, `attr_build`, `coverage`. Texture maths: `fbm`, `voronoi`, `vdisp`, `sstep`, `curvature`, `dilate`. Review: `audit`, `workbench`, `studio`, `world`, `camera`, `look_from`, `shot`, `wire`, `sheet`, `uv_sheet`, `dummy`. Export: `fbx`, `mesh_json`.
- `scripts/blender/examples/` - five finished builds that show each method end to end: `samurai.py` (the baseline: R6 character from a picked reference, stages block, highs, full and compose, 16,670 low and 610k high triangles, sheet in `references/sheets/samurai.png`), `crate.py` (mid-poly hard surface), `sword.py` (high-to-low bake), `rock.py` (terrain), `chest.py` (intricate hero prop with imperfection - the reference for item quality). Their final review sheets are in `references/sheets/`. The crate and the sword were made before the imperfection rule; apply imperfection.md when you use them as a base.
- `scripts/blender/preview_export.py` - raw 512 px maps and mesh JSON for the Studio preview.
- `scripts/studio/StyleScan.lua` - read-only style scan of a place. `PreviewMesh.lua` - builds a preview MeshPart from served data under the local camera. `serve_preview.js` - chunked local file server.

Run a build: `& "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --factory-startup --python <script> -- out=<folder> tex=1024`.

## Traps measured on this machine

- EEVEE crashes Blender on Lepy's Vega 11 GPU (compute shaders fail, access violation). Render with Workbench (clay, matcap, wire) and CPU Cycles (beauty, bakes). Cycles has no GPU device here.
- Never render through the Blender MCP socket (deadlock). Build in `blender.exe --background`.
- Smart UV Project splits every bevel strip into its own island (46% UV use on the crate). Chart seams fixed it.
- A boolean adds an empty material slot from the cutter; `tidy()` after every join and every boolean apply.
- In Blender 5.2 the EXACT solver returned an EMPTY mesh when the cutter was several separate pieces joined into one object (the katana guard vanished); MANIFOLD (now the `rbx.cut` default) and FLOAT cut it correctly. If a part has 0 faces after a cut, suspect this first.
- Removing an object can leave a stale view-layer entry; `only()` refreshes the layer first.
- Stacked UV copies must be duplicates of one master moved by a rigid transform; separately built copies can order loops differently (the chest feet broke this way). `stack_uvs` checks the topology.
- Bake margin wider than half the island spacing lets one island's padding overwrite another's gutter (red gem fringe on brass brackets). Bake IDs with margin 0, normals and AO with half the spacing, then `dilate` from the coverage mask.
- Bevel after a boolean chip cut tore the high poly; cut chips last in the stack.
- Uniform cell noise reads as crumpled foil and regular strata read as a beehive; terrain needs big cleaved planes.
- Studio lighting with bloom and colour correction lifts mid-grey albedo a lot; judge colour in the target game's lighting.
- Local ports 8766, 8768 and 8771 were held by servers from other sessions; scan for a free port before starting a server.
