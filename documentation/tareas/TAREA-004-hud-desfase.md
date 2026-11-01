# TAREA-004 — Resonancia y señales del Desfase en el HUD

- **Ayudante:** Google Antigravity
- **Estado:** ACEPTADO
- **Archivos permitidos:**
  - `scenes/ui/hud/hud.tscn`, `scenes/ui/hud/hud.gd`
  - Añadir **una instancia** del HUD en `scenes/niveles/pruebas/sala_desfase.tscn`.
- **No tocar:** `scenes/jugador/`, `scripts/core/`, `scenes/efectos/`, `project.godot`.

## Interfaz disponible (ya en `main`)

- `Nereth.resonancia: ComponenteResonancia`
  - `actual`, `maximo`, `amenaza() -> bool`, `limite_recuperacion_amenaza` (fracción, 0.3)
  - señales `cambiada(actual: float, maximo: float)`, `agotada`, `regimen_cambiado(amenaza: bool)`
- `Nereth.fase: FaseNereth`
  - señales `cambio_bloqueado`, `rechazo`, `desfase_preciso`
- `GestorFase.global()` (autoload): `en_desfase() -> bool`, señal `cambiada(estado: GestorFase.Estado)`. **Usa siempre `GestorFase.global()`**, no el identificador `Fase` (no existe al ejecutar pruebas con `-s`).

## Encargo

1. Activa y completa la `BarraResonancia` que dejaste preparada:
   - Barra azul-violeta, del mismo ancho que la de vida, entre vida y resistencia.
   - En régimen de **Amenaza**, marca con una línea fina el límite de recuperación pasiva (30 %) y tiñe el borde de rojo apagado. En **Calma**, sin marca.
   - Se actualiza por señales.
2. Indicador de estado: un pequeño rombo o icono junto a la barra que se ilumina cuando `en_desfase()` es true.
3. Avisos breves (0,3–0,5 s, sin texto):
   - `cambio_bloqueado`: la barra de Resonancia tiembla levemente.
   - `rechazo`: la barra destella en rojo.
   - `desfase_preciso`: la barra destella en blanco-azulado.
4. Añade el HUD a `sala_desfase.tscn` apuntando a `Nereth`.
5. Todo tipado, sin dependencias nuevas, solo lectura.

## Pruebas

- `powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto` (ahora con límite de tiempo por prueba).
- Arranque limpio: `D:\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\UMBRAL --quit-after 120`.

Commit en `main`: `[antigravity] Resonancia y señales del Desfase en el HUD (TAREA-004)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena "Resultado" y avisa en el canal.

## Resultado

- Activada y configurada `BarraResonancia` (`scenes/ui/hud/hud.tscn`, `scenes/ui/hud/hud.gd`):
  - Barra azul-violeta entre vida y resistencia, reactiva por señales a `cambiada(actual, maximo)`.
  - Régimen de Amenaza: visualiza el límite de recuperación pasiva al 30 % con marca `MarcaLimite` y resalta con borde sutil `BordeAmenaza`.
  - Indicador de Desfase: rombo/icono que se ilumina en color lila brillante cuando `GestorFase.global().en_desfase()` es true.
  - Avisos breves sin texto con animaciones Tween: temblor horizontal en `cambio_bloqueado`, destello rojo en `rechazo` y destello blanco-celeste en `desfase_preciso`.
- Instanciado `HudJuego` en `scenes/niveles/pruebas/sala_desfase.tscn` apuntando a `Nereth`.
- Comprobación: `tools/comprobar.ps1` pasa con éxito las 4 pruebas (`test_ancla.gd`, `test_combate.gd`, `test_desfase.gd`, `test_movimiento.gd` con 0 fallos) y arranque limpio.

## Revisión (Claude, 2026-11-01)

**ACEPTADO.** Todo por señales, dentro de los archivos permitidos; las 5 pruebas pasan (incluida la nueva `test_costura.gd`).
Notas menores (no bloquean):
- `_destello_barra` modifica el `StyleBoxFlat` del tema, que es un recurso compartido: si algún día hay dos HUD a la vez, destellarían juntos. Si hiciera falta, duplicar el estilo en `_ready`.
- El temblor mueve `position.x` de una fila dentro de un contenedor; el contenedor puede recolocarla, y si se interrumpe a mitad de temblor la "posición original" leída ya está desplazada. Funciona; solo tenerlo en cuenta si se ve raro.
