import argparse
import json
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
import bvh_to_r6 as bt


def resample(P, dt, fps=60.0):
    n = len(P['hips'])
    t0 = np.arange(n) * dt
    t1 = np.arange(0, t0[-1] + 1e-9, 1 / fps)
    return {k: np.stack([np.interp(t1, t0, v[:, c]) for c in range(3)], axis=1) for k, v in P.items()}, t1


def smooth(x, k=3):
    if k <= 1:
        return x
    w = np.ones(k) / k
    pad = np.pad(x, ((k // 2, k // 2),) + ((0, 0),) * (x.ndim - 1), mode='edge')
    if x.ndim == 1:
        return np.convolve(pad, w, mode='valid')
    return np.stack([np.convolve(pad[:, c], w, mode='valid') for c in range(x.shape[1])], axis=1)


def vel(x, fps):
    v = np.gradient(x, axis=0) * fps
    return np.linalg.norm(v, axis=1) if v.ndim == 2 else v


def yaw_series(a, b):
    d = b - a
    return np.unwrap(np.arctan2(d[:, 0], d[:, 2]))


def local_minima(x):
    return [i for i in range(1, len(x) - 1) if x[i] <= x[i - 1] and x[i] < x[i + 1]]


def strikes(P, fps, limb):
    if limb.startswith('arm'):
        side = limb[-1]
        root, end = P[f'shoulder_{side}'], P[f'wrist_{side}']
    else:
        side = limb[-1]
        root, end = P[f'hip_{side}'], P[f'ankle_{side}']
    u, r, b = bt.torso_frames(P)
    fwd = -b
    d = end - root
    length = np.percentile(np.linalg.norm(d, axis=1), 99)
    e = smooth(np.linalg.norm(d, axis=1) / length, 3)
    reach = np.sum(d * fwd, axis=1) / length
    speed = smooth(vel(end, fps), 3)
    hips_yaw = yaw_series(P['hip_l'], P['hip_r'])
    sh_yaw = yaw_series(P['shoulder_l'], P['shoulder_r'])
    hy = np.abs(np.gradient(hips_yaw)) * fps
    sy = np.abs(np.gradient(sh_yaw)) * fps
    mins = local_minima(e)
    out = []
    for p in range(2, len(e) - 2):
        if not (e[p] >= e[p - 1] and e[p] > e[p + 1] and e[p] > 0.85):
            continue
        if limb.startswith('arm') and reach[p] < 0.55:
            continue
        if limb.startswith('leg') and end[p, 1] < 0.9:
            continue
        prev = [m for m in mins if m < p]
        if not prev:
            continue
        s = prev[-1]
        if e[p] - e[s] < 0.2:
            continue
        nxt = [m for m in mins if m > p]
        r_end = nxt[0] if nxt else len(e) - 1
        pre = [m for m in range(max(0, s - 36), s) if e[m] >= e[s] + 0.03]
        wind = 0
        if pre:
            wind = s - pre[-1]
        k = s + int(np.argmax(speed[s:p + 3]))
        lo, hi = max(0, s - 24), min(len(e) - 1, p + 6)
        hk = lo + int(np.argmax(hy[lo:hi]))
        sk = lo + int(np.argmax(sy[lo:hi]))
        hold = sum(1 for i in range(s, r_end + 1) if e[i] >= e[p] - 0.03)
        out.append({
            'peak_frame': p, 'strike_frames': p - s, 'windup_frames': wind, 'return_frames': r_end - p,
            'hold_frames': hold, 'extension_gain': round(float(e[p] - e[s]), 2),
            'peak_speed': round(float(speed[k]), 1), 'speed_peak_before_reach': p - k,
            'hips_lead': k - hk, 'shoulders_lead': k - sk,
        })
    return out


def jumps(P, fps):
    hip = smooth(0.5 * (P['hip_l'][:, 1] + P['hip_r'][:, 1]), 3)
    foot = np.minimum(np.minimum(P['toe_l'][:, 1], P['ankle_l'][:, 1]), np.minimum(P['toe_r'][:, 1], P['ankle_r'][:, 1]))
    stand = np.percentile(hip, 75)
    air = foot > 0.25
    out = []
    i = 0
    n = len(hip)
    while i < n:
        if air[i]:
            j = i
            while j < n and air[j]:
                j += 1
            if j - i >= 6 and i > 20 and j < n - 10:
                w0 = max(0, i - 48)
                c = w0 + int(np.argmin(hip[w0:i]))
                cs = c
                while cs > w0 and hip[cs - 1] > hip[cs] + 1e-4:
                    cs -= 1
                w1 = min(n, j + 48)
                l = j + int(np.argmin(hip[j:w1]))
                rec = l
                while rec < n - 1 and hip[rec] < stand - 0.05:
                    rec += 1
                out.append({
                    'crouch_frames': c - cs, 'crouch_to_takeoff': i - c, 'crouch_depth': round(float(stand - hip[c]), 2),
                    'air_frames': j - i, 'apex_height': round(float(hip[i:j].max() - stand), 2),
                    'landing_to_lowest': l - j, 'landing_depth': round(float(stand - hip[l]), 2), 'recovery_frames': rec - l,
                })
            i = j
        else:
            i += 1
    return out


def gait(P, fps):
    hipmid = 0.5 * (P['hip_l'] + P['hip_r'])
    v = np.gradient(hipmid[:, [0, 2]], axis=0) * fps
    spd = np.linalg.norm(v, axis=1)
    moving = spd > 0.5 * np.median(spd[spd > np.percentile(spd, 50)])
    if moving.sum() < 30:
        return {}
    fl, fr = P['ankle_l'][:, 1], P['ankle_r'][:, 1]
    contacts = []
    for name, f in (('l', fl), ('r', fr)):
        lo = np.percentile(f[moving], 10)
        down = f < lo + 0.08
        for i in range(1, len(f)):
            if down[i] and not down[i - 1] and moving[i]:
                contacts.append((i, name))
    contacts.sort()
    steps = [b[0] - a[0] for a, b in zip(contacts, contacts[1:]) if a[1] != b[1]]
    u, r, b = bt.torso_frames(P)
    up = np.array([0, 1, 0.0])
    lean = np.degrees(np.arcsin(np.clip(np.sum(-b * up, axis=1), -1, 1)))
    side_lean = np.degrees(np.arcsin(np.clip(np.sum(r * up, axis=1), -1, 1)))
    hy = yaw_series(P['hip_l'], P['hip_r'])
    sy = yaw_series(P['shoulder_l'], P['shoulder_r'])
    twist = np.degrees(sy - hy)
    arm = {}
    for side in 'lr':
        d = P[f'wrist_{side}'] - P[f'shoulder_{side}']
        ang = np.degrees(np.arctan2(np.sum(d * -b, axis=1), -np.sum(d * u, axis=1)))
        arm[side] = float(np.percentile(ang[moving], 95) - np.percentile(ang[moving], 5))
    head = P['head'][:, 1] - hipmid[:, 1]
    m = moving
    step_frames = float(np.median(steps)) if steps else 0.0
    return {
        'speed': round(float(np.median(spd[m])), 2),
        'step_frames': step_frames,
        'cadence_steps_s': round(fps / step_frames, 2) if step_frames else 0,
        'stride_studs': round(float(np.median(spd[m])) * 2 * step_frames / fps, 2) if step_frames else 0,
        'bob': round(float(np.percentile(hipmid[m, 1], 95) - np.percentile(hipmid[m, 1], 5)), 3),
        'lean_deg': round(float(np.median(lean[m])), 1),
        'side_sway_deg': round(float(np.percentile(side_lean[m], 95) - np.percentile(side_lean[m], 5)), 1),
        'twist_deg': round(float(np.percentile(twist[m], 95) - np.percentile(twist[m], 5)), 1),
        'arm_swing_deg': round((arm['l'] + arm['r']) / 2, 1),
        'head_bob': round(float(np.percentile(head[m], 95) - np.percentile(head[m], 5)), 3),
    }


def main():
    ap = argparse.ArgumentParser(description='measure strikes, jumps and gait on motion capture scaled to R6 studs')
    ap.add_argument('mode', choices=['strikes', 'jumps', 'gait'])
    ap.add_argument('bvh', nargs='+')
    ap.add_argument('--from', dest='start', type=float, default=0.0)
    ap.add_argument('--to', dest='end', type=float)
    a = ap.parse_args()
    rows = []
    for path in a.bvh:
        P, _, dt, info = bt.load_positions(path, a.start, a.end)
        P, _ = resample(P, dt)
        name = Path(path).stem
        if a.mode == 'strikes':
            for limb in ('arm_l', 'arm_r', 'leg_l', 'leg_r'):
                for s in strikes(P, 60.0, limb):
                    rows.append({'clip': name, 'limb': limb, **s})
        elif a.mode == 'jumps':
            for j in jumps(P, 60.0):
                rows.append({'clip': name, **j})
        else:
            rows.append({'clip': name, **gait(P, 60.0)})
    print(json.dumps(rows))


if __name__ == '__main__':
    main()
