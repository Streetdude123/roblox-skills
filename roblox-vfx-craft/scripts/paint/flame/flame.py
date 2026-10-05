import numpy as np, sys, os
from PIL import Image

OUT = os.path.dirname(os.path.abspath(__file__))
GRAD = np.array([[1, 1, 0], [-1, 1, 0], [1, -1, 0], [-1, -1, 0], [1, 0, 1], [-1, 0, 1], [1, 0, -1], [-1, 0, -1],
                 [0, 1, 1], [0, -1, 1], [0, 1, -1], [0, -1, -1]], np.float32)


def hsh(ix, iy, iz, seed):
    h = (ix * 73856093) ^ (iy * 19349663) ^ (iz * 83492791) ^ (seed * 2654435761)
    h = (h ^ (h >> 13)) * 1274126177
    return (h ^ (h >> 16)) & 0x7FFFFFFF


def perlin(x, y, z, seed=0):
    xi, yi, zi = np.floor(x).astype(np.int64), np.floor(y).astype(np.int64), np.floor(z).astype(np.int64)
    xf, yf, zf = (x - xi).astype(np.float32), (y - yi).astype(np.float32), (z - zi).astype(np.float32)

    def fade(t):
        return t * t * t * (t * (t * 6 - 15) + 10)

    u, v, w = fade(xf), fade(yf), fade(zf)
    out = 0
    acc = {}
    for dx in (0, 1):
        for dy in (0, 1):
            for dz in (0, 1):
                g = GRAD[hsh(xi + dx, yi + dy, zi + dz, seed) % 12]
                acc[(dx, dy, dz)] = g[..., 0] * (xf - dx) + g[..., 1] * (yf - dy) + g[..., 2] * (zf - dz)
    x00 = acc[(0, 0, 0)] * (1 - u) + acc[(1, 0, 0)] * u
    x10 = acc[(0, 1, 0)] * (1 - u) + acc[(1, 1, 0)] * u
    x01 = acc[(0, 0, 1)] * (1 - u) + acc[(1, 0, 1)] * u
    x11 = acc[(0, 1, 1)] * (1 - u) + acc[(1, 1, 1)] * u
    y0 = x00 * (1 - v) + x10 * v
    y1 = x01 * (1 - v) + x11 * v
    return y0 * (1 - w) + y1 * w


def fbm(x, y, z, oct=4, seed=0, lac=2.0, gain=0.5):
    tot, amp, norm, f = 0.0, 1.0, 0.0, 1.0
    for k in range(oct):
        tot = tot + perlin(x * f, y * f, z * f, seed + k * 17) * amp
        norm += amp
        amp *= gain
        f *= lac
    return tot / norm


def ss(a, b, x):
    t = np.clip((x - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


RAMP = np.array([[0.00, 150, 40, 8], [0.18, 196, 64, 12], [0.34, 232, 98, 18], [0.50, 250, 136, 32], [0.66, 255, 176, 62],
                 [0.82, 255, 212, 120], [1.00, 255, 238, 196]], np.float32)


def ramp(T):
    T = np.clip(T, 0, 1)
    out = np.zeros(T.shape + (3,), np.float32)
    for c in range(3):
        out[..., c] = np.interp(T, RAMP[:, 0], RAMP[:, c + 1])
    return out / 255.0


def tongue(t, X, Y, seed, P=None):
    P = P or {}
    rise = P.get("rise", 2.4)
    W0 = P.get("w", 0.36)
    ero = P.get("ero", 0.62)
    n1 = fbm(X * 1.8, Y * 1.6 - t * rise * 0.7, t * 0.7, 3, seed + 3)
    xw = X + 0.30 * (Y + 0.25) * n1
    yw = Y + 0.10 * fbm(X * 1.8 + 5.1, Y * 1.6 - t * rise * 0.7, t * 0.7, 2, seed + 7)
    yb = -0.35 + 1.15 * ss(0.25, 1.0, t) ** 1.3
    yt = 0.42 + 0.50 * ss(0.0, 0.45, t) + 0.16 * ss(0.4, 1.0, t)
    s = np.clip((yw - yb) / max(yt - yb, 1e-3), 0, 1.5)
    G = np.clip(1 - s, 0, 1) ** 0.8 * ss(0.0, 0.18, s)
    Wd = W0 * (0.45 + 0.55 * (1 - np.clip(s, 0, 1)) ** 0.7) * (1 - 0.35 * ss(0.3, 1.0, t))
    F = np.clip(1 - (xw / Wd) ** 2, 0, 1)
    n2 = fbm(X * 3.6, Y * 3.0 - t * rise * 1.4, t * 1.6, 4, seed + 19)
    n3 = fbm(X * 9.0, Y * 7.0 - t * rise * 2.4, t * 3.0, 2, seed + 31)
    base = G * F
    M = ss(0.0, 0.3, base + 0.12 * (1 - s))
    T = (base * 1.3 + ero * n2 * (0.3 + 0.9 * s) + 0.14 * n3) * M - 0.06
    T = T * ss(0.0, 0.10, Y + 0.02)
    life = ss(0.0, 0.08, t) * (1 - ss(0.6, 1.0, t))
    return np.clip(T * 0.9, 0, 1.2) * life


def frame(t, N, seed, kind):
    g = (np.arange(N) + 0.5) / N
    X, Y = np.meshgrid(g * 2 - 1, 1 - g)
    if kind == "tongue":
        T = tongue(t, X, Y, seed)
    else:
        T = np.zeros_like(X)
        for k, (ox, sc, dt) in enumerate(((0.0, 1.0, 0.0), (-0.3, 0.75, 0.33), (0.32, 0.8, 0.66))):
            tt = (t + dt) % 1.0
            T = np.maximum(T, tongue(tt, (X - ox) / sc, Y / sc, seed + k * 101) * (0.85 if k else 1.0))
    a = ss(0.02, 0.62, T) ** 1.15
    rgb = ramp(T)
    return np.dstack([rgb, a])


def sheet(kind, grid, cell, seed, ss_=2):
    n = grid * grid
    img = np.zeros((grid * cell, grid * cell, 4), np.float32)
    for i in range(n):
        t = i / (n - 1)
        f = frame(t, cell * ss_, seed, kind)
        if ss_ > 1:
            f = f.reshape(cell, ss_, cell, ss_, 4).mean((1, 3))
        r, c = divmod(i, grid)
        img[r * cell:(r + 1) * cell, c * cell:(c + 1) * cell] = f
    return img


def save(img, path):
    Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA").save(path)


def preview(img, path, bg=(18, 16, 15)):
    a = img[..., 3:4]
    base = np.ones_like(img[..., :3]) * np.array(bg, np.float32) / 255
    out = base * (1 - a) + img[..., :3] * a
    Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8)).save(path)


if __name__ == "__main__":
    kind = sys.argv[1] if len(sys.argv) > 1 else "tongue"
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 3
    grid = int(sys.argv[3]) if len(sys.argv) > 3 else 8
    cell = int(sys.argv[4]) if len(sys.argv) > 4 else 128
    img = sheet(kind, grid, cell, seed, 2 if cell >= 128 else 1)
    save(img, os.path.join(OUT, "flame_%s.png" % kind))
    preview(img, os.path.join(OUT, "flame_%s_prev.png" % kind))
    print("done", kind)
