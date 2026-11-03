class_name EsenciasNereth
extends Node
## Esencias de Nereth: cargas de curación (continuidad condensada,
## documentation/propuestas/elyndor_textos.md §6). Pulsar «curar» en el suelo
## gasta una carga: Nereth queda quieto y vulnerable mientras bebe y, al terminar,
## recupera vida. Un golpe durante la curación la interrumpe y la carga se pierde.
## Se rellenan al descansar en un Ancla o al reaparecer (Nereth.restaurar()).
## Nereth llama a procesar() cada frame de física.

signal cargas_cambiadas(cargas: int, maximo: int)
signal curacion_iniciada
signal curacion_completada(cantidad: float)
signal curacion_interrumpida

@export var cargas_maximas: int = 3
## Fracción de la vida máxima que devuelve cada Esencia.
@export_range(0.0, 1.0) var curacion: float = 0.4
## Tiempo quieto y vulnerable mientras bebe.
@export var duracion: float = 0.8

var cargas: int = 0

var _tiempo: float = -1.0

@onready var _nereth: Nereth = get_parent() as Nereth


func _ready() -> void:
	rellenar()


func curando() -> bool:
	return _tiempo >= 0.0


## Lo pide Nereth al pulsar «curar» en un estado que lo permite.
func intentar_curar() -> bool:
	if curando() or cargas <= 0 or _nereth.vida.actual >= _nereth.vida.maximo:
		return false
	cargas -= 1
	_tiempo = 0.0
	cargas_cambiadas.emit(cargas, cargas_maximas)
	curacion_iniciada.emit()
	GestorSonido.global().reproducir(&"esencia", -4.0, 0.0)
	return true


func procesar(delta: float) -> void:
	if not curando():
		return
	_tiempo += delta
	if _tiempo >= duracion:
		_tiempo = -1.0
		var cantidad: float = _nereth.vida.maximo * curacion
		_nereth.vida.establecer(minf(_nereth.vida.actual + cantidad, _nereth.vida.maximo))
		curacion_completada.emit(cantidad)
		_nereth.terminar_curacion()


## Un golpe corta la curación: la carga ya gastada no se devuelve.
func interrumpir() -> void:
	if curando():
		_tiempo = -1.0
		curacion_interrumpida.emit()


func rellenar() -> void:
	_tiempo = -1.0
	cargas = cargas_maximas
	cargas_cambiadas.emit(cargas, cargas_maximas)
