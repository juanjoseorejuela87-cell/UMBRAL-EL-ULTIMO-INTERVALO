extends SceneTree
## Captura fotogramas de una sala con Nereth en una posición, para revisar el
## aspecto visual sin abrir el editor.
## Uso (los PNG salen numerados junto a la ruta indicada):
##   Godot_console.exe --path D:\UMBRAL -s res://tools/captura_sala.gd --write-movie C:\ruta\f.png --fixed-fps 30 --quit-after 40 -- <escena.tscn> <x> <y> [desfase] [accion...]
## Las acciones extra (p. ej. mover_derecha, atacar_ligero) se mantienen pulsadas;
## «llamar=metodo» llama a ese método de la escena (p. ej. llamar=mostrar_sonido).
## Ejemplo: ... -- res://scenes/niveles/elyndor/salon_prefecto.tscn 19 0.5 desfase


func _initialize() -> void:
	ConfigControles.registrar()
	_preparar.call_deferred()


func _preparar() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("Faltan argumentos: <escena> <x> <y> [desfase]")
		quit(1)
		return
	change_scene_to_file(args[0])
	for i: int in 20:
		await physics_frame
		if current_scene and current_scene.scene_file_path == args[0]:
			break
	await physics_frame
	var nereth: Nereth = get_first_node_in_group(&"jugador") as Nereth
	if nereth:
		nereth.reaparecer(Vector3(float(args[1]), float(args[2]), 0.0))
		var camara: Node = current_scene.find_child("CamaraLateral", true, false)
		if camara and camara.has_method(&"saltar_a_objetivo"):
			camara.call(&"saltar_a_objetivo")
	for i: int in range(3, args.size()):
		if args[i].begins_with("llamar="):
			current_scene.call(StringName(args[i].trim_prefix("llamar=")))
		elif args[i] == "desfase":
			GestorFase.global().cambiar(GestorFase.Estado.DESFASE)
		elif InputMap.has_action(StringName(args[i])):
			Input.action_press(StringName(args[i]))
