class_name HudJuego
extends CanvasLayer
## HUD de juego para Nereth: barras de vida, daño reciente, resonancia, resistencia y esencias.

@export var objetivo: Nereth
@export var estilo_esencia_llena: StyleBoxFlat
@export var estilo_esencia_vacia: StyleBoxFlat

@onready var _barra_vida: ProgressBar = $Margen/ContenedorBarras/FilaVida/BarraVida
@onready var _barra_dano_reciente: ProgressBar = $Margen/ContenedorBarras/FilaVida/BarraDanoReciente
@onready var _fila_resonancia: MarginContainer = $Margen/ContenedorBarras/FilaResonancia
@onready var _barra_resonancia: ProgressBar = $Margen/ContenedorBarras/FilaResonancia/BarraResonancia
@onready var _marca_limite: ColorRect = $Margen/ContenedorBarras/FilaResonancia/MarcaLimite
@onready var _indicador_desfase: ColorRect = $Margen/ContenedorBarras/FilaResonancia/IndicadorDesfase
@onready var _borde_amenaza: Panel = $Margen/ContenedorBarras/FilaResonancia/BordeAmenaza
@onready var _barra_resistencia: ProgressBar = $Margen/ContenedorBarras/FilaResistencia/BarraResistencia
@onready var _fila_esencias: HBoxContainer = $Margen/ContenedorBarras/FilaEsencias

var _tween_dano: Tween
var _tween_resistencia: Tween
var _tween_resonancia: Tween
var _tween_aviso: Tween
var _tween_esencias: Tween
var _tween_icono: Tween

var _iconos_esencias: Array[Panel] = []
var _ultimo_indice_gastado: int = -1

var fila_esencias: HBoxContainer:
	get: return _fila_esencias
var iconos_esencias: Array[Panel]:
	get: return _iconos_esencias


func _ready() -> void:
	_fila_resonancia.visible = true
	_marca_limite.visible = false
	_borde_amenaza.visible = false
	_indicador_desfase.visible = true
	_indicador_desfase.color = Color(0.3, 0.25, 0.45, 0.5)
	_inicializar_iconos_esencias()
	if not objetivo:
		return
	if not objetivo.is_node_ready():
		await objetivo.ready
	_conectar_senales()
	_inicializar_valores()


func _inicializar_iconos_esencias() -> void:
	_iconos_esencias.clear()
	if _fila_esencias:
		for hijo: Node in _fila_esencias.get_children():
			if hijo is Panel:
				_iconos_esencias.append(hijo as Panel)

	if not estilo_esencia_llena or not estilo_esencia_vacia:
		_crear_estilos_esencia_por_defecto()

	for icono: Panel in _iconos_esencias:
		icono.set_meta("lleno", true)
		if estilo_esencia_llena:
			icono.add_theme_stylebox_override("panel", estilo_esencia_llena)


func _crear_estilos_esencia_por_defecto() -> void:
	if not estilo_esencia_llena:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.92, 0.68, 0.18, 0.95)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(1.0, 0.88, 0.55, 0.9)
		sb.corner_radius_top_left = 3
		sb.corner_radius_top_right = 3
		sb.corner_radius_bottom_right = 4
		sb.corner_radius_bottom_left = 4
		sb.shadow_color = Color(0.85, 0.55, 0.1, 0.35)
		sb.shadow_size = 2
		estilo_esencia_llena = sb

	if not estilo_esencia_vacia:
		var sb_v := StyleBoxFlat.new()
		sb_v.bg_color = Color(0.12, 0.12, 0.16, 0.45)
		sb_v.border_width_left = 1
		sb_v.border_width_top = 1
		sb_v.border_width_right = 1
		sb_v.border_width_bottom = 1
		sb_v.border_color = Color(0.28, 0.28, 0.32, 0.5)
		sb_v.corner_radius_top_left = 3
		sb_v.corner_radius_top_right = 3
		sb_v.corner_radius_bottom_right = 4
		sb_v.corner_radius_bottom_left = 4
		estilo_esencia_vacia = sb_v


func _conectar_senales() -> void:
	if objetivo.vida:
		objetivo.vida.cambiada.connect(_al_cambiar_vida)
	if objetivo.resistencia:
		objetivo.resistencia.cambiada.connect(_al_cambiar_resistencia)
	if objetivo.resonancia:
		objetivo.resonancia.cambiada.connect(_al_cambiar_resonancia)
		objetivo.resonancia.regimen_cambiado.connect(_al_cambiar_regimen)
	if objetivo.fase:
		objetivo.fase.cambio_bloqueado.connect(_al_bloquear_cambio)
		objetivo.fase.rechazo.connect(_al_rechazo)
		objetivo.fase.desfase_preciso.connect(_al_desfase_preciso)
	if objetivo.esencias:
		objetivo.esencias.cargas_cambiadas.connect(_al_cambiar_esencias)
		objetivo.esencias.curacion_iniciada.connect(_al_iniciar_curacion)
		objetivo.esencias.curacion_interrumpida.connect(_al_interrumpir_curacion)
	var gestor: GestorFase = GestorFase.global()
	if gestor:
		gestor.cambiada.connect(_al_cambiar_fase)


func _inicializar_valores() -> void:
	if objetivo.vida:
		var max_v: float = objetivo.vida.maximo
		var act_v: float = objetivo.vida.actual
		_barra_vida.max_value = max_v
		_barra_vida.value = act_v
		_barra_dano_reciente.max_value = max_v
		_barra_dano_reciente.value = act_v

	if objetivo.resonancia:
		var max_r: float = objetivo.resonancia.maximo
		var act_r: float = objetivo.resonancia.actual
		_barra_resonancia.max_value = max_r
		_barra_resonancia.value = act_r
		_actualizar_marca_limite(objetivo.resonancia.amenaza())

	if objetivo.resistencia:
		var max_e: float = objetivo.resistencia.maximo
		var act_e: float = objetivo.resistencia.actual
		_barra_resistencia.max_value = max_e
		_barra_resistencia.value = act_e

	if objetivo.esencias:
		_actualizar_iconos_esencia(objetivo.esencias.cargas, objetivo.esencias.cargas_maximas)


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


func _al_cambiar_resonancia(actual: float, maximo: float) -> void:
	_barra_resonancia.max_value = maximo
	if _tween_resonancia and _tween_resonancia.is_valid():
		_tween_resonancia.kill()
	_tween_resonancia = create_tween()
	_tween_resonancia.tween_property(_barra_resonancia, "value", actual, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _al_cambiar_regimen(en_amenaza: bool) -> void:
	_actualizar_marca_limite(en_amenaza)


func _actualizar_marca_limite(en_amenaza: bool) -> void:
	_marca_limite.visible = en_amenaza
	_borde_amenaza.visible = en_amenaza
	if en_amenaza and objetivo and objetivo.resonancia:
		var fraccion: float = objetivo.resonancia.limite_recuperacion_amenaza
		var ancho_barra: float = _barra_resonancia.size.x if _barra_resonancia.size.x > 0.0 else 230.0
		_marca_limite.position.x = ancho_barra * fraccion
		_marca_limite.size.x = 2.0


func _al_cambiar_fase(estado: GestorFase.Estado) -> void:
	var activo: bool = estado == GestorFase.Estado.DESFASE
	if activo:
		_indicador_desfase.color = Color(0.55, 0.45, 0.95, 1.0)
	else:
		_indicador_desfase.color = Color(0.3, 0.25, 0.45, 0.5)


func _al_bloquear_cambio() -> void:
	_destello_barra(Color(0.9, 0.3, 0.2, 0.7), true)


func _al_rechazo() -> void:
	_destello_barra(Color(0.95, 0.15, 0.1, 0.9), false)


func _al_desfase_preciso() -> void:
	_destello_barra(Color(0.7, 0.85, 1.0, 0.95), false)


func _destello_barra(color: Color, con_temblor: bool) -> void:
	if _tween_aviso and _tween_aviso.is_valid():
		_tween_aviso.kill()

	_tween_aviso = create_tween()
	var estilo: StyleBoxFlat = _barra_resonancia.get_theme_stylebox("fill") as StyleBoxFlat
	if estilo:
		var color_original: Color = Color(0.38, 0.28, 0.72, 1.0)
		estilo.bg_color = color
		_tween_aviso.tween_property(estilo, "bg_color", color_original, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if con_temblor:
		var pos_original: float = _fila_resonancia.position.x
		_tween_aviso.parallel().tween_property(_fila_resonancia, "position:x", pos_original + 4.0, 0.05)
		_tween_aviso.tween_property(_fila_resonancia, "position:x", pos_original - 3.0, 0.05)
		_tween_aviso.tween_property(_fila_resonancia, "position:x", pos_original + 2.0, 0.05)
		_tween_aviso.tween_property(_fila_resonancia, "position:x", pos_original, 0.05)


func _al_cambiar_esencias(cargas: int, maximo: int) -> void:
	_actualizar_iconos_esencia(cargas, maximo)


func _actualizar_iconos_esencia(cargas: int, maximo: int) -> void:
	if not estilo_esencia_llena or not estilo_esencia_vacia:
		_crear_estilos_esencia_por_defecto()

	while _iconos_esencias.size() < maximo:
		var nuevo_icono := Panel.new()
		nuevo_icono.custom_minimum_size = Vector2(14, 18)
		_fila_esencias.add_child(nuevo_icono)
		_iconos_esencias.append(nuevo_icono)
	while _iconos_esencias.size() > maximo:
		var sobrante: Panel = _iconos_esencias.pop_back()
		if is_instance_valid(sobrante):
			sobrante.queue_free()

	for i: int in range(_iconos_esencias.size()):
		var icono: Panel = _iconos_esencias[i]
		var estaba_lleno: bool = icono.get_meta("lleno", false)
		var ahora_lleno: bool = i < cargas
		icono.set_meta("lleno", ahora_lleno)
		var estilo: StyleBoxFlat = estilo_esencia_llena if ahora_lleno else estilo_esencia_vacia
		icono.add_theme_stylebox_override("panel", estilo)
		if estaba_lleno and not ahora_lleno:
			_ultimo_indice_gastado = i


func _al_iniciar_curacion() -> void:
	var idx: int = _ultimo_indice_gastado
	if idx >= 0 and idx < _iconos_esencias.size():
		var icono: Panel = _iconos_esencias[idx]
		if is_instance_valid(icono):
			if _tween_icono and _tween_icono.is_valid():
				_tween_icono.kill()
			_tween_icono = create_tween()
			icono.modulate = Color(2.0, 1.8, 1.2, 1.0)
			_tween_icono.tween_property(icono, "modulate", Color.WHITE, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_ultimo_indice_gastado = -1


func _al_interrumpir_curacion() -> void:
	if _tween_esencias and _tween_esencias.is_valid():
		_tween_esencias.kill()
	_tween_esencias = create_tween()
	_fila_esencias.modulate = Color(1.0, 0.35, 0.35, 1.0)
	_tween_esencias.tween_property(_fila_esencias, "modulate", Color.WHITE, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var pos_original: float = _fila_esencias.position.x
	_tween_esencias.parallel().tween_property(_fila_esencias, "position:x", pos_original + 3.0, 0.05)
	_tween_esencias.tween_property(_fila_esencias, "position:x", pos_original - 3.0, 0.05)
	_tween_esencias.tween_property(_fila_esencias, "position:x", pos_original + 2.0, 0.05)
	_tween_esencias.tween_property(_fila_esencias, "position:x", pos_original, 0.05)


func obtener_cargas_esencias() -> int:
	var total: int = 0
	for icono: Panel in _iconos_esencias:
		if is_instance_valid(icono) and icono.get_meta("lleno", false):
			total += 1
	return total


func obtener_iconos_esencias() -> Array[Panel]:
	return _iconos_esencias.duplicate()
