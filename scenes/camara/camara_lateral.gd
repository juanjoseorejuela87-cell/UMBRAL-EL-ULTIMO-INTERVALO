class_name CamaraLateral
extends Camera3D
## Cámara lateral 2.5D: sigue a Nereth con suavizado y adelanto hacia donde mira.
## Admite temblor (golpes, impactos) que se suma sin alterar el seguimiento.

@export var objetivo: Nereth
@export var distancia: float = 15.0
@export var altura: float = 3.0
@export var campo_vision: float = 50.0
@export var adelanto: float = 1.8
@export var suavizado: float = 6.0
@export var suavizado_adelanto: float = 2.5
@export var inclinacion_grados: float = 0.0
## Multiplica todos los temblores (0 = desactivado; opción de accesibilidad).
@export_range(0.0, 2.0) var escala_temblor: float = 1.0

var _adelanto_actual: float = 0.0
## Posición de seguimiento sin temblor.
var _posicion_base: Vector3 = Vector3.ZERO
var _temblor_intensidad: float = 0.0
var _temblor_restante: float = 0.0
var _temblor_duracion: float = 0.0


func _ready() -> void:
	rotation_degrees.x = inclinacion_grados
	fov = campo_vision
	_posicion_base = global_position
	var impactos: DirectorImpactos = DirectorImpactos.global()
	if impactos:
		impactos.registrar_camara(self)
	if objetivo:
		objetivo.reaparecido.connect(saltar_a_objetivo)
		saltar_a_objetivo()


## Coloca la cámara en su sitio sin suavizado (inicio, reapariciones).
func saltar_a_objetivo() -> void:
	if objetivo:
		_adelanto_actual = adelanto * objetivo.mirando
		_posicion_base = _posicion_deseada()
		global_position = _posicion_base


## Temblor que se desvanece en `duracion` segundos. Si ya hay uno más fuerte, se conserva.
func temblar(intensidad: float, duracion: float) -> void:
	var nueva: float = intensidad * escala_temblor
	if nueva <= 0.0 or (nueva < _temblor_intensidad and _temblor_restante > 0.0):
		return
	_temblor_intensidad = nueva
	_temblor_duracion = maxf(duracion, 0.01)
	_temblor_restante = _temblor_duracion


func temblando() -> bool:
	return _temblor_restante > 0.0


func _physics_process(delta: float) -> void:
	if not objetivo:
		return
	_adelanto_actual = lerpf(_adelanto_actual, adelanto * objetivo.mirando, 1.0 - exp(-suavizado_adelanto * delta))
	_posicion_base = _posicion_base.lerp(_posicion_deseada(), 1.0 - exp(-suavizado * delta))
	global_position = _posicion_base + _desplazamiento_temblor(delta)


func _desplazamiento_temblor(delta: float) -> Vector3:
	if _temblor_restante <= 0.0:
		return Vector3.ZERO
	_temblor_restante = maxf(_temblor_restante - delta, 0.0)
	var fuerza: float = _temblor_intensidad * (_temblor_restante / _temblor_duracion)
	return Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * fuerza


func _posicion_deseada() -> Vector3:
	var foco: Vector3 = objetivo.global_position
	return Vector3(foco.x + _adelanto_actual, foco.y + altura, foco.z + distancia)
