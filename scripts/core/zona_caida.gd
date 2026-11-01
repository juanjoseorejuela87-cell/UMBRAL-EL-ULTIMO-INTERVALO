class_name ZonaCaida
extends Area3D
## Si Nereth cae dentro, vuelve al punto de reaparición (salas de prueba y
## fosos sin muerte).

@export var punto_reaparicion: Node3D


func _ready() -> void:
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node3D) -> void:
	var nereth: Nereth = cuerpo as Nereth
	if nereth and punto_reaparicion:
		nereth.reaparecer(punto_reaparicion.global_position)
