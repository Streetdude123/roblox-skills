# Hair for Roblox characters (anime and UGC standard)

Learned 2026-10-06 on the Shinsenkyō convicts. Lepy's words, in order: "Hair looks kind of tacky", "use real reference please from the roblox catalog ... look at real professional ugc hair", "Your hair in general needs more volume, look at anime character head avatars, like gabimaru's hair, lelouch's hair, simon the digger's hair ... yoko littner's hair ... yuzuriha's hair". Never invent hair. Study the references below first, every time.

## Study method

- Search only hair items: `https://catalog.roblox.com/v1/search/items/details?assetTypes=41&Keyword=<words>&Limit=10` (relevance order; `SortType` drops the keyword). Thumbnails: `https://thumbnails.roblox.com/v1/assets?assetIds=<ids>&size=700x700&format=Png`. The older `Category=11&Subcategory=19` filter leaks faces, ears and clothing.
- For each character in the brief, get the official anime art (fandom wiki API: `https://<wiki>.fandom.com/api.php?action=query&titles=<Page>&prop=pageimages&format=json&pithumbsize=1000`, request with a browser User-Agent) and the top fan UGC hairs. Put them on one study sheet.
- In Studio Edit, `InsertService:LoadAsset(id)` loads catalog hair accessories (the MCP `insert_asset` tool returns 404 for them). Put each on a test head: a Part 2x1x1 with a Head SpecialMesh at scale 1.25, `HatAttachment` at (0, 0.6, 0) and `FaceCenterAttachment` at (0, 0, 0); move the Handle so its attachment meets the head's. Set the camera `FieldOfView` to 26 and use `screen_capture` with `camera_position` at 5 studs for front, 3/4, side and back views. `CreateEditableMeshAsync` on someone else's mesh fails ("no permission"): study by looking only. Remove the study folder before a save.

## What professional and anime hair measures

- Size: catalog hair Handles are 1.75 to 2.05 studs wide on a 1.2-stud head, so the hair mass is about 1.5 to 1.7 times the head width; anime character hair (Gabimaru, Lelouch fan UGC) reaches 1.8. The top sits 0.3 to 0.45 studs above the skull.
- Anime and anime-UGC hair = a large rounded mass with a strong silhouette plus thick pointed clumps; the face window is a clean opening; the fringe is 6 to 9 thick clumps with sharp tips.
- Messy "pro" UGC hair (Packed Studios) = 100+ thin curved locks with streak highlights. In black it reads as a blob without its texture; it is not the anime look he asked for.

## Construction that works (`anime_hair` in `Shinsenkyo/blender/convicts/core.py`)

1. A volume mass: a shell on a superellipsoid around the head (exponent 3 so it clears the rounded R6 box), radius x (1 + volume), volume per region (top 0.56, sides 0.27, back 0.5, front 0.28; sides 0.46 got "Too much side volume"), bottom edge on a hairline (forehead el 30, sides el 0, nape el -34) with a small jag, solidified 0.05.
2. Thick crescent clumps (width 0.36 to 0.5, thickness 0.07, sag 0.05) laid on the mass: a side and back ring of 22 from el 52 down past the hairline with outward tips (30 percent flick up), a crown ring of 16 sweeping in the cut direction, 9 fringe clumps ending above the eye line, 2 side bangs per side, 5 tufts. Paths: slerp between two scalp directions, lift = base + rise x sin(pi/2 x t/0.7) (a dome, not a spike), droop and an end curl.
3. About 6,000 low triangles for mass plus 48 clumps.

## Traps

- A clump whose lift is set once at its root carries the root's volume along its whole path: crown clumps rooted at the top (volume 0.5) that sweep down to the temples made a wide helmet. Compute the lift from the local volume at every path point (`vfun=vloc` in `arc_path`). Measured on the A2 hairs: ear-level width 2.1 to 1.75 studs on a 1.12-stud head (1.56 x head, inside the pro range), maximum 2.24 to 1.85, top 0.05 studs lower.

- Radial clumps from the crown with lift growing to the tip read as a sea urchin or a pineapple.
- A hair cap that wraps the front corners of the head, or sideburn locks that hug the head, read as flat black panels beside the face. Cut the cap along a diagonal hairline (temple to behind the ear to the nape).
- Side and mid layers rooted inside the face window (azimuth -155 to -25 from the front) hang over the face.
- A fringe swept over one eye is a canon trademark (Gabimaru); keep fringe tips above the eye line on original characters.
- `rbx.ID_COLORS` has 14 entries; a build with more materials fails after the normal bake with IndexError. Extend the list first.

## Shading

Hair colour plus a highlight colour (black 24,24,28 with 92,100,122; brown 60,42,32 with 150,112,84; auburn 122,54,34 with 222,132,88) on convex ridges (baked curvature) and up-facing surfaces, darker in AO crevices, roughness 0.4.
