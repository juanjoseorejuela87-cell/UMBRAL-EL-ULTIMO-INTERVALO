extends Node
## Escena de arranque de UMBRAL: El Último Intervalo.
## De momento carga la sala de pruebas de combate.

const ESCENA_INICIAL: String = "res://scenes/niveles/pruebas/sala_combate.tscn"


func _ready() -> void:
	print("UMBRAL: El Último Intervalo — arranque correcto")
	get_tree().change_scene_to_file.call_deferred(ESCENA_INICIAL)
