extends Node
## Escena de arranque de UMBRAL: El Último Intervalo.
## Si hay partida guardada, continúa en el último Ancla; si no, empieza en el
## primer tramo de Elyndor.

const ESCENA_INICIAL: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"


func _ready() -> void:
	print("UMBRAL: El Último Intervalo — arranque correcto")
	_empezar.call_deferred()


func _empezar() -> void:
	var partida: GestorPartida = GestorPartida.global()
	var salas: GestorSalas = GestorSalas.global()
	if partida.hay_reaparicion and ResourceLoader.exists(partida.escena_ancla):
		salas.ir_a_posicion(partida.escena_ancla, partida.posicion_reaparicion, true)
	else:
		salas.ir_a_entrada(ESCENA_INICIAL, &"inicio")
