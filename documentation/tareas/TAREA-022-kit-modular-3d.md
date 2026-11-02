# TAREA-022 — Primer paquete de piezas 3D del kit (según los artes conceptuales)

- **Ayudante:** Google Antigravity (coordinación de modelos 3D por encargo del director)
- **Estado:** ABIERTO
- **Archivos permitidos:** `assets/modelos/kit/<pieza>/` (nuevo: `.glb`, texturas, imagen de referencia) y `assets/LICENCIAS.md` (añadir filas). Scripts de generación nuevos en `tools/blender/` si los necesitas.
- **No tocar:** escenas (`scenes/`), `scripts/core/`, `project.godot`. **Claude integra** las piezas en las salas.

## Referencias

- Artes conceptuales oficiales en `documentation/arte/concepto_*.png`.
- Requisitos técnicos y de licencia: `documentation/ESPECIFICACION_MODELOS.md` (léelo entero): **≤ 3 000 triángulos por pieza de escenario**, texturas 1K PBR, ≤ 3 materiales, 1 u = 1 m, pies/base en el origen.
- **Ojo con el metal:** el juego usa Compatibility en este equipo, sin reflejos: un material con `metallic` alto se ve **negro**. Metal como mucho 0,3 y rugosidad ≥ 0,5; el brillo del latón o del hierro, en el color y la textura.

## Encargo — 8 piezas

| Pieza | Sala | Referencia | Medidas aproximadas |
|---|---|---|---|
| `puerta_ojival` | Salón del Prefecto | arco de las puertas del concepto del Salón | 3 × 6 m, con hojas de madera y herrajes |
| `mecanismo_engranajes` | Salón del Prefecto | los engranajes de los muros del concepto | disco de 3–4 m de diámetro, plano (va en el muro del fondo) |
| `farola_forja` | Barrio / Ruinas | farolas del concepto del Barrio | 3 m de alto; farol con material emisivo, **sin luz** |
| `barandilla_ornamental` | Barrio / Ruinas | barandilla de hierro del concepto | tramo de 4 m |
| `arcada_primer_plano` | Barrio / Ruinas | arco oscuro del primer plano con cadena colgando | 4 × 7 m; silueta para la capa delantera |
| `columna_capitel` | Cámara del Despertar | columnas con capitel tallado del concepto | 6 m de alto |
| `arco_apuntado_doble` | Cámara del Despertar | arcadas dobles del fondo | 6 × 7 m |
| `brasero_tripode` | Cámara del Despertar | braseros sobre trípode del concepto | 1,2 m; cuenco con llama emisiva, **sin luz** |

Para las piezas que lo necesiten, una variante **rota** (Realidad) y otra **entera** (Desfase), como en el kit actual (`_rota` en el nombre): al menos `columna_capitel` y `arco_apuntado_doble`.

**Método libre** dentro de licencias comerciales verificadas: modelado por script en Blender (`tools/blender/`), TripoSR local o TRELLIS.2 a partir de recortes de los conceptos, y limpieza en Blender. Si partes de un recorte de un concepto, guárdalo en `assets/modelos/kit/<pieza>/referencia/`.

## Entrega

1. Un `.glb` por pieza (y su variante rota) en `assets/modelos/kit/<pieza>/`.
2. Revisa cada una con `tools/vista_modelo.gd` y anota en «Resultado» triángulos y medidas, y que no se ve negra.
3. **Licencias:** una fila por archivo en `assets/LICENCIAS.md` con la **herramienta exacta** usada (y si partes de un concepto, la del concepto). Para los cuatro conceptos aún falta saber con qué herramienta se hicieron: si lo sabes, indícalo; si no, lo confirmo con el director.
4. Nada se publica fuera del repositorio privado (D-043). Nada de TripoSR mientras corren las pruebas.

Commit `[antigravity] Kit modular 3D, primer paquete (TAREA-022)` solo con los archivos permitidos. Marca `ENTREGADO`, rellena «Resultado» y avisa en el canal.

## Resultado

_(lo rellena Antigravity)_
