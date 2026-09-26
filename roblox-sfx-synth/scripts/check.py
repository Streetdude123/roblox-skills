import argparse
import struct
import wave
import zlib
from pathlib import Path

import numpy as np
from scipy import signal

BANDS = [("sub", 20, 80), ("low", 80, 300), ("mid", 300, 2000), ("high", 2000, 8000), ("air", 8000, 20000)]
COLORS = np.array([[0, 0, 0], [40, 10, 90], [170, 30, 110], [250, 120, 30], [255, 240, 150]], float)


def load(path):
    with wave.open(str(path), "rb") as w:
        rate = w.getframerate()
        ch = w.getnchannels()
        x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float) / 32768
    return x.reshape(-1, ch).mean(axis=1), rate


def db(v):
    return 20 * np.log10(max(v, 1e-9))


def windows(x, rate, sec=0.01):
    k = int(rate * sec)
    m = len(x) // k
    return np.sqrt(np.mean(x[: m * k].reshape(m, k) ** 2, axis=1)) if m else np.array([np.sqrt(np.mean(x**2))])


def stats(x, rate, loop=False):
    peak = np.max(np.abs(x))
    rms = windows(x, rate)
    loud = np.nonzero(rms > 10 ** (-40 / 20))[0]
    top = int(np.argmax(rms))
    quiet = np.nonzero(rms[top:] < rms[top] * 10 ** (-40 / 20))[0]
    spec = np.abs(np.fft.rfft(x)) ** 2
    f = np.fft.rfftfreq(len(x), 1 / rate)
    total = np.sum(spec) + 1e-20
    out = {
        "length": round(len(x) / rate, 3),
        "peak_db": round(db(peak), 1),
        "rms_db": round(db(np.sqrt(np.mean(x**2))), 1),
        "loudest_10ms_db": round(db(rms[top]), 1),
        "clipped": int(np.sum(np.abs(x) > 0.985)),
        "onset_ms": int(loud[0] * 10) if len(loud) else None,
        "peak_at_ms": top * 10,
        "fall_40db_ms": int(quiet[0] * 10) if len(quiet) else None,
        "centroid_hz": int(np.sum(f * spec) / total),
    }
    for name, lo, hi in BANDS:
        e = np.sum(spec[(f >= lo) & (f < hi)])
        out[name] = round(10 * np.log10(e / total + 1e-12), 1)
    if loop:
        k = int(rate * 0.05)
        out["seam_jump"] = round(abs(x[-1] - x[0]), 4)
        out["seam_rms_db"] = round(db(np.sqrt(np.mean(x[-k:] ** 2))) - db(np.sqrt(np.mean(x[:k] ** 2))), 1)
    return out


def paint(v):
    v = np.clip(v, 0, 1) * (len(COLORS) - 1)
    i = np.minimum(v.astype(int), len(COLORS) - 2)
    t = (v - i)[..., None]
    return (COLORS[i] * (1 - t) + COLORS[i + 1] * t).astype(np.uint8)


def save_png(path, img):
    h, w, _ = img.shape
    raw = b"".join(b"\x00" + img[y].tobytes() for y in range(h))

    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    head = struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)
    Path(path).write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", head) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def spectro(x, rate, path, height=240, width=600, wave_h=60):
    f, _, z = signal.stft(x, rate, nperseg=1024, noverlap=768)
    mag = 20 * np.log10(np.abs(z) + 1e-9)
    mag = (mag - (mag.max() - 80)) / 80
    rows = np.geomspace(40, rate / 2, height)[::-1]
    idx = np.clip(np.searchsorted(f, rows), 0, len(f) - 1)
    img = mag[idx]
    cols = np.linspace(0, img.shape[1] - 1, width).astype(int)
    img = paint(img[:, cols])
    env = np.zeros((wave_h, width, 3), np.uint8)
    step = max(1, len(x) // width)
    for c in range(width):
        seg = x[c * step : (c + 1) * step]
        a = np.max(np.abs(seg)) if len(seg) else 0
        h = int(a * (wave_h // 2 - 1))
        env[wave_h // 2 - h : wave_h // 2 + h + 1, c] = (120, 200, 255)
    save_png(path, np.concatenate([env, img], axis=0))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+")
    ap.add_argument("--png", action="store_true")
    ap.add_argument("--loop", action="store_true")
    args = ap.parse_args()
    for p in args.files:
        x, rate = load(p)
        s = stats(x, rate, args.loop or "loop" in Path(p).stem)
        print(Path(p).name, " ".join(f"{k}={v}" for k, v in s.items()))
        if args.png:
            spectro(x, rate, Path(p).with_suffix(".png"))


if __name__ == "__main__":
    main()
