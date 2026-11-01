# TAREA-011 — Sección «Gráficos» en el menú de pausa

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
- **Archivos permitidos:**
  - `scenes/ui/pausa/menu_pausa.tscn`, `scenes/ui/pausa/menu_pausa.gd`.
  - `tests/test_menu_graficos.gd` (nuevo).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `scenes/niveles/`, `project.godot`.

## Interfaz disponible (ya en `main`, hito 12)

Autoload **`Graficos`** → `ConfiguracionGrafica.global()` (`scripts/core/graficos/configuracion_grafica.gd`):

- `enum Preajuste { BAJO, MEDIO, ALTO, ULTRA }` y `NOMBRES: Array[String]` = `["Bajo", "Medio", "Alto", "Ultra"]`.
- `preajuste: Preajuste`: calidad actual (se guarda sola en `user://ajustes.cfg`).
- `requiere_reinicio(p: Preajuste) -> bool`: true si ese preajuste usa otro renderizador (BAJO/MEDIO = Compatibility, ALTO/ULTRA = Forward+) y el juego tendrá que reiniciarse.
- `cambiar(p: Preajuste) -> bool`: aplica y guarda. Si hace falta otro renderizador **reinicia el juego al momento** (sin pantalla, en el editor o en las pruebas nunca reinicia; solo devuelve true).
- Señal `calidad_cambiada(preajuste)`.

## Encargo

1. Botón **Gráficos** en el menú principal de la pausa (entre «Sonido» y «Volver al título»), que abre un `PanelGraficos` con el mismo estilo que `PanelSonido`.
2. En el panel: un selector de calidad (`OptionButton` o cuatro botones) con los cuatro `NOMBRES`, que muestra el preajuste actual al abrir el panel, y un texto breve debajo que describa la opción enfocada:
   - Bajo: «Para equipos modestos y gráficas integradas.»
   - Medio: «Equilibrio entre aspecto y rendimiento.»
   - Alto: «Sombras e iluminación de calidad. Requiere una gráfica dedicada.»
   - Ultra: «Iluminación global y niebla volumétrica. Para equipos potentes.»
3. Al elegir un preajuste:
   - Si `requiere_reinicio(p)` es **false**, llama a `cambiar(p)` directamente.
   - Si es **true**, pide confirmación en el propio panel: «El juego se reiniciará para cambiar el modo gráfico. Se perderá el progreso desde la última Ancla.» con «Reiniciar» y «Cancelar». Solo «Reiniciar» llama a `cambiar(p)`; «Cancelar» devuelve el selector al preajuste actual.
4. Botón «Volver» al menú principal. Todo navegable con teclado y mando, con los sonidos `ui_mover`/`ui_aceptar` que ya usa el menú (sin `ui_mover` en el foco inicial).
5. `tests/test_menu_graficos.gd`: la sección existe y es visible al abrirla; muestra el preajuste actual; elegir otro dentro del mismo renderizador (BAJO ↔ MEDIO) cambia `preajuste`; elegir uno que pide reinicio muestra la confirmación y «Cancelar» no lo cambia. En las pruebas sin pantalla el renderizador es Compatibility, así que ALTO y ULTRA piden reinicio y puedes probar la confirmación directamente; pulsar «Reiniciar» en la prueba no cierra el juego (sin pantalla nunca reinicia).

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto` (ahora son 18 pruebas con la tuya).

Commit `[antigravity] Sección de gráficos en el menú de pausa (TAREA-011)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

_(lo rellena Antigravity)_
