import bpy, bmesh, math, os, sys, time, random
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import rbx
import numpy as np
from mathutils import Vector, Matrix, Euler

R = rbx.R
a = rbx.args(out=r"C:\Users\vietb\Desktop\roblox\Blender\Modeling\Chest", tex="1024", cell="480", seed="11")
out = a["out"]
os.makedirs(out, exist_ok=True)
T = int(a["tex"])
cell = int(a["cell"])
t0 = time.time()
rnd = random.Random(int(a["seed"]))


def log(s):
    print("[%5.1fs] %s" % (time.time() - t0, s), flush=True)


def jr(d):
    return rnd.uniform(-d, d)


sc = rbx.fresh()
HI = rbx.col("High")
LO = rbx.col("Low")

W, D = 3.0, 1.9
Z0, ZB, ZT = 0.16, 0.28, 1.42
L0 = 1.44
AA, BB = D / 2 + 0.04, 0.6
TH = 0.07

wood = rbx.mat("Wood", rbx.srgb((126, 82, 48)), 0.7)
dark = rbx.mat("WoodDark", rbx.srgb((70, 44, 28)), 0.75)
iron = rbx.mat("Iron", rbx.srgb((58, 58, 60)), 0.5, 1.0)
brass = rbx.mat("Brass", rbx.srgb((210, 165, 85)), 0.32, 1.0)
gemm = rbx.mat("Gem", rbx.srgb((160, 12, 28)), 0.05)
rivm = rbx.mat("Rivet", rbx.srgb((150, 150, 152)), 0.3, 1.0)
order = ["Wood", "WoodDark", "Iron", "Brass", "Gem", "Rivet"]
mats = dict(zip(order, (wood, dark, iron, brass, gemm, rivm)))
parts = []


def tex(name, kind, **kw):
    t = bpy.data.textures.new(name, kind)
    for k, v in kw.items():
        setattr(t, k, v)
    return t


T_DENT = tex("Dent", "STUCCI", noise_scale=0.08, turbulence=4)
T_HAM = tex("Ham", "VORONOI", noise_scale=0.035, distance_metric="DISTANCE", weight_1=1.0, weight_2=0.0, weight_3=0.0, weight_4=0.0)
T_GRAIN = tex("Grain", "WOOD", wood_type="BANDNOISE", noise_basis_2="SAW", noise_scale=0.04, turbulence=6)


def reg(lo, his, m, grp=None):
    rbx.give(lo, m)
    for h in his:
        if not h.data.materials:
            rbx.give(h, m)
    parts.append((lo, his, grp))
    return lo


def hi_detail(ob, bev, seg=3, sub=1, dent=0.0, ham=0.0, grain=0.0, cutter=None):
    if bev:
        rbx.bevel(ob, bev, seg=seg, harden=False, strength="FSTR_NONE")
    if sub:
        rbx.mod(ob, "SUBSURF", subdivision_type="SIMPLE", levels=sub, render_levels=sub)
    if dent:
        rbx.mod(ob, "DISPLACE", texture=T_DENT, strength=dent, mid_level=0.5)
    if ham:
        rbx.mod(ob, "DISPLACE", texture=T_HAM, strength=ham, mid_level=0.5)
    if grain:
        rbx.mod(ob, "DISPLACE", texture=T_GRAIN, strength=grain, mid_level=0.5)
    if cutter:
        rbx.cut(ob, cutter)
    rbx.apply(ob)
    if cutter:
        bpy.data.objects.remove(cutter, do_unlink=True)
        rbx.tidy(ob)
    rbx.smooth(ob)
    return ob


def lo_box(name, size, at, bev=0.015):
    o = rbx.box(name, size, at, LO)
    if bev:
        rbx.bevel(o, bev, seg=1, harden=False, strength="FSTR_NONE")
        rbx.apply(o)
    return o


def wobble(objs, at, deg=1.2, off=0.006, normal=None):
    m = Matrix.Translation(Vector(at)) @ Euler((R(jr(deg)), R(jr(deg)), R(jr(deg)))).to_matrix().to_4x4() @ Matrix.Translation(-Vector(at))
    if normal is not None:
        m = Matrix.Translation(Vector(normal) * jr(off)) @ m
    for o in objs:
        rbx.place(o, m)


def chip_cutter(name, size, at, n):
    bm = bmesh.new()
    sx, sy, sz = size
    ax = max(range(3), key=lambda i: size[i])
    for k in range(n):
        u = rnd.uniform(-0.45, 0.45) * size[ax]
        corner = [rnd.choice((-0.5, 0.5)) * s for s in size]
        corner[ax] = u
        c = rnd.uniform(0.025, 0.055)
        m = Matrix.Translation(Vector(at) + Vector(corner)) @ Euler((R(rnd.uniform(0, 90)), R(rnd.uniform(0, 90)), R(rnd.uniform(0, 90)))).to_matrix().to_4x4() @ Matrix.Diagonal((c, c * rnd.uniform(0.6, 1.4), c, 1))
        bmesh.ops.create_cube(bm, size=1, matrix=m)
    return rbx.put(name, bm, HI)


def plank(name, size, at, normal, m=wood):
    at = Vector(at) + Vector((0, 0, jr(0.006)))
    size = (size[0] * (1 + jr(0.01)), size[1], size[2] * (1 + jr(0.02)))
    lo = lo_box(name, size, at)
    hi = rbx.box(name + "H", size, at, HI)
    hi_detail(hi, 0.022, 3, 2, dent=0.008, grain=0.005, cutter=chip_cutter(name + "Chips", size, at, rnd.randint(2, 4)))
    wobble([lo, hi], at, 0.9, 0.006, normal)
    return reg(lo, [hi], m)


reg(lo_box("Core", (W - 0.16, D - 0.16, ZT - ZB), (0, 0, (ZT + ZB) / 2), 0), [hi_detail(rbx.box("CoreH", (W - 0.16, D - 0.16, ZT - ZB), (0, 0, (ZT + ZB) / 2), HI), 0, 0, 0)], dark)
for sy in (-1, 1):
    for k in range(3):
        plank("PlankF%d%d" % (sy + 1, k), (W - 0.36, TH, 0.368), (0, sy * (D / 2 - TH / 2), ZB + 0.006 + 0.184 + k * 0.38), (0, sy, 0))
for sx in (-1, 1):
    for k in range(3):
        plank("PlankS%d%d" % (sx + 1, k), (TH, D - 0.36, 0.368), (sx * (W / 2 - TH / 2), 0, ZB + 0.006 + 0.184 + k * 0.38), (sx, 0, 0))
for sx in (-1, 1):
    for sy in (-1, 1):
        at = (sx * (W / 2 - 0.1), sy * (D / 2 - 0.1), (ZB + ZT) / 2)
        reg(lo_box("Post", (0.2, 0.2, ZT - ZB), at), [hi_detail(rbx.box("PostH", (0.2, 0.2, ZT - ZB), at, HI), 0.02, 3, 2, dent=0.007, grain=0.004)], dark)
reg(lo_box("Plinth", (W + 0.1, D + 0.1, 0.12), (0, 0, Z0 + 0.06), 0.02), [hi_detail(rbx.box("PlinthH", (W + 0.1, D + 0.1, 0.12), (0, 0, Z0 + 0.06), HI), 0.03, 3, 2, dent=0.007, cutter=chip_cutter("PlinthChips", (W + 0.1, D + 0.1, 0.12), (0, 0, Z0 + 0.06), 6))], dark)
log("body built")


def arch(a_, b_, t0_, t1_, n):
    return [(a_ * math.cos(t), L0 + b_ * math.sin(t)) for t in np.linspace(t0_, t1_, n)]


edges = [0.0] + [math.pi * i / 7 + jr(0.025) for i in range(1, 7)] + [math.pi]
for i in range(7):
    ta, tb = edges[i] + 0.005 + abs(jr(0.003)), edges[i + 1] - 0.005 - abs(jr(0.003))
    lo = rbx.extrude_x("LidPlank%d" % i, arch(AA, BB, ta, tb, 3) + arch(AA - TH, BB - TH, tb, ta, 3), -W / 2 + 0.1, W / 2 - 0.1, LO)
    rbx.bevel(lo, 0.012, seg=1, harden=False, strength="FSTR_NONE")
    rbx.apply(lo)
    hi = rbx.extrude_x("LidPlank%dH" % i, arch(AA, BB, ta, tb, 10) + arch(AA - TH, BB - TH, tb, ta, 10), -W / 2 + 0.1, W / 2 - 0.1, HI)
    tm = (ta + tb) / 2
    cen = (0, AA * math.cos(tm), L0 + BB * math.sin(tm))
    hi_detail(hi, 0.02, 3, 2, dent=0.008, grain=0.005, cutter=chip_cutter("LidChips%d" % i, (W - 0.2, 0.1, 0.07), cen, rnd.randint(1, 3)))
    wobble([lo, hi], cen, 0.6, 0.0)
    reg(lo, [hi], wood)
reg(rbx.extrude_x("LidCore", arch(AA - TH, BB - TH, 0, math.pi, 13), -W / 2 + 0.1, W / 2 - 0.1, LO),
    [hi_detail(rbx.extrude_x("LidCoreH", arch(AA - TH, BB - TH, 0, math.pi, 13), -W / 2 + 0.1, W / 2 - 0.1, HI), 0, 0, 0)], dark)
for k, sx in enumerate((1, -1)):
    lo = rbx.extrude_x("LidCap%d" % k, arch(AA, BB, 0, math.pi, 13), sx * (W / 2 - 0.05) - 0.05, sx * (W / 2 - 0.05) + 0.05, LO)
    rbx.bevel(lo, 0.015, seg=1, harden=False, strength="FSTR_NONE")
    rbx.apply(lo)
    hi = hi_detail(rbx.extrude_x("LidCap%dH" % k, arch(AA, BB, 0, math.pi, 25), sx * (W / 2 - 0.05) - 0.05, sx * (W / 2 - 0.05) + 0.05, HI), 0.025, 3, 2, dent=0.007, grain=0.004)
    reg(lo, [hi], dark)
for sy in (-1, 1):
    at = (0, sy * (AA + 0.015), L0 + 0.05)
    reg(lo_box("LidEdge", (W - 0.06, 0.035, 0.1), at, 0.01), [hi_detail(rbx.box("LidEdgeH", (W - 0.06, 0.035, 0.1), at, HI), 0.012, 2, 2, ham=0.004)], iron)
log("lid built")


def band_loop(name, z, off, hgt):
    hx, hy = W / 2 + off, D / 2 + off
    pts = [(-hx, -hy, z), (hx, -hy, z), (hx, hy, z), (-hx, hy, z), (-hx, -hy, z)]
    lo_p = rbx.fillet(pts, 0.07, 3)[:-1]
    hi_p = rbx.resample(rbx.fillet(pts, 0.07, 8), 0.06)[:-1]
    ph = rnd.uniform(0, 6)
    hi_p = [(x, y, z_ + 0.005 * math.sin(ph + (x + y) * 3.1)) for x, y, z_ in hi_p]
    lo = rbx.sweep(name, lo_p, rbx.rect(0.035, hgt), LO, loop=True, caps=False)
    hi = rbx.sweep(name + "H", hi_p, rbx.rect(0.035, hgt, 0.008, 2), HI, loop=True, caps=False)
    hi_detail(hi, 0, 0, 1, ham=0.005)
    return reg(lo, [hi], iron)


band_loop("RimBand", ZT - 0.06, 0.0175, 0.1)
band_loop("BaseBand", ZB + 0.08, 0.0175, 0.1)

LG = 0.24
foot = [(-0.025, -0.025), (LG, -0.025), (LG, 0.0), (0.0, 0.0), (0.0, LG), (-0.025, LG)]
g_lo = rbx.prism("Guard", foot, ZB + 0.02, ZT - 0.02, LO)
g_hi = hi_detail(rbx.prism("GuardH", foot, ZB + 0.02, ZT - 0.02, HI), 0.008, 2, 2, ham=0.004)
for k, (sx, sy) in enumerate(((-1, -1), (1, -1), (1, 1), (-1, 1))):
    m = Matrix.Translation((sx * W / 2, sy * D / 2, 0)) @ Matrix.Rotation(R(90 * k), 4, "Z")
    reg(rbx.place(rbx.dup(g_lo, "Guard%d" % k, LO), m), [rbx.place(rbx.dup(g_hi, "Guard%dH" % k, HI), m)], iron, "guard")
bpy.data.objects.remove(g_lo, do_unlink=True)
bpy.data.objects.remove(g_hi, do_unlink=True)
log("bands and guards built")

SO = 0.0525
for k, x0 in enumerate((-0.85, 0.85)):
    raw = [(0, -(D / 2 + SO), ZB + 0.03), (0, -(D / 2 + SO), L0)] + [(0, y, z) for y, z in arch(AA + 0.0175, BB + 0.0175, math.pi, 0, 41)] + [(0, D / 2 + SO, L0), (0, D / 2 + SO, ZB + 0.03)]
    ph = rnd.uniform(0, 6)
    sp_hi = [(x0 + 0.01 * math.sin(ph + i * 0.23), y, z) for i, (x, y, z) in enumerate(rbx.resample(raw, 0.04))]
    sp_lo = [(x0, y, z) for x, y, z in [raw[0], raw[1]] + raw[2:-2:3] + [raw[-2], raw[-1]]]
    lo = rbx.sweep("Strap%d" % k, sp_lo, rbx.rect(0.035, 0.17), LO)
    hi = rbx.sweep("Strap%dH" % k, sp_hi, rbx.rect(0.035, 0.17, 0.008, 2), HI)
    hi_detail(hi, 0, 0, 1, ham=0.005)
    fr = rbx.frames(sp_hi)
    riv = []
    acc, nxt = 0.0, 0.2
    for i in range(1, len(fr)):
        acc += (fr[i][0] - fr[i - 1][0]).length
        if acc >= nxt:
            acc, nxt = 0.0, 0.2 + jr(0.025)
            p, t, n, b = fr[i]
            d = rbx.dome("Rivet", 0.03 * rnd.uniform(0.88, 1.1), 10, 3)
            rbx.place(d, rbx.orient(p - b * 0.0175 + n * jr(0.006), -b))
            riv.append(d)
    rv = rbx.join(riv, "Rivets%dH" % k)
    rv.users_collection[0].objects.unlink(rv)
    HI.objects.link(rv)
    rbx.give(rv, rivm)
    rbx.smooth(rv)
    reg(lo, [hi, rv], iron)
log("straps built")

lf_lo = rbx.trefoil(0.5, 0.06, 0.13, 30)
lf_hi = rbx.trefoil(0.5, 0.06, 0.13, 90)
b_lo = rbx.prism("Bracket", lf_lo, 0, 0.03, LO)
b_hi = rbx.prism("BracketH", lf_hi, 0, 0.03, HI)
hi_detail(b_hi, 0.008, 2, 2, ham=0.003)
bead = rbx.sweep("BeadH", [(x, y, 0.03) for x, y in rbx.offset2d(lf_hi, -0.02, closed=True)], rbx.circle(0.006, 6), HI, loop=True, caps=False)
rbx.smooth(bead)
bdots = []
for x, y in ((0.06, 0.0), (0.5 - 0.13 * 0.9, 0.0)):
    d = rbx.dome("BDot", 0.022, 10, 3)
    rbx.place(d, Matrix.Translation((x, y, 0.03)))
    bdots.append(d)
bd = rbx.join(bdots, "BracketDotsH")
bd.users_collection[0].objects.unlink(bd)
HI.objects.link(bd)
rbx.give(bd, rivm)
rbx.smooth(bd)
k = 0
for sx in (-1, 1):
    for sy in (-1, 1):
        for zc in (0.62, 1.18):
            for face in ("y", "x"):
                if face == "y":
                    at = (sx * W / 2, sy * (D / 2 + 0.027), zc)
                    m = rbx.orient(at, (0, sy, 0), (-sx, 0, 0))
                else:
                    at = (sx * (W / 2 + 0.027), sy * D / 2, zc)
                    m = rbx.orient(at, (sx, 0, 0), (0, -sy, 0))
                m = m @ Matrix.Rotation(R(jr(2.5)), 4, "Z")
                lo = rbx.place(rbx.dup(b_lo, "Bracket%d" % k, LO), m)
                his = [rbx.place(rbx.dup(o, o.name.replace("H", "") + "%dH" % k, HI), m) for o in (b_hi, bead, bd)]
                reg(lo, his, brass, "bracket")
                k += 1
for o in (b_lo, b_hi, bead, bd):
    bpy.data.objects.remove(o, do_unlink=True)
log("brackets built: %d" % k)

ring_lo = rbx.torus("Ring", 0.17, 0.028, 16, 6, (0, 0, 0), "YZ", LO)
ring_hi = hi_detail(rbx.torus("RingH", 0.17, 0.028, 40, 12, (0, 0, 0), "YZ", HI), 0, 0, 0, ham=0.003)
disc_lo = rbx.lathe("Mount", [(0, 0.03), (0.12, 0.03), (0.12, 0.0), (0, 0)], 12, LO, axis="X")
disc_hi = rbx.lathe("MountH", [(0, 0.03)] + [(0.108 + 0.012 * math.cos(R(a_)), 0.018 + 0.012 * math.sin(R(a_))) for a_ in range(90, -1, -15)] + [(0.12, 0.0), (0, 0)], 32, HI, axis="X")
stp = [(0.0, -0.05, 0.0)] + [(0.05 * math.sin(R(a_)), -0.05 * math.cos(R(a_)), 0.0) for a_ in range(30, 151, 30)] + [(0.0, 0.05, 0.0)]
stp_lo = rbx.sweep("Staple", stp, rbx.circle(0.018, 6), LO)
stp_hi = rbx.sweep("StapleH", rbx.resample(stp, 0.01), rbx.circle(0.018, 12), HI)
for k, sx in enumerate((-1, 1)):
    m = Matrix.Translation((sx * (W / 2 + 0.035), 0, 0.95)) @ Matrix.Rotation(0 if sx > 0 else math.pi, 4, "Z")
    md = m @ Matrix.Translation((-0.015, 0, 0.1))
    reg(rbx.place(rbx.dup(disc_lo, "Mount%d" % k, LO), md), [rbx.place(rbx.dup(disc_hi, "Mount%dH" % k, HI), md)], brass, "mount")
    mr = m @ Matrix.Translation((0.05, 0, 0.1)) @ Matrix.Rotation(R(jr(9)), 4, "Y") @ Matrix.Rotation(R(jr(4)), 4, "X") @ Matrix.Translation((0, 0, -0.17))
    reg(rbx.place(rbx.dup(ring_lo, "Ring%d" % k, LO), mr), [rbx.place(rbx.dup(ring_hi, "Ring%dH" % k, HI), mr)], iron, "ring")
    ms = m @ Matrix.Translation((0.03, 0, 0.1)) @ Matrix.Rotation(R(90), 4, "Y")
    reg(rbx.place(rbx.dup(stp_lo, "Staple%d" % k, LO), ms), [rbx.place(rbx.dup(stp_hi, "Staple%dH" % k, HI), ms)], iron, "staple")
for o in (ring_lo, ring_hi, disc_lo, disc_hi, stp_lo, stp_hi):
    bpy.data.objects.remove(o, do_unlink=True)
log("handles built")


def fil2(pts, r, n):
    return [(p[0], p[1]) for p in rbx.fillet([(x, y, 0) for x, y in pts] + [(pts[0][0], pts[0][1], 0)], r, n)[:-1]]


shield = [(-0.2, 0.25), (0.2, 0.25), (0.23, 0.02), (0.13, -0.19), (0.0, -0.28), (-0.13, -0.19), (-0.23, 0.02)]
m = rbx.orient((0, -(D / 2 + 0.025), 1.0), (0, -1, 0), (1, 0, 0))
esc_lo = rbx.place(rbx.prism("Escutcheon", fil2(shield, 0.04, 1), 0, 0.03, LO), m)
esc_hi = rbx.place(hi_detail(rbx.prism("EscutcheonH", fil2(shield, 0.04, 3), 0, 0.03, HI), 0.01, 2, 2, ham=0.003), m)
esc_b = rbx.place(rbx.sweep("EscBeadH", [(x, y, 0.03) for x, y in rbx.offset2d(fil2(shield, 0.04, 3), -0.03, closed=True)], rbx.circle(0.007, 6), HI, loop=True, caps=False), m)
reg(esc_lo, [esc_hi, esc_b], brass)
reg(lo_box("Hasp", (0.12, 0.03, 0.34), (0, -(D / 2 + 0.08), 1.36), 0.008), [hi_detail(rbx.box("HaspH", (0.12, 0.03, 0.34), (0, -(D / 2 + 0.08), 1.36), HI), 0.01, 2, 2, ham=0.003)], iron)
pb = Vector((0, -(D / 2 + 0.085), 1.0))
ml = Matrix.Translation(pb + Vector((0, 0, 0.1))) @ Matrix.Rotation(R(6), 4, "Y") @ Matrix.Rotation(R(-4), 4, "X") @ Matrix.Translation((0, 0, -0.1))
lk = [(-0.13, 0.1), (0.13, 0.1), (0.145, -0.02), (0.085, -0.1), (0.0, -0.135), (-0.085, -0.1), (-0.145, -0.02)]
mo = rbx.orient((0, 0, 0), (0, -1, 0), (1, 0, 0))
lock_lo = rbx.place(rbx.place(rbx.prism("Padlock", fil2(lk, 0.03, 1), 0, 0.09, LO), mo), ml)
rbx.bevel(lock_lo, 0.012, seg=1, harden=False, strength="FSTR_NONE")
rbx.apply(lock_lo)
lock_hi = rbx.place(rbx.prism("PadlockH", fil2(lk, 0.03, 4), 0, 0.09, HI), mo)
rbx.place(lock_hi, ml)
kc = rbx.cyl("KeyCut", 0.018, 0.3, 16, (0, 0, 0.02), "Y", HI)
ks = rbx.box("KeySlot", (0.014, 0.3, 0.05), (0, 0, -0.015), HI)
kj = rbx.place(rbx.join([kc, ks], "KeyCutter"), ml @ Matrix.Translation((0, -0.09, 0)))
hi_detail(lock_hi, 0.018, 3, 0, ham=0.003, cutter=kj)
reg(lock_lo, [lock_hi], iron)
kp = [(0.0, 0.07), (0.045, 0.045), (0.05, 0.0), (0.03, -0.06), (0.0, -0.075), (-0.03, -0.06), (-0.05, 0.0), (-0.045, 0.045)]
mk = ml @ rbx.orient((0, -0.09, 0.0), (0, -1, 0), (1, 0, 0))
kp_lo = rbx.place(rbx.prism("KeyPlate", kp, 0, 0.012, LO), mk)
kp_hi = rbx.place(rbx.prism("KeyPlateH", fil2(kp, 0.01, 3), 0, 0.012, HI), mk)
kc2 = rbx.place(rbx.cyl("KeyCut2", 0.018, 0.1, 16, (0, 0, 0.02), "Z", HI), mk)
hi_detail(kp_hi, 0.004, 2, 0, cutter=kc2)
reg(kp_lo, [kp_hi], brass)
shk = [(-0.075, 0, 0.08), (-0.075, 0, 0.22), (0.075, 0, 0.22), (0.075, 0, 0.08)]
msh = ml @ Matrix.Translation((0, -0.045, 0))
reg(rbx.place(rbx.sweep("Shackle", rbx.fillet(shk, 0.07, 4), rbx.circle(0.02, 8), LO), msh),
    [rbx.place(rbx.sweep("ShackleH", rbx.resample(rbx.fillet(shk, 0.07, 10), 0.015), rbx.circle(0.02, 16), HI), msh)], iron)
log("lock built")

th = R(122)
cy, cz = AA * math.cos(th), L0 + BB * math.sin(th)
nrm = Vector((0, math.cos(th) / AA, math.sin(th) / BB)).normalized()
mm = rbx.orient((0, cy, cz), nrm, (1, 0, 0)) @ Matrix.Rotation(R(jr(3)), 4, "Z")
med_lo = rbx.place(rbx.lathe("Medallion", [(0, 0.04), (0.2, 0.04), (0.23, 0.0), (0, 0.0)], 16, LO), mm)
med_hi = rbx.place(rbx.lathe("MedallionH", [(0, 0.04), (0.17, 0.04), (0.18, 0.036), (0.225, 0.016), (0.23, 0.0), (0, 0.0)], 48, HI), mm)
star_h = rbx.place(hi_detail(rbx.prism("StarH", rbx.star(8, 0.165, 0.09, math.pi / 2), 0.04, 0.05, HI), 0.003, 2, 0), mm)
beads = []
for i in range(26):
    an = 2 * math.pi * i / 26
    d = rbx.dome("MBead", 0.011, 8, 2)
    rbx.place(d, Matrix.Translation((0.2 * math.cos(an), 0.2 * math.sin(an), 0.026)))
    beads.append(d)
mb_ = rbx.place(rbx.join(beads, "MedBeadsH"), mm)
mb_.users_collection[0].objects.unlink(mb_)
HI.objects.link(mb_)
rbx.give(mb_, brass)
reg(med_lo, [med_hi, star_h, mb_], brass)
bez_lo = rbx.place(rbx.lathe("Bezel", [(0, 0.09), (0.1, 0.09), (0.115, 0.04), (0, 0.04)], 12, LO), mm)
reg(bez_lo, [rbx.place(rbx.lathe("BezelH", [(0, 0.09), (0.098, 0.09), (0.106, 0.085), (0.115, 0.05), (0.115, 0.04), (0, 0.04)], 40, HI), mm)], brass)
gem = rbx.place(rbx.lathe("Gem", [(0, 0.16), (0.05, 0.16), (0.085, 0.12), (0.088, 0.095), (0, 0.06)], 8, LO), mm)
gem.data.shade_flat()
reg(gem, [rbx.dup(gem, "GemH", HI)], gemm)
f_lo = rbx.lathe("Foot", [(0, Z0), (0.07, Z0), (0.1, 0.11), (0.11, 0.07), (0.09, 0.02), (0, 0)], 10, LO)
f_hi = rbx.lathe("FootH", [(0, Z0), (0.07, Z0)] + [(0.11 * math.cos(R(a_)) * (1 if a_ > -60 else 0.9), 0.07 + 0.06 * math.sin(R(a_))) for a_ in range(50, -91, -10)] + [(0, 0.01)], 32, HI)
for k, (sx, sy) in enumerate(((-1, -1), (1, -1), (1, 1), (-1, 1))):
    mf = Matrix.Translation((sx * (W / 2 - 0.13), sy * (D / 2 - 0.13), 0))
    reg(rbx.place(rbx.dup(f_lo, "Foot%d" % k, LO), mf), [rbx.place(rbx.dup(f_hi, "Foot%dH" % k, HI), mf)], brass, "foot")
bpy.data.objects.remove(f_lo, do_unlink=True)
bpy.data.objects.remove(f_hi, do_unlink=True)
log("medallion, gem and feet built")

masters = {}
for lo, his, g in parts:
    lo.data.shade_smooth()
    if lo.name != "Gem":
        lo.data.set_sharp_from_angle(angle=R(45))
    rbx.tag_faces(lo, "copy", 0)
    me = lo.data
    at = me.attributes.get("tint") or me.attributes.new("tint", "FLOAT", "FACE")
    at.data.foreach_set("value", np.full(len(me.polygons), rnd.random(), np.float32))
    if g and g in masters and rbx.same_topology(masters[g], lo):
        lo["copy_of"] = masters[g].name
        rbx.tag_faces(lo, "copy", 1)
        if not lo.data.uv_layers:
            lo.data.uv_layers.new(name="UVMap")
    else:
        rbx.chart_seams(lo, 50)
        rbx.unwrap(lo)
    if g and g not in masters:
        masters[g] = lo
lows = [p[0] for p in parts]
log("hidden islands shrunk: %d" % rbx.pack_parts(lows, 5, T, low=0.12, ground=True))
for lo in lows:
    rbx.tri(lo)
    rbx.apply(lo)
rbx.lowvis(lows, False)
hi_tris = sum(sum(len(f.vertices) - 2 for f in o.data.polygons) for o in HI.objects)
lo_tris = sum(len(o.data.polygons) for o in lows)
log("high tris %d, low tris %d, parts %d" % (hi_tris, lo_tris, len(lows)))

for lo in lows:
    if lo.get("copy_of"):
        rbx.shift_uv(lo, 1.0)
bakeable = [(lo, his) for lo, his, g in parts if not lo.get("copy_of")]
nim = rbx.fimage("normal", T)
for i, (lo, his) in enumerate(bakeable):
    rbx.bake(lo, "NORMAL", nim, his, samples=12, extrude=0.03, clear=(i == 0), margin=2)
log("normal baked")
idm = {n: rbx.emit_mat("ID_" + n, lambda nt, c=rbx.ID_COLORS[k]: c) for k, n in enumerate(order)}
for o in HI.objects:
    for k_, m_ in enumerate(o.data.materials):
        o.data.materials[k_] = idm[m_.name]
idim = rbx.fimage("id", T)
for i, (lo, his) in enumerate(bakeable):
    rbx.bake(lo, "EMIT", idim, his, samples=1, extrude=0.03, clear=(i == 0), margin=0)
for o in HI.objects:
    for k_, m_ in enumerate(o.data.materials):
        o.data.materials[k_] = mats[m_.name[3:]]
log("id baked")
w = bpy.data.worlds.new("Bake")
sc.world = w
w.light_settings.distance = 0.35
aoim = rbx.fimage("ao", T)
for i, (lo, his) in enumerate(bakeable):
    rbx.bake(lo, "AO", aoim, his, samples=32, extrude=0.03, clear=(i == 0), margin=2)
log("ao baked")
for lo in lows:
    if lo.get("copy_of"):
        rbx.shift_uv(lo, -1.0)

chest = rbx.join(lows, "Chest")
lo, hi = rbx.bounds([chest])
psim = rbx.fimage("pos", T)
rbx.mask_bake(chest, rbx.pos_build(lo, hi), psim, samples=1)
nwim = rbx.fimage("nrmw", T)
rbx.mask_bake(chest, rbx.nrm_build(), nwim, samples=1)
tnim = rbx.fimage("tint", T)
rbx.mask_bake(chest, rbx.attr_build("tint"), tnim, samples=1)
COV = rbx.coverage(chest, T)
log("position, normal, tint and coverage baked")

I = rbx.ids_of(rbx.px(idim))
AO = rbx.px(aoim)[..., 0]
CV = rbx.curvature(nim, 1.6)
P = rbx.px(psim)[..., :3] * np.array(hi - lo, np.float32) + np.array(lo, np.float32)
NW = rbx.px(nwim)[..., :3] * 2 - 1
TN = rbx.px(tnim)[..., 0]


def C(*c):
    return np.array(c, np.float32) / 255.0


mw, md, mi, mb, mg, mr = [(I == k) for k in range(6)]
n1 = rbx.fbm(P, 1.2, 4, 1)
n2 = rbx.fbm(P, 6.0, 4, 2)
n3 = rbx.fbm(P, 24.0, 3, 3)
side = np.abs(NW[..., 0]) > 0.6
gx = rbx.fbm(P * np.array([1.2, 34, 34], np.float32), 1.0, 3, 7)
gy = rbx.fbm(P * np.array([34, 1.2, 34], np.float32), 1.0, 3, 7)
grain = np.where(side, gy, gx)
col = np.zeros(P.shape, np.float32)
rough = np.full(I.shape, 0.6, np.float32)
metal = np.zeros(I.shape, np.float32)
wd = mw | md
base_w = np.where(mw[..., None], C(128, 84, 50), C(72, 46, 30))
hue = np.stack([1 + 0.1 * (TN - 0.5), 1 + 0.02 * (TN - 0.5), 1 - 0.08 * (TN - 0.5)], -1)
col[wd] = (base_w * hue * (0.84 + 0.26 * TN)[..., None] * (0.9 + 0.2 * n1)[..., None])[wd]
gl = rbx.sstep(0.45, 0.75, grain)
col = col * (1 - 0.3 * (gl * wd)[..., None])
streak = rbx.sstep(0.6, 0.8, rbx.fbm(P * np.array([14, 14, 0.8], np.float32), 1.0, 3, 21)) * wd * (1 - rbx.sstep(0.6, 0.9, NW[..., 2]))
col = col * (1 - 0.25 * streak[..., None])
rough[wd] = (0.68 + 0.1 * n2)[wd]
we = rbx.sstep(0.55, 0.8, CV * (0.7 + 0.6 * n2)) * wd
col = col * (1 - 0.45 * we[..., None]) + C(170, 120, 78) * (0.45 * we[..., None])
col[mi] = (C(60, 60, 62) * (0.86 + 0.28 * n2)[..., None] * (0.92 + 0.16 * TN)[..., None])[mi]
rough[mi] = (0.5 + 0.14 * n2)[mi]
metal[mi | mr] = 1
ie = rbx.sstep(0.56, 0.8, CV * (0.7 + 0.6 * n2)) * mi
col = col * (1 - 0.55 * ie[..., None]) + C(150, 150, 152) * (0.55 * ie[..., None])
rough = rough - 0.2 * ie
scr = rbx.sstep(0.7, 0.74, rbx.fbm(P * np.array([60, 4, 60], np.float32), 1.0, 2, 31)) * (mi | mb)
col = col * (1 - 0.35 * scr[..., None]) + C(170, 168, 160) * (0.35 * scr[..., None])
col[mr] = (C(150, 150, 152) * (0.9 + 0.2 * n3)[..., None])[mr]
rough[mr] = 0.28
rust = rbx.sstep(0.18, 0.6, (1 - AO) * (0.4 + 1.1 * n2) * (0.7 + 0.6 * TN)) * (mi | mr)
col = col * (1 - 0.8 * rust[..., None]) + C(112, 58, 30) * (0.8 * rust[..., None])
rough = rough + 0.3 * rust
metal = np.where(rust > 0.5, 0.0, metal)
col[mb] = (C(212, 166, 86) * (0.9 + 0.14 * n1)[..., None])[mb]
rough[mb] = (0.3 + 0.08 * n2)[mb]
metal[mb] = 1
tar = rbx.sstep(0.2, 0.6, (1 - AO) * (0.5 + 0.9 * n2)) * mb
col = col * (1 - 0.7 * tar[..., None]) + C(82, 80, 52) * (0.7 * tar[..., None])
rough = rough + 0.35 * tar
metal = np.where(tar > 0.55, 0.0, metal)
pol = rbx.sstep(0.55, 0.78, CV) * mb
col = col * (1 - 0.5 * pol[..., None]) + C(246, 214, 140) * (0.5 * pol[..., None])
rough = rough - 0.12 * pol
col[mg] = C(168, 14, 30)
rough[mg] = 0.05
cav = rbx.sstep(0.2, 0.75, 1 - AO)
col = col * (1 - 0.5 * (cav * wd)[..., None])
col = col * np.where(wd, 0.72 + 0.28 * AO, 0.85 + 0.15 * AO)[..., None]
grime = rbx.sstep(0.5, 0.0, P[..., 2]) * (0.5 + 0.5 * n2)
col = col * (1 - 0.3 * grime[..., None])
dust = rbx.sstep(0.6, 0.95, NW[..., 2]) * rbx.sstep(0.5, 0.75, n1) * 0.25
col = col * (1 - dust[..., None]) + C(160, 148, 126) * dust[..., None]

rgba = np.ones(P.shape[:2] + (4,), np.float32)
rgba[..., :3] = rbx.dilate(np.clip(col, 0, 1), COV)
cim = rbx.unpx("chest_color", rgba, os.path.join(out, "chest_color.png"))
ra = np.ones_like(rgba)
ra[..., :3] = rbx.dilate(np.clip(rough, 0.04, 1)[..., None], COV)
rim = rbx.unpx("chest_rough", ra, os.path.join(out, "chest_rough.png"), data=True)
ma = np.ones_like(rgba)
ma[..., :3] = rbx.dilate((metal > 0.5).astype(np.float32)[..., None], COV)
mim = rbx.unpx("chest_metal", ma, os.path.join(out, "chest_metal.png"), data=True)
na = np.ones_like(rgba)
na[..., :3] = rbx.dilate(rbx.px(nim)[..., :3], COV)
nrm8 = rbx.unpx("chest_normal", na, os.path.join(out, "chest_normal.png"), data=True)
fin = rbx.pbr_mat("Chest", cim, rim, mim, nrm8)
chest.data.materials.clear()
chest.data.materials.append(fin)
log("textures composed")
rep = rbx.audit(chest, T)
rep["high_tris"] = hi_tris

shots = []
HI.hide_render = False
chest.hide_render = True
rbx.workbench(sc, "matcap", "basic_grey.exr")
rbx.camera(sc, list(HI.objects), 35, 22)
shots.append(rbx.shot(sc, os.path.join(out, "r_high.png"), cell, cell))
HI.hide_render = True
chest.hide_render = False
wi = rbx.wire(chest, 0.0035)
chest.color = (0.75, 0.75, 0.75, 1)
rbx.workbench(sc, "studio", color="OBJECT")
rbx.camera(sc, [chest], 35, 22)
shots.append(rbx.shot(sc, os.path.join(out, "r_low_wire.png"), cell, cell))
bpy.data.objects.remove(wi, do_unlink=True)
log("workbench renders")
rbx.studio(sc, [chest])
rbx.cycles(sc, 40)
sc.cycles.use_denoising = True
rbx.camera(sc, [chest], 35, 22)
shots.append(rbx.shot(sc, os.path.join(out, "r_front.png"), cell, cell))
rbx.camera(sc, [chest], 140, 30)
shots.append(rbx.shot(sc, os.path.join(out, "r_back.png"), cell, cell))
cam = rbx.camera(sc, [chest], 15, 12)
foc = Vector((0, -D / 2, 1.2))
cam.data.lens = 60
cam.location = foc + Vector((0.6, -3.2, 0.9))
cam.rotation_euler = (foc - cam.location).to_track_quat("-Z", "Y").to_euler()
shots.append(rbx.shot(sc, os.path.join(out, "r_lock.png"), cell, cell))
rbx.no_studio()
flo = rbx.box("Floor", (300, 300, 0.2), (0, 0, -0.1))
rbx.give(flo, rbx.mat("Floor", rbx.srgb((92, 94, 98)), 0.85))
dm = rbx.dummy((3.0, -1.6, 0), yaw=30)
rbx.world(sc, "forest.exr", 1.0, 120, sun=3.0)
rbx.look_from(sc, (6.5, -12.5, 7.0), (1.2, -0.5, 1.4), 70)
shots.append(rbx.shot(sc, os.path.join(out, "r_player.png"), cell, cell))
bpy.data.objects.remove(dm, do_unlink=True)
bpy.data.objects.remove(flo, do_unlink=True)
log("cycles renders")
rbx.sheet(shots, 3, os.path.join(out, "sheet.png"))
rbx.uv_sheet(chest, os.path.join(out, "r_uv.png"), T, cim)

rbx.fbx([chest], os.path.join(out, "chest.fbx"))
rbx.mesh_json(chest, os.path.join(out, "chest.json"))
for im in (cim, rim, mim, nrm8):
    im.filepath = os.path.join(out, im.name + ".png")
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out, "chest.blend"))
rbx.report(os.path.join(out, "report.json"), rep)
log("done")
