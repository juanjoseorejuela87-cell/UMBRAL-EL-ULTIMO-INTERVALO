class_name FiguraEcoRezagado
extends Node3D
## Controlador de animación procedural para el Eco Rezagado (TAREA-012).
## Anima la figura etérea flotante, sus garras y sus jirones espectrales.

var _enemigo: Enemigo
var _tiempo: float = 0.0

@onready var _cuerpo: MeshInstance3D = get_parent().get_node_or_null(^"Cuerpo")
@onready var _cabeza: MeshInstance3D = get_parent().get_node_or_null(^"Cabeza")
@onready var _piernas: Node3D = get_parent().get_node_or_null(^"Piernas")
@onready var _brazo_delante: Node3D = get_parent().get_node_or_null(^"BrazoDelante")
@onready var _brazo_detras: Node3D = get_parent().get_node_or_null(^"BrazoDetras")
@onready var _jirones: Array[Node3D] = []


func _ready() -> void:
	_enemigo = owner as Enemigo
	if _enemigo == null and get_parent():
		_enemigo = get_parent().get_parent() as Enemigo

	var contenedor_jirones: Node3D = get_parent().get_node_or_null(^"Jirones")
	if contenedor_jirones:
		for hijo in contenedor_jirones.get_children():
			if hijo is Node3D:
				_jirones.append(hijo as Node3D)


func _process(delta: float) -> void:
	if _enemigo == null or not is_instance_valid(_cuerpo):
		return

	_tiempo += delta
	var vel_x: float = _enemigo.velocity.x
	var rapidez: float = clampf(absf(vel_x) / maxf(_enemigo.velocidad, 0.01), 0.0, 1.0)
	var est: Enemigo.Estado = _enemigo.estado

	# Flotación vertical suave
	var vaiven: float = sin(_tiempo * 3.2) * 0.06
	var inclinacion: float = -0.16 * rapidez

	var ang_brazo_delante: float = 0.2
	var ang_brazo_detras: float = -0.2

	match est:
		Enemigo.Estado.REPOSO:
			ang_brazo_delante = 0.15 + sin(_tiempo * 2.8) * 0.08
			ang_brazo_detras = -0.15 - sin(_tiempo * 2.8) * 0.08

		Enemigo.Estado.PERSECUCION:
			inclinacion = -0.25 * rapidez
			ang_brazo_delante = -0.3 + sin(_tiempo * 6.0) * 0.25 * rapidez
			ang_brazo_detras = 0.3 - sin(_tiempo * 6.0) * 0.25 * rapidez

		Enemigo.Estado.ATAQUE:
			var etapa: Enemigo.Etapa = _enemigo.etapa
			var t_etapa: float = _enemigo.tiempo_en_etapa()
			match etapa:
				Enemigo.Etapa.PREPARACION:
					var p: float = clampf(t_etapa / 0.4, 0.0, 1.0)
					ang_brazo_delante = lerpf(0.2, 2.3, p)
					inclinacion = 0.12 * p
				Enemigo.Etapa.ACTIVO:
					ang_brazo_delante = -0.75
					inclinacion = -0.35
				Enemigo.Etapa.RECUPERACION:
					var p_rec: float = clampf(t_etapa / 0.3, 0.0, 1.0)
					ang_brazo_delante = lerpf(-0.75, 0.2, p_rec)
					inclinacion = lerpf(-0.35, 0.0, p_rec)

		Enemigo.Estado.RUPTURA, Enemigo.Estado.ATURDIDO:
			inclinacion = 0.22 + sin(_tiempo * 25.0) * 0.06
			ang_brazo_delante = -0.8
			ang_brazo_detras = -0.8
			vaiven = -0.1

	var suave: float = 1.0 - exp(-delta * 14.0)
	_cuerpo.position.y = lerpf(_cuerpo.position.y, 0.85 + vaiven, suave)
	_cuerpo.rotation.z = lerp_angle(_cuerpo.rotation.z, inclinacion, suave)

	if is_instance_valid(_cabeza):
		_cabeza.position.y = _cuerpo.position.y + 0.48
		_cabeza.rotation.z = lerp_angle(_cabeza.rotation.z, inclinacion * 0.8, suave)

	if is_instance_valid(_piernas):
		_piernas.position.y = _cuerpo.position.y - 0.48
		_piernas.rotation.z = lerp_angle(_piernas.rotation.z, -inclinacion * 0.5, suave)

	if is_instance_valid(_brazo_delante):
		_brazo_delante.position.y = _cuerpo.position.y + 0.26
		_brazo_delante.rotation.z = lerp_angle(_brazo_delante.rotation.z, ang_brazo_delante, suave)

	if is_instance_valid(_brazo_detras):
		_brazo_detras.position.y = _cuerpo.position.y + 0.26
		_brazo_detras.rotation.z = lerp_angle(_brazo_detras.rotation.z, ang_brazo_detras, suave)

	# Animación de jirones flotantes
	for i: int in _jirones.size():
		var jiron: Node3D = _jirones[i]
		if is_instance_valid(jiron):
			var onda: float = sin(_tiempo * 5.0 - i * 0.9) * 0.15
			var viento: float = -0.45 * rapidez
			jiron.rotation.z = lerp_angle(jiron.rotation.z, viento + onda, suave)
