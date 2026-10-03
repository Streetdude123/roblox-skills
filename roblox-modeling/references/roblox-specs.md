# Roblox mesh and texture specifications

Collected from the Roblox Creator Docs and DevForum on 2026-10-03. Check the pages again when a number matters; Roblox changes them.

Sources: create.roblox.com/docs/art/modeling/specifications, .../texture-specifications, .../surface-appearance, .../export-requirements, create.roblox.com/docs/art/blender, create.roblox.com/docs/en-us/studio/importer.md, create.roblox.com/docs/parts/meshes, create.roblox.com/docs/workspace/collisions, create.roblox.com/docs/performance-optimization/improve, create.roblox.com/docs/avatar/rigid-accessories/specifications, create.roblox.com/docs/avatar/character-bodies/specifications, devforum "More Control Over Importer: Custom Scale Factor and Updated Unit Conversions" (4644371), devforum "Vertex Colored Meshes using Blender and Studio" (3050119).

## Geometry

- 20,000 triangles maximum per mesh.
- Quads where possible in the source; the engine renders triangles.
- Watertight, no exposed holes or backfaces, no zero-thickness geometry (all faces need volume).
- One material per mesh object, one UV set, UVs inside 0-1. Overlapping UVs are allowed.
- Skinned meshes: max 4 bone influences per vertex, no influence on the root bone, bones at scale 1 and rotation 0 in rest, root at 0,0,0. Only one animation track exports with a mesh.
- Layered clothing cages: suffix `_InnerCage` and `_OuterCage`; never delete cage vertices or change cage UVs.
- Vertex colours from an FBX render on MeshParts and multiply with `MeshPart.Color` (set the part white to see them). The Importer has "Ignore Vertex Colors". SpecialMesh ignores them.

## Textures and SurfaceAppearance

- Formats: png, jpg, tga, bmp. Up to 4096 x 4096 is accepted now; the texture guide still says 256 px for a 5 x 5 stud object, 512 for 10 x 10, 1024 for 20 x 20 (about 51 px per stud). Marketplace items: max 2048.
- Memory is set by pixel count, not file size: 1024 x 1024 costs four times 512 x 512. Roblox's performance page says most images need 512 or less unless they cover a large part of the screen.
- SurfaceAppearance maps: ColorMap (RGB, alpha used by AlphaMode), NormalMap (tangent space, **OpenGL** convention, flat = 127,127,255), RoughnessMap (grey, 0 = mirror, 1 = matte), MetalnessMap (grey, use 0 or 1), EmissiveMask (grey, with EmissiveTint and EmissiveStrength 0-40 on Marketplace items). Blender bakes OpenGL normals by default (+X +Y +Z).
- AlphaMode: Opaque (ignores alpha), Overlay (default; colour map over `MeshPart.Color` where alpha is low), Transparency (alpha cuts the surface), TintMask (alpha marks where `SurfaceAppearance.Color` tints).
- SurfaceAppearance cannot change at runtime from game scripts (pre-processing). The `*MapContent` properties take `Content.fromObject(EditableImage)` from plugin-level code (used by the Studio preview).
- If a part has both SurfaceAppearance and MaterialVariant, only the SurfaceAppearance texture settings apply.
- There is no AO slot: multiply a soft AO into the colour map.

## Scale, axes and the Importer

- Studio is Y-up, front is -Z (LookVector). Blender is Z-up, front view looks along +Y, so a model's front faces -Y.
- Blender docs: Scene Units > Unit System None, Rotation Degrees, so 1 unit = 1 stud.
- FBX export for Roblox (docs): Path Mode Copy + Embed Textures, Apply Scalings = FBX Unit Scale, Add Leaf Bones off, Bake Animation off unless the file carries animation. Default Blender FBX settings import too large.
- This skill exports with `axis_forward="Z", axis_up="Y"`, which is the same map as the mesh JSON: Roblox (x, y, z) = (-x, z, y) of Blender. The JSON preview in Studio confirmed size, front and winding on 2026-10-03; confirm the FBX facing on the first real Import 3D (the Chara import in 2026-10 came in facing +Z with the default forward -Z).
- Importer formats: fbx, gltf, obj. Defaults: Scale Unit Studs, World Forward Front, World Up Top, Upload to Roblox on, Add to Workspace on, Set Pivot to Scene Origin on, Use Imported Pivot on, Anchored off, Merge Meshes off, Invert Negative Faces off, Make Double Sided off, Ignore Vertex Colors off, Keep Zero Influence Bones off, Rig Type auto (R15, Custom, No Rig), Uses Cage auto.
- Since 2026-06-16 one meter imports as 25/7 studs (0.28 m per stud; the old ratio was 20 studs per meter). A custom scale factor multiplies on top; 5.6 restores the old behaviour. With Scale Unit Studs, 1 file unit = 1 stud.

## Rendering, LOD, collision

- RenderFidelity Automatic: highest detail under 250 studs, medium 250-500, lowest beyond 500. Precise keeps full detail (cost); Performance reduces it.
- CollisionFidelity: Box (cheapest, small or non-interactive props), Hull (convex), Default (approximate, concave allowed), PreciseConvexDecomposition (most precise, most expensive, slow to compute), Tunable (a CollisionPrecision slider). Use Box or Hull, or invisible simple parts, unless players must touch the real shape.
- Draw calls: MeshParts batch into one call when the mesh and the SurfaceAppearance (or TextureContent, or material when neither exists) are identical. Reuse one mesh and one texture set for repeated props.
- Partial transparency overdraw is costly; turn CastShadow off on small parts; Model.LevelOfDetail = SLIM with streaming lowers far cost.
- DoubleSided costs more; use it for VFX ribbons and thin leaves only.

## Avatar budgets

- Rigid accessory: max 4,000 triangles, single mesh, watertight, Plastic, transparency 0, textures max 2048 (Marketplace), one attachment named for the type (HatAttachment, HairAttachment, FaceFrontAttachment, BodyBackAttachment, ...), size limits per type (classic hat 3 x 4 x 3 studs).
- Character body: DynamicHead 4,000, Torso 1,750, each arm and leg 1,248, total 10,742 triangles; texture max 2048; R15 part names (Head_Geo, UpperTorso_Geo, LowerTorso_Geo, LeftUpperArm_Geo, ... RightFoot_Geo); root and LowerTorso at 0,0,0; outer cages `_OuterCage`, attachments with `_Att`.

## Scale references (studs)

R6 character 5 tall (head 1, torso 2, legs 2), 4 wide at the arms; R15 default about 5.3. A door is usually 7-8 tall and 4-5 wide, a table top 3, a step 0.5-1, a wall 10-14 high. Lepy's games: anime battlegrounds and fantasy scale, chunkier than real life for readability.
