# Organic forms and terrain

Lepy: terrain is dialed down - clean big forms, few strong breaks, quiet texture. Characters, creatures and hero organic items get the full detail treatment.

## Terrain rock (example: `examples/rock.py`, final pass 2,158 triangles)

1. **Base: a cleaved block.** `rbx.cleaved(name, size, cuts, seed)` starts from a box and slices it with 9-12 random planes on the top and sides (`bisect_plane` + `holes_fill`), keeping the bottom flat on the ground. This gives the big planar facets real rock has. A convex hull of random points gave diamond outlines with spikes; do not use it for rocks.
2. **Weathering:** voxel remesh at size/110 and a light smooth (factor 0.5, 2 iterations) to round the cut edges.
3. **Coded sculpt** with `rbx.vdisp(ob, fn)` (moves vertices along their normals by a numpy function of position and normal):
   - one strata direction shared by the whole formation; 2-3 broken ledges on side faces only (`sstep(0.8, 0.97, frac(t / h))` with h = size/3.2, masked by a noise so ledges break up), depth 0.02 x size;
   - sparse shallow cracks: `voronoi` F2 - F1 near zero, masked to about a third of the surface by low-frequency noise, depth 0.01 x size;
   - broad undulation 0.06 x size; fine grain 0.004 studs;
   - no displacement near the ground (`sstep(0, 0.12 * size, z)`), so the base stays planted.
4. **Low poly:** Decimate (collapse) to the budget, smooth shading with sharp edges at 75 degrees, chart seams at 65 degrees.
5. **Formation:** one main stone about the player's height or taller, two side stones leaning on it, a broken slab, a ring of pebbles. Bake contact AO with all the highs together.
6. **Texture:** see Stone in bake-and-texture.md. Faint strata, cavity dirt, moss only on steep tops, a damp band at the ground. No lichen speckle, no cell patterns.

What failed and why (keep away from these):
- Uniform Voronoi cell displacement made every stone look like crumpled foil.
- Seven regular ledges looked like a beehive or masonry.
- A curvature mask from fine grain drew crack lines everywhere.
- At its first size the main stone was knee-high on the R6 figure; terrain landmarks need player-height scale.

## Stylized flat variant

The cleaved blocks themselves, triangulated and flat shaded, with a face-corner byte colour attribute (`Col`): stone grey with random value per face, green on faces that point up more than 0.6, darker underneath. 528 triangles for the whole formation, no texture. At the Roblox camera it read as natural rock as well as the baked one did, and it is the better choice for colour-driven games.

## Characters and creatures (method, not yet practised in this skill)

- Base mesh with box modeling or the Skin modifier plus subdivision; keep loops around joints (shoulders, elbows, knees) for deformation.
- High detail by multires or by coded displacement; retopology by Quad Remesh with guides, Shrinkwrap on a hand-placed cage, or decimation for static parts.
- Bake normals and AO like hard surface. For R6 rigs, each limb is its own mesh around its Motor6D; for skinned rigs, max 4 influences per vertex.
- The Roblox character limits are in roblox-specs.md.

## Lush ground fill (Shinsenkyō Eishū, measured 2026-10-06)

- Terrain Grass decoration at quality 21 stands about 2 studs. Anything lower is invisible under it: flat flower carpets (cards 0.15 to 0.7 studs high) cost 2.4 ms on screen and showed nothing. Ground flowers must stand 2.5 to 5 studs: upright crosses of the carpet texture cells (2.0 to 2.9 studs), lilies, plumes at 1.3x, orchids at 1.8x.
- Fill the floor on the client, not with server instances: tiles of 12 x 12 studs (490 to 1,220 triangles, 6 variants over two atlases) on a hashed grid around the camera (cell 13, range 75), plus a near clutter layer (cell 11, range 85: ferns, leaves, small fungi, pebbles) and a far layer (cell 20, range 180: giant flowers, shrubs, tree ferns, tall fungi). Pool the clones, raycast terrain only, keep Grass with normal Y over 0.8, skip spots within 5 studs of server props. An on/off test measured 1 to 1.5 ms for all three layers together.
- Keep collidable scenery (rocks, logs, stumps) on the server at a lower density; the client layers carry the density.
- The canopy leaves were the main cost (646k of 1.56M scene triangles, 8 ms GPU), not the fill. Read `Stats.SceneTriangleCount`, `RenderGPUFrameTime` and `RenderCPUFrameTime` with each group hidden by `LocalTransparencyModifier` to find the cost before you cut anything.
- Check the fill per view with a capture from the player camera and a hue count; the Eishū views read 10 to 12 of 12 hue groups.

## Wasteland set (Shinsenkyō Hōjō, 2026-10-06)

- Dead trees from code: a trunk tube with root fins and knots, primary limbs at 0.55 to 0.7 of the trunk radius, three levels of crooked branches (a sharp kink on about 1 in 5 segments, a light droop), arched roots that start on the trunk wall and end under the ground. Thin limbs (under 0.5 of the trunk) read as a young sapling, not a dead tree. 1,700 to 5,900 triangles each.
- Stone stacks: icosphere stones with fbm noise, 2 to 4 random plane cuts for flat broken faces, flattened top and bottom, each stone placed on the top of the last. Smooth pebbles read as a zen garden; the cuts make them read as rough volcanic stone.
- A canon detail with no anime frame (the Sōshin stacks) still goes on the sheet as a text tile with the wiki quote, next to real photos for the build.
- Set pieces as Models with children at local offsets; the placer snaps each child to the terrain at its own XZ, so one template fits any slope.

## Paved courtyards on terrain (Shinsenkyō Hōrai, 2026-10-06)

- A palace court of 1,000 x 1,200 studs is terrain, not parts. Give it a texture with a MaterialVariant override: a variant with BaseMaterial Pavement and the paving maps, then `MaterialService:SetBaseMaterialOverride(Enum.Material.Pavement, "HoraiPaving")`. Pick a terrain material the rest of the map does not use, because the override is global.
- Swap the court surface with `Terrain:ReplaceMaterial(region, 4, Slate, Pavement)` in strips of 248 studs. The occupancy stays, so the floor height does not move. A path is a second unused material (Concrete) with its own variant, written the same way.
- Values that read from the player camera: slabs (Poly Haven large_grey_tiles) at StudsPerTile 22 with contrast 0.8 and mean 112,110,104; the lighter central way (floor_tiles_02) at StudsPerTile 16, mean 178,172,160. At contrast 1.2 the slabs read as a checkerboard.
- A moat: carve only the four arms (FillBlock Air 16 high, Mud floor 3, Water 5.5). Do not carve the whole box and refill the island with FillBlock: FillBlock writes full occupancy, and the court surface voxels hold partial occupancy, so the refilled island would not match the court height.
- Studio in the background shows none of this: focus it and wait 6 s before a capture.

## Statue faces from an SDF (Shinsenkyō golden heads, 2026-10-06)

- A smiling closed eye is a groove shaped like an arch (middle higher than the corners) between an upper lid dome and a lower cheek bulge. A socket cut under the lid leaves a pit that reads as an open eye.
- Brows whose inner ends sit lower than the arch, plus a nose bridge that reaches the brows, read as a frown. Raise the inner ends, start them wider apart, and fill the glabella with a soft ellipsoid.
- A laughing mouth: a cavity with a top edge that curves up at the corners (`Z + 0.195 - 0.9 X^2`), the upper teeth set just behind the lip, a tongue deeper inside. Teeth that sit flush with the lips read as a closed slit.

## Big terrain in strips (2026-10-07, Shinsenskyō region pass)

He asked for the first region "2.5x wider" with 10-12 open clearings of 150-250 studs for fights, "a LITTLE bit less flowers", and ruins in every valley of the second region.

- A 3,328 x 3,328 numpy heightmap (13,312 studs at 4 studs per cell) with 20 float fields needs about 3 GB; on a 6 GB machine with Studio open it does not fit. Generate the terrain in strips of 256 rows with a 16-row halo (the halo keeps gradients, smoothing filters and neighbour minima correct at the seams), write the tiles of each strip, and drop the strip. The same terrain at r < 5,000 took 70 s and under 1 GB.
- Scatter scripts that need the fields keep only float16 copies of the few fields they use (height, a validity mask, forest density, slope, gradients).
- Clearings: a list of (x, z, radius); blend the height toward a 31-cell box blur inside the clearing (flat but not a plate), paint grass, and keep trees, patches and client clutter out by the same list (one shared module on the client).
- Memory: a far forest belt does not need server parts. Ground patches became a client layer (a grid cell around the camera, a raycast to the terrain, tilt to the normal), which removed 9,150 server parts. Trees with collision stay on the server.
- Studio Play holds the Edit, Server and Client copies: 33.6M terrain cells, 7,558 trees and 10,000 prop parts made Studio commit 7.8 GB on a 6 GB machine; it paged and the forest frame went from 36-47 ms to 60 ms median. Measure free memory and paging (Pages/sec) next to every frame time.
- Ruins: build pieces as separate models with a pivot at the base, place them in clusters along the valley axis, sit each on the lowest of five ground hits, and keep them off the gameplay slots.
