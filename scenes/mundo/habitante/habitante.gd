class_name Habitante
extends Area3D
## Habitante atrapado en un bucle de memoria en Elyndor (TAREA-021).
## Repite un gesto característico por código y, al interactuar con Nereth cerca,
## reproduce sus líneas con Subtitulo.mostrar.

@export var nombre: String = "Habitante"
@export var lineas: PackedStringArray = []
@export var gesto: StringName = &"linterna"
## Estado de fase en el que existe (-1 para existir en ambos estados).
@export var existe_en: int = -1

var _nereth_cerca: Nereth
var _tiempo: float = 0.0
var _mat_llama: StandardMaterial3D
var _base_brazo_der_rot: Vector3 = Vector3.ZERO
var _base_brazo_izq_rot: Vector3 = Vector3.ZERO
var _base_brazo_der_pos: Vector3 = Vector3.ZERO
var _base_torso_rot: Vector3 = Vector3.ZERO

@onready var _aviso: Label3D = get_node_or_null("Aviso") as Label3D
@onready var _visual: Node3D = get_node_or_null("Visual") as Node3D
@onready var _torso: Node3D = get_node_or_null("Visual/Torso") as Node3D
@onready var _brazo_der: Node3D = get_node_or_null("Visual/BrazoDerecho") as Node3D
@onready var _brazo_izq: Node3D = get_node_or_null("Visual/BrazoIzquierdo") as Node3D
@onready var _prop_linterna: Node3D = get_node_or_null("Visual/Props/Linterna") as Node3D
@onready var _cristal_linterna: MeshInstance3D = get_node_or_null("Visual/Props/Linterna/Cristal") as MeshInstance3D
@onready var _prop_manto: Node3D = get_node_or_null("Visual/Props/Manto") as Node3D
@onready var _prop_llave: Node3D = get_node_or_null("Visual/Props/Llave") as Node3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 8
	monitorable = false
	monitoring = true

	body_entered.connect(_al_entrar)
	body_exited.connect(_al_salir)

	if _aviso:
		_aviso.visible = false

	if _brazo_der:
		_base_brazo_der_rot = _brazo_der.rotation
		_base_brazo_der_pos = _brazo_der.position
	if _brazo_izq:
		_base_brazo_izq_rot = _brazo_izq.rotation
	if _torso:
		_base_torso_rot = _torso.rotation

	_configurar_gesto()


func _configurar_gesto() -> void:
	if _prop_linterna:
		_prop_linterna.visible = (gesto == &"linterna")
	if _prop_manto:
		_prop_manto.visible = (gesto == &"manto")
	if _prop_llave:
		_prop_llave.visible = (gesto == &"llave")

	if gesto == &"linterna" and _cristal_linterna:
		var mat: Material = _cristal_linterna.get_active_material(0)
		if mat is StandardMaterial3D:
			_mat_llama = (mat as StandardMaterial3D).duplicate()
			_cristal_linterna.set_surface_override_material(0, _mat_llama)
	elif gesto == &"manto":
		if _brazo_der:
			_brazo_der.rotation = Vector3(-0.65, 0.2, 0.0)
		if _brazo_izq:
			_brazo_izq.rotation = Vector3(-0.65, -0.2, 0.0)
	elif gesto == &"llave":
		if _brazo_der:
			_brazo_der.rotation = Vector3(-0.75, 0.35, 0.0)


func _process(delta: float) -> void:
	_tiempo += delta
	match gesto:
		&"linterna":
			_animar_linterna()
		&"manto":
			_animar_manto()
		&"llave":
			_animar_llave()


func _physics_process(_delta: float) -> void:
	if _nereth_cerca and Input.is_action_just_pressed(&"interactuar"):
		hablar()


func hablar() -> Subtitulo:
	if lineas.is_empty():
		return null
	return Subtitulo.mostrar(get_tree(), nombre, lineas)


func interactuar() -> Subtitulo:
	return hablar()


func esta_cerca() -> bool:
	return _nereth_cerca != null


func _animar_linterna() -> void:
	# Encendido y apagado cíclico de la llama emisiva (sin OmniLight3D)
	var pulso: float = clampf(sin(_tiempo * 2.2) * 1.5 + 0.5, 0.0, 2.2)
	if _mat_llama:
		_mat_llama.emission_energy_multiplier = pulso
	if _prop_linterna:
		_prop_linterna.rotation.z = sin(_tiempo * 1.4) * 0.08
	if _torso:
		_torso.rotation.x = _base_torso_rot.x + sin(_tiempo * 1.4) * 0.02


func _animar_manto() -> void:
	# Mecido suave y continuo de brazos y torso sosteniendo el manto vacío
	var balanceo: float = sin(_tiempo * 1.8) * 0.07
	if _torso:
		_torso.rotation.z = _base_torso_rot.z + balanceo
	if _brazo_der:
		_brazo_der.rotation.x = -0.65 + sin(_tiempo * 1.8) * 0.07
	if _brazo_izq:
		_brazo_izq.rotation.x = -0.65 - sin(_tiempo * 1.8) * 0.07
	if _prop_manto:
		_prop_manto.position.y = 0.88 + sin(_tiempo * 1.8) * 0.02


func _animar_llave() -> void:
	# Frotado rápido y repetitivo de la llave oxidada contra el jubón en el pecho
	var frotado: float = sin(_tiempo * 7.5)
	if _brazo_der:
		_brazo_der.position.y = _base_brazo_der_pos.y + frotado * 0.025
		_brazo_der.rotation.x = -0.75 + frotado * 0.12
	if _prop_llave:
		_prop_llave.position.y = 0.98 + frotado * 0.025
		_prop_llave.rotation.z = frotado * 0.08
	if _torso:
		_torso.rotation.x = _base_torso_rot.x + 0.08 + sin(_tiempo * 3.5) * 0.015


func _al_entrar(cuerpo: Node3D) -> void:
	if cuerpo is Nereth:
		_nereth_cerca = cuerpo as Nereth
		if _aviso:
			_aviso.visible = true


func _al_salir(cuerpo: Node3D) -> void:
	if cuerpo == _nereth_cerca:
		_nereth_cerca = null
		if _aviso:
			_aviso.visible = false
