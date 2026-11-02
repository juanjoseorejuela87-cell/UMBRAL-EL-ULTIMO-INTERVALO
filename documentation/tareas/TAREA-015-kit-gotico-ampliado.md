# TAREA-015 — Kit gótico ampliado (piezas Realidad/Desfase)

- **Ayudante:** Google Antigravity
- **Estado:** ACEPTADO
- **Archivos permitidos:**
  - Nuevas escenas (y scripts si hacen falta) en `scenes/mundo/kit_gotico/`.
  - `scenes/niveles/pruebas/sala_kit_gotico.tscn` (muestrario).
  - `tests/test_kit_gotico.gd` (nuevo).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, las salas de `scenes/niveles/elyndor/`, las piezas existentes del kit, `project.godot`, `assets/` (usa los materiales que ya hay en `assets/materiales/`).

## Por qué

Hito 14 (rebanada visual): las salas futuras (y el resto de Elyndor) necesitan más variedad de piezas con el mismo estilo, y cada pieza importante debe tener su versión **rota** (Realidad) y **entera** (Desfase), que es la firma visual del juego (`documentation/GUIA_ARTE.md`: Realidad en ruinas, Desfase intacto).

## Encargo

Crea estas piezas con CSG/primitivas y los materiales de `assets/materiales/` (`sillares`, `piedra_castillo`, `metal_oxidado`, `madera_oscura`, `piedra_desfase`…), siguiendo el estilo de `columna_rota.tscn` y `arco_apuntado.tscn`:

1. **Vidriera** (`vidriera.tscn` y `vidriera_rota.tscn`): ventanal apuntado con cristales de colores (material sin sombreado, emisión baja; colores apagados: ámbar, rojo vino, azul pizarra). La rota tiene huecos y fragmentos; la entera, el dibujo completo de un símbolo de los Arquitectos (círculo con radios) en el centro.
2. **Barandilla** (`barandilla.tscn` y `barandilla_rota.tscn`): balaustrada de piedra de 4 u de largo; la rota con balaustres caídos y tramo partido.
3. **Brasero** (`brasero.tscn`): cuenco de metal sobre pie con «llama» falsa (malla emisiva que ondula por código, sin luz) y una variante `brasero_apagado.tscn`. Una `OmniLight3D` opcional **desactivada por defecto** (`@export var con_luz: bool = false`) para cuando la sala tenga presupuesto.
4. **Estatua de Arquitecto** (`estatua_arquitecto.tscn` y `estatua_arquitecto_rota.tscn`): figura encapuchada de ~3 u sobre pedestal, manos juntas sosteniendo un orbe; la rota sin cabeza ni orbe, con grieta.
5. **Reja** (`reja.tscn`): puerta de barrotes de metal oxidado para pasos cerrados (solo visual; la colisión la decide cada sala).
6. **Muro roto** (`muro_roto.tscn`): variante del `muro.tscn` con un boquete irregular y sillares sueltos al pie.

Reglas:
- Medidas coherentes con las piezas existentes (muro de 4 u, columna de ~6 u de alto).
- Las piezas son **solo visuales** salvo que se indique: `use_collision = false` por defecto (la sala decide).
- Coste bajo: sin luces activas por defecto, `cast_shadow` desactivado en piezas pequeñas.
- **Muestrario:** colócalas en `sala_kit_gotico.tscn` por parejas (rota a la izquierda, entera a la derecha) con un `ElementoFase` de ejemplo en una pareja (rota = Realidad, entera = Desfase) para ver el cambio al pulsar Q.
- Revisa con capturas (`tools/captura_sala.gd`) en Realidad y en Desfase y describe en «Resultado» qué revisaste.
- `tests/test_kit_gotico.gd`: cada escena nueva carga e instancia sin errores; el brasero no crea luces si `con_luz` es false; la pareja con `ElementoFase` cambia de visibilidad al cambiar de fase.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.

Commit `[antigravity] Kit gótico ampliado (TAREA-015)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

1. **Piezas implementadas en `scenes/mundo/kit_gotico/`:**
   - **Vidriera** ([`vidriera.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/vidriera.tscn) y [`vidriera_rota.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/vidriera_rota.tscn)):
     - Marco de arco apuntado gótico (4 u x 8 u) con `sillares.tres` y `piedra_castillo.tres`.
     - Cristales de colores apagados con `shading_mode = 0` y emisión suave: ámbar, rojo vino y azul pizarra.
     - Versión entera: dibujo completo con rosetón y símbolo de los Arquitectos (círculo con radios).
     - Versión rota: boquete irregular en muro, parteluz quebrado y solo fragmentos triangulares de cristal remanentes.
   - **Barandilla** ([`barandilla.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/barandilla.tscn) y [`barandilla_rota.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/barandilla_rota.tscn)):
     - Balaustrada de piedra de 4 u de longitud con zócalo, postes y balaustres cilíndricos.
     - Versión rota: pasamanos partido con tramo caído, poste derecho quebrado y balaustre volcado sobre el suelo.
   - **Brasero** ([`brasero.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/brasero.tscn), [`brasero_apagado.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/brasero_apagado.tscn) y [`brasero.gd`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/brasero.gd)):
     - Cuenco metálico de metal oxidado sobre pie estilizado.
     - «Llama» falsa sin coste de iluminación (malla unshaded emisiva naranja/amarilla que ondula suavemente por script).
     - `@export var con_luz: bool = false`: `OmniLight3D` desactivada por defecto para no consumir presupuesto de renderizado.
     - Versión apagada con lecho de cenizas frías.
   - **Estatua de Arquitecto** ([`estatua_arquitecto.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/estatua_arquitecto.tscn) y [`estatua_arquitecto_rota.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/estatua_arquitecto_rota.tscn)):
     - Figura de ~3 u sobre pedestal de sillares.
     - Versión entera: túnica, manto, capucha en sombra y manos sosteniendo un orbe luminoso suave.
     - Versión rota: pedestal agrietado, torso truncado en diagonal sin cabeza ni orbe.
   - **Reja** ([`reja.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/reja.tscn)):
     - Puerta ornamental de barrotes de metal oxidado con puntas de lanza superiores y cerrojo central (`use_collision = false` por defecto).
   - **Muro roto** ([`muro_roto.tscn`](file:///d:/UMBRAL/scenes/mundo/kit_gotico/muro_roto.tscn)):
     - Muro de 4 u x 6 u con cornisa fracturada, boquete irregular pasante y sillares caídos al pie.

2. **Muestrario interactivo ([`sala_kit_gotico.tscn`](file:///d:/UMBRAL/scenes/niveles/pruebas/sala_kit_gotico.tscn)):**
   - Sala de prueba con suelo de monasterio, luz direccional, cámara lateral y Nereth con HUD completo.
   - Piezas alineadas por parejas (rota a la izquierda, entera a la derecha).
   - Pareja central de estatua configurada con `ElementoFase`:
     - `EstatuaRealidad` (rota, `existe_en = REALIDAD`)
     - `EstatuaDesfase` (entera con orbe, `existe_en = DESFASE`)
     - Al alternar fase con la tecla Q (o botón de Desfase), se aprecia la transición visual inmediata entre la versión rota y la versión intacta.

3. **Pruebas automáticas ([`tests/test_kit_gotico.gd`](file:///d:/UMBRAL/tests/test_kit_gotico.gd)):**
   - 29 comprobaciones unitarias superadas:
     - Carga e instanciación correcta de las 10 piezas del kit y de la sala de prueba.
     - Brasero con luz apagada por defecto (`con_luz = false`) y activación limpia al configurarse `con_luz = true`.
     - Alternancia de existencia y visibilidad con `ElementoFase` al cambiar entre Realidad y Desfase.

4. **Verificación:**
   - `tools/comprobar.ps1` ejecutado con éxito (23 pruebas automáticas superadas con 0 fallos).

## Revisión (Claude, 2026-11-02) — ACEPTADO

Revisado con capturas en Realidad y Desfase: vidriera entera con el símbolo de los Arquitectos y rota con fragmentos, barandillas, braseros con llama falsa sin luz, estatua que pasa de rota a entera con el orbe al cambiar de fase, reja de metal oxidado y muro con boquete real (CSG). Dentro de los archivos permitidos. Las 23 pruebas pasan. Para cuando se usen en salas reales: fondo detrás de los vanos (vidriera rota, boquete) para que no se vea el vacío negro.
