import os, math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = r"C:\Users\vietb\Desktop\roblox\Shinsenkyo\build\fx"
os.makedirs(OUT, exist_ok=True)
S = 2048
F = 512


def P(u, v):
    return ((1 - u) * (S - 1), v * (S - 1))


def spline(pts, n=24):
    out = []
    m = len(pts)
    for i in range(m):
        p0, p1, p2, p3 = pts[(i - 1) % m], pts[i], pts[(i + 1) % m], pts[(i + 2) % m]
        for k in range(n):
            t = k / n
            t2, t3 = t * t, t * t * t
            x = 0.5 * ((2 * p1[0]) + (-p0[0] + p2[0]) * t + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2 + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3)
            y = 0.5 * ((2 * p1[1]) + (-p0[1] + p2[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2 + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3)
            out.append((x, y))
    return out


fore = [(0.0, 0.26), (0.25, 0.16), (0.55, 0.07), (0.82, 0.02), (0.97, 0.05), (0.93, 0.17), (0.84, 0.33), (0.72, 0.47), (0.52, 0.55), (0.25, 0.53), (0.0, 0.47)]
hind = [(0.0, 0.42), (0.3, 0.46), (0.55, 0.52), (0.66, 0.62), (0.64, 0.74), (0.56, 0.84), (0.47, 0.9), (0.44, 0.995), (0.36, 0.93), (0.24, 0.88), (0.1, 0.8), (0.0, 0.7)]


def mask(pts):
    m = Image.new("L", (S, S), 0)
    ImageDraw.Draw(m).polygon([P(u, v) for u, v in spline(pts)], fill=255)
    return np.asarray(m, np.float32) / 255.0


mf, mh = mask(fore), mask(hind)
yy, xx = np.mgrid[0:S, 0:S].astype(np.float32) / (S - 1)
u = 1 - xx
v = yy


def dist_in(m):
    R = 256
    cur = Image.fromarray((m * 255).astype(np.uint8)).resize((R, R), Image.BILINEAR)
    acc = np.zeros((R, R), np.float32)
    for i in range(64):
        acc += np.asarray(cur, np.float32) / 255.0
        cur = cur.filter(ImageFilter.MinFilter(3))
    d = Image.fromarray((acc / 64.0).astype(np.float32), "F").resize((S, S), Image.BILINEAR)
    return np.asarray(d, np.float32) * 0.25


df, dh = dist_in(mf), dist_in(mh)
rng = np.random.default_rng(7)
n = np.asarray(Image.fromarray((rng.random((S // 8, S // 8)) * 255).astype(np.uint8)).resize((S, S), Image.BICUBIC).filter(ImageFilter.GaussianBlur(6)), np.float32) / 255.0

col = np.zeros((S, S, 3), np.float32)
alpha = np.zeros((S, S), np.float32)

hb = np.array([46, 30, 32], np.float32)
hin = np.array([150, 70, 34], np.float32)
t = np.clip(1 - u / 0.42, 0, 1)[..., None]
hcol = hb * (1 - t * 0.85) + hin * t * 0.85
spots = np.zeros((S, S), np.float32)
for k in range(7):
    a = k / 6.0
    su = 0.6 - 0.1 * a + 0.02 * math.sin(a * 9)
    sv = 0.58 + 0.33 * a
    r = 0.028 - 0.006 * abs(a - 0.4)
    d = np.sqrt((u - su * 0.9) ** 2 + (v - sv) ** 2)
    spots = np.maximum(spots, np.clip((r - d) / 0.008, 0, 1))
hcol = hcol * (1 - spots[..., None]) + np.array([236, 222, 188], np.float32) * spots[..., None]
col = col * (1 - mh[..., None]) + hcol * mh[..., None]
alpha = np.maximum(alpha, mh)

fa = np.array([238, 156, 58], np.float32)
fl = np.array([248, 196, 104], np.float32)
fh = np.array([140, 62, 30], np.float32)
g = np.clip((u - 0.08) / 0.7, 0, 1)[..., None]
fcol = fh * (1 - np.clip(g * 2.2, 0, 1)) + fa * np.clip(g * 2.2, 0, 1)
fcol = fcol * (1 - np.clip((g - 0.55) * 2, 0, 1) * 0.6) + fl * np.clip((g - 0.55) * 2, 0, 1) * 0.6
fcol = fcol * (0.9 + 0.2 * n[..., None])
band = np.clip(1 - (df - 0.018) / 0.014, 0, 1)
dark = np.array([34, 26, 30], np.float32)
fcol = fcol * (1 - band[..., None] * np.clip((u - 0.3) / 0.15, 0, 1)[..., None]) + dark * (band * np.clip((u - 0.3) / 0.15, 0, 1))[..., None]
apex = np.clip(1 - np.sqrt((u - 0.95) ** 2 * 1.4 + (v - 0.06) ** 2) / 0.24, 0, 1)
fcol = fcol * (1 - apex[..., None] * 0.92) + dark * apex[..., None] * 0.92
for k in range(5):
    a = k / 4.0
    du = 0.88 - 0.08 * a
    dv = 0.09 + 0.07 * a
    d = np.sqrt((u - du) ** 2 + (v - dv) ** 2)
    s = np.clip((0.016 - d) / 0.006, 0, 1) * np.clip(apex * 3, 0, 1)
    fcol = fcol * (1 - s[..., None]) + np.array([236, 222, 188], np.float32) * s[..., None]
red = np.array([132, 28, 22], np.float32)
for off, wdt in ((0.046, 0.0055), (0.074, 0.0045)):
    w = df + 0.004 * np.sin(v * 70 + u * 20)
    line = np.clip(1 - np.abs(w - off) / wdt, 0, 1) * np.clip((u - 0.22) / 0.1, 0, 1) * (1 - apex)
    fcol = fcol * (1 - line[..., None] * 0.85) + red * line[..., None] * 0.85
col = col * (1 - mf[..., None]) + fcol * mf[..., None]
alpha = np.maximum(alpha, mf)

base = Image.fromarray(np.clip(col, 0, 255).astype(np.uint8))
img = base.copy()
d = ImageDraw.Draw(img)
vc = (52, 30, 24)
for k in range(9):
    ang = -0.42 + k * 0.105
    pts = []
    for s in np.linspace(0.02, 1.0, 40):
        uu = s * (0.97 - 0.25 * abs(ang + 0.1))
        vv = 0.36 + math.sin(ang) * s * 1.0 + 0.03 * s * s
        pts.append(P(uu, vv))
    d.line(pts, fill=vc, width=4)
for k in range(7):
    ang = 0.25 + k * 0.17
    pts = []
    for s in np.linspace(0.02, 1.0, 40):
        uu = s * 0.62 * math.cos(ang - 0.3)
        vv = 0.56 + s * 0.42 * math.sin(ang)
        pts.append(P(uu, vv))
    d.line(pts, fill=vc, width=4)
col = np.asarray(base, np.float32) * 0.4 + np.asarray(img, np.float32) * 0.6
col = col * (1 - (1 - np.clip(df / 0.0045, 0, 1))[..., None] * mf[..., None] * 0.9) + np.array([22, 16, 18], np.float32) * ((1 - np.clip(df / 0.0045, 0, 1)) * mf * 0.9)[..., None]
only_h = mh * (1 - mf)
col = col * (1 - (1 - np.clip(dh / 0.0045, 0, 1))[..., None] * only_h[..., None] * 0.9) + np.array([22, 16, 18], np.float32) * ((1 - np.clip(dh / 0.0045, 0, 1)) * only_h * 0.9)[..., None]
hingefade = np.clip(u / 0.006, 0, 1)
alpha = alpha * (0.35 + 0.65 * hingefade)

rgba = np.dstack([np.clip(col, 0, 255), np.clip(alpha * 255, 0, 255)]).astype(np.uint8)
im = Image.fromarray(rgba, "RGBA").resize((F, F), Image.LANCZOS)
im.save(os.path.join(OUT, "wing.png"))
prev = Image.new("RGBA", (F * 2, F), (120, 170, 110, 255))
prev.alpha_composite(im, (0, 0))
prev.alpha_composite(im.transpose(Image.FLIP_LEFT_RIGHT), (F, 0))
prev.convert("RGB").save(os.path.join(OUT, "wing_preview.jpg"), quality=92)
print("wing done")
