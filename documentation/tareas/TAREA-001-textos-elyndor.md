# TAREA-001 — Textos narrativos de la vertical slice de Elyndor

- **Ayudante:** ChatGPT → hecho por Claude con Gemini 3.5 Flash (decisión del director, 2026-11-02)
- **Estado:** ACEPTADO
- **Entrega:** un único documento Markdown que el director guardará como `documentation/propuestas/elyndor_textos.md`.

## Encargo (copiar y pegar a ChatGPT)

> Eres guionista de apoyo del videojuego **UMBRAL: El Último Intervalo**, un Action RPG Metroidvania 2.5D de fantasía oscura gótica. Te adjunto `LORE.md` y `GAMEPLAY.md` (pégalos a continuación). Todo lo que escribas es **propuesta**: `LORE.md` contiene ya la **historia oficial**; no la contradigas. En Elyndor el jugador todavía no sabe nada de los Arquitectos, la Permanencia ni el Primer Testigo: los textos solo pueden **insinuar** (principio narrativo 4: pistas antes de las revelaciones). Maelis aparece solo como una voz que pronuncia el nombre de Nereth y como rastros de alguien que lo conoce.
>
> Escribe en español, tono sobrio, críptico y melancólico; frases cortas; nada de humor moderno ni referencias a otras obras. Entrega:
>
> 1. **5 ecos de memoria** de Elyndor (escenas del pasado que Nereth percibe en el Desfase): título, lugar dentro de la ciudad, 3–6 líneas de texto, y si alguno insinúa una ruta oculta, indícalo.
> 2. **Diálogo del Prefecto de las Puertas**: 2–3 líneas al empezar el combate, 1 línea al pasar a cada fase (2 y 3), 2–3 líneas al ser derrotado.
> 3. **3 habitantes de Elyndor** atrapados en bucles: nombre, qué gesto repiten, 2–4 líneas de diálogo cada uno.
> 4. **3 Vestigios**: nombre, descripción del objeto (2–3 líneas de ambientación) y efecto propuesto (ventaja y desventaja).
> 5. **Descripción de 3 enemigos** (un corpóreo, un eco y un bifásico): nombre, aspecto en 2 líneas, comportamiento en 2 líneas, coherentes con `GAMEPLAY.md` §3.5.
> 6. **Descripciones de objeto** para: Espada del Umbral, Esencia (curación), Hebra (moneda) y el primer Fragmento de Continuidad.
>
> Formato: Markdown con un encabezado por apartado. No añadas personajes con nombre fuera de los pedidos.

## Criterios de aceptación (los revisa Claude)

- Respeta el canon de `LORE.md` y no desarrolla Maelis ni revelaciones centrales.
- Encaja con las mecánicas de `GAMEPLAY.md`.
- Textos cortos, aptos para pantalla de juego.

## Resultado

Entregado en `documentation/propuestas/elyndor_textos.md`: generado con Gemini 3.5 Flash (`tools/gemini_texto.py`, solo con extractos del canon de Elyndor) y revisado por Claude (cinco correcciones de canon y coherencia, listadas en el documento). Los cinco ecos están integrados en la Cámara, las Ruinas y el Salón (`tests/test_eco_memoria.gd` comprueba que los de las Ruinas tienen suelo en el Desfase). El diálogo del Prefecto, los habitantes y los Vestigios quedan como propuesta hasta tener esos sistemas.
