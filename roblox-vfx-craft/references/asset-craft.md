# Texture, flipbook, and mesh craft

Use this when a good block-in loses clarity during asset polish. Public texture
lessons by Ali Sorensen and artist breakdowns are linked in sources.md. The workflow
below translates those concerns to the assets Roblox can actually render.

## Select assets by their role

| Need | Prefer | Inspect before use |
|---|---|---|
| Stable soft support | Soft sprite with useful alpha | Bright square edges, excess empty border, whiteout in overlap |
| Directional hit | A designed flash or streak | Tip direction and contour at gameplay size |
| Evolving material | Flipbook | Frame order, silhouette changes, pivot, termination |
| Sword sweep | Trail or curved mesh | Blade alignment, local axes, camera edge-on view |
| Connected stream | Beam or mesh ribbon | UV direction, taper, endpoint continuity |
| Volume viewed from several sides | Mesh with supporting particles if needed | Pivot, normals, depth, intersections, material |

Prefer verified project assets when they fit. A name like "Shock" does not establish
what a mesh looks like. View a candidate alone and at the intended proportions.
Do not invent asset IDs or treat an old ID as proof of current access.

## Design a useful texture

Define its silhouette and alpha before decorating its interior. Check it on dark,
middle, and light backgrounds at the intended on-screen size. Give the leading edge
the intended sharpness and let secondary edges vary. Remove isolated visual noise
that turns into glitter when reduced.

For a reusable tintable sprite, neutral values often work well; colored textures
can be necessary for a particular material. Separate color from opacity deliberately.
Inspect alpha edges for halos and stray opaque pixels. Keep enough padding to avoid
clipping without spending most of the texture on empty space.

For a tiling strip, test the wrap seam and directional continuity before animating
it. A gradient across a strip is not automatically a seamless texture. Match the
UV direction to the motion instead of compensating with arbitrary rotations.

If new bitmap assets are required, use the available image/painting workflow and
inspect the result. A generated reference image is not an uploaded Roblox asset.
Import, obtain the real asset reference, check access in the target experience,
and inspect it on the actual instance. Keep source assets editable.

## Author a flipbook as animation

Plan a contour progression: formation, peak, breakup, disappearance, or a repeatable
cycle. Avoid producing a sheet of unrelated attractive frames. Keep a stable pivot
and consistent cell bounds so the effect does not wobble accidentally.

Pack cells in the engine's expected order and use a layout that matches the sheet.
Preview the isolated sheet before layering it. Choose frame blending deliberately:
it can smooth smoke but soften a crisp drawn impact. Random starts can vary a loop;
they can skip the essential beginning of a one-shot.

Budget resolution per cell. A 1024 by 1024 sheet with an 8 by 8 layout gives only
128 by 128 pixels per frame; a 4 by 4 layout gives 256 by 256. More frames do not
automatically give a sharper or better effect. Preserve the changing silhouette
at the actual gameplay distance and choose duration through playback.

For a loop, compare the last-to-first transition for contour, value, direction, and
speed. For an impact, avoid a blank opening cell that delays contact. Do not keep
the final opaque shape alive after the intended dissipation.

## Mesh design

Record the mesh's front axis, thin axis, pivot, dimensions, and UV direction. Use a
neutral preview to check the silhouette before relying on Neon or transparency.
Inspect both sides and an oblique angle. A flat card may be enough for one camera;
a moving third-person camera can expose it immediately.

Keep curved strips, cones, rings, and shells fitted to their purpose. Animate scale
around an intentional pivot. Avoid coplanar surfaces and thick overlapping shells
that obscure the body. Test the camera both outside and inside a large volume.

Normal maps and materials affect shading; they do not repair a wrong silhouette.
Spend geometry on the visible contour and curvature. Retain the source mesh so an
artist can change the shape instead of endlessly layering over it.

## Translate other engines honestly

Tutorials may use shader graphs, erosion masks, UV distortion, soft particles,
depth sampling, or refraction. Do not invent matching ParticleEmitter properties.
Check the current Roblox API and the project's implemented material tools first.

| Source technique | Practical Roblox approach when no matching project feature exists |
|---|---|
| Animated alpha erosion | Bake shape breakup into a flipbook; transparency alone is a uniform fade |
| Panning energy strip | Beam texture motion or an authored animated asset |
| Shader-driven mesh deformation | Authored mesh animation or supported rig deformation |
| Refraction/heat distortion | Evaluate supported materials in the real view; otherwise disclose an approximation |
| Particle collision shaping | Use project collision events to place effects; do not assume sprite physics |

Preserve the visual goal while stating the compromise. Do not label an approximate
glow or translucent shell as a verified refraction implementation.
