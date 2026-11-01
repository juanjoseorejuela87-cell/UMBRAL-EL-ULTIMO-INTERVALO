class_name ComponenteVida
extends Node
## Vida de una entidad.

signal cambiada(actual: float, maximo: float)
signal agotada

@export var maximo: float = 100.0

var actual: float = 0.0


func _ready() -> void:
	actual = maximo


func recibir_dano(cantidad: float) -> void:
	if actual <= 0.0:
		return
	actual = maxf(actual - cantidad, 0.0)
	cambiada.emit(actual, maximo)
	if actual <= 0.0:
		agotada.emit()


func restaurar() -> void:
	actual = maximo
	cambiada.emit(actual, maximo)
