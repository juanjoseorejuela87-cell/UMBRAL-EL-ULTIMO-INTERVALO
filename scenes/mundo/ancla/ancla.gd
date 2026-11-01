class_name AnclaContinuidad
extends Area3D
## Ancla de Continuidad: dormida hasta que se estabiliza (con o sin reto local).
## Estabilizada permite descansar: guardar, restaurar a Nereth, fijar la
## reaparición y reiniciar la zona. Al estabilizarse retira sus distorsiones.
## Diseño: documentation/GAMEPLAY.md §5.

signal estabilizada
signal descanso

enum Estado { DORMIDA, ESTABILIZADA }

const COLOR_DORMIDA: Color = Color(0.35, 0.35, 0.42)
const COLOR_ESTABLE: Color = Color(0.55, 0.75, 1.0)

## Identificador único en todo el juego (se guarda en la partida).
@export var id: StringName = &""
## Si es true, hay que llamar a completar_reto() antes de poder estabilizarla.
@export var requiere_reto: bool = false
## Elementos de la zona que desaparecen al estabilizar el Ancla.
@export var distorsiones: Array[Node3D] = []

var estado: Estado = Estado.DORMIDA
var reto_completado: bool = false

var _nereth_cerca: Nereth
var _material_cristal: StandardMaterial3D

@onready var _punto: Marker3D = $PuntoReaparicion
@onready var _aviso: Label3D = $Aviso
@onready var _cristal: MeshInstance3D = $Cristal
@onready var _luz: OmniLight3D = $Luz


func _ready() -> void:
	if id == &"":
		push_warning("Ancla sin id en %s" % get_path())
	_material_cristal = (_cristal.get_active_material(0) as StandardMaterial3D).duplicate()
	_cristal.set_surface_override_material(0, _material_cristal)
	body_entered.connect(_al_entrar)
	body_exited.connect(_al_salir)
	if GestorPartida.global().ancla_estabilizada(id):
		_aplicar_estabilizacion()
	_actualizar_visual()
	_aviso.visible = false


func completar_reto() -> void:
	reto_completado = true
	_actualizar_visual()


func puede_estabilizar() -> bool:
	return not requiere_reto or reto_completado


func _physics_process(_delta: float) -> void:
	if _nereth_cerca and Input.is_action_just_pressed(&"interactuar") \
			and _nereth_cerca.estado == Nereth.Estado.SUELO:
		interactuar(_nereth_cerca)


## Estabiliza (si está dormida y se puede) y descansa.
func interactuar(nereth: Nereth) -> void:
	if estado == Estado.DORMIDA:
		if not puede_estabilizar():
			return
		GestorPartida.global().estabilizar_ancla(id)
		_aplicar_estabilizacion()
		estabilizada.emit()
	GestorPartida.global().descansar(nereth, id, _punto.global_position)
	GestorSonido.global().reproducir(&"ancla", -2.0, 0.0)
	descanso.emit()


func _aplicar_estabilizacion() -> void:
	estado = Estado.ESTABILIZADA
	for distorsion: Node3D in distorsiones:
		_retirar(distorsion)
	_actualizar_visual()


func _retirar(nodo: Node3D) -> void:
	nodo.visible = false
	if "use_collision" in nodo:
		nodo.set("use_collision", false)
	if nodo is CollisionObject3D:
		(nodo as CollisionObject3D).collision_layer = 0
	nodo.process_mode = Node.PROCESS_MODE_DISABLED


func _actualizar_visual() -> void:
	var estable: bool = estado == Estado.ESTABILIZADA
	_material_cristal.emission = COLOR_ESTABLE if estable else COLOR_DORMIDA
	_material_cristal.emission_energy_multiplier = 1.6 if estable else 0.3
	_luz.visible = estable
	if estable:
		_aviso.text = "[E] Descansar"
	elif puede_estabilizar():
		_aviso.text = "[E] Estabilizar"
	else:
		_aviso.text = "El Ancla no responde"


func _al_entrar(cuerpo: Node3D) -> void:
	var nereth: Nereth = cuerpo as Nereth
	if nereth:
		_nereth_cerca = nereth
		_aviso.visible = true


func _al_salir(cuerpo: Node3D) -> void:
	if cuerpo == _nereth_cerca:
		_nereth_cerca = null
		_aviso.visible = false
