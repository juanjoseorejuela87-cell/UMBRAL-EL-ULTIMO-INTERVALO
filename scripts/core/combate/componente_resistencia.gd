class_name ComponenteResistencia
extends Node
## Resistencia: la gastan ataques, esquiva y bloqueo. Se recupera tras un
## breve retraso sin gastarla. Con resistencia > 0 siempre se puede actuar.

signal cambiada(actual: float, maximo: float)
signal agotada

@export var maximo: float = 100.0
@export var regeneracion: float = 45.0
@export var retraso_regeneracion: float = 0.6

var actual: float = 0.0

var _espera: float = 0.0


func _ready() -> void:
	actual = maximo


func puede_actuar() -> bool:
	return actual > 0.0


## Gasta resistencia si queda algo; devuelve false si estaba agotada.
func consumir(cantidad: float) -> bool:
	if not puede_actuar():
		return false
	actual = maxf(actual - cantidad, 0.0)
	_espera = retraso_regeneracion
	cambiada.emit(actual, maximo)
	if actual <= 0.0:
		agotada.emit()
	return true


func _physics_process(delta: float) -> void:
	if _espera > 0.0:
		_espera -= delta
	elif actual < maximo:
		actual = minf(actual + regeneracion * delta, maximo)
		cambiada.emit(actual, maximo)
