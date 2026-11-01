# TAREA-009 — Ambiente de las salas, sonidos de interfaz y volúmenes

- **Ayudante:** Google Antigravity
- **Estado:** ACEPTADO
- **Archivos permitidos:**
  - `scenes/niveles/elyndor/barrio_desprendido.tscn` y `scenes/niveles/elyndor/salon_prefecto.tscn` (solo añadir un nodo `AmbienteSala`).
  - `scenes/ui/titulo/titulo.tscn`, `scenes/ui/titulo/titulo.gd`, `scenes/ui/fin_demo/fin_demo.tscn`, `scenes/ui/fin_demo/fin_demo.gd` (solo sonidos de botones).
  - `scenes/ui/pausa/menu_pausa.tscn`, `scenes/ui/pausa/menu_pausa.gd`.
  - `tests/test_sonido_ui.gd`.
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `project.godot`.

## Interfaz disponible (ya en `main`, hito 11)

- Autoload **`Sonido`** → `GestorSonido.global()`:
  - `reproducir(nombre: StringName, volumen_db := 0.0, variacion := 0.06) -> AudioStreamPlayer`
  - `ambiente(nombre: StringName)` (`&""` lo detiene); pistas: `&"elyndor"`, `&"prefecto"`.
  - `fijar_volumen(bus: StringName, lineal: float)`; buses: `GestorSonido.BUS_MUSICA`, `BUS_EFECTOS`, `BUS_AMBIENTE`.
  - Efectos disponibles en `GestorSonido.RECETAS`; para la interfaz: `&"ui_mover"` y `&"ui_aceptar"`.
- Nodo **`AmbienteSala`** (`scripts/core/sonido/ambiente_sala.gd`): `Node` con `@export var pista: StringName`; al entrar en la sala fija el ambiente.
- Escucha los sonidos provisionales en `D:\UMBRAL\builds\sonidos_provisionales\*.wav` (no está en git).

## Encargo

1. **Ambiente por sala:** añade un `AmbienteSala` con `pista = &"elyndor"` en el Barrio y `&"prefecto"` en el Salón. En el título y el fin de la demo, el ambiente debe detenerse (`GestorSonido.global().ambiente(&"")` en su `_ready`).
2. **Sonidos de interfaz** en título, fin de la demo y menú de pausa: `ui_mover` al cambiar el foco entre botones (`focus_entered`) y `ui_aceptar` al pulsar (`pressed`). Que no suene `ui_mover` al dar el foco inicial automáticamente.
3. **Volúmenes en el menú de pausa:** una sección *Sonido* con tres `HSlider` (Música, Efectos, Ambiente; 0–1, paso 0,05) que llaman a `fijar_volumen`. Al abrir la sección, los deslizadores muestran el volumen actual de cada bus (`db_to_linear(AudioServer.get_bus_volume_db(...))`). Navegables con mando.
4. `tests/test_sonido_ui.gd`: el Barrio fija el ambiente `elyndor`, el Salón `prefecto` y el título lo detiene; mover un deslizador cambia el volumen del bus.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.

Commit `[antigravity] Ambiente de las salas, sonidos de interfaz y volúmenes (TAREA-009)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena "Resultado" y avisa en el canal.

## Resultado

- **Ambiente por sala:**
  - Instanciado nodo `AmbienteSala` en `scenes/niveles/elyndor/barrio_desprendido.tscn` (`pista = &"elyndor"`).
  - Instanciado nodo `AmbienteSala` en `scenes/niveles/elyndor/salon_prefecto.tscn` (`pista = &"prefecto"`).
  - En `scenes/ui/titulo/titulo.gd` y `scenes/ui/fin_demo/fin_demo.gd` se detiene el ambiente (`GestorSonido.global().ambiente(&"")`).
- **Sonidos de interfaz:**
  - Enlazados `ui_mover` (`focus_entered`) y `ui_aceptar` (`pressed`) en todos los botones y deslizadores de `titulo.gd`, `fin_demo.gd` y `menu_pausa.gd`.
  - Suprimido el sonido `ui_mover` en la asignación del foco inicial diferido mediante bandera `_foco_inicial_dado` activada tras el primer frame de procesamiento.
- **Volúmenes en el menú de pausa:**
  - Creada sección `PanelSonido` en `scenes/ui/pausa/menu_pausa.tscn` y `menu_pausa.gd` accesible desde la opción "Sonido".
  - Tres deslizadores `HSlider` para Música, Efectos y Ambiente (rango 0.0–1.0, paso 0.05), navegables con teclado y mando.
  - Sincronizados con `AudioServer` al abrir la sección (`db_to_linear(AudioServer.get_bus_volume_db(...))`) y conectados a `GestorSonido.global().fijar_volumen(...)` en tiempo real.
- **Pruebas y verificación:**
  - Creado `tests/test_sonido_ui.gd` validando ambientes por sala, detención en título y fin de demo, visibilidad de ajustes y cambio de volúmenes por bus.
  - Comprobación completa con `tools/comprobar.ps1`: **15 de 15 pruebas superadas con 0 fallos (`Todo correcto`)**.

## Revisión (Claude, 2026-11-01) — ACEPTADO

Dentro de los archivos permitidos, ambiente por sala, ambiente detenido en título y fin de la demo, sonidos de interfaz sin el falso `ui_mover` inicial y volúmenes por bus sincronizados con `AudioServer`. Las 15 pruebas pasan.
