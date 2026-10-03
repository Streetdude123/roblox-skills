VL = [LEN[n] for n in VINE]


def qchest(s):
    return E(s["pel"]) @ E(s["sp"]) @ E(s["ch"])


class VineChain:
    def __init__(self, k=(0.55, 0.42, 0.32), damp=(0.55, 0.6, 0.65), on=True):
        self.k = k
        self.damp = damp
        self.on = on
        self.x = {}
        self.xp = {}

    def apply(self, P, s, t, wave=None):
        qc = qchest(s)
        S = P.head("Arm_R.001")
        Wr = P.head("Arm_R.002")
        u = (Wr - S).normalized()
        vd = list(s["vd"])
        vl = list(s["vl"])
        dirs = [u] + [(qc @ Vector(vd[i * 3:i * 3 + 3])).normalized() for i in range(3)]
        if wave:
            dirs = wave(dirs, t, qc)
        head = P.head("Vine1")
        heads = [head]
        for i in range(3):
            heads.append(heads[-1] + dirs[i] * VL[i] * vl[i])
        tips = [heads[i] + dirs[i] * VL[i] * vl[i] for i in range(4)]
        if self.on:
            for i in range(1, 4):
                tgt = tips[i]
                base = heads[i]
                if i not in self.x:
                    self.x[i] = tgt.copy()
                    self.xp[i] = tgt.copy()
                x, xp = self.x[i], self.xp[i]
                nx = x + (x - xp) * self.damp[i - 1] + (tgt - x) * self.k[i - 1]
                d = (nx - base)
                if d.length < 1e-6:
                    d = dirs[i].copy()
                nd = d.normalized()
                seg = VL[i] * vl[i]
                nx = base + nd * seg
                self.xp[i] = x
                self.x[i] = nx
                dirs[i] = nd
                if i + 1 < 4:
                    heads[i + 1] = nx
                    tips[i + 1] = heads[i + 1] + dirs[i + 1] * VL[i + 1] * vl[i + 1]
        for i, n in enumerate(VINE):
            rest_y = R3[n] @ Y
            q = rest_y.rotation_difference(dirs[i]) @ RQ[n]
            P.put(n, mat(q, heads[i]))
        w = smooth((vl[1] - 0.3) / 0.6)
        if w > 0:
            T = dirs[1]
            fo = P.W("Arm_R.003").to_3x3() @ Y
            F = fo - T * fo.dot(T)
            if F.length < 1e-4:
                F = T.orthogonal()
            F.normalize()
            q_new = (remap(YREST["R"], THUMB["R"], F, T) @ R3["Arm_R.002"]).to_quaternion()
            q_old = P.W("Arm_R.002").to_quaternion()
            if q_old.dot(q_new) < 0:
                q_new = -q_new
            P.rot("Arm_R.002", q_old.slerp(q_new, w))
        return dirs


def hold_wave(dirs, t, qc):
    out = [dirs[0]]
    up = qc @ Z
    side = qc @ X
    for i in range(1, 4):
        ph = 2 * math.pi * t - i * 0.95
        ph0 = -i * 0.95
        a1 = math.radians(8 + 6 * i) * (math.sin(ph) - math.sin(ph0))
        a2 = math.radians(4 + 4 * i) * (math.sin(2 * ph + 0.7) - math.sin(2 * ph0 + 0.7))
        out.append((Quaternion(up, a1) @ Quaternion(side, a2) @ dirs[i]).normalized())
    return out


GROUND = (0.15, -0.95, -0.25)
TH = {}
c0 = solve(N)
S0 = c0.head("Arm_R.001")
u0 = (c0.head("Arm_R.002") - S0).normalized()
qn = qchest(N)
u0c = tuple(qn.inverted() @ u0)
TH["C0"] = pose(N, vd=u0c * 3, vl=(0.45, 0.12, 0.1, 0.08))
TH["C1"] = pose(N, hip_add=(0.01, -0.02, -0.03), pel=(-24, 2, 3), sp=(-3, 2, 1), ch=(-4, 3, 2), nk=(12, 0, -2), hd=(16, 4, -3),
                fR=0, aR=(0.55, -0.1, -0.83, 0.98), tR=(0.45, -0.3, -0.84), eR=(0.6, -0.6, 0.1), gR=None,
                fL=0, aL=(-0.42, -0.1, -0.9, 0.97), tL=(0.1, 0.9, 0.3), eL=(-0.6, -0.4, -0.1), gL=None,
                vd=(0.4, -0.3, -0.87, 0.3, -0.5, -0.81, 0.2, -0.6, -0.77), vl=(0.9, 0.5, 0.35, 0.25))
TH["C2"] = pose(TH["C1"], hip_add=(0.03, -0.04, -0.06), pel=(-28, 5, 5), sp=(-5, 4, 2), ch=(-7, 5, 4), nk=(16, -2, -1), hd=(18, 8, 4),
                fR=0, aR=(0.6, 0.25, -0.76, 0.98), tR=(0.3, 0.1, -0.95),
                fL=0, aL=(-0.5, 0.2, -0.84, 0.95), oL=0.4,
                vd=(0.3, 0.1, -0.95, 0.3, -0.8, -0.5, 0.1, -0.95, -0.2), vl=(1.0, 0.9, 0.8, 0.6))
TH["C3"] = pose(TH["C2"], hip_add=(0.04, -0.06, -0.075), pel=(-32, 7, 6), sp=(-6, 5, 2), ch=(-9, 6, 5), nk=(20, -3, 2), hd=(20, 12, 10),
                cR=(-4, -6, 0), cL=(2, 4, 0),
                fR=0, aR=(0.55, -0.15, -0.82, 0.98), tR=(0.25, -0.4, -0.88), eR=(0.5, -0.7, -0.2), gR=None,
                fL=0, aL=(-0.55, 0.3, -0.78, 0.92), tL=(0.0, 0.8, 0.6), eL=(-0.5, -0.6, -0.4), gL=None, oL=0.6,
                vd=(0.25, -0.4, -0.88) + GROUND + (-0.2, -0.9, 0.38), vl=(1.0, 1.0, 1.0, 1.0))
TH["T1"] = pose(TH["C3"], hip_add=(0.06, -0.08, -0.08), pel=(-40, 2, 8), sp=(-9, 0, 3), ch=(-12, -2, 6), nk=(24, 0, 1), hd=(24, 10, 8),
                cR=(6, -14, 0), cL=(0, 12, 0),
                fR=0, aR=(0.5, -0.65, -0.1, 0.98), tR=(0.2, -0.85, 0.48), eR=(0.4, -0.2, -0.9), gR=None,
                fL=0, aL=(-0.35, 0.55, -0.76, 0.92),
                vd=(0.2, -0.85, 0.48, 0.0, -0.9, 0.3, -0.1, -0.95, 0.1))
TH["T2"] = pose(TH["T1"], hip_add=(-0.02, 0.06, -0.09), pel=(-4, 8, 2), sp=(2, 6, 0), ch=(4, 8, 0), nk=(0, -6, 0), hd=(0, 8, 4),
                cR=(6, 12, 0), cL=(-2, -8, 0),
                fR=0, aR=(0.25, 0.8, 0.1, 0.99), tR=(0.3, 0.2, 0.93), eR=(0.6, -0.3, -0.75), gR=None,
                fL=0, aL=(-0.5, -0.3, -0.81, 0.97),
                vd=(0.3, 0.2, 0.93, 0.0, -0.6, 0.8, -0.1, -0.9, 0.3),
                footL=foot("L", dy=0.12, dz=0.04))
TH["T3"] = pose(TH["T2"], hip_add=(-0.01, 0.03, 0), pel=(0, 9, 0), sp=(0, 6, 0), ch=(-1, 8, -2), nk=(0, -6, 0), hd=(0, 6, 2),
                fR=0, aR=(0.18, 0.98, 0.05, 0.995), tR=(0.18, 0.98, 0.08),
                vd=(0.18, 0.98, 0.08, 0.17, 0.98, 0.09, 0.16, 0.98, 0.1), vl=(1.0, 1.45, 1.55, 1.7),
                footL=foot("L", dy=0.18))
TH["T4"] = pose(TH["T3"], hip_add=(0, 0.01, -0.005), pel=(2, 9, 0), ch=(0, 9, -2),
                fR=0, aR=(0.17, 0.98, 0.02, 0.995), vd=(0.17, 0.98, 0.05, 0.16, 0.98, 0.06, 0.15, 0.98, 0.07), vl=(1.0, 1.4, 1.5, 1.6))
TH["T5"] = pose(TH["T4"], hip_add=(0.03, -0.08, -0.1), pel=(-24, -6, 6), sp=(-6, -4, 2), ch=(-8, -6, 5), nk=(14, 4, 0), hd=(16, 6, 6),
                cR=(-2, -16, 0), cL=(2, 10, 0),
                fR=0, aR=(0.6, -0.4, -0.5, 0.97), tR=(0.6, 0.6, -0.5), eR=(0.3, -0.3, -0.9), gR=None,
                fL=0, aL=(-0.3, 0.6, -0.74, 0.9), oL=0.7,
                vd=(0.6, 0.6, -0.5, 0.4, 0.85, -0.3, 0.2, 0.95, -0.2), vl=(1.0, 1.0, 1.0, 1.0),
                footL=foot("L", dy=0.1))
TH["T6"] = pose(TH["T5"], hip_add=(0.02, -0.05, -0.07), pel=(-26, 0, 5), sp=(-5, 1, 2), ch=(-7, 2, 4), nk=(16, 0, 0), hd=(18, 8, 6),
                fR=0, aR=(0.62, -0.1, -0.78, 0.98), tR=(0.2, 0.3, 0.93), eR=(0.4, -0.6, -0.6), gR=None,
                vd=(0.2, 0.3, 0.93, -0.5, 0.2, 0.84, -0.8, -0.4, 0.4), vl=(0.9, 0.5, 0.3, 0.2))
TH["T7"] = pose(TH["T6"], hip_add=(0.01, -0.04, -0.05), pel=(-24, 2, 4), sp=(-3, 1, 1), ch=(-4, 2, 2), nk=(14, 0, -1), hd=(16, 5, 2),
                fR=0, aR=(0.55, -0.25, -0.8, 0.98), tR=(0.3, -0.2, -0.93), gR=None,
                fL=0, aL=(-0.42, -0.1, -0.9, 0.97), oL=0.2,
                vd=(0.3, -0.2, -0.93, 0.3, -0.2, -0.93, 0.3, -0.2, -0.93), vl=(0.55, 0.12, 0.1, 0.08),
                footL=foot("L", dy=0.04, dz=0.03))
TH["N2"] = pose(N, vd=u0c * 3, vl=(0.45, 0.12, 0.1, 0.08))
