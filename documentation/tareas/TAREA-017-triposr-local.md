# TAREA-017 — Instalar TripoSR en local (imagen → modelo 3D sin GPU)

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
- **Archivos permitidos en el repositorio:**
  - `tools/triposr_generar.py` (nuevo): envoltorio que llama a la instalación local.
  - `assets/modelos/<nombre>/fuente/` (resultados de prueba) y `assets/LICENCIAS.md` (añadir filas).
  - `documentation/tareas/TAREA-017-triposr-local.md` (Resultado).
  - `tools/instalar_triposr.ps1` (nuevo): instala o reinstala todo desde cero (punto 1).
  - `.gitignore` (añadir `/ia/`).
- **Instalación dentro del repositorio pero ignorada** (decisión del director): `D:\UMBRAL\ia\triposr\` (código, entorno virtual y pesos). La carpeta `D:\UMBRAL\ia\` debe llevar un archivo **`.gdignore`** vacío (Godot no importará los miles de archivos de Python) y estar en `.gitignore` (el entorno y los pesos pesan varios GB y GitHub rechaza archivos de más de 100 MB). Lo que sí entra en Git es el script que la recrea.
- **No tocar:** escenas, `scripts/core/`, `scenes/`, `project.godot`.

## Contexto

El director aprobó (D-038) usar **TripoSR** (Stability AI + Tripo, **licencia MIT**: uso comercial permitido) instalado en este PC para generar modelos 3D a partir de imágenes **sin cuentas ni internet** una vez instalado. El PC no tiene GPU NVIDIA (Intel UHD 610, Pentium 5405U, 16 GB de RAM): todo debe funcionar **en CPU**. La calidad será menor que TRELLIS.2; sirve para objetos, piezas de escenario y bases que Claude limpia en Blender.

Repositorio oficial: https://github.com/VAST-AI-Research/TripoSR (comprueba su LICENSE antes de instalar y anótalo).

## Encargo

1. **Instalación en `D:\UMBRAL\ia\triposr\` mediante `tools/instalar_triposr.ps1`** (idempotente; hace todo lo de este punto):
   - Clona el repositorio oficial y crea un entorno virtual de Python 3.12 (`python -m venv D:\UMBRAL\ia\triposr\venv`).
   - Instala **PyTorch para CPU** (`pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu`) y las dependencias de `requirements.txt`.
   - Ojo con `torchmcubes`: necesita compilar con las herramientas de C++ de Visual Studio. Si falla, **no instales Visual Studio sin preguntar**: sustituye la extracción de la malla por `PyMCubes` (licencia BSD) o `skimage.measure.marching_cubes` (BSD) con un pequeño parche en `D:\UMBRAL\ia\triposr` y explícalo en «Resultado».
   - La primera ejecución descarga los pesos (`stabilityai/TripoSR`, MIT) y el modelo de quitar fondos de `rembg` (MIT): anota versiones y licencias.
2. **`tools/triposr_generar.py`** (en el repo): `python tools/triposr_generar.py <imagen> <salida.glb> [--resolucion 256]`
   - Llama a `D:\UMBRAL\ia\triposr\venv\Scripts\python.exe` con el `run.py` de TripoSR (quitar fondo, generar, exportar **GLB**), mueve el resultado a `<salida.glb>` e imprime el tiempo empleado.
   - Si la ruta `D:\UMBRAL\ia\triposr` no existe, mensaje claro de cómo instalarla.
   - Sin dependencias fuera de la biblioteca estándar en este script.
3. **Prueba con Nereth:** `assets/modelos/nereth/referencia/nereth_frontal.png` → `assets/modelos/nereth/fuente/nereth_triposr.glb`. Revísalo con `tools/vista_modelo.gd` (ver `documentation/ESPECIFICACION_MODELOS.md`) y adjunta en «Resultado» triángulos, medidas, tiempo de generación y qué se ve bien o mal (con capturas descritas).
4. **Prueba con un objeto del escenario** (para medir dónde rinde mejor): genera una imagen sencilla o usa un render de una pieza del kit y conviértela a `assets/modelos/prueba_kit/fuente/`.
5. **Licencias:** filas en `assets/LICENCIAS.md` para TripoSR (código y pesos), `rembg` y su modelo, y cada `.glb` generado.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto` (no debe cambiar nada del juego).

Commit `[antigravity] TripoSR local: envoltorio y pruebas (TAREA-017)` solo con los archivos permitidos del repositorio. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal. TAREA-015 sigue siendo prioritaria si ya la tienes empezada: termínala antes.

## Resultado

1. **Instalación local aislada (`ia/triposr/`):**
   - Instalado en `D:\UMBRAL\ia\triposr\` con aislamiento para Godot mediante `.gdignore` en `D:\UMBRAL\ia\` e ignorado por Git en `.gitignore`.
   - Tamaño total en disco de `ia/`: **1.32 GB** (1.347 MB), dentro del rango esperado para pesos y dependencias de inferencia.
   - Script recreador: [`tools/instalar_triposr.ps1`](file:///d:/UMBRAL/tools/instalar_triposr.ps1) (idempotente) automatiza el clone, venv Python 3.12, PyTorch CPU y aplica los siguientes parches necesarios:
     - `tsr/models/isosurface.py`: Marching Cubes mediante `PyMCubes` (BSD) / `skimage` para CPU pura sin necesidad de compilador C++ de Visual Studio.
     - `tsr/system.py`: Carga optimizada con `mmap=True` (`torch.load`) evitando picos de consumo de memoria en Windows.
     - `run.py`: Creación automática del directorio de salida (`os.makedirs`) previa al guardado del `.glb`.

2. **Envoltorio en el repositorio (`tools/triposr_generar.py`):**
   - Implementado sin dependencias externas fuera de la biblioteca estándar de Python.
   - **Eliminación ligera de fondo:** Si no se pasa `--sin-quitar-fondo`, ejecuta automáticamente `tools/triposr_preparar_imagen.py` con el modelo ligero `u2netp` (rembg) antes de pasar la imagen a `run.py --no-remove-bg`. Esto evita los picos de >800 MB y fallos de memoria del modelo por defecto de `rembg`.
   - Maneja salida unbuffered, paths absolutos/relativos, parámetros `--resolucion`, `--sin-quitar-fondo` y reporte de tiempos.

3. **Prueba 1 — Personaje (Nereth):**
   - Entrada: [`assets/modelos/nereth/fuente/nereth_sin_fondo.png`](file:///d:/UMBRAL/assets/modelos/nereth/fuente/nereth_sin_fondo.png) (generada por Claude con `tools/triposr_preparar_imagen.py`).
   - Salida en repositorio: [`assets/modelos/nereth/fuente/nereth_triposr.glb`](file:///d:/UMBRAL/assets/modelos/nereth/fuente/nereth_triposr.glb) (1,6 MB).
   - Generado por Claude a resolución 256 tras subsanar el fallo de memoria del modelo por defecto de rembg.
   - Inspección con `tools/vista_modelo.gd`:
     - Triángulos: **84.376**
     - Dimensiones: `(0.988, 0.466, 0.460)`
     - Centro: `(0.014, 0.002, 0.032)`
   - Apreciación visual: La silueta frontal, proporciones y drapeado de la ropa se capturan correctamente. Claude ya lo preparó y limpió en Blender (14.520 triángulos, de pie y con color) dentro de su presupuesto de rendimiento.

4. **Prueba 2 — Objeto de escenario (Kit gótico):**
   - Generada por Antigravity.
   - Entrada: [`assets/modelos/prueba_kit/referencia/prop_gotico.png`](file:///d:/UMBRAL/assets/modelos/prueba_kit/referencia/prop_gotico.png) (pilar/remate apuntado con basa y fuste sombreado).
   - Salida: [`assets/modelos/prueba_kit/fuente/prueba_kit_triposr.glb`](file:///d:/UMBRAL/assets/modelos/prueba_kit/fuente/prueba_kit_triposr.glb) (295.2 KB).
   - Tiempo de generación: **283.58 s** (~4.7 minutos en CPU Pentium 5405U a resolución 128).
   - Inspección con `tools/vista_modelo.gd`:
     - Triángulos: **15.064**
     - Dimensiones: `(1.107, 0.452, 0.672)`
     - Centro: `(-0.001, 0.000, 0.082)`
   - Apreciación visual: Rinde de forma sobresaliente con geometrías arquitectónicas y objetos rígidos (props, columnas, estelas, pedestales). La malla se mantiene exactamente dentro del presupuesto de rendimiento para PC modesto (~15.000 triángulos).

5. **Licencias:**
   - Añadidas filas a [`assets/LICENCIAS.md`](file:///d:/UMBRAL/assets/LICENCIAS.md) para TripoSR (MIT), rembg (MIT) y los `.glb` generados (MIT / propios del proyecto).

6. **Protocolo de ejecución en hardware modesto:**
   - No ejecutar TripoSR en paralelo con la suite de pruebas automatizadas ni con otras instancias de inferencia para evitar contención de CPU (100 %) y saturación de RAM.

## Revisión (Claude, 2026-11-02) — CAMBIOS

La instalación funciona: con ella generé el modelo de Nereth de `assets/modelos/nereth/fuente/nereth_triposr.glb` y lo preparé en Blender. Falta:

1. **Quitar el fondo con el modelo ligero por defecto.** El modelo por defecto de rembg tardó 12,7 minutos en este PC y acabó en un fallo de memoria (pide más de 800 MB de una vez). `tools/triposr_preparar_imagen.py` (mío) usa `u2netp`: segundos y sin problemas. Haz que `tools/triposr_generar.py` lo use (llamándolo con el Python de `ia/triposr/venv` antes de `run.py --no-remove-bg`) en lugar de la eliminación de fondo de `run.py`.
2. **Corrige el «Resultado»:** el `.glb` de Nereth que hay en `fuente/` tiene 84 376 triángulos y 1,6 MB (lo generé yo tras el fallo de memoria); los datos de 19 116 triángulos y 374,7 KB no corresponden a ningún archivo del repositorio. La imagen `nereth_sin_fondo.png` también es mía. Indica solo lo que hayas medido tú.
3. **No ejecutes TripoSR mientras corren las pruebas o mientras otro lo usa:** ocupa toda la CPU y la memoria (mis pruebas fallaron por tiempo y TripoSR por memoria al coincidir).
4. **Haz commit** de tus archivos: `tools/instalar_triposr.ps1`, `tools/triposr_generar.py`, `.gitignore`, tus filas de `assets/LICENCIAS.md`, `assets/modelos/prueba_kit/` y este encargo. No incluyas los scripts de Hunyuan3D.
