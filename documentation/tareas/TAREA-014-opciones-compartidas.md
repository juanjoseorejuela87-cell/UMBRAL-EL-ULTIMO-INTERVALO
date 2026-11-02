# TAREA-014 — Opciones en el título con un panel de ajustes compartido

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
- **Archivos permitidos:**
  - Nuevos: `scenes/ui/ajustes/panel_ajustes.tscn` y `scenes/ui/ajustes/panel_ajustes.gd`.
  - `scenes/ui/pausa/menu_pausa.tscn`, `scenes/ui/pausa/menu_pausa.gd`.
  - `scenes/ui/titulo/titulo.tscn`, `scenes/ui/titulo/titulo.gd`.
  - `tests/test_pausa.gd`, `tests/test_menu_graficos.gd`, `tests/test_sonido_ui.gd`, `tests/test_titulo.gd` (solo para adaptar rutas de nodos al nuevo panel; las comprobaciones deben seguir siendo las mismas o más).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `scenes/niveles/`, `project.godot`.

## Por qué

Ahora los ajustes de **Sonido** y **Gráficos** solo existen dentro de la pausa, y su lógica vive en `menu_pausa.gd`. Un jugador debe poder ajustarlos desde la pantalla de título antes de empezar (lo normal en cualquier juego comercial), y no queremos duplicar código.

## Novedad del núcleo (ya en `main`)

`GestorSonido` guarda los volúmenes en `user://ajustes.cfg` (sección `[sonido]`) cada vez que se llama a `fijar_volumen(bus, lineal)` y los recupera al arrancar. Nuevo `volumen(bus) -> float` (lineal 0–1) para leer el valor actual: úsalo en lugar de `db_to_linear(AudioServer.get_bus_volume_db(...))`.

## Encargo

1. **Extrae** las secciones *Sonido* y *Gráficos* (con la confirmación de reinicio) de `menu_pausa` a una escena reutilizable `PanelAjustes` (`Control`, `class_name PanelAjustes`):
   - API sugerida: `mostrar_sonido()`, `mostrar_graficos()`, señal `volver_pulsado`, y la misma lógica de hoy (`seleccionar_preajuste(p)`, `confirmar_reinicio()`, `cancelar_reinicio()`), con sonidos de interfaz y sin `ui_mover` en el foco inicial.
   - Mismo aspecto que ahora en la pausa.
2. **Pausa:** usa `PanelAjustes` en lugar de los paneles propios. Todo debe comportarse igual que antes (navegación, foco, volver al menú).
3. **Título:** nuevo botón **Opciones** entre «Nueva partida» y «Salir», que abre un pequeño submenú (Sonido / Gráficos / Volver) usando el mismo `PanelAjustes`, con el estilo de botones del título (TAREA-013). El fondo 3D sigue animándose detrás.
4. **Pruebas:** adapta las existentes a las nuevas rutas de nodos sin perder comprobaciones, y añade a `tests/test_titulo.gd`: el botón Opciones existe, abre Sonido y Gráficos, mover un deslizador cambia el volumen del bus (`GestorSonido.global().volumen(bus)`) y Volver regresa al menú del título.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.

Commit `[antigravity] Opciones en el título con panel de ajustes compartido (TAREA-014)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

_(lo rellena Antigravity)_
