# Hard surface

Two professional methods. Pick by budget and camera distance.

## Mid-poly: bevels and weighted normals (no normal map)

The surface shading comes from real bevels plus custom normals that keep the big faces flat, so there is no bake and no normal map to store. Best for medium props seen at normal distance, and for kits that share one trim or palette texture.

Stack per part (`rbx` calls):
1. Build the base shape with bmesh (prism from an outline, inset panels with `bmesh.ops.inset_individual`, boolean cuts with `rbx.cut(..., solver="EXACT")`).
2. `rbx.bevel(ob, width, seg, ang=30, harden=True, strength="FSTR_AFFECTED", miter="MITER_ARC")` - limit by angle, clamp overlap on.
3. `rbx.wn(ob)` - Weighted Normal, Face Area, weight 50, Keep Sharp, Face Influence (reads the face strength the bevel set).
4. `rbx.smooth(ob)`, then `rbx.apply` and `rbx.tri` before export (Triangulate keeps custom normals).

Widths and segments at Roblox scale (measured on the crate, 4.5 x 3.3 x 2.7 studs, 3,900 triangles):
- Main silhouette edges: 0.03-0.04 studs, 2 segments.
- Small boxes (latches, ribs, mounts): 1 segment chamfer, 44 triangles per box (2 segments cost 108).
- Bolts and pins: 6-8 sides, no bevel - a bevel on a 0.15 stud bolt never reads.
- Details under about 6 screen pixels at review distance (plate screws, tiny rivets) are painted in the texture.
- Bevel strips create long thin triangles; the crate kept 514 slivers. That is the accepted cost of the method.

## High-to-low bake

A dense high poly carries the detail; a light low poly with good silhouette receives it through a normal map. Best for weapons, hero props and anything ornamented. Polycount's order, applied:

1. Blockout, then high and low built side by side with matching names (`PartL` / `PartH`).
2. Low poly: silhouette only, enough sides for round parts that are close to the camera (sword grip 12, pommel 14, knobs 10), hard edges only where the angle is large, and every hard edge on a UV seam (`set_sharp_from_angle(60)` plus chart seams at 50).
3. Triangulate the low before baking so the bake and the game share the same triangles.
4. Bake per part: the low part as active, only its own high parts selected (`rbx.bake(low, "NORMAL", img, highs, samples=12-16, extrude=0.03)`). This is "match by name" baking; nothing needs exploding. Samples above 1 anti-alias the bake (1 sample left stair steps on the sword's strap edges).
5. AO with all highs as occluders: turn the lows' ray visibility off (`rbx.lowvis`) so they do not shadow the highs.
6. Keep the cage extrusion just above the largest low-to-high distance (0.03 studs for the sword and chest, 0.06-0.08 for rocks).

Supports for a subdivision high poly: a subdivided cube becomes a sphere unless loops sit near each corner; the closer the loop, the tighter the highlight. In code, a multi-segment bevel (3-4 segments) on the high does the same job.

## Booleans

- `rbx.cut` uses the MANIFOLD solver by default: fast, and correct with joined multi-piece cutters. EXACT returned an empty mesh for a guard cut by four holes and two crescents joined into one cutter (Blender 5.2); use EXACT only with a single connected cutter, and check the face count after every cut.
- A boolean adds the cutter's empty material slot to the result; call `rbx.tidy()`.
- On a high poly, cut chips and dents last, after bevel and subdivision; a bevel after a chip cut tore the chest planks.
- Join many small cutters into one object before cutting.

## Building blocks in rbx.py

- `prism(outline)` for plates, guards, brackets, keyhole plates; `offset2d` for frames and engraved beads; `fillet` for rounded paths and outlines.
- `sweep(path, profile)` for straps, bands, handles, wire wraps (`ups=` radial vectors keep a wrap flat on a grip), with `resample` for the high.
  - `scale=` and `twist=` take the ring index, not the arc length. `fillet` puts many points in each corner, so a tapered sweep on a fillet path tapers in the corners. The samurai bangs became thin spikes this way, and the low tapered differently from the evenly resampled high. Resample the low path evenly too (`rbx.resample(path, 0.07)`) before a tapered sweep.
- `lathe(profile, n)` for knobs, feet, pommels, gems; `extrude_x` for arch-shaped lids.
- `leaf` and `trefoil` for ornament ends; `star` for reliefs; `dome` for rivets and beads; `torus` for rings.
- `orient(at, z_to, x_hint)` places a flat part on any face; `place(ob, matrix)` bakes the transform into the mesh so copies stay stackable.

## Proportion for Roblox

Real proportions read thin from the player camera. The sword's blade was widened 25% after the Roblox camera render showed a grey line. Thicken thin parts 1.2-1.5x for gameplay readability unless the style brief says realistic.
