import argparse
import math
from pathlib import Path
import re
import shutil
import subprocess
import sys

import numpy as np

HEADER = re.compile(r'^#(.+?) len=(\S+) loop=(\S+)')

JOINTS = {
    'Torso': (None, (0, 0, 0), (0, 0, 0), (2, 2, 1)),
    'Head': ('Torso', (0, 1, 0), (0, 0.5, 0), (2, 1, 1)),
    'Right Arm': ('Torso', (1, 0.5, 0), (0.5, -0.5, 0), (1, 2, 1)),
    'Left Arm': ('Torso', (-1, 0.5, 0), (-0.5, -0.5, 0), (1, 2, 1)),
    'Right Leg': ('Torso', (1, -1, 0), (-0.5, -1, 0), (1, 2, 1)),
    'Left Leg': ('Torso', (-1, -1, 0), (0.5, -1, 0), (1, 2, 1)),
}
ORDER = ['Torso', 'Head', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg']
TIPS = {'Right Arm': (0, -1, 0), 'Left Arm': (0, -1, 0), 'Right Leg': (0, -1, 0), 'Left Leg': (0, -1, 0), 'Head': (0, 0.5, 0), 'Torso': (0, 0, 0)}
COLORS = {
    'Torso': (40, 110, 200), 'Head': (245, 205, 60), 'Right Arm': (245, 205, 60), 'Left Arm': (225, 185, 50),
    'Right Leg': (120, 180, 70), 'Left Leg': (100, 160, 60),
}
VIEWS = {'side': (90, 5), 'front': (180, 5), 'rear': (0, 8), 'rear34': (35, 12), 'front34': (145, 8), 'top': (90, 80), 'low': (160, -12)}


def rx(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[1, 0, 0], [0, c, -s], [0, s, c]])


def ry(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[c, 0, s], [0, 1, 0], [-s, 0, c]])


def rz(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]])


def pose_matrix(lift, twist, side):
    r = math.radians
    return rz(r(side)) @ rx(r(lift)) @ ry(r(twist))


def mat_to_quat(m):
    t = m[0, 0] + m[1, 1] + m[2, 2]
    if t > 0:
        s = math.sqrt(t + 1) * 2
        q = [0.25 * s, (m[2, 1] - m[1, 2]) / s, (m[0, 2] - m[2, 0]) / s, (m[1, 0] - m[0, 1]) / s]
    elif m[0, 0] > m[1, 1] and m[0, 0] > m[2, 2]:
        s = math.sqrt(1 + m[0, 0] - m[1, 1] - m[2, 2]) * 2
        q = [(m[2, 1] - m[1, 2]) / s, 0.25 * s, (m[0, 1] + m[1, 0]) / s, (m[0, 2] + m[2, 0]) / s]
    elif m[1, 1] > m[2, 2]:
        s = math.sqrt(1 + m[1, 1] - m[0, 0] - m[2, 2]) * 2
        q = [(m[0, 2] - m[2, 0]) / s, (m[0, 1] + m[1, 0]) / s, 0.25 * s, (m[1, 2] + m[2, 1]) / s]
    else:
        s = math.sqrt(1 + m[2, 2] - m[0, 0] - m[1, 1]) * 2
        q = [(m[1, 0] - m[0, 1]) / s, (m[0, 2] + m[2, 0]) / s, (m[1, 2] + m[2, 1]) / s, 0.25 * s]
    q = np.array(q)
    return q / np.linalg.norm(q)


def quat_to_mat(q):
    w, x, y, z = q
    return np.array([
        [1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
        [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
        [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)],
    ])


def slerp(a, b, u):
    d = float(np.dot(a, b))
    if d < 0:
        b, d = -b, -d
    if d > 0.9995:
        q = a + u * (b - a)
        return q / np.linalg.norm(q)
    th = math.acos(d)
    return (math.sin((1 - u) * th) * a + math.sin(u * th) * b) / math.sin(th)


def read_decode(path):
    lines = Path(path).read_text(encoding='utf-8').splitlines()
    head = HEADER.match(lines[0]) if lines else None
    clip = {'name': head.group(1) if head else Path(path).stem, 'len': float(head.group(2)) if head else 0.0, 'joints': {}}
    for line in lines[1:]:
        f = line.split('|')
        if len(f) < 9 or f[1] == 'MARKER' or f[1] not in JOINTS:
            continue
        t = float(f[2])
        m = pose_matrix(float(f[3]), float(f[4]), float(f[5]))
        clip['joints'].setdefault(f[1], []).append((t, mat_to_quat(m), np.array([float(f[6]), float(f[7]), float(f[8])])))
    for k in clip['joints']:
        clip['joints'][k].sort(key=lambda e: e[0])
    if not clip['len']:
        clip['len'] = max((s[-1][0] for s in clip['joints'].values()), default=0.0)
    return clip


def sample(keys, t):
    if not keys:
        return np.eye(3), np.zeros(3)
    if t <= keys[0][0]:
        return quat_to_mat(keys[0][1]), keys[0][2]
    if t >= keys[-1][0]:
        return quat_to_mat(keys[-1][1]), keys[-1][2]
    lo, hi = 0, len(keys) - 1
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if keys[mid][0] <= t:
            lo = mid
        else:
            hi = mid
    a, b = keys[lo], keys[hi]
    u = (t - a[0]) / max(1e-9, b[0] - a[0])
    return quat_to_mat(slerp(a[1], b[1], u)), a[2] + (b[2] - a[2]) * u


def world_parts(clip, t, root=None):
    root_r, root_p = root if root else (np.eye(3), np.array([0.0, 3.0, 0.0]))
    out = {}
    for name in ORDER:
        parent, c0, c1, size = JOINTS[name]
        pr, pp = sample(clip['joints'].get(name, []), t)
        base_r, base_p = (root_r, root_p) if parent is None else out[parent][:2]
        piv = base_p + base_r @ np.array(c0, dtype=float)
        r = base_r @ pr
        p = piv + base_r @ pp + r @ np.array(c1, dtype=float)
        out[name] = (r, p, size)
    return out


def tip_point(parts, name):
    r, p, _ = parts[name]
    return p + r @ np.array(TIPS[name], dtype=float)


class Camera:
    def __init__(self, yaw, pitch, dist, target, fov, w, h):
        self.w, self.h = w, h
        a, b = math.radians(yaw), math.radians(pitch)
        back = np.array([math.sin(a) * math.cos(b), math.sin(b), math.cos(a) * math.cos(b)])
        self.pos = np.array(target, dtype=float) + back * dist
        f = np.array(target, dtype=float) - self.pos
        f /= np.linalg.norm(f)
        right = np.cross(f, [0, 1, 0])
        if np.linalg.norm(right) < 1e-6:
            right = np.array([1.0, 0, 0])
        right /= np.linalg.norm(right)
        up = np.cross(right, f)
        self.f, self.r, self.u = f, right, up
        self.k = (h / 2) / math.tan(math.radians(fov) / 2)

    def project(self, pts):
        d = pts - self.pos
        z = d @ self.f
        x = d @ self.r
        y = d @ self.u
        z = np.maximum(z, 1e-3)
        return np.stack([self.w / 2 + self.k * x / z, self.h / 2 - self.k * y / z], axis=1), z


FACES = [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)]
NORMALS = [(-1, 0, 0), (1, 0, 0), (0, -1, 0), (0, 1, 0), (0, 0, -1), (0, 0, 1)]


def corners(r, p, size):
    sx, sy, sz = size[0] / 2, size[1] / 2, size[2] / 2
    local = np.array([[x, y, z] for x in (-sx, sx) for y in (-sy, sy) for z in (-sz, sz)])
    return p + local @ r.T


def box_polys(parts, cam, alpha=255, tint=None):
    light = np.array([0.4, 0.8, -0.45])
    light /= np.linalg.norm(light)
    polys = []
    for name, (r, p, size) in parts.items():
        c = corners(r, p, size)
        pts, z = cam.project(c)
        base = np.array(tint if tint else COLORS[name], dtype=float)
        for face, n in zip(FACES, NORMALS):
            nw = r @ np.array(n, dtype=float)
            center = c[list(face)].mean(axis=0)
            if np.dot(nw, cam.pos - center) <= 0:
                continue
            shade = 0.45 + 0.55 * max(0.0, float(np.dot(nw, light)))
            face_col = base
            if n == (0, 0, -1) and name in ('Head', 'Torso') and not tint:
                face_col = base * 0.55 + np.array([255, 255, 255]) * 0.45
            col = tuple(int(min(255, v * shade)) for v in face_col)
            polys.append((float(z[list(face)].mean()), [tuple(pts[i]) for i in face], col + (alpha,)))
    return polys


def draw_floor(draw, cam, floor_y=0.0, span=8, step=1.0):
    cx = round((cam.pos[0] + cam.f[0] * 6) / step) * step
    cz = round((cam.pos[2] + cam.f[2] * 6) / step) * step
    for i in range(-span, span + 1):
        for a, b in (((cx + i * step, floor_y, cz - span * step), (cx + i * step, floor_y, cz + span * step)), ((cx - span * step, floor_y, cz + i * step), (cx + span * step, floor_y, cz + i * step))):
            pts, z = cam.project(np.array([a, b], dtype=float))
            if (z > 0.05).all():
                draw.line([tuple(pts[0]), tuple(pts[1])], fill=(55, 60, 68, 255), width=1)


def render(clip, times, cam, ghosts=(), trail=None, label=None, root=None):
    from PIL import Image, ImageDraw
    img = Image.new('RGBA', (cam.w, cam.h), (32, 36, 42, 255))
    layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_floor(d, cam)
    polys = []
    for i, gt in enumerate(ghosts):
        a = int(40 + 60 * (i + 1) / max(1, len(ghosts)))
        polys += box_polys(world_parts(clip, gt, root), cam, alpha=a, tint=(170, 180, 200))
    ld = ImageDraw.Draw(layer)
    for _, pts, col in sorted(polys, key=lambda e: -e[0]):
        ld.polygon(pts, fill=col)
    img = Image.alpha_composite(img, layer)
    d = ImageDraw.Draw(img)
    parts = world_parts(clip, times, root)
    for _, pts, col in sorted(box_polys(parts, cam), key=lambda e: -e[0]):
        d.polygon(pts, fill=col, outline=(20, 20, 24, 255))
    if trail:
        name, ts = trail
        pts, _ = cam.project(np.array([tip_point(world_parts(clip, tt, root), name) for tt in ts]))
        for k in range(len(pts)):
            if k:
                d.line([tuple(pts[k - 1]), tuple(pts[k])], fill=(255, 90, 90, 255), width=1)
        for q in pts:
            d.ellipse([q[0] - 2.5, q[1] - 2.5, q[0] + 2.5, q[1] + 2.5], fill=(255, 235, 90, 255))
    if label:
        d.rectangle([0, 0, 8 + 6 * len(label), 14], fill=(0, 0, 0, 255))
        d.text((4, 2), label, fill=(255, 230, 90, 255))
    return img.convert('RGB')


def frame_times(clip, fps, start, end):
    end = clip['len'] if end is None else end
    n = int(round((end - start) * fps))
    return [start + i / fps for i in range(n + 1)]


def make_camera(view, w, h, dist, fov, yaw=None, pitch=None, target=(0, 2.4, 0)):
    y0, p0 = VIEWS.get(view, (90, 5))
    return Camera(yaw if yaw is not None else y0, pitch if pitch is not None else p0, dist, target, fov, w, h)


def contact_sheet(images, cols, path):
    from PIL import Image
    w, h = images[0].size
    rows = (len(images) + cols - 1) // cols
    sheet = Image.new('RGB', (w * cols, h * rows), (0, 0, 0))
    for i, im in enumerate(images):
        sheet.paste(im, ((i % cols) * w, (i // cols) * h))
    sheet.save(path, quality=90)


def write_video(images, fps, path):
    ff = shutil.which('ffmpeg')
    if not ff:
        try:
            import imageio_ffmpeg
            ff = imageio_ffmpeg.get_ffmpeg_exe()
        except ImportError:
            print('no ffmpeg; skipped the video')
            return
    tmp = Path(path).with_suffix('')
    tmp.mkdir(parents=True, exist_ok=True)
    for i, im in enumerate(images):
        im.save(tmp / f'{i:05d}.png')
    subprocess.run([ff, '-y', '-hide_banner', '-loglevel', 'error', '-framerate', str(fps), '-i', str(tmp / '%05d.png'),
                    '-pix_fmt', 'yuv420p', '-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2', str(path)], check=True)
    shutil.rmtree(tmp)


def main():
    ap = argparse.ArgumentParser(description='render ReadClips or Poser.dump decode text as an R6 box figure')
    ap.add_argument('decode')
    ap.add_argument('out')
    ap.add_argument('--view', default='side', help='side front rear rear34 front34 top low, or comma separated')
    ap.add_argument('--yaw', type=float)
    ap.add_argument('--pitch', type=float)
    ap.add_argument('--dist', type=float, default=11)
    ap.add_argument('--fov', type=float, default=50)
    ap.add_argument('--size', default='320x240')
    ap.add_argument('--fps', type=float, default=60)
    ap.add_argument('--every', type=int, default=2, help='sheet every nth frame')
    ap.add_argument('--times', help='comma separated seconds for the sheet instead of --every')
    ap.add_argument('--cols', type=int, default=8)
    ap.add_argument('--from', dest='start', type=float, default=0.0)
    ap.add_argument('--to', dest='end', type=float)
    ap.add_argument('--onion', type=int, default=0, help='ghost this many earlier frames behind each cell')
    ap.add_argument('--trail', help='part whose tip is traced one dot per frame, e.g. "Right Arm"')
    ap.add_argument('--video', action='store_true')
    ap.add_argument('--follow', action='store_true', help='keep the camera on the torso when the clip travels or leaves the floor')
    a = ap.parse_args()

    clip = read_decode(a.decode)
    if not clip['joints']:
        sys.exit('no R6 joints in the decode')
    w, h = (int(v) for v in a.size.split('x'))
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    all_t = frame_times(clip, a.fps, a.start, a.end)
    picks = [float(x) for x in a.times.split(',')] if a.times else all_t[::max(1, a.every)]
    made = []
    def cam_at(view, t):
        target = (0, 2.4, 0)
        if a.follow:
            c = world_parts(clip, t)['Torso'][1]
            target = (c[0], max(2.4, c[1] - 0.6), c[2])
        return make_camera(view, w, h, a.dist, a.fov, a.yaw, a.pitch, target)

    for view in a.view.split(','):
        cam = cam_at(view, picks[0])
        cells = []
        for t in picks:
            cam = cam_at(view, t)
            ghosts = [t - k / a.fps * max(1, a.every) for k in range(a.onion, 0, -1) if t - k / a.fps * max(1, a.every) >= a.start]
            trail = (a.trail, [x for x in all_t if x <= t + 1e-9]) if a.trail else None
            cells.append(render(clip, t, cam, ghosts, trail, f'{t:.3f}s f{int(round(t * 60))}'))
        sheet = out / f"{clip['name']}_{view}.jpg"
        contact_sheet(cells, a.cols, sheet)
        made.append(sheet.name)
        if a.trail:
            full = render(clip, picks[-1], cam, [], (a.trail, all_t), f"{a.trail} path, one dot per frame")
            p = out / f"{clip['name']}_{view}_trail.png"
            full.save(p)
            made.append(p.name)
        if a.video:
            v = out / f"{clip['name']}_{view}.mp4"
            write_video([render(clip, t, cam_at(view, t), label=f'{t:.2f}s') for t in all_t], a.fps, v)
            made.append(v.name)
    print('\n'.join(made))


if __name__ == '__main__':
    main()
