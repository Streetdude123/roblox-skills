import sys
from collections import deque
from PIL import Image, ImageFilter, ImageChops

src = Image.open(sys.argv[1]).convert("RGBA")
S = 1024
src = src.resize((S, S), Image.LANCZOS)
px = src.load()

def lum(c):
    return (0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]) / 255

ink = Image.new("L", (S, S), 0)
ip = ink.load()
for y in range(S):
    for x in range(S):
        c = px[x, y]
        if c[3] > 40 and lum(c) < 0.86:
            ip[x, y] = 255

seen = bytearray(S * S)
lion = Image.new("L", (S, S), 0)
lp = lion.load()
kept = 0
for sy in range(S):
    for sx in range(S):
        i = sy * S + sx
        if ip[sx, sy] and not seen[i]:
            q = deque([(sx, sy)])
            seen[i] = 1
            comp = []
            while q:
                x, y = q.popleft()
                comp.append((x, y))
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if 0 <= nx < S and 0 <= ny < S:
                        j = ny * S + nx
                        if not seen[j] and ip[nx, ny]:
                            seen[j] = 1
                            q.append((nx, ny))
            r = sum(((x - S / 2) ** 2 + (y - S / 2) ** 2) ** 0.5 for x, y in comp) / len(comp)
            if r < 0.41 * S and len(comp) > 40:
                kept += len(comp)
                for x, y in comp:
                    lp[x, y] = 255
best = (0, [0] * kept)

outside = bytearray(S * S)
q = deque()
for x in range(S):
    for y in (0, S - 1):
        q.append((x, y))
        q.append((y, x))
while q:
    x, y = q.popleft()
    if not (0 <= x < S and 0 <= y < S):
        continue
    j = y * S + x
    if outside[j] or lp[x, y]:
        continue
    outside[j] = 1
    q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

mask = Image.new("L", (S, S), 0)
mp = mask.load()
for y in range(S):
    for x in range(S):
        if not outside[y * S + x]:
            mp[x, y] = 255
mask = mask.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.2))

core = (232, 255, 246)
mint = (150, 255, 220)
jade = (30, 235, 185)
teal = (0, 170, 140)

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

g = src.convert("L")
edges = g.filter(ImageFilter.FIND_EDGES).point(lambda v: min(255, v * 3))
edges = edges.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(1.0))
ep = edges.load()
mk = mask.load()

body = Image.new("RGBA", (S, S), (0, 0, 0, 0))
bp = body.load()
for y in range(S):
    for x in range(S):
        m = mk[x, y] / 255
        if m <= 0:
            continue
        v = lum(px[x, y])
        e = ep[x, y] / 255
        if v > 0.7:
            col, a = core, 1.0
        elif v > 0.3:
            t = (v - 0.3) / 0.4
            col, a = lerp(jade, mint, t), 0.5 + 0.35 * t
        else:
            t = v / 0.3
            col, a = lerp(teal, jade, t), 0.16 + 0.2 * t
        col = lerp(col, core, e * 0.85)
        a = min(1.0, a + e * 0.75)
        bp[x, y] = col + (int(255 * a * m),)

halo_a = mask.filter(ImageFilter.GaussianBlur(26)).point(lambda v: int(v * 0.35))
halo = Image.new("RGBA", (S, S), jade + (0,))
halo.putalpha(halo_a)

def zoom(img, steps, amount):
    acc = img.copy()
    for k in range(1, steps + 1):
        s = 1 + amount * k / steps
        w = int(S * s)
        z = img.resize((w, w), Image.BILINEAR)
        off = (w - S) // 2
        z = z.crop((off, off, off + S, off + S))
        r, gg, b, a = z.split()
        a = a.point(lambda v, f=1 - k / (steps + 1): int(v * f * 0.22))
        z = Image.merge("RGBA", (r, gg, b, a))
        acc = Image.alpha_composite(z, acc)
    return acc

streak = zoom(body, 28, 0.2)
out = Image.alpha_composite(halo, streak)
out = Image.alpha_composite(out, body)
out.save(sys.argv[2])

flat = Image.new("RGBA", (S, S), (10, 14, 18, 255))
Image.alpha_composite(flat, out).convert("RGB").save(sys.argv[2].replace(".png", "_preview.jpg"), quality=88)
print("saved", sys.argv[2], len(best[1]))
