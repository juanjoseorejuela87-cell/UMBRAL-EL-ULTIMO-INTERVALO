# TAREA-017 — Instalar TripoSR en local (imagen → modelo 3D sin GPU)

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
- **Archivos permitidos en el repositorio:**
  - `tools/triposr_generar.py` (nuevo): envoltorio que llama a la instalación local.
  - `assets/modelos/<nombre>/fuente/` (resultados de prueba) y `assets/LICENCIAS.md` (añadir filas).
  - `documentation/tareas/TAREA-017-triposr-local.md` (Resultado).
- **Fuera del repositorio:** la instalación completa va en **`D:\IA\TripoSR\`** (código, entorno virtual y pesos del modelo). **Nunca dentro de `D:\UMBRAL`**: Godot importaría miles de archivos de Python y Git se llenaría.
- **No tocar:** escenas, `scripts/core/`, `scenes/`, `project.godot`.

## Contexto

El director aprobó (D-038) usar **TripoSR** (Stability AI + Tripo, **licencia MIT**: uso comercial permitido) instalado en este PC para generar modelos 3D a partir de imágenes **sin cuentas ni internet** una vez instalado. El PC no tiene GPU NVIDIA (Intel UHD 610, Pentium 5405U, 16 GB de RAM): todo debe funcionar **en CPU**. La calidad será menor que TRELLIS.2; sirve para objetos, piezas de escenario y bases que Claude limpia en Blender.

Repositorio oficial: https://github.com/VAST-AI-Research/TripoSR (comprueba su LICENSE antes de instalar y anótalo).

## Encargo

1. **Instalación en `D:\IA\TripoSR\`:**
   - Clona el repositorio oficial y crea un entorno virtual de Python 3.12 (`python -m venv D:\IA\TripoSR\venv`).
   - Instala **PyTorch para CPU** (`pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu`) y las dependencias de `requirements.txt`.
   - Ojo con `torchmcubes`: necesita compilar con las herramientas de C++ de Visual Studio. Si falla, **no instales Visual Studio sin preguntar**: sustituye la extracción de la malla por `PyMCubes` (licencia BSD) o `skimage.measure.marching_cubes` (BSD) con un pequeño parche en `D:\IA\TripoSR` y explícalo en «Resultado».
   - La primera ejecución descarga los pesos (`stabilityai/TripoSR`, MIT) y el modelo de quitar fondos de `rembg` (MIT): anota versiones y licencias.
2. **`tools/triposr_generar.py`** (en el repo): `python tools/triposr_generar.py <imagen> <salida.glb> [--resolucion 256]`
   - Llama a `D:\IA\TripoSR\venv\Scripts\python.exe` con el `run.py` de TripoSR (quitar fondo, generar, exportar **GLB**), mueve el resultado a `<salida.glb>` e imprime el tiempo empleado.
   - Si la ruta `D:\IA\TripoSR` no existe, mensaje claro de cómo instalarla.
   - Sin dependencias fuera de la biblioteca estándar en este script.
3. **Prueba con Nereth:** `assets/modelos/nereth/referencia/nereth_frontal.png` → `assets/modelos/nereth/fuente/nereth_triposr.glb`. Revísalo con `tools/vista_modelo.gd` (ver `documentation/ESPECIFICACION_MODELOS.md`) y adjunta en «Resultado» triángulos, medidas, tiempo de generación y qué se ve bien o mal (con capturas descritas).
4. **Prueba con un objeto del escenario** (para medir dónde rinde mejor): genera una imagen sencilla o usa un render de una pieza del kit y conviértela a `assets/modelos/prueba_kit/fuente/`.
5. **Licencias:** filas en `assets/LICENCIAS.md` para TripoSR (código y pesos), `rembg` y su modelo, y cada `.glb` generado.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto` (no debe cambiar nada del juego).

Commit `[antigravity] TripoSR local: envoltorio y pruebas (TAREA-017)` solo con los archivos permitidos del repositorio. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal. TAREA-015 sigue siendo prioritaria si ya la tienes empezada: termínala antes.

## Resultado

_(lo rellena Antigravity)_
