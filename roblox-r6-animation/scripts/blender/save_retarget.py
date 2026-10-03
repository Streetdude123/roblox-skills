SD = json.load(open(os.path.join(D, "storm_grab.json")))
MM = Matrix(((-1, 0, 0), (0, 0, -1), (0, 1, 0)))
MMi = MM.inverted()
SCALE = 0.38


def srot(c):
    return Matrix(((c[3], c[4], c[5]), (c[6], c[7], c[8]), (c[9], c[10], c[11])))


def spos(c):
    return Vector((c[0], c[1], c[2]))


SR = {k: v["w"] for k, v in SD["rest"].items()}


def sdelta(fr, n):
    return (MM @ (srot(fr[n]) @ srot(SR[n]).inverted()) @ MMi).to_quaternion()


def sdir(fr, n, axis):
    m = srot(fr[n])
    v = Vector((m[0][axis], m[1][axis], m[2][axis]))
    return (MM @ v).normalized()


def storm_spec(fr):
    s = dict(N)
    qh = sdelta(fr, "spine")
    q1 = sdelta(fr, "spine.001")
    q4 = sdelta(fr, "spine.004")
    q6 = sdelta(fr, "spine.006")
    rel = qh.inverted() @ q1
    half = Quaternion().slerp(rel, 0.5)
    s["pel"] = unE(qh)
    s["sp"] = unE(half)
    s["ch"] = unE(half.inverted() @ rel)
    s["nk"] = unE(q1.inverted() @ q4)
    s["hd"] = unE(q4.inverted() @ q6)
    s["hip"] = tuple(MM @ (spos(fr["spine"]) - spos(SR["spine"])) * SCALE)
    qc = E(s["pel"]) @ E(s["sp"]) @ E(s["ch"])
    qci = qc.inverted()
    for side, sside in (("R", "L"), ("L", "R")):
        S_ = spos(fr["upper_arm." + sside])
        El = spos(fr["forearm." + sside])
        Wr = spos(fr["hand." + sside])
        L_ = (El - S_).length + (Wr - El).length
        u = (MM @ (Wr - S_)).normalized()
        ext = min(1.0, (Wr - S_).length / L_)
        e = MM @ (El - S_)
        pole = e - u * e.dot(u)
        if pole.length < 1e-4:
            pole = Vector((SG[side] * 0.5, -0.5, -0.7))
        s["a" + side] = tuple(qci @ u) + (ext,)
        s["e" + side] = tuple(qci @ pole.normalized())
        g = sdir(fr, "hand." + sside, 1)
        s["g" + side] = tuple(qci @ g)
        if side == "R":
            s["tR"] = tuple(qci @ sdir(fr, "Bone", 1))
        else:
            z = sdir(fr, "hand." + sside, 2)
            s["tL"] = tuple(qci @ (-z))
        elev = math.degrees(math.asin(max(-1, min(1, u.z))))
        lift = max(0.0, elev + 10) * 0.25
        s["c" + side] = (lift, 0.0, 0.0)
        s["f" + side] = (1.0,)
    for side, sside, bn in (("R", "L", "Boot_R.001"), ("L", "R", "Boot_L.001")):
        d = MM @ (spos(fr["foot." + sside]) - spos(SR["foot." + sside])) * SCALE
        base = RESTM[bn].translation
        fy = sdir(fr, "foot." + sside, 1)
        fy0 = (MM @ Vector((SR["foot." + sside][4], SR["foot." + sside][7], SR["foot." + sside][10]))).normalized()
        yaw = math.degrees(math.atan2(-fy.x, fy.y) - math.atan2(-fy0.x, fy0.y))
        s["foot" + side] = (base.x + d.x, base.y + d.y, base.z + d.z, yaw, 0.0)
    return s


SAVE_KEYS = []
fps_s = SD["fps"]
CUT = int(ARGS.get("cut", 32))
for i, fr in enumerate(SD["frames"][:CUT + 1]):
    SAVE_KEYS.append((i / fps_s, storm_spec(fr)))
SAVE_LEN = (len(SD["frames"]) - 1) / fps_s
last = SAVE_KEYS[-1][1]
t0 = SAVE_KEYS[-1][0]


def mixf(a, b, w, lift=0.0):
    return tuple(a[i] + (b[i] - a[i]) * w for i in range(5))[:2] + (a[2] + (b[2] - a[2]) * w + lift,) + tuple(a[i] + (b[i] - a[i]) * w for i in (3, 4))


K1 = pose(last, hip_add=(0, 0, -0.02), hd=(last["hd"][0], last["hd"][1] + 14, last["hd"][2] + 9))
K2 = pose(N, hip_add=(0.01, -0.01, -0.05), pel=(-12, 4, 2), sp=(-2, 3, 1), ch=(-2, 4, 1), nk=(8, 2, -1), hd=(8, 16, 6),
          fR=0, aR=(0.5, -0.2, -0.84, 0.97), tR=(0.2, 0.95, 0.0), eR=(0.6, -0.6, 0.1), gR=None,
          fL=0, aL=(-0.5, -0.2, -0.84, 0.97), tL=(0.1, 0.9, 0.3), eL=(-0.6, -0.4, -0.1), gL=None,
          footR=mixf(last["footR"], N["footR"], 0.5, 0.07), footL=mixf(last["footL"], N["footL"], 0.25, 0.0))
K3 = pose(N, hip_add=(0.0, -0.01, -0.035), pel=(-17, 2, 3), nk=(9, 1, -2), hd=(10, 8, 0),
          fR=0, aR=(0.45, -0.4, -0.8, 0.97), tR=(0.35, -0.9, 0.25), eR=(0.6, -0.6, 0.1), gR=None,
          fL=0, aL=(-0.45, -0.35, -0.82, 0.97), tL=(0.1, 0.9, 0.3), eL=(-0.6, -0.4, -0.1), gL=None,
          footR=N["footR"], footL=mixf(last["footL"], N["footL"], 0.6, 0.05))
SAVE_KEYS += [(t0 + 0.13, K1), (t0 + 0.27, K2), (t0 + 0.41, K3), (round(SAVE_LEN * 12) / 12, N)]
print("SAVEFEET end storm R", tuple(round(x, 2) for x in last["footR"]), "L", tuple(round(x, 2) for x in last["footL"]))
