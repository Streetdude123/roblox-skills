import sys
import numpy as np, cv2
from texrender import TexRig
from rig import Camera
from engine2 import transforms, POSE_N
from keyanim import euler
import carry_search as cs

tr = TexRig()
rows = []
for spec in sys.argv[2:]:
    top, tilt, side, pitch, inw, roll = [float(x) for x in spec.split(",")]
    q = cs.solve_arm(top, tilt, side)
    w = cs.world(q, cs.SW_CARRY)
    Ra = w["RightArm"][:3, :3]
    p, i = np.radians(pitch), np.radians(inw)
    B = np.array([-np.sin(i) * np.cos(p), np.sin(p), np.cos(i) * np.cos(p)])
    Rs = cs.sword_R(B, roll)
    sr = euler(Ra.T @ Rs)
    pp = np.zeros(POSE_N); pp[9:12] = q[:3]; pp[21:24] = q[3:]
    w = tr.rig.solve(transforms(pp, [*sr, 0, 0, 0]))
    print(spec, "arm", np.round(q, 3).tolist(), "sword", np.round(sr, 2).tolist())
    tiles = []
    for cp, lk in (((3.0, 2.2, 9.0), (0, -0.4, -1.0)), ((0.0, 0.8, 8.0), (0, 0.2, 0)), ((8.0, 0.8, 0.0), (0, 0.0, 0)), ((5.0, 1.0, -6.0), (0.5, 0.2, 0)), ((-2.0, 0.8, -8.0), (0, 0.2, 0))):
        cam = Camera(np.array(cp, float), np.array(lk, float), 520.0, 180, 220)
        img, lab = tr.render(w, cam, (360, 440))
        im = cv2.cvtColor(np.clip(img, 0, 255).astype(np.uint8), cv2.COLOR_RGB2BGR); im[lab == 0] = (235, 235, 235)
        tiles.append(im)
    row = np.concatenate(tiles, 1)
    cv2.putText(row, spec, (6, 430), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 200), 2)
    rows.append(row)
cv2.imwrite(sys.argv[1], np.concatenate(rows, 0), [cv2.IMWRITE_JPEG_QUALITY, 85])
