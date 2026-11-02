extends SceneTree
## Prueba unitaria de los habitantes atrapados en bucles de memoria (TAREA-021).
## Valida que Aldous, Elspeth y Gowan existen en las Ruinas bajo Elyndor,
## que no tienen colisiones bloqueantes ni luces OmniLight3D, y que al interactuar
## con Nereth cerca muestran sus líneas de diálogo y no lo hacen desde lejos.
##
## Uso:
##   Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_habitantes.gd

const BARRIO: String = "res://scenes/niveles/elyndor/barrio_desprendido.tscn"
const RUTA_PRUEBA: String = "user://prueba_habitantes.json"

var _fallos: int = 0
var _nereth: Nereth


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = RUTA_PRUEBA
	GestorPartida.global().nueva_partida()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	change_scene_to_file(BARRIO)
	for i: int in 60:
		await physics_frame
		if current_scene and current_scene.scene_file_path == BARRIO:
			break
	await _esperar(10)

	_nereth = current_scene.find_child("Nereth", true, false) as Nereth
	_comprobar(_nereth != null, "Nereth está instanciado en las Ruinas")

	var nodo_habitantes: Node = current_scene.find_child("Habitantes", true, false)
	_comprobar(nodo_habitantes != null, "el nodo contenedor Habitantes existe en la escena")

	var aldous: Habitante = nodo_habitantes.get_node_or_null("Aldous") as Habitante if nodo_habitantes else null
	var elspeth: Habitante = nodo_habitantes.get_node_or_null("Elspeth") as Habitante if nodo_habitantes else null
	var gowan: Habitante = nodo_habitantes.get_node_or_null("Gowan") as Habitante if nodo_habitantes else null

	# 1. Existencia y configuración de nombres, líneas y gestos
	_comprobar(aldous != null, "Aldous está instanciado en las Ruinas")
	if aldous:
		_comprobar(aldous.nombre == "Aldous", "el nombre de Aldous es correcto")
		_comprobar(aldous.lineas.size() == 3, "Aldous tiene sus 3 líneas canónicas")
		_comprobar(aldous.gesto == &"linterna", "el gesto de Aldous es linterna")

	_comprobar(elspeth != null, "Elspeth está instanciada en las Ruinas")
	if elspeth:
		_comprobar(elspeth.nombre == "Elspeth", "el nombre de Elspeth es correcto")
		_comprobar(elspeth.lineas.size() == 3, "Elspeth tiene sus 3 líneas canónicas")
		_comprobar(elspeth.gesto == &"manto", "el gesto de Elspeth es manto")

	_comprobar(gowan != null, "Gowan está instanciado en las Ruinas")
	if gowan:
		_comprobar(gowan.nombre == "Gowan", "el nombre de Gowan es correcto")
		_comprobar(gowan.lineas.size() == 3, "Gowan tiene sus 3 líneas canónicas")
		_comprobar(gowan.gesto == &"llave", "el gesto de Gowan es llave")

	# 2. Sin luces OmniLight3D
	var tiene_luces: bool = false
	for h: Habitante in [aldous, elspeth, gowan]:
		if h and not h.find_children("*", "OmniLight3D", true, false).is_empty():
			tiene_luces = true
	_comprobar(not tiene_luces, "ningún habitante utiliza luces OmniLight3D")

	# 3. Sin colisiones físicas que bloqueen a Nereth ni enemigos
	var tiene_cuerpos_solidos: bool = false
	for h: Habitante in [aldous, elspeth, gowan]:
		if h == null:
			continue
		if not (h is Area3D) or h.collision_layer != 0:
			tiene_cuerpos_solidos = true
		if not h.find_children("*", "StaticBody3D", true, false).is_empty():
			tiene_cuerpos_solidos = true
		if not h.find_children("*", "AnimatableBody3D", true, false).is_empty():
			tiene_cuerpos_solidos = true
	_comprobar(not tiene_cuerpos_solidos, "ningún habitante añade colisiones físicas que bloqueen")

	# 4. Con Nereth lejos, pulsar interactuar NO muestra subtítulos
	_nereth.reaparecer(Vector3(-16.0, 0.2, 0.0))
	await _esperar(10)
	_limpiar_subtitulos()
	await _pulsar(&"interactuar")
	await _esperar(5)
	_comprobar(_subtitulos().is_empty(), "con Nereth lejos, pulsar interactuar NO muestra subtítulos")

	# 5. Con Nereth cerca de Aldous, pulsar interactuar muestra su primera línea
	if aldous:
		_nereth.reaparecer(aldous.global_position)
		await _esperar(10)
		_limpiar_subtitulos()
		await _pulsar(&"interactuar")
		await _esperar(5)
		var sub_aldous: Subtitulo = _subtitulo_actual()
		_comprobar(sub_aldous != null and sub_aldous.texto_actual() == aldous.lineas[0],
				"con Nereth cerca de Aldous, interactuar muestra su primera línea")

	# 6. Con Nereth cerca de Elspeth, pulsar interactuar muestra su primera línea
	if elspeth:
		_nereth.reaparecer(elspeth.global_position)
		await _esperar(10)
		_limpiar_subtitulos()
		await _pulsar(&"interactuar")
		await _esperar(5)
		var sub_elspeth: Subtitulo = _subtitulo_actual()
		_comprobar(sub_elspeth != null and sub_elspeth.texto_actual() == elspeth.lineas[0],
				"con Nereth cerca de Elspeth, interactuar muestra su primera línea")

	# 7. Con Nereth cerca de Gowan, pulsar interactuar muestra su primera línea
	if gowan:
		_nereth.reaparecer(gowan.global_position)
		await _esperar(10)
		_limpiar_subtitulos()
		await _pulsar(&"interactuar")
		await _esperar(5)
		var sub_gowan: Subtitulo = _subtitulo_actual()
		_comprobar(sub_gowan != null and sub_gowan.texto_actual() == gowan.lineas[0],
				"con Nereth cerca de Gowan, interactuar muestra su primera línea")

	# 8. Al volver a interactuar, el habitante repite sus líneas (bucle de memoria)
	if aldous:
		_nereth.reaparecer(aldous.global_position)
		await _esperar(10)
		_limpiar_subtitulos()
		await _pulsar(&"interactuar")
		await _esperar(5)
		var sub_repetido: Subtitulo = _subtitulo_actual()
		_comprobar(sub_repetido != null and sub_repetido.texto_actual() == aldous.lineas[0],
				"al volver a interactuar se repiten las mismas líneas (bucle de memoria)")

	_limpiar_subtitulos()
	await _esperar(5)
	_borrar_archivo()

	print("\nRESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(clamp(_fallos, 0, 125))


func _subtitulos() -> Array[Node]:
	return get_nodes_in_group(Subtitulo.GRUPO)


func _subtitulo_actual() -> Subtitulo:
	var subs: Array[Node] = _subtitulos()
	return subs[0] as Subtitulo if not subs.is_empty() else null


func _limpiar_subtitulos() -> void:
	for s: Node in _subtitulos():
		s.queue_free()


func _pulsar(accion: StringName) -> void:
	Input.action_press(accion)
	await _esperar(2)
	Input.action_release(accion)
	await _esperar(2)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1


func _borrar_archivo() -> void:
	if FileAccess.file_exists(RUTA_PRUEBA):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_PRUEBA))
