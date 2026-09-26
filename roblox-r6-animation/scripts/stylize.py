import argparse
import json
import math
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
import r6_render as rr
import bvh_to_r6 as bt

JOINTS = ['Torso', 'Head', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg']


def dense(clip, fps=60.0):
    times = rr.frame_times(clip, fps, 0.0, None)
    samples = []
    for t in times:
        pose = {}
        for name in JOINTS:
            pose[name] = rr.sample(clip['joints'].get(name, []), t)
        samples.append(pose)
    return np.array(times), samples




def gauss_kernel(sigma):
    r = max(1, int(math.ceil(3 * sigma)))
    t = np.arange(-r, r + 1)
    g = np.exp(-0.5 * (t / sigma) ** 2)
    return g / g.sum()


def dominant_sigma(x, i, win=32, lo=1.5, hi=12.0):
    a, b = max(0, i - win // 2), min(len(x), i + win // 2)
    seg = np.diff(x[a:b])
    if len(seg) < 8 or np.allclose(seg, 0):
        return hi
    spec = np.abs(np.fft.rfft(seg - seg.mean()))
    k = int(np.argmax(spec[1:])) + 1
    omega = 2 * math.pi * k / len(seg)
    return float(np.clip(1 / omega, lo, hi))


def cartoon(x, amp=3.0, sigma=None):
    acc = np.gradient(np.gradient(x))
    out = x.copy()
    n = len(x)
    sig = [sigma] * n if sigma else [dominant_sigma(x, i) for i in range(n)]
    for i in range(n):
        g = gauss_kernel(sig[i])
        r = len(g) // 2
        lo, hi = max(0, i - r), min(n, i + r + 1)
        w = g[r - (i - lo): r + (hi - i)]
        out[i] = x[i] - amp * float(np.dot(acc[lo:hi], w))
    return out


def moving_mean(x, w):
    if w <= 1:
        return x.copy()
    pad = np.pad(x, (w // 2, w - 1 - w // 2), mode='edge')
    return np.convolve(pad, np.ones(w) / w, mode='valid')


def exaggerate(x, gain, window):
    base = moving_mean(x, window)
    return base + gain * (x - base)


def qmul(a, b):
    w1, x1, y1, z1 = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
    w2, x2, y2, z2 = b[..., 0], b[..., 1], b[..., 2], b[..., 3]
    return np.stack([w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2, w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2,
                     w1 * y2 - x1 * z2 + y1 * w2 + z1 * x2, w1 * z2 + x1 * y2 - y1 * x2 + z1 * w2], axis=-1)


def qconj(q):
    return q * np.array([1, -1, -1, -1])


def qlog(q):
    v = q[..., 1:]
    n = np.linalg.norm(v, axis=-1, keepdims=True)
    ang = 2 * np.arctan2(n, q[..., :1])
    return np.where(n > 1e-9, v / np.maximum(n, 1e-12) * ang, 2 * v)


def qexp(r):
    ang = np.linalg.norm(r, axis=-1, keepdims=True)
    half = ang / 2
    axis = np.where(ang > 1e-9, r / np.maximum(ang, 1e-12), 0.0)
    return np.concatenate([np.cos(half), axis * np.sin(half)], axis=-1)


def continuous(q):
    q = q.copy()
    for i in range(1, len(q)):
        if np.dot(q[i], q[i - 1]) < 0:
            q[i] = -q[i]
    return q


def smooth_quats(q, w):
    pad = np.pad(q, ((w // 2, w - 1 - w // 2), (0, 0)), mode='edge')
    k = np.ones(w) / w
    m = np.stack([np.convolve(pad[:, c], k, mode='valid') for c in range(4)], axis=1)
    return m / np.linalg.norm(m, axis=1, keepdims=True)


def split(samples):
    out = {}
    for name in samples[0]:
        q = continuous(np.array([rr.mat_to_quat(pose[name][0]) for pose in samples]))
        p = np.array([pose[name][1] for pose in samples])
        out[name] = (q, p)
    return out


def join(tracks):
    n = len(next(iter(tracks.values()))[0])
    return [{name: (rr.quat_to_mat(q[i] / np.linalg.norm(q[i])), p[i]) for name, (q, p) in tracks.items()} for i in range(n)]


def stylize_tracks(tracks, fps, amp=0.0, gain=1.0, window=45, root_y=True):
    out = {}
    for name, (q, p) in tracks.items():
        base = smooth_quats(q, window)
        d = qlog(qmul(qconj(base), q))
        d = d * gain
        if amp > 0:
            d = np.stack([cartoon(d[:, c], amp) for c in range(3)], axis=1)
        p = p.copy()
        if name == 'Torso':
            if gain != 1.0:
                p[:, 1] = exaggerate(p[:, 1], gain, window)
            if amp > 0 and root_y:
                p[:, 1] = cartoon(p[:, 1], amp)
        out[name] = (continuous(qmul(base, qexp(d))), p)
    return out


def tracks_speed(tracks, fps):
    v = None
    for name, (q, p) in tracks.items():
        dq = qmul(qconj(q[:-1]), q[1:])
        ang = np.linalg.norm(qlog(dq), axis=1) * fps
        ang = np.degrees(np.concatenate([ang, ang[-1:]]))
        mv = np.linalg.norm(np.diff(p, axis=0), axis=1) * fps
        mv = np.concatenate([mv, mv[-1:]])
        s = ang + 30 * mv
        v = s if v is None else v + s
    return v


def resample_tracks(tracks, src):
    out = {}
    for name, (q, p) in tracks.items():
        n = len(q)
        qs, ps = [], []
        for t in src:
            a = min(n - 2, int(math.floor(t)))
            u = t - a
            qs.append(rr.slerp(q[a], q[a + 1], u))
            ps.append(p[a] + (p[a + 1] - p[a]) * u)
        out[name] = (continuous(np.array(qs)), np.array(ps))
    return out



def key_frames(speed, min_gap=6, prominence=0.15):
    n = len(speed)
    peak = speed.max() if n else 0
    keys = [0]
    for i in range(1, n - 1):
        if speed[i] <= speed[i - 1] and speed[i] < speed[i + 1]:
            left = speed[max(keys[-1], i - 30):i + 1].max()
            right = speed[i:min(n, i + 31)].max()
            if min(left, right) - speed[i] >= prominence * peak and i - keys[-1] >= min_gap:
                keys.append(i)
    if n - 1 - keys[-1] >= min_gap:
        keys.append(n - 1)
    else:
        keys[-1] = n - 1
    return keys


def siso_times(keys, strength):
    ts = []
    for a, b in zip(keys, keys[1:]):
        m = b - a
        for j in range(m):
            u = j / m
            e = u - strength * math.sin(2 * math.pi * u) / (2 * math.pi)
            ts.append(a + m * e)
    ts.append(float(keys[-1]))
    return np.array(ts)


def speed_warp_times(speed, gamma, lo, hi):
    med = max(np.median(speed), 1e-6)
    rate = np.clip((speed / med) ** gamma, lo, hi)
    step = rate / rate.mean()
    t = np.concatenate([[0.0], np.cumsum(step[:-1])])
    return t * (len(speed) - 1) / t[-1]




def main():
    ap = argparse.ArgumentParser(description='push dense R6 motion toward a keyed animation style')
    ap.add_argument('decode')
    ap.add_argument('out')
    ap.add_argument('--name')
    ap.add_argument('--gain', type=float, default=1.0, help='exaggerate joint angles around their 0.75 s moving average')
    ap.add_argument('--window', type=int, default=45)
    ap.add_argument('--cartoon', type=float, default=0.0, help='cartoon animation filter strength (Wang et al. 2006 used 3)')
    ap.add_argument('--siso', type=float, default=0.0, help='slow in and slow out at the extremes, 0 to 1 (White et al. 2006)')
    ap.add_argument('--snap', type=float, default=0.0, help='play fast parts faster and slow parts slower, e.g. 0.6')
    ap.add_argument('--fps', type=float, default=60)
    a = ap.parse_args()
    clip = rr.read_decode(a.decode)
    times, samples = dense(clip, a.fps)
    tracks = stylize_tracks(split(samples), a.fps, a.cartoon, a.gain, a.window)
    info = {}
    if a.snap > 0:
        tracks = resample_tracks(tracks, speed_warp_times(tracks_speed(tracks, a.fps), a.snap, 0.5, 2.5))
    if a.siso > 0:
        keys = key_frames(tracks_speed(tracks, a.fps))
        info['keys'] = [round(k / a.fps, 3) for k in keys]
        tracks = resample_tracks(tracks, siso_times(keys, a.siso))
    name = a.name or clip['name'] + 'Styled'
    out_samples = join(tracks)
    length = (len(out_samples) - 1) / a.fps
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    (out / f'{name}.txt').write_text(bt.decode_text(name, out_samples, a.fps, length))
    lua, counts = bt.lua_clip(name, out_samples, a.fps, length)
    (out / f'{name}.lua').write_text(lua)
    info.update({'name': name, 'length': round(length, 3), 'keys_per_joint': counts})
    print(json.dumps(info))


if __name__ == '__main__':
    main()
