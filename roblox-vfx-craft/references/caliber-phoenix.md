# Caliber Phoenix: a flying sword wave on the move rung

Built 2026-09-28 in Place1 for Lepy's client Moon ("Three-Blade Swordsman" sheet: three teal-green sword trails combine into a flying crescent with a subtle feathered shape, thin cutting streaks and a sharp impact burst). Samurai R6 with two katanas in the hands and one in the mouth; key Z; a dummy takes the hit with a ragdoll knockback. Sources: `Desktop/roblox/Samurai` (Fx.lua, tools/BuildFx.lua, Config.lua). The animation side is in the animation skill (weapons.md, "Three swords").

## Beats (clip time, real time in brackets)

| Beat | Clip | What shows |
| --- | --- | --- |
| Gather | 0.08 (0.09 s) | Aura carrier welded to the root: wind wisps and curls flowing inward (Sphere, `ShapeInOut` Inward), rising motes, a jade light 0.9; glow beams grow on all three blades. The air-rush sound starts at 0 and peaks at the release. |
| Spread | 0.44 (0.55 s) | Hop with the blades raised like wings: two feather bursts from the arms (7 + 5 feathers, 4 wind hooks, 8 to 14 studs/s), a ground ring and dust, the blade trails switch on. |
| Release | 0.585 (0.73 s) | The crescent forms around the body: two thin ghost arcs above and below merge into the main arc over 0.1 s while it drifts 2 studs, then it flies at 110 studs/s for 0.72 s. Camera kick 0.3 for the caster. |
| Impact | on contact | Flash 0.1 s, star, spiky ring, a flat ring facing the travel, 26 sparks, 18 feathers, smoke, a light 6, two crossed crescent cuts (Neon mesh, 0.24 s), impact + boom sounds, a distance-scaled kick. |

## The crescent

- Base: a free Shanks saber slash pack (beam crescent: Darkest, Dark, Medium, Clear, Clearest beams between two attachments with CurveSize +-16, plus two dark tail containers rotated +-30 degrees). Recoloured jade (dark rim 4,30,32; body 20,255,190; core 200,255,235), scaled 0.8 (span 19.2, the arc front 9.6 ahead of the part), all beams FaceCamera. Keep the pack's beam layering; it is what makes it read as a slash wave and not a mesh.
- Roll the whole carrier 14 degrees and let it wobble +-2: a flat horizontal crescent is a thin line from the player camera.
- Feathered shape: 15 feather beams (the painted feather sprite along the beam, `TextureMode` Stretch) on the trailing edge of the Bezier arc, pointing back and up (back 0.55, outward 0.9 x |s|^0.8, up 0.75), 1.6 to 4.6 studs long, longest at the horns. Pointing them straight back hid them: from behind the player they point at the camera.
- On the carrier: spark streaks (Squash 2.5 to 3.5), cut lines, 16 + 10 feathers a second, wind wisps, a jade light 3. At the end the beams shrink in 0.16 s and 16 + 12 feathers scatter.
- Hit test: `Sweep.touches` checks the band between the arc front at the last frame and now (the first step covers the whole arc), shared by the server and the caster's prediction.

## Traps found

- A Trail with a streak texture over a fast sweep draws stacked flat panes (each frame one quad). No texture gave solid white panels. What worked: a painted strip texture (bright tip edge, soft body), LightEmission 0.8, lifetime 0.12, transparency 0.3 to 1.
- The pack's jagged strip texture on VelocityParallel particles draws striped panes; a negative Squash widens it into rectangles. Use the four-point spark texture with a positive Squash for thin streaks.
- Warm-up out of view does nothing: templates spawned at y -400 were culled, and the first cast after join had an 87 ms frame at +261 ms. Spawned 12 studs in front of the camera at 0.98 transparency, plus a silent play of every sound: the first cast's worst frame was 19.8 ms on a 16.5 ms idle.
- The aura light at 1.8 tinted the whole body green; 0.9 with range 8 reads as a glow.
- With Studio at 3.5 GB private on the 6 GB machine and the quarantined packs still in ServerStorage, recordings dropped 548 frames; deleting the quarantine (956 instances) and recording 10 to 22 s takes at scale 0.6 gave 20 to 22 fps with 0 drops.

## Checks (2026-09-28)

- Clip: frozen 0, still 2.2%, rest 47% in real time, contrast 7.5; first cast worst frame 19.8 ms; second cast 26.2 ms.
- Console clean on the client and the server; dummy knocked back and reset home after 3.2 s.
