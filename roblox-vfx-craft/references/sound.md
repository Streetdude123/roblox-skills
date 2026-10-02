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

## Licensed library picks (Caliber Phoenix, 2026-09-28)

The Creator Store audio search mixes ripped game sounds (Limbus Company, JJS, League) with licensed partner audio. Use only
the partner uploads: creator `ProSoundEffects` ("Courtesy of Pro Sound Effects") and `APMOfficial`. Search with the library's
own title style, for example `Sword Swish (SFX)`, `Whoosh Fast Pass (SFX)`, `Cinematic Impact Hit Boom Deep (SFX)`.

Measure every pick with `PlaybackLoudness` sampled each RenderStepped (onset = first sample over 20% of the peak) before timing it:

| Use | Id | Onset | Peak at | How it was placed |
| --- | --- | --- | --- | --- |
| Gather (air rush, pitch 1.15) | 9113080188 | 0.51 | 0.78 | started at the cast so the peak lands on the release (0.73 s) |
| Spread swish (pitch 0.9) | 9119750447 | 0.12 | 0.13 | started 0.12 s before the spread |
| Swing (Sword Swishes 2) | 9119749931 | 0.04 | 0.05 | started 0.04 s before the sweep |
| Flight (searing whoosh) | 9125920594 | 0.35 | 0.45 | `TimePosition` 0.3 (a `Skip` attribute) so it rises with the launch |
| Impact (Sword Impact 202) | 9119747138 | 0.07 | 0.08 | Skip 0.05 |
| Boom (deep hit, pitch 1.1) | 9125484526 | 0.07 | 0.17 | Skip 0.05, faded after 0.7 s (`Cut`) |

A long lead-in on a whoosh is better skipped with `TimePosition` than started early: the sound then follows the object it is
parented to. All six ride one SoundGroup with the usual compressor (-9, 12:1, 1 ms, 0.12 s) and a +3 dB high EQ.

## Slash and cut sounds (samurai, 2026-09-28)

"you're missing slash sound effects". The kit had only air swishes (ProSoundEffects "Swish Med High End Sharp Swords",
"Sword Swish 5"): a swish is the air, not the blade. Every sword move needs three layers: a swish or whip on the swing, a metal
**cut** on the frame the blade lands, and the impact body on a hit. Search the Creator Store page with the creator filter
(`create.roblox.com/store/audio?keyword=...&creatorName=ProSoundEffects`); the Studio search and the toolbox API return
ripped game audio first. Measured with `PlaybackLoudness`:

| Use | Id | Peak at | Loudness | Placement |
| --- | --- | --- | --- | --- |
| Cut A (Sever Metal Hit 1: "Sword Slice, Metal Hit, Swipe, Cut") | 9119028728 | 0.03 | 337 | volume 0.75, on the landing frame |
| Cut B (Sever Metal Hit 2) | 9119028721 | 0.05 | 592 | volume 0.6, 0.05 to 0.06 s after Cut A for a second blade; also in every full impact |
| Cut soft (Sever 1, pitch 1.2) | 9119028728 | 0.03 | - | volume 0.4 on each multi-hit tick |
| Whip A / B (Sword Whip 501 / 601: metal slide and ching) | 9119751604 / 9119751891 | 0.32 / 0.35 | about 60 | Skip 0.19 / 0.15, volume 2.4, Cut 0.5 |
| Whip C / D (Sword Whip 702 / 1002) | 9119752176 / 9119753139 | 0.68 / 0.65 | about 86 | Skip 0.47 / 0.52, volume 2, Cut 0.5 |

The whips are quiet and start late; skip to 0.03 s before their onset and raise the volume, or they vanish under a tornado bed.
Check a take with a 3.5 kHz high-pass envelope in the browser: a cut shows as a spike of 0.6 to 0.75 on the hit frame.

## Punch kit (Scripter Combat Trial, 2026-10-01)

Fist combat picks, all ProSoundEffects (public, play on any account). Envelopes measured with `PlaybackLoudness` (onset over 20% of the peak):

| Use | Id | Onset / peak | Loudness | Placement |
| --- | --- | --- | --- | --- |
| Swing whoosh 1-4 (Whoosh Heavy Punches 1, 2, 3, 4) | 9120728815, 9120728883, 9120729007, 9120729005 | peaks 0.14, 0.17, 0.15, 0.22 | 246 to 314 | started at 0.37 - peak - network lateness after the Swing event, so the peak lands mid-strike |
| Hit 1 (Punch Kit Beefy Hit 7) | 9117970193 | 0.03 / 0.03 | 657 | on the Hit event |
| Hit 2, 3 (Beefy Hit 3, 4) | 9117969717, 9117969878 | 0.05 / 0.07, 0.05 / 0.13 | 601, 574 | Skip 0.03, 0.05 |
| Uppercut crack layer (Cracky Punch 10) | 9113965059 | 0.27 | 122 | Skip 0.25, volume 1.8, with Beefy Hit 7 at 0.9 pitch |
| Parry press (Swish Med High End Sharp Swords Fast Punches) | 9126014020 | 0.08 | 233 | Skip 0.04 |
| Clash crack (Whip Cracks 2) | 9120660382 | 0.37 / 0.42 | 306 | Skip 0.35 |
| Clash ring (Anvil Hits Ringing Metal Clinks Blacksmith 1) | 9125361455 | 0.02 | 101 | volume 1.6 |

One SoundGroup with the usual limiter and +3 dB high EQ; the final take peaked at -1.0 dBFS, RMS -21.9 dB, 0 clipped samples.

## CC0 punch kit and public upload (Scripter Combat Trial, 2026-10-01)

- A trial or a place file that someone else opens needs public audio: uploaded audio is private to the owner, so distribute each sound on the Creator Store (configure page, "Distribute on Creator Store", 100 shares per 30 days).
- Upload to the account Lepy names: the dashboard creator switcher was on a group and the first upload landed there. Read the creator before every batch.
- A description with a web address ("kenney.nl") gets moderated to "####" and the distribute switch stays disabled until the description is rewritten without the address.
- The configure page loads its saved state about 4 s after the route change; clicking the switch earlier is undone by the load.
- Level new sounds against the old ones by PlaybackLoudness in the same Sound template (same EQ), not by file RMS; a thin metallic ring scores far lower than a deep thump at the same perceived level.
