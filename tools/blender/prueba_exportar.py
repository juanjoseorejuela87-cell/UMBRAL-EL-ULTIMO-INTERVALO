"""Prueba del flujo Blender sin ventana → .glb para Godot.

Uso:
    blender.exe -b --factory-startup --python tools/blender/prueba_exportar.py -- <salida.glb>

Crea una columna gótica sencilla (basa, fuste, capitel) con un material,
la orienta para Godot (Y arriba, mirando a +X) y la exporta como glTF binario.
"""

import sys

import bpy


def limpiar_escena() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def material(nombre: str, color: tuple) -> bpy.types.Material:
    mat = bpy.data.materials.new(nombre)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85
    return mat


def crear_columna() -> None:
    piedra = material("piedra", (0.42, 0.38, 0.34))
    piezas = []
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.2))
    basa = bpy.context.object
    basa.scale = (1.3, 1.3, 0.4)
    piezas.append(basa)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.45, depth=5.0, location=(0, 0, 2.9))
    piezas.append(bpy.context.object)
    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.45, radius2=0.75, depth=0.5, location=(0, 0, 5.65))
    piezas.append(bpy.context.object)
    for pieza in piezas:
        pieza.data.materials.append(piedra)
        pieza.select_set(True)
    bpy.context.view_layer.objects.active = piezas[0]
    bpy.ops.object.join()
    bpy.context.object.name = "Columna"
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)


def exportar(ruta: str) -> None:
    # El exportador glTF convierte Z-arriba (Blender) a Y-arriba (Godot).
    bpy.ops.export_scene.gltf(filepath=ruta, export_format="GLB", export_yup=True, export_apply=True)


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    salida = argumentos[0] if argumentos else "prueba.glb"
    limpiar_escena()
    crear_columna()
    exportar(salida)
    print("EXPORTADO:", salida)
