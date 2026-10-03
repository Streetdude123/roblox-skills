# UI motion

"If visual design aims to communicate a message that is clearly understood, motion aims to have that
message clearly felt" (Riot). Motion is never polish on a bad layout: fix the layout first.

## 1. The five goals (Riot) and what they mean in Roblox

1. **Responsiveness:** every press shows a change within one frame (UIScale or colour on
   `InputBegan`/`MouseButton1Down`, not on release). Never wait for a remote before showing the press.
2. **Intention:** motion leads the eye to the next action (the reward pops, then the CLAIM button
   pulses once; the new tab slides in from the side of its tab).
3. **Awareness:** elements move **from their source**: a popup grows from the button that opened it
   (set the AnchorPoint toward the trigger), a coin flies from the pet to the coin counter, a toast
   slides in from the edge it lives on. Modals are the exception: they stay centred.
4. **Consistency:** one element type always moves the same way (every panel opens with the same
   tween, every toast enters from the same side). Put the TweenInfos in one module (`Ui.lua`).
5. **Physical intuition:** the motion fits the game: bouncy Back Out for a cartoon simulator, crisp
   Quint Out for a tactical shooter, slow fades for horror, snappy cuts for an anime battlegrounds HUD.

## 2. Should it animate at all? (frequency rule)

| How often the player sees it | Decision |
|---|---|
| Many times a minute (hotbar swaps, ability presses, inventory scrolling) | instant, or a 60-100 ms press scale only |
| Many times a session (opening the shop, tabs, hover) | short: 120-250 ms |
| Occasionally (rewards, level up, results) | can be richer: 0.4-1.5 s, but skippable |
| Once (first-join intro, title screen) | can be a show piece, always skippable |

Keyboard and gamepad shortcuts that toggle a panel should open it fast (<= 150 ms) or instantly.

## 3. Easing (TweenService names)

| Situation | EasingStyle / Direction | Why |
|---|---|---|
| Something enters or responds | **Quint Out** or **Exponential Out** (strong ease-out) | starts fast, feels immediate |
| Playful entrance (cartoon, simulator) | **Back Out** (about 10% overshoot) | a pop with a settle |
| Something leaves | **Quad In** / **Sine In**, shorter than the entrance | gets out of the way |
| Moves across the screen and stops | **Quart InOut** / **Quint InOut** | accelerates and settles |
| Colour or transparency change | **Quad Out** / **Sine Out** | soft |
| Continuous (spinner, progress fill) | **Linear** | constant speed |
| Bounce, Elastic | rarely: a coin landing, a mascot; never on panels | distracting when repeated |

Never use an In easing for something the player just pressed - it starts slow and feels laggy.

## 4. Durations

| Element | Duration |
|---|---|
| Press feedback | 60-100 ms down, 140-200 ms back |
| Hover | 100-150 ms |
| Tooltip | 120-200 ms in, after a 400 ms hover delay; instant for neighbours |
| Dropdown, tab content | 150-250 ms |
| Panel / modal open | 200-300 ms |
| Panel close | 120-180 ms (exits are faster than entrances) |
| Toast | 250 ms in, 2-4 s hold (longer for more text), 200 ms out |
| Reward reveal | 0.5-1.5 s total, skippable with a tap |
| Stagger between list items | 30-50 ms, total capped near 300 ms |

UI motion over 300 ms on frequent actions feels slow. The exception is a reward or level-up moment,
which is rare and should feel big (peak-end rule).

## 5. Recipes

**Button press** (every GuiButton): a `UIScale` child. Down: Scale 0.95 in 0.07 s Quad Out. Up: Scale
1 in 0.16 s Back Out (cartoon) or Quint Out (clean). Hover (mouse only): Scale 1.04 in 0.12 s or a
lighter fill. Turn `AutoButtonColor` off and drive colours yourself. Play the click sound on the down
frame. `Ui.press(button)` wires this.

**Never animate from zero.** Panels start at UIScale 0.9-0.95 with full transparency, not at 0 size:
"nothing in the real world appears from nothing".

**Panel open/close:** a `UIScale` and a `CanvasGroup` (or transparency on each part). Open: Scale
0.92 -> 1 (Back Out 0.26 s) and GroupTransparency 1 -> 0 (Quad Out 0.18 s); backdrop dim 1 -> 0.45
(0.2 s). Close: Scale 1 -> 0.95 and fade out (Quad In 0.15 s), then `Visible = false`. Keep the tween
handles: a close during the open must cancel the open tween (Aboshima bug: a stray tween reopened a
closed panel). Without a CanvasGroup, fade only the backdrop and scale the panel.

**Toast / notification:** enters from its edge (top-centre or bottom-centre on phones, above the
thumb zones), 16-24 px slide + fade, Quint Out 0.25 s, holds 2-4 s, leaves the same way it came
(Apple: "if something disappears one way, we expect it to emerge from where it came"). Stack new
toasts on top; cap at 3 visible.

**Number count-up:** tween a NumberValue and write the formatted text on `Changed`. 0.4-0.8 s Quad
Out; at the end a 1.15x pop of the label. Currency bars: the icon pops when coins arrive.

**Health bar with a damage trail:** two fills. The main fill jumps to the new value in 0.08 s; a
lighter (or white/red) trail fill under it waits 0.3-0.4 s, then shrinks over 0.3-0.5 s Quad Out. On
heal the trail jumps first (green) and the main fill grows.

**Cooldown:** a radial sweep (UIGradient `Type = Conical` with a hard transparency edge, rotated by the
remaining fraction) or a fill from the bottom; the icon is desaturated and dim while cooling; at ready
a short flash (white overlay 0.15 s) and a pop.

**Selection (tabs, cards, gamepad):** the selected item scales 1.05 and takes the accent stroke;
the indicator bar under tabs slides to the new tab (Quint Out 0.2 s) instead of jumping.

**Stagger:** reveal list items 30-50 ms apart with a 8-12 px rise and fade; never block input while
the stagger runs.

**Attention pulse:** only for the one thing that needs action now (claimable reward): UIScale
1 -> 1.06 -> 1 over 1 s, repeating, stopped as soon as it is pressed. Never more than one pulsing
element on a screen.

**Shake for errors:** a 6-8 px horizontal shake, 3 cycles in 0.3 s, plus the error sound and a red
flash of the field. Not for every refusal: a "not enough coins" toast is gentler.

**Gradient shine:** a white UIGradient with a narrow transparency band; tween `Offset` from (-1, 0)
to (1, 0) over 0.6-0.8 s every few seconds on a premium button only.

## 6. Interruptible motion

- A new tween on the same property cancels the running one and starts from the current value, so
  UI built from tweens retargets smoothly. Never set the start value again before retargeting (that
  jumps).
- Never lock input while an animation plays. A panel must close even while it is opening.
- Keep one tween handle per animated property group and cancel it in the opposite action.

## 7. Reduced motion

When `GuiService.ReducedMotionEnabled` is true: no slides, no scale pops, no shakes, no pulses, no
parallax. Keep 150-200 ms fades and colour changes that carry meaning. `Ui.lua` checks the flag in one
place.

## 8. Sound with motion

Visual, sound and haptic on the **same frame**, only for meaningful moments (Apple). One sound per
action type, used everywhere. UI sounds in a "UI" SoundGroup.
