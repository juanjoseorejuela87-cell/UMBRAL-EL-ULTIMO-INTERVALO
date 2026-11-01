class_name Escombros
extends MultiMeshInstance3D
## Montón de escombros generado por código: piedras de tamaño y giro
## aleatorios en una zona, dibujadas en una sola llamada (barato en GPU integrada).
## La semilla fija el resultado para que el nivel siempre se vea igual.

@export var cantidad: int = 24
@export var zona: Vector3 = Vector3(3.0, 0.6, 1.5)
@export var tamano_min: float = 0.15
@export var tamano_max: float = 0.6
@export var semilla: int = 1
@export var material: Material


func _ready() -> void:
	var azar := RandomNumberGenerator.new()
	azar.seed = semilla
	var malla := BoxMesh.new()
	malla.material = material
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = malla
	multimesh.instance_count = cantidad
	for i: int in cantidad:
		var tamano: float = azar.randf_range(tamano_min, tamano_max)
		var escala := Vector3(tamano * azar.randf_range(0.7, 1.4), tamano * azar.randf_range(0.5, 1.0), tamano * azar.randf_range(0.7, 1.3))
		var giro := Basis.from_euler(Vector3(azar.randf_range(-0.4, 0.4), azar.randf() * TAU, azar.randf_range(-0.4, 0.4)))
		var posicion := Vector3(azar.randf_range(-zona.x, zona.x) * 0.5, escala.y * 0.4 + azar.randf() * zona.y * 0.3, azar.randf_range(-zona.z, zona.z) * 0.5)
		multimesh.set_instance_transform(i, Transform3D(giro.scaled(escala), posicion))
