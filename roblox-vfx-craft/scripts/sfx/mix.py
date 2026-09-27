import argparse
import json
import sys
import wave
from pathlib import Path

import numpy as np
from scipy.ndimage import maximum_filter1d, uniform_filter1d

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

RATE = 44100


def load(path):
    with wave.open(str(path), "rb") as w:
        n = w.getnframes()
        ch = w.getnchannels()
        width = w.getsampwidth()
        rate = w.getframerate()
        raw = w.readframes(n)
    if width == 2:
        data = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768
    elif width == 3:
        b = np.frombuffer(raw, dtype=np.uint8).reshape(-1, 3)
        v = (b[:, 0].astype(np.int32) | (b[:, 1].astype(np.int32) << 8) | (b[:, 2].astype(np.int32) << 16))
        v = np.where(v >= 1 << 23, v - (1 << 24), v)
        data = v.astype(np.float32) / (1 << 23)
    else:
        data = np.frombuffer(raw, dtype=np.int32).astype(np.float32) / (1 << 31)
    data = data.reshape(-1, ch)
    if ch == 1:
        data = np.repeat(data, 2, axis=1)
    if rate != RATE:
        data = speed(data, rate / RATE)
    return data[:, :2]


def speed(data, ratio):
    n = int(len(data) / ratio)
    x = np.arange(n) * ratio
    i = np.clip(x.astype(np.int64), 0, len(data) - 2)
    f = (x - i)[:, None]
    return data[i] * (1 - f) + data[i + 1] * f


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("log")
    ap.add_argument("cues")
    ap.add_argument("--start", type=float, required=True)
    ap.add_argument("--scale", type=float, default=1)
    ap.add_argument("--length", type=float, required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--gain", type=float, default=0)
    args = ap.parse_args()

    cues = json.loads(Path(args.cues).read_text(encoding="utf-8"))
    base = Path(args.cues).parent
    cache = {}
    events, fades = [], {}
    for line in Path(args.log).read_text(encoding="utf-8").splitlines():
        part = line.strip().split("|")
        if part[0] == "SFX":
            events.append((int(part[1]), part[2], float(part[3]), float(part[4]), float(part[5])))
        elif part[0] == "FADE":
            fades[int(part[1])] = (float(part[2]), float(part[3]))

    total = np.zeros((int(args.length * RATE) + 1, 2), dtype=np.float32)
    for cue, name, volume, pitch, ms in events:
        at = (ms - args.start) / 1000 / args.scale
        if at > args.length:
            continue
        spec = cues[name]
        files = spec["files"]
        path = base / files[cue % len(files)]
        if path not in cache:
            cache[path] = load(path)
        clip = cache[path]
        if abs(pitch - 1) > 1e-3:
            clip = speed(clip, pitch)
        if spec.get("loop"):
            need = int((args.length - at) * RATE) + 1
            clip = np.tile(clip, (need // len(clip) + 1, 1))[:need]
        gain = volume * 10 ** (spec.get("db", 0) / 20)
        clip = clip * gain
        if cue in fades:
            dur, fms = fades[cue]
            f0 = int(((fms - args.start) / 1000 / args.scale - at) * RATE)
            f1 = f0 + int(dur * RATE)
            env = np.ones(len(clip), dtype=np.float32)
            if f0 < len(env):
                ramp = np.linspace(1, 0, max(1, f1 - f0))
                env[f0:f0 + len(ramp)] = ramp[: len(env) - f0]
                env[f0 + len(ramp):] = 0
            clip = clip * env[:, None]
        i = int(at * RATE)
        if i < 0:
            clip = clip[-i:]
            i = 0
        j = min(len(total), i + len(clip))
        total[i:j] += clip[: j - i]

    total *= 10 ** (args.gain / 20)
    limit = 10 ** (-1 / 20)
    over = np.maximum(np.abs(total).max(axis=1) / limit, 1)
    win = int(0.01 * RATE)
    env = uniform_filter1d(maximum_filter1d(over, size=win), size=win)
    total = total / np.maximum(env, over)[:, None]
    out = np.clip(total, -1, 1)
    with wave.open(args.out, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((out * 32767).astype(np.int16).tobytes())
    rms = float(np.sqrt(np.mean(out ** 2)))
    print(f"wrote {args.out} events {len(events)} peak {20 * np.log10(max(1e-9, np.max(np.abs(out)))):.1f} dB rms {20 * np.log10(max(1e-9, rms)):.1f} dB")


if __name__ == "__main__":
    main()
