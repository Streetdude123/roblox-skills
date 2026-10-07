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

## Natural fall: gravity drape (current method, 2026-10-06)

His note on the volume-shell hair: "let the hair fall naturally, kind of looks like it's floating". A shell around the head with clumps laid on it reads as a helmet that hovers. The fix is to grow every lock from the scalp and drape it (`drape`, `add_dlock`, `scalp_cap` in `Shinsenkyo/blender/convicts/core.py`; styles in `hair_styles.py`):

- Collide against the real head shape: a rounded-box SDF with the R6 head half sizes and the 0.3 bevel radius (`head_sdf`). A superellipsoid sits 0.05 off the flat faces and inside the corners, so hair either floats or clips.
- Roots: Fibonacci directions kept above a hairline (front 28, sides -8, back -36 degrees from the head centre), about 62 locks from 112 directions.
- Each step: blend the direction toward a comb field, add gravity 9 per stud, step 0.02, push out to the layer offset, and above the head's mid-height pull the lock back to that offset (hug 0.6) so it lies on the skull; below mid-height it hangs freely.
- Layer offset 0.012 to 0.077 and root lift up to 0.075 by closeness to the part or the crown whorl: hair from the top lies over hair from lower down, which gives volume without a shell.
- Styles: middle part (comb away from x = 0, front locks steered by a waypoint beside the temple), side part (part at x 0.24, fringe steered across to the far temple, stopped above the brows), messy (comb away from a crown whorl, random twist, some tip flicks), combed back to a low tie (great-circle field toward the tie plus a backward bias near the front, because the great circles diverge at the antipode on the forehead; flat bands with tapered roots so the hairline shows no square ends; tail draped against the robe back).
- Pointed tips: full width to 40 percent of the length, then taper to 1.5 percent; wider rounded tips read as drips.
- Cost: about 6,600 low triangles per style (curtain, side, messy), 9,900 for the tied style with the tail.
- His verdict on the four drape styles: N1 middle part and N2 side part "pretty good"; N3 messy layers and N4 combed back "bad". Build from clear parts with wide locks; do not use many narrow pointed locks or flat sleek bands.

## No gaps (2026-10-06, "Fill this gap")

The first N1 build on A2 showed the scalp cap at the middle part and at the crown. With the cap AO and the steep normals of the lock root ends it read as a dark hole. Three changes in `drape_hair` (core.py) closed it:

- Part roots: 8 pairs of roots 0.02 studs left and right of the part line, from the front hairline (32 degrees) over the top to the crown (130 degrees). Remove the random roots within 0.12 studs of the part (up to y 0.42) so the count stays low.
- Root tuck: every lock starts 0.01 inside the scalp (`root_off=-0.01`) and rises to its layer offset with a smoothstep over 0.15 studs (`rise`), and the lift uses the same ramp. A lock that starts at its layer offset (up to 0.077) leaves its flat root end in the air; that end and the gap under it bake to steep normals and dark spots.
- Coverage test (`bare`): 3,600 points on the scalp above hairline + 8 degrees, each with one ray along the head normal and eight rays tilted 37 and 52 degrees (only the rays that point up, z > 0.2), reach 0.5, against a BVH of the low locks. A point where any ray escapes is bare. Grow a filler lock at each bare point (skip points within 0.13 of a filler, layer offset x 0.6 so it sits under its neighbours) and test again; 3 rounds. On A2: 105 bare points and 18 fillers in round one, 1 bare point and 1 filler in round two, then 0.
- Blend the comb at the crown: a hard switch from side locks to back locks (at y 0.3) leaves a bare wedge between them. Interpolate the comb and the end height with a smoothstep over y 0.12 to 0.42.
- To find gaps, render the test head with the cap in bright green (`hair_gap.py`): top, front top, front, three quarter, back top and side, low and high.
- Cost on A2: 59 locks and 6,668 head triangles before, 87 locks and 9,244 after.

## Research 2026-10-06: what good hair needs ("Your hair design is horrible")

His verdict on the gravity-drape hair after the textured A2 sheet. Research he asked for (design tips, real hair, modeling tips), with sources:

Why the drape hair failed, measured against the sources:
- No big shape. The hair followed the R6 box with a uniform offset, so the silhouette was a box. Professional hair starts as a designed "helmet" mass with a clear silhouette, then clumps, then strands (80.lv ZBrush hair guide; stylized sculpting guides).
- Uniform clumps. 87 locks of almost one width (0.24 to 0.32), one thickness (0.06) and one taper read as shingles or "spaghetti". Clumps must vary: some thick, some medium, some thin, with a few hero clumps (Polycount critiques).
- Wrong lock shape. A constant crescent section reads as a flat strip. Good stylized locks are blades or leaves: thick at the root, widest near a third of the length, then a long taper to a sharp tip, with thickness (Ready Player Me hair style guide: "curls and strands should have thickness"), on C and S curves (Clip Studio hair tutorials).
- No designed flow. Gravity and a comb field made stiff parallel strips. Hair flows out from one source near the top back of the head (the crown whorl), clumps pass over and under each other in a designed order, and the flow is broken on purpose by a few wisps (80.lv hair flow analysis).
- Plastic texture. Flat colour with curvature highlights and AO blotches. Avatar hair guides paint 3 shades (base, darkest in the shadows, a lighter shade on top), then strands, then a few highlight pops and defined ends; little dark on the fringe; too much highlight reads wet (Highrise hair art guide). Real hair shows a highlight band across the strand direction (anisotropic "angel ring") and darker roots and undersides.

Real hair (barber and drawing sources):
- Hair grows out from the crown whorl (most people have one, near the midline at the crown; it usually turns clockwise); the direction of every region follows from it; near the whorl the hair lies flat along the skull.
- Hair rises from the root and then falls under gravity, so the hair mass sits above the skull with volume; straight hair lies flatter, short hair lifts more. Draw the skull first and keep the hair a varied distance above it.
- Natural fall = hanging under gravity alone. A middle part makes two rounded domes that lift at the part, arc out over the temples and turn in at the ends (photo study R8): the front silhouette is a bell, widest at the temples.
- An off-centre part puts more volume on the larger side.

Roblox UGC hair that sells (catalog study, middle part, 2026-10-06): a big rounded silhouette about 1.6 to 1.8 head widths; a narrow, clean part with lift on both sides; layered tiers (top, middle, darker under layer at the nape); many thin-edged pointed locks breaking the outline; a jagged hem with tips at different lengths; strong painted strand texture (dark gaps, light strands, root-to-tip gradient). Low-poly anime hair (Blender packs) = a shaped cap plus many long pointed blades from the crown.

Rules from now on:
1. Hair gets a numbered reference sheet and his pick like every model (sheet: `Shinsenkyo/references/characters/hair_refs_R1_R8.jpg`). Match the pick's silhouette in front, side and back before any lock is placed.
2. Build in the order big, medium, small: the mass, then 6 to 12 hero clumps, then medium clumps, then a few wisps. Vary width, length and thickness at every level; avoid symmetry.
3. Every clump is a tapered blade with thickness, on a C or S curve, with a sharp tip. No clump of constant width.
4. Design the flow from the part and the crown whorl, and decide which clump passes over which.
5. Texture: 3 shades plus strand lines along each clump, darker roots and undersides, a soft highlight band, defined tips.

Sources: 80.lv "Guide: Sculpting Stylized Hair in ZBrush" (Dan Eder); 80.lv "Designing a Real-Time Traditional Chinese Hairstyle in Blender"; Ready Player Me (wolf3d) style guide; Clip Studio TIPS "Drawing Stylised Hair: Shapes, Tufts & Strands", "Let's Draw Hair! by Ricky", "The Science behind HAIR Highlight"; Envato Tuts+ "What You Need to Consider When Drawing Hairstyles From Scratch"; Highrise "Hair & Hair Textures" art guide; Red Seal hairdressing study guide 5.5 "Growth Patterns, Natural Fall"; hair transplant clinics on the crown whorl; Roblox DevForum "How to make hair in Blender"; ArtStation stylized hair packs (World Dream, Stylized Male Hair Vol 1 and 2); Roblox catalog middle-part hairs.
