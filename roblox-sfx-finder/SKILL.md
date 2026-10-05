---
name: roblox-sfx-finder
description: Get realistic sound effects for Roblox games by finding them on the internet first - search free-to-use libraries (BigSoundBank, freesound CC0, Mixkit, 効果音ラボ, Kenney) with scripts/find.py, measure and rank the downloads, search the Roblox Creator Store's licensed partner library (ProSoundEffects, APMOfficial) for ready asset IDs, then trim, pitch and layer real recordings into anime and Frieren-style SFX with scripts/build.py and pedalboard, with license credits for every file. Synthesis (the roblox-sfx-synth skill) is the last resort. Use whenever a Roblox sound effect must be found, chosen, built, fixed or judged. Voice lines are not made here; they come from the user's own recordings.
---

# Roblox SFX finder

The user wants realistic sound. The all-synth presets from `roblox-sfx-synth` came out "super super mid", and measurement confirmed why: 16–25 dB too little presence and top end, and tails 2–10 times too short. So this skill searches the internet for real recordings, and when one sound is not enough, it layers several real recordings. Synthesis (`roblox-sfx-synth`) is only for a gap no real sound fills. Voice lines come from the user's own recordings.

The agent cannot hear. It ranks by metadata and measurements, looks at the spectrograms, then sends the top picks to the user. The user's ears decide.

## Setup

```sh
pip install -r roblox-sfx-finder/requirements.txt
cd roblox-sfx-finder/scripts
python3 find.py web "sword clash" --ja "剣" --out sfx_find/sword_clash
python3 find.py roblox "sword clash"
python3 build.py sfx_find/barrier_block.json --out sfx_find/built --variants 4
python3 check.py sfx_find/built/*.wav --png
```

## Workflow

1. **Brief.** Name the sound, its rung on the tone ladder in `roblox-vfx-craft/SKILL.md` (summon, move or ultimate), its length, and its parts (cast, travel, impact, residue). For magic in the Frieren style, read `references/frieren.md` first: attack magic is built from weapons, metal, glass and missile sounds, not sparkles.
2. **Search the web** once for each part. Use an English query, plus a Japanese query for 効果音ラボ (`--ja`). The command is `find.py web`. It downloads each result, converts it to 44.1 kHz WAV and measures it. It then writes `candidates.md` (ranked table with licenses), `candidates.json` and `sheet.png` (spectrograms of the top 9 in table order: 3 per row, left to right).
3. **Search the Roblox store** with `find.py roblox`. Licensed partners are listed first. A partner sound that fits as it is needs no upload: use its ID. Store sounds cannot be downloaded, so they cannot be layered. If Studio is connected, run `scripts/Audition.lua` on the picked IDs.
4. **Pick with evidence.** Look for:
   - title words that match the query;
   - `top Hz` of 16000 or more (full band; below about 12 kHz means dull or low quality);
   - a noise `floor dB` of -55 or lower;
   - no clipped samples;
   - a body length that fits the rung.

   Read `sheet.png`: a hit needs a bright full-height column at the start.
5. **Layer when one sound is not enough.** Write a recipe (format in `references/layering.md`) at the root of the search folder and run `build.py`. It writes the WAV variants and a `_credits.json` with the source, author, license and page of every layer.
6. **Check** the result with `check.py --png` against the reference ranges in `references/layering.md`.
7. **Send** the files, or the store IDs, to the user with a one-line description of each. Log what they say in the feedback log below.
8. **Hand off.** The user uploads the built WAVs; the agent cannot upload assets. Uploads that contain Mixkit or 効果音ラボ material stay private (redistribution is forbidden). Store IDs go straight into `Sound.SoundId` or `AudioPlayer.Asset`. Mix in game with the rules in `roblox-vfx-craft/references/sound.md`.
9. **Synthesize only as a last resort.** Use the `roblox-sfx-synth` skill, or a `synth` layer in a recipe, which loads a preset from `../roblox-sfx-synth/scripts/sfx.py`. Follow the fallback section of `references/layering.md`.

## Rules

- **Licenses:** CC0, or a site license that allows commercial game use with no attribution. Never NC, never attribution-required, never community store uploads of unverified ownership unless the user says so. The license list and evidence are in `references/sources.md`.
- **Real sources:** magic is more convincing when "rooted in reality". Build it from real metal, glass, air, cloth, bells, rockets and explosions. Transform them with pitch, frequency shift and drive.
- **Pitch down to make things bigger:** a sword clash at -14 semitones becomes a metal door. Recordings with lots of high-frequency content pitch down best.
- **Anime processing:** distortion on hard transients, a frequency shifter mixed in parallel on metal, a short echo train for barrier hits.
- **Limits:** 3 to 5 layers per sound, each with its own job and frequency range. The body carries weight on phones (200 Hz–1 kHz).
- **Frieren subtraction:** keep charge-ups almost silent and let the hit carry the moment.
- **Variants:** render 4 to 6 variants with `pitch_jitter` 0.8–1.5 semitones for any sound that repeats.

## Measured on this setup

- One `find.py web` query with 5 results per source took about 27 s for 20 downloads. Rows measured for "sword clash": BigSoundBank FLAC top 10–17 kHz; freesound hq previews top 17.7–20.2 kHz; Mixkit WAV top 19.4–21.8 kHz; 効果音ラボ MP3 top 18.7–19.0 kHz.
- Roblox partner results per single word, ProSoundEffects: magic 829, sword 728, glass 1000+, explosion 328, punch 541, whoosh 1000+, cloth 840, bell 608, energy 789.
- Built from real layers: `barrier_block` 1.9 s, centroid 5720 Hz; `heavy_hit` 5 s, centroid 698 Hz. Not yet judged by ear.
- `Audition.lua` has not been run yet. It uses `AudioPlayer:GetWaveformAsync` and `AudioAnalyzer` PeakLevel and RmsLevel; check its output the first time it runs in Studio.
- Python was not installed on 2026-10-05, so `find.py` and `build.py` did not run. The fallback: MCP `search_asset` (Audio, creator_store) for the store, and Web Audio in the built-in browser to measure.
- **Listening page for store audio and local files (2026-10-05).** A create.roblox.com tab gets the CDN location from `assetdelivery.roblox.com/v2/assetId/<id>` with no sign-in. That tab cannot fetch localhost or frame it (CSP). A localhost page can fetch the CDN URL (CORS allowed): the bytes come back as plain `OggS` typed `binary/octet-stream`, so `<audio src=cdn>` fails with error 4, and a `Blob` typed `audio/ogg` plays. Pass the long signed URLs to the local page through a JSON file, never through tool output. One page per request: every candidate grouped by role, numbered per group, tick boxes and a summary line to copy.
- **Level the page before the user listens.** ProSoundEffects ambience loops are mastered very low: Birds Park 1 -55 dB RMS, Forest Ambience 2 -59, Mountain Birds 1 -48, Water Lap Glugs 1 -39. DistroKid jazz measured -12 to -23 dB RMS; Kenney UI sounds -11 to -25 dB RMS at about -1 dBFS peak. Raw, the ambience is inaudible next to the music. Give each row a gain to its planned in-game RMS and put a limiter on the master.
- **`Sound:Play()` does not restart a Sound that is playing.** A 0.45 s typing blip played on each new letter sounded once per 0.45 s (1 blip for a 31-letter line). `Stop()` then `Play()` gave one per letter (11 for 11 letters).
- **`SoundService:PlayLocalSound` is invisible to tests:** the template gets no `IsPlaying` and no `Played`. Clone the template into a local folder under SoundService, `Play()`, destroy on `Ended`. A test can count it, clicks overlap, and 3D sounds use the same function with a part as the parent.
- A Sound with an empty `SoundId` fires no `Played`. To count events before the real ids exist, give the clones a client-local test id.
- **Footsteps on the default R6 walk** (180426354, 0.667 s loop): the right foot is forward at 0 s and the left at 0.381 s. Play a step when `TimePosition` wraps or crosses 0.381. At 7 studs/s (speed 0.48), 12 walkers made 51 steps in 10 s with a median gap of 0.63 s.

## Reading the spectrogram

`check.py --png` and `sheet.png` show a peak envelope strip on top and a log-frequency spectrogram (40 Hz to 22 kHz, 80 dB range) below it. Look for:
- a bright full-height column: a crisp transient;
- dense horizontal lines: metal or glass partials;
- a diagonal: a pitch sweep;
- energy only in the bottom fifth: a dull sound that phones will not play.

## Feedback log

- 2026-09-26: "like anime sound effects, voicelines will come frol my own records, i just want you to be able to CREATE your own sound effects". This led to the synth and its 16 presets.
- 2026-09-26: "your sound effects are super super mid and they aren't anything special". This led to the research and the measurement. Presets vs 32 CC0 references: centroid 89–169 Hz vs 800–7500 Hz, top end 16–25 dB down, tails 2–10 times short.
- 2026-09-26: "i want these to sound realistic ... utilize the internet to get super realistic sounds ... making your own sfx is last resort, the skill will just go through the internet and find the perfect aound effects for your needs". This led to `find.py`, `build.py` and the find-first workflow.

  The user chose: search both the web and the Roblox store; licenses CC0 plus free site licenses with no attribution; layering and processing allowed.
- 2026-09-26: "Actually no keep them seperate, two separate repos" (meaning two skill folders in this repo). The finder became `roblox-sfx-finder`, and `roblox-sfx-synth` went back to synthesis only.
- 2026-10-04 (Untitled TD lobby): "add sound effects, soft jazz music please too that plays in the lobby". His sound picks: ambient nature, villager sounds, elevator sounds, UI clicks.
- 2026-10-05: "Lobby sounds and soft jazz candidates please". On the jazz: "I gotta listeb it to thugh" - he listens before he picks music. On the Kenney CC0 packs: "Yes, upload and make public". This led to the listening page with every candidate, levelled to its in-game level (Measured on this setup).
- 2026-10-05 (later): "Pick whatever music you want". The pick came from measurement for "soft": spectral centroid and onset punch over the whole track. Cozy Autumn Cafe Vibes (centroid 1187 Hz, punch 0.073), Golden Cafe Hours (2114 Hz) and Smooth Morning (2265 Hz) became a shuffled rotation, each set to -26 dB RMS. Left out: the most percussive track (punch 0.119) and the two brightest (2.7 to 2.9 kHz). For the sound effects he chose "Use your picks", ticks on the last 5 seconds only, the join sound for everyone near the pad, the teleport sound only for the players inside, and a fix for the shopkeeper's typing blip (stop, then play, one blip per letter). The teleport pick came from the attack: Magical Exit 3 reaches half its peak at 0.10 s and holds 76% of its energy in the first second, while Powered Up Chimes holds 12% and the teleport cuts it off.
- 2026-10-05 (upload): "sign in for me, you have my full permission" with his password in chat; the agent must not type passwords, and he was told to change it. Then "i can't get on my pc". What worked: Roblox Quick Sign-in. Click the login page's Quick Sign-in button (id `cross-device-login-button`), read the 6-character code from `.modal-content` (the screenshot tool showed a stale image, so read the DOM), send it to him, and he approves it in the Roblox app (More > Quick Sign In). The code changes about once a minute, so read and send the newest one fast. Then "You don't need to upload under any group, under me please im the creator a solo dev": uploads always go to his user account.
- Upload facts from that pass: the Audio upload form now requires a Description (the Upload button stays disabled without one; write it with the native value setter and an `input` event). 11 WAVs uploaded in about one minute. The Distribute on Creator Store checkbox stayed disabled ("Enabling Store is unavailable at this time") until moderation finished, about an hour later for 10 of them; one (LobbyJoin) still had a disabled checkbox with "Your audio can be distributed" shown. A place owned by his user plays his private audio at once.

## References

- [sources.md](references/sources.md): every source, its license with evidence, how it is accessed, what was excluded and why.
- [frieren.md](references/frieren.md): the Frieren team, evidence, sound brief and search terms.
- [layering.md](references/layering.md): principles, measured reference ranges, the recipe format, built sounds, and the synthesis fallback.
- `roblox-sfx-synth` skill: the synth presets (last resort).

## Scripts

- `scripts/find.py`: `web` search, download, measure and rank; `roblox` store search.
- `scripts/build.py`: layers found files and synth presets from a JSON recipe through pedalboard, and writes credits.
- `scripts/check.py`: measures any audio file; `--png` writes a spectrogram.
- `scripts/Audition.lua`: measures Creator Store IDs in Studio (untested).
