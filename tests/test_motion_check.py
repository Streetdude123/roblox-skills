import math
from pathlib import Path
import shutil
import subprocess
import json

import pytest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'roblox-r6-animation/scripts/motion_check.js'
NODE = shutil.which('node')


def write_clip(tmp_path, name, frames):
    lines = [f'#{name} len={(len(frames) - 1) / 60:.3f} loop=false frames={len(frames)} prio=Action']
    for i, angles in enumerate(frames):
        t = i / 60
        for joint, lift in angles.items():
            lines.append(f'{name}|{joint}|{t:.3f}|{lift:.1f}|0.0|0.0|0.00|0.00|0.00|Linear|In')
    path = tmp_path / f'{name}.txt'
    path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    return path


def measure(path):
    out = subprocess.run([NODE, str(SCRIPT), str(path), '--json'], capture_output=True, text=True, check=True)
    return json.loads(out.stdout)[0]


def cubic_in_out(u):
    u = min(1.0, max(0.0, u))
    return 4 * u ** 3 if u < 0.5 else 1 - (-2 * u + 2) ** 3 / 2


JOINTS = ('Torso', 'Head', 'Right Arm', 'Left Arm')


@pytest.mark.skipif(NODE is None, reason='node is not installed')
def test_continuous_motion_has_no_rest_or_stops(tmp_path):
    # every joint swings on a sine with its own phase, so none ever parks
    frames = [{j: 40 * math.sin(2 * math.pi * (i / 60) / 0.8 + k) for k, j in enumerate(JOINTS)} for i in range(61)]
    r = measure(write_clip(tmp_path, 'Flow', frames))
    assert r['stillPct'] == 0
    assert r['stopsPerSec'] == 0
    assert r['unisonPerSec'] == 0


@pytest.mark.skipif(NODE is None, reason='node is not installed')
def test_eased_keys_with_holds_on_shared_frames_stop_together(tmp_path):
    # the dead pattern: every joint eases into the same pose on the same frames, then holds it for 6 frames
    keys = [0, 60, 10, 70, 0]

    def value(t):
        seg = min(int(t / 0.3), 3)
        u = (t - seg * 0.3) / 0.2
        return keys[seg] + (keys[seg + 1] - keys[seg]) * cubic_in_out(u)

    frames = [{j: value(i / 60) for j in JOINTS} for i in range(73)]
    r = measure(write_clip(tmp_path, 'Robot', frames))
    assert r['stillPct'] > 20
    assert r['stopsPerSec'] >= 3
    assert r['unisonPerSec'] >= 3
    assert r['peakSpread'] == 0


@pytest.mark.skipif(NODE is None, reason='node is not installed')
def test_a_held_pose_is_frozen(tmp_path):
    frames = [{j: 20.0 for j in JOINTS} for _ in range(61)]
    r = measure(write_clip(tmp_path, 'Statue', frames))
    assert r['frozenPct'] == 100
    assert r['stillPct'] == 100


@pytest.mark.skipif(NODE is None, reason='node is not installed')
def test_range_and_sweep_measure_how_far_each_joint_turns(tmp_path):
    frames = [{'Torso': 90 * i / 30 if i <= 30 else 90 - 30 * (i - 30) / 30, 'Head': 0.0} for i in range(61)]
    r = measure(write_clip(tmp_path, 'Swing', frames))
    assert abs(r['range']['Torso'] - 90) < 0.5
    assert abs(r['sweep']['Torso'] - 120) < 0.5
    assert r['range']['Head'] == 0
