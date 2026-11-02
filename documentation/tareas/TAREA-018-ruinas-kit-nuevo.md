# TAREA-018 — Ambientar las Ruinas bajo Elyndor con el kit ampliado

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
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

_(lo rellena Antigravity)_
