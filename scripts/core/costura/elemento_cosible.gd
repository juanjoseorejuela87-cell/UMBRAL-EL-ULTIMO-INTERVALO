class_name ElementoCosible
extends Node3D
## Marca a su padre como Elemento de Doble Estado: muestra sus Hilos en el
## Desfase y permite coserlo con la Costura de Continuidad.
## - Puntada: el elemento existe en ambos estados durante un tiempo.
## - Remiendo: permanente; requiere un Ancla estabilizada y se guarda.
## Necesita un ElementoFase hermano. Diseño: documentation/GAMEPLAY.md §4.

signal cosido
signal soltado

enum Tipo { PUNTADA, REMIENDO }

const GRUPO: StringName = &"cosibles"
const COLOR_PUNTADA: Color = Color(0.45, 0.85, 1.0)
const COLOR_REMIENDO: Color = Color(1.0, 0.8, 0.4)

@export var tipo: Tipo = Tipo.PUNTADA
@export var duracion: float = 10.0
## Segundos finales en los que la Puntada parpadea antes de soltarse.
@export var aviso_final: float = 2.0
@export var coste_resonancia: float = 25.0
## Solo Remiendo: identificador único para el guardado.
@export var id: StringName = &""
## Solo Remiendo: Ancla que debe estar estabilizada para poder coser.
@export var ancla_requerida: AnclaContinuidad

var _elemento: ElementoFase
var _restante: float = 0.0
var _marca: MeshInstance3D
var _material_marca: StandardMaterial3D
var _resaltado: bool = false
var _fase: GestorFase = GestorFase.global()


func _ready() -> void:
	add_to_group(GRUPO)
	for hermano: Node in get_parent().get_children():
		if hermano is ElementoFase:
			_elemento = hermano
	if _elemento == null:
		push_error("ElementoCosible sin ElementoFase hermano en %s" % get_path())
		return
	_crear_marca()
	if tipo == Tipo.REMIENDO and GestorPartida.global().remiendo_hecho(id):
		_elemento.cosido = true
	_fase.cambiada.connect(_actualizar_marca.unbind(1))
	_actualizar_marca()


func esta_cosido() -> bool:
	return _elemento != null and _elemento.cosido


## True si ahora mismo se puede coser (sin contar la Resonancia).
func disponible() -> bool:
	if _elemento == null or esta_cosido():
		return false
	if tipo == Tipo.REMIENDO:
		return ancla_requerida == null or ancla_requerida.estado == AnclaContinuidad.Estado.ESTABILIZADA
	return true


func coste() -> float:
	return coste_resonancia if tipo == Tipo.PUNTADA else 0.0


func tiempo_restante() -> float:
	return _restante


func coser() -> void:
	_elemento.cosido = true
	if tipo == Tipo.PUNTADA:
		_restante = duracion
	else:
		GestorPartida.global().registrar_remiendo(id)
	cosido.emit()
	_actualizar_marca()


## Suelta una Puntada (los Remiendos no se sueltan).
func soltar() -> void:
	if tipo == Tipo.REMIENDO or not esta_cosido():
		return
	_restante = 0.0
	_elemento.cosido = false
	soltado.emit()
	_actualizar_marca()


func resaltar(activo: bool) -> void:
	_resaltado = activo
	_actualizar_marca()


## Distancia desde un punto al elemento (a su caja si es un CSGBox3D).
func distancia_a(punto: Vector3) -> float:
	var padre: Node3D = get_parent() as Node3D
	if padre is CSGBox3D:
		var local: Vector3 = padre.to_local(punto)
		var mitad: Vector3 = (padre as CSGBox3D).size * 0.5
		var cercano: Vector3 = local.clamp(-mitad, mitad)
		return padre.to_global(cercano).distance_to(punto)
	return padre.global_position.distance_to(punto)


func _physics_process(delta: float) -> void:
	if tipo != Tipo.PUNTADA or _restante <= 0.0:
		return
	_restante -= delta
	if _restante <= 0.0:
		soltar()
	elif _restante <= aviso_final:
		_elemento.parpadear(fmod(_restante, 0.25) < 0.08)


func _crear_marca() -> void:
	var malla := SphereMesh.new()
	malla.radius = 0.18
	malla.height = 0.5
	malla.radial_segments = 4
	malla.rings = 2
	_material_marca = StandardMaterial3D.new()
	_material_marca.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material_marca.albedo_color = COLOR_REMIENDO if tipo == Tipo.REMIENDO else COLOR_PUNTADA
	_marca = MeshInstance3D.new()
	_marca.mesh = malla
	_marca.material_override = _material_marca
	_marca.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var altura: float = 1.0
	if get_parent() is CSGBox3D:
		altura = (get_parent() as CSGBox3D).size.y * 0.5 + 0.6
	_marca.position = Vector3(0.0, altura, 0.0)
	add_child(_marca)


## Los Hilos solo se ven en el Desfase y mientras el elemento no esté cosido.
func _actualizar_marca() -> void:
	if _marca == null:
		return
	_marca.visible = _fase.en_desfase() and not esta_cosido()
	_marca.scale = Vector3.ONE * (1.6 if _resaltado else 1.0)
