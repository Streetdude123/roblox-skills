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
