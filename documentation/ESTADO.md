# Estado del proyecto

**Etapa actual:** Fase 1 — Vertical slice de Elyndor jugable de principio a fin. **Historia oficial integrada** en `LORE.md`. Hitos 12 y 13 completos. En curso: lo que queda del **14** (modelos reales de personajes). La demo se puede jugar con `builds/windows/UMBRAL.exe`.
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
| 10 | Sensación de combate: parada de impacto, temblor de cámara, partículas | Hecho — autoload `Impactos` (`tests/test_impactos.gd`, 10/10) + efecto de impacto (Antigravity, TAREA-008) |
| 11 | Audio base (efectos provisionales y ambiente) | Hecho — autoload `Sonido` con 16 efectos sintetizados y 2 ambientes (`tests/test_sonido.gd`, 15/15); ambiente por sala, interfaz y volúmenes (Antigravity, TAREA-009). Música sintetizada (`CompositorMusica`, `Sonido.musica()` con fundidos, compuesta en segundo plano): exploración de Elyndor (ligada al ambiente de la sala, se compone durante el título) y combate contra el Prefecto |
| 12 | Calidad gráfica escalable: preajustes Bajo–Ultra, Compatibility ↔ Forward+, detección automática y menú de gráficos | Hecho — autoload `Graficos` (`tests/test_graficos.gd`) y sección «Gráficos» en la pausa (Antigravity, TAREA-011) — D-017, D-034. Falta probar el reinicio a Forward+ en un PC con gráfica dedicada |
| 13 | Ajustes narrativos de la demo según el canon (Cámara del Despertar, Ruinas bajo Elyndor, Fragmento de Memoria, frases de Maelis) | Hecho — Cámara del Despertar integrada (inicio del juego, Desfase obligado por un derrumbe; `tests/test_camara_despertar.gd` 7/7); Ruinas reambientadas (Antigravity, TAREA-010); Fragmento de Memoria con recuerdo y frases oficiales de Maelis hecho (`PantallaRecuerdo`). Salón del Prefecto reambientado (arcos apuntados en las 4 puertas, columnas Realidad/Desfase, atmósfera). Ecos de memoria ocultos (A6): `scenes/mundo/eco_memoria/`, visibles solo en el Desfase tras el Fragmento de Memoria; uno en la Cámara y otro en el Salón, con textos provisionales (`tests/test_eco_memoria.gd`, 11/11). Salida del Salón abierta a una vista del reino de Elyndor al amanecer (A5). Ajustes A1–A6 completos; textos de Elyndor generados con Gemini y revisados (TAREA-001): cinco ecos integrados |
| 14 | **Rebanada visual**: una sala con acabado de calidad final (guía de arte, kit gótico detallado, iluminación, niebla, posprocesado y un modelo real de Nereth) como referencia para todo el juego | **En curso (Claude)** — hecho: `GUIA_ARTE.md`, atmósfera por estado (`AtmosferaFase`), kit detallado (columna rota, arco apuntado, ventanal, escombros, símbolos), polvo y rayos de luz baratos, sala de referencia `elyndor/camara_despertar.tscn`. Figura estilizada provisional de Nereth con primitivas y animación procedural (`scenes/jugador/figura_nereth.gd`: capucha, capa por segmentos, espada, carrera/salto/esquiva/ataque/guardia); figuras de los cuatro enemigos (Antigravity, TAREA-012). Diseño oficial de Nereth entregado por el director (D-036). **Nereth jugable con el modelo generado por TripoSR** a partir de su hoja, con esqueleto automático y animación por huesos (D-040). El Prefecto habla con subtítulos (textos de TAREA-001). Falta: modelos definitivos (especificación en `ESPECIFICACION_MODELOS.md`, encargo TAREA-016 para la futura IA de modelado), kit gótico ampliado con vidriera, barandilla, brasero, estatua de Arquitecto, reja y muro roto (TAREA-015, Antigravity) |

## Encargos a ayudantes

| Encargo | Ayudante | Estado |
|---|---|---|
| [TAREA-001](tareas/TAREA-001-textos-elyndor.md) | Claude + Gemini | ACEPTADO |
| [TAREA-002](tareas/TAREA-002-hud-depuracion.md) | Antigravity | ACEPTADO |
| [TAREA-003](tareas/TAREA-003-hud-juego.md) | Antigravity | ACEPTADO |
| [TAREA-004](tareas/TAREA-004-hud-desfase.md) | Antigravity | ACEPTADO |
| [TAREA-005](tareas/TAREA-005-greybox-elyndor.md) | Antigravity | ACEPTADO |
| [TAREA-006](tareas/TAREA-006-conexion-barrio-salon.md) | Antigravity | ACEPTADO |
| [TAREA-007](tareas/TAREA-007-menu-pausa.md) | Antigravity | ACEPTADO |
| [TAREA-008](tareas/TAREA-008-efecto-impacto.md) | Antigravity | ACEPTADO |
| [TAREA-009](tareas/TAREA-009-ambiente-y-sonido-ui.md) | Antigravity | ACEPTADO |
| [TAREA-010](tareas/TAREA-010-ruinas-bajo-elyndor.md) | Antigravity | ACEPTADO |
| [TAREA-011](tareas/TAREA-011-menu-graficos.md) | Antigravity | ACEPTADO |
| [TAREA-012](tareas/TAREA-012-figuras-enemigos.md) | Antigravity | ACEPTADO |
| [TAREA-013](tareas/TAREA-013-titulo-3d.md) | Antigravity | ACEPTADO |
| [TAREA-014](tareas/TAREA-014-opciones-compartidas.md) | Antigravity | ACEPTADO |
| [TAREA-015](tareas/TAREA-015-kit-gotico-ampliado.md) | Antigravity | ACEPTADO |
| [TAREA-016](tareas/TAREA-016-modelo-nereth.md) | Claude (Blender) | ABIERTO |
| [TAREA-017](tareas/TAREA-017-triposr-local.md) | Antigravity | ACEPTADO |
| [TAREA-018](tareas/TAREA-018-ruinas-kit-nuevo.md) | Antigravity | ACEPTADO |
| [TAREA-019](tareas/TAREA-019-camara-salon-kit.md) | Antigravity | ACEPTADO |
| [TAREA-020](tareas/TAREA-020-rendimiento.md) | Antigravity | ABIERTO |

## Notas técnicas

- Controles (teclado): A/D o flechas mover, Espacio saltar, Shift o L esquivar, J o clic izquierdo ataque ligero, K o clic derecho ataque pesado (mantener para cargar), E interactuar. Mando: stick izquierdo/cruceta, A saltar, B esquivar, X ligero, RB pesado, Y interactuar.
- Arranque: `main.tscn` → pantalla de título (`scenes/ui/titulo/`, fondo 3D animado con pulso de Desfase): Continuar (último Ancla), Nueva partida (borra `user://partida.json`, pide confirmación; **empieza en la Cámara del Despertar**) y Salir. Recorrido: Cámara del Despertar → Ruinas bajo Elyndor (antes «Barrio Desprendido») → Salón del Prefecto → fin de la demo. La salida del Salón del Prefecto lleva a `scenes/ui/fin_demo/`.
- Salas: autoload `Salas` (`GestorSalas.global()`), `PuntoEntrada` y `TransicionSala` en `scripts/core/mundo/`.
- Desfase: Q / I o LB. Autoload `Fase` (`GestorFase`); en código usar `GestorFase.global()`. Geometría de cada estado en capa 2 (Realidad) o 3 (Desfase) mediante un nodo hijo `ElementoFase`; Nereth solo cambia su `collision_mask`. Las cajas CSG con `ElementoFase` reciben automáticamente una colisión convexa.
- Costura: F / O o gatillo derecho (mantener, desde el Desfase). `ElementoCosible` (hijo `Node3D` de un elemento con `ElementoFase`): Puntada (`tipo = 0`, temporal, 25 de Resonancia, una activa) o Remiendo (`tipo = 1`, permanente, `id` + `ancla_requerida`, se guarda en `Partida.remiendos`).
- Atmósfera: `AtmosferaFase` (sustituye al WorldEnvironment de una sala) funde niebla, luz ambiental, brillo y saturación entre Realidad y Desfase. Efectos aditivos (rayos, polvo): en Compatibility la mezcla aditiva ignora la transparencia, así que la intensidad va en el color. Guía visual: `documentation/GUIA_ARTE.md`.
- Arte (D-032): texturas CC0 de Poly Haven en `assets/texturas/` (1K), materiales PBR triplanares en `assets/materiales/` y kit gótico modular en `scenes/mundo/kit_gotico/` (muro, columna, arco). Muestra: `scenes/niveles/pruebas/sala_kit_gotico.tscn`. Todo recurso externo se anota en `assets/LICENCIAS.md`.
- Sonido: autoload `Sonido` (`GestorSonido.global()`): `reproducir(nombre)`, `ambiente(pista)`, `fijar_volumen(bus, lineal)` (se guarda en `user://ajustes.cfg` junto a la calidad gráfica), `volumen(bus)`, `musica(pista)`. Efectos **sintetizados por código** (no hay archivos de audio); se sustituyen por grabaciones con `GestorSonido.archivos`. Escucha previa en `builds/sonidos_provisionales/`.
- Impactos: autoload `Impactos` (`DirectorImpactos.global()`): `golpe()`, `parry()`, `herida()`, `sacudir()`. La parada de impacto se desactiva sin pantalla; `CamaraLateral.escala_temblor = 0` quita el temblor (accesibilidad).
- Defensa: U / C o gatillo izquierdo = guardia (los primeros 0,15 s son parry). La guardia no cubre la espalda; sin resistencia se rompe.
- Enemigos: `scripts/core/enemigos/enemigo.gd` (`Enemigo`) + escenas en `scenes/enemigos/`. `existe_en` (0 Realidad, 1 Desfase, 2 ambos), `peso` (0 ligero, 1 medio, 2 pesado), `ia_activa` (false = presente pero quieto), ataques como `DatosAtaque` (`parable`, `bloqueable`, `fuerza`). Entran en el grupo `reinicio_descanso`.
- Anclas: escena `scenes/mundo/ancla/ancla.tscn` (`AnclaContinuidad`, `id` único obligatorio). Autoload `Partida` (`GestorPartida.global()`) guarda en `user://partida.json`. Los nodos del grupo `reinicio_descanso` reciben `reiniciar()` al descansar o reaparecer.
- Combate: ataques definidos como recursos (`DatosAtaque`) agrupados por arma (`DatosArma`) en `scenes/jugador/armas/`. Capas de física 6 (`dano_enemigo`) y 7 (`dano_jugador`) para cajas de golpe/daño.
- Pendiente para más adelante: plataformas atravesables desde abajo (Godot 3D no tiene colisión de un sentido; requiere solución propia).
- Capturas sin editor: `tools/captura_sala.gd` (ver cabecera) saca fotogramas PNG de una sala con Nereth en una posición, en Realidad o Desfase.
- Modelos 3D: Blender 5.2 sin ventana con scripts de `tools/blender/` (D-037); requisitos en `documentation/ESPECIFICACION_MODELOS.md`; revisión con `tools/vista_modelo.gd`.
- Textos con IA: `tools/gemini_texto.py` (Gemini, clave `GEMINI_API_KEY` en `.env`, que Git ignora; en la cabecera, nunca en la URL). Gemini 4 Argon no tiene cuota gratuita; se usa Gemini 3.5 Flash.
- Pruebas automáticas: `Godot_console.exe --headless --path D:\UMBRAL -s res://tests/<prueba>.gd` (código de salida = fallos).

## Pendiente del director

- **Origen de los modelos 3D y animaciones** (generados con IA, comprados, encargados…). La dirección visual ya está decidida: calidad escalable (D-017).
