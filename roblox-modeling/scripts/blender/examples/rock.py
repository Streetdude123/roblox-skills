import bpy, bmesh, math, os, sys, time, random
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import rbx
import numpy as np
from mathutils import Vector, Matrix, Euler

R = rbx.R
a = rbx.args(out=r"C:\Users\vietb\Desktop\roblox\Blender\Modeling\Rock", tex="1024", cell="480", seed="7")
out = a["out"]
os.makedirs(out, exist_ok=True)
T = int(a["tex"])
cell = int(a["cell"])
SEED = int(a["seed"])
t0 = time.time()


def log(s):
    print("[%5.1fs] %s" % (time.time() - t0, s), flush=True)


sc = rbx.fresh()
HI = rbx.col("High")
LO = rbx.col("Low")
FL = rbx.col("Flat")
rnd = random.Random(SEED)
tilt = bpy.data.objects.new("Strata", None)
sc.collection.objects.link(tilt)
tilt.rotation_euler = (R(8), R(90), R(0))


def hull(name, size, n, seed, cut=0.22, c=None):
    r = random.Random(seed)
    bm = bmesh.new()
    for i in range(n):
        while True:
            p = Vector((r.uniform(-1, 1), r.uniform(-1, 1), r.uniform(-1, 1)))
            if p.length <= 1:
                break
        p = p.normalized() * (0.72 + 0.28 * r.random())
        bm.verts.new((p.x * size[0] / 2, p.y * size[1] / 2, p.z * size[2] / 2))
    bmesh.ops.convex_hull(bm, input=bm.verts)
    for v in [v for v in bm.verts if not v.link_faces]:
        bm.verts.remove(v)
    zl = min(v.co.z for v in bm.verts)
    bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=(0, 0, zl + size[2] * cut), plane_no=(0, 0, -1), clear_outer=True)
    bmesh.ops.holes_fill(bm, edges=[e for e in bm.edges if e.is_boundary])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    zl = min(v.co.z for v in bm.verts)
    bmesh.ops.translate(bm, vec=(0, 0, -zl), verts=bm.verts)
    return rbx.put(name, bm, c)


def tex(name, kind, **kw):
    t = bpy.data.textures.new(name, kind)
    for k, v in kw.items():
        setattr(t, k, v)
    return t


def detail(ob, s, seed, voxel):
    rbx.mod(ob, "REMESH", mode="VOXEL", voxel_size=voxel, use_smooth_shade=True)
    rbx.mod(ob, "SMOOTH", factor=0.5, iterations=2)
    big = tex("Big%d" % seed, "CLOUDS", noise_scale=0.6 * s, noise_depth=2)
    chunk = tex("Chunk%d" % seed, "VORONOI", distance_metric="DISTANCE", noise_scale=0.75 * s, weight_1=1.0, weight_2=0.0, weight_3=0.0, weight_4=0.0, noise_intensity=1.0)
    band = tex("Band%d" % seed, "MARBLE", marble_type="SHARPER", noise_scale=0.35 * s, turbulence=1.5, noise_depth=2)
    crack = tex("Crack%d" % seed, "VORONOI", distance_metric="DISTANCE", noise_scale=0.5 * s, weight_1=-1.0, weight_2=1.0, weight_3=0.0, weight_4=0.0, noise_intensity=1.0, contrast=4.0, intensity=1.25)
    fine = tex("Fine%d" % seed, "STUCCI", noise_scale=0.06, turbulence=5)
    rbx.mod(ob, "DISPLACE", texture=big, strength=0.08 * s, mid_level=0.5, texture_coords="LOCAL")
    rbx.mod(ob, "DISPLACE", texture=chunk, strength=-0.16 * s, mid_level=0.5, texture_coords="LOCAL")
    rbx.mod(ob, "DISPLACE", texture=band, strength=0.06 * s, mid_level=0.5, texture_coords="OBJECT", texture_coords_object=tilt)
    rbx.mod(ob, "DISPLACE", texture=crack, strength=0.09 * s, mid_level=1.0, texture_coords="LOCAL")
    rbx.mod(ob, "DISPLACE", texture=fine, strength=0.012, mid_level=0.5, texture_coords="LOCAL")
    rbx.apply(ob)
    with rbx.Edit(ob) as bm:
        zl = min(v.co.z for v in bm.verts)
        for v in bm.verts:
            if v.co.z < zl + 0.05:
                v.co.z = zl
    rbx.smooth(ob)
    return ob


STRATA = np.array(Vector((0.18, 0.1, 1.0)).normalized(), np.float32)


def rockify(ob, size, seed):
    s = max(size)
    rbx.mod(ob, "REMESH", mode="VOXEL", voxel_size=s / 110.0, use_smooth_shade=True)
    rbx.mod(ob, "SMOOTH", factor=0.5, iterations=2)
    rbx.apply(ob)

    def fn(P, N):
        t = P @ STRATA
        h = s / 3.2
        wob = rbx.fbm(P, 1.5 / s, 3, seed + 5) - 0.5
        u = np.mod(t / h + 0.9 * wob, 1.0)
        brk = rbx.sstep(0.45, 0.6, rbx.fbm(P, 2.0 / s, 2, seed + 9))
        ledge = rbx.sstep(0.8, 0.97, u) * (1 - np.abs(N @ STRATA)) * brk
        f1, f2 = rbx.voronoi(P / (s * 0.3), seed)
        crack = rbx.sstep(0.05, 0.0, f2 - f1) * rbx.sstep(0.6, 0.7, rbx.fbm(P, 0.9 / s, 2, seed + 8))
        big = rbx.fbm(P, 1.2 / s, 3, seed + 6) - 0.5
        fine = rbx.fbm(P, 6.0, 3, seed + 7) - 0.5
        keep = rbx.sstep(0.0, 0.12 * s, P[:, 2])
        return (-0.02 * s * ledge - 0.01 * s * crack + 0.06 * s * big + 0.004 * fine) * keep

    rbx.vdisp(ob, fn)
    rbx.smooth(ob)
    return ob


def decimate(ob, tris):
    n = sum(len(f.vertices) - 2 for f in ob.data.polygons)
    rbx.mod(ob, "DECIMATE", decimate_type="COLLAPSE", ratio=min(1.0, tris / max(n, 1)), use_collapse_triangulate=True)
    rbx.apply(ob)
    ob.data.shade_smooth()
    ob.data.set_sharp_from_angle(angle=R(75))
    return ob


layout = [("Main", (6.4, 5.0, 6.2), (0, 0, -0.2), 0, 900, 0.16, 0.06),
          ("SideA", (3.6, 3.0, 3.0), (4.2, 1.4, -0.2), 35, 360, 0.2, 0.045),
          ("SideB", (2.8, 2.4, 2.1), (-3.7, 1.7, -0.15), -20, 300, 0.22, 0.04),
          ("Slab", (3.4, 0.95, 2.6), (1.0, -3.4, -0.15), 12, 240, 0.15, 0.035)]
pairs = []
flats = []
for i, (nm, size, at, yaw, budget, cut, vox) in enumerate(layout):
    h = rbx.cleaved(nm + "Block", size, 12 if nm == "Main" else 9, SEED * 31 + i, FL)
    h.rotation_euler = (0, 0, R(yaw))
    if nm == "Slab":
        h.rotation_euler = (R(-24), R(6), R(yaw))
    h.location = at
    rbx.freeze(h)
    flats.append(h)
    hi = rbx.dup(h, nm + "H", HI)
    rockify(hi, size, SEED * 31 + i)
    lo = decimate(rbx.dup(hi, nm + "L", LO), budget)
    pairs.append((lo, [hi]))
log("boulders built")

peb_l, peb_h = [], []
for k in range(10):
    ang = rnd.uniform(0, 2 * math.pi)
    rad = rnd.uniform(3.3, 5.6)
    s = rnd.uniform(0.25, 0.85)
    p = hull("Peb%d" % k, (s * rnd.uniform(1.0, 1.5), s, s * rnd.uniform(0.55, 0.85)), 14, SEED * 97 + k, 0.15, FL)
    p.rotation_euler = (0, 0, rnd.uniform(0, 6.28))
    p.location = (math.cos(ang) * rad * 1.15, math.sin(ang) * rad * 0.9, -s * 0.12)
    rbx.freeze(p)
    flats.append(p)
    ph = rbx.dup(p, "PebH%d" % k, HI)
    rbx.mod(ph, "SUBSURF", levels=3, render_levels=3)
    rbx.mod(ph, "DISPLACE", texture=tex("PebN%d" % k, "STUCCI", noise_scale=0.05, turbulence=4), strength=0.012, mid_level=0.5)
    rbx.apply(ph)
    rbx.smooth(ph)
    pl = rbx.dup(p, "PebL%d" % k, LO)
    pl.data.shade_smooth()
    peb_l.append(pl)
    peb_h.append(ph)
rub_l = rbx.join(peb_l, "RubbleL")
rub_l.data.shade_smooth()
rub_h = rbx.join(peb_h, "RubbleH")
pairs.append((rub_l, [rub_h]))
lows = [p[0] for p in pairs]
highs = [h for p in pairs for h in p[1]]
log("rubble built")

m_low = rbx.mat("RockLow", (0.5, 0.5, 0.5), 0.8)
for o in lows:
    rbx.give(o, m_low)
    rbx.chart_seams(o, 65)
    rbx.unwrap(o)
log("hidden islands shrunk: %d" % rbx.pack_parts(lows, 8, T, ground=True))
for o in lows:
    rbx.tri(o)
    rbx.apply(o)
rbx.lowvis(lows + flats, False)
for f in flats:
    f.hide_render = True
hi_tris = sum(sum(len(f.vertices) - 2 for f in o.data.polygons) for o in highs)
lo_tris = sum(len(o.data.polygons) for o in lows)
log("high tris %d, low tris %d" % (hi_tris, lo_tris))

nim = rbx.fimage("normal", T)
for i, (lo_, hs) in enumerate(pairs):
    rbx.bake(lo_, "NORMAL", nim, hs, samples=16, extrude=0.08, clear=(i == 0), margin=4)
log("normal baked")
w = bpy.data.worlds.new("Bake")
sc.world = w
w.light_settings.distance = 0.9
aoim = rbx.fimage("ao", T)
for i, (lo_, hs) in enumerate(pairs):
    rbx.bake(lo_, "AO", aoim, hs, samples=48, extrude=0.08, clear=(i == 0), margin=4)
log("ao baked")
keep = {h.name: list(h.data.materials) for h in highs}
hn = rbx.emit_mat("HN", rbx.nrm_build())
for h in highs:
    h.data.materials.clear()
    h.data.materials.append(hn)
nwim = rbx.fimage("nrmw", T)
for i, (lo_, hs) in enumerate(pairs):
    rbx.bake(lo_, "EMIT", nwim, hs, samples=4, extrude=0.08, clear=(i == 0), margin=4)
log("world normal baked")

rock = rbx.join(lows, "RockFormation")
lo, hi = rbx.bounds([rock])
psim = rbx.fimage("pos", T)
rbx.mask_bake(rock, rbx.pos_build(lo, hi), psim, samples=1)
COV = rbx.coverage(rock, T)

AO = rbx.px(aoim)[..., 0]
CV = rbx.curvature(nim, 1.2)
P = rbx.px(psim)[..., :3] * np.array(hi - lo, np.float32) + np.array(lo, np.float32)
NW = rbx.px(nwim)[..., :3] * 2 - 1


def C(*c):
    return np.array(c, np.float32) / 255.0


n1 = rbx.fbm(P, 0.35, 4, SEED)
n2 = rbx.fbm(P, 1.8, 4, SEED + 1)
n3 = rbx.fbm(P, 7.0, 3, SEED + 2)
n4 = rbx.fbm(P, 22.0, 2, SEED + 3)
strata = 0.5 + 0.5 * np.sin(P[..., 2] * 3.6 + P[..., 0] * 0.4 + n1 * 2.5)
col = C(126, 120, 112) * (0.86 + 0.22 * n1)[..., None]
col = col * (1 - 0.08 * strata[..., None]) + C(152, 140, 122) * (0.08 * strata[..., None])
col = col * (0.92 + 0.14 * n3)[..., None]
cav = rbx.sstep(0.3, 0.75, 1 - AO)
col = col * (1 - 0.45 * cav[..., None]) + C(50, 42, 34) * (0.3 * cav[..., None])
crk = rbx.sstep(0.38, 0.22, CV)
col = col * (1 - 0.2 * crk[..., None])
edge = rbx.sstep(0.58, 0.85, CV)
col = col * (1 - 0.2 * edge[..., None]) + C(186, 180, 168) * (0.2 * edge[..., None])
up = rbx.sstep(0.62, 0.9, NW[..., 2])
moss = up * rbx.sstep(0.5, 0.64, n2 * 0.7 + n1 * 0.5) * rbx.sstep(0.35, 0.8, AO) * 0.85
mcol = C(74, 102, 42) * (0.75 + 0.45 * n3)[..., None]
col = col * (1 - moss[..., None]) + mcol * moss[..., None]
damp = rbx.sstep(0.45, 0.0, P[..., 2] - lo.z) * (0.6 + 0.4 * n2)
col = col * (1 - 0.35 * damp[..., None])
rough = np.clip(0.84 + 0.1 * n3 - 0.12 * edge + 0.05 * moss - 0.18 * damp, 0.05, 1)
col = col * (0.78 + 0.22 * AO)[..., None]

rgba = np.ones(P.shape[:2] + (4,), np.float32)
rgba[..., :3] = rbx.dilate(np.clip(col, 0, 1), COV)
cim = rbx.unpx("rock_color", rgba, os.path.join(out, "rock_color.png"))
ra = np.ones_like(rgba)
ra[..., :3] = rbx.dilate(rough[..., None], COV)
rim = rbx.unpx("rock_rough", ra, os.path.join(out, "rock_rough.png"), data=True)
na = np.ones_like(rgba)
na[..., :3] = rbx.dilate(rbx.px(nim)[..., :3], COV)
nrm8 = rbx.unpx("rock_normal", na, os.path.join(out, "rock_normal.png"), data=True)
fin = rbx.pbr_mat("Rock", cim, rim, None, nrm8)
rbx.give(rock, fin)
for h in highs:
    h.data.materials.clear()
    for m in keep[h.name]:
        h.data.materials.append(m)
log("textures composed")

flat = rbx.join([rbx.dup(f, f.name + "F", FL) for f in flats], "RockFlat")
with rbx.Edit(flat) as bm3:
    bmesh.ops.triangulate(bm3, faces=bm3.faces[:])
flat.data.shade_flat()
cl = flat.data.color_attributes.new("Col", "BYTE_COLOR", "CORNER")
for poly in flat.data.polygons:
    nz = poly.normal.z
    base = np.array([0.45, 0.43, 0.4]) * (0.82 + 0.3 * rnd.random())
    if nz > 0.6:
        base = base * 0.3 + np.array([0.32, 0.46, 0.18]) * 0.7
    elif nz < -0.2:
        base = base * 0.7
    for li in poly.loop_indices:
        cl.data[li].color_srgb = (*base, 1.0)
fm = bpy.data.materials.new("FlatRock")
try:
    fm.use_nodes = True
except Exception:
    pass
fnt = fm.node_tree
vc = fnt.nodes.new("ShaderNodeVertexColor")
vc.layer_name = "Col"
fnt.links.new(vc.outputs["Color"], fnt.nodes["Principled BSDF"].inputs["Base Color"])
fnt.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.9
rbx.give(flat, fm)
flat.hide_render = True

rep = rbx.audit(rock, T)
rep["high_tris"] = hi_tris
rep["flat_tris"] = len(flat.data.polygons)

shots = []
HI.hide_render = False
rock.hide_render = True
rbx.workbench(sc, "matcap", "basic_grey.exr")
rbx.camera(sc, highs, 30, 24)
shots.append(rbx.shot(sc, os.path.join(out, "r_high.png"), cell, cell))
HI.hide_render = True
rock.hide_render = False
wi = rbx.wire(rock, 0.006)
rock.color = (0.75, 0.75, 0.75, 1)
rbx.workbench(sc, "studio", color="OBJECT")
shots.append(rbx.shot(sc, os.path.join(out, "r_low_wire.png"), cell, cell))
bpy.data.objects.remove(wi, do_unlink=True)
clay = rbx.pbr_mat("Clay", None, None, None, nrm8)
clay.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.3, 0.3, 0.3, 1)
clay.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.6
rock.data.materials[0] = clay
rbx.studio(sc, [rock])
rbx.cycles(sc, 32)
sc.cycles.use_denoising = True
rbx.camera(sc, [rock], 30, 24)
shots.append(rbx.shot(sc, os.path.join(out, "r_low_normal.png"), cell, cell))
rock.data.materials[0] = fin
shots.append(rbx.shot(sc, os.path.join(out, "r_beauty.png"), cell, cell))
rbx.no_studio()
fl = rbx.box("Floor", (300, 300, 0.2), (0, 0, lo.z - 0.1))
rbx.give(fl, rbx.mat("Floor", rbx.srgb((88, 100, 70)), 0.9))
dm = rbx.dummy((-4.6, -5.2, 0), yaw=25)
fl.location.z = -0.1
rbx.world(sc, "forest.exr", 1.0, 120, sun=3.0)
rbx.look_from(sc, (-9.5, -20.0, 10.0), (0.0, 0, 2.6), 70)
shots.append(rbx.shot(sc, os.path.join(out, "r_player.png"), cell, cell))
rock.hide_render = True
flat.hide_render = False
shots.append(rbx.shot(sc, os.path.join(out, "r_flat.png"), cell, cell))
bpy.data.objects.remove(dm, do_unlink=True)
bpy.data.objects.remove(fl, do_unlink=True)
rock.hide_render = False
rbx.sheet(shots, 3, os.path.join(out, "sheet.png"))
rbx.uv_sheet(rock, os.path.join(out, "r_uv.png"), T, cim)
log("renders done")

rbx.fbx([rock], os.path.join(out, "rock.fbx"))
rbx.fbx([flat], os.path.join(out, "rock_flat.fbx"))
rbx.mesh_json(rock, os.path.join(out, "rock.json"))
for im in (cim, rim, nrm8):
    im.filepath = os.path.join(out, im.name + ".png")
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out, "rock.blend"))
rbx.report(os.path.join(out, "report.json"), rep)
log("done")
