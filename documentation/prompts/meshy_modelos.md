# Meshy AI: cómo generar los modelos de UMBRAL

Usa **Image to 3D** con las imágenes limpias que ya están en el repositorio. Para vender el juego, genera con una **cuenta de pago** (en el plan gratuito los modelos suelen ser públicos y con licencia que exige crédito; compruébalo en tu cuenta).

## 1. Nereth (personaje jugable, con esqueleto y animaciones)

1. **Image to 3D** → sube `assets/modelos/nereth/referencia/nereth_pose_t.png`.
2. Ajustes:
   - **Topology:** Quad · **Target polycount:** 15 000 (o «Low/Medium»)
   - **Symmetry:** On · **Pose:** T-pose (o A-pose)
   - **Texture:** On, **PBR:** On
   - **Texture prompt** (si te lo pide):
     ```
     Dark gothic fantasy hero, matte black leather and dark charcoal armor plates with thin polished silver edges, glowing violet energy lines on the left arm, pale skin, messy jet black hair, realistic game character textures, high detail
     ```
3. Cuando esté, **Rig & Animate** (Animate / Auto-rig):
   - Tipo: **Humanoid** · coloca los marcadores (barbilla, muñecas, codos, rodillas, ingle) si te los pide.
   - Animaciones (las que ofrezca más parecidas): **Idle, Walk, Run, Jump, Dodge/Roll, Sword Slash (×2–3), Heavy Attack, Block, Hit Reaction, Death**.
4. **Download → GLB** (con *skin* y animaciones) y guárdalo en `assets/modelos/nereth/fuente/nereth_meshy.glb`.

La **capa** (`assets/modelos/nereth/referencia/nereth_capa.png`) se genera aparte, sin rig: Image to 3D, Target polycount 5 000, textura On; descarga `nereth_capa_meshy.glb` en la misma carpeta.

## 2. Piezas del kit (escenario, sin rig)

Para cada imagen de `assets/modelos/kit/<pieza>/referencia/`:
- **Image to 3D** · **Target polycount:** 3 000 · **Topology:** Triangle o Quad · **Texture:** On, PBR On.
- **Texture prompt** general:
  ```
  Weathered gothic stone and aged iron, moss in the cracks, realistic game environment asset textures, high detail
  ```
  (para los engranajes: `aged brass and bronze gears on carved grey stone with runes`; para el brasero y el farol: `dark forged iron, glowing embers`).
- **Download → GLB** como `assets/modelos/kit/<pieza>/<pieza>_meshy.glb`.

Orden recomendado: puerta ojival, engranajes, columna, columna rota, arco doble, arco doble roto, arcada con cadena, barandilla, farol colgante, brasero.

## 3. Después

Avisa a Claude: revisa cada modelo, lo ajusta a tamaño y orientación, baja el metal para que no se vea negro en equipos modestos, integra las animaciones de Nereth y anota la licencia en `assets/LICENCIAS.md` (plan de Meshy y fecha).
