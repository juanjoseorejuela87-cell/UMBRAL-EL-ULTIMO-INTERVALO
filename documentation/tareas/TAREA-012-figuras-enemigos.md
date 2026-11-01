# TAREA-012 — Figuras estilizadas de los enemigos

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
- **Archivos permitidos:**
  - `scenes/enemigos/vigia_hueco/vigia_hueco.tscn`, `scenes/enemigos/eco_rezagado/eco_rezagado.tscn`, `scenes/enemigos/guardian_partido/guardian_partido.tscn`, `scenes/enemigos/prefecto/prefecto.tscn` (solo el nodo `Visual` y sus hijos, y los `sub_resource` de mallas/materiales).
  - Nuevos scripts de animación junto a cada escena: `scenes/enemigos/<enemigo>/figura_<enemigo>.gd` (opcionales).
  - `tests/test_figuras_enemigos.gd` (nuevo).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, colisiones, cajas de golpe/daño, `ElementoFase`, datos de ataques (`.tres`), `prefecto.gd`.

## Contexto

Mientras llegan los modelos definitivos (D-032), sustituimos las cápsulas por **figuras hechas con primitivas** (cápsulas, cilindros, cajas, prismas, esferas) con animación procedural barata, como ya tiene Nereth. **Plantilla:** `scenes/jugador/figura_nereth.gd` (construye las piezas en código con pivotes en hombros y caderas y las anima leyendo el estado). Puedes construir las piezas en código como allí o directamente en la escena.

**Regla del núcleo (ya en `main`):** al arrancar, `Enemigo` duplica el material de `Visual/Cuerpo` y se lo aplica a **todas** las mallas bajo `Visual` que usen ese mismo material. Por tanto:
- **No renombres ni borres `Visual/Cuerpo`** (el núcleo lo busca). Conviértelo en la pieza principal (torso/coraza).
- Todas las piezas «del cuerpo» deben usar el **mismo** `sub_resource` de material que `Cuerpo` (`Mat_cuerpo`): así el destello al recibir golpes, la telegrafía de ataques y el color de Ruptura afectan a la figura entera. Los detalles (luz del yelmo, ojos, filos) pueden usar otros materiales.
- `Visual` se voltea con `scale.x` según hacia dónde mira el enemigo: modela la figura **mirando hacia +X**.

## Interfaz de lectura (para animar)

`Enemigo` (`scripts/core/enemigos/enemigo.gd`): `estado` (`Enemigo.Estado`: REPOSO, PERSECUCION, ATAQUE, ATURDIDO, RUPTURA, MUERTO), `etapa` durante un ataque (`Enemigo.Etapa`: PREPARACION, ACTIVO, RECUPERACION), `ataque_actual: DatosAtaque`, `tiempo_en_etapa()`, `velocity`, `velocidad`, señales `ataque_telegrafiado(datos)` y `derrotado`. Solo **leer**: la figura no cambia el comportamiento.

## Encargo

Cada figura debe medir lo mismo que su colisión actual y leerse bien de perfil a la distancia de la cámara (siluetas claras, nada de piezas más finas de 0,05 u).

1. **Vigía Hueco** (corpóreo, Realidad): armadura **vacía** con lanza. Yelmo con rendija oscura (sin cara), hombreras, faldón de placas, lanza larga. Anima: paso pesado al perseguir, lanza que retrocede en PREPARACION y se proyecta en ACTIVO, cabeza caída en RUPTURA.
2. **Eco Rezagado** (solo Desfase): figura humana translúcida y alargada, sin rasgos, con jirones que flotan detrás (como la capa de Nereth). Material translúcido azul pálido **sin** modo aditivo (en Compatibility la mezcla aditiva ignora la transparencia). Anima: flota con un vaivén suave; zarpazo con un brazo.
3. **Guardián Partido** (bifásico): armadura pesada **partida en dos mitades** desplazadas entre sí (la mitad trasera algo separada y girada, como si no encajara en el tiempo). Escudo o brazo blindado. Anima: embestida con el hombro adelantado; barrido amplio.
4. **El Prefecto de las Puertas** (jefe): armadura **monumental** (≈ 1,6× Nereth), alabarda, capa larga y una **luz fría en el yelmo** (emisiva azul blanquecina, pequeña). Anima: alabarda en alto en PREPARACION de los golpes descendentes, estocada, giro de barrido. Que la luz del yelmo pulse más fuerte cuando telegrafía.
5. **Rendimiento:** como máximo ~25 mallas por figura y ninguna luz nueva (la luz del yelmo es solo material emisivo). Sin sombras en piezas pequeñas (`cast_shadow = 0`).
6. **Capturas:** usa `tools/captura_sala.gd` (instrucciones en su cabecera) para revisarlas en `scenes/niveles/pruebas/sala_enemigos.tscn` y en el Salón del Prefecto, en Realidad y en Desfase. Describe en «Resultado» qué revisaste.
7. `tests/test_figuras_enemigos.gd`: cada enemigo conserva `Visual/Cuerpo`; tiene varias piezas bajo `Visual` que comparten el material de `Cuerpo` después de `_ready` (comprueba que tras un golpe la emisión se ve en una pieza que no sea `Cuerpo`); la colisión no ha cambiado; el Eco sigue invisible en la Realidad.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto` (incluidas `test_enemigos.gd` y `test_prefecto.gd`, que no deben cambiar).

Commit `[antigravity] Figuras estilizadas de los enemigos (TAREA-012)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

1. **Figuras estilizadas construidas y articuladas:**
   - **Vigía Hueco** (`scenes/enemigos/vigia_hueco/`): Silueta de armadura vacía con yelmo de hendidura oscura frontal, hombreras pesadas, faldón segmentado de placas y una lanza larga con asta y contera. 13 piezas `MeshInstance3D` en total (presupuesto <= 25).
     - *Animación procedural:* `figura_vigia_hueco.gd` modula el balanceo pesado de piernas/brazos al patrullar/perseguir, retracción de lanza en `PREPARACION`, estocada hacia adelante en `ACTIVO`, y caída lánguida de cabeza y hombros durante `RUPTURA`.
   - **Eco Rezagado** (`scenes/enemigos/eco_rezagado/`): Figura humana estilizada y esbelta sin rostro, modelada con material translúcido azul pálido `Color(0.55, 0.72, 1, 0.65)` sin modo aditivo (totalmente compatible con el renderizador Compatibility), con 3 jirones espectrales colgando a modo de estela. 11 piezas `MeshInstance3D` en total.
     - *Animación procedural:* `figura_eco_rezagado.gd` genera ondulación suave vertical/inclinada simulando levitación flotante, zarpazo frontal extendido en ataque y agitación rápida de jirones con arrastre inercial.
   - **Guardián Partido** (`scenes/enemigos/guardian_partido/`): Armadura pesada partida transversalmente en dos mitades temporales desalineadas (la mitad posterior desplazada en altura y girada), con cristales de fractura temporal entre ambas mitades. Brazo izquierdo con escudo blindado curvado y derecho con maza pesada. 12 piezas `MeshInstance3D` en total.
     - *Animación procedural:* `figura_guardian_partido.gd` ejecuta embestida adelantando el hombro y escudo en preparación/ataque, barrido horizontal amplio con la maza y apertura errática de la grieta temporal.
   - **El Prefecto de las Puertas** (`scenes/enemigos/prefecto/`): Armadura monumental ceremonial (≈ 1,6× escala respecto a Nereth), hombreras monumentales escalonadas, alabarda de guardia con cuchilla ceremonial y llave de Elyndor en el pomo, capa larga de 4 segmentos con inercia, y visor con hendidura emisiva fría `Mat_luz_yelmo` sin ningún nodo `Light3D`. 22 piezas `MeshInstance3D` en total (presupuesto <= 25).
     - *Animación procedural:* `figura_prefecto.gd` levanta la alabarda a dos manos en preparación de golpes descendentes, orienta estocadas y giros de barrido, dota de caída física/ondulación a la capa y pulsa la emisión del visor con mayor luminosidad y frecuencia durante la telegrafía de ataques.

2. **Rendimiento e integración con el núcleo:**
   - Todas las piezas conservan intacto `Visual/Cuerpo` como el torso base.
   - Todas las sub-piezas de coraza/cuerpo usan `Mat_cuerpo` (`surface_material_override/0`), permitiendo que el mecanismo de duplicación de material de `Enemigo._ready()` propague automáticamente a toda la figura los destellos de impacto, los colores de telegrafía de ataques y el brillo de Ruptura.
   - Ninguna figura añade nodos de luz (`Light3D`).
   - Las piezas secundarias y detalles finos tienen desactivadas las sombras (`cast_shadow = 0`).
   - Las colisiones físicas originales (`CapsuleShape3D` con sus dimensiones exactas de radio y altura) se preservaron sin modificación alguna.

3. **Revisión visual con `tools/captura_sala.gd`:**
   - Se ejecutaron capturas en `scenes/niveles/pruebas/sala_enemigos.tscn` y `scenes/niveles/pruebas/salon_prefecto.tscn` tanto en Realidad como en Desfase (`captura_sala_enemigos_realidad.png`, `captura_sala_enemigos_desfase.png`, `captura_salon_prefecto_realidad.png`, `captura_salon_prefecto_desfase.png`).
   - Se verificó la correcta lectura de perfiles a la distancia de cámara, la perfecta desaparición del Eco Rezagado en Realidad (`ElementoFase`), la visibilidad de los cristales del Guardián Partido y la imponente silueta del Prefecto frente a las cuatro puertas.

4. **Pruebas automatizadas:**
   - Se creó `tests/test_figuras_enemigos.gd` con 38 aserciones cubriendo: existencia de escenas, preservación de `Visual/Cuerpo`, presupuestos de mallas (<= 25), ausencia de luces `Light3D`, dimensiones de colisión, propagación del material compartido `Mat_cuerpo` y destello de daño a piezas secundarias, e invisibilidad/visibilidad del Eco entre fases.
   - Ejecución: **38 comprobaciones superadas con 0 fallos**.
   - Suite completa con `tools/comprobar.ps1`: `test_enemigos.gd`, `test_figuras_enemigos.gd` y `test_prefecto.gd` superadas con 0 fallos.
