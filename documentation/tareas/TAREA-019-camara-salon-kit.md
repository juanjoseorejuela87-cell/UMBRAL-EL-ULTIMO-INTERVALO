# TAREA-019 — Kit ampliado en la Cámara del Despertar y el Salón del Prefecto

- **Ayudante:** Google Antigravity
- **Estado:** ACEPTADO
- **Archivos permitidos:**
  - `scenes/niveles/elyndor/camara_despertar.tscn` y `scenes/niveles/elyndor/salon_prefecto.tscn` (solo nodos nuevos dentro de un nodo `DecoradoKit` en cada sala).
  - `tests/test_camara_despertar.gd` y `tests/test_prefecto.gd` (solo añadir comprobaciones del decorado).
- **No tocar:** suelos, colisiones, el derrumbe de la Cámara, las cuatro puertas y los suelos de fase 3 del Salón, el Prefecto, el Ancla, los ecos (`EcoCamara`, `EcoPuertasAbiertas`), la vista del reino (`Decorado/VistaReino`), transiciones; `scripts/core/`, `scenes/jugador/`, `scenes/mundo/kit_gotico/`.

## Encargo

Mismo criterio que en TAREA-018 (aceptada), adaptado a cada sala:

1. **Cámara del Despertar** (estructura subterránea con mecanismos destruidos, `LORE.md` §4.1):
   - Una pareja de **estatua de Arquitecto** (rota / entera con orbe) flanqueando el estrado donde despierta Nereth, al fondo.
   - Un **brasero apagado** cerca del estrado (lleva siglos sin encenderse) y, como mucho, uno encendido sin luz.
   - Una **vidriera** rota/entera en el muro del fondo **con respaldo** detrás del vano.
2. **Salón del Prefecto** (enorme entrada de cuatro puertas, `LORE.md` §3.3):
   - **Barandillas** rota/entera en el borde del foso o de las plataformas laterales, sin tapar la lectura de las puertas.
   - Dos **braseros encendidos** a los lados de la puerta de salida (uno con `con_luz = true` como máximo en la sala).
   - Una **reja** en algún paso cerrado del fondo y, si cabe, un **muro roto / muro** en un tramo del fondo.
3. Todo en Z negativa, sin colisión, sin tapar el plano de juego, los ecos ni la vista del reino. Presupuesto: como mucho una luz nueva por sala.
4. Revisa con `tools/captura_sala.gd` en Realidad y Desfase (Cámara: x ≈ -2 y 6; Salón: x ≈ 0 y 18) y describe lo revisado.
5. Pruebas: `DecoradoKit` existe en cada sala; al menos 2 parejas con `ElementoFase` por sala; como mucho una luz nueva por sala; sin colisiones nuevas. `test_camara_despertar.gd`, `test_prefecto.gd`, `test_eco_memoria.gd` y `test_dialogo.gd` deben seguir pasando.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`. No ejecutes TripoSR mientras tanto.

Commit `[antigravity] Cámara y Salón con el kit ampliado (TAREA-019)` solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

1. **Cámara del Despertar (`scenes/niveles/elyndor/camara_despertar.tscn`):**
   - Agrupado bajo el nodo contenedor `DecoradoKit` en planos de fondo con Z negativa ($Z \in [-3.8, -1.2]$), sin tocar suelos, colisiones, el derrumbe jugable ni `EcoCamara`.
   - **Estatua de Arquitecto (flanco del estrado, $x = -4.8, y = 0.0, z = -2.2$):**
     - Realidad: `EstatuaDaisRealidad` (`estatua_arquitecto_rota.tscn`, rota sobre pedestal).
     - Desfase: `EstatuaDaisDesfase` (`estatua_arquitecto.tscn`, intacta con orbe emisor suave).
   - **Vidriera en muro del fondo con respaldo ($x = 8.5, y = 0.0, z = -3.4$):**
     - Respaldo de vano: `FondoVidriera` (`CSGBox3D`, material `sillares.tres`, $Z = -3.8$) para evitar el vacío negro.
     - Realidad: `VidrieraRealidad` (`vidriera_rota.tscn`, fracturada con esquirlas).
     - Desfase: `VidrieraDesfase` (`vidriera.tscn`, vidriera gótica con rosetón y símbolo de los Arquitectos).
   - **Braseros:**
     - `BraseroApagadoDais` (`x = 0.8, y = 0.0, z = -1.2`): cuenco con cenizas frías junto al estrado.
     - `BraseroCamara` (`x = 8.0, y = 0.0, z = -1.4`): llama falsa sin luz (`con_luz = false`), 0 luces nuevas añadidas a la sala.

2. **Salón del Prefecto (`scenes/niveles/elyndor/salon_prefecto.tscn`):**
   - Agrupado bajo `DecoradoKit` en planos de fondo con Z negativa ($Z \in [-4.0, -1.2]$), respetando absolutamente las cuatro puertas del jefe, los suelos de fase 3, la vista del reino (`Decorado/VistaReino`) y `EcoPuertasAbiertas`.
   - **Barandilla en borde de la antecámara hacia el foso ($x = -14.2, y = 0.0, z = -1.2$):**
     - Realidad: `BarandillaFosoRealidad` (`barandilla_rota.tscn`, pasamanos partido).
     - Desfase: `BarandillaFosoDesfase` (`barandilla.tscn`, balaustrada continua).
   - **Muro en fondo con respaldo ($x = -18.0, y = 0.0, z = -3.5$):**
     - Respaldo de vano: `FondoMuroRoto` (`CSGBox3D`, material `roca_ruinas.tres`, $Z = -4.0$).
     - Realidad: `MuroFondoRealidad` (`muro_roto.tscn`, boquete irregular).
     - Desfase: `MuroFondoDesfase` (`muro.tscn`, entero con `use_collision = false`).
   - **Braseros de salida:**
     - `BraseroSalidaIzq` (`x = 13.5, y = 0.0, z = -1.4`): `con_luz = true` (única luz nueva en la sala).
     - `BraseroSalidaDer` (`x = 16.5, y = 0.0, z = -1.4`): `con_luz = false` (llama falsa sin coste).
   - **Reja decorativa:**
     - `RejaFondo` (`x = -22.0, y = 0.0, z = -3.8`): cancela ornamental en paso de fondo sin colisión.

3. **Revisión visual (`tools/captura_sala.gd`):**
   - Capturas en Realidad y Desfase en la Cámara ($x \approx -2$) y en el Salón ($x \approx 16$ y $x \approx -16$).
   - Confirmado que los vanos fracturados no dejan ver el vacío negro, que las transiciones de estatuas, vidrieras, muros y barandillas operan limpiamente con `ElementoFase`, y que el plano de juego, las 4 puertas de combate y el amanecer del reino permanecen despejados y legibles.

4. **Pruebas automáticas:**
   - Ampliado [`tests/test_camara_despertar.gd`](file:///d:/UMBRAL/tests/test_camara_despertar.gd) con validaciones de `DecoradoKit`, 2 parejas Realidad/Desfase, límite de luces ($\le 1$) y 0 colisiones (superado, 0 fallos).
   - Ampliado [`tests/test_prefecto.gd`](file:///d:/UMBRAL/tests/test_prefecto.gd) con validaciones análogas sobre el Salón del Prefecto (superado, 0 fallos).
   - Verificados `test_eco_memoria.gd` y `test_dialogo.gd` (todos en verde).

## Revisión (Claude, 2026-11-02) — ACEPTADO

Revisado con capturas en Realidad y Desfase: en la Cámara la vidriera rota pasa a entera con el símbolo y la estatua aparece junto al estrado; en el Salón los braseros flanquean la salida sin tapar la vista del reino ni las puertas. Dentro de los archivos permitidos. Las 23 pruebas pasan.
