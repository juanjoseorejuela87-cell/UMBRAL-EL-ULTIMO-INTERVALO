class_name HudJuego
extends CanvasLayer
## HUD de juego para Nereth: barras de vida, daño reciente y resistencia.

@export var objetivo: Nereth

@onready var _barra_vida: ProgressBar = $Margen/ContenedorBarras/FilaVida/BarraVida
@onready var _barra_dano_reciente: ProgressBar = $Margen/ContenedorBarras/FilaVida/BarraDanoReciente
@onready var _barra_resistencia: ProgressBar = $Margen/ContenedorBarras/FilaResistencia/BarraResistencia
@onready var _barra_resonancia: Control = $Margen/ContenedorBarras/BarraResonancia

var _tween_dano: Tween
var _tween_resistencia: Tween


func _ready() -> void:
	_barra_resonancia.visible = false
	if not objetivo:
		return
	if not objetivo.is_node_ready():
		await objetivo.ready
	_conectar_senales()
	_inicializar_valores()


func _conectar_senales() -> void:
	if objetivo.vida:
		objetivo.vida.cambiada.connect(_al_cambiar_vida)
	if objetivo.resistencia:
		objetivo.resistencia.cambiada.connect(_al_cambiar_resistencia)


func _inicializar_valores() -> void:
	if objetivo.vida:
		var max_v: float = objetivo.vida.maximo
		var act_v: float = objetivo.vida.actual
		_barra_vida.max_value = max_v
		_barra_vida.value = act_v
		_barra_dano_reciente.max_value = max_v
		_barra_dano_reciente.value = act_v

	if objetivo.resistencia:
		var max_r: float = objetivo.resistencia.maximo
		var act_r: float = objetivo.resistencia.actual
		_barra_resistencia.max_value = max_r
		_barra_resistencia.value = act_r


func _al_cambiar_vida(actual: float, maximo: float) -> void:
	_barra_vida.max_value = maximo
	_barra_dano_reciente.max_value = maximo

	var hubo_dano: bool = actual < _barra_vida.value
	_barra_vida.value = actual

	if _tween_dano and _tween_dano.is_valid():
		_tween_dano.kill()

	if hubo_dano:
		_tween_dano = create_tween()
		_tween_dano.tween_interval(0.4)
		_tween_dano.tween_property(_barra_dano_reciente, "value", actual, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		_barra_dano_reciente.value = actual


func _al_cambiar_resistencia(actual: float, maximo: float) -> void:
	_barra_resistencia.max_value = maximo
	if _tween_resistencia and _tween_resistencia.is_valid():
		_tween_resistencia.kill()
	_tween_resistencia = create_tween()
	_tween_resistencia.tween_property(_barra_resistencia, "value", actual, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
