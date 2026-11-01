class_name FiguraPrefecto
extends Node3D
## Controlador de animación procedural para el Prefecto de las Puertas (TAREA-012).
## Anima la figura monumental, la alabarda ceremonial, la capa y la pulsación de la luz del yelmo.

var _enemigo: Prefecto
var _tiempo: float = 0.0
var _ciclo_paso: float = 0.0
var _pulso_luz: float = 1.8
var _mat_luz: StandardMaterial3D

@onready var _cuello: Node3D = get_parent().get_node_or_null(^"Cuello")
@onready var _faldon: Node3D = get_parent().get_node_or_null(^"Faldon")
@onready var _cuerpo: MeshInstance3D = get_parent().get_node_or_null(^"Cuerpo")
@onready var _brazo_libre: Node3D = get_parent().get_node_or_null(^"BrazoLibre")
@onready var _brazo_alabarda: Node3D = get_parent().get_node_or_null(^"BrazoAlabarda")
@onready var _pivote_alabarda: Node3D = get_parent().get_node_or_null(^"BrazoAlabarda/PivoteAlabarda")
@onready var _pierna_delante: Node3D = get_parent().get_node_or_null(^"PiernaDelante")
@onready var _pierna_detras: Node3D = get_parent().get_node_or_null(^"PiernaDetras")
@onready var _luz_yelmo: MeshInstance3D = get_parent().get_node_or_null(^"Cuello/LuzYelmo")
@onready var _capa_segmentos: Array[Node3D] = []


func _ready() -> void:
	_enemigo = owner as Prefecto
	if _enemigo == null and get_parent():
		_enemigo = get_parent().get_parent() as Prefecto

	if is_instance_valid(_luz_yelmo):
		var mat_orig: Material = _luz_yelmo.get_active_material(0)
		if mat_orig is StandardMaterial3D:
			_mat_luz = mat_orig.duplicate() as StandardMaterial3D
			_luz_yelmo.set_surface_override_material(0, _mat_luz)

	var contenedor_capa: Node3D = get_parent().get_node_or_null(^"Capa")
	if contenedor_capa:
		for hijo in contenedor_capa.get_children():
			if hijo is Node3D:
				_capa_segmentos.append(hijo as Node3D)

	if _enemigo:
		_enemigo.ataque_telegrafiado.connect(func(_d: DatosAtaque) -> void:
			_pulso_luz = 5.2
		)


func _process(delta: float) -> void:
	if _enemigo == null or not is_instance_valid(_cuerpo):
		return

	_tiempo += delta
	var vel_x: float = _enemigo.velocity.x
	var rapidez: float = clampf(absf(vel_x) / maxf(_enemigo.velocidad, 0.01), 0.0, 1.0)
	var est: Enemigo.Estado = _enemigo.estado

	var ang_pierna_a: float = 0.0
	var ang_pierna_b: float = 0.0
	var ang_brazo_libre: float = 0.1
	var ang_brazo_alabarda: float = -0.15
	var rot_alabarda_z: float = 0.0
	var pos_alabarda_x: float = 0.0
	var ang_cuello: float = 0.0
	var ang_torso: float = 0.0

	# Decaimiento del pulso de la luz del yelmo
	_pulso_luz = move_toward(_pulso_luz, 1.8, delta * 3.5)
	if is_instance_valid(_mat_luz):
		_mat_luz.emission_energy_multiplier = _pulso_luz + sin(_tiempo * 4.0) * 0.25

	match est:
		Enemigo.Estado.REPOSO:
			var latido: float = sin(_tiempo * 2.0) * 0.04
			ang_cuello = latido * 0.5
			ang_torso = latido * 0.3
			ang_brazo_alabarda = -0.15 + latido
			ang_brazo_libre = 0.15 - latido

		Enemigo.Estado.PERSECUCION:
			_ciclo_paso += delta * 5.0 * rapidez
			var s: float = sin(_ciclo_paso)
			ang_pierna_a = s * 0.6 * rapidez
			ang_pierna_b = -ang_pierna_a
			ang_brazo_libre = -s * 0.4 * rapidez
			ang_brazo_alabarda = -0.25 + s * 0.15 * rapidez
			ang_torso = -0.1 * rapidez

		Enemigo.Estado.ATAQUE:
			var etapa: Enemigo.Etapa = _enemigo.etapa
			var t_etapa: float = _enemigo.tiempo_en_etapa()
			var atk: DatosAtaque = _enemigo.ataque_actual
			var es_estocada: bool = atk != null and atk.resource_path.contains("estocada")
			var es_descendente: bool = atk != null and (atk.resource_path.contains("llave") or atk.resource_path.contains("cierre") or atk.resource_path.contains("salida"))

			_pulso_luz = maxf(_pulso_luz, 4.0)

			match etapa:
				Enemigo.Etapa.PREPARACION:
					var p: float = clampf(t_etapa / 0.5, 0.0, 1.0)
					if es_estocada:
						ang_brazo_alabarda = lerpf(-0.15, -0.6, p)
						pos_alabarda_x = lerpf(0.0, -0.45, p)
						rot_alabarda_z = lerpf(0.0, -1.4, p)
						ang_torso = 0.12 * p
					elif es_descendente:
						# Alabarda en alto vertical lista para descargar
						ang_brazo_alabarda = lerpf(-0.15, 2.7, p)
						rot_alabarda_z = lerpf(0.0, 0.6, p)
						ang_torso = 0.18 * p
					else:
						# Barrido giratorio
						ang_brazo_alabarda = lerpf(-0.15, -0.4, p)
						rot_alabarda_z = lerpf(0.0, -1.8, p)
						ang_torso = 0.2 * p
				Enemigo.Etapa.ACTIVO:
					if es_estocada:
						ang_brazo_alabarda = -0.2
						pos_alabarda_x = 0.85
						rot_alabarda_z = -1.57
						ang_torso = -0.25
					elif es_descendente:
						# Descarga brutal contra el suelo
						ang_brazo_alabarda = -0.65
						rot_alabarda_z = -0.3
						ang_torso = -0.35
						ang_cuello = 0.25
					else:
						# Barrido completo
						ang_brazo_alabarda = 0.8
						rot_alabarda_z = 1.6
						ang_torso = -0.2
				Enemigo.Etapa.RECUPERACION:
					var p_rec: float = clampf(t_etapa / 0.45, 0.0, 1.0)
					ang_brazo_alabarda = lerpf(-0.4, -0.15, p_rec)
					rot_alabarda_z = lerpf(-0.3, 0.0, p_rec)
					pos_alabarda_x = lerpf(pos_alabarda_x, 0.0, p_rec)
					ang_torso = lerpf(-0.3, 0.0, p_rec)

		Enemigo.Estado.RUPTURA, Enemigo.Estado.ATURDIDO:
			# Se apoya en una rodilla con cabeza gacha
			ang_cuello = -0.6
			ang_torso = 0.22
			ang_brazo_alabarda = -0.45
			rot_alabarda_z = -0.25
			ang_pierna_a = 0.45
			ang_pierna_b = -0.5
			_pulso_luz = 0.6

	var suave: float = 1.0 - exp(-delta * 14.0)
	if is_instance_valid(_cuello):
		_cuello.rotation.z = lerp_angle(_cuello.rotation.z, ang_cuello, suave)
	if is_instance_valid(_cuerpo):
		_cuerpo.rotation.z = lerp_angle(_cuerpo.rotation.z, ang_torso, suave)
	if is_instance_valid(_faldon):
		_faldon.rotation.z = lerp_angle(_faldon.rotation.z, ang_torso * 0.7, suave)
	if is_instance_valid(_brazo_libre):
		_brazo_libre.rotation.z = lerp_angle(_brazo_libre.rotation.z, ang_brazo_libre, suave)
	if is_instance_valid(_brazo_alabarda):
		_brazo_alabarda.rotation.z = lerp_angle(_brazo_alabarda.rotation.z, ang_brazo_alabarda, suave)
	if is_instance_valid(_pivote_alabarda):
		_pivote_alabarda.rotation.z = lerp_angle(_pivote_alabarda.rotation.z, rot_alabarda_z, suave * 1.5)
		_pivote_alabarda.position.x = lerpf(_pivote_alabarda.position.x, pos_alabarda_x, suave * 1.5)
	if is_instance_valid(_pierna_delante):
		_pierna_delante.rotation.z = lerp_angle(_pierna_delante.rotation.z, ang_pierna_a, suave)
	if is_instance_valid(_pierna_detras):
		_pierna_detras.rotation.z = lerp_angle(_pierna_detras.rotation.z, ang_pierna_b, suave)

	# Ondear la capa ceremonial
	var viento_capa: float = -0.5 * rapidez
	for i: int in _capa_segmentos.size():
		var seg: Node3D = _capa_segmentos[i]
		if is_instance_valid(seg):
			var onda: float = sin(_tiempo * 4.5 - i * 0.8) * (0.05 + 0.1 * rapidez)
			seg.rotation.z = lerp_angle(seg.rotation.z, viento_capa + onda, suave)
