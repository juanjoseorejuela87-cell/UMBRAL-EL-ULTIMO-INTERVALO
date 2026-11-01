# UMBRAL — Guía de arte

> **Estado:** [PROPUESTA] de Claude a partir del canon (`LORE.md`) y de las decisiones D-017 (calidad escalable) y D-032 (arte gratuito con IA, uso comercial). La valida el director.
> **Objetivo:** que todo el juego parezca obra de una sola mano aunque los recursos salgan de fuentes distintas (texturas CC0, kit procedural, modelos generados con IA). La coherencia pesa más que el detalle.

## 1. La idea visual en una frase

**Un mundo hermoso que se está olvidando a sí mismo.** Cada lugar existe en dos versiones: la **Realidad**, en ruinas, cálida y apagada como un recuerdo que se desvanece, y el **Desfase**, intacto, frío y luminoso como el instante antes de la Ruptura. El jugador debe *ver* la pérdida.

## 2. Los dos estados

| | **Realidad** | **Desfase** |
|---|---|---|
| Estado de las cosas | Ruinas, grietas, escombros, piezas que faltan | Arquitectura completa, como era antes de la Ruptura |
| Luz | Cálida y escasa: antorchas, brasas, luz de tarde que entra por huecos | Fría y uniforme: luz azul-blanca sin fuente clara |
| Niebla | Densa, ocre-gris, cercana | Fina, azulada, lejana |
| Color dominante | Ocres, pardos, piedra gris cálida | Azules, plata, blanco hueso |
| Contraste | Alto (sombras profundas) | Medio (sombras suaves) |
| Partículas | Polvo y ceniza que caen | Motas de luz que flotan hacia arriba |
| Sonido (referencia) | Grave, reverberante | Agudo, cristalino |

**Regla:** al cambiar de estado no solo cambia la geometría; cambian también la luz, la niebla y las partículas. El cambio debe sentirse como «cambiar de época».

## 3. Paleta

**Realidad (Elyndor):**
- Piedra: `#5A5048` (cálida), `#3A3532` (sombra)
- Ocre de antorcha: `#E89A4A`, brasa: `#B5502A`
- Óxido / metal: `#7A4A2E`
- Fondo y sombra profunda: `#0E0C10`

**Desfase:**
- Luz: `#BFD8FF`, `#7FA8FF`
- Piedra intacta: `#C9CDD8` (blanco hueso azulado)
- Hilos y Costura: `#73D9FF`
- Fondo: `#0A0F1E`

**Acentos narrativos (escasos):**
- Fragmentos de Continuidad y Maelis: blanco-dorado `#FFE7B0`.
- El Primer Testigo y la Permanencia: blanco frío sin matices `#F4F6FA` (lo inmóvil).
- Peligro y telegrafía enemiga: naranja `#FF7A1A` (ya usado en el código).

## 4. Arquitectura (kit gótico)

- **Estilo:** gótico pesado y antiguo, de la civilización de los Arquitectos, con asentamientos posteriores más pobres construidos encima (madera, remiendos). La mezcla de épocas cuenta la historia de Elyndor.
- **Formas clave:** arcos de medio punto y apuntados, columnas con basa y capitel, contrafuertes, ventanales altos, escaleras anchas, puertas monumentales y mecanismos de los Arquitectos (anillos, engranajes, símbolos).
- **Desgaste en la Realidad:** columnas partidas, arcos incompletos, escombros en el suelo y raíces o ceniza acumulada. En el Desfase, las mismas piezas aparecen enteras.
- **Escala:** Nereth mide 1,8 u y las puertas monumentales al menos 6 u. La arquitectura debe empequeñecerlo.
- **Materiales:** los de `assets/materiales/` (CC0). No mezclar más de 3 materiales de piedra en una misma sala.

## 5. Composición de una sala 2.5D

Cada sala se construye en **capas de profundidad** (Z):

| Capa | Z aprox. | Contenido | Colisión |
|---|---|---|---|
| Primer plano | +2 a +4 | Siluetas oscuras desenfocadas por la niebla (columnas, cadenas, raíces) que pasan delante de la cámara | No |
| Plano de juego | 0 | Suelo, plataformas, enemigos, Nereth | Sí |
| Fondo cercano | −2 a −4 | Muros, arcos, columnas, puertas: la arquitectura legible | No |
| Fondo lejano | −10 a −40 | Siluetas de torres y bóvedas, cada vez más absorbidas por la niebla | No |

**Reglas de lectura:**
1. El plano de juego siempre es el más contrastado y mejor iluminado.
2. Lo que se puede pisar tiene un borde claro (luz rasante o un material distinto).
3. Elementos interactivos (Anclas, Hilos, Fragmentos): su propia luz y color de acento.
4. Los enemigos nunca se confunden con el fondo: silueta recortada contra algo más claro u oscuro.

## 6. Luz

- **Una luz principal** por sala (direccional suave), **una o dos luces de acento** (antorchas, grietas) y la luz propia de los interactivos.
- La luz cuenta la historia: los lugares importantes para Maelis tienen luz cálida dorada; los de la Permanencia, luz blanca fría y quieta.
- En el renderizador ligero (PC modestos): pocas luces con sombra (máx. 2 por sala).

## 7. Personajes (para cuando lleguen los modelos)

- **Nereth:** silueta delgada y alta, ropa en capas desgastada de varias épocas (su cuerpo contiene restos de distintos acontecimientos), sin armadura pesada. Detalles que brillan débilmente en azul-blanco cuando está en el Desfase. Cara parcialmente oculta.
- **Maelis:** se ve solo como eco: figura traslúcida dorada, vestimenta de investigadora de los Arquitectos.
- **El Prefecto:** alto y rígido, armadura de guardia ceremonial deteriorada, llave-alabarda; partes de su armadura existen solo en un estado (conexiones visibles en el Desfase).
- **Enemigos de Elyndor:** habitantes y guardias atrapados en bucles, deformados por la repetición, nunca monstruos genéricos.
- **Reglas para los modelos generados con IA:** misma paleta, proporciones realistas algo alargadas, materiales mate y desgastados, nada brillante ni de plástico. Todo modelo pasa por limpieza y se ajusta a la paleta antes de entrar.

## 8. Escalabilidad (D-017)

| Elemento | PC modesto (Compatibility) | PC potente (Forward+) |
|---|---|---|
| Niebla | Niebla de profundidad | Niebla volumétrica |
| Luz global | Luz ambiental + antorchas | Iluminación global (SDFGI) y oclusión ambiental |
| Sombras | 1–2 luces con sombra, resolución media | Varias, alta resolución |
| Brillo (glow) | Suave | Completo |
| Texturas | 1K | 2K |
| Partículas | Menos cantidad | Cantidad completa |

**Regla:** la sala debe verse **bien** en un PC modesto y **mejor** en uno potente. Nunca diseñar algo que solo funcione con los efectos caros.

## 9. Lo que no queremos

- Colores saturados de fantasía genérica, brillo de plástico, cel shading.
- Monstruos genéricos sin relación con el lore.
- Fondos vacíos o negros sin capas.
- Mezclar estilos (realista + caricaturesco) por usar recursos de fuentes distintas sin ajustarlos.
