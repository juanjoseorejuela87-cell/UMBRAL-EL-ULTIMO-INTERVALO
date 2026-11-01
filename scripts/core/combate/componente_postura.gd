class_name ComponentePostura
extends Node
## Postura de un enemigo: se acumula con los golpes y, al llenarse, provoca
## la Ruptura (vulnerable al Golpe de Umbral). Se vacía sola con el tiempo.

signal cambiada(actual: float, maximo: float)
signal rota
signal recuperada

@export var maximo: float = 60.0
## Postura que se vacía por segundo tras el retraso.
@export var regeneracion: float = 15.0
@export var retraso_regeneracion: float = 1.0
@export var duracion_ruptura: float = 2.5

var actual: float = 0.0
var en_ruptura: bool = false

var _espera: float = 0.0
var _tiempo_ruptura: float = 0.0


func acumular(cantidad: float) -> void:
	if en_ruptura:
		return
	actual = minf(actual + cantidad, maximo)
	_espera = retraso_regeneracion
	cambiada.emit(actual, maximo)
	if actual >= maximo:
		en_ruptura = true
		_tiempo_ruptura = duracion_ruptura
		rota.emit()


## Termina la Ruptura (por tiempo o al recibir el Golpe de Umbral).
func terminar_ruptura() -> void:
	en_ruptura = false
	actual = 0.0
	cambiada.emit(actual, maximo)
	recuperada.emit()


func _physics_process(delta: float) -> void:
	if en_ruptura:
		_tiempo_ruptura -= delta
		if _tiempo_ruptura <= 0.0:
			terminar_ruptura()
		return
	if _espera > 0.0:
		_espera -= delta
	elif actual > 0.0:
		actual = maxf(actual - regeneracion * delta, 0.0)
		cambiada.emit(actual, maximo)
