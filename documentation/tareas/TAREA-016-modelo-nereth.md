# TAREA-016 — Modelo 3D de Nereth

- **Ayudante:** IA de modelado (por incorporar)
- **Estado:** ABIERTO (pendiente de que el director guarde la hoja de personaje en el repositorio)
- **Archivos permitidos:** `assets/modelos/nereth/` (nuevo) y `assets/LICENCIAS.md` (añadir filas).
- **No tocar:** escenas, código, `scenes/jugador/` (Claude integra el modelo).

## Referencia

- **Hoja de personaje oficial:** `documentation/arte/nereth_hoja_personaje.png` (vistas frontal, laterales y trasera; detalle del rostro; armadura; estados; espada; paleta).
- Resumen escrito: `documentation/GUIA_ARTE.md`, sección «Nereth» (CONFIRMADO).
- Requisitos técnicos y de licencia: `documentation/ESPECIFICACION_MODELOS.md` (leer entero).

## Encargo

1. **`nereth.glb`**: hombre de 1,82 m, atlético y delgado; pelo negro despeinado sobre la cara; cuello alto; armadura ligera oscura con filos plateados combinada con tela hecha jirones (abrigo largo abierto por detrás); guanteletes. Mirando a +X, pose en T o A, manos vacías, ≤ 15 000 triángulos, texturas 1K PBR, esqueleto humanoide estándar.
   - Piezas separadas (o grupos de materiales separados) para: **fragmentos flotantes** del hombro izquierdo (5–8 esquirlas), **marcas de Continuidad** del brazo (material emisivo propio, violeta) y los **jirones de la tela** (para animarlos por código).
2. **`espada_umbral.glb`**: la Espada del Umbral de la hoja (larga, hoja quebrada con vetas violetas, guarda angulosa), ≤ 2 000 triángulos, empuñadura en el origen y hoja hacia +Y.
3. **Animaciones** (en el mismo `nereth.glb` o en `nereth_animaciones.glb` con el mismo esqueleto): las de la tabla de `ESPECIFICACION_MODELOS.md` §3. Si la herramienta no anima, entrega el modelo con esqueleto y lo indicas.
4. **Licencias:** una fila por archivo en `assets/LICENCIAS.md` con la herramienta usada y su licencia de uso comercial.
5. Revisa tu entrega con `tools/vista_modelo.gd` (ver la especificación) y describe en «Resultado» triángulos, medidas y lo que comprobaste.

Commit `[modelado] Modelo de Nereth (TAREA-016)` solo con los archivos permitidos. Marca `ENTREGADO` y avisa en `comunicacion/CANAL.md`.

## Resultado

_(lo rellena la IA de modelado)_
