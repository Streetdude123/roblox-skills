import importlib.util
import math
import os
from pathlib import Path
import shutil
import sys

import pytest

np = pytest.importorskip('numpy')
pytest.importorskip('PIL')

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / 'roblox-r6-animation/scripts'
sys.path.insert(0, str(SCRIPTS))


def load(name):
    spec = importlib.util.spec_from_file_location(name, SCRIPTS / f'{name}.py')
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


rr = load('r6_render')
bt = load('bvh_to_r6')
beats = load('beats')
sty = load('stylize')
fc = load('feet_check')
po = load('poser_offline')

JOINTS = ('Torso', 'Head', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg')


def write_decode(path, name, frames):
    lines = [f'#{name} len={(len(frames) - 1) / 60:.3f} loop=false frames={len(frames)} prio=Action']
    for i, pose in enumerate(frames):
        for j in JOINTS:
            l, t, s = pose.get(j, (0, 0, 0))
            lines.append(f'{name}|{j}|{i / 60:.3f}|{l:.1f}|{t:.1f}|{s:.1f}|0.00|0.00|0.00|Linear|In')
    path.write_text('\n'.join(lines) + '\n')
    return path


def test_neutral_r6_stands_on_the_floor(tmp_path):
    clip = rr.read_decode(write_decode(tmp_path / 'n.txt', 'N', [{}, {}]))
    parts = rr.world_parts(clip, 0)
    assert np.allclose(parts['Head'][1], [0, 4.5, 0])
    assert np.allclose(parts['Right Arm'][1], [1.5, 3, 0])
    assert np.allclose(parts['Left Leg'][1], [-0.5, 1, 0])
    assert abs(rr.tip_point(parts, 'Right Leg')[1]) < 1e-9


def test_positive_lift_raises_the_arm_forward(tmp_path):
    clip = rr.read_decode(write_decode(tmp_path / 'a.txt', 'A', [{'Right Arm': (90, 0, 0)}] * 2))
    tip = rr.tip_point(rr.world_parts(clip, 0), 'Right Arm')
    assert np.allclose(tip, [1.5, 3.5, -1.5])


def test_render_draws_a_frame_of_the_requested_size(tmp_path):
    clip = rr.read_decode(write_decode(tmp_path / 'r.txt', 'R', [{}, {}]))
    cam = rr.make_camera('rear34', 160, 120, 9, 50)
    img = rr.render(clip, 0, cam, trail=('Right Arm', [0, 1 / 60]))
    assert img.size == (160, 120)


BVH = """HIERARCHY
ROOT Hips
{
  OFFSET 0 0 0
  CHANNELS 6 Xposition Yposition Zposition Zrotation Xrotation Yrotation
  JOINT Chest
  {
    OFFSET 0 30 0
    CHANNELS 3 Zrotation Xrotation Yrotation
    JOINT Neck
    {
      OFFSET 0 20 0
      CHANNELS 3 Zrotation Xrotation Yrotation
      JOINT Head
      {
        OFFSET 0 10 0
        CHANNELS 3 Zrotation Xrotation Yrotation
        End Site
        {
          OFFSET 0 10 0
        }
      }
    }
    JOINT UpperArm_L
    {
      OFFSET 18 18 0
      CHANNELS 3 Zrotation Xrotation Yrotation
      JOINT LowerArm_L
      {
        OFFSET 0 -28 0
        CHANNELS 3 Zrotation Xrotation Yrotation
        JOINT Hand_L
        {
          OFFSET 0 -26 0
          CHANNELS 3 Zrotation Xrotation Yrotation
          End Site
          {
            OFFSET 0 -8 0
          }
        }
      }
    }
    JOINT UpperArm_R
    {
      OFFSET -18 18 0
      CHANNELS 3 Zrotation Xrotation Yrotation
      JOINT LowerArm_R
      {
        OFFSET 0 -28 0
        CHANNELS 3 Zrotation Xrotation Yrotation
        JOINT Hand_R
        {
          OFFSET 0 -26 0
          CHANNELS 3 Zrotation Xrotation Yrotation
          End Site
          {
            OFFSET 0 -8 0
          }
        }
      }
    }
  }
  JOINT UpperLeg_L
  {
    OFFSET 9 -5 0
    CHANNELS 3 Zrotation Xrotation Yrotation
    JOINT LowerLeg_L
    {
      OFFSET 0 -42 0
      CHANNELS 3 Zrotation Xrotation Yrotation
      JOINT Foot_L
      {
        OFFSET 0 -42 0
        CHANNELS 3 Zrotation Xrotation Yrotation
        JOINT Toes_L
        {
          OFFSET 0 -6 12
          CHANNELS 3 Zrotation Xrotation Yrotation
          End Site
          {
            OFFSET 0 0 4
          }
        }
      }
    }
  }
  JOINT UpperLeg_R
  {
    OFFSET -9 -5 0
    CHANNELS 3 Zrotation Xrotation Yrotation
    JOINT LowerLeg_R
    {
      OFFSET 0 -42 0
      CHANNELS 3 Zrotation Xrotation Yrotation
      JOINT Foot_R
      {
        OFFSET 0 -42 0
        CHANNELS 3 Zrotation Xrotation Yrotation
        JOINT Toes_R
        {
          OFFSET 0 -6 12
          CHANNELS 3 Zrotation Xrotation Yrotation
          End Site
          {
            OFFSET 0 0 4
          }
        }
      }
    }
  }
}
MOTION
Frames: 2
Frame Time: 0.0333333
"""


def bvh_frame(right_arm_x=0.0):
    vals = [0, 95, 0, 0, 0, 0] + [0, 0, 0] * 3
    vals += [0, 0, 0] * 3
    vals += [0, right_arm_x, 0] + [0, 0, 0] * 2
    vals += [0, 0, 0] * 8
    return ' '.join(str(v) for v in vals)


def test_bvh_retarget_keeps_a_neutral_stand_and_maps_a_forward_arm(tmp_path):
    path = tmp_path / 'stand.bvh'
    path.write_text(BVH + bvh_frame() + '\n' + bvh_frame(-90) + '\n')
    frames, dt, info = bt.retarget(str(path))
    assert info['mirrored'] is False
    first = frames[0]
    for name in ('Torso', 'Left Arm', 'Left Leg', 'Right Leg'):
        lift, twist, side = bt.euler(first[name][0])
        assert abs(lift) < 3 and abs(side) < 3, (name, lift, twist, side)
    lift, _, _ = bt.euler(frames[1]['Right Arm'][0])
    assert abs(lift - 90) < 5
    samples, length = bt.resample(frames, dt, 60)
    text = bt.decode_text('Stand', samples, 60, length)
    assert text.startswith('#Stand len=0.033')
    lua, counts = bt.lua_clip('Stand', samples, 60, length)
    assert 'curve = "spline"' in lua and '["Right Arm"] = {' in lua
    assert set(counts) == set(JOINTS)


def test_asf_amc_bone_turns_about_its_axis(tmp_path):
    asf = tmp_path / 's.asf'
    asf.write_text(""":units
  length 1
  angle deg
:root
   order TX TY TZ RX RY RZ
   axis XYZ
   position 0 0 0
   orientation 0 0 0
:bonedata
  begin
     id 1
     name a
     direction 0 -1 0
     length 2
     axis 0 0 0 XYZ
    dof rx
  end
:hierarchy
  begin
    root a
  end
""")
    amc = tmp_path / 's.amc'
    amc.write_text(':FULLY-SPECIFIED\n:DEGREES\n1\nroot 0 0 0 0 0 0\na 0\n2\nroot 0 0 0 0 0 0\na 90\n')
    bones, order = bt.parse_asf(asf)
    pos, _ = bt.parse_amc(amc, bones, order)
    assert np.allclose(pos['a'][0], [0, -2, 0])
    assert np.allclose(pos['a'][1], [0, 0, -2], atol=1e-9)


def test_beats_finds_a_move_a_hold_and_a_return(tmp_path):
    frames = []
    for i in range(80):
        if i < 10:
            lift = 90 * (i / 10)
        elif i < 40:
            lift = 90
        elif i < 50:
            lift = 90 * (1 - (i - 40) / 10)
        else:
            lift = 0
        frames.append({'Right Arm': (lift, 0, 0)})
    r = beats.analyze(write_decode(tmp_path / 'b.txt', 'B', frames), local=True)
    tip = r['tips']['Right Arm']
    assert tip['summary']['moves'] == 2
    assert tip['holds'] and tip['holds'][0]['frames'] >= 25


def test_quaternion_log_and_exp_round_trip():
    rng = np.random.default_rng(1)
    for _ in range(50):
        v = rng.normal(size=3)
        v = v / np.linalg.norm(v) * rng.uniform(0, 3)
        q = sty.qexp(v)
        assert np.allclose(sty.qlog(q), v, atol=1e-9)


def test_slow_in_slow_out_warp_keeps_the_key_frames_and_order():
    ts = sty.siso_times([0, 10, 30], 1.0)
    assert ts[0] == 0 and ts[10] == 10 and ts[-1] == 30
    assert np.all(np.diff(ts) >= -1e-12)
    assert ts[1] - ts[0] < ts[5] - ts[4]


def test_neutral_stylize_changes_nothing():
    samples = [{n: (rr.pose_matrix(10 * math.sin(i / 5), 5, -3), np.zeros(3)) for n in JOINTS} for i in range(40)]
    tracks = sty.split(samples)
    same = sty.stylize_tracks(tracks, 60, amp=0.0, gain=1.0)
    for n in JOINTS:
        a, b = tracks[n][0], same[n][0]
        assert np.allclose(np.abs(np.sum(a * b, axis=1)), 1, atol=1e-9)


def test_feet_check_passes_a_neutral_stand(tmp_path):
    clip = rr.read_decode(write_decode(tmp_path / 's.txt', 'S', [{}, {}, {}]))
    for r in fc.feet(clip).values():
        assert abs(r['low']) < 1e-9 and abs(r['high']) < 1e-9
        assert r['slide'] < 1e-9 and r['gap'] < 1e-9 and r['twist'] < 1e-9


def test_feet_check_sees_a_sinking_twisted_leg(tmp_path):
    clip = rr.read_decode(write_decode(tmp_path / 'k.txt', 'K', [{'Right Leg': (0, 40, 10)}] * 2))
    r = fc.feet(clip)['Right Leg']
    assert r['low'] < -0.1 and 35 < r['twist'] < 45 and r['gap'] < 1e-9


def test_poser_offline_wraps_every_required_module():
    src = po.entry(SCRIPTS / 'ExampleClips.lua')
    for name in ('ExampleClips', 'Feet', 'Poser', 'Tw'):
        assert f'mods["{name}"] = function(script, require)' in src
    assert 'local MAIN = "ExampleClips"' in src


def test_poser_offline_reads_checks_and_decodes():
    out = po.parse('@@check A len=0.500 frozen=0.00 still=1.00 longest=0.017 rest=20.00 stops=1.000 unison=0.000 contrast=3.000 spread=0.500\n'
                   '@@dump A\n#A len=0.500 loop=false frames=1 prio=Action\nA|Torso|0.000|0.0|0.0|0.0|0.00|0.00|0.00|Linear|In\n@@end\n')
    assert out['A']['check']['contrast'] == 3.0
    assert out['A']['decode'].startswith('#A len=0.500')


LUAU = os.environ.get('LUAU') or shutil.which('luau')


@pytest.mark.skipif(not LUAU, reason='needs the luau cli (set LUAU or put luau on PATH)')
def test_example_clips_pass_offline(tmp_path):
    clips = po.run(SCRIPTS / 'ExampleClips.lua', luau=LUAU)
    c = clips['Cross']['check']
    assert c['frozen'] == 0 and c['still'] == 0 and c['rest'] <= 45 and 2 <= c['contrast'] <= 10
    assert clips['Guard']['check']['frozen'] == 0
    for name in ('Cross', 'Guard'):
        path = tmp_path / f'{name}.txt'
        path.write_text(clips[name]['decode'])
        for r in fc.feet(rr.read_decode(path)).values():
            assert abs(r['low']) <= 0.03 and r['slide'] <= 0.05 and r['gap'] <= 0.12


@pytest.mark.skipif(not LUAU, reason='needs the luau cli (set LUAU or put luau on PATH)')
def test_example_throw_peaks_on_the_whip_offline(tmp_path):
    c = po.run(SCRIPTS / 'ExampleThrow.lua', luau=LUAU)['Throw']
    assert c['check']['frozen'] == 0 and c['check']['still'] == 0 and c['check']['spread'] < 2
    path = tmp_path / 'Throw.txt'
    path.write_text(c['decode'])
    feet = fc.feet(rr.read_decode(path))
    assert feet['Right Leg']['low'] >= -0.03 and feet['Right Leg']['high'] <= 0.03
    for r in feet.values():
        assert r['low'] >= -0.03 and r['slide'] <= 0.05 and r['gap'] <= 0.12 and r['twist'] <= 50
