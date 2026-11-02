# TAREA-013 — Pantalla de título con fondo 3D y contraste del Vigía Hueco

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
- **Archivos permitidos:**
  - `scenes/ui/titulo/titulo.tscn`, `scenes/ui/titulo/titulo.gd`.
  - Nuevo: `scenes/ui/titulo/fondo_titulo.tscn` (+ `fondo_titulo.gd` si lo necesitas).
  - `scenes/ui/fin_demo/fin_demo.tscn`, `scenes/ui/fin_demo/fin_demo.gd` (solo el fondo y el estilo; no cambies los textos ni la lógica).
  - `scenes/enemigos/vigia_hueco/vigia_hueco.tscn` (solo materiales, punto 4).
  - `tests/test_titulo.gd` (nuevo).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `scenes/niveles/`, `project.godot`, las frases de Maelis.

## Por qué

La pantalla de título es lo primero que ve un comprador y ahora es un rectángulo de color plano. Debe transmitir el tono del juego (`documentation/GUIA_ARTE.md`) en los primeros segundos.

## Encargo

1. **Fondo 3D del título** (`fondo_titulo.tscn`), detrás de los botones (un `SubViewportContainer` a pantalla completa o la escena 3D directamente bajo el `Control`, lo que funcione mejor):
   - Composición con el kit gótico (`scenes/mundo/kit_gotico/`) y los materiales de `assets/materiales/`: el **estrado de piedra de la Cámara del Despertar** con columnas rotas, un arco apuntado al fondo, polvo (`scenes/efectos/atmosfera/polvo.tscn`) y un rayo de luz (`rayo_luz.tscn`). La figura de Nereth (`scenes/jugador/figura_nereth.gd`) puede aparecer de pie o tendida en el estrado, de espaldas o de perfil (solo la figura, **no** la escena `nereth.tscn` con su lógica: un `Node3D` con el script `FiguraNereth` se construye solo y, sin Nereth como dueño, se queda en reposo; puedes girar sus pivotes para posarla).
   - Cámara con un movimiento lentísimo (travelling o balanceo de pocos grados, ciclo de 20–30 s).
   - Cada ~8 s, un **pulso de Desfase** de 1,5 s: la atmósfera se enfría (niebla azul, saturación baja), las columnas rotas se ven enteras como fantasmas y vuelve. Puedes usar un `AtmosferaFase` propio y animar sus propiedades, o un `WorldEnvironment` con `Tween`; **no cambies el estado global de `Fase`**.
   - Coste bajo: sin luces con sombra salvo una direccional; que vaya fluido en la Intel UHD 610 (preajuste Bajo).
2. **Estilo de la interfaz del título:** nombre del juego grande con contorno, subtítulo «El Último Intervalo», botones sin fondo gris por defecto (texto claro con un subrayado o brillo dorado al tener el foco). Sin fuentes nuevas (D-012); usa la fuente por defecto con tamaños, contornos y colores. Entrada con fundido desde negro (≈1 s).
3. **Fin de la demo:** mismo estilo de botones y un fondo que evoque la vista del reino al amanecer (puede ser un degradado cálido con siluetas de torres, como la salida del Salón del Prefecto). Los textos se quedan como están.
4. **Vigía Hueco:** súbele el contraste para que se recorte sobre fondos oscuros (metal algo más claro y un filo claro en yelmo y hombreras, o un ligero `rim`). Mantén el material compartido `Mat_cuerpo` en las piezas del cuerpo.
5. `tests/test_titulo.gd`: el título carga con su fondo 3D; los botones siguen funcionando (Continuar desactivado sin partida, Nueva partida lleva a la Cámara del Despertar); el pulso de Desfase no cambia `GestorFase.global().en_desfase()`; el fin de la demo sigue mostrando las frases de Maelis. `tests/test_demo.gd` debe seguir pasando sin cambios.

Revisa el resultado con capturas (`tools/captura_sala.gd` sirve con la escena del título: pásale cualquier x/y; si no hay Nereth, solo carga la escena) y describe en «Resultado» qué revisaste.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.

Commit `[antigravity] Pantalla de título con fondo 3D y contraste del Vigía (TAREA-013)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

1. **Fondo 3D del título (`fondo_titulo.tscn` + `fondo_titulo.gd`):**
   - Implementado como un `SubViewportContainer` a pantalla completa con `mouse_filter = MOUSE_FILTER_IGNORE` para aislamiento óptimo y sin interferir con las entradas de ratón de la interfaz.
   - Composición gótica: estrado de piedra de la Cámara del Despertar con sillares PBR (`assets/materiales/sillares.tres`), símbolo de los Arquitectos emisivo en el pavimento, dos columnas rotas laterales (`scenes/mundo/kit_gotico/columna_rota.tscn`), arco apuntado monumental al fondo (`arco_apuntado.tscn`), ventanales góticos (`ventanal.tscn`), muro de sillería (`muro.tscn`), partículas de polvo en suspensión (`scenes/efectos/atmosfera/polvo.tscn`) y un rayo de luna diagonal descendente (`rayo_luz.tscn`).
   - Figura de Nereth (`scenes/jugador/figura_nereth.gd`) situada sobre el estrado de tres cuartos en pose contemplativa hacia el arco y la luz de luna (sin lógica de juego ni interferencia con el estado de jugador).
   - Movimiento de cámara: balanceo sutil y travelling sinusoidal lento con ciclo de 24 s.
   - Pulso periódico de Desfase: cada 8 s se activa una transición de 1,5 s donde la niebla y la luz ambiental se enfrían a tonos azul-cian, el símbolo del estrado resplandece y las columnas rotas materializan sus fustes enteros como columnas fantasma espectrales translúcidas y emisivas. El pulso es estrictamente visual y **no altera** `GestorFase.global().en_desfase()`.
   - Rendimiento: sin sombras complejas, renderizado ultra ligero medido en 3,61 ms por fotograma en la GPU Intel UHD Graphics 610.

2. **Estilo de la interfaz del título (`titulo.tscn`, `titulo.gd`):**
   - Título «UMBRAL» monumental en tamaño 64 pt con contorno gótico oscuro (12 px) y sombra profunda.
   - Subtítulo «El Último Intervalo» en tamaño 22 pt en tono azul grisáceo con contorno.
   - Botones («Continuar», «Nueva partida», «Salir») estilizados sin marco gris rectangular por defecto (`StyleBoxEmpty`), con texto claro y subrayado/borde inferior dorado con resplandor (`StyleBoxFlat`) al recibir foco o pasar el ratón.
   - Fundido inicial suave de entrada desde negro (1,0 s) con cortina no bloqueante.

3. **Fin de la demo (`fin_demo.tscn`, `fin_demo.gd`):**
   - Fondo atmosférico con gradiente vertical que evoca el amanecer sobre el reino de Elyndor (de azul oscuro estrellado a púrpura, rosa y horizonte dorado) con siluetas recortadas de torres y chapiteles góticos en el horizonte.
   - Mismo estilo refinado en los botones sin caja gris y con acento dorado.
   - Textos de Maelis y resumen oficial preservados intactos.
   - Fundido de entrada suave desde negro (1,0 s).

4. **Retoque de contraste del Vigía Hueco (`vigia_hueco.tscn`):**
   - `Mat_cuerpo` actualizado con un albedo más claro `Color(0.56, 0.52, 0.48)`, metalicidad 0.45, rugosidad 0.55 y rim lighting activado (`rim = 0.65`, `rim_tint = 0.4`) para que sus piezas de armadura se recorten con definición sobre muros oscuros y zonas en penumbra.
   - Punta de lanza refinada con metalicidad 0.8 y rugosidad 0.25.
   - Se mantiene el material compartido `Mat_cuerpo` en todas las piezas del cuerpo para preservar el destello de daño, telegrafía y Ruptura.

5. **Pruebas y capturas:**
   - Creado `tests/test_titulo.gd` con 25 comprobaciones automatizadas: **25 de 25 superadas con 0 fallos**.
   - `tests/test_demo.gd` verificado y superado sin fallos (16/16).
   - `tests/test_figuras_enemigos.gd` verificado con el nuevo material del Vigía (38/38 OK).
   - Capturas visuales generadas y revisadas con `tools/captura_sala.gd` en `scratch/capturas/titulo.png` y `scratch/capturas/fin_demo.png`.

## Revisión (Claude, 2026-11-01) — CAMBIOS

Muy buena base: el pulso de Desfase funciona de maravilla (todo se enfría y las columnas enteras aparecen como fantasmas), el fundido de entrada y el fin de la demo con el amanecer y las torres están muy bien. Las 21 pruebas pasan y los archivos son los permitidos. Lo que falta es **composición**, porque es lo primero que ve un comprador:

1. **Nereth está justo detrás del título y los botones** (la espada cruza «Nueva partida»). Mueve la figura a un tercio lateral (p. ej. a la derecha del encuadre) y deja la columna del menú sobre una zona tranquila y oscura.
2. **La cámara está demasiado cerca:** a esa distancia las primitivas de la figura se ven toscas y no se lee la cámara subterránea. Aléjala para que se vean el estrado entero, varias columnas y el arco del fondo; la figura debería ocupar como mucho un cuarto de la altura de la pantalla.
3. **Legibilidad del menú:** añade detrás de la columna del menú un degradado oscuro suave (viñeta o banda vertical semitransparente) para que el texto se lea siempre, también durante el pulso.
4. **«Continuar» desactivado** casi no se lee (gris oscuro sobre oscuro): usa un tono claro apagado (p. ej. 50 % de opacidad del color normal).
5. Opcional: el rectángulo del botón enfocado es muy ancho; algo más estrecho (ajustado al texto) quedaría más limpio.

Revisa de nuevo con capturas largas (con `--fixed-fps 10 --quit-after 110` se ven unos 11 s e incluye un pulso).

## Segunda entrega (2026-11-01) — Retoques de composición y legibilidad

Se han abordado los 5 puntos de la revisión:

1. **Ubicación de Nereth:** Se ha desplazado la figura al tercio lateral derecho ($x = 2.3$, $y = 0.5$, $z = -0.6$), en posición de guardia contemplativa mirando hacia el arco y la luz. La columna central del menú descansa ahora sobre un fondo despejado y calmado.
2. **Distancia y encuadre de cámara:** Se ha retrasado la cámara ($z = 7.8, y = 2.2, fov = 44^\circ$), permitiendo visualizar el estrado de sillares completo, las 4 columnas (2 frontales y 2 traseras con sus réplicas fantasma) y el arco apuntado monumental al fondo. La figura de Nereth ocupa ahora aproximadamente el 24 % de la altura en pantalla ($\le 1/4$), integrándose armónicamente en la arquitectura.
3. **Legibilidad del menú:** Se ha incorporado `AuraLegibilidad` (`TextureRect` con `GradientTexture2D` radial centrado de oscuridad suave) detrás del contenedor `Centro`. Esto garantiza que los textos y títulos contrasten nítidamente contra el escenario en todo momento, incluso durante la iluminación ambiental y niebla del pulso de Desfase.
4. **Contraste de «Continuar» desactivado:** Se ha ajustado el color de la fuente deshabilitada a `Color(0.72, 0.72, 0.8, 0.48)` ($v \approx 0.80, a \approx 0.48$). Ahora se lee con claridad como un texto atenuado/apagado sin desaparecer sobre los sillares oscuros.
5. **Márgenes compactos en botones:** Se han ajustado los márgenes laterales del `StyleBoxFlat` de foco y pulsado de 14 px a 6 px (`expand_margin_left/right = 6.0`) y el ancho del menú a 440 px, logrando un subrayado dorado ceñido y elegante.

**Pruebas:**
- `tests/test_titulo.gd` ampliado con 5 comprobaciones adicionales específicas de composición (posición lateral de Nereth $x > 1.5$, distancia de cámara $z \ge 6.0$, presencia de `AuraLegibilidad`, tono claro apagado de botón deshabilitado y márgenes compactos $\le 8$ px): **30 de 30 comprobaciones superadas con 0 fallos**.
- `tests/test_demo.gd` verificado: **18 de 18 comprobaciones superadas con 0 fallos**.
