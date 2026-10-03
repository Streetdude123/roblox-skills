# UI brief - <game> / <screen>

Fill this in before building. Ask Lepy about every line that his request leaves open.

## 1. Purpose and player
- Screen(s):
- Who uses it, on which devices (phone / tablet / desktop / console / VR):
- What the player wants to do here, in one sentence:

## 2. Tasks by frequency (UX first)
| Task | How often | Taps / presses now | Target |
|---|---|---|---|
| | many times a minute / session / rarely | | |

The most frequent task gets the fewest steps. What happens to the game while this is open
(keeps running / player frozen / slows)?

## 3. Information priority
- Now (always visible, peripheral):
- Soon (visible but quiet, or on change):
- Later (menu only):

## 4. Style
- Authored screens captured (names):
- Style family (styles.md) and the game's own motifs (shapes, props, colours):
- Font family and weights:
- Palette roles (bg, surface, raised, line, text, text2, text3, primary, semantic, tiers):
- Radius family / stroke widths / depth:
- Motion feel (crisp, bouncy, slow):

## 5. States matrix
| Element | normal | hover (mouse) | pressed | selected / focus | disabled | loading | empty | error | locked / owned |
|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | | |

## 6. Layout per device class
| Class | Scale | Changes from the base layout |
|---|---|---|
| Phone (<= 500 short side) | 1.0 | |
| Tablet | | |
| Desktop | | |
| Console / TV | | TV-safe 5%, glyphs, selection order |
| VR | | |

## 7. Build plan
- Instance tree (names are the contract):
- Templates and where they live:
- Runtime modules (Ui, Fit, Layout, feature module):
- Sounds:

## 8. Verification plan
- Device set: galaxy_a16, iphone_7, iphone_16_pro_max, ipad_10th_generation, average_laptop, hd_1080, xbox
- Audit options per class:
- States to show in captures:
- First-open budget:

## 9. Open questions for Lepy
-
