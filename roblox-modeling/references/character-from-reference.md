# Character from a picked reference

Lepy, 2026-10-03, after the samurai rebuild on reference 2: "Much better, i really like this remember how you built this". This is that method, step by step. `scripts/blender/examples/samurai.py` is the worked example.

## 1. Candidates he can pick from

- ArtStation search API from the built-in browser on an artstation.com tab (the page itself, not a new origin):
  - `POST /api/v2/csrf_protection/token.json` gives `public_csrf_token`.
  - `POST /api/v2/search/projects.json` with header `PUBLIC-CSRF-TOKEN` and body `{query, page, per_page, sorting: "relevance", pro_first: "1", filters: [], additional_fields: []}` returns `hash_id`, `title`, `smaller_square_cover_url` (swap `smaller_square` for `large`).
  - `GET /projects/<hash_id>.json` lists every image of a project (renders, clay, wireframe, in-Studio shot, texture maps).
- Sketchfab: `https://api.sketchfab.com/v3/search?type=models&count=24&q=...` works from any page (CORS open).
- Search the asset kind with "roblox" in the query ("roblox samurai", "roblox r6 armor"). Finished Roblox R6 models beat concept art because they already solved the R6 proportions.
- Show 6-8 on one numbered sheet: inject a fixed overlay grid into the artstation.com tab (local files and localhost are refused in the pane). Each cell gets a number and a 4-6 word description. List the same numbers with links in the reply.

## 2. Study the pick before any vertex

- Show each project image in the overlay. Crop and enlarge regions with CSS (`showCrop(url, x0, y0, x1, y1)`): the pane has no zoom.
- Read every view: the front, side and back renders, the clay render (forms without texture), the wireframe (topology density, mid-poly or baked), and the in-Studio shot (how the colours read in Roblox light).
- Measure in pixels and convert to studs with a known R6 size. The samurai scale came from the chest plate top (about 3.95 studs) to the sole (0): 147 px per stud. Measured: hat brim 2.8, crown 1.05 x 0.7, shoulders across 4.23, chest plate 1.97 x 1.57, front skirt 1.33 wide down to 0.71, shin splints 0.41-1.12.
- Sample the pick's own texture maps with a canvas `fetch` of the CDN image (ArtStation CDN allows it): base colour, metalness, roughness per material. The samurai lacquer was sRGB (41, 8, 5) with roughness 0.44, which looks like (90, 30, 25) in Roblox light. Copy these values and do not guess them.
- Write the spec: every piece, its size in studs, its R6 part, its material, its colour, its roughness.

## 3. Conflicts go to him

When the pick disagrees with an earlier answer (cloth versus chainmail, straw hat versus the pick's hat, his "faceless" versus the pick's face), ask with one question per conflict, the pick as the recommended option. On the samurai the pick won every point.

## 4. Build

- Use the R6 part volumes as the frame: torso x ±1, y ±0.5, z 2-4; arms x ±1-2; legs x ±0-1, z 0-2; head about 1.2 at z 4-5.14. Armor that belongs to a limb goes in that limb's group so it moves with it. A plate that spans both legs goes on the torso.
- Plates come from one frame dict (`ctr`, `nd`, `w`, `h`, `t`, `bow`, `tilt`): `hplate` builds the low and the high from it, and `surf` and `deco_frame` place slots, ties and rivets on its outer face. Random jitter goes into the dict once, so the low and the high agree.
- Small detail (lacing slots, tie loops, rivets, twisted rope, hair strands) exists only in the high and reaches the low through the normal and ID bakes.
- Stepped plates need a real step and tilt to read from the front: the samurai sode went from 0.045 step, 10 degrees and 0.07 thickness (invisible edge-on) to 0.075 step, 16 + 7 per tier degrees and 0.1 thickness.

## 5. Show before the bake

- Render colour views from the pick's own angles (back, side, front, 3/4) in one row (`*_compare.png`), and the high clay sheet (`stage=highs`, about 15 s).
- Put the pick and the renders on one HTML page (the pick hotlinked, the renders as `file:///` paths). Writing the file opens it in the browser pane. Send the PNGs with SendUserFile too.
- Bake only after his word.
