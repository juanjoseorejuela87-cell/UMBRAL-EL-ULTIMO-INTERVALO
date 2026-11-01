# Prompt: versión web de UMBRAL (Google AI Studio / Build)

Pega todo el bloque de abajo en Google AI Studio (modo *Build*). Si el resultado es muy grande, pídelo por fases: «Haz solo la FASE 1», luego «Ahora la FASE 2», etc.

```text
Eres un desarrollador senior de videojuegos web. Crea un prototipo jugable en el navegador de mi juego original «UMBRAL: El Último Intervalo». Es un Action RPG de acción lateral con estructura Metroidvania, oscuro, gótico y melancólico. Quiero algo que se sienta como un juego de verdad, no una demo técnica: controles precisos, peso en los golpes, atmósfera y un pequeño recorrido completo de principio a fin.

═══════════════════════════════
1. TECNOLOGÍA Y REGLAS
═══════════════════════════════
- Aplicación web en TypeScript + React solo para la interfaz (menús, HUD). El juego se dibuja en un <canvas> con HTML5 Canvas 2D (sin motores externos ni assets descargados).
- Todo el arte se genera por código: formas, degradados, partículas, siluetas. Todo el sonido con Web Audio API (sintetizado: osciladores + ruido con envolventes).
- 60 FPS estables con delta time fijo para la física (paso de 1/60 s). Debe ir fluido en un portátil con gráfica integrada.
- Código organizado en módulos: motor (bucle, entrada, cámara), jugador, enemigos, combate, fases (Realidad/Desfase), niveles, efectos, audio, interfaz. Nada de números mágicos repartidos: un archivo de constantes de ajuste (velocidades, daños, tiempos).
- Textos del juego en español.
- Opción de calidad gráfica Baja / Alta en el menú (Baja: menos partículas, sin desenfoque ni brillo; Alta: todo).

═══════════════════════════════
2. MUNDO E HISTORIA (contexto, no lo cambies)
═══════════════════════════════
Hace siglos, los Arquitectos (una civilización avanzada) intentaron detener el cambio con el proyecto de la Permanencia. Provocaron la Primera Ruptura: la realidad quedó fragmentada. Ahora el mundo existe en dos estados superpuestos:
- La REALIDAD: el mundo actual, en ruinas, cálido, polvoriento, denso.
- El DESFASE: el mundo que debería haber sido, intacto, frío, azulado, nítido y silencioso.

La protagonista es NERETH, que despierta en una estructura subterránea bajo el reino de Elyndor sin saber cuánto tiempo ha estado allí. Puede moverse entre los dos estados. Una voz, Maelis, le habla en momentos clave. Elyndor es un reino que olvida: sus habitantes pierden recuerdos y las campanas suenan solas.

Frases oficiales que debes usar tal cual:
- Al obtener el Fragmento de Memoria: «Si has despertado, significa que el último intervalo no se ha cerrado.»
- Al terminar la demo: «No recuperes los fragmentos sin comprender lo que estás devolviendo.»

═══════════════════════════════
3. CONTROLES (teclado y mando con Gamepad API)
═══════════════════════════════
- A/D o flechas: moverse · Espacio: saltar (salto variable: soltar antes = salto más bajo)
- Shift: esquiva (rueda rápida con invulnerabilidad breve)
- J: ataque ligero (combo de 3) · K: ataque pesado (mantener para cargar)
- U: guardia (los primeros 0,15 s son PARRY)
- Q: cambiar entre Realidad y Desfase
- F (mantener): Costura
- E: interactuar · Esc: pausa
Mando: stick/cruceta, A saltar, B esquivar, X ligero, RB pesado, LT guardia, LB Desfase, RT Costura, Y interactuar, Start pausa.
Sensaciones obligatorias: coyote time (0,1 s), buffer de salto (0,12 s), buffer de esquiva durante un ataque, aceleración y frenado suaves, caída más rápida que la subida.

═══════════════════════════════
4. SISTEMAS PRINCIPALES
═══════════════════════════════
A) DESFASE (el corazón del juego)
- Con Q, Nereth cambia de estado. Cada estado tiene su propia geometría: hay plataformas, puentes y muros que solo existen en la Realidad, otros solo en el Desfase, y elementos comunes.
- Lo que no existe en el estado actual se dibuja como un fantasma translúcido (si es de la Realidad visto desde el Desfase) o directamente no se ve (si es del Desfase visto desde la Realidad).
- Al cambiar: destello, distorsión breve de pantalla, cambio de paleta (cálido ↔ frío) y de sonido ambiente (en el Desfase todo suena más apagado, con eco).
- RESONANCIA: barra 0–100. Sube estando en el Desfase. Si llega a 100, Nereth sufre un «Rechazo»: es expulsada a la Realidad y queda aturdida 1 s. Baja en la Realidad.
- Si cambias de estado estando dentro de un objeto sólido del otro estado, no se permite el cambio (sacudida y sonido de error).
- «Desfase preciso»: cambiar de estado justo cuando un ataque te va a golpear lo esquiva sin coste.

B) COSTURA (solo desde el Desfase, manteniendo F cerca de un elemento marcado)
- PUNTADA: lleva temporalmente (8 s) una plataforma del Desfase a la Realidad. Cuesta 25 de Resonancia. Solo una activa.
- REMIENDO: une permanentemente un puente roto (atajo). Se guarda.
- DESGARRO: contra enemigos, corta el ataque que están preparando (20 de Resonancia).
- Mientras se cose: hilos de luz dorada entre Nereth y el objetivo.

C) COMBATE
- Ataques con hitbox activa solo en sus frames activos; anticipación, golpe y recuperación.
- Enemigos con VIDA y POSTURA. Al vaciar la postura entran en RUPTURA (aturdidos); el siguiente golpe es un «Golpe de Umbral» que hace ×2,5 de daño con un efecto enorme.
- PARRY (guardia en los primeros 0,15 s): congela el juego 0,13 s, chispas, gran daño de postura al enemigo y +12 de Resonancia.
- Guardia normal: bloquea gastando resistencia; sin resistencia la guardia se rompe.
- Sensación de impacto: hitstop (0,045 s golpe normal, 0,11 s crítico), temblor de cámara, partículas, retroceso del enemigo, destello blanco del sprite.
- Nereth tiene vida y resistencia (la resistencia se gasta al esquivar y bloquear y se recupera sola).

D) ENEMIGOS (tres tipos con relación distinta con las fases)
- VIGÍA HUECO (corpóreo, vive en la Realidad): armadura vacía con lanza. Patrulla, embiste. Desde el Desfase solo se le puede dañar la postura (golpeando sus hilos).
- ECO REZAGADO (solo existe en el Desfase): figura translúcida que repite un ataque del pasado. Invisible e intocable desde la Realidad.
- GUARDIÁN PARTIDO (bifásico): blindado en la Realidad (poco daño), expuesto en el Desfase. Obliga a cambiar de estado en mitad del combate.
- Un enemigo solo te daña si estáis en el mismo estado.

E) ANCLAS DE CONTINUIDAD (puntos de guardado)
- Estructuras que se estabilizan al tocarlas. Descansar en ellas restaura vida y Resonancia y reaparecen los enemigos.
- Al morir se reaparece en la última Ancla. Guardado en localStorage.

═══════════════════════════════
5. JEFE: EL PREFECTO DE LAS PUERTAS
═══════════════════════════════
Antiguo protector de Elyndor. Recibió la orden de impedir que nadie se acercara a las estructuras antiguas y ha olvidado que su función original era permitir el paso de los habitantes. No reconoce a Nereth, pero percibe algo extraño en ella y la considera una amenaza. Armadura monumental, alabarda, luz fría en el yelmo.
- Fase 1 (100–65 %): combate puro. Barrido, estocada cargada y golpe al suelo con onda. Ataques telegrafiados y parables.
- Fase 2 (65–30 %): se teletransporta entre 4 puertas de la sala. La puerta por la que saldrá solo se ve en el Desfase. Coser la puerta de entrada (Costura) le tiende una trampa y lo deja en Ruptura.
- Fase 3 (30–0 %): pasa a ser bifásico (casi inmune en la Realidad). Los suelos laterales solo existen en el Desfase. Cada 12 s lanza el «Cierre», un ataque de toda la sala que solo se evita esquivando con precisión o escondiéndose tras una puerta cosida.
- Barra de vida grande con su nombre abajo en la pantalla. Música propia sintetizada (tambores graves, coro sintético).
- Al derrotarlo aparece el Fragmento de Memoria.

═══════════════════════════════
6. RECORRIDO DE LA DEMO (3 salas conectadas)
═══════════════════════════════
1. CÁMARA DEL DESPERTAR: Nereth despierta en un estrado de piedra. Símbolos de los Arquitectos en las paredes que brillan cuando pasa cerca. Un derrumbe bloquea la salida en la Realidad: el jugador debe descubrir el Desfase (texto breve: «Q — Desfase») para atravesarlo.
2. RUINAS BAJO ELYNDOR: sala larga con plataformas, enseña a combinar Realidad/Desfase, una Puntada, un Remiendo que abre un atajo, primeros enemigos (2 Vigías, 1 Eco, 1 Guardián), una Ancla a mitad de camino.
3. SALÓN DEL PREFECTO: sala enorme con arcos apuntados y 4 puertas. Jefe. Tras vencerlo: Fragmento de Memoria → pantalla dorada con la visión «Una ciudad antigua. Una sala gigantesca. Una mujer observa una estructura luminosa.» y la frase oficial. La salida lleva a la pantalla final con la segunda frase oficial.
Extra: después de obtener el Fragmento de Memoria, aparecen en el Desfase «ecos de memoria» ocultos (figuras azules translúcidas) que muestran escenas breves del pasado al tocarlos.

═══════════════════════════════
7. DIRECCIÓN DE ARTE (2.5D falso con parallax)
═══════════════════════════════
- Vista lateral con 4 capas de profundidad: fondo lejano (muy oscuro, siluetas de catedral), fondo medio (muros, columnas, arcos góticos), capa de juego, primer plano (siluetas finas y oscuras de columnas y cadenas que pasan por delante, con parallax más rápido).
- REALIDAD: piedra rota, paleta cálida (ocres, marrones, ámbar), polvo flotando, rayos de luz diagonales, niebla cálida. Columnas rotas.
- DESFASE: la misma arquitectura pero intacta (columnas enteras, arcos completos), paleta fría (azules, blanco pálido), aire limpio, partículas que suben lentamente, viñeta azul.
- Nereth: silueta esbelta con capa que ondea (simulación simple por puntos), detalles de luz dorada. Animaciones por código: correr, saltar, esquivar, 3 golpes, golpe pesado, guardia, aturdida.
- Iluminación falsa con degradados radiales y modo de mezcla aditivo para antorchas, símbolos y golpes.
- Interfaz sobria: vida (roja oscura), resistencia (gris), Resonancia (arco azul que se vuelve inestable y tiembla cerca de 100). Fuente con serifa elegante.

═══════════════════════════════
8. AUDIO (Web Audio, todo sintetizado)
═══════════════════════════════
Efectos: golpe, golpe crítico, parry (metálico brillante), esquiva, salto, aterrizaje, cambio de fase (barrido), Rechazo, costura (zumbido creciente), daño recibido, Ancla, fragmento (campanas). Ambientes en bucle: ruinas (viento grave + gotas) y salón (drones graves). Buses de volumen separados para música, efectos y ambiente, con deslizadores en la pausa.

═══════════════════════════════
9. MENÚS
═══════════════════════════════
Pantalla de título (Continuar / Nueva partida / Opciones / Salir) con fondo animado. Pausa con: Reanudar, Controles, Sonido, Gráficos, Volver al título. Pantalla de muerte breve («La continuidad te retiene…») y reaparición en el Ancla.

═══════════════════════════════
10. ENTREGA POR FASES
═══════════════════════════════
FASE 1: motor, Nereth con movimiento completo, cámara con suavizado y sala de pruebas.
FASE 2: Desfase y Resonancia, con geometría de doble estado.
FASE 3: combate, postura, parry, y los 3 enemigos.
FASE 4: Costura, Anclas y guardado.
FASE 5: las 3 salas de la demo y el Prefecto.
FASE 6: arte, partículas, audio, menús y pulido de sensación.
Al terminar cada fase, el juego debe funcionar sin errores en consola. Explica brevemente qué has hecho y cómo probarlo.
```
