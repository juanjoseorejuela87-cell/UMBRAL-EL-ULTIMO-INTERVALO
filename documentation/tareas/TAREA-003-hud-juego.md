# TAREA-003 — HUD de juego y barra de postura de enemigos

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
- **Archivos permitidos:**
  - `scenes/ui/hud/hud.tscn`, `scenes/ui/hud/hud.gd`
  - `scenes/ui/barra_postura/barra_postura.tscn`, `scenes/ui/barra_postura/barra_postura.gd`
  - Añadir **una instancia** del HUD en `scenes/niveles/pruebas/sala_combate.tscn`.
  - Añadir **una instancia** de la barra de postura como hija de la raíz en `scenes/enemigos/muneco_practica/muneco_practica.tscn`.
- **No tocar:** scripts de `scenes/jugador/`, `scripts/core/`, `project.godot`, `muneco_practica.gd`.

## Interfaz disponible (ya en `main`)

- `Nereth.vida: ComponenteVida` → `actual`, `maximo`, señal `cambiada(actual: float, maximo: float)`.
- `Nereth.resistencia: ComponenteResistencia` → `actual`, `maximo`, señal `cambiada(actual: float, maximo: float)`.
- `MunecoPractica.postura: ComponentePostura` → `actual`, `maximo`, `en_ruptura`, señales `cambiada(actual, maximo)`, `rota`, `recuperada`.
- `MunecoPractica.vida: ComponenteVida`.

## Encargo

1. **HUD** (`CanvasLayer`, `class_name HudJuego`):
   - `@export var objetivo: Nereth`.
   - Abajo a la izquierda: barra de **vida** (roja apagada) y barra de **resistencia** (verde-amarillenta), más fina, debajo.
   - Se actualizan **por señales** (`cambiada`), no leyendo cada frame. Inicializa los valores en `_ready` (espera a que `objetivo` esté listo: usa `await objetivo.ready` si hace falta).
   - La resistencia puede animar suavemente (tween corto) hacia el nuevo valor; la vida muestra además una "barra de daño reciente" que baja con retraso (estilo sobrio, sin colores chillones).
   - Deja preparado un hueco (nodo oculto `BarraResonancia`) para la Resonancia de la etapa 3; no la implementes.
2. **Barra de postura** del enemigo (`Node3D`, `class_name BarraPostura`):
   - Flota sobre la cabeza del muñeco (≈ 2,4 m de altura), siempre de cara a la cámara (`Sprite3D`/`SubViewport` o `MeshInstance3D` con `billboard`; elige lo más ligero para la GPU integrada).
   - Muestra la postura acumulada (`actual / maximo`); en Ruptura cambia a color ámbar y parpadea suavemente.
   - Busca el `ComponentePostura` en su padre (`get_parent().get_node("Postura")`) o por `@export`.
   - Oculta cuando la postura está a 0 y no hay Ruptura.
3. Todo tipado, sin dependencias nuevas, solo lectura de los componentes (no modifica valores).

## Pruebas

- `powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.
- Arranque sin errores ni avisos nuevos: `D:\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\UMBRAL --quit-after 120`.

Commit en `main`: `[antigravity] HUD de juego y barra de postura (TAREA-003)`, **solo con los archivos permitidos**. Marca este encargo como `ENTREGADO`, rellena "Resultado" y avisa en `comunicacion/CANAL.md`.

## Criterios de aceptación (los revisa Claude)

- Solo toca los archivos permitidos.
- Actualización por señales; legible a 1280×720.
- Todas las pruebas pasan; arranque limpio.

## Resultado

_(Rellenar al entregar.)_
