import argparse
import math
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
import r6_render as rr

LEGS = {'Right Leg': 1, 'Left Leg': -1}
CORNERS = [np.array(c, dtype=float) for c in ((0.5, -1, 0.5), (-0.5, -1, 0.5), (0.5, -1, -0.5), (-0.5, -1, -0.5))]


def yaw_of(r):
    f = r @ np.array([0, 0, -1.0])
    return math.degrees(math.atan2(-f[0], -f[2]))


def feet(clip, fps=60.0, planted=0.06):
    out = {leg: {'low': math.inf, 'high': -math.inf, 'slide': 0.0, 'gap': 0.0, 'twist': 0.0} for leg in LEGS}
    anchor = {}
    for t in rr.frame_times(clip, fps, 0.0, None):
        parts = rr.world_parts(clip, t)
        tr, tp, _ = parts['Torso']
        for leg, s in LEGS.items():
            r, p, _ = parts[leg]
            o = out[leg]
            h = min(float((p + r @ c)[1]) for c in CORNERS)
            o['low'], o['high'] = min(o['low'], h), max(o['high'], h)
            sole = p + r @ np.array([0, -1.0, 0])
            if h < planted:
                anchor.setdefault(leg, sole)
                o['slide'] = max(o['slide'], float(math.hypot(sole[0] - anchor[leg][0], sole[2] - anchor[leg][2])))
            else:
                anchor.pop(leg, None)
            c = tr.T @ (p + r @ np.array([0.5 * s, 1, 0]) - tp)
            o['gap'] = max(o['gap'], max(0.0, -1 - c[1]) + math.hypot(c[0] - s, c[2]))
            o['twist'] = max(o['twist'], abs((yaw_of(r) - yaw_of(tr) + 180) % 360 - 180))
    return out


def text(name, res):
    rows = [f"{leg} lowest corner {r['low']:.2f}..{r['high']:.2f} slide {r['slide']:.2f} hip gap {r['gap']:.2f} twist {r['twist']:.0f}" for leg, r in res.items()]
    return f'{name}: ' + '; '.join(rows)


def main():
    ap = argparse.ArgumentParser(description='planted feet check on R6 decode text: lowest sole corner, slide while planted, hip gap, toe twist')
    ap.add_argument('decodes', nargs='+')
    a = ap.parse_args()
    for p in a.decodes:
        clip = rr.read_decode(p)
        print(text(clip['name'], feet(clip)))


if __name__ == '__main__':
    main()
