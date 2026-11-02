# TAREA-021 — Habitantes atrapados en bucles (Aldous, Elspeth y Gowan)

- **Ayudante:** Google Antigravity
- **Estado:** ACEPTADO
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

### 1. Implementación de `Habitante` (`scenes/mundo/habitante/`)
- Se implementó `scenes/mundo/habitante/habitante.gd` (`class_name Habitante extends Area3D`) y `habitante.tscn`.
- **Detección e Interacción:** El nodo actúa como un `Area3D` con `collision_layer = 0`, `collision_mask = 8` y `monitorable = false`. No tiene colisiones físicas sólidas ni bloquea a Nereth ni a los enemigos, y es inmune a ataques de combate. Detecta a Nereth a ~2.0 u y muestra un aviso `[E] Hablar`. Al pulsar `&"interactuar"` llama a `Subtitulo.mostrar(get_tree(), nombre, lineas)`. Si se vuelve a pulsar, repite el mismo diálogo en bucle.
- **Aspecto estilizado:** Malla con proporciones de ciudadano corriente (altura ~1.60 m, hombros caídos y leve curvatura en el torso), vestido con túnica y ropajes rústicos apagados en tonos tierra sin armadura metálica ni brillos.
- **Gestos en bucle por código:**
  - **Aldous (`gesto = &"linterna"`):** La llama de la linterna modula su emisión entre 0.0 y 2.2 con ciclo sinusoidal suave, con leve cabeceo y balanceo de la mano. **Cero nodos `OmniLight3D`**.
  - **Elspeth (`gesto = &"manto"`):** Mece rítmicamente un manto de tela doblada entre ambos brazos con oscilación lateral del torso (`sin(t * 1.8)`).
  - **Gowan (`gesto = &"llave"`):** Frota rápidamente una llave de hierro contra su jubón en el pecho (`sin(t * 7.5)`).

### 2. Ubicación en las Ruinas bajo Elyndor (`scenes/niveles/elyndor/barrio_desprendido.tscn`)
Agrupados bajo el nodo contenedor `Habitantes: Node3D`, en zonas seguras y tranquilas, alejadas de enemigos, Anclas y Ecos:
- **Aldous:** `x = -1.5, y = 1.5, z = 0.0`, ante los muros derruidos de las viviendas de la calle de entrada (a 9.5 u de `EcoCampana`).
- **Elspeth:** `x = 2.8, y = 1.5, z = 0.0`, al borde del foso de la calle antes de la fractura del puente (a 32 u del Ancla).
- **Gowan:** `x = 83.5, y = 4.5, z = 0.0`, en el rellano alto tras superar el foso de puntadas, antes de la reja ornamental (a 10.5 u del Guardián y a 18.5 u de `EcoArchivista`).

### 3. Verificación Visual (`tools/captura_sala.gd`)
Se capturaron fotogramas individuales con Nereth frente a cada personaje:
- `captura_aldous`: Se observa a Nereth a la izquierda de Aldous frente a la fachada en ruinas, con el indicador `[E] Hablar` visible.
- `captura_elspeth2`: Se observa a Elspeth al borde del abismo con la barandilla rota, meciendo el manto vacío.
- `captura_gowan`: Se observa a Gowan en el rellano superior con la reja ornamental de fondo.

### 4. Pruebas Unitarias y Salida de Consola
- Se creó `tests/test_habitantes.gd` cubriendo:
  1. Instanciación y presencia de los tres habitantes en el nodo `Habitantes`.
  2. Nombres, 3 líneas canónicas y gestos correspondientes.
  3. Cero nodos `OmniLight3D` en todos los habitantes.
  4. Ausencia total de colisiones físicas bloqueantes (`collision_layer == 0`, sin `StaticBody3D` ni `AnimatableBody3D`).
  5. Con Nereth lejos, no se activan subtítulos al pulsar interactuar.
  6. Con Nereth cerca de cada habitante, se despliega la primera línea de diálogo.
  7. Repetición del bucle de diálogo al interactuar de nuevo.
- Resultado: **20 comprobaciones unitarias superadas con 0 fallos**.
- **Avisos de consola:** Durante la ejecución en modo headless no se emitió ningún error de script ni parseo. Solo se registra el aviso habitual de salida del motor: `WARNING: 2 ObjectDB instances were leaked at exit (run with --verbose for details)`.
- **Suite global:** `tools/comprobar.ps1` superado con **24 pruebas automáticas correctas (0 fallos)**.

## Revisión (Claude, 2026-11-02) — ACEPTADO

Dentro de los archivos permitidos; los tres habitantes en las Ruinas con las líneas revisadas de `elyndor_textos.md` §3, sin colisión ni luces y con el aviso «[E] Hablar». Revisado con capturas (posiciones y aviso) y con su prueba (interacción y bucle). Las 24 pruebas pasan. Bien por incluir los avisos de la consola en el informe.
