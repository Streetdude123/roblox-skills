# Game UI: HUDs, menus, inventories, shops, rewards, onboarding

## 1. Information priority (do this before any layout)

For every screen, sort every piece of information into three bins:

1. **Now** - the player needs it this second to act (health in a fight, the parry window, the
   objective timer, the ammo count). Always visible, peripheral, high contrast, large enough to read
   without looking at it directly.
2. **Soon** - needed in the next minute or on demand (currency, quest progress, minimap). Visible but
   quiet, or shown when it changes, then fading.
3. **Later** - looked up in a menu (stats, collection, settings, codes). Never on the HUD.

"80% of player attention never reaches the HUD": the periphery sees motion and contrast, not detail.
Use size, colour and a short motion (a pop when a value changes) for Now items; never fine print.
Progressive disclosure: The Last of Us shows almost no HUD while exploring and expands it in combat.
Roblox's Spellbound RPG shows skill buttons only after the Items button.

## 2. Screen zones (landscape)

```
+------------------------------------------------------------------+
| top bar (Roblox, 52-58 px)   | objective / timer / round info    |
| left: party / quest / team   |                   right: currency |
|                              |                     leaderboard   |
|           ( centre: the action - keep it clear )                 |
|                              |                                   |
| bottom-left: THUMBSTICK zone | bottom-centre: hotbar (desktop)   |
| (touch: keep clear)          |      bottom-right: JUMP + actions |
+------------------------------------------------------------------+
```

- Top centre: game state (round timer, objective, score). Top right: currency (most simulators) or
  player list area. Left edge above the stick zone: quests, party, notifications.
- Centre: only transient things (crosshair, hit markers, interaction prompts, big announcements).
- Bottom centre: hotbar on desktop; on touch it moves up or becomes the action arc on the right.
- Group by category: "if you group UI elements from different categories together throughout the
  screen, players won't know where to look" (Roblox curriculum).
- New HUD pieces go into the existing HUD stack (a UIListLayout column), never as a separate
  ScreenGui placed by code that drifts on phones (Lepy, Wacky Pets).

## 3. HUD by genre

| Genre | HUD core | Notes |
|---|---|---|
| Battlegrounds / fighting | health, stamina/posture, ability slots with cooldowns, combo/parry indicator | minimal, fast-reading bars; hit feedback in the world (VFX, numbers), not in the HUD; the Strongest Battlegrounds style: tiny HUD, big moves |
| Simulator / tycoon | currency stack top-right/left, big round menu buttons on the left edge, boost timers, a goal tracker | chunky cartoon buttons with icons and a label under each; every number counts up; constant reward feedback |
| Obby / platformer | stage number, timer, checkpoints, skip/rewind | almost nothing else; the course is the UI |
| Horror | nearly nothing; diegetic cues (flashlight battery on the item, heartbeat sound, screen-edge meta effects) | every HUD element reduces fear; hide when not needed |
| RPG / adventure | health/mana, quest tracker, minimap, hotbar, XP bar | the densest HUD; strict zones; a strong theme frame (9-slice) |
| Shooter | ammo, health, crosshair, kill feed, minimap/compass | high contrast numbers, kill feed top-right, damage direction indicators |
| Roleplay / social | phone/menu button, money, job | everything else in menus; the avatar and chat matter most |
| Tower defense | wave, base health, money, unit cards with costs | the unit bar is the main control; cost red when unaffordable |
| Racing | speed, position, lap, minimap | big numbers, readable at a glance |

## 4. Menus and flows

- Write the flow for each task (Berry Avenue avatar example in Roblox's UX doc: tap Avatar -> pick a
  category -> scroll -> tap item -> Done) and count the taps. Remove steps from the most common task
  first (Design Doc's Iron Boots lesson).
- Every screen answers: where am I (title), where can I go (tabs, buttons), what is here, how do I get
  out (X / B / Esc, always in the same place).
- Depth: no more than two levels (menu -> panel -> detail). A third level is a sign the IA is wrong.
- Roblox games do not pause. Decide what happens while a panel is open: the player keeps moving
  (menu small, on one side), the player is frozen (shops at a stand, say so visibly), or the game
  continues around a full-screen menu (risky in PvP - provide a quick close).
- Opening a panel from a world object: open it at the object (BillboardGui prompt) or slide it from
  the side; close it automatically when the player walks away (Wacky Pets sell shop closes past range + 4).

## 5. Inventory UX

- Match the inventory to the game's values (Design Doc): scarce items -> limited slots and a look that
  says so; collect-everything games -> unlimited space with sort and filter.
- Make the common task the fastest: equip best, quick-swap (Doom's tap-for-last-weapon), sell/fuse
  all of a kind, favourite/lock to protect. Context actions appear on the HUD only while they apply.
- Show, do not make the player recall: icons, tier colours, counts, equipped markers, "new" badges.
- Sort options (rarity, power, newest), a search box when there are more than ~50 items, filters by
  type. Comparison in one action (hover/select shows the delta against the equipped item: green up,
  red down arrows).
- Card states via authored overlays: equipped, locked, new, favourite, maxed.
- Quick wheel or hotbar for frequent items (8 slots fit a wheel; touch gets a bigger radial).

## 6. Shops and monetization UI

- Each shop has its own palette (Lepy: the sell shop gold/yellow, the seed shop brown wood) but the
  same structure (card grid, tabs, a hotbar/footer) as the rest of the game.
- Price on every card; unaffordable prices red; owned items show "Owned" via an authored overlay, not
  by rewriting the price label (Lepy's rule).
- Highlight value the honest way: the best-value bundle gets more size and padding (Dragon Adventures)
  or a gold stripe (Jailbreak premium rewards) - attention through size, space and colour.
- Robux purchases go through `MarketplaceService:PromptProductPurchase` / `PromptGamePassPurchase`; the
  shop shows the result (owned state, a toast) after `PromptPurchaseFinished`/`ProcessReceipt`, never
  before.
- Read prices from `GetProductInfo` instead of typing them.
- No dark patterns: no fake timers, no hidden costs, close buttons always visible, no confirm-shaming.
  Roblox players are young; trust is retention.

## 7. Rewards, results, progression

- Peak-end rule: the reward moment and the round end are what players remember - give them the richest
  motion and sound in the UI (see the reward popup recipe), but always skippable.
- Goal gradient: show the next goal and how close it is (a bar under the currency stack, "2 more
  quests for a new plot").
- Zeigarnik: unfinished progress (3/5) pulls players back; daily and playtime rewards show the next
  claim time.
- Results screens: the outcome word first (VICTORY / DEFEAT, huge), then the player's own numbers,
  then the rewards counting up, then Continue. League's post-game: the LP change in a big ring.

## 8. Onboarding (first-time UI)

- Teach by doing: wait for the real action at each step (Wacky Pets 13-step tutorial), not NEXT
  buttons. Spotlight the target (one hole frame + huge stroke), point with an arrow or a world beam,
  freeze nothing the player needs to do the step.
- One instruction at a time, short, device-aware text ("Tap PICK" on touch, "Press E" on desktop,
  the A glyph on console).
- Skippable, with a reward for finishing; log each step (`AnalyticsService:LogOnboardingFunnelStepEvent`)
  to see where players quit.

## 9. Conventions players already know (Jakob's law)

X closes (top-right); B / Esc goes back; grey = disabled; lock icon = locked; red price =
unaffordable; green health (or red in combat games - keep one); gold = currency; a red dot = something
new; E = interact (ProximityPrompt), C = crouch, 1-9 = hotbar, Tab = player list, M = map, I or B =
inventory, Shift = sprint; long-press on touch = details; rarity colours grey < green < blue < purple <
gold < red.

## 10. Reference library

- Game UI Database (gameuidatabase.com): screens of thousands of games by screen type (HUD, inventory,
  shop, settings, map...). Pull 3-5 references per screen before designing.
- Top Roblox games in the same genre: play them on a phone and on desktop and note where everything
  sits, which sizes they use and how panels open.
- Riot's advice: recreate a favourite game's HUD or menu exactly to learn its decisions.
