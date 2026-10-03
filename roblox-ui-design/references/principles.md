# UI design principles (the theory behind every rule in SKILL.md)

Sources are listed in `sources.md`. Each section ends with what it means on Roblox.

## 1. UX first, UI second

- **UX** is the information architecture and the flow: where every piece of information lives, how
  the player reaches it, how many steps each task takes. **UI** is the visual layer on that flow
  (Riot). Write the flow before drawing a pixel.
- Hodent (The Gamer's Brain) splits game UX into **usability** and **engage-ability**.
  - Usability pillars: **signs and feedback**, **clarity**, **form follows function**,
    **consistency**, **minimum workload** (cognitive and physical), **error prevention / recovery**,
    **flexibility** (remapping, accessibility options).
  - Engage-ability pillars: **motivation**, **emotion** (game feel), **game flow** (difficulty and
    learning curves).
- Roblox's own UX guidance: know the players (age, device, experience, genre familiarity, play style),
  use **conventions** (E to interact, C to crouch, number keys for the toolbar, walk into a circle to
  queue), use **metaphors** (cards for spells), give **feedback** for every action, and reduce
  **friction** (count the taps from wanting something to having it; draw the flow as a chart).

**On Roblox:** for each screen, write: who uses it, the task list sorted by frequency, the steps per
task, and what the player must know this second versus what can live in a menu.

## 2. Hierarchy - the single most powerful lever

- Hierarchy is the perceived importance of elements, controlled by **size, weight, colour, contrast,
  position and spacing** (Refactoring UI). It is what makes a design look professional.
- Contrast creates hierarchy: small vs big, colourful vs not (Kole Jain). The most important item is
  near the top, bigger, bolder, more colourful; images help scanning.
- **Emphasize by de-emphasizing:** when the main thing does not stand out, make the others quieter
  (lighter weight, softer colour) instead of making the main thing louder.
- Do not lean only on font size: weight and colour do most of the work. Use 2-3 text colours (primary,
  secondary, tertiary) and 2 weights (regular 400-500 and bold 600-700). Avoid weights under 400 for UI.
- **Labels are a last resort:** "12 Kills" beats "Kills: 12"; a coin icon beats the word "Coins".
- **Action hierarchy:** one primary action (solid, high contrast), a couple of secondary actions
  (outline or low contrast), tertiary actions as plain text. A destructive action that is not the
  primary one does not need to be big and red; confirm it instead.
- Roblox's attention tools (UI and UX design doc): **colour** (bright beats dull), **size**, **space**
  (padding makes things eye-catching), **proximity**, **movement** (motion draws the eye) - "moderation
  is key", too many bright or moving things cancel each other.

**On Roblox:** one focal point per screen; the buy or play button is the only filled accent; secondary
info is a lighter, smaller text colour; never three things competing in the same bright colour.

## 3. Gestalt and the Laws of UX (lawsofux.com)

Grouping:
- **Proximity:** near things read as one group. Space inside a group < space between groups.
- **Similarity:** things that look alike read as related (same colour = same kind).
- **Common region:** things inside one bordered area read as a group (cards, panels).
- **Uniform connectedness:** visually connected things read as more related (a line, a shared bar).
- **Prägnanz:** people read complex images as the simplest shape possible - keep silhouettes simple.

Decision and memory:
- **Hick's law:** decision time grows with the number and complexity of choices. Fewer options per
  screen; progressive disclosure (show the common path first, advanced one level deeper).
- **Choice overload:** too many options overwhelm.
- **Miller's law / working memory:** about 7 +/- 2 items; **chunking** groups information into units.
- **Cognitive load:** the mental effort to use an interface; cut it with familiar patterns.
- **Serial position:** the first and last items are remembered best - put key actions at the ends.
- **Von Restorff:** the one that differs is remembered - the one accent button.
- **Zeigarnik:** unfinished tasks stay in mind - progress bars and "2/5" counters pull players back.
- **Goal-gradient:** effort rises as the goal nears - show how close the next reward is.
- **Peak-end:** an experience is judged by its peak and its end - make reward screens and results great.

Motor and time:
- **Fitts's law:** the time to hit a target depends on its distance and size. Big targets for common
  actions, near where the thumb or cursor already is; screen edges and corners are easy for a mouse but
  hard for thumbs on tablets.
- **Doherty threshold:** keep responses under 400 ms; acknowledge every input within 100 ms (visual
  press state now, the result later).

Expectation:
- **Jakob's law:** players spend most of their time in other games - match their conventions.
- **Mental model:** match what players already believe about how a thing works.
- **Paradox of the active user:** players never read instructions; they start pressing.
- **Aesthetic-usability effect:** good-looking UI is perceived as easier to use (and forgiven more).
- **Tesler's law:** some complexity cannot be removed; the designer absorbs it so the player does not.
- **Postel's law:** accept messy input (forgiving hit areas, any input device), output clean and
  consistent results.
- **Pareto:** 20% of the screens and actions get 80% of the use - polish those first.

## 4. The design system (Refactoring UI, distilled)

- **Start with a feature, not the layout.** Design one real piece of functionality first.
- **Design in grayscale first**, then add colour: hierarchy must already work from spacing, size,
  weight and contrast.
- **Choose a personality:** serif = elegant/classic; rounded sans = playful; neutral sans = plain.
  Blue = safe and familiar; gold = expensive; pink = fun. Small radius = neutral, large radius =
  playful, square corners = serious/formal. Keep one radius family everywhere.
- **Limit your choices in advance:** a spacing scale, a type scale, 8-10 shades per colour, ~5 shadow
  levels, a fixed set of radii, border widths and opacities. When unsure, try the values on either
  side and pick by elimination.
- **Spacing:** start with too much white space and remove it. Adjacent scale steps differ by at least
  ~25%: 4, 8, 12, 16, 24, 32, 48, 64, 96, 128. More space around groups than within them.
- **Text:** hand-picked type scale (12, 14, 16, 18, 20, 24, 30, 36, 48, 64); line length 45-75
  characters; line height inverse to size (1.5 for body, ~1.0-1.2 for headings); align mixed sizes on
  the baseline; left-align most text; right-align numbers in tables; tighten large headings; track out
  all-caps text.
- **Colour:** think in HSL. Greys 8-10 shades; a primary 5-10 shades (100-900, base 500); accent and
  semantic colours 5-10 shades each. Raise saturation as lightness moves away from 50%. Rotate the hue
  up to 20-30 degrees toward a brighter hue (60, 180, 300) for light shades and toward a darker hue (0,
  120, 240) for dark shades. Tint greys warm or cool. Never grey text on a coloured background - pick a
  lighter or darker shade of the background's hue. Contrast: 4.5:1 for body text, 3:1 for large text.
  Never rely on colour alone.
- **Depth:** light comes from above: a raised element has a lighter top edge and a small dark shadow
  under it; an inset element has a lighter bottom edge and a shadow inside the top. Define ~5 shadow
  levels (button < dropdown < modal). Two shadows (a tight dark one and a large soft one) look most
  real. In flat design, lighter = closer, darker = further; or use a short offset shadow with no blur.
  Overlap elements to show layers.
- **Images and icons:** do not scale bitmaps or icons above their native size; put a small icon in a
  coloured shape instead of blowing it up. Text on images needs an overlay, lower image contrast, or a
  soft text shadow.
- **Finishing touches:** accent borders on cards/alerts; empty states designed like real screens
  (illustration + call to action); fewer borders - use spacing, background shades or shadows instead.
- **Level up:** ask "did the designer do anything I never would have thought to do?" and recreate
  favourite designs from scratch.

## 5. Nielsen's heuristics, in game terms

1. Visibility of system status (timers, cooldowns, loading, "saving...").
2. Match the real world and the game's fiction (words and icons players know).
3. User control and freedom (close, back, cancel, undo a purchase within seconds where possible).
4. Consistency and standards (X closes, grey = disabled, lock = locked, red price = unaffordable).
5. Error prevention (confirm only destructive or expensive actions; disable impossible ones).
6. Recognition rather than recall (show the item, do not make the player remember its name).
7. Flexibility (shortcuts for experts: hotkeys, quick-swap, sell all).
8. Aesthetic and minimalist design (every element earns its place).
9. Help players recognize and recover from errors (say what went wrong and what to do).
10. Help and documentation (contextual, short, at the moment it is needed).

## 6. Game UI types (Fagerholt and Lorentzon, "Beyond the HUD", 2009)

| Type | In the 3D world? | In the fiction? | Roblox carrier | Example |
|---|---|---|---|---|
| Non-diegetic | no | no | ScreenGui | HUD bars, menus |
| Diegetic | yes | yes | SurfaceGui on a part, a prop | Dead Space health spine, a wrist screen |
| Spatial | yes | no | BillboardGui, Beam, highlight | waypoint markers, name plates, damage numbers |
| Meta | no | yes | ScreenGui effect | red screen edges when hurt, blood on the lens |

Diegetic and spatial UI are the most immersive; non-diegetic is the densest and the cheapest to build.
A horror game leans diegetic and meta; a simulator is almost all non-diegetic.

## 7. Roblox's own UI rules (UI and UX design doc, UI design curriculum)

- **Prioritize:** share the most significant information first; show only what is relevant now; swap
  buttons by context (Spellbound RPG shows skill buttons only after the Items button).
- **Visual language:** shape, colour and style say purpose, status and relation. Related stats share a
  palette and icon shape; buttons live in a container so they read as interactive (a highlight or
  shadow adds tactility); headers are bigger and bolder than body; keep a written style guide.
- **Conventions:** X closes; grey means locked or unusable; a lock icon means not earned; a green
  "Health" everywhere.
- **Consistency examples from the doc:** "Health" always green in text, icons and bars; NPC dialogue
  bolds item names; close buttons always square, red, white X, top-right only; unaffordable prices red.
- **Screen zones (curriculum):** top = objective/game state; centre = the action (keep clear);
  sides = player state. Do not mix categories across the screen or "players won't know where to look".
- **Art style steps:** list the UI elements by purpose -> pick a colour theme that marks function and
  genre -> simple icons that read when small (genre conventions: sword = strength, beaker = magic;
  study the Game UI Database) -> order the interactions (primary, secondary, tertiary) -> one text
  system ("display text on top of a contrasting colour or with a stroke"; stylized text only for titles
  or alerts; leave room for translation).
- **Wireframe in grey** shapes first, test over varied backgrounds, chart every flow including edge
  cases (disconnects, interruptions, early exits) and every input method.

## 8. Apple's design foundations (WWDC), applied to games

- **Purpose:** decide what not to build; every element spends the player's attention.
- **Familiarity:** things that look the same behave the same and live in the same place.
- **Simplicity, not minimalism:** hiding everything in one menu looks minimal but is not simple. Show
  the common path first and advanced options one level deeper.
- **Craft:** every spacing, timing and alignment value is a deliberate choice you can defend; jitter,
  misalignment and layouts that break on rotation read as carelessness.
- **Delight** is the result of the other principles, not confetti on top.
- **Feedback kinds:** status, completion, warning, error.
- **Wayfinding:** every screen answers: where am I, where can I go, what is here, how do I get out.
- **Mapping:** put a control near the thing it changes; if a control needs a label to explain it, the
  mapping is weak.
- **Multimodal feedback:** the visual, the sound and the haptic fire on the same frame, only for
  meaningful moments.

## 9. Riot's five goals of UI motion

Responsiveness, Intention, Awareness, Consistency, Physical intuition - see `lesson-videos.md` #3 and
`motion.md`.
