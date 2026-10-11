import json
import sys

import numpy as np
from scipy.interpolate import PchipInterpolator
from scipy.optimize import least_squares

from engine2 import transforms, POSE_N, ROT_N
from rig import Rig

GROUND = -3.40
S = 72

WALK = {
    "T": 1.1, "duty": 0.62, "z_contact": -0.75, "z_off": 0.85,
    "lean": -4.0, "lean_osc": 1.0, "yaw": 4.0, "roll": 2.0, "sway": 0.07,
    "bob_base": -0.06, "bob_amp": 0.05, "bob_sign": 1.0,
    "shield_mean": 6.0, "shield_amp": 22.0, "sword_bounce": 2.0,
    "kick": 6.0, "kick_u": 0.06, "lift_kick": 0.14, "pass": 8.0, "pass_u": 0.8, "lift": 0.32, "reach": 24.0, "reach_u": 0.93, "lift_reach": 0.06,
    "toe_out": 6.0, "spring_head": [5.0, 0.55], "spring_arm": [3.2, 0.6], "spring_sword": [4.0, 0.45], "nod": 1.5,
}
RUN = {
    "T": 0.68, "duty": 0.25, "z_contact": -0.95, "z_off": 1.2,
    "lean": -22.0, "lean_osc": 4.0, "yaw": 11.0, "roll": 3.0, "sway": 0.05,
    "bob_base": -0.15, "bob_amp": 0.10, "bob_sign": -1.0,
    "shield_mean": 15.0, "shield_amp": 62.0, "sword_bounce": 6.0,
    "kick": 40.0, "kick_u": 0.11, "lift_kick": 0.55, "pass": 45.0, "pass_u": 0.6, "lift": 0.95, "reach": 82.0, "reach_u": 0.8, "lift_reach": 0.7,
    "toe_out": 5.0, "spring_head": [6.0, 0.55], "spring_arm": [4.5, 0.6], "spring_sword": [5.5, 0.4], "nod": 2.5,
}


def spring(x, T, f0, zeta):
    n = len(x)
    X = np.fft.rfft(x)
    w = 2 * np.pi * np.fft.rfftfreq(n, T / n)
    w0 = 2 * np.pi * f0
    H = w0 ** 2 / (w0 ** 2 - w ** 2 + 2j * zeta * w0 * w)
    return np.fft.irfft(X * H, n)


def sole(world, part, rig):
    v = rig.parts[part]["verts"]
    bot = v[v[:, 1] < v[:, 1].min() + 0.05].mean(0)
    m = world[part]
    return bot @ m[:3, :3].T + m[:3, 3]


def author(P, walk, rig):
    T, duty = P["T"], P["duty"]
    ph = np.arange(S) / S
    mid = duty / 2
    lean = P["lean"] - P["lean_osc"] * np.cos(4 * np.pi * (ph - mid - 0.05))
    yaw = -P["yaw"] * np.cos(2 * np.pi * (ph - 0.02))
    roll = -P["roll"] * np.cos(2 * np.pi * (ph - mid))
    sway = P["sway"] * np.cos(2 * np.pi * (ph - mid))
    bob = P["bob_base"] + P["bob_sign"] * P["bob_amp"] * np.cos(4 * np.pi * (ph - mid))
    bob_n = (bob - bob.mean()) / (np.ptp(bob) / 2 + 1e-9)
    base = np.array(walk[:POSE_N], float)
    sw = np.array(walk[POSE_N:POSE_N + 6], float)
    fh, zh = P["spring_head"]
    fa, za = P["spring_arm"]
    fs, zs = P["spring_sword"]
    head_x = -3.0 - spring(lean, T, fh, zh) + P["nod"] * spring(-bob_n, T, fh, zh)
    head_y = -0.7 * spring(yaw, T, fh, zh)
    head_z = -0.6 * spring(roll, T, fh, zh)
    shield_drive = P["shield_amp"] * np.cos(2 * np.pi * (ph - 0.02))
    shield = P["shield_mean"] + spring(shield_drive, T, fa, za)
    shield_z = -5.0 + 2.5 * spring(np.cos(2 * np.pi * (ph - 0.02)), T, fa, za) - 0.6 * roll
    sword_x = walk[9] + P["sword_bounce"] * spring(bob_n, T, fs, zs)
    sword_y = walk[10] + 0.25 * spring(yaw, T, fs, zs)
    poses = []
    for i in range(S):
        p = base.copy()
        r = np.radians(lean[i])
        p[0:3] = [lean[i], yaw[i], roll[i]]
        p[3:6] = [sway[i], bob[i] + 1.01 * (np.cos(r) - 1), 1.01 * np.sin(r)]
        p[6:9] = [head_x[i], head_y[i], head_z[i]]
        p[9] = sword_x[i]
        p[10] = sword_y[i]
        p[12] = shield[i]
        p[14] = shield_z[i]
        p[16], p[19] = -P["toe_out"], P["toe_out"]
        p[ROT_N:POSE_N] = 0.0
        p[ROT_N:ROT_N + 3] = walk[ROT_N:ROT_N + 3]
        poses.append((p, sw.copy()))
    rest_w = rig.solve(transforms(np.concatenate([np.zeros(ROT_N), np.array(walk[ROT_N:ROT_N + 3]), np.zeros(POSE_N - ROT_N - 3)]), sw))
    lanes = {"R": sole(rest_w, "RightLegPants", rig)[0], "L": sole(rest_w, "LeftLegPants", rig)[0]}
    v = (P["z_off"] - P["z_contact"]) / (duty * T)
    legs = {}
    for side, off in (("R", 0.0), ("L", 0.5)):
        ix = 15 if side == "R" else 18
        it = ROT_N + (6 if side == "R" else 9)
        part = "RightLegPants" if side == "R" else "LeftLegPants"
        u = (ph + off) % 1.0
        st = {}
        guess = np.array([20.0, 0.0, 0.05])
        for i in np.argsort(u):
            if u[i] >= duty:
                continue
            z = P["z_contact"] + v * u[i] * T
            p0, s0 = poses[i]

            def res(q):
                pp = p0.copy()
                pp[ix] = q[0]
                pp[ix + 2] = q[1]
                pp[it + 1] = q[2]
                w = rig.solve(transforms(pp, s0))
                s = sole(w, part, rig)
                return [(s[1] - GROUND) / 0.01, (s[2] - z) / 0.004, (s[0] - lanes[side]) / 0.01]

            guess = least_squares(res, guess, bounds=([-90, -30, -0.1], [90, 30, 1.0]), x_scale=[5, 2, 0.05]).x
            st[i] = guess.copy()
        order = sorted(st, key=lambda j: u[j])
        su = np.array([u[j] for j in order])
        sv = np.array([st[j] for j in order])
        rx_o = sv[-1, 0]
        ku = np.array([su[-2], su[-1], duty + P["kick_u"], P["pass_u"], P["reach_u"], 1.0 + su[0], 1.0 + su[1]])
        fx = PchipInterpolator(ku, [sv[-2, 0], sv[-1, 0], rx_o - P["kick"], P["pass"], P["reach"], sv[0, 0], sv[1, 0]])
        ft = PchipInterpolator(ku, [sv[-2, 2], sv[-1, 2], P["lift_kick"], P["lift"], P["lift_reach"], sv[0, 2], sv[1, 2]])
        fz = PchipInterpolator(np.array([su[-2], su[-1], 1.0 + su[0], 1.0 + su[1]]), [sv[-2, 1], sv[-1, 1], sv[0, 1], sv[1, 1]])
        rx, rz, ty = np.empty(S), np.empty(S), np.empty(S)
        for i in range(S):
            if i in st:
                rx[i], rz[i], ty[i] = st[i]
            else:
                rx[i], rz[i], ty[i] = float(fx(u[i])), float(fz(u[i])), float(ft(u[i]))
        legs[side] = (ix, it, rx, rz, ty)
    thetas = []
    for i, (p, sw_i) in enumerate(poses):
        p = p.copy()
        for side in ("R", "L"):
            ix, it, rx, rz, ty = legs[side]
            p[ix], p[ix + 2], p[it + 1] = rx[i], rz[i], ty[i]
        thetas.append(np.concatenate([p, sw_i]))
    return np.array(thetas), v


def export(thetas, T, path):
    n = int(round(T * 30))
    keys = []
    for k in range(n + 1):
        f = (k / n) * S
        i0 = int(np.floor(f)) % S
        a = f - np.floor(f)
        th = thetas[i0] * (1 - a) + thetas[(i0 + 1) % S] * a
        t = transforms(th[:POSE_N], th[POSE_N:])
        poses = {}
        for j in ("Torso", "Head", "RightArm", "LeftArm", "RightLeg", "LeftLeg", "Sword"):
            m = t[j]
            poses[j] = [float(x) for x in [m[0, 3], m[1, 3], m[2, 3], m[0, 0], m[0, 1], m[0, 2], m[1, 0], m[1, 1], m[1, 2], m[2, 0], m[2, 1], m[2, 2]]]
        keys.append({"t": min(k / 30.0, T), "poses": poses})
    json.dump({"length": T, "keys": keys}, open(path, "w"))


def report(thetas, P, rig):
    T, duty = P["T"], P["duty"]
    v = (P["z_off"] - P["z_contact"]) / (duty * T)
    for side, off, part in (("R", 0.0, "RightLegPants"), ("L", 0.5, "LeftLegPants")):
        hs, slide, swing_min = [], [], []
        prev = None
        for i in range(S):
            u = (i / S + off) % 1
            w = rig.solve(transforms(thetas[i][:POSE_N], thetas[i][POSE_N:]))
            s = sole(w, part, rig)
            if u < duty:
                hs.append(s[1] - GROUND)
                slide.append(s[2] - (P["z_contact"] + v * u * T))
            else:
                swing_min.append(s[1] - GROUND)
        print(f"{side}: stance foot above floor max {max(hs):.3f}, slide max {max(abs(z) for z in slide):.3f}; swing clearance min {min(swing_min):.3f}")
    ty = np.concatenate([thetas[:, ROT_N + 7], thetas[:, ROT_N + 10]])
    print(f"torso height {thetas[:, 4].min():.2f}..{thetas[:, 4].max():.2f}; leg lift {ty.min():.2f}..{ty.max():.2f}; speed at 1.0x {v:.2f} studs/s; cycle {T} s")


if __name__ == "__main__":
    mode = sys.argv[1]
    out = sys.argv[2]
    P = dict(WALK if mode == "walk" else RUN)
    if len(sys.argv) > 3:
        P.update(json.loads(sys.argv[3]))
    walk = json.load(open("walk_mean.json"))["mean"]
    rig = Rig("data")
    thetas, v = author(P, walk, rig)
    np.save(f"{mode}_authored.npy", thetas)
    export(thetas, P["T"], out)
    report(thetas, P, rig)
