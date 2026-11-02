extends Node3D
## Brasero gótico con cuenco de metal y llama oscilante sin coste de iluminación.
## Opcionalmente soporta luz puntual si la sala cuenta con presupuesto de rendimiento.

@export var con_luz: bool = false

@onready var _llama: MeshInstance3D = get_node_or_null("Llama") as MeshInstance3D
@onready var _luz: OmniLight3D = get_node_or_null("Luz") as OmniLight3D

var _tiempo: float = 0.0
var _escala_base: Vector3 = Vector3.ONE


func _ready() -> void:
	if _luz:
		_luz.visible = con_luz
	if _llama:
		_escala_base = _llama.scale


func _process(delta: float) -> void:
	if not _llama:
		return
	_tiempo += delta * 6.0
	var ondulacion_y: float = 1.0 + sin(_tiempo) * 0.08 + sin(_tiempo * 2.3) * 0.04
	var ondulacion_xz: float = 1.0 + cos(_tiempo * 1.7) * 0.05
	_llama.scale = Vector3(
		_escala_base.x * ondulacion_xz,
		_escala_base.y * ondulacion_y,
		_escala_base.z * ondulacion_xz
	)
