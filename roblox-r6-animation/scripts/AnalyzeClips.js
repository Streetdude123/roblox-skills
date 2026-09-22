// summarises the decoded clip dumps: per joint keys, ranges, eases, and the beat structure
const fs = require('fs'), path = require('path');
const DIR = path.join(__dirname, 'anim');
const files = process.argv.slice(2).length ? process.argv.slice(2) : fs.readdirSync(DIR).filter(f => f.endsWith('.txt'));
const JOINTS = ['Torso', 'Head', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg'];
for (const f of files) {
  const lines = fs.readFileSync(path.join(DIR, f), 'utf8').split('\n').filter(Boolean);
  const head = lines[0];
  const byJoint = {};
  for (const l of lines.slice(1)) {
    const p = l.split('|');
    if (p[1] === 'MARKER') { console.log('  MARKER', p[2], p[3]); continue; }
    const [label, joint, t, lift, twist, side, x, y, z, es, ed] = p;
    if (!byJoint[joint]) byJoint[joint] = [];
    byJoint[joint].push({ t: +t, lift: +lift, twist: +twist, side: +side, x: +x, y: +y, z: +z, es, ed });
  }
  console.log('\n==== ' + head);
  for (const j of JOINTS.concat(Object.keys(byJoint).filter(k => !JOINTS.includes(k)))) {
    const ks = byJoint[j]; if (!ks) continue;
    ks.sort((a, b) => a.t - b.t);
    const rng = (k) => { const v = ks.map(x => x[k]); return `${Math.min(...v).toFixed(1)}..${Math.max(...v).toFixed(1)}`; };
    const eases = {}; for (const k of ks) { const e = k.es + '/' + k.ed; eases[e] = (eases[e] || 0) + 1; }
    console.log(`-- ${j}: keys=${ks.length} lift ${rng('lift')} twist ${rng('twist')} side ${rng('side')} x ${rng('x')} y ${rng('y')} z ${rng('z')} eases ${JSON.stringify(eases)}`);
    // print keys, but thin out long idles: show every key where any channel moves more than 0.5 deg or 0.02 studs from the previous printed key
    let last = null, printed = 0;
    for (const k of ks) {
      const moved = !last || Math.abs(k.lift - last.lift) > 0.5 || Math.abs(k.twist - last.twist) > 0.5 || Math.abs(k.side - last.side) > 0.5 || Math.abs(k.x - last.x) > 0.02 || Math.abs(k.y - last.y) > 0.02 || Math.abs(k.z - last.z) > 0.02;
      if (moved || ks.length <= 30) {
        console.log(`   t=${k.t.toFixed(3)} r={${k.lift.toFixed(1)}, ${k.twist.toFixed(1)}, ${k.side.toFixed(1)}} p=(${k.x.toFixed(2)}, ${k.y.toFixed(2)}, ${k.z.toFixed(2)}) ${k.es}/${k.ed}`);
        last = k; printed++;
      }
    }
  }
}
