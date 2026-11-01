class_name PantallaFinDemo
extends Control
## Pantalla de fin de la demo de Elyndor: resumen y vuelta al título.

const ESCENA_TITULO: String = "res://scenes/ui/titulo/titulo.tscn"

@onready var resumen: Label = %Resumen
@onready var boton_titulo: Button = %VolverTitulo


func _ready() -> void:
	var partida: GestorPartida = GestorPartida.global()
	resumen.text = "Fragmentos de Continuidad: %d\nAnclas estabilizadas: %d\nRemiendos: %d\nEl Prefecto de las Puertas: %s" % [
		partida.fragmentos.size(),
		partida.anclas_estabilizadas.size(),
		partida.remiendos.size(),
		"derrotado" if partida.evento_ocurrido(Prefecto.EVENTO_DERROTA) else "en pie",
	]
	boton_titulo.pressed.connect(volver_al_titulo)
	boton_titulo.grab_focus.call_deferred()


func volver_al_titulo() -> void:
	GestorSalas.global().ir_a_entrada(ESCENA_TITULO, &"")
