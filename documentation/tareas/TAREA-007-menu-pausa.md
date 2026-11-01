# TAREA-007 — Menú de pausa y pantalla de controles

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
- **Archivos permitidos:** todo lo que crees en `scenes/ui/pausa/`; añadir **una instancia** del menú en `scenes/niveles/elyndor/barrio_desprendido.tscn` y en `scenes/niveles/elyndor/salon_prefecto.tscn`; `tests/test_pausa.gd`.
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `project.godot`.

## Encargo

1. `scenes/ui/pausa/menu_pausa.tscn` (`CanvasLayer`, `class_name MenuPausa`, `process_mode = PROCESS_MODE_ALWAYS`):
   - Se abre y se cierra con **Esc** y con el botón **Start** del mando. Registra la acción `pausa` desde el script si no existe (igual que hiciste con `depuracion_alternar`): `KEY_ESCAPE` y `JOY_BUTTON_START`.
   - Al abrir: `get_tree().paused = true`; al cerrar: `false`.
   - Opciones (botones navegables con teclado y mando; el primero recibe el foco): **Reanudar**, **Controles**, **Volver al título**.
   - **Controles** muestra una lista legible (teclado y mando) leyendo las acciones de `ConfigControles.ACCIONES` (`scripts/core/controles.gd`); no la escribas a mano. Para los nombres bonitos de cada acción usa un diccionario local en tu script (p. ej. `&"desfase": "Desfase"`).
   - **Volver al título**: quita la pausa y llama a `GestorSalas.global().ir_a_entrada("res://scenes/ui/titulo/titulo.tscn", &"")`.
   - Estilo coherente con la pantalla de título (`scenes/ui/titulo/`): fondo oscuro translúcido, tipografía sobria.
2. Instancia el menú en las dos salas de Elyndor.
3. `tests/test_pausa.gd`: abrir (simulando la acción) pausa el árbol, cerrar lo reanuda, la lista de controles contiene al menos «Desfase», «Coser» y «Guardia», y «Volver al título» quita la pausa.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.

Commit `[antigravity] Menú de pausa y pantalla de controles (TAREA-007)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena "Resultado" y avisa en el canal.

## Resultado

- Creados `scenes/ui/pausa/menu_pausa.gd` y `scenes/ui/pausa/menu_pausa.tscn`:
  - `CanvasLayer` con `class_name MenuPausa` y `process_mode = PROCESS_MODE_ALWAYS` (layer = 100).
  - Acción `pausa` registrada en tiempo de ejecución con `KEY_ESCAPE` y `JOY_BUTTON_START`.
  - Abre y cierra alternando `get_tree().paused = true / false`, con gestión de foco para teclado y mando.
  - Opciones principales: **Reanudar** (cierra el menú y reanuda), **Controles** (despliega lista), y **Volver al título** (quita la pausa e invoca `GestorSalas.global().ir_a_entrada` hacia la pantalla de título).
  - Pantalla de controles con generación automática dinámica a partir de `ConfigControles.ACCIONES` y mapeo de nombres amigables (`Desfase`, `Coser`, `Guardia`, etc.) diferenciando teclado/ratón y mando.
  - Estilo visual sobrio coherente con la pantalla de título (fondo oscuro traslúcido, paleta lavanda/azul de Umbral).
- Instanciado `MenuPausa` en `scenes/niveles/elyndor/barrio_desprendido.tscn` y `scenes/niveles/elyndor/salon_prefecto.tscn`.
- Creada suite de pruebas en `tests/test_pausa.gd` validando ciclo completo de pausa/reanudación por acción y métodos, controles requeridos, vuelta al título e instanciación en niveles.
- Comprobación completa con `tools/comprobar.ps1`: 11 de 11 pruebas superadas con 0 fallos (`Todo correcto`).
