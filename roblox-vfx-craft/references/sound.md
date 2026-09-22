# Sound for an effect

## The mix (measured from his recording)

The first mix clipped for 2.5 s: an Impact at volume 4 sat outside the compressor and stacked
Explosion layers pinned the master. True peak +0.6 dBFS with 12,000 clipped samples, RMS -9.9 dB.
The second recording after the fix: peak -3.5 dBFS, RMS -19.3, zero clips, but the pillar sat 10 dB
under the hit, the explosion no louder than the hit, and highs 15 to 25 dB under lows.

Rules that came out of it:
- Two `SoundGroup`s in `SoundService`: a bed group that ducks and muffles as a whole (`UltMix`) and a
  hits group that only gets limited (`UltHits`) so a hit still cuts through a full duck.
- A `CompressorSoundEffect` on each as a limiter: Threshold -9, Ratio 12, Attack 0.001, Release 0.12,
  GainMakeup 0. An `EqualizerSoundEffect` with +3 dB HighGain on both for air, a second EQ on the bed
  for the muffle (HighGain -30, MidGain -12 on the hit stop, back over 0.5 s), a `ReverbSoundEffect`
  on the bed (DecayTime 2.2, WetLevel -80 at rest, -6 on the burst).
- Stacked layers 8 to 10 dB lower than instinct: Impact 1.7, Explosion 1.3 to 1.9, Rumble 0.6,
  Aftermath 2.2, PillarLoop 1.1 to 1.9, sub stab 1.7, wave two 1.5 and 1.2.
- A slowed sub hit becomes a drone: `stab(sound, hold, fadeTime)` fades it after 0.3 to 0.4 s.
- Ducks: to 0.05 in 0.02 s on the hit stop, back to 1 over 0.12 s when it releases; to zero with the
  black at the end.
- Rolloff `InverseTapered`, 40/500 studs for a big effect, 25/300 for a summon.
- A summon uses one group (`StandMix`) with one limiter and two or three clips (Ambience 0.35,
  SummonSound 1.2, StandSFX 0.9; the WRY voice line is off by default).
- A `Start` attribute on a template seeks the clone after `Play` (Crown has a 0.2 s silent head);
  `LoopRegion` makes a 1 s clip loop cleanly (Aftermath 0.3 to 2.0, PillarLoop 0.15 to 2.55).

## Mirelo clips

He generates SFX with the Mirelo TextToSfx plugin (Duration max 1 s, Loop, Samples 2/4/6, Cartoonish or
Realistic). Prompt like a sound designer labels a file: event noun, its shape, then "single" or
"loop" ("sharp sword whoosh, single fast swish", "low rumble loop, steady sub bass shake"). Never
describe the scene or the motion; "sword lifting slowly, gentle wind" produced a constant wind bed.
Long tails come from a looped 1 s clip faded out in code, not from a long prompt. Clips asked for at
1 s came back 1 to 4.6 s with fades, silent heads and one falling riser, so measure them.

## Measuring a clip in Studio

Clone the Sound template, Play it and sample `PlaybackLoudness` (0 to 1000) every 50 to 100 ms for
its `TimeLength`: that gives the envelope without downloading the asset. Fix with `LoopRegion`, a
`Start` attribute and volume ramps in code.

## Measuring his recording

With no ffmpeg on the machine: a 20 line Node server serves the mp4 and a page; in the built-in
browser `decodeAudioData` the buffer, mix to mono, take 100 ms RMS and peak in dBFS, count samples
above 0.985 for clipping, and render through an `OfflineAudioContext` with a lowpass 150 and a
highpass 4000 `BiquadFilter` for low and high band envelopes. Find the cast onset as the first window
above -40 dB and subtract it to line up with `T`.

## Dead private audio

Free packs carry private audio ids that spam "not authorized" on every play start (54 in his kit:
LightningBolt1-5, Clashing 2-6, Leap, GustLoop, DRSummon, Aura, ...). Blank `SoundId` and keep the old
id in a `DeadSoundId` attribute (`scripts/BlankDeadSounds.lua`). A pack's own `SFX` folder that keeps
failing in the console is not ours to fix.

## Preload

`UltimateClient` and `StandClient` preload every sound, the clip and every particle texture at join,
else the first cast misses the first clip (Wind was silent on the first cast before that).
