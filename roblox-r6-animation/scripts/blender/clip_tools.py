def render_clip(name, poses, outdir, cams=("Player", "Front"), step=2, vine=False, face="Head", w=360, h=360, only=None, vine_until=None):
    exec(open(os.path.join(D, "rtools.py")).read(), globals())
    os.makedirs(outdir, exist_ok=True)
    cm = render_setup(w, h, vine=vine, face=face)
    idx = list(range(0, len(poses), step))
    if idx[-1] != len(poses) - 1:
        idx.append(len(poses) - 1)
    if only:
        idx = [i for i in only if i < len(poses)]
    for i in idx:
        if vine and vine_until is not None:
            bpy.data.objects["VineArm"].hide_render = i / HZ > vine_until
        apply_pose(poses[i])
        shoot(cm, cams, os.path.join(outdir, "%s_%04d_%%s.png" % (name, i)))
    print("RENDERED", name, len(idx), "frames to", outdir)


def run(name, keys, length, lag=None, render=None, cams=("Player", "Front"), step=2, hair=True, ends=(0.1, 0.12), vine=False, face="Head", post=None, only=None, vine_until=None):
    act, poses, rep = bake(name, keys, length, lag=lag, hair=hair, ends=ends, post=post)
    metrics(name)
    tip_path(name, [k[0] for k in keys])
    if render:
        render_clip(name, poses, os.path.join(D, render), cams=cams, step=step, vine=vine, face=face, only=only, vine_until=vine_until)
    return poses
