import bpy, os, sys, shutil
import numpy as np

args = dict(a.split("=", 1) for a in sys.argv[sys.argv.index("--") + 1:]) if "--" in sys.argv else {}
src = args["src"]
dst = args["dst"]
names = args["names"].split(",")
size = int(args.get("size", "512"))
os.makedirs(dst, exist_ok=True)
done = []
for name in names:
    folder = os.path.join(src, name)
    base = name.lower()
    j = os.path.join(folder, base + ".json")
    if os.path.exists(j):
        shutil.copy(j, os.path.join(dst, base + ".json"))
        done.append(base + ".json")
    for kind in ("color", "normal", "rough", "metal"):
        p = os.path.join(folder, "%s_%s.png" % (base, kind))
        if not os.path.exists(p):
            continue
        im = bpy.data.images.load(p)
        im.colorspace_settings.name = "Non-Color"
        if tuple(im.size) != (size, size):
            im.scale(size, size)
        a = np.empty(size * size * 4, np.float32)
        im.pixels.foreach_get(a)
        a = a.reshape(size, size, 4)[::-1]
        a[..., 3] = 1.0
        out = os.path.join(dst, "%s_%s.rgba" % (base, kind))
        (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8).tofile(out)
        done.append(os.path.basename(out))
        bpy.data.images.remove(im)
print("EXPORTED " + ",".join(done))
