# Style families

Pick ONE family per game (or follow the place's authored style), write it into the theme, and keep it
on every screen. Each recipe lists the values to start from; tune them in captures, never mid-build by
eye. Lepy's default when nothing is authored and he says "simple": **Flat minimal** (`taste.md`).

## 1. Flat minimal (Lepy's default)

- **When:** combat trials, battlegrounds HUDs, creature games, anything where the world is the show.
- **Font:** one face, caps for labels: Oswald Medium 12-14, Jura Regular, or BuilderSans SemiBold.
- **Palette:** off-white text (#F5F5F5-#EDEDED) with a 1 px black text stroke; bars in flat meaning
  colours (health orange #FF8C1E, stamina yellow #FFD732, posture dark gold #B99114 in the Scripter
  trial; thirst blue, hunger orange, stamina white in Vesna). No backdrop tracks.
- **Shapes:** square corners, no UICorner; flat rectangles; a 1 px black outline on bars to match the
  text stroke.
- **Depth:** none. No gradients, no shadows, no glows.
- **Panels** (menus): white or near-black fills with a 1 px stroke, sharp corners, panels at 0.9
  transparency over a dim (Aboshima menu: Jura, black on white, 1 px strokes).
- **Motion:** quick fades (0.15 s) and instant state changes; no bounce.
- **Signature detail:** small coloured text labels next to each bar so a glance tells which is which.

## 2. Clean modern (dark)

- **When:** shooters, sci-fi, competitive games, settings and lobby menus.
- **Font:** BuilderSans / Montserrat: headings Bold, body Medium.
- **Palette:** slate ramp surfaces (#0F172A panel, #1E293B card, #334155 lines), text #F8FAFC / #CBD5E1 /
  #64748B, one accent (sky #38BDF8 or the game hue).
- **Shapes:** radius 8 (buttons) / 12 (cards) / 16 (panels); 1 px strokes at 0.6-0.8 transparency.
- **Depth:** lighter surfaces instead of shadows; one level-4 UIShadow on modals.
- **Motion:** Quint Out, 0.2-0.25 s; hover = lighter fill; press = 0.96 scale.
- **Signature:** a thin accent bar on the selected tab/row; tabular numbers; generous padding (16-24).
- **Avoid:** making every panel translucent glass; it reads as generated and hurts contrast.

## 3. Simulator / cartoon (bubbly)

- **When:** pet, clicker, tycoon, collect games for young players.
- **Font:** FredokaOne for everything (or LuckiestGuy for titles), white text with a dark stroke
  2-3 px in a dark shade of the button's hue.
- **Palette:** saturated fills per function (green buy, blue info, yellow currency, red close, purple
  premium), each with its own ramp: fill = hue 400-500, outline = hue 800-900, a lighter top highlight.
- **Shapes:** radius 12-20; thick outlines 3-5 px (`UIStroke` Border, `LineJoinMode.Round`).
- **Depth:** a vertical UIGradient on fills (lighter top -> base bottom), a "3D" bottom lip (a darker
  copy of the button 4-6 px lower behind it, or a no-blur UIShadow offset 0,5), soft outer glow on
  rare items only.
- **Icons:** big, chunky, outlined icons with the same stroke as the text; icon above the label on
  the left-edge menu buttons.
- **Motion:** Back Out pops (0.2-0.3 s), press squash to 0.92, coins flying to the counter, counters
  rolling up, rays behind rewards.
- **Each shop its own colour** (Wacky Pets: seed shop brown wood, sell shop gold). Same structure.
- **Avoid:** five different outline colours on one screen; gradients that run in different directions.

## 4. Anime battlegrounds

- **When:** fighting games with ability kits (Lepy's Grimoire, Asta, DIO kits).
- **Font:** BuilderExtended / Oswald caps for labels; Bangers or a heavy italic only for hit words.
- **Palette:** black and white base with the character's kit colour as the accent (Asta: black/red,
  water mage: blue/white, DIO: gold/lavender).
- **Shapes:** slanted parallelograms (Rotation or a skewed image), sharp corners, thin speed-line
  textures as decoration on the ability bar, square slots with key chips.
- **HUD:** small and low: a compact health/stamina block bottom-left (desktop) or top-left (touch),
  ability slots bottom-centre on desktop and in the right-hand arc on touch, cooldown sweeps.
- **Motion:** snappy (0.1-0.15 s), impact pops on use, a white flash when a cooldown ends; the moves
  carry the drama, the HUD stays out of the way.

## 5. Horror / diegetic

- **When:** horror and atmosphere-first games.
- **Font:** SourceSansPro or Arimo for anything readable; SpecialElite or Creepster only for titles.
- **Palette:** desaturated, dark, low contrast for decoration, high contrast only for the one thing
  that matters (the interaction prompt).
- **HUD:** almost nothing; information through the world (battery on the flashlight model, a note on
  a SurfaceGui) and meta effects (screen edges darken with low health, heartbeat).
- **Motion:** slow fades (0.4-0.8 s), no bounce; flicker sparingly.

## 6. Fantasy / RPG (ornate)

- **When:** RPGs, medieval, magic games.
- **Font:** Merriweather or Fondamento titles, SourceSansPro or Merriweather body.
- **Palette:** parchment (#E9DCC0), leather browns, gold trims (#C9A44C), deep red/blue banners.
- **Shapes:** 9-sliced frame images (corners with ornaments), dividers with small ornaments, item
  slots with bevelled frames; rarity coloured slot borders.
- **Depth:** inner shadows on slots (sunken), raised buttons with a light top edge.
- **Motion:** medium (0.25-0.35 s), page-like slides, soft glows on legendary items.
- **Assets:** paint or source the frame textures at 2x; one frame set for the whole game.

## 7. Sci-fi / tech

- **When:** space, mech, cyber games.
- **Font:** Michroma or Zekton caps for titles and numbers, TitilliumWeb or Roboto body.
- **Palette:** near-black blue (#050B14) panels at 0.2-0.35 transparency, cyan or mint accent, a
  warning orange; team colours like the Laser Tag curriculum (mint vs carnation pink).
- **Shapes:** clipped corners (images or Path2D), hexagons, 1 px lines with corner brackets, scanline
  or grid textures at very low opacity.
- **Motion:** Quint Out slides with a short delay chain (lines draw first, then content), small
  glitch flickers on alerts only.

## 8. Retro pixel (Undertale-like) - built and verified 2026-10-03

- **When:** pixel or retro games; Lepy's Undertale place ("UNDERTALE: ECHOES OF THE FALLEN"), whose own
  UI is PressStart2P text, black panels with white hand-drawn outlines, bone and heart motifs, and
  teal-to-red edge shading. The full working sample is `scripts/examples/PixelLab.lua` (HUD, shop with
  confirm, settings, round result; captures in the 2026-10-03 report).
- **Font:** PressStart2P only (Regular is its only weight). Sizes 12 / 16 / 24 (caption / body /
  title) at UIScale 1; it is narrower than its size suggests (about 0.55 em per glyph at 12 px).
- **Palette:** black #000000 fills, white #FFFFFF borders and text, selection yellow #FFFF00, command
  orange (255, 140, 26), soul red #FF0000, disabled grey (128, 128, 128), HP = yellow fill on red,
  stamina cyan (66, 252, 255) on (48, 48, 48). Soul colours for categories: red, cyan, orange, blue
  (0, 60, 255), purple (213, 53, 217), green (0, 192, 0), yellow.
- **Shapes:** square corners only; `UIStroke` Border, **Inner**, **Miter**; 2 px (rows, chips, detail
  boxes), 3 px (HUD boxes, command buttons), 4 px (panels). Panel edge shading: an inner frame with a
  horizontal UIGradient teal (31, 181, 200) -> black -> wine (200, 40, 60), transparency 0.62 at the
  edges, 1 between 16% and 84%, inset by the border width.
- **Selection = the heart:** a selected item turns yellow and its icon is replaced by the red heart
  (the `Ink` + `Soul` pattern in `Ui.press`); menus use a 16 px heart cursor slot left of the label.
- **Icons:** white pixel art drawn from text grids (`capture/pixicons.ps1`, 8 px per cell), tinted by
  `ImageColor3`, `ResampleMode = Enum.ResamplerMode.Pixelated` (a 112 px heart stays perfectly crisp).
- **Text voice:** dialogue lines start with "* " ("* You earned 120 EXP and 45 GOLD."); numbers that
  matter in yellow via rich text.
- **Scale:** `Fit` with `Step = 0.5` (phones 1, tablets 1.5, desktop 1.5, TV 2) so pixel strokes and
  glyphs stay on whole pixels.
- **Motion:** instant colour swaps for selection, 0.1-0.15 s pops, a typewriter
  (`MaxVisibleGraphemes`) for dialogue, no smooth bounces.

## What reads as AI-made (avoid unless the game's own style asks for it)

Lepy on 2026-09-30: rounded pill bars on a dark translucent track "look so AI". Generic generated UI
has the same tells everywhere:

1. Pill-shaped bars on a dark translucent rounded track; pill buttons on dark glass.
2. Every panel a dark translucent rounded rectangle with a thin white stroke (default glassmorphism).
3. Purple-to-blue or cyan-to-magenta gradients on everything, neon glows, drop shadows on everything,
   all at once on one element (gradient + stroke + shadow + corner + glow).
4. Emoji or text symbols as icons; mismatched icon styles (outline next to filled next to 3D).
5. No hierarchy: every label the same size and weight, everything centred, equal spacing everywhere.
6. "Label: value" text everywhere ("Coins: 100", "Level: 5", "Damage: 20").
7. Generic copy: "Welcome to the Shop!", "Click here", "Awesome Item", "Coming soon".
8. Random values: 13 px padding here, 17 px there, three different corner radii on one screen.
9. Default Gotham/Arial-like text at TextScaled sizes that differ label to label.
10. A dark grey box with white text that ignores the game's world - the "black boxes with white text"
    failure (lesson video 4).
11. Buttons with no states, or the default AutoButtonColor grey flash.
12. Linear bar animations; things that slide in from nowhere at scale 0.
13. Floating HUD buttons placed by code next to (not in) the existing HUD stack.

The cure is always the same: the game's own palette, shapes and motifs; one system of values; clear
hierarchy; fewer effects, each with a reason.
