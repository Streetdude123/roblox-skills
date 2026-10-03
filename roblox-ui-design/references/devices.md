# UI for every device: phone, tablet, desktop, console/TV, handheld, VR

Lepy, 2026-10-03: "Make sure you study correct UI for all devices too". Every screen is designed
and checked for all of the classes below. The numbers come from Roblox's own device presets (read
from `StudioDeviceSimulatorService` in Studio), Roblox's PlayerModule touch-control source, the
Roblox docs and staff posts, Apple's and Google's platform guidelines, and Microsoft's TV guidelines.
Sources are in `sources.md`.

## 1. How Roblox measures the screen

- Roblox gives UI **logical pixels**, not device pixels. Roblox staff (tiffblocks, 0xbaadf00d):
  "The mobile resolution scaling is there specifically so that you can use offset without worrying
  about high-DPI devices." An iPhone X reports `AbsoluteSize` 812x375, not 2436x1125, and renders 3x
  for sharpness. The target is "around 160 dpi". On iOS a Roblox logical pixel equals an iOS point.
- Desktop and console report 96 dpi: 1 logical px = 1 screen px at 1920x1080.
- Consequence: an offset size is roughly the same **physical** size on a phone, a tablet and a monitor
  (phone 150 dpi at ~30 cm, monitor 96 dpi at ~60 cm subtend almost the same angle). A TV at 3 m is the
  exception: there the same pixels look about half as big, so console UI must be scaled up (section 6).
- Make image assets at **2x** their offset size so they stay sharp on 2x-3x phones (staff advice).

## 2. Device classes and the logical sizes Roblox uses (landscape)

From `StudioDeviceSimulatorService:GetDeviceListAsync()` on 2026-10-03 (Studio version-76e1a02649ad4f35).
Size = logical width x height; scale = device pixels per logical pixel.

| Class | Preset id | Name | Logical size | Scale | DPI | Keyboard (landscape) |
|---|---|---|---|---|---|---|
| Phone | `iphone_7` | iPhone 7 | 667 x 375 | 2 | 326 | 162 |
| Phone | `iphone_6_Plus` | iPhone 6 Plus | 736 x 414 | 3 | 401 | 162 |
| Phone | `samsung_galaxy_s22_ultra` | Galaxy S22 Ultra | 772 x 360 | 4 | 501 | 162 |
| Phone | `samsung_galaxy_a16` | Galaxy A16 | 780 x 360 | 3 | 385 | 162 |
| Phone | `samsung_galaxy_s25_ultra` | Galaxy S25 Ultra | 780 x 360 | 4 | 498 | 162 |
| Phone | `samsung_galaxy_a06` | Galaxy A06 | 800 x 360 | 2 | 262 | 162 |
| Phone | `iphone_13` / `iphone_14` | iPhone 13 / 14 | 844 x 390 | 3 | 460 | 176 |
| Phone | `iphone_16` | iPhone 16 | 852 x 393 | 3 | 460 | 177 |
| Phone | `iphone_16_pro` / `iphone_17_pro` | iPhone 16 Pro / 17 Pro | 874 x 402 | 3 | 460 | 181 |
| Phone | `iphone_XR` / `iphone_11` | iPhone XR / 11 | 896 x 414 | 2 | 326 | 186 |
| Phone | `iphone_13_pro_max` | iPhone 13 Pro Max | 926 x 428 | 3 | 458 | 192 |
| Phone | `iphone_16_pro_max` | iPhone 16 Pro Max | 956 x 440 | 3 | 460 | 198 |
| Tablet | `xiaomi_redmi_pad_se`, `amazon_fire_hd10_2023`, `samsung_galaxy_tab_a8`, `samsung_galaxy_tab_a9+` | Android tablets | 960 x 600 | 2 | 206-224 | 302 |
| Tablet | `ipad_6th_generation` | iPad 6th gen | 1024 x 768 | 2 | 264 | 408 |
| Tablet | `ipad_8th_generation`, `ipad_9th_generation` | iPad 8th/9th | 1080 x 810 | 2 | 264 | 408 |
| Tablet | `ipad_10th_generation`, `ipad_a16`, `ipad_air_5th_generation` | iPad 10th / A16 / Air 5 | 1180 x 820 | 2 | 264 | 413 |
| Tablet | `ipad_pro_M4_11in` | iPad Pro 11 | 1210 x 834 | 2 | 264 | 420 |
| Tablet | `samsung_galaxy_tab_S11` | Galaxy Tab S11 | 1280 x 800 | 2 | 274 | 403 |
| Tablet | `samsung_galaxy_tab_a9` | Galaxy Tab A9 | 1340 x 800 | 1 | 179 | 403 |
| Tablet | `ipad_pro_M5_13in` | iPad Pro 13 | 1376 x 1032 | 2 | 264 | 520 |
| TV box | `android_tv_1080` | Android TV 1080p | 1920 x 1080 | 1 | 44 | 540 |
| Desktop | `vga` / `hd_720` / `average_laptop` / `hd_1080` | VGA / HD 720 / laptop / HD 1080 | 640x480 / 1280x720 / 1366x768 / 1920x1080 | 1 | 96 | - |
| Console | `xbox`, `ps4`, `ps5` | Xbox One / PS4 / PS5 | 1920 x 1080 | 1 | 96 | - |
| Handheld | `generic_handheld_720`, `generic_handheld_1080` | Handheld 720 / 1080 | 1280x720 / 1920x1080 | 1.5 | 274 / 411 | - |
| VR | `meta_quest_2`, `meta_quest_3` | Quest 2 / Quest 3 panel | 611 x 640 / 688 x 736 | 3 | 773 / 1218 | - |

Portrait swaps width and height. Roblox's own "small screen" test (PlayerModule) is
`math.min(width, height) <= 500`: every phone is small, every tablet is big.

**Design floor:** the tightest common screens are **667 x 375** (old iPhones) and **780 x 360**
(most Android phones, short side 360). Every HUD and every panel must fit and stay usable there. The
"896 x 414" check from Lepy's Wacky Pets feedback is the comfortable phone, not the worst one.

**Measured in the simulator (2026-10-03):** the usable viewport is smaller than the preset size. The
Galaxy A16 preset (780 x 360) gives a 686 x 339 viewport after the Android system bars and the
punch-hole inset; minus the 52 px top bar that leaves **686 x 287** for a ScreenGui with
CoreUISafeInsets. A panel with 16 px margins therefore has 255 px of height on that phone. Design
phone panels for about 250 px of height or let them scroll.

## 3. Detecting the device (never guess from the size alone)

| Signal | API | Use it for |
|---|---|---|
| Current input | `UserInputService.PreferredInput` (`KeyboardAndMouse`, `Gamepad`, `Touch`, `MicroGamepad`) + its changed signal | button prompts, hover on/off, gamepad selection |
| Physical screen size | `GuiService.ViewportDisplaySize` (`Small` phones/tablets/handhelds, `Medium` laptops/monitors, `Large` TVs) + changed signal | UI scale and density (full release 2025-10-21) |
| Capabilities | `UserInputService.TouchEnabled`, `KeyboardEnabled`, `GamepadEnabled`, `VRService.VREnabled` | what can happen, not what is happening |
| Style queries | `@PreferredInputTouch`, `@PreferredInputGamepad`, `@PreferredInputKeyboardAndMouse`, `@ViewportDisplaySizeSmall/Medium/Large`, `@ReducedMotionEnabledTrue/False` | the same switches inside a StyleSheet, no code |

A laptop can have touch, a phone can have a controller, a player can switch mid-session: listen to
the changed signals and re-apply. Do not use `TouchEnabled and not KeyboardEnabled` as "mobile" for
layout; use it only as a fallback when `PreferredInput` is missing.

## 4. Phones (short side <= 500)

**Reserved zones (from the PlayerModule source in the Studio install):**
- The dynamic thumbstick listens on the **left 40% of the width and the bottom two thirds of the
  height** in landscape (portrait: the bottom 40%, full width). Its resting ring is a 74 px circle
  centred about 66 px from the left edge and 56 px above the bottom on phones (148 px, centred about
  132 px / 112 px on tablets). A touch that starts on a GUI button goes to the button, so a big
  interactive frame in that zone blocks movement. Keep it clear during play.
- The jump button is **70-72 px** on phones and **120 px** on tablets in the bottom-right corner.
  Classic layout: phones x W-95..W-25, y H-90..H-20; tablets x W-170..W-50, y H-210..H-90. With the
  newer ability-controls layout: phones x W-136..W-64, y H-136..H-64; tablets x W-220..W-100,
  y H-232..H-112. Read the live spot in Play from `PlayerGui.TouchGui.TouchControlFrame.JumpButton`
  `.AbsolutePosition/AbsoluteSize` instead of trusting either set.
- The Roblox top bar is **52 px** tall on mobile (58 on desktop); its buttons are 44 px with
  `inset - 46` px of spacing (6 on mobile, 12 on desktop). `GuiService.TopbarInset` is 0 on the first
  frame - connect to its changed signal.
- The default `ScreenGui.ScreenInsets = CoreUISafeInsets` keeps content out of the notch and the top
  bar. Use `None` only for non-interactive full-screen art (backdrops, vignettes, loading art).

**Thumb reach:** players hold the phone with two thumbs, one on the stick, one on jump. Put frequent
actions in an arc around the jump button (Roblox's doc places a custom button 20 px left of jump),
put information (timers, objective) at the top, and put rare actions (settings, shop) at the top
corners or the left edge above the stick zone. A button 40% down from the top is reachable on a
phone and a stretch on a tablet.

**Sizes:**
- Touch targets: **44 x 44 px minimum** (Apple HIG = 44 pt = 44 Roblox logical px on iOS), **48 px**
  for normal buttons (Material), **56-72 px** for the primary action buttons near the jump button
  (Roblox/WCAG ask about 9 x 9 mm, which is 50-57 logical px at ~150 dpi). Keep 8 px between targets.
  A small visual (a 24 px icon) can have a bigger invisible hit area (a transparent TextButton parent).
- Text: body **14-16 px**, secondary **12-13 px**, nothing important under **11 px**. Use bold
  weights for small text over the 3D world.
- Panels: a modal panel uses at most about 90% of the height (360 x 0.9 = 324 px on the worst phone)
  and leaves the top bar visible; a full-screen menu is fine for shops and inventories on phones.

**Text input:** the on-screen keyboard covers **162-198 px** of a 360-440 px landscape screen. Put
TextBoxes in the top half, or move the panel up while `UserInputService.OnScreenKeyboardVisible` is
true (read `OnScreenKeyboardPosition` / `OnScreenKeyboardSize`).

**No hover:** touch has no hover, and a tap can leave a hover state stuck on. Gate every hover
visual by `PreferredInput ~= Enum.PreferredInput.Touch` (or `@PreferredInputTouch` in a style sheet).
Give every hover-only piece of information (tooltips) another path: a tap, a long press
(`TouchLongPress`), or always-visible text.

**Orientation:** `StarterGui.ScreenOrientation` (default `LandscapeSensor`). If a game allows portrait,
every screen needs a portrait check too.

## 5. Tablets (touch, short side > 500)

- More room, but the same thumbs: the thumb zone is relatively smaller, so keep touch actions in the
  bottom corners and information at the top; never centre-bottom-only controls.
- Do not stretch phone panels: cap widths with `UISizeConstraint` (a dialog rarely needs more than
  ~600 px; a two-column shop ~900 px) and centre them.
- iPads are 4:3 (1024x768 - 1376x1032): a 16:9 layout gains height, so anything anchored to the
  bottom and top drifts apart - check the vertical gaps.

## 6. Desktop and laptops (mouse and keyboard)

- Sizes run from 1280x720 and the very common **1366x768** laptop to 1920x1080, 2560x1440 and
  ultrawide 3440x1440. Cap panel widths and centre them; never let a list stretch across 3440 px.
- Mouse precision allows **32-40 px** targets, but Roblox players expect touch-sized UI too; 40-48 px
  buttons work on both.
- Hover states are expected (0.1-0.15 s). Tooltips are fine: show after ~0.4 s, then instant for
  neighbours while one is open.
- Show keyboard shortcuts as key chips ("E", "Q", "Tab") next to actions; hide them on touch and
  gamepad. Scroll wheel must work on every scrolling list (ScrollingFrame does this).
- The top bar is 58 px; the leaderboard and chat sit top-right / top-left - keep the HUD clear of them.

## 7. Console and TV (gamepad, ~3 m away)

- Xbox One, PS4 and PS5 report **1920 x 1080 at 96 dpi** with no extra scale. Microsoft scales Xbox
  apps by 200% so they lay out in **960 x 540 effective px**: "the amount of information displayed on
  a TV should be comparable to what you'd see on a mobile phone". So on `ViewportDisplaySize == Large`
  scale the UI up (root `UIScale` about 1.5-2; measure in the Device Simulator) and make sure the
  layout fits 960 x 540 before scaling - the phone layout already does.
- **TV-safe area:** keep all text and interactive UI out of the outer **5%** of every edge (96 px
  left/right and 54 px top/bottom at 1920x1080). Backgrounds and decoration may run to the edges.
- **Minimums at 1080p logical:** interactive elements **64 px** tall (32 epx x 2); main text **30 px**;
  supplemental text **24 px** (15 / 12 epx x 2). Avoid 1 px lines and tiny gaps: they shimmer on TVs.
- **Navigation:** at most about six D-pad presses from one edge to the other. Every interactive
  element `Selectable = true`; call `GuiService:Select(panel)` when a panel opens (it picks the lowest
  `SelectionOrder`, then top-left); set `SelectionGroup = true` on a modal with
  `SelectionBehaviorUp/Down/Left/Right = Enum.SelectionBehavior.Stop` so the highlight cannot leave it;
  use `NextSelectionUp/Down/Left/Right` only where the automatic path is wrong; listen to
  `SelectionChanged` to restyle the selected item and to re-select when the selection is lost; set
  `GuiService.SelectedObject = nil` when closing.
- **Focus must be unmistakable:** a thick outline or a scale-up on the selected item. The default
  highlight follows `UICorner`; replace it with `GuiObject.SelectionImageObject` (per item) or
  `PlayerGui.SelectionImageObject` (global) to match the style.
- **Button glyphs:** `UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonA)` returns the right
  Xbox or PlayStation icon; `GetStringForKeyCode` maps keyboard layouts. B = back/close everywhere.
- Avoid tooltips (they pop on focus and distract), avoid text entry, avoid hover-only information.
- Colours: TVs differ; do not separate states by subtle colour differences. Haptics: `HapticEffect`
  (`Type = Enum.HapticEffectType.UIClick`, `:Play()`) for selection and confirm on gamepads.

## 8. Handhelds (gamepad + small screen)

Steam Deck-class presets (`generic_handheld_720/1080`, scale 1.5). Treat them as a phone-sized layout
with console navigation: phone text and target sizes, plus full gamepad selection.

## 9. VR

- ScreenGuis are drawn on a floating panel (about 611 x 640 logical on Quest 2, 688 x 736 on Quest 3)
  that the player can collapse at any time. `GuiService:Select()` opens it.
- Keep the 2D HUD minimal and centred; edge-anchored HUDs and full-screen overlays (vignettes, damage
  flashes) do not work on a panel.
- Put critical information **in the world**: SurfaceGuis on parts attached to the camera or the hand,
  BillboardGuis over objects (diegetic and spatial UI).

## 10. Accessibility settings (all devices)

- `GuiService.PreferredTextSize` (`Medium`, `Large`, `Larger`, `Largest`) scales text automatically
  unless the label uses `TextScaled` or a `UITextSizeConstraint` cap. Give text boxes `AutomaticSize`
  or room to grow, and test at `Largest`.
- `GuiService.PreferredTransparency` (0-1): multiply panel `BackgroundTransparency` by it (0 = fully
  opaque backgrounds for players who need them).
- `GuiService.ReducedMotionEnabled`: replace slides, scales and shakes with short fades.
- Colour blindness affects over 5% of players: pair every colour signal with an icon, shape or label.

## 11. Testing every device in Studio

Use `scripts/Devices.lua` (it calls `StudioDeviceSimulatorService` from the Edit datamodel through
`execute_luau`) to switch presets, then capture. The standard set, in order:

1. `samsung_galaxy_a16` (780 x 360, the worst common phone)
2. `iphone_7` (667 x 375, the narrowest)
3. `iphone_16_pro_max` (956 x 440, notch side insets)
4. `ipad_10th_generation` (1180 x 820, touch tablet, 3:2)
5. `average_laptop` (1366 x 768)
6. `hd_1080` (1920 x 1080 desktop)
7. `xbox` (1920 x 1080 TV, gamepad)
8. `meta_quest_3` (only if the game supports VR)

Read every capture against the checklist in `verification.md`, then restore with
`SetDeviceAsync("default")`. Lepy can also switch devices by hand from the Device Simulator toolbar
above the viewport (File > Beta Features > New Device Simulator).

`scripts/Preview.lua` does the whole switch in one call: device, `Fit` scale, the real top-bar inset
(Edit mode has none), the screen's `Layout` module for the device class, and ghost touch controls.
The pixel lab's Fit results: Galaxy A16 and iPhone 7 = Phone x1.0; iPad 10th = Tablet x1.5;
HD 1080 = Desktop x1.5; Xbox = Tv x2.0 (all with `Step = 0.5`).
