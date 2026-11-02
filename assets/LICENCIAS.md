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
| `assets/modelos/nereth/referencia/nereth_frontal.png` | Recorte de la hoja de personaje del director | Del director | **Pendiente:** el director debe indicar con qué herramienta se generó la hoja para registrar su licencia |
| `assets/modelos/nereth/fuente/nereth_triposr.glb` | Generado con TripoSR local (CPU) a partir de `nereth_frontal.png` | MIT / Propio del proyecto | Modelo base generado localmente sin conexión (TAREA-017) |
| `assets/modelos/prueba_kit/fuente/prueba_kit_triposr.glb` | Generado con TripoSR local (CPU) a partir de pieza de kit gótico | MIT / Propio del proyecto | Objeto de escenario de prueba generado localmente (TAREA-017) |
