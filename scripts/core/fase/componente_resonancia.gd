class_name ComponenteResonancia
extends Node
## Resonancia: recurso que consume el Desfase. Dos regímenes
## (documentation/GAMEPLAY.md §3.3):
## - Calma: entrar es gratis, consumo bajo y recuperación rápida en la Realidad.
## - Amenaza (combate o zona de presión): coste de entrada, consumo creciente y
##   recuperación pasiva limitada; el resto se gana combatiendo.

signal cambiada(actual: float, maximo: float)
signal agotada
signal regimen_cambiado(amenaza: bool)

@export var maximo: float = 100.0

@export_group("Calma")
@export var consumo_calma: float = 2.0
@export var recuperacion_calma: float = 25.0

@export_group("Amenaza")
@export var coste_entrada_amenaza: float = 15.0
@export var consumo_amenaza_inicial: float = 4.0
@export var consumo_amenaza_maximo: float = 10.0
## Segundos seguidos en Desfase hasta alcanzar el consumo máximo.
@export var tiempo_consumo_maximo: float = 4.0
@export var recuperacion_amenaza: float = 3.0
## La recuperación pasiva en Amenaza solo llega hasta esta fracción del máximo.
@export_range(0.0, 1.0) var limite_recuperacion_amenaza: float = 0.3

var actual: float = 0.0
var en_desfase: bool = false

var _fuentes_amenaza: Array[Object] = []
var _tiempo_en_desfase: float = 0.0


func _ready() -> void:
	actual = maximo


func amenaza() -> bool:
	return not _fuentes_amenaza.is_empty()


## Una fuente (enemigo en alerta, zona de presión...) activa el régimen de Amenaza.
func registrar_amenaza(fuente: Object) -> void:
	if fuente in _fuentes_amenaza:
		return
	var antes: bool = amenaza()
	_fuentes_amenaza.append(fuente)
	if not antes:
		regimen_cambiado.emit(true)


func retirar_amenaza(fuente: Object) -> void:
	if not fuente in _fuentes_amenaza:
		return
	_fuentes_amenaza.erase(fuente)
	if not amenaza():
		regimen_cambiado.emit(false)


func coste_entrada() -> float:
	return coste_entrada_amenaza if amenaza() else 0.0


func puede_entrar() -> bool:
	return actual > 0.0 and actual >= coste_entrada()


func entrar() -> void:
	gastar(coste_entrada())
	en_desfase = true
	_tiempo_en_desfase = 0.0


func salir() -> void:
	en_desfase = false


## Fija la Resonancia a un valor (p. ej. al conservarla entre salas).
func establecer(valor: float) -> void:
	actual = clampf(valor, 0.0, maximo)
	cambiada.emit(actual, maximo)


func restaurar() -> void:
	actual = maximo
	cambiada.emit(actual, maximo)


func ganar(cantidad: float) -> void:
	actual = minf(actual + cantidad, maximo)
	cambiada.emit(actual, maximo)


func gastar(cantidad: float) -> void:
	if cantidad <= 0.0 or actual <= 0.0:
		return
	actual = maxf(actual - cantidad, 0.0)
	cambiada.emit(actual, maximo)
	if actual <= 0.0:
		agotada.emit()


## Retira fuentes de amenaza liberadas (enemigos destruidos...).
func _limpiar_fuentes() -> void:
	for i: int in range(_fuentes_amenaza.size() - 1, -1, -1):
		if not is_instance_valid(_fuentes_amenaza[i]):
			_fuentes_amenaza.remove_at(i)
			if not amenaza():
				regimen_cambiado.emit(false)


## Consumo por segundo en el instante actual (para el HUD y las pruebas).
func consumo_actual() -> float:
	if not amenaza():
		return consumo_calma
	var progreso: float = clampf(_tiempo_en_desfase / tiempo_consumo_maximo, 0.0, 1.0)
	return lerpf(consumo_amenaza_inicial, consumo_amenaza_maximo, progreso)


func _physics_process(delta: float) -> void:
	_limpiar_fuentes()
	if en_desfase:
		_tiempo_en_desfase += delta
		gastar(consumo_actual() * delta)
		return
	var techo: float = maximo * limite_recuperacion_amenaza if amenaza() else maximo
	if actual < techo:
		var tasa: float = recuperacion_amenaza if amenaza() else recuperacion_calma
		actual = minf(actual + tasa * delta, techo)
		cambiada.emit(actual, maximo)
