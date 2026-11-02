"""Generador del Kit Modular 3D de Escenarios (TAREA-022, D-032, D-037).
Cumple estrictamente:
- ESPECIFICACION_MODELOS.md: <= 3 000 triangulos por pieza, <= 3 materiales.
- Compatibilidad Intel UHD 610 (D-017): metal <= 0.3, rugosidad >= 0.5.
- Orientacion: Y-arriba de Godot, pies/base en y=0 o centrado segun la pieza.
- Carpetas: assets/modelos/kit/<pieza>/<pieza>.glb
"""

import math
import os
import sys

import bpy


def limpiar() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    for col in (bpy.data.meshes, bpy.data.materials, bpy.data.textures, bpy.data.images):
        for item in list(col):
            col.remove(item)


def mat(nombre: str, color: tuple, metal: float = 0.2, rugosidad: float = 0.65,
        emision: tuple = None, emision_fuerza: float = 0.0) -> bpy.types.Material:
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = min(metal, 0.28)  # Regla Compatibility
        bsdf.inputs["Roughness"].default_value = max(rugosidad, 0.5)
        if emision and emision_fuerza > 0.0:
            bsdf.inputs["Emission Color"].default_value = (*emision, 1.0)
            bsdf.inputs["Emission Strength"].default_value = emision_fuerza
    return m


def unir_y_exportar(objetos: list, nombre_nodo: str, ruta_glb: str) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    for o in objetos:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objetos[0]
    if len(objetos) > 1:
        bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = nombre_nodo
    obj.data.name = nombre_nodo
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

    os.makedirs(os.path.dirname(os.path.abspath(ruta_glb)), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=ruta_glb,
        export_format="GLB",
        export_yup=True,
        export_apply=True
    )
    print(f"[OK] Exportado: {ruta_glb}")


# ==============================================================================
# 1. PUERTA OJIVAL (Salón del Prefecto: 3 x 6 m, madera y forja)
# ==============================================================================
def pieza_puerta_ojival(base_dir: str) -> None:
    limpiar()
    m_piedra = mat("piedra_gotica", (0.52, 0.49, 0.46), metal=0.05, rugosidad=0.85)
    m_madera = mat("madera_roble", (0.32, 0.22, 0.16), metal=0.05, rugosidad=0.72)
    m_forja = mat("hierro_forjado", (0.22, 0.22, 0.24), metal=0.25, rugosidad=0.55)
    piezas = []

    ancho = 3.0
    alto = 6.0
    alto_imposta = 3.8
    luz = 2.1
    grosor_marco = 0.5

    # Jambas laterales escalonadas
    for lado in (-1.0, 1.0):
        x = lado * (luz * 0.5 + 0.22)
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, 0, alto_imposta * 0.5))
        j = bpy.context.object
        j.scale = (0.45, grosor_marco, alto_imposta)
        j.data.materials.append(m_piedra)
        piezas.append(j)

        # Capitel de imposta
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, 0, alto_imposta + 0.12))
        cap = bpy.context.object
        cap.scale = (0.6, grosor_marco * 1.15, 0.25)
        cap.data.materials.append(m_piedra)
        piezas.append(cap)

    # Dovelas del arco ojival
    for s in range(10):
        t = s / 9.0
        ang = math.pi * (0.12 + t * 0.76)
        px = (t - 0.5) * (luz + 0.5)
        pz = alto_imposta + math.sin(ang) * (alto - alto_imposta) * 1.25
        pz = min(pz, alto)
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(px, 0, pz))
        dov = bpy.context.object
        dov.scale = (0.4, grosor_marco, 0.32)
        dov.data.materials.append(m_piedra)
        piezas.append(dov)

    # Hojas dobles de madera
    ancho_hoja = luz * 0.49
    alto_hoja = 3.8
    for lado in (-1.0, 1.0):
        hx = lado * (ancho_hoja * 0.5 + 0.01)
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(hx, -0.04, alto_hoja * 0.5))
        h = bpy.context.object
        h.scale = (ancho_hoja, 0.1, alto_hoja)
        h.data.materials.append(m_madera)
        piezas.append(h)

        # Bandas de hierro horizontales
        for hz in (0.7, 1.9, 3.2):
            bpy.ops.mesh.primitive_cube_add(size=1.0, location=(hx, -0.04 - 0.055, hz))
            banda = bpy.context.object
            banda.scale = (ancho_hoja * 0.96, 0.025, 0.09)
            banda.data.materials.append(m_forja)
            piezas.append(banda)

        # Argollas
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.1, depth=0.03,
                                            location=(lado * 0.25, -0.12, 1.8))
        arg = bpy.context.object
        arg.rotation_euler = (math.pi * 0.5, 0, 0)
        arg.data.materials.append(m_forja)
        piezas.append(arg)

    # Tímpano gótico superior
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.04, alto_imposta + 0.8))
    timp = bpy.context.object
    timp.scale = (luz * 0.95, 0.12, 1.4)
    timp.data.materials.append(m_madera)
    piezas.append(timp)

    out = os.path.join(base_dir, "puerta_ojival", "puerta_ojival.glb")
    unir_y_exportar(piezas, "PuertaOjival", out)


# ==============================================================================
# 2. MECANISMO DE ENGRANAJES (Salón: disco de 3-4 m, plano en muro Z)
# ==============================================================================
def pieza_mecanismo_engranajes(base_dir: str) -> None:
    limpiar()
    m_laton = mat("laton_dorado", (0.76, 0.62, 0.28), metal=0.25, rugosidad=0.52)
    m_hierro = mat("hierro_eje", (0.24, 0.23, 0.25), metal=0.22, rugosidad=0.6)
    piezas = []

    radio = 1.9
    dientes = 24
    grosor = 0.12

    # Corona exterior
    bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=radio, depth=grosor, location=(0, 0, 0))
    corona = bpy.context.object
    corona.data.materials.append(m_laton)
    piezas.append(corona)

    # Dientes
    for i in range(dientes):
        ang = (i / dientes) * math.tau
        dx = math.cos(ang) * (radio + 0.1)
        dz = math.sin(ang) * (radio + 0.1)
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(dx, 0, dz), rotation=(0, -ang, 0))
        d = bpy.context.object
        d.scale = (0.2, grosor * 0.96, 0.14)
        d.data.materials.append(m_laton)
        piezas.append(d)

    # Anillo astrológico medio
    bpy.ops.mesh.primitive_cylinder_add(vertices=36, radius=1.35, depth=grosor * 1.3, location=(0, 0, 0))
    anillo = bpy.context.object
    anillo.data.materials.append(m_laton)
    piezas.append(anillo)

    # 6 Radios curvados ornamentales
    for r in range(6):
        ang = (r / 6) * math.tau
        bx = math.cos(ang) * 0.95
        bz = math.sin(ang) * 0.95
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(bx, 0, bz), rotation=(0, -ang, 0))
        brazo = bpy.context.object
        brazo.scale = (1.1, grosor * 0.8, 0.1)
        brazo.data.materials.append(m_laton)
        piezas.append(brazo)

    # Núcleo y eje central
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.55, depth=grosor * 1.6, location=(0, 0, 0))
    buje = bpy.context.object
    buje.data.materials.append(m_laton)
    piezas.append(buje)

    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.22, depth=grosor * 2.2, location=(0, 0, 0))
    eje = bpy.context.object
    eje.data.materials.append(m_hierro)
    piezas.append(eje)

    out = os.path.join(base_dir, "mecanismo_engranajes", "mecanismo_engranajes.glb")
    unir_y_exportar(piezas, "MecanismoEngranajes", out)


# ==============================================================================
# 3. FAROLA DE FORJA (Barrio/Ruinas: 3 m alto, cristal emisivo, sin luz)
# ==============================================================================
def pieza_farola_forja(base_dir: str) -> None:
    limpiar()
    m_forja = mat("hierro_forjado", (0.2, 0.2, 0.22), metal=0.25, rugosidad=0.58)
    m_llama = mat("cristal_ambar", (1.0, 0.75, 0.35), emision=(1.0, 0.65, 0.22), emision_fuerza=4.0)
    piezas = []

    # Pedestal octagonal
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.3, depth=0.25, location=(0, 0, 0.125))
    basa = bpy.context.object
    basa.data.materials.append(m_forja)
    piezas.append(basa)

    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.22, depth=0.3, location=(0, 0, 0.38))
    basa2 = bpy.context.object
    basa2.data.materials.append(m_forja)
    piezas.append(basa2)

    # Fuste
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.075, depth=1.8, location=(0, 0, 1.4))
    fuste = bpy.context.object
    fuste.data.materials.append(m_forja)
    piezas.append(fuste)

    # Anillo
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.11, depth=0.06, location=(0, 0, 1.85))
    anillo = bpy.context.object
    anillo.data.materials.append(m_forja)
    piezas.append(anillo)

    # Capitel soporte
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.08, radius2=0.2, depth=0.25, location=(0, 0, 2.42))
    cap = bpy.context.object
    cap.data.materials.append(m_forja)
    piezas.append(cap)

    # Farol hexagonal
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.22, depth=0.06, location=(0, 0, 2.58))
    bfarol = bpy.context.object
    bfarol.data.materials.append(m_forja)
    piezas.append(bfarol)

    # Núcleo emisivo
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.18, depth=0.42, location=(0, 0, 2.82))
    llama = bpy.context.object
    llama.data.materials.append(m_llama)
    piezas.append(llama)

    # Tejadillo y pináculo (3.0 m total)
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.24, radius2=0.02, depth=0.28, location=(0, 0, 3.16))
    techo = bpy.context.object
    techo.data.materials.append(m_forja)
    piezas.append(techo)

    out = os.path.join(base_dir, "farola_forja", "farola_forja.glb")
    unir_y_exportar(piezas, "FarolaForja", out)


# ==============================================================================
# 4. BARANDILLA ORNAMENTAL (Barrio/Ruinas: tramo de 4 m de forja)
# ==============================================================================
def pieza_barandilla_ornamental(base_dir: str) -> None:
    limpiar()
    m_forja = mat("hierro_forjado", (0.2, 0.2, 0.22), metal=0.25, rugosidad=0.55)
    piezas = []

    largo = 4.0
    alto = 1.15

    # 3 Postes (extremos y centro)
    for px in (-2.0, 0.0, 2.0):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(px, 0, alto * 0.5))
        poste = bpy.context.object
        poste.scale = (0.08, 0.08, alto)
        poste.data.materials.append(m_forja)
        piezas.append(poste)

        # Pináculo
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.06, radius2=0.0, depth=0.15,
                                        location=(px, 0, alto + 0.075), rotation=(0, 0, math.pi * 0.25))
        pin = bpy.context.object
        pin.data.materials.append(m_forja)
        piezas.append(pin)

    # Pasamanos superior y larguero inferior
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, alto))
    pasa = bpy.context.object
    pasa.scale = (largo, 0.07, 0.04)
    pasa.data.materials.append(m_forja)
    piezas.append(pasa)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.12))
    larg = bpy.context.object
    larg.scale = (largo, 0.05, 0.035)
    larg.data.materials.append(m_forja)
    piezas.append(larg)

    # Barrotes verticales con arquitos (19 barrotes)
    num = 19
    paso = (largo - 0.2) / (num - 1)
    for i in range(num):
        bx = - (largo - 0.2) * 0.5 + i * paso
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(bx, 0, (alto + 0.12) * 0.5))
        bar = bpy.context.object
        bar.scale = (0.03, 0.03, alto - 0.14)
        bar.data.materials.append(m_forja)
        piezas.append(bar)

        # Anillo decorativo
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.03, depth=0.035, location=(bx, 0, 0.85))
        anillo = bpy.context.object
        anillo.data.materials.append(m_forja)
        piezas.append(anillo)

    out = os.path.join(base_dir, "barandilla_ornamental", "barandilla_ornamental.glb")
    unir_y_exportar(piezas, "BarandillaOrnamental", out)


# ==============================================================================
# 5. ARCADA PRIMER PLANO (Barrio: 4 x 7 m con cadenas colgando, silueta Z > 3)
# ==============================================================================
def pieza_arcada_primer_plano(base_dir: str) -> None:
    limpiar()
    m_silueta = mat("piedra_silueta", (0.16, 0.15, 0.16), metal=0.05, rugosidad=0.92)
    m_forja = mat("hierro_cadena", (0.18, 0.18, 0.19), metal=0.25, rugosidad=0.6)
    piezas = []

    ancho = 4.0
    alto = 7.0
    luz = 2.8
    alto_arranque = 4.4
    grosor = 0.65

    # Columnas laterales robustas
    for lado in (-1.0, 1.0):
        cx = lado * (luz * 0.5 + 0.35)
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(cx, 0, alto_arranque * 0.5))
        col = bpy.context.object
        col.scale = (0.7, grosor, alto_arranque)
        col.data.materials.append(m_silueta)
        piezas.append(col)

    # Arco superior ojival apuntado
    for s in range(12):
        t = s / 11.0
        ang = math.pi * (0.12 + t * 0.76)
        px = (t - 0.5) * (luz + 0.6)
        pz = alto_arranque + math.sin(ang) * (alto - alto_arranque) * 1.3
        pz = min(pz, alto)
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(px, 0, pz))
        dov = bpy.context.object
        dov.scale = (0.5, grosor, 0.38)
        dov.data.materials.append(m_silueta)
        piezas.append(dov)

    # Muro superior continuo
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, alto - 0.2))
    dintel = bpy.context.object
    dintel.scale = (ancho + 0.4, grosor * 0.95, 0.4)
    dintel.data.materials.append(m_silueta)
    piezas.append(dintel)

    # 2 Cadenas de hierro colgando de la clave y de un lado
    for cad_x in (-0.8, 0.7):
        cad_len = 1.8 if cad_x < 0 else 1.3
        eslabones = 6
        for k in range(eslabones):
            kz = 5.2 - k * (cad_len / eslabones)
            bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.06, depth=0.02, location=(cad_x, 0, kz))
            esl = bpy.context.object
            esl.rotation_euler = (math.pi * 0.5, 0, (k % 2) * math.pi * 0.5)
            esl.data.materials.append(m_forja)
            piezas.append(esl)

    out = os.path.join(base_dir, "arcada_primer_plano", "arcada_primer_plano.glb")
    unir_y_exportar(piezas, "ArcadaPrimerPlano", out)


# ==============================================================================
# 6. COLUMNA CON CAPITEL (Cámara: 6 m, entera y rota)
# ==============================================================================
def pieza_columna_capitel(base_dir: str) -> None:
    # 6A. Entera (Desfase)
    limpiar()
    m_piedra = mat("piedra_cripta", (0.54, 0.51, 0.48), metal=0.05, rugosidad=0.82)
    piezas = []

    alto = 6.0
    r_fuste = 0.45

    # Plinto y basa
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.22))
    plinto = bpy.context.object
    plinto.scale = (1.4, 1.4, 0.44)
    plinto.data.materials.append(m_piedra)
    piezas.append(plinto)

    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.58, depth=0.28, location=(0, 0, 0.58))
    toro = bpy.context.object
    toro.data.materials.append(m_piedra)
    piezas.append(toro)

    # Fuste
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=r_fuste, depth=alto - 1.6,
                                        location=(0, 0, (alto - 1.6) * 0.5 + 0.72))
    fuste = bpy.context.object
    fuste.data.materials.append(m_piedra)
    piezas.append(fuste)

    # Capitel acampanado
    z_cap = alto - 0.8
    bpy.ops.mesh.primitive_cone_add(vertices=20, radius1=r_fuste, radius2=0.72, depth=0.5,
                                    location=(0, 0, z_cap + 0.25))
    cap = bpy.context.object
    cap.data.materials.append(m_piedra)
    piezas.append(cap)

    # Volutas esquineras
    for c in range(4):
        ang = c * math.pi * 0.5 + math.pi * 0.25
        cx = math.cos(ang) * 0.52
        cy = math.sin(ang) * 0.52
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.15, radius2=0.03, depth=0.38,
                                        location=(cx, cy, z_cap + 0.22),
                                        rotation=(0.35 * math.sin(ang), -0.35 * math.cos(ang), ang))
        vol = bpy.context.object
        vol.data.materials.append(m_piedra)
        piezas.append(vol)

    # Ábaco superior
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, alto - 0.16))
    abaco = bpy.context.object
    abaco.scale = (1.45, 1.45, 0.32)
    abaco.data.materials.append(m_piedra)
    piezas.append(abaco)

    out_entera = os.path.join(base_dir, "columna_capitel", "columna_capitel.glb")
    unir_y_exportar(piezas, "ColumnaCapitel", out_entera)

    # 6B. Rota (Realidad)
    limpiar()
    m_piedra_rota = mat("piedra_cripta", (0.5, 0.47, 0.44), metal=0.05, rugosidad=0.88)
    piezas_rotas = []

    # Plinto y basa intactos
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.22))
    plinto = bpy.context.object
    plinto.scale = (1.4, 1.4, 0.44)
    plinto.data.materials.append(m_piedra_rota)
    piezas_rotas.append(plinto)

    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.58, depth=0.28, location=(0, 0, 0.58))
    toro = bpy.context.object
    toro.data.materials.append(m_piedra_rota)
    piezas_rotas.append(toro)

    # Fuste truncado a 2.6 m con fractura inclinada
    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=r_fuste, depth=2.0, location=(0, 0, 1.72))
    fuste_bajo = bpy.context.object
    fuste_bajo.data.materials.append(m_piedra_rota)
    piezas_rotas.append(fuste_bajo)

    # Bloques de fractura / remate irregular
    for b in range(5):
        ang_b = b * (math.tau / 5)
        bx = math.cos(ang_b) * 0.22
        by = math.sin(ang_b) * 0.22
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.22, radius2=0.04, depth=0.45,
                                        location=(bx, by, 2.75), rotation=(0.2, -0.3, ang_b))
        frag = bpy.context.object
        frag.data.materials.append(m_piedra_rota)
        piezas_rotas.append(frag)

    # Escombros caídos al pie de la columna
    for es in range(4):
        ang_e = es * (math.tau / 4) + 0.4
        ex = math.cos(ang_e) * 0.85
        ey = math.sin(ang_e) * 0.85
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(ex, ey, 0.18),
                                        rotation=(0.4, 0.5 * es, 0.3 * es))
        escombro = bpy.context.object
        escombro.scale = (0.35, 0.28, 0.25)
        escombro.data.materials.append(m_piedra_rota)
        piezas_rotas.append(escombro)

    out_rota = os.path.join(base_dir, "columna_capitel", "columna_capitel_rota.glb")
    unir_y_exportar(piezas_rotas, "ColumnaCapitelRota", out_rota)


# ==============================================================================
# 7. ARCO APUNTADO DOBLE (Cámara: 6 x 7 m, fondo, entero y roto)
# ==============================================================================
def pieza_arco_apuntado_doble(base_dir: str) -> None:
    # 7A. Entero (Desfase)
    limpiar()
    m_piedra = mat("piedra_cripta", (0.53, 0.5, 0.47), metal=0.05, rugosidad=0.84)
    piezas = []

    ancho = 6.0
    alto = 7.0
    grosor = 0.5
    luz_total = 5.2
    luz_arco = 2.3
    alto_columna = 3.8

    # 3 Columnas de soporte (izq, centro, der)
    for i, col_x in enumerate((-luz_total * 0.5 + 0.2, 0.0, luz_total * 0.5 - 0.2)):
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.3, depth=alto_columna,
                                            location=(col_x, 0, alto_columna * 0.5))
        c = bpy.context.object
        c.data.materials.append(m_piedra)
        piezas.append(c)

        # Capitel
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(col_x, 0, alto_columna + 0.12))
        cap = bpy.context.object
        cap.scale = (0.68, grosor * 1.1, 0.25)
        cap.data.materials.append(m_piedra)
        piezas.append(cap)

    # Dos arcos apuntados gemelos
    for arco_idx, centro_x in enumerate((-luz_arco * 0.5 - 0.1, luz_arco * 0.5 + 0.1)):
        for s in range(8):
            t = s / 7.0
            ang = math.pi * (0.15 + t * 0.7)
            px = centro_x + (t - 0.5) * luz_arco
            pz = alto_columna + math.sin(ang) * (alto - alto_columna) * 1.1
            bpy.ops.mesh.primitive_cube_add(size=1.0, location=(px, 0, pz))
            dov = bpy.context.object
            dov.scale = (0.35, grosor, 0.26)
            dov.data.materials.append(m_piedra)
            piezas.append(dov)

    # Gran arco envolvente superior
    for s in range(12):
        t = s / 11.0
        ang = math.pi * (0.1 + t * 0.8)
        px = (t - 0.5) * luz_total
        pz = alto_columna + 0.8 + math.sin(ang) * (alto - alto_columna - 0.8) * 1.25
        pz = min(pz, alto)
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(px, 0, pz))
        dov2 = bpy.context.object
        dov2.scale = (0.45, grosor * 0.9, 0.3)
        dov2.data.materials.append(m_piedra)
        piezas.append(dov2)

    out_entero = os.path.join(base_dir, "arco_apuntado_doble", "arco_apuntado_doble.glb")
    unir_y_exportar(piezas, "ArcoApuntadoDoble", out_entero)

    # 7B. Roto (Realidad)
    limpiar()
    m_piedra_rota = mat("piedra_cripta", (0.48, 0.45, 0.42), metal=0.05, rugosidad=0.88)
    piezas_rotas = []

    # Columna izquierda entera y central rota a media altura
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.3, depth=alto_columna,
                                        location=(-luz_total * 0.5 + 0.2, 0, alto_columna * 0.5))
    c1 = bpy.context.object
    c1.data.materials.append(m_piedra_rota)
    piezas_rotas.append(c1)

    # Columna central rota a 1.8 m
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.3, depth=1.8, location=(0.0, 0, 0.9))
    c2 = bpy.context.object
    c2.data.materials.append(m_piedra_rota)
    piezas_rotas.append(c2)

    # Columna derecha entera
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.3, depth=alto_columna,
                                        location=(luz_total * 0.5 - 0.2, 0, alto_columna * 0.5))
    c3 = bpy.context.object
    c3.data.materials.append(m_piedra_rota)
    piezas_rotas.append(c3)

    # Solo el arco izquierdo sobrevive parcialmente; el arco derecho y la clave están colapsados
    centro_x = -luz_arco * 0.5 - 0.1
    for s in range(5):
        t = s / 7.0
        ang = math.pi * (0.15 + t * 0.7)
        px = centro_x + (t - 0.5) * luz_arco
        pz = alto_columna + math.sin(ang) * (alto - alto_columna) * 1.1
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(px, 0, pz))
        dov = bpy.context.object
        dov.scale = (0.35, grosor, 0.26)
        dov.data.materials.append(m_piedra_rota)
        piezas_rotas.append(dov)

    # Dovelas caídas en el suelo en el centro
    for es in range(5):
        ex = (es - 2) * 0.45
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(ex, 0, 0.2),
                                        rotation=(0.3, 0.4 * es, 0.2))
        escombro = bpy.context.object
        escombro.scale = (0.42, 0.35, 0.28)
        escombro.data.materials.append(m_piedra_rota)
        piezas_rotas.append(escombro)

    out_roto = os.path.join(base_dir, "arco_apuntado_doble", "arco_apuntado_doble_roto.glb")
    unir_y_exportar(piezas_rotas, "ArcoApuntadoDobleRoto", out_roto)


# ==============================================================================
# 8. BRASERO TRÍPODE (Cámara: 1.2 m, hierro y llama emisiva, sin luz física)
# ==============================================================================
def pieza_brasero_tripode(base_dir: str) -> None:
    limpiar()
    m_forja = mat("hierro_brasero", (0.22, 0.21, 0.22), metal=0.25, rugosidad=0.55)
    m_fuego = mat("fuego_emisivo", (1.0, 0.42, 0.08), emision=(1.0, 0.38, 0.05), emision_fuerza=5.0)
    piezas = []

    alto_total = 1.2
    alto_cuenco = 0.82
    r_cuenco = 0.42

    # 3 Patas en trípode
    for i in range(3):
        ang = i * (math.tau / 3.0)
        px1 = math.cos(ang) * 0.42
        py1 = math.sin(ang) * 0.42
        px2 = math.cos(ang) * 0.32
        py2 = math.sin(ang) * 0.32

        mid_x = (px1 + px2) * 0.5
        mid_y = (py1 + py2) * 0.5
        bpy.ops.mesh.primitive_cube_add(
            size=1.0,
            location=(mid_x, mid_y, alto_cuenco * 0.48),
            rotation=(0.14 * math.sin(ang), -0.14 * math.cos(ang), ang)
        )
        pata = bpy.context.object
        pata.scale = (0.05, 0.05, 0.95)
        pata.data.materials.append(m_forja)
        piezas.append(pata)

        # Garra pie
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.07, radius2=0.02, depth=0.15,
                                        location=(px1 * 1.05, py1 * 1.05, 0.075))
        pie = bpy.context.object
        pie.data.materials.append(m_forja)
        piezas.append(pie)

    # Anillo collar de unión
    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.28, depth=0.05, location=(0, 0, 0.32))
    aro = bpy.context.object
    aro.data.materials.append(m_forja)
    piezas.append(aro)

    # Cuenco de hierro
    bpy.ops.mesh.primitive_cone_add(vertices=20, radius1=r_cuenco * 0.65, radius2=r_cuenco,
                                    depth=0.3, location=(0, 0, alto_cuenco + 0.1))
    cuenco = bpy.context.object
    cuenco.data.materials.append(m_forja)
    piezas.append(cuenco)

    # Reborde
    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=r_cuenco + 0.04, depth=0.06,
                                        location=(0, 0, alto_cuenco + 0.25))
    reborde = bpy.context.object
    reborde.data.materials.append(m_forja)
    piezas.append(reborde)

    # Ascuas emisivas de carbón
    bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=7, radius=r_cuenco * 0.88,
                                         location=(0, 0, alto_cuenco + 0.18))
    ascuas = bpy.context.object
    ascuas.scale = (1.0, 1.0, 0.35)
    ascuas.data.materials.append(m_fuego)
    piezas.append(ascuas)

    # Lenguas de llama (1.2 m altura máxima)
    for f in range(4):
        ang_f = f * (math.tau / 4.0)
        fx = math.cos(ang_f) * 0.14
        fy = math.sin(ang_f) * 0.14
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=0.08, radius2=0.0, depth=0.25,
                                        location=(fx, fy, alto_cuenco + 0.36))
        llama = bpy.context.object
        llama.data.materials.append(m_fuego)
        piezas.append(llama)

    out = os.path.join(base_dir, "brasero_tripode", "brasero_tripode.glb")
    unir_y_exportar(piezas, "BraseroTripode", out)


# ==============================================================================
# EJECUCIÓN PRINCIPAL
# ==============================================================================
if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    base_dir = args[0] if args else "assets/modelos/kit"
    os.makedirs(base_dir, exist_ok=True)

    print("=== Generando TAREA-022: Kit Modular 3D (8 piezas + 2 rotas) ===")
    pieza_puerta_ojival(base_dir)
    pieza_mecanismo_engranajes(base_dir)
    pieza_farola_forja(base_dir)
    pieza_barandilla_ornamental(base_dir)
    pieza_arcada_primer_plano(base_dir)
    pieza_columna_capitel(base_dir)
    pieza_arco_apuntado_doble(base_dir)
    pieza_brasero_tripode(base_dir)
    print("=== Kit modular generado con éxito ===")
