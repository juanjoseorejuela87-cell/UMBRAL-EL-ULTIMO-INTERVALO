extends SceneTree
## Prueba automática de los subtítulos de diálogo y de las frases del Prefecto
## (textos de TAREA-001).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_dialogo.gd
## Código de salida = número de comprobaciones fallidas.

const SALON: String = "res://scenes/niveles/elyndor/salon_prefecto.tscn"

var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	GestorPartida.global().ruta_guardado = "user://prueba_dialogo.json"
	GestorPartida.global().nueva_partida()
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	change_scene_to_file(SALON)
	for i: int in 60:
		await physics_frame
		if current_scene and current_scene.scene_file_path == SALON:
			break
	await _esperar(5)

	# Subtítulos: muestran a quien habla y se sustituyen entre sí
	var primero: Subtitulo = Subtitulo.mostrar(self, "Voz", PackedStringArray(["Uno", "Dos"]))
	await _esperar(3)
	_comprobar(primero.texto_actual() == "Uno", "el subtítulo muestra la primera línea")
	var segundo: Subtitulo = Subtitulo.mostrar(self, "Otra voz", PackedStringArray(["Tres"]))
	await _esperar(3)
	_comprobar(_subtitulos().size() == 1 and _subtitulos()[0] == segundo, "un subtítulo nuevo sustituye al anterior")

	# El Prefecto habla al empezar el combate, al cambiar de fase y al caer
	var prefecto: Prefecto = current_scene.find_children("*", "Prefecto", true, false)[0] as Prefecto
	# Puede haber visto ya a Nereth (sobre todo con el equipo cargado): se repite el saludo desde cero.
	prefecto.set(&"_saludo_dicho", false)
	prefecto.call(&"_entrar_en_alerta")
	await _esperar(3)
	_comprobar(_texto() == prefecto.lineas_inicio[0], "el Prefecto saluda al empezar el combate")
	prefecto.call(&"_entrar_en_alerta")
	await _esperar(3)
	_comprobar(_subtitulos().size() == 1, "el saludo no se repite")
	prefecto.call(&"_entrar_fase", 2)
	await _esperar(3)
	_comprobar(_texto() == prefecto.linea_fase_2, "habla al pasar a la fase 2")
	prefecto.call(&"_entrar_fase", 3)
	await _esperar(3)
	_comprobar(_texto() == prefecto.linea_fase_3, "habla al pasar a la fase 3")
	prefecto.vida.recibir_dano(prefecto.vida.actual + 1.0)
	await _esperar(3)
	_comprobar(_texto() == prefecto.lineas_derrota[0], "al caer recuerda su función original")

	GestorPartida.global().nueva_partida()
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _subtitulos() -> Array[Node]:
	var lista: Array[Node] = []
	for nodo: Node in get_nodes_in_group(Subtitulo.GRUPO):
		if not nodo.is_queued_for_deletion():
			lista.append(nodo)
	return lista


func _texto() -> String:
	var lista: Array[Node] = _subtitulos()
	return (lista[0] as Subtitulo).texto_actual() if not lista.is_empty() else ""


## Los subtítulos avanzan con fotogramas de proceso; se esperan ambos tipos.
func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame
		await process_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
