import sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
import argparse
import html
import json
import re
import subprocess
import urllib.parse
import zipfile
from pathlib import Path

import imageio_ffmpeg
import numpy as np

from check import spectro, save_png

UA = "Mozilla/5.0 (X11; Linux x86_64)"
FF = imageio_ffmpeg.get_ffmpeg_exe()
RATE = 44100
CACHE = Path.home() / ".cache" / "roblox-sfx"
PARTNERS = {7462895450: "ProSoundEffects", 7462718749: "APMOfficial"}
KENNEY = ["impact-sounds", "interface-sounds", "rpg-audio", "sci-fi-sounds", "ui-audio", "digital-audio"]


def get(url, binary=False, ref=None):
    r = subprocess.run(["curl", "-sSL", "-m", "40", "-A", UA] + (["-e", ref] if ref else []) + [url], capture_output=True)
    return r.stdout if binary else r.stdout.decode("utf8", "ignore")


def freesound(q, n):
    url = "https://freesound.org/search/?q=" + urllib.parse.quote(q) + "&f=license%3A%22Creative+Commons+0%22"
    s = get(url)
    out = []
    pat = r'data-sound-id="(\d+)"\s+data-username="([^"]+)".*?data-mp3="([^"]+)".*?data-title="([^"]*)"\s+data-duration="([\d.]+)"'
    for sid, user, mp3, title, dur in re.findall(pat, s, re.S)[:n]:
        out.append(dict(source="freesound", id=sid, title=html.unescape(title), author=user, dur=float(dur),
                        file=mp3.replace("-lq.mp3", "-hq.mp3"), page=f"https://freesound.org/people/{user}/sounds/{sid}/",
                        license="CC0", note="hq preview mp3 128 kbps, original needs a freesound login"))
    return out


def bigsoundbank(q, n):
    out = []
    seen = set()
    for word in [q] + q.split():
        s = get("https://bigsoundbank.com/search?q=" + urllib.parse.quote(word))
        for slug, sid, title in re.findall(r"<h2[^>]*><a href='/([a-z0-9-]+)-s(\d+)\.html'>([^<]+)<", s):
            if sid in seen:
                continue
            seen.add(sid)
            out.append(dict(source="bigsoundbank", id=sid, title=f"{html.unescape(title).strip()} ({slug.replace('-', ' ')})", author="Joseph Sardin",
                            file=f"https://bigsoundbank.com/UPLOAD/flac/{sid}.flac", page=f"https://bigsoundbank.com/{slug}-s{sid}.html",
                            license="CC0 (Free and Royalty Free)"))
    words = q.lower().split()
    out.sort(key=lambda it: -sum(w in it["title"].lower() for w in words))
    return out[:n]


def mixkit(q, n):
    tags = {q.lower().replace(" ", "-")} | set(q.lower().split())
    out = []
    seen = set()
    for tag in tags:
        s = get(f"https://mixkit.co/free-sound-effects/{urllib.parse.quote(tag)}/")
        for sid, title in re.findall(r'data-audio-player-item-id-value="(\d+)".*?item-grid-card__title">\s*([^<]+?)\s*<', s, re.S):
            if sid in seen:
                continue
            seen.add(sid)
            out.append(dict(source="mixkit", id=sid, title=html.unescape(title), author="Mixkit",
                            file=f"https://assets.mixkit.co/active_storage/sfx/{sid}/{sid}.wav",
                            page=f"https://mixkit.co/free-sound-effects/{tag}/", license="Mixkit Sound Effects Free License",
                            note="no redistribution as-is: keep the Roblox upload private"))
    return out[:n]


def lab(q, n):
    s = get("https://soundeffect-lab.info/sound/search.php?s=" + urllib.parse.quote(q))
    out = []
    for title, desc, mp3 in re.findall(r'<li><span>([^<]+)</span>([^<]*)<a href="([^"]+\.mp3)"', s)[:n]:
        out.append(dict(source="lab", id=Path(mp3).stem, title=f"{title} {desc}".strip(), author="効果音ラボ",
                        file="https://soundeffect-lab.info" + mp3, ref="https://soundeffect-lab.info/", page="https://soundeffect-lab.info/sound/search.php?s=" + urllib.parse.quote(q),
                        license="効果音ラボ terms (free, games OK, no credit)", note="no redistribution: keep the Roblox upload private"))
    return out


def kenney(q, n):
    words = q.lower().split()
    out = []
    for pack in KENNEY:
        z = CACHE / "kenney" / f"{pack}.zip"
        if not z.exists():
            z.parent.mkdir(parents=True, exist_ok=True)
            m = re.search(r"(https://kenney\.nl/media/pages/assets/[^'\"]+\.zip)", get(f"https://kenney.nl/assets/{pack}"))
            if not m:
                continue
            z.write_bytes(get(m.group(1), True))
        with zipfile.ZipFile(z) as f:
            for name in f.namelist():
                if not name.lower().endswith((".ogg", ".wav")):
                    continue
                label = re.sub(r"([a-z])([A-Z])", r"\1 \2", Path(name).stem).replace("_", " ").lower()
                if all(w in label for w in words):
                    out.append(dict(source="kenney", id=f"{pack}/{Path(name).stem}", title=label, author="Kenney",
                                    file=f"zip://{z}!{name}", page=f"https://kenney.nl/assets/{pack}", license="CC0"))
    return out[:n]


WEB = dict(freesound=freesound, bigsoundbank=bigsoundbank, mixkit=mixkit, lab=lab, kenney=kenney)


def fetch(item, raw):
    ext = Path(urllib.parse.urlparse(item["file"].split("!")[-1]).path).suffix or ".mp3"
    dst = raw / f"{item['source']}_{re.sub(r'[^A-Za-z0-9_-]', '_', item['id'])}{ext}"
    if not dst.exists():
        if item["file"].startswith("zip://"):
            zpath, name = item["file"][6:].split("!")
            with zipfile.ZipFile(zpath) as f:
                dst.write_bytes(f.read(name))
        else:
            dst.write_bytes(get(item["file"], True, item.get("ref")))
    return dst


def decode(path):
    raw = subprocess.run([FF, "-v", "quiet", "-i", str(path), "-ac", "1", "-ar", str(RATE), "-f", "f32le", "-"], capture_output=True).stdout
    return np.frombuffer(raw, np.float32).astype(float)


def to_wav(path, dst):
    subprocess.run([FF, "-v", "quiet", "-y", "-i", str(path), "-ar", str(RATE), "-c:a", "pcm_s16le", str(dst)])


def measure(x):
    peak = np.max(np.abs(x)) + 1e-12
    k = int(RATE * 0.01)
    m = len(x) // k
    rms = np.sqrt(np.mean(x[: m * k].reshape(m, k) ** 2, axis=1)) / peak
    loud = np.nonzero(rms > 10 ** (-40 / 20))[0]
    spec = np.abs(np.fft.rfft(x)) ** 2
    f = np.fft.rfftfreq(len(x), 1 / RATE)
    cum = np.cumsum(spec) / (np.sum(spec) + 1e-20)
    top = np.nonzero(spec > spec.max() * 1e-6)[0]
    return dict(
        dur=round(len(x) / RATE, 2),
        lead_ms=int(loud[0] * 10) if len(loud) else 0,
        body_s=round((loud[-1] - loud[0] + 1) / 100, 2) if len(loud) else 0,
        floor_db=round(20 * np.log10(np.percentile(rms, 5) + 1e-9), 1),
        clipped=int(np.sum(np.abs(x) > 0.985)),
        centroid=int(np.sum(f * spec) / (np.sum(spec) + 1e-20)),
        f95=int(f[np.searchsorted(cum, 0.95)]),
        top_hz=int(f[top[-1]]) if len(top) else 0,
    )


def score(item, q, lo, hi):
    words = [w for w in re.split(r"\W+", q.lower()) if w]
    if item["source"] == "lab":
        words = [c for c in item["query"] if not c.isspace()]
    title = item["title"].lower()
    text = sum(w in title for w in words) / max(1, len(words))
    m = item["m"]
    quality = min(m["top_hz"], 18000) / 18000 + (m["floor_db"] < -55) * 0.3 - (m["clipped"] > 50) * 0.5 - (m["lead_ms"] > 150) * 0.3
    fit = 1.0 if lo <= m["body_s"] <= hi else 0.3
    return round(2 * text + quality + fit, 2)


def search(args):
    out = Path(args.out)
    raw = out / "raw"
    wav = out / "wav"
    raw.mkdir(parents=True, exist_ok=True)
    wav.mkdir(exist_ok=True)
    items = []
    for name in args.sources.split(","):
        q = args.ja if name == "lab" and args.ja else args.query
        if name == "lab" and not args.ja:
            continue
        try:
            found = WEB[name](q, args.per)
        except Exception as e:
            print(f"{name}: failed {e}")
            continue
        for it in found:
            it["query"] = q
        print(f"{name}: {len(found)}")
        items += found
    keep = []
    for it in items:
        src = fetch(it, raw)
        x = decode(src)
        if len(x) < RATE * 0.02:
            continue
        dst = wav / (src.stem + ".wav")
        to_wav(src, dst)
        it["raw"] = str(src)
        it["wav"] = str(dst)
        it["m"] = measure(x)
        it["score"] = score(it, args.query, args.min, args.max)
        keep.append(it)
    keep.sort(key=lambda it: -it["score"])
    (out / "candidates.json").write_text(json.dumps(keep, ensure_ascii=False, indent=1), encoding="utf-8")
    rows = ["| # | score | source | title | body s | centroid | top Hz | floor dB | license | page |", "|---|---|---|---|---|---|---|---|---|---|"]
    for i, it in enumerate(keep):
        m = it["m"]
        rows.append(f"| {i} | {it['score']} | {it['source']} | {it['title'][:50]} | {m['body_s']} | {m['centroid']} | {m['top_hz']} | {m['floor_db']} | {it['license']} | {it['page']} |")
    (out / "candidates.md").write_text("\n".join(rows) + "\n", encoding="utf-8")
    print("\n".join(rows[: args.show + 2]))
    sheet(keep[: args.sheet], out / "sheet.png")


def sheet(items, path):
    tiles = []
    for it in items:
        p = Path(it["wav"]).with_suffix(".png")
        spectro(decode(it["wav"]), RATE, p, height=120, width=300, wave_h=30)
        tiles.append(read_png(p))
    if not tiles:
        return
    cols = 3
    gap = np.full((tiles[0].shape[0], 6, 3), 255, np.uint8)
    blank = np.zeros_like(tiles[0])
    rows = []
    for i in range(0, len(tiles), cols):
        row = tiles[i : i + cols] + [blank] * (cols - len(tiles[i : i + cols]))
        rows.append(np.concatenate(sum([[t, gap] for t in row], [])[:-1], axis=1))
        rows.append(np.full((6, rows[-1].shape[1], 3), 255, np.uint8))
    save_png(path, np.concatenate(rows[:-1], axis=0))


def read_png(path):
    import struct
    import zlib
    b = Path(path).read_bytes()
    i = 8
    data = b""
    while i < len(b):
        size = struct.unpack(">I", b[i : i + 4])[0]
        tag = b[i + 4 : i + 8]
        if tag == b"IHDR":
            w, h = struct.unpack(">II", b[i + 8 : i + 16])
        if tag == b"IDAT":
            data += b[i + 8 : i + 8 + size]
        i += 12 + size
    raw = zlib.decompress(data)
    return np.stack([np.frombuffer(raw[y * (w * 3 + 1) + 1 : (y + 1) * (w * 3 + 1)], np.uint8).reshape(w, 3) for y in range(h)])


def roblox(args):
    base = "https://apis.roblox.com/toolbox-service/v1"
    creators = list(PARTNERS) + ([None] if args.community else [])
    rows = []
    for c, kw in [(c, kw) for c in creators for kw in [args.query] + args.query.split()]:
        url = f"{base}/marketplace/3?keyword={urllib.parse.quote(kw)}&num={args.num}"
        if c:
            url += f"&creatorTargetId={c}&creatorType=1"
        ids = [str(d["id"]) for d in json.loads(get(url)).get("data", [])]
        if not ids:
            continue
        for d in json.loads(get(f"{base}/items/details?assetIds={','.join(ids)}")).get("data", []):
            a = d["asset"]
            kind = (a.get("audioDetails") or {}).get("audioType")
            if kind != "SoundEffect" or a.get("duration", 0) > args.max:
                continue
            rows.append(dict(id=a["id"], name=a["name"], creator=d["creator"]["name"], dur=a.get("duration"),
                             partner=d["creator"]["id"] in PARTNERS))
    words = args.query.lower().split()
    for r in rows:
        r["hits"] = sum(w in r["name"].lower() for w in words)
    rows.sort(key=lambda r: (-r["hits"], -r["partner"]))
    seen = set()
    lines = ["| id | name | creator | s | words | licensed partner |", "|---|---|---|---|---|---|"]
    for r in rows:
        if r["id"] in seen:
            continue
        seen.add(r["id"])
        lines.append(f"| {r['id']} | {r['name'][:60]} | {r['creator']} | {r['dur']} | {r['hits']} | {'yes' if r['partner'] else 'no, ownership unverified'} |")
    text = "\n".join(lines)
    print(text)
    if args.out:
        Path(args.out).parent.mkdir(parents=True, exist_ok=True)
        Path(args.out).write_text(text + "\n", encoding="utf-8")


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("web")
    s.add_argument("query")
    s.add_argument("--ja", default="")
    s.add_argument("--out", required=True)
    s.add_argument("--sources", default="bigsoundbank,freesound,mixkit,lab,kenney")
    s.add_argument("--per", type=int, default=6)
    s.add_argument("--min", type=float, default=0.1)
    s.add_argument("--max", type=float, default=4.0)
    s.add_argument("--show", type=int, default=12)
    s.add_argument("--sheet", type=int, default=9)
    r = sub.add_parser("roblox")
    r.add_argument("query")
    r.add_argument("--num", type=int, default=30)
    r.add_argument("--max", type=float, default=8)
    r.add_argument("--community", action="store_true")
    r.add_argument("--out", default="")
    args = ap.parse_args()
    search(args) if args.cmd == "web" else roblox(args)


if __name__ == "__main__":
    main()
