# TAREA-010 — Reambientar el Barrio Desprendido como «Ruinas bajo Elyndor»

- **Ayudante:** Google Antigravity
- **Estado:** ABIERTO
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

_(Rellenar al entregar.)_
