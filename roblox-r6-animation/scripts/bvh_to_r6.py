import argparse
import json
import math
from pathlib import Path
import re
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
import r6_render as rr

ROLES = {
    'hips': ['Hips', 'hip', 'pelvis', 'Pelvis', 'Root'],
    'chest': ['Chest', 'Spine2', 'Spine1', 'chest', 'Spine3', 'UpperChest'],
    'neck': ['Neck', 'neck', 'Neck1'],
    'head': ['Head', 'head'],
    'shoulder_r': ['UpperArm_R', 'RightArm', 'rShldr', 'RightUpperArm', 'R_UpperArm', 'upperarm_r'],
    'elbow_r': ['LowerArm_R', 'RightForeArm', 'rForeArm', 'RightLowerArm', 'R_Forearm', 'lowerarm_r'],
    'wrist_r': ['Hand_R', 'RightHand', 'rHand', 'R_Hand', 'hand_r'],
    'shoulder_l': ['UpperArm_L', 'LeftArm', 'lShldr', 'LeftUpperArm', 'L_UpperArm', 'upperarm_l'],
    'elbow_l': ['LowerArm_L', 'LeftForeArm', 'lForeArm', 'LeftLowerArm', 'L_Forearm', 'lowerarm_l'],
    'wrist_l': ['Hand_L', 'LeftHand', 'lHand', 'L_Hand', 'hand_l'],
    'hip_r': ['UpperLeg_R', 'RightUpLeg', 'rThigh', 'RightUpperLeg', 'R_Thigh', 'thigh_r'],
    'knee_r': ['LowerLeg_R', 'RightLeg', 'rShin', 'RightLowerLeg', 'R_Calf', 'calf_r'],
    'ankle_r': ['Foot_R', 'RightFoot', 'rFoot', 'R_Foot', 'foot_r'],
    'toe_r': ['Toes_R', 'RightToeBase', 'RightToe', 'R_Toe', 'ball_r', 'rToe'],
    'hip_l': ['UpperLeg_L', 'LeftUpLeg', 'lThigh', 'LeftUpperLeg', 'L_Thigh', 'thigh_l'],
    'knee_l': ['LowerLeg_L', 'LeftLeg', 'lShin', 'LeftLowerLeg', 'L_Calf', 'calf_l'],
    'ankle_l': ['Foot_L', 'LeftFoot', 'lFoot', 'L_Foot', 'foot_l'],
    'toe_l': ['Toes_L', 'LeftToeBase', 'LeftToe', 'L_Toe', 'ball_l', 'lToe'],
}


def parse_bvh(path):
    tokens = Path(path).read_text(encoding='utf-8', errors='replace').split()
    i = 0
    joints, stack, order = {}, [], []
    while tokens[i] != 'MOTION':
        tk = tokens[i]
        if tk in ('ROOT', 'JOINT'):
            name = tokens[i + 1]
            joints[name] = {'parent': stack[-1] if stack else None, 'offset': None, 'channels': []}
            order.append(name)
            stack.append(name)
            i += 2
        elif tk == 'End':
            end = stack[-1] + '_End'
            joints[end] = {'parent': stack[-1], 'offset': None, 'channels': [], 'end': True}
            order.append(end)
            stack.append(end)
            i += 2
        elif tk == 'OFFSET':
            joints[stack[-1]]['offset'] = np.array([float(tokens[i + 1]), float(tokens[i + 2]), float(tokens[i + 3])])
            i += 4
        elif tk == 'CHANNELS':
            n = int(tokens[i + 1])
            joints[stack[-1]]['channels'] = tokens[i + 2:i + 2 + n]
            i += 2 + n
        elif tk == '}':
            stack.pop()
            i += 1
        else:
            i += 1
    frames = int(tokens[i + 2])
    dt = float(tokens[i + 5])
    vals = np.array([float(x) for x in tokens[i + 6:]])
    width = sum(len(j['channels']) for j in joints.values())
    vals = vals[:frames * width].reshape(frames, width)
    return joints, order, vals, dt


AMC_ROLES = {
    'hips': 'root', 'chest': 'thorax', 'neck': 'upperneck', 'head': 'head',
    'shoulder_r': 'rclavicle', 'elbow_r': 'rhumerus', 'wrist_r': 'rradius',
    'shoulder_l': 'lclavicle', 'elbow_l': 'lhumerus', 'wrist_l': 'lradius',
    'hip_r': 'rhipjoint', 'knee_r': 'rfemur', 'ankle_r': 'rtibia', 'toe_r': 'rfoot',
    'hip_l': 'lhipjoint', 'knee_l': 'lfemur', 'ankle_l': 'ltibia', 'toe_l': 'lfoot',
}


def euler_xyz(x, y, z):
    r = np.radians
    return rr.rz(r(z)) @ rr.ry(r(y)) @ rr.rx(r(x))


def parse_asf(path):
    lines = [l.strip() for l in Path(path).read_text(errors='replace').splitlines()]
    bones = {'root': {'dir': np.zeros(3), 'len': 0.0, 'axis': np.eye(3), 'dof': ['tx', 'ty', 'tz', 'rx', 'ry', 'rz'], 'parent': None}}
    order = ['root']
    section, cur = None, None
    root_order = ['tx', 'ty', 'tz', 'rx', 'ry', 'rz']
    root_axis = np.zeros(3)
    for l in lines:
        if not l or l.startswith('#'):
            continue
        if l.startswith(':'):
            section = l.split()[0]
            continue
        f = l.split()
        if section == ':root':
            if f[0] == 'order':
                root_order = [x.lower() for x in f[1:]]
            elif f[0] == 'orientation':
                root_axis = np.array([float(x) for x in f[1:4]])
        elif section == ':bonedata':
            if f[0] == 'begin':
                cur = {'dir': np.zeros(3), 'len': 0.0, 'axis': np.eye(3), 'dof': [], 'parent': None}
            elif f[0] == 'name':
                cur['name'] = f[1]
            elif f[0] == 'direction':
                cur['dir'] = np.array([float(x) for x in f[1:4]])
            elif f[0] == 'length':
                cur['len'] = float(f[1])
            elif f[0] == 'axis':
                cur['axis'] = euler_xyz(float(f[1]), float(f[2]), float(f[3]))
            elif f[0] == 'dof':
                cur['dof'] = [x.lower() for x in f[1:]]
            elif f[0] == 'end':
                bones[cur['name']] = cur
                order.append(cur['name'])
        elif section == ':hierarchy':
            if f[0] in ('begin', 'end'):
                continue
            for child in f[1:]:
                bones[child]['parent'] = f[0]
    bones['root']['dof'] = root_order
    bones['root']['axis'] = euler_xyz(*root_axis)
    seen, ordered = set(), []

    def visit(n):
        ordered.append(n)
        seen.add(n)
        for k in order:
            if bones[k]['parent'] == n and k not in seen:
                visit(k)
    visit('root')
    return bones, ordered


def parse_amc(path, bones, order, stride=1):
    frames, cur = [], None
    for l in Path(path).read_text(errors='replace').splitlines():
        l = l.strip()
        if not l or l.startswith('#') or l.startswith(':'):
            continue
        f = l.split()
        if f[0].isdigit() and len(f) == 1:
            cur = {}
            frames.append(cur)
        elif cur is not None:
            cur[f[0]] = [float(x) for x in f[1:]]
    frames = frames[::stride]
    n = len(frames)
    pos = {k: np.zeros((n, 3)) for k in order}
    rot = {k: np.zeros((n, 3, 3)) for k in order}
    for i, fr in enumerate(frames):
        for k in order:
            b = bones[k]
            vals = dict(zip(b['dof'], fr.get(k, [])))
            m = euler_xyz(vals.get('rx', 0.0), vals.get('ry', 0.0), vals.get('rz', 0.0))
            local = b['axis'] @ m @ b['axis'].T
            if b['parent'] is None:
                rot[k][i] = local
                pos[k][i] = np.array([vals.get('tx', 0.0), vals.get('ty', 0.0), vals.get('tz', 0.0)])
            else:
                rot[k][i] = rot[b['parent']][i] @ local
                pos[k][i] = pos[b['parent']][i] + b['len'] * (rot[k][i] @ b['dir'])
    return pos, rot


def axis_rot(axis, deg):
    a = math.radians(deg)
    return {'X': rr.rx, 'Y': rr.ry, 'Z': rr.rz}[axis](a)


def forward_kinematics(joints, order, vals):
    n = vals.shape[0]
    pos = {k: np.zeros((n, 3)) for k in order}
    rot = {k: np.zeros((n, 3, 3)) for k in order}
    col = {}
    c = 0
    for k in order:
        col[k] = c
        c += len(joints[k]['channels'])
    for f in range(n):
        for k in order:
            j = joints[k]
            local_t = j['offset'].copy() if j['offset'] is not None else np.zeros(3)
            local_r = np.eye(3)
            ch = j['channels']
            base = col[k]
            has_pos = any(x.endswith('position') for x in ch)
            if has_pos:
                local_t = np.zeros(3)
            for m, name in enumerate(ch):
                v = vals[f, base + m]
                if name.endswith('position'):
                    local_t['XYZ'.index(name[0])] = v
                else:
                    local_r = local_r @ axis_rot(name[0], v)
            p = j['parent']
            if p is None:
                pos[k][f] = local_t
                rot[k][f] = local_r
            else:
                pos[k][f] = pos[p][f] + rot[p][f] @ local_t
                rot[k][f] = rot[p][f] @ local_r
    return pos, rot


def find_roles(order):
    found = {}
    for role, names in ROLES.items():
        for nm in names:
            hit = [k for k in order if k == nm]
            if hit:
                found[role] = hit[0]
                break
        if role not in found:
            low = {k.lower(): k for k in order}
            for nm in names:
                if nm.lower() in low:
                    found[role] = low[nm.lower()]
                    break
    missing = [r for r in ROLES if r not in found]
    return found, missing


def unit(v):
    n = np.linalg.norm(v, axis=-1, keepdims=True)
    return v / np.maximum(n, 1e-9)


def perp(v, axis):
    return v - axis * np.sum(v * axis, axis=-1, keepdims=True)


def frame_from(y_axis, z_hint):
    y = unit(y_axis)
    z = unit(perp(z_hint, y))
    x = np.cross(y, z)
    return np.stack([x, y, z], axis=-1)


def limb_frames(top, mid, low, tip, fallback_z, point_z):
    d = unit(low - top)
    y = -d
    bend = perp(mid - top, d)
    bend_len = np.linalg.norm(bend, axis=-1)
    limb = np.linalg.norm(mid - top, axis=-1) + np.linalg.norm(low - mid, axis=-1)
    hint = fallback_z.copy()
    if tip is not None:
        t = perp(tip - low, y)
        ok = np.linalg.norm(t, axis=-1) > 1e-3 * np.maximum(limb, 1e-6)
        hint[ok] = -unit(t[ok])
    else:
        w = np.clip((bend_len / np.maximum(limb, 1e-6) - 0.02) / 0.08, 0, 1)[:, None]
        hint = unit(point_z * w * unit(bend) + (1 - w) * fallback_z)
    hint = perp(hint, y)
    bad = np.linalg.norm(hint, axis=-1) < 1e-4
    if bad.any():
        hint[bad] = perp(np.tile([0.0, 1.0, 0.0], (int(bad.sum()), 1)), y[bad])
    return frame_from(y, hint), np.linalg.norm(low - top, axis=-1) / np.maximum(limb, 1e-6)


def euler(m):
    lift = math.degrees(math.asin(max(-1.0, min(1.0, m[2, 1]))))
    twist = math.degrees(math.atan2(-m[2, 0], m[2, 2]))
    side = math.degrees(math.atan2(-m[0, 1], m[1, 1]))
    return lift, twist, side


def unwrap(prev, cur):
    l, t, s = cur
    alts = [(l, t, s), (180 - l if l >= 0 else -180 - l, t + 180, s + 180)]
    best, bd = None, 1e18
    for a in alts:
        b = []
        for k in range(3):
            v = a[k]
            if prev is not None:
                v = v + 360 * round((prev[k] - v) / 360)
            b.append(v)
        d = 0 if prev is None else sum((b[k] - prev[k]) ** 2 for k in range(3))
        if d < bd:
            best, bd = b, d
    return best


def torso_frames(P, blend=0.65):
    u = unit(P['neck'] - 0.5 * (P['hip_l'] + P['hip_r']))
    rs = perp(P['shoulder_r'] - P['shoulder_l'], u)
    rh = perp(P['hip_r'] - P['hip_l'], u)
    r = unit(blend * unit(rs) + (1 - blend) * unit(rh))
    return u, r, np.cross(r, u)


def load_positions(path, start=0.0, end=None, blend=0.65, asf=None):
    if str(path).lower().endswith('.amc'):
        asf = asf or next(iter(sorted(Path(path).parent.glob(Path(path).stem.split('_')[0] + '.asf'))), None)
        if asf is None:
            raise SystemExit('an .amc clip needs its skeleton: pass --asf subject.asf')
        bones, order = parse_asf(asf)
        pos, rot = parse_amc(path, bones, order, stride=2)
        dt = 2 / 120.0
        roles = AMC_ROLES
        n = len(pos['root'])
    else:
        joints, order, vals, dt = parse_bvh(path)
        roles, missing = find_roles(order)
        if missing:
            raise SystemExit(f'missing roles {missing}; joints are {order}')
        pos, rot = forward_kinematics(joints, order, vals)
        n = vals.shape[0]
    f0 = int(round(start / dt))
    f1 = n if end is None else min(n, int(round(end / dt)) + 1)
    P = {r: pos[k][f0:f1].copy() for r, k in roles.items()}
    Rh = rot[roles['head']][f0:f1].copy()
    n = f1 - f0

    up0 = P['head'][0] - P['hips'][0]
    ax = int(np.argmax(np.abs(up0)))
    if ax != 1:
        g = np.eye(3)
        if ax == 2:
            g = rr.rx(-math.pi / 2) if up0[2] > 0 else rr.rx(math.pi / 2)
        else:
            g = rr.rz(math.pi / 2) if up0[0] > 0 else rr.rz(-math.pi / 2)
        for r in P:
            P[r] = P[r] @ g.T
        Rh = np.einsum('ij,fjk->fik', g, Rh)
    elif up0[1] < 0:
        g = rr.rx(math.pi)
        for r in P:
            P[r] = P[r] @ g.T
        Rh = np.einsum('ij,fjk->fik', g, Rh)

    def torso_axes():
        return torso_frames(P, blend)

    u, r, b = torso_axes()
    toe_dir = perp((P['toe_l'] + P['toe_r'] - P['ankle_l'] - P['ankle_r'])[0], u[0])
    mirrored = np.dot(-b[0], toe_dir) < 0
    if mirrored:
        m = np.diag([-1.0, 1.0, 1.0])
        for k in P:
            P[k] = P[k] @ m.T
        Rh = np.einsum('ij,fjk,kl->fil', m, Rh, m)
        u, r, b = torso_axes()
    f = -b[0]
    yaw = math.atan2(f[0], -f[2])
    g = rr.ry(yaw)
    hip0 = 0.5 * (P['hip_l'][0] + P['hip_r'][0])
    for k in P:
        P[k] = (P[k] - np.array([hip0[0], 0, hip0[2]])) @ g.T
    Rh = np.einsum('ij,fjk->fik', g, Rh)
    floor = min(P['toe_l'][:, 1].min(), P['toe_r'][:, 1].min(), P['ankle_l'][:, 1].min(), P['ankle_r'][:, 1].min())
    hipmid = 0.5 * (P['hip_l'] + P['hip_r'])
    stand = np.percentile(hipmid[:, 1], 90) - floor
    s = 2.0 / max(stand, 1e-6)
    for k in P:
        P[k] = (P[k] - np.array([0.0, floor, 0.0])) * s
    info = {'source': str(path), 'frames': n, 'fps': round(1 / dt, 3), 'scale_studs_per_unit': s, 'mirrored': bool(mirrored), 'roles': roles}
    return P, Rh, dt, info


def retarget(path, blend=0.65, arm_piston=0.75, leg_slide=True, start=0.0, end=None, asf=None):
    P, Rh, dt, info = load_positions(path, start, end, blend, asf)
    n = len(P['hips'])
    u, r, b = torso_frames(P, blend)
    hipmid = 0.5 * (P['hip_l'] + P['hip_r'])
    R_torso = np.stack([r, u, b], axis=-1)
    torso_center = hipmid + R_torso @ np.array([0.0, 1.0, 0.0])

    arm_r, k_ar = limb_frames(P['shoulder_r'], P['elbow_r'], P['wrist_r'], None, b, 1.0)
    arm_l, k_al = limb_frames(P['shoulder_l'], P['elbow_l'], P['wrist_l'], None, b, 1.0)
    leg_r, k_lr = limb_frames(P['hip_r'], P['knee_r'], P['ankle_r'], P['toe_r'], b, -1.0)
    leg_l, k_ll = limb_frames(P['hip_l'], P['knee_l'], P['ankle_l'], P['toe_l'], b, -1.0)
    head = np.einsum('fij,jk,kl->fil', Rh, Rh[0].T, R_torso[0])

    world = {'Torso': R_torso, 'Head': head, 'Right Arm': arm_r, 'Left Arm': arm_l, 'Right Leg': leg_r, 'Left Leg': leg_l}
    slides = {
        'Right Arm': np.clip((1 - k_ar / max(k_ar.max(), 1e-6)) * 2 * arm_piston, 0, 0.6),
        'Left Arm': np.clip((1 - k_al / max(k_al.max(), 1e-6)) * 2 * arm_piston, 0, 0.6),
        'Right Leg': np.clip((1 - k_lr / max(k_lr.max(), 1e-6)) * 2, 0, 1.2) if leg_slide else np.zeros(n),
        'Left Leg': np.clip((1 - k_ll / max(k_ll.max(), 1e-6)) * 2, 0, 1.2) if leg_slide else np.zeros(n),
        'Head': np.zeros(n),
    }
    frames = []
    for i in range(n):
        poses = {}
        rt = world['Torso'][i]
        poses['Torso'] = (rt, torso_center[i] - np.array([0.0, 3.0, 0.0]))
        for name in ('Head', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg'):
            rw = world[name][i]
            pr = rt.T @ rw
            pp = rt.T @ (rw @ np.array([0.0, slides[name][i], 0.0]))
            poses[name] = (pr, pp)
        frames.append(poses)
    return frames, dt, info


def resample(frames, dt, fps):
    n = len(frames)
    length = (n - 1) * dt
    m = int(round(length * fps)) + 1
    out = []
    for i in range(m):
        t = min(length, i / fps)
        a = min(n - 2, int(t / dt)) if n > 1 else 0
        u = (t - a * dt) / dt if n > 1 else 0
        pose = {}
        for name in frames[0]:
            ra, pa = frames[a][name]
            rb, pb = frames[min(n - 1, a + 1)][name]
            q = rr.slerp(rr.mat_to_quat(ra), rr.mat_to_quat(rb), u)
            pose[name] = (rr.quat_to_mat(q), pa + (pb - pa) * u)
        out.append(pose)
    return out, length


def channels(samples):
    out = {}
    for name in samples[0]:
        prev = None
        rows = []
        for pose in samples:
            m, p = pose[name]
            e = unwrap(prev, euler(m))
            prev = e
            rows.append([e[0], e[1], e[2], p[0], p[1], p[2]])
        out[name] = np.array(rows)
    return out


def decode_text(name, samples, fps, length, loop=False):
    ch = channels(samples)
    lines = [f'#{name} len={length:.3f} loop={str(loop).lower()} frames={len(samples)} prio=Action']
    for i in range(len(samples)):
        t = i / fps
        for jn in sorted(ch):
            c = ch[jn][i]
            lines.append(f'{name}|{jn}|{t:.3f}|{c[0]:.1f}|{c[1]:.1f}|{c[2]:.1f}|{c[3]:.2f}|{c[4]:.2f}|{c[5]:.2f}|Linear|In')
    return '\n'.join(lines) + '\n'


def reduce_keys(times, rows, tol_deg, tol_stud):
    scale = np.array([1 / tol_deg] * 3 + [1 / tol_stud] * 3)
    x = rows * scale
    keep = {0, len(times) - 1}
    stack = [(0, len(times) - 1)]
    while stack:
        a, b = stack.pop()
        if b - a < 2:
            continue
        u = (times[a + 1:b] - times[a]) / (times[b] - times[a])
        line = x[a] + (x[b] - x[a]) * u[:, None]
        err = np.abs(x[a + 1:b] - line).max(axis=1)
        k = int(np.argmax(err))
        if err[k] > 1.0:
            m = a + 1 + k
            keep.add(m)
            stack += [(a, m), (m, b)]
    for c in range(rows.shape[1]):
        v = rows[:, c]
        for i in range(1, len(v) - 1):
            if (v[i] - v[i - 1]) * (v[i + 1] - v[i]) < 0 and abs(v[i] - v[i - 1]) + abs(v[i + 1] - v[i]) > 0:
                span = np.abs(v - v[i]).max()
                if span * scale[c] > 2.0:
                    keep.add(i)
    return sorted(keep)


def lua_clip(name, samples, fps, length, tol_deg=1.5, tol_stud=0.03, loop=False):
    ch = channels(samples)
    times = np.array([i / fps for i in range(len(samples))])
    out = ['return {', f'\tname = "{name}",', f'\tlength = {length:.3f},']
    if loop:
        out.append('\tloop = true,')
    out += ['\tcurve = "spline",', '\tjoints = {']
    counts = {}
    for jn in ['Torso', 'Head', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg']:
        rows = ch[jn]
        idx = reduce_keys(times, rows, tol_deg, tol_stud)
        counts[jn] = len(idx)
        key = jn if ' ' not in jn else f'["{jn}"]'
        out.append(f'\t\t{key} = {{')
        for i in idx:
            c = rows[i]
            out.append(f'\t\t\t{{t = {times[i]:.3f}, r = {{{c[0]:.1f}, {c[1]:.1f}, {c[2]:.1f}}}, p = Vector3.new({c[3]:.3f}, {c[4]:.3f}, {c[5]:.3f})}},')
        out.append('\t\t},')
    out += ['\t},', '}']
    return '\n'.join(out) + '\n', counts


def main():
    ap = argparse.ArgumentParser(description='retarget a BVH motion capture clip onto a stock R6 rig')
    ap.add_argument('bvh')
    ap.add_argument('out')
    ap.add_argument('--name')
    ap.add_argument('--from', dest='start', type=float, default=0.0)
    ap.add_argument('--to', dest='end', type=float)
    ap.add_argument('--fps', type=float, default=60)
    ap.add_argument('--blend', type=float, default=0.65, help='torso facing from the shoulders (1) or the hips (0)')
    ap.add_argument('--arm-piston', type=float, default=0.75, help='how much of an elbow bend becomes an arm slide (0.75 keeps the fist at its real reach, capped at 0.6 studs)')
    ap.add_argument('--no-leg-slide', action='store_true')
    ap.add_argument('--tol', type=float, default=1.5, help='key reduction tolerance in degrees')
    ap.add_argument('--loop', action='store_true')
    ap.add_argument('--asf', help='the skeleton file for an .amc clip (CMU); defaults to <subject>.asf next to it')
    a = ap.parse_args()

    name = a.name or re.sub(r'[^A-Za-z0-9]', '', Path(a.bvh).stem.title())
    frames, dt, info = retarget(a.bvh, a.blend, a.arm_piston, not a.no_leg_slide, a.start, a.end, a.asf)
    samples, length = resample(frames, dt, a.fps)
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    (out / f'{name}.txt').write_text(decode_text(name, samples, a.fps, length, a.loop))
    lua, counts = lua_clip(name, samples, a.fps, length, a.tol, 0.03, a.loop)
    (out / f'{name}.lua').write_text(lua)
    info.update({'name': name, 'length': round(length, 3), 'keys': counts})
    (out / f'{name}.json').write_text(json.dumps(info, indent=1))
    print(json.dumps(info))


if __name__ == '__main__':
    main()
