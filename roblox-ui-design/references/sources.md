# Sources (researched 2026-10-03)

## Lesson videos Lepy assigned
- Jesse Showalter, "4 Foundational UI Design Principles | C.R.A.P." - https://youtu.be/uwNClNmekGU
- Kole Jain, "Every UI/UX Concept Explained in Under 10 Minutes" - https://youtu.be/EcbgbKtOELY
- Riot Games, "So You Wanna Make Games?? Episode 9: User Interface Design" - https://youtu.be/sc3h5JXtIzw
- BiteMe Games with Rive, "How you can make amazing game UI, the easy way" - https://youtu.be/E7zlgzldV40
- Design Doc, "Inventory UX Design - How Zelda, Resident Evil, and Doom Make Great Game Menu UX" - https://youtu.be/5_3BUU9ZmNo

## Roblox documentation (creator-docs repository and create.roblox.com)
- UI overview - https://create.roblox.com/docs/ui
- UI styling, Style Editor, CSS comparisons - https://create.roblox.com/docs/ui/styling , https://create.roblox.com/docs/ui/styling/editor , https://github.com/Roblox/creator-docs/blob/main/content/en-us/ui/styling/css-comparisons.md
- StyleRule, StyleQuery, GuiState, InputSink, ScreenInsets, StrokeSizingMode, BorderStrokePosition, GradientType, GradientTileMode, PreferredInput, DisplaySize, DeviceSimulatorScalingMode reference YAML - https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine
- Classes UIShadow, UIStroke, UIGradient, UICorner, GuiObject, ScreenGui, CanvasGroup, StudioDeviceSimulatorService - same repository, `classes/`
- On-screen containers, position and size, size modifiers, list and flex layouts, appearance modifiers, animation, labels, rich text, 9-slice - https://github.com/Roblox/creator-docs/tree/main/content/en-us/ui
- UI and UX design - https://create.roblox.com/docs/production/game-design/ui-ux-design
- UI design curriculum: choose an art style, wireframe your layouts, implement designs in Studio - https://create.roblox.com/docs/tutorials/curriculums/user-interface-design/choose-an-art-style
- Accessibility guidelines - https://create.roblox.com/docs/production/publishing/accessibility
- Console guidelines - https://create.roblox.com/docs/production/publishing/console-guidelines
- Cross-platform design - https://create.roblox.com/docs/building-and-visuals/ui/cross-platform-design
- Studio testing modes and Device Simulator - https://github.com/Roblox/creator-docs/blob/main/content/en-us/studio/device-simulator.md
- Gamepad input - https://github.com/Roblox/creator-docs/blob/main/content/en-us/input/gamepad.md

## Roblox announcements and staff answers (DevForum)
- [Studio Beta] Introducing UI Styling (2025-05-22, later client beta and full release) - https://devforum.roblox.com/t/studio-beta-introducing-ui-styling/3660722
- [Full Release] Build Cross-Platform UI with the ViewportDisplaySize API (2025-10-21) - https://devforum.roblox.com/t/full-release-build-cross-platform-ui-with-the-viewportdisplaysize-api/3880384
- Introducing Builder Font + Deprecating Gotham and Arial (2024-03-07; removal 2024-05-28) - https://devforum.roblox.com/t/introducing-builder-font-deprecating-gotham-and-arial/2868222
- New Gamepad UI Selection APIs - https://devforum.roblox.com/t/new-gamepad-ui-selection-apis/1791278
- Specific details about UI scaling best practices (staff: offset content, 160 dpi normalization, 2x assets) - https://devforum.roblox.com/t/specific-details-about-ui-scaling-best-practices/3888004
- InputSink not preventing input (staff 2026-07-23: "not currently enabled") - https://devforum.roblox.com/t/inputsink-not-preventing-input-processes-on-ui-behind-it/4753268
- New topbar inset sizes (58 desktop / 52 mobile) - https://devforum.roblox.com/t/what-are-the-new-topbar-inset-dimensions/3237388

## Roblox community tutorials
- Here's How to Create a Modern Sleek UI Design - https://devforum.roblox.com/t/heres-how-to-create-a-modern-sleek-ui-design-ui-tutorial/2528850
- How to make UI styled for simulator - https://devforum.roblox.com/t/how-to-make-ui-styled-for-simulator-detailed-tutorial/2895762
- (hopefully) The last UI tutorial you'll ever need - https://devforum.roblox.com/t/hopefully-the-last-ui-tutorial-youll-ever-need/1788203
- Complete, Comprehensive Roblox UI Scaling Guide - https://devforum.roblox.com/t/complete-comprehensive-roblox-ui-scaling-guide/2232510
- Scaler - Using UIScale to Scale Your UI - https://devforum.roblox.com/t/scaler-using-uiscale-to-scale-your-ui/1105672

## Local sources
- Roblox PlayerModule touch controls (TouchJump.lua, DynamicThumbstick.lua) in
  `%LOCALAPPDATA%\Roblox\Versions\version-76e1a02649ad4f35\ExtraContent\scripts\PlayerScripts\StarterPlayerScripts\PlayerModule.module\ControlModule\`
- Font families in `...\content\fonts\families\`
- `StudioDeviceSimulatorService:GetDeviceListAsync()` / `GetDeviceInfoAsync()` (42 presets)

## General UI and UX
- Laws of UX - https://lawsofux.com/
- Refactoring UI (Adam Wathan, Steve Schoger), summary - https://howtoes.blog/2025/07/04/refactoring-ui-complete-book-summary-all-key-ideas/
- Material Design 3 easing and duration tokens - https://m3.material.io/styles/motion/easing-and-duration/tokens-specs ; states - https://m3.material.io/foundations/interaction/states/applying-states
- Microsoft, Designing for Xbox and TV (TV-safe area, 10-foot sizes) - https://learn.microsoft.com/en-us/windows/apps/design/devices/designing-for-tv
- Celia Hodent, The Gamer's Brain (usability and engage-ability pillars) - https://celiahodent.com/video-game-ux-psychology/
- Fagerholt and Lorentzon, Beyond the HUD (2009) - https://www.semanticscholar.org/paper/Beyond-the-HUD-User-Interfaces-for-Increased-Player-Fagerholt-Lorentzon/16ee02a8839923752c6bc93f294bec67d73a586e
- HUD design article - https://nastyrodent.com/what-is-hud-in-games/
- Game UI design guide - https://www.uichallenges.design/guides/game-ui-design
- Game UI Database (reference library) - https://gameuidatabase.com/
- Local skills `emil-design-eng` and `apple-design` (motion and interaction principles)
- Icon sets used by `icons.html`: Phosphor (MIT), Lucide (ISC), Tabler (MIT), via cdn.jsdelivr.net
- Tailwind CSS v3 colour ramps (MIT)
