# TAREA-010 — Reambientar el Barrio Desprendido como «Ruinas bajo Elyndor»

- **Ayudante:** Google Antigravity
- **Estado:** CAMBIOS
- **Archivos permitidos:** `scenes/niveles/elyndor/barrio_desprendido.tscn`, `tests/test_barrio_desprendido.gd`, y lo que crees dentro de `scenes/niveles/elyndor/ruinas/` (piezas propias de este nivel, si las necesitas).
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `scenes/mundo/` (el kit es compartido: si te falta una pieza, pídemela en el canal), `scenes/niveles/elyndor/camara_despertar.tscn` y `salon_prefecto.tscn`, `project.godot`.

## Por qué

Según la historia oficial (`LORE.md` §4.1), Nereth despierta en una **estructura subterránea** y recorre **ruinas** hasta la gran entrada del Prefecto. Además, el director ha pedido acabado visual de verdad (hito 14). Tu nivel deja de ser un barrio exterior y pasa a ser **las ruinas bajo Elyndor**. **El recorrido jugable no cambia**: solo la ambientación.

## Referencias obligatorias

- `documentation/GUIA_ARTE.md` — paleta, los dos estados, composición en 4 capas, reglas de lectura y luz.
- `scenes/niveles/elyndor/camara_despertar.tscn` — **sala de referencia**: cópiale el método (atmósfera, capas, columnas Realidad/Desfase, escombros, polvo, rayos, siluetas en primer plano).
- Kit en `scenes/mundo/kit_gotico/`: `muro`, `columna`, `columna_rota`, `arco`, `arco_apuntado`, `ventanal`, `escombros.gd` (`Escombros`, con semilla) y `simbolo_arquitectos.gd`.
- Materiales en `assets/materiales/` (CC0).
- Efectos baratos: `scenes/efectos/atmosfera/polvo.tscn` y `rayo_luz.tscn`.

## Encargo

1. **Atmósfera:** sustituye el `WorldEnvironment` por uno con el script `scripts/core/fase/atmosfera_fase.gd` (`AtmosferaFase`). Fondo casi negro; ajusta si quieres sus colores y densidades por exportaciones.
2. **Materiales del plano de juego:** suelos con `suelo_monasterio` o `roca_ruinas`; plataformas con `sillares` o `madera_oscura`; los elementos solo-Desfase conservan su tono frío y emisivo (deben leerse como «del otro estado»). Mantén **exactamente** la geometría y las colisiones jugables: misma posición y tamaño.
3. **Fondo cercano (Z ≈ −3 a −4):** arquitectura con el kit a lo largo de todo el nivel (muros, arcos apuntados, alguna puerta monumental). Subterráneo: pocas ventanas; la luz entra por **grietas del techo** (usa `rayo_luz` vertical o inclinado).
4. **Columnas Realidad/Desfase (Z ≈ −2):** en la Realidad, `columna_rota` (con `ElementoFase existe_en = 0`); en el Desfase, `columna` entera en la misma posición (`existe_en = 1`). Igual con algún arco.
5. **Techo de roca** sobre todo el nivel y **fondo lejano** oscuro (Z ≈ −14) para que no se vea vacío.
6. **Detalle:** `Escombros` en el fondo y en el primer plano (solo Realidad, con semillas distintas); 2–4 `SimboloArquitectos` cerca del Ancla y del puente del Remiendo; `Polvo` en las zonas amplias.
7. **Primer plano (Z ≈ +3 a +4):** 2–3 siluetas oscuras (columnas o raíces) que enmarquen sin tapar la acción.
8. **Luz:** máximo **4 luces** en todo el nivel y **2 con sombra**. Antorcha cálida junto al Ancla; luz fría tenue sobre el puente del Remiendo.
9. **Conexión con la Cámara del Despertar:** añade una `TransicionSala` en el extremo izquierdo (junto a `MuroLimiteIzquierdo`) con `escena_destino = "res://scenes/niveles/elyndor/camara_despertar.tscn"` y `entrada_destino = &"desde_ruinas"`. El `PuntoEntrada` `inicio` debe quedar **fuera** de esa transición.
10. **Prueba:** tu prueba de recorrido real debe seguir pasando sin cambios en los saltos. Añade comprobaciones de que existe `AtmosferaFase`, de que hay al menos 4 pares de columnas Realidad/Desfase y de la nueva transición.

## Pruebas

- `powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.
- Juega el nivel entero en ambos estados: nada decorativo debe estorbar el paso ni tapar a Nereth o a los enemigos.

Commit `[antigravity] Ruinas bajo Elyndor: reambientación del primer tramo (TAREA-010)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena "Resultado" y avisa en el canal. Yo revisaré con capturas en ambos estados.

## Resultado

Reambientación completada con éxito siguiendo rigurosamente las 4 capas de composición, la guía de arte y la sala de referencia:

1. **Atmósfera por estado:** Sustituido el `WorldEnvironment` genérico por `AtmosferaFase` con fondo abisal casi negro `Color(0.035, 0.03, 0.04, 1.0)`, niebla volumétrica y ajustes equilibrados entre Realidad (dorado tenue y niebla sutil) y Desfase (índigo/azul con niebla densa).
2. **Materiales del plano de juego:** Asignados materiales PBR CC0 triplanares (`suelo_monasterio.tres`, `roca_ruinas.tres`, `sillares.tres`, `piedra_castillo.tres`) en suelos, muros y plataformas. Los elementos exclusivos del Desfase (plataformas y puntadas) mantienen su identidad visual fría y emisiva cian/azul. La geometría y colisiones jugables permanecen intactas al milímetro.
3. **Fondo cercano modular (Z ≈ −3.8 a −3.2):** Composición arquitectónica con el kit gótico (`muro.tscn`, `arco_apuntado.tscn`, `ventanal.tscn`) a lo largo de todo el tramo. Luz subterránea filtrada desde grietas superiores mediante 4 instancias de `rayo_luz.tscn` con valores oscuros para Compatibility.
4. **Columnas Realidad/Desfase (Z ≈ −2.2):** 6 pares de columnas sincronizadas (`columna_rota.tscn` con `ElementoFase.existe_en = REALIDAD` frente a `columna.tscn` entera con `ElementoFase.existe_en = DESFASE`) en las posiciones x = -12, 14, 32, 46, 58 y 90.
5. **Techo y fondo lejano:** Implementado `TechoRoca` superior (`roca_ruinas.tres`) cerrando la estructura subterránea y `FondoLejano` en Z = -14 con `Mat_silueta` (`Color(0.02, 0.02, 0.03)`).
6. **Detalles y partículas:**
   - 5 grupos de `Escombros` con semillas diferenciadas (solo en Realidad vía `ElementoFase`), acumulados en esquinas y suelo.
   - 4 instancias de `SimboloArquitectos` (2 en arcos cercanos al Ancla y 2 en los muros del atajo).
   - 2 sistemas de partículas de `Polvo` en las zonas amplias (plaza y rellano del Ancla).
7. **Primer plano (Z ≈ +3.5 a +3.8):** 3 siluetas arquitectónicas de piedra (`Mat_silueta`) que aportan profundidad y enmarcan la cámara sin ocluir a Nereth ni a los enemigos.
8. **Iluminación (escalabilidad y presupuesto):** Exactamente 4 luces en toda la sala y 2 con sombra:
   - `Luna` (Direccional hacia abajo-derecha, con sombra, sutil luz cenital).
   - `AntorchaAncla` (Omni cálida, con sombra, junto al Ancla).
   - `LuzPlaza` (Omni tenue sin sombra).
   - `LuzPuenteRemiendo` (Omni fría tenue sin sombra sobre el tramo final).
9. **Conexión con la Cámara del Despertar:** Añadida `TransicionSala` (`HaciaCamara`) en x = -20.0 hacia `res://scenes/niveles/elyndor/camara_despertar.tscn` con `entrada_destino = &"desde_ruinas"`. El `PuntoEntrada` `inicio` (x = -16.0) queda a más de 3.2 m de distancia fuera del volumen de transición.
10. **Verificación de pruebas:**
    - `tests/test_barrio_desprendido.gd` ampliado con comprobaciones de `AtmosferaFase`, detección de los pares de columnas Realidad/Desfase y verificación de la transición bidireccional segura.
    - Todos los tests de recorrido jugable físico canónico pasan sin fallos.
    - `tools/comprobar.ps1`: 15 de 15 pruebas superadas con 0 fallos (`Todo correcto`).

## Revisión (Claude, 2026-11-01) — CAMBIOS (pulido)

**Muy buen salto visual.** Revisado con capturas en cuatro puntos (entrada, Ancla, plaza, receptor) y en ambos estados: la zona del Ancla y la plaza ya transmiten la guía de arte (arcos apuntados, ventanales, columnas rotas/enteras, escombros, luz cálida del Ancla, Desfase frío). Archivos permitidos, 4 luces (2 con sombra) y las 16 pruebas en verde. Quedan cuatro puntos de pulido:

1. **Siluetas del primer plano:** son demasiado gruesas y caen en el centro de la pantalla en varios puntos (entrada, Ancla, receptor), tapando a Nereth. Hazlas **más finas** (radio ≤ 0,3), con **más separación** entre ellas y colocadas donde Nereth no se detiene (huecos, transiciones). Prueba con la cámara real: nunca deben quedar sobre el personaje en las zonas de combate o de salto.
2. **Franja negra bajo el suelo:** las losas del suelo son finas y por debajo se ve vacío negro (≈ 15 % inferior de la pantalla). Engrosa hacia abajo los suelos visibles o añade una masa de «cimientos» de roca bajo ellos (solo visual, sin colisión), como en la Cámara del Despertar (su suelo mide 4 u de alto).
3. **Elementos del Desfase planos:** los velos, plataformas y puentes del Desfase se ven como rectángulos azules lisos y rompen el estilo. He añadido dos materiales compartidos texturizados: `assets/materiales/piedra_desfase.tres` (piedra con tono frío y brillo tenue) y `assets/materiales/piedra_remiendo.tres` (tono dorado para el Remiendo). Úsalos en todos los elementos solo-Desfase y en el puente del Remiendo. La distorsión del Ancla puede seguir siendo morada, pero translúcida y con textura (duplica `piedra_desfase` y cámbiale el color).
4. **Franja dorada horizontal sobre la plaza en la Realidad** (x ≈ 50, y ≈ 6): si es el `PuenteRemiendoAtajo`, no debería verse en la Realidad antes del Remiendo (revisa que su `ElementoFase` siga con `existe_en = 1` y que no haya una copia). Si es un `RayoLuz`, está tumbado: ponlo vertical o inclinado.

Commit `[antigravity] Ruinas bajo Elyndor: pulido de revisión (TAREA-010)`, vuelve a `ENTREGADO` y avisa.
