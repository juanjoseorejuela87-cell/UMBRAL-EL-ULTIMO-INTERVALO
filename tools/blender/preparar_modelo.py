"""Prepara un modelo generado por IA (TRELLIS, etc.) para el juego.

Uso:
    blender.exe -b --factory-startup --python tools/blender/preparar_modelo.py -- <entrada.glb> <salida.glb> [alto_m] [max_triangulos] [giro_grados] [textura_px] [eje_vertical]

- `eje_vertical` (x, y, z o «auto», por defecto «auto»): eje del modelo importado
  que debe quedar hacia arriba. En «auto» se usa el más largo, lo que falla con
  piezas más anchas o profundas que altas (arcos, puertas): indícalo a mano.

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
    eje = args[6].lower() if len(args) > 6 else "auto"

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
    # El importador glTF deja los objetos en modo cuaternión: los giros en Euler no surtirían efecto.
    obj.rotation_mode = "XYZ"

    # Poner de pie: si el eje más largo no es Z (TripoSR entrega la figura tumbada
    # a lo largo de X), se gira para que lo sea.
    bpy.context.view_layer.update()
    dim = obj.dimensions.copy()
    print("DIMENSIONES:", tuple(round(v, 3) for v in dim))
    if eje == "auto":
        eje = "x" if dim.x >= dim.y and dim.x > dim.z else ("y" if dim.y > dim.x and dim.y > dim.z else "z")
    if eje == "x":
        obj.rotation_euler = (0.0, math.radians(-90.0), 0.0)
    elif eje == "y":
        obj.rotation_euler = (math.radians(90.0), 0.0, 0.0)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(rotation=True)
    bpy.context.view_layer.update()
    print("DE PIE:", tuple(round(v, 3) for v in obj.dimensions))

    # Giro para mirar a +X
    obj.rotation_euler = (0.0, 0.0, math.radians(giro))
    bpy.ops.object.transform_apply(rotation=True)

    # Colores por vértice (TripoSR) → material que los usa como color base
    if obj.data.color_attributes and not any(m and m.use_nodes and any(n.type == "TEX_IMAGE" for n in m.node_tree.nodes)
                                             for m in obj.data.materials):
        mat = bpy.data.materials.new("color_vertices")
        mat.use_nodes = True
        nodos = mat.node_tree.nodes
        atributo = nodos.new("ShaderNodeVertexColor")
        atributo.layer_name = obj.data.color_attributes[0].name
        bsdf = nodos["Principled BSDF"]
        bsdf.inputs["Roughness"].default_value = 0.8
        mat.node_tree.links.new(atributo.outputs["Color"], bsdf.inputs["Base Color"])
        obj.data.materials.clear()
        obj.data.materials.append(mat)

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
