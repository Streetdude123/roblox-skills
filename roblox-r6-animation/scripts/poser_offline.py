import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
SHIM = HERE / 'offline' / 'roblox_shim.luau'
GLOBALS = ('Vector3', 'CFrame', 'typeof', 'game', 'Enum', 'Instance', 'task', 'os')
NEED = re.compile(r'require\(\s*script\.Parent\.(\w+)\s*\)')

HEAD = '''
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
'''

CHECK = '''
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

RUNTIME = '''
local RS = shim.game:GetService("RunService")
local CF = shim.CFrame.new
local function motor(name, c0)
	return {Name = name, Part1 = {Name = name}, C0 = c0, Transform = CF(), Parent = true, IsA = function(_, c)
		return c == "Motor6D"
	end}
end
local motors = {
	motor("Torso", CF(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)),
	motor("Head", CF(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)),
	motor("Right Arm", CF(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)),
	motor("Left Arm", CF(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)),
	motor("Right Leg", CF(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)),
	motor("Left Leg", CF(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)),
}
local rig = Poser.attach({Parent = true, GetDescendants = function()
	return motors
end})
local function find(name)
	if type(clips[name]) == "table" then
		return clips[name]
	end
	for _, m in pairs(cache) do
		if type(m) == "table" and type(m[name]) == "table" and m[name].joints then
			return m[name]
		end
	end
	error("no clip " .. name)
end
local done, lines, count, clock = {}, {}, 0, 0
for f = 0, math.floor(LENGTH * FPS + 0.5) do
	clock = f / FPS
	shim.setClock(clock)
	for i, s in ipairs(SCENARIO) do
		if not done[i] and s.t <= clock + 1e-6 then
			done[i] = true
			if s.act == "play" then
				local opts = {fadeIn = s.fade, blend = s.blend, startAt = s.start, speed = s.speed}
				if s.after then
					opts.onDone = function()
						print(("@@event %.3f done %s, play %s"):format(clock, s.clip, s.after))
						rig:play(find(s.after), {fadeIn = s.fade, blend = s.blend})
					end
				end
				rig:play(find(s.clip), opts)
			elseif s.act == "hold" then
				rig:hold(s.v)
			elseif s.act == "stop" then
				rig:stop(s.v)
			elseif s.act == "speed" then
				rig:setSpeed(s.v)
			elseif s.act == "seek" then
				rig:seek(s.v)
			end
			print(("@@event %.3f %s %s"):format(clock, s.act, s.clip or tostring(s.v)))
		end
	end
	for _, m in ipairs(motors) do
		m.Transform = CF()
	end
	RS.PreSimulation:Fire(1 / FPS)
	count += 1
	for _, m in ipairs(motors) do
		local r = m.C0.Rotation
		local c = Poser.cfChan(r * m.Transform * r:Inverse())
		table.insert(lines, ("%s|%s|%.3f|%.1f|%.1f|%.1f|%.2f|%.2f|%.2f|Linear|In"):format(NAME, m.Name, clock, c[1], c[2], c[3], c[4], c[5], c[6]))
	end
end
print("@@dump " .. NAME)
print(("#%s len=%.3f loop=false frames=%d prio=Action"):format(NAME, LENGTH, count))
print(table.concat(lines, "\\n"))
print("@@end")
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


def scenario(text):
    steps = []
    for part in text.split(';'):
        w = part.split()
        if not w:
            continue
        s = {'t': float(w[0]), 'act': w[1]}
        if w[1] == 'play':
            s['clip'] = w[2]
            rest = w[3:]
            while rest:
                if rest[0] == 'then':
                    s['after'] = rest[1]
                    rest = rest[2:]
                    continue
                k, v = rest.pop(0).split('=')
                s[{'fade': 'fade', 'blend': 'blend', 'start': 'start', 'speed': 'speed'}[k]] = v if k == 'blend' else float(v)
        else:
            s['v'] = float(w[2]) if len(w) > 2 else 0.0
        steps.append(s)
    return steps


def lua_value(v):
    if isinstance(v, str):
        return f'"{v}"'
    return repr(v)


def entry(main, only=(), fps=60, steps=None, length=0.0, name='Runtime'):
    mods = modules(main)
    names = ', '.join(GLOBALS)
    take = ', '.join(f'shim.{g}' for g in GLOBALS)
    out = ['local shim = (function()', SHIM.read_text(), 'end)()', 'local mods = {}']
    for mod, path in mods.items():
        out += [f'mods["{mod}"] = function(script, require)', f'local {names} = {take}', path.read_text(), 'end']
    out.append(f'local MAIN = "{Path(main).stem}"')
    out.append('local ONLY = {' + ', '.join(f'"{o}"' for o in only) + '}')
    out.append(f'local FPS = {fps}')
    out.append(HEAD)
    if steps is None:
        out.append(CHECK)
    else:
        rows = ', '.join('{' + ', '.join(f'{k} = {lua_value(v)}' for k, v in s.items()) + '}' for s in steps)
        out.append(f'local SCENARIO = {{{rows}}}')
        out.append(f'local LENGTH = {length}')
        out.append(f'local NAME = "{name}"')
        out.append(RUNTIME)
    return '\n'.join(out)


def luau_path(given=None):
    p = given or os.environ.get('LUAU') or shutil.which('luau')
    if not p:
        raise SystemExit('no luau binary: pass --luau, set LUAU, or put luau on PATH (github.com/luau-lang/luau/releases)')
    return p


def parse(text):
    clips, cur, dump = {}, None, None
    for line in text.splitlines():
        if line.startswith('@@event '):
            clips.setdefault('events', []).append(line[8:])
        elif line.startswith('@@check '):
            head, *pairs = line[8:].split(' ')
            cur = head
            clips[cur] = {'check': {k: float(v) for k, v in (p.split('=') for p in pairs)}}
        elif line.startswith('@@dump '):
            cur = line[7:]
            clips.setdefault(cur, {})
            dump = []
        elif line == '@@end':
            clips[cur]['decode'] = '\n'.join(dump) + '\n'
            dump = None
        elif dump is not None:
            dump.append(line)
    return clips


def run(main, only=(), fps=60, luau=None, steps=None, length=0.0, name='Runtime'):
    with tempfile.TemporaryDirectory() as tmp:
        src = Path(tmp) / 'entry.luau'
        src.write_text(entry(main, only, fps, steps, length, name))
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
    ap.add_argument('--runtime', help='play the clips through Rig:play on a stock R6 motor set, e.g. "0 play Guard; 0.5 play Cross then Guard; 0.79 hold 0.08"')
    ap.add_argument('--length', type=float, default=3.0, help='seconds the runtime scenario runs')
    ap.add_argument('--name', default='Runtime', help='name of the runtime decode')
    a = ap.parse_args()
    if a.out:
        Path(a.out).mkdir(parents=True, exist_ok=True)
    if a.runtime:
        res = run(a.module, fps=a.fps, luau=a.luau, steps=scenario(a.runtime), length=a.length, name=a.name)
        for e in res.get('events', []):
            print(e)
        if a.out:
            (Path(a.out) / f'{a.name}.txt').write_text(res[a.name]['decode'])
        return
    only = [c for c in a.clip.split(',') if c]
    clips = run(a.module, only, a.fps, a.luau)
    for k, r in clips.items():
        c = r['check']
        print(f"{k} len {c['len']:.2f} frozen {c['frozen']:.1f}% still {c['still']:.1f}% longest {c['longest']:.2f}s rest {c['rest']:.1f}% "
              f"stops {c['stops']:.2f}/s unison {c['unison']:.2f}/s contrast {c['contrast']:.1f} spread {c['spread']:.1f}")
        if a.out:
            (Path(a.out) / f'{k}.txt').write_text(r['decode'])


if __name__ == '__main__':
    main()
