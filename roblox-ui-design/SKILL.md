---
name: roblox-ui-design
description: Design and build professional Roblox game UI for Lepy's places - HUDs, menus, shops, inventories, settings, popups, toasts, prompts and reward screens - that work on phones, tablets, desktop, console/TV and VR, as real instance trees in the game's own style. Holds the lessons of the five UI videos he assigned, the design system (hierarchy, spacing, type, colour, depth, motion tokens), the device rules measured from Roblox's own device presets and touch-control source, the style families and the "AI look" list, Lepy's UI taste log, and the tools to build (Build.lua), scale (Fit.lua), animate (Ui.lua), preview on simulated devices (Preview.lua), audit (Audit.lua) and capture. Use whenever Roblox UI must be designed, built, restyled, animated, reviewed or fixed.
---

# Roblox UI design

This skill was built on 2026-10-03 when Lepy asked for "a roblox ui design skill" with research on
how to make good UI, said "Your own UI must be at a professional advanced level", and added "Make sure
you study correct UI for all devices too". It holds the five lesson videos he assigned, the research
behind every rule (`references/sources.md`), everything learned from his UI feedback since 2026-08
(`references/taste.md`), and tools that were proven on a full sample (HUD, shop, settings, result) in
his Undertale place on seven simulated devices.

## Start with the actual task

1. Read `references/taste.md` (his rules) and, for a new kind of screen, `references/lesson-videos.md`.
2. Capture and read the place's **authored UI** first: tree, fonts, colours, strokes, radii, scale or
   offset sizing, and how it looks on a phone preset. New UI copies that vocabulary.
3. Fill `templates/ui-brief.md`: tasks by frequency, information priority, states, devices. **Ask
   Lepy** about every value his request leaves open (what a button does, prices, which screens, what
   happens on close) - never assume, never add screens or features he did not ask for.
4. Pick the method: restyle or clone an authored panel (his default for existing games), or a new tree
   from `Build.lua` in the place's style. Pick the style family (`references/styles.md`).
5. Build, wire, animate, then verify on every device class (`references/verification.md`).

## Lepy's rules (short form; the log is `references/taste.md`)

- **Simple and flat by default** when nothing is authored and he says "simple": flat square shapes,
  no dark translucent tracks, no rounded pills, no gradients or glows. Rounded pill bars on a dark track
  "look so AI". If "simple" is unclear, show 2-3 text mock-ups and let him pick.
- **Match the game's style**: clone and restyle authored panels; each shop its own palette inside one
  structure; no seams; information labels never covered; HUD pieces inside the existing HUD stack.
- **Never overwrite an authored label** unless its text is a placeholder for exactly that value;
  never `Instance.new` a visible element into an authored panel; report states through the existing
  toast.
- **UI is a real instance tree** in the place (StarterGui or ReplicatedStorage templates). Code clones,
  positions and drives it.
- **Code**: no comments, short natural names, modular, few defensive guards.
- **For UI work he wants the captures sent** (2026-10-03), as labelled contact sheets.

## Workflow

1. **UX first.** List the tasks by frequency and count the taps; make the most common task the
   fastest (Design Doc's Iron Boots lesson). Sort information into Now / Soon / Later
   (`references/game-ui.md`). Decide what the game does while a panel is open.
2. **References.** Two or three references for the screen type (the place's own art first, then the
   Game UI Database or a top Roblox game of the genre). Name what each does well.
3. **Grey layout at phone size first** (686 x 287 usable on a Galaxy A16 after the system bars and
   the 52 px top bar; 667 x 375 iPhone 7). If it works there, it scales up.
4. **Tokens.** Write the theme (spacing, type, colours by role, radius family, strokes, depth, motion)
   into `Build.t` or a StyleSheet before building (`references/design-tokens.md`).
5. **Build** the instance tree with `scripts/Build.lua` in Edit mode (or clone authored panels). Every
   screen: ScreenGui (ResetOnSpawn false, ScreenInsets CoreUISafeInsets) > `Root` frame > `Fit`
   UIScale; overlays outside list layouts; every state authored; names are the contract.
6. **Wire** with `scripts/Ui.lua` (press/hover/ink states, open/close, toast, count, bar, hints) and
   `scripts/Fit.lua`; a `Layout` ModuleScript per screen moves things per device class.
7. **Verify** with `scripts/Preview.lua` + `scripts/Audit.lua` on the device set; read every capture;
   fix; capture again (two rounds minimum); measure the first open; send the sheets.
8. **Log** every sentence of his feedback in `references/taste.md` and push the skill folder.

## Principles in one page (theory and sources in `references/principles.md`)

- **Hierarchy is the main lever**: size, weight, colour, contrast, position, space. One focal point
  per screen; the primary action is the only solid accent; secondary info is quieter. Emphasize by
  de-emphasizing. Labels are a last resort ("12 Kills" or an icon, not "Kills: 12").
- **C.R.A.P.**: Contrast (title about 2x body and heavier; one accent word), Repetition (one template
  per kind), Alignment (every element shares an edge - check the numbers), Proximity (space inside a
  group < space between groups).
- **Signifiers and states**: a container says "together", a filled container says "selected", grey
  says "disabled". Every button: normal, hover (mouse only), pressed, disabled, plus selected,
  loading, cooldown, owned, locked where they apply. Every action answers within one frame.
- **Conventions players know**: X top-right closes, B/Esc goes back, grey = disabled, lock = locked,
  red price = unaffordable, rarity grey < green < blue < purple < gold < red, gold = currency.
- **Laws**: Fitts (big and near for frequent actions), Hick (fewer choices, progressive disclosure),
  Jakob (match other games), Doherty (respond < 400 ms, show the press now), peak-end (make rewards and
  results the best moments), goal-gradient and Zeigarnik (show progress to the next goal).
- **Theme**: build the UI from the game's world - its palette, shapes, motifs, font - never a generic
  dark box ("black boxes with white text" is the failure in lesson video 4).
- **Motion** (Riot): responsive, intentional, from its source, consistent per element type, fitting
  the game's physics. Motion never rescues a bad layout.

## The numbers (full tables in `references/design-tokens.md` and `references/motion.md`)

- Spacing 2, 4, 8, 12, 16, 24, 32, 48, 64 (4 px base); screen margin 16 px phones, 24 px desktop,
  5% on TV.
- Six text sizes at most: 12 caption, 14 body, 16 label, 20 title, 28 heading, 40 display (pixel fonts
  use 12 / 16 / 24). Nothing a player must read under 11 px (24 px on TV after scaling). One family,
  two weights. Roblox has no letter-spacing: choose faces for their spacing.
- Colour by role, ramps of 9-11 shades in HSL, 60/30/10 proportions, WCAG 4.5:1 body and 3:1 large
  text and shapes, colour never the only signal.
- Radius family per game (square / soft 6-16 / round 12-24); strokes 1-2 px UI, 3-5 px cartoon;
  5 depth levels (`UIShadow` or a 9-slice shadow); DisplayOrder ladder HUD 0-9, menus 10-19, modals
  20-29, toasts 30-39, overlays 40-49, loading 100.
- Motion: press 60-100 ms to UIScale 0.95; release 140-200 ms Back Out or Quint Out; hover 100-150 ms;
  open 200-300 ms from UIScale 0.92 + fade; close 120-180 ms In; toasts 250 ms in, 2-4 s hold;
  stagger 30-50 ms; counts 0.4-0.8 s; bar trail waits 0.35 s then 0.4 s. Never animate from scale 0;
  exits faster than entrances; reduced motion = fades only.

## Devices (full guide in `references/devices.md`)

- Roblox UI pixels are **logical**: phones report ~160 dpi sizes (an iPhone 7 is 667 x 375), desktop
  and console 96 dpi. An offset size is about the same physical size on phone, tablet and monitor; a
  TV at 3 m needs about 2x.
- **Phones** (short side <= 500): thumbstick listens on the left 40% x bottom 2/3; jump 70-72 px
  bottom-right (120 px on tablets); top bar 52 px (58 desktop); targets 44 px minimum, 48 normal,
  56-72 for the main action buttons near jump; keyboard covers 162-198 px; no hover.
- **Tablets**: same thumbs, more room - cap widths, keep actions in the bottom corners.
- **Desktop**: hover states, tooltips, key chips, 1366 x 768 laptops to ultrawide - cap and centre.
- **Console/TV**: 1920 x 1080 at 96 dpi -> scale ~2 (layout must fit 960 x 540); keep text and
  controls out of the outer 5%; controls 64 px, text 24-30 px; everything Selectable, `GuiService:Select`
  on open, SelectionGroup with Stop on modals, glyphs from `GetImageForKeyCode`, B closes.
- **VR**: ScreenGuis sit on a collapsible ~611-688 px panel; critical info goes in the world.
- Detect with `UserInputService.PreferredInput` + `GuiService.ViewportDisplaySize` (and their changed
  signals), or `@PreferredInputTouch` / `@ViewportDisplaySizeLarge` style queries. Respect
  `PreferredTextSize`, `PreferredTransparency`, `ReducedMotionEnabled`.

## Sizing method

- **Inside an authored place, use its method** (usually scale + UIAspectRatioConstraint from the
  artist): keep padding in scale inside scale grids; put a UIAspectRatioConstraint under a
  UIGridLayout for cell shape; never mix a fixed-offset label into a scale-sized frame (the authored
  Undertale timer text spills out of its panel on phones for exactly this reason).
- **New UI: position with scale + AnchorPoint, size content in offset, scale the whole screen with one
  root UIScale** (`Fit.lua`): `Root` frame sized `1/k` under a UIScale `k`, so edge anchors stay on the
  screen edges while offsets grow. Defaults: `Ref = 288` (the usable short side of the worst common
  phone: Galaxy A16 339 px minus the 52 px top bar), Phone 1, Tablet 1.25, Desktop 1.25, TV up to 2
  (`short / 540`), Min 0.75 for tiny windows; attributes `Ref`, `Min`, `Phone`, `Tablet`, `Desktop`,
  `Tv`, `Step` tune it per game (`Step = 0.5` keeps pixel art on whole pixels). Fit reads the
  ScreenGui's usable size, so the top bar is already removed. This follows Roblox staff advice (offset
  content, reflow the top level, 2x image assets).
- Per-device arrangement lives in a `Layout` ModuleScript inside each ScreenGui:
  `function(gui, kind)` with kind Phone / Tablet / Desktop / Tv; it only moves, shows and hides
  authored instances.

## Engine traps (full list in `references/roblox-ui-engine.md`)

- `Active` does not sink clicks; only a GuiButton does (invisible `Guard`). `InputSink` exists but
  was "not currently enabled" on 2026-07-23 - test before relying on it.
- A GuiButton inside a GuiButton eats the parent's click; `AutoButtonColor` undoes selected colours;
  a UIListLayout grabs every child (keep overlays outside the laid-out frame).
- `ZIndexBehavior.Sibling`: a popup cannot rise above a neighbouring card - raise the card.
- `IgnoreGuiInset` roots sit at (0, -58): convert with `target.AbsolutePosition - container.AbsolutePosition`.
- BillboardGui `Active = false` kills its buttons; strokes in billboards scale with the billboard.
- Style sheets apply only while the instance property is still default. CanvasGroup costs texture
  memory and can render blank past the cap. `TextScaled` ignores `PreferredTextSize` - cap it.
- A child named like a parent property (`Text`) is unreachable by dot; `Enum.KeyCode.Escape`, not `Esc`;
  a disabled ScreenGui keeps a stale AbsoluteSize; `TextSize` ignores UIScale.
- Fresh image uploads can render blank until moderation completes; decal ids need `LoadAsset` to get
  the image id; `.png` downloads may be WebP.
- Edit mode has no top bar: check full-screen UI in Play and keep the top element below
  `GuiService.TopbarInset` (verification.md section 9).
- Hiding the selected button moves the gamepad selection to the nearest `Selectable` object (a
  backdrop button, then the HUD): clear `SelectedObject` first and make backdrop buttons not `Selectable`.

## Definition of done

1. The brief's open questions were asked and answered.
2. The UI matches the place's style (compared side by side with an authored screen).
3. `Preview.lua` captures on the device set (at least Galaxy A16, iPhone 7, iPad 10th, HD 1080, Xbox),
   read with the checklist in `references/verification.md`, fixed, and captured again - two rounds.
4. `Audit.lua` clean on phone (`touch`, `hud`), desktop and TV (`tv`), or every remaining finding
   explained.
5. All states shown; gamepad selection and glyphs work; touch layout clear of the stick and jump zones.
6. Console output clean; first open measured (pixel lab: 0.3-7.2 ms on desktop).
7. Test hooks, preview ghosts, `HttpEnabled` and the editor camera restored; samples named `Lab_*`
   and disabled until Lepy says keep or delete.
8. Labelled contact sheets sent; the report gives the numbers, the captures, and what was not tested
   (Play-mode motion when RAM is short).
9. Feedback logged in `references/taste.md`; skill pushed.

## Files

- `references/lesson-videos.md` - the five assigned videos, their lessons and the hand-off checklist
- `references/principles.md` - UX vs UI, hierarchy, Gestalt and Laws of UX, Refactoring UI, Nielsen,
  diegetic types, Roblox's own UI rules, Apple's foundations
- `references/devices.md` - every device class with measured numbers and the test set
- `references/design-tokens.md` - spacing, type, colour, rarity, radius, strokes, depth, layers, motion
- `references/motion.md` - when and how to animate, easing map, recipes
- `references/components.md` - buttons, panels, tabs, grids, rows, toggles, sliders, bars, counters,
  toasts, tooltips, modals, rewards, hotbars, key chips, nameplates, damage numbers, loading, spotlight
- `references/game-ui.md` - information priority, screen zones, HUD per genre, menus, inventories,
  shops, rewards, onboarding, conventions
- `references/styles.md` - style families with recipes (incl. the verified pixel style) and the AI look
- `references/roblox-ui-engine.md` - current API facts (styles, UIShadow, UIStroke, gradients, flex,
  insets, text, images, input, accessibility, performance) and traps
- `references/verification.md` - tools, device set, captures, audit, checklist, profiling
- `references/taste.md` - Lepy's UI feedback log
- `references/sources.md` - every source
- `templates/ui-brief.md` - the brief to fill before building
- `scripts/Build.lua` - Edit-mode builder (theme, make, corner, border, outline, pad, list, grid, flex,
  cap, scale, shadow, gradient, frame, box, text, icon, button, bar, hsl, ramp, lift, contrast, on)
- `scripts/Ui.lua` - runtime feedback and motion (press with Fill or Ink states, paint, open, close,
  pop, pulse, short, comma, count, bar, toast, stagger, shake, hints)
- `scripts/Fit.lua` - root UIScale per device class
- `scripts/Preview.lua`, `scripts/Devices.lua` - simulated-device previews from Edit mode
- `scripts/Audit.lua` - the UI checker
- `scripts/Install.lua`, `scripts/serve.js` - push sources into a place (port 8775)
- `scripts/icons.html` - SVG icon sets to white PNGs at 2x
- `scripts/capture/` - `grab.ps1`, `crop.ps1`, `sheet.ps1`, `pixicons.ps1`
- `scripts/examples/PixelLab.lua` - the full verified sample (Undertale-style HUD, shop + confirm,
  settings, result) built with `Build.lua`
- `scripts/examples/ShopPhoneLayout.lua` - a `Layout` module for an authored scale-built panel (the Untitled TD Unit Shop, 2026-10-04): on Phone it stores the authored values once, places every key element in offset pixels below the top bar inset, sets each UIAspectRatioConstraint to the new box ratio, and restores everything for other kinds (0 differences on restore). The client calls it with `Fit.kind` on open and on `AbsoluteSize` change and hides touch controls while the modal is open. Measured: buttons 12 px -> 44 px, slots 17 -> 48 px, close 26 -> 52 x 44 px on a Galaxy A16; layout 1.56 ms.

## Pushing the skill

Clone `Streetdude123/roblox-skills` into the scratchpad, copy this folder over `roblox-ui-design`,
stage only real diffs (the checkout is CRLF: compare with `--ignore-cr-at-eol`), add a README section
and a CHANGELOG entry, commit, push (`gh` is logged in as Streetdude123).
