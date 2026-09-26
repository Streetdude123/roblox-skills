import argparse
import json
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
import r6_render as rr

TIPS = ['Right Arm', 'Left Arm', 'Right Leg', 'Left Leg', 'Head']


def tip_tracks(clip, fps=60.0, local=False):
    times = rr.frame_times(clip, fps, 0.0, None)
    tracks = {k: [] for k in TIPS}
    torso = []
    for t in times:
        parts = rr.world_parts(clip, t)
        r, p, _ = parts['Torso']
        torso.append((r, p))
        for k in TIPS:
            q = rr.tip_point(parts, k)
            tracks[k].append(r.T @ (q - p) if local else q)
    return np.array(times), {k: np.array(v) for k, v in tracks.items()}, torso


def speed(x, fps, win=2):
    n = len(x)
    out = np.zeros(n)
    for i in range(n):
        a, b = max(0, i - win), min(n - 1, i + win)
        if b > a:
            out[i] = np.linalg.norm(x[b] - x[a]) * fps / (b - a)
    return out


def torso_turn_speed(torso, fps, win=2):
    n = len(torso)
    out = np.zeros(n)
    for i in range(n):
        a, b = max(0, i - win), min(n - 1, i + win)
        if b > a:
            m = torso[a][0].T @ torso[b][0]
            ang = np.degrees(np.arccos(np.clip((np.trace(m) - 1) / 2, -1, 1)))
            out[i] = ang * fps / (b - a)
    return out


def segments(v, rel=0.2, floor=1.5, min_len=3):
    peak = float(v.max()) if len(v) else 0.0
    thr = max(rel * peak, floor)
    moving = v > thr
    segs, start = [], None
    for i, m in enumerate(moving):
        if m and start is None:
            start = i
        if not m and start is not None:
            if i - start >= min_len:
                segs.append((start, i - 1))
            start = None
    if start is not None and len(v) - start >= min_len:
        segs.append((start, len(v) - 1))
    return segs, thr


def split_by_peaks(v, seg, rel_valley=0.55):
    a, b = seg
    sub = v[a:b + 1]
    peaks = [i for i in range(1, len(sub) - 1) if sub[i] >= sub[i - 1] and sub[i] > sub[i + 1]]
    if len(peaks) < 2:
        return [seg]
    cuts = []
    for p, q in zip(peaks, peaks[1:]):
        lo = p + int(np.argmin(sub[p:q + 1]))
        if sub[lo] < rel_valley * min(sub[p], sub[q]):
            cuts.append(lo)
    out, s = [], a
    for c in cuts:
        if a + c - s >= 3:
            out.append((s, a + c))
            s = a + c
    out.append((s, b))
    return out


def moves_of(x, v, fps, rel=0.2, floor=1.5):
    segs, thr = segments(v, rel, floor)
    moves = []
    for seg in segs:
        for a, b in split_by_peaks(v, seg):
            k = a + int(np.argmax(v[a:b + 1]))
            path = float(np.sum(np.linalg.norm(np.diff(x[a:b + 1], axis=0), axis=1)))
            chord = float(np.linalg.norm(x[b] - x[a]))
            moves.append({
                'start': a, 'end': b, 'frames': b - a + 1, 'accel': k - a, 'decel': b - k,
                'peak': round(float(v[k]), 2), 'path': round(path, 3), 'straight': round(chord / path, 2) if path > 1e-6 else 1.0,
            })
    holds = []
    for m0, m1 in zip(moves, moves[1:]):
        gap = m1['start'] - m0['end'] - 1
        if gap >= 2:
            drift = float(np.sum(np.linalg.norm(np.diff(x[m0['end']:m1['start'] + 1], axis=0), axis=1)))
            holds.append({'start': m0['end'] + 1, 'frames': gap, 'drift': round(drift, 3)})
    return moves, holds, thr


def summarize(moves, holds, n):
    if not moves:
        return {'moves': 0}
    med = lambda k, xs: round(float(np.median([m[k] for m in xs])), 2)
    moving = sum(m['frames'] for m in moves)
    return {
        'moves': len(moves),
        'move_frames': med('frames', moves), 'accel_frames': med('accel', moves), 'decel_frames': med('decel', moves),
        'peak_speed': med('peak', moves), 'straightness': med('straight', moves),
        'hold_frames': med('frames', holds) if holds else 0, 'hold_drift': med('drift', holds) if holds else 0,
        'moving_pct': round(100 * moving / max(1, n), 1),
    }


def analyze(path, local=False, rel=0.2, floor=1.5, fps=60.0):
    clip = rr.read_decode(path)
    times, tracks, torso = tip_tracks(clip, fps, local)
    out = {'clip': clip['name'], 'len': round(clip['len'], 3), 'tips': {}}
    for k in TIPS:
        v = speed(tracks[k], fps)
        moves, holds, thr = moves_of(tracks[k], v, fps, rel, floor)
        out['tips'][k] = {'summary': summarize(moves, holds, len(times)), 'moves': moves, 'holds': holds, 'threshold': round(thr, 2)}
    tv = torso_turn_speed(torso, fps)
    tm, th, tthr = moves_of(np.array([p for _, p in torso]), tv, fps, rel, 12.0)
    out['torso_turn'] = {'summary': summarize(tm, th, len(times)), 'peak_deg_s': round(float(tv.max()), 1)}
    return out


def main():
    ap = argparse.ArgumentParser(description='measure moves and holds of the hands, feet and head in R6 decode text')
    ap.add_argument('decodes', nargs='+')
    ap.add_argument('--local', action='store_true', help='measure the tips in torso space, not world space')
    ap.add_argument('--rel', type=float, default=0.2, help='a tip moves above this share of its clip peak speed')
    ap.add_argument('--floor', type=float, default=1.5, help='and above this many studs per second')
    ap.add_argument('--json', action='store_true')
    ap.add_argument('--tip', default='Right Arm,Left Arm')
    a = ap.parse_args()
    rows = [analyze(p, a.local, a.rel, a.floor) for p in a.decodes]
    if a.json:
        print(json.dumps(rows, indent=1))
        return
    tips = a.tip.split(',')
    print('clip                 tip        moves  move_f  accel_f  decel_f  peak_st/s  straight  hold_f  drift  moving%')
    for r in rows:
        for k in tips:
            s = r['tips'][k]['summary']
            if not s.get('moves'):
                print(f"{r['clip'][:20]:20} {k[:10]:10}      0")
                continue
            print(f"{r['clip'][:20]:20} {k[:10]:10} {s['moves']:6d} {s['move_frames']:7.1f} {s['accel_frames']:8.1f} {s['decel_frames']:8.1f} {s['peak_speed']:10.1f} {s['straightness']:9.2f} {s['hold_frames']:7.1f} {s['hold_drift']:6.2f} {s['moving_pct']:8.1f}")


if __name__ == '__main__':
    main()
