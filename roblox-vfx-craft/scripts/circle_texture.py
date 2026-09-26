import sys
import numpy as np
from PIL import Image, ImageFilter

src = sys.argv[1]
out = sys.argv[2]
im = np.asarray(Image.open(src).convert("RGB")).astype(np.float32)
h, w, _ = im.shape
r, g, b = im[..., 0], im[..., 1], im[..., 2]
lum = 0.299 * r + 0.587 * g + 0.114 * b
sat = im.max(axis=2) - im.min(axis=2)

disc = (sat < 18) & (lum > 150)
ys, xs = np.nonzero(disc)
cy, cx = h / 2, w / 2
d = np.hypot(ys - cy, xs - cx)
keep = d < min(h, w) * 0.3
ys, xs = ys[keep], xs[keep]
cx, cy = xs.mean(), ys.mean()
dark = (lum < 120)
yy, xx = np.mgrid[0:h, 0:w]
rr = np.hypot(yy - cy, xx - cx)
ring = dark & (rr < min(h, w) * 0.3)
R = np.percentile(rr[ring], 99.5)
print(f"centre {cx:.1f} {cy:.1f} radius {R:.1f} px")

pad = R * 1.04
box = (int(cx - pad), int(cy - pad), int(cx + pad), int(cy + pad))
N = 512
crop = Image.fromarray(lum.astype(np.uint8)).crop(box).resize((N, N), Image.LANCZOS)
L = np.asarray(crop).astype(np.float32)
alpha = np.clip((215 - L) / 150, 0, 1)
yy, xx = np.mgrid[0:N, 0:N]
rn = np.hypot(yy - (N - 1) / 2, xx - (N - 1) / 2) / (N / 2 / 1.04)
alpha[rn > 1.01] = 0


def save(a, name):
    a = np.clip(a, 0, 1)
    rgba = np.zeros((N, N, 4), np.uint8)
    rgba[..., :3] = 255
    rgba[..., 3] = (a * 255).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(f"{out}/{name}.png")
    print(name, f"coverage {a.mean():.3f}")


save(alpha, "circle_lines")
glow = Image.fromarray((alpha * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(5))
glow = np.asarray(glow).astype(np.float32) / 255 * 1.3
save(glow, "circle_glow")
split = 0.79
save(alpha * (rn >= split), "circle_band")
save(alpha * (rn < split), "circle_core")

prev = np.zeros((N, N * 4, 3), np.uint8)
prev[:] = (30, 24, 44)
for i, a in enumerate([alpha, np.clip(glow, 0, 1), alpha * (rn >= split), alpha * (rn < split)]):
    tile = (np.array([30, 24, 44]) * (1 - a[..., None]) + np.array([245, 240, 255]) * a[..., None]).astype(np.uint8)
    prev[:, i * N:(i + 1) * N] = tile
Image.fromarray(prev).resize((N * 2, N // 2)).save(f"{out}/circle_preview.png")
