# Skinned bone rigs animated in Blender

Use this file when the character is not a Motor6D R6 rig but a skinned mesh with Bones (an Import 3D model from a team's .blend), and the clips are authored in Blender and converted to KeyframeSequences. It comes from the UT:EF Chara kit (2026-10-03): the first pass was called "super buggy, unnatural, and just isn't as cool as i expected"; the second pass rebuilt every clip with the method below.

## What made the first pass look buggy (measured)

| Fault | Cause | Number |
| --- | --- | --- |
| Shoulders swung like wings | The posing helper treated the collarbone (`Arm_R`, parent of the upper arm) as the upper arm | Collarbones turned 55 to 117 degrees; the team's own clips turn them 15 to 44 |
| Straight, stiff arms | The upper arm and the forearm were aimed in the same direction | Elbow bend 0 degrees in every pose |
| The knife twisted in the hand | The knife bone was aimed on its own instead of riding the fist | Up to 153 degrees between the knife and the hand |
| Reviewed from the wrong side | The "Player" camera of the render script stood in front of the character | Every review frame showed the face, not the back |
| A dead end on a copied clip | The source clip held an arm-out rest pose for its last 0.6 s | Still frames at the end of the move |

Before any posing, dump the rest bones (head, tail, length, parent, local X and Z axes) and find which bone is the collarbone, the upper arm, the forearm, the hand and any held prop. Bone names lie: `Arm_R` was the collarbone, `Arm_R.001` the upper arm, `Arm_R.003` the forearm, `Arm_R.002` the hand, `Arm_R.004` the knife.

## The solver (scripts/blender/pose3.py)

A pose is a dictionary of channels, not bone rotations. The solver turns it into bone bases with its own forward kinematics (no scene update per bone), so a 60 Hz bake of a 1 s clip takes seconds.

| Channel | Meaning |
| --- | --- |
| `hip` | Hip offset from rest (Blender units) |
| `pel`, `sp`, `ch`, `nk`, `hd` | Pelvis, spine, chest, neck, head as (yaw, pitch, roll) degrees, each relative to the bone below; yaw + turns left, pitch + leans forward, roll + drops the right shoulder |
| `cR`, `cL` | Collarbone (raise, forward, twist), small: 0 to 20 degrees |
| `aR`, `aL` | Arm as (direction from the shoulder to the wrist, extension 0 to 1 of the arm length), in the chest frame |
| `eR`, `eL` | Elbow pole: where the elbow points |
| `tR`, `tL` | Thumb direction; for the knife hand this is the blade direction |
| `gR`, `gL` | Knuckle direction hint, or None for the least wrist bend |
| `fR`, `fL` | Frame weight: 1 = the vectors are in the chest frame, 0 = world; the bake converts every key to the chest frame |
| `oR`, `oL` | Hand open 0 (fist from the idle) to 1 (rest hand) |
| `footR`, `footL` | IK target of the foot (x, y, z, yaw, pitch); planted feet are planted because the target does not move |

- The arm is a two-bone IK: the elbow sits in the plane of the shoulder, the wrist target and the pole; the upper arm and the forearm frames map the rest hinge onto the new hinge, so the elbow always bends the right way.
- The hand comes from the blade direction: the grip of the idle stays fixed in the hand, and the roll about the blade is chosen for the least wrist bend. 60% of the remaining twist goes into the forearm roll (pronation), so the wrist never shows a candy wrapper.
- Keep the blade square to the forearm. Six first-pass keys pointed the blade along the arm and bent the wrist 70 to 105 degrees; the bake prints `wristR` and the time of the worst frame.
- Arms of a chibi rig are short (0.61 units from the shoulder to the wrist on Chara). A hand cannot reach the far shoulder, so a self-hug from an MMD reference becomes a forearm across the chest with the fist at the near-centre; say so in the report.
- The team's idle had the legs already 1.2% past their reach and location keys on the left arm bones (a stretched arm). Drop the hips 0.05 to 0.1 for any lunge or step, and start and end each clip with `ends=(0.1, 0.12)`, which blends the first and last frames to the exact idle bases.

## Keys, curves and layers

- Channels are cubic Hermite curves with auto tangents that go flat only where a channel turns round; a key after another key's time keeps its speed through it.
- `lag` delays a whole channel (seconds): hips lead, `sp` 0.01, `ch` 0.02, the free arm 0.03 to 0.04, the blade 0.017 behind the striking hand. Do not lag the striking arm.
- A hold is two keys that keep travelling, or a settle that overshoots and returns with the parts at different times; a flat hold of all joints made the first follow-through read as a still.
- Hair bones get a verlet spring after the solve, with a 10 to 18 degree limit: without the limit, a fast torso turn threw the hair locks out of the head.
- A vine or a tail is a chain with a spring per segment on top of the keyed directions (a whip wave). Bone translations along the chain grow, fold and stretch it (Roblox Bones take position keys); 1.4 to 1.7 times the rest length still read as a vine.
- A conjured limb that replaces an arm: keep the real arm straight inside the first segment and turn the hand so the held prop lies along the second segment; fold the chain back and hide it before the arm leaves it.

## Measure

`metrics(name)` samples the baked action at 60 Hz on 17 joints (the spine, the collarbones, both arm chains, both leg chains). The ranges in motion-metrics.md were made on six R6 joints, so stops per second read about three times higher here and every clip that starts and ends at the idle adds two rests per joint; judge stops by where they fall (`STOPS` prints the runs), not by the total. The Chara pass ended at still 0 to 3%, rest 26 to 49%, contrast 2.2 to 3.9.

## Review renders

- `rtools.py` sets Workbench, a floor and cameras. The player camera stands behind the character and 18 degrees to its right; straight behind, a knife in front of the body never shows.
- Dark props vanish against a dark floor in the preview: the preview paints the knife red and the vine bright green (preview only, the .blend keeps its materials). Say that in the report.
- `video_render.py` renders one player-camera video per move at 30 fps (the last 0.3 s of the idle loop, the move, 0.35 s of idle); encode with `encode.html` from scripts/video.
