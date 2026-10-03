# Controlled imperfection

Lepy, 2026-10-03, after the first ornate chest: it looked nice but too perfect - "it should be perfect but not too perfect to the point where it basically unrealistic". Perfect symmetry, identical parts and even wear read as CG. Real objects are built by hand, used, knocked and repaired. The aim is believable, not broken: a viewer should not be able to point at one error, only feel that the object is real.

## Geometry (apply the same transform to a low part and its high parts)

| Change | Range used on the chest | Note |
| --- | --- | --- |
| Small random rotation of parts (planks, brackets, plates) | 0.6 - 2.5 degrees | `wobble([lo, hi], center, deg, off, normal)`; brackets turn about their face normal |
| Offset along the face normal | +/- 0.006 studs | planks stand slightly in and out |
| Uneven gaps and sizes | +/- 0.006 position, +/- 1-2% size | plank height and lid plank boundaries jittered |
| Chips on edges (high poly only) | 2-4 random cubes of 0.025-0.055 studs per plank, cut last | `chip_cutter` in chest.py; bake carries them |
| Dents and hammered metal (high only) | Stucci 0.006-0.008, Voronoi 0.003-0.005 strength | displace modifiers in `hi_detail` |
| Slight waves on long bands and straps | 0.005-0.01 studs along the path | phase-shifted sine on the high path |
| Rivet spacing and size | spacing 0.2 +/- 0.025, scale 0.88-1.1, off-centre 0.006 | |
| Hanging parts at rest angles | rings 4-9 degrees, padlock 4-6 degrees | gravity, not symmetry |

Stacked UV copies must stay rigid copies of the master; rotation and offset are fine, scale and shape changes are not.

## Texture

- A random tint per part (`tint` face attribute, baked): +/- 12% value and a small hue shift on wood, +/- 8% on metal.
- Wear that follows use: more on top edges, handles and corners, less in protected areas; modulate every edge mask with noise so wear is uneven.
- Dirt collects low and in cavities: a height gradient near the ground plus AO.
- Directional streaks: water streaks on wood sides, rust runs below rivets.
- Scratches on metal: thin stretched noise thresholds, 30-35% blend.
- Never a uniform pattern: if a texture reads as a pattern at the Roblox camera (camo, cells, stripes), it is wrong.

## Limits

- Terrain gets less of all of this, not more.
- Hero silhouettes stay clean; imperfection lives in the secondary and tertiary forms.
- In a stylized game (style brief), keep imperfection in shape and colour variation, not in grime.
