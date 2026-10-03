# Review loop

Every build script ends with a review sheet (3 x 2 cells of 480 px) and a JSON audit. Read the sheet, fix, build again. Two rounds minimum; the practice pieces needed three to five.

## The renders

| Cell | How | Look for |
| --- | --- | --- |
| High clay | Workbench matcap `basic_grey.exr` on the high collection | form, detail passes, torn or exploded geometry (the chest's bevel-after-boolean tears showed here first) |
| Low wire | Workbench studio light, object colour, `rbx.wire(ob, t)` (no even offset - it spikes on slivers) | silhouette kept, density where the silhouette curves, no wasted loops |
| Low with normal map | CPU Cycles, grey clay Principled + the baked normal map, `rbx.studio` rig | baked detail transferred, no seams, no stair steps |
| Beauty front and back | CPU Cycles 32-40 samples + OpenImageDenoise, `rbx.studio` (key, fill, rim area lights; the camera sees a flat background, reflections see the studio HDRI) | materials, wear, imperfection, colour balance |
| Close-up | lens 60-85 mm, 3 studs from the hero detail | texel density, bleed, small detail |
| Roblox camera | `rbx.look_from(cam, target, fov=70)` about 12 studs behind and above, R6 dummy beside the model, forest HDRI and a sun | readability at play distance, scale against the 5-stud figure |
| UV sheet | `rbx.uv_sheet(ob, path, size, color_img)` | overlaps, fans, packing, axis alignment |

Studio's EEVEE does not run on this machine; do not switch engines. Lights scale with distance squared (`6 * d * d` watts in `studio`); at 55 or 16 the clay rendered white.

## Audit thresholds (`rbx.audit`)

- `tris` inside the class budget; `high_tris` reported.
- `open_edges` 0, `nonmanifold_edges` 0, `loose_verts` 0, `zero_faces` 0.
- `materials` 1 on the exported mesh; `custom_normals` true for mid-poly.
- `uv_faces_outside_0_1` 0; `uv_area_used` 0.3-0.65 for multi-part props (stacked copies excluded).
- `texel_px_per_stud.p90` at the class target (p90 is the visible density when hidden faces were shrunk).
- `size_studs` and `pivot_from_bottom_center` as planned (bottom centre for floor props, grip for held items, contact plane for half-buried terrain).
- `sliver_tris` is information: bevel strips make them; a jump without a bevel change means bad triangulation.

## Studio check

After the Blender sheet is clean, run the Studio preview (studio-preview.md) or a real Import 3D in a test place: view it from the player camera in the target game's lighting. The 2026-10-03 check matched every size to Blender, confirmed front, winding, UV and normal-map direction, and showed that bright game lighting lifts grey albedo.

## Report

Show the final sheet, the Studio capture, and the numbers. Name the reference and the style brief. List what changed between rounds and why. Never write "should look good"; write what the renders show.
