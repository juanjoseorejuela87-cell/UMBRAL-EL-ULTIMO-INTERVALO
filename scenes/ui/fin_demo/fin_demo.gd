class_name PantallaFinDemo
extends Control
## Pantalla de fin de la demo de Elyndor: resumen y vuelta al título.

const ESCENA_TITULO: String = "res://scenes/ui/titulo/titulo.tscn"

var _foco_inicial_dado: bool = false

@onready var resumen: Label = %Resumen
@onready var boton_titulo: Button = %VolverTitulo


func _ready() -> void:
	if GestorSonido.global() != null:
		GestorSonido.global().ambiente(&"")

	var partida: GestorPartida = GestorPartida.global()
	resumen.text = "Fragmentos de Continuidad: %d\nAnclas estabilizadas: %d\nRemiendos: %d\nEl Prefecto de las Puertas: %s" % [
		partida.fragmentos.size(),
		partida.anclas_estabilizadas.size(),
		partida.remiendos.size(),
		"derrotado" if partida.evento_ocurrido(Prefecto.EVENTO_DERROTA) else "en pie",
	]

	_conectar_sonidos_boton(boton_titulo)
	boton_titulo.pressed.connect(volver_al_titulo)
	boton_titulo.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func _conectar_sonidos_boton(boton: Button) -> void:
	boton.focus_entered.connect(func() -> void:
		if not _foco_inicial_dado:
			return
		if GestorSonido.global() != null:
			GestorSonido.global().reproducir(&"ui_mover")
	)
	boton.pressed.connect(func() -> void:
		if GestorSonido.global() != null:
			GestorSonido.global().reproducir(&"ui_aceptar")
	)


func _activar_sonido_foco_tras_frame() -> void:
	await get_tree().process_frame
	_foco_inicial_dado = true


func volver_al_titulo() -> void:
	GestorSalas.global().ir_a_entrada(ESCENA_TITULO, &"")
