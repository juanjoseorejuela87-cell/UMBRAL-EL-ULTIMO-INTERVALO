# TAREA-005 — Greybox del primer tramo de Elyndor: «Barrio Desprendido»

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
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

_(Rellenar al entregar.)_
