# Especificación de modelos 3D

Requisitos para **cualquier** modelo 3D que entre en el juego, lo cree una persona o una IA de modelado. Claude revisa cada entrega con `tools/vista_modelo.gd` antes de integrarla.

## 1. Licencia (obligatorio, D-032)

- Solo herramientas y recursos que permitan **uso comercial** del resultado (el juego se venderá).
- Cada modelo se anota en `assets/LICENCIAS.md` en la misma entrega: archivo, herramienta (y versión o fecha), licencia de la herramienta y de cualquier imagen de referencia usada, autor.
- Sin licencia registrada, el modelo no entra en `main`.

## 2. Diseño

- Fuente de verdad: `documentation/GUIA_ARTE.md` y las hojas de personaje del director en `documentation/arte/`. No inventar rasgos que contradigan la hoja ni el `LORE.md`.
- Contraste Realidad/Desfase: los elementos que cambian con el estado (marcas, fragmentos, tela) en piezas o materiales separados para poder animarlos o teñirlos por código.

## 3. Formato y técnica

| Requisito | Valor |
|---|---|
| Formato | `.glb` (glTF 2.0 binario), texturas incrustadas |
| Escala | 1 unidad = 1 metro; Nereth mide 1,82 |
| Orientación | Mirando a **+X** (el juego es lateral); pies en el origen (y = 0) |
| Pose | T o A, manos vacías (armas como modelos aparte) |
| Triángulos | Personaje jugable ≤ 15 000; enemigo común ≤ 10 000; jefe ≤ 25 000; pieza de escenario ≤ 3 000 |
| Texturas | 1K (2K opcional para preajustes Alto/Ultra), PBR: color base, normal, rugosidad/metal |
| Materiales | ≤ 3 por modelo |
| Esqueleto | Humanoide compatible con Mixamo o con el retargeting de Godot (nombres de huesos estándar) |
| Animaciones (personajes) | quieto, caminar, correr, saltar (subida/caída), esquivar, ataque ligero ×3, ataque pesado, guardia, parry, recibir daño, aturdido, morir |

## 4. Entrega

- Carpeta: `assets/modelos/<nombre>/` (`<nombre>.glb` + imagen de referencia si la hay).
- Comprobación propia antes de entregar: `Godot_console.exe --path D:\UMBRAL -s res://tools/vista_modelo.gd --write-movie <ruta>\f.png --fixed-fps 10 --quit-after 40 -- res://assets/modelos/<nombre>/<nombre>.glb` → revisar las capturas, triángulos y medidas que imprime.
- Claude integra el modelo en las escenas (los modelos no tocan `scenes/jugador/`, `scenes/enemigos/` ni `scripts/core/`).
