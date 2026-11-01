class_name FiguraVigiaHueco
extends Node3D
## Controlador de animación procedural para el Vigía Hueco (TAREA-012).
## Anima las articulaciones (cuello, piernas, brazos y lanza) leyendo el estado del enemigo.

var _enemigo: Enemigo
var _tiempo: float = 0.0
var _ciclo_paso: float = 0.0

@onready var _cuello: Node3D = get_parent().get_node_or_null(^"Cuello")
@onready var _faldon: Node3D = get_parent().get_node_or_null(^"Faldon")
@onready var _pierna_delante: Node3D = get_parent().get_node_or_null(^"PiernaDelante")
@onready var _pierna_detras: Node3D = get_parent().get_node_or_null(^"PiernaDetras")
@onready var _brazo_libre: Node3D = get_parent().get_node_or_null(^"BrazoLibre")
@onready var _brazo_lanza: Node3D = get_parent().get_node_or_null(^"BrazoLanza")
@onready var _pivote_lanza: Node3D = get_parent().get_node_or_null(^"BrazoLanza/PivoteLanza")
@onready var _torso: MeshInstance3D = get_parent().get_node_or_null(^"Cuerpo")


func _ready() -> void:
	_enemigo = owner as Enemigo
	if _enemigo == null and get_parent():
		_enemigo = get_parent().get_parent() as Enemigo


func _process(delta: float) -> void:
	if _enemigo == null or not is_instance_valid(_torso):
		return

	_tiempo += delta
	var vel_x: float = _enemigo.velocity.x
	var rapidez: float = clampf(absf(vel_x) / maxf(_enemigo.velocidad, 0.01), 0.0, 1.0)
	var est: Enemigo.Estado = _enemigo.estado

	var ang_pierna_a: float = 0.0
	var ang_pierna_b: float = 0.0
	var ang_brazo_libre: float = 0.0
	var ang_brazo_lanza: float = 0.0
	var pos_lanza_x: float = 0.0
	var ang_cuello: float = 0.0
	var ang_torso: float = 0.0
	var caida_cuerpo: float = 0.0

	match est:
		Enemigo.Estado.REPOSO:
			var respiracion: float = sin(_tiempo * 2.5) * 0.03
			ang_cuello = respiracion * 0.5
			ang_torso = respiracion * 0.3
			ang_brazo_lanza = -0.15 + respiracion
			ang_brazo_libre = 0.15 - respiracion

		Enemigo.Estado.PERSECUCION:
			_ciclo_paso += delta * 7.5 * rapidez
			var s: float = sin(_ciclo_paso)
			ang_pierna_a = s * 0.65 * rapidez
			ang_pierna_b = -ang_pierna_a
			ang_brazo_libre = -s * 0.45 * rapidez
			ang_brazo_lanza = -0.25 + s * 0.18 * rapidez
			ang_torso = -0.12 * rapidez
			caida_cuerpo = absf(cos(_ciclo_paso)) * 0.04 * rapidez

		Enemigo.Estado.ATAQUE:
			var etapa: Enemigo.Etapa = _enemigo.etapa
			var t_etapa: float = _enemigo.tiempo_en_etapa()
			match etapa:
				Enemigo.Etapa.PREPARACION:
					# Carga la lanza hacia atrás con tensión
					var dur_prep: float = _enemigo.ataques[0].preparacion if not _enemigo.ataques.is_empty() else 0.5
					var p: float = clampf(t_etapa / maxf(dur_prep, 0.01), 0.0, 1.0)
					ang_torso = 0.15 * p
					ang_cuello = -0.1 * p
					ang_brazo_lanza = -0.4 * p
					pos_lanza_x = -0.38 * p
					ang_brazo_libre = 0.35 * p
				Enemigo.Etapa.ACTIVO:
					# Estocada violenta hacia adelante
					ang_torso = -0.22
					ang_cuello = 0.15
					ang_brazo_lanza = -0.15
					pos_lanza_x = 0.55
					ang_brazo_libre = -0.4
					ang_pierna_a = 0.35
					ang_pierna_b = -0.35
				Enemigo.Etapa.RECUPERACION:
					var p_rec: float = clampf(t_etapa / 0.4, 0.0, 1.0)
					ang_torso = lerpf(-0.22, 0.0, p_rec)
					pos_lanza_x = lerpf(0.55, 0.0, p_rec)
					ang_brazo_lanza = lerpf(-0.15, 0.0, p_rec)

		Enemigo.Estado.RUPTURA, Enemigo.Estado.ATURDIDO:
			# Desarticulado, cabeza caída y cuerpo vencido
			ang_cuello = -0.65
			ang_torso = 0.28
			ang_brazo_lanza = -0.85
			ang_brazo_libre = -0.75
			ang_pierna_a = 0.25
			ang_pierna_b = -0.25
			caida_cuerpo = 0.12

	var suave: float = 1.0 - exp(-delta * 14.0)
	if is_instance_valid(_cuello):
		_cuello.rotation.z = lerp_angle(_cuello.rotation.z, ang_cuello, suave)
	if is_instance_valid(_torso):
		_torso.rotation.z = lerp_angle(_torso.rotation.z, ang_torso, suave)
		_torso.position.y = lerpf(_torso.position.y, 1.05 - caida_cuerpo, suave)
	if is_instance_valid(_faldon):
		_faldon.rotation.z = lerp_angle(_faldon.rotation.z, ang_torso * 0.6, suave)
	if is_instance_valid(_pierna_delante):
		_pierna_delante.rotation.z = lerp_angle(_pierna_delante.rotation.z, ang_pierna_a, suave)
	if is_instance_valid(_pierna_detras):
		_pierna_detras.rotation.z = lerp_angle(_pierna_detras.rotation.z, ang_pierna_b, suave)
	if is_instance_valid(_brazo_libre):
		_brazo_libre.rotation.z = lerp_angle(_brazo_libre.rotation.z, ang_brazo_libre, suave)
	if is_instance_valid(_brazo_lanza):
		_brazo_lanza.rotation.z = lerp_angle(_brazo_lanza.rotation.z, ang_brazo_lanza, suave)
	if is_instance_valid(_pivote_lanza):
		_pivote_lanza.position.x = lerpf(_pivote_lanza.position.x, pos_lanza_x, suave * 1.5)
