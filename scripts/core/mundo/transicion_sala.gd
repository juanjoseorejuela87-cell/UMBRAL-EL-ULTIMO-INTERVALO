class_name TransicionSala
extends Area3D
## Al entrar Nereth, lleva a otra sala y lo coloca en el PuntoEntrada indicado.
## collision_mask debe incluir la capa del jugador (8).

@export_file("*.tscn") var escena_destino: String = ""
@export var entrada_destino: StringName = &""


func _ready() -> void:
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node3D) -> void:
	if not cuerpo is Nereth or escena_destino == "":
		return
	var salas: GestorSalas = GestorSalas.global()
	if salas.cambiando():
		return
	salas.ir_a_entrada(escena_destino, entrada_destino)
