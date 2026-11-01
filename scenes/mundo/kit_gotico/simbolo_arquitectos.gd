class_name SimboloArquitectos
extends MeshInstance3D
## Símbolo de los Arquitectos grabado en la piedra: reacciona a la presencia de
## Nereth iluminándose (LORE.md §4.1: «símbolos que parecen reaccionar a su presencia»).

@export var color: Color = Color(0.55, 0.8, 1.0)
@export var distancia: float = 5.0
@export var energia_maxima: float = 3.0

var _material: StandardMaterial3D
var _nereth: Nereth


func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.albedo_color = color.darkened(0.7)
	_material.emission_enabled = true
	_material.emission = color
	_material.emission_energy_multiplier = 0.0
	material_override = _material


func _process(delta: float) -> void:
	if _nereth == null:
		_nereth = get_tree().get_first_node_in_group(Nereth.GRUPO) as Nereth
		return
	var cercania: float = 1.0 - clampf(global_position.distance_to(_nereth.global_position) / distancia, 0.0, 1.0)
	var objetivo: float = energia_maxima * cercania * cercania
	_material.emission_energy_multiplier = lerpf(_material.emission_energy_multiplier, objetivo, 1.0 - exp(-4.0 * delta))
	_material.albedo_color = color.darkened(0.7).lerp(color, cercania * 0.5)
