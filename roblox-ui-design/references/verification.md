# Verification: prove the UI on every device before calling it done

A screen is not done after it is built. It is done when it was captured on the device set, read,
fixed and captured again at least twice, `Audit.lua` reports nothing real on phone, desktop and
console, the console is clean, the first open was measured, and the report shows the captures and the
numbers. Lepy wants the final captures sent (2026-10-03).

## 1. Tools (all in `scripts/`)

| Tool | Runs in | Does |
|---|---|---|
| `serve.js` | Node (PowerShell, `run_in_background`) | serves `scripts/*.lua` and `scripts/examples/*.lua` at `/src/`, files in OUT at `/out/`, writes POSTed files (data URLs decoded) to OUT. Default port **8775** (8766-8772 are often held by other sessions' servers - check with `Get-NetTCPConnection`). |
| `Build.lua` | Edit, via `loadstring` | theme tokens + helpers that make real instance trees |
| `Fit.lua` | client at run time (and Preview) | root UIScale per device class |
| `Ui.lua` | client at run time | press/hover/ink states, open/close, toast, count, bar trail, pop, pulse, shake, stagger, key hints per input |
| `Preview.lua` | Edit | switches the simulated device, applies Fit and the top-bar inset, runs each screen's `Layout` module, shows chosen screens, draws a top-bar + touch-control ghost |
| `Devices.lua` | Edit | small wrapper over `StudioDeviceSimulatorService` |
| `Audit.lua` | Edit or Client | the checker (section 4) |
| `Install.lua` | Edit | copies runtime modules into the place from the server |
| `icons.html` | built-in browser at `http://127.0.0.1:8775/icons.html?...` | renders Phosphor / Lucide / Tabler SVG icons to white PNGs at 2x and posts them to OUT |
| `capture/pixicons.ps1` | PowerShell | draws pixel-art icons from text grids |
| `capture/grab.ps1`, `capture/crop.ps1`, `capture/sheet.ps1` | PowerShell | Studio window grab, letterbox trim, labelled contact sheets |

Load pattern inside `execute_luau` (Edit):

```lua
local Http = game:GetService("HttpService")
_G.uiGet = function(n)
	local was = Http.HttpEnabled
	Http.HttpEnabled = true
	local ok, src = pcall(Http.GetAsync, Http, "http://127.0.0.1:8775/src/" .. n)
	Http.HttpEnabled = was
	assert(ok, src)
	return loadstring(src)()
end
_G.uiFit = _G.uiGet("Fit.lua")
_G.uiPreview = _G.uiGet("Preview.lua")
_G.uiAudit = _G.uiGet("Audit.lua")
```

Always restore `HttpEnabled` (it is a place setting). Compile-check every script first:
`loadstring(src)` returns nil plus the error on a syntax error.

## 2. The device set (in this order)

`samsung_galaxy_a16` (worst common phone, usable 686 x 339 after Android bars), `iphone_7`
(narrowest, 667 x 375), `iphone_16_pro_max` (notch insets), `ipad_10th_generation` (tablet),
`average_laptop` (1366 x 768), `hd_1080`, `xbox` (TV), `meta_quest_3` (VR, only if supported).

Facts measured 2026-10-03 with the simulator from `execute_luau` (Edit):
- `SetDeviceAsync(id)` switches the viewport; `workspace.CurrentCamera.ViewportSize` becomes the
  **usable** viewport (Galaxy A16: 686 x 339, not 780 x 360 - the Android system bars and the
  punch-hole inset are taken off). Read sizes from the camera: a **disabled ScreenGui does not update
  its AbsoluteSize**.
- `GuiService.ViewportDisplaySize` and `UserInputService.PreferredInput` follow the simulated
  device: phones Small/Touch, desktops Medium/KeyboardAndMouse, Xbox Large/Gamepad with
  `GuiService:IsTenFootInterface() == true`. So `Fit.lua` and `Layout` modules run correctly in Edit.
- Edit mode has **no Roblox top bar** (`GetGuiInset` = 0) and no touch controls. `Preview.lua`
  shifts the screen's Root down by the real inset (52 px touch, 58 px desktop/console) and draws a
  ghost top bar, jump button and thumbstick at their real places. Pass `controls = false` for modal
  screens (a game should hide the touch controls while a full menu is open:
  `GuiService.TouchControlsEnabled = false`).
- Use `SetScalingModeAsync(Enum.DeviceSimulatorScalingMode.FitToWindow)` so 1080p devices fit the
  Studio viewport; `ActualResolution` gives 1:1 for phones.
- Always finish with `preview(Fit, {reset = true})` (device default, screens disabled, ghost removed)
  and restore the editor camera.

## 3. Captures

- `screen_capture` (Studio MCP) shows the 3D view plus ScreenGuis at the simulated size. It is fine
  for reading layouts; it skips CoreGui and AlwaysOnTop billboards, and it returns no file.
- For files to send: `capture/grab.ps1` (brings Studio to the front, moves the pointer off the
  viewport, grabs the window) then `capture/crop.ps1` (trims the simulator's letterbox colour
  32,34,39; search box x 300-1446, y 176-804 on a maximized 1920 x 1080 Studio - re-measure if the
  layout differs). The grab includes the simulator's device frame (notch, bezel), which is useful.
- Team Create presence bubbles ("+14") show in window grabs. Tilt the editor camera a little
  (`cam.CFrame = saved * CFrame.Angles(math.rad(20-26), math.rad(-8), 0)`) until none are in frame,
  and restore it after.
- `capture/sheet.ps1` builds labelled 2-column contact sheets; send them with `SendUserFile`.
- PowerShell trap: never name a function `diff` (it is an alias of Compare-Object and wins).

## 4. `Audit.lua`

`audit(gui, {touch = true, hud = true})` for phones/tablets, `{}` for desktop, `{tv = true}` for
console. It reports, each capped at `cap` lines:

- `OFFSCREEN`, `TV-UNSAFE` (outer 5%), `STICK ZONE` (left 40% x bottom 2/3), `JUMP ZONE`
- `SMALL HIT` (< 44 touch, < 32 mouse, < 64 TV, measured in absolute px)
- `SMALL TEXT` (< 11, or < 24 on TV - effective size = TextSize x every UIScale above it)
- `OVERFLOW` (`TextFits` false), `TEXTSCALED NO CAP`
- `CONTRAST` (WCAG ratio against the nearest opaque background: 4.5 body, 3 large) and
  `NO PLATE OR STROKE` (text over the 3D world with neither)
- `NESTED BUTTON`, `AUTOBUTTONCOLOR`, `OVERLAP` (interactive vs interactive), `RESETONSPAWN`
- the sets of fonts, text sizes, corner radii, stroke widths and paddings in use, and unnamed
  GuiObjects - the consistency check: one font family, about 3-6 sizes, 1-3 radii, 2-3 strokes,
  paddings on the 4 px scale.

Elements are clipped by their ScrollingFrame / ClipsDescendants / CanvasGroup ancestors first, so
rows scrolled out of a list are not reported. Names `Guard`, `Backdrop`, `Hit`, `Dim`, `Shade` and the
attribute `AuditSkip` are skipped as intentional full-cover buttons. A finding is a question, not a
verdict: confirm it in the capture before changing anything.

## 5. Reading a capture (the checklist)

1. Does it look like **this game** (its palette, frame shapes, motifs, font)? Compare with an
   authored screen side by side.
2. One focal point per screen? Is the primary action the only accent?
3. Edges: does every element line up with another (read the AbsolutePosition numbers)?
4. Groups: is inside-group space smaller than between-group space?
5. Phone: anything in the stick or jump zones, under the top bar, touching the notch? Targets 44+?
   Panel inside 52 px top bar + 16 px margins? Text 11+?
6. Tablet: stretched panels? Things drifting apart vertically on 4:3?
7. Desktop: hover states, key chips, nothing tiny, nothing absurdly stretched?
8. Console: glyphs instead of keys, TV-safe margins, 64 px controls, 24/30 px text, a visible focus?
9. States: are hover, pressed, selected, disabled, cooldown, owned, locked, unaffordable all shown?
10. Motion (Play, if RAM allows): press within one frame, open 0.2-0.3 s, close faster, nothing from
    scale 0, reduced motion falls back to fades.

## 6. Profile

Measure the first open in Edit: `os.clock()` around `gui.Enabled = true` plus reading a deep
element's `AbsoluteSize` (forces layout), then the time to the next Heartbeat. Pixel lab numbers on
the desktop preset (2026-10-03): HUD 144 instances 7.2 ms, shop 161 instances 4.1 ms, settings 84
instances 0.3 ms, result 38 instances 0.5 ms. Anything over ~8 ms on desktop will hitch on a phone:
pre-enable once at join behind a fully transparent state, or split the screen.

## 7. Team Create and the place

Edits in a Team Create place are live for everyone and saved to the cloud. Build samples and tests as
clearly named, disabled ScreenGuis (`Lab_*`, attribute `Lab`) and ask Lepy at the end whether to keep
or delete them. Never touch the authored UI without his word; report its defects instead (for example
the Undertale timer text overflowing its panel on phones).

## 8. Real clicks in the device emulator (2026-10-05)

- The Studio MCP virtual mouse does not activate buttons while the emulator is a touch phone; real clicks (`SetCursorPos` + `mouse_event`) with Studio in front do.
- Measure the screen mapping in the same Play session: grab the screen, find two buttons, fit `screen = offset + scale * AbsolutePosition`. The Roblox top-bar buttons showed in one session and not in another, and an inset of `CoreUISafeInsets` moved the shop's top row about 80 px while the bottom-anchored row stayed. A take that clicks only bottom-anchored buttons survives that change.
- A BillboardGui prompt sits lower on screen than `WorldToViewportPoint` of its adornee (87 px in the shop test); find it in a grab.
- Log every `Activated` click with a sound or attribute logger, so a missed click shows at once.

## 9. Full-screen screens, the top bar and the gamepad in Play (2026-10-05)

- Edit mode has no Roblox top bar, so an Edit preview cannot show a collision with it. Check a full-screen screen (`ScreenInsets.None` + `IgnoreGuiInset`) in Play with a real screen grab on the narrowest phone (iPhone 7). There the menu pill spans about x 69-164, y 12-55 px and covered the corner of a title tab at y 49.
- `GuiService.TopbarInset` gives the occupied band: Min (164, 0), Max (666, 58) on an iPhone 7; the height is 87 with a gamepad on the Xbox device. Keep the top element at `max(offset, (TopbarInset.Height + 2) / k + stroke)` in the fit function and refit on `TopbarInset` changes. Disconnect that `GuiService` connection when the screen is destroyed: it outlives the gui and threw "Fit is not a valid member of Frame Root".
- Tablets and desktops also show the Roblox player list (top right) over full-screen UI. Keep the top-right corner free.
- Selection leak: hiding the selected button moves `GuiService.SelectedObject` to the nearest `Selectable` object (a full-screen backdrop TextButton, then a HUD button after the screen is destroyed), and the pad then drives the HUD instead of the character. Clear `SelectedObject` before hiding, and set `Selectable = false` on backdrop buttons.
- Touch emulator: one real click gives two touches mirrored about a fixed point (the device centre; 342.8, 121.9 GUI px on a Galaxy A16). A click near the bottom right also taps the Roblox logo at the top left, which opens the menu and cancels the press. Pick a click point whose mirror lands on nothing. Escape did not close the menu; a tap on the logo did.
- Controller Emulator: the "Virtual Controller" box in the device bar (x 947, y 183 in Play and x 1086, y 182 in Edit on this machine) opens a key map: Y 7, X 8, B 0, A 9, left stick W A S D. Press a pad key to make `PreferredInput` Gamepad. With it on, Studio prints "Setting GuiService.SelectedObject to invalid GuiObject - Studio" at Play start (context Studio, before the client starts); it is not from a place script.
- A screen that shows for a few seconds: clone its LocalScript into PlayerGui from the client VM to run it again with the real template, and trigger a grab from the pixels (wait for the dark backdrop, then for the white label). Drive a teleport screen by setting the server attributes the client watches (queued elevator, countdown 0), then restore them.
