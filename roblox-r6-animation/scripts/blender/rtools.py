import bpy, os, math
from mathutils import Vector

CAMS = {
    "Player": ((1.75, -5.35, 4.3), (0.0, 0.9, 1.75), 46),
    "Front": ((2.9, 5.2, 2.15), (0.05, 0.1, 1.6), 34),
    "Side": ((6.2, 0.6, 1.85), (0.0, 0.25, 1.55), 34),
    "Back34": ((-3.4, -4.6, 2.6), (0.1, 0.3, 1.6), 36),
}


def render_setup(w=480, h=480, color="TEXTURE", vine=False, face="Head"):
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_WORKBENCH"
    sh = scene.display.shading
    sh.light = "STUDIO"
    sh.color_type = color
    sh.show_shadows = True
    sh.shadow_intensity = 0.35
    sh.show_cavity = True
    sh.cavity_type = "WORLD"
    scene.display.light_direction = (0.35, -0.45, 0.82)
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = False
    scene.render.image_settings.file_format = "PNG"
    faces = {"Head", "HeadBigEyes", "HeadCreepy", "HeadDeadTexture", "HeadHurtTexture"}
    for o in bpy.data.objects:
        if o.name in ("Plane", "DeadMouth", "HurtMouth", "HappyMouth", "Hands", "Camera"):
            o.hide_render = True
        if o.name in faces:
            o.hide_render = o.name != face
        if o.name == "Mouth":
            o.hide_render = face != "Head"
        if o.name == "VineArm":
            o.hide_render = not vine
    if "VineArm" in bpy.data.objects and vine:
        img = bpy.data.images.get("VineGreen") or bpy.data.images.new("VineGreen", 4, 4)
        img.pixels = [0.09, 0.42, 0.05, 1.0] * 16
        for slot in bpy.data.objects["VineArm"].material_slots:
            if slot.material:
                slot.material.diffuse_color = (0.07, 0.21, 0.045, 1)
                if slot.material.node_tree:
                    for nd in slot.material.node_tree.nodes:
                        if nd.type == "TEX_IMAGE":
                            nd.image = img
    kimg = bpy.data.images.get("KnifeRed") or bpy.data.images.new("KnifeRed", 4, 4)
    kimg.pixels = [0.9, 0.08, 0.06, 1.0] * 16
    for o in bpy.data.objects:
        if o.type == "MESH" and o.name == "Cube":
            for slot in o.material_slots:
                if slot.material:
                    slot.material.diffuse_color = (0.9, 0.08, 0.06, 1)
                    if slot.material.node_tree:
                        for nd in slot.material.node_tree.nodes:
                            if nd.type == "TEX_IMAGE":
                                nd.image = kimg
    if "RFloor" not in bpy.data.objects:
        me = bpy.data.meshes.new("RFloor")
        me.from_pydata([(-12, -12, 0), (12, -12, 0), (12, 12, 0), (-12, 12, 0)], [], [(0, 1, 2, 3)])
        ob = bpy.data.objects.new("RFloor", me)
        scene.collection.objects.link(ob)
        mat = bpy.data.materials.new("RFloorMat")
        mat.diffuse_color = (0.55, 0.54, 0.58, 1)
        me.materials.append(mat)
    world = scene.world
    if world:
        world.color = (0.17, 0.17, 0.19)
    cams = {}
    for name, (loc, look, fov) in CAMS.items():
        key = "RC_" + name
        if key in bpy.data.objects:
            ob = bpy.data.objects[key]
        else:
            cam = bpy.data.cameras.new(key)
            ob = bpy.data.objects.new(key, cam)
            scene.collection.objects.link(ob)
        ob.data.sensor_fit = "VERTICAL"
        ob.data.sensor_height = 24
        ob.data.lens = 12 / math.tan(math.radians(fov / 2))
        ob.location = Vector(loc)
        ob.rotation_euler = (Vector(look) - Vector(loc)).to_track_quat("-Z", "Y").to_euler()
        cams[name] = ob
    return cams


def shoot(cams, names, path_fmt):
    scene = bpy.context.scene
    out = []
    for c in names:
        scene.camera = cams[c]
        scene.render.filepath = path_fmt % c
        bpy.ops.render.render(write_still=True)
        out.append(scene.render.filepath)
    return out
