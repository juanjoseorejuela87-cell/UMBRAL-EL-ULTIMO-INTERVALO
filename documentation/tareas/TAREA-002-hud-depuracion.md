# TAREA-002 — Panel de depuración del movimiento

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
- **Archivos permitidos:** `scenes/ui/depuracion/panel_depuracion.tscn`, `scenes/ui/depuracion/panel_depuracion.gd`, y añadir **una instancia** del panel en `scenes/niveles/pruebas/sala_movimiento.tscn`.
- **No tocar:** `scenes/jugador/`, `scripts/core/`, `project.godot`.

## Encargo (copiar y pegar a Antigravity)

> Trabajas en el repositorio `D:\UMBRAL` (Godot 4.7.2, GDScript tipado). Lee primero `AGENTS.md` y respeta sus convenciones y su protocolo.
>
> Crea un panel de depuración (`CanvasLayer`) para ajustar el movimiento de Nereth (`scenes/jugador/nereth.gd`, clase `Nereth`). El panel:
>
> 1. Tiene `@export var objetivo: Nereth`.
> 2. Muestra en una esquina superior izquierda, con una `Label` de fuente monoespaciada o la predeterminada: estado (`Nereth.Estado` como texto), `velocity.x`, `velocity.y`, `is_on_floor()`, `invulnerable`, `mirando`, FPS.
> 3. Se muestra/oculta con la tecla **F3** (registra la acción `depuracion_alternar` desde el propio script si no existe en `InputMap`; no edites `project.godot`).
> 4. Visible por defecto solo en compilaciones de depuración (`OS.is_debug_build()`).
> 5. Todo tipado; sin dependencias nuevas; solo lectura del jugador (no modifica sus valores).
>
> Instancia el panel en `scenes/niveles/pruebas/sala_movimiento.tscn` apuntando a `Nereth`.
>
> Prueba: `D:\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\UMBRAL --import` y después `-s res://tests/test_movimiento.gd` debe seguir dando `RESULTADO: OK`. Sin errores ni avisos nuevos.
>
> Haz commit en `main` con el mensaje `[antigravity] Panel de depuración del movimiento (TAREA-002)` y marca este archivo como `ENTREGADO` con un resumen breve.

## Criterios de aceptación (los revisa Claude)

- Solo toca los archivos permitidos.
- La prueba de movimiento sigue pasando; arranque sin errores.
- Código tipado y conforme a `AGENTS.md`.

## Resultado

- Creados `scenes/ui/depuracion/panel_depuracion.gd` y `scenes/ui/depuracion/panel_depuracion.tscn` (`CanvasLayer` tipado que monitorea FPS, estado, `velocity.x`, `velocity.y`, `is_on_floor()`, `invulnerable` y `mirando`).
- Registrada la acción `depuracion_alternar` dinámicamente asignada a `KEY_F3`, respetando `OS.is_debug_build()` para la visibilidad inicial.
- Instanciado en `scenes/niveles/pruebas/sala_movimiento.tscn` vinculado a `Nereth`.
- Verificado con Godot 4.7.2 headless (`test_movimiento.gd`: RESULTADO: OK con 0 fallos; y `--quit-after 60`: 0 avisos o errores).
