import argparse
import wave
from pathlib import Path

import numpy as np
from scipy import signal

RATE = 44100


def n(sec):
    return max(1, int(round(sec * RATE)))


def times(sec):
    return np.arange(n(sec)) / RATE


def buf(sec):
    return np.zeros(n(sec))


def put(out, x, at=0.0, gain=1.0):
    i = n(at) if at > 0 else 0
    j = min(len(out), i + len(x))
    out[i:j] += x[: j - i] * gain
    return out


def fit(x, sec):
    if len(x) >= n(sec):
        return x[: n(sec)]
    return np.concatenate([x, np.zeros(n(sec) - len(x))])


def noise(sec, rng, kind="white"):
    x = rng.standard_normal(n(sec))
    if kind == "pink":
        spec = np.fft.rfft(x)
        f = np.arange(len(spec), dtype=float)
        f[0] = 1
        x = np.fft.irfft(spec / np.sqrt(f), len(x))
    return x / np.max(np.abs(x))


def glide(a, b, sec, bend=1.0):
    x = np.linspace(0, 1, n(sec)) ** bend
    return a * (b / a) ** x


def osc(freq, sec, shape="sine"):
    f = np.full(n(sec), float(freq)) if np.ndim(freq) == 0 else fit(np.asarray(freq, float), sec)
    ph = np.cumsum(f) / RATE
    if shape == "sine":
        return np.sin(2 * np.pi * ph)
    if shape == "saw":
        return 2 * (ph % 1) - 1
    if shape == "square":
        return np.sign(np.sin(2 * np.pi * ph))
    return 2 * np.abs(2 * (ph % 1) - 1) - 1


def env(sec, attack=0.002, hold=0.0, decay=0.2):
    t = times(sec)
    rise = np.clip(t / max(attack, 1e-5), 0, 1)
    fall = np.exp(-6.9 * np.clip(t - attack - hold, 0, None) / decay)
    return rise * fall


def swell(sec, power=2.0):
    return np.linspace(0, 1, n(sec)) ** power


def bell(sec, peak=0.4, power=2.0):
    t = np.linspace(0, 1, n(sec))
    up = np.clip(t / peak, 0, 1)
    down = np.clip((1 - t) / (1 - peak), 0, 1)
    return (np.sin(np.pi / 2 * np.minimum(up, down))) ** power


def lfo(sec, rate, depth, shape="sine"):
    return 1 - depth * 0.5 * (1 - osc(rate, sec, shape))


def lowpass(x, cut, order=2):
    return signal.sosfilt(signal.butter(order, min(cut, RATE * 0.45), "lowpass", fs=RATE, output="sos"), x)


def highpass(x, cut, order=2):
    return signal.sosfilt(signal.butter(order, cut, "highpass", fs=RATE, output="sos"), x)


def band(x, lo, hi, order=2):
    return signal.sosfilt(signal.butter(order, [lo, min(hi, RATE * 0.45)], "bandpass", fs=RATE, output="sos"), x)


def sweep(x, freqs, kind="band", width=1.0, block=64):
    freqs = fit(np.asarray(freqs, float), len(x) / RATE)
    out = np.zeros_like(x)
    zi = None
    for i in range(0, len(x), block):
        f = float(freqs[i])
        if kind == "band":
            lo = max(20.0, f / 2 ** (width / 2))
            hi = min(RATE * 0.45, f * 2 ** (width / 2))
            sos = signal.butter(2, [lo, hi], "bandpass", fs=RATE, output="sos")
        else:
            sos = signal.butter(2, min(f, RATE * 0.45), "lowpass", fs=RATE, output="sos")
        if zi is None:
            zi = np.zeros((sos.shape[0], 2))
        out[i : i + block], zi = signal.sosfilt(sos, x[i : i + block], zi=zi)
    return out


def drive(x, amt):
    return np.tanh(amt * x) / np.tanh(amt)


def ring(base, sec, rng, ratios=(1.0, 2.76, 5.40, 8.93), decay=0.6, spread=0.004):
    out = buf(sec)
    for k, r in enumerate(ratios):
        f = base * r * (1 + rng.uniform(-spread, spread))
        if f >= RATE * 0.45:
            continue
        out += osc(f, sec) * env(sec, 0.001, 0, decay / (1 + 0.6 * k)) / (1 + k)
    return out


def verb(x, sec, rng, decay=1.0, wet=0.2, tone=5000):
    ir = noise(decay, rng) * env(decay, 0.005, 0, decay)
    ir = lowpass(ir, tone)
    ir /= np.sqrt(np.sum(ir**2))
    x = fit(x, sec)
    tail = signal.fftconvolve(x, ir)[: len(x)]
    return x * (1 - wet) + tail * wet * 3


def loopify(x, fade):
    k = n(fade)
    body = x[:-k].copy()
    w = np.linspace(0, 1, k)
    body[:k] = body[:k] * w + x[-k:] * (1 - w)
    return body


def finish(x, peak_db=-1.0, loop=False):
    if loop:
        k = len(x)
        x = highpass(np.concatenate([x, x, x]), 25, 2)[k : 2 * k]
    else:
        x = highpass(x, 25, 2)
        k = min(len(x), n(0.01))
        x[-k:] *= np.linspace(1, 0, k)
    return x / np.max(np.abs(x)) * 10 ** (peak_db / 20)


def punch_light(rng):
    sec = 0.3
    p = rng.uniform(0.9, 1.1)
    out = buf(sec)
    put(out, highpass(noise(0.03, rng), 2500) * env(0.03, 0.0005, 0, 0.02), 0, 1.0)
    put(out, drive(osc(glide(190 * p, 60 * p, 0.14, 0.5), 0.14) * env(0.14, 0.001, 0.01, 0.12), 2.0), 0, 0.8)
    put(out, drive(band(noise(0.08, rng), 700, 3200) * env(0.08, 0.001, 0, 0.06), 2.0), 0.002, 1.0)
    return out


def punch_heavy(rng):
    sec = 1.0
    p = rng.uniform(0.92, 1.08)
    out = buf(sec)
    put(out, drive(highpass(noise(0.05, rng), 1500) * env(0.05, 0.0005, 0, 0.04), 3.0), 0, 1.0)
    put(out, drive(band(noise(0.15, rng), 500, 3000) * env(0.15, 0.001, 0.01, 0.1), 3.0), 0.001, 0.9)
    put(out, drive(osc(glide(150 * p, 38 * p, 0.4, 0.4), 0.4) * env(0.4, 0.001, 0.03, 0.4), 3.5), 0, 0.8)
    put(out, lowpass(noise(0.3, rng, "pink"), 900) * env(0.3, 0.002, 0, 0.25), 0.003, 0.8)
    put(out, osc(44 * p, 0.7) * env(0.7, 0.01, 0.05, 0.6), 0.01, 0.5)
    return verb(out, sec, rng, 0.8, 0.15, 3000)


def barrage_hit(rng):
    sec = 0.13
    p = rng.uniform(0.85, 1.15)
    out = buf(sec)
    put(out, highpass(noise(0.02, rng), 3000) * env(0.02, 0.0003, 0, 0.012), 0, 0.9)
    put(out, drive(osc(glide(240 * p, 90 * p, 0.07, 0.5), 0.07) * env(0.07, 0.0008, 0, 0.06), 2.5), 0, 0.7)
    put(out, drive(band(noise(0.04, rng), 1000, 4000) * env(0.04, 0.0005, 0, 0.03), 2.0), 0.001, 1.0)
    return out


def kick_impact(rng):
    sec = 0.6
    p = rng.uniform(0.92, 1.08)
    out = buf(sec)
    put(out, drive(highpass(noise(0.04, rng), 1800) * env(0.04, 0.0005, 0, 0.03), 2.5), 0, 1.0)
    put(out, drive(band(noise(0.2, rng), 400, 2000) * env(0.2, 0.001, 0.01, 0.14), 2.5), 0.001, 1.0)
    put(out, drive(osc(glide(125 * p, 48 * p, 0.3, 0.5), 0.3) * env(0.3, 0.001, 0.02, 0.26), 3.0), 0, 0.7)
    return verb(out, sec, rng, 0.5, 0.12, 3500)


def swing(rng):
    sec = 0.4
    lo = rng.uniform(350, 450)
    hi = rng.uniform(2200, 2800)
    f = np.concatenate([glide(lo, hi, 0.16, 0.8), glide(hi, 800, 0.24, 1.2)])
    return sweep(noise(sec, rng), f, "band", 1.2) * bell(sec, 0.4, 1.5)


def dash(rng):
    sec = 0.55
    f = glide(rng.uniform(280, 340), rng.uniform(3600, 4400), sec, 0.7)
    out = sweep(noise(sec, rng), f, "band", 1.5) * bell(sec, 0.3, 1.2)
    put(out, lowpass(noise(sec, rng, "pink"), 400) * bell(sec, 0.25, 2.0), 0, 0.6)
    put(out, highpass(noise(sec, rng), 6000) * bell(sec, 0.35, 3.0), 0, 0.25)
    return out


def slash(rng):
    sec = 0.8
    out = buf(sec)
    f = glide(1400, 6000, 0.18, 0.6)
    put(out, sweep(noise(0.18, rng), f, "band", 1.0) * bell(0.18, 0.6, 1.2), 0, 1.0)
    put(out, highpass(ring(rng.uniform(2200, 2600), 0.7, rng, decay=0.7), 1500), 0.1, 0.35)
    put(out, highpass(noise(0.4, rng), 5000) * env(0.4, 0.002, 0, 0.3), 0.1, 0.15)
    return out


def teleport(rng):
    sec = 0.4
    out = buf(sec)
    f = glide(rng.uniform(260, 340), rng.uniform(2800, 3400), 0.12, 1.4) * fit(lfo(0.12, 45, 0.08), 0.12)
    put(out, osc(f, 0.12) * bell(0.12, 0.7, 1.0), 0, 0.6)
    put(out, sweep(noise(0.14, rng), glide(500, 7000, 0.14), "band", 1.0) * bell(0.14, 0.8, 1.0), 0, 0.7)
    put(out, highpass(ring(rng.uniform(3000, 3600), 0.28, rng, (1.0, 1.5, 2.0, 3.0), 0.25), 2000), 0.11, 0.3)
    return out


def charge_up(rng):
    sec = 1.6
    f = glide(80, 330, sec, 1.3)
    tone = sum(osc(f * d, sec, "saw") for d in (1.0, 1.007, 0.994, 2.003)) / 4
    tone = sweep(tone, glide(300, 5000, sec, 1.6), "low")
    rate = np.cumsum(glide(6, 26, sec)) / RATE
    trem = 1 - 0.35 * 0.5 * (1 - np.sin(2 * np.pi * rate))
    out = tone * trem * swell(sec, 1.6)
    out += highpass(noise(sec, rng), 3000) * swell(sec, 3.0) * 0.25
    out += osc(glide(40, 60, sec), sec) * swell(sec, 1.0) * 0.4
    k = n(0.04)
    out[-k:] *= np.linspace(1, 0, k)
    return out


def aura_loop(rng):
    sec = 2.0
    fade = 0.25
    full = sec + fade
    out = osc(55, full) * 0.3
    saws = sum(osc(110 * d, full, "saw") for d in (1.0, 1.006, 0.995, 2.004)) / 4
    out += sweep(saws, 1400 + 600 * np.sin(2 * np.pi * 0.5 * times(full)), "low") * 0.8
    crackle = band(noise(full, rng, "pink"), 400, 1600)
    flicker = lowpass(np.abs(rng.standard_normal(n(full))), 12, 1)
    out += crackle * flicker / np.max(flicker) * 1.2
    out *= lfo(full, 0.5, 0.2)
    return loopify(out, fade)


def summon(rng):
    sec = 1.3
    out = buf(sec)
    rise = 0.5
    put(out, sweep(noise(rise, rng), glide(300, 6000, rise, 1.5), "band", 1.2) * swell(rise, 2.5), 0, 0.7)
    put(out, drive(osc(glide(120, 40, 0.5, 0.5), 0.5) * env(0.5, 0.002, 0.02, 0.45), 2.5), rise, 1.0)
    put(out, highpass(noise(0.05, rng), 1500) * env(0.05, 0.0005, 0, 0.04), rise, 0.5)
    chord = sum(ring(f, 0.8, rng, (1.0, 2.0, 3.01), 0.8) for f in (523, 784, 1046))
    put(out, chord, rise, 0.25)
    return verb(out, sec, rng, 1.2, 0.3, 6000)


def time_stop(rng):
    sec = 2.8
    out = buf(sec)
    pre = 0.6
    put(out, sweep(noise(pre, rng), glide(800, 8000, pre, 2.0), "band", 1.5) * swell(pre, 3.0), 0, 0.6)
    drop = 1.3
    saw = sum(osc(glide(420 * d, 55 * d, drop, 0.6), drop, "saw") for d in (1.0, 1.01, 0.5))
    put(out, sweep(saw / 3, glide(6000, 300, drop, 0.8), "low") * env(drop, 0.005, 0.5, 0.9), pre, 0.8)
    put(out, ring(880, 2.0, rng, (1.0, 2.76, 5.4), 1.8), pre, 0.3)
    put(out, drive(osc(glide(80, 30, 0.8), 0.8) * env(0.8, 0.003, 0.05, 0.7), 2.0), pre, 0.8)
    return verb(out, sec, rng, 2.0, 0.35, 4000)


def ui_click(rng):
    sec = 0.06
    out = osc(rng.uniform(1700, 1900), sec) * env(sec, 0.0005, 0, 0.03)
    put(out, highpass(noise(0.01, rng), 4000) * env(0.01, 0.0002, 0, 0.006), 0, 0.3)
    return out


def ui_hover(rng):
    sec = 0.08
    return lowpass(osc(rng.uniform(1150, 1250), sec, "tri") * env(sec, 0.003, 0, 0.05), 4000)


def ui_confirm(rng):
    sec = 0.32
    out = buf(sec)
    for i, f in enumerate((880, 1320)):
        put(out, osc(f, 0.2, "tri") * env(0.2, 0.002, 0.02, 0.14), i * 0.08, 1.0)
    return out


def ui_cooldown(rng):
    sec = 0.7
    out = buf(sec)
    for i, f in enumerate((1046, 1318, 1568)):
        put(out, ring(f, 0.45, rng, (1.0, 2.0, 3.0), 0.4), i * 0.06, 1.0)
    return verb(out, sec, rng, 0.5, 0.15, 7000)


PRESETS = {
    "punch_light": ("hit", punch_light, False),
    "punch_heavy": ("hit", punch_heavy, False),
    "barrage_hit": ("hit", barrage_hit, False),
    "kick_impact": ("hit", kick_impact, False),
    "swing": ("whoosh", swing, False),
    "dash": ("whoosh", dash, False),
    "slash": ("whoosh", slash, False),
    "teleport": ("whoosh", teleport, False),
    "charge_up": ("charge", charge_up, False),
    "aura_loop": ("charge", aura_loop, True),
    "summon": ("charge", summon, False),
    "time_stop": ("charge", time_stop, False),
    "ui_click": ("ui", ui_click, False),
    "ui_hover": ("ui", ui_hover, False),
    "ui_confirm": ("ui", ui_confirm, False),
    "ui_cooldown": ("ui", ui_cooldown, False),
}


def save(path, x):
    data = (np.clip(x, -1, 1) * 32767).astype("<i2")
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data.tobytes())


def render(name, seed, peak_db=-1.0):
    _, fn, loop = PRESETS[name]
    return finish(fn(np.random.default_rng(seed)), peak_db, loop)


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("list")
    mk = sub.add_parser("make")
    mk.add_argument("names", nargs="+")
    mk.add_argument("--seed", type=int, default=1)
    mk.add_argument("--variants", type=int, default=1)
    mk.add_argument("--peak", type=float, default=-1.0)
    mk.add_argument("--out", default="sfx_out")
    args = ap.parse_args()

    if args.cmd == "list":
        for name, (kind, _, loop) in PRESETS.items():
            print(f"{kind:7} {name}{'  (loop)' if loop else ''}")
        return

    names = list(PRESETS) if args.names == ["all"] else args.names
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    for name in names:
        for v in range(args.variants):
            seed = args.seed + v
            path = out / f"{name}_{seed}.wav"
            save(path, render(name, seed, args.peak))
            print(path)


if __name__ == "__main__":
    main()
