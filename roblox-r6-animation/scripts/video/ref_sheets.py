import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys


def ffmpeg_path():
    found = shutil.which('ffmpeg')
    if found:
        return found
    try:
        import imageio_ffmpeg
    except ImportError:
        sys.exit('needs ffmpeg on PATH or pip install imageio-ffmpeg')
    return imageio_ffmpeg.get_ffmpeg_exe()


def probe_fps(ffmpeg, video):
    out = subprocess.run([ffmpeg, '-hide_banner', '-i', str(video)], capture_output=True, text=True).stderr
    for part in out.replace(',', '\n').splitlines():
        part = part.strip()
        if part.endswith(' fps'):
            return float(part[:-4])
    return 60.0


def extract(ffmpeg, video, folder, width, start, end):
    folder.mkdir(parents=True, exist_ok=True)
    cmd = [ffmpeg, '-hide_banner', '-loglevel', 'error']
    if start is not None:
        cmd += ['-ss', str(start)]
    if end is not None:
        cmd += ['-to', str(end)]
    cmd += ['-i', str(video), '-vf', f'scale={width}:-2', '-q:v', '3', str(folder / '%05d.jpg')]
    subprocess.run(cmd, check=True)
    return sorted(folder.glob('*.jpg'))


def frame_stats(paths):
    import numpy as np
    from PIL import Image
    diffs, corrs = [], []
    prev = small_prev = None
    for p in paths:
        im = Image.open(p).convert('L')
        g = np.asarray(im.resize((160, 90)), dtype=np.float32)
        s = np.asarray(im.resize((48, 27)), dtype=np.float32).ravel()
        if prev is None:
            diffs.append(0.0)
            corrs.append(1.0)
        else:
            diffs.append(float(np.abs(g - prev).mean()))
            a, b = s - s.mean(), small_prev - small_prev.mean()
            corrs.append(float((a * b).sum() / (np.sqrt((a * a).sum() * (b * b).sum()) + 1e-6)))
        prev, small_prev = g, s
    return diffs, corrs


def unique_frames(diffs, dup=0.3):
    return [i for i, d in enumerate(diffs) if i == 0 or d >= dup]


def capture_fps(diffs, fps, dup=0.3):
    if not diffs:
        return 0.0
    return fps * len(unique_frames(diffs, dup)) / len(diffs)


def cluster(frames, gap=8):
    out = []
    for f in frames:
        if out and f - out[-1][1] <= gap:
            out[-1][1] = f
        else:
            out.append([f, f])
    return out


def cuts(uniq, corrs, low=0.35):
    return [i for i in uniq if i > 0 and corrs[i] < low]


def static_runs(uniq, diffs, fps, still=1.0, least=0.3):
    runs, start = [], None
    for k, i in enumerate(uniq):
        quiet = k > 0 and diffs[i] < still
        if quiet and start is None:
            start = uniq[k - 1]
        if not quiet and start is not None:
            if (uniq[k - 1] - start) / fps >= least:
                runs.append([start, uniq[k - 1]])
            start = None
    if start is not None and (uniq[-1] - start) / fps >= least:
        runs.append([start, uniq[-1]])
    return runs


def sheets(paths, picks, fps, offset, out, prefix, cols, rows, w, h):
    from PIL import Image, ImageDraw
    out.mkdir(parents=True, exist_ok=True)
    made = []
    per = cols * rows
    for s in range(0, len(picks), per):
        group = picks[s:s + per]
        img = Image.new('RGB', (w * cols, h * ((len(group) + cols - 1) // cols)), 'black')
        draw = ImageDraw.Draw(img)
        for k, i in enumerate(group):
            x, y = (k % cols) * w, (k // cols) * h
            img.paste(Image.open(paths[i]).resize((w, h)), (x, y))
            draw.rectangle([x, y, x + 92, y + 12], fill='black')
            draw.text((x + 2, y + 1), f'{i + 1} {offset + i / fps:.2f}s', fill='yellow')
        name = out / f'{prefix}{s // per:02d}_{group[0] + 1}-{group[-1] + 1}.jpg'
        img.save(name, quality=86)
        made.append(name.name)
    return made


def main():
    ap = argparse.ArgumentParser(description='frame by frame study sheets for a reference video')
    ap.add_argument('video')
    ap.add_argument('out')
    ap.add_argument('--from', dest='start', type=float)
    ap.add_argument('--to', dest='end', type=float)
    ap.add_argument('--width', type=int, default=480)
    ap.add_argument('--cols', type=int, default=8)
    ap.add_argument('--rows', type=int, default=6)
    ap.add_argument('--thumb', type=int, default=240)
    ap.add_argument('--all', action='store_true', help='sheet every frame, duplicates included')
    a = ap.parse_args()

    out = Path(a.out)
    ffmpeg = ffmpeg_path()
    fps = probe_fps(ffmpeg, a.video)
    paths = extract(ffmpeg, a.video, out / 'frames', a.width, a.start, a.end)
    if not paths:
        sys.exit('no frames extracted')
    diffs, corrs = frame_stats(paths)
    uniq = unique_frames(diffs)
    events = cluster(cuts(uniq, corrs))
    holds = static_runs(uniq, diffs, fps)
    offset = a.start or 0.0
    th = a.thumb * 9 // 16
    made = sheets(paths, list(range(len(paths))) if a.all else uniq, fps, offset, out, 'sheet', a.cols, a.rows, a.thumb, th)

    report = {
        'video': str(a.video), 'fps': fps, 'frames': len(paths), 'unique': len(uniq),
        'capture_fps': round(capture_fps(diffs, fps), 1),
        'cuts_or_flashes': [{'from': round(offset + s / fps, 3), 'to': round(offset + e / fps, 3), 'frames': [s + 1, e + 1]} for s, e in events],
        'static_runs': [{'from': round(offset + s / fps, 3), 'to': round(offset + e / fps, 3), 'seconds': round((e - s) / fps, 3)} for s, e in holds],
        'sheets': made,
    }
    (out / 'report.json').write_text(json.dumps(report, indent=1))
    print(f"{report['frames']} frames at {fps:g} fps, {report['unique']} unique, capture about {report['capture_fps']} fps")
    print(f"{len(events)} cut or flash events, {len(holds)} static runs, {len(made)} sheets in {out}")
    for e in report['cuts_or_flashes']:
        print(f"  cut/flash {e['from']:.2f}-{e['to']:.2f}s")
    for r in report['static_runs']:
        print(f"  static {r['from']:.2f}-{r['to']:.2f}s ({r['seconds']:.2f}s)")


if __name__ == '__main__':
    main()
