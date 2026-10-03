# The Roblox UI engine: facts, new features and traps

Checked against the creator-docs repository and the API reference on 2026-10-03. Traps marked
"(measured)" were found in Lepy's places and cost real debugging time.

## Containers

- `ScreenGui` (screen), `SurfaceGui` (on a part face), `BillboardGui` (faces the camera over a part).
- `ScreenGui` in `StarterGui` is cloned into `PlayerGui` on join. `ResetOnSpawn = true` (default)
  re-clones it on every respawn and drops all runtime bindings - set it **false** for HUDs and menus.
  An indirect StarterGui descendant always resets.
- `ScreenGui.Enabled = false` stops rendering, input and updates for the whole tree: hide whole
  screens this way, not by toggling every child's `Visible`.
- `DisplayOrder` orders ScreenGuis. Keep a ladder: HUD 0-9, menus 10-19, modals 20-29, toasts 30-39,
  tutorial and overlays 40-49, loading 100.
- `ZIndexBehavior.Sibling` (the default): a child always draws above its parent, and a whole subtree
  draws inside its parent's slot. Raising ZIndex on a popup inside a card does nothing against the next
  card - raise the **card's** ZIndex while it is hovered (measured, Wacky Pets).
- `ScreenInsets`: `CoreUISafeInsets` (default; clear of notch and top bar), `DeviceSafeInsets` (clear of
  the notch only), `TopbarSafeInsets`, `None` (only for non-interactive full-screen art).
  `ClipToDeviceSafeArea` (default true), `SafeAreaCompatibility` (default `FullscreenExtension`),
  `IgnoreGuiInset` (legacy; prefer `ScreenInsets`).
- **Inset trap (measured):** with `IgnoreGuiInset = true` the root frame reports
  `AbsolutePosition = (0, -58)`. Converting another element's `AbsolutePosition` into an offset puts it
  58 px too high. Always use `target.AbsolutePosition - container.AbsolutePosition`.
- `BillboardGui.Active = false` kills every button inside it (measured). `UIStroke.Thickness` inside a
  BillboardGui scales with the billboard: 0.1 draws ~2 px, 2 draws a 40 px blob (measured). Setting
  `Adornee` before parenting can stop it drawing. `AlwaysOnTop` billboards do not show in
  `screen_capture`.
- A `Camera` saved inside a ViewportFrame in StarterGui never reaches the client: build it at run time.
  ViewportFrames do not draw particles. A WorldModel is needed for an Animator to pose a rig inside one.

## Position and size

- `UDim2` = `{scaleX, offsetX}, {scaleY, offsetY}`; scale is a fraction of the **parent**, offset is
  logical pixels; they add.
- `AnchorPoint` sets the origin: `(0.5, 0.5)` centre, `(0.5, 1)` bottom centre, `(1, 0)` top right.
  Pin to an edge with scale (`Position = UDim2.new(1, -16, 0, 16)`, `AnchorPoint = (1, 0)`), size with
  offset.
- `AutomaticSize` (X, Y, XY) grows a frame to fit its content; `Size` becomes the **minimum**. It
  respects `AnchorPoint`. `TextWrapped` + `AutomaticSize.Y` grows labels downward. ScrollingFrames use
  `AutomaticCanvasSize` instead.
- `UIScale.Scale` multiplies the absolute size of its parent and everything under it, **including
  strokes and corners**. Use it for global device scaling and for press/pop animations.
- `UIAspectRatioConstraint` and `UISizeConstraint` **override** a layout's sizing of that child.
  `UITextSizeConstraint` caps `TextScaled` text (never `MinTextSize` under 9).
- Studio typing trick: entering `0.5` in Size gives scale, `20` gives offset.

## Layouts

- `UIListLayout`: `FillDirection`, `Padding` (between items only, not around), `SortOrder`
  (`LayoutOrder` - use it, never `Name`), `HorizontalAlignment`, `VerticalAlignment`, `Wraps`, flex:
  `HorizontalFlex` / `VerticalFlex` (`Enum.UIFlexAlignment` None, Fill, SpaceAround, SpaceBetween,
  SpaceEvenly), `ItemLineAlignment`.
- `UIFlexItem` on a child: `FlexMode` None, Grow, Shrink, Fill, Custom (`GrowRatio`, `ShrinkRatio`),
  `ItemLineAlignment`. Flex costs more: use it on purpose.
- A layout takes over `Position` (and `Size` with flex) of **every** visible GuiObject sibling. An
  invisible overlay button added to a laid-out frame becomes a list item and moves one row down
  (measured, Wacky Pets quests). Put overlays in a frame without a layout, or listen on the frame.
- `UIGridLayout`: `CellSize`, `CellPadding`, `FillDirectionMaxCells`, `StartCorner`. A Y-scale
  `CellSize` inside an auto-canvas ScrollingFrame resolves against the frame or the canvas
  unpredictably: put a `UIAspectRatioConstraint` **under the UIGridLayout** and use
  `CellSize = UDim2.fromScale(x, 1)` (measured). Leave room for the 12 px scroll bar. Use scale
  padding with scale cells (a pixel gap made a 4th column fall off on a phone - measured).
- `UITableLayout` (rows and columns), `UIPageLayout` (swipeable pages with `Animated`, `EasingStyle`,
  `TweenTime`, `:JumpTo`, `:Next`, `:Previous`).
- `UIPadding` pads the inside of a frame (scale or offset; negative allowed).

## Appearance modifiers (all current properties)

- `UICorner`: `CornerRadius` (UDim; scale is a fraction of the **shortest** edge, >= 0.5 makes a pill)
  plus per-corner `TopLeftRadius`, `TopRightRadius`, `BottomRightRadius`, `BottomLeftRadius`.
- `UIStroke`: `Thickness`, `Color`, `Transparency`, `LineJoinMode` (Round, Bevel, Miter),
  `ApplyStrokeMode` (Contextual = the text, Border = the box), `BorderStrokePosition` (Outer, Center,
  Inner), `BorderOffset` (UDim), `StrokeSizingMode` (FixedSize, ScaledSize - scaled is relative to the
  font size for text), `ZIndex` (order among sibling strokes; equal ZIndex = undefined order),
  `Enabled`. A child `UIGradient` makes a gradient stroke. Do not tween `Thickness` on text (it renders
  new glyph sizes every frame and flickers).
- `UIGradient`: `Color` (ColorSequence), `Transparency` (NumberSequence), `Offset`, `Rotation`,
  `Scale`, `TileMode` (Clamp, Repeat, Mirror), `Type` (Linear, Radial - radius (w+h)/4, rotation
  ignored - and Conical - sweeps clockwise from `Rotation`), `Enabled`. Tween `Offset` for shines and
  `Rotation` for spinning rings.
- `UIShadow` (new): `BlurRadius` (UDim, scale of the shorter side), `Color`, `Transparency`, `Offset`
  (UDim2), `Spread` (UDim2), `ZIndex` (must be negative), `Enabled`. Follows rotation and UICorner. No
  text shadows (it shadows the label's box), no inset shadows, no gradients. Before UIShadow, soft
  shadows were a 9-sliced shadow image behind the panel; both work.
- `UIDragDetector` (drag a GuiObject: sliders, joysticks, map panning) and `Path2D` (draw lines and
  curves) exist; use them instead of hand-rolled drag code.

## CanvasGroup

- Draws its subtree as one flattened texture, so `GroupTransparency` and `GroupColor3` fade or tint a
  whole panel at once (only under `ZIndexBehavior.Sibling`). It always clips its descendants.
- Costs texture memory capped by the client's quality level; past the cap it draws **blank**. Keep the
  size static (a resize makes a new texture) and use it only for panels that fade, not for the HUD.
- It stopped compositing in the Studio edit viewport once (every transparency rendered solid) while
  Play was fine (measured, Aboshima). Judge CanvasGroup fades in Play.

## Images

- `ScaleType`: Stretch, Slice (9-slice), Tile (`TileSize`), Fit, Crop. Use Fit for icons.
- 9-slice: `ScaleType = Slice`, `SliceCenter = Rect.new(left, top, right, bottom)` in **image pixels**,
  `SliceScale` scales the corners. Corners never stretch, edges stretch one way, the centre both ways.
- Sprite sheets: `ImageRectOffset` + `ImageRectSize`.
- `ResampleMode = Pixelated` for pixel art.
- Uploads: `upload_image` only takes http URLs - serve the PNG from a local Node server. A fresh upload
  renders blank until moderation finishes (`thumbnails.roblox.com/v1/assets?assetIds=<id>` state
  `Completed`). A Creator Store **decal** id fails in an ImageLabel: `InsertService:LoadAsset(decalId)`
  and read the Decal's `Texture` for the image id. Files named `.png` from the web can be WebP
  (measured).
- Make icons at 2x the displayed size; keep a 1-2 px transparent margin so edges do not clip.

## Text

- `FontFace = Font.new("rbxasset://fonts/families/<Family>.json", Enum.FontWeight.X, Enum.FontStyle.Normal)`
  or `Font.fromName("FredokaOne")`. Weights: Thin 100, ExtraLight 200, Light 300, Regular 400,
  Medium 500, SemiBold 600, Bold 700, ExtraBold 800, Heavy 900 (only the weights the family ships).
- Families in this Studio build (content/fonts/families): AccanthisADFStd, AmaticSC, Arimo, Balthazar,
  Bangers, BuilderExtended, BuilderMono, BuilderSans, ComicNeueAngular, Creepster, DenkOne, Fondamento,
  FredokaOne, GrenzeGotisch, Guru, HighwayGothic, Inconsolata, IndieFlower, JosefinSans, Jura, Kalam,
  LegacyArial, LegacyArimo, LuckiestGuy, Merriweather, Michroma, Montserrat, NotoSansCJKFallback,
  Nunito, Oswald, PatrickHand, PermanentMarker, PressStart2P, Roboto, RobotoCondensed, RobotoMono,
  RomanAntique, Sarpanch, SourceSansPro, SpecialElite, TitilliumWeb, Ubuntu, Zekton. Creator Store
  fonts can be added by id with `Font.fromId`.
- Gotham was retired on 2024-05-28 and auto-replaced by **Montserrat**; Arial by **Arimo**. Builder
  Sans is Roblox's platform font (Builder Extended for display, Builder Mono for code).
- `TextScaled` fits text to the box, but sizes differ label to label, it ignores
  `PreferredTextSize`, and it costs performance; Roblox staff recommend fixed `TextSize` with offset
  boxes. If `TextScaled` is used (Lepy's artists often do), always add `UITextSizeConstraint` and make
  sibling labels the same box height so they land on the same size.
- `TextWrapped`, `TextTruncate` (AtEnd, SplitWord), `LineHeight` (multiplier), `TextXAlignment`,
  `TextYAlignment`, `TextFits` (read-only: false when the text does not fit), `TextBounds`,
  `MaxVisibleGraphemes` (typewriter reveal), `ContentText` (the text without rich-text tags).
- Rich text (`RichText = true`): `<b> <i> <u> <s>`, `<font color="#FF7800" size="18"
  face="Michroma" family="rbxasset://fonts/families/Michroma.json" weight="Bold" transparency="0.5">`,
  `<stroke color="#000" thickness="2" transparency="0" joins="round" sizing="fixed">`,
  `<uppercase>`/`<uc>`, `<smallcaps>`/`<sc>`, `<mark color="#FFD700" transparency="0.5">`, `<br/>`,
  `<!-- -->`, entities `&lt; &gt; &quot; &apos; &amp;`. Localized text loses rich-text tags.
- Text over the 3D world needs a stroke (`UIStroke` on the label, Contextual, 1-2 px, dark, transparency
  0-0.3) or a backplate. The old `TextStrokeTransparency` stroke is a fixed 1 px outline; UIStroke is
  better.
- `TextService:GetTextBoundsAsync()` measures text before layout.

## Style sheets (UI styling, full release after the 2025-05-22 Studio beta)

- Instances: `StyleSheet` (rules + tokens as attributes), `StyleRule` (`Selector`, `Priority`,
  `SetProperties`, `SetPropertyTransitions`, `SetDefaultPropertyTransition`), `StyleLink` (connects a
  sheet to a ScreenGui tree; one per instance), `StyleDerive` (a sheet inherits another - themes),
  `StyleQuery` (conditions: `MinSize`, `MaxSize`, `AspectRatioRange`).
- Selectors: class `TextButton`; tag `.ButtonPrimary` (CollectionService tag); name `#CloseButton`;
  state `:Hover`, `:Press`, `:NonInteractable` (GuiState values Idle, Hover, Press, NonInteractable);
  pseudo-instance `::UICorner`, `::UIStroke`, `::UIPadding`, `::UIListLayout` (creates a phantom
  modifier, one per type per element); combinators `>` (child), `>>` (descendant), `,` (list);
  queries `@ViewportDisplaySizeSmall/Medium/Large`, `@PreferredInputTouch/Gamepad/KeyboardAndMouse`,
  `@ReducedMotionEnabledTrue/False`, or a custom `@Name` from a StyleQuery.
- Tokens: attributes on a sheet (`sheet:SetAttribute("Primary", Color3.fromHex("335FFF"))`), used as
  `"$Primary"` in rule properties. Themes are sheets with the same token names; swap with
  `StyleSheet:SetDerives({...})`.
- Example: `rule.Selector = ".ButtonPrimary:Hover"`, `rule:SetProperties({BackgroundColor3 =
  "$PrimaryHover"})`, `rule:SetPropertyTransitions({BackgroundColor3 = TweenInfo.new(0.12)})`.
- **A rule only applies while the instance's own property is still at its default.** A value set
  directly on the instance wins (it shows bold in Properties). Builders that set every property by hand
  silently defeat the sheet: either style through the sheet or through the instance, not both.
- The Style Editor (Studio) creates `ReplicatedStorage.Design` with BaseStyleSheet (never edit),
  StyleSheet, TokenSheet and theme folders.
- When to use: new UI built from scratch with many repeated components and states (hover, press,
  device queries) - the sheet is a real instance tree, which fits Lepy's rule. When not: inside a place
  whose artist-made panels set every property directly.

## Input

- `Active = true` on a Frame does **not** stop clicks reaching a button behind it; only another
  GuiButton sinks a click (measured, Aboshima). A modal needs an invisible full-size `TextButton`
  guard (Text "", AutoButtonColor false, BackgroundTransparency 1) with a ZIndex above the backdrop and
  below the panel's controls.
- `GuiObject.InputSink` (`None`, `Activate`, `All`) is meant to fix this, but on 2026-07-23 Roblox staff
  said it is "not currently enabled". Test it in the current build before relying on it; until it works,
  keep the guard button.
- A GuiButton nested inside another GuiButton always eats the parent's click, whatever its ZIndex. Set
  `Active = false` and `Selectable = false` on decorative buttons inside a button (measured, Sword Arena).
- `AutoButtonColor = true` (the default) caches the colour on hover-enter and writes it back on
  hover-exit, undoing any selected-state colour set during the click (measured). Turn it off on every
  button with custom states and drive the states yourself.
- `GuiButton.Interactable = false` disables a button and sets its state to `NonInteractable`.
- `Activated` fires for mouse, touch and gamepad A; prefer it over `MouseButton1Click`.
- `MouseEnter`/`MouseLeave` misfire on touch; never put function behind hover.
- Gamepad: see `devices.md` section 7 (`GuiService:Select`, `SelectionGroup`, `SelectionBehavior*`,
  `SelectionOrder`, `NextSelection*`, `SelectionImageObject`, `SelectionChanged`).
- Studio synthetic clicks (`user_mouse_input`) reach `UserInputService` but never ClickDetectors or
  BillboardGui buttons; test those paths through their remotes or a probe (measured).

## Accessibility APIs

`GuiService.PreferredTextSize`, `GuiService.PreferredTransparency`, `GuiService.ReducedMotionEnabled`
(see `devices.md` section 10). Sample: `BackgroundTransparency = default * GuiService.PreferredTransparency`;
with reduced motion, fade a CanvasGroup instead of sliding it.

## Performance

- Fewer instances beat clever ones: a HUD of 50-150 GuiObjects is normal; thousands (big scrolling
  shops) need pooling (recycle row frames) or pages.
- `TextScaled`, flex layouts, `AutomaticSize` chains and CanvasGroups cost layout or texture time;
  use them on purpose.
- Tweens: TweenService runs off the script; prefer one tween per property over per-frame code. A new
  tween on the same property cancels the old one and starts from the current value (good for
  interruptible UI). Keep a handle for any tween a later call must cancel (measured, Aboshima overlay).
- Hide closed screens with `ScreenGui.Enabled = false`.
- `RenderStepped` stops when Studio is hidden behind another window; tween timing tests need Studio
  in front (measured).

## Traps found while building the pixel lab (2026-10-03)

- A child named `Text` inside a TextButton is unreachable as `button.Text` (the property wins).
  Never name children after properties of their parent class (`Text`, `Size`, `Position`, `Image`).
- `Enum.KeyCode.Esc` does not exist: the key is `Escape`. Key-hint attributes must be real KeyCode
  names; put a short display text in a separate attribute.
- A disabled ScreenGui does not update `AbsoluteSize` (it kept the previous device's size); read the
  screen from `workspace.CurrentCamera.ViewportSize` or enable the gui first.
- A UIListLayout grabs every child: keep overlays (key chips, cooldown shades, corner badges) outside
  the laid-out frame (button > Body(list) + Key + Cool).
- `TextSize` ignores UIScale: the rendered size is `TextSize` times every UIScale above the label.
- A fixed-offset TextLabel inside a scale-sized image breaks on phones: the authored Undertale timer
  ("99:99", 138 x 39 px TextScaled) spills out of its 0.25-scale panel on a 667 x 375 iPhone. Size the
  text with the same method as its frame (scale + aspect, or both offset under one UIScale).

## Reading a place's existing UI

Before touching any authored panel: list its tree, its fonts, colours, strokes, corner radii, sizes
(scale or offset), layouts and constraints, and capture it on screen. Copy its vocabulary. Lepy's
rules: never overwrite an authored label except a placeholder for exactly that value, never
`Instance.new` a visible element into an authored panel, clone and restyle an authored panel for a new
one (see `taste.md`).
