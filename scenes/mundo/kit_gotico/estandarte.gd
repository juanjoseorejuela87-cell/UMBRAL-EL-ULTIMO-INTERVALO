class_name Estandarte
extends MeshInstance3D
## Estandarte de tela rasgada que se mece despacio (solo visual).

@export var balanceo_grados: float = 3.0
@export var velocidad: float = 0.5

var _tiempo: float = 0.0
var _rotacion_base: Vector3


func _ready() -> void:
	_rotacion_base = rotation
	_tiempo = randf() * TAU


func _process(delta: float) -> void:
	_tiempo += delta * velocidad
	rotation = _rotacion_base + Vector3(deg_to_rad(balanceo_grados) * sin(_tiempo), 0.0, deg_to_rad(balanceo_grados * 0.4) * sin(_tiempo * 1.7))
