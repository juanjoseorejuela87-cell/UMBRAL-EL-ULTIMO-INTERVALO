# TAREA-021 — Habitantes atrapados en bucles (Aldous, Elspeth y Gowan)

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
- **Archivos permitidos:**
  - Nuevos: `scenes/mundo/habitante/habitante.tscn` y `scenes/mundo/habitante/habitante.gd` (`class_name Habitante`), y si hace falta una figura por habitante en esa carpeta.
  - `scenes/niveles/elyndor/barrio_desprendido.tscn` (solo añadir los tres habitantes, dentro de un nodo `Habitantes`).
  - `tests/test_habitantes.gd` (nuevo).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `scenes/ui/dialogo/` (usa `Subtitulo` tal cual), el resto de la sala.

## Por qué

Elyndor es «el reino que olvidó» (`LORE.md` §4.1): sus habitantes repiten gestos de vidas que ya no existen. Los textos están escritos y revisados en `documentation/propuestas/elyndor_textos.md` §3 (TAREA-001). Con ellos la demo gana personajes sin tocar el combate.

## Interfaz disponible (ya en `main`)

- **Subtítulos:** `Subtitulo.mostrar(get_tree(), "Nombre", PackedStringArray([...]))` muestra las líneas una tras otra en la parte baja de la pantalla y se desvanece sola (`scenes/ui/dialogo/subtitulo.gd`). Uno nuevo sustituye al anterior.
- **Acción de interactuar:** `&"interactuar"` (E / botón Y). Ejemplo de uso con proximidad: `scenes/mundo/ancla/ancla.gd` (área que detecta a Nereth en la capa 4 y `Input.is_action_just_pressed(&"interactuar")`).
- **Figura estilizada:** puedes construir la figura con primitivas como `scenes/jugador/figura_nereth.gd` (sin su lógica de combate) o con piezas simples en la escena; con aspecto de **habitante corriente** (ropa de tela apagada, sin armadura), más bajo y encorvado que Nereth.

## Encargo

1. **`Habitante`** (`Node3D` o `Area3D`): exporta `nombre: String`, `lineas: PackedStringArray`, `gesto: StringName` (identificador del gesto que repite) y `existe_en` como los demás elementos de fase si hace falta (por defecto, ambos estados).
   - Cuando Nereth está cerca (≈ 2 u), aparece sobre él un indicador discreto de «interactuar» (p. ej. una pequeña runa que brilla) y, al pulsar `interactuar`, muestra sus líneas con `Subtitulo.mostrar`. Si se vuelve a hablar, repite las mismas líneas (está en bucle: es el sentido del personaje).
   - **Gesto en bucle** animado por código, distinto para cada uno:
     - **Aldous:** enciende y apaga una linterna de aceite (un punto de luz emisivo que se enciende y se apaga; **sin** `OmniLight3D`) ante una casa en escombros.
     - **Elspeth:** mece un manto vacío entre los brazos (balanceo suave), junto a una grieta.
     - **Gowan:** frota sin parar una llave contra su jubón (movimiento corto y repetitivo del brazo).
2. **Colocación en las Ruinas**, dentro de un nodo `Habitantes`, en el plano de juego pero **sin colisión** que bloquee a Nereth ni a los enemigos, en zonas tranquilas (lejos de los enemigos, del Ancla y de los tres ecos de memoria). Usa las líneas exactas de `elyndor_textos.md` §3.
3. **No los afecta el combate**: los ataques de Nereth no los dañan y los enemigos los ignoran.
4. Revisa con `tools/captura_sala.gd` (posición cerca de cada habitante) y describe lo revisado.
5. `tests/test_habitantes.gd`: los tres existen en las Ruinas con sus nombres y líneas; con Nereth cerca y pulsando `interactuar` aparece un `Subtitulo` con su primera línea; lejos no; no tienen colisión que bloquee; ninguno usa `OmniLight3D`.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`. Sin TripoSR mientras tanto.

Commit `[antigravity] Habitantes en bucle de Elyndor (TAREA-021)` solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» (incluidos errores o avisos de la salida, si los hay) y avisa en el canal.

## Resultado

_(lo rellena Antigravity)_
