import itertools
import numpy as np
from scipy.optimize import least_squares
from rig import Rig
from engine2 import transforms, POSE_N
from keyanim import euler
from clips import RA_CARRY, RA_CARRY_T, SW_CARRY

rig = Rig("data")
SV = rig.parts["Sword"]["verts"]
HV = rig.parts["Head"]["verts"]


def world(ra, sw):
    p = np.zeros(POSE_N)
    p[9:12] = ra[:3]
    p[21:24] = ra[3:]
    return rig.solve(transforms(p, sw))


def pts(w, part):
    v = rig.parts[part]["verts"]
    m = w[part]
    return v @ m[:3, :3].T + m[:3, 3]


def solve_arm(top, tilt, side):
    def res(q):
        w = world(q, SW_CARRY)
        a = pts(w, "RightArm")
        low = a[a[:, 1] < np.percentile(a[:, 1], 30)]
        ax = w["RightArm"][:3, :3] @ np.array([0, -1.0, 0])
        return [(low[:, 0].min() - 1.07) / 0.01, (a[:, 1].max() - top) / 0.01, (low[:, 2].mean() - 0.05) / 0.02,
                (np.degrees(np.arctan2(-ax[2], ax[1])) - tilt) / 1.0, (np.degrees(np.arctan2(ax[0], ax[1])) - side) / 1.0, q[1] / 30.0]
    return least_squares(res, np.array(RA_CARRY + RA_CARRY_T), x_scale=[5, 5, 5, 0.05, 0.05, 0.05]).x


def sword_R(B, roll):
    up = np.array([0, 1.0, 0])
    xs = up - (up @ B) * B
    xs /= np.linalg.norm(xs)
    zs = -B
    ys = np.cross(zs, xs)
    r = np.radians(roll)
    x2 = np.cos(r) * xs + np.sin(r) * ys
    y2 = np.cross(zs, x2)
    return np.stack([x2, y2, zs], 1)


def main():
    pass


if __name__ == "__main__":
    head_c = None
    best = []
    for top, tilt, side in itertools.product([1.35, 1.5, 1.65], [0, 8, 16], [0, 8, 16]):
        q = solve_arm(top, tilt, side)
        w = world(q, SW_CARRY)
        Ra = w["RightArm"][:3, :3]
        gp = w["Sword"][:3, :3] @ np.array([0, 0, 1.8]) + w["Sword"][:3, 3]
        axis = Ra @ np.array([0, 1.0, 0])
        a = pts(w, "RightArm")
        head = pts(w, "Head")
        hmin, hmax = head.min(0) - 0.04, head.max(0) + 0.04
        for pitch, inw, roll in itertools.product([5, 12, 20, 28, 36], [-10, 0, 10, 20, 30, 40], [0, 30, 60, 90]):
            p, i = np.radians(pitch), np.radians(inw)
            B = np.array([-np.sin(i) * np.cos(p), np.sin(p), np.cos(i) * np.cos(p)])
            Rs = sword_R(B, roll)
            s = SV @ Rs.T + (gp - Rs @ np.array([0, 0, 1.8]))
            blade = s[SV[:, 2] < 1.4]
            ge = np.degrees(np.arcsin(abs(axis @ B)))
            over = blade[(blade[:, 0] < 1.06) & (blade[:, 0] > -1.06) & (np.abs(blade[:, 2]) < 0.52) & (blade[:, 1] < 1.6)]
            pen = max(0.0, 1.05 - over[:, 1].min()) if len(over) else 0.0
            hh = int(((s > hmin) & (s < hmax)).all(1).sum())
            rest = over[:, 1].min() - 1.02 if len(over) else 9.0
            cost = ge + 200 * pen + 3 * hh + 30 * max(0.0, rest - 0.25) + 10 * (top - 1.35)
            best.append((cost, top, tilt, side, pitch, inw, roll, round(ge, 1), round(float(rest), 2), hh, q, Rs, Ra))
    best.sort(key=lambda t: t[0])
    for b in best[:12]:
        print([round(x, 2) if isinstance(x, float) else x for x in b[:10]])
    b = best[0]
    sr = euler(b[12].T @ b[11])
    np.save("carry_best.npy", np.concatenate([b[10], sr, [0, 0, 0]]))
    print("arm", np.round(b[10], 3).tolist(), "sword", np.round(sr, 2).tolist())
