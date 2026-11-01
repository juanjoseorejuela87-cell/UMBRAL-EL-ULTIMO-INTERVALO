# UMBRAL: El Último Intervalo — Guía para agentes

Este archivo es la referencia común para **todos** los agentes de IA que trabajan en el repositorio (Claude Code, Google Antigravity, ChatGPT/Codex). Léelo entero antes de tocar nada.

## Proyecto

- Action RPG con estructura Metroidvania, un jugador, PC Windows.
- **Godot 4.7.2**, **GDScript tipado**. Calidad **escalable** (D-017): debe funcionar en PC modestos (renderizador Compatibility; el equipo de desarrollo tiene una Intel UHD 610) y aprovechar PC potentes (Forward+). Todo efecto caro debe tener alternativa barata o poder desactivarse.
- 2.5D: mundo 3D, movimiento de Nereth sobre un plano lateral (eje X/Y; Z fijo salvo transiciones de profundidad contextuales).
- Documentación de diseño en `documentation/`:
  - `LORE.md` — **historia oficial** (canon). No contradecirla; las dudas se anotan en su §12.
  - `GAMEPLAY.md` — sistemas jugables.
  - `DECISIONES.md` — registro de decisiones (qué, por qué, estado).
  - `ESTADO.md` — hoja de ruta, etapa actual y tareas en curso.
  - `tareas/` — encargos para los ayudantes.

Etiquetas de estado en la documentación: **[CONFIRMADO]** (decidido por el director del proyecto), **[PROPUESTA]** (diseño provisional; puede cambiar), **[PENDIENTE]** (sin definir; no inventar).

## Roles

| Agente | Rol | Qué hace |
|---|---|---|
| **Claude Code** | Programador principal y arquitecto | Arquitectura, sistemas núcleo (`scripts/core/`, jugador, Desfase, Costura, Anclas, combate), revisión e integración de todo lo que entregan los ayudantes, documentación de diseño. |
| **Google Antigravity** | Ayudante de implementación | Tareas acotadas dentro del repo: salas de prueba, enemigos a partir de plantillas existentes, herramientas de editor, pruebas, UI. Solo trabaja sobre un encargo de `documentation/tareas/`. |
| **ChatGPT** | Ayudante creativo y de redacción | Textos: diálogos, descripciones de objetos, ecos de memoria, nombres, conceptos de enemigos y jefes, *prompts* de arte. Entrega texto; no edita código del núcleo. |

El director del proyecto (humano) tiene la última palabra sobre cualquier decisión.

## Protocolo de coordinación

0. **Canal de comunicación:** `comunicacion/CANAL.md`. Al empezar cada sesión, lee los mensajes `ABIERTO` dirigidos a ti y respóndelos. Reglas dentro del propio archivo.
1. **Antes de empezar:** lee `documentation/ESTADO.md` y el encargo que te toca. Si hay cambios sin commit que no son tuyos, no los toques: pueden ser trabajo en curso del otro agente.
1b. **Haz commit solo de tus archivos** (`git add <rutas>`), nunca `git add -A`, porque los agentes comparten la misma carpeta.
2. **Trabaja solo en los archivos que indica tu encargo.** Si necesitas tocar otro, anótalo en el encargo y para.
3. **No modifiques** `scripts/core/`, `project.godot` ni `AGENTS.md` salvo que el encargo lo pida expresamente.
4. **Commits pequeños en `main`**, uno por tarea verificada, con prefijo del agente:
   `[claude] ...`, `[antigravity] ...`, `[chatgpt] ...`.
5. Nunca reescribas historial (`rebase`, `reset --hard`, `push --force`) ni borres trabajo de otro agente. **Nunca uses `git stash`, `git checkout -- <archivo>`, `git reset` ni `git clean` sobre cambios sin commit que no sean tuyos**: la carpeta es compartida y el otro agente puede estar trabajando en ese momento.
6. Al terminar, marca el encargo como `ENTREGADO` y resume qué hiciste y cómo lo probaste. Claude lo revisa y lo marca `ACEPTADO` o `CAMBIOS`.
7. Sin dependencias nuevas (addons, plugins, assets de terceros) sin aprobación registrada en `DECISIONES.md`.

## Convenciones de código

- **Todo tipado**: variables, parámetros y retornos (`var velocidad: float = 0.0`, `func mover(dir: Vector2) -> void`). El proyecto avisa de declaraciones sin tipo.
- Archivos y carpetas en `snake_case`; `class_name` en `PascalCase`; constantes en `MAYUSCULAS`.
- Identificadores en **español sin tildes** (`resonancia`, `desfase`, `salto_variable`); comentarios en español.
- Cada escena junto a su script (`scenes/jugador/nereth.tscn` + `nereth.gd`). Código compartido en `scripts/`.
- Valores de ajuste como `@export` o en recursos `.tres`, nunca "números mágicos" repartidos por el código.
- Comunicación entre sistemas por **señales**; los autoloads solo para estado verdaderamente global.
- Indentación con tabuladores; UTF-8; saltos de línea LF (ver `.editorconfig`).

## Estructura

```
assets/        audio, fuentes, sprites, modelos
scenes/        escenas por dominio (jugador/, niveles/, enemigos/, ui/...)
scripts/       código compartido; scripts/core/ = núcleo (solo Claude)
documentation/ diseño, decisiones, estado, encargos
```

## Probar

Godot está en `D:\`. Pruebas sin ventana:

```
D:\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\UMBRAL --import
D:\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\UMBRAL --quit-after 120
```

Comprobación completa (sincroniza con `--ff-only`, muestra el estado de los encargos y ejecuta todas las pruebas de `tests/`):

```
powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1
```

Una entrega sin errores ni avisos nuevos en la salida es requisito para `ENTREGADO`.
