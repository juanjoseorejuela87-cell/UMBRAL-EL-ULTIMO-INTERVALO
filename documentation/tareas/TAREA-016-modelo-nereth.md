# TAREA-016 — Modelo 3D de Nereth

- **Ayudante:** Claude con Blender (D-037); opcionalmente base generada con TRELLIS.2 (MIT) a partir de la vista frontal de la hoja
- **Estado:** ABIERTO
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

## Avance (Claude, 2026-11-02)

- Modelo **provisional por piezas** hecho en Blender (`tools/blender/nereth.py` → `assets/modelos/nereth/`), 1 284 triángulos, integrado en `FiguraNereth` con los fragmentos del hombro orbitando (más rápido en el Desfase). Funciona, pero es una figura geométrica: el director lo considera insuficiente.
- Siguiente paso acordado: generar una base detallada con **TRELLIS.2** (MIT) a partir de `assets/modelos/nereth/referencia/nereth_frontal.png` (o de la hoja original en alta resolución), y luego limpiarla, reducirla a ≤ 15 000 triángulos y orientarla en Blender.
- `tools/trellis_cliente.py`: cliente propio (solo biblioteca estándar) de la demo pública de TRELLIS.2; sube la imagen, genera y descarga el `.glb`. Probado hasta el paso de preparar la imagen: la cuota anónima de GPU (ZeroGPU) se agota; necesita `HF_TOKEN` (cuenta gratuita de Hugging Face) en `.env`, que Git ignora.
- `tools/blender/preparar_modelo.py`: escala a 1,82 m, pies en el suelo, orienta a +X, reduce a ≤ 15 000 triángulos y texturas a 1K.
- **Modelo jugable actual (2026-11-02):** `assets/modelos/nereth/nereth_animable.glb`. Cadena: vista frontal de la hoja → fondo quitado con `u2netp` (`tools/triposr_preparar_imagen.py`) → **TripoSR** local en CPU (~9 min) → `tools/blender/preparar_modelo.py` (de pie, 1,82 m, a +X, 14 520 triángulos, color por vértice) → `tools/blender/esqueleto.py` (17 huesos por proporciones, pesos por cercanía; el abrigo sigue a la cadera). `FiguraNereth` mueve los huesos con la misma animación procedural (muslos, rodillas, brazos, torso) y lleva la Espada del Umbral en la mano derecha.
- Limitaciones: la cara y la espalda son poco detalladas (una sola vista), el color es por vértice (no textura) y la capa y los fragmentos forman parte de la malla (no ondean ni orbitan por separado). Mejoras posibles: generar con TRELLIS.2 (más detalle y textura) o separar capa y fragmentos en Blender.
