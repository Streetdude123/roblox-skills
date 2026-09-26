---
name: roblox-sfx-synth
description: Create original anime style sound effects for Roblox from code - hits and punches, whooshes and slashes, charge ups, auras, summons, time stops and UI blips - with the numpy/scipy synth in scripts/sfx.py, measure them with scripts/check.py (peak, RMS, envelope, band energy, loop seam, spectrogram PNG) and hand them off as mono WAV files for upload. Use whenever a Roblox sound effect must be made, varied, fixed or judged without a recorded source. Voice lines are not made here; they come from the user's own recordings.
---

# Roblox SFX synth

This skill makes sound effects from nothing: noise, oscillators, envelopes, filters, distortion and
a convolution reverb, layered in numpy. Voice lines are out of scope; the user records those.

The agent cannot hear. Every sound is judged in three steps: the numbers from `check.py`, the
spectrogram PNG read as an image, then the user's ears. Only the last one decides. The numbers
below were measured on the shipped presets and have not yet been judged by ear.

## Setup

```sh
pip install -r roblox-sfx-synth/requirements.txt
python3 roblox-sfx-synth/scripts/sfx.py list
python3 roblox-sfx-synth/scripts/sfx.py make punch_heavy slash --variants 4 --out sfx_out
python3 roblox-sfx-synth/scripts/check.py sfx_out/*.wav --png
```

`make all` renders every preset. `--seed` picks the first seed, `--variants` renders that many seeds
in a row, `--peak` sets the peak in dBFS (default -1). Output is 44.1 kHz 16 bit mono WAV, named
`<preset>_<seed>.wav`. All 16 presets render in about 3.5 s.

## Workflow

1. **Pick the rung.** Match the length to the move on the tone ladder in
   `roblox-vfx-craft/SKILL.md`: a barrage hit is 0.13 s, a heavy punch 1 s, a summon 1.3 s, a
   time stop 2.8 s. A summon sound that is as big as an ultimate sound makes the ultimate small.
2. **Start from a preset** when one fits. Change its numbers before writing a new recipe. See
   `references/recipes.md` for the layers of each preset and which number changes what.
3. **Write a new recipe** as a function `name(rng)` that returns a numpy array, and add it to
   `PRESETS` with its kind and loop flag. Build it from layers (see below). Put every random
   choice through `rng` so a seed gives the same sound again.
4. **Render 4 variants.** Hits that repeat (barrage, M1 chains) need 4 to 6 variants, played at
   random in game, or the repeat is audible.
5. **Check** with `check.py --png`. Read the numbers against the table below and look at the PNG.
   Fix what the numbers show before the user listens.
6. **Send the files to the user** to listen. Log what they say in the feedback log below and turn
   each sentence into a rule or a changed number.
7. **Hand off.** The user uploads the WAV files (the agent cannot upload assets) and gives back the
   asset ids. Mix them in game with the `SoundGroup` and limiter rules in
   `roblox-vfx-craft/references/sound.md`.

## Layers

Most anime SFX are 3 to 4 layers, each with one job:

| Layer | Job | Built from |
|---|---|---|
| crack / click | the first 20 to 50 ms, the "it hit" moment | highpassed white noise, 0.5 ms attack, `drive` |
| smack / body | the mid band, the part a phone speaker plays | bandpassed noise 400 to 4000 Hz, `drive` |
| thump / boom | weight | a sine gliding down (150 to 40 Hz for heavy), `drive` |
| tail | size and space | pink noise, a sine sub, or `verb` |
| air / whoosh | motion | noise through `sweep`, shaped with `bell` |
| ring / shing | metal, magic, UI | `ring` with inharmonic ratios for metal, whole ratios for chimes |

## Rules

- A hit needs a mid layer. The first hit renders had a centroid of 103 to 210 Hz and mid energy 12
  to 17 dB under the low band: the weight was all under 300 Hz, which phone and laptop speakers
  do not play. A driven bandpass smack moved the centroids to 208 to 448 Hz.
- Pitch goes down on impacts (`glide(high, low, ...)`) and up on build-ups and teleports.
- A whoosh is shaped noise, not a tone: `sweep` a band across the move and shape the level with
  `bell`. The peak position in `bell` sets where the swing feels fastest.
- Loops are rendered 0.25 s long and cross faded by `loopify`. `finish` filters a loop circularly
  so the seam stays clean. Check `seam_jump` (under 0.01) and `seam_rms_db` (within 1 dB).
- Every preset is normalized to -1 dBFS peak. The loudness balance between sounds is done in game
  with `Volume` and `SoundGroup`, not in the file.
- Random pitch ±8 to 15 % per variant on hits, applied in the recipe with `p = rng.uniform(...)`.
- Keep every layer's attack at 0.5 to 2 ms on hits. A longer attack reads as soft.

## Measured on the shipped presets (seed 1)

| Preset | Length s | RMS dB | Peak at ms | -40 dB fall ms | Centroid Hz | Low | Mid | High |
|---|---|---|---|---|---|---|---|---|
| punch_light | 0.3 | -17.0 | 10 | 90 | 274 | -0.2 | -15.6 | -18.9 |
| punch_heavy | 1.0 | -16.5 | 70 | 460 | 208 | -3.9 | -16.4 | -20.6 |
| barrage_hit | 0.13 | -16.9 | 0 | 50 | 423 | -0.4 | -13.5 | -15.6 |
| kick_impact | 0.6 | -17.8 | 0 | 370 | 448 | -2.4 | -12.2 | -18.1 |
| swing | 0.4 | -16.3 | 170 | 220 | 2568 | -46.5 | -4.8 | -1.7 |
| dash | 0.55 | -16.6 | 150 | 390 | 3113 | -7.7 | -5.4 | -7.5 |
| slash | 0.8 | -21.6 | 100 | 450 | 3699 | -70.4 | -25.4 | -0.2 |
| teleport | 0.4 | -13.9 | 80 | 170 | 1326 | -29.7 | -0.6 | -8.8 |
| charge_up | 1.6 | -14.0 | 1510 | - | 318 | -8.0 | -9.3 | -19.5 |
| aura_loop | 2.0 | -11.5 | 240 | - | 222 | -4.5 | -7.3 | -24.1 |
| summon | 1.3 | -19.0 | 590 | 610 | 162 | -2.9 | -11.3 | -21.3 |
| time_stop | 2.8 | -17.4 | 1050 | 1230 | 314 | -3.3 | -6.5 | -16.3 |
| ui_click | 0.06 | -18.3 | 0 | 30 | 1826 | -42.4 | -0.2 | -13.4 |
| ui_hover | 0.08 | -16.9 | 0 | 40 | 1220 | -51.2 | 0.0 | -21.1 |
| ui_confirm | 0.32 | -13.1 | 10 | 190 | 1139 | -50.3 | -0.1 | -18.5 |
| ui_cooldown | 0.7 | -17.9 | 60 | 430 | 1607 | -55.0 | -1.1 | -6.6 |

Band columns are dB of the total energy: low 80 to 300 Hz, mid 300 to 2000, high 2000 to 8000.
`check.py` also prints sub (under 80) and air (over 8000), the onset, the clipped sample count and,
for a file with `loop` in its name or `--loop`, the seam numbers.

## Reading the spectrogram

`check.py --png` writes `<file>.png` next to the WAV: a peak envelope strip on top, then a 40 Hz to
22 kHz log frequency spectrogram, 80 dB range, black to purple to orange to pale yellow. Time runs
over the full width, so short and long files are stretched differently. Look for:
- a bright full height column at the hit: the crack. None means the hit will read soft.
- a bright band under the bottom fifth only: all weight, nothing a phone plays.
- a thin horizontal line: a ring or a tone. Several lines at odd spacing read as metal.
- a diagonal: a sweep. Up for build-ups, down for drops.

## Roblox upload limits

From the Creator Hub audio assets page: a single track in `.mp3`, `.ogg`, `.wav` or `.flac`, under
20 MB and 7 minutes, sample rate 48 kHz or less, mono or stereo 2.0, 3.0 or 5.1. 100 free audio
uploads per 30 days unverified, 2,000 ID verified. The WAV files from `sfx.py` fit all of these.

## Feedback log

Log the user's sentences here with the date and the preset, and the change made from each one.

## References

- [recipes.md](references/recipes.md) - each preset's layers, and the numbers to change for a variant.

## Scripts

- `scripts/sfx.py` - the synth building blocks, the 16 presets, `list` and `make`.
- `scripts/check.py` - measurement and the spectrogram PNG.
