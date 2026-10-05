# Lepy's modeling taste - feedback log

Log every sentence of his feedback on models here, with the date and the model, then push the skill folder.

## 2026-10-03 - skill creation session

- Request: "Start creation of the roblox modeling skill, research as much as possible and take your time, you'll be using blender yo model most of your assets please learn how to model and create skill in my roblox skills repository please." He sent three lesson videos (lesson-videos.md).
- During the research: "Make sure your modeling is basically a super advanced professional level please"
- After the crate and the longsword: "I like if you'd put more detail into your models to make them more intricate please"
- During the rock formation: "For like terrain i'd say dial down on the intricacy, for characters and props and weapons and items such stuff like that, that's when i want you to bring out your creativity and intricacy to detailing the objects"
- After the ornate chest v1: "Looks nice, problem is i think it looks too perfect, it should be perfect but not too perfect to the point where it basically unrealistic. Make sure you scan the game beforr you make models too so that you can get the games style before you make models"
- Studio test place choice: local preview inside UT:EF under the local camera, nothing uploaded or saved.

## 2026-10-03 - samurai character

- Request: "Make a super cool samurai model for me, you can close the current place i don't care just make sure it's saved"
- His answers to the scope questions: R6 armored character; a new place; anime style; gear = straw hat (kasa), katana in hand, daisho on the hip.
- After the blockout and the v1 renders (boxy indigo haori with big box sleeves, a large lacquer sode on one shoulder, wide hakama, painted anime eyes): "The clothing looks horrible and the proportions are terrible, keep it faceless"
  - Meaning for the next build: no face features; the cloth and the body proportions need a new design agreed with him on a picked reference before the blockout.
- His answers to the rebuild questions: heavy armored build (big silhouette from armor plates); light armor over kimono (kimono and hakama close to the body, chest plate, two shoulder plates, bracers, shin guards); faceless = blank skin, no eyes (hair, mask and hat stay); numbered reference candidates first.
- "Please use references, just like how you animate use heavy reference"
  - Rule 6 in SKILL.md: no blockout before he picks a reference; match the pick closely.
- His pick from 8 numbered candidates: "Heavy lamellar armor, wide hat" (Edrey Aldana, "3D Roblox Character - Samurai for ZO Roblox video game", artstation.com/artwork/kNlGAd: R6, red-brown lamellar do, 4-tier kusazuri, stepped shoulder and forearm plates, chainmail sleeves with rope, splint shins, wide black hat with a studded crown).
- His answers where the pick and the first answers disagreed: match the pick under the armor (chainmail sleeves with rope, splint shin guards with rope bows, straw sandals); the pick's wide hat; long white hair and a plain armored half mask with no eyes, no tusks and no face features; the pick's colours (dark red-brown lacquer, brass slots and rivets, white rope, dark grey chainmail, black hat).
  - Rule: when a pick conflicts with an earlier answer, ask; the pick won on every point here.
- After the rebuilt blockout and the high clay beside reference 2: "Much better, i really like this remember how you built this but the model has to be significantly more detailed and intricate complex"
  - The method is in character-from-reference.md (pick, measure, sample the pick's maps, ask on conflicts, plate frames, show before the bake).
  - Next pass: far more detail and intricacy on top of the same construction.

- On the finished samurai in Studio: "looks good already, make sure to store what you learned in the modeling skill please, this type of modeling should be the baseline minimum for modeling, unless the game's style or quality calls for quality less of this. Finish this up and we'll go to the real game where you'll begin modeling for my game."
  - SKILL.md rule 9: the samurai is the minimum standard; go lower only when the game's style scan calls for it.

## 2026-10-04 - Untitled Tower Defense lobby map

- Request: "I want you to improve the lobby UI significantly and the map in general please." (with /roblox-modeling)
- His picks: the lobby map; "Retro bricks, richer" - keep the studded blocky style of the game and add better props, set dressing, lighting and composition in that same style. This is the case rule 9 allows: the game style is lower fidelity than the samurai, so match the style scan, not the samurai detail.

- His answers after the sheet of 8 numbered candidates: "I like yhe little pathway I create with the fireflies and trees and lanterns i create that lead into the real lonby so try to incorporate that just make it shorter. I pick the stud village, number one. Keep the lighting the reference i pocket. Change layout."
  - The pick: reference 1, stud village (timber houses, stone tower, stairs, dirt paths, cube trees, red mushroom), devforum.roblox.com/t/2939498.
  - The light matches the pick, not the old lobby light. The layout is new.
  - Rule: when he names a set piece he made himself (here the entry path with trees, lanterns and fireflies), move and reuse his real instances in the new layout; change only what he asks (here: shorter).

- "Make sure to always use the UI skill when you make UI, and modeling skill whenever you make maps and props and everytjing"
  - This skill runs for every map, prop and part build too, not only for Blender meshes.

- On the plan v1 drawing (top view: meadow with his shorter tree tunnel, two stud stairs up an 8-stud cliff, the square with the 4 portals on the plateau): "Build plan v1". On five giant background cube trees that hid the open sky and sea of the pick: "Move them to ServerStorage".
  - Rule: for a map, draw a numbered top-view plan from the pick and get a yes before the blockout; move removed pieces to ServerStorage, never delete them.

- During the build: "You may change the structure of the map however you'd like" -> the layout, terrain and placement of his pieces are free for this lobby pass (his named pieces still stay in use).

- Later: "make the walk shorter too from spawn to elevators, and change up how the tower looks by making it more details and complex in shape and intricacy". His picks: the timber towers and the round stone tower get the detail pass; the walk from the spawn to the nearest elevator about 5 seconds (the tree path shorter again, the elevators in the east half of the square near the stairs).
  - Rule: a lobby walk to the queue is a cost; about 5 s (80 studs) is his target.

- Later the same day: "Make the map much larger please so players can explore more and the game will be adding new features in the lobby, this also gives the elevators more space. Maybe add npcs around the map, just make it SO much bigger." His picks: about 4x the area (open plazas kept for future features); the walk from the spawn to the elevators may be longer now. NPCs: "make sure the villagers are dummies, as this is a dummies vs noobs game. Add ambient villagers that can talk to you when you get close enough to them. Make sure it's just a dummy from the toolbox with a dark gray torso and some accessories attatched to them. Make placeholder prompts".
  - Rule: in Untitled TD the player side is dummies and the enemies are noobs; friendly NPCs are dummies.

What it means in practice (applied in this skill):
1. Items, props, weapons, characters: intricate, creative, layered detail (chest.py is the reference).
2. Terrain: calm big forms (rock.py final pass).
3. Controlled imperfection on everything (imperfection.md).
4. Style scan before modeling (style-scan.md).

- Same day, while the Forest work ran: "Don't forget the lobby task too okay?" and the order "Cutscene, king, and then lobby". The 4x lobby with dummy villagers is next after the Forest cutscenes and the Noob King animations.
- For the Forest intro he asked for a portal frame that shows the noob kingdom's homeland through it with nothing behind it ("Like the door from suzume? but make it a portal instead"). The homeland and the frame are models: they need the numbered reference pick like every model.
- 2026-10-04, after the cutscene videos: "after fixes with the king, don't forget the lobby". The lobby (4x with dummy villagers) follows the Noob King animation fixes.
- 2026-10-04 (Untitled TD lobby, 4x pass): from three numbered top views (now, option 1, option 2) he picked "Option 1: all sides": the island grows to about 880 x 600 around the current village, open north, south and west plazas for future features, a market street, new house clusters, a bigger forest, and the elevators stay (5 s walk). Villagers: "12", "Walk short routes" (stop when a player comes close, turn and talk), "Bubble over head" (the game's UI style, typed line, about 12 studs).
- 2026-10-04 (Untitled TD lobby villagers): from a numbered sheet of 6 R6 Toolbox dummies plus 2 accessory packs (torso set to the towers' dark grey) he answered "1. Scientist, 2. Fedora, they have to have the same body type but just accessories on." and "4. Top hat, 6. Side hair, shirt print", packs "No, picked looks only", the other body parts "Like the towers", the clothing, prop and print "Keep all of them", the face "Classic smile for all", the size "Player size". Then: "Publish changes after this please".
  - Rule: NPC variants share one body (same rig, colours, face and size); the variety is in what they wear and hold. Take the body colours from the game's own units (here the tower dummies: grey head and arms, Smoky grey torso, black legs).
  - Rule: when his words ("just accessories") and a pick conflict (a pick with clothing, a held prop and a decal), ask which wins before you build.
  - Method that worked: insert candidates into ServerStorage, read and delete every script, stage them in a row in the target map, capture each from the same 3/4 camera, compose one numbered sheet; build the picks as real templates with standard R6 attachments and hand-made AccessoryWelds (Humanoid:AddAccessory in Edit makes no weld).
- 2026-10-04 night (Untitled TD lobby shopkeeper): "New outfit" -> a numbered sheet of 6 outfits built from official Roblox catalog accessories (catalog API search with CreatorName=Roblox, then InsertService:LoadAsset in Edit) on the same villager body; he picked "outfit 2" (Kbux's Accountant Visor, Master of Disguise Mustache, Midnight Blue Checkered Bow Tie).
  - "make sure the cannon for cannoneer is actually there on the figurine and it correctly rendsand supported with a proper wooden base." -> the figurine's root anchored (the Cannoneer gunner's root was unanchored and dropped between frames) and a two-layer base made from the shop stand's own studded wood mesh (9651888717), sized to each figurine's footprint.
  - "Hide the humanoid root part please and try not to make the shop kodelmparts so glitchy" and "Not the shop figurine the like shop stand model itself". The Toolbox R6 body under all villagers had its HumanoidRootPart at 0.5 transparency (a still grey box during emotes); now 1. The shop stand's counter top was nine overlapping boards with coplanar faces (21 z-fighting pairs). Rule: check every authored model a close camera will show for overlapping parts with coplanar faces and give each a unique offset (here +0.004 studs height and +0.008 depth per board, originals kept in OldCFrame/OldSize attributes); check a rig's root part transparency before you use it.
