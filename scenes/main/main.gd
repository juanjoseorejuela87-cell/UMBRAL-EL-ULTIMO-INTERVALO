extends Node
## Escena de arranque de UMBRAL: El Último Intervalo. Lleva a la pantalla de
## título (que ofrece continuar o empezar una partida nueva).

const ESCENA_TITULO: String = "res://scenes/ui/titulo/titulo.tscn"


func _ready() -> void:
	print("UMBRAL: El Último Intervalo — arranque correcto")
	get_tree().change_scene_to_file.call_deferred(ESCENA_TITULO)
