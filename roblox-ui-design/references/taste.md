# Lepy's UI taste log

Every sentence Lepy has said about UI, with the date, the place and what changed. Read this before
every UI task. Add every new sentence here (date, place, quote, what was done) and push the skill
folder to `Streetdude123/roblox-skills`.

## Standing rules (from the log below)

1. **Simple and flat by default.** No rounded pills, no dark translucent tracks, no gradients, no
   glows unless the game's authored style has them. When "simple" is unclear, show 2-3 text mock-ups
   and let him pick.
2. **Match the game's own style.** Capture the authored panels first; build new panels by cloning and
   restyling an authored one (outline colour, gradients, font, strokes, close button). Each shop or
   panel gets its own palette inside the same structure.
3. **Never overwrite the artist's labels or add visible elements into authored panels.** Write a label
   only when its authored text is a placeholder for exactly that value. Report other states through
   the existing toast. Invisible fixes (Active, hit areas) are fine.
4. **UI is a real instance tree.** ScreenGuis, frames and templates exist in the place (StarterGui or
   ReplicatedStorage); code clones, positions and drives them; no `Instance.new` UI at run time.
5. **HUD pieces live in the existing HUD stack**, load with it, sit below what they must not cover; no
   separate ScreenGui placed by code that drifts on phones; no floating buttons beside the HUD column.
6. **Nothing covers information labels** (high ZIndex / AlwaysOnTop); no render defects (a 1 px seam is
   a fail).
7. **Test on a phone-sized view** (896 x 414 at least, and the device presets in `devices.md`) as well as
   desktop. Scale padding inside scale grids.
8. **Readable over pretty when he asks:** "doesn't matter how it looks" means label it clearly first.
   Required indicators from a brief stay even in the simplest pass.
9. **Code:** no comments, short natural names, modular, few defensive guards, ask before assuming, do
   only what he asked.

## The log

**2026-08-26, Sword Arena** - "you modified the UI and added (SOON) to the UI, don't do that, please
change that and revert UI back to what it used to be, it should still be functional."
-> Reverted every relabel ("SOON", "OWNED", "SHOP", "COMING SOON") and removed the added PriceTag
labels and UIStroke borders. Rule 3.

**2026-09-10, Ashes of Aboshima (menu)** - the authored menu was Jura, black on white, square corners,
1 px strokes, panels at 0.9 transparency. The new stats panel was cloned from the viewport panel so its
styling is the artist's; no colour, radius or gradient was invented.

**2026-09-12, Ashes of Aboshima (settings)** - he asked for shadows, blood and volume sliders "built as a
real instance tree" and matching the rest of the UI. -> White fills, 1 px black UIStroke, no UICorner,
Jura, rows named after their config keys.

**2026-09-14, Ashes of Aboshima (platforms)** - "a translucent black controls list on the left". ->
A 232-wide black panel at 0.7 transparency at the left middle, a Jura "CONTROLS" title, a hairline,
rows of action (left) and key (right, gold, bold), pad glyphs on a gamepad, hidden on touch.

**2026-09-16, Wacky Pets** - pick and fill prompts must be **BillboardGuis, not ScreenGuis** (world
buttons over the crop and the well, in the egg-OPEN style).

**2026-09-23, Grimoire / all projects** - "All UI and VFX must be built as a REAL INSTANCE TREE". Rule 4.
Also "Never try to assume anything", "Do NOT do anything I didn't ask", no comments, non-AI names.

**2026-09-24, Grimoire Battlegrounds (water mage)** - "Make the gui super bareboens and insanely
simple". -> The kit selector became a list of plain buttons at the top right plus one text line.

**2026-09-27, Wacky Pets** - "Make suee your GUI matches the style of the game"; "I don't like this
line, fix it" and "the line is here too???" (a 1 px seam in a four-frame dim overlay -> one hole frame
with a huge UIStroke); "Do you really gotta position the pet index there?" (a floating button beside
the HUD column -> moved into the Pets panel's side strip); "maka sure the z index for the pet stats is
high and none of it is covered please".

**2026-09-28, Wacky Pets (phone screenshot)** - "fix this issue on mobile by making the UI behave like
the coins UI and loading with it too instead of loading after, it's z index needs to be lower since it
covers some of the UI". -> The Next Goal bar and the Gifts button moved into the coin bar stack
(`CurrencyFrames` UIListLayout). Rule 5.
Then "is it alright if you change how the seedshop looks actually with the same color palette but
looks better and suits the game style more too? Do the same with the sell shop" (he picked the
Pets/Index card grid), and "The sell shop shouldn't look like the seed shop in terms of color palette
okay?" (he picked gold/yellow). Rule 2.

**2026-09-30, Vesna (stamina/hunger/thirst bars)** - "Make the gui simpler WAY simpler super simple
okay? It looks so AI right now so just make it super simple". The bars were 240 x 6 fills with
`UICorner(1,0)` on a 45% black track. He picked flat square bars with no dark track and no rounded
corners, colours kept (thirst blue, hunger orange, stamina white). Rule 1.

**2026-10-01, Scripter Combat Trial HUD** - "super duper simple" -> two thin flat lines; "make it
easier tontell which gui is which, doesn't matter how it looks" -> small coloured text labels beside
each line; "Make the bars thicker longer" -> 360 x 8; "make the bars actually match the font" -> the
same 1 px black outline as the text stroke (he picked only that: no track, no white fills). The parry
status became a centred 60 x 20 rectangle above the bars with its label above it. Final HUD: Oswald
Medium 12 caps off-white with a 1 px black stroke; colours health 255,140,30, stamina 255,215,50,
posture 185,145,20, parry grey -> lit 255,215,50.

**2026-10-03, this skill** - "You will be creating a roblox ui design skill ... Your own UI must be at a
professional advanced level, please research as much as possible for me take your time on this." Then
"Make sure you study correct UI for all devices too". Picks: **send the captures** with the report (for
UI work he wants to see the screens). Asked where to test while Studio held 5.2 GB with 0.65 GB free,
he answered "Make UI in the place itself" (the open Undertale Team Create place). -> The samples were
built in that place's own style as disabled `Lab_*` ScreenGuis; the authored UI was not touched.

**2026-10-04, Untitled Tower Defense (lobby 119472908687736, Forest 98611647936601, Frozen Peak
84729196662975)** - "I want you to improve the lobby UI significantly and the map in general please. I
think the forest map has some pretty good UI, ignore the win lose screen though, i'd like if you were to
fix it's UI." ... "The upgrade UI in my opinion is pretty good UI." Picks: the lobby UI matches the
Forest UI (charcoal panels with a fine diagonal stripe, white mono text, bright green primary and red
danger buttons, thin light borders - the upgrade panel is the style reference); the win/lose screen
keeps its content (gold reward, time, Play Again, Back to Lobby) with a new design in that style.
- During the merge: "Make sure the frost meter only appears if the frosty peaks map is loaded though
  when it's selected in the lobby" -> the meter (a side tab on the upgrade panel cloned from authored
  pieces: stat box, level pip with stripes, the Frosty Peaks frost bar and its ❄ label) is saved
  hidden and is shown only when the loaded map's data has `frost = true` (only Frosty Peaks).
- Win/lose result: same content (gold earned, time, Play Again, Back to Lobby) rebuilt from clones of
  the upgrade panel's own parts: charcoal card, striped header with the authored trophies or skulls,
  two stat cells (authored coin icon, an uploaded Phosphor `timer` glyph), green Play Again and red
  Back to Lobby side by side (stacked buttons were 40 px on a phone; side by side keeps them about
  46 px under the top bar). Card capped at 720 x 456 so desktop matches the old panel size; button
  text has 10 %/20 % padding so it never touches the edges on phones.
- Lobby: the Unit Shop, stats panel, radar chart, equip slots and Exit button were restyled to the
  Forest tokens without renaming anything; the queue pad billboards became a `ServerStorage`
  template (the old one was built with `Instance.new` in `QueueTeleport`) and float above head
  height. Open: the Shop's authored layout gives 12 px buttons on a Galaxy A16 and sits under the top
  bar - reported, not changed.
- Answer to the open Shop item: "Shop on phonws fix it." -> the Shop phone layout is fixed in the lobby pass (44 px+ targets, clear of the top bar).
- Later the same day: "Also completely change up the victory and death screen and the commander dialogue please". His picks from 3 mock-ups each: result screens = cinematic banner (the world stays visible but dark, a wide band with huge VICTORY or DEFEAT sweeps in, gold and time count up, buttons slide in, Forest colours) with the same content (gold, time, Play Again, Back to Lobby); commander dialogue = radio transmission (monitor panel, portrait with scanlines and a static flicker on open, INCOMING TRANSMISSION header, typed text, a radio click per line, boss lines in a red SIGNAL OVERRIDE version). Change the box design, the animation and sound, and the Commander portrait; keep the lines.
  - Rule: "completely change up" after a restyle means a new layout and presentation, not new colours on the old layout. Offer 2-3 different presentations as text mock-ups.
- "Make sure to always use the UI skill when you make UI, and modeling skill whenever you make maps and props and everytjing" -> this skill runs for every UI task, with no exception.
- Order and dialogue sound (2026-10-04): "Results screens + dialogue first" and "make sure theres a little sound effect for the commanders text everytime a letter is brought out by the dialogue" -> a short blip per typed letter in the commander dialogue.
- During the radio build (2026-10-04): "Make sure you remember all VFX and UI are built as real instance trees". The radio panel is a saved StarterGui tree (Dialogue > Root > Fit, Main > Panel, Tab, Screen, Body; Open, Close and Blip sounds; a Layout module) made once by a builder in Edit. At run time the code makes only the viewport Camera (cameras do not replicate) and a GetTextBoundsParams.
- On the result banners (2026-10-04): "Those emoji's ruin it kind of". His picks: the skulls on DEFEAT and the trophies on VICTORY, replaced by "Flat retro icons". Built: 16 x 16 pixel icons drawn at 256 px (a trophy in the VICTORY title yellow 255,238,0 and a skull in the DEFEAT title red 181,0,0, each with a black outline 8/256 of the icon like the 4 px title stroke, ResampleMode Pixelated). Rule: no emoji art in his UI; an icon is flat, one colour, square edges, in the colour and stroke of the text next to it.
  - Radio panel facts (measured): TextScaled chose about 12 px for a 59 character line in a 424 x 74 box; a fixed size per line from GetTextBoundsAsync fits better. Measure at floor(size x UIScale) against the absolute box, because the render rounds the scaled font to whole pixels (40 "x" at size 15 under UIScale 1.25: 280 logical measured, 360 absolute = 288 logical drawn).
  - Trap: calling a Layout module through a Clone() on the authored ScreenGui saves the phone values into StarterGui (the clone's held values are lost). Preview layouts on a Lab_ copy of the ScreenGui and delete it after.
  - Trap: in Play the Studio viewport is wider than the Edit crop region; an auto-crop from x 297 cut the left 286 px and made a centred banner look shifted. Use the Play region (x 12, y 196, 1444 x 620 on this machine).
- On the intro cutscene video (2026-10-04): "The black cinematic bar is kind of covering the commander dialogue fix that". A letterbox layer (DisplayOrder 5, bars at 12% of the screen height) covered the bottom-right radio panel (DisplayOrder 0). Rule: dialogue that must stay readable during a cutscene gets a DisplayOrder above the cutscene layer and below the result screens (Dialogue 10, Cutscene 5, Victory and Defeat 20); the builder sets it so a rebuild keeps it.
