# TAREA-015 — Kit gótico ampliado (piezas Realidad/Desfase)

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
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

_(lo rellena Antigravity)_
