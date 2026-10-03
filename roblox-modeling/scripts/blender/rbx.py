import bpy, bmesh, math, os, sys, json
import numpy as np
from mathutils import Vector, Matrix

R = math.radians
BL = os.path.dirname(bpy.app.binary_path)
SL = os.path.join(BL, "%d.%d" % bpy.app.version[:2], "datafiles", "studiolights")


def args(**d):
    if "--" in sys.argv:
        for a in sys.argv[sys.argv.index("--") + 1:]:
            k, v = a.split("=", 1)
            d[k] = v
    return d


def fresh():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.unit_settings.system = "NONE"
    sc.unit_settings.system_rotation = "DEGREES"
    return sc


def col(name):
    c = bpy.data.collections.get(name)
    if not c:
        c = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(c)
    return c


def put(name, bm, c=None, loc=(0, 0, 0)):
    me = bpy.data.meshes.new(name)
    bm.normal_update()
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    (c or bpy.context.scene.collection).objects.link(ob)
    ob.location = loc
    return ob


class Edit:
    def __init__(s, ob):
        s.ob = ob

    def __enter__(s):
        s.bm = bmesh.new()
        s.bm.from_mesh(s.ob.data)
        return s.bm

    def __exit__(s, *a):
        s.bm.normal_update()
        s.bm.to_mesh(s.ob.data)
        s.bm.free()
        s.ob.data.update()


def box(name, size, at=(0, 0, 0), c=None):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1)
    for v in bm.verts:
        v.co = Vector((v.co.x * size[0] + at[0], v.co.y * size[1] + at[1], v.co.z * size[2] + at[2]))
    return put(name, bm, c)


def cyl(name, r, h, n=16, at=(0, 0, 0), axis="Z", c=None, r2=None, caps=True):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=caps, cap_tris=False, segments=n, radius1=r, radius2=r if r2 is None else r2, depth=h)
    rot = {"Z": Matrix(), "X": Matrix.Rotation(R(90), 4, "Y"), "Y": Matrix.Rotation(R(90), 4, "X")}[axis]
    bmesh.ops.transform(bm, matrix=Matrix.Translation(at) @ rot, verts=bm.verts)
    return put(name, bm, c)


def lathe(name, prof, n=24, c=None, axis="Z", at=(0, 0, 0)):
    bm = bmesh.new()
    vs = [bm.verts.new((r, 0, z)) for r, z in prof]
    es = [bm.edges.new((vs[i], vs[i + 1])) for i in range(len(vs) - 1)]
    bmesh.ops.spin(bm, geom=vs + es, cent=(0, 0, 0), axis=(0, 0, 1), angle=2 * math.pi, steps=n, use_merge=True)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    rot = {"Z": Matrix(), "X": Matrix.Rotation(R(90), 4, "Y"), "Y": Matrix.Rotation(R(-90), 4, "X")}[axis]
    bmesh.ops.transform(bm, matrix=Matrix.Translation(at) @ rot, verts=bm.verts)
    return put(name, bm, c)


def frames(path, up=None, ups=None):
    p = [Vector(x) for x in path]
    t = []
    for i in range(len(p)):
        a = p[max(i - 1, 0)]
        b = p[min(i + 1, len(p) - 1)]
        t.append((b - a).normalized())
    u = Vector(up) if up else (Vector((0, 0, 1)) if abs(t[0].z) < 0.9 else Vector((1, 0, 0)))
    n = (u - t[0] * u.dot(t[0])).normalized()
    out = []
    for i in range(len(p)):
        if ups:
            q = Vector(ups[i])
            n = (q - t[i] * q.dot(t[i])).normalized()
        elif i:
            n = (n - t[i] * n.dot(t[i])).normalized()
        out.append((p[i], t[i], n, t[i].cross(n)))
    return out


def loft(name, rings, c=None, cap0=True, tip=None, cap1=False):
    bm = bmesh.new()
    vr = [[bm.verts.new(p) for p in ring] for ring in rings]
    m = len(rings[0])
    for a, b in zip(vr, vr[1:]):
        for j in range(m):
            bm.faces.new((a[j], a[(j + 1) % m], b[(j + 1) % m], b[j]))
    if cap0:
        bm.faces.new(list(reversed(vr[0])))
    if tip is not None:
        t = bm.verts.new(tip)
        for j in range(m):
            bm.faces.new((vr[-1][j], vr[-1][(j + 1) % m], t))
    elif cap1:
        bm.faces.new(vr[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return put(name, bm, c)


def loft_open(name, rings, c=None):
    bm = bmesh.new()
    vr = [[bm.verts.new(p) for p in ring] for ring in rings]
    m = len(rings[0])
    for a, b in zip(vr, vr[1:]):
        for j in range(m - 1):
            bm.faces.new((a[j], a[j + 1], b[j + 1], b[j]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return put(name, bm, c)


def ring_sample(pts, n, closed=True):
    p = [Vector((x, y)) for x, y in pts]
    if closed:
        p = p + [p[0]]
    acc = [0.0]
    for a, b in zip(p, p[1:]):
        acc.append(acc[-1] + (b - a).length)
    L = acc[-1]
    out = []
    cnt = n if closed else n - 1
    k = 0
    for i in range(n):
        s = L * i / cnt
        while k < len(acc) - 2 and acc[k + 1] < s:
            k += 1
        seg = acc[k + 1] - acc[k] or 1.0
        t = (s - acc[k]) / seg
        q = p[k].lerp(p[k + 1], t)
        out.append((q.x, q.y))
    return out


def rr(w, d, r, n=40, start=0.0):
    pts = rect(w, d, min(r, w / 2 - 1e-3, d / 2 - 1e-3), 6)
    s = ring_sample(pts, 400)
    angs = [math.atan2(y, x) for x, y in s]
    i0 = min(range(len(s)), key=lambda i: abs(((angs[i] - start + math.pi) % (2 * math.pi)) - math.pi))
    s = s[i0:] + s[:i0]
    return ring_sample(s, n)


def sweep(name, path, prof, c=None, loop=False, shut=True, scale=None, twist=None, up=None, caps=True, uvs="world", ups=None):
    fr = frames(path, up, ups)
    bm = bmesh.new()
    uvl = bm.loops.layers.uv.new("UVMap")
    rings = []
    for i, (p, t, n, b) in enumerate(fr):
        s = scale(i / max(len(fr) - 1, 1)) if scale else 1.0
        w = R(twist(i / max(len(fr) - 1, 1))) if twist else 0.0
        cw, sw = math.cos(w), math.sin(w)
        ring = []
        for x, y in prof:
            xx, yy = (x * cw - y * sw) * s, (x * sw + y * cw) * s
            ring.append(bm.verts.new(p + n * yy + b * xx))
        rings.append(ring)
    seg = list(range(len(prof))) if not shut else list(range(len(prof)))
    per = [0.0]
    for i in range(1, len(prof) + (1 if shut else 0)):
        a, z = Vector(prof[(i - 1) % len(prof)]), Vector(prof[i % len(prof)])
        per.append(per[-1] + (z - a).length)
    plen = [0.0]
    for i in range(1, len(fr)):
        plen.append(plen[-1] + (fr[i][0] - fr[i - 1][0]).length)
    L = (plen[-1] or 1.0) if uvs == "unit" else 1.0
    P = (per[-1] or 1.0) if uvs == "unit" else 1.0
    m = len(prof)
    cols = m if shut else m - 1
    nr = len(rings)
    for i in range(nr if loop else nr - 1):
        r0, r1 = rings[i], rings[(i + 1) % nr]
        v0, v1 = plen[i] / L, (plen[i + 1] / L if i + 1 < nr else (plen[-1] + (fr[0][0] - fr[-1][0]).length) / L)
        for j in range(cols):
            j1 = (j + 1) % m
            f = bm.faces.new((r0[j], r0[j1], r1[j1], r1[j]))
            us = (per[j] / P, per[j + 1] / P)
            for lp, uv in zip(f.loops, ((us[0], v0), (us[1], v0), (us[1], v1), (us[0], v1))):
                lp[uvl].uv = uv
    if caps and shut and not loop:
        bm.faces.new(list(reversed(rings[0])))
        bm.faces.new(rings[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return put(name, bm, c)


def circle(r, n, start=0.0):
    return [(r * math.cos(start + 2 * math.pi * i / n), r * math.sin(start + 2 * math.pi * i / n)) for i in range(n)]


def rect(w, h, bev=0.0, seg=2):
    if bev <= 0:
        return [(-w / 2, -h / 2), (w / 2, -h / 2), (w / 2, h / 2), (-w / 2, h / 2)]
    pts = []
    for cx, cy, a0 in ((w / 2 - bev, -h / 2 + bev, -90), (w / 2 - bev, h / 2 - bev, 0), (-w / 2 + bev, h / 2 - bev, 90), (-w / 2 + bev, -h / 2 + bev, 180)):
        for k in range(seg + 1):
            a = R(a0 + 90 * k / seg)
            pts.append((cx + bev * math.cos(a), cy + bev * math.sin(a)))
    return pts


def extrude_x(name, pts_yz, x0, x1, c=None):
    bm = bmesh.new()
    a = [bm.verts.new((x0, y, z)) for y, z in pts_yz]
    b = [bm.verts.new((x1, y, z)) for y, z in pts_yz]
    m = len(pts_yz)
    for j in range(m):
        bm.faces.new((a[j], a[(j + 1) % m], b[(j + 1) % m], b[j]))
    bm.faces.new(list(reversed(a)))
    bm.faces.new(b)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return put(name, bm, c)


def leaf(L, w, bulge=0.05, n=10, tip=0.35):
    side = []
    for k in range(n + 1):
        t = k / n
        if t < 1 - tip:
            h = w
        else:
            u = (t - (1 - tip)) / tip
            h = (w + bulge * math.sin(math.pi * min(u * 1.6, 1.0))) * (1 - u ** 3)
        side.append((t * L, h))
    return [(x, -y) for x, y in side] + [(x, y) for x, y in reversed(side[:-1])][:-1] + [(0.0, w)]


def trefoil(L, w, R_, n=48):
    cx = L - R_ * 0.9
    arc = []
    for k in range(n + 1):
        t = -math.pi + 2 * math.pi * k / n
        r = R_ * (0.68 + 0.32 * math.cos(3 * t))
        x, y = cx + r * math.cos(t), r * math.sin(t)
        if not (x < cx and abs(y) < w):
            arc.append((x, y))
    return [(0.0, -w), (arc[0][0], -w)] + arc + [(arc[-1][0], w), (0.0, w)]


def attr_build(name):
    def b(nt):
        at = nt.nodes.new("ShaderNodeAttribute")
        at.attribute_type = "GEOMETRY"
        at.attribute_name = name
        return at.outputs["Fac"]
    return b


def star(n, r1, r2, start=math.pi / 2):
    return [((r1 if k % 2 == 0 else r2) * math.cos(start + math.pi * k / n), (r1 if k % 2 == 0 else r2) * math.sin(start + math.pi * k / n)) for k in range(2 * n)]


def orient(at, z_to, x_hint=None):
    z = Vector(z_to).normalized()
    x = Vector(x_hint) if x_hint else (Vector((1, 0, 0)) if abs(z.x) < 0.9 else Vector((0, 1, 0)))
    x = (x - z * x.dot(z)).normalized()
    y = z.cross(x)
    m = Matrix((x, y, z)).transposed().to_4x4()
    m.translation = Vector(at)
    return m


def place(ob, m):
    ob.data.transform(m)
    ob.data.update()
    return ob


def ring_path(r, n, center=(0, 0, 0), plane="XY"):
    pts = []
    for k in range(n):
        a = 2 * math.pi * k / n
        u, v = r * math.cos(a), r * math.sin(a)
        x, y, z = {"XY": (u, v, 0), "YZ": (0, u, v), "XZ": (u, 0, v)}[plane]
        pts.append((center[0] + x, center[1] + y, center[2] + z))
    return pts


def torus(name, R_, r, n1=24, n2=10, center=(0, 0, 0), plane="XY", c=None):
    return sweep(name, ring_path(R_, n1, center, plane), circle(r, n2), c, loop=True, caps=False)


def dome(name, r, n=12, rings=4, c=None):
    prof = [(r * math.cos(math.pi / 2 * k / rings), r * math.sin(math.pi / 2 * k / rings)) for k in range(rings + 1)]
    return lathe(name, [(0.0, 0.0)] + prof, n, c)


def chamfer_rect(w, d, c):
    hw, hd = w / 2, d / 2
    return [(-hw + c, -hd), (hw - c, -hd), (hw, -hd + c), (hw, hd - c), (hw - c, hd), (-hw + c, hd), (-hw, hd - c), (-hw, -hd + c)]


def prism(name, pts, z0, z1, c=None):
    bm = bmesh.new()
    vs = [bm.verts.new((x, y, z0)) for x, y in pts]
    f = bm.faces.new(vs)
    r = bmesh.ops.extrude_face_region(bm, geom=[f])
    top = [e for e in r["geom"] if isinstance(e, bmesh.types.BMVert)]
    bmesh.ops.translate(bm, vec=(0, 0, z1 - z0), verts=top)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return put(name, bm, c)


def offset2d(pts, d, closed=False):
    p = [Vector((x, y)) for x, y in pts]
    n = len(p)
    segs = range(n if closed else n - 1)
    nrm = []
    for i in segs:
        t = (p[(i + 1) % n] - p[i]).normalized()
        nrm.append(Vector((t.y, -t.x)))
    out = []
    for i in range(n):
        if not closed and i == 0:
            out.append(p[0] + nrm[0] * d)
            continue
        if not closed and i == n - 1:
            out.append(p[-1] + nrm[-1] * d)
            continue
        a, b = nrm[(i - 1) % len(nrm)], nrm[i % len(nrm)]
        m = (a + b).normalized()
        out.append(p[i] + m * (d / max(m.dot(a), 0.2)))
    return [(v.x, v.y) for v in out]


def fillet(pts, r, n=4):
    p = [Vector(x) for x in pts]
    out = [p[0]]
    for i in range(1, len(p) - 1):
        a, b, c = p[i - 1], p[i], p[i + 1]
        u, v = (a - b).normalized(), (c - b).normalized()
        ang = u.angle(v)
        if ang > math.pi - 1e-3:
            out.append(b)
            continue
        t = r / math.tan(ang / 2)
        t = min(t, (a - b).length * 0.5, (c - b).length * 0.5)
        rr = t * math.tan(ang / 2)
        s, e = b + u * t, b + v * t
        ctr = b + (u + v).normalized() * (rr / math.sin(ang / 2))
        a0, a1 = s - ctr, e - ctr
        ax = a0.cross(a1).normalized()
        tot = a0.angle(a1)
        for k in range(n + 1):
            q = Matrix.Rotation(tot * k / n, 3, ax) @ a0
            out.append(ctr + q)
    out.append(p[-1])
    return [tuple(x) for x in out]


def resample(path, step):
    p = [Vector(x) for x in path]
    out = [p[0]]
    for a, b in zip(p, p[1:]):
        n = max(1, int(math.ceil((b - a).length / step)))
        for k in range(1, n + 1):
            out.append(a.lerp(b, k / n))
    return [tuple(x) for x in out]


def lowvis(obs, on=False):
    for o in obs:
        for k in ("visible_diffuse", "visible_glossy", "visible_transmission", "visible_volume_scatter", "visible_shadow"):
            setattr(o, k, on)


def mod(ob, kind, **kw):
    m = ob.modifiers.new(kind.title(), kind)
    for k, v in kw.items():
        setattr(m, k, v)
    return m


def bevel(ob, w, seg=3, ang=30, prof=0.5, limit="ANGLE", harden=True, strength="FSTR_AFFECTED", miter="MITER_ARC", clamp=True):
    return mod(ob, "BEVEL", width=w, segments=seg, limit_method=limit, angle_limit=R(ang), profile=prof,
               harden_normals=harden, face_strength_mode=strength, miter_outer=miter, use_clamp_overlap=clamp)


def wn(ob, weight=50, sharp=True, infl=True):
    return mod(ob, "WEIGHTED_NORMAL", mode="FACE_AREA", weight=weight, keep_sharp=sharp, use_face_influence=infl)


def tri(ob):
    return mod(ob, "TRIANGULATE", quad_method="BEAUTY", ngon_method="BEAUTY", keep_custom_normals=True)


def cut(ob, cutter, op="DIFFERENCE", solver="MANIFOLD"):
    cutter.display_type = "WIRE"
    cutter.hide_render = True
    return mod(ob, "BOOLEAN", object=cutter, operation=op, solver=solver)


def smooth(ob, ang=None):
    ob.data.shade_smooth()
    if ang is not None:
        ob.data.set_sharp_from_angle(angle=R(ang))


def apply(ob):
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg), preserve_all_data_layers=True, depsgraph=dg)
    old = ob.data
    ob.modifiers.clear()
    ob.data = me
    me.name = old.name
    if old.users == 0:
        bpy.data.meshes.remove(old)
    return ob


def freeze(ob):
    ob.data.transform(ob.matrix_basis)
    ob.matrix_basis = Matrix()
    return ob


def pivot(ob, p):
    p = Vector(p)
    ob.data.transform(Matrix.Translation(-p))
    ob.location = ob.location + p
    return ob


def only(obs):
    vl = bpy.context.view_layer
    vl.update()
    for o in bpy.context.scene.objects:
        if o:
            o.select_set(False)
    for o in obs:
        o.select_set(True)
    vl.objects.active = obs[0]


def tidy(ob):
    me = ob.data
    idx = np.zeros(len(me.polygons), np.int32)
    me.polygons.foreach_get("material_index", idx)
    used = [i for i, m in enumerate(me.materials) if m and (idx == i).any()]
    mats = [me.materials[i] for i in used]
    remap = np.zeros(max(len(me.materials), 1), np.int32)
    for n, i in enumerate(used):
        remap[i] = n
    me.materials.clear()
    for m in mats:
        me.materials.append(m)
    if len(idx):
        me.polygons.foreach_set("material_index", remap[np.clip(idx, 0, len(remap) - 1)])
    me.update()
    return ob


def join(obs, name=None):
    obs = [o for o in obs if o]
    only(obs)
    with bpy.context.temp_override(active_object=obs[0], object=obs[0], selected_objects=obs, selected_editable_objects=obs):
        bpy.ops.object.join()
    if name:
        obs[0].name = name
        obs[0].data.name = name
    return tidy(obs[0])


def dup(ob, name, c=None, keep_mods=True):
    d = ob.copy()
    d.data = ob.data.copy()
    d.name = name
    d.data.name = name
    if not keep_mods:
        d.modifiers.clear()
    (c or ob.users_collection[0]).objects.link(d)
    return d


def edit_mode(ob, fn):
    only([ob])
    try:
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        r = fn()
    except RuntimeError as e:
        print("EDITFAIL %s type=%s mode=%s ctxobj=%s visible=%s faces=%d hide=%s err=%s" % (
            ob.name, ob.type, bpy.context.mode, bpy.context.object.name if bpy.context.object else None,
            ob.visible_get(), len(ob.data.polygons), ob.hide_get(), str(e).splitlines()[0]))
        raise
    finally:
        if bpy.context.object and bpy.context.object.mode != "OBJECT":
            bpy.ops.object.mode_set(mode="OBJECT")
    return r


def chart_seams(ob, tol=50, clear=True):
    with Edit(ob) as bm:
        if clear:
            for e in bm.edges:
                e.seam = False
        chart = {}
        ct = math.cos(R(tol))
        cid = 0
        for f in sorted(bm.faces, key=lambda f: -f.calc_area()):
            if f in chart:
                continue
            n0 = f.normal.copy()
            chart[f] = cid
            stack = [f]
            while stack:
                g = stack.pop()
                for e in g.edges:
                    for h in e.link_faces:
                        if h not in chart and h.normal.dot(n0) > ct:
                            chart[h] = cid
                            stack.append(h)
            cid += 1
        for e in bm.edges:
            fs = e.link_faces
            if len(fs) != 2 or chart[fs[0]] != chart[fs[1]]:
                e.seam = True
    return cid


def uv_unfold(ob, tol=50, method="ANGLE_BASED"):
    chart_seams(ob, tol)
    unwrap(ob, method)
    return ob


def seams(ob, ang=None, pick=None, clear=True):
    with Edit(ob) as bm:
        for e in bm.edges:
            if clear:
                e.seam = False
            if ang is not None and len(e.link_faces) == 2 and e.calc_face_angle(0) > R(ang):
                e.seam = True
            if pick and pick(e):
                e.seam = True
            if e.is_boundary:
                e.seam = True


def unwrap(ob, method="ANGLE_BASED"):
    edit_mode(ob, lambda: bpy.ops.uv.unwrap(method=method, fill_holes=True, margin=0.001))


def smart_uv(ob, ang=66, margin=0.002):
    edit_mode(ob, lambda: bpy.ops.uv.smart_project(angle_limit=R(ang), island_margin=margin, area_weight=0.0, correct_aspect=True, scale_to_bounds=False))


def pack(ob, px=8, size=1024, rotate=True, shape="CONCAVE", even=True):
    def go():
        if even:
            bpy.ops.uv.average_islands_scale()
        bpy.ops.uv.pack_islands(rotate=rotate, scale=True, margin_method="FRACTION", margin=px / size, shape_method=shape)
    edit_mode(ob, go)


def visibility(ob, rays=24, dist=200.0, ground=None):
    from mathutils.bvhtree import BVHTree
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    bm.faces.ensure_lookup_table()
    tree = BVHTree.FromBMesh(bm)
    if ground is True:
        ground = min(v.co.z for v in bm.verts)
    dirs = []
    for i in range(rays):
        z = (i + 0.5) / rays
        r = math.sqrt(max(0.0, 1 - z * z))
        a = i * 2.399963
        dirs.append(Vector((r * math.cos(a), r * math.sin(a), z)))
    out = {}
    for f in bm.faces:
        n = f.normal
        c = f.calc_center_median() + n * 1e-4
        q = n.to_track_quat("Z", "Y")
        free = 0
        for d in dirs:
            w = q @ d
            if ground is not None and w.z < -1e-4 and (ground - c.z) / w.z < dist:
                continue
            if tree.ray_cast(c, w, dist)[0] is None:
                free += 1
        out[f.index] = free / rays
    bm.free()
    return out


def same_topology(a, b):
    if len(a.data.loops) != len(b.data.loops) or len(a.data.polygons) != len(b.data.polygons):
        return False
    va = np.empty(len(a.data.loops), np.int32)
    vb = np.empty(len(b.data.loops), np.int32)
    a.data.loops.foreach_get("vertex_index", va)
    b.data.loops.foreach_get("vertex_index", vb)
    return bool((va == vb).all())


def stack_uvs(master, copy):
    if not same_topology(master, copy):
        return False
    if not copy.data.uv_layers:
        copy.data.uv_layers.new(name=master.data.uv_layers.active.name)
    a = master.data.uv_layers.active.data
    b = copy.data.uv_layers.active.data
    buf = np.empty(len(a) * 2, np.float32)
    a.foreach_get("uv", buf)
    b.foreach_set("uv", buf)
    return True


def shift_uv(ob, du, dv=0.0):
    uv = ob.data.uv_layers.active.data
    buf = np.empty(len(uv) * 2, np.float32)
    uv.foreach_get("uv", buf)
    buf[0::2] += du
    buf[1::2] += dv
    uv.foreach_set("uv", buf)
    return ob


def tag_faces(ob, name, value):
    me = ob.data
    at = me.attributes.get(name) or me.attributes.new(name, "INT", "FACE")
    at.data.foreach_set("value", np.full(len(me.polygons), value, np.int32))


def shift_tagged(ob, name, du):
    me = ob.data
    at = me.attributes.get(name)
    if not at:
        return 0
    flags = np.empty(len(me.polygons), np.int32)
    at.data.foreach_get("value", flags)
    uv = me.uv_layers.active.data
    buf = np.empty(len(uv) * 2, np.float32)
    uv.foreach_get("uv", buf)
    buf = buf.reshape(-1, 2)
    loops = np.empty(len(me.polygons), np.int32)
    me.polygons.foreach_get("loop_start", loops)
    tot = np.empty(len(me.polygons), np.int32)
    me.polygons.foreach_get("loop_total", tot)
    for s, t, f in zip(loops, tot, flags):
        if f:
            buf[s:s + t, 0] += du
    uv.foreach_set("uv", buf.ravel())
    me.update()
    return int(flags.sum())


def visibility_parts(parts, rays=24, dist=200.0, ground=None):
    from mathutils.bvhtree import BVHTree
    big = bmesh.new()
    spans = []
    for p in parts:
        me = p.data.copy()
        me.transform(p.matrix_world)
        n0 = len(big.faces)
        big.from_mesh(me)
        bpy.data.meshes.remove(me)
        spans.append((p, n0, len(big.faces) - n0))
    big.faces.ensure_lookup_table()
    tree = BVHTree.FromBMesh(big)
    if ground is True:
        ground = min(v.co.z for v in big.verts)
    dirs = []
    for i in range(rays):
        z = (i + 0.5) / rays
        r = math.sqrt(max(0.0, 1 - z * z))
        a = i * 2.399963
        dirs.append(Vector((r * math.cos(a), r * math.sin(a), z)))
    out = {}
    for p, n0, cnt in spans:
        vis = []
        for k in range(cnt):
            f = big.faces[n0 + k]
            n = f.normal
            c = f.calc_center_median() + n * 1e-4
            q = n.to_track_quat("Z", "Y")
            free = 0
            for d in dirs:
                w = q @ d
                if ground is not None and w.z < -1e-4 and (ground - c.z) / w.z < dist:
                    continue
                if tree.ray_cast(c, w, dist)[0] is None:
                    free += 1
            vis.append(free / rays)
        out[p.name] = vis
    big.free()
    return out


def multi_edit(obs, fn):
    only(obs)
    with bpy.context.temp_override(active_object=obs[0], object=obs[0], selected_objects=obs, selected_editable_objects=obs):
        bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    r = fn()
    bpy.ops.object.mode_set(mode="OBJECT")
    return r


def pack_parts(parts, px=8, size=1024, low=0.2, thresh=0.03, rot="AXIS_ALIGNED", ground=None, boost=None):
    from bpy_extras import bmesh_utils
    uniq = [p for p in parts if not p.get("copy_of")]
    vis = visibility_parts(parts, ground=ground)
    multi_edit(uniq, lambda: bpy.ops.uv.average_islands_scale())
    hidden = 0
    for p in uniq:
        if p.get("grp"):
            continue
        v = vis[p.name]
        with Edit(p) as bm:
            bm.faces.ensure_lookup_table()
            uvl = bm.loops.layers.uv.active
            for isl in bmesh_utils.bmesh_linked_uv_islands(bm, uvl):
                ar = sum(f.calc_area() for f in isl) or 1.0
                k = None
                if sum(v[f.index] * f.calc_area() for f in isl) / ar < thresh:
                    hidden += 1
                    k = low
                elif boost:
                    for name, test, factor in boost:
                        if p.name == name and any(test(f) for f in isl):
                            k = factor
                if k:
                    pts = [l[uvl].uv.copy() for f in isl for l in f.loops]
                    c = sum(pts, Vector((0, 0))) / len(pts)
                    for f in isl:
                        for l in f.loops:
                            l[uvl].uv = c + (l[uvl].uv - c) * k
    multi_edit(uniq, lambda: bpy.ops.uv.pack_islands(rotate=True, rotate_method=rot, scale=True, merge_overlap=False,
                                                     margin_method="FRACTION", margin=px / size, shape_method="CONCAVE"))
    for p in parts:
        if p.get("copy_of"):
            stack_uvs(bpy.data.objects[p["copy_of"]], p)
    return hidden


def pack_weighted(ob, px=8, size=1024, low=0.2, thresh=0.03, rot="AXIS_ALIGNED", ground=None):
    from bpy_extras import bmesh_utils
    vis = visibility(ob, ground=ground)
    edit_mode(ob, lambda: bpy.ops.uv.average_islands_scale())
    hidden = 0
    with Edit(ob) as bm:
        bm.faces.ensure_lookup_table()
        uvl = bm.loops.layers.uv.active
        stk = bm.faces.layers.int.get("stack")
        for isl in bmesh_utils.bmesh_linked_uv_islands(bm, uvl):
            if stk and any(f[stk] for f in isl):
                continue
            ar = sum(f.calc_area() for f in isl) or 1.0
            v = sum(vis[f.index] * f.calc_area() for f in isl) / ar
            if v < thresh:
                hidden += 1
                pts = [l[uvl].uv.copy() for f in isl for l in f.loops]
                c = sum(pts, Vector((0, 0))) / len(pts)
                for f in isl:
                    for l in f.loops:
                        l[uvl].uv = c + (l[uvl].uv - c) * low
    edit_mode(ob, lambda: bpy.ops.uv.pack_islands(rotate=True, rotate_method=rot, scale=True, merge_overlap=True,
                                                  margin_method="FRACTION", margin=px / size, shape_method="CONCAVE"))
    return hidden


def straighten(ob, pick):
    with Edit(ob) as bm:
        for f in bm.faces:
            f.select = pick(f)


def mat(name, color=(0.8, 0.8, 0.8), rough=0.5, metal=0.0):
    m = bpy.data.materials.new(name)
    try:
        m.use_nodes = True
    except Exception:
        pass
    b = m.node_tree.nodes.get("Principled BSDF")
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    m.diffuse_color = (*color, 1)
    m.roughness = rough
    m.metallic = metal
    return m


def give(ob, m):
    ob.data.materials.clear()
    ob.data.materials.append(m)
    return ob


def srgb(c):
    c = np.asarray(c, float) / 255.0
    return tuple(np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4))


def image(name, size, data=False, color=(0.5, 0.5, 1.0, 1.0)):
    im = bpy.data.images.get(name) or bpy.data.images.new(name, size, size, alpha=False, float_buffer=False)
    im.colorspace_settings.name = "Non-Color" if data else "sRGB"
    im.generated_color = color
    return im


def target(ob, im):
    for s in ob.material_slots:
        nt = s.material.node_tree
        n = nt.nodes.get("BakeTarget") or nt.nodes.new("ShaderNodeTexImage")
        n.name = "BakeTarget"
        n.image = im
        n.location = (-700, 600)
        nt.nodes.active = n


def cycles(sc, samples=16):
    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = samples
    sc.cycles.use_denoising = False
    return sc


def bake(low, kind, im, highs=(), samples=16, extrude=0.02, ray=0.0, margin=16, cage=None, clear=True):
    sc = cycles(bpy.context.scene, samples)
    target(low, im)
    only(list(highs) + [low])
    bpy.context.view_layer.objects.active = low
    kw = dict(type=kind, margin=margin, margin_type="EXTEND", use_clear=clear, target="IMAGE_TEXTURES")
    if highs:
        kw.update(use_selected_to_active=True, cage_extrusion=extrude, max_ray_distance=ray)
        if cage:
            kw.update(use_cage=True, cage_object=cage.name)
    if kind == "NORMAL":
        kw.update(normal_space="TANGENT", normal_r="POS_X", normal_g="POS_Y", normal_b="POS_Z")
    if kind == "DIFFUSE":
        kw.update(pass_filter={"COLOR"})
    bpy.ops.object.bake(**kw)
    return im


def save(im, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.filepath_raw = path
    im.file_format = "PNG"
    im.save()
    return path


def px(im):
    w, h = im.size
    a = np.empty(w * h * 4, np.float32)
    im.pixels.foreach_get(a)
    return a.reshape(h, w, 4)


def unpx(name, a, path=None, data=False):
    h, w = a.shape[:2]
    old = bpy.data.images.get(name)
    if old:
        bpy.data.images.remove(old)
    im = bpy.data.images.new(name, w, h, alpha=True)
    im.colorspace_settings.name = "Non-Color" if data else "sRGB"
    im.pixels.foreach_set(np.ascontiguousarray(a, np.float32).ravel())
    if path:
        save(im, path)
    return im


def coverage(ob, size):
    obs = ob if isinstance(ob, (list, tuple)) else [ob]
    im = fimage("coverage", size)
    for i, o in enumerate(obs):
        mask_bake(o, lambda nt: (1.0, 1.0, 1.0), im, samples=1, margin=0, clear=(i == 0))
    return px(im)[..., 0] > 0.5


def dilate(a, mask, iters=24):
    a = a.copy()
    m = mask.copy()
    for _ in range(iters):
        if m.all():
            break
        acc = np.zeros_like(a)
        cnt = np.zeros(m.shape, np.float32)
        for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)):
            sm = np.roll(np.roll(m, dy, 0), dx, 1)
            sa = np.roll(np.roll(a, dy, 0), dx, 1)
            acc += sa * sm[..., None]
            cnt += sm
        grow = (~m) & (cnt > 0)
        a[grow] = acc[grow] / cnt[grow][..., None]
        m = m | grow
    return a


def curvature(nrm, k=1.5):
    a = px(nrm)[..., :3] * 2 - 1
    dx = np.zeros(a.shape[:2], np.float32)
    dy = np.zeros(a.shape[:2], np.float32)
    dx[:, 1:-1] = (a[:, 2:, 0] - a[:, :-2, 0]) * 0.5
    dy[1:-1, :] = (a[2:, :, 1] - a[:-2, :, 1]) * 0.5
    c = np.clip(0.5 + (dx + dy) * k * a.shape[1] / 256.0, 0, 1)
    return c


def emit_mat(name, build):
    m = bpy.data.materials.new(name)
    try:
        m.use_nodes = True
    except Exception:
        pass
    nt = m.node_tree
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    em = nt.nodes.new("ShaderNodeEmission")
    nt.links.new(em.outputs[0], out.inputs["Surface"])
    sock = build(nt)
    if isinstance(sock, (tuple, list)):
        em.inputs["Color"].default_value = (*sock[:3], 1)
    else:
        nt.links.new(sock, em.inputs["Color"])
    return m


def node(nt, kind, **kw):
    n = nt.nodes.new(kind)
    for k, v in kw.items():
        if k in n.inputs:
            n.inputs[k].default_value = v
        else:
            setattr(n, k, v)
    return n


def swap_bake(ob, mats, kind, im, samples, margin, clear=True):
    keep = list(ob.data.materials)
    for i, m in enumerate(mats):
        ob.data.materials[i] = m
    bake(ob, kind, im, samples=samples, margin=margin, clear=clear)
    for i, k in enumerate(keep):
        ob.data.materials[i] = k
    for m in set(mats):
        bpy.data.materials.remove(m)
    return im


def mask_bake(ob, build, im, samples=8, margin=16, clear=True):
    m = emit_mat("MaskBake", build)
    return swap_bake(ob, [m] * len(ob.data.materials), "EMIT", im, samples, margin, clear)


def bake_ids(ob, im, margin=16):
    mats = [emit_mat("ID%d" % i, lambda nt, c=ID_COLORS[i % len(ID_COLORS)]: c) for i in range(len(ob.data.materials))]
    return swap_bake(ob, mats, "EMIT", im, 1, margin)


ID_COLORS = [(1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 0), (1, 0, 1), (0, 1, 1), (1, 1, 1), (0.5, 0, 0), (0, 0.5, 0), (0, 0, 0.5)]


def ids_of(idmap):
    a = idmap[..., :3]
    pal = np.array(ID_COLORS, np.float32)
    d = ((a[:, :, None, :] - pal[None, None, :, :]) ** 2).sum(-1)
    return d.argmin(-1)


def edge_build(radius=0.04, gain=6.0):
    def b(nt):
        bev = node(nt, "ShaderNodeBevel", samples=16)
        bev.inputs["Radius"].default_value = radius
        geo = node(nt, "ShaderNodeNewGeometry")
        dot = node(nt, "ShaderNodeVectorMath", operation="DOT_PRODUCT")
        nt.links.new(bev.outputs["Normal"], dot.inputs[0])
        nt.links.new(geo.outputs["Normal"], dot.inputs[1])
        inv = node(nt, "ShaderNodeMath", operation="SUBTRACT")
        inv.inputs[0].default_value = 1.0
        nt.links.new(dot.outputs["Value"], inv.inputs[1])
        mul = node(nt, "ShaderNodeMath", operation="MULTIPLY", use_clamp=True)
        mul.inputs[1].default_value = gain
        nt.links.new(inv.outputs[0], mul.inputs[0])
        return mul.outputs[0]
    return b


def point_build(gain=4.0):
    def b(nt):
        geo = node(nt, "ShaderNodeNewGeometry")
        mp = node(nt, "ShaderNodeMapRange", clamp=True)
        mp.inputs["From Min"].default_value = 0.5
        mp.inputs["From Max"].default_value = 0.5 + 0.5 / gain
        nt.links.new(geo.outputs["Pointiness"], mp.inputs["Value"])
        return mp.outputs["Result"]
    return b


def pos_build(lo, hi):
    def b(nt):
        geo = node(nt, "ShaderNodeNewGeometry")
        sub = node(nt, "ShaderNodeVectorMath", operation="SUBTRACT")
        sub.inputs[1].default_value = tuple(lo)
        div = node(nt, "ShaderNodeVectorMath", operation="DIVIDE")
        div.inputs[1].default_value = tuple(max(x, 1e-4) for x in (hi - lo))
        nt.links.new(geo.outputs["Position"], sub.inputs[0])
        nt.links.new(sub.outputs[0], div.inputs[0])
        return div.outputs[0]
    return b


def nrm_build():
    def b(nt):
        geo = node(nt, "ShaderNodeNewGeometry")
        mad = node(nt, "ShaderNodeVectorMath", operation="MULTIPLY_ADD")
        mad.inputs[1].default_value = (0.5, 0.5, 0.5)
        mad.inputs[2].default_value = (0.5, 0.5, 0.5)
        nt.links.new(geo.outputs["Normal"], mad.inputs[0])
        return mad.outputs[0]
    return b


def fimage(name, size):
    im = bpy.data.images.get(name)
    if im:
        bpy.data.images.remove(im)
    im = bpy.data.images.new(name, size, size, alpha=True, float_buffer=True)
    im.colorspace_settings.name = "Non-Color"
    return im


def _hash(ix, iy, iz, seed):
    h = (ix * 73856093) ^ (iy * 19349663) ^ (iz * 83492791) ^ (seed * 2654435761)
    h = (h ^ (h >> 13)) * 1274126177
    return ((h ^ (h >> 16)) & 0xFFFF).astype(np.float32) / 65535.0


def vnoise(p, seed=0):
    f = np.floor(p)
    t = p - f
    t = t * t * (3 - 2 * t)
    i = f.astype(np.int64)
    out = 0
    for dx in (0, 1):
        for dy in (0, 1):
            for dz in (0, 1):
                w = (t[..., 0] if dx else 1 - t[..., 0]) * (t[..., 1] if dy else 1 - t[..., 1]) * (t[..., 2] if dz else 1 - t[..., 2])
                out = out + w * _hash(i[..., 0] + dx, i[..., 1] + dy, i[..., 2] + dz, seed)
    return out


def fbm(p, freq=1.0, oct=4, seed=0, gain=0.5):
    tot, amp, norm = 0.0, 1.0, 0.0
    for k in range(oct):
        tot = tot + vnoise(p * freq * (2 ** k), seed + k) * amp
        norm += amp
        amp *= gain
    return tot / norm


def voronoi(p, seed=0):
    c = np.floor(p).astype(np.int64)
    f1 = np.full(p.shape[:-1], 1e9, np.float32)
    f2 = np.full(p.shape[:-1], 1e9, np.float32)
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            for dz in (-1, 0, 1):
                cc = c + np.array([dx, dy, dz], np.int64)
                j = np.stack([_hash(cc[..., 0], cc[..., 1], cc[..., 2], seed * 3 + k) for k in range(3)], -1)
                d = ((p - (cc + j)) ** 2).sum(-1)
                f2 = np.where(d < f1, f1, np.minimum(f2, d))
                f1 = np.minimum(f1, d)
    return np.sqrt(f1), np.sqrt(f2)


def vdisp(ob, fn):
    me = ob.data
    n = len(me.vertices)
    co = np.empty(n * 3, np.float32)
    nr = np.empty(n * 3, np.float32)
    me.vertices.foreach_get("co", co)
    me.vertices.foreach_get("normal", nr)
    co = co.reshape(-1, 3)
    nr = nr.reshape(-1, 3)
    d = fn(co, nr)
    me.vertices.foreach_set("co", (co + nr * d[:, None]).ravel())
    me.update()
    return ob


def cleaved(name, size, cuts, seed, c=None, low=-0.15, high=0.95):
    import random as _r
    r = _r.Random(seed)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1)
    for v in bm.verts:
        v.co = Vector((v.co.x * size[0], v.co.y * size[1], v.co.z * size[2] + size[2] / 2))
    for k in range(cuts):
        th = r.uniform(0, 2 * math.pi)
        ph = r.uniform(low, high)
        n = Vector((math.cos(th) * math.cos(ph), math.sin(th) * math.cos(ph), math.sin(ph)))
        ext = abs(n.x) * size[0] / 2 + abs(n.y) * size[1] / 2 + abs(n.z) * size[2] / 2
        p = Vector((0, 0, size[2] / 2)) + n * ext * r.uniform(0.5, 0.82)
        bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=p, plane_no=n, clear_outer=True)
        bmesh.ops.holes_fill(bm, edges=[e for e in bm.edges if e.is_boundary])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return put(name, bm, c)


def sstep(a, b, x):
    t = np.clip((x - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def to_lin(c):
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def pbr_mat(name, color=None, rough=None, metal=None, normal=None, nstrength=1.0):
    m = bpy.data.materials.new(name)
    try:
        m.use_nodes = True
    except Exception:
        pass
    nt = m.node_tree
    b = nt.nodes.get("Principled BSDF")
    y = 300
    for im, sock, data in ((color, "Base Color", False), (rough, "Roughness", True), (metal, "Metallic", True)):
        if im is None:
            continue
        t = nt.nodes.new("ShaderNodeTexImage")
        t.image = im
        t.location = (-400, y)
        y -= 280
        im.colorspace_settings.name = "Non-Color" if data else "sRGB"
        nt.links.new(t.outputs["Color"], b.inputs[sock])
    if normal is not None:
        t = nt.nodes.new("ShaderNodeTexImage")
        t.image = normal
        normal.colorspace_settings.name = "Non-Color"
        t.location = (-700, y)
        nm = nt.nodes.new("ShaderNodeNormalMap")
        nm.inputs["Strength"].default_value = nstrength
        nt.links.new(t.outputs["Color"], nm.inputs["Color"])
        nt.links.new(nm.outputs["Normal"], b.inputs["Normal"])
    return m


def dummy(at=(0, 0, 0), c=None, yaw=0.0):
    parts = [("Head", (1.2, 1.2, 1.0), (0, 0, 4.5)), ("Torso", (2, 1, 2), (0, 0, 3)),
             ("LArm", (1, 1, 2), (-1.5, 0, 3)), ("RArm", (1, 1, 2), (1.5, 0, 3)),
             ("LLeg", (1, 1, 2), (-0.5, 0, 1)), ("RLeg", (1, 1, 2), (0.5, 0, 1))]
    obs = [box("R6_" + n, s, p, c) for n, s, p in parts]
    for o in obs:
        bevel(o, 0.06, seg=2, harden=False, strength="FSTR_NONE")
    d = join([apply(o) for o in obs], "R6Dummy")
    d.data.shade_smooth()
    give(d, mat("Dummy", (0.55, 0.57, 0.6), 0.6))
    d.rotation_euler.z = R(yaw)
    d.location = at
    return d


def bounds(objs):
    dg = bpy.context.evaluated_depsgraph_get()
    pts = []
    for o in objs:
        e = o.evaluated_get(dg)
        pts += [e.matrix_world @ Vector(c) for c in e.bound_box]
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    return lo, hi


def camera(sc, objs, yaw=30, pitch=20, lens=60, ortho=False, pad=1.08, name="Cam"):
    lo, hi = bounds(objs)
    ctr = (lo + hi) / 2
    rad = (hi - lo).length / 2 * pad
    cd = bpy.data.cameras.get(name) or bpy.data.cameras.new(name)
    cd.lens = lens
    ob = bpy.data.objects.get(name) or bpy.data.objects.new(name, cd)
    if ob.name not in sc.collection.objects:
        sc.collection.objects.link(ob)
    d = Vector((math.sin(R(yaw)) * math.cos(R(pitch)), -math.cos(R(yaw)) * math.cos(R(pitch)), math.sin(R(pitch))))
    fov = 2 * math.atan(18.0 / lens)
    dist = rad / math.sin(fov / 2)
    ob.location = ctr + d * dist
    ob.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()
    cd.type = "ORTHO" if ortho else "PERSP"
    cd.ortho_scale = rad * 2
    cd.clip_start = max(dist / 200, 0.001)
    cd.clip_end = dist * 4
    sc.camera = ob
    return ob


def look_from(sc, pos, at, fov=70, name="Cam"):
    cd = bpy.data.cameras.get(name) or bpy.data.cameras.new(name)
    cd.type = "PERSP"
    cd.sensor_fit = "VERTICAL"
    cd.sensor_height = 24
    cd.lens = 12.0 / math.tan(R(fov) / 2)
    ob = bpy.data.objects.get(name) or bpy.data.objects.new(name, cd)
    if ob.name not in sc.collection.objects:
        sc.collection.objects.link(ob)
    ob.location = pos
    ob.rotation_euler = (Vector(at) - Vector(pos)).to_track_quat("-Z", "Y").to_euler()
    cd.clip_start = 0.05
    cd.clip_end = 500
    sc.camera = ob
    return ob


def workbench(sc, look="matcap", cap="basic_grey.exr", color="SINGLE", cavity=False, shadows=False, aa="16"):
    sc.render.engine = "BLENDER_WORKBENCH"
    s = sc.display.shading
    s.light = {"matcap": "MATCAP", "studio": "STUDIO", "flat": "FLAT"}[look]
    if look == "matcap":
        s.studio_light = cap
    s.color_type = color
    s.single_color = (0.72, 0.72, 0.72)
    s.show_cavity = cavity
    if cavity:
        s.cavity_type = "BOTH"
    s.show_shadows = shadows
    s.show_specular_highlight = True
    sc.display.render_aa = aa
    sc.view_settings.view_transform = "Standard"
    return sc


def world(sc, hdri="studio.exr", strength=1.0, rot=0.0, sun=None):
    w = bpy.data.worlds.get("Look") or bpy.data.worlds.new("Look")
    sc.world = w
    try:
        w.use_nodes = True
    except Exception:
        pass
    nt = w.node_tree
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputWorld")
    bg = nt.nodes.new("ShaderNodeBackground")
    env = nt.nodes.new("ShaderNodeTexEnvironment")
    mp = nt.nodes.new("ShaderNodeMapping")
    tc = nt.nodes.new("ShaderNodeTexCoord")
    env.image = bpy.data.images.load(os.path.join(SL, "world", hdri), check_existing=True)
    mp.inputs["Rotation"].default_value = (0, 0, R(rot))
    nt.links.new(tc.outputs["Generated"], mp.inputs["Vector"])
    nt.links.new(mp.outputs["Vector"], env.inputs["Vector"])
    nt.links.new(env.outputs["Color"], bg.inputs["Color"])
    nt.links.new(bg.outputs["Background"], out.inputs["Surface"])
    bg.inputs["Strength"].default_value = strength
    if sun:
        ld = bpy.data.lights.get("Sun") or bpy.data.lights.new("Sun", "SUN")
        ld.energy = sun
        ld.angle = R(4)
        lo = bpy.data.objects.get("Sun") or bpy.data.objects.new("Sun", ld)
        if lo.name not in sc.collection.objects:
            sc.collection.objects.link(lo)
        lo.rotation_euler = (R(50), R(10), R(35))
    sc.view_settings.view_transform = "AgX"
    sc.view_settings.look = "AgX - Medium High Contrast"
    return w


def studio(sc, objs, key=1.0, bg=(0.035, 0.036, 0.04), contrast="AgX - Medium High Contrast", hdri="studio.exr", refl=0.7):
    lo, hi = bounds(objs)
    c = (lo + hi) / 2
    r = max((hi - lo).length / 2, 0.1)
    w = bpy.data.worlds.get("Studio") or bpy.data.worlds.new("Studio")
    sc.world = w
    try:
        w.use_nodes = True
    except Exception:
        pass
    nt = w.node_tree
    nt.nodes.clear()
    o = nt.nodes.new("ShaderNodeOutputWorld")
    flat = nt.nodes.new("ShaderNodeBackground")
    flat.inputs["Color"].default_value = (*bg, 1)
    env = nt.nodes.new("ShaderNodeBackground")
    tex = nt.nodes.new("ShaderNodeTexEnvironment")
    tex.image = bpy.data.images.load(os.path.join(SL, "world", hdri), check_existing=True)
    env.inputs["Strength"].default_value = refl
    nt.links.new(tex.outputs["Color"], env.inputs["Color"])
    lp = nt.nodes.new("ShaderNodeLightPath")
    mx = nt.nodes.new("ShaderNodeMixShader")
    nt.links.new(lp.outputs["Is Camera Ray"], mx.inputs["Fac"])
    nt.links.new(env.outputs[0], mx.inputs[1])
    nt.links.new(flat.outputs[0], mx.inputs[2])
    nt.links.new(mx.outputs[0], o.inputs[0])
    for nm, off, size, pw in (("Key", (-1.3, -1.7, 1.5), 1.6, 1.0), ("Fill", (1.8, -1.2, 0.3), 2.2, 0.28), ("Rim", (0.9, 2.1, 1.3), 1.0, 0.9)):
        ld = bpy.data.lights.get(nm) or bpy.data.lights.new(nm, "AREA")
        ld.shape = "DISK"
        ld.size = size * r
        pos = c + Vector(off) * r * 1.6
        d = (pos - c).length
        ld.energy = 6.0 * key * pw * d * d
        lo_ = bpy.data.objects.get(nm) or bpy.data.objects.new(nm, ld)
        if lo_.name not in sc.collection.objects:
            sc.collection.objects.link(lo_)
        lo_.location = pos
        lo_.rotation_euler = (c - pos).to_track_quat("-Z", "Y").to_euler()
    sc.view_settings.view_transform = "AgX"
    sc.view_settings.look = contrast
    return w


def no_studio():
    for nm in ("Key", "Fill", "Rim"):
        o = bpy.data.objects.get(nm)
        if o:
            bpy.data.objects.remove(o, do_unlink=True)


def cut_rings(ob, axis, at, eps=1e-4):
    k = "xyz".index(axis)
    n = 0
    with Edit(ob) as bm:
        for e in bm.edges:
            a, b = e.verts[0].co[k], e.verts[1].co[k]
            if any(abs(a - v) < eps and abs(b - v) < eps for v in at):
                e.seam = True
                n += 1
    return n


def shot(sc, path, w=640, h=640, transparent=False):
    sc.render.resolution_x = w
    sc.render.resolution_y = h
    sc.render.resolution_percentage = 100
    sc.render.film_transparent = transparent
    sc.render.image_settings.file_format = "PNG"
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    return path


def wire(ob, t=None, name=None):
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg), depsgraph=dg)
    w = bpy.data.objects.new(name or ob.name + "_Wire", me)
    bpy.context.scene.collection.objects.link(w)
    w.matrix_world = ob.matrix_world
    lo, hi = bounds([ob])
    mod(w, "WIREFRAME", thickness=t or (hi - lo).length * 0.0016, use_replace=True, use_even_offset=False,
        use_relative_offset=False, use_boundary=True, offset=1.0)
    w.color = (0.03, 0.03, 0.04, 1)
    return w


def sheet(paths, cols, out, bg=(0.1, 0.1, 0.11)):
    ims = [bpy.data.images.load(p, check_existing=False) for p in paths]
    w, h = ims[0].size
    rows = math.ceil(len(ims) / cols)
    big = np.zeros((rows * h, cols * w, 4), np.float32)
    big[..., :3] = bg
    big[..., 3] = 1
    for i, im in enumerate(ims):
        if tuple(im.size) != (w, h):
            im.scale(w, h)
        a = px(im)
        r, c = divmod(i, cols)
        y0 = (rows - 1 - r) * h
        rgb = a[..., :3] * a[..., 3:4] + np.array(bg, np.float32) * (1 - a[..., 3:4])
        big[y0:y0 + h, c * w:(c + 1) * w, :3] = rgb
    o = unpx("Sheet", big)
    save(o, out)
    for im in ims:
        bpy.data.images.remove(im)
    return out


def line(img, a, b, col):
    h, w = img.shape[:2]
    n = int(max(abs(b[0] - a[0]), abs(b[1] - a[1]))) + 1
    xs = np.clip(np.linspace(a[0], b[0], n).astype(int), 0, w - 1)
    ys = np.clip(np.linspace(a[1], b[1], n).astype(int), 0, h - 1)
    img[ys, xs, :3] = col


def uv_sheet(ob, out, size=1024, under=None, col=(0.1, 1.0, 0.4)):
    me = ob.data
    uv = me.uv_layers.active.data
    if under is not None:
        a = px(under).copy()
        if a.shape[0] != size:
            under.scale(size, size)
            a = px(under).copy()
        a[..., :3] *= 0.65
    else:
        a = np.zeros((size, size, 4), np.float32)
        a[..., :3] = 0.08
    a[..., 3] = 1
    for p in me.polygons:
        pts = [uv[i].uv * size for i in p.loop_indices]
        for i in range(len(pts)):
            line(a, pts[i], pts[(i + 1) % len(pts)], col)
    unpx("UVSheet", a, out)
    return out


def audit(ob, tex=1024):
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg), preserve_all_data_layers=True, depsgraph=dg)
    me.transform(ob.matrix_world)
    bm = bmesh.new()
    bm.from_mesh(me)
    faces = list(bm.faces)
    tris = sum(len(f.verts) - 2 for f in faces)
    r = {"name": ob.name, "tris": tris, "verts": len(bm.verts), "faces": len(faces),
         "quads": sum(1 for f in faces if len(f.verts) == 4), "ngons": sum(1 for f in faces if len(f.verts) > 4),
         "open_edges": sum(1 for e in bm.edges if e.is_boundary),
         "nonmanifold_edges": sum(1 for e in bm.edges if not e.is_manifold and not e.is_boundary),
         "loose_verts": sum(1 for v in bm.verts if not v.link_edges),
         "zero_faces": sum(1 for f in faces if f.calc_area() < 1e-9)}
    thin = 0
    bm2 = bm.copy()
    bmesh.ops.triangulate(bm2, faces=bm2.faces[:])
    for f in bm2.faces:
        a, b, c = [v.co for v in f.verts]
        angs = []
        for p, q, s in ((a, b, c), (b, c, a), (c, a, b)):
            u, v = q - p, s - p
            if u.length > 1e-9 and v.length > 1e-9:
                angs.append(u.angle(v))
        if angs and min(angs) < R(2):
            thin += 1
    bm2.free()
    r["sliver_tris"] = thin
    try:
        r["volume"] = round(bm.calc_volume(signed=True), 4)
    except Exception:
        r["volume"] = None
    lo = Vector((min(v.co.x for v in bm.verts), min(v.co.y for v in bm.verts), min(v.co.z for v in bm.verts)))
    hi = Vector((max(v.co.x for v in bm.verts), max(v.co.y for v in bm.verts), max(v.co.z for v in bm.verts)))
    r["size_studs"] = [round(x, 3) for x in (hi - lo)]
    o = ob.matrix_world.translation
    r["pivot_from_bottom_center"] = [round(x, 3) for x in (o - Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z)))]
    r["materials"] = len([m for m in me.materials if m])
    r["custom_normals"] = bool(me.has_custom_normals)
    uvl = bm.loops.layers.uv.active
    cpl = bm.faces.layers.int.get("copy")
    if uvl:
        out = 0
        dens = []
        wts = []
        used = 0.0
        for f in faces:
            if cpl and f[cpl]:
                continue
            uvs = [l[uvl].uv for l in f.loops]
            if any(u.x < -1e-4 or u.x > 1.0001 or u.y < -1e-4 or u.y > 1.0001 for u in uvs):
                out += 1
            ua = 0.0
            for i in range(1, len(uvs) - 1):
                ua += abs((uvs[i] - uvs[0]).cross(uvs[i + 1] - uvs[0])) / 2
            used += ua
            wa = f.calc_area()
            if wa > 1e-9 and ua > 1e-12:
                dens.append(math.sqrt(ua / wa) * tex)
                wts.append(wa)
        r["uv_faces_outside_0_1"] = out
        r["uv_area_used"] = round(used, 3)
        if dens:
            d = np.array(dens)
            ww = np.array(wts)
            o2 = np.argsort(d)
            cw = np.cumsum(ww[o2]) / ww.sum()
            med = d[o2][np.searchsorted(cw, 0.5)]
            p10 = d[o2][np.searchsorted(cw, 0.1)]
            p90 = d[o2][min(np.searchsorted(cw, 0.9), len(d) - 1)]
            r["texel_px_per_stud"] = {"median": round(float(med), 1), "p10": round(float(p10), 1), "p90": round(float(p90), 1), "tex": tex}
    else:
        r["uv"] = None
    bm.free()
    bpy.data.meshes.remove(me)
    return r


def rbx(v):
    return (-v[0], v[2], v[1])


def fbx(objs, path, forward="Z"):
    only(objs)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with bpy.context.temp_override(selected_objects=objs, active_object=objs[0], object=objs[0]):
        bpy.ops.export_scene.fbx(filepath=path, use_selection=True, object_types={"MESH"}, use_mesh_modifiers=True,
                                 mesh_smooth_type="OFF", colors_type="SRGB", apply_unit_scale=True,
                                 apply_scale_options="FBX_SCALE_UNITS", global_scale=1.0, axis_forward=forward,
                                 axis_up="Y", path_mode="COPY", embed_textures=True, bake_anim=False,
                                 add_leaf_bones=False, use_triangles=True)
    return path


def mesh_json(ob, path):
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg), preserve_all_data_layers=True, depsgraph=dg)
    me.calc_loop_triangles()
    uv = me.uv_layers.active.data if me.uv_layers.active else None
    nr = me.corner_normals
    col = me.color_attributes.active_color if me.color_attributes else None
    d = {"name": ob.name, "v": [], "t": [], "n": [], "uv": [], "c": []}
    d["v"] = [[round(x, 5) for x in rbx(v.co)] for v in me.vertices]
    for lt in me.loop_triangles:
        d["t"].append(list(lt.vertices))
        d["n"].append([[round(x, 4) for x in rbx(nr[i].vector)] for i in lt.loops])
        if uv:
            d["uv"].append([[round(uv[i].uv.x, 5), round(1 - uv[i].uv.y, 5)] for i in lt.loops])
        if col and col.domain == "CORNER":
            d["c"].append([[round(x, 3) for x in col.data[i].color_srgb[:3]] for i in lt.loops])
    with open(path, "w") as f:
        json.dump(d, f, separators=(",", ":"))
    bpy.data.meshes.remove(me)
    return path


def report(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=1)
    print("REPORT " + json.dumps(data))
