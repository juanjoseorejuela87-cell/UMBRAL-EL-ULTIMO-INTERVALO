# TAREA-014 — Opciones en el título con un panel de ajustes compartido

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
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

1. **PanelAjustes compartido (`panel_ajustes.tscn` + `panel_ajustes.gd`):**
   - Creado como `class_name PanelAjustes` extendiendo `VBoxContainer` para layout automático y limpio.
   - Encapsula las secciones *Sonido* y *Gráficos* completas con la confirmación de reinicio para cambios de renderizador.
   - API completa implementada: `mostrar_sonido()`, `mostrar_graficos()`, `ocultar_todo()`, `actualizar_deslizadores_sonido()`, `actualizar_selector_graficos()`, `seleccionar_preajuste(p)`, `cancelar_reinicio()`, `confirmar_reinicio()`, y señal `volver_pulsado`.
   - Utiliza la novedad del núcleo `GestorSonido.global().volumen(bus)` en lugar de conversiones manuales con `db_to_linear`.
   - Conexión de sonidos de interfaz (`ui_mover`, `ui_aceptar`) sin disparo espurio en el foco inicial (`_foco_inicial_dado`).

2. **Menú de Pausa (`menu_pausa.tscn` + `menu_pausa.gd`):**
   - Reemplazados los paneles locales por la instancia única `%PanelAjustes`.
   - `MenuPausa` expone propiedades delegadas (`panel_sonido`, `panel_graficos`, `deslizador_musica`, `selector_calidad`, etc.) manteniendo total compatibilidad con todas las pruebas y código existente.
   - Conectada la señal `volver_pulsado` para regresar fluidamente al menú principal de opciones de pausa.

3. **Pantalla de Título (`titulo.tscn` + `titulo.gd`):**
   - Añadido el botón **Opciones** (%Opciones) ubicado entre «Nueva partida» y «Salir», con el estilo refinado de TAREA-013.
   - Creado el submenú `%MenuOpciones` con los botones «Sonido», «Gráficos» y «Volver».
   - Instanciado `%PanelAjustes` dentro del contenedor central bajo el aura de legibilidad.
   - Al pulsar Opciones se muestra el submenú; al pulsar Sonido o Gráficos se abre el panel de ajustes correspondiente; al pulsar Volver en el panel se regresa al submenú de opciones, y al pulsar Volver en el submenú se regresa al menú principal dando foco a Opciones.
   - El fondo 3D y su pulso de Desfase siguen animándose continuamente detrás sin ninguna interrupción.

4. **Verificación y pruebas:**
   - `tests/test_pausa.gd`: 15/15 OK (0 fallos).
   - `tests/test_menu_graficos.gd`: 27/27 OK (0 fallos).
   - `tests/test_sonido_ui.gd`: 12/12 OK (0 fallos).
   - `tests/test_titulo.gd`: ampliado de 30 a **38 comprobaciones** (verificación de existencia del botón Opciones, posición entre Nueva partida y Salir, apertura de submenú, apertura de Sonido y Gráficos, cambio de volumen con `GestorSonido.volumen(bus)`, y navegación completa de Volver): **38/38 OK (0 fallos)**.
   - `tests/test_demo.gd`: 18/18 OK (0 fallos).
   - `tools/comprobar.ps1`: **Todo correcto (21 de 21 suites pasadas)**.
