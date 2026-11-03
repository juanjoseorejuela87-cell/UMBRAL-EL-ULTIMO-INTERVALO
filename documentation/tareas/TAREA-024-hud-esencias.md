# TAREA-024 — Esencias en el HUD y «Curar» en los controles

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
- **Archivos permitidos:** `scenes/ui/hud/hud.tscn`, `scenes/ui/hud/hud.gd`, `scenes/ui/pausa/menu_pausa.gd` (solo añadir el nombre de la acción), `tests/test_hud_esencias.gd` (nuevo).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, el resto de la interfaz.

## Novedad del núcleo (ya en `main`)

Nereth tiene **Esencias**, cargas de curación (`scenes/jugador/esencias_nereth.gd`, nodo `Nereth/Esencias`, accesible como `nereth.esencias`):
- `cargas: int`, `cargas_maximas: int` (3 por ahora).
- Señales: `cargas_cambiadas(cargas, maximo)`, `curacion_iniciada`, `curacion_completada(cantidad)`, `curacion_interrumpida`.
- Acción de entrada **`&"curar"`** (tecla R / arriba en la cruceta). Se rellenan al descansar en un Ancla o al reaparecer.

## Encargo

1. **HUD:** junto a las barras de vida, resistencia y Resonancia, una fila de **3 iconos de Esencia** (pequeños frascos o gotas; llenos en un color cálido, vacíos en gris translúcido) que se actualizan con `cargas_cambiadas`. Breve destello del icono al gastar una (`curacion_iniciada`) y aviso visual sutil si se interrumpe (`curacion_interrumpida`). Que no tape nada y se lea en 1280×720 y en pantallas mayores.
2. **Controles de la pausa:** añade `&"curar": "Curar (Esencia)"` a `NOMBRES_ACCIONES` en `menu_pausa.gd` para que aparezca en la lista de controles.
3. `tests/test_hud_esencias.gd`: el HUD muestra 3 iconos llenos al empezar; tras gastar una (llamando a `nereth.esencias.intentar_curar()` con la vida por debajo del máximo) muestra 2; tras `nereth.restaurar()` vuelve a 3; la lista de controles de la pausa incluye «Curar».

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto` (sin TripoSR en marcha mientras tanto).

Commit `[antigravity] Esencias en el HUD (TAREA-024)` solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» (con errores o avisos de la consola, si los hay) y avisa en el canal.

## Resultado

_(lo rellena Antigravity)_
