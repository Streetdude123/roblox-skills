import sys
from pathlib import Path

import numpy as np
from PIL import Image

out = Path(sys.argv[1] if len(sys.argv) > 1 else "tex")
out.mkdir(parents=True, exist_ok=True)
rng = np.random.default_rng(int(sys.argv[2]) if len(sys.argv) > 2 else 7)

W, H, S = 512, 256, 4
DARK = np.array([22, 14, 40])
GREEN = np.array([120, 255, 170])
PINK = np.array([230, 110, 255])


def periods(total, lo, hi):
    out, left = [], total
    while left > hi + lo:
        p = int(rng.integers(lo, hi))
        out.append(p)
        left -= p
    out.append(left)
    return out


def teeth(n, lo, hi, amp_lo, amp_hi):
    ext = np.zeros(n)
    x = 0
    for p in periods(n, lo, hi):
        a = rng.uniform(amp_lo, amp_hi)
        u = np.arange(p) / p
        ext[x:x + p] = a * u ** 1.6
        x += p
    return ext


def save(rgb, a, name, along=True):
    img = np.zeros(a.shape + (4,), np.uint8)
    img[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    img[..., 3] = np.clip(a * 255, 0, 255).astype(np.uint8)
    Image.fromarray(img.transpose(1, 0, 2) if along else img, "RGBA").save(out / name)
    return img


def down(a):
    h, w = a.shape[0] // S, a.shape[1] // S
    return a.reshape(h, S, w, S).mean(axis=(1, 3))


def grain(d, inner, outer, h, w):
    p = np.clip((outer - d) / (outer - inner), 0, 1) ** 1.3
    cells = rng.random((h // 2, w // 2)).repeat(2, 0).repeat(2, 1)
    return (cells < p).astype(np.float32)


def strip():
    n = W * S
    base = 50
    top = teeth(n, 20 * S, 70 * S, 4 * S, 36 * S) / S
    bot = teeth(n, 20 * S, 70 * S, 4 * S, 36 * S) / S
    y = np.arange(H * S)[:, None] / S - (H - 1) / 2
    edge = np.where(y < 0, base + top[None, :], base + bot[None, :])
    white = down((np.abs(y) < edge).astype(np.float32))
    yy = np.arange(H)[:, None] - (H - 1) / 2
    e = base + np.where(yy < 0, down(top[None, :].repeat(S, 0))[0][None, :], down(bot[None, :].repeat(S, 0))[0][None, :])
    d = np.abs(yy) - e
    dark = grain(np.maximum(d, 0), 0, 70, H, W) * 0.9 * (d > 0)
    speck = (d > -1) & (d < 18) & (rng.random((H, W)) < np.exp(-np.maximum(d, 0) / 5) * 0.5)
    rgb = np.ones((H, W, 3)) * DARK
    rgb[speck & (yy < 0)] = GREEN
    rgb[speck & (yy >= 0)] = PINK
    a = np.maximum(dark, speck * 1.0)
    a = np.maximum(a, white)
    rgb = rgb * (1 - white[..., None]) + 255 * white[..., None]
    body = save(rgb, a, "beam_body.png")
    core = save(np.full(white.shape + (3,), 255.0), white, "beam_core.png")
    return body, core


def glow():
    y = np.abs(np.arange(H)[:, None] - (H - 1) / 2) * np.ones((1, W))
    a = np.exp(-(y / 46) ** 2)
    return save(np.full(a.shape + (3,), 255.0), a, "beam_glow.png")


def disc():
    n = 512
    big = n * S
    yy, xx = np.mgrid[0:big, 0:big]
    cx = (big - 1) / 2
    r = np.hypot(yy - cx, xx - cx) / S
    ang = (np.arctan2(yy - cx, xx - cx) + np.pi) / (2 * np.pi)
    ring = teeth(1440, 14, 44, 4, 38)
    spike = ring[(ang * 1440).astype(int) % 1440]
    white = down((r < 150 + spike).astype(np.float32))
    r1 = down(r)
    a = grain(r1, 150, 255, n, n) * 0.92
    rgb = np.ones((n, n, 3)) * DARK
    fringe = (r1 > 140) & (r1 < 190) & (rng.random((n, n)) < np.clip((190 - r1) / 50, 0, 1) * 0.5)
    left = (np.mgrid[0:n, 0:n][1] < n / 2)
    rgb[fringe & left] = GREEN
    rgb[fringe & ~left] = PINK
    a[fringe] = 1
    a = np.maximum(a, white)
    rgb = rgb * (1 - white[..., None]) + 255 * white[..., None]
    return save(rgb, a, "beam_disc.png", False)


def over(dst, src):
    a = src[..., 3:4] / 255
    return dst * (1 - a) + src[..., :3] * a


def preview(body, core, g, d):
    rows = []
    for bg in ([214, 150, 96], [40, 44, 70]):
        canvas = np.ones((H * 2, W, 3)) * bg
        band = slice(H // 2, H // 2 + H)
        canvas[band] = over(canvas[band], body)
        ga = g.astype(np.float32)
        canvas[band] = np.clip(canvas[band] + ga[..., :3] * (ga[..., 3:4] / 255) * 0.25, 0, 255)
        rows.append(canvas)
    dd = np.array(Image.fromarray(d).resize((H * 2, H * 2)))
    side = np.ones((H * 4, H * 2, 3)) * [40, 44, 70]
    side[:H * 2] = over(np.ones((H * 2, H * 2, 3)) * [214, 150, 96], dd)
    side[H * 2:] = over(side[H * 2:], dd)
    img = np.concatenate([np.concatenate(rows, 0), side], 1)
    Image.fromarray(img.astype(np.uint8)).save(out / "beam_preview.png")


body, core = strip()
g, d = glow(), disc()
preview(body, core, g, d)
print("wrote", ", ".join(p.name for p in sorted(out.glob("beam_*.png"))))
