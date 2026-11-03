"""Prepara los props de alta definicion generados con TRELLIS (Hugging Face)
para Godot 4.7.2 segun ESPECIFICACION_MODELOS.md y renderizador Compatibility (D-017).
- Escala correcta en metros.
- Decimacion a <= 3 000 triangulos preservando detalle esculpido.
- Calibracion PBR (metal <= 0.25, rugosidad >= 0.55).
- Orientacion Y-arriba de Godot.
"""

import os
import bpy


def limpiar() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def procesar_prop(ruta_entrada: str, ruta_salida: str, escala_objetivo: tuple,
                  max_triangulos: int = 2800) -> None:
    limpiar()
    print(f"--- Procesando {ruta_entrada} -> {ruta_salida} ---")
    bpy.ops.import_scene.gltf(filepath=ruta_entrada)
    
    mallas = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not mallas:
        print("ERROR: no se encontraron mallas.")
        return
    
    # Unir si hay varias
    bpy.ops.object.select_all(action="DESELECT")
    for m in mallas:
        m.select_set(True)
    bpy.context.view_layer.objects.active = mallas[0]
    if len(mallas) > 1:
        bpy.ops.object.join()
    obj = bpy.context.object

    # Centrar origen en la base
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    
    # Decimar si supera max_triangulos
    total_caras = len(obj.data.polygons)
    if total_caras > max_triangulos:
        ratio = max_triangulos / total_caras
        mod = obj.modifiers.new("Decimar", "DECIMATE")
        mod.ratio = ratio
        bpy.ops.object.modifier_apply(modifier="Decimar")
        print(f"  Decimado de {total_caras} a {len(obj.data.polygons)} caras (ratio: {ratio:.3f})")

    # Ajustar dimensiones exactas (X, Y, Z de Blender: Z es alto, X es ancho, Y es grosor)
    obj.dimensions = escala_objetivo
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

    # Calibrar materiales para Compatibility
    for m in obj.data.materials:
        if m and m.use_nodes:
            bsdf = m.node_tree.nodes.get("Principled BSDF")
            if bsdf:
                if "Metallic" in bsdf.inputs:
                    bsdf.inputs["Metallic"].default_value = min(bsdf.inputs["Metallic"].default_value, 0.25)
                if "Roughness" in bsdf.inputs:
                    bsdf.inputs["Roughness"].default_value = max(bsdf.inputs["Roughness"].default_value, 0.55)

    # Exportar
    os.makedirs(os.path.dirname(os.path.abspath(ruta_salida)), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=ruta_salida,
        export_format="GLB",
        export_yup=True,
        export_apply=True
    )
    print(f"[OK] Exportado con éxito: {ruta_salida} ({len(obj.data.polygons)} triángulos)")


if __name__ == "__main__":
    # 1. Puerta Ojival Monumental (3.2 m ancho, 0.6 m fondo, 6.0 m alto)
    procesar_prop(
        "assets/modelos/kit/puerta_ojival/puerta_ojival_trellis.glb",
        "assets/modelos/kit/puerta_ojival/puerta_ojival_hd.glb",
        (3.2, 0.6, 6.0),
        max_triangulos=2800
    )

    # 2. Mecanismo de Engranajes (3.8 m ancho, 0.25 m fondo, 3.8 m alto)
    procesar_prop(
        "assets/modelos/kit/mecanismo_engranajes/mecanismo_engranajes_trellis.glb",
        "assets/modelos/kit/mecanismo_engranajes/mecanismo_engranajes_hd.glb",
        (3.8, 0.25, 3.8),
        max_triangulos=2800
    )
