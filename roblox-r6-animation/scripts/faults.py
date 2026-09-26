import argparse
import math
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
import r6_render as rr
import feet_check as fc

JOINTS = ['Torso', 'Head', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg']
MIRROR = np.diag([-1.0, 1.0, 1.0])
CORNERS = [np.array(c, dtype=float) for c in ((0.5, -1, 0.5), (-0.5, -1, 0.5), (0.5, -1, -0.5), (-0.5, -1, -0.5))]


def angle(a, b):
    return math.degrees(math.acos(max(-1.0, min(1.0, (np.trace(a.T @ b) - 1) / 2))))


def runs(mask, min_len):
    out, start = [], None
    for i, m in enumerate(list(mask) + [False]):
        if m and start is None:
            start = i
        if not m and start is not None:
            if i - start >= min_len:
                out.append((start, i - 1))
            start = None
    return out


def frames(clip, fps):
    times = rr.frame_times(clip, fps, 0.0, None)
    local, world = [], []
    for t in times:
        local.append({j: rr.sample(clip['joints'].get(j, []), t) for j in JOINTS})
        world.append(rr.world_parts(clip, t))
    return times, local, world


def speeds(world, fps, win=2):
    n = len(world)
    out = {j: np.zeros(n) for j in JOINTS}
    for j in JOINTS:
        for i in range(n):
            a, b = max(0, i - win), min(n - 1, i + win)
            if b > a:
                ra, pa, _ = world[a][j]
                rb, pb, _ = world[b][j]
                out[j][i] = (angle(ra, rb) + 30 * np.linalg.norm(pb - pa)) * fps / (b - a)
    return out


def smears(path, fps=60.0, width=1.0):
    clip = rr.read_decode(path)
    times = rr.frame_times(clip, fps, 0.0, None)
    world = [rr.world_parts(clip, t) for t in times]
    out = []
    for j in ['Right Arm', 'Left Arm', 'Right Leg', 'Left Leg'] + [k for k in rr.PROPS if k in world[0]]:
        tips = np.array([rr.tip_point(w, j) for w in world])
        step = np.linalg.norm(np.diff(tips, axis=0), axis=1)
        for a, b in runs(step > width, 1):
            out.append({'part': j, 'from': round(times[a], 3), 'to': round(times[b + 1], 3), 'jump': round(float(step[a:b + 1].max()), 2),
                        'path': [[round(float(v), 2) for v in tips[i]] for i in range(a, b + 2)]})
    return sorted(out, key=lambda e: (e['from'], e['part']))


def find(path, fps=60.0, pop=90.0, twin=8.0, loop=None, feet=True, flat=55.0, twist=60.0, strike=None, view='rear34', travel=0.0):
    clip = rr.read_decode(path)
    head = Path(path).read_text(encoding='utf-8').splitlines()[0]
    if loop is None:
        loop = 'loop=true' in head
    times, local, world = frames(clip, fps)
    n = len(times)
    out = []

    def add(kind, a, b, text):
        out.append({'kind': kind, 'from': round(times[a], 3), 'to': round(times[b], 3), 'text': text})

    props = [k for k in rr.PROPS if k in world[0]]
    for j in JOINTS + props:
        for i in range(1, n):
            d = angle(world[i - 1][j][0], world[i][j][0])
            if d > pop:
                add('pop', i - 1, i, f'{j} turns {d:.0f} deg in one frame: it needs a smear or an in-between')

    ang = np.array([angle(l['Right Arm'][0], MIRROR @ l['Left Arm'][0] @ MIRROR) for l in local])
    away = np.array([min(angle(l['Right Arm'][0], np.eye(3)), angle(l['Left Arm'][0], np.eye(3))) for l in local])
    for a, b in runs((ang < twin) & (away > 25), int(0.25 * fps)):
        add('twinning', a, b, f'the arms mirror each other within {twin:.0f} deg: offset one in pose or time')

    v = speeds(world, fps)
    lean = np.array([abs(math.degrees(math.asin(max(-1.0, min(1.0, w['Torso'][0][2, 1]))))) for w in world])
    for j in ('Right Arm', 'Left Arm'):
        down = np.array([math.degrees(math.acos(max(-1.0, min(1.0, w[j][0][1, 1])))) for w in world])
        for a, b in runs((down < 15) & (v[j] < 20) & (lean > 15), int(0.4 * fps)):
            add('dead arm', a, b, f'{j} hangs straight down and still under a {lean[a:b + 1].mean():.0f} deg lean: key it forward by the lean or give it a job')

    neutral = []
    for l in local:
        rot = max(angle(l[j][0], np.eye(3)) for j in JOINTS)
        off = max(float(np.linalg.norm(l[j][1])) for j in JOINTS)
        neutral.append(rot < 12 and off < 0.1)
    edge = int(0.1 * fps)
    for a, b in runs([m and edge <= i < n - edge for i, m in enumerate(neutral)], 3):
        add('neutral pose', a, b, 'every joint is within 12 deg of the default stand: no key should be neutral')

    body = sum(v[j] for j in JOINTS)
    if not loop and n > 10:
        peak = int(np.argmax(body)) if strike is None else min(n - 1, int(round(strike * fps)))
        for j in ('Torso', 'Right Arm', 'Left Arm'):
            pk = int(np.argmax(v[j]))
            if v[j][pk] < 60 or abs(pk - peak) <= 6:
                continue
            near = v[j][max(0, peak - 3):peak + 4].max()
            if v[j][pk] > 0.9 * near:
                add('outruns the strike', pk, pk, f'{j} is fastest at {times[pk]:.2f} s, not at the strike {times[peak]:.2f} s ({v[j][pk]:.0f} against {near:.0f}): slow the wind-up or the recovery')
        if peak >= 3:
            limb = max(('Right Arm', 'Left Arm', 'Right Leg', 'Left Leg'), key=lambda j: v[j][max(0, peak - 2):peak + 3].max())
            cam = rr.make_camera(view, 240, 200, 9, 50)
            _, first = rr.part_pixels(world[0], cam)
            best = None
            for k in range(peak, min(n, peak + 7)):
                seen, now = rr.part_pixels(world[k], cam)
                overlap = float((first & now).sum()) / max(1, int((first | now).sum()))
                if best is None or overlap < best[1]:
                    best = (k, overlap, seen)
            k, overlap, seen = best
            alone, _ = rr.part_pixels(world[k], cam, only=limb)
            shown = seen[limb] / max(1, alone[limb])
            if shown < 0.2 and overlap > 0.7:
                add('hidden strike', k, k, f'from the {view} camera the {limb} shows {100 * shown:.0f}% and the body keeps {100 * overlap:.0f}% of its first silhouette: move the strike out of the body or change the body more')
            elif overlap > 0.75:
                add('small silhouette change', k, k, f'from the {view} camera the strike pose keeps {100 * overlap:.0f}% of the first silhouette (pro strikes 46 to 67%): push the pose')

    for j in ['Right Arm', 'Left Arm', 'Head', 'Torso'] + props:
        low = []
        for w in world:
            r, p, size = w[j]
            h = np.array(size, dtype=float) / 2
            pts = [p + r @ (h * np.array(c)) for c in ((1, -1, 1), (-1, -1, 1), (1, -1, -1), (-1, -1, -1), (1, 1, 1), (-1, 1, 1), (1, 1, -1), (-1, 1, -1))]
            low.append(min(float(q[1]) for q in pts))
        for a, b in runs([y < -0.05 for y in low], 1):
            add('through the floor', a, b, f'{j} goes {-min(low[a:b + 1]):.2f} below the floor')

    if not feet:
        return clip['name'], sorted(out, key=lambda f: (f['from'], f['kind']))
    lowest = {leg: [] for leg in fc.LEGS}
    for w in world:
        for leg in fc.LEGS:
            r, p, _ = w[leg]
            lowest[leg].append(min(float((p + r @ c)[1]) for c in CORNERS))
    for leg, s in fc.LEGS.items():
        if min(lowest[leg]) > 0.3:
            continue
        planted = [h < 0.06 for h in lowest[leg]]
        tilt, turn = [], []
        for w in world:
            r, _, _ = w[leg]
            d = -r[:, 1]
            tilt.append(math.degrees(math.acos(max(-1.0, min(1.0, -d[1])))))
            turn.append(abs((fc.yaw_of(r) - fc.yaw_of(w['Torso'][0]) + 180) % 360 - 180))
        for a, b in runs([p and t > flat for p, t in zip(planted, tilt)], 2):
            add('flat leg', a, b, f'{leg} lies {max(tilt[a:b + 1]):.0f} deg from vertical while planted: bring the foot under the hip (fine for a kneel)')
        for a, b in runs([p and t <= flat and tw > twist for p, t, tw in zip(planted, tilt, turn)], 2):
            add('leg twist', a, b, f'{leg} toe is {max(turn[a:b + 1]):.0f} deg off the torso heading while planted: pivot the foot with the hips')
    res = fc.feet(clip, fps, travel=travel)
    for leg, r in res.items():
        if min(lowest[leg]) > 0.3:
            continue
        if r['gap'] > 0.12:
            add('hip gap', 0, n - 1, f"{leg} opens {r['gap']:.2f} at the hip: lower the torso or bring the foot closer")
        if r['slide'] > 0.05:
            add('foot slide', 0, n - 1, f"{leg} slides {r['slide']:.2f} while planted")
    return clip['name'], sorted(out, key=lambda f: (f['from'], f['kind']))


def main():
    ap = argparse.ArgumentParser(description='flag common animation faults in R6 decode text')
    ap.add_argument('decodes', nargs='+')
    ap.add_argument('--pop', type=float, default=90.0, help='degrees in one frame that count as a pop')
    ap.add_argument('--twin', type=float, default=8.0, help='arms closer than this to a mirror image count as twinning')
    ap.add_argument('--flat', type=float, default=55.0, help='a planted leg further than this from vertical is flat')
    ap.add_argument('--twist', type=float, default=60.0, help='a planted toe further than this off the torso heading is twisted')
    ap.add_argument('--float', action='store_true', help='a stand or any rig whose feet do not touch the floor: skip the foot checks')
    ap.add_argument('--strike', type=float, help='seconds of the strike or contact; default the fastest whole-body moment')
    ap.add_argument('--view', default='rear34', help='camera for the staging checks: rear34 (the player), side, front34 and the other r6_render views')
    ap.add_argument('--travel', type=float, default=0.0, help='studs a second the root moves forward in the game (a walk or run cycle played in place)')
    ap.add_argument('--smears', type=float, nargs='?', const=1.0, help='also list the frames where a tip jumps more than this many studs (default 1, a limb\'s width): each needs a smear, with the tip path in world space')
    a = ap.parse_args()
    for p in a.decodes:
        name, found = find(p, pop=a.pop, twin=a.twin, feet=not a.float, flat=a.flat, twist=a.twist, strike=a.strike, view=a.view, travel=a.travel)
        print(f'{name}: {len(found)} found')
        for f in found:
            span = f"{f['from']:.2f}" if f['from'] == f['to'] else f"{f['from']:.2f}-{f['to']:.2f}"
            print(f"  {span:>11}  {f['kind']:18} {f['text']}")
        if a.smears:
            for m in smears(p, width=a.smears):
                print(f"  {m['from']:.2f}-{m['to']:.2f}  smear              {m['part']} tip jumps up to {m['jump']} studs a frame; path {m['path']}")


if __name__ == '__main__':
    main()
