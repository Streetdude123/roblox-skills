# Measure the target's own sound first

Use this when the user says a sound must match an anime, a show or a game ("it needs to match world trigger"). The agent cannot hear, so "match" means: measure the original sound in short windows, then pick and layer candidates until their windows measure close to it. Worked on 2026-10-08 for the World Trigger Escudo and Shield.

## Find a clip where the sound is clear

- Fan "all scenes" compilations of one ability work best: 「忙しい人のための「エスクード」全シーン集」 (ピーターマン製作所) had every Escudo scene with a caption per scene.
- Skip compilations made of manga panels (the description says 画像を引用): they carry music only.
- Fight scenes with music under them measure badly: the S3E12 remote-shield clip was music from end to end. A short sound still shows as a step in band energy over the music; measure the step, and name the music level next to it.

## Record the audio in the built-in browser (no download)

1. Open the video; skip ads with `.ytp-skip-ad-button` clicks while `.ad-showing` exists.
2. Build the graph once: `ctx = new AudioContext({sampleRate: 48000})`, `src = ctx.createMediaElementSource(video)`, a `ScriptProcessor(4096, 2, 2)`, a `Gain` at 0, then `src → sp → gain → destination`. The element's own output stops once it feeds the graph, so the user hears nothing. The element must not be `muted` (muted feeds silence).
3. In `onaudioprocess`, skip blocks while `video.paused || video.seeking`, mix to mono and push the block with `video.currentTime`.
4. Play from 0 at 1x. Pause before the end (`timeupdate`, `currentTime > duration - 0.4`): YouTube autoplays the next video into the same element.
5. Map samples to video time **per block**, not with one start offset: a linear fit drifted 0.66 % (1.1 s over 165 s) and a buffering stall moved it 3.3 s. Use block k's own `currentTime` as the time of its last sample.

`window` globals survive YouTube's in-page navigation; `movie_player.loadVideoById(id)` reloads a clip into the same graph.

## Find the moments

- Onsets: 20 ms RMS, a jump of 9 dB or more over the mean of the 160 ms before it.
- Frame sheets: a 1280 x 720 canvas inside a `<dialog>` opened with `showModal()`; seek, `play()` muted, wait for `requestVideoFrameCallback`, `pause()`, `drawImage`. Draw the frames at each onset plus 0.2 s, read the captions, then draw a scene sheet: one row of frames, a 70 px RMS strip and a log spectrogram (40 Hz to 22 kHz, 70 dB) of the same window.
- The screenshot of the pane comes back scaled (800 x 455 of the 1280 x 720 page) or as a 1:1 crop of the top-left; take a second screenshot when the first one is stale or cut.

## Measure a window

For each window: band energy every 10 ms with a 2048-point Hann FFT, summed per band and given in dB re the total (40-150, 150-400, 400-1k, 1k-2.5k, 2.5k-5k, 5k-10k, 10k-16k, 16k-22k Hz), the power centroid, and the 20 ms RMS envelope. `scripts/match.py` does the same on files and scores them: mean absolute band difference over the first 7 bands + 6 x |log2(centroid ratio)|.

## World Trigger numbers (anime, 2026-10-08)

| Event | Window | Centroid | Strongest band | Shape |
|---|---|---|---|---|
| S3 Hyuse hand slap on the floor | 0-0.3 s | 4302 Hz | 5-10 kHz -4.5 dB, 40-150 Hz -7.3 | two transients 0.15 s apart |
| Sweep after the slap | 0.25-0.65 s | 2291 Hz | 1-2.5 kHz -1.8 | falling electronic tone, about 5 kHz to 1 kHz |
| Wall rise, head | 0-0.5 s | 3682 Hz | flat, every band -5 to -10 | attack 40-60 ms |
| Wall rise, body | 0.5-1.5 s | 1054 Hz | 40-150 Hz -2.5 | low rumble swells 3-5 dB, faint rising streaks at 5-10 kHz |
| Asteroid bullets on a shield | 0-0.15 s | 320-700 Hz | 150-400 Hz -0.2 to -1.0 | thumps 0.2 s apart, about 100 ms to -10 dB |
| Shield block burst | 0-0.36 s | 3426 Hz | 5-10 kHz -4.2 | +15 dB in 40 ms, holds 0.6 s, falls 6 dB over 1 s |

The surprise: a World Trigger shield hit is a short low-mid thump, not the bright magic-shield ping in layering.md. The built sounds that matched these windows are in layering.md, "Built so far".
