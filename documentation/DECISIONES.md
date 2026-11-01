# Registro de decisiones

Estados: **CONFIRMADO** (director) · **PROPUESTA** (adoptada provisionalmente por Claude bajo el acuerdo de alta autonomía; revisable) · **REVERTIDA**.

| ID | Fecha | Decisión | Motivo | Estado |
|---|---|---|---|---|
| D-001 | 2026-10-31 | Godot 4.7.2, GDScript tipado, PC Windows | Contexto maestro | CONFIRMADO |
| D-002 | 2026-10-31 | Renderizador Compatibility | GPU Intel UHD 610 | CONFIRMADO |
| D-003 | 2026-10-31 | Proyecto en `D:\UMBRAL`, Git en rama `main` | Contexto maestro | CONFIRMADO |
| D-004 | 2026-10-31 | Alta autonomía: Claude decide e implementa, commits directos en `main`, solo para ante bloqueos | Indicación del director | CONFIRMADO |
| D-005 | 2026-10-31 | Claude es programador principal; ChatGPT y Antigravity son ayudantes que trabajan por encargos (`documentation/tareas/`) | Indicación del director | CONFIRMADO |
| D-006 | 2026-10-31 | 2.5D = mundo 3D con movimiento sobre el plano X/Y (Z fijo) y cambios de profundidad solo en puntos marcados | Lectura clara del combate, producción viable | PROPUESTA |
| D-007 | 2026-10-31 | Resonancia con dos regímenes (Calma / Amenaza) | La exploración no debe ser una carrera contra el recurso | PROPUESTA |
| D-008 | 2026-10-31 | Costura en tres usos: Puntada (temporal), Remiendo (permanente), Desgarro (combate) | Pedido del director: no todas iguales | PROPUESTA |
| D-009 | 2026-10-31 | Seis habilidades de exploración (Paso Intervalo, Agarre de Grieta, Hilo Tensor, Huella, Caída de Ruptura, Travesía de Ceniza); Desfase y Costura son poderes base | Ver GAMEPLAY §7.3 | PROPUESTA |
| D-010 | 2026-10-31 | Prioridad de producción: vertical slice de Elyndor | Indicación del director | CONFIRMADO |
| D-011 | 2026-10-31 | Muerte sin pérdida de moneda; se pierden ecos no registrados | Castigo suave ligado a las Anclas | PROPUESTA |
| D-012 | 2026-10-31 | Sin addons ni assets de terceros por ahora | Contexto maestro: no dependencias innecesarias | CONFIRMADO |
| D-013 | 2026-11-01 | Coordinación con Antigravity por `comunicacion/CANAL.md`; Claude puede hacer push de `main` tras cada commit verificado | Indicación del director: trabajar sin él | CONFIRMADO |
| D-014 | 2026-11-01 | Ataques como recursos `.tres` (`DatosAtaque`/`DatosArma`); componentes reutilizables de vida, postura y resistencia | Las 4 familias de armas y los enemigos comparten el mismo sistema | PROPUESTA |
| D-015 | 2026-11-01 | Golpear a un enemigo en Ruptura produce automáticamente el Golpe de Umbral (×2,5) | Simple de leer; sin botón extra | PROPUESTA |
| D-016 | 2026-11-01 | La esquiva pulsada durante un ataque se guarda 0,15 s y sale al abrirse la ventana de cancelación | Respuesta de control: no se pierden pulsaciones | PROPUESTA |
| D-017 | 2026-11-01 | El director pide modelos 3D y acabado visual "mínimo AAA". El código separa lógica y apariencia (nodo `Visual`) para sustituir las cápsulas por modelos sin tocar sistemas. Falta decidir: GPU dedicada + renderizador Forward+ para el acabado final, y origen de modelos/animaciones | Una UHD 610 con Compatibility no puede mostrar ni editar arte de nivel AAA | PENDIENTE (director) |
| D-019 | 2026-11-01 | Estabilizar un Ancla también descansa en ella; al morir se reaparece en el último Ancla con todo restaurado (sin pérdida de recursos de momento) | Simple y coherente con D-011 | PROPUESTA |
| D-020 | 2026-11-01 | Guardado en JSON legible (`user://partida.json`) con número de versión | Fácil de depurar y de migrar | PROPUESTA |
| D-018 | 2026-11-01 | Desfase por capas de física (comunes 1, Realidad 2, Desfase 3); `GestorFase.global()` como acceso estático | Barato y robusto; funciona también en pruebas `-s` | PROPUESTA |
