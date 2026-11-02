# TAREA-019 — Kit ampliado en la Cámara del Despertar y el Salón del Prefecto

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
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

_(lo rellena Antigravity)_
