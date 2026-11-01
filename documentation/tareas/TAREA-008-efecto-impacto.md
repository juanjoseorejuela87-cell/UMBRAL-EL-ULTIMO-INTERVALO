# TAREA-008 — Efecto visual de impacto

- **Ayudante:** Google Antigravity
- **Estado:** ENTREGADO
- **Archivos permitidos:** todo lo que crees en `scenes/efectos/impacto/` (escena principal: `scenes/efectos/impacto/impacto.tscn`); `tests/test_efecto_impacto.gd`.
- **No tocar:** `scripts/core/`, `scenes/jugador/`, `scenes/enemigos/`, `project.godot`.

## Contexto

En el hito 10 Claude está añadiendo el autoload **`Impactos`** (`scripts/core/efectos/director_impactos.gd`), que ya gestiona la parada de impacto y el temblor de cámara. Cuando un golpe conecta, `Impactos` hará esto:

```gdscript
var efecto := load("res://scenes/efectos/impacto/impacto.tscn").instantiate()
get_tree().current_scene.add_child(efecto)
efecto.global_position = posicion_del_golpe
efecto.configurar(tipo)  # tipo: &"golpe", &"critico", &"parry", &"herida", &"desfase"
```

Si la escena no existe, no hace nada; así que puedes trabajar sin esperarme.

## Encargo

1. `impacto.tscn`: raíz `Node3D` con `class_name EfectoImpacto` y método `configurar(tipo: StringName) -> void`.
2. Una breve explosión de chispas (0,2–0,4 s) con **`CPUParticles3D`** (no `GPUParticles3D`: GPU integrada y renderizador Compatibility), en modo `one_shot`, que **se libera sola** al terminar (`queue_free`).
3. Variantes según `tipo`:
   - `golpe`: chispas blancas, pocas (8–12).
   - `critico` (Golpe de Umbral): más (20–30), doradas, algo más grandes y con un destello breve (`OmniLight3D` que se apaga en 0,1 s).
   - `parry`: anillo/estallido azul-blanco.
   - `herida` (Nereth recibe daño): rojizo, pocas.
   - `desfase`: partículas azul frío que se dispersan despacio.
4. Barato: materiales sin sombreado (`unshaded`), sin sombras, ≤ 30 partículas por efecto.
5. `tests/test_efecto_impacto.gd`: instancia cada tipo, comprueba que existe un `CPUParticles3D` emitiendo y que el nodo se libera solo en menos de 1,5 s.

## Pruebas

`powershell -ExecutionPolicy Bypass -File D:\UMBRAL\tools\comprobar.ps1` → `Todo correcto`.

Commit `[antigravity] Efecto visual de impacto (TAREA-008)`, solo con los archivos permitidos. Marca `ENTREGADO`, rellena "Resultado" y avisa en el canal.

## Resultado

- Creados `scenes/efectos/impacto/impacto.gd` y `scenes/efectos/impacto/impacto.tscn`:
  - Raíz `Node3D` con `class_name EfectoImpacto` y método `configurar(tipo: StringName) -> void`.
  - Sistema de partículas con `CPUParticles3D` (`one_shot = true`, `explosiveness = 1.0`, `cast_shadow = 0`), con material `StandardMaterial3D` `unshaded` y `vertex_color_use_as_albedo`.
  - Configuración por variantes respetando el límite de rendimiento (≤ 24 partículas):
    - `golpe`: 10 chispas blancas rápidas.
    - `critico`: 24 partículas doradas más enérgicas + destello `OmniLight3D` apagado en 0.1 s vía Tween.
    - `parry`: 20 partículas azul-blanco con dispersión radial y estallido luminoso breve (0.08 s).
    - `herida`: 10 partículas rojizas con caída rápida.
    - `desfase`: 18 partículas azul frío de dispersión suave y flotante.
  - Auto-liberación (`queue_free`) al concluir la emisión (enlace a `finished` y temporizador de seguridad de ~0.4–0.5 s).
- Creado `tests/test_efecto_impacto.gd` validando los 5 tipos, verificación de `CPUParticles3D` emitiendo en `one_shot`, cantidad ≤ 30 y liberación automática en < 1.5 s (t real ≈ 0.13–0.25 s).
- Comprobación completa con `tools/comprobar.ps1`: 13 de 13 suites pasadas con 0 fallos (`Todo correcto`).
