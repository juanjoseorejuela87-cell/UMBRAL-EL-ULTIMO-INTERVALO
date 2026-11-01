class_name CamaraLateral
extends Camera3D
## Cámara lateral 2.5D: sigue a Nereth con suavizado y adelanto hacia donde mira.

@export var objetivo: Nereth
@export var distancia: float = 15.0
@export var altura: float = 3.0
@export var campo_vision: float = 50.0
@export var adelanto: float = 1.8
@export var suavizado: float = 6.0
@export var suavizado_adelanto: float = 2.5
@export var inclinacion_grados: float = 0.0

var _adelanto_actual: float = 0.0


func _ready() -> void:
	rotation_degrees.x = inclinacion_grados
	fov = campo_vision
	if objetivo:
		objetivo.reaparecido.connect(saltar_a_objetivo)
		saltar_a_objetivo()


## Coloca la cámara en su sitio sin suavizado (inicio, reapariciones).
func saltar_a_objetivo() -> void:
	if objetivo:
		_adelanto_actual = adelanto * objetivo.mirando
		global_position = _posicion_deseada()


func _physics_process(delta: float) -> void:
	if not objetivo:
		return
	_adelanto_actual = lerpf(_adelanto_actual, adelanto * objetivo.mirando, 1.0 - exp(-suavizado_adelanto * delta))
	global_position = global_position.lerp(_posicion_deseada(), 1.0 - exp(-suavizado * delta))


func _posicion_deseada() -> Vector3:
	var foco: Vector3 = objetivo.global_position
	return Vector3(foco.x + _adelanto_actual, foco.y + altura, foco.z + distancia)
