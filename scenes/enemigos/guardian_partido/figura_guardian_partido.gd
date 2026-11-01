class_name FiguraGuardianPartido
extends Node3D
## Controlador de animación procedural para el Guardián Partido (TAREA-012).
## Anima la armadura pesada partida en dos mitades temporales desfasadas.

var _enemigo: Enemigo
var _tiempo: float = 0.0
var _ciclo_paso: float = 0.0

@onready var _mitad_delantera: Node3D = get_parent().get_node_or_null(^"MitadDelantera")
@onready var _mitad_trasera: Node3D = get_parent().get_node_or_null(^"MitadTrasera")
@onready var _brazo_escudo: Node3D = get_parent().get_node_or_null(^"MitadDelantera/BrazoEscudo")
@onready var _brazo_maza: Node3D = get_parent().get_node_or_null(^"MitadTrasera/BrazoMaza")
@onready var _pierna_delantera: Node3D = get_parent().get_node_or_null(^"MitadDelantera/PiernaFrontal")
@onready var _pierna_trasera: Node3D = get_parent().get_node_or_null(^"MitadTrasera/PiernaTrasera")
@onready var _cuerpo: MeshInstance3D = get_parent().get_node_or_null(^"Cuerpo")


func _ready() -> void:
	_enemigo = owner as Enemigo
	if _enemigo == null and get_parent():
		_enemigo = get_parent().get_parent() as Enemigo


func _process(delta: float) -> void:
	if _enemigo == null or not is_instance_valid(_cuerpo):
		return

	_tiempo += delta
	var vel_x: float = _enemigo.velocity.x
	var rapidez: float = clampf(absf(vel_x) / maxf(_enemigo.velocidad, 0.01), 0.0, 1.0)
	var est: Enemigo.Estado = _enemigo.estado

	var offset_x_delante: float = 0.12
	var offset_x_detras: float = -0.16
	var rot_y_detras: float = 0.22
	var rot_z_detras: float = -0.09
	var ang_escudo: float = 0.0
	var ang_maza: float = 0.0
	var ang_pierna_a: float = 0.0
	var ang_pierna_b: float = 0.0

	match est:
		Enemigo.Estado.REPOSO:
			var latido: float = sin(_tiempo * 2.2) * 0.03
			offset_x_detras = -0.16 + latido
			rot_y_detras = 0.22 + latido * 1.5

		Enemigo.Estado.PERSECUCION:
			_ciclo_paso += delta * 5.5 * rapidez
			var s: float = sin(_ciclo_paso)
			ang_pierna_a = s * 0.55 * rapidez
			ang_pierna_b = -ang_pierna_a
			ang_escudo = -s * 0.2 * rapidez
			ang_maza = s * 0.3 * rapidez
			offset_x_delante = 0.12 + 0.06 * rapidez
			offset_x_detras = -0.16 - 0.06 * rapidez

		Enemigo.Estado.ATAQUE:
			var etapa: Enemigo.Etapa = _enemigo.etapa
			var t_etapa: float = _enemigo.tiempo_en_etapa()
			var es_embestida: bool = _enemigo.ataque_actual != null and _enemigo.ataque_actual.resource_path.contains("embestida")

			match etapa:
				Enemigo.Etapa.PREPARACION:
					var p: float = clampf(t_etapa / 0.6, 0.0, 1.0)
					if es_embestida:
						offset_x_delante = lerpf(0.12, -0.05, p)
						ang_escudo = lerpf(0.0, 0.45, p)
					else:
						# Barrido con la maza hacia atrás
						ang_maza = lerpf(0.0, 1.8, p)
						rot_y_detras = lerpf(0.22, -0.6, p)
				Enemigo.Etapa.ACTIVO:
					if es_embestida:
						offset_x_delante = 0.45
						ang_escudo = 0.6
					else:
						# Golpe de barrido
						ang_maza = -0.8
						rot_y_detras = 0.85
				Enemigo.Etapa.RECUPERACION:
					var p_rec: float = clampf(t_etapa / 0.5, 0.0, 1.0)
					offset_x_delante = lerpf(0.45 if es_embestida else 0.12, 0.12, p_rec)
					ang_escudo = lerpf(0.6 if es_embestida else 0.0, 0.0, p_rec)
					ang_maza = lerpf(-0.8, 0.0, p_rec)
					rot_y_detras = lerpf(0.85, 0.22, p_rec)

		Enemigo.Estado.RUPTURA, Enemigo.Estado.ATURDIDO:
			# Las dos mitades se descuelgan y separan
			offset_x_detras = -0.35
			rot_y_detras = 0.55
			rot_z_detras = -0.35
			ang_escudo = -0.6
			ang_maza = -0.7

	var suave: float = 1.0 - exp(-delta * 12.0)
	if is_instance_valid(_mitad_delantera):
		_mitad_delantera.position.x = lerpf(_mitad_delantera.position.x, offset_x_delante, suave)
	if is_instance_valid(_cuerpo):
		_cuerpo.position.x = lerpf(_cuerpo.position.x, offset_x_delante, suave)
	if is_instance_valid(_mitad_trasera):
		_mitad_trasera.position.x = lerpf(_mitad_trasera.position.x, offset_x_detras, suave)
		_mitad_trasera.rotation.y = lerp_angle(_mitad_trasera.rotation.y, rot_y_detras, suave)
		_mitad_trasera.rotation.z = lerp_angle(_mitad_trasera.rotation.z, rot_z_detras, suave)
	if is_instance_valid(_brazo_escudo):
		_brazo_escudo.rotation.z = lerp_angle(_brazo_escudo.rotation.z, ang_escudo, suave)
	if is_instance_valid(_brazo_maza):
		_brazo_maza.rotation.z = lerp_angle(_brazo_maza.rotation.z, ang_maza, suave)
	if is_instance_valid(_pierna_delantera):
		_pierna_delantera.rotation.z = lerp_angle(_pierna_delantera.rotation.z, ang_pierna_a, suave)
	if is_instance_valid(_pierna_trasera):
		_pierna_trasera.rotation.z = lerp_angle(_pierna_trasera.rotation.z, ang_pierna_b, suave)
