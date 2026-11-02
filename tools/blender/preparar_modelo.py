"""Prepara un modelo generado por IA (TRELLIS, etc.) para el juego.

Uso:
    blender.exe -b --factory-startup --python tools/blender/preparar_modelo.py -- <entrada.glb> <salida.glb> [alto_m] [max_triangulos] [giro_grados] [textura_px]

- Une todas las mallas, centra el modelo con los pies en el suelo (Z = 0) y lo
  escala a `alto_m` (por defecto 1,82, Nereth).
- Gira `giro_grados` alrededor de Z para que mire a +X (el juego es lateral).
  TRELLIS entrega el modelo mirando a la cámara (-Y en Blender): 90° lo deja a +X.
- Reduce a `max_triangulos` (por defecto 15 000) y reescala las texturas a `textura_px`.
"""

import math
import sys

import bpy
from mathutils import Vector


def argumentos() -> list:
    return sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []


def triangulos(obj: bpy.types.Object) -> int:
    return sum(len(p.vertices) - 2 for p in obj.data.polygons)


def main() -> None:
    args = argumentos()
    entrada, salida = args[0], args[1]
    alto = float(args[2]) if len(args) > 2 else 1.82
    maximo = int(args[3]) if len(args) > 3 else 15000
    giro = float(args[4]) if len(args) > 4 else 90.0
    textura = int(args[5]) if len(args) > 5 else 1024

    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    bpy.ops.import_scene.gltf(filepath=entrada)

    mallas = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    bpy.ops.object.select_all(action="DESELECT")
    for o in mallas:
        o.select_set(True)
    bpy.context.view_layer.objects.active = mallas[0]
    if len(mallas) > 1:
        bpy.ops.object.join()
    obj = bpy.context.object
    # Quitar padres/vacíos importados y aplicar transformaciones
    bpy.ops.object.parent_clear(type="CLEAR_KEEP_TRANSFORM")
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    for o in list(bpy.context.scene.objects):
        if o != obj:
            bpy.data.objects.remove(o, do_unlink=True)
    obj.name = "Modelo"

    # Giro para mirar a +X
    obj.rotation_euler = (0.0, 0.0, math.radians(giro))
    bpy.ops.object.transform_apply(rotation=True)

    # Escala y pies en el suelo
    esquinas = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    minimo = Vector((min(c.x for c in esquinas), min(c.y for c in esquinas), min(c.z for c in esquinas)))
    maximo_v = Vector((max(c.x for c in esquinas), max(c.y for c in esquinas), max(c.z for c in esquinas)))
    factor = alto / max(maximo_v.z - minimo.z, 1e-4)
    obj.scale = (factor, factor, factor)
    bpy.ops.object.transform_apply(scale=True)
    esquinas = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    centro_x = (min(c.x for c in esquinas) + max(c.x for c in esquinas)) / 2.0
    centro_y = (min(c.y for c in esquinas) + max(c.y for c in esquinas)) / 2.0
    obj.location = (-centro_x, -centro_y, -min(c.z for c in esquinas))
    bpy.ops.object.transform_apply(location=True)

    # Reducción de triángulos
    actuales = triangulos(obj)
    if actuales > maximo:
        mod = obj.modifiers.new("Reducir", "DECIMATE")
        mod.ratio = maximo / actuales * 0.97
        bpy.ops.object.modifier_apply(modifier=mod.name)
    print("TRIANGULOS:", actuales, "->", triangulos(obj))

    # Texturas más ligeras
    for imagen in bpy.data.images:
        if imagen.size[0] > textura:
            imagen.scale(textura, textura)
            imagen.pack()

    bpy.ops.export_scene.gltf(filepath=salida, export_format="GLB", export_yup=True, export_apply=True)
    print("EXPORTADO:", salida)


if __name__ == "__main__":
    main()
