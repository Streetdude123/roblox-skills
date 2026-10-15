# Projectiles, beams and elements

This file covers flying effects and the elements they carry: the parts of a projectile, how its trail ends, beam geometry and layering, replication, lightning, fire, earth and colour language. The sources are engine tutorials, Riot and Real Time VFX artists, the Roblox creator docs and DevForum resources. Every finding was read from its source and re-checked by an independent reader on 2026-10-11. Each rule is restated with the instance, property or number it implies. Where a source disagrees with his taste or a SKILL.md rule, his rule wins and the file says so. Sources are at the end.

## 1. A projectile is a cast, a head, a tail and an impact (Kodeco, Unreal Community Wiki)

Kodeco's Unity tutorial builds a projectile as a head (the core of the flying body) plus a tail that follows it. "When the projectile only has a head, the visual just doesn't look right." The head is one additive, stretched half-sphere mesh particle: speed 0, max particles 1, scale 15, 15, then Z raised to 55, about 3.7x longer along the travel. The tail is a backward cone emitter (angle 0, rotation Y 180) at rate 50 to 200, lifetime 0.1 to 0.6 s (0.1 to 0.3 on the fireball), size 0.1 to 0.4, speed 1 to 3. Some randomness improves it.

The cast (muzzle) effect has three elements, all one-shot bursts: a cone, a flash with a light, and sparks. The cone is one mesh particle with speed 0, size 50, life 0.2 s and a fire gradient. The flash is one particle, size 3, life 0.1 s, colour FFF247, plus a point light. The sparks are a burst of 15, size 0.05 to 0.1, life 0.1 to 0.4 s, speed 3 to 5, white to yellow and fading out.

The fireball also gets a secondary, darker flame tail "to help it stand out from the original flame". It is the FlameTail duplicated, recoloured red and brown "to mimic half-burned ash", switched to an alpha-blended material, and sorted behind FlameTail. The fireball also emits continuous sparks: life 0.1 to 0.4, size 0.01 to 0.05, start colour FFE981, stretched billboards with length scale 7, noise strength 0.5 and frequency 1.

The Unreal Community Wiki says an impact must meet three criteria: an initial hit for player feedback, a radial energy path out from the impact point, and an aftermath on the world. Hit flash: one particle, lifetime 0.075 to 0.125 s, size growing 0 to 5x over life, no velocity, drawn on top of geometry, over-bright orange. Dust: a burst of 10 to 20, life 0.125 to 0.25 s, size growing 1 to 10x, alpha 0 up to 0.75 at a quarter of its life, then 0. Debris: 10 to 20 pieces, life 1 to 2 s, gravity varied around real gravity (900 to 1200 against 980 cm/s2) for air friction and shape, 1 to 2 bounces, then freeze. The emitters face out along the surface normal.

Roblox translation:
- The head is the projectile's hero: the palest, brightest piece. Build it as one carrier part with a glow stretched along the travel: a FaceCamera Beam between a nose and a rear attachment, or one LockedToPart glow particle with Squash.
- The tail is a separate emitter on a rear attachment pointing backward (Rate 50 to 200, Lifetime 0.1 to 0.6, small sizes, all as ranges) plus a Trail. Both sit one step down in value from the head (principles.md section 1). Never ship a head with no tail.
- Give every tail a dark partner: a second emitter with LightEmission 0, LightInfluence 1, the palette's deep or ash colour, and a lower ZOffset than the additive tail. This is the skill's dark-rim rule on a moving tail.
- Sparks dragged along a moving head use VelocityParallel with a much stronger stretch than burst sparks (length scale 7 against the 2 to 4x in principles.md), at small sizes.
- Cast flash at the hand or weapon on the launch frame, all as `Emit`, never `Rate`: one cone or crescent sprite facing the shot with Lifetime about 0.2, one `glow` flash with Lifetime about 0.1 in the palette's pale core colour, a PointLight spike that decays, and about 15 short sparks (VelocityParallel, Squash, Lifetime 0.1 to 0.4).
- His water laser pick ("a flash and a stronger kick on the laser", taste.md) is this cast flash plus `CameraRig.kick`.
- Impact on the hit frame: one `glow` flash `Emit(1)` with Lifetime 0.08 to 0.12, a size curve from 0 to 5x, and a high ZOffset so it draws over the target. A dust puff `Emit(10)` to `Emit(20)` with a short life and a size curve growing about 10x.
- Impact debris uses an Acceleration near workspace gravity (196.2 by default), scaled 0.9 to 1.2 per piece. That is far heavier than the -20 to -40 used for sparks.
- Orient the impact carrier to the hit normal so the burst leaves the surface. The aftermath is the skill's permanence rule: a crack or a dust ring left 2 to 5 s.

## 2. End the trail with the projectile, and show the direction in a still frame (Real Time VFX, Riot)

A Niagara poison ball left a solid ribbon line after the sphere was hidden on hit. The poster's fix was a boolean "HasStopped", set from Blueprint on the hit, that switched the ribbon emitter's spawn rate so it stopped making new particles. Another reply suggested driving a material parameter with a timeline.

Riot's clarity rules: a projectile should show its travel direction even in a still frame, and blurring the tail end is the suggested technique. Mismatched hitboxes are a key frustration. The attention an ability grabs should match its importance: Zoe's Q is bright, saturated and has an audio cue ahead of time, and Taric's stun has a bright effect, an audio wind-up and a well-defined hitbox. Arcane Comet's large ground circle suggests more dodgeability than is real.

Roblox translation:
- On the hit, hide the head (Transparency 1), set the tail emitters' `Enabled = false`, anchor the carrier at the hit point, and destroy it only after the longest tail Lifetime. Live particles finish their life after `Enabled = false` (engine-and-performance.md section 2).
- Calling `Destroy()` on the hit frame pops the whole trail at once: the kind of hard cut he reads first ("it cuts off here not smoothly").
- A Trail in Stretch mode shrinks inward once its attachments stop moving, so a stopped carrier lets it collapse into the impact.
- Check a paused frame of every projectile. A sharp bright head and a soft tail that fades backward must show its direction.
- The visible head and glow radius equal the server cast's hit radius. A telegraph (a ground circle, a line) is never larger than the real hit area.
- A dodgeable projectile gets an audible cue before the launch (a charge or a whoosh in the sound bed). The anticipation gather in principles.md section 6 is its visual wind-up. This also serves his rule that every attack answers block, parry and dodge.

## 3. Trail colour from one hue; two trails for contrast (FRGFX, Shannon McSheehan)

FRGFX: you don't really need a palette, only an understanding of how colours relate. Pick a base colour and derive the others by varying S or V (HSV). The most intense piece of the trail has the highest V (it can go above 1.0) and the least intense a much lower V, which gives a gradient. He later judged the poster's result "a little saturated for an ice effect".

Riot artist Shannon McSheehan's trail rules: widen the trail over its lifetime to mimic a wake, and shorten the UV tile with it so detail drops as it ages. The texture must make sense for its flow direction. Spawn two trails with the same UV tile, one additive and one subtractive or alpha blended, and give the alpha trail a shorter lifetime to keep the contrast at the head. Scroll fast at first, then slow, to read as energy dissipating. For a ribbon look, keep the texture's highest values at its edges.

Roblox translation:
- Build tail and Trail ColorSequences from one palette hue with `Color3.fromHSV`: the same H, V falling from the most intense end to the least, S rising slightly toward the faint end. This matches the skill's one-dominant-hue palette.
- A Trail maps Color over segment age, so keypoint 0 is the head end. FRGFX does not name the end; for a projectile, the head is the intense end.
- An ice projectile runs paler and less saturated than fire or electric ones.
- Two Trails on the same attachment pair with the same texture. The glow Trail has LightEmission 1. The dark Trail has LightEmission 0 (normal blending; Roblox has no subtractive mode), the deep colour, and a shorter Lifetime.
- His taste limits the dark Trail: a dark trail under a fast blade drew big dark smears (taste.md, Ice Blade). Use it on slower projectiles, never on fast blades, and judge it in a capture.
- For a wake, the width grows toward the old end: attachments at the full width and WidthScale rising from a small value to 1 over the age. A dash streak tapers the other way (movement-fx.md section 2).
- Wind lines and swing ribbons follow the same rule: a ribbon that widens, thins and slows as it ages reads as air dissipating.
- On a Beam ribbon, step TextureSpeed down over the effect with `Tw.play`.
- Painted strips for a ribbon look put the brightest values on the edges.

## 4. Beam geometry, texture modes and blending (creator-docs Beam, TextureMode)

A Beam is a cubic Bezier curve. P0 is at Attachment0 and P3 at Attachment1. P1 sits CurveSize0 studs along Attachment0's positive X axis, and P2 sits CurveSize1 studs along Attachment1's negative X axis. `Segments` (default 10) is the number of straight pieces; a beam needs at least n - 1 segments for n Color or Transparency keypoints. Width0 and Width1 are studs at each end, interpolated linearly. FaceCamera makes the segments always face the camera.

`TextureMode` on a Beam: Wrap repeats the texture (length in studs / TextureLength) times, so the texture density stays constant as the beam changes length. Stretch repeats it exactly TextureLength times across the whole length, so the texture stretches with the beam. Static is not supported on Beam and behaves exactly like Wrap.

`TextureSpeed` is in cycles per second (default 1): positive moves the texture from Attachment0 to Attachment1, negative reverses it, 0 is static. `SetTextureOffset` sets the cycle offset (0 to 1, wrapping), and 0 resets it. `LightEmission` 0 is normal blending and 1 is additive; it does not make the beam light the environment. `LightInfluence` 0 ignores scene lighting and 1 is lit like a part. `Brightness` (default 1, range 0 to 10000) scales the emitted light only when LightInfluence is below 1. `ZOffset` shifts the beam in studs toward the camera and is meant to stop Z-fighting between beams that share the same attachments.

Roblox translation:
- To bend a beam (an arcing bolt, a homing lance, a torrent), point Attachment0's X axis along the launch tangent and Attachment1's X axis along the arrival direction, then set CurveSize in studs.
- A beam that tapers in at the source (his "a beam must grow out of its source") has 3 to 4 Transparency keypoints, so Segments must be at least 2 to 3. Segments = 1 samples only the ends (ambient.md).
- Scale Segments with length and curvature: 3 to 10 per water.md, at about 1.5 ms per 100 beams at Segments 10.
- A beam that extends from caster to target over time (a laser, a lance, a bolt) uses Wrap, so its stripes do not smear as Attachment1 moves out.
- A single shaped image that must fit end to end (a painted bolt, a lance head, a feather) uses Stretch with TextureLength 1 and TextureSpeed 0 (textures.md: the speed default is 1).
- Layered beams on one attachment pair: a wide glow at ZOffset 0, then the body, then a narrow pale core at the highest ZOffset. Beam ZOffset also changes the beam's screen size (textures.md), so keep the steps small.
- Push a glow with Brightness above 1 only together with a LightInfluence below 1. The volcano uses Brightness 8 and 20 with LightInfluence 0 (section 5, section 8).
- A beam never lights the scene. Add a PointLight at the head or the source.
- Point Attachment0 at the caster so a positive TextureSpeed flows toward the target, and call `SetTextureOffset(0)` on cast so every cast starts the same.

## 5. Layered and extending beams (Roblox Creator Hub, Real Time VFX)

Roblox's volcano tutorial builds the lava flow from three beams on one path. The magma base: width 50, CurveSize0 -50, CurveSize1 5, LightEmission 1, LightInfluence 0, Brightness 8, colour 255, 51, 0 to 211, 39, 0 to 118, 24, 0 along its length (cooling), and transparency 1 at 0, 0 by 0.09, 0 to 0.867, 0.725 at 0.941 and 1 at 1. Two crust beams share one texture: widths 35 to 25 and 25 to 35, TextureSpeed 0.01 and -0.008, TextureLength 3 and 2, attachments flipped, ZOffset 1 and 2, "so the textures never have the opportunity to fully line up".

On Real Time VFX, extending bolt and beam effects are generally meshes extended by code, with the ratio of current to base length added to the UVs so the texture does not stretch (Luos_83). Detail comes from extra noise and emissive layering on a high-resolution texture. A precisely shaped bolt is easier as a few hand-drawn frames on a flat mesh that UV-scroll a bit and switch between random frames (kuba_kuleszewicz), because ribbons make precise shapes very hard. The outer glow can be a flat mesh or sprite rendered behind a more cylindrical white core (Travis).

Roblox translation:
- Recipe for any sustained beam (a laser, fire breath, an energy torrent): an additive base beam with a colour ramp along its length and a transparency curve that fades in at both ends. Over it, two layers that share one texture and scroll at different speeds in opposite directions, with different TextureLength and stepped ZOffset, so the pattern never visibly repeats.
- The fade-in keyframes at the source are his "a beam must grow out of its source". The colour cooling along the length is the trail value gradient of section 3.
- In Roblox the length-ratio trick is free: TextureMode Wrap, with Attachment1 tweened out from the source over the extend time.
- For a shaped bolt, swap the Beam's Texture every few frames among pack bolt images, with a small TextureSpeed. He wants pack art over hand-painted elements (taste.md), so the frames come from his packs.
- Stack a narrow pale core beam (highest ZOffset) inside a wider, softer glow beam: the core and glow pair that the "too geometric" fix already uses.

## 6. Render projectiles on the clients; validate on the server (DevForum, FastCast)

Affenity's answer on projectile replication: the shooting client renders its projectile immediately, because waiting for the server shows a delay ("wait .5 seconds" before the bullet appears). It then tells the server, which checks the hit when it receives the fire event, applies damage and notifies the other clients. Those clients render it or not depending on distance, whether it is in the viewport, and their quality settings. The shooter ignores the server's projectile event for its own shot.

FastCast splits the path from start to goal into many small pieces and fires the next cast each Heartbeat. Under lag, the cast moves as far as it would have with no lag. Gravity defaults to 0 (straight shots). The example uses speed 1600, max distance 1000 and gravity 5 against the game's default 196.2. `LengthChanged` is where a tracer part's CFrame is updated. The author states there is no compensation for network latency. FastCast addresses bullet lag, jittering or teleporting, and the Touched event not firing.

Roblox translation:
- The visual head, tail and trail are built only on clients, from templates pre-warmed at join (the summon's warm-up rule).
- The server keeps an invisible cast for validation and damage only and never parents a visual part.
- The server's RemoteEvent to the others carries the caster, the origin, the direction and the cast time. Each client skips the render when the shot is far or off-screen. The caster does not re-render its own echo.
- Run the same FastCast, or the same per-Heartbeat raycast stepping, twice: on the server with no visual, and on each client with the head carrier moved in `LengthChanged`.
- Never use unanchored physics parts with Touched for abilities.
- Latency is the game's job; FastCast does not handle it.
- Give arcing elements (fire bombs, thrown rocks) an acceleration, because gravity is 0 by default.

## 7. Lightning: midpoint bolts, a flicker rhythm, a cut instead of a fade (drilian, Real Time VFX)

Michael Hoffman's midpoint displacement bolt: take each segment's midpoint, offset it perpendicular by a random amount up to offsetAmount, and split the segment in two. Halve offsetAmount each generation; his illustrations use five. For branches, a split occasionally adds a third segment from the midpoint, roughly in the original direction rotated by a small random angle, with a length scale of about 0.7, subdivided like the rest. Branches are dimmer, since only the main bolt connects to the target. To animate, alternate two bolts half a cycle apart and jitter every point slightly each frame. Overlapping glow quads made bright dots at the joints.

Cel's critique of a lightning strike: it needs anticipation before the bolt appears, and the whole effect should be faster (it looked better at 2x speed). Do not fade lightning out, because "lightning flashes". The big bolt needs motion from a flipbook or UV distortion. The ground impact mark could scale so it bounces out of existence (vaxkun: squash and stretch).

njhc on lightning rhythm: "a one, two punch combo. Ie : Strike, pause, pop, pop, pause, pause, pop, pop." The silhouettes read quickly, while the reviewed effect felt noisy, "like it's fizzling". Stefan_Jevremovic: when lightning disappears, it usually goes by erosion of particles, not by scrolling.

Timing notes on another stylized strike: the effect ran close to 1.9 s, and Travis suggested about 0.75 s. Sirhaian suggested shortening the impact burst to just a few frames. smou suggested a delay of about 0.1 to 0.15 s on an impact element and said a blank frame adds dynamic and punch. Feanix: lightning stays fairly fixed once it anchors itself, and swapping the mesh once or twice at the start gives flickering energy. Doggett: it needs a big flash or glow and a thicker, brighter bolt.

Roblox translation:
- The ultimate's `bolt` helper (six jittered attachments joined by FaceCamera Beams) is one level of noise. A better bolt is 3 to 4 generations of midpoint displacement (8 to 16 straight pieces), with the first offset about a fifth of the span, halved each generation.
- Use one Beam per piece with Segments = 1, each piece sharing its end attachment with the next so the joints meet. SKILL.md found that a chain of FaceCamera beams shows wedge gaps and overlaps at every joint, and drilian saw bright dots there. Check the joints in a capture; if they show, use the SKILL.md joint method (FaceCamera off, each joint attachment's CFrame written every frame).
- Branches start at random midpoints with a length of 0.7 of the remainder, a thinner Width and a higher Transparency.
- Drive a strike or an arc with an explicit flicker schedule, not continuous jitter: strike (a new bolt), off, pop, pop, off, off, pop, pop. Each step lasts 1 to 3 frames at 60 fps; the impact frames already use 0.05 s steps. Each pop draws a new random bolt.
- Re-rolling every point every frame is the fizzle. For a sustained arc, alternate two bolts and re-roll the pair.
- The bolt holds its anchor points between pops; it is not dragged around.
- The bolt Beams leave by a cut: Transparency to 1 within one frame, or a quick width collapse, never a long tween. The ease-out rule in principles.md applies to the glow, the light and the scorch, not to the bolt.
- Exit with the last bolt breaking into spark particles (a short `Emit` along its points), not with the texture scrolling away.
- The anticipation is a crackle gather 0.2 to 0.6 s before the strike: the kit's `Lightning` pops at small scale and a rising light.
- Try one blank frame in the flicker. The source does not say where; test it just before the main strike.
- The impact flash lasts a few frames, with a big glow and a light spike. The impact decal or ring scales out with a small overshoot instead of fading.
- A lightning move's strike phase is about 0.75 s on the move rung. Cinematic ultimates may run longer in waves, by his request.
- Lightning is an identity choice. On Asta he said "definitely not electric" (taste.md): use it only where the character's vocabulary calls for it.

## 8. Elements: fire, earth and colour language (VFX Apprentice, Roblox Creator Hub, Real Time VFX, DevForum)

Daniélle Viljoen (VFX Apprentice) on stylized fire: fire has a strong base and thins and tapers as it flows up. Block the shape with an S-swoop for the wind, cut C-shapes out of the outline so it "doesn't look like a glob of toothpaste", use hooks for sharper points, and vary the sizes of the hooks and C-shapes. Keep the edges imprecise with some wobble. Heat rises, and wind gusts of varying strength make flames dance back and forth, which gives the flicker.

Roblox's volcano embers: VelocityParallel; Squash -3 at birth, relaxing to -0.188 at 0.32 and -0.5 at the end; size 0.313 to 0; lifetime 1 to 5 s; speed 5 to 8; spread 180, 180; Acceleration 0, 10, 0 (rising); Drag 0.8; LightEmission 1, LightInfluence 0, Brightness 20; colour 130, 53, 2 to 224, 82, 0 to 147, 5, 0. Its smoke: black, then warm-lit 195, 104, 76 and 225, 121, 86 at 0.37 to 0.47 of life, then grey 111; Acceleration 0, 7, 0; Drag 1; LightEmission 0.1; LightInfluence 0.06; ZOffset -10.

An earth projectile critique (Ryan and William_Mauritzen): for anticipation, cracks form in the ground or pebbles levitate and shake. The rock is "fighting its way out of the ground", and that struggle should carry on after it breaks free. The rock should not be a perfect sphere. Falling debris needs an acceleration on top of its initial velocity and should scale down near the end of its life "so it's not just popping out". Dust should look dirtier, linger longer and be left behind spreading on the ground, not puff and cut through the surface. The impact could use some bounce.

The Bezier Debris module is client-side visuals only, required from a LocalScript. Rocks spawn coloured and textured to match the ground of origin, arc through the air on a Bezier curve, and raycast to find where they will actually land. A landing triggers smoke and a sound chosen by what they hit. Its custom preset example: RockCount 12, RockSizeRange 1 to 2, HeightRange 15 to 20, DurationRange 0.6 to 0.9 s.

VFX Apprentice's Genshin Impact breakdown: strict, high-contrast colour separates the elements (vibrant Pyro oranges, sharp neon Electro purples), with hard-edged, vector-like silhouettes instead of soft gradients. Diluc's fire trails are hard-edged, jagged vector shapes layered on top of each other. Raiden's ultimate uses a flat, unlit ribbon with an emissive panning noise texture and desaturates the screen except for her and her glowing eye trails. Ayato's Hydro slashes are distorted crescent meshes with the tail stretched backward to suggest speed.

Roblox translation:
- Fire comes from Toolbox pack flipbooks, not hand-painted sprites (taste.md, 2026-10-10). Use Viljoen's shape rules as the test for choosing and tuning pack fire: a wide base, tapering, hooked tongues, no round blobs (his "no round glows in the centre").
- Spawn pack fire from a Box part over the base. Keep the upward speed slow: fast tongues stretched the fire into a column (textures.md).
- Give fire sideways gusts rather than a steady sway: a varying X/Z Acceleration, or WindAffectsDrag, which follows GlobalWind only while Drag is above 0 (engine-and-performance.md section 4).
- Fire move embers: VelocityParallel with Squash starting near -3 (the streak at launch) and relaxing, an upward Acceleration with Drag about 0.8, LightEmission 1 and LightInfluence 0, with Brightness above 1 for the hot pops.
- Shorten the ember life to the move rung: up to 2 s (principles.md). The 1 to 5 s is a landmark volcano.
- Fire smoke tints warm in mid-life where the fire lights it, sits behind the flames with a negative ZOffset (principles.md section 9), and keeps a low LightInfluence so it stays dark against the glow.
- Earth pillar or boulder: the anticipation window (0.2 to 0.6 s on a move) shows a `flatCrack` on `groundBelow` and a few pebbles hovering with a noise shake before the rise.
- The rock is a real rock mesh at random turns (taste.md), never a sphere. Do not use the kit's "rock" meshes 3027924097, 1254390558 and 4933939521: SKILL.md says they are faceted spiky shapes and must never be debris.
- The rock rises with an overshoot and a jitter, not a clean tween. Debris Size curves end at 0.
- Ground dust spreads flat as a ring and lingers 2 to 5 s at low opacity: the permanence rule. Tint it from the floor (SKILL.md: dark dust on a pale floor reads as soot).
- Earth debris for a heavy move, on each client: read Material and Color from the `groundBelow` raycast and copy them onto the rocks. About 12 rocks of 1 to 2 studs on Bezier arcs 15 to 20 studs high over 0.6 to 0.9 s, each landing point raycast, with a dust puff there.
- Scale the rock counts and sizes by the tone ladder: a light hit fewer and smaller, an ultimate in waves.
- Each element owns one hue family, so a player can tell the hit type at a glance: fire orange, electric neon violet or cyan, ice pale and desaturated, earth a grey-brown with no glow.
- The skill's palette rules still apply on top: one dominant hue plus an accent per character, and the vocabulary comes from the character's identity.
- Hard-edged shapes come from pack sprites and crescent meshes at 0.35+ transparency with a soft partner, never clean Neon solids ("too geometric").
- A desaturated world around the caster is already in his toolkit: the time stop's `TimeStopCC`.

## Where the sources and his taste disagree

- Viljoen's hand-drawn fire shapes. His rule wins: fire comes from pack flipbooks, and the shape rules only guide the choice.
- kuba_kuleszewicz's hand-drawn bolt frames. Pack bolt images replace them.
- The researcher's suggestion of the kit's rock meshes for earth. SKILL.md says those meshes are spiky shapes, never debris; a real rock mesh replaces them.
- Shannon McSheehan's dark second trail. His Ice Blade trap (a dark trail under a fast blade draws dark smears) limits it to slower projectiles.
- Genshin's hard-edged vector shapes. They need a soft partner and 0.35+ transparency under his "too geometric" rule.
- The 1 to 5 s volcano embers. The move rung caps embers at about 2 s.
- Travis's 0.75 s strike. It holds for the move rung; cinematic ultimates run longer by his request.

## Not covered

- Ice element shape language (shards, frost rings, crystal growth timing). No primary source with specifics was found; the only ice source fetched (Real Time VFX, UE4 Ice Projectile Magic) gives colour advice only.
- Wind lines. No dedicated breakdown was fetched; a search for stylized wind-line ribbons found nothing beyond Shannon McSheehan's trail dissipation tips (section 3).
- Exact lightning flicker frame counts. None of the fetched Real Time VFX lightning threads (9607, 3936, 1972) give frame numbers, only the rhythm and durations in seconds.
- FastCast documentation on networking (server against client simulation, replicating cosmetic bullets). The API docs index and the FastCastBehavior page do not cover it; FastCastBehavior only says CosmeticBulletProvider needs PartCache and is recommended for many bullets.
- Quasiduck's Lightning Beams v1.1 (DevForum 843534) properties and defaults. The post points to a GitHub API page that was not found. It says only that the module uses layered moving Perlin noise, can follow a Bezier curve, is client-only and uses PartCache.
- SecureCast (server-authoritative projectiles with lag compensation). Only an archived-link mention was found; the thread was not fetched.
- Example values in the creator-docs beams guide (effects/beams.md). It has no TextureSpeed, LightEmission, ZOffset or laser and lightning values, only Width0 0.5, Width1 3 and the curve and mode diagrams.
- Roblox's "Create laser beams with VFX" tutorial. It is a single-layer hazard beam (texture 6060542021, LightEmission 0.5, Width 4 and 4, TextureSpeed 2, FaceCamera) with no layering, caps, taper or particles. It was left out because it breaks his "a beam must grow out of its source" rule.
- Crater Module V1.0 (DevForum 2648456). It lists property names but no numbers; the only usable detail is a commenter's suggestion to fade rocks to transparency 1 before destroying them.
- VFX Apprentice, "Everything to Know About the Properties of Fire FX". General only (hotter flames bluish, several sprite frames for flicker, fire and smoke layered with varied size and opacity); no core and edge values, no ember or smoke specifics.
- Real Time VFX, "[Breakdown] Stylized Energy Beam" (21866). Short: only vertex-painted fades at both ends of the beam mesh and an inner duplicate with a lower alpha clip for a solid core; no widths, speeds or colours.

## Sources

- Kodeco (Ray Wenderlich), "VFX in Unity: Getting Started", pages 2 to 4, https://www.kodeco.com/23120977-vfx-in-unity-getting-started?page=3 (also ?page=2 and ?page=4) - head and tail, the three cast elements, the dark secondary tail and stretched sparks (section 1).
- Unreal Community Wiki, "Projectile Visual Effects", https://unrealcommunity.wiki/projectile-visual-effects-900bey6t - the three impact criteria and the hit, dust and debris values (section 1).
- "How to properly end a trail when a projectile hits?", Real Time VFX (2023), https://realtimevfx.com/t/how-to-properly-end-a-trail-when-a-projectile-hits/23571 - stopping the ribbon spawn on hit (section 2).
- Riot Games (bananaband1t), "Clarity in League" (2021-03-12), https://www.leagueoflegends.com/en-gb/news/dev/clarity-in-league/ - direction in a still frame, hitbox match, attention matching importance (section 2).
- FRGFX, feedback in "UE4 - Ice Projectile Magic", Real Time VFX (2022), https://realtimevfx.com/t/ue4-ice-projectile-magic/18884 - deriving trail colours by S and V (section 3).
- Shannon McSheehan, "LoL FX + Knowledge Share", post 300, Real Time VFX (2020-08-12), https://realtimevfx.com/t/shannon-mcsheehan-lol-fx-knowledge-share/1133/300 - widening wakes, two trails, fast-then-slow scroll, bright edges (section 3).
- Roblox creator-docs, Beam class reference, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Beam.yaml - the Bezier curve, Segments, TextureSpeed, blending, Brightness and ZOffset (section 4).
- Roblox creator-docs, TextureMode enum reference, https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/enums/TextureMode.yaml - Wrap, Stretch and Static on Beams and Trails (sections 2 and 4).
- Roblox Creator Hub, "Create volcanic eruptions with VFX", https://create.roblox.com/docs/tutorials/use-case-tutorials/vfx/create-volcanoes - the three-beam lava flow and the ember and smoke values (sections 5 and 8).
- "How are extending bolt/beam effects made?", Real Time VFX, replies by Luos_83, kuba_kuleszewicz and Travis, https://realtimevfx.com/t/how-are-extending-bolt-beam-effects-made/11834 - extending meshes, hand-drawn bolt frames, the core and glow pair (section 5).
- Affenity, answer in "Projectile Replication", Roblox DevForum (2019), https://devforum.roblox.com/t/projectile-replication/312021 - the client-first replication pattern (section 6).
- Xan_TheDragon (EtiTheSpirit), "Making a combat game with ranged weapons? FastCast may be the module for you!", Roblox DevForum, https://devforum.roblox.com/t/making-a-combat-game-with-ranged-weapons-fastcast-may-be-the-module-for-you/133474 - stepped casts, default gravity, LengthChanged, no latency compensation (section 6).
- Michael Hoffman (drilian), "Lightning Bolts" (2009), http://drilian.com/2009/02/25/lightning-bolts/ - midpoint displacement, branches, alternating bolts (section 7).
- "[UE4] Lightning Strike - Looking for feedback", Real Time VFX (2019), https://realtimevfx.com/t/ue4-lightning-strike-looking-for-feedback/9607 - anticipation, no fade, a bouncing impact mark (section 7).
- njhc and Stefan_Jevremovic, "Lightning vfx WIP", Real Time VFX (2018), https://realtimevfx.com/t/lightning-vfx-wip/3936 - the strike-pause-pop rhythm and particle erosion (section 7).
- "Lightning Strike! (stylized) what do you guys think? (Update)", Real Time VFX, https://realtimevfx.com/t/lightning-strike-stylized-what-do-you-guys-think-update/1972 - 0.75 s, a few-frame burst, the blank frame, anchored bolts (section 7).
- VFX Apprentice, "How to Draw Stylized Fire and Flames for Animation and 2D FX", https://www.vfxapprentice.com/blog/how-to-draw-stylized-fire-flames - the fire shape rules (section 8).
- Ryan and William_Mauritzen, feedback in "Earth projectile", Real Time VFX, https://realtimevfx.com/t/earth-projectile/7204 - earth anticipation, the struggling rock, debris and dust (section 8).
- "Bezier Debris 1.0", Roblox DevForum, https://devforum.roblox.com/t/bezier-debris-10/4755754 - ground-matched rocks on Bezier arcs and its preset (section 8).
- VFX Apprentice, "Genshin Impact VFX Breakdown: Stylized Technical Art Guide" (2026-09-18), https://www.vfxapprentice.com/blog/genshin-impact-stylized-vfx-breakdown - element colour separation and hard-edged shapes (section 8).
