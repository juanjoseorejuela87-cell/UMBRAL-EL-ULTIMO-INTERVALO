class_name PantallaMuerte
extends CanvasLayer
## Pantalla de muerte: fundido cinematográfico en negro y carmesí con la
## inscripción «EL INTERVALO SE HA CERRADO». La reaparición en el Altar ya ha
## ocurrido debajo (no hay carga): la pantalla solo la cubre y se retira sola o
## al pulsar «Reaparecer en el Altar» (ratón, teclado o mando).

signal cerrada

## Segundos que la pantalla queda visible si nadie pulsa nada.
@export var duracion: float = 2.8

@onready var _fondo: ColorRect = $Fondo
@onready var _centro: Control = $Centro
@onready var _titulo: Label = $Centro/Columna/Titulo
@onready var _detalle: Control = $Centro/Columna/Detalle
@onready var _boton: Button = $Centro/Columna/Detalle/BotonReaparecer

var _tween: Tween
var _abierta: bool = false


func _ready() -> void:
	visible = false
	_boton.pressed.connect(cerrar)


func abierta() -> bool:
	return _abierta


func mostrar() -> void:
	_abierta = true
	visible = true
	if _tween and _tween.is_valid():
		_tween.kill()
	# El negro cae de golpe (cubre el salto al Altar) y la inscripción emerge.
	_fondo.modulate.a = 1.0
	_centro.modulate.a = 1.0
	_titulo.modulate.a = 0.0
	_titulo.pivot_offset = _titulo.size * 0.5
	_titulo.scale = Vector2(1.08, 1.08)
	_detalle.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_interval(0.25)
	_tween.tween_property(_titulo, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_titulo, "scale", Vector2.ONE, 1.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_detalle, "modulate:a", 1.0, 0.4)
	_tween.tween_callback(_enfocar_boton)
	_tween.tween_interval(maxf(duracion - 1.35, 0.0))
	_tween.tween_callback(cerrar)


func cerrar() -> void:
	if not _abierta:
		return
	_abierta = false
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_centro, "modulate:a", 0.0, 0.3)
	_tween.parallel().tween_property(_fondo, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_ocultar)


func _ocultar() -> void:
	visible = false
	cerrada.emit()


func _enfocar_boton() -> void:
	if _abierta and _boton.is_visible_in_tree():
		_boton.grab_focus()


func _unhandled_input(evento: InputEvent) -> void:
	if not _abierta:
		return
	if evento.is_action_pressed(&"ui_accept") or evento.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		cerrar()
