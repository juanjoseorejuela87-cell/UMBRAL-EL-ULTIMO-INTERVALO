class_name BarraOrnamental
extends Control
## Barra del HUD con marco de hierro y oro viejo (StyleBoxFlat en capas), relleno
## con shader de relieve, barra rezagada ámbar que se desgasta con un Tween
## (TRANS_CUBIC + EASE_OUT) y remates en rombo. Sirve para vida, estamina,
## vida de jefe y postura (con «desde_centro» crece desde el medio, estilo Sekiro).

const SHADER_RELLENO: Shader = preload("res://shaders/ui/barra_relleno.gdshader")

@export var color_relleno: Color = Color(0.62, 0.06, 0.09):
	set(v):
		if v == color_relleno and is_node_ready() and _relleno.has_theme_stylebox_override(&"panel"):
			return
		color_relleno = v
		_aplicar_colores()
@export var color_rezagado: Color = Color(0.95, 0.62, 0.18):
	set(v):
		color_rezagado = v
		_aplicar_colores()
@export var mostrar_rezagado: bool = true
## Espera antes de que la barra rezagada empiece a bajar.
@export var espera_rezagado: float = 0.3
## Duración del desgaste de la barra rezagada (TRANS_CUBIC + EASE_OUT).
@export var duracion_rezagado: float = 0.6
## La barra crece desde el centro hacia los lados (postura de jefe).
@export var desde_centro: bool = false:
	set(v):
		desde_centro = v
		_colocar()
@export var mostrar_remates: bool = true:
	set(v):
		mostrar_remates = v
		_colocar()
@export_range(0.0, 1.0) var fraccion_inicial: float = 1.0

@onready var _marco: Panel = $Marco
@onready var _interior: Panel = $Interior
@onready var _rezagado: Panel = $Interior/Rezagado
@onready var _relleno: Panel = $Interior/Relleno
@onready var _remate_izq: Panel = $RemateIzq
@onready var _remate_der: Panel = $RemateDer

var maximo: float = 100.0
var valor: float = 100.0
var _fraccion: float = 1.0
var _fraccion_rezagada: float = 1.0
var _tween_rezagado: Tween
var _tween_destello: Tween
var _material: ShaderMaterial
var _alerta: bool = false


func _ready() -> void:
	_fraccion = fraccion_inicial
	_fraccion_rezagada = fraccion_inicial
	_material = ShaderMaterial.new()
	_material.shader = SHADER_RELLENO
	_relleno.material = _material
	_aplicar_colores()
	resized.connect(_colocar)
	_colocar()


## Fija el valor. Si baja y «animar» es true, la barra rezagada se desgasta despacio.
func fijar(actual: float, max_valor: float, animar: bool = true) -> void:
	maximo = maxf(max_valor, 0.001)
	var anterior: float = _fraccion
	valor = clampf(actual, 0.0, maximo)
	_fraccion = valor / maximo
	if _tween_rezagado and _tween_rezagado.is_valid():
		_tween_rezagado.kill()
	if animar and mostrar_rezagado and _fraccion < anterior and is_inside_tree():
		_fraccion_rezagada = maxf(_fraccion_rezagada, anterior)
		_tween_rezagado = create_tween()
		_tween_rezagado.tween_interval(espera_rezagado)
		_tween_rezagado.tween_method(_fijar_rezagada, _fraccion_rezagada, _fraccion, duracion_rezagado) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		_fraccion_rezagada = _fraccion
	_colocar()


func fraccion() -> float:
	return _fraccion


func fraccion_rezagada() -> float:
	return _fraccion_rezagada


## Destello breve del relleno (golpe, curación, aviso).
func destello(color: Color, duracion: float = 0.35) -> void:
	if not _material:
		return
	if _tween_destello and _tween_destello.is_valid():
		_tween_destello.kill()
	_material.set_shader_parameter(&"color_destello", color)
	_material.set_shader_parameter(&"destello", 0.85)
	_tween_destello = create_tween()
	_tween_destello.tween_method(_fijar_destello, 0.85, 0.0, duracion) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Parpadeo continuo mientras «activa» sea true (estamina agotada, postura al límite).
func alerta(activa: bool, color: Color = Color(1.0, 0.35, 0.25)) -> void:
	if activa == _alerta or not _material:
		return
	_alerta = activa
	if _tween_destello and _tween_destello.is_valid():
		_tween_destello.kill()
	if activa:
		_material.set_shader_parameter(&"color_destello", color)
		_tween_destello = create_tween().set_loops()
		_tween_destello.tween_method(_fijar_destello, 0.0, 0.7, 0.18).set_trans(Tween.TRANS_SINE)
		_tween_destello.tween_method(_fijar_destello, 0.7, 0.0, 0.32).set_trans(Tween.TRANS_SINE)
	else:
		_fijar_destello(0.0)


func en_alerta() -> bool:
	return _alerta


func _fijar_rezagada(f: float) -> void:
	_fraccion_rezagada = f
	_colocar()


func _fijar_destello(v: float) -> void:
	if _material:
		_material.set_shader_parameter(&"destello", v)


func _aplicar_colores() -> void:
	if not is_node_ready():
		return
	var sb_relleno: StyleBoxFlat = StyleBoxFlat.new()
	sb_relleno.bg_color = color_relleno
	sb_relleno.border_width_top = 1
	sb_relleno.border_color = color_relleno.lightened(0.35)
	sb_relleno.corner_radius_top_right = 1
	sb_relleno.corner_radius_bottom_right = 1
	_relleno.add_theme_stylebox_override(&"panel", sb_relleno)
	var sb_rez: StyleBoxFlat = StyleBoxFlat.new()
	sb_rez.bg_color = color_rezagado
	sb_rez.border_width_right = 1
	sb_rez.border_color = color_rezagado.lightened(0.4)
	_rezagado.add_theme_stylebox_override(&"panel", sb_rez)


func _colocar() -> void:
	if not is_node_ready():
		return
	_marco.position = Vector2.ZERO
	_marco.size = size
	var borde: Vector2 = Vector2(3, 3)
	_interior.position = borde
	_interior.size = (size - borde * 2.0).max(Vector2.ZERO)
	var ancho: float = _interior.size.x
	var alto: float = _interior.size.y
	_rezagado.visible = mostrar_rezagado
	if desde_centro:
		var w: float = ancho * _fraccion
		_relleno.position = Vector2((ancho - w) * 0.5, 0)
		_relleno.size = Vector2(w, alto)
		var wr: float = ancho * _fraccion_rezagada
		_rezagado.position = Vector2((ancho - wr) * 0.5, 0)
		_rezagado.size = Vector2(wr, alto)
	else:
		_relleno.position = Vector2.ZERO
		_relleno.size = Vector2(ancho * _fraccion, alto)
		_rezagado.position = Vector2.ZERO
		_rezagado.size = Vector2(ancho * _fraccion_rezagada, alto)
	if _material:
		_material.set_shader_parameter(&"tamano", Vector2(maxf(ancho, 1.0), maxf(alto, 1.0)))
	# Remates en rombo, centrados en los extremos.
	var lado: float = clampf(size.y * 0.9, 8.0, 18.0)
	for remate: Panel in [_remate_izq, _remate_der]:
		remate.visible = mostrar_remates
		remate.size = Vector2(lado, lado)
		remate.pivot_offset = remate.size * 0.5
		remate.rotation = PI / 4.0
	_remate_izq.position = Vector2(-lado * 0.5, size.y * 0.5 - lado * 0.5)
	_remate_der.position = Vector2(size.x - lado * 0.5, size.y * 0.5 - lado * 0.5)
