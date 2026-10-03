# Design tokens: the fixed set of values every screen draws from

A professional UI looks consistent because every size, colour, radius and timing comes from a small
set chosen in advance (Refactoring UI: "limit your choices"). Write the game's token table before the
first frame, put it in the builder's `theme` (and in a StyleSheet's attributes when the UI uses
styles), and never pick a value by eye mid-build. All sizes are Roblox logical pixels at UIScale 1
(see `devices.md` for device scaling).

## Spacing (4 px base)

`2, 4, 8, 12, 16, 24, 32, 48, 64`

| Token | px | Use |
|---|---|---|
| `xxs` | 2 | icon to its badge, stroke gaps |
| `xs` | 4 | icon to its label, tight chips |
| `sm` | 8 | inside a group: label to value, button gap, grid gap on phones |
| `md` | 12 | card padding on phones, row gap |
| `lg` | 16 | panel padding, card padding on desktop, gap between groups |
| `xl` | 24 | gap between sections, screen-edge margin on desktop |
| `xxl` | 32 | big section breaks, hero spacing |
| `3xl` | 48-64 | only on large screens and title screens |

Rules: the space inside a group is smaller than the space between groups (at least 2x). Screen-edge
margin: 12-16 px on phones (inside the safe area), 24 px on desktop, 96 x 54 px TV-safe on consoles.
Inner corner radius = outer radius - padding (nested rounded boxes look concentric).

## Type scale (six sizes)

One family for the whole game, two at most (a display face for titles, a plain face for everything
else). Two or three weights.

| Token | Size | Weight | Use |
|---|---|---|---|
| `caption` | 12 | Medium/SemiBold | timers, counts, fine print, badges |
| `body` | 14 | Regular/Medium | descriptions, rows |
| `label` | 16 | SemiBold/Bold | buttons, tabs, list titles |
| `title` | 20 | Bold | card and dialog titles |
| `heading` | 28 | Bold/ExtraBold | panel headers |
| `display` | 40 | ExtraBold/Heavy | reward amounts, round results, title screens |

- Phones and desktops use the same sizes (Roblox normalizes DPI); consoles scale everything about 2x
  through the root UIScale. Never go under 11 px for anything a player must read.
- `LineHeight`: 1.15-1.3 for body, 1.0-1.1 for headings.
- Roblox has **no letter-spacing property**: pick the face for its spacing. Caps titles read best in
  faces that are already open (Michroma, Oswald, BuilderExtended, Montserrat Bold); dense numbers read
  best in Builder Sans or Roboto with tabular figures for timers (use `RobotoMono` / `BuilderMono` for a
  ticking timer so the width does not jump).
- Numbers that change (currency, timers, damage) use one fixed box width so the layout does not wobble.

**Face by personality (built-in families):**

| Personality | Display / titles | Body |
|---|---|---|
| Clean, modern, neutral | BuilderSans Bold, Montserrat Bold | BuilderSans, Montserrat |
| Playful, cartoon, simulator | FredokaOne, LuckiestGuy, Bangers (sparingly) | FredokaOne, Nunito Bold |
| Sci-fi, tech | Michroma, Zekton, Sarpanch | TitilliumWeb, Roboto |
| Anime / battlegrounds | BuilderExtended, Oswald, Bangers for hit words | BuilderSans, RobotoCondensed |
| Fantasy, medieval | Fondamento, Merriweather, GrenzeGotisch (titles only) | Merriweather, SourceSansPro |
| Horror | Creepster or SpecialElite (titles only) | SourceSansPro, Arimo |
| Retro / pixel | PressStart2P (small sizes stay crisp) | PressStart2P or Ubuntu |
| Handwritten / cosy | PatrickHand, Kalam, IndieFlower | Nunito |
| Minimal, Lepy's flat look | Jura, Oswald Medium caps, BuilderSans | same |

Decorative faces (Creepster, Bangers, LuckiestGuy, GrenzeGotisch, PermanentMarker) are for titles and
short words only, never for paragraphs or numbers that must be read fast.

## Colour

**Roles, not paint.** Every colour in the UI has a role:

| Role | Meaning | Default (dark UI) |
|---|---|---|
| `bg` | full-screen backdrop | neutral 950 at 0.3-0.5 transparency |
| `surface` | panel | neutral 900 |
| `raised` | card on a panel | neutral 800 |
| `sunken` | input wells, bar tracks | neutral 950 |
| `line` | dividers, quiet strokes | neutral 700 |
| `text` | primary text | neutral 50 |
| `text2` | secondary text | neutral 300 |
| `text3` | hints, disabled | neutral 500 |
| `primary` | the one call to action | the game's hue 500 |
| `primaryHover` / `primaryPress` | its states | hue 400 / hue 600 |
| `onPrimary` | text on the primary fill | white or neutral 950 by contrast |
| `success` / `warning` / `danger` / `info` | meaning only | green 500 / amber 400 / red 500 / sky 400 |

**Ramps.** Each hue has 9-11 shades (50-950). Build them in HSL: the 500 shade is the base; lighter
shades rise in lightness and saturation and rotate the hue 5-20 degrees toward the nearest bright hue
(60 yellow, 180 cyan, 300 magenta); darker shades fall in lightness, rise in saturation and rotate
toward the nearest dark hue (0 red, 120 green, 240 blue). `Build.ramp(h, s, l)` does this. Tint the
greys toward the primary hue (cool blue-grey or warm brown-grey), never pure grey on a coloured game.

Ready ramps (Tailwind CSS v3, MIT; tested, well balanced):

| Shade | slate (cool grey) | zinc (neutral grey) | stone (warm grey) |
|---|---|---|---|
| 50 | #F8FAFC | #FAFAFA | #FAFAF9 |
| 100 | #F1F5F9 | #F4F4F5 | #F5F5F4 |
| 200 | #E2E8F0 | #E4E4E7 | #E7E5E4 |
| 300 | #CBD5E1 | #D4D4D8 | #D6D3D1 |
| 400 | #94A3B8 | #A1A1AA | #A8A29E |
| 500 | #64748B | #71717A | #78716C |
| 600 | #475569 | #52525B | #57534E |
| 700 | #334155 | #3F3F46 | #44403C |
| 800 | #1E293B | #27272A | #292524 |
| 900 | #0F172A | #18181B | #1C1917 |
| 950 | #020617 | #09090B | #0C0A09 |

Accent 400 / 500 / 600: red #F87171 / #EF4444 / #DC2626; orange #FB923C / #F97316 / #EA580C;
amber #FBBF24 / #F59E0B / #D97706; yellow #FACC15 / #EAB308 / #CA8A04; green #4ADE80 / #22C55E /
#16A34A; emerald #34D399 / #10B981 / #059669; sky #38BDF8 / #0EA5E9 / #0284C7; blue #60A5FA /
#3B82F6 / #2563EB; violet #A78BFA / #8B5CF6 / #7C3AED; purple #C084FC / #A855F7 / #9333EA;
pink #F472B6 / #EC4899 / #DB2777; rose #FB7185 / #F43F5E / #E11D48.

**Proportion:** about 60% neutral surfaces, 30% secondary (cards, rows, headers), 10% accent (the call
to action, the selected tab, the reward). If more than one or two elements per screen carry the accent,
nothing stands out.

**Rarity ladder** (the convention players know from many games; keep it identical on every screen -
card border, name, glow, drop beam):

| Tier | Colour | Hex |
|---|---|---|
| Common | grey | #A1A1AA |
| Uncommon | green | #4ADE80 |
| Rare | blue | #38BDF8 |
| Epic | purple | #A855F7 |
| Legendary | gold/orange | #F59E0B |
| Mythic | red/pink | #F43F5E |
| Secret / Divine | animated gradient (white-cyan or rainbow) | UIGradient |

Pair each tier with a shape or label too (tier name, star count, frame shape) for colour-blind players.

**Contrast.** Body text at least 4.5:1 against its background, large text (18 px+ bold or 24 px+) and
icons/shapes at least 3:1 (WCAG). `Audit.lua` measures it. Text over the 3D world has no stable
background: give it a dark stroke (1-2 px) or a backplate.

**Game conventions:** health green (or red in combat games - pick one and keep it), mana/energy blue,
stamina yellow/white, XP purple or blue, currency gold, premium currency cyan/purple, damage taken red,
heal green, crit yellow/orange, disabled grey, locked = lock icon, unaffordable price red.

## Radius (pick one family per game)

| Family | Buttons | Cards | Panels | Chips |
|---|---|---|---|---|
| Square (serious, Lepy's flat default) | 0 | 0 | 0 | 0 |
| Soft (modern) | 6-8 | 8-12 | 12-16 | 6-8 |
| Round (playful, simulator) | 12-16 | 16-20 | 20-24 | pill (scale 0.5) |

Never mix square panels with pill buttons unless the style sheet says so.

## Strokes

| Use | Thickness | Colour | Notes |
|---|---|---|---|
| Hairline divider / quiet border | 1 | `line`, transparency 0.4-0.7 | flat and modern styles |
| Card border | 1-2 | neutral 700 or tier colour | `BorderStrokePosition = Inner` keeps the size exact |
| Selected / focus ring | 2-3 | primary or white | gamepad focus needs 3+ |
| Cartoon outline (simulator) | 3-5 | a dark shade of the fill (hue 800-900), not black | on buttons, panels and text alike |
| Text over the world | 1-2 | black or neutral 950, transparency 0-0.3 | `ApplyStrokeMode.Contextual` |

`StrokeSizingMode.ScaledSize` keeps text strokes proportional when the text size changes.

## Depth (elevation)

| Level | Use | UIShadow (or 9-slice shadow image) |
|---|---|---|
| 0 | flat HUD, inline items | none |
| 1 | buttons, chips | Offset (0,0,0,2), BlurRadius (0,4), Transparency 0.7 |
| 2 | cards | Offset (0,0,0,4), BlurRadius (0,10), Transparency 0.75 |
| 3 | dropdowns, tooltips | Offset (0,0,0,8), BlurRadius (0,18), Transparency 0.7 |
| 4 | modals | Offset (0,0,0,16), BlurRadius (0,32), Transparency 0.6 |

Shadow colour = a very dark shade of the background hue, not pure black. "If the shadow is the first
thing you notice, you're not using it right." On dark UIs depth comes from lighter surfaces
(`surface` < `raised` < hover), not shadows. In the flat style: no shadows; use a 1 px line or a
4-8% lighter fill. A short shadow with no blur (Offset 0,4, BlurRadius 0) gives a tactile "3D button"
in cartoon styles.

## Layers (DisplayOrder ladder)

HUD 0-9 / menus 10-19 / modals 20-29 / toasts 30-39 / tutorial and spotlight 40-49 / loading 100.
Information labels that must never be covered (Lepy): top of their ScreenGui, or `AlwaysOnTop` for
billboards.

## Motion tokens (TweenService)

| Token | Duration | EasingStyle / Direction | Use |
|---|---|---|---|
| `press` | 0.06-0.08 | Quad Out | button down: UIScale 0.94-0.96 |
| `release` | 0.14-0.2 | Back Out (playful) or Quint Out (clean) | button up |
| `hover` | 0.12 | Quad Out | colour shift or UIScale 1.03-1.05 |
| `open` | 0.22-0.28 | Back Out or Quint Out | panel in: UIScale 0.92 -> 1 + fade |
| `close` | 0.14-0.18 | Quad In or Sine In | panel out: UIScale 1 -> 0.95 + fade |
| `toastIn` / `toastOut` | 0.25 / 0.2 | Quint Out / Quad In | 16-24 px slide + fade; hold 2-4 s |
| `stagger` | 0.03-0.05 per item | - | list reveals, cap the total at ~0.3 |
| `count` | 0.4-0.8 | Quad Out | number roll-ups |
| `bar` | 0.08 fill, trail after 0.3-0.4 delay over 0.3-0.5 | Quad Out | damage trail |
| `pop` | 0.12 up + 0.18 down | Quad Out / Back Out | scale 1 -> 1.15 -> 1 on a value change |

Details and the reasons are in `motion.md`. Reduced motion: fades of 0.15-0.2 s only.

## Sound tokens

Every UI sound fires on the same frame as its visual. Click 0.3-0.5 volume; hover very quiet (or
none); open/close soft whooshes; purchase/reward a bright chime; error a short low buzz; all in one
`SoundGroup` ("UI") so the settings panel can trim it. Hover sounds only for mouse.
