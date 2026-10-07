# Hair for Roblox characters (anime and UGC standard)

Hair is the first thing Lepy judges on a character. Every hair built so far was rejected (see "Why the earlier hair failed"). Read the rules first, every time, then the research behind them.

## Rules (read first, every time)

1. **Reference first.** Hair gets its own numbered reference sheet (real catalog UGC hair, stylized sculpts, anime art, real photos) and his pick, like every model. Match the pick's silhouette in front, side and back before any clump is placed. Sheet for the convicts: `Shinsenkyo/references/characters/hair_refs_R1_R8.jpg`.
2. **Big, medium, small, in that order.** First a mass (the "helmet") with a designed silhouette that meets the scalp at the hairline, then 6 to 12 hero clumps that define the style, then medium clumps between them, then 2 to 6 small wisps. Never start with strands.
3. **Clump shape.** Every clump is a blade or a leaf with thickness: thick at the root, widest at about a third of its length, then a long taper to a sharp tip, on a C or S curve, the tip flicked out or tucked in. Never a strip of constant width. Vary width, length and thickness at every level (on a 1.1-stud head: hero 0.3 to 0.45 wide, medium 0.15 to 0.3, wisps 0.05 to 0.1).
4. **Flow.** Hair flows out from the part and from the crown whorl (near the midline, top back). Decide which clump passes over which. Break the flow on purpose with a few wisps. Avoid symmetry.
5. **Silhouette.** Round, never the shape of the head box: about 1.4 to 1.7 head widths, the top 0.2 to 0.45 studs above the skull, the outline broken by tips, the hem jagged with tips at different lengths.
6. **No scalp shows** anywhere (coverage test below).
7. **Texture.** Three shades (base, darker in crevices and under layers, lighter on top), strand lines along each clump, darker roots and undersides, a soft highlight band across the flow on the top of the head, defined tips. Never one flat colour with curvature highlights (reads as plastic). Too much highlight reads wet.
8. **Review.** Clay renders of the high (front, three quarter, side, back, top) side by side with the pick before any bake; then the textured renders; then the player camera in Studio.

## Why the earlier hair failed (his verdicts, 2026-10-06)

1. Procedural spiky clumps (radiating tapered clumps with grooves): "Hair looks kind of tacky".
2. Thin ribbon locks after the catalog study: "your hair isn't good, look at real professional ugc hair", then "Your hair in general needs more volume".
3. Volume mass plus thick crescent clumps (`anime_hair`): "Too much side volume but other than that not bad" (side volume 0.46), then "let the hair fall naturally, kind of looks like it's floating" (a shell with an edge that hovers off the head).
4. Gravity drape (`drape_hair`): the clay sheet N1 and N2 got "pretty good"; on the textured A2, "Fill this gap" (scalp at the part), then "Your hair design is horrible". Measured against the research below: a box silhouette (uniform offset over the R6 box), 87 locks of nearly one width (0.24 to 0.32), one thickness (0.06) and one taper (shingles, "spaghetti"), flat crescent strips, stiff parallel flow from gravity and a comb field, and a plastic texture (flat colour, curvature highlights, AO blotches).

## Research (2026-10-06, "search up hair design modeling tips, real life hair, and modeling hair tips online")

Design and modeling:
- Work general to specific: the primary form is a simple helmet, the secondary forms are clumps, the tertiary forms are strands; never sculpt every strand (80.lv, Dan Eder, "Guide: Sculpting Stylized Hair in ZBrush"; stylized sculpting guides).
- "Try to find a good balance in the number of strands - too many looks messy, too few looks clay-like." Common mistakes: clipping, repeated identical strands, wobbly lines, too much symmetry. Get the basic shapes right before any detail; rotate the model often (Dan Eder).
- Hair that looks like spaghetti has every strand doing its own thing: group strands into bigger locks of varied size, some thick, some medium, some thin; design which lock passes over which and where one disappears under another; a few hero strands with bold highlights show the form (Polycount critiques).
- Hair flow analysis: where the direction changes, how hair clumps, how layers overlap, how flyaways break the flow, how gravity pulls it down; stylized hair exaggerates the direction changes of real hair (80.lv, "Designing a Real-Time Traditional Chinese Hairstyle in Blender").
- Avatar hair style guide: "stylized but believable and natural hair, clear and readable silhouette, simplified forms (hard edges, no fine details), thickness of details (curls and strands should have thickness), avoid obvious symmetry, appealing look" (Ready Player Me, wolf3d).
- Shapes: big shapes make the silhouette, medium shapes are the clumps, small shapes are strands inside or breaking away from the clumps; every hairstyle is built from C and S curves; leave calm areas for the eye (Clip Studio TIPS: "Drawing Stylised Hair: Shapes, Tufts & Strands", "Let's Draw Hair! by Ricky"). Tufts radiate from one source near the top back of the head, slightly off centre.
- Curve method in Blender (Roblox DevForum "How to make hair in Blender"): a bevel profile (teardrop or triangle) swept along path curves, points scaled to 0 for pointed tips, curve resolution 4, converted to mesh, joined, decimated. "The less complex the shape is, the less tris you have."

Real hair:
- Hair grows out from the crown whorl; most people have one, near the midline at the crown, usually clockwise; every region's direction follows from it, and near the whorl the hair lies flat along the skull (hair transplant clinics; barber guides).
- Natural fall is the position of hair that hangs under gravity alone (Red Seal hairdressing study guide 5.5, "Growth Patterns, Natural Fall"). Hair rises from the root and then falls, so the hair sits above the skull with volume; draw the skull first and keep the hair a varied distance above it. Straight hair lies flatter; short hair lifts more (Envato Tuts+, "What You Need to Consider When Drawing Hairstyles From Scratch").
- A middle part (photo study R8): the hair lifts at once on both sides of a thin part line, makes two rounded domes that arc out over the temples, falls, and turns in at the ends; the front silhouette is a bell, widest at the temples; the hair moves in broad sheets, not thin strips. An off-centre part puts more volume on the larger side.
- Light: each strand is a small cylinder, so hair shows a highlight band across the strand direction (anisotropic, the "angel ring"); highlights sit inside the lit area, not on the edge (Clip Studio TIPS, "The Science behind HAIR Highlight").

Texture (Highrise "Hair & Hair Textures" art guide): start with the second darkest shade for the shape, add the darkest shade for shadows (little on the fringe), add a lighter shade on top for form and fluff, then smaller pieces and strands, then a few highlight pops and defined ends. Too much highlight looks wet; too little has no impact.

Roblox UGC hair that sells (catalog study, middle part): a big rounded silhouette about 1.6 to 1.8 head widths; a narrow clean part with lift on both sides; layered tiers (top, middle, a darker under layer at the nape); many thin-edged pointed locks breaking the outline; a jagged hem; strong painted strands (dark gaps, light strands, a root-to-tip gradient). Professional stylized packs (ArtStation, World Dream; Stylized Male Hair Vol 1 and 2): a sculpted helmet with carved clumps and strand grooves, or many long pointed blades with thick rounded sections layered from the crown whorl; the hem is a row of tapered tips.

## Study method

- Search only hair items: `https://catalog.roblox.com/v1/search/items/details?assetTypes=41&Keyword=<words>&Limit=10` (relevance order; `SortType` drops the keyword). Thumbnails: `https://thumbnails.roblox.com/v1/assets?assetIds=<ids>&size=420x420&format=Png` (strip the CR from the URL lines before `curl` on Windows).
- Web pictures: a Bing image search in the built-in browser; read each result's full image URL from the `m` attribute of `a.iusc` (JSON `murl`), download with a browser User-Agent, and view the files at full size. Crop and put the candidates on one numbered sheet with PIL.
- For each character in the brief, get the official anime art (fandom wiki API: `https://<wiki>.fandom.com/api.php?action=query&titles=<Page>&prop=pageimages&format=json&pithumbsize=1000`, browser User-Agent) and the top fan UGC hairs.
- In Studio Edit, `InsertService:LoadAsset(id)` loads catalog hair accessories (the MCP `insert_asset` tool returns 404 for them). Put each on a test head: a Part 2x1x1 with a Head SpecialMesh at scale 1.25, `HatAttachment` at (0, 0.6, 0) and `FaceCenterAttachment` at (0, 0, 0); move the Handle so its attachment meets the head's. Set the camera `FieldOfView` to 26 and use `screen_capture` with `camera_position` at 5 studs for front, three quarter, side and back. `CreateEditableMeshAsync` on someone else's mesh fails ("no permission"): study by looking only. Remove the study folder and reset the field of view before a save.

## Measurements

- Catalog hair Handles are 1.75 to 2.05 studs wide on a 1.2-stud head (1.5 to 1.7 x head width); anime character hair (Gabimaru, Lelouch fan UGC) reaches 1.8. The top sits 0.3 to 0.45 studs above the skull.
- Anime and anime-UGC hair: a large rounded mass with a strong silhouette plus thick pointed clumps; the face window is a clean opening; the fringe is 6 to 9 thick clumps with sharp tips.
- Messy "pro" UGC hair (Packed Studios): 100+ thin curved locks with streak highlights; in black it reads as a blob without its texture.
- On the R6 convict head (1.12 studs), an ear-level width of 1.75 studs (1.56 x head) was accepted; 2.1 studs got "Too much side volume".

## No gaps (coverage test)

Still valid for any construction. On the drape hair the middle part showed the scalp as a dark trench ("Fill this gap"):
- Roots on both sides of the part line (8 pairs, 0.02 studs off the line, from the front hairline to the crown).
- Roots tucked 0.01 inside the scalp, rising to their layer over 0.15 studs. A root end in the air bakes to steep normals and dark spots.
- Coverage test (`bare` in core.py): 3,600 scalp points above hairline + 8 degrees, one ray along the head normal and eight rays tilted 37 and 52 degrees (only rays with z > 0.2), reach 0.5, against a BVH of the low hair. Any escaping ray = bare. Grow a filler clump at each bare point (skip points within 0.13 of a filler, under its neighbours) and test again, up to 3 rounds. A2: 105 bare points and 18 fillers, then 1 and 1, then 0.
- Blend the flow where two regions meet (side and back at the crown); a hard switch leaves a bare wedge.
- Find gaps with a test render that paints the scalp cap bright green (`hair_gap.py`): top, front top, front, three quarter, back top and side, low and high.

## Traps

- A clump whose lift is set once at its root carries the root's volume along its whole path: crown clumps rooted at the top that sweep down to the temples made a wide helmet. Compute the lift from the local volume at every path point.
- Radial clumps from the crown with lift growing to the tip read as a sea urchin or a pineapple.
- A hair cap that wraps the front corners of the head, or sideburn locks that hug the head, read as flat panels beside the face. Cut the cap along a diagonal hairline (temple to behind the ear to the nape).
- Side and mid layers rooted inside the face window (azimuth -155 to -25 from the front) hang over the face.
- A fringe swept over one eye is a canon trademark (Gabimaru); keep fringe tips above the eye line on original characters.
- A superellipsoid head proxy sits 0.05 off the flat faces of the R6 head and inside its corners, so hair floats or clips. Collide with a rounded-box SDF of the real head (half sizes and the 0.3 bevel, `head_sdf`).
- `rbx.ID_COLORS` has 14 entries; a build with more materials fails after the normal bake with IndexError. Extend the list first.

## Earlier constructions (rejected; kept for their numbers)

- `anime_hair` (volume mass plus clumps): a shell on a superellipsoid around the head, radius x (1 + volume), volume top 0.56, sides 0.27, back 0.5, front 0.28, bottom edge on a hairline (forehead el 30, sides el 0, nape el -34), solidified 0.05; crescent clumps 0.36 to 0.5 wide, 0.07 thick, laid on the shell (a side and back ring of 22, a crown ring of 16, 9 fringe clumps, 2 side bangs per side, 5 tufts); about 6,000 low triangles. Rejected for floating: the shell edge hovered off the head.
- `drape_hair` (gravity drape): Fibonacci roots above the hairline (front 28, sides -8, back -36 degrees), comb field plus gravity 9 per stud, step 0.02, pushed out to a layer offset of 0.012 to 0.077 with a root lift up to 0.075, hugged to the skull above mid-height; crescent locks with a pointed taper from 40 percent of the length; about 6,600 low triangles, 9,200 with the gap fillers. Rejected as a design (see above).
- Old shading (rejected as plastic): hair colour plus a highlight colour (black 24,24,28 with 92,100,122; brown 60,42,32 with 150,112,84; auburn 122,54,34 with 222,132,88) on curvature ridges and up-facing surfaces, roughness 0.4.
