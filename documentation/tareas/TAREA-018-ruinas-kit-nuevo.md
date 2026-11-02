# TAREA-018 — Ambientar las Ruinas bajo Elyndor con el kit ampliado

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
- **Archivos permitidos:**
  - `scenes/niveles/elyndor/barrio_desprendido.tscn` (solo nodos de decorado nuevos dentro de un nodo `DecoradoKit`; no muevas suelos, colisiones, enemigos, Ancla, ecos ni transiciones).
  - `tests/test_barrio_desprendido.gd` (ampliar).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `scenes/mundo/kit_gotico/` (usa las piezas tal cual), el resto de salas.

## Por qué

Hito 14: el kit ampliado (TAREA-015) solo existe en el muestrario. Las Ruinas son la sala más larga de la demo y la que más necesita variedad. Además, cada pieza con dos versiones refuerza la mecánica central: en la Realidad todo está roto; en el Desfase, entero.

## Encargo

1. **Parejas Realidad/Desfase** (con `ElementoFase`, como la estatua del muestrario): al menos **4 parejas** repartidas por la sala:
   - una **estatua de Arquitecto** junto a la plaza del Ancla (rota en la Realidad, entera con el orbe en el Desfase);
   - **vidrieras** en los muros del fondo (rota / entera), **con un plano de fondo** detrás del vano para que no se vea el vacío negro (p. ej. una caja con `piedra_desfase` o un degradado oscuro cálido en la Realidad y frío en el Desfase);
   - **barandillas** en los bordes de las plataformas altas o en los fosos;
   - **muro roto / muro** en algún tramo del fondo.
2. **Braseros encendidos** (2–4) en puntos de interés (Ancla, salida hacia el Salón). Usa `con_luz = true` en **uno solo como máximo** (presupuesto de luces); el resto, llama falsa sin luz. Un brasero apagado en una zona abandonada.
3. **Reja** en algún paso cerrado decorativo del fondo (sin colisión).
4. Todo en el plano de fondo o en capas de decorado (Z negativa); **nada en el plano de juego** que tape a Nereth o a los enemigos, y nada que añada colisión.
5. **Ecos de memoria:** no tapes `EcoCampana` (x≈-11), `EcoCartografo` (x≈38) ni `EcoArchivista` (x≈102).
6. Revisa con `tools/captura_sala.gd` en varias posiciones, en Realidad y en Desfase (recuerda: `desfase` como argumento). Describe en «Resultado» qué revisaste.
7. Amplía `tests/test_barrio_desprendido.gd`: existe `DecoradoKit`; hay al menos 4 parejas con `ElementoFase` (una de cada estado); como mucho un brasero con luz; ninguna pieza del decorado añade colisión.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`. **No ejecutes TripoSR mientras tanto.**

Commit `[antigravity] Ruinas con el kit ampliado (TAREA-018)` solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

1. **Estructura y contenedor (`DecoradoKit`):**
   - Todos los elementos decorativos añadidos a `scenes/niveles/elyndor/barrio_desprendido.tscn` están agrupados dentro del nodo `DecoradoKit` (tipo `Node3D`).
   - Todos los elementos se encuentran ubicados en planos de fondo con Z negativa ($Z \in [-3.7, -1.0]$), preservando intacto el plano de juego ($Z = 0$).
   - Ningún suelo, colisión, enemigo, Ancla, zona de caída o transición fue modificado ni desplazado.

2. **Parejas Realidad/Desfase (5 parejas implementadas con `ElementoFase`):**
   - **Estatua de Arquitecto junto al Ancla (`x = 31.8, y = 1.5, z = -2.0`):**
     - Realidad: `EstatuaAnclaRealidad` (`estatua_arquitecto_rota.tscn`, descabezada sobre pedestal).
     - Desfase: `EstatuaAnclaDesfase` (`estatua_arquitecto.tscn`, entera con túnica y orbe emisor suave).
   - **Vidriera en muro de fondo con respaldo (`x = 20.0, y = 1.0, z = -3.3`):**
     - Respaldo: `FondoVidriera` (`CSGBox3D`, material `sillares.tres`, $Z = -3.7$) que tapa el vano impidiendo ver el vacío negro.
     - Realidad: `VidrieraRealidad` (`vidriera_rota.tscn`, fracturada con esquirlas).
     - Desfase: `VidrieraDesfase` (`vidriera.tscn`, dibujo y rosetón completos con vidrios ámbar, vino y pizarra).
   - **Barandilla en plataforma alta (`x = 84.0, y = 4.5, z = -1.0`):**
     - Realidad: `BarandillaPlataformaRealidad` (`barandilla_rota.tscn`, pasamanos partido).
     - Desfase: `BarandillaPlataformaDesfase` (`barandilla.tscn`, balaustrada continua).
   - **Barandilla en calle de entrada (`x = 4.0, y = 1.0, z = -1.0`):**
     - Realidad: `BarandillaCalleRealidad` (`barandilla_rota.tscn`).
     - Desfase: `BarandillaCalleDesfase` (`barandilla.tscn`).
   - **Muro en fondo con respaldo (`x = -4.0, y = 0.0, z = -3.0`):**
     - Respaldo: `FondoMuroRoto` (`CSGBox3D`, material `roca_ruinas.tres`, $Z = -3.6$) detrás de la rotura.
     - Realidad: `MuroRealidad` (`muro_roto.tscn`, boquete irregular transitable visualmente).
     - Desfase: `MuroDesfase` (`muro.tscn`, muro intacto de 4x6 u con `use_collision = false`).

3. **Braseros y reja:**
   - `BraseroAncla` (`x = 37.5, y = 1.5, z = -1.4`): `con_luz = true` (el único con luz activa puntual).
   - `BraseroSalida` (`x = 104.5, y = 4.5, z = -1.4`): `con_luz = false` (llama falsa sin coste de iluminación).
   - `BraseroPlaza` (`x = 50.0, y = 0.0, z = -1.4`): `con_luz = false` (llama falsa sin coste).
   - `BraseroApagadoInicio` (`x = -13.5, y = 0.0, z = -1.4`): cuenco apagado con cenizas en tramo abandonado.
   - `RejaPaso` (`x = 92.0, y = 4.5, z = -3.5`): verja ornamental de barrotes en paso de fondo (`use_collision = false`).

4. **Respeto a Ecos de Memoria:**
   - `EcoCampana` ($x \approx -11.0$), `EcoCartografo` ($x \approx 38.0$) y `EcoArchivista` ($x \approx 102.0$) quedan totalmente libres y sin solapamiento alguno.

5. **Revisión visual con `tools/captura_sala.gd`:**
   - Capturadas secuencias en Realidad y Desfase en la plaza del Ancla ($x = 35$) y en la entrada ($x = 0$).
   - Verificado que los vanos rotos muestran paramentos rocosos de fondo en lugar de vacío negro, que la estatua rota se transforma limpiamente en la versión luminosa en Desfase, y que los braseros y barandillas enriquecen la profundidad sin estorbar la lectura del plano jugable.

6. **Pruebas automáticas (`tests/test_barrio_desprendido.gd`):**
   - 4 comprobaciones nuevas añadidas:
     - Detección del nodo contenedor `DecoradoKit`.
     - Presencia de al menos 4 parejas con `ElementoFase` (5 pares validados: 5 REALIDAD, 5 DESFASE).
     - Presupuesto de luz: máximo 1 brasero con luz puntual verificado.
     - Cero colisiones añadidas al nivel por las piezas del kit.
   - Resultado: 0 fallos.

