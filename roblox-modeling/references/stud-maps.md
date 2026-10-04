# Stud-style maps built from parts (the Untitled TD lobby, 2026-10-04)

Use this method when a game's style scan shows a part-built "retro bricks" look (studs, inlets, flat colours) and the request is a map or a set of props for it. Blender meshes are the wrong tool for that style: the target is Parts with the place's own stud surfaces.

## 1. Read the style the place already uses

- The lobby's stud look came from two sources, found with `StyleScan.lua` plus a surface count: a `Studs` MaterialVariant (Plastic, 1 stud per tile, a colour and a normal map) on 3,215 parts, and the classic `SurfaceType.Studs` / `Inlet` on about 2,400 parts.
- A test bench of four 6-stud cubes (variant, Studs surface, Inlet surface, variant + Inlet) under the target light showed the vocabulary of the pick: raised rounded studs = the variant (grass, dirt, roofs, canopies); dark square holes = `Inlet` on every face (stone, trunks, step fronts); the quilted blue-grey wall of the reference = `Enum.Material.DiamondPlate`; cream plaster = SmoothPlastic.
- Alternating rows of studs and holes (the reference's round tower) = wall courses 2 studs tall that alternate Inlet and variant.

## 2. Plan before the blockout

- Draw a numbered top view of the current map from bounding boxes (`plan_draw.ps1`) and the proposed layout (`plan_new.ps1`), send both, and get a yes. He answered "Build plan v1" and then "You may change the structure of the map however you'd like".
- Keep his named set pieces (here a tree tunnel with lanterns and fireflies, a gate, a statue, a watch tower, a training yard). Move them as whole models with `PivotTo`; record each old pivot so the session can undo; move removed pieces to `ServerStorage.LobbyArchive.*`, never delete them.
- Function first: the walk from the spawn to the queue is a cost. His target was about 5 s (80 studs at WalkSpeed 16). Measure it in Play with `Humanoid:MoveTo` along the real path, not a straight line (a diagonal waypoint ran into a rock).
- Sightlines: nothing big between the arrival point and the thing the player came for. A hero cube tree at the stair top blocked the elevator previews; two smaller trees flanking the arrival fixed it.

## 3. Builders (`scripts/studio/stud/`)

- `Village.lua` - `V.part(parent, name, cf, size, color, kind)` with kinds `studs`, `inlet`, `diamond`, `neon`, `smooth`; `stairs` (solid steps + stone rail cubes, step fronts Inlet), `mushroom`, `lampPost`, `fence`, `cubeTree`, `house` (stone ground floor, jettied timber upper floor, strip gable roof with plaster gables), `tower` (v1), `roundTower` (v1), `pond`, `wheat`, `disk`, `block`, `bush`, `flowers`, `bench`, and the palette `V.C`.
- `Towers.lua` - `V.tower2` (chamfered stone base in alternating courses, stepped buttresses, arched plank door with hinges and wall lanterns, arrow slits, corbelled ledge, jettied cross-braced timber story with shutters and flower boxes, pent skirt, octagonal lantern story with a balcony, optional belfry with a bell, stepped roof with four dormers, cupola, spire, pennant; about 440 parts) and `V.roundTower2` (stepped plinth, alternating courses, pilasters, arched glowing windows, a timber gallery on struts with a pent roof, machicolations, crenellated parapet, stepped cone roof, flag, banners, arched door; about 550 parts). His words for this pass: "more details and complex in shape and intricacy".
- `Paths.lua` - rasterises rings and segments on a 2-stud grid with edge jitter and merges each row into strips: blocky hand-laid dirt paths like the reference for about 300 parts.
- Load: `local V = loadstring(src)()` then `loadstring(towersSrc)()(V)`.

## 4. Colour by measurement

- Sample the reference at named points (`sample.ps1`, 9 x 9 average; draw a 50 px grid first, guessed coordinates hit the wrong objects), render the same view in Studio, sample the same points, and correct the albedo. The response is not linear: grass albedo G 88 rendered 77, G 108 rendered 101, G 137 rendered 133 (target 136).
- Warm lighting turns greys cream: stone needs a blue push (86, 94, 118) to read as the reference's blue-grey.
- Recolouring by nearest palette colour is a trap when two palette entries are close: timber (96, 62, 42) sat 0.04 from the step colour and 522 timber parts took the step colour. Recolour by part name inside the building models instead.
- Final palette under his reference light: grass 37/137/60, dirt 134/94/66, path 110/80/60, step 120/82/60, stone 86/94/118, stone light 108/116/138, diamond 104/116/152, plaster 226/214/186, timber 86/58/42, roof 140/102/84, leaf 40/130/56, trunk 92/72/58, mushroom red 226/64/60.

## 5. Traps measured on this build

- A Model made with `Instance.new` gets its pivot at the bounding-box centre: `PivotTo` a ground CFrame sank benches 1.95 studs. Every builder now sets `m.WorldPivot = at`.
- The Studio editor camera turns back to `Camera.Focus` when Studio regains focus; set `Focus` with `CFrame` for scripted Edit captures.
- A free skybox search returned malicious "pastel" skies; the same look came from the built-in volumetric `Clouds` (pink 255/214/196, cover 0.78) plus Atmosphere colour 236/206/200 and decay 150/140/180.
