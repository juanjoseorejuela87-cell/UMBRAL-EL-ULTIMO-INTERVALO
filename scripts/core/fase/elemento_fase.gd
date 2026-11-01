class_name ElementoFase
extends Node
## Hace que su nodo padre exista solo en un estado de la realidad.
## Asigna al padre la capa de colisión de su estado y ajusta su apariencia:
## lo que solo existe en la Realidad se intuye como silueta desde el Desfase;
## lo que solo existe en el Desfase es invisible desde la Realidad.

enum Existencia { REALIDAD, DESFASE, AMBOS }

const COLOR_FANTASMA: Color = Color(0.6, 0.7, 1.0, 0.16)

@export var existe_en: Existencia = Existencia.DESFASE

static var _material_fantasma: StandardMaterial3D

var _geometrias: Array[GeometryInstance3D] = []
var _materiales_originales: Dictionary = {}
var _fase: GestorFase = GestorFase.global()


func _ready() -> void:
	var padre: Node = get_parent()
	if padre is CSGBox3D and (padre as CSGBox3D).use_collision:
		_crear_colision_convexa(padre as CSGBox3D)
	elif "collision_layer" in padre:
		padre.set("collision_layer", _capa())
	_recoger_geometrias(padre)
	_fase.cambiada.connect(_aplicar)
	_aplicar(_fase.estado)


func existe_en_estado(estado: GestorFase.Estado) -> bool:
	match existe_en:
		Existencia.REALIDAD:
			return estado == GestorFase.Estado.REALIDAD
		Existencia.DESFASE:
			return estado == GestorFase.Estado.DESFASE
		_:
			return true


func _capa() -> int:
	match existe_en:
		Existencia.REALIDAD:
			return GestorFase.CAPA_REALIDAD
		Existencia.DESFASE:
			return GestorFase.CAPA_DESFASE
		_:
			return GestorFase.CAPA_COMUN


## La colisión de CSG es cóncava (solo superficie): no detecta a Nereth si está
## completamente dentro, y FaseNereth necesita saberlo para no atraparlo al
## cambiar de estado. Se sustituye por una caja convexa equivalente.
func _crear_colision_convexa(caja: CSGBox3D) -> void:
	caja.use_collision = false
	var cuerpo := StaticBody3D.new()
	cuerpo.name = "ColisionFase"
	cuerpo.collision_layer = _capa()
	cuerpo.collision_mask = 0
	var forma := CollisionShape3D.new()
	var caja_forma := BoxShape3D.new()
	caja_forma.size = caja.size
	forma.shape = caja_forma
	cuerpo.add_child(forma)
	caja.add_child.call_deferred(cuerpo)


func _recoger_geometrias(nodo: Node) -> void:
	var geometria: GeometryInstance3D = nodo as GeometryInstance3D
	# Las formas CSG hijas no se dibujan por separado: solo la raíz.
	if geometria and not (geometria is CSGShape3D and not (geometria as CSGShape3D).is_root_shape()):
		_geometrias.append(geometria)
		_materiales_originales[geometria] = geometria.material_override
	for hijo: Node in nodo.get_children():
		if hijo != self:
			_recoger_geometrias(hijo)


func _aplicar(estado: GestorFase.Estado) -> void:
	var existe: bool = existe_en_estado(estado)
	for geometria: GeometryInstance3D in _geometrias:
		if existe:
			geometria.visible = true
			geometria.material_override = _materiales_originales[geometria]
		elif existe_en == Existencia.REALIDAD:
			geometria.visible = true
			geometria.material_override = _fantasma()
		else:
			geometria.visible = false


static func _fantasma() -> StandardMaterial3D:
	if _material_fantasma == null:
		_material_fantasma = StandardMaterial3D.new()
		_material_fantasma.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material_fantasma.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material_fantasma.albedo_color = COLOR_FANTASMA
		_material_fantasma.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _material_fantasma
