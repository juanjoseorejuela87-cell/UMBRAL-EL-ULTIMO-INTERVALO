# UMBRAL: El Último Intervalo — Gameplay

> **Etiquetas:** **[CONFIRMADO]** decidido por el director · **[PROPUESTA]** diseño provisional (puede estar implementado y aun así cambiar) · **[PENDIENTE]** sin definir.
> Los valores numéricos son **puntos de partida de ajuste**, no definitivos.

## 0. Pilares [CONFIRMADO]

1. **Combate:** precisión, estrategia y dominio del personaje.
2. **Exploración:** descubrimiento, progresión y regiones interconectadas.
3. **Manipulación de la realidad:** Desfase, Costura y Anclas.

Regla de diseño: cada sistema debe tocar al menos dos pilares. Cada región y cada jefe importante usan al menos una mecánica de manipulación de la realidad.

Principios de producción: sistemas pocos y profundos; implementables por etapas; pensados para una persona con ayuda de IA; presupuesto gráfico de una GPU integrada.

---

## 1. Movimiento de Nereth

| Elemento | Diseño | Estado |
|---|---|---|
| Plano 2.5D | Mundo 3D; Nereth se mueve en X/Y con Z fijo. Cámara lateral con perspectiva suave que sigue con margen y adelanto en la dirección de la mirada. | PROPUESTA |
| Profundidad contextual | Sin movimiento libre en Z. En puntos marcados (escaleras, pórticos, pasarelas de fondo) un botón de interacción mueve a Nereth por una ruta guiada a otro plano. | PROPUESTA |
| Aceleración | Rápida (~0,08 s a velocidad máxima) y frenada corta (~0,06 s). Control aéreo algo menor que en suelo. | PROPUESTA |
| Salto variable | Altura máxima ~3 unidades; soltar el botón corta la subida. Tiempo de gracia tras dejar un borde (~0,1 s) y salto anticipado antes de aterrizar (~0,12 s). | PROPUESTA |
| Caída | Gravedad mayor al caer que al subir; velocidad máxima de caída limitada. | PROPUESTA |
| Esquiva | Desplazamiento corto (~0,25 s) con invulnerabilidad en su parte central (~0,15 s). Una en el aire hasta tocar suelo. Coste de resistencia. | PROPUESTA |
| Recuperación | Toda acción tiene recuperación; la esquiva puede cancelar la recuperación de ataques ligeros a partir de cierto punto. | PROPUESTA |
| Superficies | Plataformas atravesables desde abajo (y descenso pulsando abajo + salto), superficies propias de cada estado (solo Realidad / solo Desfase), cornisas. | PROPUESTA |

---

## 2. Combate

### 2.1 Anatomía de una acción [PROPUESTA]
Preparación → activo (golpea) → recuperación. Las cancelaciones están limitadas y explícitas: es lo que da peso a cada decisión.

### 2.2 Acciones [PROPUESTA]
- **Ligero:** cadena de 3 golpes (varía por arma).
- **Pesado:** cargable; mayor daño de postura.
- **Aéreo**, **pesado en carrera**.
- **Guardia / parry:** el primer instante de la guardia (~0,15 s) es parry; el resto es bloqueo.

### 2.3 Resistencia [CONFIRMADO]
La gastan ataques, esquiva y bloqueo. Se recupera rápido sin acciones. Agotada: no se puede esquivar y el bloqueo se rompe.

### 2.4 Parry y contraataque [PROPUESTA]
Parry correcto: gran daño de postura, abre un contraataque y **devuelve Resonancia**. Fallido: bloqueo normal.

### 2.5 Postura y Ruptura [PROPUESTA]
Solo los enemigos tienen postura. Se llena con golpes pesados, parries y técnicas; se vacía con el tiempo. Llena → **Ruptura**: enemigo vulnerable y **Golpe de Umbral** (crítico).

### 2.6 Daño [PROPUESTA]
Dos tipos: **Físico** (armas) y **Resonante** (técnicas de Desfase, Costura). La postura es un canal aparte.

### 2.7 Peso de los enemigos [PROPUESTA]
Ligero (cualquier golpe interrumpe), medio (solo pesados), pesado (solo Ruptura).

### 2.8 Curación [PROPUESTA]
Cargas limitadas (**Esencias**, nombre provisional) que se rellenan en Anclas; su número aumenta con progresión.

---

## 3. Desfase

### 3.1 Estados [CONFIRMADO]
**Realidad:** estado físico normal. **Desfase:** aparecen estructuras, rutas, criaturas y acontecimientos ocultos.

### 3.2 Transición [PROPUESTA]
- Una pulsación para entrar y otra para salir (opción de accesibilidad: mantener).
- Dura ~0,3 s. Durante ese tiempo los golpes enemigos atraviesan a Nereth.
- **Desfase preciso:** cambiar justo cuando llega un golpe devuelve parte del coste.
- Si al cambiar de estado Nereth quedaría dentro de un sólido, el cambio se bloquea con aviso visual (nunca atrapa al jugador).

### 3.3 Equilibrio de Resonancia: dos regímenes [PROPUESTA]

El Desfase debe costar en combate y en los retos diseñados para ello, pero **nunca convertir la exploración en una carrera contra el recurso**.

| | **Calma** (ningún enemigo en alerta cerca) | **Amenaza** (combate o zona de presión) |
|---|---|---|
| Entrar en Desfase | Gratis | Coste fijo (~15 % de la barra) |
| Permanecer | Consumo bajo y constante (~2 %/s) | Consumo creciente (de ~4 %/s a ~10 %/s) |
| Recuperación en Realidad | Rápida: barra completa en ~4 s | Pasiva lenta hasta un 30 %; el resto con golpes, parries y Desfases precisos |
| Fuentes del escenario | Vetas de Resonancia | Vetas de Resonancia |

- **Zonas de presión:** salas concretas (retos, secretos, arenas) pueden forzar el régimen de Amenaza sin enemigos. Se señalizan visualmente.
- **Rechazo:** si la Resonancia llega a 0 en Desfase, Nereth vuelve a la Realidad, queda aturdido ~0,5 s y no puede volver a entrar ~2 s. En Calma, la barra baja tan despacio que solo ocurre si el jugador lo provoca.

### 3.4 Escenario [PROPUESTA]
- Elementos **solo Realidad**, **solo Desfase** y **comunes**.
- Barreras atravesables, rutas invisibles, plataformas especiales, escenas del pasado (ecos).
- A la inversa: estructuras de la Realidad desaparecen en el Desfase (riesgo de quedarse sin suelo).

### 3.5 Enemigos por estado [PROPUESTA]
- **Corpóreos:** solo Realidad; en Desfase se ven como siluetas y se les ven los **Hilos**.
- **Ecos:** solo Desfase; invisibles e intangibles desde la Realidad.
- **Bifásicos:** en ambos; un punto débil distinto en cada estado.

### 3.6 Aplicaciones en combate [PROPUESTA]
Esquivar sin gastar resistencia (Desfase preciso), golpear Hilos de corpóreos desde el Desfase (daño de postura), combatir ecos, usar las Técnicas de Desfase del arma.

### 3.7 Consecuencias de cambiar [PROPUESTA]
Cambian el suelo disponible, los enemigos que pueden dañarte y a los que puedes dañar, y los peligros activos. Un cambio a destiempo deja a Nereth sin suelo o rodeado de ecos.

---

## 4. Costura de Continuidad

### 4.1 Detección [PROPUESTA]
- Los elementos cosibles muestran **Hilos** solo visibles en el Desfase.
- Con Percepción alta se intuyen, tenues, desde la Realidad.
- [CONFIRMADO] No funciona con cualquier elemento: todo lo cosible está marcado explícitamente.

### 4.2 Tres usos distintos [PROPUESTA]

| | **Puntada** (temporal) | **Remiendo** (permanente) | **Desgarro** (combate) |
|---|---|---|---|
| Objetivo | Elementos de Doble Estado menores: plataformas, puentes, puertas, mecanismos, muros | **Nodos mayores** marcados: grandes estructuras que reconectan el mapa | Hilos de enemigos |
| Efecto | Proyecta el estado del Desfase en la Realidad durante un tiempo | Restaura la estructura **para siempre** (persistente en el guardado) | Según el enemigo: **Anclar** (fija un bifásico a un estado), **Cortar** (interrumpe una transformación o carga), **Exponer** (revela un punto débil) |
| Coste | ~25 % de Resonancia | Requiere un Ancla estabilizada que alimente el nodo, o un reto local; sin coste de Resonancia | ~20 % de Resonancia y enfriamiento corto |
| Duración | ~10 s (mejorable) | Permanente | Instantáneo o breve (~3 s) |
| Límite | Una activa (dos con mejora) | Una por nodo | Una por enemigo a la vez |
| Uso | Puzles y rutas temporales | Atajos, progresión del mapa, estabilización de zonas | Abrir defensas, romper patrones |

Mismo botón, comportamiento según el objetivo. Se mantiene pulsado desde el Desfase apuntando al elemento; el Desgarro es más rápido para que funcione en combate.

### 4.3 Ejemplos de puzles [PROPUESTA]
1. **El puente** (ejemplo canónico): coser un puente intacto en el Desfase y cruzarlo en la Realidad.
2. **Cadena contrarreloj:** coser una plataforma, saltar, volver al Desfase y coser la siguiente antes de que caiga la primera.
3. **La puerta del pasado:** una puerta abierta en el Desfase; coserla para pasar en la Realidad.
4. **Muro inverso** (mejora): llevar un muro de la Realidad al Desfase para bloquear a un eco.
5. **El contrapeso:** coser un mecanismo y dejar una **Huella** sobre su placa para mantenerlo activo.
6. **El remiendo del barrio:** varios puzles de Puntada llevan a un Nodo mayor; el Remiendo restaura el barrio y crea un atajo permanente al Ancla.

---

## 5. Anclas de Continuidad

| Aspecto | Diseño | Estado |
|---|---|---|
| Estados | **Dormida** → **estabilizada** (requiere un reto local: puzle de Costura o combate). | PROPUESTA |
| Guardado | Guardar y reaparecer en la última Ancla usada. | CONFIRMADO (guardar) / PROPUESTA (reaparecer) |
| Recuperación | Vida, Resonancia y Esencias al máximo. | CONFIRMADO / PROPUESTA (detalle) |
| Mejoras | Subir atributos, mejorar armas, cambiar arma y Vestigios. | CONFIRMADO (mejorar) / PROPUESTA (detalle) |
| Registro | Registrar los ecos de memoria recogidos. | CONFIRMADO (registrar acontecimientos) |
| Estabilización | Al estabilizarla desaparecen distorsiones de la zona, se habilita el viaje entre Anclas y puede alimentar un Remiendo cercano. | CONFIRMADO (estabilizar) / PROPUESTA (detalle) |
| Descansar | Los enemigos vuelven: la zona **repite sus acontecimientos** (bucles de la ruptura). | PROPUESTA |
| Muerte | Reaparición en el último Ancla; **sin pérdida de moneda**; se pierden los ecos no registrados desde el último descanso (siguen en su sitio). | PROPUESTA |
| Narrativa | Relación de las Anclas con la historia. | PENDIENTE |

---

## 6. Progresión RPG

### 6.1 Atributos [CONFIRMADO nombres / PROPUESTA efectos]

| Atributo | Efecto |
|---|---|
| **Vitalidad** | Vida máxima, algo de resistencia máxima |
| **Resonancia** | Resonancia máxima (el atributo amplía el recurso), duración de la Puntada, daño resonante |
| **Dominio** | Daño de las armas y daño de postura |
| **Percepción** | Ver Hilos y rutas ocultas desde la Realidad, detectar ecos y secretos, ventana de parry ligeramente mayor |

Subida en Anclas con **Hebras**; coste creciente por nivel. Sin niveles de personaje aparte de los atributos.

### 6.2 Armas [CONFIRMADO nombres / PROPUESTA estilos]

| Arma | Estilo | Técnica de Desfase |
|---|---|---|
| **Espada del Umbral** (inicial) | Equilibrada, buen parry | Tajo que corta Hilos a distancia corta |
| **Mandoble de Ruptura** | Lento, mucha postura, no se interrumpe al cargar | Impacto que golpea en ambos estados |
| **Cuchillas Gemelas** | Rápidas, poca postura, mucha ganancia de Resonancia | Ráfaga que atraviesa al enemigo |
| **Lanza de Continuidad** | Alcance, estocadas | Desgarro a distancia que atrae o fija |

Un arma activa; cambio en Anclas. Mejora posterior: cambio rápido entre dos armas. Mejora de armas con materiales de forja.

### 6.3 Vestigios [CONFIRMADO concepto / PROPUESTA detalle]
Pasivos en huecos limitados (3 → 6). Varios con ventaja y desventaja. Cada uno ligado a la historia de su región.

### 6.4 Economía [PROPUESTA]
- **Hebras:** única moneda (enemigos, ecos, secretos). Atributos y comercio.
- **Materiales de forja:** un tipo por nivel de mejora de arma.
- **Esencias:** cargas de curación.

---

## 7. Exploración y Metroidvania

### 7.1 Estructura [PROPUESTA]
- **Elyndor es el centro.** Sus puertas exteriores llevan a las regiones 2–6.
- Cada región: bucles internos, al menos dos conexiones con otras regiones, al menos dos Anclas.
- **Núcleo** accesible con los Fragmentos de Continuidad (cantidad [PENDIENTE]).
- Técnicamente cada sala es una escena; el mundo se produce por partes.

### 7.2 Bloqueos [PROPUESTA]
Por habilidad, por Desfase, por Costura (Puntada o Remiendo), por Ancla, narrativos y atajos de un sentido.

### 7.3 Habilidades de exploración [PROPUESTA]

Desfase y Costura son **poderes base** (no cuentan entre las seis).

| # | Habilidad | Utilidad | Con Desfase | Con Costura | En combate | Dónde (propuesta) |
|---|---|---|---|---|---|---|
| 1 | **Paso Intervalo** | Impulso corto en suelo o aire | En Desfase atraviesa **Velos** (barreras finas) | Cruzar el hueco entre dos Puntadas | Atravesar enemigos para reposicionarse | Bosque de las Voces Hundidas |
| 2 | **Agarre de Grieta** | Aferrarse a muros y saltar entre ellos | Muros que solo existen en un estado | Coser un muro para escalarlo en la Realidad | Salto de muro con ataque descendente | Catedral de las Horas Muertas |
| 3 | **Hilo Tensor** | Lanzarse hacia Nodos de anclaje | Muchos nodos solo son visibles en Desfase | Tensar hacia elementos cosidos | Atraer enemigos ligeros / lanzarse hacia uno | Mar de Ceniza |
| 4 | **Huella** | Dejar una copia temporal de Nereth | La copia se queda en el estado que abandonas | Mantiene placas y mecanismos de Puntadas | Señuelo | Forja de los Cuerpos Imposibles |
| 5 | **Caída de Ruptura** | Golpe descendente que rompe suelos | Rompe suelos que solo existen en un estado | Rompe Puntadas enemigas o viejas | Gran daño de postura aéreo | Elyndor (zona avanzada, fuera de la vertical slice) |
| 6 | **Travesía de Ceniza** | Moverse sumergido en ceniza | En Desfase la ceniza se vuelve transitable por encima | Coser corrientes de ceniza | Emerger con ataque | Mar de Ceniza (cierre) o Palacio de los Ausentes |

Progresión: primero movilidad básica (1, 2), luego conexión con el mundo (3, 4), luego dominio vertical y regional (5, 6). Cada nueva habilidad abre rutas en regiones ya visitadas.

### 7.4 Secretos, atajos y ecos [PROPUESTA]
- **Secretos:** muros falsos visibles en Desfase, Puntadas ocultas, rutas que requieren combinar dos habilidades.
- **Atajos:** puertas de un sentido y Remiendos que acortan el regreso a las Anclas.
- **Ecos de memoria:** escenas del pasado en el Desfase. Dan historia y Hebras; algunos revelan rutas ocultas. Se registran en Anclas.

### 7.5 Mapa [PROPUESTA]
Se descubre explorando y se consolida en las Anclas. Marcadores manuales.

### 7.6 Recompensas [PROPUESTA]
Hebras, materiales de forja, Vestigios, aumento de Esencias, fragmentos de Resonancia máxima, ecos de memoria, habilidades.

---

## 8. Dificultad y accesibilidad [PROPUESTA]

| | Historia | Normal | Difícil |
|---|---|---|---|
| Daño recibido | −40 % | Estándar | +30 % |
| Ventanas de parry/esquiva/Desfase preciso | +50 % | Estándar | −25 % |
| Consumo de Resonancia (Amenaza) | −40 % | Estándar | +25 % |
| Agresividad y recuperación de postura enemiga | Baja | Estándar | Alta |
| Ecos no registrados al morir | Se conservan | Se pierden | Se pierden |

Todas las mecánicas existen en los tres modos. La dificultad se puede cambiar en cualquier momento.

**Accesibilidad (independiente):** reasignar controles, pulsar/mantener Desfase, indicadores del estado que no dependen solo del color, reducción de destellos y temblor de pantalla, contraste de elementos interactivos, subtítulos.

---

## 9. Experiencia del jugador [PROPUESTA]

- **Ciclo inmediato:** leer → esquivar o parry → cambiar de estado a tiempo → romper postura → Golpe de Umbral → recuperar Resonancia.
- **Ciclo intermedio:** explorar sala → bloqueo → resolver con Desfase/Costura → estabilizar Ancla → mejorar.
- **Ciclo largo:** región → jefe → Fragmento y habilidad → rutas nuevas en zonas conocidas → revelación.
- **Actos:** I (Elyndor): fundamentos y Desfase; el Prefecto exige combinar Desfase y Costura. II (regiones intermedias): habilidades y combinaciones. III (hasta el Núcleo): dominio de todo.

---

## 10. Primer jefe: el Prefecto de las Puertas [PROPUESTA]

### 10.1 Identidad
Antiguo custodio de las puertas de Elyndor que siguió cerrando el paso cuando la ciudad empezó a borrarse (ver `LORE.md` §8.2). Figura alta y rígida, con una **llave-alabarda**; existe a medias entre los dos estados. Mecánica temática: **las puertas y el paso entre estados**.

### 10.2 Arena
Sala circular con **cuatro puertas**. Cada puerta existe en un estado distinto (dos en Realidad, una en Desfase, una en ambos). Suelo parcialmente borrado en la Realidad e intacto en el Desfase.

### 10.3 Fases

**Fase 1 — Custodia (100–65 %).** Enseña combate base.
- *Barrido de alabarda:* amplio, parryable.
- *Estocada cargada:* telegrafiada con brillo; esquivar.
- *Golpe de llave:* contra el suelo, onda que se salta.
- Rompe postura con parries; Golpe de Umbral disponible.

**Fase 2 — Puertas cruzadas (65–30 %).** Exige Desfase y Puntada.
- Entra por una puerta y sale por otra para atacar por la espalda. **Solo en el Desfase se ve por qué puerta saldrá** (rastro de Hilos).
- Invoca **ecos de guardias** que solo existen en el Desfase.
- **Puntada sobre la puerta por la que ha entrado:** la cierra, queda atrapado al salir y entra en Ruptura inmediata.

**Fase 3 — Umbral abierto (30–0 %).** Exige alternar estados.
- Se vuelve **bifásico**: en Realidad lleva armadura (daño muy reducido); en Desfase se le ven los Hilos.
- Ritmo: parry en Realidad para abrir → cambiar a Desfase → **Desgarro (Exponer)** o golpes a los Hilos.
- Parte del suelo desaparece en la Realidad: hay que moverse por el Desfase.
- *Ataque final "Cierre de todas las puertas":* todas las puertas se cierran de golpe; el único refugio es una puerta cosida a tiempo.

### 10.4 Recompensa
Primer **Fragmento de Continuidad** y apertura de las puertas exteriores de Elyndor.

### 10.5 Relación con los sistemas
Combate (parry/postura) → F1. Desfase (lectura de información oculta) → F2. Costura (Puntada y Desgarro) → F2–F3. Es el examen final de la vertical slice.

---

## 11. Estrategia de producción [PROPUESTA]

Las siete regiones se mantienen como visión general; se producen **de una en una**.

**Fase 0 — Fundamentos:** movimiento, cámara, entrada, sala de pruebas.
**Fase 1 — Vertical slice de Elyndor** (prioridad):
- 10–15 salas en greybox con estética provisional.
- Movimiento completo, combate base, Espada del Umbral.
- Desfase completo, Puntada, un Remiendo y Desgarro.
- Dos Anclas con guardado, mejora de atributos y registro de ecos.
- Tres arquetipos: corpóreo, eco y bifásico.
- El Prefecto de las Puertas.
- 2–3 Vestigios, 3–5 ecos de memoria, HUD básico, menú de pausa.

**Fase 2 — Elyndor completo**, después **una región por fase**, cada una con el mismo ciclo: diseño en papel → greybox → mecánicas propias → enemigos → jefe → arte → pulido.

Orden técnico de la Fase 0–1:
1. Movimiento y cámara · 2. Combate base contra un muñeco · 3. Desfase · 4. Ancla y guardado · 5. Costura · 6. Tres arquetipos · 7. Prefecto · 8. Montaje de las salas de Elyndor.
