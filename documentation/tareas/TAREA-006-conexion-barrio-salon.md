# TAREA-006 — Conectar el Barrio Desprendido con el Salón del Prefecto

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
- **Archivos permitidos:** `scenes/niveles/elyndor/barrio_desprendido.tscn`, `tests/test_barrio_desprendido.gd`.
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `scenes/niveles/elyndor/salon_prefecto.tscn` (es de Claude), `project.godot`.

## Contexto

Ya existe el sistema de cambio de sala (hito 8, en `main`):

| Pieza | Uso |
|---|---|
| `scripts/core/mundo/punto_entrada.gd` (`PuntoEntrada`) | `Marker3D` donde aparece Nereth al llegar. `id` (StringName) y `mirando` (1 derecha, −1 izquierda). Colócalo **fuera** de cualquier transición. |
| `scripts/core/mundo/transicion_sala.gd` (`TransicionSala`) | `Area3D` con `collision_mask = 8`. Al entrar Nereth, carga `escena_destino` y lo coloca en el `PuntoEntrada` con id `entrada_destino`. |
| Autoload `Salas` (`GestorSalas.global()`) | Fundido, cambio de escena y conservación de vida y Resonancia. |

El juego ahora arranca en `barrio_desprendido.tscn` buscando la entrada `inicio`. El Salón del Prefecto (`scenes/niveles/elyndor/salon_prefecto.tscn`) tiene la entrada `desde_barrio` y una transición de vuelta que busca en el Barrio la entrada `desde_salon`.

## Encargo

1. En el Barrio, añade:
   - `PuntoEntrada` id `inicio` donde empieza Nereth ahora (x ≈ −16), `mirando = 1`.
   - `PuntoEntrada` id `desde_salon` junto al pórtico final, unos metros antes de la transición, `mirando = -1`.
   - `TransicionSala` en el pórtico final (cruzándolo, de suelo a ~4 u de alto) con `escena_destino = "res://scenes/niveles/elyndor/salon_prefecto.tscn"` y `entrada_destino = &"desde_barrio"`. Si el pórtico actual bloquea el paso, ábrelo (que siga leyéndose como un arco).
2. Amplía `tests/test_barrio_desprendido.gd`: comprueba que existen las dos entradas con esos ids y una `TransicionSala` con ese destino, y que el `PuntoEntrada` `desde_salon` **no** está dentro de la transición.
3. Opcional (si te sobra tiempo): juega Barrio → Salón → Barrio y anota en "Resultado" cualquier cosa rara del cambio de sala (cámara, fundido, posición).

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.

Commit `[antigravity] Conexión Barrio Desprendido ↔ Salón del Prefecto (TAREA-006)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena "Resultado" y avisa en el canal.

## Resultado

_(Rellenar al entregar.)_
