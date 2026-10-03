# The five lesson videos Lepy assigned (2026-10-03)

Lepy sent these five videos with the request for this skill. Each one was studied in full: the
transcript came from the player's own caption request and the screens came from frame grids
(see the YouTube method in the r6 animation skill's `video-rotoscope.md` and the memory note on the
built-in browser). The lessons below are the ones to apply to every Roblox screen. The checklist at
the end is part of the hand-off for every UI task.

---

## 1. "4 Foundational UI Design Principles | C.R.A.P." - Jesse Showalter (9:15)

https://youtu.be/uwNClNmekGU

C.R.A.P. = **Contrast, Repetition, Alignment, Proximity**. "If you can master these four, your
designs go from meh to wow."

**Contrast** organizes the design, sets the hierarchy, marks the focal point and adds interest. Make
it with colour, weight, size and imagery.
- His demo: the headline went from 24 px to 54 px ("not an exact formula, it is just bigger") and
  from Medium to SemiBold (two weight steps). One word of the headline ("bikes") took the accent
  colour (yellow). The hero image (the bike) grew and ran off the edge of the canvas.
- The primary button is the filled colour; the secondary button is an outline next to it.
- Frames: before = small regular headline, body text far below it, small image, lone button. After =
  large bold headline with one accent word, body text tight under it, two buttons together, big image.

**Repetition** builds consistency and lets the player learn the interface ("it reduces confusion").
- Pick ONE card layout and make every card match it: same image side, same orientation (all bikes
  face the same way), bottoms aligned, even distribution. "It looks like a yard sale" is the before.

**Alignment** groups elements, makes rhythm, "brings order to chaos".
- Every element sits on an invisible axis. Left-align the text blocks; centre captions under their
  images; distribute the cards evenly. Even a rotated, experimental layout reads as ordered when its
  pieces share axes.

**Proximity** makes elements read as related ("everybody loves to have a friend").
- Related items go close together; groups separate with more space. Body copy belongs right under its
  headline; two buttons sit side by side; the fine print ("Black Friday 50% off") sits right under the
  button it belongs to; nav items get equal spacing and group together.

**Roblox translation:** a panel title is 2x the body size and one or two weight steps heavier; one
accent colour per screen marks the one thing to do; every card in a grid comes from one template;
everything snaps to the same left edge and the same padding; a label sits closer to its own value
than to the next row.

---

## 2. "Every UI/UX Concept Explained in Under 10 Minutes" - Kole Jain (9:23)

https://youtu.be/EcbgbKtOELY

**Affordances and signifiers.** A container around two items says they belong together; a container
around one says it is selected; grey text says it is inactive. "I didn't need to write instructions...
the UI was signifying how things worked." Signifiers: press states, active-tab highlight, hover
states, tooltips.

**Visual hierarchy** uses size, position and colour. Frames: a "spreadsheet" card (Item: / Day: /
Time: / Deliver To: / Pickup From: / Total Cost:) became a card with an image at the top-left, the
item name large and bold, the time small and grey under it, the price at the top-right in blue, and
the route shown with two icons and alignment instead of the words "from" and "to". Rules: the most
important thing is near the top, bigger and more colourful; use images whenever possible; contrast
(small vs big, colourful vs not) is what creates hierarchy.

**Grids, layout, spacing.** A 12-column grid is a guideline, not a law; grids help repeated content
(galleries, lists). White space matters more: "let things breathe". His landing example: 32 px
between every item, with grouped pairs closer (text + subtext). The 4-point system: every value is a
multiple of 4 "because you can always split things in half".

**Typography.** One sans-serif font is enough for almost any design. Large headings: tighten letter
spacing by about -2% to -3% and set line height to 110-120%: "it instantly makes any larger text look
super pro". No more than six font sizes on a page; dense dashboards rarely go above 24 px.

**Colour.** Start with one primary (brand) colour; lighten it for backgrounds and darken it for text,
which is half of a colour ramp. Semantic colours carry meaning: blue = trust, red = danger/urgency,
yellow = warning, green = success. "Use color for purpose, not just for decoration."

**Dark mode.** Lower the border contrast; there are no shadows, so depth comes from a lighter card on a
darker background (frames: stacked layers, the top one lightest); dim the saturation and brightness
of chips; deep purples, reds and greens work, not only navy and grey.

**Shadows.** Most are too strong: lower the opacity and raise the blur. Cards need little; content
above content (popovers) needs more. Inner + outer shadows make a raised, tactile button. "If the
shadow is the first thing you notice, you're not using it right."

**Icons and buttons.** Icons are usually too big: size them to the line height of the text beside them
(24 px for 24 px line height) and tighten the text. Ghost buttons are buttons with no fill until hover.
Button padding: horizontal padding = 2x vertical padding.

**Feedback and states.** "When a user does anything, there should be a response." Every button has
at least default, hover, pressed and disabled, sometimes loading. Inputs need focus, error and warning
states. Frames at 7:40: Default / Hovered (lighter) / Pressed (darker) / Disabled (grey) for one
button.

**Micro-interactions** confirm an action: a "Copied" chip slides up after the copy button is pressed.

**Overlays.** Text on an image: a full dark overlay kills the image; use a gradient that runs from
clear to a text-readable dark behind the text (optionally a blur).

**Roblox translation:** one font family per game with two or three weights; a type scale of six sizes
or fewer; spacing on a 4 px grid; one primary hue ramp plus semantic colours; every GuiButton gets
four states; every action gets visible feedback in the same frame (and a sound); text over the 3D
world sits on a gradient or a stroke, never on a flat full-screen dim.

---

## 3. "So You Wanna Make Games?? Episode 9: User Interface Design" - Riot Games (12:29)

https://youtu.be/sc3h5JXtIzw

**UX vs UI.** UX is the information architecture: where each piece of information lives and how the
player reaches it, "with the fewest necessary actions". UI is the visual layer built on that flow. UX
work comes first.

**Visual design** is "presenting complex information in a simple way that your audience can
intuitively understand and act upon". Know the audience: platform (Fortnite's PC and mobile HUDs
differ: frames show the mobile layout with big round action buttons on the right, the stick at the
lower left, the map top-left, the hotbar bottom-centre), genre (a card game is 90% UI; narrative games
can be minimal), and what information the player needs, and when.

**UI is an ecosystem.** Every screen (HUD, map, character select, inventory, skill tree, quest window)
must feel like one game: "rules for the meaning behind different colors, text, position on screen".
The League client started from a core theme (hextech magic) and wrote rules for typography,
iconography, colour, shape language and animation. Frame at 5:18, the League type sheet:

| Style | Font | Size / leading / tracking | Colour |
|---|---|---|---|
| Header 1 | Beaufort Bold, caps | 40 / 42 / 50 | #F0E6D2 |
| Header 2 | Beaufort Bold, caps | 30 / 32 / 50 | #F0E6D2 |
| Header 3 | Beaufort Bold, caps | 24 / 28 / 50 | #F0E6D2 |
| Header 4 | Beaufort Bold, caps | 18 / - / 50 | #F0E6D2 |
| Header 5 | Beaufort Bold, caps | 14 / 18 / 75 | #F0E6D2 |
| Header 6 | Beaufort Bold, caps | 12 / 12 / 75 | #F0E6D2 |
| Large text | Beaufort Medium | 16 / 24 / 40 | #A09B8C |
| Medium text | Spiegel Regular | 14 / 20 / 25 | #A09B8C |
| Small text | Spiegel Regular | 12 / 16 / 50 | #A09B8C |
| Gold link | Spiegel 12 | rest #CDBD91, hover #EFE5D1 | |

Lessons in that sheet: two families (a display face for headers, a plain face for reading); headers
in a warm off-white, body one step darker and greyer; caps get wider tracking, and the smaller the caps
the wider the tracking; a hover state is a brighter version of the rest colour.

**Layout** is a puzzle: proximity creates meaning ("a bar next to an enemy name = that enemy's health
bar; an XP counter next to a bar = level progress"), and layout decides how fast critical information
is found.

**Motion** makes the message felt. "You can't polish a bad design into functioning." The five goals of
UI motion:
1. **Responsiveness** - interactions are fast; clicking feels fluid and effortless.
2. **Intention** - motion leads focus to the key actions and pathways.
3. **Awareness** - elements respond from their location (frame: "UI moves with cursor").
4. **Consistency** - one element type always moves the same way.
5. **Physical intuition** - motion fits the game's brand and feels natural (friction, scale): a paper
   login screen moves like paper; the Worlds screen sweeps with parallax for grandeur.

**Workflow:** UX flow -> UI visuals (shape, colour, layout, values consistent across the game) ->
motion that reinforces the message, guides and gives feedback. **Advice:** play games and find their
pain points; copy what you love to learn (one designer recreated favourite games' HUDs and menus).

**Roblox translation:** before drawing, write the flow and the info priority; give each game a theme
sentence and a rule sheet (type table, colour roles, shape language, motion rules) and follow it on
every screen; animate from the source element, the same way every time.

---

## 4. "How you can make amazing game UI, the easy way" - BiteMe Games with Rive's co-founder (9:42)

https://youtu.be/E7zlgzldV40

**The failure mode** (frames 0:04): a day spent in the engine produces "black boxes with white text"
- an OPTIONS / VOLUME / BACK screen in plain orange text on a dark grid, or a dark translucent options
panel over the game with small white text and same-size tabs. No theme, no hierarchy.

**The contrast case** (frame 0:20): a "Select player" screen built from the game's own world: a frosted
pastel card with a white outline and cloud decorations, a character portrait, the name in bold
periwinkle, three stats, round arrow buttons and a "Play" pill with clouds on it. The UI uses the
world's palette, shapes and motifs, so it belongs to the game.

**Lessons:**
- The number one mistake is treating UI as an afterthought. "UI can make or break a game" - the most
  fun game is painful with bad UI. Think about UI from the start, as part of the look and feel.
- UI and gameplay must be "cohesive" and "part of the same story": the same first principles drive
  both.
- How to get good: look at great design and break it down from first principles - why does this
  typography work, what is going on with the grid, with proximity; open other people's files and see
  that "this thing aligns to that thing" and that alignment creates the relationship.
- Build the real, working UI with its states (Rive's state machines), not a mock-up that someone has
  to rebuild in code: designers should ship "real graphics that work".

**Roblox translation:** this is Lepy's rule that UI is a real instance tree. Build the actual
ScreenGui with all states (normal, hover, pressed, disabled, selected, empty, locked) as authored
instances, drive them from code, and make the UI from the game's own world (its colours, shapes,
props), never a generic dark box.

---

## 5. "Inventory UX Design - How Zelda, Resident Evil, and Doom Make Great Game Menu UX" - Design Doc (16:38)

https://youtu.be/5_3BUU9ZmNo

UX is "the experience of using the UI": how navigating feels and how easy the menus are to understand.
Inventories are specialised menus, so menu UX rules apply.

**Styles follow the game:** Zork's text list; Final Fantasy's ledger of counts (fine when items are not
unique); point-and-click sprites on a themed, skeuomorphic board (unique items, visual puzzles); Doom's
hotkeys (one key per weapon for a fast game); Elder Scrolls weights (realism - but realism can break
belief when it is gamed); Resident Evil 4's attache case (frame 6:05: a grid of items in a case - the
look says "limited space, specific rules", you Tetris items in); Moonlighter's curses (frame 6:50: the
bag is a puzzle). The best inventories "amplify the same message" as the other systems: scarce items ->
limited space and a matching look; a sprawling crafting RPG -> unlimited space and good sorting.

**Make the common task fast.** A menu exists to get a job done; "the faster you can finish a job the
better". If not every task can be fast, make the most common ones fast. Burying common items makes the
whole game feel clunky.
- Ocarina of Time: the Iron Boots were equipment, not a hotkey item, so every use was open menu ->
  equipment -> equip -> back out, many times per room. Fixed in the remake.
- Majora's Mask: three C-button slots for dozens of masks; time spent swapping eats the time the
  hotbar saves.
- Wind Waker HD: an always-visible inventory on the second screen = one less step every time, plus
  direct touch drag; context items (the sail) left the menu; the D-pad auto-maps boat tools while
  sailing (context-sensitive controls).
- Quick wheels: one button opens a wheel, the stick picks one of about 8 slots (frame 12:20: a hex
  wheel with the selected item's name and count); more slots, fewer swaps.
- Doom 2016: a tap swaps to the last weapon (the single most common action made the fastest); holding
  opens the wheel and slows time.

**Decide what the world does while the menu is open.** Keep running (Dark Souls, ZombiU: immersive,
demands a very clean, fast menu), slow down (Doom's wheel: time to think), or pause (the default: time
to plan). Each choice has trade-offs; pick by the game's values.

**Roblox translation:** for every screen, list the tasks by frequency and give the top task the fewest
taps (equip the best, sell all, quick-swap); put context actions on the HUD only while they apply (a
PICK button near a ripe crop, a FEED button when a pet is near); on touch, show the hotbar instead of a
menu trip; decide and state whether the game keeps running while a panel is open (Roblox games do not
pause: so the panel must be fast, and must not block movement unless that is chosen).

---

## The checklist (answer it in every UI hand-off)

1. **Contrast:** is there exactly one focal point per screen, and is it the biggest, boldest or most
   colourful thing?
2. **Repetition:** do all cards, rows and buttons of one kind come from one template?
3. **Alignment:** does every element share an edge or centre line with another? (Read the X and Y
   numbers, not the picture.)
4. **Proximity:** is the space inside each group smaller than the space between groups?
5. **Signifiers:** can a player tell what is clickable, selected, locked and disabled without text?
6. **States:** does every button have normal, hover (not on touch), pressed and disabled, and does
   every action give feedback in the same frame?
7. **Type:** one family (two at most), six sizes or fewer, large headings tight, caps tracked wide?
8. **Colour:** one primary ramp, semantic colours used only for meaning, colour never the only signal?
9. **Theme:** does the screen use the game's own palette, shapes and motifs, or is it a generic box?
10. **UX:** is the most common task the fastest one? What happens to the game while the panel is open?
11. **Motion:** fast, from its source, consistent per element type, fitting the game's feel?
