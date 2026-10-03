# UV layout and texel density

Texel density is texture pixels per stud on the model's surface. Roblox's guide is about 51 px/stud (1024 px for a 20 x 20 stud object). Keep density even across one model: `rbx.audit(ob, tex)` reports the area-weighted median, p10 and p90.

## The pipeline (all in `rbx.py`)

1. **Chart seams** - `chart_seams(ob, tol=50)` grows charts from the largest faces and takes every neighbour whose normal is within `tol` degrees of the seed. Each flat face takes the half of each bevel strip next to it, so bevel strips never become their own islands. Use 50 for hard surface, 65 for rocks. Then `unwrap(ob)` (angle based). Smart UV Project put every bevel strip in its own island: 46% UV use on the crate, against 62% with chart seams.
2. **Hard edges on seams** - every sharp edge (`set_sharp_from_angle`) must be a seam, or the normal map shows a seam line.
3. **Long islands** - a 3.5 stud blade strip forces a small pack scale. `cut_rings(ob, "z", [1.6, 2.6])` adds seams across the blade: UV use went from 27% to 61% and density from 288 to 404 px/stud. The texture stays continuous because the composite noise comes from 3D position.
4. **Stacked copies** - identical parts share UV space. Build one master, make copies with `dup` + `place` (rigid moves only), mark them `copy_of`, and copy the UVs with `stack_uvs`, which first checks `same_topology`. Separately built copies broke on the chest feet because the lathe merge ordered their loops differently.
5. **Hidden faces** - `pack_parts(parts, px, size, low, ground=True)` ray-casts 24 directions from each face over the whole assembly (with a ground plane for floor props) and shrinks islands that see less than 3% of the sky to `low` (0.12-0.2) of their size. On the crate this raised visible density by 14% on the same texture; the chest hides more than half of its surface (plank backs, core, posts).
6. **Pack** - `pack_parts` packs all unique parts together in multi-object edit mode: average island scale, then `pack_islands` with axis-aligned rotation (crisp straight edges), concave shape method, margin = px / size. Copies then take their master's UVs.
   - **Hero islands** - `pack_parts(..., boost=[(part_name, test, factor)])` scales the islands of that part that have a face where `test(face)` is true, before the pack. A painted face needs it: the samurai face island got 2.6x (about 300 px/stud against 118 for the body), so a 0.07-stud eye gets more than 20 px of height. The cost is small: one face island is a few percent of the atlas.
7. **Bake offset** - before bakes, move copies one unit right (`shift_uv(ob, 1)`) so only the master bakes; move them back afterwards.

## Margins

5 px at 1024 for dense multi-part props, 8 px for simple ones. The bake and dilation rules for the gutters are in bake-and-texture.md.

## Checks

- `uv_faces_outside_0_1` = 0 after the shift back.
- The UV sheet (`uv_sheet` over the colour map): no long fans across the map (a fan means broken stacking), islands axis-aligned, no overlaps except stacked copies.
- Visible density at or above the class target; hidden faces may be low.
- `audit` skips stacked copies when it sums UV use; a median far below p90 means most of the area is hidden, which is fine when p90 meets the target.

## VFX meshes

VFX meshes use unit UVs instead (`sweep(..., uvs="unit")`): U along the path from 0 to 1, V across the profile from 0 to 1. A gradient or scrolling texture then reads the same on every mesh of the kit.
