import json, sys, math
from mathutils import Euler, Quaternion, Matrix, Vector

args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
opt = dict(a.split("=", 1) for a in args)
SRC = opt["src"]
OUT = opt["out"]
GRIP_SRC = opt["grip_src"]
RIG = opt["rig"]
ROOT = int(opt.get("root", "0"))
TOUCH = float(opt.get("touch", "0.04"))

rig = json.load(open(RIG))
motors = {m["p1"]: m for m in rig["motors"]}
sizes = {p["name"]: p["size"] for p in rig["parts"]}
TORSO_H = Vector(sizes["Torso"]) / 2


def rot(c):
    return Euler((math.radians(c[0]), math.radians(c[1]), math.radians(c[2])), "YXZ").to_matrix().to_4x4()


def pose_m(c):
    return Matrix.Translation(Vector(c[3:6])) @ rot(c)


def cf_m(v):
    x, y, z, a, b, cc, d, e, f, g, h, i = v
    return Matrix(((a, b, cc, x), (d, e, f, y), (g, h, i, z), (0, 0, 0, 1)))


def part_m(name, c):
    m = motors[name]
    return cf_m(m["c0"]) @ pose_m(c) @ cf_m(m["c1"]).inverted()


def box_points(h, n=(4, 10, 4)):
    pts = []
    for i in range(n[0] + 1):
        for j in range(n[1] + 1):
            for k in range(n[2] + 1):
                pts.append(Vector((h.x * (2 * i / n[0] - 1), h.y * (2 * j / n[1] - 1), h.z * (2 * k / n[2] - 1))))
    return pts


def gap_of(name, c):
    m = part_m(name, c)
    best, bp, bq = 1e9, None, None
    for p in box_points(Vector(sizes[name]) / 2):
        w = m @ p
        q = Vector((max(-TORSO_H.x, min(TORSO_H.x, w.x)), max(-TORSO_H.y, min(TORSO_H.y, w.y)), max(-TORSO_H.z, min(TORSO_H.z, w.z))))
        dist = (w - q).length
        if dist < best:
            best, bp, bq = dist, w, q
    return best, bp, bq


def mean_grip(frames):
    qs = [Euler((math.radians(f["Sword"][0]), math.radians(f["Sword"][1]), math.radians(f["Sword"][2])), "YXZ").to_quaternion() for f in frames]
    acc = [0.0, 0.0, 0.0, 0.0]
    for q in qs:
        s = -1 if q.dot(qs[0]) < 0 else 1
        acc = [acc[0] + s * q.w, acc[1] + s * q.x, acc[2] + s * q.y, acc[3] + s * q.z]
    q = Quaternion(acc).normalized()
    e = q.to_euler("YXZ")
    loc = [sum(f["Sword"][3 + i] for f in frames) / len(frames) for i in range(3)]
    return [math.degrees(e.x), math.degrees(e.y), math.degrees(e.z)] + loc


d = json.load(open(SRC))
frames = d["frames"]
grip = mean_grip(json.load(open(GRIP_SRC))["frames"])

report = []
for name in ("RightArm", "LeftArm"):
    before = [gap_of(name, f[name])[0] for f in frames]
    report.append("%s gap before: max %.3f, frames over 0.02: %d of %d" % (name, max(before), sum(1 for g in before if g > 0.02), len(frames)))

shifts = []
for f in frames:
    c = list(f["RightArm"])
    total = Vector((0, 0, 0))
    for _ in range(12):
        g, p, q = gap_of("RightArm", c)
        if g <= 0.0:
            break
        step = (q - p).normalized() * (g + TOUCH)
        c[3] += step.x
        c[4] += step.y
        c[5] += step.z
        total += step
    shifts.append(total)

n = len(shifts)
smooth = []
for i in range(n):
    acc = Vector((0, 0, 0))
    wsum = 0
    for k in range(-3, 4):
        j = (i + k) % n if d.get("loop", True) else min(max(i + k, 0), n - 1)
        w = 4 - abs(k)
        acc += shifts[j] * w
        wsum += w
    smooth.append(acc / wsum)

for f, s in zip(frames, smooth):
    c = list(f["RightArm"])
    c[3] += s.x
    c[4] += s.y
    c[5] += s.z
    for _ in range(12):
        g, p, q = gap_of("RightArm", c)
        if g <= 0.0:
            break
        step = (q - p).normalized() * (g + TOUCH)
        c[3] += step.x
        c[4] += step.y
        c[5] += step.z
    f["RightArm"] = c
    f["Sword"] = list(grip)

after = [gap_of("RightArm", f["RightArm"])[0] for f in frames]
maxshift = max(s.length for s in smooth)
report.append("RightArm gap after: max %.3f, largest move %.3f studs" % (max(after), maxshift))
report.append("grip %s" % ", ".join("%.3f" % v for v in grip))

if ROOT:
    d["root"] = [0.0] * (int(round(d["times"][-1] * 60)) + 1)
d["action"] = opt.get("action", d.get("action", "fixed"))
json.dump(d, open(OUT, "w"))
print("\n".join(report))
print("wrote", OUT)
