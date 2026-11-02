extends SceneTree
## Muestra un modelo 3D (.glb/.tscn) girando delante de una cámara, para revisar
## modelos generados sin abrir el editor, e informa de su tamaño y triángulos.
## Uso: Godot_console.exe --path D:\UMBRAL -s res://tools/vista_modelo.gd --write-movie C:\ruta\f.png --fixed-fps 10 --quit-after 40 -- res://ruta/modelo.glb


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Falta la ruta del modelo")
		quit(1)
		return
	var raiz := Node3D.new()
	root.add_child(raiz)
	var modelo: Node3D = (load(args[0]) as PackedScene).instantiate() as Node3D
	raiz.add_child(modelo)

	# Medidas y triángulos
	var caja := AABB()
	var triangulos: int = 0
	var primera: bool = true
	for nodo: Node in modelo.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = nodo as MeshInstance3D
		var c: AABB = mi.global_transform * mi.get_aabb()
		caja = c if primera else caja.merge(c)
		primera = false
		for s: int in mi.mesh.get_surface_count():
			var arrays: Array = mi.mesh.surface_get_arrays(s)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			triangulos += (indices.size() if indices.size() > 0 else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	print("Tamaño: %s  Centro: %s  Triángulos: %d" % [caja.size, caja.get_center(), triangulos])

	var centro: Vector3 = caja.get_center()
	var alto: float = maxf(caja.size.y, 0.01)
	var camara := Camera3D.new()
	raiz.add_child(camara)
	camara.position = centro + Vector3(0, 0, alto * 1.6)
	camara.look_at(centro)
	var sol := DirectionalLight3D.new()
	raiz.add_child(sol)
	sol.rotation_degrees = Vector3(-40, 30, 0)
	var entorno := WorldEnvironment.new()
	entorno.environment = Environment.new()
	entorno.environment.background_mode = Environment.BG_COLOR
	entorno.environment.background_color = Color(0.25, 0.25, 0.28)
	entorno.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.environment.ambient_light_color = Color(0.6, 0.6, 0.65)
	raiz.add_child(entorno)
	_girar.call_deferred(modelo, centro)


func _girar(modelo: Node3D, centro: Vector3) -> void:
	var pivote := Node3D.new()
	modelo.get_parent().add_child(pivote)
	pivote.position = centro
	modelo.reparent(pivote)
	while true:
		await process_frame
		pivote.rotation.y += TAU / 40.0
