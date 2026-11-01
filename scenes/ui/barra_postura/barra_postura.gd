class_name BarraPostura
extends Node3D
## Barra de postura flotante (billboard) sobre la cabeza de los enemigos.

const COLOR_NORMAL: Color = Color(0.82, 0.82, 0.88, 0.95)
const COLOR_RUPTURA: Color = Color(0.98, 0.68, 0.15, 1.0)
const ANCHO_RELLENO: float = 0.86

@export var postura: ComponentePostura

@onready var _fondo: MeshInstance3D = $Fondo
@onready var _relleno: MeshInstance3D = $Relleno

var _material_relleno: StandardMaterial3D
var _tween_parpadeo: Tween


func _ready() -> void:
	var mat_orig: Material = _relleno.get_surface_override_material(0)
	if mat_orig:
		_material_relleno = mat_orig.duplicate() as StandardMaterial3D
		_relleno.set_surface_override_material(0, _material_relleno)
	else:
		_material_relleno = StandardMaterial3D.new()
		_material_relleno.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material_relleno.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		_material_relleno.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material_relleno.albedo_color = COLOR_NORMAL
		_relleno.set_surface_override_material(0, _material_relleno)

	if not postura and get_parent():
		postura = get_parent().get_node_or_null("Postura") as ComponentePostura

	if postura:
		postura.cambiada.connect(_al_cambiar_postura)
		postura.rota.connect(_al_romper_postura)
		postura.recuperada.connect(_al_recuperar_postura)
		_actualizar_visual(postura.actual, postura.maximo)
	else:
		visible = false


func _al_cambiar_postura(actual: float, maximo: float) -> void:
	_actualizar_visual(actual, maximo)


func _al_romper_postura() -> void:
	visible = true
	_detener_parpadeo()
	_material_relleno.albedo_color = COLOR_RUPTURA
	_relleno.scale.x = 1.0
	_relleno.position.x = 0.0

	_tween_parpadeo = create_tween().set_loops()
	_tween_parpadeo.tween_property(_material_relleno, "albedo_color:a", 0.35, 0.22)
	_tween_parpadeo.tween_property(_material_relleno, "albedo_color:a", 1.0, 0.22)


func _al_recuperar_postura() -> void:
	_detener_parpadeo()
	_material_relleno.albedo_color = COLOR_NORMAL
	if postura:
		_actualizar_visual(postura.actual, postura.maximo)
	else:
		visible = false


func _actualizar_visual(actual: float, maximo: float) -> void:
	var en_ruptura: bool = postura != null and postura.en_ruptura
	if actual <= 0.0 and not en_ruptura:
		visible = false
		return

	visible = true
	if not en_ruptura:
		_detener_parpadeo()
		_material_relleno.albedo_color = COLOR_NORMAL
		var ratio: float = clampf(actual / maximo, 0.0, 1.0) if maximo > 0.0 else 0.0
		_relleno.scale.x = ratio
		_relleno.position.x = -ANCHO_RELLENO * 0.5 * (1.0 - ratio)


func _detener_parpadeo() -> void:
	if _tween_parpadeo and _tween_parpadeo.is_valid():
		_tween_parpadeo.kill()
	if _material_relleno:
		_material_relleno.albedo_color.a = 1.0
