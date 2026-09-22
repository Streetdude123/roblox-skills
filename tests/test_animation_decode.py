import importlib.util
import json
from pathlib import Path
import subprocess
import sys

import pytest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'roblox-r6-animation/scripts/check_decode.py'
SPEC = importlib.util.spec_from_file_location('animation_decode', SCRIPT)
DECODE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DECODE)


def write_clip(tmp_path, rows, loop=True, length=1):
    path = tmp_path / 'clip.txt'
    path.write_text(f'#Test len={length} loop={str(loop).lower()} frames=3 prio=Idle\n'
                    + '\n'.join(rows) + '\n', encoding='utf-8')
    return path


def row(time, side=0, x=0, easing='Linear'):
    return f'Test|Torso|{time}|0|0|{side}|{x}|0|0|{easing}|In'


def test_euler_wrap_is_short_rotation():
    assert DECODE.rotation_distance(DECODE.rotation((0, 0, 179)),
                                    DECODE.rotation((0, 0, -179))) == pytest.approx(2)


def test_equivalent_euler_branches_match():
    assert DECODE.rotation_distance(DECODE.rotation((100, 0, 0)),
                                    DECODE.rotation((80, 180, 180))) == pytest.approx(0, abs=1e-5)


def test_closed_pose_can_have_velocity_break(tmp_path):
    path = write_clip(tmp_path, [row(0), row(0.5, x=1), row(1)])
    seam = DECODE.summarize(DECODE.read_decode(path))['joints']['Torso']['loop_seam']
    assert seam['position_studs'] == 0
    assert seam['translation_velocity_delta_studs_per_second'] == pytest.approx(4)


def test_missing_boundary_does_not_claim_loop_seam(tmp_path):
    path = write_clip(tmp_path, [row(0.2), row(0.5), row(0.8)])
    joint = DECODE.summarize(DECODE.read_decode(path))['joints']['Torso']
    assert not joint['covers_clip']
    assert joint['loop_seam'] is None


def test_importer_losses_are_reported(tmp_path):
    path = write_clip(tmp_path, [row(0, easing='Cubic'),
                                 'Test|MARKER|0.5|Impact=right|hand', row(1)])
    report = DECODE.summarize(DECODE.read_decode(path))
    assert report['markers'][0]['payload'] == 'Impact=right|hand'
    assert any('easing' in warning for warning in report['warnings'])
    assert any('markers' in warning for warning in report['warnings'])


@pytest.mark.parametrize('bad_row', [row(0), row(2), row(0.5, x='nan'), row(-0.5)])
def test_rejects_invalid_sample_data(tmp_path, bad_row):
    path = write_clip(tmp_path, [row(0), bad_row])
    with pytest.raises(ValueError):
        DECODE.read_decode(path)


def test_single_pose_has_no_invented_motion(tmp_path):
    path = write_clip(tmp_path, [row(0)], length=0)
    report = DECODE.summarize(DECODE.read_decode(path))
    assert report['joints']['Torso']['loop_seam'] is None
    assert report['joints']['Torso']['max_sample_gap_seconds'] == 0


def test_cli_reads_all_bundled_decodes():
    files = sorted((ROOT / 'roblox-r6-animation/references/decodes').glob('*.txt'))
    result = subprocess.run([sys.executable, str(SCRIPT), *map(str, files), '--json'],
                            capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    reports = json.loads(result.stdout)
    assert len(reports) == 8
    assert all(len(report['joints']) == 6 for report in reports)


def test_cli_rejects_invalid_input(tmp_path):
    path = write_clip(tmp_path, [row(0), row(0)])
    result = subprocess.run([sys.executable, str(SCRIPT), str(path), '--json'],
                            capture_output=True, text=True)
    assert result.returncode == 1
    assert 'strictly increase' in result.stderr
    assert not result.stdout
