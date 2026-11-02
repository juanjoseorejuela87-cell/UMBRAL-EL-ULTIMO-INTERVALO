# Registro de licencias de recursos

El juego se va a **vender** (D-032). Solo se admiten recursos cuya licencia permita **uso comercial**. Cada recurso de terceros o generado con IA se anota aquí **en el momento de incorporarlo**, con la licencia tal como estaba ese día.

| Archivo(s) en el proyecto | Origen (web / herramienta) | Autor | Licencia | Fecha | ¿Atribución obligatoria? | Notas (modificaciones, prompt de IA…) |
|---|---|---|---|---|---|---|
| `assets/texturas/castle_brick_07/` (color, normal, rugosidad, 1K) | Poly Haven — https://polyhaven.com/a/castle_brick_07 | Rob Tuytel | CC0 1.0 (verificada en polyhaven.com/license) | 2026-11-01 | No | Sin modificar; importadas con compresión VRAM |
| `assets/texturas/castle_wall_slates/` (color, normal, rugosidad, 1K) | Poly Haven — https://polyhaven.com/a/castle_wall_slates | Rob Tuytel | CC0 1.0 (verificada en polyhaven.com/license) | 2026-11-01 | No | Sin modificar; importadas con compresión VRAM |
| `assets/texturas/cobblestone_floor_08/` (color, normal, rugosidad, 1K) | Poly Haven — https://polyhaven.com/a/cobblestone_floor_08 | Rob Tuytel | CC0 1.0 (verificada en polyhaven.com/license) | 2026-11-01 | No | Sin modificar; importadas con compresión VRAM |
| `assets/texturas/dark_wooden_planks/` (color, normal, rugosidad, 1K) | Poly Haven — https://polyhaven.com/a/dark_wooden_planks | Amal Kumar | CC0 1.0 (verificada en polyhaven.com/license) | 2026-11-01 | No | Sin modificar; importadas con compresión VRAM |
| `assets/texturas/medieval_blocks_02/` (color, normal, rugosidad, 1K) | Poly Haven — https://polyhaven.com/a/medieval_blocks_02 | Rob Tuytel | CC0 1.0 (verificada en polyhaven.com/license) | 2026-11-01 | No | Sin modificar; importadas con compresión VRAM |
| `assets/texturas/monastery_stone_floor/` (color, normal, rugosidad, 1K) | Poly Haven — https://polyhaven.com/a/monastery_stone_floor | Amal Kumar | CC0 1.0 (verificada en polyhaven.com/license) | 2026-11-01 | No | Sin modificar; importadas con compresión VRAM |
| `assets/texturas/rock_wall_08/` (color, normal, rugosidad, 1K) | Poly Haven — https://polyhaven.com/a/rock_wall_08 | Amal Kumar | CC0 1.0 (verificada en polyhaven.com/license) | 2026-11-01 | No | Sin modificar; importadas con compresión VRAM |
| `assets/texturas/rusty_metal_02/` (color, normal, rugosidad, 1K) | Poly Haven — https://polyhaven.com/a/rusty_metal_02 | Rob Tuytel | CC0 1.0 (verificada en polyhaven.com/license) | 2026-11-01 | No | Sin modificar; importadas con compresión VRAM |

## Reglas

1. Sin licencia clara que permita uso comercial → **no entra**.
2. Recursos generados con IA: anotar herramienta, versión o modelo, licencia de sus resultados y, si es posible, el prompt o la imagen de partida.
3. Al publicar en tiendas (p. ej. Steam), declarar el uso de contenido generado con IA según sus normas.
4. Las licencias cambian: si una herramienta cambia sus condiciones, lo ya descargado conserva la licencia anotada; lo nuevo se revisa de nuevo.

## Herramientas

- **Blender 5.2** (GPL-3.0-or-later, Blender Foundation): herramienta de modelado. Según la propia Blender Foundation, la licencia GPL no se aplica a las obras creadas con Blender: los modelos que produce son propiedad del autor y pueden usarse comercialmente.
- **TripoSR** (MIT, VAST-AI-Research / Stability AI + Tripo): código y pesos (`stabilityai/TripoSR`, MIT) para reconstrucción 3D a partir de una sola imagen. Totalmente utilizable comercialmente sin restricciones de distribución.
- **rembg** (MIT, Daniel Gatis): herramienta de eliminación de fondos utilizada por TripoSR, con modelo base `u2net` (Apache 2.0).

## Modelos 3D

| Archivo | Origen | Licencia | Notas |
|---|---|---|---|
| `assets/modelos/nereth/nereth.glb`, `espada_umbral.glb` | Creados por Claude con Blender 5.2 (`tools/blender/nereth.py`) | Propios del proyecto | Provisionales por piezas; se sustituirán por un modelo con más detalle |
| `documentation/arte/nereth_hoja_personaje.png` | Hoja de personaje de Nereth generada por el director con **ChatGPT (DALL-E 3)** de OpenAI, cuenta gratuita (2026-11) | Términos de Uso de OpenAI, §3 «Contenido»: OpenAI cede al usuario sus derechos sobre el contenido generado; uso comercial permitido | Hecho con IA: declararlo en Steam. En algunas jurisdicciones el contenido solo generado por IA puede no tener derechos de autor propios |
| `assets/modelos/nereth/referencia/nereth_frontal.png` | Recorte de la hoja de personaje del director | Igual que la hoja (DALL-E 3, OpenAI) | Entrada de TripoSR |
| `assets/modelos/nereth/fuente/nereth_triposr.glb` | Generado con TripoSR local (CPU) a partir de `nereth_frontal.png` | MIT / Propio del proyecto | Modelo base generado localmente sin conexión (TAREA-017) |
| `assets/modelos/prueba_kit/fuente/prueba_kit_triposr.glb` | Generado con TripoSR local (CPU) a partir de pieza de kit gótico | MIT / Propio del proyecto | Objeto de escenario de prueba generado localmente (TAREA-017) |
| `assets/modelos/nereth/nereth_tsr.glb` | `nereth_triposr.glb` preparado por Claude en Blender (`tools/blender/preparar_modelo.py`: de pie, 1,82 m, mirando a +X, 14 520 triángulos, color por vértice) | MIT / Propio del proyecto | Base para el modelo jugable; falta esqueleto |
| `assets/modelos/nereth/fuente/nereth_sin_fondo.png` | Recorte de `nereth_frontal.png` sin fondo con rembg `u2netp` (Apache 2.0) | Igual que la hoja (DALL-E 3, OpenAI) | Entrada de TripoSR |
| `assets/modelos/nereth/nereth_cabeza_alta_definicion.glb` | Generado con **Microsoft TRELLIS** (Hugging Face) a partir de `nereth_rostro_referencia.png` | Licencia MIT (Microsoft Research) | Cabeza de alta definición (18 349 triángulos, texturas PBR) |
| `assets/modelos/nereth/nereth_trellis_animable.glb` | Generado con **Microsoft TRELLIS** a partir de `nereth_sin_fondo.png`, optimizado en Blender 5.2 (14 550 triángulos, texturas 1K PBR, mirando a +X, 1,82 m) con esqueleto de 17 huesos | Licencia MIT / Propio del proyecto | Modelo de cuerpo entero articulado con esqueleto listo para el juego |
| `documentation/arte/concepto_camara_despertar.png` | Arte conceptual de la Cámara del Despertar generado por el director con IA (2026-11) | Propio del director / Uso comercial | Referencia para el kit gótico 3D de la Cámara del Despertar |
| `documentation/arte/concepto_barrio_desprendido.png` | Arte conceptual del Barrio Desprendido generado por el director con IA (2026-11) | Propio del director / Uso comercial | Referencia para el kit gótico 3D y capas 2.5D de las Ruinas de Elyndor |
| `documentation/arte/concepto_salon_prefecto.png` | Arte conceptual del Salón del Prefecto generado por el director con IA (2026-11) | Propio del director / Uso comercial | Referencia para las 4 puertas y engranajes de los Arquitectos |
| `documentation/arte/concepto_balcon_amanecer.png` | Arte conceptual del Balcón del Amanecer generado por el director con IA (2026-11) | Propio del director / Uso comercial | Referencia para la panorámica y horizonte de cierre de la demo |
