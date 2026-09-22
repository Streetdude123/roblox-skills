# Pack intake: from a pasted VFX pack to a template folder

Lepy pastes whole packs into a place (one was 50k instances, 48k descendants of meshes, flipbooks and
emitters in Workspace). This is the order of work every time a pack arrives.

## 1. Quarantine and scan

Art needs no scripts. Run `scripts/ScanPack.lua` on the pack root (Edit mode). It lists every
`LuaSourceContainer` with its full name and flags `require(`, `getfenv`, `loadstring`, `GetObjects`,
`HttpService`, `MarketplaceService`, `TeleportService`, and any numeric array longer than 20 entries
(a byte-array payload). Read every flagged source in full, then delete or disable every script.

What has been found before:
- A "Hit Effects" pack: a `Script` inside a particle attachment required a `ModuleScript` that required
  a `NumberPose` value holding an asset id, under 450 lines of filler about "texture streaming". Studio's
  sandbox blocked it (`lacking capability LoadUnownedAsset`); a published place might not.
- A free crate: a Command Bar social-engineering payload rebuilt from a byte table, kicking every player
  with "Error 500" until the developer pastes attacker code. A keyword scan reported it clean.
- `insert_asset` reporting `sandboxed: true` means the model has scripts. Read them.

His packs so far carried only dead helper scripts (`Grow`, `#Scr1pt`), which stay dead in `ServerStorage`.

## 2. Archive the whole pack

Move every Workspace child that is not the map, the camera, terrain, spawn or the character into
`ServerStorage.<PackName>` keeping the group names (loose parts to `Loose`, decal reference tiles to
`DecalRefs`). Nothing in `ServerStorage` renders, streams or runs, so the place stays light. The DIO
place holds his kit as `ServerStorage.VfxKit` with these groups:

| Group | What it holds |
|---|---|
| `Anime` | 36 named effect parts: Charge, Shiny, Lighting-01..03 blue flipbooks, Shield-Break lavender rings, Crack, Shoot shockwave, Punch hits, Wind, Smoke, Stars, Portal, Splash, Realistic-Explosion |
| `Big` | Explosion, Tornado windspins, Ball, Lighting with 8 to 20 stud impacts, Big-Crack |
| `Auras` | RNG-Aura-01 purple rune ring with chain beams, RNG-Aura-02 gold beam fan with stars, RNG-Aura-03 green floor rays, Fire and Water body auras |
| `Beams` | waterfall, wind, lava |
| `vfx pack` | a purple (172, 98, 255) explosion kit: cross sparks 33 studs, shards, specs, streak stars, flat ground rings, rocks, crescents |
| `Heads` | face particles |
| `VFX` | rings, shockwaves, spirals, spheres, spikes, EyeRing, a Lightning Gold Skin mesh |
| `VFX PACK` | a categorised texture gallery of 639 tiles: trail, square, debris, screen, fire, smoke, crosshair, star, circle, wave, burst, symbol, random, light flash, lightning, line types |
| `VFX :D` | 1447 numbered flipbook sample parts; the names are meaningless, the texture ids are the value |
| `Meshes/VFX` | a mesh gallery plus an SFX folder by element (spams "Failed to load sound" in the console; not ours) |
| `Wing Rigs`, `Weapon Meshes`, `Particle Storage` | rigs, weapons, gallery walls |

## 3. Render the meshes before trusting a name

Mesh names lie. In one kit "Ring" was a solid cube and "ShockDisc" was the real ring; a house-sized
white box popped on every hit because of it. Every mesh looks like a white blob at cube proportions,
so run `scripts/MeshGallery.lua`: it lays the candidates in a row at the proportions you will use
(a blade is about `(length, length * 0.014, length * 0.35)`), labels each with a BillboardGui, and you
capture once. These meshes are thin on their local Y, so a ground ring needs no rotation and a ring
facing a direction needs `CFrame.lookAt(p, p + dir) * CFrame.Angles(-math.pi / 2, 0, 0)`.

Texture galleries do not read in a capture at all (hundreds of tiles are unreadable); study a pack by
its named effect parts and by reading emitter properties, not by screenshots of the gallery walls.

## 4. Sounds: blank the dead ones

54 of the kit's SFX clips were private audio and spammed "not authorized" on every play start.
`scripts/BlankDeadSounds.lua` plays each Sound template once, and for any that fails to load it blanks
`SoundId` and stores the old id in a `DeadSoundId` attribute so nothing is lost. The Stand model's own
70 sounds and the picked library clips all loaded.

## 5. Build the template folder

Clone only the pieces the effect uses into `ReplicatedStorage.<Feature>.Assets.Vfx` (template parts
with their emitters and beams, all disabled), `Assets.Meshes` (normalised MeshParts) and
`Assets.Sounds`. `Kit.lua` spawns, tints, scales, emits and kills these templates; the effect module
never touches `ServerStorage`. Proven templates in the DIO summon: ChainRing, GoldBurst, GreenAura,
Lightning, ShieldBreak, Charge, Shiny, Crack, Shock (direction Front; rotate the carrier 90 degrees
about X for a floor ring), Tornado, BigLightning, PackExplosion, PackF (its rocks emitter is named
`rocks(14`), PurpleCore, Swirling, Twirl, Rays, AuraSheet, RingShock, PurpleExpanding, FlashSheet,
Stars, MiniSparks, Dots, Smoke, Hit1, Hit2.

`Kit.emit(inst, counts)` takes a number for every emitter or a table keyed by emitter name or by the
digits of the texture id, so a template with an oddly named emitter can still be driven exactly.

## 6. Preload and warm

At join the client preloads every sound, every emitter and beam texture (through hidden ImageLabels
in a disabled ScreenGui) and every MeshPart or SpecialMesh of the rig. Preload alone is not enough:
the first draw of a mesh, a material or a sprite still costs a frame. `SummonVfx.warm` spawns the
burst templates and the sparkle set once with all emitters at transparency 1 and `Emit(1)`, sets the
rig's parts to 0.98 transparency for two frames with their real materials, then two frames as the
Neon ghost, then hides them again. The first cast dropped from a 57 ms frame to 26 ms.

## 7. Keep the pack out of the scene

A showcase arena sits 2600 studs from the pack's old position so nothing from it streams in. If the
pack must stay in Workspace for browsing, it belongs at that distance too.
