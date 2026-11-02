"""Modelo de Nereth por piezas (TAREA-016, D-036, D-037).

Uso:
    blender.exe -b --factory-startup --python tools/blender/nereth.py -- <carpeta_salida>

Genera <carpeta>/nereth.glb y <carpeta>/espada_umbral.glb.

Diseño: hoja de personaje del director (documentation/GUIA_ARTE.md, «Nereth»):
hombre de 1,82 m, atlético y delgado, pelo negro despeinado, cuello alto,
armadura ligera oscura con filos plateados, abrigo hecho jirones, fragmentos
flotando junto al hombro izquierdo y marcas de Continuidad violetas.

Estructura (la que anima scenes/jugador/figura_nereth.gd, sin esqueleto):
    Raiz
    ├── PiernaDetras, PiernaDelante   (pivote en la cadera)
    └── Torso                          (pivote en la cadera)
        ├── BrazoLibre, BrazoEspada    (pivote en el hombro) → Mano
        ├── Capa → Segmento0 → … → Segmento4
        └── Fragmento0 … Fragmento5
Coordenadas de Blender: Z arriba, mirando a +X, la cámara del juego mira desde
-Y (el exportador convierte a Y arriba de Godot: -Y de Blender = +Z de Godot).
"""

import math
import os
import random
import sys

import bmesh
import bpy
from mathutils import Vector

random.seed(1)

ALTO_CADERA = 0.95
ALTO_HOMBRO = 1.44
ANCHO_HOMBRO = 0.2
SEGMENTOS_CAPA = 5
LARGO_SEGMENTO = 0.22


# --- Utilidades ---------------------------------------------------------------

def limpiar() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    for coleccion in (bpy.data.meshes, bpy.data.materials):
        for bloque in list(coleccion):
            coleccion.remove(bloque)


def material(nombre: str, color: tuple, metal: float = 0.0, rugosidad: float = 0.8,
             emision: float = 0.0) -> bpy.types.Material:
    mat = bpy.data.materials.new(nombre)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metal
    bsdf.inputs["Roughness"].default_value = rugosidad
    if emision > 0.0:
        bsdf.inputs["Emission Color"].default_value = (*color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emision
    return mat


MAT = {}


def preparar_materiales() -> None:
    MAT["armadura"] = material("armadura", (0.055, 0.055, 0.065), metal=0.6, rugosidad=0.45)
    MAT["tela"] = material("tela", (0.04, 0.04, 0.05), rugosidad=0.95)
    MAT["plata"] = material("plata", (0.75, 0.76, 0.82), metal=0.9, rugosidad=0.25)
    MAT["piel"] = material("piel", (0.8, 0.75, 0.72), rugosidad=0.7)
    MAT["pelo"] = material("pelo", (0.025, 0.025, 0.03), rugosidad=0.6)
    MAT["marcas"] = material("marcas", (0.55, 0.3, 1.0), emision=3.0)
    MAT["cuero"] = material("cuero", (0.045, 0.035, 0.032), rugosidad=0.75)


def asignar(obj: bpy.types.Object, mat: str) -> bpy.types.Object:
    obj.data.materials.clear()
    obj.data.materials.append(MAT[mat])
    return obj


def cilindro(r1: float, r2: float, z0: float, z1: float, x: float = 0.0, y: float = 0.0,
             lados: int = 8, mat: str = "armadura", escala_x: float = 1.0) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cone_add(vertices=lados, radius1=r1, radius2=r2, depth=abs(z1 - z0),
                                    location=(x, y, (z0 + z1) / 2.0))
    obj = bpy.context.object
    if z1 < z0:
        obj.rotation_euler = (math.pi, 0.0, 0.0)
    obj.scale.x = escala_x
    return asignar(obj, mat)


def caja(tam: tuple, pos: tuple, mat: str = "armadura", rot: tuple = (0.0, 0.0, 0.0)) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=pos, rotation=rot)
    obj = bpy.context.object
    obj.scale = tam
    return asignar(obj, mat)


def esfera(r: float, pos: tuple, mat: str, escala: tuple = (1.0, 1.0, 1.0), seg: int = 10) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=max(seg // 2, 4), radius=r, location=pos)
    obj = bpy.context.object
    obj.scale = escala
    return asignar(obj, mat)


def punta(r: float, largo: float, pos: tuple, rot: tuple, mat: str, lados: int = 4) -> bpy.types.Object:
    """Cono afilado (mechones, placas dentadas, esquirlas)."""
    bpy.ops.mesh.primitive_cone_add(vertices=lados, radius1=r, radius2=0.0, depth=largo, location=pos, rotation=rot)
    return asignar(bpy.context.object, mat)


def unir(piezas: list, nombre: str, pivote: tuple) -> bpy.types.Object:
    bpy.ops.object.select_all(action="DESELECT")
    for p in piezas:
        p.select_set(True)
    bpy.context.view_layer.objects.active = piezas[0]
    if len(piezas) > 1:
        bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = nombre
    obj.data.name = nombre
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    bpy.context.scene.cursor.location = pivote
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
    bpy.ops.object.shade_flat()
    return obj


def vacio(nombre: str, pos: tuple) -> bpy.types.Object:
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=pos)
    obj = bpy.context.object
    obj.name = nombre
    return obj


def emparentar(hijo: bpy.types.Object, padre: bpy.types.Object) -> None:
    hijo.parent = padre
    hijo.matrix_parent_inverse = padre.matrix_world.inverted()


# --- Piezas -------------------------------------------------------------------

def pierna(nombre: str, y: float) -> bpy.types.Object:
    p = []
    p.append(cilindro(0.08, 0.065, ALTO_CADERA, 0.52, y=y, mat="tela"))                   # muslo
    p.append(caja((0.05, 0.13, 0.22), (0.045, y, 0.74), "armadura"))                     # placa del muslo
    p.append(cilindro(0.06, 0.05, 0.53, 0.14, y=y, mat="tela"))                          # pierna
    p.append(caja((0.07, 0.12, 0.09), (0.045, y, 0.53), "plata"))                        # rodillera
    p.append(cilindro(0.068, 0.072, 0.44, 0.05, y=y, mat="cuero"))                       # caña de la bota
    p.append(caja((0.25, 0.1, 0.07), (0.06, y, 0.035), "cuero"))                         # pie
    p.append(caja((0.03, 0.11, 0.05), (0.18, y, 0.04), "plata"))                         # puntera
    return unir(p, nombre, (0.0, y, ALTO_CADERA))


def brazo(nombre: str, y: float, con_marcas: bool) -> bpy.types.Object:
    p = []
    p.append(cilindro(0.052, 0.045, ALTO_HOMBRO, 1.17, y=y, mat="tela"))                 # brazo
    p.append(cilindro(0.046, 0.04, 1.17, 0.93, y=y, mat="tela"))                         # antebrazo
    p.append(cilindro(0.058, 0.05, 1.1, 0.9, y=y, mat="armadura"))                       # guantelete
    p.append(caja((0.02, 0.1, 0.16), (0.05, y, 1.0), "plata"))                           # filo del guantelete
    p.append(caja((0.08, 0.05, 0.09), (0.0, y, 0.85), "cuero"))                          # mano
    if con_marcas:
        for i in range(3):
            p.append(caja((0.012, 0.096, 0.03), (0.0, y, 1.13 - i * 0.06), "marcas"))   # marcas de Continuidad
    return unir(p, nombre, (0.0, y, ALTO_HOMBRO))


def torso() -> bpy.types.Object:
    p = []
    p.append(cilindro(0.13, 0.15, ALTO_CADERA, 1.18, mat="tela", escala_x=0.8))          # abdomen
    p.append(cilindro(0.15, 0.185, 1.15, 1.45, mat="armadura", escala_x=0.75))           # pecho
    p.append(caja((0.03, 0.2, 0.22), (0.12, 0.0, 1.3), "armadura", rot=(0.0, -0.15, 0.0)))  # peto
    p.append(caja((0.012, 0.21, 0.02), (0.137, 0.0, 1.41), "plata"))                     # filo del peto
    p.append(caja((0.012, 0.18, 0.02), (0.128, 0.0, 1.2), "plata"))
    p.append(cilindro(0.145, 0.145, 0.95, 1.0, mat="cuero", escala_x=0.82))              # cinturón
    p.append(caja((0.03, 0.06, 0.05), (0.12, 0.0, 0.975), "plata"))                      # hebilla
    p.append(cilindro(0.075, 0.098, 1.45, 1.555, mat="tela", lados=10))                  # cuello alto (deja ver la cara)
    p.append(cilindro(0.099, 0.1, 1.548, 1.56, mat="plata", lados=10))                    # ribete del cuello
    p.append(cilindro(0.05, 0.048, 1.44, 1.56, mat="piel", lados=8))                     # cuello
    p.append(esfera(0.1, (0.012, 0.0, 1.66), "piel", escala=(1.0, 0.92, 1.15)))          # cabeza
    # Pelo negro despeinado: casquete + mechones que caen hacia atrás y sobre la cara
    p.append(esfera(0.106, (-0.018, 0.0, 1.7), "pelo", escala=(1.0, 1.0, 0.82), seg=8))
    for i in range(13):
        ang = -1.2 + i * 0.2
        p.append(punta(0.04, 0.2, (-0.07 + random.uniform(-0.01, 0.01), math.sin(ang) * 0.09, 1.72 - abs(ang) * 0.04),
                       (0.0, -2.2 + random.uniform(-0.2, 0.2), ang * 0.4), "pelo"))
    for i in range(5):
        p.append(punta(0.03, 0.14, (0.08, -0.07 + i * 0.035, 1.72),
                       (0.0, 2.6 + random.uniform(-0.15, 0.15), random.uniform(-0.3, 0.3)), "pelo"))   # flequillo
    # Hombrera izquierda dentada (lado +Y) y derecha más sobria
    for i in range(4):
        p.append(punta(0.05, 0.18 - i * 0.025, (-0.02 + i * 0.03, ANCHO_HOMBRO + 0.04, 1.5 + i * 0.015),
                       (-0.9 - i * 0.12, 0.25, 0.0), "armadura"))
    p.append(esfera(0.075, (0.0, ANCHO_HOMBRO + 0.01, 1.46), "armadura", escala=(1.1, 1.0, 0.7), seg=8))
    p.append(caja((0.13, 0.015, 0.02), (0.0, ANCHO_HOMBRO + 0.075, 1.47), "plata"))
    p.append(esfera(0.065, (0.0, -ANCHO_HOMBRO - 0.01, 1.46), "armadura", escala=(1.1, 1.0, 0.6), seg=8))
    p.append(caja((0.12, 0.012, 0.018), (0.0, -ANCHO_HOMBRO - 0.07, 1.47), "plata"))
    # Faldones del abrigo a los lados de la cadera
    for lado in (-1.0, 1.0):
        p.append(caja((0.16, 0.02, 0.32), (-0.03, lado * 0.15, 0.82), "tela", rot=(lado * 0.12, 0.0, 0.0)))
    return unir(p, "Torso", (0.0, 0.0, ALTO_CADERA))


def segmento_capa(i: int) -> bpy.types.Object:
    z_alto = ALTO_HOMBRO - i * LARGO_SEGMENTO
    ancho = 0.3 + 0.05 * i
    grosor = 0.03 + 0.008 * i
    p = [caja((grosor, ancho, LARGO_SEGMENTO + 0.02), (-0.14 - 0.015 * i, 0.0, z_alto - LARGO_SEGMENTO / 2.0), "tela")]
    if i == SEGMENTOS_CAPA - 1:
        # Bajo hecho jirones
        for k in range(6):
            yk = -ancho / 2.0 + (k + 0.5) * ancho / 6.0
            p.append(punta(0.045, 0.12 + random.uniform(0.0, 0.1), (-0.14 - 0.015 * i, yk, z_alto - LARGO_SEGMENTO - 0.06),
                           (math.pi, 0.0, 0.0), "tela", lados=3))
    return unir(p, "Segmento%d" % i, (-0.14 - 0.015 * i, 0.0, z_alto))


def fragmentos(padre: bpy.types.Object) -> None:
    centro = Vector((-0.02, ANCHO_HOMBRO + 0.12, 1.62))
    for i in range(6):
        ang = i * math.tau / 6.0
        pos = centro + Vector((math.cos(ang) * 0.13, math.sin(ang) * 0.05, math.sin(ang) * 0.1 + random.uniform(-0.03, 0.03)))
        esquirla = punta(0.022, 0.07 + random.uniform(0.0, 0.05), tuple(pos),
                         (random.uniform(0, 3), random.uniform(0, 3), random.uniform(0, 3)), "armadura", lados=3)
        filo = punta(0.008, 0.05, tuple(pos + Vector((0, -0.012, 0))), (0.3, 0.2, 0.0), "marcas", lados=3)
        frag = unir([esquirla, filo], "Fragmento%d" % i, tuple(pos))
        emparentar(frag, padre)


def construir_nereth() -> None:
    raiz = vacio("Raiz", (0.0, 0.0, 0.0))
    detras = pierna("PiernaDetras", ANCHO_HOMBRO * 0.5)
    delante = pierna("PiernaDelante", -ANCHO_HOMBRO * 0.5)
    tronco = torso()
    libre = brazo("BrazoLibre", ANCHO_HOMBRO + 0.01, True)
    espada = brazo("BrazoEspada", -ANCHO_HOMBRO - 0.01, False)
    mano = vacio("Mano", (0.0, -ANCHO_HOMBRO - 0.01, 0.86))
    for hijo in (detras, delante, tronco):
        emparentar(hijo, raiz)
    for hijo in (libre, espada):
        emparentar(hijo, tronco)
    emparentar(mano, espada)
    capa = vacio("Capa", (-0.14, 0.0, ALTO_HOMBRO))
    emparentar(capa, tronco)
    padre = capa
    for i in range(SEGMENTOS_CAPA):
        seg = segmento_capa(i)
        emparentar(seg, padre)
        padre = seg
    fragmentos(tronco)


# --- Espada del Umbral ---------------------------------------------------------

def construir_espada() -> None:
    """Hoja larga y quebrada con veta violeta; empuñadura en el origen y hoja hacia abajo (-Z)."""
    malla = bpy.data.meshes.new("Hoja")
    bm = bmesh.new()
    perfil = [(0.032, -0.03), (0.036, -0.45), (0.022, -0.58), (0.04, -0.63), (0.03, -0.82), (0.0, -1.0),
              (-0.026, -0.8), (-0.034, -0.6), (-0.02, -0.5), (-0.032, -0.4), (-0.032, -0.03)]
    verts = [bm.verts.new((x, 0.0, z)) for x, z in perfil]
    cara = bm.faces.new(verts)
    resultado = bmesh.ops.extrude_face_region(bm, geom=[cara])
    desplazar = [e for e in resultado["geom"] if isinstance(e, bmesh.types.BMVert)]
    bmesh.ops.translate(bm, verts=desplazar, vec=(0.0, 0.012, 0.0))
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0.0, -0.006, 0.0))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(malla)
    bm.free()
    hoja = bpy.data.objects.new("Hoja", malla)
    bpy.context.collection.objects.link(hoja)
    asignar(hoja, "plata")
    p = [hoja]
    p.append(caja((0.006, 0.016, 0.7), (0.0, 0.0, -0.42), "marcas"))                         # veta violeta
    p.append(caja((0.05, 0.03, 0.035), (0.0, 0.0, 0.0), "armadura"))                         # guarda central
    p.append(punta(0.02, 0.12, (0.08, 0.0, 0.01), (0.0, 1.9, 0.0), "armadura"))               # gavilanes angulosos
    p.append(punta(0.02, 0.12, (-0.08, 0.0, 0.01), (0.0, -1.9, 0.0), "armadura"))
    p.append(cilindro(0.016, 0.016, 0.02, 0.2, mat="cuero"))                                 # empuñadura
    p.append(esfera(0.026, (0.0, 0.0, 0.22), "plata", seg=6))                               # pomo
    unir(p, "EspadaUmbral", (0.0, 0.0, 0.1))


def exportar(ruta: str) -> None:
    bpy.ops.export_scene.gltf(filepath=ruta, export_format="GLB", export_yup=True, export_apply=True,
                              export_extras=False)


if __name__ == "__main__":
    argumentos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    carpeta = argumentos[0] if argumentos else "."
    os.makedirs(carpeta, exist_ok=True)
    limpiar()
    preparar_materiales()
    construir_nereth()
    exportar(os.path.join(carpeta, "nereth.glb"))
    limpiar()
    preparar_materiales()
    construir_espada()
    exportar(os.path.join(carpeta, "espada_umbral.glb"))
    print("EXPORTADO:", carpeta)
