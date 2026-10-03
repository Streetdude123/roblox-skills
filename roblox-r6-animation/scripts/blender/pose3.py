import bpy, json, os, sys, math, bisect
from mathutils import Matrix, Vector, Quaternion

ARGS = dict(a.split("=", 1) for a in sys.argv[sys.argv.index("--") + 1:]) if "--" in sys.argv else {}
D = os.path.dirname(os.path.abspath(__file__))
scene = bpy.context.scene
FPS = scene.render.fps
HZ = 60
STUD = 2.107
arm = bpy.data.objects["Armature"]
for _t in arm.animation_data.nla_tracks:
    _t.mute = True
pbs = arm.pose.bones
bones = arm.data.bones
for pb in pbs:
    pb.rotation_mode = "QUATERNION"

PARENT = {b.name: b.parent.name if b.parent else None for b in bones}
RESTM = {b.name: b.matrix_local.copy() for b in bones}
REL = {n: (RESTM[p].inverted() @ RESTM[n]) if p else RESTM[n].copy() for n, p in PARENT.items()}
R3 = {n: m.to_3x3() for n, m in RESTM.items()}
RQ = {n: m.to_quaternion() for n, m in RESTM.items()}
LEN = {b.name: b.length for b in bones}
X, Y, Z = Vector((1, 0, 0)), Vector((0, 1, 0)), Vector((0, 0, 1))
ID = Matrix.Identity(4)


def mat(q, l=(0, 0, 0)):
    m = q.to_matrix().to_4x4()
    m.translation = Vector(l)
    return m


def E(a):
    a = tuple(a) + (0, 0, 0)
    return Quaternion(Z, math.radians(a[0])) @ Quaternion(X, -math.radians(a[1])) @ Quaternion(Y, math.radians(a[2]))


def unE(q):
    e = q.to_euler("YXZ")
    return (math.degrees(e.z), -math.degrees(e.x), math.degrees(e.y))


class Pose:
    def __init__(self, basis=None):
        self.basis = dict(basis or {})
        self.cache = {}

    def base(self, n):
        p = PARENT[n]
        return (self.W(p) @ REL[n]) if p else REL[n]

    def W(self, n):
        w = self.cache.get(n)
        if w is None:
            w = self.base(n) @ self.basis.get(n, ID)
            self.cache[n] = w
        return w

    def put(self, n, Wd):
        self.basis[n] = self.base(n).inverted() @ Wd
        self.cache = {}

    def set(self, n, m):
        self.basis[n] = m
        self.cache = {}

    def head(self, n):
        b = self.basis.get(n, ID)
        return (self.base(n) @ Matrix.Translation(b.translation)).translation

    def rot(self, n, q):
        self.put(n, mat(q, self.head(n)))

    def tail(self, n):
        return self.W(n) @ Vector((0, LEN[n], 0))


arm.animation_data.action = None
for pb in pbs:
    pb.location = (0, 0, 0)
    pb.rotation_quaternion = (1, 0, 0, 0)
    pb.scale = (1, 1, 1)
arm.animation_data.action = bpy.data.actions["Idle"]
scene.frame_set(0)
IDLE = {pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in pbs}
arm.animation_data.action = None
IDLEB = {n: mat(q, l) for n, (q, l) in IDLE.items()}
P0 = Pose(IDLEB)

FINGERS = [n for n in PARENT if n.startswith("Finger_")]
HAIR = ["hairbone1.003", "hairbone_R", "hairbone_L", "hairbone1.002", "hairbone1"]
VINE = ["Vine1", "Vine2", "Vine3", "Vine4"]
SPINE = ["Bone", "Bone.001", "Bone.004", "Bone.002", "Bone.003"]
ARMS = ["Arm_R", "Arm_R.001", "Arm_R.003", "Arm_R.002", "Arm_R.004", "Arm_L", "Arm_L.001", "Arm_L.003", "Arm_L.002"]
LEGS = ["MasterController", "Boot_R.001", "Boot_L.001", "Foot_R", "Foot_L", "Leg_R.003", "Leg_L.003", "Leg_R.002", "Leg_L.002", "pocket_R", "pocket_L"]
KEYED = SPINE + ARMS + LEGS + FINGERS + HAIR + VINE
SIDES = {"R": ("Arm_R", "Arm_R.001", "Arm_R.003", "Arm_R.002"), "L": ("Arm_L", "Arm_L.001", "Arm_L.003", "Arm_L.002")}
SG = {"R": 1, "L": -1}
L1 = LEN["Arm_R.001"]
L2 = LEN["Arm_R.003"]
YREST = {"R": X.copy(), "L": -X}
HINGE = {"R": Z.copy(), "L": -Z}
GRIP = IDLEB["Arm_R.004"]
BLADE_REST = ((RESTM["Arm_R.004"] @ GRIP).to_3x3() @ Y).normalized()
THUMB = {"R": BLADE_REST, "L": Z.copy()}
LEGLEN = LEN["Leg_R"] + LEN["Leg_R.001"]
KNIFE_OFF = Vector((0, 0, 0))


def frame(a, b):
    a = a.normalized()
    b = (b - a * b.dot(a)).normalized()
    return Matrix((a, b, a.cross(b))).transposed()


def remap(a0, b0, a1, b1):
    return frame(a1, b1) @ frame(a0, b0).transposed()


def V(v):
    return Vector(tuple(v)[:3])


class Report:
    def __init__(self):
        self.rows = []
        self.worst = {}

    def note(self, key, val, t):
        cur = self.worst.get(key)
        if cur is None or val > cur[0]:
            self.worst[key] = (val, t)


def arm_solve(P, side, s, qc, rep=None, t=0):
    cl, up, fo, ha = SIDES[side]
    sg = SG[side]
    c = tuple(s["c" + side]) + (0, 0, 0)
    qcl = qc @ Quaternion(Z, sg * math.radians(c[1])) @ Quaternion(Y, -sg * math.radians(c[0])) @ Quaternion(X, math.radians(c[2]))
    P.rot(cl, qcl @ RQ[cl])
    S = P.head(up)
    fw = s.get("f" + side, 1.0)
    fw = fw[0] if isinstance(fw, (list, tuple)) else fw
    qc = Quaternion().slerp(qc, fw)
    a = tuple(s["a" + side])
    H = S + (qc @ Vector(a[:3]).normalized()) * a[3] * (L1 + L2)
    pole = qc @ V(s["e" + side])
    d = H - S
    want = d.length
    dist = min(max(want, 0.08), (L1 + L2) * 0.998)
    u = d.normalized()
    x = (dist * dist + L1 * L1 - L2 * L2) / (2 * dist)
    h = math.sqrt(max(0.0, L1 * L1 - x * x))
    v = pole - u * pole.dot(u)
    v = v.normalized() if v.length > 1e-6 else Z.copy()
    Ep = S + u * x + v * h
    Hp = S + u * dist
    ud = (Ep - S).normalized()
    fd = (Hp - Ep).normalized()
    hinge = -(u.cross(v)).normalized()
    Rup = remap(YREST[side], HINGE[side], ud, hinge)
    P.rot(up, (Rup @ R3[up]).to_quaternion())
    Rfo = remap(YREST[side], HINGE[side], fd, hinge)
    T = (qc @ V(s["t" + side])).normalized()
    g = s.get("g" + side)
    F = (qc @ V(g)) if g is not None else fd.copy()
    F = F - T * F.dot(T)
    if F.length < 1e-4:
        F = fd.cross(T)
    F.normalize()
    Rha = remap(YREST[side], THUMB[side], F, T)
    Qrel = (R3[fo].transposed() @ Rfo.transposed() @ Rha @ R3[fo]).to_quaternion()
    tw = 2 * math.atan2(Qrel.y, Qrel.w)
    tw = (tw + math.pi) % (2 * math.pi) - math.pi
    kk = s.get("k" + side, 0.6)
    kk = kk[0] if isinstance(kk, (list, tuple)) else kk
    roll = max(-1.45, min(1.45, tw * kk))
    Rfo = Quaternion(fd, roll).to_matrix() @ Rfo
    P.rot(fo, (Rfo @ R3[fo]).to_quaternion())
    P.rot(ha, (Rha @ R3[ha]).to_quaternion())
    if rep:
        rep.note("reach" + side, want / (L1 + L2), t)
        rep.note("wrist" + side, math.degrees(F.angle(fd)), t)
        rep.note("elbow" + side, math.degrees(ud.angle(fd)), t)
        rep.note("twist" + side, abs(math.degrees(tw - roll)), t)
    return F


def vine_solve(P, s):
    dirs = s.get("vine")
    if dirs is None:
        return
    for i, n in enumerate(VINE):
        dv = Vector(dirs[i * 3:i * 3 + 3]).normalized()
        rest_y = R3[n] @ Y
        P.rot(n, rest_y.rotation_difference(dv) @ RQ[n])


def solve(s, rep=None, t=0):
    P = Pose()
    for n in FINGERS:
        q, l = IDLE[n]
        op = s.get("o" + ("R" if "_R" in n else "L"), (0,))[0]
        P.set(n, mat(q.slerp(Quaternion(), op) if op else q, l))
    for n in HAIR + ["MasterController", "Leg_R.003", "Leg_L.003", "Foot_R", "Foot_L", "Leg_R.002", "Leg_L.002", "pocket_R", "pocket_L"]:
        P.set(n, IDLEB[n])
    for n in VINE:
        P.set(n, IDLEB[n])
    P.set("Arm_R.004", GRIP)
    qh = E(s["pel"])
    P.put("Bone", mat(qh @ RQ["Bone"], RESTM["Bone"].translation + V(s["hip"])))
    q = qh
    for n, k in (("Bone.001", "sp"), ("Bone.004", "ch"), ("Bone.002", "nk"), ("Bone.003", "hd")):
        q = q @ E(s[k])
        P.rot(n, q @ RQ[n])
    qc = qh @ E(s["sp"]) @ E(s["ch"])
    for side in ("R", "L"):
        arm_solve(P, side, s, qc, rep, t)
    for side, n in (("R", "Boot_R.001"), ("L", "Boot_L.001")):
        f = s["foot" + side]
        qf = Quaternion(Z, math.radians(f[3])) @ Quaternion(X, math.radians(f[4] if len(f) > 4 else 0))
        P.put(n, mat(qf @ RQ[n], Vector(f[:3])))
        if rep:
            hipj = P.head("Leg_" + side)
            rep.note("leg" + side, (hipj - Vector(f[:3])).length / LEGLEN, t)
    vine_solve(P, s)
    return P


def spec_from(P):
    s = {}
    s["hip"] = tuple(P.W("Bone").translation - RESTM["Bone"].translation)
    qd = {n: P.W(n).to_quaternion() @ RQ[n].inverted() for n in SPINE + ["Arm_R", "Arm_L"]}
    s["pel"] = unE(qd["Bone"])
    s["sp"] = unE(qd["Bone"].inverted() @ qd["Bone.001"])
    s["ch"] = unE(qd["Bone.001"].inverted() @ qd["Bone.004"])
    s["nk"] = unE(qd["Bone.004"].inverted() @ qd["Bone.002"])
    s["hd"] = unE(qd["Bone.002"].inverted() @ qd["Bone.003"])
    qci = qd["Bone.004"].inverted()
    for side in ("R", "L"):
        cl, up, fo, ha = SIDES[side]
        sg = SG[side]
        e = (qci @ qd[cl]).to_euler("XYZ")
        s["c" + side] = (-sg * math.degrees(e.y), sg * math.degrees(e.z), math.degrees(e.x))
        S = P.head(up)
        Hh = P.head(ha)
        El = P.head(fo)
        u = (Hh - S).normalized()
        pole = (El - S) - u * (El - S).dot(u)
        s["a" + side] = tuple(qci @ u) + (min(1.0, (Hh - S).length / (L1 + L2)),)
        s["e" + side] = tuple(qci @ pole.normalized())
        if side == "R":
            s["tR"] = tuple(qci @ (P.W("Arm_R.004").to_3x3() @ Y).normalized())
        else:
            s["tL"] = tuple(qci @ ((P.W(ha).to_3x3() @ R3[ha].transposed()) @ Z).normalized())
        s["g" + side] = tuple(qci @ (P.W(ha).to_3x3() @ Y).normalized())
        s["o" + side] = (0.0,)
        s["f" + side] = (1.0,)
    for side, n in (("R", "Boot_R.001"), ("L", "Boot_L.001")):
        W = P.W(n)
        fwd = W.to_3x3() @ R3[n].transposed() @ Y
        s["foot" + side] = tuple(W.translation) + (math.degrees(math.atan2(-fwd.x, fwd.y)), 0.0)
    return s


N = spec_from(P0)


def pose(base=None, **kw):
    s = dict(N if base is None else base)
    for k, v in kw.items():
        if k == "hip_add":
            s["hip"] = tuple(a + b for a, b in zip(s["hip"], v))
        elif k.startswith("add_"):
            key = k[4:]
            s[key] = tuple(a + b for a, b in zip(s[key], v))
        elif k in ("oR", "oL", "fR", "fL", "kR", "kL"):
            s[k] = (v,) if not isinstance(v, (tuple, list)) else tuple(v)
        elif k in ("gR", "gL") and v is None:
            s[k] = None
        else:
            s[k] = tuple(v) if isinstance(v, (tuple, list)) else v
    return s


def foot(side, dx=0, dy=0, dz=0, yaw=0, pitch=0):
    f = N["foot" + side]
    return (f[0] + dx, f[1] + dy, f[2] + dz, f[3] + yaw, pitch)


def body_pts():
    return None


def tangents(ts, vs, flat):
    n = len(ts)
    out = []
    for i in range(n):
        dim = len(vs[i])
        if i == 0 or i == n - 1 or i in flat:
            out.append([0.0] * dim)
            continue
        m = []
        for c in range(dim):
            d0 = (vs[i][c] - vs[i - 1][c]) / (ts[i] - ts[i - 1])
            d1 = (vs[i + 1][c] - vs[i][c]) / (ts[i + 1] - ts[i])
            if d0 * d1 <= 0:
                m.append(0.0)
            else:
                sl = (vs[i + 1][c] - vs[i - 1][c]) / (ts[i + 1] - ts[i - 1])
                lim = 3 * min(abs(d0), abs(d1))
                m.append(max(-lim, min(lim, sl)))
        out.append(m)
    return out


def hermite(t, ts, vs, ms):
    if t <= ts[0]:
        return list(vs[0])
    if t >= ts[-1]:
        return list(vs[-1])
    i = bisect.bisect_right(ts, t) - 1
    h = ts[i + 1] - ts[i]
    u = (t - ts[i]) / h
    h00 = 2 * u ** 3 - 3 * u ** 2 + 1
    h10 = u ** 3 - 2 * u ** 2 + u
    h01 = -2 * u ** 3 + 3 * u ** 2
    h11 = u ** 3 - u ** 2
    return [h00 * vs[i][c] + h10 * h * ms[i][c] + h01 * vs[i + 1][c] + h11 * h * ms[i + 1][c] for c in range(len(vs[i]))]


def flatten(v):
    if isinstance(v, (int, float)):
        return [float(v)]
    out = []
    for x in v:
        out += flatten(x)
    return out


BODY_SLICES = [(1.00, 0.40, -0.21, 0.25), (1.20, 0.42, -0.25, 0.27), (1.35, 0.42, -0.26, 0.32), (1.50, 0.39, -0.25, 0.32),
               (1.75, 0.37, -0.23, 0.29), (1.95, 0.36, -0.25, 0.25), (2.05, 0.30, -0.20, 0.23)]


def inside_body(P, p):
    best = 0.0
    for n, z0, z1 in (("Bone", 0.95, 1.17), ("Bone.001", 1.17, 1.5), ("Bone.004", 1.5, 2.08)):
        Mw = P.W(n) @ RESTM[n].inverted()
        r = Mw.inverted() @ p
        if not (z0 <= r.z <= z1):
            continue
        zs = [s[0] for s in BODY_SLICES]
        i = max(0, min(len(zs) - 2, bisect.bisect_right(zs, r.z) - 1))
        a, b = BODY_SLICES[i], BODY_SLICES[i + 1]
        f = max(0.0, min(1.0, (r.z - a[0]) / (b[0] - a[0])))
        hw = a[1] + (b[1] - a[1]) * f - 0.03
        y0 = a[2] + (b[2] - a[2]) * f + 0.03
        y1 = a[3] + (b[3] - a[3]) * f - 0.03
        cy = (y0 + y1) / 2
        hd = (y1 - y0) / 2
        e = (r.x / hw) ** 2 + ((r.y - cy) / hd) ** 2
        if e < 1:
            best = max(best, 1 - e)
    return best


def knife_pts(P):
    W = P.W("Arm_R.004")
    return [W @ Vector((0, s, 0)) for s in (0.35, 0.55, 0.75, 0.9)]


def limb_pts(P, side):
    cl, up, fo, ha = SIDES[side]
    pts = [P.W(fo) @ Vector((0, LEN[fo] * f, 0)) for f in (0.3, 0.7, 1.0)]
    pts.append(P.W(ha) @ Vector((0, LEN[ha] * 0.6, 0)))
    pts.append(P.W(up) @ Vector((0, LEN[up] * 0.9, 0)))
    return pts


class HairSim:
    SET = [("hairbone_R", 0.32, 0.62, 18), ("hairbone_L", 0.32, 0.62, 18), ("hairbone1.002", 0.4, 0.6, 10), ("hairbone1", 0.34, 0.62, 14)]

    def __init__(self, bones_set=None):
        self.set = bones_set or HairSim.SET
        self.x = {}
        self.xp = {}

    def step(self, P, w=1.0):
        for n, k, damp, maxang in self.set:
            Wr = P.W(n)
            head = Wr.translation.copy()
            tail = Wr @ Vector((0, LEN[n], 0))
            if n not in self.x:
                self.x[n] = tail.copy()
                self.xp[n] = tail.copy()
            x, xp = self.x[n], self.xp[n]
            nx = x + (x - xp) * damp + (tail - x) * k
            rd = (tail - head).normalized()
            nd = (nx - head).normalized()
            ang = math.degrees(rd.angle(nd)) if rd.dot(nd) < 0.99999 else 0.0
            if ang > maxang:
                nd = rd.slerp(nd, maxang / ang) if hasattr(rd, "slerp") else (rd + (nd - rd) * (maxang / ang)).normalized()
            nx = head + nd * LEN[n]
            self.xp[n] = x
            self.x[n] = nx
            q = rd.rotation_difference(nd)
            q = Quaternion().slerp(q, w)
            P.put(n, mat(q @ Wr.to_quaternion(), head))


def action_curves(act):
    curves = []
    for layer in getattr(act, "layers", []):
        for strip in layer.strips:
            for cb in getattr(strip, "channelbags", []):
                curves += list(cb.fcurves)
    if hasattr(act, "fcurves"):
        curves += list(act.fcurves)
    return curves


def smooth(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


def bake(name, keys, length, lag=None, flat=(), hair=True, post=None, quiet=False, ends=None):
    lag = lag or {}
    ts = [k[0] for k in keys]
    specs = [dict(k[1]) for k in keys]
    for s in specs:
        for side in ("R", "L"):
            s.setdefault("f" + side, (1.0,))
            if not isinstance(s["f" + side], (list, tuple)):
                s["f" + side] = (s["f" + side],)
            if s.get("g" + side) is None:
                P = solve(dict(s, **{"g" + side: None}))
                qc = Quaternion().slerp(E(s["pel"]) @ E(s["sp"]) @ E(s["ch"]), s["f" + side][0])
                s["g" + side] = tuple(qc.inverted() @ (P.W(SIDES[side][3]).to_3x3() @ Y))
            fw = s["f" + side][0]
            if abs(fw - 1.0) > 1e-6:
                qc = E(s["pel"]) @ E(s["sp"]) @ E(s["ch"])
                conv = qc.inverted() @ Quaternion().slerp(qc, fw)
                a = tuple(s["a" + side])
                s["a" + side] = tuple(conv @ Vector(a[:3])) + (a[3],)
                for c in ("e", "t", "g"):
                    s[c + side] = tuple(conv @ Vector(s[c + side]))
                s["f" + side] = (1.0,)
    chans = {}
    for c in specs[0]:
        if specs[0][c] is None:
            continue
        vs = [flatten(s[c]) for s in specs]
        fl = set(i for i, k in enumerate(keys) if len(k) > 2 and (k[2] is True or (isinstance(k[2], (set, tuple, list)) and c in k[2])))
        fl |= set(flat)
        chans[c] = (vs, tangents(ts, vs, fl))
    if name in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions[name])
    act = bpy.data.actions.new(name)
    act.use_fake_user = True
    arm.animation_data.action = act
    n = int(round(length * HZ))
    rep = Report()
    sim = HairSim() if hair else None
    prevq = {}
    poses = []
    for i in range(n + 1):
        t = i / HZ
        s = {}
        for c, (vs, ms) in chans.items():
            tt = max(ts[0], min(ts[-1], t - lag.get(c, 0.0)))
            v = hermite(tt, ts, vs, ms)
            s[c] = v if len(v) > 1 else v
        for c in ("hip", "pel", "sp", "ch", "nk", "hd", "cR", "cL", "aR", "aL", "eR", "eL", "tR", "tL", "gR", "gL", "footR", "footL"):
            s[c] = tuple(s[c])
        P = solve(s, rep, t)
        if post:
            post(P, t, s)
        if sim:
            sim.step(P, 1.0 if t < length - 0.15 else max(0.0, (length - t) / 0.15))
        if i == n:
            P = solve(specs[-1])
            if post:
                post(P, t, specs[-1])
        w = 0.0
        if ends:
            a, b = ends
            if a and t < a:
                w = 1 - smooth(t / a)
            if b and t > length - b:
                w = max(w, smooth((t - (length - b)) / b))
        if w > 0:
            for nm in KEYED:
                if nm in VINE:
                    continue
                m = P.basis.get(nm, ID)
                mi = IDLEB[nm]
                qa = m.to_quaternion()
                qi = mi.to_quaternion()
                if qa.dot(qi) < 0:
                    qi = -qi
                P.basis[nm] = mat(qa.slerp(qi, w), m.translation.lerp(mi.translation, w))
            P.cache = {}
        for p in knife_pts(P):
            rep.note("knifeInBody", inside_body(P, p), t)
        for side in ("R", "L"):
            for p in limb_pts(P, side):
                rep.note("arm%sInBody" % side, inside_body(P, p), t)
        f = t * FPS
        for nm in KEYED:
            m = P.basis.get(nm, ID)
            q = m.to_quaternion()
            if nm in prevq and prevq[nm].dot(q) < 0:
                q = -q
            prevq[nm] = q
            pb = pbs[nm]
            pb.rotation_quaternion = q
            pb.location = m.translation
            pb.keyframe_insert("rotation_quaternion", frame=f)
            pb.keyframe_insert("location", frame=f)
        poses.append(P)
    for fc in action_curves(act):
        for kp in fc.keyframe_points:
            kp.interpolation = "LINEAR"
    act["length"] = length
    if not quiet:
        print("BAKE", name, "length", length, "samples", n + 1)
        for k in sorted(rep.worst):
            v, t = rep.worst[k]
            print("  %-14s %7.3f at %.3f" % (k, v, t))
    return act, poses, rep


def metrics(name, joints=None):
    act = bpy.data.actions[name]
    arm.animation_data.action = act
    length = act.get("length", (act.frame_range[1] - act.frame_range[0]) / FPS)
    joints = joints or ["Bone", "Bone.001", "Bone.004", "Bone.002", "Bone.003", "Arm_R", "Arm_R.001", "Arm_R.003", "Arm_R.002",
                        "Arm_L", "Arm_L.001", "Arm_L.003", "Arm_L.002", "Leg_R", "Leg_R.001", "Leg_L", "Leg_L.001"]
    n = int(round(length * HZ))
    rots = {j: [] for j in joints}
    locs = {j: [] for j in joints}
    ik_err = 0.0
    for i in range(n + 1):
        f = i / HZ * FPS
        scene.frame_set(int(f), subframe=f - int(f))
        for j in joints:
            pb = pbs[j]
            par = pb.parent
            base = (par.matrix @ REL[j]) if par else REL[j]
            local = base.inverted() @ pb.matrix
            rots[j].append(local.to_quaternion())
            locs[j].append(pb.matrix.translation.copy() if j == "Bone" else Vector())
        for side in ("R", "L"):
            ik_err = max(ik_err, (pbs["Leg_%s.001" % side].tail - pbs["Boot_%s.001" % side].head).length)
    sp = {}
    for j in joints:
        out = []
        for i in range(n + 1):
            a, b = max(0, i - 2), min(n, i + 2)
            dt = (b - a) / HZ
            ang = math.degrees(rots[j][a].rotation_difference(rots[j][b]).angle)
            ang = min(ang, 360 - ang)
            lin = (locs[j][b] - locs[j][a]).length * STUD
            out.append(ang / dt + 30 * lin / dt)
        sp[j] = out
    active = [j for j in joints if max(sp[j]) >= 60]
    body = [sum(sp[j][i] for j in joints) for i in range(n + 1)]
    still = [all(sp[j][i] < 12 for j in joints) for i in range(n + 1)]
    longest = run = 0
    for s_ in still:
        run = run + 1 if s_ else 0
        longest = max(longest, run)
    rest = []
    stops = 0
    starts = []
    peaks = []
    detail = []
    for j in active:
        pk = max(sp[j])
        under = [v < 0.1 * pk for v in sp[j]]
        rest.append(sum(under) / len(under))
        r = 0
        runs = []
        for i, u in enumerate(under + [False]):
            if u:
                r += 1
            else:
                if r >= 4:
                    stops += 1
                    starts.append(i - r)
                    runs.append("%.2f-%.2f" % ((i - r) / HZ, (i - 1) / HZ))
                r = 0
        peaks.append(sp[j].index(pk))
        detail.append("%s pk%d@%.2f [%s]" % (j, pk, sp[j].index(pk) / HZ, " ".join(runs)))
    print("STOPS", name, " | ".join(detail))
    unison = 0
    starts.sort()
    i = 0
    while i < len(starts):
        k = i
        while k < len(starts) and starts[k] - starts[i] <= 1:
            k += 1
        if k - i >= 3:
            unison += 1
        i = k
    med = sorted(body)[len(body) // 2]
    mean_pk = sum(peaks) / len(peaks) if peaks else 0
    spread = math.sqrt(sum((p - mean_pk) ** 2 for p in peaks) / len(peaks)) if peaks else 0
    print("METRICS %-13s len %.3f still %.1f%% longest %.3fs rest %.1f%% stops/s %.2f unison/s %.2f contrast %.2f spread %.1f active %d ikErr %.3f" % (
        name, length, 100 * sum(still) / len(still), longest / HZ, 100 * sum(rest) / max(1, len(rest)), stops / length, unison / length,
        max(body) / max(med, 1e-6), spread, len(active), ik_err))
    return sp


def apply_pose(P):
    arm.animation_data.action = None
    for nm in KEYED:
        m = P.basis.get(nm, ID)
        pbs[nm].rotation_quaternion = m.to_quaternion()
        pbs[nm].location = m.translation
    bpy.context.view_layer.update()


def sheet(poses, outdir, cams=("Player", "Front"), vine=False, face="Head", w=360, h=360):
    exec(open(os.path.join(D, "rtools.py")).read(), globals())
    os.makedirs(outdir, exist_ok=True)
    cm = render_setup(w, h, vine=vine, face=face)
    rep = Report()
    for i, (label, s) in enumerate(poses):
        P = solve(s, rep, i)
        apply_pose(P)
        knife = max(inside_body(P, p) for p in knife_pts(P))
        armr = max(inside_body(P, p) for p in limb_pts(P, "R"))
        arml = max(inside_body(P, p) for p in limb_pts(P, "L"))
        kw = P.W("Arm_R.004")
        bd = kw.to_3x3() @ Y
        tip = kw @ Vector((0, 0.9, 0))
        wr = P.head("Arm_R.002")
        print("POSE %02d %-10s knifeIn %.2f armRIn %.2f armLIn %.2f blade (%.2f %.2f %.2f) tip (%.2f %.2f %.2f) wristR (%.2f %.2f %.2f) wristL (%.2f %.2f %.2f) hips (%.2f %.2f %.2f)" % (
            i, label, knife, armr, arml, bd.x, bd.y, bd.z, tip.x, tip.y, tip.z, wr.x, wr.y, wr.z, *P.head("Arm_L.002"), *P.W("Bone").translation))
        shoot(cm, cams, os.path.join(outdir, "%02d_%s_%%s.png" % (i, label)))
    for k in sorted(rep.worst):
        v, t = rep.worst[k]
        print("  %-14s %7.3f at pose %d" % (k, v, t))


def tip_path(name, times):
    act = bpy.data.actions[name]
    arm.animation_data.action = act
    out = []
    for t in times:
        f = t * FPS
        scene.frame_set(int(f), subframe=f - int(f))
        W = pbs["Arm_R.004"].matrix
        tip = W @ Vector((0, 0.9, 0))
        out.append("%.3f:(%.2f,%.2f,%.2f)" % (t, tip.x, tip.y, tip.z))
    print("TIP", name, " ".join(out))


if __name__ == "__main__" or True:
    chk = solve(N)
    err = max((chk.W(n).translation - P0.W(n).translation).length for n in ["Arm_R.002", "Arm_L.002", "Arm_R.004", "Bone.003", "Boot_R.001"])
    kerr = math.degrees((chk.W("Arm_R.004").to_3x3() @ Y).angle(P0.W("Arm_R.004").to_3x3() @ Y))
    print("NEUTRAL check pos err %.4f knife dir err %.2f deg" % (err, kerr))
    print("NEUTRAL", {k: tuple(round(x, 3) for x in v) if isinstance(v, tuple) else v for k, v in N.items()})
    if ARGS.get("spec"):
        exec(open(os.path.join(D, ARGS["spec"])).read())
        if ARGS.get("save", "1") == "1":
            bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
            print("SAVED")
