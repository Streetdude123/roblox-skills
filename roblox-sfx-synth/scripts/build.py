import argparse
import json
import subprocess
from pathlib import Path

import imageio_ffmpeg
import numpy as np
from pedalboard import Pedalboard, Reverb, Compressor, Limiter, Distortion, HighpassFilter, LowpassFilter, Delay, Chorus
from scipy import signal

import sfx

RATE = 44100
FF = imageio_ffmpeg.get_ffmpeg_exe()


def load(path):
    raw = subprocess.run([FF, "-v", "quiet", "-i", str(path), "-ac", "1", "-ar", str(RATE), "-f", "f32le", "-"], capture_output=True).stdout
    return np.frombuffer(raw, np.float32).astype(float)


def speed(x, semis):
    if not semis:
        return x
    return signal.resample(x, max(1, int(len(x) / 2 ** (semis / 12))))


def fshift(x, hz):
    return np.real(signal.hilbert(x) * np.exp(2j * np.pi * hz * np.arange(len(x)) / RATE))


def fade(x, a, b):
    ka = min(len(x), int(a * RATE))
    kb = min(len(x), int(b * RATE))
    if ka:
        x[:ka] *= np.linspace(0, 1, ka)
    if kb:
        x[-kb:] *= np.linspace(1, 0, kb)
    return x


def layer(L, rng, jitter, base):
    if "synth" in L:
        x = sfx.PRESETS[L["synth"]][1](np.random.default_rng(L.get("seed", 1)))
    else:
        x = load(base / L["file"])
    start = int(L.get("start", 0) * RATE)
    end = int(L["end"] * RATE) if "end" in L else len(x)
    x = x[start:end].copy()
    if L.get("reverse"):
        x = x[::-1].copy()
    x = speed(x, L.get("pitch", 0) + rng.uniform(-jitter, jitter))
    if "hp" in L:
        x = sfx.highpass(x, L["hp"])
    if "lp" in L:
        x = sfx.lowpass(x, L["lp"])
    if "shift" in L:
        x = x + L.get("shift_mix", 0.5) * fshift(x, L["shift"])
    if "drive" in L:
        x = sfx.drive(x / (np.max(np.abs(x)) + 1e-12), L["drive"])
    x = fade(x, L.get("fade_in", 0.0), L.get("fade_out", 0.01))
    x = x / (np.max(np.abs(x)) + 1e-12)
    return x * 10 ** (L.get("gain_db", 0) / 20)


FX = dict(
    reverb=lambda p: Reverb(room_size=p.get("room", 0.5), damping=p.get("damp", 0.5), wet_level=p.get("wet", 0.2), dry_level=p.get("dry", 0.9), width=0.0),
    compressor=lambda p: Compressor(threshold_db=p.get("threshold_db", -16), ratio=p.get("ratio", 3), attack_ms=p.get("attack_ms", 3), release_ms=p.get("release_ms", 120)),
    distortion=lambda p: Distortion(drive_db=p.get("drive_db", 6)),
    delay=lambda p: Delay(delay_seconds=p.get("time", 0.12), feedback=p.get("feedback", 0.3), mix=p.get("mix", 0.2)),
    chorus=lambda p: Chorus(rate_hz=p.get("rate", 1.0), depth=p.get("depth", 0.2), mix=p.get("mix", 0.3)),
    highpass=lambda p: HighpassFilter(cutoff_frequency_hz=p["hz"]),
    lowpass=lambda p: LowpassFilter(cutoff_frequency_hz=p["hz"]),
    limiter=lambda p: Limiter(threshold_db=p.get("threshold_db", -3), release_ms=p.get("release_ms", 80)),
)


def render(recipe, seed, base):
    rng = np.random.default_rng(seed)
    jitter = recipe.get("layer_jitter", 0.0)
    parts = [(L.get("at", 0.0), layer(L, rng, jitter, base)) for L in recipe["layers"]]
    total = max(int(at * RATE) + len(x) for at, x in parts) + int(recipe.get("tail", 1.5) * RATE)
    out = np.zeros(total)
    for at, x in parts:
        i = int(at * RATE)
        out[i : i + len(x)] += x
    board = Pedalboard([FX[f["type"]](f) for f in recipe.get("fx", [])])
    out = board(out.astype(np.float32), RATE).astype(float)
    out = speed(out, rng.uniform(-1, 1) * recipe.get("pitch_jitter", 0.0))
    out = sfx.highpass(out, 25)
    e = np.abs(out)
    keep = np.nonzero(e > e.max() * 10 ** (recipe.get("trim_db", -60) / 20))[0]
    out = fade(out[: keep[-1] + 1].copy(), 0, 0.02)
    return out / np.max(np.abs(out)) * 10 ** (recipe.get("peak_db", -1) / 20)


def credits(recipe, manifest):
    seen = {}
    for L in recipe["layers"]:
        if "file" in L:
            name = Path(L["file"]).stem
            it = manifest.get(name, {})
            seen[name] = {k: it.get(k) for k in ("source", "title", "author", "license", "page")}
        else:
            seen[f"synth:{L['synth']}"] = {"source": "roblox-sfx-synth", "license": "own"}
    return seen


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("recipe")
    ap.add_argument("--out", default="sfx_out")
    ap.add_argument("--variants", type=int, default=1)
    ap.add_argument("--seed", type=int, default=1)
    args = ap.parse_args()
    recipe = json.loads(Path(args.recipe).read_text())
    base = Path(args.recipe).resolve().parent
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    manifest = {}
    for c in base.glob("**/candidates.json"):
        for it in json.loads(c.read_text()):
            manifest[Path(it["wav"]).stem] = it
    for v in range(args.variants):
        path = out / f"{recipe['name']}_{args.seed + v}.wav"
        sfx.save(path, render(recipe, args.seed + v, base))
        print(path)
    (out / f"{recipe['name']}_credits.json").write_text(json.dumps(credits(recipe, manifest), ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
