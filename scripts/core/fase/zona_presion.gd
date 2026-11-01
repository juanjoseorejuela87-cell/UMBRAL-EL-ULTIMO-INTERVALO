class_name ZonaPresion
extends Area3D
## Zona que fuerza el régimen de Amenaza de la Resonancia aunque no haya
## enemigos (salas de reto, secretos, arenas).


func _ready() -> void:
	body_entered.connect(_al_entrar)
	body_exited.connect(_al_salir)


func _al_entrar(cuerpo: Node3D) -> void:
	var nereth: Nereth = cuerpo as Nereth
	if nereth:
		nereth.resonancia.registrar_amenaza(self)


func _al_salir(cuerpo: Node3D) -> void:
	var nereth: Nereth = cuerpo as Nereth
	if nereth:
		nereth.resonancia.retirar_amenaza(self)
