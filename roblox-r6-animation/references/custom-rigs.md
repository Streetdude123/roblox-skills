# Custom creature rigs (quadrupeds)

Learned on Verix (Vesna place, 2026-09-27): a small four-legged creature with MainTorso, Neck, Head, Jaw, two ears, two front legs (`LeftArm`, `RightArm`) and ONE `LeftLeg` block that holds both hind feet. Poser works on any Motor6D rig because it keys joints by `Part1.Name`; `Feet.lua` and `EditStrip.lua` are R6-only. `scripts/QuadRig.lua` and `scripts/QuadClips.lua` are the tested example; copy and adapt the leg names and the floor.

## Before any clip

- Read every joint: `C0`, `C1`, the parent, the part size and the welded decoration parts. Compute the rest sole of each leg in root space and the floor height (Verix: floor at root y -1.642, front legs 1.544 from pivot to sole, hind block 1.399).
- A Humanoid with RigType R6 and no R6 leg parts sits in Freefall. Set RigType R15 and HipHeight (root bottom to floor), and switch collision off on every part but the root, decorations included.

## The foot solver (QuadRig)

- Each leg is a rigid box. `solveLeg` aims the leg at a sole target with lift and side only, and slides it along its own axis up into the torso to shorten it (clamped by `tuck`). It never lengthens a leg.
- The corner raise runs on every solve, swing included: the sole centre goes up until the LOWEST corner of the leg group (decorations counted) is on the target height. Without it a swing foot near lift-off went 0.16 into the floor.
- A rigid box leg at 31 degrees touches with its heel corner and the sole centre sits 0.18 up, so the needed body drop is small (0.04 on the Verix walk). That is correct, not a bug.
- Stance feet move with the ground in root space: straight `(0, 0, v)`, turning `(-w z, 0, v + w x)` (rotation about the turn centre at `x = -v / w`). Swing is a Hermite whose end speeds equal the ground speed, so the foot lifts moving back and lands moving back.
- The torso drop is found per frame for the front and hind girdles, then smoothed upward (the envelope never goes under the need), and applied as a drop plus a pitch. Authored torso keys ride on top.

## Gait numbers that read well on Verix

| Clip | Cycle | Speed | Legs (phase, duty, swing height) |
| --- | --- | --- | --- |
| Walk | 0.40 s | 8 | fronts 0 / 0.5, duty 0.45, h 0.2; hind block 0.22, duty 0.42, h 0.18 |
| Sprint (half-bound) | 0.34 s | 20 | hind 0, duty 0.24, h 0.5, 0.3 forward; fronts 0.42 / 0.50, duty 0.24, h 0.55 |
| Pivot | 0.40 s | 8 at 240 deg/s | as the walk, turning flow; mirror for the other side |
| Crouch | 1.00 s | 1.3 | fronts 0 / 0.5, duty 0.7, h 0.16; hind 0.25, duty 0.68; body -0.45 |

A front swing of 0.32 read as a prance from the side; 0.2 read as a walk. Measured: walk rest 0%, contrast 1.2, feet within 0.004 of the floor, slide 0.13 to 0.69 studs/s.

## Baking loops

- Bake with a warm-up of one loop (`Poser.bake(clip, rig, 60, name, clip.length, clip.length)`) so springs (ears) are in their steady cycle at the seam.
- `life` on a loop now samples noise on a circle of the loop length, so a baked loop has no jump at the wrap.
- Set `Weight = 0` on every pose whose joint the clip does not key (the Animation Editor does the same). A neck-only Bite then layers over a walk instead of pinning the torso.

## Get-up from a physics ragdoll

- The clip starts from a pose close to a collapse: the torso low, the head down, the legs lying flat. Rigid legs whose hooves sit forward of the leg cannot fold backward under the chest (the hooves dug 0.46 into the floor); a sphinx pose with the front legs forward works. `GetUp` in QuadClips: head first, the front feet step back under the shoulders and the chest rises, then the hind block steps back under the hips, a small head shake, 1.13 s. Checks: rest 37%, contrast 3.9, feet within 0.08.
- The joints come back where the ragdoll left them only if code holds them: capture every Motor6D's Part0 and Part1 CFrame when `Downed` clears, hold `C0:Inverse() * Part0:Inverse() * Part1 * C1` in PreSimulation (root joint against the current root CFrame) and lerp into the Animator's pose, which reads back in PreSimulation. Stand the root upright at hip height in `PreAnimation` on the owning client first, or the Humanoid's lift during the step pops the body 0.36 studs. Measured worst rendered frame 2.8 degrees and 0.053 studs.

## Momentum for a Humanoid creature

The Humanoid reaches any WalkSpeed at once and `Move(Vector3.zero)` brakes in one frame. Keep a speed variable, ramp it (Verix: 16 up, 14 down, studs/s2, about 4.5 and 3.9 m/s2), keep calling `Move(heading)` while it coasts, cap it at the real speed plus 1 so a wall takes the momentum, and pick the gait clip from the speed, not from the keys. The clips then play through the coast at speed divided by their authored speed.

## Pivot means turning in place

A pivot that walks a tight arc reads as "it kinda just walks in a circle" (Corvid, 2026-09-27). The turn centre must be the animal: creep at 0.5 studs/s so AutoRotate still turns the body (radius about 0.16 studs), rotate the heading with angular momentum (accelerate at 720 deg/s2 toward `min(top, sqrt(2 * accel * remaining))`, so it eases in and stops on the heading, never instantly), and bake the pivot clips with the ground flow at v 0.5 and the pivot rate so the feet step around the body. When the player asks for a direction behind while walking, brake harder than a coast (28 against 14 studs/s2), then pivot; a running animal never pivots and turns on its radius; the walking trigger angle is wider than the standing one (135 against 90 degrees). Mesozoico footage shows the head and front leading, the body curving behind, about 150 deg/s with eased starts and stops.

## Limits seen

- A 1.4 stud rigid hind block cannot fold under a sitting body: with the rump on the floor the block is 0.1 to 0.2 under it. The sit that fits pitches the torso 38 and plants the block at an angle under the belly; its top shows through the rump.
- The ragdoll get-up snaps in one frame without a clip.

## Moving clips between two rigs of one model

Verix came back from the designer rigged again (2026-09-30): the same parts at the same places, but a `Core` joint under the root, arms and hind block hung from `Core`, part frames turned 90 degrees about X and new names (`Arm.L`, `Leg`, `Ear.R`). A clip keys joints by `Part1.Name` in joint space, so the old clips play nothing on the new rig. Check first that it is the same model: every welded decoration part sat 0.0067 studs off its twin relative to the root on both rigs (compare parts of equal size, not names).

The exact transfer (`scripts/RigTransfer.lua`): for each frame, run forward kinematics on the old rig with the old poses, take each old part's root-space CFrame, multiply by the rest offset `oldRest^-1 * newRest` of the matching new part, then solve the new rig top down with `T = C0^-1 * parentRel^-1 * target * C1`. A new joint with no old twin (`Core`) follows the old part it replaces. Pivots may differ, so `T` may carry a translation; that is correct. Worst error 0.00001 studs in the math and 0.0007 on the played Animator pose. An overlay clip (Weight 0 on the parents) transfers with the parents at rest and only the keyed joints weighted. Raise the new root by the rest offset (HipHeight + 0.0067 on Verix) so the feet stay on the floor. The authoring tools (QuadRig, Poser) keep working on the old rig; author there and transfer.

## Crouch walk (Verix, 2026-09-30)

Crouch speed 3 studs/s. The first cut (0.7 s, drop 0.45, duty 0.68) swung the legs -44 to +54 degrees and read as a crawl; the kept one is 0.6 s, drop 0.36, duty 0.66, lift 0.18 with `early` 0.7: legs -35 to +42, frozen 0, rest 1.8%, contrast 1.4, feet within 0.02 of the floor, planted slide 0.000. The head counters the torso sway on its own frames so the face stays level (a stalk). The game pauses it (speed 0) when the body stops, so every frame must read as a crouch.

## Movement lessons from the same pass

- Humanoid AutoRotate trails the move direction by about 0.12 s, and an eased turn with angular acceleration a trails a turning camera by w^2 / 2a (measured 16.7 degrees at 90 deg/s and 45 at 180 before the fix). Feed the camera's own yaw step into the heading (capped at the turn rate), rotate the input by the same step (it is one frame stale), and set the root facing yourself with AutoRotate off: 0.00 degrees after.
- Lean into a turn from physics: `atan(speed * yawRate / gravity)`, times how far the speed is between walk and run, clamped (12 degrees); pivot about the floor under the root. Measured 9.0 degrees at 20 studs/s and 90 deg/s (the formula gives 9.1).
- Terrain alignment: four rays (front, back, left, right of the root) give pitch and roll; rotate the root joint about the floor point under the root. Mean 21 degrees on a 20 degree ramp with the walk's own pitch on top.
- A clip's first play waits for its asset download (1.2 to 1.6 s measured on the sit clips); `ContentProvider:PreloadAsync` on the Animation objects at spawn removes it.
