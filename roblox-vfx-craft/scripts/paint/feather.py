import math, random
from PIL import Image, ImageDraw, ImageFilter

random.seed(7)
S = 512
W = S * 2

def lerp(a, b, t):
    return a + (b - a) * t

def mix(c0, c1, t):
    return tuple(int(lerp(c0[i], c1[i], t)) for i in range(3))

CORE = (240, 255, 250)
MINT = (140, 255, 215)
TEAL = (20, 205, 170)
DEEP = (0, 95, 90)

def shaft(t):
    x = W / 2 + math.sin(t * math.pi * 0.9) * W * 0.05
    y = W * 0.93 - t * W * 0.86
    return x, y

def vane(t):
    return math.sin(min(1, t * 1.25) * math.pi * 0.5) * (1 - t) ** 0.55 * W * 0.26 + W * 0.012

def feather(path, split_seed):
    random.seed(split_seed)
    col = Image.new("RGB", (W, W), (0, 0, 0))
    alpha = Image.new("L", (W, W), 0)
    dc = ImageDraw.Draw(col)
    da = ImageDraw.Draw(alpha)
    gaps = [random.uniform(0.25, 0.8) for _ in range(3)]
    n = 220
    for side in (-1, 1):
        for i in range(n):
            t = 0.1 + 0.88 * i / n
            if any(abs(t - g) < 0.012 for g in gaps) and random.random() < 0.85:
                continue
            x0, y0 = shaft(t)
            x1, y1 = shaft(min(1, t + 0.004))
            dx, dy = x1 - x0, y1 - y0
            l = math.hypot(dx, dy)
            nx, ny = -dy / l * side, dx / l * side
            ang = math.radians(38 + random.uniform(-4, 4))
            bx = nx * math.cos(ang) + (dx / l) * math.sin(ang)
            by = ny * math.cos(ang) + (dy / l) * math.sin(ang)
            length = vane(t) / math.cos(ang) * random.uniform(0.9, 1.05)
            steps = 18
            px, py = x0, y0
            for k in range(1, steps + 1):
                u = k / steps
                curl = u * u * 0.18
                qx = x0 + (bx * (1 - curl) + dx / l * curl) * length * u
                qy = y0 + (by * (1 - curl) + dy / l * curl) * length * u
                c = mix(CORE, MINT, min(1, u * 1.6)) if u < 0.6 else mix(MINT, TEAL, (u - 0.6) / 0.4)
                a = int(255 * (1 - u ** 3) * (0.8 + 0.2 * (1 - t)))
                wdt = max(1, int(3 * (1 - u) + 1))
                dc.line([(px, py), (qx, qy)], fill=c, width=wdt)
                da.line([(px, py), (qx, qy)], fill=a, width=wdt)
                px, py = qx, qy
    pts = [shaft(i / 100) for i in range(0, 101)]
    for i in range(len(pts) - 1):
        t = i / 100
        w = int(lerp(10, 2, t))
        dc.line([pts[i], pts[i + 1]], fill=CORE, width=w)
        da.line([pts[i], pts[i + 1]], fill=255, width=w)
    glow = alpha.filter(ImageFilter.GaussianBlur(18))
    rim = alpha.filter(ImageFilter.GaussianBlur(4))
    base = Image.new("RGB", (W, W), DEEP)
    out_rgb = Image.composite(col, base, alpha)
    out_a = Image.eval(Image.merge("L", [alpha]), lambda v: v)
    halo = glow.point(lambda v: int(v * 0.55))
    rim2 = rim.point(lambda v: int(v * 0.8))
    a = Image.new("L", (W, W))
    a = Image.fromarray if False else a
    from PIL import ImageChops
    a = ImageChops.lighter(ImageChops.lighter(alpha, rim2), halo)
    out = out_rgb.copy()
    out.putalpha(a)
    out = out.resize((S, S), Image.LANCZOS)
    out.save(path)

feather("feather_a.png", 3)
feather("feather_b.png", 11)
print("ok")
