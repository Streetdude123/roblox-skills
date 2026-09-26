# Preset recipes

Times are seconds from the start of the file. `glide(a, b, len, bend)` is an exponential pitch
move; a `bend` under 1 moves fast early, over 1 moves late. `env(len, attack, hold, decay)` falls
60 dB over `decay`. `drive(x, amt)` is tanh saturation; 2 to 3.5 adds crunch and loudness.

## Building blocks

| Function | Does |
|---|---|
| `noise(len, rng, "white" / "pink")` | noise at full scale; pink is darker |
| `osc(freq, len, shape)` | sine, saw, square or tri; `freq` can be a number or a `glide` array |
| `env`, `swell(len, power)`, `bell(len, peak, power)` | decay, rise, rise and fall |
| `lfo(len, rate, depth)` | a gain curve for tremolo and slow pulses |
| `lowpass`, `highpass`, `band` | fixed Butterworth filters |
| `sweep(x, freqs, "band" / "low", width)` | a moving filter, updated every 64 samples; `width` in octaves |
| `ring(base, len, rng, ratios, decay)` | decaying partials; higher partials decay faster |
| `verb(x, len, rng, decay, wet, tone)` | noise impulse reverb; `tone` is the lowpass on the tail |
| `put(out, x, at, gain)` | adds a layer into a buffer at a time |
| `loopify(x, fade)` | cross fades the extra `fade` seconds onto the head |
| `finish(x, peak_db, loop)` | 25 Hz highpass, 10 ms end fade, peak normalize |

## Hits

**punch_light** 0.3 s. Crack: white noise over 2500 Hz, 20 ms. Thump: sine 190 to 60 Hz over
0.14 s, drive 2. Smack: noise 700 to 3200 Hz, 60 ms, drive 2. Pitch ±10 %.

**punch_heavy** 1.0 s. Crack over 1500 Hz, 40 ms, drive 3. Smack 500 to 3000 Hz, 0.1 s, drive 3.
Boom: sine 150 to 38 Hz over 0.4 s, drive 3.5. Body: pink noise under 900 Hz, 0.25 s. Sub: 44 Hz
sine, 0.6 s. Reverb 0.8 s, wet 0.15. Pitch ±8 %.

**barrage_hit** 0.13 s. Crack over 3000 Hz, 12 ms. Thump 240 to 90 Hz over 70 ms. Smack 1000 to
4000 Hz, 30 ms. Pitch ±15 % so a fast chain does not machine gun. Render 6 variants.

**kick_impact** 0.6 s. Crack over 1800 Hz. Smack 400 to 2000 Hz, 0.14 s, drive 2.5: lower and
longer than a punch, it reads as a "thwack". Thump 125 to 48 Hz. Reverb 0.5 s, wet 0.12.

To make a hit heavier: lower the thump end pitch, lengthen its decay, add `verb`. To make it
sharper: raise the smack band and the crack gain, shorten every decay.

## Whooshes

**swing** 0.4 s. Noise through a 1.2 octave band that goes 400 to 2500 Hz in 0.16 s and back to
800 Hz, level `bell(peak=0.4)`.

**dash** 0.55 s. Band 300 to 4000 Hz rising over the whole file, a pink rumble under 400 Hz, a
hiss over 6000 Hz. Rising pitch reads as moving away fast.

**slash** 0.8 s. A fast bright swish, band 1400 to 6000 Hz in 0.18 s, then a metal `ring` at
2200 to 2600 Hz with bar ratios 1, 2.76, 5.40, 8.93 from 0.1 s, highpassed at 1500 Hz, plus a hiss.

**teleport** 0.4 s. A sine zip 300 to 3000 Hz in 0.12 s with a 45 Hz wobble, a noise band
500 to 7000 Hz, then a short chime ring (ratios 1, 1.5, 2, 3) at 0.11 s.

## Charge, aura, summon

**charge_up** 1.6 s. Four detuned saws 80 to 330 Hz, lowpass opening 300 to 5000 Hz, tremolo
speeding up 6 to 26 Hz, hiss swelling in, a 40 to 60 Hz sub. Cut with a 40 ms fade at the peak so
the release sound takes over.

**aura_loop** 2.0 s loop. A 55 Hz sine, detuned saws on 110 and 220 Hz under a lowpass moving
800 to 2000 Hz at 0.5 Hz, crackle (pink noise 400 to 1600 Hz with a random 12 Hz flicker), a slow
0.5 Hz pulse. Loop it with `Looped = true`.

**summon** 1.3 s. A 0.5 s rising noise band 300 to 6000 Hz, then a boom (120 to 40 Hz), a crack
and a C major chime (523, 784, 1046 Hz) at 0.5 s. Reverb 1.2 s, wet 0.3. The hit lands at 0.5 s:
start the sound 0.5 s before the stand appears.

**time_stop** 2.8 s. A 0.6 s rising hiss, then at 0.6 s a saw stack dropping 420 to 55 Hz over
1.3 s under a closing lowpass, a bell at 880 Hz, a 80 to 30 Hz boom. Reverb 2 s, wet 0.35. The
freeze lands at 0.6 s.

## UI

**ui_click** 0.06 s, a 1800 Hz sine blip and a tick of noise. **ui_hover** 0.08 s, a soft 1200 Hz
triangle. **ui_confirm** 0.32 s, 880 then 1320 Hz, 80 ms apart. **ui_cooldown** 0.7 s, a rising
C E G chime (1046, 1318, 1568 Hz) 60 ms apart with a short reverb.

UI sounds play often: keep them under 0.1 s unless they mark an event, and keep the low band empty
so they do not fight the hits.
