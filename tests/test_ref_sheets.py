import importlib.util
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('ref_sheets', ROOT / 'roblox-r6-animation/scripts/video/ref_sheets.py')
ref = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ref)


def test_a_30_fps_capture_saved_at_60_repeats_every_other_frame():
    diffs = [0.0] + [5.0 if i % 2 else 0.0 for i in range(1, 120)]
    assert ref.unique_frames(diffs)[:4] == [0, 1, 3, 5]
    assert abs(ref.capture_fps(diffs, 60) - 30.5) < 0.1


def test_cut_frames_close_together_merge_into_one_event():
    assert ref.cluster([10, 12, 15, 40, 41, 90]) == [[10, 15], [40, 41], [90, 90]]


def test_only_unique_frames_below_the_correlation_floor_count_as_cuts():
    uniq = [0, 2, 4, 6]
    corrs = [1.0, 0.9, 0.95, 0.1, 0.2, 0.9, 0.3]
    assert ref.cuts(uniq, corrs) == [4, 6]


def test_static_runs_need_quiet_unique_frames_for_the_minimum_time():
    uniq = list(range(0, 60))
    diffs = [5.0] * 10 + [0.5] * 30 + [5.0] * 20
    assert ref.static_runs(uniq, diffs, 60) == [[9, 39]]
    assert ref.static_runs(uniq, diffs, 60, least=0.6) == []
