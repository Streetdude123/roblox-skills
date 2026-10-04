# Bake and texture

Textures are authored like a Substance Painter layer stack, but in code: bake mask maps once, then compose colour, roughness and metalness in numpy. Changing a colour or a wear amount then costs seconds, not a re-bake.

## Mask maps (all float images, Non-Color)

| Map | How | Use |
| --- | --- | --- |
| ID | high parts carry materials named by layer (Wood, Iron, Brass, Gem, Rivet...); swap each to an emission colour from `rbx.ID_COLORS`, bake EMIT selected-to-active with **margin 0**; `rbx.ids_of` classifies | which layer stack a texel gets |
| Normal | per-part bake from the high, 12-16 samples, margin = half the island spacing | the final normal map; curvature source |
| AO | per-part bake from the highs, lows invisible to rays, world AO distance 0.25-0.9 studs | cavity dirt, rust, tarnish; a soft multiply in colour |
| Curvature | `rbx.curvature(normal_img, k)` - divergence of the tangent normal, 0.5 = flat | edge wear and polish (> 0.55), cracks (< 0.4) |
| Position | `mask_bake(pos_build(lo, hi))` on the joined low | 3D noise with no UV seams; height gradients |
| World normal | `mask_bake(nrm_build())` or EMIT from the highs | dust and moss on top faces |
| Edge (mid-poly only) | `mask_bake(edge_build(radius, gain))` - Cycles Bevel node against the true normal | edge wear when there is no high poly |
| Tint | float face attribute `tint` per part, `mask_bake(attr_build("tint"))` | per-plank and per-part variation |
| Coverage | `rbx.coverage(ob, size)` - white emission, margin 0 | which texels belong to islands; drives dilation |

Bake on CPU Cycles; keep `samples` low (1 for ID, position and coverage; 12-16 for normals; 32-48 for AO).

## Composite recipes (sRGB 0-1 values; `C(r,g,b)` = /255)

Common noise: `n1 = fbm(P, 1.2, 4)` large, `n2 = fbm(P, 6)` medium, `n3 = fbm(P, 24)` fine. Stretch the coordinates for direction: `fbm(P * [1.2, 34, 34])` gives grain along X.

- **Painted metal** (crate): base paint x (0.92 + 0.16 n1); wear = `sstep(0.3, 0.55, edge * (0.55 + 0.9 n2))` reveals bare steel C(168,168,165), metal 1, rough 0.28; a lighter paint rim just before the wear (x 1.28) makes edges read at distance; grime = `sstep(0.12, 0.65, (1-AO)(0.6+0.8 n1))` darkens 50% toward C(46,37,29), rough +0.16; dust on up-facing texels toward C(170,158,134).
- **Polished steel** (blade): C(192,194,197), metal 1, rough 0.15 + 0.1 brushed noise stretched along the blade; a honed edge band from the position map, brighter C(216,218,222) and rough 0.08; small nicks from `sstep(0.8, 0.85, n3)` in the edge band.
- **Iron** (chest straps): C(60,60,62), metal 1, rough 0.5; polished convex edges toward C(150,150,152), rough -0.2; scratches = `sstep(0.7, 0.74, fbm(P * [60, 4, 60]))`; rust in cavities toward C(112,58,30), rough +0.3, metal 0 where rust > 0.5.
- **Brass and gold**: C(212,166,86), metal 1, rough 0.3; tarnish in cavities toward C(82,80,52) as a dielectric; polished edges toward C(246,214,140), rough -0.12.
- **Wood**: C(128,84,50) or dark C(72,46,30); per-part tint multiplies value and shifts hue; grain lines darken 30%; vertical water streaks darken 25% on side faces; edges worn lighter toward C(170,120,78); cavities darker; rough 0.68.
- **Leather**: C(96,60,38) strap, C(46,30,22) core; convex wear lighter C(140,98,64); AO darkening between turns; rough 0.55-0.62.
- **Stone** (terrain): C(126,120,112) x large noise; faint strata bands (8%); cavity dirt (45%); faint edge highlight (20%); moss only on steep tops C(74,102,42); damp band near the ground; rough 0.84. In bright Roblox lighting use a darker base (90-110).
- **Gem**: flat-shaded facets in the low, C(168,14,30), rough 0.05; an EmissiveMask can make it glow.

- **Lacquered armor (samurai, from the pick's own maps)**: base sRGB (44, 10, 7), roughness 0.44, metal 0. Wear only on strong edges (`sstep(0.7, 0.86, CV)` with a patch noise) toward (88, 40, 30) at 0.4; an edge lift of (8, 4, 3); sparse isotropic scratches (`fbm(P * 40)` above 0.76). Scratches stretched along one axis (`P * [60, 60, 5]`) read as wood grain on plates; do not use them on lacquer.
- **Chainmail (texture height, no geometry)**: rows of overlapping ellipse rings, spacing 0.05 stud, radii 0.55 and 0.4 of the spacing, wire half-width 0.2 of the spacing, odd rows offset by half a spacing; keep the strongest ring per texel and brighten the upper half of each ring. Gaps (18, 17, 16), wires (50, 48, 45) to (90, 87, 82), roughness 0.95 to 0.65, height 0.006 into `rbx.height_normal`. Round rings with a wide profile read as honeycomb.
- **Straw weave (texture height)**: checkerboard of over and under strands, 0.045 stud cells, height 0.006.

Finish: multiply colour by a soft AO (0.72 + 0.28 AO for dielectrics, 0.85 + 0.15 AO for metals); clamp roughness to 0.04-1; threshold metalness to 0 or 1.

## Cache the masks, compose many times

A character bake took 24 minutes on this machine (Blender used 1.9 GB and paged). Save every mask array after the bake (`np.savez_compressed(out/masks.npz, I, AO, NB, CV, PP, NW, TN, GID, COV)`) and add a `compose` stage that rebuilds the lows (same seed, so the same UVs), checks the coverage against the cache, loads the arrays and runs only the composite, the renders and the export. A texture round then costs minutes. Blender's UV pack is not repeatable between runs (a rebuild gave a 22.6% coverage mismatch), so also save the joined lows' UVs (`uvs.npz`) after the bake and write them back in the compose stage; check that the coverage mismatch is 0. `scripts/blender/restore_export.py` re-exports the FBX and JSON from a saved .blend (Blender keeps the previous save as .blend1) when a run overwrote them. Any change to the low geometry makes the cache invalid.

## Painted graphics (eyes, crests, brows, emblems)

Paint each shape as a signed distance `d` in studs (negative inside) from the position map, and convert it to coverage with a one-pixel ramp: `cover(d) = clip(0.5 - d / w, 0, 1)`, with `w` = one texel in studs (0.0035 at 300 px/stud). Then blend: `col = col * (1 - m) + C(...) * m`. Boolean masks (`col[mask] = ...`) gave stair-stepped samurai eyes in v1.
- Shapes: circle `hypot(u, v) - r`; ellipse `(hypot(u / a, v / b) - 1) * min(a, b)`; a stroke along a curve `abs(v - curve(u)) - half_width`; a region between two curves `max(v - upper(u), lower(u) - v)`; cut any shape to a span with `max(d, u - u1, u0 - u)`.
- Clip inner shapes by the outer coverage (`iris = cover(d_iris) * opening`), so the lid line hides the top of the iris.
- Anime eyes that read stern, not cute: a narrow almond (height about 0.25 of the width), the outer corner higher, a thick upper lash line that gets thicker toward the outer corner and ends in a wing, a thin lower line on the outer half only, a crease line above, the iris top hidden under the lid, two highlights, brows thick at the inner end and slanted down toward the nose.

## PBR value ranges

- Non-metal albedo: sRGB 50 (charcoal) to 240 (fresh snow); keep most surfaces 60-200.
- Raw metal reflectance: sRGB 180-255 (70-100%); dark "metal" is paint or oxide, so dielectric.
- Metalness 0 or 1; mixed values only in thin transition pixels.
- Roughness: polished 0.05-0.2, used metal 0.3-0.5, paint 0.45-0.6, wood and leather 0.55-0.75, stone 0.8-0.9.

## Margins and dilation (the gutter rule)

Islands sit `px` pixels apart (5-8 at 1024). If a bake margin is wider than half of that, one island's padding overwrites the neighbour's gutter and texture filtering pulls the wrong colour into the edge (the chest's brass brackets got a red fringe from the gem). So:
- ID and coverage: margin 0.
- Normal and AO: margin 2 (half of 5 px spacing).
- After composing every final map (colour, roughness, metalness, normal): `rbx.dilate(map, coverage)` fills each gutter pixel from the nearest island pixels, 24 rings deep, so mipmaps stay clean.

## Output for Roblox

Save colour as sRGB PNG; normal, roughness and metalness as Non-Color PNG. One material slot on the exported mesh. In Studio these go into one SurfaceAppearance (ColorMap, NormalMap, RoughnessMap, MetalnessMap); 512 px is often enough for medium props, 1024 for hero props.
