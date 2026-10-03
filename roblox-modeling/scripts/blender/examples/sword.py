import bpy, bmesh, math, os, sys, time
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import rbx
import numpy as np
from mathutils import Vector, Matrix

R = rbx.R
a = rbx.args(out=r"C:\Users\vietb\Desktop\roblox\Blender\Modeling\Sword", tex="1024", cell="480")
out = a["out"]
os.makedirs(out, exist_ok=True)
T = int(a["tex"])
cell = int(a["cell"])
t0 = time.time()


def log(s):
    print("[%5.1fs] %s" % (time.time() - t0, s), flush=True)


sc = rbx.fresh()
HI = rbx.col("High")
LO = rbx.col("Low")
ZB0, ZT, ZTIP = 0.45, 3.25, 3.95


def ss(x, lo_, hi_):
    t = min(max((x - lo_) / (hi_ - lo_), 0.0), 1.0)
    return t * t * (3 - 2 * t)


WB, WT = 0.42, 0.34


def width(z):
    if z <= 0.55:
        return WB
    if z <= ZT:
        return WB + (WT - WB) * (z - 0.55) / (ZT - 0.55)
    v = (z - ZT) / (ZTIP - ZT)
    return WT * max(0.0, 1 - v ** 1.7) ** 0.75


def thick(z):
    return 0.07 + (0.032 - 0.07) * min(max((z - 0.55) / (ZTIP - 0.55), 0.0), 1.0)


def fdepth(z):
    return 0.014 * ss(z, 0.62, 0.72) * (1 - ss(z, 2.55, 2.95))


def fwid(z):
    return 0.12 - 0.035 * min(max((z - 0.55) / 2.4, 0.0), 1.0)


def yprof(x, z):
    h = width(z) / 2
    s = min(abs(x) / h, 1.0)
    y = thick(z) / 2 * (1 - s ** 1.6)
    fw = fwid(z)
    if abs(x) < fw / 2:
        y -= fdepth(z) * math.cos(math.pi * x / fw) ** 2
    return y


def ring_hi(z, n=46):
    h = width(z) / 2
    xs = [h - 2 * h * (k + 1) / (n + 1) for k in range(n)]
    pts = [(h, 0.0)] + [(x, yprof(x, z)) for x in xs] + [(-h, 0.0)] + [(x, -yprof(x, z)) for x in reversed(xs)]
    return [(x, y, z) for x, y in pts]


def ring_lo(z):
    h, t, k = width(z) / 2, thick(z), 0.36
    return [(x, y, z) for x, y in ((h, 0), (k * h, t / 2), (-k * h, t / 2), (-h, 0), (-k * h, -t / 2), (k * h, -t / 2))]


m_steel = rbx.mat("Steel", rbx.srgb((192, 194, 197)), 0.2, 1.0)
m_fuller = rbx.mat("Fuller", rbx.srgb((170, 172, 176)), 0.3, 1.0)
m_brass = rbx.mat("Brass", rbx.srgb((222, 174, 90)), 0.3, 1.0)
m_core = rbx.mat("LeatherD", rbx.srgb((46, 30, 22)), 0.62)
m_strap = rbx.mat("Leather", rbx.srgb((96, 60, 38)), 0.55)
order = ["Steel", "Fuller", "Brass", "LeatherD", "Leather"]

zs = [ZB0 + 0.025 * i for i in range(int((ZTIP - 0.012 - ZB0) / 0.025) + 1)]
blade_h = rbx.loft("BladeH", [ring_hi(z) for z in zs], HI, tip=(0, 0, ZTIP))
blade_h.data.materials.append(m_steel)
blade_h.data.materials.append(m_fuller)
for p in blade_h.data.polygons:
    c = p.center
    if fdepth(c.z) > 0.002 and abs(c.x) < fwid(c.z) / 2:
        p.material_index = 1
rbx.smooth(blade_h)
blade_l = rbx.loft("BladeL", [ring_lo(z) for z in (ZB0, 1.6, 2.6, ZT, 3.6)], LO, tip=(0, 0, ZTIP))

gp = [(-0.74, 0, 0.57), (-0.56, 0, 0.5), (-0.22, 0, 0.47), (0.22, 0, 0.47), (0.56, 0, 0.5), (0.74, 0, 0.57)]


def taper(t):
    return 1 - 0.3 * abs(2 * t - 1) ** 2


bar_h = rbx.sweep("GuardBarH", rbx.resample(rbx.fillet(gp, 0.15, 6), 0.02), rbx.rect(0.11, 0.09, 0.03, 4), HI, scale=taper)
bar_l = rbx.sweep("GuardBarL", rbx.fillet(gp, 0.15, 3), rbx.rect(0.11, 0.09, 0.025, 2), LO, scale=taper)
knobs_h, knobs_l = [], []
for end in (gp[0], gp[-1]):
    knobs_h.append(rbx.lathe("KnobH", [(0.062 * math.sin(R(a_)), 0.062 * math.cos(R(a_))) for a_ in range(0, 181, 15)], 24, HI, at=end))
    knobs_l.append(rbx.lathe("KnobL", [(0.062 * math.sin(R(a_)), 0.062 * math.cos(R(a_))) for a_ in (0, 45, 90, 135, 180)], 10, LO, at=end))
block_h = rbx.box("BlockH", (0.26, 0.2, 0.2), (0, 0, 0.47), HI)
rbx.bevel(block_h, 0.025, seg=4, harden=False, strength="FSTR_NONE")
rbx.apply(block_h)
block_l = rbx.box("BlockL", (0.26, 0.2, 0.2), (0, 0, 0.47), LO)
rbx.bevel(block_l, 0.022, seg=1, harden=False, strength="FSTR_NONE")
rbx.apply(block_l)
for o in [bar_h, block_h] + knobs_h:
    rbx.give(o, m_brass)
    rbx.smooth(o)


def core_r(z):
    return 0.066 + 0.012 * (1 - (z / 0.43) ** 2)


core_h = rbx.lathe("CoreH", [(0, -0.42)] + [(core_r(-0.42 + 0.86 * i / 40), -0.42 + 0.86 * i / 40) for i in range(41)] + [(0, 0.44)], 32, HI)
rbx.give(core_h, m_core)
rbx.smooth(core_h)
N = 8 * 28
path, ups = [], []
for i in range(N + 1):
    u = i / N
    z = -0.385 + 0.79 * u
    an = 2 * math.pi * 8 * u
    r = core_r(z) + 0.007
    path.append((r * math.cos(an), r * math.sin(an), z))
    ups.append((math.cos(an), math.sin(an), 0))
strap_h = rbx.sweep("StrapH", path, rbx.rect(0.075, 0.014, 0.005, 2), HI, ups=ups)
rbx.give(strap_h, m_strap)
rbx.smooth(strap_h)
grip_l = rbx.lathe("GripL", [(0, -0.42), (0.086, -0.42), (0.094, -0.2), (0.096, 0.01), (0.094, 0.22), (0.082, 0.42), (0, 0.42)], 12, LO)

pp = [(0.0, 0, -0.40), (0.07, 0, -0.40), (0.075, 0, -0.43), (0.14, 0, -0.48), (0.155, 0, -0.54), (0.14, 0, -0.60), (0.08, 0, -0.66), (0.035, 0, -0.69), (0.0, 0, -0.695)]
pom_h = rbx.lathe("PommelH", [(p[0], p[2]) for p in rbx.fillet(pp, 0.02, 4)], 32, HI)
rbx.give(pom_h, m_brass)
rbx.smooth(pom_h)
pom_l = rbx.lathe("PommelL", [(0, -0.40), (0.075, -0.42), (0.135, -0.465), (0.155, -0.52), (0.152, -0.575), (0.13, -0.62), (0.08, -0.662), (0, -0.695)], 14, LO)
log("high and low built")

m_low = rbx.mat("SwordLow", (0.6, 0.6, 0.6), 0.5)
guard_l = rbx.join([bar_l, block_l] + knobs_l, "GuardL")
lows = [blade_l, guard_l, grip_l, pom_l]
groups = {"BladeL": [blade_h], "GuardL": [bar_h, block_h] + knobs_h, "GripL": [core_h, strap_h], "PommelL": [pom_h]}
for o in lows:
    rbx.give(o, m_low)
    o.data.shade_smooth()
    o.data.set_sharp_from_angle(angle=R(60))
    rbx.chart_seams(o, 50)
    if o is blade_l:
        rbx.cut_rings(o, "z", [1.6, 2.6])
    rbx.unwrap(o)
rbx.pack_parts(lows, 8, T)
for o in lows:
    rbx.tri(o)
    rbx.apply(o)
rbx.lowvis(lows, False)
hi_tris = sum(sum(len(f.vertices) - 2 for f in o.data.polygons) for o in HI.objects)
lo_tris = sum(len(o.data.polygons) for o in lows)
log("high tris %d, low tris %d" % (hi_tris, lo_tris))

nim = rbx.fimage("normal", T)
for i, o in enumerate(lows):
    rbx.bake(o, "NORMAL", nim, groups[o.name], samples=16, extrude=0.03, clear=(i == 0), margin=4)
log("normal baked")

idm = {n: rbx.emit_mat("ID_" + n, lambda nt, c=rbx.ID_COLORS[k]: c) for k, n in enumerate(order)}
keep = {o.name: list(o.data.materials) for o in HI.objects}
for o in HI.objects:
    for k, m in enumerate(o.data.materials):
        o.data.materials[k] = idm[m.name]
idim = rbx.fimage("id", T)
for i, o in enumerate(lows):
    rbx.bake(o, "EMIT", idim, groups[o.name], samples=1, extrude=0.03, clear=(i == 0), margin=0)
for o in HI.objects:
    for k, m in enumerate(keep[o.name]):
        o.data.materials[k] = m
log("id baked")

w = bpy.data.worlds.new("Bake")
sc.world = w
w.light_settings.distance = 0.25
aoim = rbx.fimage("ao", T)
for i, o in enumerate(lows):
    rbx.bake(o, "AO", aoim, groups[o.name], samples=48, extrude=0.03, clear=(i == 0), margin=4)
log("ao baked")

sword = rbx.join(lows, "Sword")
lo, hi = rbx.bounds([sword])
psim = rbx.fimage("pos", T)
rbx.mask_bake(sword, rbx.pos_build(lo, hi), psim, samples=1)
COV = rbx.coverage(sword, T)
log("position and coverage baked")

I = rbx.ids_of(rbx.px(idim))
AO = rbx.px(aoim)[..., 0]
CV = rbx.curvature(nim, 2.0)
P = rbx.px(psim)[..., :3] * np.array(hi - lo, np.float32) + np.array(lo, np.float32)


def C(*c):
    return np.array(c, np.float32) / 255.0


steel, fuller, brass, core, strap = [(I == k) for k in range(5)]
n1 = rbx.fbm(P, 2.0, 4, 1)
n2 = rbx.fbm(P, 9.0, 4, 2)
n3 = rbx.fbm(P, 30.0, 3, 3)
br = rbx.fbm(P * np.array([60, 60, 2.5], np.float32), 1.0, 3, 5)
col = np.zeros(P.shape, np.float32)
rough = np.full(I.shape, 0.5, np.float32)
metal = np.zeros(I.shape, np.float32)

zz = P[..., 2]
wv = np.where(zz <= 0.55, 0.34, np.where(zz <= ZT, 0.34 + (0.27 - 0.34) * (zz - 0.55) / (ZT - 0.55),
              0.27 * np.clip(1 - np.clip((zz - ZT) / (ZTIP - ZT), 0, 1) ** 1.7, 0, 1) ** 0.75))
ez = rbx.sstep(0.035, 0.0, wv / 2 - np.abs(P[..., 0])) * steel
col[steel] = C(192, 194, 197)
col[fuller] = C(168, 170, 174)
col = col * (0.92 + 0.12 * br)[..., None]
rough[steel] = (0.15 + 0.1 * br + 0.08 * n1)[steel]
rough[fuller] = (0.3 + 0.1 * n1)[fuller]
metal[steel | fuller] = 1
col = col * (1 - ez[..., None]) + C(216, 218, 222) * ez[..., None]
rough = rough * (1 - ez) + 0.08 * ez
nick = rbx.sstep(0.8, 0.85, n3) * ez
col = col * (1 - 0.5 * nick[..., None]) + C(140, 140, 142) * (0.5 * nick[..., None])
rough = rough + 0.15 * nick

col[brass] = (C(222, 174, 90) * (0.92 + 0.12 * n1)[..., None])[brass]
rough[brass] = (0.3 + 0.1 * n2)[brass]
metal[brass] = 1
pat = rbx.sstep(0.1, 0.55, (1 - AO) * (0.6 + 0.8 * n2)) * brass
col = col * (1 - 0.75 * pat[..., None]) + C(84, 64, 36) * (0.75 * pat[..., None])
rough = rough + 0.35 * pat
metal = np.where(pat > 0.55, 0.0, metal)
pol = rbx.sstep(0.55, 0.75, CV) * brass
col = col * (1 - 0.6 * pol[..., None]) + C(246, 214, 140) * (0.6 * pol[..., None])
rough = rough - 0.12 * pol

col[core] = (C(46, 30, 22) * (0.9 + 0.2 * n2)[..., None])[core]
rough[core] = 0.62
col[strap] = (C(96, 60, 38) * (0.85 + 0.3 * n2)[..., None])[strap]
rough[strap] = (0.55 + 0.1 * n3)[strap]
lw = rbx.sstep(0.55, 0.8, CV) * strap
col = col * (1 - 0.5 * lw[..., None]) + C(140, 98, 64) * (0.5 * lw[..., None])
diel = core | strap
col = col * np.where(diel, 0.68 + 0.32 * AO, 0.86 + 0.14 * AO)[..., None]

rgba = np.ones(P.shape[:2] + (4,), np.float32)
rgba[..., :3] = rbx.dilate(np.clip(col, 0, 1), COV)
cim = rbx.unpx("sword_color", rgba, os.path.join(out, "sword_color.png"))
ra = np.ones_like(rgba)
ra[..., :3] = rbx.dilate(np.clip(rough, 0.04, 1)[..., None], COV)
rim = rbx.unpx("sword_rough", ra, os.path.join(out, "sword_rough.png"), data=True)
ma = np.ones_like(rgba)
ma[..., :3] = rbx.dilate((metal > 0.5).astype(np.float32)[..., None], COV)
mim = rbx.unpx("sword_metal", ma, os.path.join(out, "sword_metal.png"), data=True)
na = np.ones_like(rgba)
na[..., :3] = rbx.dilate(rbx.px(nim)[..., :3], COV)
nrm8 = rbx.unpx("sword_normal", na, os.path.join(out, "sword_normal.png"), data=True)
log("textures composed")

tex = []
for nm, arr in (("t_ao", AO), ("t_curv", CV)):
    t_ = np.ones(P.shape[:2] + (4,), np.float32)
    t_[..., :3] = np.clip(arr, 0, 1)[..., None]
    rbx.unpx(nm, t_, os.path.join(out, nm + ".png"), data=True)
    tex.append(os.path.join(out, nm + ".png"))
rbx.sheet([os.path.join(out, "sword_color.png"), os.path.join(out, "sword_normal.png"), os.path.join(out, "sword_rough.png"), os.path.join(out, "sword_metal.png")] + tex, 3, os.path.join(out, "textures.png"))

fin = rbx.pbr_mat("Sword", cim, rim, mim, nrm8)
sword.data.materials.clear()
sword.data.materials.append(fin)
rep = rbx.audit(sword, T)
rep["high_tris"] = hi_tris

pivot = bpy.data.objects.new("Turn", None)
sc.collection.objects.link(pivot)
for o in list(HI.objects) + [sword]:
    o.parent = pivot
pivot.rotation_euler = (0, R(-50), 0)
shots = []
HI.hide_render = False
sword.hide_render = True
rbx.workbench(sc, "matcap", "basic_grey.exr")
rbx.camera(sc, list(HI.objects), 15, 12)
shots.append(rbx.shot(sc, os.path.join(out, "r_high.png"), cell, cell))
HI.hide_render = True
sword.hide_render = False
wi = rbx.wire(sword, 0.004)
wi.parent = pivot
wi.matrix_parent_inverse = pivot.matrix_world.inverted()
sword.color = (0.75, 0.75, 0.75, 1)
rbx.workbench(sc, "studio", color="OBJECT")
shots.append(rbx.shot(sc, os.path.join(out, "r_low_wire.png"), cell, cell))
bpy.data.objects.remove(wi, do_unlink=True)
log("workbench renders")

clay = rbx.pbr_mat("Clay", None, None, None, nrm8)
clay.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.3, 0.3, 0.3, 1)
clay.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.35
sword.data.materials[0] = clay
rbx.studio(sc, [sword])
rbx.cycles(sc, 32)
sc.cycles.use_denoising = True
rbx.camera(sc, [sword], 15, 12)
shots.append(rbx.shot(sc, os.path.join(out, "r_low_normal.png"), cell, cell))
sword.data.materials[0] = fin
shots.append(rbx.shot(sc, os.path.join(out, "r_beauty.png"), cell, cell))
pivot.rotation_euler = (0, R(-50), R(35))
cam = rbx.camera(sc, [sword], 15, 12)
hilt = sword.matrix_world @ Vector((0, 0, 0.1))
cam.data.lens = 85
cam.location = hilt + (cam.location - hilt).normalized() * 3.4
cam.rotation_euler = (hilt - cam.location).to_track_quat("-Z", "Y").to_euler()
shots.append(rbx.shot(sc, os.path.join(out, "r_hilt.png"), cell, cell))
pivot.rotation_euler = (0, 0, 0)
rbx.no_studio()
sword.location = (2.2, -0.4, 0.7)
dm = rbx.dummy((0, 0, 0), yaw=0)
fl = rbx.box("Floor", (240, 240, 0.2), (0, 0, -0.1))
rbx.give(fl, rbx.mat("Floor", rbx.srgb((92, 94, 98)), 0.85))
rbx.world(sc, "forest.exr", 1.0, 120, sun=3.0)
rbx.look_from(sc, (5.5, -11.0, 6.5), (1.2, 0, 2.4), 70)
shots.append(rbx.shot(sc, os.path.join(out, "r_player.png"), cell, cell))
log("cycles renders")
rbx.sheet(shots, 3, os.path.join(out, "sheet.png"))
uvp = rbx.uv_sheet(sword, os.path.join(out, "r_uv.png"), T, cim)
bpy.data.objects.remove(dm, do_unlink=True)
bpy.data.objects.remove(fl, do_unlink=True)
sword.location = (0, 0, 0)
sword.parent = None
rbx.fbx([sword], os.path.join(out, "sword.fbx"))
rbx.mesh_json(sword, os.path.join(out, "sword.json"))
for im in (cim, rim, mim, nrm8):
    im.filepath = os.path.join(out, im.name + ".png")
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out, "sword.blend"))
rbx.report(os.path.join(out, "report.json"), rep)
log("done")
