import json

import numpy as np
from scipy.interpolate import CubicSpline

from engine2 import transforms, POSE_N, ROT_N
from rig import Rig, pose

GROUND = -3.40
FPS = 60
IDX = {
    "Torso": [0, 1, 2, 3, 4, 5],
    "Head": [6, 7, 8, None, None, None],
    "RightArm": [9, 10, 11, ROT_N + 0, ROT_N + 1, ROT_N + 2],
    "LeftArm": [12, 13, 14, ROT_N + 3, ROT_N + 4, ROT_N + 5],
    "RightLeg": [15, 16, 17, ROT_N + 6, ROT_N + 7, ROT_N + 8],
    "LeftLeg": [18, 19, 20, ROT_N + 9, ROT_N + 10, ROT_N + 11],
    "Sword": [POSE_N + 0, POSE_N + 1, POSE_N + 2, POSE_N + 3, POSE_N + 4, POSE_N + 5],
}
CH = ["rx", "ry", "rz", "px", "py", "pz"]


def curve(keys, n, lag=0.0):
    us = np.array([k[0] for k in keys], float)
    vs = np.array([k[1] for k in keys], float)
    if us[0] > 0 or us[-1] < 1:
        us = np.concatenate([us, [us[0] + 1.0]])
        vs = np.concatenate([vs, [vs[0]]])
    cs = CubicSpline(us, vs, bc_type="periodic")
    u = (np.arange(n) / n - lag - us[0]) % 1.0 + us[0]
    return cs(u)


def spring(x, dt, f, z, r):
    k1 = z / (np.pi * f)
    k2 = 1.0 / ((2 * np.pi * f) ** 2)
    k3 = r * z / (2 * np.pi * f)
    n = len(x)
    y = x[0]
    yd = 0.0
    out = np.empty(n)
    for loop in range(4):
        for i in range(n):
            xp = x[i - 1]
            xd = (x[i] - xp) / dt
            y = y + dt * yd
            yd = yd + dt * (x[i] + k3 * xd - y - k1 * yd) / k2
            if loop == 3:
                out[i] = y
    return out


def build(clip, base):
    T = clip["T"]
    n = int(round(T * FPS))
    th = np.tile(np.array(base, float), (n, 1))
    for joint, chans in clip["keys"].items():
        lag = clip.get("lag", {}).get(joint, 0.0) / T
        for ch, keys in chans.items():
            i = IDX[joint][CH.index(ch)]
            th[:, i] = curve(keys, n, lag)
    for joint, (f, z, r) in clip.get("springs", {}).items():
        for c in range(6):
            i = IDX[joint][c]
            if i is not None and np.ptp(th[:, i]) > 1e-6:
                th[:, i] = spring(th[:, i], 1.0 / FPS, f, z, r)
    return th


def waist(th):
    r = np.radians(th[:, 0])
    th[:, 4] = th[:, 4] + 1.01 * (np.cos(r) - 1)
    th[:, 5] = th[:, 5] + 1.01 * np.sin(r)
    return th


def sole_points(rig, world):
    out = {}
    for part in ("RightLegPants", "LeftLegPants"):
        v = rig.parts[part]["verts"]
        m = world[part]
        w = v @ m[:3, :3].T + m[:3, 3]
        out[part] = w
    return out


def ground_pass(th, rig, mode):
    n = len(th)
    for i in range(n):
        w = rig.solve(transforms(th[i, :POSE_N], th[i, POSE_N:]))
        low = min(p[:, 1].min() for p in sole_points(rig, w).values())
        d = GROUND - low
        if mode == "lowest" or (mode == "no_sink" and d > 0):
            th[i, 4] += d
    return th


def euler(R):
    b = np.arcsin(np.clip(R[0, 2], -1, 1))
    a = np.arctan2(-R[1, 2], R[2, 2])
    c = np.arctan2(-R[0, 1], R[0, 0])
    return np.degrees([a, b, c])


def aim_sword(th, rig, pitch, out_x=0.35):
    grip = []
    for i in range(len(th)):
        ra = pose(*th[i, 9:12])[:3, :3]
        p = np.radians(pitch[i])
        B = np.array([out_x, np.sin(p), np.cos(p)])
        B /= np.linalg.norm(B)
        x = np.cross(np.array([0.0, 1.0, 0.0]), B)
        x /= np.linalg.norm(x)
        y = np.cross(B, x)
        Rs = np.stack([x, y, -B], 1)
        Rt = ra.T @ Rs
        th[i, POSE_N:POSE_N + 3] = euler(Rt)
        th[i, POSE_N + 3:POSE_N + 6] = 0.0
        arm_axis = ra @ np.array([0.0, 1.0, 0.0])
        grip.append(np.degrees(np.arcsin(abs(np.dot(-B, arm_axis)))))
    return th, grip


def export(th, T, path):
    n = len(th)
    m = int(round(T * 30))
    keys = []
    for k in range(m + 1):
        f = k / m * n
        i0 = int(np.floor(f)) % n
        a = f - np.floor(f)
        t = th[i0] * (1 - a) + th[(i0 + 1) % n] * a
        tf = transforms(t[:POSE_N], t[POSE_N:])
        poses = {}
        for j in ("Torso", "Head", "RightArm", "LeftArm", "RightLeg", "LeftLeg", "Sword"):
            M = tf[j]
            poses[j] = [float(x) for x in [M[0, 3], M[1, 3], M[2, 3], M[0, 0], M[0, 1], M[0, 2], M[1, 0], M[1, 1], M[1, 2], M[2, 0], M[2, 1], M[2, 2]]]
        keys.append({"t": min(k / 30.0, T), "poses": poses})
    json.dump({"length": T, "keys": keys}, open(path, "w"))


def foot_report(th, rig, T):
    n = len(th)
    soles = {"RightLegPants": [], "LeftLegPants": []}
    for i in range(n):
        w = rig.solve(transforms(th[i, :POSE_N], th[i, POSE_N:]))
        for part, pts in sole_points(rig, w).items():
            lo = pts[pts[:, 1] < pts[:, 1].min() + 0.05]
            soles[part].append([pts[:, 1].min(), lo[:, 2].mean(), lo[:, 0].mean()])
    rep = {}
    for part, arr in soles.items():
        a = np.array(arr)
        h = a[:, 0] - GROUND
        planted = h < 0.05
        vz = np.gradient(a[:, 2]) * FPS
        rep[part] = {"height min": round(float(h.min()), 3), "height max": round(float(h.max()), 3), "planted %": round(100 * float(planted.mean()), 1), "foot speed back while planted (median)": round(float(np.median(vz[planted])), 2) if planted.any() else None}
    return rep
