class_name Cadena
extends MultiMeshInstance3D
## Cadena colgante generada por código: eslabones toroidales alternos (uno de
## frente y otro de canto) en una sola llamada de dibujo. Cuelga hacia abajo
## desde el nodo y se balancea levemente.

@export var eslabones: int = 14
@export var tamano_eslabon: float = 0.18
@export var material: Material
@export var balanceo_grados: float = 2.0
@export var velocidad_balanceo: float = 0.6

var _tiempo: float = 0.0
var _rotacion_base: Vector3


func _ready() -> void:
	_rotacion_base = rotation
	_tiempo = randf() * TAU
	var malla := TorusMesh.new()
	malla.inner_radius = tamano_eslabon * 0.55
	malla.outer_radius = tamano_eslabon
	malla.rings = 8
	malla.ring_segments = 6
	malla.material = material
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = malla
	multimesh.instance_count = eslabones
	var paso: float = tamano_eslabon * 1.5
	for i: int in eslabones:
		# Toro tumbado en Y por defecto: se pone vertical y se alterna el giro.
		var base: Basis = Basis(Vector3.RIGHT, PI * 0.5)
		if i % 2 == 1:
			base = Basis(Vector3.UP, PI * 0.5) * base
		multimesh.set_instance_transform(i, Transform3D(base, Vector3(0.0, -i * paso, 0.0)))


func _process(delta: float) -> void:
	_tiempo += delta * velocidad_balanceo
	rotation = _rotacion_base + Vector3(0.0, 0.0, deg_to_rad(balanceo_grados) * sin(_tiempo))
