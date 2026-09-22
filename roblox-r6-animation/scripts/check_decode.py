"""Measure rounded ReadClips.lua exports without treating measurements as quality scores."""

import argparse
import json
import math
from pathlib import Path
import re
import sys


HEADER = re.compile(
    r"#(?P<name>.+?) len=(?P<length>\S+) loop=(?P<loop>true|false) "
    r"frames=(?P<frames>\d+) prio=(?P<priority>\S+)"
)


def matmul(a, b):
    return tuple(tuple(sum(a[i][k] * b[k][j] for k in range(3))
                       for j in range(3)) for i in range(3))


def rotation(angles):
    lift, twist, side = map(math.radians, angles)
    x, sx = math.cos(lift), math.sin(lift)
    y, sy = math.cos(twist), math.sin(twist)
    z, sz = math.cos(side), math.sin(side)
    rx = ((1, 0, 0), (0, x, -sx), (0, sx, x))
    ry = ((y, 0, sy), (0, 1, 0), (-sy, 0, y))
    rz = ((z, -sz, 0), (sz, z, 0), (0, 0, 1))
    return matmul(matmul(rz, rx), ry)


def rotation_distance(a, b):
    trace = sum(a[i][j] * b[i][j] for i in range(3) for j in range(3))
    return math.degrees(math.acos(max(-1.0, min(1.0, (trace - 1) / 2))))


def distance(a, b):
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))


def velocity(a, b):
    return tuple((y - x) / (b['time'] - a['time'])
                 for x, y in zip(a['position'], b['position']))


def read_decode(path):
    lines = path.read_text(encoding='utf-8').splitlines()
    if not lines or not (match := HEADER.fullmatch(lines[0])):
        raise ValueError('expected the ReadClips header on line 1')
    meta = match.groupdict()
    length = float(meta['length'])
    if not math.isfinite(length) or length < 0:
        raise ValueError('duration must be finite and nonnegative')
    tracks, markers = {}, []
    for line_number, line in enumerate(lines[1:], 2):
        if not line.strip():
            continue
        fields = line.split('|')
        if len(fields) < 4 or fields[0] != meta['name']:
            raise ValueError(f'line {line_number}: invalid clip row')
        time = float(fields[2])
        if not math.isfinite(time) or time < 0 or time > length + 0.001:
            raise ValueError(f'line {line_number}: time outside clip bounds')
        if fields[1] == 'MARKER':
            markers.append({'time': time, 'payload': '|'.join(fields[3:])})
            continue
        if len(fields) != 11 or not fields[1] or not fields[9] or not fields[10]:
            raise ValueError(f'line {line_number}: expected 11 pose fields')
        values = tuple(map(float, fields[3:9]))
        if not all(map(math.isfinite, values)):
            raise ValueError(f'line {line_number}: nonfinite pose value')
        keys = tracks.setdefault(fields[1], [])
        if keys and time <= keys[-1]['time']:
            raise ValueError(f'line {line_number}: joint times must strictly increase')
        keys.append({'time': time, 'rotation': rotation(values[:3]),
                     'position': values[3:], 'easing': fields[9],
                     'direction': fields[10]})
    if not tracks:
        raise ValueError('no pose tracks')
    return {'name': meta['name'], 'duration': length, 'loop': meta['loop'] == 'true',
            'declared_frames': int(meta['frames']), 'priority': meta['priority'],
            'tracks': tracks, 'markers': markers}


def summarize(clip):
    joints = {}
    warnings = []
    for name, keys in sorted(clip['tracks'].items()):
        first, last = keys[0], keys[-1]
        intervals = list(zip(keys, keys[1:]))
        covers = abs(first['time']) <= 0.001 and abs(last['time'] - clip['duration']) <= 0.001
        easing = sorted({k['easing'] for k in keys})
        seam = None
        if clip['loop'] and covers and len(keys) >= 2:
            seam = {
                'position_studs': distance(first['position'], last['position']),
                'rotation_degrees': rotation_distance(first['rotation'], last['rotation']),
                'translation_velocity_delta_studs_per_second': distance(
                    velocity(keys[0], keys[1]), velocity(keys[-2], keys[-1])),
            }
        joints[name] = {
            'samples': len(keys), 'first_time': first['time'], 'last_time': last['time'],
            'covers_clip': covers, 'easing': easing,
            'max_sample_gap_seconds': max((b['time'] - a['time'] for a, b in intervals), default=0),
            'max_sample_rotation_step_degrees': max(
                (rotation_distance(a['rotation'], b['rotation']) for a, b in intervals), default=0),
            'endpoint_position_delta_studs': distance(first['position'], last['position']),
            'endpoint_rotation_delta_degrees': rotation_distance(first['rotation'], last['rotation']),
            'loop_seam': seam,
        }
        if not covers:
            warnings.append(f'{name}: samples do not cover both clip boundaries')
        if any(e != 'Linear' for e in easing):
            warnings.append(f'{name}: source easing is discarded by Poser.fromSequence')
        if len(keys) < 3:
            warnings.append(f'{name}: insufficient samples to assess boundary motion')
    if clip['markers']:
        warnings.append('Poser.fromSequence does not preserve these markers')
    return {'name': clip['name'], 'duration': clip['duration'], 'loop': clip['loop'],
            'declared_frames': clip['declared_frames'], 'priority': clip['priority'],
            'markers': clip['markers'], 'joints': joints, 'warnings': warnings,
            'limits': ['Local rounded pose samples only; no rig geometry or world contacts.',
                       'No pose weights, exact native interpolation, or angular velocity test.',
                       'Sample gaps can hide motion; zero seam error is not a quality verdict.']}


def format_report(report):
    lines = [f"{report['name']}: {report['duration']:.3f}s loop={report['loop']}",
             'joint | samples | max gap s | endpoint studs | endpoint degrees']
    for name, joint in report['joints'].items():
        lines.append(f"{name} | {joint['samples']} | {joint['max_sample_gap_seconds']:.3f} | "
                     f"{joint['endpoint_position_delta_studs']:.4f} | "
                     f"{joint['endpoint_rotation_delta_degrees']:.3f}")
        if joint['loop_seam'] is not None:
            delta = joint['loop_seam']['translation_velocity_delta_studs_per_second']
            lines.append(f'  local translation velocity mismatch: {delta:.4f} studs/s')
    lines.extend('note: ' + warning for warning in report['warnings'])
    lines.extend('limit: ' + limit for limit in report['limits'])
    return '\n'.join(lines)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('files', nargs='+', type=Path)
    parser.add_argument('--json', action='store_true', help='emit measurements as JSON')
    args = parser.parse_args(argv)
    reports = []
    for path in args.files:
        try:
            reports.append({'file': str(path), **summarize(read_decode(path))})
        except (OSError, ValueError) as exc:
            print(f'{path}: {exc}', file=sys.stderr)
            return 1
    if args.json:
        print(json.dumps(reports, indent=2, allow_nan=False))
    else:
        print('\n\n'.join(format_report(report) for report in reports))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
