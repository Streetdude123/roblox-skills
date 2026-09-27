import argparse
import subprocess
import sys
from pathlib import Path

import imageio_ffmpeg
import numpy as np
from PIL import Image

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
FF = imageio_ffmpeg.get_ffmpeg_exe()
HERE = Path(__file__).parent


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rec")
    ap.add_argument("log")
    ap.add_argument("--scale", type=float, required=True)
    ap.add_argument("--length", type=float, required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--lead", type=float, default=0.0)
    ap.add_argument("--gap", type=float, default=150)
    ap.add_argument("--gain", type=float, default=0)
    ap.add_argument("--frozen", type=float, default=0)
    ap.add_argument("--frozen-min", type=float, default=800)
    args = ap.parse_args()

    rec = Path(args.rec)
    lines = (rec / "times.txt").read_text().split("\n")
    start = float(lines[0].split()[1])
    frames = []
    for line in lines[1:]:
        part = line.split()
        if len(part) == 2:
            frames.append((int(part[0]), start + float(part[1])))
    frames.sort()

    log = Path(args.log).read_text(encoding="utf-8").splitlines()
    cine = [float(l.split("|")[1]) for l in log if l.startswith("CINE|")]
    t0 = cine[0] - args.lead * 1000 * args.scale
    end = t0 + (args.length + args.lead) * 1000 * args.scale

    keep = [(i, ms) for i, ms in frames if t0 - 200 <= ms <= end + 200]
    gaps = []
    for (_, a), (_, b) in zip(keep, keep[1:]):
        if b - a > args.gap:
            gaps.append((a, b - a - 60))
    if args.frozen:
        prev, run = None, None
        for i, ms in keep:
            img = np.asarray(Image.open(rec / f"f{i:05d}.jpg").convert("L").resize((96, 40)), np.float32)
            still = prev is not None and np.abs(img - prev).mean() < args.frozen
            if still and run is None:
                run = last_ms
            if not still and run is not None:
                if ms - run > max(args.gap, args.frozen_min):
                    gaps.append((run, ms - run - 60))
                run = None
            prev, last_ms = img, ms
        spans = []
        for g0, g in sorted(gaps):
            if spans and g0 <= spans[-1][1]:
                spans[-1][1] = max(spans[-1][1], g0 + g)
            else:
                spans.append([g0, g0 + g])
        gaps = [(a, b - a) for a, b in spans]

    def squeeze(ms):
        cut = 0
        for g0, g in gaps:
            if ms > g0:
                cut += min(g, ms - g0)
        return ms - cut

    keep = [(i, squeeze(ms)) for i, ms in keep]
    t0 = squeeze(t0)
    end = squeeze(end)
    remap = []
    for line in log:
        part = line.split("|")
        if part[0] in ("SFX", "FADE", "CINE"):
            part[-1] = str(int(squeeze(float(part[-1]))))
        remap.append("|".join(part))
    squeezed = Path(args.out).with_suffix(".log")
    squeezed.write_text("\n".join(remap) + "\n", encoding="utf-8")
    listing = []
    for k, (i, ms) in enumerate(keep):
        nxt = keep[k + 1][1] if k + 1 < len(keep) else ms + 40
        dur = max(0.001, (nxt - ms) / 1000 / args.scale)
        listing.append(f"file '{(rec / f'f{i:05d}.jpg').as_posix()}'\nduration {dur:.5f}")
    listing.append(f"file '{(rec / f'f{keep[-1][0]:05d}.jpg').as_posix()}'")
    lst = Path(args.out).with_suffix(".txt")
    lst.write_text("\n".join(listing) + "\n", encoding="utf-8")
    first = (keep[0][1] - t0) / 1000 / args.scale

    video = Path(args.out).with_suffix(".video.mp4")
    subprocess.run([FF, "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", str(lst), "-vf", "fps=30,scale=trunc(iw/2)*2:trunc(ih/2)*2", "-c:v", "libx264", "-preset", "slow", "-crf", "16", "-pix_fmt", "yuv420p", str(video)], check=True)

    audio = Path(args.out).with_suffix(".wav")
    subprocess.run([sys.executable, str(HERE / "mix.py"), str(squeezed), str(HERE / "cues.json"), "--start", str(t0 + first * 1000 * args.scale), "--scale", str(args.scale), "--length", str(args.length + args.lead), "--out", str(audio), "--gain", str(args.gain)], check=True)

    subprocess.run([FF, "-y", "-loglevel", "error", "-i", str(video), "-i", str(audio), "-c:v", "copy", "-c:a", "aac", "-b:a", "224k", "-shortest", str(args.out)], check=True)
    fps = len(keep) / ((keep[-1][1] - keep[0][1]) / 1000 / args.scale)
    print(f"wrote {args.out}: {len(keep)} frames, {fps:.1f} source fps after retime, first frame {first:.3f} s, {len(gaps)} gaps cut ({sum(g for _, g in gaps) / 1000:.2f} s real)")


if __name__ == "__main__":
    main()
