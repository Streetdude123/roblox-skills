import os
import numpy as np
from PIL import Image

OUT = r"C:\Users\vietb\Desktop\roblox\Shinsenkyo\build\fx"
os.makedirs(OUT, exist_ok=True)
L, W = 512, 256
rng = np.random.default_rng(11)
x = np.linspace(0, 1, L)[None, :]
y = np.linspace(-1, 1, W)[:, None]
env = np.exp(-(y / 0.62) ** 2 * 2.2)
streak = np.full((W, L), 0.25)
for k in range(15):
    c = rng.uniform(-0.75, 0.75)
    w = rng.uniform(0.025, 0.11)
    a = rng.uniform(0.35, 1.0)
    ph = rng.uniform(0, 6.28)
    fr = rng.uniform(0.6, 1.6)
    along = 0.55 + 0.45 * np.sin(x * 6.28 * fr + ph)
    streak = streak + a * np.exp(-((y - c) / w) ** 2) * along
streak = streak / streak.max()
alpha = np.clip(env * (0.35 + 0.65 * streak), 0, 1)
alpha = alpha / alpha.max()
rgba = np.zeros((W, L, 4), np.uint8)
rgba[..., :3] = 255
rgba[..., 3] = (alpha * 255).astype(np.uint8)
Image.fromarray(rgba, "RGBA").transpose(Image.ROTATE_90).save(os.path.join(OUT, "shaft2.png"))
im = Image.fromarray(rgba, "RGBA").transpose(Image.ROTATE_90)
prev = Image.new("RGB", im.size, (40, 70, 40))
prev.paste(im, (0, 0), im)
prev.save(os.path.join(OUT, "shaft2_preview.jpg"), quality=92)
print("shaft done")
