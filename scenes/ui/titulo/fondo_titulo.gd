class_name FondoTitulo
extends SubViewportContainer
## Fondo 3D interactivo y atmosférico para la pantalla de título (TAREA-013).
## Muestra el estrado de la Cámara del Despertar con kit gótico, polvo, rayo de luz,
## la figura estilizada de Nereth en contemplación y un pulso periódico de Desfase.

const INTERVALO_PULSO_BASE: float = 8.0
const DURACION_PULSO_BASE: float = 1.5

@export var duracion_ciclo_camara: float = 24.0
@export var intervalo_pulso: float = INTERVALO_PULSO_BASE
@export var duracion_pulso: float = DURACION_PULSO_BASE

var _tiempo_camara: float = 0.0
var _tiempo_pulso: float = 0.0
var _en_pulso: bool = false
var _pos_camara_base: Vector3 = Vector3(0.0, 2.2, 7.8)
var _rot_camara_base: Vector3 = Vector3(-0.14, 0.0, 0.0)

var _entorno: Environment
var _material_fantasma: StandardMaterial3D
var _material_simbolo: StandardMaterial3D
var _tween_pulso: Tween

@onready var camara: Camera3D = %Camara
@onready var entorno_nodo: WorldEnvironment = %Entorno
@onready var columnas_fantasma: Node3D = %ColumnasFantasma
@onready var simbolo_dais: MeshInstance3D = %SimboloDais
@onready var figura_nereth: Node3D = %FiguraNereth


func _ready() -> void:
	# Ignorar el ratón para que los clics lleguen intactos a los botones del menú
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stretch = true

	if camara:
		_pos_camara_base = camara.position
		_rot_camara_base = camara.rotation

	if entorno_nodo and entorno_nodo.environment:
		_entorno = entorno_nodo.environment.duplicate()
		entorno_nodo.environment = _entorno

	# Preparar material fantasma para las columnas espectrales
	_material_fantasma = StandardMaterial3D.new()
	_material_fantasma.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material_fantasma.cull_mode = BaseMaterial3D.CULL_DISABLED
	_material_fantasma.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material_fantasma.albedo_color = Color(0.38, 0.72, 1.0, 0.0)
	_material_fantasma.emission_enabled = true
	_material_fantasma.emission = Color(0.35, 0.7, 1.0)
	_material_fantasma.emission_energy_multiplier = 0.0

	if columnas_fantasma:
		for hijo in columnas_fantasma.get_children():
			_asignar_material_recursivo(hijo, _material_fantasma)

	# Preparar material emisivo para el símbolo de los Arquitectos en el estrado
	if simbolo_dais:
		_material_simbolo = StandardMaterial3D.new()
		_material_simbolo.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material_simbolo.albedo_color = Color(0.25, 0.45, 0.7, 0.8)
		_material_simbolo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material_simbolo.emission_enabled = true
		_material_simbolo.emission = Color(0.4, 0.75, 1.0)
		_material_simbolo.emission_energy_multiplier = 0.25
		simbolo_dais.material_override = _material_simbolo


func _process(delta: float) -> void:
	_actualizar_camara(delta)
	_actualizar_pulso(delta)


func _actualizar_camara(delta: float) -> void:
	if camara == null:
		return
	_tiempo_camara += delta
	var fase: float = _tiempo_camara * (TAU / maxf(duracion_ciclo_camara, 1.0))
	var balanceo_x: float = sin(fase) * 0.4
	var balanceo_y: float = sin(fase * 1.5) * 0.06
	camara.position = _pos_camara_base + Vector3(balanceo_x, balanceo_y, 0.0)
	camara.rotation.y = _rot_camara_base.y - balanceo_x * 0.03
	camara.rotation.x = _rot_camara_base.x + sin(fase * 1.2) * 0.01


func _actualizar_pulso(delta: float) -> void:
	if _en_pulso:
		return
	_tiempo_pulso += delta
	if _tiempo_pulso >= intervalo_pulso:
		_tiempo_pulso = 0.0
		lanzar_pulso_desfase()


## Dispara el pulso visual de Desfase de ~1.5 s sin alterar el estado global de Fase.
func lanzar_pulso_desfase() -> void:
	if _tween_pulso and _tween_pulso.is_running():
		_tween_pulso.kill()

	_en_pulso = true
	var dur_subida: float = duracion_pulso * 0.25
	var dur_mantenimiento: float = duracion_pulso * 0.45
	var dur_bajada: float = duracion_pulso * 0.30

	_tween_pulso = create_tween()
	_tween_pulso.set_parallel(true)

	# 1. Niebla fría azul y luz ambiental
	if _entorno:
		_tween_pulso.tween_property(_entorno, "fog_light_color", Color(0.12, 0.32, 0.58), dur_subida)
		_tween_pulso.tween_property(_entorno, "fog_density", 0.055, dur_subida)
		_tween_pulso.tween_property(_entorno, "ambient_light_color", Color(0.18, 0.38, 0.65), dur_subida)

	# 2. Materialización de columnas fantasma
	if _material_fantasma:
		_tween_pulso.tween_property(_material_fantasma, "albedo_color:a", 0.65, dur_subida)
		_tween_pulso.tween_property(_material_fantasma, "emission_energy_multiplier", 1.4, dur_subida)

	# 3. Brillo del símbolo en el estrado
	if _material_simbolo:
		_tween_pulso.tween_property(_material_simbolo, "emission_energy_multiplier", 2.6, dur_subida)

	# Mantenimiento y regreso a la Realidad
	var cadena := _tween_pulso.chain()
	cadena.tween_interval(dur_mantenimiento)

	var regreso := cadena.chain()
	regreso.set_parallel(true)
	if _entorno:
		regreso.tween_property(_entorno, "fog_light_color", Color(0.20, 0.18, 0.24), dur_bajada)
		regreso.tween_property(_entorno, "fog_density", 0.035, dur_bajada)
		regreso.tween_property(_entorno, "ambient_light_color", Color(0.22, 0.20, 0.25), dur_bajada)
	if _material_fantasma:
		regreso.tween_property(_material_fantasma, "albedo_color:a", 0.0, dur_bajada)
		regreso.tween_property(_material_fantasma, "emission_energy_multiplier", 0.0, dur_bajada)
	if _material_simbolo:
		regreso.tween_property(_material_simbolo, "emission_energy_multiplier", 0.25, dur_bajada)

	_tween_pulso.chain().tween_callback(func() -> void:
		_en_pulso = false
	)


func esta_en_pulso() -> bool:
	return _en_pulso


func tiene_camara_activa() -> bool:
	return camara != null and camara.current


func tiene_figura_nereth() -> bool:
	return figura_nereth != null


func _asignar_material_recursivo(nodo: Node, mat: Material) -> void:
	if nodo is GeometryInstance3D:
		nodo.material_override = mat
	for hijo in nodo.get_children():
		_asignar_material_recursivo(hijo, mat)
