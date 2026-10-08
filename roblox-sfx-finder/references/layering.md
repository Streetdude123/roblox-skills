# Layering and processing

## Principles, with sources

- **Layers:** 3 to 5 per sound, each with one job: transient, body, sub, texture or sweetener, tail. They line up on the same frame, and the body is set first. Walter Murch: about 5 layers of different kinds is the limit for clarity, and only about 2.5 layers of the same kind can be heard apart. (Research notes, core principles.)
- **Magic needs a real source:** "we all find them more convincing if they are rooted in reality. So it's a subtle balance between acoustic sources and transformed or synthesis elements." (Vincent Fliniaux, https://www.asoundeffect.com/magic-sound-effects-library/)
- **Processing moves named for anime SE:**
  - Distortion on hard transients: "tons of anime sounds are super distorted".
  - A frequency shifter mixed in parallel on metal or noise, "the most heavily used effect".
  - Tape-style saturation.

  Sources: https://blog.prosoundeffects.com/anime-sound-effects-recreating-recognizable-sounds-of-an-iconic-genre and https://www.asoundeffect.com/vintage-anime-sound/
- **Composites:** the classic mecha clang 「ガキーン」 is a forging strike plus an explosion. The source does not have to be literal: a swing in Frieren is covered by a glass and debris drop.
- **Phones:** micro-speakers produce little below about 250 Hz. Weight on phones comes from the 200 Hz–1 kHz body, saturation harmonics and a 2–5 kHz transient.
- **Pitch:** one semitone is a speed ratio of 1.06. Pitching a recording down 12 to 24 semitones turns small objects into big ones: a sword clash pitched down 14 semitones becomes a metal door. Recordings with lots of high-frequency content pitch down best.
- **Structure:** split an ability into cast, travel, impact and residue. Each category keeps one signature (League of Legends uses wind chimes for every heal).

## Measured reference ranges (32 CC0 clips)

| Group | Centroid Hz | 2–5 kHz dB | 5–12 kHz dB | Tail ms |
|---|---|---|---|---|
| Sword clashes | 983–6658 | -2.8 to -10.2 | -1.2 to -4.6 | 428–1221 |
| Magic shield hits | 5160–6258 | -3.0 to -8.3 | -1.0 to -4.3 | 895–1650 |
| Glass breaks | 2780–7554 | -4.9 to -9.6 | -2.7 to -8.9 | 386–2066 |
| Magic projectile or blast | 800–3868 | -6.7 to -11.3 | -4.3 to -17.9 | 1462–1769 |

**Sword clash partials:** 10–14 strong partials between 2 and 10 kHz, in close pairs 30–200 Hz apart. Most fall 20–35 dB in 0.23 s; one or two keep ringing.

**Magic shield reference:** a burst followed by 5–6 repeats about 70 ms apart, each quieter than the last.

## Recipe format for `scripts/build.py`

Save the recipe at the root of the search folder. `build.py` reads every `candidates.json` under that folder to write the credits. File paths are relative to the recipe.

```json
{
 "name": "barrier_block",
 "layers": [
  {"file": "sword_clash/wav/freesound_364530.wav", "at": 0.0, "gain_db": 0},
  {"file": "sword_clash/wav/freesound_364530.wav", "gain_db": -8, "pitch": -5, "shift": -180, "shift_mix": 0.6},
  {"file": "glass/wav/lab_glass-break3.wav", "at": 0.004, "gain_db": -7, "hp": 2500},
  {"synth": "punch_heavy", "seed": 2, "gain_db": -10}
 ],
 "fx": [
  {"type": "delay", "time": 0.07, "feedback": 0.45, "mix": 0.18},
  {"type": "reverb", "room": 0.45, "wet": 0.15},
  {"type": "compressor", "threshold_db": -16, "ratio": 3},
  {"type": "limiter"}
 ],
 "pitch_jitter": 1.0,
 "tail": 1.5
}
```

**Layer keys:**
- `file` or `synth` (a preset name from `roblox-sfx-synth/scripts/sfx.py`), plus `seed` for a synth layer.
- `at` (s), `gain_db`, `start` and `end` (s, for cutting the source), `reverse`.
- `pitch` (semitones, varispeed, so length changes with pitch).
- `hp` and `lp` (Hz).
- `shift` (frequency shift in Hz, added in parallel at `shift_mix`).
- `drive` (tanh saturation amount).
- `fade_in`, `fade_out`.

Every layer is peak-normalised before `gain_db`, so gains are relative.

**Recipe keys:**
- `fx`: a chain of `reverb`, `delay`, `compressor`, `distortion`, `chorus`, `highpass`, `lowpass` and `limiter`, run through pedalboard.
- `pitch_jitter`: random semitones per variant.
- `layer_jitter`: random semitones per layer.
- `tail`: seconds of room left for the effects.
- `trim_db`: the level where the end is cut, default -60.
- `peak_db`: default -1.

## Built so far

| Sound | Layers | Result |
|---|---|---|
| barrier_block | freesound 364530 sword clash; the same clash -5 semitones with a -180 Hz shift; 効果音ラボ wine glass break highpassed at 2.5 kHz; Kenney explosion crunch lowpassed at 400 Hz; 70 ms echo | 1.9 s, centroid 5720 Hz, 2–8 kHz band -2.0 dB |
| heavy_hit | freesound 326868 sword clash -14 semitones with drive (metal door); Kenney explosion crunch with drive; 効果音ラボ bomb; Mixkit whoosh -4 semitones at +0.1 s; freesound glass -7 semitones lowpassed at 6 kHz (debris) | 5 s, centroid 698 Hz, mid band -3.7 dB |

| escudo_rise (World Trigger) | freesound 560768 Breaking Glass 3; 効果音ラボ 魔法反射 (light wall) to 0.9 s; 文字表示の衝撃音1 highpassed 1.2 kHz; 打撃6; 地震魔法2 rumble lowpassed 1.5 kHz; 岩にヒビが入る crackle at 0.3 s | 1.7 s; head 0-0.5 s centroid 2876 Hz (anime 3682), body 0.5-1.5 s 892 Hz (anime 1054); scores 5.1 and 3.2 |
| escudo_press | ジャンプの着地; Kenney impactPunch_medium_002; 石が砕ける highpassed 3 kHz; ガラスにひびが入る; 跳弾 (ricochet whine) +2 semitones highpassed 1.1 kHz at 0.1 s; 地震魔法1 low hum; ロボットの目が光る at -14 dB | 1.1 s; slap 0-0.25 s centroid 4441 Hz (anime 4302), sweep 0.25-0.65 s 2004 Hz (anime 2291); scores 4.7 and 4.1 |
| escudo_line | ビームガン to 0.35 s; freesound 512471 electric zap | 0.36 s, centroid 7337 Hz |
| escudo_sink | 石の壁がスライドする -2 semitones; 地震魔法2 lowpassed 700 Hz; 岩にヒビが入る; 魔法反射 -3 semitones highpassed 2 kHz | 1.5 s, centroid 432 Hz |
| wall_hit | 打撃4 (岩を砕く); 石が砕ける highpassed 2.5 kHz; 岩にヒビが入る; ロボットを強く殴る2 | 0.52 s, centroid 937 Hz |
| wall_break | 岩が真っ二つに割れる to 1.6 s; 石が砕ける; ガラスが割れる1 highpassed 1.5 kHz; 建物が少し崩れる2; ドーン lowpassed 900 Hz | 2.0 s, centroid 799 Hz |
| shield_up | 決定ボタンを押す16 (glass-like); キラッ2; シャキーン2; ジャンプの着地 lowpassed | 0.77 s, centroid 5375 Hz |
| shield_hit | Kenney impactPunch_medium_002 +5 semitones highpassed 170 Hz; 打撃4 band 180 Hz-1.2 kHz; 盾で防御 at -16 dB; ガラスにひびが入る at -18 dB | 0.46 s, centroid 636 Hz (anime 563), score 6.3 |
| shield_break | freesound 861044 Hard Glass Break 3 lowpassed 10 kHz; ガラスが割れる2; ビーム砲2; 打撃6 | 1.25 s; burst 0-0.36 s centroid 3402 Hz (anime 3426), score 2.7 |
| shield_down | 縮む to 0.4 s; ワープ | 0.5 s, centroid 1407 Hz |

The barrier_block and heavy_hit rows are not yet judged by ear. The World Trigger rows are uploaded and in game, matched to the anime by measurement (anime-reference.md), not yet judged by ear.

## Synthesis fallback: what the lab showed

These apply only when nothing real fits:
- **Metal:** 40 or more partials, log-uniform over 1.8–11 kHz. Each is in a close pair 15–120 Hz apart, and the pair starts in phase. Decays 30–220 ms, plus one ringer at 0.5–0.9 s and band noise. Fewer partials ring like a tuning fork.
- **Glass and debris:** narrow-band noise grains (±15 % around a random centre, 3–30 ms), about 2500 grains/s, fading with a 90 ms time constant. Sine pings sound like wind chimes.
- **Cloth:** noise gated by a pulse train at 14–32 Hz whose rate wanders.
- **Small bell:** the Csound handbell doublets, 1312.0/1314.5, 2353.3/2362.9, 3306.5/3309.4, 3923.8/3928.2, 4966.6/4993.7 and 5994.4/6003.0 Hz. https://csound.com/docs/manual/MiscModalFreq.html
- The first all-synth presets measured a centroid of 89–169 Hz, with the 2–5 kHz and 5–12 kHz bands 16–25 dB down. The user called them "super super mid".
