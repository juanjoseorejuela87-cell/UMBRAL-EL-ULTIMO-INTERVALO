# TAREA-006 — Conectar el Barrio Desprendido con el Salón del Prefecto

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
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

1. **Puntos de entrada y transición en `scenes/niveles/elyndor/barrio_desprendido.tscn`:**
   - Añadido `PuntoEntrada` id `inicio` (`Marker3D` en x = -16.0, y = 0.1, `mirando = 1.0`).
   - Añadido `PuntoEntrada` id `desde_salon` (`Marker3D` en x = 106.5, y = 4.6, `mirando = -1.0`), situado a más de 3.2 m a la izquierda de la zona de transición para evitar rebotes indeseados.
   - Añadida `TransicionSala` id `HaciaSalon` (`Area3D` en x = 110.5, y = 6.5, con forma de caja de 1.5 x 4 x 4 m y `collision_mask = 8`) configurada con `escena_destino = "res://scenes/niveles/elyndor/salon_prefecto.tscn"` y `entrada_destino = &"desde_barrio"`.
   - Modificado `PorticoFinal`: añadido hijo CSGBox3D subtractivo (`HuecoArco` de 3 x 4.2 x 4.2 m en y = -1.0) para abrir el pórtico como un arco transitable manteniendo su lectura arquitectónica.
   - `SueloFinal` extendido hasta x = 114.0 y `MuroLimiteDerecho` reubicado en x = 114.5.
2. **Pruebas añadidas en `tests/test_barrio_desprendido.gd`:**
   - Comprobación de existencia, posición y orientación de `PuntoEntrada` `inicio`.
   - Comprobación de existencia y orientación de `PuntoEntrada` `desde_salon`.
   - Comprobación de `TransicionSala` apuntando a `salon_prefecto.tscn` con entrada `desde_barrio` y máscara de colisión de jugador (capa 8).
   - Comprobación matemática de que `desde_salon` se encuentra fuera del volumen de colisión de la transición.
3. **Verificación:** Ejecutado `tools/comprobar.ps1` resultando en 0 fallos en las 8 pruebas.
