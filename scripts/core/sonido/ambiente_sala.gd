class_name AmbienteSala
extends Node
## Pon este nodo en una sala para fijar su ambiente sonoro en bucle al entrar.
## Las pistas disponibles están en GestorSonido.AMBIENTES (p. ej. &"elyndor").

@export var pista: StringName = &""


func _ready() -> void:
	GestorSonido.global().ambiente(pista)
