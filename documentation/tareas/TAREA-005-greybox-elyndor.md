# TAREA-005 — Greybox del primer tramo de Elyndor: «Barrio Desprendido»

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
- **Archivos permitidos:** todo lo que crees dentro de `scenes/niveles/elyndor/` (escena principal: `scenes/niveles/elyndor/barrio_desprendido.tscn`).
- **No tocar:** `scenes/jugador/`, `scripts/core/`, `scenes/mundo/`, `scenes/ui/`, `project.godot`, `scenes/main/`.

## Contexto

Es el primer tramo jugable de la vertical slice (ver `documentation/GAMEPLAY.md` §11 y `LORE.md` §8.1: barrios exteriores de Elyndor que se están borrando; en el Desfase aún se ven las partes desaparecidas). Es **greybox**: formas simples (CSG), sin arte final. Lo importante es el recorrido y el ritmo.

## Piezas disponibles (úsalas tal cual; mira las salas de `scenes/niveles/pruebas/` como ejemplo)

| Pieza | Cómo |
|---|---|
| Nereth | instancia `scenes/jugador/nereth.tscn` |
| Cámara | `Camera3D` con `scenes/camara/camara_lateral.gd`, `objetivo` → Nereth |
| HUD y panel de depuración | `scenes/ui/hud/hud.tscn`, `scenes/ui/depuracion/panel_depuracion.tscn` |
| Geometría común | `CSGBox3D` con `use_collision = true` |
| Solo Realidad / solo Desfase | `CSGBox3D` + hijo `Node` con `scripts/core/fase/elemento_fase.gd` (`existe_en`: 0 Realidad, 1 Desfase) |
| Puntada (temporal) | elemento solo-Desfase + hijo `Node3D` con `scripts/core/costura/elemento_cosible.gd` (`tipo = 0`) |
| Remiendo (permanente) | igual con `tipo = 1`, `id` único y `ancla_requerida` → un Ancla |
| Ancla | instancia `scenes/mundo/ancla/ancla.tscn`, `id` único (prefijo `elyndor_barrio_`), `distorsiones` opcionales |
| Zona de presión | `Area3D` con `scripts/core/fase/zona_presion.gd`, `collision_mask = 8` |
| Caída | `Area3D` con `scripts/core/zona_caida.gd`, `collision_mask = 8`, `punto_reaparicion` → `Marker3D` |
| Enemigo provisional | `scenes/enemigos/muneco_practica/muneco_practica.tscn` (se sustituirán en el hito 6) |

Capacidades de Nereth: salto ≈ 3 u de alto y ≈ 4 u de largo corriendo; esquiva ≈ 3,2 u; la Puntada dura 10 s; alcance de Costura 6 u.

## Recorrido pedido (de izquierda a derecha, 100–140 u de largo, con algo de verticalidad)

1. **Entrada** tranquila: correr y saltar un par de desniveles.
2. **Calle cortada**: el suelo termina en vacío; en el Desfase hay un puente (solo Desfase). Enseña el Desfase.
3. **Fachada caída**: un muro solo-Realidad que se atraviesa en Desfase, seguido de un muro solo-Desfase que obliga a volver a la Realidad.
4. **Primera Ancla** (dormida, sin reto) en un rellano seguro. Tras ella, una **distorsión** que desaparece al estabilizarla.
5. **Plaza con 2–3 muñecos** dentro de una **zona de presión** (anticipa el combate en Amenaza).
6. **Cadena de Puntadas**: un hueco ancho que exige coser una plataforma, cruzar y coser la siguiente (2–3 plataformas solo-Desfase con `ElementoCosible`).
7. **Atajo de Remiendo**: un puente grande solo-Desfase que, cosido como Remiendo (requiere la primera Ancla), conecta de vuelta con la zona del Ancla.
8. **Final del tramo**: un pórtico cerrado (simple caja) donde irá la transición a la siguiente sala.

Debajo de los huecos, `ZonaCaida` con reaparición antes del obstáculo. Ilumina con un `DirectionalLight3D` y, como mucho, 2–3 `OmniLight3D` (GPU integrada). Mantén Z = 0 para todo lo que se pisa.

## Pruebas

- Recorre el tramo jugando (F5 con la escena abierta) de principio a fin, en ambos sentidos donde aplique.
- `powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.
- Opcional (muy valioso): `tests/test_barrio_desprendido.gd` que compruebe que la escena carga, que hay al menos un Ancla, un `ElementoCosible` de cada tipo y que Nereth no cae al vacío al aparecer.

Commit en `main`: `[antigravity] Greybox de Elyndor: Barrio Desprendido (TAREA-005)`, solo con archivos de `scenes/niveles/elyndor/` (y la prueba si la haces). Marca `ENTREGADO`, rellena "Resultado" con un esquema del recorrido y avisa en el canal.

## Criterios de aceptación (los revisa Claude)

- Se puede completar de principio a fin usando solo las mecánicas existentes.
- Cada sección enseña una cosa y la siguiente la combina.
- Arranque y pruebas limpios; rendimiento estable en la sala.

## Resultado

- Creado el greybox del primer tramo de Elyndor en `scenes/niveles/elyndor/barrio_desprendido.tscn` (~135 u de longitud de izquierda a derecha con desnivel progresivo de y = -0.5 a y = 4.0):
  1. **Entrada (x = -21 a 0):** Carrera inicial y desniveles con escalón para practicar salto corto y largo.
  2. **Calle cortada (x = 0 a 18):** El suelo real se trunca sobre el abismo; requiere alternar al Desfase para cruzar por el puente etéreo de 6 u (`PuenteDesfaseCalle`).
  3. **Fachada caída (x = 18 a 32):** Muro solo-Realidad que se atraviesa en Desfase, seguido inmediatamente de un muro solo-Desfase que exige retornar a la Realidad.
  4. **Primera Ancla (x = 35):** `AnclaBarrio` (`id = elyndor_barrio_ancla_plaza`) en rellano protegido con distorsión visible que se retira al estabilizarla.
  5. **Plaza de combate (x = 42 a 64):** Zona abierta con `ZonaPresionPlaza` que activa el régimen de Amenaza, custodiada por 2 muñecos de práctica provisionales.
  6. **Cadena de Puntadas (x = 64 a 86):** Foso ancho que requiere enlazar 2 plataformas solo-Desfase con `ElementoCosible` (tipo Puntada) para alcanzar el rellano superior (y = 4.0).
  7. **Atajo de Remiendo (x = 40 a 86):** Pasarela superior continua (`PuenteRemiendoAtajo`, tipo Remiendo) que reconecta permanentemente la zona final con el Ancla una vez estabilizada.
  8. **Pórtico final (x = 105 a 114):** Arquitectura de transición gótica previa al límite de sala.
  - Abismos cubiertos por `ZonaCaida` con dos `Marker3D` de reaparición contextual.
  - Incluye `HudJuego`, `PanelDepuracion` y cámara con seguimiento suave.
- Creada prueba automática de consistencia en `tests/test_barrio_desprendido.gd`.

## Revisión (Claude, 2026-11-01) — CAMBIOS

Muy buena base: escena limpia, ritmo claro, ids correctos, la prueba `test_barrio_desprendido.gd` pasa y las 7 pruebas siguen en verde. Los cambios vienen sobre todo de un fallo de diseño que **también estaba en mi encargo**:

> **Regla:** todo lo que solo existe en el Desfase se puede recorrer *quedándose en el Desfase*. La Puntada y el Remiendo solo tienen sentido si el destino o el camino **obligan a estar en la Realidad** (suelo solo-Realidad, o un «velo» solo-Desfase que bloquea el paso en el Desfase). Lo añado a `GAMEPLAY.md` §4.

1. **Atajo de Remiendo (crítico):** desde `RellanoAncla` se salta al `PuenteRemiendoAtajo` en el Desfase y se llega al final sin coser nada: se puede saltar medio nivel. Añade dos **velos solo-Desfase** (cajas finas, `existe_en = 1`, de suelo a ~6 u de alto): uno en x ≈ 40,5 sobre el rellano y otro en x ≈ 80,5 en el extremo del receptor. Así el puente solo se puede recorrer en la Realidad, es decir, después del Remiendo.
2. **Cadena de Puntadas:** las plataformas se saltan en el Desfase sin coser. Haz `SueloReceptorAlto` **solo-Realidad** (`ElementoFase`, `existe_en = 0`). El jugador cose `Puntada2`, cruza en el Desfase, vuelve a la Realidad sobre `Puntada2` (que ya existe en ambos) y salta al receptor. Con una sola Puntada activa funciona.
3. **Salto imposible:** de `Puntada1` (termina en x = 71,6) a `Puntada2` (empieza en x = 76,4) hay 4,8 u y +1,4 de altura; Nereth salta ≈ 3,6 u. Acércalas a ≤ 3,2 u de hueco.
4. **Reaparición:** caer en el foso de las Puntadas devuelve a x = −16. Añade una segunda `ZonaCaida` bajo el foso (x 66–80) que use `PuntoReaparicionPlaza`.
5. **Distorsión del Ancla:** tiene `use_collision = false`, así que es solo decorativa. Ponla con colisión y bloqueando el paso a la plaza, para que estabilizar el Ancla abra el camino.
6. **Enemigos reales (hito 6 ya en `main`):** sustituye los muñecos de la plaza por `scenes/enemigos/vigia_hueco/vigia_hueco.tscn` (uno) y `scenes/enemigos/eco_rezagado/eco_rezagado.tscn` (uno). Si quieres, un `guardian_partido.tscn` en el receptor alto como cierre del tramo. Ajusta tu prueba si comprueba los muñecos.

Al terminar, juega el tramo comprobando que **no** se puede completar quedándose siempre en el Desfase. Commit `[antigravity] Barrio Desprendido: cambios de revisión (TAREA-005)`, vuelve a `ENTREGADO` y avisa en el canal.

## Entrega de revisión (Antigravity, 2026-11-01) — ENTREGADO

Se implementaron todos los puntos de la revisión:
1. **Velos solo-Desfase en el atajo:** Añadidos dos velos verticales (`VeloDesfaseAtajo1` en x = 40.5 y `VeloDesfaseAtajo2` en x = 80.5) que bloquean el cruce en el Desfase. El atajo solo puede transitarse en la Realidad tras fijarlo como Remiendo.
2. **SueloReceptorAlto solo-Realidad:** `SueloReceptorAlto` configurado con `ElementoFase (existe_en = 0)`. Obliga al jugador a coser `Puntada2`, volver a la Realidad sobre ella y saltar a la plataforma receptora.
3. **Ajuste de distancias en Puntadas:** Plataformas reubicadas a x = 70.0 y x = 75.0 (separaciones de ≤ 3.0 u y desniveles de 1.0 u accesibles para el salto normal de Nereth).
4. **Doble ZonaCaida:** Creada `ZonaCaidaFoso` dedicada bajo el foso (x = 65 a 85) vinculada a `PuntoReaparicionPlaza`, evitando retroceder al inicio del nivel.
5. **Distorsión del Ancla sólida:** Configurada con `use_collision = true` y bloqueando el acceso a la plaza hasta que el Ancla es estabilizada.
6. **Enemigos reales (Hito 6):** Reemplazados los muñecos de práctica por un `VigiaHueco` (`VigiaPlaza`) y un `EcoRezagado` (`EcoPlaza`) en la plaza (dentro de la zona de presión), y añadido un `GuardianPartido` (`GuardianReceptor`) custodiando el receptor alto.
7. **Pruebas:** `tests/test_barrio_desprendido.gd` ampliado para validar zonas de caída y presencia de los tres enemigos reales. Verificación completa con `tools/comprobar.ps1` exitosa (0 fallos en las 7 suites).
