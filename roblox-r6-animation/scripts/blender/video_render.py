import bpy, os, sys, math
from mathutils import Vector

ARGS = dict(a.split("=", 1) for a in sys.argv[sys.argv.index("--") + 1:]) if "--" in sys.argv else {}
D = os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(D, "rtools.py")).read())
scene = bpy.context.scene
FPS = scene.render.fps
arm = bpy.data.objects["Armature"]
for t in arm.animation_data.nla_tracks:
    t.mute = True
for pb in arm.pose.bones:
    pb.rotation_mode = "QUATERNION"

PLANS = {
    "slash": [("Idle", 72.8 / 24, 80 / 24, False), ("Slash1", 0, 0.75, False), ("Idle", 0, 0.35, False), ("Idle", 72.8 / 24, 80 / 24, False),
              ("Slash2", 0, 0.75, False), ("Idle", 0, 0.35, False)],
    "thrash": [("Idle", 72.8 / 24, 80 / 24, False), ("ThrashCharge", 0, 0.375, True), ("ThrashHold", 0, 1.0, True), ("ThrashHold", 0, 0.6, True),
               ("ThrashThrow", 0, 0.75, True), ("ThrashThrow", 0.75, 1.083, False), ("Idle", 0, 0.35, False)],
    "save": [("Idle", 72.8 / 24, 80 / 24, False), ("Corrupted Save", 0, 1.667, False), ("Idle", 0, 0.35, False)],
}
name = ARGS["plan"]
out = os.path.join(D, ARGS.get("out", "video_" + name))
os.makedirs(out, exist_ok=True)
w, h = int(ARGS.get("w", 720)), int(ARGS.get("h", 540))
cams = render_setup(w, h, vine=True)
scene.camera = cams[ARGS.get("cam", "Player")]
scene.render.image_settings.file_format = "JPEG"
scene.render.image_settings.quality = 90
vine = bpy.data.objects["VineArm"]
step = 1 / float(ARGS.get("fps", 30))
lines = ["start 0"]
idx = 0
clock = 0.0
for act_name, a, b, show_vine in PLANS[name]:
    arm.animation_data.action = bpy.data.actions[act_name]
    t = a
    while t < b - 1e-6 or (t <= b + 1e-6 and act_name == PLANS[name][-1][0] and b == PLANS[name][-1][2]):
        f = t * FPS
        scene.frame_set(int(f), subframe=f - int(f))
        vine.hide_render = not show_vine
        idx += 1
        scene.render.filepath = os.path.join(out, "f%05d.jpg" % idx)
        bpy.ops.render.render(write_still=True)
        lines.append("%d %d" % (idx, round(clock * 1000)))
        clock += step
        t += step
        if t > b + 1e-6:
            break
lines.append("%d %d" % (idx + 1, round(clock * 1000)))
import shutil
shutil.copy(os.path.join(out, "f%05d.jpg" % idx), os.path.join(out, "f%05d.jpg" % (idx + 1)))
open(os.path.join(out, "times.txt"), "w").write("\n".join(lines) + "\n")
print("VIDEO", name, "frames", idx + 1, "ms", round(clock * 1000))
