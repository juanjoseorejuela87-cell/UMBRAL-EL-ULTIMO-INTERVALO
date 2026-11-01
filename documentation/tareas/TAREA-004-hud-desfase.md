# TAREA-004 — Resonancia y señales del Desfase en el HUD

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
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

_(Rellenar al entregar.)_
