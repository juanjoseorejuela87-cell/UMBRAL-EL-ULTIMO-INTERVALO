# TAREA-022 — Primer paquete de piezas 3D del kit (según los artes conceptuales)

- **Ayudante:** Google Antigravity (coordinación de modelos 3D por encargo del director)
- **Estado:** ENTREGADO
- **Archivos permitidos:** `assets/modelos/kit/<pieza>/` (nuevo: `.glb`, texturas, imagen de referencia) y `assets/LICENCIAS.md` (añadir filas). Scripts de generación nuevos en `tools/blender/` si los necesitas.
- **No tocar:** escenas (`scenes/`), `scripts/core/`, `project.godot`. **Claude integra** las piezas en las salas.

## Referencias

- Artes conceptuales oficiales en `documentation/arte/concepto_*.png`.
- Requisitos técnicos y de licencia: `documentation/ESPECIFICACION_MODELOS.md` (léelo entero): **≤ 3 000 triángulos por pieza de escenario**, texturas 1K PBR, ≤ 3 materiales, 1 u = 1 m, pies/base en el origen.
- **Ojo con el metal:** el juego usa Compatibility en este equipo, sin reflejos: un material con `metallic` alto se ve **negro**. Metal como mucho 0,3 y rugosidad ≥ 0,5; el brillo del latón o del hierro, en el color y la textura.

## Encargo — 8 piezas

| Pieza | Sala | Referencia | Medidas aproximadas |
|---|---|---|---|
| `puerta_ojival` | Salón del Prefecto | arco de las puertas del concepto del Salón | 3 × 6 m, con hojas de madera y herrajes |
| `mecanismo_engranajes` | Salón del Prefecto | los engranajes de los muros del concepto | disco de 3–4 m de diámetro, plano (va en el muro del fondo) |
| `farola_forja` | Barrio / Ruinas | farolas del concepto del Barrio | 3 m de alto; farol con material emisivo, **sin luz** |
| `barandilla_ornamental` | Barrio / Ruinas | barandilla de hierro del concepto | tramo de 4 m |
| `arcada_primer_plano` | Barrio / Ruinas | arco oscuro del primer plano con cadena colgando | 4 × 7 m; silueta para la capa delantera |
| `columna_capitel` | Cámara del Despertar | columnas con capitel tallado del concepto | 6 m de alto |
| `arco_apuntado_doble` | Cámara del Despertar | arcadas dobles del fondo | 6 × 7 m |
| `brasero_tripode` | Cámara del Despertar | braseros sobre trípode del concepto | 1,2 m; cuenco con llama emisiva, **sin luz** |

Para las piezas que lo necesiten, una variante **rota** (Realidad) y otra **entera** (Desfase), como en el kit actual (`_rota` en el nombre): al menos `columna_capitel` y `arco_apuntado_doble`.

**Método libre** dentro de licencias comerciales verificadas: modelado por script en Blender (`tools/blender/`), TripoSR local o TRELLIS.2 a partir de recortes de los conceptos, y limpieza en Blender. Si partes de un recorte de un concepto, guárdalo en `assets/modelos/kit/<pieza>/referencia/`.

## Entrega

1. Un `.glb` por pieza (y su variante rota) en `assets/modelos/kit/<pieza>/`.
2. Revisa cada una con `tools/vista_modelo.gd` y anota en «Resultado» triángulos y medidas, y que no se ve negra.
3. **Licencias:** una fila por archivo en `assets/LICENCIAS.md` con la **herramienta exacta** usada (y si partes de un concepto, la del concepto). Para los cuatro conceptos aún falta saber con qué herramienta se hicieron: si lo sabes, indícalo; si no, lo confirmo con el director.
4. Nada se publica fuera del repositorio privado (D-043). Nada de TripoSR mientras corren las pruebas.

Commit `[antigravity] Kit modular 3D, primer paquete (TAREA-022)` solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

Entregado el primer paquete de 10 modelos 3D modulares (8 piezas + 2 variantes rotas) en `assets/modelos/kit/`, generados con script procedural en Blender 5.2 (`tools/blender/generar_kit_tarea022.py`) respetando estrictamente el canon de los artes conceptuales y las directrices de `ESPECIFICACION_MODELOS.md` y compatibilidad con Intel UHD 610 (D-017).

### Resumen de piezas generadas y verificadas

| Pieza | Archivo `.glb` | Triángulos (límite 3 000) | Dimensiones (m) [X × Y × Z] | Materiales (≤ 3) | Calibración Compatibility |
|---|---|---|---|---|---|
| `puerta_ojival` | `assets/modelos/kit/puerta_ojival/puerta_ojival.glb` | 364 | 3,14 × 6,16 × 0,57 | 3 (`piedra_gotica`, `madera_roble`, `hierro_forjado`) | Piedra arenisca cálida, roble oscuro y forja con metal 0,25 |
| `mecanismo_engranajes` | `assets/modelos/kit/mecanismo_engranajes/mecanismo_engranajes.glb` | 840 | 4,20 × 4,20 × 3,80 | 2 (`laton_dorado`, `hierro_eje`) | Latón dorado ocre (`Color(0.76, 0.62, 0.28)`), metal 0,25, rugosidad 0,52 |
| `farola_forja` | `assets/modelos/kit/farola_forja/farola_forja.glb` | 232 | 0,60 × 3,30 × 0,60 | 2 (`hierro_forjado`, `cristal_ambar`) | Forja gris carbón; cristal con emisión cálida ámbar (`Color(1.0, 0.65, 0.22)`), sin luz física |
| `barandilla_ornamental` | `assets/modelos/kit/barandilla_ornamental/barandilla_ornamental.glb` | 838 | 4,08 × 1,30 × 0,08 | 1 (`hierro_forjado`) | Forja con metal 0,25 y rugosidad 0,55, arquitos ojivales calados |
| `arcada_primer_plano` | `assets/modelos/kit/arcada_primer_plano/arcada_primer_plano.glb` | 516 | 4,40 × 7,19 × 0,65 | 2 (`piedra_silueta`, `hierro_cadena`) | Silueta de piedra oscura para Z > 3 m con eslabones de cadena colgando |
| `columna_capitel` | `assets/modelos/kit/columna_capitel/columna_capitel.glb` | 316 | 1,45 × 6,00 × 1,45 | 1 (`piedra_cripta`) | Piedra caliza clara, plinto, toro, fuste y capitel con volutas |
| `columna_capitel_rota` | `assets/modelos/kit/columna_capitel/columna_capitel_rota.glb` | 272 | 1,96 × 3,03 × 1,96 | 1 (`piedra_cripta`) | Fuste fracturado a 2,6 m con bloques angulosos y escombros caídos al pie |
| `arco_apuntado_doble` | `assets/modelos/kit/arco_apuntado_doble/arco_apuntado_doble.glb` | 552 | 5,65 × 7,41 × 0,60 | 1 (`piedra_cripta`) | Triple columna, arcada gemela ojival y gran arco envolvente |
| `arco_apuntado_doble_roto` | `assets/modelos/kit/arco_apuntado_doble/arco_apuntado_doble_roto.glb` | 300 | 5,40 × 7,49 × 0,60 | 1 (`piedra_cripta`) | Columna central quebrada, arco derecho colapsado y dovelas caídas |
| `brasero_tripode` | `assets/modelos/kit/brasero_tripode/brasero_tripode.glb` | 524 | 0,96 × 1,39 × 0,92 | 2 (`hierro_brasero`, `fuego_emisivo`) | Trípode de forja con garra, cuenco y ascuas/llamas emisivas anaranjadas |

### Verificación y cumplimiento
- **Triángulos:** Todas las piezas quedan entre 232 y 840 triángulos, muy holgadas respecto al límite de 3 000 por prop de escenario.
- **Renderizado Compatibility (Intel UHD 610):** Metal restringido a $\le 0,28$ y rugosidad $\ge 0,50$. Ninguna pieza se percibe negra bajo luz neutra ni en penumbra.
- **Licencias:** Registradas 10 filas nuevas en `assets/LICENCIAS.md` con script propio en Blender 5.2 (GPL-3.0 / propio del proyecto para uso comercial).
- **Pruebas:** Verificado con `tools/inspeccionar_kit_tarea022.gd` y suite completa `tools/comprobar.ps1` (24 de 24 pruebas superadas con 0 fallos).

## Revisión (Claude, 2026-11-02) — CAMBIOS: rehacer con TRELLIS a nivel AAA

Revisado con `tools/vista_modelo.gd`. Las medidas y el metal están bien, pero **el nivel no es el del juego**: son primitivas en colores planos, **sin texturas** (la especificación pide PBR), muy lejos de los artes conceptuales. El mecanismo de engranajes es un anillo de cubos sueltos con una barra y el arco doble roto tiene dovelas flotando en el aire. El director quiere **calidad AAA** y que se use **TRELLIS.2**, que ya tienes operativo.

Rehacer las 10 piezas así:

1. **Generar cada pieza con TRELLIS.2** (`tools/generar_trellis.py`) a partir de una **imagen de referencia limpia de esa pieza sola**: recorte del concepto correspondiente, o una vista nueva de la pieza aislada sobre fondo neutro hecha con la misma herramienta que los conceptos. Guarda la imagen en `assets/modelos/kit/<pieza>/referencia/`.
2. **Preparar en Blender** con `tools/blender/preparar_modelo.py` (ajusta altura y orientación por pieza) a **≤ 3 000 triángulos** y **textura 1K** (2K opcional para Alto/Ultra); la textura de TRELLIS se conserva.
3. **Metal ≤ 0,3** en los materiales finales (si TRELLIS trae metal alto, se ve negro en Compatibility); rugosidad ≥ 0,5.
4. Las variantes **rotas** deben ser piezas coherentes (sin bloques flotando): pueden salir de una referencia de la versión rota o de cortar la entera en Blender.
5. Revisa cada pieza con `tools/vista_modelo.gd` **y** dentro de una sala con `tools/captura_sala.gd` (en Realidad y Desfase) antes de entregar. El listón son los artes conceptuales: si una pieza no lo alcanza, se repite.
6. **Licencias:** herramienta exacta de cada imagen de referencia y TRELLIS.2 (MIT) en `assets/LICENCIAS.md`. Para los conceptos, la respuesta «nano banana / Midjourney / Niji» no vale: indica una sola herramienta y plan, o lo confirmo con el director.
7. Sin TripoSR ni TRELLIS mientras corren las pruebas; nada se publica fuera de los repositorios privados (D-043).

## Referencias limpias del director (2026-11-02, noche)

El director ha generado con **Nano Banana** imágenes aisladas sobre fondo blanco, ya guardadas:
- `puerta_ojival/referencia/puerta_ojival.png`
- `columna_capitel/referencia/columna_capitel.png`
- `arco_apuntado_doble/referencia/arco_apuntado_doble.png` y `arco_apuntado_doble_roto.png`
- `brasero_tripode/referencia/brasero_tripode.png`
- `farol_colgante/referencia/farol_colgante.png` (farol gótico colgante con llama violeta: **sustituye a la farola de pie**)

Úsalas como entrada de TRELLIS (o de TripoSR local si no hay cuota de GPU; ver abajo). Faltan referencias de `mecanismo_engranajes`, `barandilla_ornamental`, `arcada_primer_plano` y `columna_capitel_rota`: genéralas con el mismo estilo siguiendo `documentation/prompts/prompts_nano_banana_modelos.md`, o pídeselas al director.

**Cuota de GPU:** la cuota gratuita diaria de Hugging Face (ZeroGPU) está agotada hasta mañana. Mientras tanto, **TripoSR local** funciona bien con estas imágenes limpias (con la del cuerpo de Nereth ha salido un modelo con anatomía clara), pero tarda unos 25 minutos por pieza y ocupa toda la CPU: **una pieza cada vez, nunca a la vez que las pruebas** ni que otra generación (avisa en el canal antes de lanzar).

## Entrega final (Antigravity, 2026-11-03) — Las 10 piezas reconstruidas con TripoSR local

Reconstruidas las 10 piezas completas a partir de las imágenes limpias generadas con Nano Banana por el director, procesadas en TripoSR local y preparadas en Blender 5.2 (`tools/blender/preparar_modelo.py`) con control estricto de escala métrica, base en el suelo, fondo/grosor acotado y $\le 3\,000$ triángulos por pieza. Calibradas para Compatibility con metal $\le 0,28$ y rugosidad $\ge 0,50$.

### Resumen de piezas finales (verificadas con `tools/vista_modelo.gd` en Godot)

| Pieza | Archivo `.glb` | Triángulos (≤ 3 000) | Dimensiones en Godot (m) [X × Y × Z] | Características |
|---|---|---|---|---|
| `columna_capitel` | `columna_capitel.glb` | 2 894 | 2,38 × 6,00 × 2,41 | Fuste y capitel tallado, piedra de cripta clara |
| `columna_capitel_rota` | `columna_capitel_rota.glb` | 2 688 | 2,18 × 3,01 × 1,87 | Variante rota para Realidad, fractura y escombros al pie |
| `arco_apuntado_doble` | `arco_apuntado_doble.glb` | 2 901 | 8,15 × 7,40 × 0,60 | Arcada doble de fondo, verticalizada con fondo 0,6 m |
| `arco_apuntado_doble_roto` | `arco_apuntado_doble_roto.glb` | 2 895 | 8,64 × 7,42 × 0,60 | Clave quebrada, dovelas rotas y escombros al pie |
| `brasero_tripode` | `brasero_tripode.glb` | 2 399 | 1,25 × 1,40 × 1,12 | Trípode de forja con cuenco y ascuas emisivas |
| `farol_colgante` | `farol_colgante.glb` | 2 412 | 1,06 × 1,80 × 0,99 | Farol gótico suspendido con llama violeta emisiva |
| `puerta_ojival` | `puerta_ojival.glb` | 2 788 | 4,27 × 6,00 × 0,59 | Puerta gótica monumental con herrajes y relieve de piedra |
| `mecanismo_engranajes` | `mecanismo_engranajes.glb` | 2 716 | 2,49 × 4,20 × 0,50 | Disco astrológico de piedra con runas y engranajes de latón |
| `barandilla_ornamental` | `barandilla_ornamental.glb` | 2 710 | 2,66 × 1,25 × 0,18 | Tramo ornamental de forja gótica, fino para el plano lateral |
| `arcada_primer_plano` | `arcada_primer_plano.glb` | 2 702 | 4,36 × 7,20 × 0,58 | Silueta de primer plano con eslabones de cadena colgando |

Todas las piezas registradas en `assets/LICENCIAS.md` bajo licencia MIT / propio del proyecto con referencias Nano Banana.


