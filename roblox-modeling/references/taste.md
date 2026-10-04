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

What it means in practice (applied in this skill):
1. Items, props, weapons, characters: intricate, creative, layered detail (chest.py is the reference).
2. Terrain: calm big forms (rock.py final pass).
3. Controlled imperfection on everything (imperfection.md).
4. Style scan before modeling (style-scan.md).
