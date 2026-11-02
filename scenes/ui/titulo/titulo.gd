class_name PantallaTitulo
extends Control
## Pantalla de título: continuar la partida guardada, empezar una nueva, opciones o salir.
## Fondo 3D de la Cámara del Despertar con kit gótico, pulso de Desfase y fundido inicial.

const ESCENA_INICIAL: String = "res://scenes/niveles/elyndor/camara_despertar.tscn"

var _confirmando_nueva: bool = false
var _foco_inicial_dado: bool = false

@onready var menu_principal: VBoxContainer = %MenuPrincipal
@onready var menu_opciones: VBoxContainer = %MenuOpciones
@onready var panel_ajustes: PanelAjustes = %PanelAjustes

@onready var boton_continuar: Button = %Continuar
@onready var boton_nueva: Button = %NuevaPartida
@onready var boton_opciones: Button = %Opciones
@onready var boton_salir: Button = %Salir

@onready var boton_opciones_sonido: Button = %OpcionesSonido
@onready var boton_opciones_graficos: Button = %OpcionesGraficos
@onready var boton_opciones_volver: Button = %OpcionesVolver

@onready var cortina: ColorRect = $CortinaNegra
@onready var fondo_3d: FondoTitulo = $FondoTitulo


func _ready() -> void:
	if GestorSonido.global() != null:
		GestorSonido.global().ambiente(&"")

	_iniciar_fundido_entrada()

	# Conexiones menú principal
	boton_continuar.pressed.connect(continuar)
	boton_nueva.pressed.connect(nueva_partida)
	boton_opciones.pressed.connect(mostrar_menu_opciones)
	boton_salir.pressed.connect(func() -> void: get_tree().quit())

	# Conexiones submenú opciones
	boton_opciones_sonido.pressed.connect(mostrar_sonido)
	boton_opciones_graficos.pressed.connect(mostrar_graficos)
	boton_opciones_volver.pressed.connect(mostrar_menu_principal)

	panel_ajustes.volver_pulsado.connect(mostrar_menu_opciones)

	for btn: Button in [
		boton_continuar,
		boton_nueva,
		boton_opciones,
		boton_salir,
		boton_opciones_sonido,
		boton_opciones_graficos,
		boton_opciones_volver,
	]:
		_conectar_sonidos_boton(btn)

	var hay_partida: bool = GestorPartida.global().hay_reaparicion
	boton_continuar.disabled = not hay_partida
	(boton_continuar if hay_partida else boton_nueva).grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func _iniciar_fundido_entrada() -> void:
	if cortina == null:
		return
	cortina.visible = true
	cortina.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_property(cortina, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func() -> void:
		cortina.visible = false
	)


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


func mostrar_menu_principal() -> void:
	menu_principal.visible = true
	menu_opciones.visible = false
	panel_ajustes.visible = false
	panel_ajustes.ocultar_todo()
	_foco_inicial_dado = false
	boton_opciones.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func mostrar_menu_opciones() -> void:
	menu_principal.visible = false
	menu_opciones.visible = true
	panel_ajustes.visible = false
	panel_ajustes.ocultar_todo()
	_foco_inicial_dado = false
	boton_opciones_sonido.grab_focus.call_deferred()
	_activar_sonido_foco_tras_frame()


func mostrar_sonido() -> void:
	menu_principal.visible = false
	menu_opciones.visible = false
	panel_ajustes.mostrar_sonido()


func mostrar_graficos() -> void:
	menu_principal.visible = false
	menu_opciones.visible = false
	panel_ajustes.mostrar_graficos()


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
