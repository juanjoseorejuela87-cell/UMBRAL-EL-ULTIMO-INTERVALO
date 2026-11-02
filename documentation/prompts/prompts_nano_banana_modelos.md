# Prompts para Nano Banana: imágenes de referencia para modelos 3D (TRELLIS.2)

TRELLIS convierte **una** imagen en un modelo 3D. Cuanto más limpia y «de catálogo» es la imagen, mejor sale el modelo. Reglas para todas:
- **Un solo objeto o personaje**, entero, centrado, sin nada delante ni detrás.
- **Fondo blanco liso**, luz suave y uniforme, sin sombras fuertes.
- Vista **frontal de tres cuartos** (o frontal para personajes en pose en T).
- Nada recortado por los bordes.

Genera cada imagen en la app de Gemini (Nano Banana), descárgala y guárdala en la carpeta indicada. Después se convierte a 3D con `tools/generar_trellis.py` y se prepara en Blender.

---

## 1. Nereth (prioridad máxima)

Guardar en `assets/modelos/nereth/referencia/nereth_pose_t.png`. Adjunta la hoja de personaje (`documentation/arte/nereth_hoja_personaje.png`) en la conversación para que mantenga el diseño.

```
Using the attached character sheet as the exact design reference, create a single full-body image of Nereth for 3D modeling: a young man, 1.82 m, athletic and slim, messy black hair over the face, high collar, light dark armor with silver edges and glowing violet continuity marks on the arm, floating shard fragments near the left shoulder. Pose: strict T-pose, arms straight out horizontally, legs slightly apart, hands open, standing upright, facing the camera. IMPORTANT: no cape and no long coat tails, so the arms, torso and legs are fully visible and separated. Whole body visible from head to feet, centered, plain pure white background, soft even studio lighting, no shadows on the background, realistic game character style, high detail, no text, no frame.
```

Y la capa por separado, en `assets/modelos/nereth/referencia/nereth_capa.png`:

```
The long tattered dark cloak of the character in the attached sheet, shown alone without any body inside, as if hanging from invisible shoulders, front three-quarter view, whole cloak visible, torn and frayed lower edges, dark charcoal fabric with subtle violet lining, plain pure white background, soft even studio lighting, realistic game asset style, no text.
```

## 2. Piezas del kit (TAREA-022)

Una imagen por pieza, en `assets/modelos/kit/<pieza>/referencia/<pieza>.png`. Plantilla (cambia la descripción en mayúsculas):

```
A single 3D game asset for a dark gothic fantasy game: DESCRIPCIÓN. Shown alone, whole object visible, centered, front three-quarter view, plain pure white background, soft even studio lighting, realistic stylized game asset, high detail, no text, no frame.
```

| Pieza | DESCRIPCIÓN |
|---|---|
| `puerta_ojival` | a monumental gothic pointed-arch double door, 6 meters tall, dark oak planks with forged iron hinges and studs, set in a carved stone frame |
| `mecanismo_engranajes` | a large ancient clockwork mechanism of interlocking brass and bronze gears of different sizes mounted on a round stone plate, engraved with mysterious circular symbols |
| `farola_forja` | a medieval wrought-iron street lamp post, 3 meters tall, ornate base, glowing amber glass lantern on top |
| `barandilla_ornamental` | a straight section of ornate gothic wrought-iron railing with pointed arches and spikes, 4 meters long |
| `arcada_primer_plano` | a dark weathered stone gothic archway with a heavy iron chain hanging from it |
| `columna_capitel` | a tall gothic stone column with a richly carved capital and a square base |
| `columna_capitel_rota` | the same tall gothic stone column broken in half, jagged fracture at the top, fallen stone chunks at its base |
| `arco_apuntado_doble` | a gothic double pointed arch in carved stone supported by three slender columns |
| `arco_apuntado_doble_roto` | the same gothic double pointed arch partially collapsed, right arch broken, fallen stones on the ground |
| `brasero_tripode` | a medieval iron brazier on a three-legged tripod stand with claw feet, burning embers and flames in the bowl |
