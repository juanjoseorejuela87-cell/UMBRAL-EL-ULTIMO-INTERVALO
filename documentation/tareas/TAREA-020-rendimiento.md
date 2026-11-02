# TAREA-020 — Medir y mejorar el rendimiento de la demo en el equipo modesto

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
- **Archivos permitidos:**
  - `tools/medir_rendimiento.gd` (nuevo).
  - Solo para optimizar decorado: nodos dentro de `DecoradoKit` y de los decorados de `camara_despertar.tscn`, `barrio_desprendido.tscn` y `salon_prefecto.tscn` (propiedades de render: `cast_shadow`, `visibility_range_*`, LOD; nunca posiciones, colisiones ni lógica).
  - `documentation/tareas/TAREA-020-rendimiento.md` (Resultado).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, enemigos, el kit (`scenes/mundo/kit_gotico/`), `project.godot`.

## Por qué

D-017: la demo debe ir fluida en la Intel UHD 610 del equipo de desarrollo con el preajuste **Bajo**. Desde la última medición se han añadido mucho decorado (TAREA-018 y 019), un Nereth con esqueleto (14 500 triángulos) y música compuesta en segundo plano.

## Encargo

1. **`tools/medir_rendimiento.gd`** (script `-s`, CON ventana, sin `--headless`): carga una sala, coloca a Nereth en varias posiciones (lista de x) y en cada una espera 3 s y anota FPS medio, mínimo y `RenderingServer.get_rendering_info(RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)` y de primitivas. Repite en Realidad y Desfase. Imprime una tabla. Usa el preajuste de calidad actual (debe ser **Bajo** en este equipo; compruébalo con `ConfiguracionGrafica.global().preajuste`).
2. **Mide** las tres salas de la demo y el título. Incluye la tabla en «Resultado».
3. **Si alguna posición baja de 50 FPS** en Bajo: aplica solo optimizaciones de render en el decorado (desactivar sombras proyectadas en piezas pequeñas o lejanas, `visibility_range_end` en piezas de fondo que no se ven desde ciertos tramos) y vuelve a medir. Indica antes/después.
4. Si el cuello de botella no está en el decorado (por ejemplo, Nereth, la niebla o la música), **no lo cambies**: descríbelo en «Resultado» con los datos y yo me encargo.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`. Nada de TripoSR mientras mides (falsea los resultados).

Commit `[antigravity] Medición y mejoras de rendimiento (TAREA-020)` solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

_(lo rellena Antigravity)_
