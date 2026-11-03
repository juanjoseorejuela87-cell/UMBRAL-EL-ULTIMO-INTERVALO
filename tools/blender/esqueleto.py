"""Añade un esqueleto humanoide sencillo a un modelo de personaje preparado
(de pie, 1,82 m, mirando a +X, pies en Z = 0) y lo exporta con piel (skin).

Uso:
    blender.exe -b --factory-startup --python tools/blender/esqueleto.py -- <entrada.glb> <salida.glb> [pose_t]

Con «pose_t» los brazos del esqueleto son horizontales (modelos generados en
pose en T) y no se aplica la regla del abrigo (la capa va aparte).

Los huesos se colocan por proporciones humanas (no hace falta ajustar a mano).
Los pesos se calculan por cercanía a cada hueso (más robusto que el «calor de
huesos» de Blender con mallas generadas por IA, que no son cerradas). El abrigo
(zona baja alejada de las piernas) sigue a la cadera para no desgarrarse.

Nombres de huesos (los usa scenes/jugador/figura_nereth.gd):
    Cadera, Columna, Pecho, Cuello, Cabeza,
    BrazoSup.L/.R, Antebrazo.L/.R, Mano.L/.R, Muslo.L/.R, Pierna.L/.R, Pie.L/.R
Lado izquierdo = +Y en Blender (el personaje mira a +X); el derecho (-Y) es el
que queda hacia la cámara del juego.
"""

import sys

import bpy
from mathutils import Vector

ALTO = 1.82
# (nombre, cabeza, cola, padre) en metros, para 1,82 m
HUESOS = [
    ("Cadera", (0.0, 0.0, 0.92), (0.0, 0.0, 1.06), None),
    ("Columna", (0.0, 0.0, 1.06), (0.0, 0.0, 1.25), "Cadera"),
    ("Pecho", (0.0, 0.0, 1.25), (0.0, 0.0, 1.46), "Columna"),
    ("Cuello", (0.0, 0.0, 1.46), (0.0, 0.0, 1.57), "Pecho"),
    ("Cabeza", (0.0, 0.0, 1.57), (0.0, 0.0, 1.82), "Cuello"),
]
for lado, s in (("L", 1.0), ("R", -1.0)):
    HUESOS += [
        ("BrazoSup." + lado, (0.0, s * 0.19, 1.44), (0.0, s * 0.23, 1.16), "Pecho"),
        ("Antebrazo." + lado, (0.0, s * 0.23, 1.16), (0.0, s * 0.25, 0.9), "BrazoSup." + lado),
        ("Mano." + lado, (0.0, s * 0.25, 0.9), (0.0, s * 0.26, 0.78), "Antebrazo." + lado),
        ("Muslo." + lado, (0.0, s * 0.1, 0.92), (0.0, s * 0.1, 0.5), "Cadera"),
        ("Pierna." + lado, (0.0, s * 0.1, 0.5), (0.0, s * 0.1, 0.1), "Muslo." + lado),
        ("Pie." + lado, (0.0, s * 0.1, 0.1), (0.14, s * 0.1, 0.02), "Pierna." + lado),
    ]
PIERNAS = {"Muslo.L", "Pierna.L", "Pie.L", "Muslo.R", "Pierna.R", "Pie.R"}

# Variante para modelos en pose en T (brazos horizontales, piernas algo
# abiertas). Medidas tomadas de la referencia nereth_pose_t.png (1,82 m).
HUESOS_POSE_T = [h for h in HUESOS if not h[0].split(".")[0] in ("BrazoSup", "Antebrazo", "Mano", "Muslo", "Pierna", "Pie")]
for lado, s in (("L", 1.0), ("R", -1.0)):
    HUESOS_POSE_T += [
        # TripoSR deja los brazos ~40° por debajo de la horizontal (pose en A)
        ("BrazoSup." + lado, (0.0, s * 0.16, 1.48), (0.0, s * 0.4, 1.3), "Pecho"),
        ("Antebrazo." + lado, (0.0, s * 0.4, 1.3), (0.0, s * 0.6, 1.14), "BrazoSup." + lado),
        ("Mano." + lado, (0.0, s * 0.6, 1.14), (0.0, s * 0.68, 1.07), "Antebrazo." + lado),
        ("Muslo." + lado, (0.0, s * 0.09, 0.96), (0.0, s * 0.11, 0.54), "Cadera"),
        ("Pierna." + lado, (0.0, s * 0.11, 0.54), (0.0, s * 0.14, 0.1), "Muslo." + lado),
        ("Pie." + lado, (0.0, s * 0.14, 0.1), (0.14, s * 0.14, 0.02), "Pierna." + lado),
    ]


def distancia_segmento(p: Vector, a: Vector, b: Vector) -> float:
    ab = b - a
    t = max(0.0, min(1.0, (p - a).dot(ab) / max(ab.length_squared, 1e-9)))
    return (p - (a + ab * t)).length


def main() -> None:
    args = sys.argv[sys.argv.index("--") + 1:]
    entrada, salida = args[0], args[1]
    huesos = HUESOS_POSE_T if "pose_t" in args[2:] else HUESOS
    sin_abrigo = "pose_t" in args[2:]
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    bpy.ops.import_scene.gltf(filepath=entrada)
    malla = next(o for o in bpy.context.scene.objects if o.type == "MESH")
    malla.name = "Nereth"
    escala = malla.dimensions.z / ALTO

    # Esqueleto
    datos = bpy.data.armatures.new("EsqueletoNereth")
    esqueleto = bpy.data.objects.new("Esqueleto", datos)
    bpy.context.collection.objects.link(esqueleto)
    bpy.context.view_layer.objects.active = esqueleto
    bpy.ops.object.mode_set(mode="EDIT")
    segmentos = {}
    for nombre, cabeza, cola, padre in huesos:
        hueso = datos.edit_bones.new(nombre)
        hueso.head = Vector(cabeza) * escala
        hueso.tail = Vector(cola) * escala
        if padre:
            hueso.parent = datos.edit_bones[padre]
        segmentos[nombre] = (hueso.head.copy(), hueso.tail.copy())
    bpy.ops.object.mode_set(mode="OBJECT")

    # Pesos por cercanía: los 3 huesos más cercanos, 1/d^4, y abrigo a la cadera
    grupos = {nombre: malla.vertex_groups.new(name=nombre) for nombre, *_ in huesos}
    mundo = malla.matrix_world
    for v in malla.data.vertices:
        p = mundo @ v.co
        distancias = sorted((distancia_segmento(p, a, b), n) for n, (a, b) in segmentos.items())
        cercanos = distancias[:3]
        pesos = {n: 1.0 / (d ** 4 + 1e-6) for d, n in cercanos}
        dist_pierna = min(d for d, n in distancias if n in PIERNAS)
        if not sin_abrigo and p.z < 0.95 * escala and dist_pierna > 0.12 * escala:
            # Faldones del abrigo: casi todo a la cadera, un poco a la pierna cercana
            pierna = min(((d, n) for d, n in distancias if n in PIERNAS))[1]
            pesos = {"Cadera": 0.8, pierna: 0.2}
        total = sum(pesos.values())
        for n, w in pesos.items():
            grupos[n].add([v.index], w / total, "REPLACE")

    malla.parent = esqueleto
    modificador = malla.modifiers.new("Esqueleto", "ARMATURE")
    modificador.object = esqueleto

    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=salida, export_format="GLB", export_yup=True, export_skins=True,
                              export_animations=False)
    print("EXPORTADO:", salida, "huesos:", len(huesos), "vertices:", len(malla.data.vertices))


if __name__ == "__main__":
    main()
