extends SceneTree
## Prueba automática de la Costura de Continuidad (Puntada y Remiendo).
## Uso: Godot_console.exe --headless --path D:\UMBRAL -s res://tests/test_costura.gd
## Código de salida = número de comprobaciones fallidas.

const SALA: String = "res://scenes/niveles/pruebas/sala_costura.tscn"
const RUTA_PRUEBA: String = "user://prueba_costura.json"

var _sala: Node
var _nereth: Nereth
var _partida: GestorPartida
var _fase: GestorFase
var _fallos: int = 0


func _initialize() -> void:
	ConfigControles.registrar()
	_fase = GestorFase.global()
	_partida = GestorPartida.global()
	_partida.ruta_guardado = RUTA_PRUEBA
	_partida.borrar_memoria()
	_borrar_archivo()
	_sala = (load(SALA) as PackedScene).instantiate()
	root.add_child(_sala)
	_nereth = _sala.get_node("Nereth") as Nereth
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	var puente: CSGBox3D = _sala.get_node("Geometria/PuenteCosible") as CSGBox3D
	var cosible: ElementoCosible = puente.get_node("Cosible") as ElementoCosible
	var plataforma: ElementoCosible = _sala.get_node("Geometria/PlataformaCosible/Cosible") as ElementoCosible
	var remiendo: ElementoCosible = _sala.get_node("Geometria/PuenteRemiendo/Cosible") as ElementoCosible
	var ancla: AnclaContinuidad = _sala.get_node("AnclaRemiendo") as AnclaContinuidad
	var res: ComponenteResonancia = _nereth.resonancia
	cosible.duracion = 3.0
	cosible.aviso_final = 0.5
	await _esperar(30)

	# Sin Desfase no hay objetivo ni Costura
	_nereth.reaparecer(Vector3(-7.0, 0.05, 0.0))
	await _esperar(5)
	await _mantener(&"coser", 30)
	_comprobar(not cosible.esta_cosido(), "en la Realidad no se puede coser")

	# Puntada desde el Desfase
	await _pulsar(&"desfase")
	await _esperar(20)
	_comprobar(_nereth.costura.objetivo == cosible, "en el Desfase el puente cercano es el objetivo")
	var antes: float = res.actual
	await _mantener(&"coser", 30)
	_comprobar(cosible.esta_cosido(), "mantener coser hace una Puntada")
	_comprobar(absf((antes - res.actual) - cosible.coste_resonancia) < 1.5, "la Puntada cuesta %.0f de Resonancia (%.1f)" % [cosible.coste_resonancia, antes - res.actual])
	_comprobar(_nereth.estado == Nereth.Estado.SUELO, "Nereth recupera el control tras coser")

	# El puente cosido existe en la Realidad
	await _pulsar(&"desfase")
	await _esperar(5)
	_comprobar(not _fase.en_desfase() and puente.visible, "el puente cosido se ve en la Realidad")
	Input.action_press(&"mover_derecha")
	await _esperar(80)
	Input.action_release(&"mover_derecha")
	_comprobar(_nereth.global_position.x > 0.0 and _nereth.global_position.y > -0.5, "se cruza el puente cosido en la Realidad (x = %.1f)" % _nereth.global_position.x)

	# La Puntada se suelta al terminar
	await _esperar(120)
	_comprobar(not cosible.esta_cosido() and not puente.visible, "al acabar el tiempo la Puntada se suelta")

	# Solo una Puntada a la vez
	_nereth.reaparecer(Vector3(-12.0, 0.05, 0.0))
	cosible.duracion = 30.0
	res.restaurar()
	await _esperar(5)
	await _pulsar(&"desfase")
	await _esperar(20)
	await _mantener(&"coser", 30)
	_comprobar(plataforma.esta_cosido(), "se cose la plataforma elevada")
	_nereth.reaparecer(Vector3(-7.0, 0.05, 0.0))
	await _esperar(5)
	await _mantener(&"coser", 30)
	_comprobar(cosible.esta_cosido() and not plataforma.esta_cosido(), "una nueva Puntada suelta la anterior")
	cosible.soltar()

	# Soltar el botón antes de tiempo cancela
	_nereth.reaparecer(Vector3(-12.0, 0.05, 0.0))
	await _esperar(5)
	plataforma.soltar()
	await _mantener(&"coser", 8)
	await _esperar(30)
	_comprobar(not plataforma.esta_cosido(), "soltar el botón antes de tiempo cancela la Costura")

	# Remiendo: requiere el Ancla estabilizada
	_nereth.fase.reiniciar()
	_nereth.reaparecer(Vector3(9.0, 0.05, 0.0))
	await _esperar(5)
	await _pulsar(&"desfase")
	await _esperar(20)
	_comprobar(_nereth.costura.objetivo == null, "con el Ancla dormida el Remiendo no está disponible")
	ancla.interactuar(_nereth)
	await _esperar(2)
	await _pulsar(&"desfase")
	await _esperar(20)
	var antes_remiendo: float = res.actual
	await _mantener(&"coser", 30)
	_comprobar(remiendo.esta_cosido(), "con el Ancla estabilizada se hace el Remiendo")
	_comprobar(res.actual >= antes_remiendo - 1.5, "el Remiendo no cuesta Resonancia")
	_comprobar(_partida.remiendo_hecho(&"pruebas_remiendo_puente"), "el Remiendo se guarda en la partida")
	await _esperar(60)
	_comprobar(remiendo.esta_cosido(), "el Remiendo no se suelta con el tiempo")

	# Persistencia: al recargar la sala, el Remiendo sigue hecho
	_partida.borrar_memoria()
	_partida.cargar()
	var sala2: Node = (load(SALA) as PackedScene).instantiate()
	root.add_child(sala2)
	await _esperar(2)
	_comprobar((sala2.get_node("Geometria/PuenteRemiendo/Cosible") as ElementoCosible).esta_cosido(), "al recargar, el Remiendo sigue hecho")
	sala2.queue_free()

	_borrar_archivo()
	print("RESULTADO: %s (%d fallos)" % ["OK" if _fallos == 0 else "FALLO", _fallos])
	quit(_fallos)


func _borrar_archivo() -> void:
	if FileAccess.file_exists(RUTA_PRUEBA):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_PRUEBA))


func _mantener(accion: StringName, frames: int) -> void:
	Input.action_press(accion)
	await _esperar(frames)
	Input.action_release(accion)
	await _esperar(2)


func _pulsar(accion: StringName) -> void:
	Input.action_press(accion)
	await _esperar(1)
	Input.action_release(accion)
	await _esperar(1)


func _esperar(frames: int) -> void:
	for i: int in frames:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("  [OK]    " if condicion else "  [FALLO] ") + descripcion)
	if not condicion:
		_fallos += 1
