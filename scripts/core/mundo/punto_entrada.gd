class_name PuntoEntrada
extends Marker3D
## Lugar donde aparece Nereth al llegar a esta sala desde otra
## (TransicionSala.entrada_destino = id). Colócalo fuera de cualquier
## TransicionSala para no rebotar de vuelta.

const GRUPO: StringName = &"puntos_entrada"

@export var id: StringName = &""
## Hacia dónde mira Nereth al llegar (1 = derecha, -1 = izquierda).
@export var mirando: float = 1.0


func _ready() -> void:
	add_to_group(GRUPO)
