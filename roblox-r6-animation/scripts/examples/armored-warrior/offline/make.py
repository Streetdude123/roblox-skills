import json
import sys

import numpy as np
from scipy.optimize import least_squares

from engine2 import transforms, POSE_N, ROT_N
from rig import Rig
from keyanim import IDX, CH, curve, spring, waist, export, GROUND, FPS
from clips import CLIPS

LEGS = {"R": ("RightLeg", "RightLegPants", 0.0), "L": ("LeftLeg", "LeftLegPants", 0.5)}


def base_vector(clip):
    th = np.zeros(POSE_N + 6)
    for joint, vals in clip.get("base", {}).items():
        for c, v in enumerate(vals):
            i = IDX[joint][c]
            if i is not None:
                th[i] = v
    return th


def build(clip):
    T = clip["T"]
    n = int(round(T * FPS))
    th = np.tile(base_vector(clip), (n, 1))
    for joint, chans in clip["keys"].items():
        lag = clip.get("lag", {}).get(joint, 0.0) / T
        for ch, keys in chans.items():
            th[:, IDX[joint][CH.index(ch)]] = curve(keys, n, lag)
    rng = np.random.default_rng(7)
    u = np.arange(n) / n
    for joint, amp in clip.get("life", {}).items():
        for c in range(3):
            i = IDX[joint][c]
            th[:, i] += sum(amp / k * np.sin(2 * np.pi * k * u + rng.uniform(0, 2 * np.pi)) for k in (1, 2, 3)) * 0.6
    for joint, (f, z, r) in clip.get("springs", {}).items():
        for c in range(6):
            i = IDX[joint][c]
            if i is not None and np.ptp(th[:, i]) > 1e-6:
                th[:, i] = spring(th[:, i], 1.0 / FPS, f, z, r)
    return waist(th)


def sole(rig, p, part):
    w = rig.solve(transforms(p[:POSE_N], p[POSE_N:]))
    m = w[part]
    v = rig.parts[part]["verts"]
    pts = v @ m[:3, :3].T + m[:3, 3]
    bot = v[v[:, 1] < v[:, 1].min() + 0.05] @ m[:3, :3].T + m[:3, 3]
    c = bot.mean(0)
    return np.array([c[0], pts[:, 1].min(), c[2]])


def leg_idx(side):
    ix = IDX[LEGS[side][0]][0]
    it = IDX[LEGS[side][0]][4]
    return ix, it


def solve_leg(rig, p, side, target, guess):
    ix, it = leg_idx(side)
    part = LEGS[side][1]

    def res(q):
        pp = p.copy()
        pp[ix], pp[ix + 2], pp[it] = q
        s = sole(rig, pp, part)
        out = [(s[1] - GROUND) / 0.005]
        if target[0] is not None:
            out.append((s[0] - target[0]) / 0.01)
        if target[2] is not None:
            out.append((s[2] - target[2]) / 0.005)
        out += [(q[0] - p[ix]) / 60.0, (q[1] - p[ix + 2]) / 20.0, (q[2] - p[it]) / 2.0]
        return out

    return least_squares(res, guess, bounds=([-100, -40, -0.12], [120, 40, 1.2]), x_scale=[5, 2, 0.05]).x


def windows(clip, n):
    u = np.arange(n) / n
    out = {}
    for side, (_, _, off) in LEGS.items():
        out[side] = ((u - off) % 1.0) / clip["stance"]
    return out


def fit_harmonics(u, y, harm):
    cols = []
    for k in harm:
        if k == 0:
            cols.append(np.ones_like(u))
        else:
            cols += [np.cos(2 * np.pi * k * u), np.sin(2 * np.pi * k * u)]
    A = np.stack(cols, 1)
    c = np.linalg.lstsq(A, y, rcond=None)[0]
    return c, cols


def eval_harmonics(c, u, harm):
    cols = []
    for k in harm:
        if k == 0:
            cols.append(np.ones_like(u))
        else:
            cols += [np.cos(2 * np.pi * k * u), np.sin(2 * np.pi * k * u)]
    return np.stack(cols, 1) @ c


def plant(clip, th, rig):
    n = len(th)
    u = np.arange(n) / n
    info = {}
    if clip["plant"] == "hold":
        mean = th.mean(0)
        need = GROUND - min(sole(rig, mean, LEGS[s][1])[1] for s in LEGS)
        th[:, 4] += need
        mean[4] += need
        targets = {s: sole(rig, mean, LEGS[s][1]) for s in LEGS}
        for s in LEGS:
            ix, it = leg_idx(s)
            g = np.array([mean[ix], mean[ix + 2], mean[it]])
            for i in range(n):
                g = solve_leg(rig, th[i], s, targets[s], g)
                th[i, ix], th[i, ix + 2], th[i, it] = g
        info["targets"] = {s: [round(float(x), 3) for x in targets[s]] for s in targets}
        return th, info
    win = windows(clip, n)
    need = np.full(n, np.nan)
    for s in LEGS:
        for i in range(n):
            if win[s][i] <= 1.0:
                d = GROUND - sole(rig, th[i], LEGS[s][1])[1]
                need[i] = d if np.isnan(need[i]) else max(need[i], d)
    ok = ~np.isnan(need)
    harm = clip.get("bob_fit", [0])
    c, _ = fit_harmonics(u[ok], need[ok], harm)
    th[:, 4] += eval_harmonics(c, u, harm)
    info["bob_fit"] = [round(float(x), 3) for x in c]
    dz = []
    for s in LEGS:
        w = win[s]
        i0 = int(np.argmin(np.where(w <= 1.0, w, 9)))
        i1 = int(np.argmax(np.where(w <= 1.0, w, -1)))
        dz.append(sole(rig, th[i1], LEGS[s][1])[2] - sole(rig, th[i0], LEGS[s][1])[2])
    span = float(np.mean(dz))
    speed = span / (clip["stance"] * clip["T"])
    info["speed"] = round(speed, 2)
    for s in LEGS:
        w = win[s]
        ix, it = leg_idx(s)
        stance = [i for i in np.argsort(w) if w[i] <= 1.0]
        mid = stance[len(stance) // 2]
        lane = sole(rig, th[mid], LEGS[s][1])[0]
        z_mid = sole(rig, th[mid], LEGS[s][1])[2]
        z0 = z_mid - speed * clip["T"] * clip["stance"] * w[mid] + 0.0
        delta = np.zeros((n, 3))
        g = np.array([th[stance[0], ix], th[stance[0], ix + 2], th[stance[0], it]])
        for i in stance:
            tz = z0 + speed * clip["T"] * clip["stance"] * w[i]
            g = solve_leg(rig, th[i], s, (lane, GROUND, tz), g)
            delta[i] = g - np.array([th[i, ix], th[i, ix + 2], th[i, it]])
        inside = np.array([w[i] <= 1.0 for i in range(n)])
        taper = max(2, int(round(0.06 * n)))
        full = delta.copy()
        for i in range(n):
            if inside[i]:
                continue
            best, dist = None, 1e9
            for d in range(1, taper + 1):
                for j in ((i - d) % n, (i + d) % n):
                    if inside[j] and d < dist:
                        best, dist = j, d
            if best is not None:
                a = 0.5 + 0.5 * np.cos(np.pi * dist / (taper + 1))
                full[i] = delta[best] * a
        th[:, ix] += full[:, 0]
        th[:, ix + 2] += full[:, 1]
        th[:, it] += full[:, 2]
    for i in range(n):
        for s in LEGS:
            ix, it = leg_idx(s)
            d = GROUND - sole(rig, th[i], LEGS[s][1])[1]
            if d > 0.002 and win[s][i] > 1.0:
                th[i, it] += d
    return th, info


def report(clip, th, rig):
    n = len(th)
    out = {}
    win = windows(clip, n) if clip["plant"] == "gait" else {s: np.zeros(n) for s in LEGS}
    for s in LEGS:
        part = LEGS[s][1]
        so = np.array([sole(rig, th[i], part) for i in range(n)])
        h = so[:, 1] - GROUND
        st = win[s] <= 1.0
        vz = (np.roll(so[:, 2], -1) - np.roll(so[:, 2], 1)) / 2 * FPS
        vx = (np.roll(so[:, 0], -1) - np.roll(so[:, 0], 1)) / 2 * FPS
        ix, it = leg_idx(s)
        out[s] = {
            "planted height": [round(float(h[st].min()), 3), round(float(h[st].max()), 3)],
            "swing clearance min": round(float(h[~st].min()), 3) if (~st).any() else None,
            "swing height max": round(float(h.max()), 3),
            "planted vz": [round(float(np.percentile(vz[st], 5)), 2), round(float(np.percentile(vz[st], 95)), 2)],
            "planted vx": [round(float(np.percentile(vx[st], 5)), 2), round(float(np.percentile(vx[st], 95)), 2)],
            "leg rx": [round(float(th[:, ix].min()), 1), round(float(th[:, ix].max()), 1)],
            "leg ty": [round(float(th[:, it].min()), 3), round(float(th[:, it].max()), 3)],
        }
    out["torso py"] = [round(float(th[:, 4].min()), 3), round(float(th[:, 4].max()), 3)]
    return out


if __name__ == "__main__":
    name = sys.argv[1]
    clip = CLIPS[name]
    rig = Rig("data")
    th = build(clip)
    th, info = plant(clip, th, rig)
    np.save(f"new_{name}.npy", th)
    export(th, clip["T"], f"serve/new_{name}_keys.json")
    print(json.dumps(info))
    print(json.dumps(report(clip, th, rig), indent=1))
