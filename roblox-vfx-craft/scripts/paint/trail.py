import math, random
from PIL import Image

random.seed(4)
W, H = 256, 256
img = Image.new("RGBA", (W, H))
px = img.load()
streaks = [random.uniform(0.5, 1.0) for _ in range(W)]
for x in range(W):
    s = 0.8 + 0.2 * math.sin(x * 0.21) * math.sin(x * 0.047 + 1.3)
    for y in range(H):
        v = y / (H - 1)
        edge = math.exp(-((1 - v) / 0.05) ** 2)
        body = v ** 2.6
        a = min(1, edge * 1.0 + body * 0.75 * s)
        a *= min(1, (1 - v) * 60 + 0.6) if v > 0.985 else 1
        white = edge
        r = int(120 + 135 * white)
        g = 255
        b = int(215 + 40 * white)
        px[x, y] = (r, g, b, int(255 * a))
img.save("trail.png")
bg = Image.new("RGBA", (W, H), (25, 25, 30, 255))
bg.alpha_composite(img)
bg.save("trail_view.png")
print("ok")
