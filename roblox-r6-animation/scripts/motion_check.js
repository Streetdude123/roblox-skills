// measures how alive a clip moves from ReadClips decode text (name|joint|t|lift|twist|side|x|y|z|...), the format
// that ReadClips.lua and Poser.dump write; Poser.check computes the same numbers inside Studio
// usage: node motion_check.js clip.txt [more.txt ...] [--json]
const fs = require('fs');

const R = Math.PI / 180;
// speeds are central differences over 4 frames so 0.1 degree and 0.01 stud rounding in a decode cannot fake a stop
const WIN = 2;
// a body is still (reads as a paused action) when no joint turns faster than 12 deg/s or slides faster than 0.3 stud/s
const ROT_STILL = 12, MOV_STILL = 0.3;
// a joint is resting under 10 percent of its own peak speed; a stop is a rest of 4 frames or more
const REST = 0.1, STOP_FRAMES = 4;
// 1 stud of slide counts like 30 degrees of turn (the end of a 2 stud limb moves 1 stud in 30 degrees)
const STUD = 30;
// a body is frozen when nothing turns over 1.5 deg/s or slides over 0.06 stud/s across a 16 frame window (breath and
// drift count as life here; the wide window keeps decode rounding under the threshold)
const FWIN = 8, ROT_FROZEN = 1.5, MOV_FROZEN = 0.06;

function mat(l, t, s) {
  const [cx, sx, cy, sy, cz, sz] = [Math.cos(l * R), Math.sin(l * R), Math.cos(t * R), Math.sin(t * R), Math.cos(s * R), Math.sin(s * R)];
  const rz = [[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]];
  const rx = [[1, 0, 0], [0, cx, -sx], [0, sx, cx]];
  const ry = [[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]];
  const mul = (a, b) => a.map(r => [0, 1, 2].map(j => r[0] * b[0][j] + r[1] * b[1][j] + r[2] * b[2][j]));
  return mul(mul(rz, rx), ry);
}

function turn(a, b) {
  let tr = 0;
  for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) tr += a[i][j] * b[i][j];
  return Math.acos(Math.max(-1, Math.min(1, (tr - 1) / 2))) / R;
}

function read(path) {
  const lines = fs.readFileSync(path, 'utf8').split(/\r?\n/);
  const head = lines[0].match(/^#(.+?) len=(\S+) loop=(\S+)/);
  const clip = { name: head ? head[1] : path, len: head ? +head[2] : 0, loop: head ? head[3] === 'true' : false, joints: {} };
  for (const line of lines.slice(1)) {
    const f = line.split('|');
    if (f.length < 9 || f[1] === 'MARKER') continue;
    (clip.joints[f[1]] ||= []).push({ t: +f[2], m: mat(+f[3], +f[4], +f[5]), p: [+f[6], +f[7], +f[8]] });
  }
  for (const k in clip.joints) clip.joints[k].sort((a, b) => a.t - b.t);
  return clip;
}

// per joint speed arrays; joints sampled much more sparsely than the rest are dropped
function speeds(clip) {
  const most = Math.max(...Object.values(clip.joints).map(s => s.length));
  const out = {};
  for (const [name, s] of Object.entries(clip.joints)) {
    if (s.length < most / 2) continue;
    const rot = [], mov = [];
    for (let i = 0; i < s.length; i++) {
      const a = s[Math.max(0, i - WIN)], b = s[Math.min(s.length - 1, i + WIN)];
      const dt = b.t - a.t;
      rot.push(dt > 0 ? turn(a.m, b.m) / dt : 0);
      mov.push(dt > 0 ? Math.hypot(...b.p.map((v, k) => v - a.p[k])) / dt : 0);
    }
    const frozen = [];
    for (let i = 0; i < s.length; i++) {
      const a = s[Math.max(0, i - FWIN)], b = s[Math.min(s.length - 1, i + FWIN)];
      const dt = b.t - a.t;
      frozen.push(dt > 0 && turn(a.m, b.m) / dt < ROT_FROZEN && Math.hypot(...b.p.map((v, k) => v - a.p[k])) / dt < MOV_FROZEN);
    }
    out[name] = { rot, mov, frozen, v: rot.map((r, i) => r + STUD * mov[i]) };
  }
  return out;
}

function analyze(clip) {
  const sp = speeds(clip);
  const names = Object.keys(sp);
  const n = Math.min(...names.map(k => sp[k].v.length));
  const len = clip.len || n / 60;
  let frozen = 0;
  for (let i = 0; i < n; i++) if (names.every(k => sp[k].frozen[i])) frozen++;
  let still = 0, run = 0, longest = 0;
  for (let i = 0; i < n; i++) {
    const moving = names.some(k => sp[k].rot[i] > ROT_STILL || sp[k].mov[i] > MOV_STILL);
    if (moving) run = 0; else { still++; run++; longest = Math.max(longest, run); }
  }
  // active joints actually take part in the action
  const active = names.filter(k => Math.max(...sp[k].v) >= 60);
  const resting = active.map(k => { const pk = Math.max(...sp[k].v); return sp[k].v.map(x => x < REST * pk); });
  let rest = 0, stops = 0;
  resting.forEach(r => {
    rest += r.filter(Boolean).length / n;
    let len2 = 0;
    for (let i = 0; i <= n; i++) {
      if (i < n && r[i]) len2++;
      else { if (len2 >= STOP_FRAMES && len2 < n) stops++; len2 = 0; }
    }
  });
  // unison: the moment three or more active joints are resting together begins
  let unison = 0, was = false;
  for (let i = 0; i < n; i++) {
    const all = resting.filter(r => r[i]).length >= 3;
    if (all && !was && i > 0) unison++;
    was = all;
  }
  const body = [];
  for (let i = 0; i < n; i++) body.push(names.reduce((s, k) => s + sp[k].v[i], 0));
  const sorted = [...body].sort((x, y) => x - y);
  const contrast = sorted[n - 1] / Math.max(1, sorted[Math.floor(n / 2)]);
  const peaks = active.map(k => sp[k].v.indexOf(Math.max(...sp[k].v)));
  const mean = peaks.reduce((x, y) => x + y, 0) / Math.max(1, peaks.length);
  const spread = Math.sqrt(peaks.reduce((s, x) => s + (x - mean) ** 2, 0) / Math.max(1, peaks.length));
  // overlap: frames of the best speed correlation between the torso and each other joint (positive = trails)
  const lag = {};
  if (sp.Torso) {
    const a = sp.Torso.v, ma = a.reduce((x, y) => x + y, 0) / n;
    for (const k of names) {
      if (k === 'Torso') continue;
      const b = sp[k].v, mb = b.reduce((x, y) => x + y, 0) / n;
      let best = -Infinity, bl = 0;
      for (let L = -8; L <= 8; L++) {
        let cov = 0, va = 0, vb = 0;
        for (let i = 0; i < n; i++) { const j = i + L; if (j >= 0 && j < n) { cov += (a[i] - ma) * (b[j] - mb); va += (a[i] - ma) ** 2; vb += (b[j] - mb) ** 2; } }
        const r = va && vb ? cov / Math.sqrt(va * vb) : 0;
        if (r > best) { best = r; bl = L; }
      }
      lag[k] = bl;
    }
  }
  return {
    clip: clip.name, len: +len.toFixed(3), active: active.length,
    frozenPct: +(100 * frozen / n).toFixed(1), stillPct: +(100 * still / n).toFixed(1), longestStill: +(longest / 60).toFixed(3),
    restPct: +(100 * rest / Math.max(1, active.length)).toFixed(1),
    stopsPerSec: +(stops / Math.max(1, active.length) / len).toFixed(2),
    unisonPerSec: +(unison / len).toFixed(2),
    contrast: +contrast.toFixed(1), peakSpread: +spread.toFixed(1), lag,
  };
}

const args = process.argv.slice(2);
const rows = args.filter(a => !a.startsWith('--')).map(f => analyze(read(f)));
if (args.includes('--json')) console.log(JSON.stringify(rows, null, 1));
else {
  console.log('clip                  len  frozen%  still%  longest  rest%  stops/s  unison/s  contrast  spread  lag head,rArm,lArm');
  for (const r of rows) {
    const L = k => (k in r.lag ? r.lag[k] : '-');
    console.log(`${r.clip.slice(0, 20).padEnd(20)} ${String(r.len).padStart(5)} ${String(r.frozenPct).padStart(8)} ${String(r.stillPct).padStart(8)} ${String(r.longestStill).padStart(8)} ${String(r.restPct).padStart(6)} ${String(r.stopsPerSec).padStart(8)} ${String(r.unisonPerSec).padStart(9)} ${String(r.contrast).padStart(9)} ${String(r.peakSpread).padStart(7)}   ${L('Head')},${L('Right Arm')},${L('Left Arm')}`);
  }
}
