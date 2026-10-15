# Realistic masks, paper and head cloth

Lepy, 2026-10-15, on the convict variant sheets: "you think that looks like a realistic mask? i asked for realism ... significantly more detail and use references for the mask ... the paper is super unrealistic". Flat plates with stuck-on boxes read as toys. This file is the method that replaced them.

## References first

- Use museum photos: Wikimedia Commons has public-domain and CC0 photos from the MET, the Tokyo National Museum (ColBase) and LACMA. Search the Commons API (`generator=search`, `iiurlwidth=640`), save a `sources.txt` with title, license and page, and make a numbered contact sheet.
- Pick one main reference per mask. Put a 25 or 50 px grid over it and read every feature position from the grid (eye centres, brow path, nose tip, mouth corners, outline points). Map pixels to mask studs with one scale (for example `x = (px - cx) * 0.0012`).
- Copy the picks and `sources.txt` into the project references folder before you report.

## Masks as a relief on a curved shell (`blender/convicts/relief.py`)

- A face mask is a height field: `H(x, z)` in front of the face plane. Build it at about 820 px per stud with numpy, then mesh it.
- Base shell: a dome in x times a vertical falloff, multiplied by an edge ramp from a blurred inside mask. Do not use the polygon distance for the edge ramp: its medial axis makes straight creases from the outline corners.
- Big forms first, as `max` unions on the shell (brow band, cheek masses, nose, lips, chin). Then details as `add` (petal flutes, forehead waves, spiral curls, chevrons), then a few grooves.
- Bug found: a polynomial smooth max adds `k/4` where both inputs are equal. Applied per window it raised whole rectangles. Fix: apply it only inside the feature (`cov > 0`) and scale `k` by the feature profile.
- What read as a toy or a cartoon: separate thin ridges ("sausages"), round balls for nostrils, an eye ring all round a dome eye (googly eyes), empty flat planes between features, many thin engraved grooves, an upper lid that slopes down at the outer corner (sad), a crescent mouth with a thick red lip ring (grin).
- What read as real: packed volumes with narrow crisp grooves between them (carved inside one mass, not stuck on top), a heavy brow and lid that cover the top of the eye, the outer eye corner higher than the inner, a wide nose mass with the alae merged in, teeth and fangs as separate gilt strips behind the lips, rim perforations, cheek rings.
- Holes (eyes, mouth, rim perforations) come from analytic SDFs; the mesh builder snaps boundary vertices onto the contour, then Solidify gives a real rim. A dark backing plate behind the mask keeps the holes black instead of showing the skin.
- Parts a height field cannot hold (horns, a beak, teeth, fangs, rings) are separate meshes: `horn_mesh`, `loft_beak` (sections with a sharp top ridge and a flat underside, hooked tip), `tooth_strip`.

## Paint in the same 2D domain

- Cavity maps from the height (`blur(H) - H` at three radii) drive grime in recesses and wear on ridges and the rim.
- Russet iron: black lacquer base, worn high points show brown iron with higher metallic and lower roughness.
- Gilding: gold leaf laid in squares (offset rows, thin seams, per-square tint), red bole where the leaf wears through, black painted hair strands, red lips, darker bronze eyes so the eyes do not vanish in a gold face.
- Painted papier-mache (kitsune): warm white gofun with fibre noise, crackle from ridged noise, vermilion patches, black brush strokes from `stroke()` with a width profile, chips only at the rim.
- Fine detail (hammer dents, pits, fibres) goes only into the bump map; the mesh uses the height blurred by 2 px.
- Image traps in Blender 5.2: changing the colour space of a generated image clears its pixels; set `colorspace_settings` first, then `pixels.foreach_set`. Do not call `update()` or `pack()` on a generated image after you set pixels.

## Paper talismans (`talisman.py`)

- Real characters, not stripes: render CJK text with a Song font (`simsun.ttc` is on this machine; Blender's Python has no PIL, so render PNGs with the system Python). Use generic spell words (急急如律令, 封, 鎮魂, 勅令), never a real shrine name.
- Ink: thicken the glyph, roughen the edge with noise, add dry-brush streaks and a slight bleed. Seals: vermilion squares with negative characters and worn patches.
- Paper: washi tone, fibres, yellowed edges, tea stains, foxing, smudges, fold creases (also in a height PNG), torn edges as alpha.
- Slips are thin cards on the cloth surface, offset past the cloth thickness, with a curl at the bottom corner.

## Cloth around the R6 head (`facecloth.py`, `wrap.py`)

- Map a relief domain `(u, z)` around the rounded head section (arc length round the rounded rectangle) and push along the section normal.
- Face cloth: gathered folds under the cord, flat over the face, deeper folds where it hangs below the chin, torn hem, torn eye hole with a dark patch behind it, painted red character, trim the hair bangs that would poke through.
- Head wrap: overlapping diagonal bands (a sawtooth height per band, a small lip at each band edge), compression wrinkles, folds from the knot, the eye slit between two horizontal band edges, a crumpled crown, a knot and two tails.

## Review

- Judge every mask in 3D with a clay pass next to the material pass: the 2D hillshade misleads (it cannot show teeth and exaggerates small grooves).
- Fit check in the character: the hood opening must be smaller than the mask outline so the hood overlaps the rim; otherwise skin shows in the gap.
