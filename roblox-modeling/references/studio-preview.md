# Getting models into Studio

## A. Local preview (no upload, nothing saved) - verified 2026-10-03

Use it to judge a model in a game's real lighting, also inside a team place (Lepy approved this for UT:EF): the preview lives under `workspace.CurrentCamera`, which is local to the Studio user.

1. Export: the build scripts write `<name>.json` (`rbx.mesh_json`: vertices mapped to Roblox (-x, z, y), triangles, per-corner normals and UVs with V flipped). `preview_export.py` copies the JSON and writes the maps as raw 512 x 512 RGBA with rows top-down:
   `blender.exe --background --factory-startup --python scripts/blender/preview_export.py -- src=<Modeling folder> dst=<out> names=Crate,Sword size=512`
2. Serve: find a free port first (8766, 8768 and 8771 were held by servers from other sessions), then
   `Start-Process node.exe -ArgumentList @("scripts/studio/serve_preview.js", "<out>", "<port>") -WindowStyle Hidden`.
   `/n/<file>` returns the chunk count, `/f/<file>?part=k` returns 512 KB chunks (base64 for binary). PowerShell shows the count as an ASCII byte (51 = "3"); Studio gets a string.
3. Load: run the body of `scripts/studio/PreviewMesh.lua` in `execute_luau` (Edit), wrapped so `HttpService.HttpEnabled` goes on and back to its old value in the same call, with arguments base URL, name, a Vector3 for the bottom centre, flip (false), size (512). It builds an EditableMesh (AddVertex, AddTriangle, AddNormal + SetFaceNormals, AddUV + SetFaceUVs), `CreateMeshPartAsync(Content.fromObject(mesh))`, and a SurfaceAppearance with `ColorMapContent`, `NormalMapContent`, `RoughnessMapContent`, `MetalnessMapContent` from EditableImages. One model per call keeps each call short.
4. Look: `screen_capture` with a camera position and a look-at point; add local floor, R6 reference blocks and PointLights under the same folder if the scene is dark.
5. Clean: destroy `workspace.CurrentCamera.ModelPreview`, count leftovers (0), confirm `HttpEnabled` false, stop the node process you started.

Facts from the run: sizes matched Blender to 0.01 stud (sword 1.604 x 4.645 x 0.302); no winding flip needed; the base64 decoder must drop the padding bytes (WritePixelsBuffer demands exactly size x size x 4 bytes).

## B. Import 3D (real asset, uploads to the chosen creator)

1. Export FBX with `rbx.fbx(objs, path)`: FBX Unit Scale, forward Z, up Y, triangulated, sRGB vertex colours, embedded textures, no leaf bones, no animation bake.
2. In a test place (never a team place without his word): File > Import 3D, Scale Unit Studs, check the preview size against the audit's `size_studs`, World Forward Front; Upload to Roblox uploads the meshes to the selected creator (his account or the group he names).
3. Add the SurfaceAppearance maps (upload the PNGs as images) or MeshPart.TextureID for colour-only models.
4. Check the facing on the first import: a Chara import with the default forward -Z faced +Z.
5. Set CollisionFidelity (Box or Hull for props), RenderFidelity Automatic, CastShadow off for tiny parts, Anchored as needed.

## C. Publish a mesh from an EditableMesh

`AssetService:CreateAssetAsync` takes Mesh, Model, Image and Plugin asset types, but needs the AssetCreateUpdate capability; it was "not available yet" for animations in 2026-09. Try it only with his approval because it creates assets on his account.
