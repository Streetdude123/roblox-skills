import sys

import cv2
import numpy as np

from texrender import TexRig
from rig import Camera
from run_strip import load_keys

VIEWS = {
    "right": (np.array([10.0, 0.3, -0.6]), np.array([0.0, -0.9, -0.6])),
    "left": (np.array([-10.0, 0.3, -0.6]), np.array([0.0, -0.9, -0.6])),
    "front": (np.array([-3.5, 0.2, -9.5]), np.array([0.0, -0.8, 0.0])),
    "rear": (np.array([3.0, 2.2, 9.0]), np.array([0.0, -0.4, -1.0])),
}


COLORS = {"Torso": (150, 150, 150), "Head": (170, 200, 230), "RightArm": (60, 60, 210), "LeftArm": (210, 120, 60),
          "RightLeg": (40, 40, 140), "LeftLeg": (140, 80, 30), "Sword": (40, 210, 230)}


def mannequin(rig, world, cam, size):
    W, H = size
    img = np.full((H, W, 3), 235, np.uint8)
    L = np.array([0.35, 0.8, -0.45])
    L /= np.linalg.norm(L)
    polys = []
    for name, col in COLORS.items():
        p = rig.parts[name]
        m = world[name]
        pts = p["verts"] @ m[:3, :3].T + m[:3, 3]
        uv, depth = cam.project(pts)
        tri = p["tris"]
        a, b, c = pts[tri[:, 0]], pts[tri[:, 1]], pts[tri[:, 2]]
        nrm = np.cross(b - a, c - a)
        nrm /= np.linalg.norm(nrm, axis=1, keepdims=True) + 1e-12
        sh = 0.5 + 0.5 * np.abs(nrm @ L)
        for k in range(len(tri)):
            polys.append((depth[tri[k]].mean(), np.round(uv[tri[k]] * 4).astype(np.int32), tuple(int(x * sh[k]) for x in col)))
    polys.sort(key=lambda t: -t[0])
    for _, t, col in polys:
        cv2.fillPoly(img, [t], col, shift=2)
    return img


def tip_report(tr, keys):
    tips, grips = [], []
    for k in keys:
        w = tr.rig.solve(k)
        s = w["Sword"]
        tip = s[:3, :3] @ np.array([0.0, 0.0, -3.014]) + s[:3, 3]
        tips.append(tip)
        arm = w["RightArm"][:3, :3] @ np.array([0.0, 1.0, 0.0])
        blade = s[:3, :3] @ np.array([0.0, 0.0, -1.0])
        grips.append(np.degrees(np.arcsin(abs(float(arm @ blade)))))
    tips = np.array(tips)
    return tips, np.array(grips)


if __name__ == "__main__":
    path, out = sys.argv[1], sys.argv[2]
    views = sys.argv[3].split(",") if len(sys.argv) > 3 else ["right", "front", "rear"]
    count = int(sys.argv[4]) if len(sys.argv) > 4 else 8
    L, keys = load_keys(path)
    tr = TexRig()
    n = len(keys)
    mode = sys.argv[5] if len(sys.argv) > 5 else "tex"
    tips, grips = tip_report(tr, keys[:n])
    print("tip y min %.2f max %.2f (floor -3.40); grip error max %.1f deg mean %.1f" % (tips[:, 1].min(), tips[:, 1].max(), grips.max(), grips.mean()))
    rows = []
    W, H = 330, 420
    for name in views:
        cp, lk = VIEWS[name]
        tiles = []
        for f in np.arange(count) / count:
            i = int(round(f * n)) % n
            w = tr.rig.solve(keys[i])
            cam = Camera(cp, lk, 420.0, W / 2, H / 2)
            if mode == "man":
                im = mannequin(tr.rig, w, cam, (W, H))
            else:
                img, lab = tr.render(w, cam, (W, H))
                im = cv2.cvtColor(np.clip(img, 0, 255).astype(np.uint8), cv2.COLOR_RGB2BGR)
                im[lab == 0] = (235, 235, 235)
            a = cam.project(np.array([[-3.0, -3.40, 0.0], [3.0, -3.40, 0.0]]))[0]
            b = cam.project(np.array([[0.0, -3.40, -3.0], [0.0, -3.40, 3.0]]))[0]
            for p in (a, b):
                cv2.line(im, (int(p[0][0]), int(p[0][1])), (int(p[1][0]), int(p[1][1])), (150, 150, 150), 1)
            cv2.putText(im, "%.2fs" % (i / n * L), (4, 16), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 1)
            tiles.append(im)
        row = np.concatenate(tiles, 1)
        cv2.putText(row, name, (4, H - 8), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 200), 2)
        rows.append(row)
    img = np.concatenate(rows, 0)
    cv2.imwrite(out, img, [cv2.IMWRITE_JPEG_QUALITY, 85])
