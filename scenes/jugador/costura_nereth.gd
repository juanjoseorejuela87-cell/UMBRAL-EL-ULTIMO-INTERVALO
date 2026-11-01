class_name CosturaNereth
extends Node
## Costura de Continuidad de Nereth: desde el Desfase, mantener el botón cerca
## de un elemento cosible lo cose (Puntada temporal o Remiendo permanente).
## Nereth llama a procesar() cada frame de física.
## Diseño: documentation/GAMEPLAY.md §4. El Desgarro (combate) llega con los
## enemigos que tienen Hilos.

signal costura_iniciada(objetivo: ElementoCosible)
signal costura_completada(objetivo: ElementoCosible)
signal costura_cancelada

@export var alcance: float = 6.0
@export var tiempo_canalizacion: float = 0.35
@export var puntadas_simultaneas: int = 1

## Elemento al que se coserá (el más cercano disponible), o null.
var objetivo: ElementoCosible

var _canalizando: bool = false
var _tiempo: float = 0.0
var _puntadas: Array[ElementoCosible] = []
var _fase: GestorFase = GestorFase.global()

@onready var _nereth: Nereth = get_parent() as Nereth
@onready var _resonancia: ComponenteResonancia = $"../Resonancia"


func canalizando() -> bool:
	return _canalizando


func procesar(delta: float) -> void:
	for i: int in range(_puntadas.size() - 1, -1, -1):
		if not is_instance_valid(_puntadas[i]) or not _puntadas[i].esta_cosido():
			_puntadas.remove_at(i)
	if _canalizando:
		if not Input.is_action_pressed(&"coser") or not _fase.en_desfase() \
				or _nereth.estado != Nereth.Estado.ACCION:
			cancelar()
		else:
			_tiempo += delta
			if _tiempo >= tiempo_canalizacion:
				_completar()
		return

	_cambiar_objetivo(_buscar_objetivo() if _fase.en_desfase() else null)
	if Input.is_action_just_pressed(&"coser") and objetivo \
			and _nereth.estado == Nereth.Estado.SUELO and _puede_pagar(objetivo):
		_canalizando = true
		_tiempo = 0.0
		_nereth.comenzar_accion(0.0, 0.0)
		costura_iniciada.emit(objetivo)


func cancelar() -> void:
	if not _canalizando:
		return
	_canalizando = false
	_nereth.terminar_accion()
	costura_cancelada.emit()


func _puede_pagar(elemento: ElementoCosible) -> bool:
	# Debe sobrar algo: coser no puede provocar un Rechazo inmediato.
	return elemento.coste() <= 0.0 or _resonancia.actual > elemento.coste()


func _completar() -> void:
	_canalizando = false
	var elemento: ElementoCosible = objetivo
	_resonancia.gastar(elemento.coste())
	if elemento.tipo == ElementoCosible.Tipo.PUNTADA:
		_puntadas.append(elemento)
		while _puntadas.size() > puntadas_simultaneas:
			_puntadas.pop_front().soltar()
	elemento.coser()
	_nereth.terminar_accion()
	costura_completada.emit(elemento)


func _buscar_objetivo() -> ElementoCosible:
	var centro: Vector3 = _nereth.global_position + Vector3.UP * 0.9
	var mejor: ElementoCosible = null
	var mejor_distancia: float = alcance
	for nodo: Node in _nereth.get_tree().get_nodes_in_group(ElementoCosible.GRUPO):
		var elemento: ElementoCosible = nodo as ElementoCosible
		if elemento == null or not elemento.disponible():
			continue
		var distancia: float = elemento.distancia_a(centro)
		if distancia <= mejor_distancia:
			mejor = elemento
			mejor_distancia = distancia
	return mejor


func _cambiar_objetivo(nuevo: ElementoCosible) -> void:
	if nuevo == objetivo:
		return
	if is_instance_valid(objetivo):
		objetivo.resaltar(false)
	objetivo = nuevo
	if objetivo:
		objetivo.resaltar(true)
