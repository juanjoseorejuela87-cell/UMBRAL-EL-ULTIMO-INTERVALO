# TAREA-013 — Pantalla de título con fondo 3D y contraste del Vigía Hueco

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
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

_(lo rellena Antigravity)_
