import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
SHIM = HERE / 'offline' / 'roblox_shim.luau'
GLOBALS = ('Vector3', 'CFrame', 'typeof', 'game', 'Enum', 'Instance', 'task')
NEED = re.compile(r'require\(\s*script\.Parent\.(\w+)\s*\)')

RUN = '''
local folder = setmetatable({}, {__index = function(_, k)
	if k == "Parent" then
		return shim.Instance.new("Folder")
	end
	return k
end})
local script = {Parent = folder, Name = "Runner"}
local cache = {}
local function need(name)
	if cache[name] == nil then
		cache[name] = mods[name](script, need)
	end
	return cache[name]
end
local Poser = need("Poser")
local clips = need(MAIN)
local names = {}
for k, v in pairs(clips) do
	if type(v) == "table" and v.joints and v.length and (#ONLY == 0 or table.find(ONLY, k)) then
		table.insert(names, k)
	end
end
table.sort(names)
for _, k in ipairs(names) do
	local clip = clips[k]
	local r = Poser.check(clip)
	print(("@@check %s len=%.3f frozen=%.2f still=%.2f longest=%.3f rest=%.2f stops=%.3f unison=%.3f contrast=%.3f spread=%.3f"):format(
		k, r.length, r.frozenPct, r.stillPct, r.longestStill, r.restPct, r.stopsPerSec, r.unisonPerSec, r.contrast, r.peakSpread))
	print("@@dump " .. k)
	print(Poser.dump(clip, FPS, clip.name or k))
	print("@@end")
end
'''


def modules(path, found=None):
    found = found if found is not None else {}
    path = Path(path).resolve()
    found[path.stem] = path
    for name in NEED.findall(path.read_text()):
        if name in found:
            continue
        for d in (path.parent, HERE):
            p = d / f'{name}.lua'
            if p.exists():
                modules(p, found)
                break
        else:
            raise SystemExit(f'{path.name} requires {name} and no {name}.lua was found')
    if 'Poser' not in found:
        modules(HERE / 'Poser.lua', found)
    return found


def entry(main, only=(), fps=60):
    mods = modules(main)
    names = ', '.join(GLOBALS)
    take = ', '.join(f'shim.{g}' for g in GLOBALS)
    out = ['local shim = (function()', SHIM.read_text(), 'end)()', 'local mods = {}']
    for name, path in mods.items():
        out += [f'mods["{name}"] = function(script, require)', f'local {names} = {take}', path.read_text(), 'end']
    out.append(f'local MAIN = "{Path(main).stem}"')
    out.append('local ONLY = {' + ', '.join(f'"{o}"' for o in only) + '}')
    out.append(f'local FPS = {fps}')
    out.append(RUN)
    return '\n'.join(out)


def luau_path(given=None):
    p = given or os.environ.get('LUAU') or shutil.which('luau')
    if not p:
        raise SystemExit('no luau binary: pass --luau, set LUAU, or put luau on PATH (github.com/luau-lang/luau/releases)')
    return p


def parse(text):
    clips, cur, dump = {}, None, None
    for line in text.splitlines():
        if line.startswith('@@check '):
            head, *pairs = line[8:].split(' ')
            cur = head
            clips[cur] = {'check': {k: float(v) for k, v in (p.split('=') for p in pairs)}}
        elif line.startswith('@@dump '):
            dump = []
        elif line == '@@end':
            clips[cur]['decode'] = '\n'.join(dump) + '\n'
            dump = None
        elif dump is not None:
            dump.append(line)
    return clips


def run(main, only=(), fps=60, luau=None):
    with tempfile.TemporaryDirectory() as tmp:
        src = Path(tmp) / 'entry.luau'
        src.write_text(entry(main, only, fps))
        res = subprocess.run([luau_path(luau), str(src)], capture_output=True, text=True)
    if res.returncode != 0:
        raise SystemExit(res.stdout[-2000:] + res.stderr[-2000:])
    return parse(res.stdout)


def main():
    ap = argparse.ArgumentParser(description='run Poser.check and Poser.dump on a clip module with the luau cli, no studio')
    ap.add_argument('module', help='a ModuleScript source that returns a table of clips, e.g. scripts/ExampleClips.lua')
    ap.add_argument('out', nargs='?', help='folder for one decode text per clip')
    ap.add_argument('--clip', default='', help='comma list of clip keys, default all')
    ap.add_argument('--fps', type=int, default=60)
    ap.add_argument('--luau')
    a = ap.parse_args()
    only = [c for c in a.clip.split(',') if c]
    clips = run(a.module, only, a.fps, a.luau)
    if a.out:
        Path(a.out).mkdir(parents=True, exist_ok=True)
    for k, r in clips.items():
        c = r['check']
        print(f"{k} len {c['len']:.2f} frozen {c['frozen']:.1f}% still {c['still']:.1f}% longest {c['longest']:.2f}s rest {c['rest']:.1f}% "
              f"stops {c['stops']:.2f}/s unison {c['unison']:.2f}/s contrast {c['contrast']:.1f} spread {c['spread']:.1f}")
        if a.out:
            (Path(a.out) / f'{k}.txt').write_text(r['decode'])


if __name__ == '__main__':
    main()
