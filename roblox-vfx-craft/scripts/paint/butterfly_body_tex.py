import os
import numpy as np
from PIL import Image

OUT = r"C:\Users\vietb\Desktop\roblox\Shinsenkyo\build\fx"
W, H = 128, 512
y = np.linspace(0, 1, H)[:, None]
x = np.linspace(-1, 1, W)[None, :]


def lobe(c, h, w):
    return np.clip(1 - ((y - c) / h) ** 2 - (x / w) ** 2, 0, 1)


head = lobe(0.09, 0.08, 0.5)
thorax = lobe(0.27, 0.13, 0.85)
abd = np.clip(1 - ((y - 0.66) / 0.33) ** 2 - (x / (0.72 * np.clip(1.15 - (y - 0.4) * 1.3, 0.25, 1))) ** 2, 0, 1)
col = np.zeros((H, W, 3), np.float32)
a = np.zeros((H, W), np.float32)
for m, c in ((abd, (34, 30, 40)), (thorax, (132, 52, 34)), (head, (120, 116, 112))):
    k = np.clip(m * 6, 0, 1)
    col = col * (1 - k[..., None]) + np.array(c, np.float32) * k[..., None]
    a = np.maximum(a, k)
seg = (np.sin((y - 0.4) * 70) > 0.75) & (y > 0.42)
col[np.broadcast_to(seg, (H, W))] *= 0.55
shade = 0.75 + 0.35 * (1 - np.abs(x)) ** 0.5
col = col * shade[..., None]
rgba = np.dstack([np.clip(col, 0, 255), np.clip(a * 255, 0, 255)]).astype(np.uint8)
Image.fromarray(rgba, "RGBA").save(os.path.join(OUT, "body.png"))
prev = Image.new("RGB", (W, H), (120, 170, 110))
im = Image.fromarray(rgba, "RGBA")
prev.paste(im, (0, 0), im)
prev.save(os.path.join(OUT, "body_preview.jpg"), quality=92)
print("body done")
