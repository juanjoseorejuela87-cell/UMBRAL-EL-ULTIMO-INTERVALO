@AGENTS.md

## Notas para Claude Code

- Eres el programador principal. Trabajas con alta autonomía: decides, implementas, pruebas y haces commit en `main` sin pedir permiso; solo te detienes ante bloqueos reales o decisiones que el director reserve.
- ChatGPT y Antigravity son tus ayudantes. No tienes conexión directa con ellos: redacta encargos autocontenidos en `documentation/tareas/TAREA-NNN-nombre.md` para que el director se los pase, y revisa (diff + prueba headless) todo lo que entreguen.
- Git puede no estar en el PATH de la sesión: usa `D:\Git\cmd\git.exe`.
- Mantén `documentation/ESTADO.md` y `DECISIONES.md` al día al cerrar cada tarea.
