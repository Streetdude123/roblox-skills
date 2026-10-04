import bpy, os, sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rbx

a = rbx.args(out="", groups="", base="samurai")
out = a["out"]
names = a["groups"].split(",")
gobs = {g: bpy.data.objects[g] for g in names}
for im in bpy.data.images:
    path = os.path.join(out, im.name + ".png")
    if im.name.startswith(a["base"] + "_") and os.path.exists(path):
        im.filepath = path
        im.reload()
for o in gobs.values():
    o.hide_render = False
uv = {}
for g, o in gobs.items():
    buf = np.empty(len(o.data.loops) * 2, np.float32)
    o.data.uv_layers.active.data.foreach_get("uv", buf)
    uv[g] = buf
np.savez_compressed(os.path.join(out, "uvs.npz"), **uv)
rbx.fbx(list(gobs.values()), os.path.join(out, a["base"] + ".fbx"))
for g, o in gobs.items():
    rbx.mesh_json(o, os.path.join(out, "%s_%s.json" % (a["base"], g.lower())))
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out, a["base"] + ".blend"))
print("RESTORED %d groups, loops %s" % (len(gobs), {g: len(o.data.loops) for g, o in gobs.items()}))
