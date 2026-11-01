class_name PantallaTitulo
extends Control
## Pantalla de título: continuar la partida guardada, empezar una nueva o salir.

const ESCENA_INICIAL: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"

var _confirmando_nueva: bool = false
var _foco_inicial_dado: bool = false

@onready var boton_continuar: Button = %Continuar
@onready var boton_nueva: Button = %NuevaPartida
@onready var boton_salir: Button = %Salir


func _ready() -> void:
	if GestorSonido.global() != null:
		GestorSonido.global().ambiente(&"")

	_conectar_sonidos_boton(boton_continuar)
	_conectar_sonidos_boton(boton_nueva)
	_conectar_sonidos_boton(boton_salir)

	boton_continuar.pressed.connect(continuar)
	boton_nueva.pressed.connect(nueva_partida)
	boton_salir.pressed.connect(func() -> void: get_tree().quit())
	var hay_partida: bool = GestorPartida.global().hay_reaparicion
	boton_continuar.disabled = not hay_partida
	(boton_continuar if hay_partida else boton_nueva).grab_focus.call_deferred()
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


func continuar() -> void:
	var partida: GestorPartida = GestorPartida.global()
	if partida.hay_reaparicion and ResourceLoader.exists(partida.escena_ancla):
		GestorSalas.global().ir_a_posicion(partida.escena_ancla, partida.posicion_reaparicion, true)
	else:
		GestorSalas.global().ir_a_entrada(ESCENA_INICIAL, &"inicio")


## Con partida guardada, la primera pulsación pide confirmación.
func nueva_partida() -> void:
	if GestorPartida.global().hay_reaparicion and not _confirmando_nueva:
		_confirmando_nueva = true
		boton_nueva.text = "¿Seguro? Se perderá la partida"
		return
	GestorPartida.global().nueva_partida()
	GestorSalas.global().ir_a_entrada(ESCENA_INICIAL, &"inicio")
