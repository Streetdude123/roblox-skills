# Style scan (do this before modeling for a game)

Lepy, 2026-10-03: "Make sure you scan the game before you make models too so that you can get the games style before you make models".

## 1. Numbers - `scripts/studio/StyleScan.lua` (read only)

Run it through `execute_luau` on the Edit data model (pass a root instance as the first argument, default Workspace). It changes nothing. It returns JSON:

- counts: parts, MeshParts, unions, MeshParts with a TextureID, with a SurfaceAppearance, DoubleSided, transparent parts, Neon parts, decals and textures;
- unique mesh and texture ids;
- materials and colours weighted by surface area (colours quantized to 16 levels per channel);
- RenderFidelity and CollisionFidelity counts, part and mesh size percentiles;
- the largest MeshParts with their texture use and material;
- Lighting values, post effects (Atmosphere, Bloom, ColorCorrection, SunRays, DepthOfField, Blur, Sky) and MaterialVariants.

## 2. Pictures

Take player-camera captures of three or four typical areas. In Edit mode the StarterGui screens draw over the viewport (seen in UT:EF), so either aim the shot so the subject sits in a clear band of the frame, capture during a Play test, or ask Lepy to hide the UI. Do not change UI or place settings in a team place to get a clean shot.

## 3. Write the style brief (five to ten lines)

- Look: stylized, semi-real or realistic; texture-driven or colour-driven.
- Palette: main colours with area shares; saturation; value range (dark or bright scene).
- Surfaces: share of textured meshes, SurfaceAppearance use, material use (Neon tricks, SmoothPlastic, real materials).
- Shape language: bevels or sharp edges, chunky or slim, triangle density of comparable props.
- Lighting: time of day, brightness, ambient colour, fog and post effects (they change how albedo reads).
- Scale: sizes of doors, props, characters.
- Rules for this model: texture size or none, palette swatches, budget.

## Example: UT:EF scan (2026-10-03, statistics only)

7,052 parts, 86% MeshParts (2,882 unique meshes) but only 334 MeshParts with a texture and 68 with a SurfaceAppearance: the look is colour-driven. Area palette: near-black 59% (large dark floors in Neon used as flat unlit colour), greys 25%, pale lavender 5.5%, white, small brown and magenta accents. Lighting: night clock, brightness 0, cool ambient, Atmosphere haze 2.05, light bloom, colour correction with saturation +0.2 and a cool tint. Brief for a prop in that game: flat colour or vertex colour from a muted cool palette, small or no textures, chunky readable shapes, emissive accents only where the game uses them. The PBR chest look would not fit it.
