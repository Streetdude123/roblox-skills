import numpy as np, sys, os, json, math
from PIL import Image

D = os.path.dirname(os.path.abspath(__file__))


def load_book(path, grid):
    a = np.asarray(Image.open(path).convert("RGBA")).astype(np.float32) / 255.0
    n = a.shape[0] // grid
    return [a[r * n:(r + 1) * n, c * n:(c + 1) * n] for r in range(grid) for c in range(grid)]


def curve(keys, t):
    ks = np.array(keys, np.float32)
    return float(np.interp(t, ks[:, 0], ks[:, 1]))


def paste(dst, spr, cx, cy, size_px, rot, rgbmul, alpha_mul, le):
    if size_px < 2:
        return
    im = Image.fromarray((np.clip(spr, 0, 1) * 255).astype(np.uint8), "RGBA")
    s = max(2, int(round(size_px)))
    im = im.resize((s, s), Image.BILINEAR)
    if rot:
        im = im.rotate(rot, resample=Image.BILINEAR, expand=False)
    a = np.asarray(im).astype(np.float32) / 255.0
    x0, y0 = int(round(cx - s / 2)), int(round(cy - s / 2))
    H, W = dst.shape[:2]
    xa, ya = max(0, x0), max(0, y0)
    xb, yb = min(W, x0 + s), min(H, y0 + s)
    if xa >= xb or ya >= yb:
        return
    sub = a[ya - y0:yb - y0, xa - x0:xb - x0]
    al = sub[..., 3:4] * alpha_mul
    rgb = sub[..., :3] * np.array(rgbmul, np.float32)
    d = dst[ya:yb, xa:xb]
    dst[ya:yb, xa:xb] = d * (1 - al * (1 - le)) + rgb * al


def run(cfg, times, bg, W=320, Hh=448, ppu=64, seed=1):
    rnd = np.random.default_rng(seed)
    books = {}
    parts = []
    for L in cfg:
        if L["tex"] not in books:
            books[L["tex"]] = load_book(os.path.join(D, L["tex"]), L["grid"])
        T0 = max(times) + 0.1
        t = -max(L["life"]) - 0.5
        while t < T0:
            t += rnd.exponential(1.0 / L["rate"])
            r = L.get("radius", 0.6) * math.sqrt(rnd.random())
            ang = rnd.random() * 2 * math.pi
            life = rnd.uniform(*L["life"])
            sp = rnd.uniform(*L["speed"])
            spread = math.radians(rnd.uniform(-L.get("spread", 0), L.get("spread", 0)))
            parts.append(dict(L=L, t0=t, x=r * math.cos(ang), z=r * math.sin(ang), life=life,
                              vx=sp * math.sin(spread), vy=sp * math.cos(spread), rot=rnd.uniform(*L.get("rot", (0, 0))), rs=rnd.uniform(*L.get("rotspeed", (0, 0)))))
    frames = []
    for T in times:
        img = np.ones((Hh, W, 3), np.float32) * np.array(bg, np.float32) / 255
        live = []
        for p in parts:
            age = T - p["t0"]
            if 0 <= age < p["life"]:
                live.append((p["z"], p, age))
        live.sort(key=lambda q: -q[0])
        for _, p, age in live:
            L = p["L"]
            u = age / p["life"]
            ac = L.get("accel", (0, 0))
            x = p["x"] + p["vx"] * age + 0.5 * ac[0] * age * age
            y = L.get("y0", 0.0) + p["vy"] * age + 0.5 * ac[1] * age * age
            size = curve(L["size"], u)
            tr = curve(L.get("trans", [(0, 0), (1, 0)]), u)
            book = books[L["tex"]]
            fi = min(len(book) - 1, int(u * len(book))) if L.get("oneshot", True) else int((age * L.get("fps", 30))) % len(book)
            cx = W / 2 + x * ppu
            cy = Hh - 40 - y * ppu
            paste(img, book[fi], cx, cy, size * ppu, p["rot"] + p["rs"] * age, L.get("color", (1, 1, 1)), (1 - tr) * L.get("bright", 1.0), L.get("le", 0.5))
        frames.append(img)
    return frames


if __name__ == "__main__":
    cfg = json.load(open(os.path.join(D, sys.argv[1])))
    times = [2.0 + k * 0.12 for k in range(6)]
    out = []
    for bg in ((22, 18, 16), (226, 150, 96)):
        fr = run(cfg, times, bg)
        out.append(np.concatenate([np.pad(f, ((0, 0), (0, 4), (0, 0)), constant_values=0.25) for f in fr], 1))
    img = np.concatenate(out, 0)
    Image.fromarray((np.clip(img, 0, 1) * 255).astype(np.uint8)).save(os.path.join(D, sys.argv[2]))
    print("sim saved")
