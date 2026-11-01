# Estado del proyecto

**Etapa actual:** Fase 0 — Fundamentos (movimiento, cámara, entrada, sala de pruebas).
**Objetivo inmediato:** vertical slice de Elyndor (ver `GAMEPLAY.md` §11).

## Hoja de ruta

| # | Hito | Estado |
|---|---|---|
| 0 | Estructura del proyecto y documentación base | Hecho |
| 1 | Movimiento de Nereth, cámara y sala de pruebas | Hecho — prueba `tests/test_movimiento.gd` (9/9) |
| 2 | Combate base contra un muñeco de práctica | Siguiente (Claude) |
| 3 | Sistema de Desfase | Pendiente |
| 4 | Ancla de Continuidad y guardado | Pendiente |
| 5 | Costura (Puntada, Remiendo, Desgarro) | Pendiente |
| 6 | Arquetipos: corpóreo, eco, bifásico | Pendiente |
| 7 | El Prefecto de las Puertas | Pendiente |
| 8 | Salas de Elyndor (greybox) | Pendiente |

## Encargos a ayudantes

| Encargo | Ayudante | Estado |
|---|---|---|
| [TAREA-001](tareas/TAREA-001-textos-elyndor.md) | ChatGPT | ABIERTO |
| [TAREA-002](tareas/TAREA-002-hud-depuracion.md) | Antigravity | ACEPTADO |

## Notas técnicas

- Controles (teclado): A/D o flechas mover, Espacio saltar, Shift o L esquivar, E interactuar. Mando: stick izquierdo/cruceta, A saltar, B esquivar, Y interactuar.
- Pendiente para más adelante: plataformas atravesables desde abajo (Godot 3D no tiene colisión de un sentido; requiere solución propia).
- Pruebas automáticas: `Godot_console.exe --headless --path D:\UMBRAL -s res://tests/<prueba>.gd` (código de salida = fallos).

## Pendiente del director

- Historia oficial para `LORE.md` (opcional: si llega, sustituye a las propuestas).
