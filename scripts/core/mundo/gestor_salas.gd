class_name GestorSalas
extends Node
## Cambio de sala (autoload "Salas"): fundido a negro, carga de la escena y
## colocación de Nereth en la entrada indicada (o en una posición), conservando
## su vida y Resonancia entre salas.

signal sala_cambiada(escena: String)

@export var duracion_fundido: float = 0.25

var _entrada_pendiente: StringName = &""
var _posicion_pendiente: Vector3 = Vector3.ZERO
var _usar_posicion: bool = false
var _restaurar_al_llegar: bool = false
var _estado_nereth: Dictionary = {}
var _cambiando: bool = false
var _velo: ColorRect

static var _instancia: GestorSalas


func _init() -> void:
	_instancia = self


## Acceso sin depender del nombre del autoload (ver GestorFase.global()).
static func global() -> GestorSalas:
	return _instancia


func _ready() -> void:
	# El fundido debe avanzar aunque el juego esté en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var capa := CanvasLayer.new()
	capa.layer = 100
	add_child(capa)
	_velo = ColorRect.new()
	_velo.color = Color(0.0, 0.0, 0.0, 0.0)
	_velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(_velo)


func cambiando() -> bool:
	return _cambiando


## Va a otra sala y coloca a Nereth en el PuntoEntrada con ese id.
func ir_a_entrada(escena: String, entrada: StringName) -> void:
	_entrada_pendiente = entrada
	_usar_posicion = false
	_restaurar_al_llegar = false
	_cambiar(escena)


## Va a otra sala y coloca a Nereth en una posición (reaparición en un Ancla).
func ir_a_posicion(escena: String, posicion: Vector3, restaurar: bool = false) -> void:
	_entrada_pendiente = &""
	_posicion_pendiente = posicion
	_usar_posicion = true
	_restaurar_al_llegar = restaurar
	_cambiar(escena)


func _cambiar(escena: String) -> void:
	if _cambiando:
		return
	_cambiando = true
	# Suele llamarse desde una señal de física (body_entered): no se puede
	# liberar la escena dentro de ese callback.
	await get_tree().process_frame
	_guardar_estado_nereth()
	await _fundir(1.0)
	get_tree().change_scene_to_file(escena)
	# El cambio se aplica al final del frame; un frame más para los _ready.
	await get_tree().process_frame
	await get_tree().process_frame
	_colocar_nereth()
	_cambiando = false
	sala_cambiada.emit(escena)
	await _fundir(0.0)


func _fundir(opacidad: float) -> void:
	if duracion_fundido <= 0.0:
		_velo.color.a = opacidad
		return
	var tween: Tween = create_tween()
	tween.tween_property(_velo, "color:a", opacidad, duracion_fundido)
	await tween.finished


func _nereth() -> Nereth:
	return get_tree().get_first_node_in_group(Nereth.GRUPO) as Nereth


func _guardar_estado_nereth() -> void:
	var nereth: Nereth = _nereth()
	_estado_nereth.clear()
	if nereth:
		_estado_nereth = {"vida": nereth.vida.actual, "resonancia": nereth.resonancia.actual}


func _colocar_nereth() -> void:
	var nereth: Nereth = _nereth()
	if nereth == null:
		return
	if _usar_posicion:
		nereth.reaparecer(_posicion_pendiente)
	elif _entrada_pendiente != &"":
		for nodo: Node in get_tree().get_nodes_in_group(PuntoEntrada.GRUPO):
			var punto: PuntoEntrada = nodo as PuntoEntrada
			if punto and punto.id == _entrada_pendiente:
				nereth.reaparecer(punto.global_position)
				nereth.mirando = punto.mirando
				break
	if _restaurar_al_llegar:
		nereth.restaurar()
	elif not _estado_nereth.is_empty():
		nereth.vida.establecer(_estado_nereth["vida"])
		nereth.resonancia.establecer(_estado_nereth["resonancia"])
	_entrada_pendiente = &""
	_usar_posicion = false
	_restaurar_al_llegar = false
