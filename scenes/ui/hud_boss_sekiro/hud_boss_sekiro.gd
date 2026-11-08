class_name HUDBossSekiro
extends Control
## Barra de jefe estilo Sekiro: título ceremonial con tipografía de serifas,
## vida colosal con desgaste rezagado (Tween TRANS_CUBIC + EASE_OUT) y barra de
## Postura que crece desde el centro con cada parry y estalla en «QUIEBRE».
## Funciona con cualquier Enemigo (usa sus componentes Vida y Postura); si el
## jefe tiene «vidas_restantes» muestra los Sellos de Ejecución.

const COLOR_POSTURA: Color = Color(0.92, 0.66, 0.2)
const COLOR_POSTURA_CRITICA: Color = Color(1.0, 0.28, 0.12)
const UMBRAL_CRITICO: float = 0.8

@export var jefe: Enemigo
## Si está vacío se usa «nombre_dialogo» del jefe o su nombre de nodo.
@export var nombre_jefe: String = ""
@export var mostrar_al_iniciar: bool = true

@onready var _contenedor: Control = $Contenedor
@onready var _nombre: Label = $Contenedor/Columna/FilaNombre/Nombre
@onready var _sellos: HBoxContainer = $Contenedor/Columna/FilaNombre/Sellos
@onready var _barra_vida: BarraOrnamental = $Contenedor/Columna/BarraVida
@onready var _barra_postura: BarraOrnamental = $Contenedor/Columna/FilaPostura/BarraPostura
@onready var _quiebre: Label = $Contenedor/Columna/FilaPostura/Quiebre

var _tween_visible: Tween
var _tween_quiebre: Tween
var _mostrada: bool = false


func _ready() -> void:
	_contenedor.modulate.a = 0.0
	_quiebre.modulate.a = 0.0
	if jefe:
		conectar_jefe(jefe, nombre_jefe)
		if mostrar_al_iniciar:
			mostrar()


func conectar_jefe(nuevo_jefe: Enemigo, nombre: String = "") -> void:
	jefe = nuevo_jefe
	if not jefe.is_node_ready():
		await jefe.ready
	var titulo: String = nombre
	if titulo == "":
		var de_dialogo: Variant = jefe.get(&"nombre_dialogo")
		titulo = String(de_dialogo) if de_dialogo is String else String(jefe.name)
	_nombre.text = titulo.to_upper()
	if jefe.vida:
		_conectar(jefe.vida.cambiada, _al_cambiar_vida)
		_barra_vida.fijar(jefe.vida.actual, jefe.vida.maximo, false)
	if jefe.postura:
		_conectar(jefe.postura.cambiada, _al_cambiar_postura)
		_conectar(jefe.postura.rota, _al_romper_postura)
		_barra_postura.fijar(jefe.postura.actual, jefe.postura.maximo, false)
	if jefe.has_signal(&"fase_iniciada"):
		_conectar(Signal(jefe, &"fase_iniciada"), _al_cambiar_fase)
	if jefe.has_signal(&"jefe_derrotado"):
		_conectar(Signal(jefe, &"jefe_derrotado"), _al_derrotar)
	if jefe.has_signal(&"combate_iniciado"):
		_conectar(Signal(jefe, &"combate_iniciado"), _al_iniciar_combate)
	if jefe.has_signal(&"combate_reiniciado"):
		_conectar(Signal(jefe, &"combate_reiniciado"), _al_reiniciar_combate)
	if jefe.has_signal(&"fase_cambiada"):
		_conectar(Signal(jefe, &"fase_cambiada"), _al_cambiar_fase)
	_conectar(jefe.derrotado, _al_derrotar_enemigo)
	actualizar_sellos()


func _conectar(senal: Signal, metodo: Callable) -> void:
	if not senal.is_connected(metodo):
		senal.connect(metodo)


func mostrar() -> void:
	if _mostrada:
		return
	_mostrada = true
	visible = true
	if _tween_visible and _tween_visible.is_valid():
		_tween_visible.kill()
	_contenedor.position.y = -16.0
	_tween_visible = create_tween()
	_tween_visible.tween_property(_contenedor, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween_visible.parallel().tween_property(_contenedor, "position:y", 0.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func ocultar(espera: float = 1.5) -> void:
	_mostrada = false
	if _tween_visible and _tween_visible.is_valid():
		_tween_visible.kill()
	_tween_visible = create_tween()
	_tween_visible.tween_interval(espera)
	_tween_visible.tween_property(_contenedor, "modulate:a", 0.0, 1.2)


func mostrada() -> bool:
	return _mostrada


func _al_iniciar_combate() -> void:
	if jefe and jefe.vida and jefe.vida.actual > 0.0:
		mostrar()


func _al_reiniciar_combate() -> void:
	if jefe and jefe.vida:
		_barra_vida.fijar(jefe.vida.actual, jefe.vida.maximo, false)
	if jefe and jefe.postura:
		_barra_postura.fijar(jefe.postura.actual, jefe.postura.maximo, false)
	ocultar(0.0)


func _al_cambiar_vida(actual: float, maximo: float) -> void:
	var dano: bool = actual < _barra_vida.valor
	_barra_vida.fijar(actual, maximo, true)
	if dano:
		_barra_vida.destello(Color(1.0, 0.9, 0.85), 0.2)


func _al_cambiar_postura(actual: float, maximo: float) -> void:
	var subio: bool = actual > _barra_postura.valor
	_barra_postura.fijar(actual, maximo, true)
	var critica: bool = actual >= maximo * UMBRAL_CRITICO
	_barra_postura.color_relleno = COLOR_POSTURA_CRITICA if critica else COLOR_POSTURA
	_barra_postura.alerta(critica, Color(1.0, 0.9, 0.6))
	if subio and not critica:
		_barra_postura.destello(Color(1.0, 0.95, 0.75), 0.25)


func _al_romper_postura() -> void:
	_barra_postura.alerta(false)
	_barra_postura.destello(Color.WHITE, 0.8)
	if _tween_quiebre and _tween_quiebre.is_valid():
		_tween_quiebre.kill()
	_quiebre.pivot_offset = _quiebre.size * 0.5
	_quiebre.scale = Vector2(1.6, 1.6)
	_quiebre.modulate.a = 1.0
	_tween_quiebre = create_tween()
	_tween_quiebre.tween_property(_quiebre, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween_quiebre.tween_interval(1.2)
	_tween_quiebre.tween_property(_quiebre, "modulate:a", 0.0, 0.6)


func _al_cambiar_fase(_fase: int) -> void:
	actualizar_sellos()


func _al_derrotar() -> void:
	_barra_vida.fijar(0.0, _barra_vida.maximo, true)
	_barra_postura.fijar(0.0, _barra_postura.maximo, false)
	actualizar_sellos()
	ocultar(2.0)


func _al_derrotar_enemigo(_enemigo: Enemigo) -> void:
	_al_derrotar()


## Sellos de Ejecución: un rombo por cada vida que le queda al jefe.
func actualizar_sellos() -> void:
	if not jefe:
		return
	var restantes: Variant = jefe.get(&"vidas_restantes")
	var totales: Variant = jefe.get(&"vidas_totales")
	_sellos.visible = restantes is int and totales is int
	if not _sellos.visible:
		return
	var i: int = 0
	for sello: Node in _sellos.get_children():
		var panel: Panel = sello as Panel
		panel.visible = i < int(totales)
		panel.modulate = Color.WHITE if i < int(restantes) else Color(0.25, 0.22, 0.22, 0.7)
		i += 1


func barra_vida() -> BarraOrnamental:
	return _barra_vida


func barra_postura() -> BarraOrnamental:
	return _barra_postura


func titulo() -> String:
	return _nombre.text
