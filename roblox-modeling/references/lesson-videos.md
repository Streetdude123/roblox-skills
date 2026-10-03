# The three lesson videos (assigned 2026-10-03)

Lepy sent these three videos when he asked for this skill. They were studied in full (transcript through the player's own caption request, plus frame grids in the built-in browser). The notes below are a summary in my own words, followed by how each idea is applied in this skill.

## 1. "6 key principles for 3D modeling" - CG Cookie (Jonathan Lampel), youtu.be/OVbIOHAI3iY, 11 min

Six rules that hold for any model:

1. **Form.** Get the overall shape right first; it is the hardest part. Complex shapes are combinations of simple ones, so a primitive blockout helps when stuck. Build the most defining features first (a jaw line, a sharp crease, a key curve) and fill the rest later. Use references for proportion, but do not live inside orthographic model sheets: orbit in perspective, because a model that lines up in front and side views can still look wrong in 3D. Start with as little geometry as possible; extra detail added too early makes the form lumpy.
2. **Detail.** Detail comes in primary, secondary and tertiary sizes (the video points to Neil Blevins' article on this). Mix large, medium and small detail, and leave rest areas with no detail. Work in passes over the whole model: all big forms, then all medium detail, then all small detail. Working one region to completion makes the regions disagree.
3. **Scale.** Model at real scale. It keeps lights, simulations, procedural textures and bevels consistent between files. Check thickness and bevel size against references too: an object with the right outer size but thick parts and fat bevels still reads smaller and wrong.
4. **Adaptation.** Keep the model easy to change: non-destructive modifiers (solidify, bevel, mirror), light meshes, topology that supports the planned deformation, and pivots and orientation set up for animation.
5. **Reuse.** Mirror and array modifiers, duplicates of finished parts, linked instances (Alt+D) instead of copies (Shift+D), particles. Hide repetition with changes of rotation, scale and UV offset or random material values per object.
6. **Surface quality.** Shading shows topology faults: pinches, bumps and warps mean the topology does not follow the form. For subdivision models keep quad loops around sharp edges, use n-gons only on flat areas, avoid triangles until there is a reason, keep normals consistent, and place poles (vertices with five or more edges) with care.

**How this skill applies it:** blockout and passes are steps 1 and 2 of the method; real scale is 1 unit = 1 stud with the R6 dummy in every render; reuse is `dup` + `place` and stacked UVs for copies; surface quality is checked on the matcap render and by `audit` (n-gons, slivers, open edges).

## 2. "3D Modeling Workflow for Games - Explained" - FlippedNormals, youtu.be/eS6gI1bAvPA, 15.5 min

The game asset pipeline, shown on a stylized handheld device (frames studied; the auto captions were mis-detected as Dutch, so the speech was reconstructed from fragments and frames):

1. **Blockout.** A rough version of the final model that fixes shape, silhouette and scale; whole game levels are blocked out first to test how they play. Beginners and intermediates should always block out.
2. **Low poly.** The model the engine renders, optimized for its use. Budget depends on how close the camera gets: a small background object needs little; a first-person weapon is always on screen and gets the best density. Low-poly models can also be stylized and colour-only.
3. **High poly.** A dense model with the detail; too heavy for a game. Made with subdivision; a subdivided cube collapses into a sphere unless support loops sit close to the corners (shown in Blender, 3ds Max and Maya).
4. **UV unwrapping.** Cut seams, unfold, and place the islands in the 0-1 square: no stretching (check with a checker texture), seams hidden where they will not be seen. Overlapping islands share texture space (more density, less unique detail); the video's asset uses a clean unique layout.
5. **Baking.** Transfer high-poly detail into maps on the low poly: the normal map (fakes the high-poly shape in lighting), ambient occlusion (soft contact shadow, also a mask), curvature (convex and concave edges, a mask for wear), and position (a top-to-bottom gradient for dirt or dust). Bakers: inside the 3D apps or in xNormal, Marmoset Toolbag or Substance Painter.
6. **Texturing.** Image maps for colour, roughness, metalness and the rest, painted in Substance Painter or similar, with stickers and screen graphics made in Photoshop.

**How this skill applies it:** the sword and chest examples follow it step for step - high and low built side by side, per-part bakes, the same mask set (ID, AO, curvature from the normal map, position), and a layered composite instead of Substance.

## 3. "Every 3D Modelling Concept, Explained" - Digitalist, youtu.be/bChytx8PHvU, 11 min

A tour of the whole toolset:

- Meshes are vertices, edges and faces. Start most models from a cube: a sphere or cylinder brings triangles and poles from the start.
- Core tools: cut (loop cut), extrude, inset (window frames), bridge, bevel or chamfer (custom profiles allowed), merge and weld (merge by distance), knife, mirror.
- Booleans: union, intersect, difference. They create awkward topology on polygon meshes; CAD (parametric, math-based) geometry handles them cleanly.
- Sculpting for organic forms. The few brushes used most: standard, clay build-up (block-out, muscles), crease or pinch (wrinkles, eyelids, nails), flatten or scrape, grab or move, mask; stamp and curve brushes for attachments and ropes. Start from a base mesh; dynamic topology adds geometry as you sculpt; multiresolution keeps levels so big changes and fine detail can alternate.
- Sculpts and CAD models are too dense for games: retopology. Manual (most control), voxel remesh (grid size controls detail), quad remesh (all quads, sometimes ugly loops), adaptive remesh (detail where needed), decimation (quick, triangle soup), and guided remesh (draw the edge flow, the tool fills it).
- Procedural modeling keeps the recipe: modifier stacks (array, smooth, shrinkwrap, cloth...) and node systems (Blender geometry nodes, Houdini).
- Instances share one mesh in memory; real duplicates can change independently. Modular kitbash parts and instancing keep large scenes cheap.
- Level of detail: simpler versions at distance.

**How this skill applies it:** booleans are used for cuts and chips with the topology cleaned by bevel or triangulation; the rock uses voxel remesh plus decimation as an automatic retopology; Roblox does its own LOD (RenderFidelity Automatic switches at 250 and 500 studs), and draw calls batch for MeshParts that share a mesh and a SurfaceAppearance.
