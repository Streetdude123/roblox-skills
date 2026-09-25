# Study a reference frame by frame

A professional animator films or collects reference, steps through it frame by frame, and copies its poses and its frame counts before adding style. Claude cannot watch playback, but it can read every frame of a video on contact sheets. Do this before planning any action that has a reference, and for every cinematic. The worked example is [study-moon-practice2.md](study-moon-practice2.md).

## Get the video

- Ask for the file when the user sends a link. In a cloud session on 2026-09-25, YouTube served the page and the captions but refused every stream with 403 (the stream links are tied to one IP and the session proxy rotates IPs). The captions came from `yt-dlp --skip-download --write-auto-subs` with `--extractor-args youtube:player_client=web_embedded`.
- A capture of our own take comes from the recorder in pipeline.md ("Video of a clip").

## Make the sheets

`scripts/video/ref_sheets.py` needs Python 3 with `pip install imageio-ffmpeg pillow numpy`, or ffmpeg on the PATH.

```sh
python3 scripts/video/ref_sheets.py ref.mp4 study/
python3 scripts/video/ref_sheets.py ref.mp4 study/throw --from 23.1 --to 24.6 --cols 6 --rows 9 --thumb 320
```

It writes `report.json` and labelled sheets (frame number and time on each cell) and prints:

- **capture fps**: frames that repeat the one before are dropped. A 60 fps file with half its frames repeated was captured at 30 fps; count beats in unique frames.
- **cut or flash events**: unique frames that share little with the frame before, merged when they sit within 8 frames. A single event is a cut; a run of events is a flash, an impact frame set or a whip pan.
- **static runs**: stretches of 0.3 s or more where the image barely changes. With a still camera these are holds.

Read every sheet; a sheet shows 48 unique frames. Then make zoom sheets (`--from`, `--to`, `--thumb 320`) of each action you will animate.

## Write down what you see

1. A shot list (for a cinematic): time, framing, camera move, what happens.
2. A beat table for each action: the time and length of every beat (load, each wind-up stage, the snap, the slow out, contact, follow-through, recoil, recovery, exit), with the silhouette facts of each key: torso lean and twist, stance width, which foot carries the weight, where each hand is, what leads.
3. The smears and effects on the fastest frames, and how many frames they last.
4. Convert lengths to 60 fps frames for the clip plan (one capture frame at 30 fps is two frames at 60).

## Rotoscope the keys

- Take the timing from the reference beat table, not from the generic table in principles.md.
- Pose each key to match the reference frame: block it, render a strip ghost (`_G.editStrip`) from the same angle as the reference shot, and compare the two images side by side. Fix the torso first, then the stance, then the arms, then the head.
- Then push the pose 10 to 20% past the reference, as principles.md says.
- R6 has no elbows or knees: match the direction of the whole limb, and use the slide (piston) for a bend.
- Study a reference; do not publish someone else's animation as your own.

## Review a take the same way

1. Record the take (pipeline.md) from the camera the player or the viewer will use.
2. Run `ref_sheets.py` on the take. On a Windows machine without Python the recorder's take folder already holds JPEG frames; `sheet.ps1 -dir <take> -frames 1,2,3,... -out sheet.jpg -cols 8 -w 240` sheets a frame list (it does not drop repeats or find cuts).
3. Put the take's sheet next to the reference's sheet at the same beats.
4. Write the differences under these headings: key poses, timing (frame counts per beat), spacing (the gap between frames), arcs, holds, overlap, weight, smears and effects, staging and camera.
5. Fix the largest difference first, record again, and compare again. Stop when the differences that remain are choices, not faults.
