# TAREA-007 — Menú de pausa y pantalla de controles

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
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

_(Rellenar al entregar.)_
