import bpy, bmesh, math, os, sys, time, random
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import rbx
import numpy as np
from mathutils import Vector, Matrix, Euler

R = rbx.R
a = rbx.args(out=r"C:\Users\vietb\Desktop\roblox\Blender\Modeling\Samurai", tex="2048", cell="520", stage="block", seed="5")
out = a["out"]
os.makedirs(out, exist_ok=True)
T = int(a["tex"])
cell = int(a["cell"])
STAGE = a["stage"]
BLOCK = STAGE == "block"
rnd = random.Random(int(a["seed"]))
t0 = time.time()


def log(s):
    print("[%5.1fs] %s" % (time.time() - t0, s), flush=True)


def jr(d):
    return rnd.uniform(-d, d)


sc = rbx.fresh()
HI = rbx.col("High")
LO = rbx.col("Low")

ORDER = ["Skin", "Hair", "Lacquer", "Brass", "Rope", "Mail", "Black", "Wood", "Cloth", "Straw", "Steel"]
PAL = {"Skin": ((226, 176, 140), 0.6, 0), "Hair": ((196, 196, 192), 0.5, 0), "Lacquer": ((44, 10, 7), 0.44, 0), "Brass": ((168, 132, 96), 0.31, 1),
       "Rope": ((160, 150, 140), 0.95, 0), "Mail": ((28, 26, 23), 0.92, 0), "Black": ((18, 13, 9), 0.6, 0), "Wood": ((50, 34, 24), 0.8, 0),
       "Cloth": ((52, 31, 23), 0.85, 0), "Straw": ((50, 44, 36), 0.85, 0), "Steel": ((202, 206, 212), 0.26, 1)}
MAT = {}
for nm in ORDER:
    rgb, ro, me = PAL[nm]
    MAT[nm] = rbx.mat(nm, rbx.srgb(rgb), ro, me)
    if BLOCK:
        k_ = min(1.9, 235.0 / max(rgb))
        MAT[nm].diffuse_color = (*rbx.srgb(tuple(min(255, int(c * k_ + 14)) for c in rgb)), 1)

P = []


def tex(name, kind, **kw):
    t = bpy.data.textures.new(name, kind)
    for k, v in kw.items():
        setattr(t, k, v)
    return t


T_DENT = tex("Dent", "STUCCI", noise_scale=0.08, turbulence=4)
T_HAM = tex("Ham", "VORONOI", noise_scale=0.035, distance_metric="DISTANCE", weight_1=1.0, weight_2=0.0, weight_3=0.0, weight_4=0.0)
T_CLOTH = tex("Cloth", "CLOUDS", noise_scale=0.18, noise_depth=2)


def hcopy(lo, name=None):
    return rbx.dup(lo, name or lo.name + "H", HI, keep_mods=False)


def soft(ob, sub=2, dent=0.0, cloth=0.0, fold=None, ham=0.0):
    if sub:
        rbx.mod(ob, "SUBSURF", subdivision_type="SIMPLE", levels=sub, render_levels=sub)
    if cloth:
        rbx.mod(ob, "DISPLACE", texture=T_CLOTH, strength=cloth, mid_level=0.5)
    if dent:
        rbx.mod(ob, "DISPLACE", texture=T_DENT, strength=dent, mid_level=0.5)
    if ham:
        rbx.mod(ob, "DISPLACE", texture=T_HAM, strength=ham, mid_level=0.5)
    rbx.apply(ob)
    if fold:
        rbx.vdisp(ob, fold)
    rbx.smooth(ob)
    return ob


def hard(ob, bev=0.012, seg=3, sub=1, ham=0.0, dent=0.0):
    if bev:
        rbx.bevel(ob, bev, seg=seg, harden=False, strength="FSTR_NONE")
    return soft(ob, sub, dent=dent, ham=ham)


def reg(group, lo, mat, his=None):
    rbx.give(lo, MAT[mat])
    lo["group"] = group
    hs = []
    if not BLOCK:
        for h in (his if his is not None else [hcopy(lo)]):
            if not h.data.materials:
                rbx.give(h, MAT[mat])
            hs.append(h)
    P.append((lo, hs, group))
    return lo


def hi(fn):
    return None if BLOCK else fn()


def lo_bev(ob, w, seg=1):
    rbx.bevel(ob, w, seg=seg, harden=False, strength="FSTR_NONE")
    rbx.apply(ob)
    return ob


def ring3(w, d, r, z, cx=0.0, cy=0.0, n=40, start=-90.0):
    return [(cx + x, cy + y, z) for x, y in rbx.rr(w, d, r, n, R(start))]


def tube(name, rings, c=LO, caps=True):
    return rbx.loft(name, rings, c, cap0=caps, cap1=caps)


def ribbon(name, path, w, t, ups=None, c=LO, scale=None, twist=None, loop=False):
    return rbx.sweep(name, path, rbx.rect(w, t), c, ups=ups, scale=scale, twist=twist, loop=loop, caps=not loop)


def lens(w, t, n):
    return [(w / 2 * math.cos(a), t / 2 * math.sin(a)) for a in np.linspace(0, 2 * math.pi, n, endpoint=False)]


def fold_fn(cx, cy, freq, amp, z0, z1, phase=0.0):
    def f(P_, N_):
        ang = np.arctan2(P_[:, 1] - cy, P_[:, 0] - cx)
        w = rbx.sstep(z0, z0 + 0.15, P_[:, 2]) * (1 - rbx.sstep(z1 - 0.15, z1, P_[:, 2]))
        return amp * np.sin(ang * freq + phase) * w * (0.7 + 0.6 * rbx.fbm(P_, 1.5, 2, 3))
    return f


def streaks(amp, sx=40.0, sz=2.5, seed=7):
    def f(P_, N_):
        return amp * (rbx.fbm(P_ * np.array([sx, sx, sz], np.float32), 1.0, 3, seed) - 0.5)
    return f


def rope(name, path, r=0.026, c=LO, loop=False, high=False):
    if not high:
        return rbx.sweep(name, path, rbx.circle(r, 4, R(45)), c, loop=loop, caps=not loop)
    src = list(path) + ([path[0]] if loop else [])
    pth = rbx.resample(src, 0.012)
    if loop:
        pth = pth[:-1]
    L_ = sum((Vector(q) - Vector(p)).length for p, q in zip(pth, pth[1:]))
    turn = (round(L_ / 0.33) * 360.0) if loop else (L_ / 0.11 * 120.0)
    prof = [(r * (0.84 + 0.16 * math.cos(3 * t)) * math.cos(t), r * (0.84 + 0.16 * math.cos(3 * t)) * math.sin(t)) for t in np.linspace(0, 2 * math.pi, 18, endpoint=False)]
    return rbx.sweep(name, pth, prof, c, loop=loop, caps=not loop, twist=lambda u: u * turn)


def cut_ring(w, d, r, z, keep, m, cx=0.0):
    dense = rbx.rr(w, d, r, 600, R(-90))
    i = next(i for i, (x, y) in enumerate(dense) if keep(x, y))
    seq = [(x, y) for x, y in dense[i:] + dense[:i] if keep(x, y)]
    return [(cx + x, y, z) for x, y in rbx.ring_sample(seq, m, closed=False)]


def frame_of(f):
    nd = Vector((f["nd"][0], f["nd"][1], 0)).normalized()
    tg = Vector((-nd.y, nd.x, 0))
    tl = R(f["tilt"])
    up = Vector((0, 0, 1)) * math.cos(tl) - nd * math.sin(tl)
    ou = nd * math.cos(tl) + Vector((0, 0, 1)) * math.sin(tl)
    return nd, tg, up, ou


def surf(f, u, hz, lift=0.0):
    nd, tg, up, ou = frame_of(f)
    return Vector(f["ctr"]) + tg * (u * f["w"] / 2) + nd * (f["bow"] * (1 - u * u)) + up * hz + ou * (f["t"] / 2 + lift)


def hplate(name, f, n=7, c=LO, bev=0.0):
    nd, tg, up, ou = frame_of(f)
    path = [tuple(Vector(f["ctr"]) + tg * (u * f["w"] / 2) + nd * (f["bow"] * (1 - u * u))) for u in np.linspace(-1, 1, n)]
    prof = rbx.rect(f["t"], f["h"], bev, 2) if bev else rbx.rect(f["t"], f["h"])
    return rbx.sweep(name, path, prof, c, ups=[tuple(up)] * n)


def deco_frame(f, u, hz):
    nd, tg, up, ou = frame_of(f)
    m = Matrix((ou.cross(up), ou, up)).transposed().to_4x4()
    m.translation = surf(f, u, hz)
    return m


def slots(f, hz, count, name, span=0.84):
    parts = []
    for k in range(count):
        u = -span + 2 * span * k / max(count - 1, 1)
        s_ = rbx.box(name, (0.1, 0.016, 0.032), (0, 0, 0), HI)
        rbx.bevel(s_, 0.007, seg=2, harden=False, strength="FSTR_NONE")
        rbx.apply(s_)
        rbx.place(s_, deco_frame(f, u + jr(0.01), hz))
        parts.append(s_)
    j = rbx.join(parts, name)
    rbx.give(j, MAT["Brass"])
    return j


def ties(f, us, name):
    parts = []
    for u in us:
        tor = rbx.torus(name, 0.026, 0.009, 10, 5, (0, 0, 0), "YZ", HI)
        rbx.place(tor, deco_frame(f, u, f["h"] / 2 - 0.012))
        parts.append(tor)
    j = rbx.join(parts, name)
    rbx.give(j, MAT["Rope"])
    return j


def rivets(spots, name, r=0.028):
    parts = []
    for p, nrm in spots:
        d = rbx.dome(name, r, 10, 3, HI)
        rbx.place(d, rbx.orient(p, nrm))
        parts.append(d)
    j = rbx.join(parts, name)
    rbx.give(j, MAT["Brass"])
    return j


def plate_reg(group, name, f, slot_n=0, tie_us=(), ends=False):
    lo = hplate(name, f)

    def build():
        h = hplate(name + "H", f, 25, HI, 0.012)
        soft(h, 1, dent=0.0015)
        rbx.give(h, MAT["Lacquer"])
        out_ = [h]
        if slot_n:
            out_.append(slots(f, f["h"] / 2 - 0.1, slot_n, name + "SlotsH"))
        if tie_us:
            out_.append(ties(f, tie_us, name + "TiesH"))
        if ends:
            nd, tg, up, ou = frame_of(f)
            out_.append(rivets([(surf(f, u, 0.0), ou) for u in (-0.8, 0.8)], name + "RivetsH"))
        return out_

    return reg(group, lo, "Lacquer", hi(build))


HZ = 4.57
log("head")
head = lo_bev(rbx.box("Head", (1.18, 1.12, 1.14), (0, 0, HZ), LO), 0.34, 3)
reg("Head", head, "Skin", hi(lambda: [soft(hcopy(head), 2)]))
neck = rbx.cyl("Neck", 0.27, 0.34, 12, (0, 0.03, 4.02), "Z", LO)
reg("Head", neck, "Skin", hi(lambda: [soft(hcopy(neck), 1)]))

_hp = np.array(rbx.rr(1.18, 1.12, 0.34, 720, 0.0))
_ha = np.arctan2(_hp[:, 1], _hp[:, 0])
_hr = np.hypot(_hp[:, 0], _hp[:, 1])
_o = np.argsort(_ha)
_ha, _hr = _ha[_o], _hr[_o]


def head_r(phi):
    return float(np.interp(phi, _ha, _hr, period=2 * math.pi))


def head_sec(z, off):
    s = 0.0
    if z > 4.8:
        s = 0.34 - math.sqrt(max(0.0, 0.34 ** 2 - (z - 4.8) ** 2))
    elif z < 4.34:
        s = 0.34 - math.sqrt(max(0.0, 0.34 ** 2 - (4.34 - z) ** 2))
    return 1.18 - 2 * s + 2 * off, 1.12 - 2 * s + 2 * off, max(0.34 - s, 0.08) + off


def menpo(name, na, nz, c):
    bm = bmesh.new()
    grid = []
    for i in range(nz + 1):
        t = i / nz
        row = []
        for j in range(na + 1):
            dd = -85 + 170 * j / na
            phi = R(-90 + dd)
            zb = 4.05 + 0.1 * (abs(dd) / 85) ** 1.5
            zt = 4.46 + 0.16 * math.exp(-(dd / 13) ** 2) - 0.03 * abs(dd) / 85
            z = zb + t * (zt - zb)
            r = head_r(phi) + 0.04 + 0.05 * math.exp(-(dd / 38) ** 2) * math.sin(math.pi * min(t * 1.15, 1.0)) ** 0.6
            r += 0.07 * math.exp(-(dd / 8) ** 2) * float(rbx.sstep(0.45, 1.0, np.float32(t)))
            row.append(bm.verts.new((r * math.cos(phi), r * math.sin(phi), z)))
        grid.append(row)
    for i in range(nz):
        for j in range(na):
            bm.faces.new((grid[i][j], grid[i][j + 1], grid[i + 1][j + 1], grid[i + 1][j]))
    bm.normal_update()
    bm.faces.ensure_lookup_table()
    f0 = bm.faces[len(bm.faces) // 2]
    if f0.normal.dot(f0.calc_center_median() - Vector((0, 0, f0.calc_center_median().z))) < 0:
        bmesh.ops.reverse_faces(bm, faces=bm.faces)
    ob = rbx.put(name, bm, c)
    rbx.mod(ob, "SOLIDIFY", thickness=0.035, offset=-1.0, use_even_offset=True)
    rbx.apply(ob)
    return ob


mask = menpo("Mask", 16, 5, LO)
reg("Head", mask, "Black", hi(lambda: [soft(menpo("MaskH", 64, 20, HI), 1, ham=0.0015)]))


def cap_keep(z):
    yl = float(np.interp(z, [4.0, 4.5, 4.7], [0.1, 0.1, 0.0]))
    xl = float(np.interp(z, [4.0, 4.5, 4.7, 4.95, 5.06, 5.2], [0.68, 0.68, 0.5, 0.5, 0.3, 0.1]))
    return lambda x, y: not (y < yl and abs(x) < xl)


def hair_cap(name, zs, m, c):
    rings = []
    for z in zs:
        w, d, r = head_sec(z, 0.02)
        rings.append(cut_ring(w, d, r, z, cap_keep(z), m))
    ob = rbx.loft_open(name, rings, c)
    rbx.mod(ob, "SOLIDIFY", thickness=0.03, offset=1.0, use_even_offset=True)
    rbx.apply(ob)
    return ob


cap = hair_cap("HairCap", [4.05, 4.25, 4.45, 4.62, 4.78, 4.92, 5.04, 5.12, 5.17], 18, LO)
reg("Head", cap, "Hair", hi(lambda: [soft(hair_cap("HairCapH", list(np.linspace(4.05, 5.17, 24)), 90, HI), 1, fold=fold_fn(0, 0.02, 44, 0.006, 4.05, 5.25))]))

taper = lambda u: 1.0 - 0.88 * u ** 2.2


def lock_path(phi, z0, z1, r0, r1, drift):
    pts = []
    for t in np.linspace(0, 1, 6):
        r = r0 + (r1 - r0) * t ** 1.6
        p_ = phi + drift * t
        pts.append((r * math.cos(p_), r * math.sin(p_), z0 + (z1 - z0) * t))
    return pts


locks = []
for k in range(9):
    phi = R(24 + 132 * k / 8 + jr(4))
    locks.append(("Lock%d" % k, phi, 4.86, 3.88 + 0.12 * abs(math.sin(k * 1.9)) + jr(0.03), 0.23 + jr(0.02), jr(0.1)))
for k, phi in enumerate((-14, 12, 168, 194)):
    locks.append(("SideLock%d" % k, R(phi + jr(3)), 4.88, 4.16 + jr(0.04), 0.2, R(-6 if phi < 90 else 6)))
for nm, phi, z0, z1, w, drift in locks:
    r0 = head_r(phi) + 0.06
    lp = lock_path(phi, z0, z1, r0, r0 + 0.2, drift)
    ups = [(math.cos(phi + drift * t), math.sin(phi + drift * t), 0) for t in np.linspace(0, 1, 6)]
    lo = rbx.sweep(nm, lp, lens(w, 0.06, 4), LO, ups=ups, scale=taper)

    def lock_hi(nm=nm, lp=lp, phi=phi, drift=drift, w=w):
        hp = rbx.resample(lp, 0.02)
        hu = [(math.cos(phi + drift * t), math.sin(phi + drift * t), 0) for t in np.linspace(0, 1, len(hp))]
        return [soft(rbx.sweep(nm + "H", hp, lens(w, 0.06, 12), HI, ups=hu, scale=taper), 1, fold=streaks(0.008, 45, 3, 11))]

    reg("Head", lo, "Hair", hi(lock_hi))

log("hat")
HAT = Vector((0, 0.0, 5.1))
hat_tilt = Matrix.Translation(HAT) @ Euler((R(-4), R(3), 0)).to_matrix().to_4x4() @ Matrix.Translation(-HAT)
brim_prof = [(0.5, 0.03), (0.95, -0.02), (1.42, -0.1), (1.445, -0.118), (1.42, -0.135), (0.95, -0.055), (0.5, 0.0), (0.5, 0.03)]
brim = rbx.place(rbx.lathe("Brim", brim_prof, 40, LO, at=HAT), hat_tilt)
reg("Hat", brim, "Black", hi(lambda: [soft(rbx.place(rbx.lathe("BrimH", brim_prof, 160, HI, at=HAT), hat_tilt), 1, fold=streaks(0.002, 12, 12, 5))]))
crown_prof = [(0.0, 0.58), (0.42, 0.58), (0.49, 0.55), (0.52, 0.46), (0.53, 0.0)]
crown = rbx.place(rbx.lathe("Crown", crown_prof, 24, LO, at=HAT), hat_tilt)
reg("Hat", crown, "Cloth", hi(lambda: [soft(rbx.place(rbx.lathe("CrownH", crown_prof, 96, HI, at=HAT), hat_tilt), 1, dent=0.002)]))
band_path = [(HAT.x + 0.545 * math.cos(t), HAT.y + 0.545 * math.sin(t), HAT.z + 0.19) for t in np.linspace(0, 2 * math.pi, 24, endpoint=False)]
band = rbx.place(rbx.sweep("Band", band_path, rbx.rect(0.022, 0.18), LO, ups=[(0, 0, 1)] * 24, loop=True, caps=False), hat_tilt)
reg("Hat", band, "Lacquer", hi(lambda: [soft(rbx.place(rbx.sweep("BandH", [(HAT.x + 0.545 * math.cos(t), HAT.y + 0.545 * math.sin(t), HAT.z + 0.19) for t in np.linspace(0, 2 * math.pi, 96, endpoint=False)], rbx.rect(0.022, 0.18, 0.006, 2), HI, ups=[(0, 0, 1)] * 96, loop=True, caps=False), hat_tilt), 1)]))
for k in range(8):
    t = 2 * math.pi * (k + 0.5) / 8
    rad = Vector((math.cos(t), math.sin(t), 0))
    st = rbx.cyl("Stud%d" % k, 0.05, 0.05, 4, (0, 0, 0), "Z", LO, r2=0.0)
    rbx.place(st, hat_tilt @ rbx.orient(HAT + Vector((0, 0, 0.19)) + rad * 0.57, rad))
    reg("Hat", st, "Brass", hi(lambda st=st: [hard(hcopy(st), 0.006, 2, 1)]))
fs = rbx.fillet([(0.7, -0.44, 5.04), (0.72, -0.62, 4.78), (0.75, -0.73, 4.32), (0.77, -0.75, 3.82)], 0.1, 3)
strip = ribbon("StripFront", rbx.resample(fs, 0.12), 0.2, 0.02, [(0, -1, 0)] * len(rbx.resample(fs, 0.12)))
reg("Hat", strip, "Cloth", hi(lambda: [soft(ribbon("StripFrontH", rbx.resample(fs, 0.02), 0.2, 0.02, [(0, -1, 0)] * len(rbx.resample(fs, 0.02)), c=HI), 1, cloth=0.004)]))
bs = rbx.fillet([(0.04, 0.5, 5.04), (0.05, 0.74, 4.8), (0.07, 0.86, 4.4), (0.08, 0.88, 4.06)], 0.1, 3)
strip2 = ribbon("StripBack", rbx.resample(bs, 0.12), 0.18, 0.02, [(0, 1, 0)] * len(rbx.resample(bs, 0.12)))
reg("Hat", strip2, "Cloth", hi(lambda: [soft(ribbon("StripBackH", rbx.resample(bs, 0.02), 0.18, 0.02, [(0, 1, 0)] * len(rbx.resample(bs, 0.02)), c=HI), 1, cloth=0.004)]))
TAG = Vector((-1.2, -0.42, 4.76))
tcord = rbx.sweep("CharmCord", [(-1.2, -0.4, 4.99), (-1.2, -0.42, 4.85)], rbx.circle(0.009, 4), LO)
reg("Hat", tcord, "Rope", hi(lambda: [rbx.sweep("CharmCordH", [(-1.2, -0.4, 4.99), (-1.2, -0.42, 4.85)], rbx.circle(0.009, 8), HI)]))
tag = rbx.box("Charm", (0.11, 0.014, 0.19), (0, 0, 0), LO)
rbx.place(tag, Matrix.Translation(TAG) @ Matrix.Rotation(R(6), 4, "Y"))
reg("Hat", tag, "Rope", hi(lambda: [hard(hcopy(tag), 0.004, 2, 1)]))

log("torso")
core = lo_bev(rbx.box("Core", (1.96, 0.98, 2.0), (0, 0, 3.0), LO), 0.1, 2)
reg("Torso", core, "Mail", hi(lambda: [soft(hcopy(core), 2)]))
DOZ = [2.52, 2.76, 3.06, 3.36, 3.6]
DOW = [(2.0, 1.22, 0.16), (2.02, 1.27, 0.18), (2.03, 1.31, 0.19), (2.02, 1.3, 0.19), (2.0, 1.26, 0.18)]


def do_depth(z):
    return float(np.interp(z, DOZ, [d for w, d, r in DOW]))


def do_shell(name, n, nz, c):
    zs = np.linspace(DOZ[0], DOZ[-1], nz)
    rings = []
    for z in zs:
        w, d, r = [float(np.interp(z, DOZ, [q[i] for q in DOW])) for i in range(3)]
        rings.append(ring3(w, d, r, z, n=n))
    return tube(name, rings, c)


def do_grooves(P_, N_):
    z = P_[:, 2]
    g = np.exp(-((z - 3.46) / 0.012) ** 2) * (P_[:, 1] < 0)
    g += (np.exp(-((z - 3.2) / 0.012) ** 2) + np.exp(-((z - 2.9) / 0.012) ** 2)) * (P_[:, 1] > 0)
    return -0.008 * g * (np.abs(N_[:, 2]) < 0.5)


def do_high():
    h = do_shell("DoH", 128, 14, HI)
    soft(h, 1, dent=0.0015, fold=do_grooves)
    rbx.give(h, MAT["Lacquer"])
    out_ = [h]
    for side_, sy in (("F", -1), ("B", 1)):
        rows = (3.5, 3.42, 2.62) if sy < 0 else (3.28, 2.98, 2.62)
        parts = []
        for z in rows:
            for k in range(11):
                x = -0.8 + 0.16 * k + jr(0.008)
                s_ = rbx.box("DoSlot", (0.1, 0.016, 0.032), (0, 0, 0), HI)
                rbx.bevel(s_, 0.007, seg=2, harden=False, strength="FSTR_NONE")
                rbx.apply(s_)
                ou = Vector((0, sy, 0))
                m = Matrix((ou.cross(Vector((0, 0, 1))), ou, Vector((0, 0, 1)))).transposed().to_4x4()
                m.translation = Vector((x, sy * do_depth(z) / 2, z))
                rbx.place(s_, m)
                parts.append(s_)
        j = rbx.join(parts, "DoSlots%sH" % side_)
        rbx.give(j, MAT["Brass"])
        out_.append(j)
    return out_


do = do_shell("Do", 32, 5, LO)
reg("Torso", do, "Lacquer", hi(do_high))
MUZ = [3.56, 3.8, 3.97]
MUW = [(1.98, 1.22, 0.17), (1.96, 1.2, 0.16), (1.9, 1.12, 0.14)]


def munaita(name, n, c):
    return tube(name, [ring3(w, d, r, z, n=n) for z, (w, d, r) in zip(MUZ, MUW)], c)


def mu_high():
    h = munaita("MunaitaH", 128, HI)
    soft(h, 1, dent=0.0015)
    rbx.give(h, MAT["Lacquer"])
    parts = []
    for sy in (-1, 1):
        for k in range(11):
            x = -0.78 + 0.156 * k + jr(0.008)
            s_ = rbx.box("MuSlot", (0.1, 0.016, 0.032), (0, 0, 0), HI)
            rbx.bevel(s_, 0.007, seg=2, harden=False, strength="FSTR_NONE")
            rbx.apply(s_)
            ou = Vector((0, sy, 0))
            m = Matrix((ou.cross(Vector((0, 0, 1))), ou, Vector((0, 0, 1)))).transposed().to_4x4()
            m.translation = Vector((x, sy * 0.605, 3.86))
            rbx.place(s_, m)
            parts.append(s_)
    j = rbx.join(parts, "MuSlotsH")
    rbx.give(j, MAT["Brass"])
    tl = []
    for x in (-0.42, 0.42):
        tor = rbx.torus("MuTie", 0.026, 0.009, 10, 5, (0, 0, 0), "YZ", HI)
        m = Matrix(((-1, 0, 0), (0, -1, 0), (0, 0, 1))).transposed().to_4x4()
        m.translation = Vector((x, -0.61, 3.95))
        rbx.place(tor, m)
        tl.append(tor)
    tj = rbx.join(tl, "MuTiesH")
    rbx.give(tj, MAT["Rope"])
    return [h, j, tj]


mu = munaita("Munaita", 32, LO)
reg("Torso", mu, "Lacquer", hi(mu_high))
osh_path = [(0.68 * math.cos(t), 0.12 + 0.5 * math.sin(t), 4.1) for t in np.linspace(R(28), R(152), 9)]
osh_up = tuple(Vector((0, 0.28, 1)).normalized())
osh = rbx.sweep("Oshitsuke", osh_path, rbx.rect(0.06, 0.36), LO, ups=[osh_up] * 9)
reg("Torso", osh, "Lacquer", hi(lambda: [soft(rbx.sweep("OshitsukeH", [(0.68 * math.cos(t), 0.12 + 0.5 * math.sin(t), 4.1) for t in np.linspace(R(28), R(152), 33)], rbx.rect(0.06, 0.36, 0.012, 2), HI, ups=[osh_up] * 33), 1, dent=0.0015)]))
belt_path = ring3(2.1, 1.34, 0.26, 2.47, n=28)
belt = rope("Belt", belt_path, 0.028, loop=True)
reg("Torso", belt, "Rope", hi(lambda: [rope("BeltH", ring3(2.1, 1.34, 0.26, 2.47, n=140), 0.028, HI, loop=True, high=True)]))
bk = rbx.lathe("BeltKnot", [(0, 0.06), (0.05, 0.045), (0.065, 0.0), (0.05, -0.045), (0, -0.06)], 8, LO, at=(0.62, -0.69, 2.47))
reg("Torso", bk, "Rope", hi(lambda: [soft(hcopy(bk), 1)]))
for side_, sy in (("Front", -1), ("Back", 1)):
    for k in range(4):
        f = dict(ctr=Vector((jr(0.012), sy * (0.67 + 0.05 * k), 2.42 - 0.4 * k - 0.23)), nd=(0, sy), w=1.3 + 0.04 * k, h=0.46, t=0.065, bow=0.03, tilt=9 + jr(1.2))
        plate_reg("Torso", "Kusazuri%s%d" % (side_, k), f, slot_n=7, tie_us=(-0.45, 0.45))

log("arms")


def arm(s):
    cx = s * 1.5
    side = "Left" if s > 0 else "Right"
    grp = side + "Arm"
    slv = lo_bev(rbx.box(side + "Sleeve", (1.04, 1.04, 2.0), (cx, 0, 3.0), LO), 0.14, 2)
    reg(grp, slv, "Mail", hi(lambda: [soft(hcopy(slv), 2)]))

    def xloop(sg, n):
        return [(cx + x, y, 3.43 + sg * 0.62 * x) for x, y in rbx.rr(1.1, 1.1, 0.18, n, 0.0)]

    for k, sg in enumerate((1, -1)):
        xl = rope(side + "RopeX%d" % k, xloop(sg, 24), loop=True)
        reg(grp, xl, "Rope", hi(lambda sg=sg, k=k: [rope(side + "RopeX%dH" % k, xloop(sg, 160), high=True, loop=True)]))
    for k, z in enumerate((2.66, 2.5, 2.34)):
        wl = rope(side + "Wrap%d" % k, ring3(1.1, 1.1, 0.18, z, cx, 0.0, 24), loop=True)
        reg(grp, wl, "Rope", hi(lambda z=z, k=k: [rope(side + "Wrap%dH" % k, ring3(1.1, 1.1, 0.18, z, cx, 0.0, 140), high=True, loop=True)]))
    for k in range(3):
        f = dict(ctr=Vector((cx + s * (0.64 + 0.075 * k), jr(0.01), 3.9 - 0.26 * k - 0.16)), nd=(s, 0), w=1.24 - 0.02 * k, h=0.32, t=0.1, bow=0.04, tilt=16 + 7 * k + jr(1.5))
        plate_reg(grp, side + "Sode%d" % k, f, ends=True)
    for k in range(3):
        f = dict(ctr=Vector((cx + s * (0.64 + 0.075 * k), jr(0.01), 2.96 - 0.25 * k - 0.15)), nd=(s, 0), w=1.16 - 0.02 * k, h=0.3, t=0.1, bow=0.04, tilt=16 + 7 * k + jr(1.5))
        plate_reg(grp, side + "Kote%d" % k, f, ends=True)
    for k, (dx, z, L_, ang) in enumerate(((0.0, 4.1, 0.72, 14), (0.46, 3.98, 0.5, 28))):
        m = Matrix.Translation((cx + s * dx, jr(0.01), z)) @ Matrix.Rotation(R(s * (ang + jr(1.5))), 4, "Y")
        bx = rbx.box(side + "Top%d" % k, (L_, 1.32 - 0.04 * k, 0.085), (0, 0, 0), LO)
        lo_bev(bx, 0.015, 1)
        rbx.place(bx, m)

        def top_hi(m=m, L_=L_, k=k):
            h = rbx.box(side + "Top%dH" % k, (L_, 1.32 - 0.04 * k, 0.085), (0, 0, 0), HI)
            rbx.place(h, m)
            hard(h, 0.014, 3, 1, dent=0.0015)
            rbx.give(h, MAT["Lacquer"])
            up_ = (m.to_3x3() @ Vector((0, 0, 1))).normalized()
            spots = [(m @ Vector((s * (L_ / 2 - 0.08), y, 0.0425)), up_) for y in (-0.45, 0.45)]
            return [h, rivets(spots, side + "Top%dRivetsH" % k)]

        reg(grp, bx, "Lacquer", hi(top_hi))


arm(1)
arm(-1)

log("legs")


def leg(s):
    cx = s * 0.5
    side = "Left" if s > 0 else "Right"
    grp = side + "Leg"
    th_ = lo_bev(rbx.box(side + "Thigh", (0.98, 0.98, 1.1), (cx, 0, 1.45), LO), 0.1, 2)
    reg(grp, th_, "Mail", hi(lambda: [soft(hcopy(th_), 2)]))
    sh = lo_bev(rbx.box(side + "Shin", (0.92, 0.92, 0.64), (cx, 0, 0.7), LO), 0.12, 2)
    reg(grp, sh, "Mail", hi(lambda: [soft(hcopy(sh), 2)]))
    ol = rbx.rr(1.0, 1.0, 0.22, 44, R(-90))
    for i in range(0, 44, 2):
        x, y = ol[i]
        if s * x < -0.32:
            continue
        xa, ya = ol[(i - 1) % 44]
        xb, yb = ol[(i + 1) % 44]
        tg = Vector((xb - xa, yb - ya, 0)).normalized()
        m = rbx.orient(Vector((cx + x, y, 0.72 + jr(0.012))), Vector((0, 0, 1)), tg) @ Matrix.Rotation(R(jr(2.0)), 4, "Y")
        spl = rbx.box(side + "Splint%d" % i, (0.13, 0.05, 0.62), (0, 0, 0), LO)
        rbx.place(spl, m)

        def spl_hi(m=m, i=i):
            h = rbx.box(side + "Splint%dH" % i, (0.13, 0.05, 0.62), (0, 0, 0), HI)
            rbx.bevel(h, 0.014, seg=3, harden=False, strength="FSTR_NONE")
            rbx.apply(h)
            rbx.place(h, m)
            soft(h, 2, fold=streaks(0.005, 50, 3, 3 + i))
            return [h]

        reg(grp, spl, "Wood", hi(spl_hi))
    for k, z in enumerate((1.0, 0.46)):
        tl = rope(side + "ShinTie%d" % k, ring3(1.1, 1.1, 0.26, z, cx, 0.0, 24), loop=True)
        reg(grp, tl, "Rope", hi(lambda z=z, k=k: [rope(side + "ShinTie%dH" % k, ring3(1.1, 1.1, 0.26, z, cx, 0.0, 140), high=True, loop=True)]))
        for j, sgn in enumerate((-1, 1)):
            bpath = [(cx + sgn * 0.035, -0.56, z), (cx + sgn * 0.1, -0.6, z + 0.05), (cx + sgn * 0.13, -0.58, z), (cx + sgn * 0.1, -0.6, z - 0.04), (cx + sgn * 0.035, -0.56, z)]
            bw = rope(side + "Bow%d%d" % (k, j), bpath, 0.02)
            reg(grp, bw, "Rope", hi(lambda bpath=bpath, k=k, j=j: [rope(side + "Bow%d%dH" % (k, j), rbx.fillet(bpath, 0.03, 3), 0.02, HI, high=True)]))
    for k in range(3):
        f = dict(ctr=Vector((cx + s * (0.55 + 0.05 * k), jr(0.01), 1.98 - 0.33 * k - 0.19)), nd=(s, 0), w=0.86, h=0.38, t=0.065, bow=0.025, tilt=10 + jr(1.5))
        plate_reg(grp, side + "Haidate%d" % k, f, slot_n=5, tie_us=(-0.4, 0.4))
    sole = lo_bev(rbx.box(side + "Sole", (1.02, 1.3, 0.08), (cx, -0.12, 0.04), LO), 0.03, 1)
    reg(grp, sole, "Wood", hi(lambda: [hard(hcopy(sole), 0.02, 2, 2, ham=0.002)]))
    wj = lo_bev(rbx.box(side + "Waraji", (0.98, 1.26, 0.03), (cx, -0.12, 0.095), LO), 0.012, 1)
    reg(grp, wj, "Straw", hi(lambda: [hard(hcopy(wj), 0.006, 2, 3, ham=0.003)]))
    ft = lo_bev(rbx.box(side + "Foot", (0.94, 1.14, 0.3), (cx, -0.09, 0.26), LO), 0.13, 2)
    reg(grp, ft, "Straw", hi(lambda: [soft(hcopy(ft), 2, cloth=0.004)]))
    for j, (y0, y1) in enumerate(((-0.5, -0.2), (-0.2, -0.5))):
        sp = rbx.fillet([(cx - 0.47, y0, 0.11), (cx - 0.3, (y0 + y1) / 2 - 0.08, 0.38), (cx, (y0 + y1) / 2 - 0.1, 0.43), (cx + 0.3, (y0 + y1) / 2 - 0.08, 0.38), (cx + 0.47, y1, 0.11)], 0.08, 3)
        stp = rope(side + "Strap%d" % j, rbx.resample(sp, 0.1), 0.022)
        reg(grp, stp, "Rope", hi(lambda sp=sp, j=j: [rope(side + "Strap%dH" % j, sp, 0.022, HI, high=True)]))


leg(1)
leg(-1)

log("weapons")
L = 3.0


def blade_ring(z):
    w = 0.26 + (0.21 - 0.26) * min(z / 2.73, 1.0)
    t = 0.06 + (0.04 - 0.06) * min(z / L, 1.0)
    dx = -0.14 * (z / L) ** 2
    zk = 2.73
    if z > zk:
        u = min((z - zk) / (L - zk), 1.0)
        span = w * math.sqrt(max(0.0, 1 - u ** 1.6))
        e = -w / 2 + span
        sh = -w / 2 + span * 0.6
        tt = t * (1 - 0.7 * u)
        pts = [(e, 0.0), (sh, tt / 2), (-w / 2, tt * 0.32), (-w / 2, -tt * 0.32), (sh, -tt / 2)]
    else:
        pts = [(w / 2, 0.0), (w / 2 - 0.38 * w, t / 2), (-w / 2, t * 0.32), (-w / 2, -t * 0.32), (w / 2 - 0.38 * w, -t / 2)]
    return [(x + dx, y, z) for x, y in pts]


def katana_parts(prefix, c, hilt_only=False, high=False):
    out_ = []
    if not hilt_only:
        zs = [0.0, 0.4, 0.9, 1.5, 2.1, 2.6, 2.73, 2.82, 2.89, 2.95] if not high else list(np.linspace(0, 2.73, 40)) + [2.78, 2.82, 2.86, 2.9, 2.93, 2.96, 2.98]
        bl = rbx.loft(prefix + "Blade", [blade_ring(z) for z in zs], c, cap0=True, tip=(-0.14 - 0.105 + 0.005, 0, L))
        out_.append((bl, "Steel"))
    hb = rbx.box(prefix + "Habaki", (0.27, 0.1, 0.19), (0, 0, -0.035), c)
    rbx.bevel(hb, 0.02, seg=3 if high else 1, harden=False, strength="FSTR_NONE")
    rbx.apply(hb)
    out_.append((hb, "Brass"))
    for j, z in enumerate((-0.135, -0.205)):
        sp = rbx.lathe(prefix + "Seppa%d" % j, [(0, 0.006), (0.135, 0.006), (0.135, -0.006), (0, -0.006)], 32 if high else 16, c, at=(0, 0, z))
        out_.append((sp, "Brass"))
    outline = [(0.215 * (1 + 0.08 * math.cos(4 * t)) * math.cos(t), 0.2 * (1 + 0.08 * math.cos(4 * t)) * math.sin(t)) for t in np.linspace(0, 2 * math.pi, 64 if high else 20, endpoint=False)]
    ts = rbx.prism(prefix + "Tsuba", outline, -0.193, -0.147, c)
    holes = []
    for k_ in range(4):
        t = R(45 + 90 * k_)
        holes.append(rbx.cyl("TsubaHole", 0.03, 0.2, 12 if high else 8, (0.15 * math.cos(t), 0.14 * math.sin(t), -0.17), "Z", c))
    na_ = 10 if high else 5
    for sx_ in (1, -1):
        cres = rbx.prism("TsubaCres", [(sx_ * (0.1 + 0.04 * math.cos(u)), 0.075 * math.sin(u)) for u in np.linspace(-1.3, 1.3, na_)] + [(sx_ * (0.1 + 0.015 * math.cos(u)), 0.06 * math.sin(u)) for u in np.linspace(1.3, -1.3, na_)], -0.25, -0.09, c)
        holes.append(cres)
    hc = rbx.join(holes, "TsubaCut")
    rbx.cut(ts, hc)
    if high:
        rbx.bevel(ts, 0.008, seg=2, harden=False, strength="FSTR_NONE")
    rbx.apply(ts)
    bpy.data.objects.remove(hc, do_unlink=True)
    rbx.tidy(ts)
    out_.append((ts, "Black"))
    fu = rbx.box(prefix + "Fuchi", (0.17, 0.125, 0.08), (0, 0, -0.25), c)
    rbx.bevel(fu, 0.02, seg=3 if high else 1, harden=False, strength="FSTR_NONE")
    rbx.apply(fu)
    out_.append((fu, "Brass"))
    tz = np.linspace(-0.29, -1.25, 16 if high else 8)
    tk_rings = [[(x, y, z) for x, y in rbx.rr(0.15 - 0.012 * math.sin(math.pi * (z + 0.29) / 0.96), 0.112 - 0.008 * math.sin(math.pi * (z + 0.29) / 0.96), 0.05, 48 if high else 16, 0.0)] for z in tz]
    tsk = rbx.loft(prefix + "Tsuka", tk_rings, c, cap0=True, cap1=True)
    out_.append((tsk, "Rope"))
    ka = rbx.box(prefix + "Kashira", (0.165, 0.125, 0.08), (0, 0, -1.29), c)
    rbx.bevel(ka, 0.035, seg=3 if high else 1, harden=False, strength="FSTR_NONE")
    rbx.apply(ka)
    out_.append((ka, "Black"))
    for sy_ in (1, -1):
        mn = rbx.box(prefix + "Menuki%d" % (sy_ + 1), (0.05, 0.03, 0.16), (0.0, sy_ * 0.065, -0.72), c)
        rbx.bevel(mn, 0.012, seg=2 if high else 1, harden=False, strength="FSTR_NONE")
        rbx.apply(mn)
        out_.append((mn, "Brass"))
    if high:
        N = 220
        for k_, sgn in enumerate((1, -1)):
            path, ups = [], []
            for i in range(N + 1):
                u = i / N
                z = -0.31 - 0.92 * u
                an = sgn * math.pi * 8 * u + (0 if sgn > 0 else math.pi)
                hw_ = 0.075 + 0.006
                hd_ = 0.056 + 0.006
                path.append((hw_ * math.cos(an), hd_ * math.sin(an), z))
                ups.append((math.cos(an) / hw_, math.sin(an) / hd_, 0))
            ito = rbx.sweep(prefix + "Ito%d" % k_, path, rbx.rect(0.06, 0.014, 0.004, 2), c, ups=ups)
            out_.append((ito, "Black"))
    return out_


F = Vector((-1.5, 0.0, 2.16))
th = R(28)
dvec = Vector((0, -math.cos(th), -math.sin(th)))
evec = Vector((0, math.sin(th), -math.cos(th)))
KM = rbx.orient(F + dvec * 0.72, dvec, evec)


def saya_parts(prefix, c, length, high=False, cap_end=True):
    out_ = []
    zs = np.linspace(0, -length, 24 if high else 8)
    rings = []
    for z in zs:
        u = -z / length
        dx = -0.12 * u ** 2
        rings.append([(x + dx, y, z) for x, y in rbx.rr(0.27 - 0.03 * u, 0.13 - 0.015 * u, 0.06, 48 if high else 14, 0.0)])
    sy = rbx.loft(prefix + "Saya", rings, c, cap0=True, cap1=True)
    out_.append((sy, "Lacquer"))
    kg = rbx.loft(prefix + "Koiguchi", [[(x, y, z) for x, y in rbx.rr(0.285, 0.145, 0.065, 48 if high else 18, 0.0)] for z in (0.01, -0.07)], c, cap0=True, cap1=True)
    out_.append((kg, "Black"))
    if cap_end:
        kj = rbx.loft(prefix + "Kojiri", [[(x - 0.12, y, z) for x, y in rbx.rr(0.25, 0.122, 0.055, 48 if high else 18, 0.0)] for z in (-length + 0.1, -length - 0.012)], c, cap0=True, cap1=True)
        out_.append((kj, "Brass"))
    kr = rbx.box(prefix + "Kurikata", (0.06, 0.07, 0.1), (0.1, 0.075, -0.34), c)
    rbx.bevel(kr, 0.02, seg=2 if high else 1, harden=False, strength="FSTR_NONE")
    rbx.apply(kr)
    out_.append((kr, "Black"))
    return out_


def placed_group(group, parts_lo, parts_hi, M):
    if parts_hi is not None:
        for oh, mth in parts_hi:
            rbx.place(oh, M)
            rbx.give(oh, MAT[mth])
    for o, mt in parts_lo:
        rbx.place(o, M)
        his = None
        if parts_hi is not None:
            key = o.name[len(group):].split(".")[0]
            his = [oh for oh, mth in parts_hi if oh.name[len(group) + 1:].split(".")[0] == key or (key == "Tsuka" and oh.name.startswith(group + "HIto"))]
        reg(group, o, mt, his)


placed_group("Katana", katana_parts("Katana", LO), None if BLOCK else katana_parts("KatanaH", HI, high=True), KM)
FLIP = Matrix.Rotation(math.pi, 4, "X")
SM = rbx.orient(Vector((1.2, -0.66, 2.02)), -Vector((0.1, 0.94, -0.33)).normalized(), (0, 0, 1))
placed_group("Saya", saya_parts("Saya", LO, 3.12), None if BLOCK else saya_parts("SayaH", HI, 3.12, high=True), SM)
kp = SM @ Vector((0.1, 0.075, -0.34))
sg = rbx.fillet([tuple(kp), tuple(kp + Vector((-0.06, -0.06, 0.22))), (0.95, -0.66, 2.47)], 0.08, 3)
sgl = rope("Sageo", rbx.resample(sg, 0.1), 0.02)
reg("Saya", sgl, "Rope", hi(lambda: [rope("SageoH", sg, 0.02, HI, high=True)]))
WM = rbx.orient(Vector((1.1, -0.6, 1.9)), -Vector((0.06, 0.95, -0.3)).normalized(), (0, 0, 1))
wl = saya_parts("Wakizashi", LO, 2.05)
wh = None if BLOCK else saya_parts("WakizashiH", HI, 2.05, high=True)


def short_hilt(prefix, c, high=False):
    ps = katana_parts(prefix, c, hilt_only=True, high=high)
    S = FLIP @ Matrix.Diagonal((0.86, 0.86, 0.66, 1.0))
    for o, mt in ps:
        rbx.place(o, S)
    return ps


placed_group("Wakizashi", wl + short_hilt("Wakizashi", LO), None if BLOCK else wh + short_hilt("WakizashiH", HI, True), WM)
placed_group("KatanaSheathed", katana_parts("KatanaSheathed", LO, hilt_only=True), None if BLOCK else katana_parts("KatanaSheathedH", HI, hilt_only=True, high=True), SM @ FLIP)
log("built %d low parts" % len(P))

groups = {}
for lo, hs, g in P:
    groups.setdefault(g, []).append(lo)
tris = {g: sum(sum(len(f.vertices) - 2 for f in o.data.polygons) for o in obs) for g, obs in groups.items()}
log("tris per group %s total %d" % (sorted(tris.items(), key=lambda x: -x[1]), sum(tris.values())))
heavy = sorted(((sum(len(f.vertices) - 2 for f in lo.data.polygons), lo.name) for lo, hs, g in P), reverse=True)[:14]
log("heaviest %s" % heavy)


def closeups():
    tsuba = KM @ Vector((0, 0, -0.17))
    return (("head", (1.0, -3.3, 5.2), (0, 0, 4.7), 30), ("headback", (-1.4, 3.0, 4.5), (0, 0, 4.6), 34),
            ("chest", (1.4, -4.0, 3.5), (0.35, 0, 2.9), 36), ("arm", (3.9, -2.4, 3.6), (1.5, 0, 3.0), 36),
            ("legs", (1.6, -3.4, 1.2), (0.25, 0, 0.9), 36), ("hilt", tuple(tsuba + Vector((-1.1, -1.3, -0.1))), tuple(tsuba + Vector((0, 0.12, 0.05))), 30))


if STAGE in ("block", "highs"):
    shots = []
    allo = [p[0] for p in P]
    show_lo = [o for o in allo if o["group"] != "KatanaSheathed"]
    for o in allo:
        o.color = (0.72, 0.72, 0.74, 1)
        o.hide_render = o["group"] == "KatanaSheathed"
    if STAGE == "highs":
        for o in allo:
            o.hide_render = True
        his_ = [h for lo, hs, g in P if g != "KatanaSheathed" for h in hs]
        for o in HI.objects:
            o.hide_render = o not in his_
        vis = his_
        log("high tris %d" % sum(sum(len(f.vertices) - 2 for f in o.data.polygons) for o in his_))
    else:
        vis = show_lo
    rbx.workbench(sc, "matcap", "basic_grey.exr", color="SINGLE")
    for nm, yaw, pitch in (("front", 0, 6), ("q34", 35, 12), ("side", 90, 4), ("back", 180, 8)):
        rbx.camera(sc, vis, yaw, pitch, lens=55)
        shots.append(rbx.shot(sc, os.path.join(out, "%s_%s.png" % (STAGE[0], nm)), cell, cell))
    rbx.camera(sc, vis, 0, 0, ortho=True)
    shots.append(rbx.shot(sc, os.path.join(out, "%s_ortho.png" % STAGE[0]), cell, cell))
    rbx.workbench(sc, "studio", color="MATERIAL")
    rbx.camera(sc, vis, 30, 12, lens=55)
    shots.append(rbx.shot(sc, os.path.join(out, "%s_color.png" % STAGE[0]), cell, cell))
    cmp_ = []
    for nm, yaw, pitch in (("c_back", 200, 6), ("c_side", 90, 4), ("c_front", 0, 4), ("c_q34", 25, 8)):
        rbx.camera(sc, vis, yaw, pitch, lens=55, pad=1.02)
        cmp_.append(rbx.shot(sc, os.path.join(out, "%s_%s.png" % (STAGE[0], nm)), cell, cell))
    rbx.sheet(cmp_, 4, os.path.join(out, "%s_compare.png" % ("block" if BLOCK else "high")))
    if STAGE == "highs":
        rbx.workbench(sc, "matcap", "basic_grey.exr", color="SINGLE")
    for nm, pos, at_c, fov in closeups():
        rbx.look_from(sc, pos, at_c, fov)
        shots.append(rbx.shot(sc, os.path.join(out, "%s_%s.png" % (STAGE[0], nm)), cell, cell))
    if BLOCK:
        dm = rbx.dummy((3.6, -0.5, 0), yaw=-20)
        fl = rbx.box("Floor", (300, 300, 0.2), (0, 0, -0.1))
        rbx.give(fl, rbx.mat("Floor", rbx.srgb((92, 104, 78)), 0.9))
        rbx.world(sc, "forest.exr", 1.0, 120, sun=3.0)
        rbx.cycles(sc, 24)
        sc.cycles.use_denoising = True
        rbx.look_from(sc, (5.5, -12.5, 7.5), (1.4, 0, 2.6), 70)
        shots.append(rbx.shot(sc, os.path.join(out, "b_player.png"), cell, cell))
    rbx.sheet(shots, 4, os.path.join(out, "%s_sheet.png" % ("block" if BLOCK else "high")))
    if BLOCK:
        bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out, "samurai_block.blend"))
    log("%s done" % STAGE)
    sys.exit(0)

for lo, hs, g in P:
    lo.data.shade_smooth()
    lo.data.set_sharp_from_angle(angle=R(50))
    rbx.chart_seams(lo, 55)
    rbx.unwrap(lo)
    me = lo.data
    at_ = me.attributes.get("tint") or me.attributes.new("tint", "FLOAT", "FACE")
    at_.data.foreach_set("value", np.full(len(me.polygons), rnd.random(), np.float32))
lows = [p[0] for p in P]
log("hidden islands shrunk: %d" % rbx.pack_parts(lows, 6, T, low=0.15))
for lo in lows:
    rbx.tri(lo)
    rbx.apply(lo)
GORDER = ["Head", "Hat", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Katana", "Saya", "Wakizashi", "KatanaSheathed"]
gl, gh = {}, {}
for lo, hs, g in P:
    gl.setdefault(g, []).append(lo)
    lst = gh.setdefault(g, [])
    for h in hs:
        if h not in lst:
            lst.append(h)
gobs = {g: rbx.join(gl[g], g) for g in GORDER}
rbx.lowvis(list(gobs.values()), False)
hi_tris = sum(sum(len(f.vertices) - 2 for f in o.data.polygons) for o in HI.objects)
log("joined into %d groups; high tris %d" % (len(gobs), hi_tris))


def gbake(kind, im, samples, margin, extrude=0.025, ray=0.07):
    for i, g in enumerate(GORDER):
        rbx.bake(gobs[g], kind, im, gh[g], samples=samples, extrude=extrude, ray=ray, clear=(i == 0), margin=margin)


nim = rbx.fimage("normal", T)
gbake("NORMAL", nim, 8, 3)
log("normal baked")
idm = {n: rbx.emit_mat("ID_" + n, lambda nt, c=rbx.ID_COLORS[k]: c) for k, n in enumerate(ORDER)}
keep = {}
for o in HI.objects:
    keep[o.name] = list(o.data.materials)
    for k, m_ in enumerate(o.data.materials):
        o.data.materials[k] = idm.get(m_.name if m_ else "Mail", idm["Mail"])
idim = rbx.fimage("id", T)
gbake("EMIT", idim, 1, 0)
for o in HI.objects:
    for k, m_ in enumerate(keep[o.name]):
        o.data.materials[k] = m_
log("id baked")
wb = bpy.data.worlds.new("Bake")
sc.world = wb
wb.light_settings.distance = 0.4
aoim = rbx.fimage("ao", T)
gbake("AO", aoim, 24, 3)
log("ao baked")
lo_b, hi_b = rbx.bounds(list(gobs.values()))
psim, nwim, tnim, gdim = rbx.fimage("pos", T), rbx.fimage("nrmw", T), rbx.fimage("tint", T), rbx.fimage("gid", T)
for i, g in enumerate(GORDER):
    ob = gobs[g]
    rbx.mask_bake(ob, rbx.pos_build(lo_b, hi_b), psim, samples=1, clear=(i == 0))
    rbx.mask_bake(ob, rbx.nrm_build(), nwim, samples=1, clear=(i == 0))
    rbx.mask_bake(ob, rbx.attr_build("tint"), tnim, samples=1, clear=(i == 0))
    gv = (i + 1) / 16.0
    rbx.mask_bake(ob, lambda nt, gv=gv: (gv, gv, gv), gdim, samples=1, margin=0, clear=(i == 0))
COV = rbx.coverage(list(gobs.values()), T)
log("masks baked")

I = rbx.ids_of(rbx.px(idim))
AO = rbx.px(aoim)[..., 0]
CV = rbx.curvature(nim, 1.4)
PP = rbx.px(psim)[..., :3] * np.array(hi_b - lo_b, np.float32) + np.array(lo_b, np.float32)
NW = rbx.px(nwim)[..., :3] * 2 - 1
TN = rbx.px(tnim)[..., 0]
GID = np.rint(rbx.px(gdim)[..., 0] * 16).astype(np.int32) - 1
GM = {g: GID == i for i, g in enumerate(GORDER)}


def C(*c):
    return np.array(c, np.float32) / 255.0


def cover(d, w=0.0035):
    return np.clip(0.5 - d / w, 0.0, 1.0)


def lay(m, c, k=1.0):
    global col
    m = (m * k)[..., None]
    col = col * (1 - m) + C(*c) * m


cls = {n: (I == k) for k, n in enumerate(ORDER)}
col = np.zeros(PP.shape, np.float32)
rough = np.full(I.shape, 0.7, np.float32)
metal = np.zeros(I.shape, np.float32)
for n in ORDER:
    col[cls[n]] = C(*PAL[n][0])
    rough[cls[n]] = PAL[n][1]
metal[cls["Brass"] | cls["Steel"]] = 1.0
n1 = rbx.fbm(PP, 1.5, 3, 1)
n2 = rbx.fbm(PP, 6.0, 3, 2)
n3 = rbx.fbm(PP, 24.0, 2, 3)
fac = (0.92 + 0.16 * TN) * (0.95 + 0.1 * n1)
col *= fac[..., None]
ax = np.argmax(np.abs(NW), -1)
U = np.where(ax == 0, PP[..., 1], PP[..., 0])
V = np.where(ax == 2, PP[..., 1], PP[..., 2])

lac = cls["Lacquer"]
wear = rbx.sstep(0.62, 0.8, CV) * rbx.sstep(0.4, 0.65, n2) * lac
lay(wear, (92, 42, 30), 0.5)
col = col + C(16, 8, 6) * (rbx.sstep(0.56, 0.7, CV) * lac)[..., None]
scr = rbx.sstep(0.72, 0.75, rbx.fbm(PP * np.array([60, 60, 5], np.float32), 1.0, 2, 31)) * lac
col = col + C(18, 10, 8) * scr[..., None]
rough = rough + 0.06 * scr
br = cls["Brass"]
pol = rbx.sstep(0.56, 0.78, CV) * br
col = col * (1 - 0.45 * pol[..., None]) + C(226, 196, 150) * (0.45 * pol[..., None])
rough = rough - 0.08 * pol
tar = rbx.sstep(0.25, 0.7, 1 - AO) * br
col = col * (1 - 0.5 * tar[..., None]) + C(86, 64, 42) * (0.5 * tar[..., None])

ml = cls["Mail"]
H = np.zeros(I.shape, np.float32)
ring = np.zeros(I.shape, np.float32)
if ml.any():
    idx = np.nonzero(ml)
    pu, pv = U[idx], V[idx]
    sp_, rr_, rw = 0.07, 0.024, 0.011
    best = np.zeros(len(pu), np.float32)
    j0 = np.floor(pv / (sp_ * 0.5))
    for dj in (-1, 0, 1, 2):
        j = j0 + dj
        off = np.mod(j, 2) * sp_ * 0.5
        i0 = np.floor((pu - off) / sp_)
        for di in (-1, 0, 1, 2):
            dist = np.hypot(pu - ((i0 + di) * sp_ + off), pv - j * sp_ * 0.5)
            best = np.maximum(best, np.exp(-((dist - rr_) / (rw * 0.75)) ** 2))
    ring[idx] = best
    H[idx] = best * rw
    tone = C(26, 24, 21)[None, :] * (1 - best[:, None]) + C(72, 70, 66)[None, :] * best[:, None]
    col[idx] = tone * fac[idx][:, None]
    rough[idx] = 0.95 - 0.15 * best

rp = cls["Rope"]
col[rp] *= (0.88 + 0.12 * n2)[rp][..., None]
bl_ = cls["Black"]
col = col + C(26, 22, 20) * (rbx.sstep(0.58, 0.75, CV) * bl_)[..., None]
rough = rough - 0.1 * rbx.sstep(0.58, 0.75, CV) * bl_
wd = cls["Wood"]
grain = rbx.fbm(PP * np.array([40, 40, 2.5], np.float32), 1.0, 3, 41)
col[wd] *= (0.78 + 0.44 * grain)[wd][..., None]
cl_ = cls["Cloth"]
col[cl_] *= (0.92 + 0.16 * n3)[cl_][..., None]
sw = cls["Straw"]
weave = 0.5 + 0.25 * np.sin(U * 140.0) * np.sin(V * 140.0) + 0.25 * np.sin((U + V) * 90.0)
col[sw] *= (0.8 + 0.35 * weave)[sw][..., None]
hr = cls["Hair"]
stk = 0.5 + 0.5 * np.sin(np.arctan2(PP[..., 1], PP[..., 0]) * 70.0 + 6.0 * n2)
col[hr] *= (0.84 + 0.16 * stk)[hr][..., None]

st = cls["Steel"] & GM["Katana"]
if st.any():
    Mi = KM.inverted()
    A3 = np.array(Mi.to_3x3(), np.float32)
    t3 = np.array(Mi.translation, np.float32)
    Q = PP @ A3.T + t3
    xl, zl = Q[..., 0], Q[..., 2]
    wz = 0.26 + (0.21 - 0.26) * np.clip(zl / 2.73, 0, 1)
    dxz = -0.14 * (np.clip(zl, 0, L) / L) ** 2
    e = dxz + wz / 2 - xl
    hw_ = 0.075 + 0.022 * np.sin(zl * 13) + 0.01 * np.sin(zl * 41 + 1.0)
    shx = dxz + wz / 2 - 0.38 * wz
    hamon = st & (e < hw_)
    shj = st & (xl < shx - 0.005)
    col[st] = C(196, 200, 206)
    col[shj] = C(150, 155, 164)
    rough[shj] = 0.2
    col[hamon] = C(234, 236, 240)
    rough[hamon] = 0.4
    edge_m = st & (e < 0.012)
    col[edge_m] = C(246, 247, 250)
    rough[edge_m] = 0.3

tg_ = (cls["Rope"] & GM["Hat"] & (np.abs(PP[..., 0] - TAG.x) < 0.07) & (np.abs(PP[..., 2] - TAG.z) < 0.11)).astype(np.float32)
du, dv = PP[..., 0] - TAG.x, PP[..., 2] - TAG.z
lay(cover(np.abs(np.hypot(du, dv - 0.035) - 0.026) - 0.006) * tg_, (20, 16, 14))
lay(cover(np.maximum(np.abs(du) - 0.006, np.abs(dv + 0.035) - 0.04)) * tg_, (20, 16, 14))

col = col * (0.9 + 0.12 * rbx.sstep(0.0, 5.6, PP[..., 2]))[..., None]
col = col * np.where(br | cls["Steel"], 0.86 + 0.14 * AO, 0.7 + 0.3 * AO)[..., None]
rough = np.clip(rough + 0.05 * (n2 - 0.5), 0.04, 1.0)

rgba = np.ones(PP.shape[:2] + (4,), np.float32)
rgba[..., :3] = rbx.dilate(np.clip(col, 0, 1), COV)
cim = rbx.unpx("samurai_color", rgba, os.path.join(out, "samurai_color.png"))
ra = np.ones_like(rgba)
ra[..., :3] = rbx.dilate(rough[..., None], COV)
rim_ = rbx.unpx("samurai_rough", ra, os.path.join(out, "samurai_rough.png"), data=True)
ma = np.ones_like(rgba)
ma[..., :3] = rbx.dilate((metal > 0.5).astype(np.float32)[..., None], COV)
mim = rbx.unpx("samurai_metal", ma, os.path.join(out, "samurai_metal.png"), data=True)
na = np.ones_like(rgba)
na[..., :3] = rbx.dilate(rbx.height_normal(rbx.px(nim), H, PP, COV), COV)
nrm8 = rbx.unpx("samurai_normal", na, os.path.join(out, "samurai_normal.png"), data=True)
fin = rbx.pbr_mat("Samurai", cim, rim_, mim, nrm8)
for g, ob in gobs.items():
    ob.data.materials.clear()
    ob.data.materials.append(fin)
log("textures composed")

rep = {g: rbx.audit(o, T) for g, o in gobs.items()}
rep["_total_tris"] = sum(r["tris"] for r in rep.values() if isinstance(r, dict))
rep["_high_tris"] = hi_tris
show = [o for g, o in gobs.items() if g != "KatanaSheathed"]
gobs["KatanaSheathed"].hide_render = True
for h in gh["KatanaSheathed"]:
    h.hide_render = True
shots = []
for o in gobs.values():
    o.hide_render = True
rbx.workbench(sc, "matcap", "basic_grey.exr")
vis_hi = [o for o in HI.objects if not o.hide_render]
rbx.camera(sc, vis_hi, 35, 12, lens=55)
shots.append(rbx.shot(sc, os.path.join(out, "r_high.png"), cell, cell))
for o in HI.objects:
    o.hide_render = True
for o in show:
    o.hide_render = False
    o.color = (0.75, 0.75, 0.75, 1)
wires = [rbx.wire(o, 0.0035) for o in show]
rbx.workbench(sc, "studio", color="OBJECT")
rbx.camera(sc, show, 35, 12, lens=55)
shots.append(rbx.shot(sc, os.path.join(out, "r_wire.png"), cell, cell))
for wv in wires:
    bpy.data.objects.remove(wv, do_unlink=True)
log("workbench renders")
rbx.studio(sc, show, refl=1.4)
rbx.cycles(sc, 40)
sc.cycles.use_denoising = True
for nm, yaw, pitch in (("front", 0, 6), ("q34", 35, 12), ("back", 205, 14), ("side", 95, 6)):
    rbx.camera(sc, show, yaw, pitch, lens=55)
    shots.append(rbx.shot(sc, os.path.join(out, "r_%s.png" % nm), cell, cell))
for nm, pos, at_c, fov in closeups():
    if nm == "headback":
        continue
    rbx.look_from(sc, pos, at_c, fov)
    shots.append(rbx.shot(sc, os.path.join(out, "r_%s.png" % nm), cell, cell))
rbx.no_studio()
flo = rbx.box("Floor", (300, 300, 0.2), (0, 0, -0.1))
rbx.give(flo, rbx.mat("Floor", rbx.srgb((92, 104, 78)), 0.9))
dm = rbx.dummy((3.6, -0.5, 0), yaw=-20)
rbx.world(sc, "forest.exr", 1.0, 120, sun=3.0)
rbx.look_from(sc, (5.5, -12.5, 7.5), (1.4, 0, 2.6), 70)
shots.append(rbx.shot(sc, os.path.join(out, "r_player.png"), cell, cell))
bpy.data.objects.remove(dm, do_unlink=True)
bpy.data.objects.remove(flo, do_unlink=True)
log("cycles renders")
rbx.sheet(shots, 4, os.path.join(out, "sheet.png"))
rbx.uv_sheet(gobs["Torso"], os.path.join(out, "r_uv_torso.png"), T, cim)

for o in gobs.values():
    o.hide_render = False
rbx.fbx(list(gobs.values()), os.path.join(out, "samurai.fbx"))
for g, o in gobs.items():
    rbx.mesh_json(o, os.path.join(out, "samurai_%s.json" % g.lower()))
for im in (cim, rim_, mim, nrm8):
    im.filepath = os.path.join(out, im.name + ".png")
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out, "samurai.blend"))
rbx.report(os.path.join(out, "report.json"), rep)
log("done")
