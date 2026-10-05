# Component recipes

Every component below is a real instance tree (authored in Edit mode with `scripts/Build.lua` or by
hand), named so code can find its parts, with all of its states authored. Sizes are tokens from
`design-tokens.md` at UIScale 1. "Hit" means the clickable area, which can be bigger than the visual.

## Buttons

```
TextButton  "Buy"            AutoButtonColor=false, Text="" (the label is a child), Size=(0,W,0,48)
  UICorner                   radius from the theme family
  UIStroke                   Border, optional
  UIPadding                  12-16 px left/right (horizontal padding = 2x vertical)
  UIScale                    press/hover animation
  UIListLayout               Horizontal, Center, Padding 8 (icon + label)
  ImageLabel "Icon"          20-24 px (= the label's line height), optional
  TextLabel  "Label"         label token, AutomaticSize X
```

| Kind | Fill | Text | Stroke | Use |
|---|---|---|---|---|
| Primary | `primary` | `onPrimary` | none or a darker shade | the one main action per screen |
| Secondary | `raised` / transparent | `text` | 1-2 px `line` | other actions |
| Ghost | none until hover | `text2` | none | tertiary, list actions, nav |
| Destructive | `danger` only when it IS the main action | white | - | delete, reset; confirm first |
| Disabled | `raised` at 0.5 | `text3` | - | `Interactable = false`; say why on press |

States: normal / hover (mouse only; +8% lightness or UIScale 1.04) / pressed (UIScale 0.95, -8%
lightness) / disabled / selected (gamepad focus ring or accent stroke) / loading (label replaced by
"..." or a spinner, input ignored). Heights: 48 (normal), 56-64 (hero CTA), 36-40 (compact desktop
lists only). Width: content + padding, or full width at the bottom of a phone panel. Primary on the
right of a pair (Cancel left, Confirm right), both the same height.

**Icon button** (close, settings, back): 36-40 px visual, 44-48 px hit. Close = X, always the
top-right corner of a panel, same size and colour in every panel. Back = arrow at the top-left.

## Panel / window

```
ScreenGui "Shop"             ResetOnSpawn=false, DisplayOrder 10, Enabled=false while closed
  TextButton "Backdrop"      full screen, black, BackgroundTransparency 0.45, Text="", AutoButtonColor=false
  Frame "Panel"              AnchorPoint (0.5,0.5), Position (0.5,0,0.5,0), offset size, UISizeConstraint
    UIScale, UICorner, UIStroke, (UIShadow level 4)
    TextButton "Guard"       full size, transparent, ZIndex above the backdrop, below the controls
    Frame "Header"           title (heading), close button top-right, optional tabs
    Frame "Body"             the content (ScrollingFrame when it can overflow)
    Frame "Footer"           actions, right-aligned, primary last
```

- The backdrop closes the panel on a click outside; the guard stops clicks on empty panel areas from
  reaching the backdrop (Active does not sink input).
- Phones: the panel may take the whole safe area (shops, inventories) or ~90% of the height; desktop:
  cap at ~900 x 600 for big panels and ~480 wide for dialogs; console: fits 960 x 540 before the 2x scale.
- One panel open at a time; opening one closes the other (or stacks with a darker backdrop).
- Gamepad: on open `GuiService:Select(panel)`, `SelectionGroup` with Stop on all four sides, B closes.

## Tabs

A row of ghost buttons with a selected state (accent text + a 3 px indicator bar under the selected tab
that slides between tabs) or segmented pills. Each tab names its content ("Pets", "Eggs", "Gamepasses"),
never "Tab 1". 3-6 tabs; more than 6 = a side list. Gamepad: LB/RB (`ButtonL1`/`ButtonR1`) switch tabs.

## Card grid (shops, inventories, indexes)

```
ScrollingFrame "Grid"        AutomaticCanvasSize Y, ScrollBarThickness 6, ScrollingDirection Y
  UIPadding                  8-12
  UIGridLayout               CellSize (x scale, 1), CellPadding (0.02, 0, 0, 8) or offset with offset cells
    UIAspectRatioConstraint  0.75-1.0 (under the LAYOUT: sets the cell aspect)
  Frame "Card" (template, Visible=false, kept in ReplicatedStorage or under the grid)
    UICorner, UIStroke (tier colour)
    ImageLabel "Icon"        ScaleType Fit, 60-70% of the card
    TextLabel "Name"         label token, TextTruncate AtEnd
    TextLabel "Info"         caption token (price, count, level)
    TextButton "Hit"         the whole card, transparent
```

- One template for every card; state by toggling authored overlays (Owned check, Lock, Equipped dot,
  "New" badge) - never by relabelling.
- Columns: about 3-4 on phones, 5-6 on desktop: compute from the frame width (`math.floor(w / 110)`)
  or use scale cells with scale padding. Leave room for the scroll bar.
- Big lists (100+): pool and reuse cards, or page them.

## List rows

`Frame "Row"` (height 48-64) with a horizontal `UIListLayout`: icon (32-40) / text stack (title + sub,
vertical) / a flex spacer (`UIFlexItem` Fill) / value or action button. Name each row after its data key
(the Aboshima settings rule: "the row's name is the contract"). Alternate nothing - use 1 px dividers or
8 px gaps.

## Toggle

Flat style (Lepy): a 44 x 24 track, square or 4 px radius; ON = accent fill with the knob right, OFF =
`sunken` with the knob left; the knob slides in 0.12 s. Or a checkbox square with a check icon. The
whole row is the hit area.

## Slider

```
Frame "Track"                height 6-8 (visual)
  Frame "Fill"               accent, Size (value, 0, 1, 0)
  Frame "Knob"               20-24 px, AnchorPoint (0.5, 0.5)
  TextButton "Hit"           transparent, 36-44 px tall over the track (touch)
TextLabel "Value"            right of the track, fixed width
```

Drag on X only from `InputBegan` on Hit to `InputEnded` (UserInputService), or a `UIDragDetector`.
Show the value while dragging. Gamepad: left/right on the selected slider steps by 5-10%.

## Bars (health, stamina, XP, progress)

- Lepy's flat style: a flat fill, no dark track, no rounded ends, a 1 px dark outline that matches
  the text stroke, a small coloured label beside it (`taste.md`).
- Full style: track (`sunken`), trail fill (lighter, delayed), main fill, optional segment ticks every
  10-25%, value text inside or beside (fixed width, "84/100").
- Colours by meaning and consistent in the whole game (health, stamina, mana, XP).
- Never animate a bar linearly over seconds; snap the main fill and let the trail show the change.

## Currency counter

Icon (24-28) + amount (label token, fixed width or AutomaticSize with right alignment) + optional "+"
button that opens the store. Abbreviate big numbers (1.2K, 3.4M, 5.6B) with one decimal; show the exact
number in a tooltip or the inventory. The amount counts up when it changes and the icon pops.

## Toast

`Frame "Toast"` AutomaticSize X, height 40-48, max width ~420, icon + one line of text, the semantic
colour as a left bar or icon (not a full red box for small errors). Top-centre under the top bar (or
bottom-centre above the thumb zones). Use for confirmations ("Equipped Fire Dragon"), refusals ("Not
enough coins") and pickups. Reuse the place's existing toast system if it has one (`UIAnimator.Toast`
in Sword Arena).

## Tooltip

A small `raised` panel with 8-12 px padding, caption/body text, max width 240, placed beside the
trigger on the side with room, clamped to the screen. Mouse: show after 400 ms hover. Touch: long
press. Gamepad: show the same info in a detail pane instead. Never put required information only in a
tooltip.

## Modal confirm

Title (title token), one or two lines of body (what happens, what it costs), two buttons: Cancel
(secondary, left) and the action (primary, right; red only when destructive). Escape/B = Cancel.
Use confirms only for destructive or expensive actions; for anything else act and offer undo.

## Reward popup

Backdrop dim -> rays (rotating ImageLabel, UIGradient fade) behind the item -> item icon pops in (Back
Out) -> name in the tier colour -> amount counts up -> CLAIM button (primary) appears last and pulses
once. Total 0.8-1.2 s; a tap anywhere skips to the end state. The sound peaks on the item pop.

## Hotbar / abilities

- Desktop: 5-9 square slots 48-56 px at the bottom centre, a key chip (1-9 or Q/E/R/F) in the corner,
  the selected slot with an accent stroke and a 1.05 scale.
- Touch: the same abilities as round 56-72 px buttons in an arc around the jump button; the most used
  ability is the biggest and nearest the thumb.
- Gamepad: map to shoulder buttons and show the glyphs (`GetImageForKeyCode`).
- Cooldown: conical sweep or fill + remaining seconds in the centre (caption token) when over 1 s.

## Key hint chip

A 22-26 px square (or AutomaticSize X for words) with a 1-2 px stroke, the key letter in caption bold,
placed left of the action label: "[E] Open". Swap to the gamepad glyph or hide on touch when
`PreferredInput` changes.

## Nameplates and world labels (BillboardGui)

`Size = UDim2.fromScale(w, h)` in studs for labels that should shrink with distance, or offset for
labels that stay readable at any distance; `StudsOffset` above the head; `MaxDistance` 60-120;
`LightInfluence = 0`; `AlwaysOnTop` only for information that must never hide (and remember captures
skip AlwaysOnTop). Strokes inside a stud-sized billboard use tiny thickness values (0.1 ~ 2 px).

## Damage numbers

A pooled BillboardGui per hit: rise 1.5-2 studs over 0.6 s with a slight random X, scale pop 1.3 -> 1 in
0.1 s, fade out in the last 0.25 s; colour by type (normal white, crit yellow/orange and bigger, heal
green). Recycle, never create hundreds per second.

## Loading screen

Full screen (`ScreenInsets.None`, DisplayOrder 100), opaque backdrop (a TextButton to swallow clicks),
game logo or art, a progress bar driven by `ContentProvider:PreloadAsync` that only ever climbs
(`min(assets, elapsed / minTime)`), a minimum display time of 3-5 s, a SKIP after a few seconds, music
muffled until done. Run its loop on Heartbeat (RenderStepped does not fire while Studio is hidden).

Built and published for Untitled TD (2026-10-05, lobby v1360 + game place v189):
- Join: a `ReplicatedFirst` LocalScript clones a `ReplicatedFirst` template into PlayerGui, then calls
  `RemoveDefaultLoadingScreen`. Before `game.Loaded` the bar climbs by time to 30%; then it climbs with
  `PreloadAsync` per child of PlayerGui, SoundService and ReplicatedStorage; it ends when the character
  exists and at least 4 s passed. Tower figures in ViewportFrames: strip KeyframeSequences, Animations,
  joints and welds from the clones (4353 -> 176 instances), anchor the parts, make the cameras at run time.
- Gamepad: select SKIP when `PreferredInput` is Gamepad; clear the selection before hiding SKIP and set
  `Selectable = false` on the backdrop button (verification.md section 9).
- Teleport: the client clones a card template when the player is queued and calls
  `TeleportService:SetTeleportGui(gui)` then and again when the card shows at countdown 0. It hides the
  card when the countdown goes back up and on `TeleportInitFailed`.
- Arrival in the destination place: a `ReplicatedFirst` LocalScript takes
  `TeleportService:GetArrivingTeleportGui()` (nil in Studio and for a direct join), enables it, parents
  it, removes the default screen, refits it, continues the bar from 0.6, and fades it out after the map
  signal (an attribute the map loader sets), the character and a 0.8 s settle. A cutscene script that
  hides all other ScreenGuis will also hide this screen; time the first cutscene after it.
- Keep the top element below `GuiService.TopbarInset` on all three screens.

## Tutorial spotlight

One `Frame "Hole"` the size of the target with a huge `UIStroke` (2600 px, black, transparency 0.4)
that darkens everything else - no four-frame mask (it drew a 1 px seam Lepy circled twice). A pulsing
ring around the hole, the target's UIScale bumped to 1.3, and the instruction card where it does not
cover the target. Position everything with `target.AbsolutePosition - gui.AbsolutePosition`.

## Settings panel

Rows named exactly like the config keys; toggles and sliders as above; values apply live; sliders for
volume are a share of the authored mix (1 = as built); defaults equal the game's current look; changes
persist only if the game has a data system (say so if it does not).

## Text input

`TextBox` with a placeholder (`PlaceholderText`, `PlaceholderColor3` = `text3`), a 1 px `line` stroke
that turns accent on focus (`Focused` / `FocusLost`), `ClearTextOnFocus = false` for edits, 44+ px tall
on touch, kept in the top half of phone screens (the keyboard covers 162-198 px).

## Empty states

An empty inventory, an empty friends list, no quests: an icon, one line saying why it is empty, and the
action that fills it ("Hatch your first egg" -> opens the egg shop). Hide filters and tabs that do
nothing while empty.

## Badges

A red dot (10-12 px) or a count pill (16-18 px tall, caption bold) on the top-right corner of a button
when something new or claimable is inside. Clear it when the player opens that place.
