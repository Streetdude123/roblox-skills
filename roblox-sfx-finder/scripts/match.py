import sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
import argparse
import json
import subprocess
from pathlib import Path

import imageio_ffmpeg
import numpy as np

RATE = 48000
N = 2048
EDGES = [40, 150, 400, 1000, 2500, 5000, 10000, 16000, 22000]
WIN = np.hanning(N)


def load(path):
    raw = subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), "-v", "quiet", "-i", str(path), "-ac", "1", "-ar", str(RATE), "-f", "f32le", "-"], capture_output=True).stdout
    return np.frombuffer(raw, np.float32).astype(float)


def onset(x):
    k = int(RATE * 0.005)
    m = len(x) // k
    e = np.sqrt(np.mean(x[: m * k].reshape(m, k) ** 2, axis=1))
    return int(np.argmax(e > e.max() * 0.1)) * k / RATE


def bands(x, t0, t1):
    f = np.fft.rfftfreq(N, 1 / RATE)
    acc = np.zeros(len(EDGES) - 1)
    cn = cd = 0.0
    for t in np.arange(t0, t1, 0.01):
        c = int(t * RATE) - N // 2
        seg = np.zeros(N)
        a, b = max(0, c), min(len(x), c + N)
        if b > a:
            seg[a - c : b - c] = x[a:b]
        p = np.abs(np.fft.rfft(seg * WIN)) ** 2
        p[0] = 0
        cn += np.sum(f * p)
        cd += np.sum(p)
        for i in range(len(acc)):
            acc[i] += np.sum(p[(f >= EDGES[i]) & (f < EDGES[i + 1])])
    tot = acc.sum() + 1e-20
    return dict(centroid=int(cn / (cd + 1e-20)), bands=[round(float(10 * np.log10(v / tot + 1e-12)), 1) for v in acc[:7]])


def score(m, target):
    d = np.mean(np.abs(np.array(m["bands"][:7]) - np.array(target["bands"])))
    c = abs(np.log2(max(m["centroid"], 20) / target["centroid"])) * 6
    return round(float(d + c), 1)


def main():
    ap = argparse.ArgumentParser(description="Score audio files against measured reference windows.")
    ap.add_argument("targets", help='JSON: {"name": {"centroid": Hz, "bands": [7 dB values], "from": s, "to": s}}; from/to are seconds after the file onset')
    ap.add_argument("files", nargs="+")
    ap.add_argument("--top", type=int, default=10)
    args = ap.parse_args()
    targets = json.loads(Path(args.targets).read_text(encoding="utf-8"))
    rows = {k: [] for k in targets}
    for f in args.files:
        x = load(f)
        if len(x) < RATE * 0.05:
            continue
        t0 = onset(x)
        for k, tg in targets.items():
            m = bands(x, t0 + tg.get("from", 0), t0 + tg.get("to", 0.5))
            rows[k].append((score(m, tg), f, m["centroid"], m["bands"]))
    for k, r in rows.items():
        r.sort()
        print("==", k)
        for s, f, c, b in r[: args.top]:
            print(f"  {s:5} {Path(f).name[:60]:60} c={c} {b}")


if __name__ == "__main__":
    main()
