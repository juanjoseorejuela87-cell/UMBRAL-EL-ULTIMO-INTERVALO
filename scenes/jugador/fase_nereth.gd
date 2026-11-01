class_name FaseNereth
extends Node
## Control del Desfase de Nereth: cambio de estado, transición con golpes que
## atraviesan, Desfase preciso y Rechazo al agotar la Resonancia.
## Nereth llama a procesar() cada frame de física.
## Diseño: documentation/GAMEPLAY.md §3.

signal cambio_bloqueado
signal rechazo
signal desfase_preciso

@export var duracion_transicion: float = 0.3
@export var aturdimiento_rechazo: float = 0.5
@export var bloqueo_tras_rechazo: float = 2.0
## Resonancia devuelta al cambiar de estado justo cuando llega un golpe.
@export var reembolso_desfase_preciso: float = 10.0
## Accesibilidad: el Desfase dura mientras se mantiene el botón.
@export var modo_mantener: bool = false

var _transicion: float = 0.0
var _bloqueo: float = 0.0
var _rechazo_pendiente: bool = false
var _preciso_usado: bool = false
var _forma_consulta: CapsuleShape3D
var _fase: GestorFase = GestorFase.global()

@onready var _nereth: Nereth = get_parent() as Nereth
@onready var _resonancia: ComponenteResonancia = $"../Resonancia"
@onready var _colision: CollisionShape3D = $"../Colision"


func _ready() -> void:
	# Forma algo menor que el cuerpo: apoyarse en una superficie no cuenta como
	# estar dentro de ella.
	var cuerpo: CapsuleShape3D = _colision.shape as CapsuleShape3D
	_forma_consulta = CapsuleShape3D.new()
	_forma_consulta.radius = cuerpo.radius * 0.85
	_forma_consulta.height = cuerpo.height * 0.85
	_resonancia.agotada.connect(_al_agotarse)
	($"../CajaDano" as CajaDano).golpe_evitado.connect(_al_evitar_golpe)
	_fase.cambiar(GestorFase.Estado.REALIDAD)
	_ajustar_colision(GestorFase.Estado.REALIDAD)


## Vuelve a la Realidad sin transición (Anclas, reapariciones, pruebas).
func reiniciar() -> void:
	_rechazo_pendiente = false
	_bloqueo = 0.0
	_transicion = 0.0
	_resonancia.salir()
	_fase.cambiar(GestorFase.Estado.REALIDAD)
	_ajustar_colision(GestorFase.Estado.REALIDAD)


func en_transicion() -> bool:
	return _transicion > 0.0


func procesar(delta: float) -> void:
	_transicion = maxf(_transicion - delta, 0.0)
	_bloqueo = maxf(_bloqueo - delta, 0.0)
	if _rechazo_pendiente:
		_intentar_rechazo()
	elif _quiere_cambiar():
		intentar_cambiar()
	_nereth.invulnerable_transicion = en_transicion()


## Cambia al estado opuesto si es posible. Devuelve true si cambió.
func intentar_cambiar() -> bool:
	if en_transicion() or _bloqueo > 0.0 or _nereth.estado == Nereth.Estado.ATURDIDO:
		return false
	var destino: GestorFase.Estado = GestorFase.opuesto(_fase.estado)
	if destino == GestorFase.Estado.DESFASE and not _resonancia.puede_entrar():
		cambio_bloqueado.emit()
		return false
	if _hay_solido_en(destino):
		cambio_bloqueado.emit()
		return false
	_aplicar(destino)
	return true


func _quiere_cambiar() -> bool:
	if modo_mantener:
		return Input.is_action_pressed(&"desfase") != _fase.en_desfase()
	return Input.is_action_just_pressed(&"desfase")


func _aplicar(destino: GestorFase.Estado) -> void:
	if destino == GestorFase.Estado.DESFASE:
		_resonancia.entrar()
	else:
		_resonancia.salir()
	_fase.cambiar(destino)
	_ajustar_colision(destino)
	_transicion = duracion_transicion
	_preciso_usado = false


func _ajustar_colision(estado: GestorFase.Estado) -> void:
	_nereth.collision_mask = GestorFase.CAPA_COMUN | GestorFase.capa_de(estado)


## True si en el estado de destino Nereth quedaría dentro de un sólido.
func _hay_solido_en(destino: GestorFase.Estado) -> bool:
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = _forma_consulta
	consulta.transform = _colision.global_transform
	consulta.collision_mask = GestorFase.capa_de(destino)
	consulta.exclude = [_nereth.get_rid()]
	return not _nereth.get_world_3d().direct_space_state.intersect_shape(consulta, 1).is_empty()


func _al_agotarse() -> void:
	if _fase.en_desfase():
		_rechazo_pendiente = true


## Expulsa a la Realidad en cuanto no haya un sólido real en el sitio.
func _intentar_rechazo() -> void:
	if _hay_solido_en(GestorFase.Estado.REALIDAD):
		return
	_rechazo_pendiente = false
	_aplicar(GestorFase.Estado.REALIDAD)
	_bloqueo = bloqueo_tras_rechazo
	_nereth.aturdir(aturdimiento_rechazo)
	rechazo.emit()


func _al_evitar_golpe(_info: InfoGolpe) -> void:
	if en_transicion() and not _preciso_usado:
		_preciso_usado = true
		_resonancia.ganar(reembolso_desfase_preciso)
		desfase_preciso.emit()
