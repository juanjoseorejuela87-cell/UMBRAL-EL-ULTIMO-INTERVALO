# Estado del proyecto

**Etapa actual:** Fase 1 — Vertical slice de Elyndor **jugable de principio a fin** (título → Barrio → Salón del Prefecto → fin de la demo). Siguiente hito: 11 (audio base); el 10 espera las partículas de Antigravity. La demo se puede jugar con `builds/windows/UMBRAL.exe`.
**Objetivo inmediato:** vertical slice de Elyndor (ver `GAMEPLAY.md` §11).

## Hoja de ruta

| # | Hito | Estado |
|---|---|---|
| 0 | Estructura del proyecto y documentación base | Hecho |
| 1 | Movimiento de Nereth, cámara y sala de pruebas | Hecho — prueba `tests/test_movimiento.gd` (9/9) |
| 2 | Combate base contra un muñeco de práctica | Hecho — `tests/test_combate.gd` (17/17). Parry y guardia: con el primer enemigo que ataque (hito 6) |
| 3 | Sistema de Desfase | Hecho — `tests/test_desfase.gd` (28/28): estados, Resonancia Calma/Amenaza, Rechazo, Desfase preciso, sala de pruebas |
| 4 | Ancla de Continuidad y guardado | Hecho — `tests/test_ancla.gd` (22/22): estabilizar, descansar, reinicio de zona, reaparición, guardado JSON |
| 5 | Costura (Puntada, Remiendo, Desgarro) | Hecho Puntada y Remiendo — `tests/test_costura.gd` (17/17). Desgarro pasa al hito 6 (necesita enemigos con Hilos) |
| 6 | Arquetipos: corpóreo, eco, bifásico + Desgarro + guardia/parry | Hecho — `tests/test_enemigos.gd` (29/29): Vigía Hueco, Eco Rezagado, Guardián Partido |
| 7 | El Prefecto de las Puertas | Hecho — `tests/test_prefecto.gd` (24/24): 3 fases, travesía entre puertas, trampa cosida, Cierre, derrota persistente |
| 8 | Salas de Elyndor + transiciones + cierre de la demo | Hecho — transiciones (8/8), Barrio (Antigravity), Salón del Prefecto, Fragmento, título y fin de la demo (`tests/test_demo.gd`, 16/16) |
| 9 | Ejecutable de Windows de la demo | Hecho — `tools/exportar.ps1` genera `builds/windows/UMBRAL.exe` (≈104 MB, todo incluido); arranque verificado |
| 10 | Sensación de combate: parada de impacto, temblor de cámara, partículas | Núcleo hecho — autoload `Impactos` (`tests/test_impactos.gd`, 9/9); partículas: TAREA-008 (Antigravity) |
| 11 | Audio base (efectos provisionales y ambiente) | Pendiente |

## Encargos a ayudantes

| Encargo | Ayudante | Estado |
|---|---|---|
| [TAREA-001](tareas/TAREA-001-textos-elyndor.md) | ChatGPT | ABIERTO |
| [TAREA-002](tareas/TAREA-002-hud-depuracion.md) | Antigravity | ACEPTADO |
| [TAREA-003](tareas/TAREA-003-hud-juego.md) | Antigravity | ACEPTADO |
| [TAREA-004](tareas/TAREA-004-hud-desfase.md) | Antigravity | ACEPTADO |
| [TAREA-005](tareas/TAREA-005-greybox-elyndor.md) | Antigravity | ACEPTADO |
| [TAREA-006](tareas/TAREA-006-conexion-barrio-salon.md) | Antigravity | ACEPTADO |
| [TAREA-007](tareas/TAREA-007-menu-pausa.md) | Antigravity | ACEPTADO |
| [TAREA-008](tareas/TAREA-008-efecto-impacto.md) | Antigravity | ABIERTO |

## Notas técnicas

- Controles (teclado): A/D o flechas mover, Espacio saltar, Shift o L esquivar, J o clic izquierdo ataque ligero, K o clic derecho ataque pesado (mantener para cargar), E interactuar. Mando: stick izquierdo/cruceta, A saltar, B esquivar, X ligero, RB pesado, Y interactuar.
- Arranque: `main.tscn` → pantalla de título (`scenes/ui/titulo/`): Continuar (último Ancla), Nueva partida (borra `user://partida.json`, pide confirmación) y Salir. La salida del Salón del Prefecto lleva a `scenes/ui/fin_demo/`.
- Salas: autoload `Salas` (`GestorSalas.global()`), `PuntoEntrada` y `TransicionSala` en `scripts/core/mundo/`.
- Desfase: Q / I o LB. Autoload `Fase` (`GestorFase`); en código usar `GestorFase.global()`. Geometría de cada estado en capa 2 (Realidad) o 3 (Desfase) mediante un nodo hijo `ElementoFase`; Nereth solo cambia su `collision_mask`. Las cajas CSG con `ElementoFase` reciben automáticamente una colisión convexa.
- Costura: F / O o gatillo derecho (mantener, desde el Desfase). `ElementoCosible` (hijo `Node3D` de un elemento con `ElementoFase`): Puntada (`tipo = 0`, temporal, 25 de Resonancia, una activa) o Remiendo (`tipo = 1`, permanente, `id` + `ancla_requerida`, se guarda en `Partida.remiendos`).
- Impactos: autoload `Impactos` (`DirectorImpactos.global()`): `golpe()`, `parry()`, `herida()`, `sacudir()`. La parada de impacto se desactiva sin pantalla; `CamaraLateral.escala_temblor = 0` quita el temblor (accesibilidad).
- Defensa: U / C o gatillo izquierdo = guardia (los primeros 0,15 s son parry). La guardia no cubre la espalda; sin resistencia se rompe.
- Enemigos: `scripts/core/enemigos/enemigo.gd` (`Enemigo`) + escenas en `scenes/enemigos/`. `existe_en` (0 Realidad, 1 Desfase, 2 ambos), `peso` (0 ligero, 1 medio, 2 pesado), `ia_activa` (false = presente pero quieto), ataques como `DatosAtaque` (`parable`, `bloqueable`, `fuerza`). Entran en el grupo `reinicio_descanso`.
- Anclas: escena `scenes/mundo/ancla/ancla.tscn` (`AnclaContinuidad`, `id` único obligatorio). Autoload `Partida` (`GestorPartida.global()`) guarda en `user://partida.json`. Los nodos del grupo `reinicio_descanso` reciben `reiniciar()` al descansar o reaparecer.
- Combate: ataques definidos como recursos (`DatosAtaque`) agrupados por arma (`DatosArma`) en `scenes/jugador/armas/`. Capas de física 6 (`dano_enemigo`) y 7 (`dano_jugador`) para cajas de golpe/daño.
- Pendiente para más adelante: plataformas atravesables desde abajo (Godot 3D no tiene colisión de un sentido; requiere solución propia).
- Pruebas automáticas: `Godot_console.exe --headless --path D:\UMBRAL -s res://tests/<prueba>.gd` (código de salida = fallos).

## Pendiente del director

- Historia oficial para `LORE.md` (opcional: si llega, sustituye a las propuestas).
- **Objetivo visual AAA con modelos 3D** (pedido el 2026-11-01): requiere decidir hardware/renderizador y canal de producción de arte. Ver D-017.
