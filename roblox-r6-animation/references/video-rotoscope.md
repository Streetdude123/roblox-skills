# Replicating a clip from a video (rotoscope by computer)

Use this when the reference is a screen recording of the clip (a commissioned animation played in Studio from several camera angles) and the task is a 1:1 copy on the same rig. Built on the Licensed To Strike warrior idle, 2026-09-28. The saved clips in the place were not the reference ("That's not commissioned work that's random anims"); the video was.

## Pipeline

1. **Export the real rig.** Read every MeshPart with `EditableMesh` (vertices scaled by `Size / MeshSize`, triangles, UVs) and its texture with `EditableImage`, plus every Motor6D and Weld (`C0`, `C1`, `Part0`, `Part1`). Post them to a local receiver. Check the export with an offline render of the rest pose against a Studio capture from the same camera before any fit.
2. **Split the video by camera.** A recording usually holds 3 to 5 camera angles of the same loop. Mark the frame ranges of each segment.
3. **Find the loop phase per segment.** The head-top bob gives the period (the Studio preview speed differs per segment by up to 10%, so take the period per segment). A walk bob runs at twice the step rate, so a bob low is ambiguous by half a cycle: resolve it with the feet (with a camera above the rig the front foot is lower in the image) or a side view.
4. **Calibrate cameras and one shared pose** at one phase in all segments together. Camera = look-at (azimuth, elevation, distance, target), one focal length for the whole recording. Losses: silhouette chamfer both ways plus a colour term with a per-channel gain. Rules: head rotation sd 15/25/15 degrees (a smooth helmet shows no rotation), limb twist sd 20, torso translation sd 0.35, feet on the floor, fix the torso yaw and the torso x/z translation (they trade exactly with the cameras).
5. **Mark thin props by hand.** A sword or a staff is a few pixels wide and a silhouette fit leaves it wrong. Mark its tip apex, the two blade corners next to the tip and the pommel in every view where they show (grid crops at 4x, sd 2 to 4 px), and add the reprojection error to the fit. See "What went wrong" below.
6. **Track the motion.** Render the calibrated pose once per view, take the surface point under each pixel, and solve each phase by Gauss-Newton on video-to-video colour (the base video frame against the phase's frame, averaged over every loop in the segment), coarse to fine blur 4, 2, 1, robust weights. Idle: chain 60 phases out from the base. A large motion (walk) re-renders the surface points at every step and closes the loop at the end.
7. **Export.** Periodic Fourier low-pass (8 harmonics for an idle), resample at 30 fps, linear keys, the pose tree under `HumanoidRootPart` (weight 0). A `Pose.CFrame` is the Motor6D `Transform` when `C0` and `C1` have no rotation.
8. **Verify in Studio from the fitted cameras.** Play the `KeyframeSequence` through `KeyframeSequenceProvider:RegisterKeyframeSequence` on a clone of the rig, set the Studio field of view to the video's vertical angle, and capture from each fitted camera (camera and target plus the clone's pivot). Compare with the video frame at the same phase.

## What went wrong on the warrior idle, and the fix

- **The camera tilt and the torso lean traded.** The shared-pose fit found a 7 degree forward torso lean and a back camera 10 degrees too low. The body silhouettes still matched in all four views; only the sword gave it away (in the high front view the handle was hidden behind the arm, in the video it sticks far out). Refitting the back camera alone with the corrected sword dropped its outline error from 1.16 to 0.91 and moved its tilt from 7 to 17 degrees. A rigid prop is the best evidence for the cameras.
- **Leave one out finds a bad point or a bad camera.** With six marked sword points, dropping either blade tip made the rest fit (cost 6 against 146); the two tips disagreed by about 12 degrees. The cause was the back camera, not the marks.
- **The fix was one joint fit:** all cameras, the pose and the sword together (CMA, silhouette + colour + the marked points with weight 0.02 per sd squared). All eight sword points ended within 1.4 sd, the torso lean went to -0.5 degrees, and the Studio captures from all four fitted cameras matched the video.
- **Dense contrast fits fail on thin props.** A local-contrast Gauss-Newton fit of the whole body raised the right arm 59 degrees to cover the handle area; on the sword alone (body locked) it drifted the sword away from the marks. The background around a thin part dominates the local contrast. Use marks for thin parts and lock the body when a prop is refined.
- **The idle motion is small but real:** torso 1.3 degrees, head up to 4.8, arms 4 to 6, legs 2 to 3, sword 4 to 7, torso height 0.04 studs. At phase 0.85 (the far end of the loop) the tracked pose matched all four views.

## Studio checks that bite

- `animator:StepAnimations(0)` right after `track:Play(0)` leaves the track at weight 0 and the rig at rest. Step once with 0.001, set `TimePosition` again, then step with 0.
- A fitted camera can sit inside a wall of the map (the capture shows only one flat colour). Raycast every camera line and move the clone to a clear spot.
- The capture tool returns a cached image for identical camera numbers; change a number by 0.001.

## Machine limits

- Seven worker processes that each loaded 30 full video frames ran out of memory on a 6 GB machine with Studio open. Load the frames once in the main process, pass the half-size frames to the workers, and use 4 workers.
