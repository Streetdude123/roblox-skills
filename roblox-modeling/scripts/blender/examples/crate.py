import bpy, bmesh, math, os, sys, time
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import rbx
import numpy as np
from mathutils import Vector, Matrix

R = rbx.R
a = rbx.args(out=r"C:\Users\vietb\Desktop\roblox\Blender\Modeling\Crate", tex="1024", cell="480")
out = a["out"]
os.makedirs(out, exist_ok=True)
T = int(a["tex"])
t0 = time.time()


def log(s):
    print("[%5.1fs] %s" % (time.time() - t0, s), flush=True)


sc = rbx.fresh()
pc = rbx.col("Parts")

W, D, CH = 4.0, 3.0, 0.42
HW, HD = W / 2, D / 2
Z0, Z1 = 0.26, 2.16
L0, L1 = 2.19, 2.62

paint = rbx.mat("Paint", rbx.srgb((196, 96, 38)), 0.55)
guard = rbx.mat("Guard", rbx.srgb((62, 64, 68)), 0.55)
steel = rbx.mat("Steel", rbx.srgb((180, 180, 178)), 0.35, 1.0)
plate = rbx.mat("Plate", rbx.srgb((222, 219, 208)), 0.5)

parts = []


def add(ob, m, w=0.035, seg=2, ang=30, harden=True, grp=None):
    rbx.give(ob, m)
    if w:
        rbx.bevel(ob, w, seg=seg, ang=ang, harden=harden)
    rbx.wn(ob)
    rbx.smooth(ob)
    if grp:
        ob["grp"] = grp
    parts.append(ob)
    return ob


body = rbx.prism("Body", rbx.chamfer_rect(W, D, CH), Z0, Z1, pc)
with rbx.Edit(body) as bm:
    side = [f for f in bm.faces if abs(f.normal.z) < 0.1 and (abs(f.normal.x) > 0.99 or abs(f.normal.y) > 0.99)]
    bmesh.ops.inset_individual(bm, faces=side, thickness=0.2, depth=-0.06, use_even_offset=True)
vb = bmesh.new()
for cx in (-0.8, 0.8):
    for k in range(5):
        bmesh.ops.create_cube(vb, size=1, matrix=Matrix.Translation((cx, HD - 0.06, 0.78 + k * 0.18)) @ Matrix.Diagonal((1.0, 0.3, 0.085, 1)))
vent = rbx.put("VentCut", vb, pc)
rbx.cut(body, vent)
add(body, paint)

lid = rbx.prism("Lid", rbx.chamfer_rect(W + 0.12, D + 0.12, CH + 0.05), L0, L1, pc)
with rbx.Edit(lid) as bm:
    top = [f for f in bm.faces if f.normal.z > 0.9]
    bmesh.ops.inset_individual(bm, faces=top, thickness=0.28, depth=-0.05, use_even_offset=True)
add(lid, paint)
for y in (-0.62, 0.62):
    add(rbx.box("Rib", (W - 0.9, 0.24, 0.1), (0, y, L1 - 0.005), pc), guard, 0.025, 1, grp="rib")

fp = rbx.chamfer_rect(W, D, CH)
n = len(fp)
E = 0.24
for k, (i, j) in enumerate(((1, 2), (3, 4), (5, 6), (7, 0))):
    pa, pb = Vector(fp[i]), Vector(fp[j])
    s = pa + (Vector(fp[i - 1]) - pa).normalized() * E
    e = pb + (Vector(fp[(j + 1) % n]) - pb).normalized() * E
    poly = [tuple(s), tuple(pa), tuple(pb), tuple(e)]
    foot = rbx.offset2d(poly, 0.07) + list(reversed(rbx.offset2d(poly, -0.01)))
    add(rbx.prism("Guard%d" % k, foot, Z0 - 0.04, Z1 - 0.02, pc), guard, 0.03, grp="guard")
    nv = Vector(((pb - pa).y, -(pb - pa).x)).normalized()
    for z in (Z0 + 0.35, Z1 - 0.37):
        p = (pa + pb) / 2 + nv * 0.09
        bolt = rbx.cyl("Bolt", 0.075, 0.07, 6, (0, 0, 0), "X", pc)
        bolt.location = (p.x, p.y, z)
        bolt.rotation_euler.z = math.atan2(nv.y, nv.x)
        rbx.freeze(bolt)
        add(bolt, steel, 0, grp="bolt")

for sx in (1, -1):
    x0 = sx * (HW - 0.06)
    path = rbx.fillet([(x0, -0.62, 1.5), (sx * (HW + 0.2), -0.62, 1.5), (sx * (HW + 0.2), 0.62, 1.5), (x0, 0.62, 1.5)], 0.12, 3)
    h = rbx.sweep("Handle", path, rbx.circle(0.06, 6, math.pi / 6), pc)
    h["keep_uv"] = True
    h["grp"] = "handle"
    rbx.give(h, steel)
    rbx.smooth(h)
    parts.append(h)
    for y in (-0.62, 0.62):
        add(rbx.box("Mount", (0.14, 0.26, 0.32), (sx * (HW + 0.01), y, 1.5), pc), guard, 0.025, 1, grp="mount")

for x in (-1.0, 1.0):
    add(rbx.box("LatchBase", (0.36, 0.07, 0.42), (x, -HD - 0.025, Z1 - 0.2), pc), steel, 0.018, 1, grp="lbase")
    add(rbx.box("LatchClasp", (0.3, 0.07, 0.2), (x, -HD - 0.085, L0 + 0.12), pc), steel, 0.018, 1, grp="lclasp")
    lever = rbx.box("LatchLever", (0.14, 0.09, 0.46), (0, 0, 0), pc)
    lever.location = (x, -HD - 0.1, Z1 + 0.02)
    lever.rotation_euler.x = R(-8)
    rbx.freeze(lever)
    add(lever, steel, 0.02, 1, grp="lever")
    add(rbx.cyl("Pin", 0.05, 0.3, 8, (x, -HD - 0.08, Z1 - 0.2), "X", pc), steel, 0, grp="pin")
    add(rbx.cyl("Hinge", 0.07, 0.5, 8, (x * 1.1, HD + 0.07, Z1 + 0.015), "X", pc), guard, 0, grp="hinge")

add(rbx.box("Plate", (1.3, 0.04, 0.55), (0, -HD + 0.04, 1.2), pc), plate, 0.012, 1)
for y in (-0.95, 0.95):
    add(rbx.box("Skid", (W - 0.5, 0.5, 0.26), (0, y, 0.13), pc), guard, 0.04, 1, grp="skid")
log("parts built: %d" % len(parts))

budget = {}
masters = {}
for p in parts:
    rbx.apply(p)
    g = p.get("grp")
    rbx.tag_faces(p, "copy", 0)
    if g and g in masters and len(masters[g].data.loops) == len(p.data.loops):
        p["copy_of"] = masters[g].name
        rbx.tag_faces(p, "copy", 1)
        if not p.data.uv_layers:
            p.data.uv_layers.new(name="UVMap")
    elif not p.get("keep_uv"):
        rbx.uv_unfold(p, 50)
    if g and g not in masters:
        masters[g] = p
    k = p.name.split(".")[0].rstrip("0123456789")
    budget[k] = budget.get(k, 0) + sum(len(f.vertices) - 2 for f in p.data.polygons)
log("tris per part %s" % sorted(budget.items(), key=lambda x: -x[1]))
bpy.data.objects.remove(vent, do_unlink=True)
log("hidden islands shrunk: %d" % rbx.pack_parts(parts, 8, T, ground=True))
crate = rbx.join(parts, "Crate")
rbx.tri(crate)
rbx.apply(crate)
log("joined, unwrapped, triangulated")
rep = rbx.audit(crate, T)
log("audit tris=%d" % rep["tris"])

lo, hi = rbx.bounds([crate])
w = bpy.data.worlds.new("Bake")
sc.world = w
w.light_settings.distance = 0.6
log("copies moved out for bakes: %d faces" % rbx.shift_tagged(crate, "copy", 1.0))
idim = rbx.fimage("id", T)
rbx.bake_ids(crate, idim, margin=0)
log("id baked")
aoim = rbx.fimage("ao", T)
rbx.bake(crate, "AO", aoim, samples=48, margin=4)
log("ao baked")
edim = rbx.fimage("edge", T)
rbx.mask_bake(crate, rbx.edge_build(0.08, 5.0), edim, samples=16)
log("edge baked")
psim = rbx.fimage("pos", T)
rbx.mask_bake(crate, rbx.pos_build(lo, hi), psim, samples=1)
nmim = rbx.fimage("nrm", T)
rbx.mask_bake(crate, rbx.nrm_build(), nmim, samples=1)
rbx.shift_tagged(crate, "copy", -1.0)
COV = rbx.coverage(crate, T)
log("position, normal and coverage baked")

slots = [s.material.name for s in crate.material_slots]
I = rbx.ids_of(rbx.px(idim))
AO = rbx.px(aoim)[..., 0]
EG = rbx.px(edim)[..., 0]
P = rbx.px(psim)[..., :3] * np.array(hi - lo, np.float32) + np.array(lo, np.float32)
N = rbx.px(nmim)[..., :3] * 2 - 1


def C(*c):
    return np.array(c, np.float32) / 255.0


def is_(name):
    return (I == slots.index(name)) if name in slots else np.zeros(I.shape, bool)


n1 = rbx.fbm(P, 1.4, 4, 1)
n2 = rbx.fbm(P, 6.0, 4, 2)
n3 = rbx.fbm(P, 24.0, 3, 3)
col = np.zeros(P.shape, np.float32)
rough = np.full(I.shape, 0.5, np.float32)
metal = np.zeros(I.shape, np.float32)
mp, mg, ms, ml = is_("Paint"), is_("Guard"), is_("Steel"), is_("Plate")
col[mp] = C(196, 96, 38)
col[mg] = C(58, 60, 64)
col[ms] = C(176, 176, 174)
col[ml] = C(222, 219, 208)
col *= (0.92 + 0.16 * n1)[..., None]
rough[mp] = 0.5 + 0.14 * n1[mp]
rough[mg] = 0.56 + 0.12 * n1[mg]
rough[ms] = 0.3 + 0.12 * n2[ms]
rough[ml] = 0.48
metal[ms] = 1.0

band = mp & (P[..., 2] > L0 + 0.05) & (P[..., 2] < L1 - 0.06) & (N[..., 1] < -0.9)
st = np.mod((P[..., 0] + P[..., 2]) * 2.6, 1.0) < 0.5
col[band & st] = C(226, 184, 46)
col[band & ~st] = C(34, 34, 34)

face = ml & (N[..., 1] < -0.9)
lx = P[..., 0]
lz = P[..., 2]
brd = face & ((np.abs(lx) > 0.56) & (np.abs(lx) < 0.6) | (np.abs(lz - 1.2) > 0.2) & (np.abs(lz - 1.2) < 0.24)) & (np.abs(lx) < 0.6) & (np.abs(lz - 1.2) < 0.24)
bars = face & (lx > -0.5) & (lx < -0.05) & (lz > 1.0) & (lz < 1.3) & (rbx._hash(np.floor((lx + 0.5) * 60).astype(np.int64), np.zeros_like(lx, np.int64), np.zeros_like(lx, np.int64), 7) > 0.45)
txt = face & (lx > 0.05) & (lx < 0.5) & ((np.abs(lz - 1.32) < 0.03) | (np.abs(lz - 1.2) < 0.03) & (lx < 0.38) | (np.abs(lz - 1.08) < 0.03) & (lx < 0.44))
col[brd | bars | txt] = C(28, 28, 28)
scr = np.zeros(I.shape, bool)
for sx_ in (-0.57, 0.57):
    for sz_ in (0.98, 1.42):
        d2 = (lx - sx_) ** 2 + (lz - sz_) ** 2
        col[face & (d2 < 0.038 ** 2)] = C(150, 150, 146)
        col[face & (d2 < 0.024 ** 2)] = C(70, 70, 70)
        scr |= face & (d2 < 0.038 ** 2)

paintable = mp | mg | ml
ew = EG * (0.55 + 0.9 * n2)
wear = rbx.sstep(0.3, 0.55, ew) * paintable
chips = rbx.sstep(0.74, 0.8, n3) * rbx.sstep(0.1, 0.45, EG + 0.35 * n2) * paintable
bare = np.clip(np.maximum(wear, chips * 0.85), 0, 1)
rim = np.clip(rbx.sstep(0.1, 0.25, ew) - bare, 0, 1) * paintable
col = col * (1 + 0.28 * rim[..., None])
steel_bare = C(168, 168, 165) * (0.9 + 0.2 * n3)[..., None]
col = col * (1 - bare[..., None]) + steel_bare * bare[..., None]
rough = rough * (1 - bare) + (0.28 + 0.1 * n3) * bare
metal = np.maximum(metal, (bare > 0.5).astype(np.float32))

cav = 1 - AO
g = rbx.sstep(0.12, 0.65, cav * (0.6 + 0.8 * n1))
col = col * (1 - 0.5 * g[..., None]) + C(46, 37, 29) * (0.25 * g[..., None])
rough = rough + 0.16 * g
up = rbx.sstep(0.6, 0.95, N[..., 2])
dust = up * rbx.sstep(0.45, 0.72, n1) * 0.35
col = col * (1 - dust[..., None]) + C(170, 158, 134) * dust[..., None]
rough = rough + 0.2 * dust
col = col * (0.78 + 0.22 * AO)[..., None]

dbg = []
for nm, arr in (("m_ao", AO), ("m_edge", EG), ("m_bare", bare), ("m_grime", g)):
    t = np.ones(P.shape[:2] + (4,), np.float32)
    t[..., :3] = np.clip(arr, 0, 1)[..., None]
    rbx.unpx(nm, t, os.path.join(out, nm + ".png"), data=True)
    dbg.append(os.path.join(out, nm + ".png"))
rbx.sheet(dbg, 4, os.path.join(out, "masks.png"))

rgba = np.ones(P.shape[:2] + (4,), np.float32)
rgba[..., :3] = rbx.dilate(np.clip(col, 0, 1), COV)
cim = rbx.unpx("crate_color", rgba, os.path.join(out, "crate_color.png"))
ra = np.ones_like(rgba)
ra[..., :3] = rbx.dilate(np.clip(rough, 0.04, 1)[..., None], COV)
rim_ = rbx.unpx("crate_rough", ra, os.path.join(out, "crate_rough.png"), data=True)
ma = np.ones_like(rgba)
ma[..., :3] = rbx.dilate((metal > 0.5).astype(np.float32)[..., None], COV)
mim = rbx.unpx("crate_metal", ma, os.path.join(out, "crate_metal.png"), data=True)
log("textures composed")

fin = rbx.pbr_mat("Crate", cim, rim_, mim)
crate.data.materials.clear()
crate.data.materials.append(fin)
for p in crate.data.polygons:
    p.material_index = 0
rep = rbx.audit(crate, T)

cell = int(a["cell"])
shots = []
crate.color = (0.78, 0.78, 0.78, 1)
rbx.workbench(sc, "matcap", "basic_grey.exr")
rbx.camera(sc, [crate], 35, 22)
shots.append(rbx.shot(sc, os.path.join(out, "r_clay.png"), cell, cell))
wi = rbx.wire(crate)
rbx.workbench(sc, "studio", color="OBJECT")
shots.append(rbx.shot(sc, os.path.join(out, "r_wire.png"), cell, cell))
bpy.data.objects.remove(wi, do_unlink=True)
log("workbench renders")

fl = rbx.box("Floor", (40, 40, 0.2), (0, 0, -0.1))
rbx.give(fl, rbx.mat("Floor", rbx.srgb((92, 94, 98)), 0.85))
rbx.world(sc, "studio.exr", 1.0, 30, sun=2.5)
rbx.cycles(sc, 40)
sc.cycles.use_denoising = True
rbx.camera(sc, [crate], 35, 22)
shots.append(rbx.shot(sc, os.path.join(out, "r_front.png"), cell, cell))
rbx.camera(sc, [crate], 215, 28)
shots.append(rbx.shot(sc, os.path.join(out, "r_back.png"), cell, cell))
dm = rbx.dummy((3.4, -1.3, 0), yaw=25)
fl.scale = (6, 6, 1)
rbx.world(sc, "forest.exr", 1.0, 120, sun=3.0)
rbx.look_from(sc, (7.5, -12.5, 7.0), (1.6, -0.8, 1.6), 70)
shots.append(rbx.shot(sc, os.path.join(out, "r_player.png"), cell, cell))
log("cycles renders")
shots.append(rbx.uv_sheet(crate, os.path.join(out, "r_uv.png"), T, cim))
uvi = bpy.data.images.load(shots[-1])
uvi.scale(cell, cell)
rbx.save(uvi, shots[-1])
rbx.sheet(shots, 3, os.path.join(out, "sheet.png"))
log("sheet saved")

bpy.data.objects.remove(dm, do_unlink=True)
bpy.data.objects.remove(fl, do_unlink=True)
rbx.fbx([crate], os.path.join(out, "crate.fbx"))
rbx.mesh_json(crate, os.path.join(out, "crate.json"))
for im in (cim, rim_, mim):
    im.filepath = os.path.join(out, im.name + ".png")
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out, "crate.blend"))
rbx.report(os.path.join(out, "report.json"), rep)
log("done")
