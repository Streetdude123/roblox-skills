import json, math
import numpy as np

D2R = math.pi / 180.0


def rx(a):
    c, s = math.cos(a * D2R), math.sin(a * D2R)
    return np.array([[1, 0, 0], [0, c, -s], [0, s, c]])


def ry(a):
    c, s = math.cos(a * D2R), math.sin(a * D2R)
    return np.array([[c, 0, s], [0, 1, 0], [-s, 0, c]])


def rz(a):
    c, s = math.cos(a * D2R), math.sin(a * D2R)
    return np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]])


def m4(R=None, p=None):
    M = np.eye(4)
    if R is not None:
        M[:3, :3] = R
    if p is not None:
        M[:3, 3] = p
    return M


def cfm(v):
    x, y, z, a, b, c, d, e, f, g, h, i = v
    return np.array([[a, b, c, x], [d, e, f, y], [g, h, i, z], [0, 0, 0, 1.0]])


def chan_rot(c):
    return rz(c[2]) @ rx(c[0]) @ ry(c[1])


def chan(c):
    return m4(chan_rot(c), c[3:6])


def rot_chan(R):
    lift = math.degrees(math.asin(max(-1.0, min(1.0, R[2, 1]))))
    twist = math.degrees(math.atan2(-R[2, 0], R[2, 2]))
    side = math.degrees(math.atan2(-R[0, 1], R[1, 1]))
    return [lift, twist, side]


def wrap(a, ref):
    return a + 360.0 * round((ref - a) / 360.0)


def near_branch(c, prev):
    a = [wrap(c[0], prev[0]), wrap(c[1], prev[1]), wrap(c[2], prev[2])]
    b = [wrap(180 - c[0], prev[0]), wrap(c[1] + 180, prev[1]), wrap(c[2] + 180, prev[2])]
    da = sum((a[i] - prev[i]) ** 2 for i in range(3))
    db = sum((b[i] - prev[i]) ** 2 for i in range(3))
    return a if da <= db else b


def unit(v):
    v = np.asarray(v, dtype=float)
    return v / np.linalg.norm(v)


def axis_angle(axis, ang):
    axis = unit(axis)
    x, y, z = axis
    c, s = math.cos(ang), math.sin(ang)
    C = 1 - c
    return np.array([[c + x * x * C, x * y * C - z * s, x * z * C + y * s],
                     [y * x * C + z * s, c + y * y * C, y * z * C - x * s],
                     [z * x * C - y * s, z * y * C + x * s, c + z * z * C]])


def nelder_mead(f, x0, step, iters=600, tol=1e-9):
    n = len(x0)
    pts = [np.array(x0, dtype=float)]
    for i in range(n):
        p = np.array(x0, dtype=float)
        p[i] += step[i] if hasattr(step, "__len__") else step
        pts.append(p)
    vals = [f(p) for p in pts]
    for _ in range(iters):
        order = np.argsort(vals)
        pts = [pts[i] for i in order]
        vals = [vals[i] for i in order]
        if abs(vals[-1] - vals[0]) < tol:
            break
        c = sum(pts[:-1]) / n
        xr = c + (c - pts[-1])
        fr = f(xr)
        if fr < vals[0]:
            xe = c + 2 * (c - pts[-1])
            fe = f(xe)
            if fe < fr:
                pts[-1], vals[-1] = xe, fe
            else:
                pts[-1], vals[-1] = xr, fr
        elif fr < vals[-2]:
            pts[-1], vals[-1] = xr, fr
        else:
            xc = c + 0.5 * (pts[-1] - c)
            fc = f(xc)
            if fc < vals[-1]:
                pts[-1], vals[-1] = xc, fc
            else:
                for i in range(1, n + 1):
                    pts[i] = pts[0] + 0.5 * (pts[i] - pts[0])
                    vals[i] = f(pts[i])
    i = int(np.argmin(vals))
    return pts[i], vals[i]


class Rig:
    def __init__(self, path):
        j = json.load(open(path))
        self.parts = {p["name"]: p for p in j["parts"]}
        self.motors = {m["p1"]: m for m in j["motors"]}
        self.c0 = {k: cfm(m["c0"]) for k, m in self.motors.items()}
        self.c1 = {k: cfm(m["c1"]) for k, m in self.motors.items()}
        self.c1i = {k: np.linalg.inv(v) for k, v in self.c1.items()}
        self.r0 = {k: v[:3, :3] for k, v in self.c0.items()}
        order, placed, left = [], {"HumanoidRootPart"}, list(self.motors.keys())
        while left:
            for k in list(left):
                if self.motors[k]["p0"] in placed:
                    order.append(k)
                    placed.add(k)
                    left.remove(k)
        self.order = order
        self.size = {k: np.array(p["size"]) for k, p in self.parts.items()}

    def joint(self, name, c):
        r = m4(self.r0[name])
        return r.T @ chan(c) @ r

    def world(self, pose):
        out = {"HumanoidRootPart": np.eye(4)}
        for name in self.order:
            m = self.motors[name]
            c = pose.get(name, [0, 0, 0, 0, 0, 0])
            out[name] = out[m["p0"]] @ self.c0[name] @ self.joint(name, c) @ self.c1i[name]
        return out

    def child(self, parent_w, name, c):
        return parent_w @ self.c0[name] @ self.joint(name, c) @ self.c1i[name]

    def pivot(self, parent_w, name):
        return (parent_w @ self.c0[name])[:3, 3]

    def arm_len(self):
        return 2.4985 / 2

    def sole(self, leg_w):
        return (leg_w @ np.array([0, -self.size["RightLeg"][1] / 2, 0, 1]))[:3]


SWORD_HALF = 3.0139


def sword_info(rig, arm_w, grip_c):
    sw = rig.child(arm_w, "Sword", grip_c)
    R = sw[:3, :3]
    grip = (arm_w @ rig.c0["Sword"])[:3, 3]
    blade = -R[:, 2]
    edge = R[:, 1]
    tip = (sw @ np.array([0, 0, -SWORD_HALF, 1]))[:3]
    pommel = (sw @ np.array([0, 0, SWORD_HALF, 1]))[:3]
    arm_up = arm_w[:3, 1]
    grip_err = abs(float(np.dot(blade, arm_up)))
    return {"sw": sw, "grip": grip, "blade": blade, "edge": edge, "tip": tip, "pommel": pommel, "grip_dot": grip_err}


def phys_twist(Rrel):
    y = Rrel[:, 1]
    yf = np.array([0.0, 0.0, 1.0])
    Rf = rx(90)
    ax = np.cross(yf, y)
    s = np.linalg.norm(ax)
    c = float(np.dot(yf, y))
    if s < 1e-6:
        Rs = np.eye(3) if c > 0 else rx(180)
    else:
        Rs = axis_angle(ax / s, math.atan2(s, c))
    q = (Rs @ Rf).T @ Rrel
    return math.degrees(math.atan2(q[0, 2], q[0, 0]))


def solve_sword(rig, torso_w, hand, blade, edge=None, seed_arm=None, seed_grip=None, slide=0.0, grip_limit=0.42, fix_grip=None):
    hand = unit(hand)
    blade = unit(blade)
    edge = unit(edge) if edge is not None else None
    seed_arm = list(seed_arm) if seed_arm is not None else [60, 0, 0]
    seed_grip = list(seed_grip) if seed_grip is not None else [0, 0, 0]
    shoulder = rig.pivot(torso_w, "RightArm")
    Rt = torso_w[:3, :3]
    def cost(x):
        a = [x[0], x[1], x[2], 0, 0, 0]
        arm_w = rig.child(torso_w, "RightArm", a)
        info = sword_info(rig, arm_w, [x[3], x[4], x[5], 0, 0, 0])
        hd = unit(info["grip"] - shoulder)
        e = 40 * (1 - float(np.dot(hd, hand))) + 40 * (1 - float(np.dot(info["blade"], blade)))
        if edge is not None:
            e += 10 * (1 - float(np.dot(info["edge"], edge)))
        g = info["grip_dot"]
        if g > grip_limit:
            e += 60 * (g - grip_limit) ** 2 * 10
        tw = abs(phys_twist(Rt.T @ arm_w[:3, :3]))
        if tw > 35:
            e += ((tw - 35) / 30.0) ** 2 * 4
        e += 2e-6 * sum((x[i] - seed_arm[i]) ** 2 for i in range(3))
        e += 2e-6 * sum((x[3 + i] - seed_grip[i]) ** 2 for i in range(3))
        return e

    def finish(best, bv):
        arm = near_branch(list(best[:3]), seed_arm)
        grip = near_branch(list(best[3:6]), seed_grip) if fix_grip is None else list(best[3:6])
        arm_c = [arm[0], arm[1], arm[2], 0, 0, 0]
        arm_w = rig.child(torso_w, "RightArm", arm_c)
        info = sword_info(rig, arm_w, grip + [0, 0, 0])
        hd = unit(info["grip"] - shoulder)
        rep = {
            "hand_err": math.degrees(math.acos(max(-1, min(1, float(np.dot(hd, hand)))))),
            "blade_err": math.degrees(math.acos(max(-1, min(1, float(np.dot(info["blade"], blade)))))),
            "grip_off_square": 90 - math.degrees(math.acos(min(1, info["grip_dot"]))),
            "twist": phys_twist(Rt.T @ arm_w[:3, :3]),
            "cost": bv,
        }
        return arm_c, grip + [0, 0, 0], rep

    if fix_grip is not None:
        fg = list(fix_grip[:3])

        def cost3(x):
            return cost([x[0], x[1], x[2]] + fg)

        best, bv = None, 1e9
        for extra in (0, 90, -90, 180):
            s = [seed_arm[0], seed_arm[1] + extra, seed_arm[2]]
            x, v = nelder_mead(cost3, s, [15, 25, 15], iters=1500)
            x, v = nelder_mead(cost3, x, [3, 5, 3], iters=1500)
            if v < bv:
                best, bv = list(x) + fg, v
        return finish(best, bv)

    best, bv = None, 1e9
    seeds = [seed_arm + seed_grip]
    for extra in ([0, 90, 0], [0, -90, 0], [0, 180, 0]):
        seeds.append([seed_arm[0], seed_arm[1] + extra[1], seed_arm[2]] + seed_grip)
    for s in seeds:
        x, v = nelder_mead(cost, s, [15, 25, 15, 15, 25, 15], iters=1500)
        x, v = nelder_mead(cost, x, [3, 5, 3, 3, 5, 3], iters=1500)
        if v < bv:
            best, bv = x, v
    return finish(list(best), bv)


def solve_reach(rig, torso_w, side, target, seed=None, max_slide=0.3):
    name = "LeftArm" if side == "L" else "RightArm"
    fist_local = np.array([-0.21, -2.25, 0.0]) if side == "L" else np.array([0.1085, -2.2456, 0.0586])
    pivot = rig.pivot(torso_w, name)
    Rt = torso_w[:3, :3]
    seed = list(seed) if seed is not None else [30, 0, 0]
    target = np.asarray(target, dtype=float)

    def fist_of(x, s):
        R = chan_rot([x[0], x[1], x[2]])
        p = R @ np.array([0, s, 0])
        return pivot + Rt @ (p + R @ fist_local)

    def cost(x):
        d = fist_of(x, 0.0)
        dirt = unit(target - pivot)
        dirf = unit(d - pivot)
        e = 40 * (1 - float(np.dot(dirt, dirf)))
        tw = abs(phys_twist(chan_rot([x[0], x[1], x[2]])))
        if tw > 35:
            e += ((tw - 35) / 30.0) ** 2 * 4
        e += 2e-6 * sum((x[i] - seed[i]) ** 2 for i in range(3))
        return e

    x, v = nelder_mead(cost, seed, [15, 25, 15], iters=1500)
    x, v = nelder_mead(cost, x, [3, 5, 3], iters=1500)
    x = near_branch(list(x), seed)
    reach = np.linalg.norm(fist_local)
    dist = float(np.linalg.norm(target - pivot))
    s = max(-max_slide, min(max_slide * 2.5, reach - dist))
    R = chan_rot(x)
    p = R @ np.array([0, s, 0])
    miss = float(np.linalg.norm(fist_of(x, s) - target))
    return [x[0], x[1], x[2], float(p[0]), float(p[1]), float(p[2])], {"miss": miss, "slide": s}


LEG_LEN = 2.3350415229797363 / 2 + 1.2


def solve_leg(rig, torso_w, name, target, toe_yaw=0.0, prev=None, max_up=1.2, max_down=0.1):
    pivot = rig.pivot(torso_w, name)
    Rt = torso_w[:3, :3]
    target = np.asarray(target, dtype=float)
    d = target - pivot
    dist = float(np.linalg.norm(d))
    y = -d / dist
    toe = np.array([-math.sin(toe_yaw * D2R), 0.0, -math.cos(toe_yaw * D2R)])
    fwd = toe - np.dot(toe, y) * y
    fwd = unit(fwd)
    zb = -fwd
    x = np.cross(y, zb)
    Rw = np.column_stack([x, y, zb])
    Rrel = Rt.T @ Rw
    c = rot_chan(Rrel)
    if prev is not None:
        c = near_branch(c, prev[:3])
    s = LEG_LEN - dist
    s = max(-max_down, min(max_up, s))
    p = Rrel @ np.array([0, s, 0])
    return [c[0], c[1], c[2], float(p[0]), float(p[1]), float(p[2])], {"gap": max(0.0, -s), "slide_up": max(0.0, s), "dist": dist}


def waist(c, hip=1.0104):
    R = chan_rot(c)
    h = np.array([0.0, -hip, 0.0])
    off = h - R @ h
    return [c[0], c[1], c[2], c[3] + off[0], c[4] + off[1], c[5] + off[2]]
